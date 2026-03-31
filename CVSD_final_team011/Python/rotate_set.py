def rotate_left(x, n):
    """Rotate-left an n-bit integer x by 1 bit."""
    return ((x << 1) & ((1 << n) - 1)) | (x >> (n - 1))


def get_cycle(x, n):
    """Return rotation cycle of x (ordered list)."""
    vals = []
    cur = x
    for _ in range(n):
        if cur in vals:
            break
        vals.append(cur)
        cur = rotate_left(cur, n)
    return vals


def hamming(a, b):
    """Hamming distance between two integers."""
    return bin(a ^ b).count("1")


def classify_rotation(n):
    """Return rotation-equivalence classes, grouped by period,
       and ordered inside each period so that reps are Hamming-close."""
    visited = set()
    classes = []

    # 先把所有 class 建好
    for x in range(1 << n):
        if x in visited:
            continue

        cycle = get_cycle(x, n)
        cycle_set = frozenset(cycle)

        rep = min(cycle)               # 代表元（最小的那個 pattern）
        ones = bin(rep).count("1")     # 代表元的 bit1 數量

        classes.append({
            "cycle": cycle,
            "set": cycle_set,
            "period": len(cycle),
            "ones": ones,
            "rep": rep
        })

        for v in cycle_set:
            visited.add(v)

    # 先依 period 分組
    by_period = {}
    for cls in classes:
        p = cls["period"]
        by_period.setdefault(p, []).append(cls)

    # 對每個 period 做「Hamming greedy 排序」
    ordered_all = []
    for period in sorted(by_period.keys()):  # period 小→大
        group = by_period[period]

        if not group:
            continue
        if len(group) == 1:
            ordered_all.extend(group)
            continue

        # 用 greedy 最近鄰：從 rep 最小的開始，每次接 Hamming 最近的
        unused_idx = list(range(len(group)))
        # 先選 rep 最小的當起點
        cur_idx = min(unused_idx, key=lambda i: group[i]["rep"])
        order_idx = [cur_idx]
        unused_idx.remove(cur_idx)

        while unused_idx:
            cur_rep = group[cur_idx]["rep"]
            # 在未使用的 class 裡找 Hamming distance 最小的
            nxt_idx = min(
                unused_idx,
                key=lambda i: hamming(cur_rep, group[i]["rep"])
            )
            order_idx.append(nxt_idx)
            unused_idx.remove(nxt_idx)
            cur_idx = nxt_idx

        # 依照算出的 index 順序加入到總列表
        ordered_all.extend(group[i] for i in order_idx)

    return ordered_all


# =====================
#        MAIN
# =====================
if __name__ == "__main__":
    n = 10  # 想換其他 bit 數就改這裡
    classes = classify_rotation(n)

    filename = f"rotation_classes_{n}bit.txt"
    with open(filename, "w") as f:
        f.write(f"Total classes for {n} bits: {len(classes)}\n\n")

        for i, cls in enumerate(classes, 1):
            period = cls["period"]
            ones = cls["ones"]
            members = sorted(cls["set"])
            members_bin = [format(v, f'0{n}b') for v in members]

            f.write(f"[Class {i:2d}] Period={period}, Ones={ones}: ")
            f.write("  " + ", ".join(members_bin) + "\n")

    print(f"已寫入檔案：{filename}")
