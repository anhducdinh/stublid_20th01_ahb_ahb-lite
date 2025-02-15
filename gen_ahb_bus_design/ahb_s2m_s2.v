//------------------------------------------------------------------------------------------------
// Create and Design: ducanh         Email: ducanhld15@gmail.com
//-----------------------------------------------------------------------------------------------
// Module: dummy ahb slave to master 2
// Ver 1.0:        mod1.0  :   17/08/2024 :  create and design 
// Ver 2.0:        mod2.0  :  
//
// Tille: if code debug or need more some feature or reduce as well as perious version, 
// you can note (Anhmode_ + "day/month/year"). Example : Anhmode_16082024
module ahb_s2m_s2
(
       input   wire         HRESETn
     , input   wire         HCLK
     , input   wire         HSELd
     , input   wire         HSEL0
     , input   wire         HSEL1
     , output  reg   [31:0] HRDATA
     , output  reg   [ 1:0] HRESP
     , output  reg          HREADY
     , input   wire  [31:0] HRDATA0
     , input   wire  [ 1:0] HRESP0
     , input   wire         HREADY0
     , input   wire  [31:0] HRDATA1
     , input   wire  [ 1:0] HRESP1
     , input   wire         HREADY1
     , input   wire  [31:0] HRDATAd
     , input   wire  [ 1:0] HRESPd
     , input   wire         HREADYd
);
  localparam D_HSEL0 = 3'h1;
  localparam D_HSEL1 = 3'h2;
  localparam D_HSELd = 3'h4;
  wire [2:0] _hsel = {HSELd,HSEL1,HSEL0};
  reg  [2:0] _hsel_reg;
  always @ (posedge HCLK or negedge HRESETn) begin
    if (HRESETn==1'b0)   _hsel_reg <= 3'h0;
    else if(HREADY) _hsel_reg <= _hsel; // default HREADY must be 1'b1
  end
  always @ (_hsel_reg or HREADYd or HREADY0 or HREADY1) begin
    case(_hsel_reg)
      D_HSEL0: HREADY = HREADY0;
      D_HSEL1: HREADY = HREADY1;
      D_HSELd: HREADY = HREADYd;
      default: HREADY = 1'b1;
    endcase
  end
  always @ (_hsel_reg or HRDATAd or HRDATA0 or HRDATA1) begin
    case(_hsel_reg)
      D_HSEL0: HRDATA = HRDATA0;
      D_HSEL1: HRDATA = HRDATA1;
      D_HSELd: HRDATA = HRDATAd;
      default: HRDATA = 32'b0;
    endcase
  end
  always @ (_hsel_reg or HRESPd or HRESP0 or HRESP1) begin
    case(_hsel_reg)
      D_HSEL0: HRESP = HRESP0;
      D_HSEL1: HRESP = HRESP1;
      D_HSELd: HRESP = HRESPd;
      default: HRESP = 2'b01; //`HRESP_ERROR;
    endcase
  end
endmodule
