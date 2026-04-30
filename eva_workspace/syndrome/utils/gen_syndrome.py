import sys

q = int(sys.argv[1])
t_min = int(sys.argv[2])

content = f"""module syndrome(
    input               clk,
    input               rst,
    input [7:0]         idata,
    input               ivalid,
    output reg [{q-1}:0]    S[{2*t_min-1}:0],
    output reg          done
);

    reg [2:0]   cnt, cnt_next;
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
        if (ivalid & cnt == 7) done_next = 1;
        else done_next = 0;
    end

    always @(*) begin
        if (ivalid) cnt_next = cnt + 1;
        else cnt_next = cnt;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            done    <= 0;
            for (i=0;i<{t_min};i=i+1) begin
                syn[i]  <= 0;
            end
        end
        else begin
            cnt     <= cnt_next;
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