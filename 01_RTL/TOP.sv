module TOP (
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    wire [5:0]  iaddr;
    wire [5:0]  oaddr;

    wire [2:0]  caddr;
    wire [62:0] cdata;
    wire        cdone, cfail, cget;
    // wire [62:0] nested_cdata;
    wire        nested_cdone, nested_cfail, nested_cget;

    wire [2:0]  naddr;
    wire [62:0] ndata[3:0];
    wire [11:0] nsyn[1:0];
    wire [3:0]  nflag;
    wire        nkill;

    wire [2:0]  cwaddr;
    wire        cwen;

    wire        forward;
    wire        late_cdone;
    wire        sdone;
    wire        Lsel_syn, Lwen_syn, Lwen_syn0, Lwen_syn1;
    wire        Lsel_kes, Lwen_kes;
    wire        Nwen;
    wire [6:0]  Ndata_nsu;
    wire        Nsel_nsu, Nwen_nsu;

    wire [2:0]  syn_cnt;
    wire [5:0]  LO_syn[3:0];
    wire        LKES_done, NKES_done, LKES_fail;
    wire [5:0]  cs_sigma_in[6:0], LKES_sigma_out[3:0], NKES_sigma_out[6:0];

    wire        LO_syn_get, HO_syn_get;
    wire        LKES_done_new, LKES_fail_new, NKES_done_new;
    wire [5:0]  NKES_sigma_out_new[6:0];

    wire        nsu_start0, nsu_start1;
    wire        nsu_b, nsu_stage_flag;
    wire [1:0]  nsu_undecoded_idx_1, nsu_undecoded_idx_2;
    wire        nsu_stage2_match_idx, nsu_sel_idx;

    wire [5:0]  LKES_b_out[3:0], LKES_delta_even_out[1:0], LKES_theta_even_out[1:0], LKES_gamma_out;
    wire [1:0]  LKES_k_out;
    wire [5:0]  HO_syn[1:0];
    wire        syn_rdy;

    wire [5:0]  HO_syn_new[1:0];
    wire        syn_rdy_new;

    assign cwen = (cdone & ~cfail) | (nested_cdone & ~nested_cfail);
    assign cwaddr = (cdone & ~cfail) ? caddr : naddr;

    assign Lwen_syn0 = Lwen_syn & sdone & LO_syn_get;
    assign Lwen_syn1 = Lwen_syn & (cdone | LKES_fail_new) & ~late_cdone;

    // temporaily set to only LKES
    genvar gi;

    generate
        for (gi=0;gi<3;gi=gi+1) begin
            assign cs_sigma_in[gi] = LKES_sigma_out[gi];
        end
        for (gi=3;gi<7;gi=gi+1) begin
            assign cs_sigma_in[gi] = 0;
        end
    endgenerate

    controller ctrl0(
        .clk(clk),
        .rst(rst),
        .ivalid(ivalid & iready),
        .ovalid(ovalid),
        .sdone(sdone & LO_syn_get),
        .LKES_done(LKES_done_new),
        .LKES_fail(LKES_fail_new),
        .cdone(cdone),
        .cfail(cfail),
        .nflag(nflag),
        .nested_cdone(nested_cdone),
        .nested_cfail(nested_cfail),
        .iready(iready),
        .iaddr(iaddr),
        .oaddr(oaddr),
        .caddr(caddr),
        .naddr(naddr),
        .nkill(nkill),
        .Lsel_syn(Lsel_syn),
        .Lwen_syn(Lwen_syn),
        .Lsel_kes(Lsel_kes),
        .Lwen_kes(Lwen_kes),
        .Nwen(Nwen),
        .forward(forward),
        .late_cdone(late_cdone),
        .syn_cnt(syn_cnt),
        .nsu_start0(nsu_start0),
        .nsu_start1(nsu_start1),
        .nsu_b(nsu_b),
        .nsu_stage_flag(nsu_stage_flag),
        .nsu_undecoded_idx_1(nsu_undecoded_idx_1),
        .nsu_undecoded_idx_2(nsu_undecoded_idx_2),
        .nsu_stage2_match_idx(nsu_stage2_match_idx),
        .nsu_sel_idx(nsu_sel_idx)
    );

    memory mem0(
        .clk(clk),
        .rst(rst),
        .forward(forward),
        .iaddr(iaddr),
        .idata(idata),
        .iwen(ivalid & iready),
        .Lsdata({LO_syn[3], LO_syn[2]}),
        .Lssel(Lsel_syn),
        .Lswen0(Lwen_syn0),
        .Lswen1(Lwen_syn1),
        .Nsdata(Ndata_nsu),
        .Nssel(Nsel_nsu),
        .Nswen(Nwen & Nwen_nsu),
        .caddr(cwaddr),
        .cdata(cdata),
        .cwen(cwen),
        .naddr(naddr[2]),
        .nkill(nkill),  // TODO: replace with final nested-decoding done signal
        .nflag(nflag),
        .ndata(ndata),
        .nsyn(nsyn),
        .oaddr(oaddr),
        .odata(odata),
        .ovalid(ovalid)
    );

    syndrome syn0(
        .clk(clk),
        .rst(rst),
        .cnt(syn_cnt),
        .idata(idata),
        .ivalid(ivalid & iready),
        .sget(LO_syn_get),
        .S(LO_syn),
        .valid(sdone)
    );

    HSU_top hsu_n0(
        .clk(clk),
        .rst(rst),
        .start0(nsu_start0),
        .start1(nsu_start1),
        .nsget(HO_syn_get),
        .r0(ndata[0]),
        .r1(ndata[1]),
        .r2(ndata[2]),
        .r3(ndata[3]),
        .b(nsu_b),
        .flag0(nflag[0]), 
        .flag1(nflag[1]), 
        .flag2(nflag[2]), 
        .flag3(nflag[3]),
        .stage_flag(nsu_stage_flag),
        .undecoded_idx_1(nsu_undecoded_idx_1),
        .undecoded_idx_2(nsu_undecoded_idx_2),
        .stage2_match_idx(nsu_stage2_match_idx),
        .sel_idx(nsu_sel_idx),
        .Syndrome_3_i0(nsyn[0][5:0]), 
        .Syndrome_4_i0(nsyn[0][11:6]), 
        .Syndrome_3_i1(nsyn[1][5:0]), 
        .Syndrome_4_i1(nsyn[1][11:6]),

        .syn_rdy(syn_rdy_new),
        .S_out_ch1(HO_syn_new[0]),
        .S_out_ch2(HO_syn_new[1]),
        .Ndata(Ndata_nsu),
        .Nsel(Nsel_nsu),
        .Nwen(Nwen_nsu)
    );

    NKES nkes_n0(
        .clk(clk),
        .rst(rst),
        .LO_syn_rdy(sdone),
        .LO_syn(LO_syn),
        .HO_syn_rdy(syn_rdy_new),
        .HO_syn(HO_syn_new),

        .forward(forward),
        .sel_idx(nsu_sel_idx),
        .Lwaddr(Lsel_kes),
        .Lwen_ctrl(Lwen_kes),
        .Nwen_ctrl(Nwen),
    
        .LO_syn_get(LO_syn_get),
        .HO_syn_get(HO_syn_get),
        .Lsigma_done(LKES_done_new),
        .Lsigma_fail(LKES_fail_new),
        .Nsigma_done(NKES_done_new),
        .sigma(NKES_sigma_out_new)
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .sigma(NKES_sigma_out_new),
        .sigma_valid(LKES_done_new & ~LKES_fail_new),
        .nested_sigma(NKES_sigma_out_new),
        .nested_sigma_valid(NKES_done_new),
        .cdata(cdata),
        .cget(),
        .cdone(cdone),
        .cfail(cfail),
        .nested_cget(),
        .nested_cdone(nested_cdone),
        .nested_cfail(nested_cfail)
    );

endmodule