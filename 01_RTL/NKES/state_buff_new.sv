module state_buff_new(
    input           clk,
    input           rst,

    input           forward,
    input           pe_cnt,

    input           raddr,

    input           Lwaddr,
    input           Lwen,
    input [5:0]     Lsigma_in[3:0],
    input [5:0]     Lb_in[3:0],
    input [5:0]     Ldelta_even_in[1:0],    // delta_even[0] = d0, delta_even[1] = d2
    input [5:0]     Ltheta_even_in[1:0],    // theta_even[0] = t0, theta_even[1] = t2
    input [5:0]     Lgamma_in,
    input [1:0]     Lk_in,

    input           Nwen,
    input [5:0]     Nsigma_in[3:0],
    input [5:0]     Nb_in[3:0],
    input [5:0]     Ndelta_even_in[1:0],
    input [5:0]     Ntheta_even_in[1:0],
    input [5:0]     Ngamma_in,
    input [2:0]     Nk_in,

    output [5:0]    sigma_out[3:0],
    output [5:0]    b_out[3:0],
    output [5:0]    delta_even_out[1:0],
    output [5:0]    theta_even_out[1:0],
    output [5:0]    gamma_out,
    output [3:0]    k_out
);

    reg [5:0]   sigma_buff[1:0][1:0][3:0], sigma_buff_next[1:0][1:0][3:0];
    reg [5:0]   b_buff[1:0][1:0][3:0], b_buff_next[1:0][1:0][3:0];
    reg [5:0]   delta_buff[1:0][1:0][1:0], delta_buff_next[1:0][1:0][1:0]; // stores only even coeff
    reg [5:0]   theta_buff[1:0][1:0][1:0], theta_buff_next[1:0][1:0][1:0]; // stores only even coeff
    reg [5:0]   gamma_buff[1:0][1:0], gamma_buff_next[1:0][1:0];
    reg [1:0]   k_buff[1:0][1:0], k_buff_next[1:0][1:0];

    reg [5:0]   sigma_buff_add[1:0], sigma_buff_add_next[1:0];
    reg [5:0]   b_buff_add[1:0], b_buff_add_next[1:0];
    reg [5:0]   delta_buff_add, delta_buff_add_next;
    reg [5:0]   theta_buff_add, theta_buff_add_next;
    reg         k_buff_add, k_buff_add_next;

    reg [5:0]   sigma_no_forward[1:0][1:0][3:0];
    reg [5:0]   b_no_forward[1:0][1:0][3:0];
    reg [5:0]   delta_no_forward[1:0][1:0][1:0];
    reg [5:0]   theta_no_forward[1:0][1:0][1:0];
    reg [5:0]   gamma_no_forward[1:0][1:0];
    reg [1:0]   k_no_forward[1:0][1:0];

    integer h, i, j;

    genvar gi;

    assign gamma_out = gamma_buff[0][raddr];
    assign k_out = {1'b0, raddr ? 1'b0 : k_buff_add, k_buff[0][raddr]};
    assign delta_even_out[0] = pe_cnt ? (raddr ? 6'b0 : delta_buff_add) : delta_buff[0][raddr][0];
    assign theta_even_out[0] = pe_cnt ? (raddr ? 6'b0 : theta_buff_add) : theta_buff[0][raddr][0];
    assign delta_even_out[1] = pe_cnt ? 6'b0 : delta_buff[0][raddr][1];
    assign theta_even_out[1] = pe_cnt ? 6'b0 : theta_buff[0][raddr][1];

    generate
        for (gi = 0; gi < 2; gi = gi + 1) begin
            assign sigma_out[gi] = pe_cnt ? (raddr ? 6'b0 : sigma_buff_add[gi]) : sigma_buff[0][raddr][gi];
            assign b_out[gi] = pe_cnt ? (raddr ? 6'b0 : b_buff_add[gi]) : b_buff[0][raddr][gi];
        end
        for (gi = 2; gi < 4; gi = gi + 1) begin
            assign sigma_out[gi] = pe_cnt ? 6'b0 : sigma_buff[0][raddr][gi];
            assign b_out[gi] = pe_cnt ? 6'b0 : b_buff[0][raddr][gi];
        end
    endgenerate

    always @(*) begin
        for (j = 0; j < 2; j = j + 1) begin
            sigma_buff_add_next[j] = forward ? 6'b0 :  ((Nwen & pe_cnt) ? Nsigma_in[j] : sigma_buff_add[j]);
            b_buff_add_next[j] = forward ? 6'b0 : ((Nwen & pe_cnt) ? Nb_in[j] : b_buff_add[j]);
        end
        delta_buff_add_next = forward ? 6'b0 : ((Nwen & pe_cnt) ? Ndelta_even_in[0] : delta_buff_add);
        theta_buff_add_next = forward ? 6'b0 : ((Nwen & pe_cnt) ? Ntheta_even_in[0] : theta_buff_add);
        k_buff_add_next = forward ? 1'b0 : ((Nwen & pe_cnt) ? Nk_in[2] : k_buff_add);
    end

    always @(*) begin
        for (j = 0; j < 4; j = j + 1) begin
            sigma_no_forward[0][0][j] = (Nwen & ~pe_cnt) ? Nsigma_in[j] : sigma_buff[0][0][j];
            sigma_no_forward[0][1][j] = sigma_buff[0][1][j];
            b_no_forward[0][0][j] = (Nwen & ~pe_cnt) ? Nb_in[j] : b_buff[0][0][j];
            b_no_forward[0][1][j] = b_buff[0][1][j];
        end
        for (j = 0; j < 2; j = j + 1) begin
            delta_no_forward[0][0][j] = (Nwen & ~pe_cnt) ? Ndelta_even_in[j] : delta_buff[0][0][j];
            delta_no_forward[0][1][j] = delta_buff[0][1][j];
            theta_no_forward[0][0][j] = (Nwen & ~pe_cnt) ? Ntheta_even_in[j] : theta_buff[0][0][j];
            theta_no_forward[0][1][j] = theta_buff[0][1][j];
        end
        gamma_no_forward[0][0] = (Nwen & ~pe_cnt) ? Ngamma_in : gamma_buff[0][0];
        gamma_no_forward[0][1] = gamma_buff[0][1];
        k_no_forward[0][0] = (Nwen & ~pe_cnt) ? Nk_in[1:0] : k_buff[0][0];
        k_no_forward[0][1] = k_buff[0][1];

        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                sigma_no_forward[1][i][j] = (Lwen && Lwaddr == i) ? Lsigma_in[j] : sigma_buff[1][i][j];
                b_no_forward[1][i][j] = (Lwen && Lwaddr == i) ? Lb_in[j] : b_buff[1][i][j];
            end
            for (j = 0; j < 2; j = j + 1) begin
                delta_no_forward[1][i][j] = (Lwen && Lwaddr == i) ? Ldelta_even_in[j] : delta_buff[1][i][j];
                theta_no_forward[1][i][j] = (Lwen && Lwaddr == i) ? Ltheta_even_in[j] : theta_buff[1][i][j];
            end
            gamma_no_forward[1][i] = (Lwen && Lwaddr == i) ? Lgamma_in : gamma_buff[1][i];
            k_no_forward[1][i] = (Lwen && Lwaddr == i) ? Lk_in : k_buff[1][i];
        end
    end

    always @(*) begin
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                sigma_buff_next[0][i][j] = forward ? sigma_no_forward[1][i][j] : sigma_no_forward[0][i][j];
                sigma_buff_next[1][i][j] = forward ? 6'b0 : sigma_no_forward[1][i][j];
                b_buff_next[0][i][j] = forward ? b_no_forward[1][i][j] : b_no_forward[0][i][j];
                b_buff_next[1][i][j] = forward ? 6'b0 : b_no_forward[1][i][j];
            end
            for (j = 0; j < 2; j = j + 1) begin
                delta_buff_next[0][i][j] = forward ? delta_no_forward[1][i][j] : delta_no_forward[0][i][j];
                delta_buff_next[1][i][j] = forward ? 6'b0 : delta_no_forward[1][i][j];
                theta_buff_next[0][i][j] = forward ? theta_no_forward[1][i][j] : theta_no_forward[0][i][j];
                theta_buff_next[1][i][j] = forward ? 6'b0 : theta_no_forward[1][i][j];
            end
            gamma_buff_next[0][i] = forward ? gamma_no_forward[1][i] : gamma_no_forward[0][i];
            gamma_buff_next[1][i] = forward ? 6'b0 : gamma_no_forward[1][i];
            k_buff_next[0][i] = forward ? k_no_forward[1][i] : k_no_forward[0][i];
            k_buff_next[1][i] = forward ? 2'b0 : k_no_forward[1][i];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (h = 0; h < 2; h = h + 1) begin
                for (i = 0; i < 2; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        sigma_buff[h][i][j] <= 0;
                        b_buff[h][i][j]     <= 0;
                    end
                    for (j = 0; j < 2; j = j + 1) begin
                        delta_buff[h][i][j] <= 0;
                        theta_buff[h][i][j] <= 0;
                    end
                    gamma_buff[h][i]    <= 0;
                    k_buff[h][i]        <= 0;
                end
            end
            for (j = 0; j < 2; j = j + 1) begin
                sigma_buff_add[j]   <= 0;
                b_buff_add[j]       <= 0;
            end
            delta_buff_add  <= 0;
            theta_buff_add  <= 0;
            k_buff_add      <= 0;
        end
        else begin
            for (h = 0; h < 2; h = h + 1) begin
                for (i = 0; i < 2; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        sigma_buff[h][i][j] <= sigma_buff_next[h][i][j];
                        b_buff[h][i][j]     <= b_buff_next[h][i][j];
                    end
                    for (j = 0; j < 2; j = j + 1) begin
                        delta_buff[h][i][j] <= delta_buff_next[h][i][j];
                        theta_buff[h][i][j] <= theta_buff_next[h][i][j];
                    end
                    gamma_buff[h][i]    <= gamma_buff_next[h][i];
                    k_buff[h][i]        <= k_buff_next[h][i];
                end
            end
            for (j = 0; j < 2; j = j + 1) begin
                sigma_buff_add[j]   <= sigma_buff_add_next[j];
                b_buff_add[j]       <= b_buff_add_next[j];
            end
            delta_buff_add  <= delta_buff_add_next;
            theta_buff_add  <= theta_buff_add_next;
            k_buff_add      <= k_buff_add_next;
        end
    end

endmodule