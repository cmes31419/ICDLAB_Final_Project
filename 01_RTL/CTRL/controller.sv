module controller(
    input           clk,
    input           rst,
    input           ivalid,
    input           ovalid,
    input           cdone,
    output          iready,
    output [4:0]    iaddr,
    output [4:0]    oaddr,
    output [1:0]    caddr,
    output [2:0]    scnt
);

    reg [5:0]   icnt, icnt_next;    // input byte counter with wrap bit
    reg [5:0]   ocnt, ocnt_next;    // output byte counter with wrap bit
    reg [1:0]   ccnt, ccnt_next;    // correction codeword counter

    // Address mapping: input/output bytes are stored and read in reverse byte order
    assign iaddr = {icnt[4:3], 3'h7 - icnt[2:0]};
    assign oaddr = {ocnt[4:3], 3'h7 - ocnt[2:0]};
    assign caddr = ccnt;
    assign scnt = icnt[2:0];

    // FIFO-style full check
    assign iready = (icnt[5] != ocnt[5] && icnt[4:0] == ocnt[4:0]) ? 0 : 1;

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