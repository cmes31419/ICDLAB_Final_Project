module CHIP(
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    wire [4:0]  iaddr;
    wire [4:0]  oaddr;
    wire [1:0]  caddr;
    wire [62:0] cdata;
    wire        cdone, cfail;
    wire [2:0]  scnt;
    wire        sdone;
    wire [5:0]  LO_syn[3:0];
    wire        LKES_done;
    wire [5:0]  cs_sigma_in [6:0], LKES_sigma_out[2:0];

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
        .iready(iready),
        .iaddr(iaddr),
        .oaddr(oaddr),
        .caddr(caddr),
        .scnt(scnt)
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

endmodule