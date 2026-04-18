module memory #(
	parameter MAX_CYCLES_M6 = 64 / `PARALLEL_NUM,
	parameter CNT_BITS = $clog2(MAX_CYCLES_M6)
)(
	input					clk,
	input					rstn,
	input [63:0]			idata,
	input					ready,
	input					chien,
	input					reset,
	output reg [CNT_BITS:0]	cnt,
	output reg [5:0]		factor8,
	output reg [5:0]		factor16
);

	reg [CNT_BITS:0]	cnt_next;

	reg [5:0]			factor8_next;
	reg [5:0]			factor16_next;

	wire [5:0]			factor8_rot;
	wire [5:0]			factor16_rot;

	integer i, j;

	rotate_8 rot80(
		.sigma(factor8),
		.sigma_rot(factor8_rot)
	);

	rotate_16 rot160(
		.sigma(factor16),
		.sigma_rot(factor16_rot)
	);

	always @(*) begin
		if (ready | reset) begin
			cnt_next = 0;
			factor8_next = 6'b1;
			factor16_next = 6'b1;
		end
		else if (chien) begin
			cnt_next = cnt + 1;
			factor8_next = factor8_rot;
			factor16_next = factor16_rot;
		end
		else begin
			cnt_next = cnt;
			factor8_next = factor8;
			factor16_next = factor16;
		end
	end

	always @(posedge clk) begin
		if (~rstn) begin
			cnt				<= 0;
			factor8			<= 6'b1;
			factor16		<= 6'b1;
		end
		else begin
			cnt				<= cnt_next;
			factor8			<= factor8_next;
			factor16		<= factor16_next;
		end
	end

endmodule