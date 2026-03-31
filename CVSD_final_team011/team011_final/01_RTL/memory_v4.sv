module memory(
	input				clk,
	input				rstn,
	input [63:0]		idata,
	input [1:0]			code,
	input				ready,
	input				chien,
	input				reset,
	output reg [9:0]	cnt,
	output reg [9:0]	factor8,
	output reg [9:0]	factor16,
	output reg [9:0]	factor24,
	output reg [9:0]	factor32,
	output reg [6:0]	chien_data[`PARALLEL_NUM-1:0]
);

	localparam MAX_CYCLES_M6 = 64 / `PARALLEL_NUM;
	localparam MAX_CYCLES_M8 = 256 / `PARALLEL_NUM;
	localparam MAX_CYCLES_M10 = 1024 / `PARALLEL_NUM;

	reg [7167:7]	data_rec, data_rec_next;
	reg [9:0]		cnt_next;

	reg [9:0]		factor8_next;
	reg [9:0]		factor16_next;
	reg [9:0]		factor24_next;
	reg [9:0]		factor32_next;

	wire [9:0]		factor8_rot;
	wire [9:0]		factor16_rot;
	wire [9:0]		factor24_rot;
	wire [9:0]		factor32_rot;

	wire [55:0]		data_rot;

	// Clock Gating
	wire			gclk1, gclk2;

	integer i, j;

	assign gclk1 = clk & (code[1] | ~rstn);
	assign gclk2 = clk & ((code[1] & code[0]) | ~rstn);

	assign data_rot[6:0]   = ready ? (idata[63] ? ~idata[56+:7] + 1 : idata[56+:7]) : data_rec[125:119];
	assign data_rot[13:7]  = ready ? (idata[55] ? ~idata[48+:7] + 1 : idata[48+:7]) : data_rec[132:126];
	assign data_rot[20:14] = ready ? (idata[47] ? ~idata[40+:7] + 1 : idata[40+:7]) : data_rec[139:133];
	assign data_rot[27:21] = ready ? (idata[39] ? ~idata[32+:7] + 1 : idata[32+:7]) : data_rec[146:140];
	assign data_rot[34:28] = ready ? (idata[31] ? ~idata[24+:7] + 1 : idata[24+:7]) : data_rec[153:147];
	assign data_rot[41:35] = ready ? (idata[23] ? ~idata[16+:7] + 1 : idata[16+:7]) : data_rec[160:154];
	assign data_rot[48:42] = ready ? (idata[15] ? ~idata[8+:7]  + 1 : idata[8+:7] ) : data_rec[167:161];
	assign data_rot[55:49] = ready ? (idata[7]  ? ~idata[0+:7]  + 1 : idata[0+:7] ) : data_rec[174:168];

	rotate_8 rot80(
		.code(code),
		.sigma(factor8),
		.sigma_rot(factor8_rot)
	);

	rotate_16 rot160(
		.code(code),
		.sigma(factor16),
		.sigma_rot(factor16_rot)
	);

	rotate_24 rot240(
		.code(code),
		.sigma(factor24),
		.sigma_rot(factor24_rot)
	);

	rotate_32 rot320(
		.code(code),
		.sigma(factor32),
		.sigma_rot(factor32_rot)
	);

	always @(*) begin
		for (i=8;i<`PARALLEL_NUM;i=i+8) begin
			for (j=0;j<8;j=j+1) begin
				case(code)
					2'd0: chien_data[i+j] = 0;
					2'd1: chien_data[i+j] = data_rec[(i*MAX_CYCLES_M6+j)*7+:7];
					2'd2: chien_data[i+j] = data_rec[(i*MAX_CYCLES_M8+j)*7+:7];
					2'd3: chien_data[i+j] = data_rec[(i*MAX_CYCLES_M10+j)*7+:7];
				endcase
			end
		end
		for (j=1;j<8;j=j+1) begin
			case(code)
				2'd0: chien_data[j] = 0;
				2'd1: chien_data[j] = data_rec[j*7+:7];
				2'd2: chien_data[j] = data_rec[j*7+:7];
				2'd3: chien_data[j] = data_rec[j*7+:7];
			endcase
		end
		case(code)
			2'd0: chien_data[0] = 0;
			2'd1: chien_data[0] = data_rec[441+:7];
			2'd2: chien_data[0] = data_rec[1785+:7];
			2'd3: chien_data[0] = data_rec[7161+:7];
		endcase
	end
	
	always @(*) begin
		if (ready | chien) begin
			case(code)
				2'd1: data_rec_next = {6720'b0, data_rec[62:7], data_rec[447:175], data_rot, data_rec[118:63]};
				2'd2: data_rec_next = {5376'b0, data_rec[62:7], data_rec[1791:175], data_rot, data_rec[118:63]};
				2'd3: data_rec_next = {data_rec[62:7], data_rec[7167:175], data_rot, data_rec[118:63]};
				default: data_rec_next = 0;
			endcase
		end
		else if (reset) data_rec_next = 0;
		else data_rec_next = data_rec;
	end

	always @(*) begin
		if (ready | reset) begin
			cnt_next = 0;
			factor8_next = 10'b1;
			factor16_next = 10'b1;
			factor24_next = 10'b1;
			factor32_next = 10'b1;
		end
		else if (chien) begin
			cnt_next = cnt + 1;
			factor8_next = factor8_rot;
			factor16_next = factor16_rot;
			factor24_next = factor24_rot;
			factor32_next = factor32_rot;
		end
		else begin
			cnt_next = cnt;
			factor8_next = factor8;
			factor16_next = factor16;
			factor24_next = factor24;
			factor32_next = factor32;
		end
	end

	always @(posedge gclk2) begin	// code = 3
		if (~rstn) begin
			data_rec[7167:1792]	<= 0;
			factor24			<= 10'b1;
			factor32			<= 10'b1;
		end
		else begin
			data_rec[7167:1792]	<= data_rec_next[7167:1792];
			factor24			<= factor24_next;
			factor32			<= factor32_next;
		end
	end

	always @(posedge gclk1) begin	// code = 2 or 3
		if (~rstn) begin
			data_rec[1791:448]	<= 0;
		end
		else begin
			data_rec[1791:448]	<= data_rec_next[1791:448];
		end
	end

	always @(posedge clk) begin
		if (~rstn) begin
			data_rec[447:7]	<= 0;
			cnt				<= 0;
			factor8			<= 10'b1;
			factor16		<= 10'b1;
		end
		else begin
			data_rec[447:7]	<= data_rec_next[447:7];
			cnt				<= cnt_next;
			factor8			<= factor8_next;
			factor16		<= factor16_next;
		end
	end

endmodule