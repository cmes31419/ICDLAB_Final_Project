module CHIP ( clk, rst, idata, ivalid, odata, ovalid, iready);
  input [7:0] idata;
  output [7:0] odata;
  input clk, rst, ivalid;
  output ovalid, iready;

  wire [7:0] i_idata;
  wire [7:0] i_odata;
  wire i_clk, i_rst, i_ivalid;
  wire i_ovalid, i_iready;
  wire n_logic0, n_logic1;
  TOP chip_in ( .clk(i_clk), .rst(i_rst), .idata(i_idata), .ivalid(i_ivalid), 
        .odata(i_odata), .ovalid(i_ovalid), .iready(i_iready) );
  
  TIE0 ipad_n_logic0 ( .O(n_logic0) );
  TIE1 ipad_n_logic1 ( .O(n_logic1) );

  XMD ipad_clk ( .O(i_clk), .I(clk), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_rst ( .O(i_rst), .I(rst), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_ivalid ( .O(i_ivalid), .I(ivalid), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_0 ( .O(i_idata[0]), .I(idata[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_1 ( .O(i_idata[1]), .I(idata[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_2 ( .O(i_idata[2]), .I(idata[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_3 ( .O(i_idata[3]), .I(idata[3]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_4 ( .O(i_idata[4]), .I(idata[4]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_5 ( .O(i_idata[5]), .I(idata[5]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_6 ( .O(i_idata[6]), .I(idata[6]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );
  XMD ipad_idata_7 ( .O(i_idata[7]), .I(idata[7]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0) );

  YA2GSD opad_ovalid ( .O(ovalid), .I(i_ovalid), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_iready ( .O(iready), .I(i_iready), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_0 ( .O(odata[0]), .I(i_odata[0]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_1 ( .O(odata[1]), .I(i_odata[1]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_2 ( .O(odata[2]), .I(i_odata[2]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_3 ( .O(odata[3]), .I(i_odata[3]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_4 ( .O(odata[4]), .I(i_odata[4]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_5 ( .O(odata[5]), .I(i_odata[5]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_6 ( .O(odata[6]), .I(i_odata[6]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );
  YA2GSD opad_odata_7 ( .O(odata[7]), .I(i_odata[7]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0) );

endmodule