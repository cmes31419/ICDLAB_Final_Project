module CHIP(
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    reg [5:0]   icnt, icnt_next;    // input byte counter with wrap bit
    reg [5:0]   ocnt, ocnt_next;    // output byte counter with wrap bit
    reg [1:0]   ccnt, ccnt_next;    // correction codeword counter

    wire [4:0]  iaddr;
    wire [4:0]  oaddr;
    wire [1:0]  caddr;
    wire        cwen;
    wire [62:0] cdata;
    wire        cdone, cfail;
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

    // Address mapping: input/output bytes are stored and read in reverse byte order
    assign iaddr = {icnt[4:3], 3'h7 - icnt[2:0]};
    assign oaddr = {ocnt[4:3], 3'h7 - ocnt[2:0]};

    assign caddr = ccnt;
    assign cwen = cdone & ~cfail;

    // FIFO-style full check
    assign iready = (icnt[5] != ocnt[5] && icnt[4:0] == ocnt[4:0]) ? 0 : 1;

    memory mem0(
        .clk(clk),
        .rst(rst),
        .iaddr(iaddr),
        .idata(idata),
        .iwen(ivalid),
        .caddr(caddr),
        .cdata(cdata),
        .cwen(cwen),
        .ckill(cdone),  // TODO: replace with final nested-decoding done signal
        .oaddr(oaddr),
        .odata(odata),
        .ovalid(ovalid)
    );

    syndrome syn0(
        .clk(clk),
        .rst(rst),
        .cnt(icnt[2:0]),
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

    always @(*) begin
        if (ivalid) icnt_next = icnt + 1;
        else icnt_next = icnt;
        if (ovalid) ocnt_next = ocnt + 1;
        else ocnt_next = ocnt;
        if (cdone) ccnt_next = ccnt + 1;
        else ccnt_next = ccnt;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            icnt    <= 0;
            ocnt    <= 0;
            ccnt    <= 0;
        end
        else begin
            icnt    <= icnt_next;
            ocnt    <= ocnt_next;
            ccnt    <= ccnt_next;
        end
    end

endmodule