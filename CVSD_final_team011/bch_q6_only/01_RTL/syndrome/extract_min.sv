module extract_min_2(
    input           clk,
    input           rstn,
    input [55:0]    data,
    output [6:0]    exm_min0_abs,
    output [2:0]    exm_min0_loc,
    output [6:0]    exm_min1_abs,
    output [2:0]    exm_min1_loc
);

    wire        sel0, sel1, sel2, sel3;

    reg [6:0]   sv0, sv1, sv2, sv3;
    reg [6:0]   bv0, bv1, bv2, bv3;
    reg [2:0]   sl0, sl1, sl2, sl3;
    reg [2:0]   bl0, bl1, bl2, bl3;
    
    wire [6:0]  sv0_next, sv1_next, sv2_next, sv3_next;
    wire [6:0]  bv0_next, bv1_next, bv2_next, bv3_next;
    wire [2:0]  sl0_next, sl1_next, sl2_next, sl3_next;
    wire [2:0]  bl0_next, bl1_next, bl2_next, bl3_next;

    wire [6:0]  sv4, sv5;
    wire [6:0]  bv4, bv5, bv6, bv7;
    wire [2:0]  sl4, sl5;
    wire [2:0]  bl4, bl5, bl6, bl7;

    wire [6:0]  sv6, bv8, bv9;
    wire [2:0]  sl6, bl8, bl9;

    cmp_loc_2 cmpl20(
        .xv(data[0+:7]),
        .yv(data[7+:7]),
        .xl(3'd7),
        .yl(3'd6),
        .sv(sv0_next),
        .bv(bv0_next),
        .sl(sl0_next),
        .bl(bl0_next)
    );
    
    cmp_loc_2 cmpl21(
        .xv(data[14+:7]),
        .yv(data[21+:7]),
        .xl(3'd5),
        .yl(3'd4),
        .sv(sv1_next),
        .bv(bv1_next),
        .sl(sl1_next),
        .bl(bl1_next)
    );

    cmp_loc_2 cmpl22(
        .xv(data[28+:7]),
        .yv(data[35+:7]),
        .xl(3'd3),
        .yl(3'd2),
        .sv(sv2_next),
        .bv(bv2_next),
        .sl(sl2_next),
        .bl(bl2_next)
    );

    cmp_loc_2 cmpl23(
        .xv(data[42+:7]),
        .yv(data[49+:7]),
        .xl(3'd1),
        .yl(3'd0),
        .sv(sv3_next),
        .bv(bv3_next),
        .sl(sl3_next),
        .bl(bl3_next)
    );

    cmp_loc_4 cmpl40(
        .sv0(sv0),
        .bv0(bv0),
        .sv1(sv1),
        .bv1(bv1),
        .sl0(sl0),
        .bl0(bl0),
        .sl1(sl1),
        .bl1(bl1),
        .sv4(sv4),
        .bv4(bv4),
        .bv5(bv5),
        .sl4(sl4),
        .bl4(bl4),
        .bl5(bl5)
    );

    cmp_loc_4 cmpl41(
        .sv0(sv2),
        .bv0(bv2),
        .sv1(sv3),
        .bv1(bv3),
        .sl0(sl2),
        .bl0(bl2),
        .sl1(sl3),
        .bl1(bl3),
        .sv4(sv5),
        .bv4(bv6),
        .bv5(bv7),
        .sl4(sl5),
        .bl4(bl6),
        .bl5(bl7)
    );

    assign sel0 = (sv4 <= sv5) ? 1 : 0;
    assign sel1 = (bv4 <= bv5) ? 1 : 0;
    assign sel2 = (bv6 <= bv7) ? 1 : 0;
    assign sel3 = (bv8 <= bv9) ? 1 : 0;

    assign sv6 = sel0 ? sv4 : sv5;
    assign bv8 = sel0 ? (sel1 ? bv4 : bv5) : (sel2 ? bv6 : bv7);
    assign bv9 = sel0 ? sv5 : sv4;
    assign sl6 = sel0 ? sl4 : sl5;
    assign bl8 = sel0 ? (sel1 ? bl4 : bl5) : (sel2 ? bl6 : bl7);
    assign bl9 = sel0 ? sl5 : sl4;

    assign exm_min0_abs = sv6;
    assign exm_min0_loc = sl6;
    assign exm_min1_abs = sel3 ? bv8 : bv9;
    assign exm_min1_loc = sel3 ? bl8 : bl9;

    always @(posedge clk) begin
        if (~rstn) begin
            sv0    <= 0;
            bv0    <= 0;
            sl0    <= 0;
            bl0    <= 0;
            sv1    <= 0;
            bv1    <= 0;
            sl1    <= 0;
            bl1    <= 0;
            sv2    <= 0;
            bv2    <= 0;
            sl2    <= 0;
            bl2    <= 0;
            sv3    <= 0;
            bv3    <= 0;
            sl3    <= 0;
            bl3    <= 0;
        end
        else begin
            sv0    <= sv0_next;
            bv0    <= bv0_next;
            sl0    <= sl0_next;
            bl0    <= bl0_next;
            sv1    <= sv1_next;
            bv1    <= bv1_next;
            sl1    <= sl1_next;
            bl1    <= bl1_next;
            sv2    <= sv2_next;
            bv2    <= bv2_next;
            sl2    <= sl2_next;
            bl2    <= bl2_next;
            sv3    <= sv3_next;
            bv3    <= bv3_next;
            sl3    <= sl3_next;
            bl3    <= bl3_next;
        end
    end

endmodule

module cmp_loc_2(
    input [6:0]     xv,
    input [6:0]     yv,
    input [2:0]     xl,
    input [2:0]     yl,
    output [6:0]    sv,
    output [6:0]    bv,
    output [2:0]    sl,
    output [2:0]    bl
);

    wire sel;

    assign sel = (xv <= yv) ? 1 : 0;
    assign sv = sel ? xv : yv;
    assign bv = sel ? yv : xv;
    assign sl = sel ? xl : yl;
    assign bl = sel ? yl : xl;

endmodule

module cmp_loc_4(
    input [6:0]     sv0,
    input [6:0]     bv0,
    input [6:0]     sv1,
    input [6:0]     bv1,
    input [2:0]     sl0,
    input [2:0]     bl0,
    input [2:0]     sl1,
    input [2:0]     bl1,
    output [6:0]    sv4,
    output [6:0]    bv4,
    output [6:0]    bv5,
    output [2:0]    sl4,
    output [2:0]    bl4,
    output [2:0]    bl5
);

    wire sel;

    assign sel = (sv0 <= sv1) ? 1 : 0;

    assign sv4 = sel ? sv0 : sv1;
    assign bv4 = sel ? bv0 : bv1;
    assign bv5 = sel ? sv1 : sv0;
    assign sl4 = sel ? sl0 : sl1;
    assign bl4 = sel ? bl0 : bl1;
    assign bl5 = sel ? sl1 : sl0;

endmodule