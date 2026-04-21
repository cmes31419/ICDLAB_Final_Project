"""
GII-BCH 系統 (完整修正版)
===========================
修正了原始 gii_bch.py 的四個主要問題：

【Bug 1】encode() 缺少 GII pi 向量
  原碼只是對每個 sub-codeword 獨立做 BCH 編碼，嵌套碼字 c~_0 不滿足 C_1
  的 syndrome 條件，導致 Stage 2 解碼完全無法運作。
  修正：加入 pi 向量修正，令 c~_0 = c_0 ⊕ c_1 ⊕ ... ⊕ c_{m-1} 是合法 C_1 碼字。

【Bug 2】decode() Stage 2 高階 syndrome 來源錯誤
  原碼直接對 received[i] 計算更多 syndromes，但 received[i] 只是 C_0 碼字，
  j > 2t₀ 的 syndrome 並不代表純誤差資訊。
  修正：利用嵌套碼字 c~₀ = ⊕ all_received 的 syndromes，因為編碼器保證
  c~₀_sent 的 syndromes 全為零 (j=1..2tv)，所以 S_j(c~₀_rcv) = S_j(e_i)。

【Bug 3】decode() Stage 2 重新開始 BM 而非延伸
  原碼在 Stage 2 呼叫 bch_decode_with_syndromes() 重新解碼。
  修正：保存 Stage 1 的 BM 狀態 (Λ, B, b, L)，用完整 syndrome 序列繼續迭代
  (論文 Section III-A nested KES 延伸)。

【Bug 4】Stage 1 誤修正後不啟動 Stage 2
  當錯誤數 > t₀ 時，BM 可能找到「虛假」的誤差定位多項式通過 Chien 檢查，
  但修正結果是錯的（残留誤差更多）。此時 Stage 2 不會被觸發。
  修正：Stage 1 修正後，用嵌套碼字的 syndromes 確認是否真正成功。
  若嵌套 syndromes 不全為零，撤銷 Stage 1 修正並觸發 Stage 2。

參考：Xie & Zhang, "Reduced-Complexity Key Equation Solvers for GII BCH
Decoders," IEEE TCAS-I, Vol. 67, No. 12, Dec. 2020.
"""

import random
import galois
from ICDLAB.ICDLAB_Final_Project.python.hsu_test.galois_field import GF


class GII_BCH_System:

    def __init__(self, q, m, v, t_list):
        """
        q      : GF(2^q) 的擴展次數，碼長 n = 2^q - 1
        m      : sub-codeword 數量（interleaves）
        v      : 嵌套層數（目前完整支援 v=0 純 BCH 和 v=1 GII）
        t_list : 各層糾錯能力 [t₀, t₁, ..., tᵥ]，非遞減
        """
        assert len(t_list) == v + 1,                   "t_list 長度必須是 v+1"
        assert all(t_list[i] <= t_list[i+1] for i in range(v)), \
                                                       "t_list 必須非遞減"
        assert v <= 1, "本實作完整支援 v=0（純 BCH）與 v=1（單層 GII）"

        self.gf     = GF(q)
        self.m      = m
        self.v      = v
        self.t_list = t_list
        self.n      = self.gf.power_max          # 2^q − 1
        self._field = galois.GF(2 ** q)
        self._alpha = self._field.primitive_element

        self.g_polys = self._build_generators()
        self.w       = [len(g) - 1 for g in self.g_polys]   # 各層 parity 長度

    # ─────────────────────────────────────────────
    # 生成多項式建構
    # ─────────────────────────────────────────────

    def _build_generators(self):
        gs = []
        for t in self.t_list:
            g = [1]; processed = set()
            for r in range(1, 2 * t + 1):
                r_mod = r % self.n
                if r_mod not in processed:
                    coset = self.gf.get_cyclotomic_coset(r_mod)
                    g = self.gf.poly_mul(g, self.gf.get_minimal_polynomial(coset))
                    processed.update(coset)
            gs.append(g)
        return gs

    # ─────────────────────────────────────────────
    # GF(2) 多項式輔助（ascending-degree：poly[k] = x^k 係數）
    # ─────────────────────────────────────────────

    @staticmethod
    def _poly_add(p1, p2):
        sz = max(len(p1), len(p2)); r = [0] * sz
        for i, v in enumerate(p1): r[i] ^= v
        for i, v in enumerate(p2): r[i] ^= v
        while len(r) > 1 and r[-1] == 0: r.pop()
        return r

    @staticmethod
    def _poly_div(dividend, divisor):
        """GF(2) 多項式除法，回傳餘式。"""
        rem = list(dividend)
        while len(rem) >= len(divisor):
            if rem[-1] == 1:
                shift = len(rem) - len(divisor)
                for i in range(len(divisor)):
                    rem[i + shift] ^= divisor[i]
            rem.pop()
        return rem

    @staticmethod
    def _L_w(poly, w):
        """取最低 w 項並補零至長度 w。"""
        return (poly[:w] + [0] * w)[:w]

    @staticmethod
    def _U_w(poly, w):
        """丟棄最低 w 項。"""
        return poly[w:] if len(poly) > w else []

    # ─────────────────────────────────────────────
    # 編碼【Bug 1 修正】
    # ─────────────────────────────────────────────

    def encode(self, data_list):
        """
        GII-BCH 系統編碼（v=0 或 v=1）。

        data_list[i] 的長度須為 n − w[layer_i]，其中
            layer_i = 0        若 i ≥ v
            layer_i = v − i    若 i < v
        """
        n, m, v = self.n, self.m, self.v

        if v == 0:
            # 純 BCH：每個 sub-codeword 獨立編碼
            cw = []
            for i in range(m):
                w0 = self.w[0]; g = self.g_polys[0]
                rem = self._L_w(self._poly_div([0]*w0 + data_list[i], g), w0)
                cw.append(rem + data_list[i])
            return cw

        # v = 1：GII 嵌套編碼
        c = [None] * m

        # Step 1：c[1..m-1] 用 g₀ 獨立編碼
        for i in range(m - 1, 0, -1):
            w0 = self.w[0]; g = self.g_polys[0]
            rem = self._L_w(self._poly_div([0]*w0 + data_list[i], g), w0)
            c[i] = rem + data_list[i]

        # Step 2：c[0] 用 g₁ + pi 向量修正
        # pi = [1, 1, ..., 1]（m−1 個），代表：
        #   f₀ = c[1] ⊕ c[2] ⊕ ... ⊕ c[m-1]
        # 確保 c~₀ = c[0] ⊕ c[1] ⊕ ... ⊕ c[m-1] 是合法 C₁ 碼字。
        w1 = self.w[1]; g1 = self.g_polys[1]
        f = []
        for j in range(1, m):
            f = self._poly_add(f, c[j])

        u_f  = self._U_w(f, w1)
        l_f  = self._L_w(f, w1)
        d_u  = self._poly_add(data_list[0], u_f)
        pstr = self._L_w(self._poly_div([0]*w1 + d_u, g1), w1)
        c[0] = self._L_w(self._poly_add(pstr, l_f), w1) + data_list[0]

        return c

    # ─────────────────────────────────────────────
    # 解碼【Bug 2、3、4 修正】
    # ─────────────────────────────────────────────

    def decode(self, received):
        """
        兩階段 GII-BCH 解碼。

        Stage 1：各 sub-codeword 獨立 BCH 解碼（糾正 ≤ t₀ 個錯誤）。
                 BM 狀態（Λ, B, b, L）從原始收到字計算，保留供 Stage 2 使用。
                 修正後用嵌套 syndrome 驗證，偵測 Stage 1 誤修正。

        Stage 2：若有 sub-codeword 失敗（包含偵測到的誤修正），
                 用 c~₀ = ⊕(all received) 的高階 syndromes 延伸 BM，
                 可糾正最多 tᵥ 個錯誤。
        """
        n, m, v = self.n, self.m, self.v
        t0, tv = self.t_list[0], self.t_list[v]

        corrected  = [list(r) for r in received]
        bm_orig    = [None] * m   # 原始 received 的 BM 狀態（供 Stage 2 使用）
        stage1_ok  = [False] * m
        status = [{"success": False, "layer": 0, "err": 0} for _ in range(m)]

        # ──── Stage 1：獨立 BCH 解碼 ────
        for i in range(m):
            S = self._syndromes(received[i], t0)

            if all(s == 0 for s in S):
                stage1_ok[i] = True
                bm_orig[i]   = (None, None, None, 0)
                status[i]    = {"success": True, "layer": 0, "err": 0}
                continue

            Lam, B, b, L = self._berlekamp_massey(S)
            bm_orig[i]   = (Lam, B, b, L)   # 保存原始 BM 狀態（修正前）
            locs = self._chien_search(Lam)
            deg  = self._poly_degree(Lam)

            if len(locs) == deg and deg > 0:
                ci = received[i][:]
                for pos in locs: ci[pos] ^= 1
                corrected[i] = ci
                stage1_ok[i] = True          # 暫定成功
                status[i]    = {"success": True, "layer": 0, "err": deg}

        # ──── Stage 1 誤修正偵測（Bug 4）────
        # 計算嵌套碼字的 syndromes；若不全為零，表示有 Stage 1 誤修正。
        if v >= 1 and any(stage1_ok):
            c_tilde = [0] * n
            for j in range(m):
                for k in range(n): c_tilde[k] ^= corrected[j][k]
            nested_s = self._syndromes_range(c_tilde, 1, 2 * tv)

            if any(s != 0 for s in nested_s):
                # 有誤修正：撤銷所有 Stage 1 修正（除了 syndrome 本為零的那些），
                # 讓 Stage 2 用正確的原始 BM 狀態重新處理。
                for i in range(m):
                    if stage1_ok[i] and bm_orig[i][0] is not None:
                        corrected[i] = list(received[i])
                        stage1_ok[i] = False
                        status[i]    = {"success": False, "layer": 0, "err": 0}

        # ──── Stage 2：嵌套解碼（v = 1）────
        if v >= 1:
            failed_idx = [i for i in range(m) if not stage1_ok[i]]

            if 0 < len(failed_idx) <= v:
                for i in failed_idx:

                    # 建立嵌套碼字：對 i 使用原始 received，對其他使用 Stage 1 結果
                    c_tilde = [0] * n
                    for j in range(m):
                        src = received[j] if j == i else corrected[j]
                        for k in range(n): c_tilde[k] ^= src[k]

                    # 高階 syndromes 來自 c~₀（等於純誤差 syndromes，因編碼保證）
                    s_s1   = self._syndromes(received[i], t0)
                    s_hi   = self._syndromes_range(c_tilde, 2*t0+1, 2*tv)
                    s_full = s_s1 + s_hi

                    # 從 Stage 1 的 BM 狀態繼續（不重新開始）
                    Lam0, B0, b0, L0 = bm_orig[i]
                    Lam2, _, _, _ = self._bm_continue(
                        Lam0, B0, b0, L0, s_full, 2*t0, 2*tv
                    )

                    locs2 = self._chien_search(Lam2)
                    deg2  = self._poly_degree(Lam2)

                    if len(locs2) == deg2 and deg2 > 0:
                        fixed = list(received[i])
                        for pos in locs2: fixed[pos] ^= 1
                        # 用 t₀ syndromes 驗證（c[i] 只保證在 C₀）
                        if all(s == 0 for s in self._syndromes(fixed, t0)):
                            corrected[i] = fixed
                            stage1_ok[i] = True
                            status[i]    = {"success": True, "layer": 1, "err": deg2}

        return corrected, status

    # ─────────────────────────────────────────────
    # Syndrome 計算
    # ─────────────────────────────────────────────

    def _syndromes(self, word, t):
        """S_j = word(α^j)，j = 1..2t。"""
        return [self.gf.eval_poly_at_alpha(word, j) for j in range(1, 2*t+1)]

    def _syndromes_range(self, word, j_start, j_end):
        """S_j = word(α^j)，j = j_start..j_end（含端點）。"""
        return [self.gf.eval_poly_at_alpha(word, j) for j in range(j_start, j_end+1)]

    # ─────────────────────────────────────────────
    # Berlekamp-Massey 演算法
    # ─────────────────────────────────────────────

    def _berlekamp_massey(self, syndromes):
        """
        標準 Berlekamp-Massey，回傳 (Λ, B, b, L)。
        保留 B 與 b 以供 _bm_continue() 使用。
        """
        F   = self._field
        Lam = [F(1)]; B = [F(1)]; L = 0; b = F(1)

        for r in range(len(syndromes)):
            d = F(0)
            for j in range(min(L+1, len(Lam))):
                if 0 <= r-j < len(syndromes):
                    d = d + Lam[j] * syndromes[r-j]

            if d == F(0):
                B = [F(0)] + B
            elif 2*L <= r:
                T = Lam[:]; db = d * b**(-1); xB = [F(0)] + B
                sz = max(len(Lam), len(xB)); nL = [F(0)] * sz
                for i, v in enumerate(Lam): nL[i] = nL[i] + v
                for i, v in enumerate(xB):  nL[i] = nL[i] + db * v
                Lam = nL; L = r+1-L; B = T; b = d
            else:
                db = d * b**(-1); xB = [F(0)] + B
                sz = max(len(Lam), len(xB)); nL = [F(0)] * sz
                for i, v in enumerate(Lam): nL[i] = nL[i] + v
                for i, v in enumerate(xB):  nL[i] = nL[i] + db * v
                Lam = nL; B = [F(0)] + B

        while len(Lam) > 1 and int(Lam[-1]) == 0: Lam.pop()
        while len(B)   > 1 and int(B[-1])   == 0: B.pop()
        return Lam, B, b, L

    def _bm_continue(self, Lam, B, b, L, S_full, r_start, r_end):
        """
        從 r_start 延伸 BM 到 r_end（不含）。
        S_full[r] = S_{r+1}，前 2t₀ 個是 Stage 1 的 syndromes，
        後面是從嵌套碼字取得的高階 syndromes。
        實現論文 Section III-A 的 nested KES 延伸。
        """
        F = self._field
        for r in range(r_start, r_end):
            d = F(0)
            for j in range(min(L+1, len(Lam))):
                if 0 <= r-j < len(S_full):
                    d = d + Lam[j] * S_full[r-j]

            if d == F(0):
                B = [F(0)] + B
            elif 2*L <= r:
                T = Lam[:]; db = d * b**(-1); xB = [F(0)] + B
                sz = max(len(Lam), len(xB)); nL = [F(0)] * sz
                for i, v in enumerate(Lam): nL[i] = nL[i] + v
                for i, v in enumerate(xB):  nL[i] = nL[i] + db * v
                Lam = nL; L = r+1-L; B = T; b = d
            else:
                db = d * b**(-1); xB = [F(0)] + B
                sz = max(len(Lam), len(xB)); nL = [F(0)] * sz
                for i, v in enumerate(Lam): nL[i] = nL[i] + v
                for i, v in enumerate(xB):  nL[i] = nL[i] + db * v
                Lam = nL; B = [F(0)] + B

        while len(Lam) > 1 and int(Lam[-1]) == 0: Lam.pop()
        return Lam, B, b, L

    # ─────────────────────────────────────────────
    # Chien Search
    # ─────────────────────────────────────────────

    def _chien_search(self, Lambda):
        """找 Λ(α^{−k}) = 0 的位置 k（誤差位置）。"""
        F, alpha, n = self._field, self._alpha, self.n
        locs = []
        for k in range(n):
            val = F(0); exp = (n - k) % n
            for j, c in enumerate(Lambda):
                val = val + c * alpha ** ((j * exp) % n)
            if val == F(0):
                locs.append(k)
        return locs

    # ─────────────────────────────────────────────
    # 輔助
    # ─────────────────────────────────────────────

    @staticmethod
    def _poly_degree(poly):
        d = len(poly) - 1
        while d > 0 and int(poly[d]) == 0: d -= 1
        return d

    def print_generators(self):
        for i, (t, g) in enumerate(zip(self.t_list, self.g_polys)):
            terms = []
            for deg in range(len(g)-1, -1, -1):
                if g[deg]:
                    terms.append("1" if deg==0 else "x" if deg==1 else f"x^{deg}")
            print(f"g{i}(x) [t={t}] = " + " + ".join(terms))
            print(f"  Parity 長度 w_{i} = {len(g)-1} bits")


# ═══════════════════════════════════════════════════════════
# 主程式
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":

    print("=" * 60)
    print("GII-BCH 系統示範  GF(2^6), n=63, m=4, v=1, t=[3,5]")
    print("=" * 60)

    sys = GII_BCH_System(q=6, m=4, v=1, t_list=[3, 5])
    sys.print_generators()

    n     = sys.n
    t0    = sys.t_list[0]
    tv    = sys.t_list[sys.v]

    random.seed(42)
    data = []
    for i in range(sys.m):
        layer = 0 if i >= sys.v else sys.v - i
        data.append([random.randint(0,1) for _ in range(n - sys.w[layer])])

    codewords = sys.encode(data)
    print(f"\n各 sub-codeword 長度: {[len(c) for c in codewords]}")

    # 驗證嵌套結構
    import galois as glib
    GF2m  = glib.GF(2**6); alpha_v = GF2m.primitive_element
    ctilde = [0]*n
    for cw in codewords:
        for k in range(n): ctilde[k] ^= cw[k]
    bad = [j for j in range(1, 2*tv+1)
           if int(sum((alpha_v**(k*j%n) for k in range(n) if ctilde[k]), GF2m(0))) != 0]
    print(f"c~₀ syndrome 驗證: {'✓ 全為零（編碼正確）' if not bad else f'✗ 錯誤 j={bad}'}\n")

    print("-" * 60)

    def run_test(desc, err_cfg):
        rcv = [list(c) for c in codewords]
        for i, pos_list in err_cfg.items():
            for p in pos_list: rcv[i][p] ^= 1
        dec, stat = sys.decode(rcv)
        residuals = [sum(a^b for a,b in zip(dec[i], codewords[i])) for i in range(sys.m)]
        ok = all(r == 0 for r in residuals)
        print(f"\n{desc}")
        for i, s in enumerate(stat):
            inj = str(sorted(err_cfg.get(i,[])))
            layer = f"Layer={s['layer']}" if s['success'] else "失敗"
            print(f"  c[{i}]: 注入={inj:22s} | {layer:10s} | 殘餘={residuals[i]}")
        print(f"  ➜ {'✓ PASS' if ok else '✗ FAIL'}")
        return ok

    # run_test("測試 1：無誤差",                  {})
    # run_test("測試 2：c[0] t₀=3 個錯誤",        {0: [1, 20, 50]})
    # run_test("測試 3：每行各 t₀=3 個錯誤",       {0:[0,10,20], 1:[1,11,21], 2:[2,12,22], 3:[3,13,23]})
    # run_test("測試 4：c[0] 4 個錯誤（Stage 2）", {0: [1, 20, 40, 55]})
    # run_test("測試 5：c[0] tᵥ=5 個錯誤（Stage 2 上限）", {0: [1, 10, 25, 40, 55]})
    # run_test("測試 6：c[0] tᵥ+1=6 個錯誤（超出能力）",   {0: [0,5,15,25,40,55]})

    # print()
    # print("=" * 60)
    # print("對齊論文設定：GF(2^6), m=4, v=1, t=[2,4]")
    # print("注入 5 個錯誤於第 0 行（t₀=2 Stage 1 無法修復）")
    # print("=" * 60)

    sys2 = GII_BCH_System(q=6, m=4, v=1, t_list=[2, 4])
    random.seed(77)
    data2 = []
    for i in range(4):
        layer = 0 if i >= 1 else 1
        data2.append([random.randint(0,1) for _ in range(sys2.n - sys2.w[layer])])
    cw2 = sys2.encode(data2)

    random.seed(77)
    err_indices = random.sample(range(sys2.n), 3)
    rcv2 = [list(c) for c in cw2]
    for pos in err_indices: rcv2[0][pos] ^= 1
    print(f"\n注入錯誤於第 0 行，位置: {sorted(err_indices)}")

    dec2, stat2 = sys2.decode(rcv2)
    print("-" * 30)
    for i, s in enumerate(stat2):
        print(f"Interleave {i}: 成功={s['success']}, 使用層級={s['layer']}, 修正錯誤數={s['err']}")
    res2 = [sum(a^b for a,b in zip(dec2[i], cw2[i])) for i in range(4)]
    print(f"\n殘餘誤差: {res2}  ({'✓ 全部正確' if all(r==0 for r in res2) else '✗ 有誤差'})")