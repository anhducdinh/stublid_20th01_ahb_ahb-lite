`timescale 1ns/1ns

module mem_ahb
     #(parameter P_SLV_ID=0
               , P_SIZE_IN_BYTES=1024
               , P_DELAY=0
               , P_INIT=0)
(
       input   wire          HRESETn
     , input   wire          HCLK
     , input   wire          HSEL
     , input   wire  [31:0]  HADDR
     , input   wire  [ 1:0]  HTRANS
     , input   wire          HWRITE
     , input   wire  [ 2:0]  HSIZE
     , input   wire  [ 2:0]  HBURST
     , input   wire  [31:0]  HWDATA
     , output  reg   [31:0]  HRDATA
     , output  wire  [ 1:0]  HRESP
     , input   wire          HREADYin
     , output  reg           HREADYout
); 
   //---------------------------------------------------------------------------
   assign HRESP = 2'b00;
   //---------------------------------------------------------------------------
   localparam ADD_WIDTH = 10;
   localparam NUM_WORDS = P_SIZE_IN_BYTES/4;
   //---------------------------------------------------------------------------
   reg  [31:0]          mem[0:NUM_WORDS-1];
   reg  [ADD_WIDTH-1:0] T_ADDR, T_ADDRw;
   reg  [31:0]          T_DATA;
   reg  [ 3:0]          T_BE, T_BE_D;
   reg                  T_WR, T_WR_D;
   wire                 T_ENABLED = HSEL && HREADYin && HTRANS[1];
   //---------------------------------------------------------------------------
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRDATA    <= ~32'h0;
           T_ADDR    <= ~'h0;
           T_ADDRw   <= ~'h0;
           T_DATA    <= ~32'h0;
           T_BE      <= 4'h0;
           T_WR      <= 1'b0;
           T_BE_D    <= 4'h0;
           T_WR_D    <= 1'b0;
       end else begin
           if (T_ENABLED) begin
               T_ADDR <= HADDR[ADD_WIDTH-1:0];
               T_BE   <= byte_enable(HADDR[1:0], HSIZE);
               T_WR   <= HWRITE;
               HRDATA <= mem[HADDR[ADD_WIDTH-1:2]];
           end else begin
               T_BE   <= 4'h0;
               T_WR   <= 1'b0;
              
           end
           if (T_WR) begin
               T_DATA[ 7: 0] <= (T_BE[0]) ? HWDATA[ 7: 0]
                                          : HRDATA[ 7: 0];
               T_DATA[15: 8] <= (T_BE[1]) ? HWDATA[15: 8]
                                          : HRDATA[15:8];
               T_DATA[23:16] <= (T_BE[2]) ? HWDATA[23:16]
                                          : HRDATA[23:16];
               T_DATA[31:24] <= (T_BE[3]) ? HWDATA[31:24]
                                          : HRDATA[31:24];
               T_BE_D <= T_BE;
               T_WR_D <= T_WR;
           end else begin
               T_BE_D <= 4'h0;
               T_WR_D <= 1'h0;
           end
           if (T_WR_D) begin
               mem[T_ADDRw[ADD_WIDTH-1:2]] <= T_DATA;
           end
           T_ADDRw <= T_ADDR;
       end
   end
   //---------------------------------------------------------------------------
   reg [5:0] count=6'h0;
   localparam IDLE = 0,
              WAIT = 1;
   reg       state=IDLE;
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HREADYout <= 1'b1;
           count     <= 6'h0;
           state     <= IDLE;
       end else begin
           case (state)
               IDLE: begin
                     if (T_ENABLED&&(P_DELAY!=0)) begin
                         HREADYout <= 1'b0;
                         count     <= 'h1;
                         state     <= WAIT;
                     end
               end // IDLE
               WAIT: begin
                     if ((P_DELAY==count)||(count=='h0)) begin
                         HREADYout <= 1'b1;
                         count     <= 'h0;
                         state     <= IDLE;
                     end else begin
                         count <= count + 1;
                         $display("count = %x", count);
                     end
               end // WAIT
               default: begin
                        HREADYout <= 1'b1;
                        count     <= 'h0;
                        state     <= IDLE;
                        end
           endcase
        end
   end
   //---------------------------------------------------------------------------
   function [3:0] byte_enable;
       input [1:0] add;   // address offset
       input [2:0] size;  // transfer size
       reg   [3:0] be;
       begin
          case ({size,add})
              5'b010_00: be = 4'b1111; // word
              5'b001_00: be = 4'b0011; // halfword
              5'b001_10: be = 4'b1100; // halfword
              5'b000_00: be = 4'b0001; // byte
              5'b000_01: be = 4'b0010; // byte
              5'b000_10: be = 4'b0100; // byte
              5'b000_11: be = 4'b1000; // byte
              default: be = 4'b0;
          endcase
          byte_enable = be;
       end
   endfunction
    //--------------------------------------------------------------------------
//    function integer logb2;
//    input [31:0] value;
//    reg   [31:0] tmp, rt;
//    begin
//          tmp = value - 1;
//          for (rt=0; tmp>0; rt=rt+1) tmp=tmp>>1;
//          logb2 = rt;
//    end
//    endfunction
   //---------------------------------------------------------------------------
   task read;
        input  [31:0] addr;
        output [31:0] data;
   begin
        data = mem[addr[ADD_WIDTH-1:2]];
   end
   endtask
   //---------------------------------------------------------------------------
   task write;
        input  [31:0] addr;
        input  [31:0] data;
        input  [ 3:0] be;
        reg    [31:0] tmp;
   begin
        tmp = mem[addr[ADD_WIDTH-1:2]];
        tmp[ 7: 0] = (be[0]) ? data[ 7: 0] : tmp[ 7: 0];
        tmp[15: 8] = (be[1]) ? data[15: 8] : tmp[15: 8];
        tmp[23:16] = (be[2]) ? data[23:16] : tmp[23:16];
        tmp[31:24] = (be[3]) ? data[31:24] : tmp[31:24];
        mem[addr[ADD_WIDTH-1:2]] = tmp;
   end
   endtask
endmodule

