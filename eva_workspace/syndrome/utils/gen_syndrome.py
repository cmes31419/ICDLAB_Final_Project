import sys
import math

q = int(sys.argv[1])
n = int(sys.argv[2])
t_min = int(sys.argv[3])

input_cycles = math.ceil(n / 8)
io_addr_bits = (input_cycles - 1).bit_length()

content = f"""module syndrome(
    input               clk,
    input               rst,
    input [{io_addr_bits-1}:0]         cnt,
    input [7:0]         idata,
    input               ivalid,
    output reg [{q-1}:0]    S[{2*t_min-1}:0],
    output reg          done
);

    reg [{q-1}:0]   syn[{t_min-1}:0], syn_next[{t_min-1}:0];
    reg         done_next;

    wire [{q-1}:0]  syn_now[{t_min-1}:0], syn_rot[{t_min-1}:0];
    wire [7:0]  data;

    integer i;

    genvar gi;

    assign data = (cnt == 0) ? {{1'b0, idata[6:0]}} : idata;

    generate
        for (gi=0;gi<{t_min};gi=gi+1) begin
            assign syn_now[gi] = (cnt == 0) ? 0 : syn[gi];
        end
    endgenerate

    syndrome_rotate_add sr0(
        .data(data),
        .syn(syn_now),
        .syn_rot(syn_rot)
    );

    syndrome_pow sp0(
        .syn(syn),
        .S(S)
    );

    always @(*) begin
        for (i=0;i<{t_min};i=i+1) begin
            syn_next[i] = ivalid ? syn_rot[i] : syn[i];
        end
    end

    always @(*) begin
        if (ivalid & cnt == {input_cycles-1}) done_next = 1;
        else done_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done    <= 0;
            for (i=0;i<{t_min};i=i+1) begin
                syn[i]  <= 0;
            end
        end
        else begin
            done    <= done_next;
            for (i=0;i<{t_min};i=i+1) begin
                syn[i]  <= syn_next[i];
            end
        end
    end

endmodule"""

f = open("syndrome.sv", "w")
f.write(content)
f.close()

print("Generated syndrome.sv")