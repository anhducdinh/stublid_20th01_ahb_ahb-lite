//------------------------------------------------------------------------------------------------
// Create and Design: ducanh         Email: ducanhld15@gmail.com
//-----------------------------------------------------------------------------------------------
// Module: ahb_lite_s2
// Ver 1.0:        mod1.0  :  18/08/2024   create and design   
//
// Tille: if code debug or need more some feature or reduce as well as perious version, 
// you can note (Anhmode_ + "day/month/year"). Example : Anhmode_16082024
module ahb_lite_s2
#(parameter P_NUM=2 // num of slaves
           , P_HSEL0_START=32'h00000000, P_HSEL0_SIZE=32'h00010000
           , P_HSEL1_START=32'h10000000, P_HSEL1_SIZE=32'h00010000
           )
(
    input   wire         HRESETn
  , input   wire         HCLK
  , input   wire  [31:0] M_HADDR
  , input   wire  [ 1:0] M_HTRANS
  , input   wire         M_HWRITE
  , input   wire  [ 2:0] M_HSIZE
  , input   wire  [ 2:0] M_HBURST
  , input   wire  [ 3:0] M_HPROT
  , input   wire  [31:0] M_HWDATA
  , output  wire  [31:0] M_HRDATA
  , output  wire  [ 1:0] M_HRESP
  , output  wire         M_HREADY
  , output  wire  [31:0] S_HADDR
  , output  wire  [ 1:0] S_HTRANS
  , output  wire  [ 2:0] S_HSIZE
  , output  wire  [ 2:0] S_HBURST
  , output  wire  [ 3:0] S_HPROT
  , output  wire         S_HWRITE
  , output  wire  [31:0] S_HWDATA
  , output  wire         S_HREADY
  , output  wire         S0_HSEL
  , input   wire         S0_HREADY
  , input   wire  [ 1:0] S0_HRESP
  , input   wire  [31:0] S0_HRDATA
  , output  wire         S1_HSEL
  , input   wire         S1_HREADY
  , input   wire  [ 1:0] S1_HRESP
  , input   wire  [31:0] S1_HRDATA
  , input   wire         REMAP
);
  wire        HSELd; // default slave
  wire [31:0] HRDATAd;
  wire [ 1:0] HRESPd;
  wire        HREADYd;
  assign S_HADDR  = M_HADDR;
  assign S_HTRANS = M_HTRANS;
  assign S_HSIZE  = M_HSIZE;
  assign S_HBURST = M_HBURST;
  assign S_HWRITE = M_HWRITE;
  assign S_HPROT  = M_HPROT;
  assign S_HWDATA = M_HWDATA;
  assign S_HREADY = M_HREADY;
  ahb_decoder_s2
    #(.P_NUM(2)
     ,.P_HSEL0_START(P_HSEL0_START),.P_HSEL0_SIZE(P_HSEL0_SIZE)
     ,.P_HSEL1_START(P_HSEL1_START),.P_HSEL1_SIZE(P_HSEL1_SIZE)
     )
  u_ahb_decoder (
                .HADDR(M_HADDR)
               ,.HSELd(HSELd)
               ,.HSEL0(S0_HSEL)
               ,.HSEL1(S1_HSEL)
               ,.REMAP(REMAP));
  ahb_s2m_s2 u_ahb_s2m (
                .HRESETn(HRESETn)
               ,.HCLK   (HCLK   )
               ,.HRDATA (M_HRDATA)
               ,.HRESP  (M_HRESP )
               ,.HREADY (M_HREADY)
               ,.HSEL0  (S0_HSEL)
               ,.HRDATA0(S0_HRDATA)
               ,.HRESP0 (S0_HRESP)
               ,.HREADY0(S0_HREADY)
               ,.HSEL1  (S1_HSEL)
               ,.HRDATA1(S1_HRDATA)
               ,.HRESP1 (S1_HRESP)
               ,.HREADY1(S1_HREADY)
               ,.HSELd  (HSELd  )
               ,.HRDATAd(HRDATAd)
               ,.HRESPd (HRESPd )
               ,.HREADYd(HREADYd));
  ahb_default_slave u_ahb_default_slave (
                .HRESETn  (HRESETn  )
               ,.HCLK     (HCLK     )
               ,.HSEL     (HSELd    )
               ,.HADDR    (S_HADDR  )
               ,.HTRANS   (S_HTRANS )
               ,.HWRITE   (S_HWRITE )
               ,.HSIZE    (S_HSIZE  )
               ,.HBURST   (S_HBURST )
               ,.HWDATA   (S_HWDATA )
               ,.HRDATA   (HRDATAd  )
               ,.HRESP    (HRESPd   )
               ,.HREADYin (S_HREADY )
               ,.HREADYout(HREADYd  ));
endmodule
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------