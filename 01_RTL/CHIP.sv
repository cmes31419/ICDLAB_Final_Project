module CHIP(
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    reg [4:0]   icnt, icnt_next;

    wire [4:0]  iaddr;
    wire [62:0] cdata;
    wire        cdone, sdone;
    wire [5:0]  LO_syn[3:0];
    wire        LKES_done;
    wire [5:0]  cs_sigma_in [6:0], LKES_sigma_out[2:0];
    
    // temporaily set to only LKES
    genvar gi;

    generate
        for (gi=0; gi<3;gi=gi+1) begin
            assign cs_sigma_in[gi] = LKES_sigma_out[gi];
        end
        for (gi=3; gi<7;gi=gi+1) begin
            assign cs_sigma_in[gi] = 0;
        end
    endgenerate

    assign iaddr = {icnt[4:3], 3'h7 - icnt[2:0]};

    assign iready = 1;

    memory mem0(
        .clk(clk),
        .rst(rst),
        .iaddr(iaddr),
        .idata(idata),
        .iwen(ivalid),
        .caddr(),
        .cdata(cdata),
        .cwen(),
        .oaddr(),
        .odata()
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
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            icnt    <= 0;
        end
        else begin
            icnt    <= icnt_next;
        end
    end
    
endmodule