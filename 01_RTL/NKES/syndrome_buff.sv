module syndrome_buff(
    input clk,
    input rst,

    input write_en,
    input write_idx,
    input [5:0] syn_in,

    input read_idx,
    output [5:0] syn_out
);

    reg [5:0] syn_buff[1:0], syn_buff_next[1:0];

    assign syn_out = syn_buff[read_idx];

    always @(*) begin
        if (write_en) begin
            syn_buff_next[0] = (write_idx == 1'b0)? syn_in : syn_buff[0];
            syn_buff_next[1] = (write_idx == 1'b1)? syn_in : syn_buff[1];
        end
        else begin
            syn_buff_next[0] = syn_buff[0];
            syn_buff_next[1] = syn_buff[1];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            syn_buff[0] <= 6'b0;
            syn_buff[1] <= 6'b0;
        end
        else begin
            syn_buff[0] <= syn_buff_next[0];
            syn_buff[1] <= syn_buff_next[1];
        end
    end

endmodule