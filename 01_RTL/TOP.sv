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
    wire        nested_cdone, nested_cfail, nested_cget;

    wire [2:0]  naddr;
    wire [62:0] ndata[3:0];
    wire [11:0] nsyn[1:0];
    wire [3:0]  nflag;
    wire        nkill;

    wire [2:0]  cwaddr;
    wire        cwen;

    wire        sdone;
    wire        swen, ssel;
    wire        Lwen;
    wire        forward;

    wire [2:0]  syn_cnt;
    wire [5:0]  LO_syn[3:0];
    wire        LKES_done, NKES_done, LKES_fail;
    wire [5:0]  cs_sigma_in[6:0], LKES_sigma_out[3:0], NKES_sigma_out[6:0];

    wire        nsu_start, nsu_b, nsu_stage_flag;

    wire [5:0] LKES_b_out[3:0], LKES_delta_even_out[1:0], LKES_theta_even_out[1:0], LKES_gamma_out;
    wire [1:0] LKES_k_out;
    wire [5:0] HO_syn[1:0];

    wire syn_rdy;
    wire [5:0] S_out_ch1, S_out_ch2;

    assign HO_syn[0] = S_out_ch1;
    assign HO_syn[1] = S_out_ch2;

    assign cwen = (cdone & ~cfail) | (nested_cdone & ~nested_cfail);
    assign cwaddr = (cdone & ~cfail) ? caddr : naddr;

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
        .sdone(sdone),
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
        .ssel(ssel),
        .swen(swen),
        .Lwen(Lwen),
        .forward(forward),
        .syn_cnt(syn_cnt),
        .nsu_start(nsu_start),
        .nsu_b(nsu_b),
        .nsu_stage_flag(nsu_stage_flag)
    );

    memory mem0(
        .clk(clk),
        .rst(rst),
        .iaddr(iaddr),
        .idata(idata),
        .iwen(ivalid & iready),
        .sdata({LO_syn[3], LO_syn[2]}),
        .ssel(ssel),
        .swen(swen),
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
        .S(LO_syn),
        .sdone(sdone)
    );

    BM bm0(
        .clk(clk),
        .rst(rst),
        .syndrome_rdy(sdone),
        .LO_syndrome(LO_syn),
        .cget(cget),
        .sigma_done(LKES_done),
        .sigma_fail(LKES_fail),
        .sigma_out(LKES_sigma_out),
        .b_out(LKES_b_out),
        .delta_even_out(LKES_delta_even_out),
        .theta_even_out(LKES_theta_even_out),
        .gamma_out(LKES_gamma_out),
        .k_out(LKES_k_out)
    );

    NKES nkes0(
        .clk(clk),
        .rst(rst),
        .syn_rdy(syn_rdy),
        .HO_syn(HO_syn),

        .Lstate_rdy(LKES_done),
        .LKES_fail(LKES_fail),
        .cdone(cdone),
        .cfail(cfail),
        .Lsigma(LKES_sigma_out),
        .Lb(LKES_b_out),
        .Ldelta_even(LKES_delta_even_out),
        .Ltheta_even(LKES_theta_even_out),
        .Lgamma(LKES_gamma_out),
        .Lk(LKES_k_out),

        .ncget(nested_cget), .ncdone(nested_cdone), .ncfail(nested_cfail),
        .fail_num(nsu_b),
        .nsu_stage_flag(nsu_stage_flag),

        .sigma_done(NKES_done),
        .sigma(NKES_sigma_out)
    );

    NKES_new nkes_n0(
        .clk(clk),
        .rst(rst),
        .syn_rdy(syn_rdy),
        .HO_syn(HO_syn),

        .forward(forward),
        .Lwaddr(ssel),
        .Lwen(Lwen),
        .Lsigma(LKES_sigma_out),
        .Lb(LKES_b_out),
        .Ldelta_even(LKES_delta_even_out),
        .Ltheta_even(LKES_theta_even_out),
        .Lgamma(LKES_gamma_out),
        .Lk(LKES_k_out),
    
        .sigma_done(),
        .sigma()
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .sigma(cs_sigma_in),
        .sigma_valid(LKES_done & ~LKES_fail),
        .nested_sigma(NKES_sigma_out),
        .nested_sigma_valid(NKES_done),
        .cdata(cdata),
        .cget(cget),
        .cdone(cdone),
        .cfail(cfail),
        .nested_cget(nested_cget),
        .nested_cdone(nested_cdone),
        .nested_cfail(nested_cfail)
    );

    HSU_top hsu0(
        .clk(clk),
        .rst(rst),
        .start(nsu_start),
        .r0(ndata[0]),
        .r1(ndata[1]),
        .r2(ndata[2]),
        .r3(ndata[3]),
        .flag0(nflag[0]), 
        .flag1(nflag[1]), 
        .flag2(nflag[2]), 
        .flag3(nflag[3]),
        .stage_flag(nsu_stage_flag),
        .Syndrome_3_i0(nsyn[0][5:0]), 
        .Syndrome_4_i0(nsyn[0][11:6]), 
        .Syndrome_3_i1(nsyn[1][5:0]), 
        .Syndrome_4_i1(nsyn[1][11:6]),   
        .valid_S3_S4(nsu_start),

        .syn_rdy(syn_rdy),
        .S_out_ch1(S_out_ch1),
        .S_out_ch2(S_out_ch2)
    );



endmodule