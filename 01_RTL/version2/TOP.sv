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
    wire        cdone, cfail;
    wire        nested_cdone, nested_cfail;

    wire [2:0]  naddr;
    wire [62:0] ndata[3:0];
    wire [11:0] nsyn[1:0];
    wire [3:0]  nflag;
    wire        nkill;

    wire        forward;
    wire        late_cdone;
    wire        Lsel_syn, Lwen_syn, Lwen_syn0, Lwen_syn1;
    wire        Lsel_kes, Lwen_kes;
    wire        Nwen, Nsel_nsu, Nwen_nsu;
    wire        nsu_start0, nsu_start1;
    wire        nsu_b, nsu_stage_flag;
    wire [1:0]  nsu_undecoded_idx_1, nsu_undecoded_idx_2;
    wire        nsu_stage2_match_idx, nsu_sel_idx;

    wire [2:0]  cwaddr;
    wire        cwen;

    wire [2:0]  syn_cnt;
    wire [5:0]  Ndata_nsu;
    wire [5:0]  LO_syn[3:0], HO_syn[1:0];
    wire        LO_syn_rdy, HO_syn_rdy;
    wire        LO_syn_get, HO_syn_get;
    wire        LKES_done, LKES_fail, NKES_done;
    wire [5:0]  LKES_sigma_out[3:0], NKES_sigma_out[6:0];

    assign cwen = (cdone & ~cfail) | (nested_cdone & ~nested_cfail);
    assign cwaddr = (cdone & ~cfail) ? caddr : naddr;

    assign Lwen_syn0 = Lwen_syn & LO_syn_rdy & LO_syn_get;
    assign Lwen_syn1 = Lwen_syn & (cdone | LKES_fail) & ~late_cdone;

    controller ctrl0(
        .clk(clk),
        .rst(rst),
        .ivalid(ivalid & iready),
        .ovalid(ovalid),
        .sdone(LO_syn_rdy & LO_syn_get),
        .LKES_done(LKES_done),
        .LKES_fail(LKES_fail),
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
        .nkill(nkill),
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
        .valid(LO_syn_rdy)
    );

    NSU hsu_n0(
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

        .syn_rdy(HO_syn_rdy),
        .S_out_ch1(HO_syn[0]),
        .S_out_ch2(HO_syn[1]),
        .Ndata(Ndata_nsu),
        .Nsel(Nsel_nsu),
        .Nwen(Nwen_nsu)
    );

    NKES nkes_n0(
        .clk(clk),
        .rst(rst),
        .LO_syn_rdy(LO_syn_rdy),
        .LO_syn(LO_syn),
        .HO_syn_rdy(HO_syn_rdy),
        .HO_syn(HO_syn),

        .forward(forward),
        .sel_idx(nsu_sel_idx),
        .Lwaddr(Lsel_kes),
        .Lwen_ctrl(Lwen_kes),
        .Nwen_ctrl(Nwen),
    
        .LO_syn_get(LO_syn_get),
        .HO_syn_get(HO_syn_get),
        .Lsigma_done(LKES_done),
        .Lsigma_fail(LKES_fail),
        .Nsigma_done(NKES_done),
        .sigma(NKES_sigma_out)
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .sigma(NKES_sigma_out),
        .sigma_valid(LKES_done & ~LKES_fail),
        .nested_sigma(NKES_sigma_out),
        .nested_sigma_valid(NKES_done),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail),
        .nested_cdone(nested_cdone),
        .nested_cfail(nested_cfail)
    );

endmodule