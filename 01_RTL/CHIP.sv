module CHIP(
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

    wire        naddr;
    wire [62:0] ndata[3:0];
    wire [3:0]  nflag;

    wire [2:0]  scnt;
    wire        sdone;

    wire [5:0]  LO_syn[3:0];
    wire        LKES_done;
    wire [5:0]  cs_sigma_in [6:0], LKES_sigma_out[2:0];

    wire        nsu_start, nsu_b;

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
        .ivalid(ivalid),
        .ovalid(ovalid),
        .cdone(cdone),
        .nflag(nflag),
        .nested_cdone(),
        .nested_cfail(),
        .iready(iready),
        .iaddr(iaddr),
        .oaddr(oaddr),
        .caddr(caddr),
        .naddr(naddr),
        .scnt(scnt),
        .nsu_start(nsu_start),
        .nsu_b(nsu_b)
    );

    memory mem0(
        .clk(clk),
        .rst(rst),
        .iaddr(iaddr),
        .idata(idata),
        .iwen(ivalid),
        .caddr(caddr),
        .cdata(cdata),
        .cwen(cdone & ~cfail),
        .ckill(cdone),  // TODO: replace with final nested-decoding done signal
        .naddr(naddr),
        .nflag(nflag),
        .ndata(ndata),
        .oaddr(oaddr),
        .odata(odata),
        .ovalid(ovalid)
    );

    syndrome syn0(
        .clk(clk),
        .rst(rst),
        .cnt(scnt),
        .idata(idata),
        .ivalid(ivalid),
        .S(LO_syn),
        .sdone(sdone)
    );

    BM bm0(
        .clk(clk),
        .rst(rst),
        .syndrome_rdy(sdone),
        .LO_syndrome(LO_syn),
        .sigma_done(LKES_done),
        .sigma(LKES_sigma_out)
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .sigma(cs_sigma_in),
        .sigma_valid(LKES_done),
        .ready(),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail)
    );

    // nsu_top nsu0(
    //     .clk(clk),
    //     .rst(rst),
    //     .start(nsu_start),
    //     .r0(ndata[0]),
    //     .r1(ndata[1]),
    //     .r2(ndata[2]),
    //     .r3(ndata[3]),
    //     .b(nsu_b),
    //     .stage_flag(),
    //     .S_out_0(),
    //     .S_out_1(),
    //     .S_out_2(),
    //     .S_out_3(),
    //     .b_out(),
    //     .valid()
    // );

endmodule