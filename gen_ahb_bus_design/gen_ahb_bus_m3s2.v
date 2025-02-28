//---------------------------------------------------------------------------
module gen_ahb_bus_m3s2
     #(parameter P_numM=3 // num of masters
               , P_numS=2 // num of slaves
               , P_HSEL0_START=32'h00000000, P_HSEL0_SIZE=32'h00010000
               , P_HSEL1_START=32'h10000000, P_HSEL1_SIZE=32'h00010000
               )
(
        input   wire         HRESETn
      , input   wire         HCLK
      , input   wire         M0_HBUSREQ
      , input   wire         M1_HBUSREQ
      , input   wire         M2_HBUSREQ
      , output  wire         M2_HGRANT
      , input   wire  [31:0] M2_HADDR
      , input   wire  [ 1:0] M2_HTRANS
      , input   wire  [ 2:0] M2_HSIZE
      , input   wire  [ 2:0] M2_HBURST
      , input   wire  [ 3:0] M2_HPROT
      , input   wire         M2_HLOCK
      , input   wire         M2_HWRITE
      , input   wire  [31:0] M2_HWDATA
      , output  wire  [31:0] M_HRDATA
      , output  wire  [ 1:0] M_HRESP
      , output  wire         M_HREADY
      , output  wire  [31:0] S_HADDR
      , output  wire         S_HWRITE
      , output  wire  [ 1:0] S_HTRANS
      , output  wire  [ 2:0] S_HSIZE
      , output  wire  [ 2:0] S_HBURST
      , output  wire  [31:0] S_HWDATA
      , output  wire  [ 3:0] S_HPROT
      , output  wire         S_HREADY
      , output  wire  [ 3:0] S_HMASTER
      , output  wire         S_HMASTLOCK
      , output  wire         S0_HSEL
      , input   wire         S0_HREADY
      , input   wire  [ 1:0] S0_HRESP
      , input   wire  [31:0] S0_HRDATA
      , input   wire  [15:0] S0_HSPLIT
      , output  wire         S1_HSEL
      , input   wire         S1_HREADY
      , input   wire  [ 1:0] S1_HRESP
      , input   wire  [31:0] S1_HRDATA
      , input   wire  [15:0] S1_HSPLIT
      , input   wire         REMAP
);
  ahb_arbiter #(.NUMM(3),.NUMS(2))
  u_ahb_arbiter (
         .HRESETn   (HRESETn    )
       , .HCLK      (HCLK       )
       , .HBUSREQ   ({M2_HBUSREQ,M1_HBUSREQ,M0_HBUSREQ})
       , .HGRANT   ({M2_HGRANT,M1_HGRANT,M0_HGRANT})
       , .HMASTER   (S_HMASTER  )
       , .HLOCK     ({M2_HLOCK,M1_HLOCK,M0_HLOCK})
       , .HREADY    (M_HREADY   )
       , .HMASTLOCK (S_HMASTLOCK)
       , .HSPLIT    ({S1_HSPLIT,S0_HSPLIT})
  );
  wire  [31:0] M_HADDR;
  wire  [ 1:0] M_HTRANS;
  wire  [ 2:0] M_HSIZE;
  wire  [ 2:0] M_HBURST;
  wire  [ 3:0] M_HPROT;
  wire         M_HWRITE;
  wire  [31:0] M_HWDATA;
  ahb_m2s_m3 u_ahb_m2s (
       .HRESETn  (HRESETn    )
     , .HCLK     (HCLK       )
     , .HREADY   (M_HREADY   )
     , .HMASTER  (S_HMASTER  )
     , .HADDR    (M_HADDR    )
     , .HPROT    (M_HPROT    )
     , .HTRANS   (M_HTRANS   )
     , .HWRITE   (M_HWRITE   )
     , .HSIZE    (M_HSIZE    )
     , .HBURST   (M_HBURST   )
     , .HWDATA   (M_HWDATA   )
     , .HADDR0   (M0_HADDR  )
     , .HPROT0   (M0_HPROT  )
     , .HTRANS0  (M0_HTRANS )
     , .HWRITE0  (M0_HWRITE )
     , .HSIZE0   (M0_HSIZE  )
     , .HBURST0  (M0_HBURST )
     , .HWDATA0  (M0_HWDATA )
     , .HADDR1   (M1_HADDR  )
     , .HPROT1   (M1_HPROT  )
     , .HTRANS1  (M1_HTRANS )
     , .HWRITE1  (M1_HWRITE )
     , .HSIZE1   (M1_HSIZE  )
     , .HBURST1  (M1_HBURST )
     , .HWDATA1  (M1_HWDATA )
     , .HADDR2   (M2_HADDR  )
     , .HPROT2   (M2_HPROT  )
     , .HTRANS2  (M2_HTRANS )
     , .HWRITE2  (M2_HWRITE )
     , .HSIZE2   (M2_HSIZE  )
     , .HBURST2  (M2_HBURST )
     , .HWDATA2  (M2_HWDATA )
  );
  ahb_lite_s2 #(.P_NUM(2)
               ,.P_HSEL0_START(P_HSEL0_START), .P_HSEL0_SIZE(P_HSEL0_SIZE)
               ,.P_HSEL1_START(P_HSEL1_START), .P_HSEL1_SIZE(P_HSEL1_SIZE)
               )
  u_ahb_lite (
       .HRESETn   (HRESETn  )
     , .HCLK      (HCLK     )
     , .M_HADDR   (M_HADDR  )
     , .M_HTRANS  (M_HTRANS )
     , .M_HWRITE  (M_HWRITE )
     , .M_HSIZE   (M_HSIZE  )
     , .M_HBURST  (M_HBURST )
     , .M_HPROT   (M_HPROT  )
     , .M_HWDATA  (M_HWDATA )
     , .M_HRDATA  (M_HRDATA )
     , .M_HRESP   (M_HRESP  )
     , .M_HREADY  (M_HREADY )
     , .S_HADDR   (S_HADDR  )
     , .S_HTRANS  (S_HTRANS )
     , .S_HSIZE   (S_HSIZE  )
     , .S_HBURST  (S_HBURST )
     , .S_HWRITE  (S_HWRITE )
     , .S_HPROT   (S_HPROT  )
     , .S_HWDATA  (S_HWDATA )
     , .S_HREADY  (S_HREADY )
     , .S0_HSEL   (S0_HSEL  )
     , .S0_HRDATA (S0_HRDATA)
     , .S0_HRESP  (S0_HRESP )
     , .S0_HREADY (S0_HREADY)
     , .S1_HSEL   (S1_HSEL  )
     , .S1_HRDATA (S1_HRDATA)
     , .S1_HRESP  (S1_HRESP )
     , .S1_HREADY (S1_HREADY)
     , .REMAP     (REMAP    )
  );
endmodule
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
module ahb_arbiter     #(parameter NUMM=3 // num of masters
               , NUMS=2)// num of slaves
(
       input   wire               HRESETn
     , input   wire               HCLK
     , input   wire [NUMM-1:0]    HBUSREQ // 0: highest priority
     , output  reg  [NUMM-1:0]    HGRANT={NUMM{1'b0}}
     , output  reg  [     3:0]    HMASTER=4'h0
     , input   wire [NUMM-1:0]    HLOCK
     , input   wire               HREADY
     , output  reg                HMASTLOCK=1'b0
     , input   wire [16*NUMS-1:0] HSPLIT
);
   reg  [NUMM-1:0] hmask={NUMM{1'b0}}; // 1=mask-out
   wire [     3:0] id=encoder(HGRANT);
   localparam ST_READY='h0
            , ST_STAY ='h1;
   reg state=ST_READY;
   always @ (posedge HCLK or negedge HRESETn) begin
   if (HRESETn==1'b0) begin
       HGRANT    <=  'h0;
       HMASTER   <= 4'h0;
       HMASTLOCK <= 1'b0;
       hmask     <=  'h0;
       state     <= ST_READY;
   end else if (HREADY==1'b1) begin
       HMASTER   <= id;
       HMASTLOCK <= HLOCK[id];
       case (state)
       ST_READY: begin
          if (HBUSREQ!=0) begin
              HGRANT  <= priority(HBUSREQ);
              hmask   <= 'h0;
              state   <= ST_STAY;
          end
          end // ST_READY
       ST_STAY: begin
          if (HBUSREQ=='b0) begin
              HGRANT <= 'h0;
              hmask  <= 'h0;
              state  <= ST_READY;
          end else if (HBUSREQ[id]==1'b0) begin
              if ((HBUSREQ&~hmask)=='b0) begin
                  HGRANT <= priority(HBUSREQ);
                  hmask  <= 'h0;
              end else begin
                  HGRANT    <= priority(HBUSREQ&~hmask);
                  hmask[id] <= 1'b1;
              end
          end
          end // ST_STAY
       default: begin
                HGRANT <= 'h0;
                state  <= ST_READY;
                end
       endcase
   end // if
   end // always
   function [NUMM-1:0] priority;
     input  [NUMM-1:0] req;
     reg    [15:0] val;
   begin
     casex ({{16-NUMM{1'b0}},req})
     16'bxxxx_xxxx_xxxx_xxx1: val = 'h0001;
     16'bxxxx_xxxx_xxxx_xx10: val = 'h0002;
     16'bxxxx_xxxx_xxxx_x100: val = 'h0004;
     16'bxxxx_xxxx_xxxx_1000: val = 'h0008;
     16'bxxxx_xxxx_xxx1_0000: val = 'h0010;
     16'bxxxx_xxxx_xx10_0000: val = 'h0020;
     16'bxxxx_xxxx_x100_0000: val = 'h0040;
     16'bxxxx_xxxx_1000_0000: val = 'h0080;
     16'bxxxx_xxx1_0000_0000: val = 'h0100;
     16'bxxxx_xx10_0000_0000: val = 'h0200;
     16'bxxxx_x100_0000_0000: val = 'h0400;
     16'bxxxx_1000_0000_0000: val = 'h0800;
     16'bxxx1_0000_0000_0000: val = 'h1000;
     16'bxx10_0000_0000_0000: val = 'h2000;
     16'bx100_0000_0000_0000: val = 'h4000;
     16'b1000_0000_0000_0000: val = 'h8000;
     default: val = 'h0000;
     endcase
     priority = val[NUMM-1:0];
   end
   endfunction // priority
   function [3:0] encoder;
     input  [NUMM-1:0] req;
   begin
     casex ({{16-NUMM{1'b0}},req})
     16'bxxxx_xxxx_xxxx_xxx1: encoder = 'h0;
     16'bxxxx_xxxx_xxxx_xx10: encoder = 'h1;
     16'bxxxx_xxxx_xxxx_x100: encoder = 'h2;
     16'bxxxx_xxxx_xxxx_1000: encoder = 'h3;
     16'bxxxx_xxxx_xxx1_0000: encoder = 'h4;
     16'bxxxx_xxxx_xx10_0000: encoder = 'h5;
     16'bxxxx_xxxx_x100_0000: encoder = 'h6;
     16'bxxxx_xxxx_1000_0000: encoder = 'h7;
     16'bxxxx_xxx1_0000_0000: encoder = 'h8;
     16'bxxxx_xx10_0000_0000: encoder = 'h9;
     16'bxxxx_x100_0000_0000: encoder = 'ha;
     16'bxxxx_1000_0000_0000: encoder = 'hb;
     16'bxxx1_0000_0000_0000: encoder = 'hc;
     16'bxx10_0000_0000_0000: encoder = 'hd;
     16'bx100_0000_0000_0000: encoder = 'he;
     16'b1000_0000_0000_0000: encoder = 'hf;
     default: encoder = 'h0;
     endcase
   end
   endfunction // encoder
endmodule 
//---------------------------------------------------------------------------
module ahb_m2s_m3
(
       input   wire          HRESETn
     , input   wire          HCLK
     , input   wire          HREADY
     , input   wire  [ 3:0]  HMASTER
     , output  reg   [31:0]  HADDR
     , output  reg   [ 3:0]  HPROT
     , output  reg   [ 1:0]  HTRANS
     , output  reg           HWRITE
     , output  reg   [ 2:0]  HSIZE
     , output  reg   [ 2:0]  HBURST
     , output  reg   [31:0]  HWDATA
     , input   wire  [31:0]  HADDR0
     , input   wire  [ 3:0]  HPROT0
     , input   wire  [ 1:0]  HTRANS0
     , input   wire          HWRITE0
     , input   wire  [ 2:0]  HSIZE0
     , input   wire  [ 2:0]  HBURST0
     , input   wire  [31:0]  HWDATA0
     , input   wire  [31:0]  HADDR1
     , input   wire  [ 3:0]  HPROT1
     , input   wire  [ 1:0]  HTRANS1
     , input   wire          HWRITE1
     , input   wire  [ 2:0]  HSIZE1
     , input   wire  [ 2:0]  HBURST1
     , input   wire  [31:0]  HWDATA1
     , input   wire  [31:0]  HADDR2
     , input   wire  [ 3:0]  HPROT2
     , input   wire  [ 1:0]  HTRANS2
     , input   wire          HWRITE2
     , input   wire  [ 2:0]  HSIZE2
     , input   wire  [ 2:0]  HBURST2
     , input   wire  [31:0]  HWDATA2
);
       reg [3:0] hmaster_delay=4'h0;
       always @ (posedge HCLK or negedge HRESETn) begin
           if (HRESETn==1'b0) begin
                hmaster_delay <= 4'b0;
           end else begin
                if (HREADY) begin
                   hmaster_delay <= HMASTER;
                end
           end
       end
       always @ (HMASTER or HADDR0 or HADDR1 or HADDR2) begin
           case (HMASTER)
           4'h0: HADDR = HADDR0;
           4'h1: HADDR = HADDR1;
           4'h2: HADDR = HADDR2;
           default: HADDR = ~32'b0;
           endcase
        end
       always @ (HMASTER or HPROT0 or HPROT1 or HPROT2) begin
           case (HMASTER)
           4'h0: HPROT = HPROT0;
           4'h1: HPROT = HPROT1;
           4'h2: HPROT = HPROT2;
           default: HPROT = 4'b0;
           endcase
        end
       always @ (HMASTER or HTRANS0 or HTRANS1 or HTRANS2) begin
           case (HMASTER)
           4'h0: HTRANS = HTRANS0;
           4'h1: HTRANS = HTRANS1;
           4'h2: HTRANS = HTRANS2;
           default: HTRANS = 2'b0;
           endcase
        end
       always @ (HMASTER or HWRITE0 or HWRITE1 or HWRITE2) begin
           case (HMASTER)
           4'h0: HWRITE = HWRITE0;
           4'h1: HWRITE = HWRITE1;
           4'h2: HWRITE = HWRITE2;
           default: HWRITE = 1'b0;
           endcase
        end
       always @ (HMASTER or HSIZE0 or HSIZE1 or HSIZE2) begin
           case (HMASTER)
           4'h0: HSIZE = HSIZE0;
           4'h1: HSIZE = HSIZE1;
           4'h2: HSIZE = HSIZE2;
           default: HSIZE = 3'b0;
           endcase
        end
       always @ (HMASTER or HBURST0 or HBURST1 or HBURST2) begin
           case (HMASTER)
           4'h0: HBURST = HBURST0;
           4'h1: HBURST = HBURST1;
           4'h2: HBURST = HBURST2;
           default: HBURST = 3'b0;
           endcase
        end
       always @ (hmaster_delay or HWDATA0 or HWDATA1 or HWDATA2) begin
           case (hmaster_delay)
           4'h0: HWDATA = HWDATA0;
           4'h1: HWDATA = HWDATA1;
           4'h2: HWDATA = HWDATA2;
           default: HWDATA = 3'b0;
           endcase
        end
endmodule
//---------------------------------------------------------------------------
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
