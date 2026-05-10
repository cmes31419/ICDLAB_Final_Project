module CHIP(
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    reg [4:0]   iaddr, iaddr_next;

    wire [62:0] cdata;
    wire        cdone, sdone;
    wire [5:0] LO_syn[3:0];

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
        .cnt(iaddr[2:0]),
        .idata(idata),
        .iwen(ivalid),
        .S(LO_syn),
        .sdone(sdone)
    );

    BM bm0(
        .clk(clk),
        .rst(rst),
        .syndrome_rdy(sdone),
        .LO_syndrome(LO_syn),
        .sigma_done(),
        .sigma()
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .sigma(),
        .sigma_valid(),
        .ready(),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail)
    );

    always @(*) begin
        if (ivalid) iaddr_next = iaddr + 1;
        else iaddr_next = iaddr;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt_next;
        end
    end
    
endmodule