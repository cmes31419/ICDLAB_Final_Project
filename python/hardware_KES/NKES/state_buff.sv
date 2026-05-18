module state_buff (
    input clk,
    input rst,

    input read_idx,
    input write_idx,
    input write_en,

    input [5:0] Lsigma_in [2:0],
    input [5:0] Lb_in [2:0],
    input [5:0] Ldelta_even_in [1:0], // delta_even[0] = d0, delta_even[1] = d2
    input [5:0] Ltheta_even_in [1:0], // theta_even[0] = t0, theta_even[1] = t2
    input [5:0] Lgamma_in,
    input [1:0] Lk_in,

    output [5:0] Lsigma_out [2:0],
    output [5:0] Lb_out [2:0],
    output [5:0] Ldelta_even_out [1:0],
    output [5:0] Ltheta_even_out [1:0],
    output [5:0] Lgamma_out,
    output [1:0] Lk_out
);


    reg [5:0] sigma_buff[1:0][2:0], sigma_buff_next[1:0][2:0];
    reg [5:0] b_buff[1:0][2:0], b_buff_next[1:0][2:0];
    reg [5:0] delta_buff[1:0][1:0], delta_buff_next[1:0][1:0]; // stores only even coeff
    reg [5:0] theta_buff[1:0][1:0], theta_buff_next[1:0][1:0]; // stores only even coeff

    reg [5:0] gamma_buff[1:0], gamma_buff_next[1:0];
    reg [1:0] k_buff[1:0], k_buff_next[1:0];

    integer i, j;

    // output assignment
    genvar gi;
    generate
        for (gi = 0; gi < 3; gi = gi + 1) begin
            assign Lsigma_out[gi] = sigma_buff[read_idx][gi];
            assign Lb_out[gi] = b_buff[read_idx][gi];
        end

        for (gi = 0; gi < 2; gi = gi + 1) begin
            assign Ldelta_even_out[gi] = delta_buff[read_idx][gi];
            assign Ltheta_even_out[gi] = theta_buff[read_idx][gi];
        end

        assign Lgamma_out = gamma_buff[read_idx];
        assign Lk_out = k_buff[read_idx]; 
    endgenerate

    always @(*) begin
        if (write_en) begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    sigma_buff_next[i][j] = (i == write_idx)? Lsigma_in[j] : sigma_buff[i][j];
                    b_buff_next[i][j] = (i == write_idx)? Lb_in[j] : b_buff[i][j];
                end

                for (j = 0; j < 2; j = j + 1) begin
                    delta_buff_next[i][j] = (i == write_idx)? Ldelta_even_in[j] : delta_buff[i][j];
                    theta_buff_next[i][j] = (i == write_idx)? Ltheta_even_in[j] : theta_buff[i][j];
                end

                gamma_buff_next[i] = (i == write_idx)? Lgamma_in : gamma_buff[i];
                k_buff_next[i] = (i == write_idx)? Lk_in : k_buff[i];
            end 
        end
        else begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    sigma_buff_next[i][j] = sigma_buff[i][j];
                    b_buff_next[i][j] = b_buff[i][j];
                end

                for (j = 0; j < 2; j = j + 1) begin
                    delta_buff_next[i][j] = delta_buff[i][j];
                    theta_buff_next[i][j] = theta_buff[i][j];
                end

                gamma_buff_next[i] = gamma_buff[i];
                k_buff_next[i] = k_buff[i];
            end 
        end
    end


    always @(posedge clk or posedge rst) begin        
        if (rst) begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    sigma_buff[i][j] <= 0;
                    b_buff[i][j] <= 0;
                end

                for (j = 0; j < 2; j = j + 1) begin
                    delta_buff[i][j] <= 0;
                    theta_buff[i][j] <= 0;
                end

                gamma_buff[i] <= 0;
                k_buff[i] <= 0;
            end 
        end
        else begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    sigma_buff[i][j] <= sigma_buff_next[i][j];
                    b_buff[i][j] <= b_buff_next[i][j];
                end

                for (j = 0; j < 2; j = j + 1) begin
                    delta_buff[i][j] <= delta_buff_next[i][j];
                    theta_buff[i][j] <= theta_buff_next[i][j];
                end

                gamma_buff[i] <= gamma_buff_next[i];
                k_buff[i] <= k_buff_next[i];
            end
        end

    end
endmodule