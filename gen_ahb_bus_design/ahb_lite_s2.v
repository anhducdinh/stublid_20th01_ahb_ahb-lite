//---------------------------------------------------------------------------
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
   `ifdef RIGOR
   // synthesis translate_off
   initial begin
       if (P_HSEL0_SIZE==0) $display("%%m ERROR P_HSEL0_SIZE should be positive 32-bit");
       if (P_HSEL1_SIZE==0) $display("%%m ERROR P_HSEL1_SIZE should be positive 32-bit");
       if ((P_HSEL0_END>P_HSEL1_START)&&
           (P_HSEL0_END<=P_HSEL1_END)) $display("%%m ERROR address range overlapped 0:1");
       if ((P_HSEL1_END>P_HSEL0_START)&&
           (P_HSEL1_END<=P_HSEL0_END)) $display("%%m ERROR address range overlapped 1:0");
   end
   // synthesis translate_on
   `endif
endmodule
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
module ahb_default_slave
(
       input   wire         HRESETn
     , input   wire         HCLK
     , input   wire         HSEL
     , input   wire  [31:0] HADDR
     , input   wire  [ 1:0] HTRANS
     , input   wire         HWRITE
     , input   wire  [ 2:0] HSIZE
     , input   wire  [ 2:0] HBURST
     , input   wire  [31:0] HWDATA
     , output  wire  [31:0] HRDATA
     , output  reg   [ 1:0] HRESP=2'b01
     , input   wire         HREADYin
     , output  reg          HREADYout=1'b1
);
   assign HRDATA = 32'h0;
   localparam STH_IDLE   = 2'h0
            , STH_WRITE  = 2'h1
            , STH_READ0  = 2'h2;
   reg [1:0] state=STH_IDLE;
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRESP     <= 2'b00; //`HRESP_OKAY;
           HREADYout <= 1'b1;
           state     <= STH_IDLE;
       end else begin // if (HRESETn==0) begin
           case (state)
           STH_IDLE: begin
                if (HSEL && HREADYin) begin
                   case (HTRANS)
                   //`HTRANS_IDLE, `HTRANS_BUSY: begin
                   2'b00, 2'b01: begin
                          HREADYout <= 1'b1;
                          HRESP     <= 2'b00; //`HRESP_OKAY;
                          state     <= STH_IDLE;
                    end // HTRANS_IDLE or HTRANS_BUSY
                   //`HTRANS_NONSEQ, `HTRANS_SEQ: begin
                   2'b10, 2'b11: begin
                          HREADYout <= 1'b0;
                          HRESP     <= 2'b01; //`HRESP_ERROR;
                          if (HWRITE) begin
                              state <= STH_WRITE;
                          end else begin
                              state <= STH_READ0;
                          end
                    end // HTRANS_NONSEQ or HTRANS_SEQ
                   endcase // HTRANS
                end else begin// if (HSEL && HREADYin)
                    HREADYout <= 1'b1;
                    HRESP     <= 2'b00; //`HRESP_OKAY;
                end
                end // STH_IDLE
           STH_WRITE: begin
                     HREADYout <= 1'b1;
                     HRESP     <= 2'b01; //`HRESP_ERROR;
                     state     <= STH_IDLE;
                end // STH_WRITE
           STH_READ0: begin
                    HREADYout <= 1'b1;
                    HRESP     <= 2'b01; //`HRESP_ERROR;
                    state     <= STH_IDLE;
                end // STH_READ0
           endcase // state
       end // if (HRESETn==0)
   end // always
endmodule
//---------------------------------------------------------------------------
