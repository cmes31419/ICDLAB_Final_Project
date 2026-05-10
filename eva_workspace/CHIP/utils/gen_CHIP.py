import sys
import math

m = int(sys.argv[1])
n = int(sys.argv[2])
memory_bank_num = int(sys.argv[3])

input_cycles = math.ceil(n / 8)
print(f"input_cycles: {input_cycles}")

b_addr_bits = (memory_bank_num - 1).bit_length()
m_addr_bits = (m - 1).bit_length()
io_addr_bits = (input_cycles - 1).bit_length()

print(f"b_addr_bits: {b_addr_bits}, m_addr_bits: {m_addr_bits}, io_addr_bits: {io_addr_bits}")

content = f"""module CHIP(
    input           clk,
    input           rst,
    input [7:0]     idata,
    input           ivalid,
    output          iready,
    output [7:0]    odata,
    output          ovalid
);

    reg [{b_addr_bits+m_addr_bits+io_addr_bits-1}:0]   iaddr, iaddr_next;

    wire        sdone;

    wire [{n-1}:0] cdata;
    wire        cdone;

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
        .cnt(iaddr[{io_addr_bits-1}:0]),
        .idata(idata),
        .iwen(ivalid),
        .S(),
        .sdone(sdone)
    );

    chien_search cs0(
        .clk(clk),
        .rst(rst),
        .ready(),
        .sigma(),
        .cdata(cdata),
        .cdone(cdone)
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
    
endmodule"""

f = open("CHIP.sv", "w")
f.write(content)
f.close()

print("Generated CHIP.sv")