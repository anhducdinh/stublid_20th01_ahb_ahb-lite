/// AMBA AHB BFM for Master 
/// 
//  Creater: Phuc Nguyen -- Lasted updated: 4/Jun/2023 (Current final version)

`timescale 1ns/1ns

module ahb_tester
     #(parameter P_MST_ID=0 // Master ID
               , P_NUM_MST=2 // num of masters
               , P_NUM_SLV=2 // num of slaves
               , P_SIZE_IN_BYTES=1024 // size of slave
               , ENABLE=1'b1)
(
       input   wire        HRESETn
     , input   wire        HCLK
     , output  reg         HBUSREQ=1'b0
     , input   wire        HGRANT
     , output  reg  [31:0] HADDR=32'h0
     , output  reg  [ 3:0] HPROT=4'h0
     , output  reg         HLOCK=1'b0
     , output  reg  [ 1:0] HTRANS=2'b0
     , output  reg         HWRITE=1'b0
     , output  reg  [ 2:0] HSIZE=3'h0
     , output  reg  [ 2:0] HBURST=3'h0
     , output  reg  [31:0] HWDATA=32'h0
     , input   wire [31:0] HRDATA
     , input   wire [ 1:0] HRESP
     , input   wire        HREADY
);
   //---------------------------------------------------------------------------
   wire [31:0] addr_start[0:P_NUM_SLV-1];
   wire [31:0] addr_end  [0:P_NUM_SLV-1]; 
   //---------------------------------------------------------------------------
   generate
   genvar ida;
   for (ida=0; ida<P_NUM_SLV; ida=ida+1) begin : BLK_ADD
        assign addr_start[ida] = P_SIZE_IN_BYTES*ida;
        assign addr_end  [ida] = P_SIZE_IN_BYTES*(ida+1)-1;
   end
   endgenerate
   //---------------------------------------------------------------------------
   `include "ahb_tasks.v"
   `include "mem_test_tasks.v"
   //---------------------------------------------------------------------------
   integer idx, idy;
   reg done=1'b0;
   //---------------------------------------------------------------------------
   initial begin
       HBUSREQ =  1'b0;
       HADDR   = 32'h0;
       HPROT   =  4'h0;
       HLOCK   =  1'b0;
       HTRANS  =  2'b0;
       HWRITE  =  1'b0;
       HSIZE   =  3'h0;
       HBURST  =  3'h0;
       HWDATA  = 32'h0;
       while  (HRESETn===1'b0) @ (posedge HCLK);
       if (ENABLE) begin
           @ (posedge HCLK);
           for (idx=0; idx<P_NUM_SLV; idx=idx+1) begin
                idy = (idx+P_MST_ID)%P_NUM_SLV;
                single_trasfer_test(addr_start[idy], addr_end[idy], 4);
				single_trasfer_test(addr_start[idy], addr_end[idy], 2);
           end
           repeat (20) @ (posedge HCLK);
           
           @ (posedge HCLK);
           for (idx=0; idx<P_NUM_SLV; idx=idx+1) begin
                idy = (idx+P_MST_ID)%P_NUM_SLV;
                HWRITE = 1'b0;
                #100;
                burst_transfer_test(addr_start[idy], addr_end[idy], 4, 2);
                burst_transfer_test(addr_start[idy], addr_end[idy], 4, 4);
           end
           repeat (20) @ (posedge HCLK);
       end
        done=1'b1;
   end
endmodule

