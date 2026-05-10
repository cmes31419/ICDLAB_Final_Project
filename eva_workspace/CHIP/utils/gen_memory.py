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

content = f"""module memory(
    input           clk,
    input           rst,
    // from input
    input [7:0]     idata,
    input [{b_addr_bits+m_addr_bits+io_addr_bits-1}:0]     iaddr,
    input           iwen,
    // from chien search
    input [{n-1}:0]    cdata,
    input [{b_addr_bits+m_addr_bits-1}:0]     caddr,
    input           cwen,
    // for output
    input [{b_addr_bits+m_addr_bits+io_addr_bits-1}:0]     oaddr,
    output [7:0]    odata
);

    reg [{n-1}:0]  data[{memory_bank_num*m-1}:0], data_next[{memory_bank_num*m-1}:0];

    integer i, j;

    always @(*) begin
        for (i=0;i<{memory_bank_num*m};i=i+1) begin
            for (j=0;j<7;j=j+1) begin
                if (iwen && iaddr[{io_addr_bits}+:{b_addr_bits+m_addr_bits}] == i && iaddr[0+:{io_addr_bits}] == j) data_next[i][j*8+:8] = idata;
                else if (icen && caddr == i) data_next[i][j*8+:8] = data[i][j*8+:8] ^ cdata[j*8+:8];
                else data_next[i][j*8+:8] = data[i][j*8+:8];
            end
            if (iwen && iaddr[{io_addr_bits}+:{b_addr_bits+m_addr_bits}] == i && iaddr[0+:{io_addr_bits}] == 7) data_next[i][56+:7] = idata[0+:7];
            else if (icen && caddr == i) data_next[i][56+:7] = data[i][56+:7] ^ cdata[56+:7];
            else data_next[i][56+:7] = data[i][56+:7];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<{memory_bank_num*m};i=i+1) begin
                data[i] <= 0;
            end
        end
        else begin
            for (i=0;i<{memory_bank_num*m};i=i+1) begin
                data[i] <= data_next[i];
            end
        end
    end

endmodule"""

f = open("memory.sv", "w")
f.write(content)
f.close()

print("Generated memory.sv")