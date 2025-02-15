//------------------------------------------------------------------------------------------------
// Create and Design: ducanh         Email: ducanhld15@gmail.com
//-----------------------------------------------------------------------------------------------
// Module: dummy ahb_decoder_s2
// Ver 1.0:        mod1.0  :  12/08/2024  ; create and design 
// Ver 2.0:        mod2.0  :  17/08/2024   
//
// Tille: if code debug or need more some feature or reduce as well as perious version, 
// you can note (Anhmode_ + "day/month/year"). Example : Anhmode_16082024
module ahb_decoder_s2
     #(parameter P_NUM        =2
               , P_HSEL0_START=32'h00000000, P_HSEL0_SIZE=32'h00010000
               , P_HSEL0_END  =P_HSEL0_START+P_HSEL0_SIZE
               , P_HSEL1_START=32'h10000000, P_HSEL1_SIZE=32'h00010000
               , P_HSEL1_END  =P_HSEL1_START+P_HSEL1_SIZE
               )
(
       input   wire [31:0] HADDR
     , output  wire        HSELd // default slave
     , output  wire        HSEL0
     , output  wire        HSEL1
     , input   wire        REMAP
);
   wire [1:0] ihsel;
   wire       ihseld = ~|ihsel;
   assign HSELd = ihseld;
   assign HSEL0 = (REMAP) ? ihsel[1] : ihsel[0];
   assign HSEL1 = (REMAP) ? ihsel[0] : ihsel[1];
   assign ihsel[0] = ((P_NUM>0)&&(HADDR>=P_HSEL0_START)&&(HADDR<P_HSEL0_END)) ? 1'b1 : 1'b0;
   assign ihsel[1] = ((P_NUM>1)&&(HADDR>=P_HSEL1_START)&&(HADDR<P_HSEL1_END)) ? 1'b1 : 1'b0;
endmodule
