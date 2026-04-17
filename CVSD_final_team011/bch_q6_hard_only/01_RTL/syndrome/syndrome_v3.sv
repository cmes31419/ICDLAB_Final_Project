module syndrome(
	input           clk,
	input           rstn,
    input           ready,
    input           reset,
	input [63:0]    data,
    output          valid,
    output [5:0]    Sa[2:0]
);

    localparam S_IDLE = 2'd0;
    localparam S_PROC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]   state, state_next;
    reg [2:0]   cnt, cnt_next;

	reg [7:0]	syn_data, syn_data_next;

    reg [5:0]   syn1, syn1_next;
    reg [5:0]   syn3, syn3_next;

    wire [5:0]  syn1_rot, syn3_rot;

    wire [7:0]  r;
    wire [55:0] exmin;

    integer i;

    assign r = {(|cnt) ? syn_data[7] : 1'b0, syn_data[6:0]};

    assign exmin[6:0]   = data[7]  ? ~data[6:0]   + 1 : data[6:0]  ;
    assign exmin[13:7]  = data[15] ? ~data[14:8]  + 1 : data[14:8] ;
    assign exmin[20:14] = data[23] ? ~data[22:16] + 1 : data[22:16];
    assign exmin[27:21] = data[31] ? ~data[30:24] + 1 : data[30:24];
    assign exmin[34:28] = data[39] ? ~data[38:32] + 1 : data[38:32];
    assign exmin[41:35] = data[47] ? ~data[46:40] + 1 : data[46:40];
    assign exmin[48:42] = data[55] ? ~data[54:48] + 1 : data[54:48];
    assign exmin[55:49] = (state == S_PROC) ? (data[63] ? ~data[62:56] + 1 : data[62:56]) : 7'b1111111;

    assign valid = (state == S_DONE) ? 1 : 0;

    assign Sa[0] = syn1;

    pow_a_2 pa20(
        .pow1(syn1),
        .pow2(Sa[1])
    );
    
    pow_a_3 pa30(
        .pow1(syn3),
        .pow3(Sa[2])
    );

    rotate_4_8_add rot48add0(
        .syn1(syn1),
        .syn3(syn3),
        .data(r),
        .syn1_rot(syn1_rot),
        .syn3_rot(syn3_rot)
    );

    always @(*) begin
        if (state == S_PROC) begin
            syn1_next = syn1_rot;
            syn3_next = syn3_rot;
        end
        else if (reset) begin
            syn1_next = 0;
            syn3_next = 0;
        end
        else begin
            syn1_next = syn1;
            syn3_next = syn3;
        end
    end

    always @(*) begin
		syn_data_next = {data[63], data[55], data[47], data[39], data[31], data[23], data[15], data[7]};
	end

    always @(*) begin
        if (state == S_DONE) cnt_next = 0;
        else if (state == S_PROC) cnt_next = cnt + 1;
        else cnt_next = cnt;
    end

    always @(*) begin
        case(state)
            S_IDLE:     state_next = ready ? S_PROC : S_IDLE;
            S_PROC:     state_next = (cnt == 3'd7) ? S_DONE : S_PROC;
            S_DONE:     state_next = S_IDLE;
            default:    state_next = S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (~rstn) begin
            state       <= S_IDLE;
            cnt         <= 0;
			syn_data	<= 0;
            syn1        <= 0;
            syn3        <= 0;
        end
        else begin
            state       <= state_next;
            cnt         <= cnt_next;
			syn_data	<= syn_data_next;
            syn1        <= syn1_next;
            syn3        <= syn3_next;
        end
    end

endmodule