//------------------------------------------------------------------------------------------------
// Create and Design: ducanh         Email: ducanhld15@gmail.com
//-----------------------------------------------------------------------------------------------
// Module:  default slave 
// Ver 1.0:        mod1.0  :  10/08/2024  : create and design with file "dummy_fsm_default_slave.v"
// Ver 2.0:        mod2.0  :  17/08/2024   
//
// Tille: if code debug or need more some feature or reduce as well as perious version, 
// you can note (Anhmode_ + "day/month/year"). Example : Anhmode_16082024
// 
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
   localparam STATE_IDLE   = 2'h0
            , STATE_WRITE  = 2'h1
            , STATE_READ0  = 2'h2;
   reg [1:0] state=STATE_IDLE;
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRESP     <= 2'b00; 
           HREADYout <= 1'b1;
           state     <= STATE_IDLE;
       end else begin 
           case (state)
           STATE_IDLE: begin
                if (HSEL && HREADYin) begin
                   case (HTRANS)
                   //`HTRANS_IDLE, `HTRANS_BUSY: begin
                   2'b00, 2'b01: begin
                          HREADYout <= 1'b1;
                          HRESP     <= 2'b00; 
                          state     <= STATE_IDLE;
                    end 
                   //`HTRANS_NONSEQ, `HTRANS_SEQ: begin
                   2'b10, 2'b11: begin
                          HREADYout <= 1'b0;
                          HRESP     <= 2'b01;
                          if (HWRITE) begin
                              state <= STATE_WRITE;
                          end else begin
                              state <= STATE_READ0;
                          end
                    end 
                   endcase 
                end else begin
                    HREADYout <= 1'b1;
                    HRESP     <= 2'b00; 
                end
                end 
           STATE_WRITE: begin
                     HREADYout <= 1'b1;
                     HRESP     <= 2'b01; 
                     state     <= STATE_IDLE;
                end 
           STATE_READ0: begin
                    HREADYout <= 1'b1;
                    HRESP     <= 2'b01; 
                    state     <= STATE_IDLE;
                end 
           endcase 
       end 
   end 
endmodule
//---------------------------------------------------------------------------
