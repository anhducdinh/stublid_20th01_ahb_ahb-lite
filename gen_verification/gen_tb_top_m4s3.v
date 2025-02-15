//------------------------------------------------------------------------------
`timescale 1ns/1ns
`ifndef CLK_FREQ
`define CLK_FREQ       50000000
`endif
`ifndef BUS_DELAY
`define BUS_DELAY #(1)
`endif
`ifndef MEM_DELAY
`define MEM_DELAY 0
`endif
`ifndef SIZE_IN_BYTES
`define SIZE_IN_BYTES 1024
`endif

module top;
   //---------------------------------------------------------------------------
   localparam NUM_MST=4
            , NUM_SLV=3;
   //---------------------------------------------------------------------------
   localparam  P_HSEL0_START=32'h0,P_HSEL0_SIZE=32'h400;
   localparam  P_HSEL1_START=32'h400,P_HSEL1_SIZE=32'h400;
   localparam  P_HSEL2_START=32'h800,P_HSEL2_SIZE=32'h400;
//---------------------------------------------------------------------------
   localparam CLK_PERIOD_HALF=1_000_000_000/(`CLK_FREQ*2);
   reg         HCLK   = 1'b0; always #(CLK_PERIOD_HALF) HCLK=~HCLK;
   reg         HRESETn= 1'b0; initial #155 HRESETn=1'b1;
   //---------------------------------------------------------------------------
   wire [NUM_MST-1:0] `BUS_DELAY M_HBUSREQ ;
   wire [NUM_MST-1:0] `BUS_DELAY M_HGRANT  ;
   wire [31:0]        `BUS_DELAY M_HADDR  [0:NUM_MST-1];
   wire [ 3:0]        `BUS_DELAY M_HPROT  [0:NUM_MST-1];
   wire               `BUS_DELAY M_HLOCK  [0:NUM_MST-1];
   wire [ 1:0]        `BUS_DELAY M_HTRANS [0:NUM_MST-1];
   wire               `BUS_DELAY M_HWRITE [0:NUM_MST-1];
   wire [ 2:0]        `BUS_DELAY M_HSIZE  [0:NUM_MST-1];
   wire [ 2:0]        `BUS_DELAY M_HBURST [0:NUM_MST-1];
   wire [31:0]        `BUS_DELAY M_HWDATA [0:NUM_MST-1];
   wire [31:0]        `BUS_DELAY M_HRDATA  ;
   wire [ 1:0]        `BUS_DELAY M_HRESP   ;
   wire               `BUS_DELAY M_HREADY  ;
   //---------------------------------------------------------------------------
   wire [31:0]        `BUS_DELAY S_HADDR    ;
   wire [ 3:0]        `BUS_DELAY S_HPROT    ;
   wire [ 1:0]        `BUS_DELAY S_HTRANS   ;
   wire               `BUS_DELAY S_HWRITE   ;
   wire [ 2:0]        `BUS_DELAY S_HSIZE    ;
   wire [ 2:0]        `BUS_DELAY S_HBURST   ;
   wire [31:0]        `BUS_DELAY S_HWDATA   ;
   wire [31:0]        `BUS_DELAY S_HRDATA [0:NUM_SLV-1];
   wire [ 1:0]        `BUS_DELAY S_HRESP  [0:NUM_SLV-1];
   wire               `BUS_DELAY S_HREADY   ;
   wire               `BUS_DELAY S_HREADYout[0:NUM_SLV-1];
   wire [15:0]        `BUS_DELAY S_HSPLIT   [0:NUM_SLV-1];
   wire [NUM_SLV-1:0] `BUS_DELAY S_HSEL     ;
   wire [ 3:0]        `BUS_DELAY S_HMASTER  ;
   wire               `BUS_DELAY S_HMASTLOCK;
//---------------------------------------------------------------------------
amba_ahb_m4s3 #(.P_NUMM(NUM_MST)
                  ,.P_NUMS(NUM_SLV) 
                  ,.P_HSEL0_START(P_HSEL0_START),.P_HSEL0_SIZE(P_HSEL0_SIZE)
                  ,.P_HSEL1_START(P_HSEL1_START),.P_HSEL1_SIZE(P_HSEL1_SIZE)
                  ,.P_HSEL2_START(P_HSEL2_START),.P_HSEL2_SIZE(P_HSEL2_SIZE)
           )
   u_amba_ahb  (
        .HRESETn      (HRESETn     )
      , .HCLK         (HCLK        )
      , .M0_HBUSREQ  (M_HBUSREQ [0])
      , .M0_HGRANT   (M_HGRANT  [0])
      , .M0_HADDR    (M_HADDR   [0])
      , .M0_HTRANS   (M_HTRANS  [0])
      , .M0_HSIZE    (M_HSIZE   [0])
      , .M0_HBURST   (M_HBURST  [0])
      , .M0_HPROT    (M_HPROT   [0])
      , .M0_HLOCK    (M_HLOCK   [0])
      , .M0_HWRITE   (M_HWRITE  [0])
      , .M0_HWDATA   (M_HWDATA  [0])
      , .M1_HBUSREQ  (M_HBUSREQ [1])
      , .M1_HGRANT   (M_HGRANT  [1])
      , .M1_HADDR    (M_HADDR   [1])
      , .M1_HTRANS   (M_HTRANS  [1])
      , .M1_HSIZE    (M_HSIZE   [1])
      , .M1_HBURST   (M_HBURST  [1])
      , .M1_HPROT    (M_HPROT   [1])
      , .M1_HLOCK    (M_HLOCK   [1])
      , .M1_HWRITE   (M_HWRITE  [1])
      , .M1_HWDATA   (M_HWDATA  [1])
      , .M2_HBUSREQ  (M_HBUSREQ [2])
      , .M2_HGRANT   (M_HGRANT  [2])
      , .M2_HADDR    (M_HADDR   [2])
      , .M2_HTRANS   (M_HTRANS  [2])
      , .M2_HSIZE    (M_HSIZE   [2])
      , .M2_HBURST   (M_HBURST  [2])
      , .M2_HPROT    (M_HPROT   [2])
      , .M2_HLOCK    (M_HLOCK   [2])
      , .M2_HWRITE   (M_HWRITE  [2])
      , .M2_HWDATA   (M_HWDATA  [2])
      , .M3_HBUSREQ  (M_HBUSREQ [3])
      , .M3_HGRANT   (M_HGRANT  [3])
      , .M3_HADDR    (M_HADDR   [3])
      , .M3_HTRANS   (M_HTRANS  [3])
      , .M3_HSIZE    (M_HSIZE   [3])
      , .M3_HBURST   (M_HBURST  [3])
      , .M3_HPROT    (M_HPROT   [3])
      , .M3_HLOCK    (M_HLOCK   [3])
      , .M3_HWRITE   (M_HWRITE  [3])
      , .M3_HWDATA   (M_HWDATA  [3])
      , .M_HRDATA    (M_HRDATA     )
      , .M_HRESP     (M_HRESP      )
      , .M_HREADY    (M_HREADY     )
      , .S_HADDR     (S_HADDR      )
      , .S_HWRITE    (S_HWRITE     )
      , .S_HTRANS    (S_HTRANS     )
      , .S_HSIZE     (S_HSIZE      )
      , .S_HBURST    (S_HBURST     )
      , .S_HWDATA    (S_HWDATA     )
      , .S_HPROT     (S_HPROT      )
      , .S_HREADY    (S_HREADY     )
      , .S_HMASTER   (S_HMASTER    )
      , .S_HMASTLOCK (S_HMASTLOCK  )
      , .S0_HSEL     (S_HSEL     [0])
      , .S0_HREADY   (S_HREADYout[0])
      , .S0_HRESP    (S_HRESP    [0])
      , .S0_HRDATA   (S_HRDATA   [0])
      , .S0_HSPLIT   (S_HSPLIT   [0])
      , .S1_HSEL     (S_HSEL     [1])
      , .S1_HREADY   (S_HREADYout[1])
      , .S1_HRESP    (S_HRESP    [1])
      , .S1_HRDATA   (S_HRDATA   [1])
      , .S1_HSPLIT   (S_HSPLIT   [1])
      , .S2_HSEL     (S_HSEL     [2])
      , .S2_HREADY   (S_HREADYout[2])
      , .S2_HRESP    (S_HRESP    [2])
      , .S2_HRDATA   (S_HRDATA   [2])
      , .S2_HSPLIT   (S_HSPLIT   [2])
      , .REMAP       (1'b0          )
   );
//---------------------------------------------------------------------------
   wire [NUM_MST-1:0] done;
   //---------------------------------------------------------------------------
   generate
   genvar idx;
   for (idx=0; idx<NUM_MST; idx=idx+1) begin : BLK_MST
        ahb_tester #(.P_MST_ID(idx)
                    ,.P_NUM_MST(NUM_MST)
                    ,.P_NUM_SLV(NUM_SLV)
                    ,.P_SIZE_IN_BYTES(`SIZE_IN_BYTES))
        u_tester (
              .HRESETn (HRESETn       )
            , .HCLK    (HCLK          )
            , .HBUSREQ (M_HBUSREQ[idx])
            , .HGRANT  (M_HGRANT [idx])
            , .HADDR   (M_HADDR  [idx])
            , .HPROT   (M_HPROT  [idx])
            , .HLOCK   (M_HLOCK  [idx])
            , .HTRANS  (M_HTRANS [idx])
            , .HWRITE  (M_HWRITE [idx])
            , .HSIZE   (M_HSIZE  [idx])
            , .HBURST  (M_HBURST [idx])
            , .HWDATA  (M_HWDATA [idx])
            , .HRDATA  (M_HRDATA      )
            , .HRESP   (M_HRESP       )
            , .HREADY  (M_HREADY      )
        );
        assign done[idx] = BLK_MST[idx].u_tester.done;
   end // for
   endgenerate
   //---------------------------------------------------------------------------
   generate
   genvar idy;
   for (idy=0; idy<NUM_SLV; idy=idy+1) begin : BLK_SLV
        mem_ahb #(.P_SLV_ID(idy)
                 ,.P_SIZE_IN_BYTES(`SIZE_IN_BYTES)
                 ,.P_DELAY(`MEM_DELAY))
        u_mem_ahb (
              .HRESETn   (HRESETn  )
            , .HCLK      (HCLK     )
            , .HADDR     (S_HADDR  )
            , .HTRANS    (S_HTRANS )
            , .HWRITE    (S_HWRITE )
            , .HSIZE     (S_HSIZE  )
            , .HBURST    (S_HBURST )
            , .HWDATA    (S_HWDATA )
            , .HSEL      (S_HSEL      [idy])
            , .HRDATA    (S_HRDATA    [idy])
            , .HRESP     (S_HRESP     [idy])
            , .HREADYin  (S_HREADY         )
            , .HREADYout (S_HREADYout [idy])
        );
        assign  S_HSPLIT[idy] = 0;
   end // for
   endgenerate
   //---------------------------------------------------------------------------
   integer idz;
   initial begin
       wait(HRESETn==1'b0);
       wait(HRESETn==1'b1);
       for (idz=0; idz<NUM_MST; idz=idz+1) begin
            wait(done[idz]==1'b1);
       end
       repeat (5) @ (posedge HCLK);
       $finish(2);
   end
   //---------------------------------------------------------------------------
endmodule