//=====================================================================
// GF(2^6) constant multipliers for NSU
// Primitive polynomial: x^6 + x + 1
// Constants: ['alpha^5', 'alpha^7', 'alpha^9', 'alpha^10', 'alpha^11', 'alpha^14', 'alpha^15', 'alpha^18', 'alpha^21', 'alpha^22', 'alpha^27', 'alpha^33']
//=====================================================================

//---------------------------------------------------------------------
// y = alpha^5 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a05 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[1];
    assign y[1] = x[1] ^ x[2];
    assign y[2] = x[2] ^ x[3];
    assign y[3] = x[3] ^ x[4];
    assign y[4] = x[4] ^ x[5];
    assign y[5] = x[0] ^ x[5];
endmodule

//---------------------------------------------------------------------
// y = alpha^7 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a07 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[4] ^ x[5];
    assign y[1] = x[0] ^ x[4];
    assign y[2] = x[0] ^ x[1] ^ x[5];
    assign y[3] = x[1] ^ x[2];
    assign y[4] = x[2] ^ x[3];
    assign y[5] = x[3] ^ x[4];
endmodule

//---------------------------------------------------------------------
// y = alpha^9 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a09 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[2] ^ x[3];
    assign y[1] = x[2] ^ x[4];
    assign y[2] = x[3] ^ x[5];
    assign y[3] = x[0] ^ x[4];
    assign y[4] = x[0] ^ x[1] ^ x[5];
    assign y[5] = x[1] ^ x[2];
endmodule

//---------------------------------------------------------------------
// y = alpha^10 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a10 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[1] ^ x[2];
    assign y[1] = x[1] ^ x[3];
    assign y[2] = x[2] ^ x[4];
    assign y[3] = x[3] ^ x[5];
    assign y[4] = x[0] ^ x[4];
    assign y[5] = x[0] ^ x[1] ^ x[5];
endmodule

//---------------------------------------------------------------------
// y = alpha^11 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a11 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[0] ^ x[1] ^ x[5];
    assign y[1] = x[0] ^ x[2] ^ x[5];
    assign y[2] = x[1] ^ x[3];
    assign y[3] = x[2] ^ x[4];
    assign y[4] = x[3] ^ x[5];
    assign y[5] = x[0] ^ x[4];
endmodule

//---------------------------------------------------------------------
// y = alpha^14 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a14 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[2] ^ x[4];
    assign y[1] = x[2] ^ x[3] ^ x[4] ^ x[5];
    assign y[2] = x[0] ^ x[3] ^ x[4] ^ x[5];
    assign y[3] = x[1] ^ x[4] ^ x[5];
    assign y[4] = x[0] ^ x[2] ^ x[5];
    assign y[5] = x[1] ^ x[3];
endmodule

//---------------------------------------------------------------------
// y = alpha^15 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a15 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[1] ^ x[3];
    assign y[1] = x[1] ^ x[2] ^ x[3] ^ x[4];
    assign y[2] = x[2] ^ x[3] ^ x[4] ^ x[5];
    assign y[3] = x[0] ^ x[3] ^ x[4] ^ x[5];
    assign y[4] = x[1] ^ x[4] ^ x[5];
    assign y[5] = x[0] ^ x[2] ^ x[5];
endmodule

//---------------------------------------------------------------------
// y = alpha^18 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a18 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[0] ^ x[3] ^ x[4] ^ x[5];
    assign y[1] = x[0] ^ x[1] ^ x[3];
    assign y[2] = x[0] ^ x[1] ^ x[2] ^ x[4];
    assign y[3] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[5];
    assign y[4] = x[1] ^ x[2] ^ x[3] ^ x[4];
    assign y[5] = x[2] ^ x[3] ^ x[4] ^ x[5];
endmodule

//---------------------------------------------------------------------
// y = alpha^21 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a21 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[5];
    assign y[1] = x[0] ^ x[4] ^ x[5];
    assign y[2] = x[1] ^ x[5];
    assign y[3] = x[0] ^ x[2];
    assign y[4] = x[0] ^ x[1] ^ x[3];
    assign y[5] = x[0] ^ x[1] ^ x[2] ^ x[4];
endmodule

//---------------------------------------------------------------------
// y = alpha^22 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a22 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[0] ^ x[1] ^ x[2] ^ x[4];
    assign y[1] = x[3] ^ x[4] ^ x[5];
    assign y[2] = x[0] ^ x[4] ^ x[5];
    assign y[3] = x[1] ^ x[5];
    assign y[4] = x[0] ^ x[2];
    assign y[5] = x[0] ^ x[1] ^ x[3];
endmodule

//---------------------------------------------------------------------
// y = alpha^27 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a27 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[3] ^ x[4] ^ x[5];
    assign y[1] = x[0] ^ x[3];
    assign y[2] = x[0] ^ x[1] ^ x[4];
    assign y[3] = x[0] ^ x[1] ^ x[2] ^ x[5];
    assign y[4] = x[1] ^ x[2] ^ x[3];
    assign y[5] = x[2] ^ x[3] ^ x[4];
endmodule

//---------------------------------------------------------------------
// y = alpha^33 * x  in GF(2^6), psi(x) = x^6 + x + 1
//---------------------------------------------------------------------
module mul_a33 (
    input  wire [5:0] x,
    output wire [5:0] y
);
    assign y[0] = x[2] ^ x[5];
    assign y[1] = x[0] ^ x[2] ^ x[3] ^ x[5];
    assign y[2] = x[1] ^ x[3] ^ x[4];
    assign y[3] = x[2] ^ x[4] ^ x[5];
    assign y[4] = x[0] ^ x[3] ^ x[5];
    assign y[5] = x[1] ^ x[4];
endmodule

