// 'ahb_write' and 'ahb_read' task for signal trasnfer operation to  generates AMBA AHB transaction.
// Created by: ducanh
// Review and test by: ducanh
// Version: Ver 1.3 - Final version

reg [31:0] data_burst_read [0:1023]; // Read burst data
reg [31:0] data_burst_write[0:1023]; // Write burst data

//------------------------------------------------------------------------------
// 'ahb_write' generates AMBA AHB wirte transaction.
// Created by: ducanh
// Review and test by: ducanh
// Version: Ver 1.3 (15/aug/2024 - 2pm)- Final version
//------------------------------------------------------------------------------
task ahb_write;
     input  [31:0] addr; // address get from signal_transfer in mem_test_task.v
     input  [31:0] data; // data get from write_data in single trasnfer
     input  [ 2:0] size; // size of data in bytes
     output [ 1:0] status; // 0 for OK and 1 is ERROR
begin
       ahb_write_core( addr
                     , data
                     , size
                     , 4'b0001 // non-cacheable,non-bufferable,user,data  --> Define HPROT singal
                     , 1'b0 // Initial HLOCK signal
                     , status);
end
endtask

//------------------------------------------------------------------------------
task ahb_write_core;
     input  [31:0] addr; 
     input  [31:0] data; // justified data
     input  [ 2:0] size; // num of bytes
     input  [ 3:0] hprot;
     input         lock;
     output [ 1:0] status; // 0 for OK, 1 for error, 2 for retry, 3 for split
begin
    status = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1;
    HLOCK   <= (lock) ? 1'b1 : HLOCK;
    @ (posedge HCLK);
	// Wating Bus permiss Master to access to Bus and HREADY(ready to tranfer) = 1
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HBUSREQ <= 1'b0;
    HLOCK   <= (lock) ? 1'b1 : HLOCK;
    HADDR   <= addr;
    HPROT   <= hprot;   //HPROT_DATA
    HTRANS  <= 2'b10;   //HTRANS_NONSEQ; 
    HBURST  <= 3'b000;  //HBURST_SINGLE; // Define single transfer operation
    HWRITE  <= 1'b1;    //HWRITE_WRITE;
    case (size)
    1:  HSIZE <= 3'b000; //HSIZE <= 3'b000; BYTE;
    2:  HSIZE <= 3'b001; //HSIZE <= 3'b001; HALF-WORD;
    4:  HSIZE <= 3'b010; //HSIZE <= 3'b010; WORD;
    default: begin
             status = 1;
             $display("%04d %m ERROR: This system unsupported transfer size: %d-byte", $time, size);
             end
    endcase
    @ (posedge HCLK);
    while (HREADY!==1) @ (posedge HCLK);
    HWDATA <= data<<(8*addr[1:0]); // for little-endian
    HTRANS <= 2'b0; // Return IDEL state
    @ (posedge HCLK);
    while (HREADY===0) @ (posedge HCLK);
    case (HRESP)
    2'b00: status = 0; // OK
    2'b01: status = 1; // ERROR
    2'b10: status = 2; // RETRY
    2'b11: status = 3; // SPLIT
    endcase
    if (HRESP!=2'b00) begin //if (HRESP!=`HRESP_OKAY)
         status = 1;
         $display("%04d %m ERROR: non OK response write", $time);
    end
end
endtask

//------------------------------------------------------------------------------
// 'ahb_read' generates AMBA AHB read transaction.
// Created by: ducanh
// Review and test by: ducanh
// Version: Ver 1.3 (15/aug/2024 - 2pm)- Final version
//------------------------------------------------------------------------------
task ahb_read;
     input  [31:0] addr;
     output [31:0] data; 
     input  [ 2:0] size; 
     output [ 1:0] status; // 0 for OK
begin
       ahb_read_core( addr
                    , data
                    , size
                    , 4'b0001 // non-cacheable,non-bufferable,user,data
                    , 1'b0 // lock
                    , status);
end
endtask

//------------------------------------------------------------------------------
task ahb_read_core;
     input  [31:0] addr; 
     output [31:0] data;
     input  [ 2:0] size; 
     input  [ 3:0] hprot;
     input         lock ;
     output [ 1:0] status;
begin
    status = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1'b1;
    HLOCK   <= (lock) ? 1'b1 : HLOCK;
    @ (posedge HCLK);
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HBUSREQ <= 1'b0;
    HLOCK   <= (lock) ? 1'b1 : 1'b0;
    HADDR   <= addr;
    HPROT   <= hprot; //`HPROT_DATA
    HTRANS  <= 2'b10;  //`HTRANS_NONSEQ;
    HBURST  <= 3'b000; //`HBURST_SINGLE;
    HWRITE  <= 1'b0;   //`HWRITE_READ;
    case (size)
    1:  HSIZE <= 3'b000; //`HSIZE_BYTE;
    2:  HSIZE <= 3'b001; //`HSIZE_HWORD;
    4:  HSIZE <= 3'b010; //`HSIZE_WORD;
    default: begin
             status = 1;
             $display("%04d %m ERROR: unsupported transfer size: %d-byte", $time, size);
             end
    endcase
    @ (posedge HCLK);
    while (HREADY!==1'b1) @ (posedge HCLK);
    HTRANS <= 2'b0;
    @ (posedge HCLK);
    while (HREADY===0) @ (posedge HCLK);
    data = HRDATA>>(8*addr[1:0]); // must be blocking
    case (HRESP)
    2'b00: status = 0; // OK
    2'b01: status = 1; // ERROR
    2'b10: status = 2; // RETRY
    2'b11: status = 3; // SPLIT
    endcase
    if (HRESP!=2'b00) begin //if (HRESP!=`HRESP_OKAY)
        status = 1;
        $display("%04d %m ERROR: non OK response for read", $time);
    end
end
endtask

//------------------------------------------------------------------------------
// 'ahb_read_burst' generates AMBA AHB read transaction for burst transfer.
// Created by: ducanh
// Review and test by: ducanh
// Version: Ver 1.3 (15/aug/2024 - 2pm)- Final version
//------------------------------------------------------------------------------
task ahb_read_burst;
     input  [31:0] addr; 
     input  [ 2:0] hburst; 
//	 input  [ 2:0] size;
     output [ 1:0] status; 
begin
     ahb_read_burst_core( addr
//                        , size
                        , 4
                        , hburst
                        , 4'b0001 // hprot
                        , status);
end
endtask

//------------------------------------------------------------------------------
task ahb_read_burst_core;
     input  [31:0] addr;
     input  [ 2:0] size; // num of byte
     input  [ 2:0] hburst; // HBURST
     input  [ 3:0] hprot;// HPROT
     output [ 1:0] status; // 0 for OK
     reg    [31:0] data;
begin
     case (hburst)
     3'b000: begin ahb_read_core(addr,data,size,hprot,1'b0, status); data_burst_read[0] = data; end // SINGLE
     3'b001: ahb_read_burst_inc (addr,size, 1,hprot,status); // INCR
     3'b011: ahb_read_burst_inc (addr,size, 4,hprot,status); // INCR4
     3'b101: ahb_read_burst_inc (addr,size, 8,hprot,status); // INCR8
     3'b111: ahb_read_burst_inc (addr,size,16,hprot,status); // INCR16
     endcase
end
endtask

task ahb_read_burst_inc;
     input  [31:0] addr;
     input  [ 2:0] size; // num of byte
     input  [31:0] burst_length; // num of beat
     input  [ 3:0] hprot;// HPROT
     output [ 1:0] status; // 0 for OK
     reg    [31:0] lock_addr ; // keep current address
     reg    [31:0] beat; // keep beat num.
     integer       i, ln, k;
begin
    status = 0;
    k = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1'b1;
    @ (posedge HCLK);
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HPROT  <= hprot;
    HADDR  <= addr ;
    HTRANS <= 2'b10; //`HTRANS_NONSEQ;
    if (burst_length==16)     begin HBURST <= 3'b111; ln=16; end //`HBURST_INCR16;
    else if (burst_length==8) begin HBURST <= 3'b101; ln= 8; end //`HBURST_INCR8;
    else if (burst_length==4) begin HBURST <= 3'b011; ln= 4; end //`HBURST_INCR4;
    else              begin HBURST <= 3'b001; ln=burst_length; end //`HBURST_INCR;
    HWRITE <= 1'b0; //`HWRITE_READ;
    case (size)
    1:  HSIZE <= 3'b000; //`HSIZE_BYTE;
    2:  HSIZE <= 3'b001; //`HSIZE_HWORD;
    4:  HSIZE <= 3'b010; //`HSIZE_WORD;
    default: begin
             status = 1;
             $display("%04d %m ERROR: unsupported transfer size: %d-byte", $time, size);
             end
    endcase
    lock_addr  = addr;
    beat = 0;
    @ (posedge HCLK);
    while (HREADY==1'b0) @ (posedge HCLK);
    while (burst_length>0) begin
       for (i=0; i<ln-1; i=i+1) begin
           if (i>=(ln-3)) HBUSREQ <= 1'b0;
           HADDR  <= HADDR + size;
           HTRANS <= 2'b11; //`HTRANS_SEQ;
           @ (posedge HCLK);
           while (HREADY==1'b0) @ (posedge HCLK);
           data_burst_read[beat] <= HRDATA>>(8*lock_addr[1:0]); // little-endian
           k = k+1;
           lock_addr = lock_addr + size;
           beat = beat + 1;
       end
       burst_length = burst_length - ln;
       if (burst_length==0) begin
          HTRANS  <= 0;
          HBUSREQ <= 1'b0;
       end 
//       else begin
//          HADDR  <= HADDR + size;
//          HTRANS <= 2'b10; //`HTRANS_NONSEQ;
//          if (burst_length>=16)     begin HBURST <= 3'b111; ln=16; end //`HBURST_INCR16;
//          else if (burst_length>=8) begin HBURST <= 3'b101; ln= 8; end //`HBURST_INCR8;
//          else if (burst_length>=4) begin HBURST <= 3'b011; ln= 4; end //`HBURST_INCR4;
//          else              begin HBURST <= 3'b001; ln=burst_length; end //`HBURST_INCR;
//          @ (posedge HCLK);
//          while (HREADY==0) @ (posedge HCLK);
//          data_burst_read[beat] = HRDATA>>(8*lock_addr[1:0]);
//          if (HRESP!=2'b00) begin //if (HRESP!=`HRESP_OKAY)
//              status = 1;
//              $display("%04d %m ERROR: non OK response for read", $time);
//          end
//          k = k+1;
//          lock_addr = lock_addr + size;
//          beat = beat + 1;
//       end
    end
    @ (posedge HCLK);
    while (HREADY==0) @ (posedge HCLK);
    data_burst_read[beat] = HRDATA>>(8*lock_addr[1:0]); // must be blocking
end
endtask

//------------------------------------------------------------------------------
task ahb_write_burst;
     input  [31:0] addr;
     input  [ 2:0] hburst;
//	 input  [ 2:0] size;
     output [ 1:0] status; // 0 for OK
begin
     ahb_write_burst_core( addr
//                         , size
                         , 4
                         , hburst
                         , 4'b0001
                         , status);
end
endtask

//------------------------------------------------------------------------------
task ahb_write_burst_core;
     input  [31:0] addr;
     input  [ 2:0] size;
     input  [ 2:0] hburst; // HBURST
     input  [ 3:0] hprot;// HPROT
     output [ 1:0] status; // 0 for OK
begin
     case (hburst)
     3'b000: ahb_write_core(addr,data_burst_write[0],size,hprot,1'b0,status); // SINGLE
     3'b001: ahb_write_burst_inc (addr,size, 1,hprot,status); // INCR
     3'b011: ahb_write_burst_inc (addr,size, 4,hprot,status); // INCR4
     3'b101: ahb_write_burst_inc (addr,size, 8,hprot,status); // INCR8
     3'b111: ahb_write_burst_inc (addr,size,16,hprot,status); // INCR16
     endcase
end
endtask

//------------------------------------------------------------------------------
// Bursts must not cross a 1kB address boundary.
task ahb_write_burst_inc;
     input  [31:0] addr;
     input  [ 2:0] size;
     input  [31:0] burst_length;
     input  [ 3:0] hprot;// HPROT
     output [ 1:0] status; // 0 for OK
     reg    [31:0] lock_addr ; // keep current address
     reg    [31:0] beat; // keep beat num.
     integer       i, j, ln;
begin
    status = 0;
    j = 0;
    ln = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1'b1;
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
       HPROT  <= hprot;
       HADDR  <= addr; addr = addr + 4;
       HTRANS <= 2'b10; //`HTRANS_NONSEQ;
       if (burst_length>=16)     begin HBURST <= 3'b111; ln=16; end//`HBURST_INCR16;
       else if (burst_length>=8) begin HBURST <= 3'b101; ln= 8; end//`HBURST_INCR8;
       else if (burst_length>=4) begin HBURST <= 3'b011; ln= 4; end//`HBURST_INCR4;
       else              begin HBURST <= 3'b001; ln=burst_length; end//`HBURST_INCR;
       HWRITE <= 1'b1; //`HWRITE_WRITE;
       case (size)
       1:  HSIZE <= 3'b000; //`HSIZE_BYTE;
       2:  HSIZE <= 3'b001; //`HSIZE_HWORD;
       4:  HSIZE <= 3'b010; //`HSIZE_WORD;
       default: begin
                status = 1;
                $display("%04d %m ERROR: unsupported transfer size: %d-byte", $time, size);
                end
       endcase
    @ (posedge HCLK);
    while (burst_length>0) begin
//       while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
//       HPROT  <= hprot;
//       HADDR  <= addr; addr = addr + 4;
//       HTRANS <= 2'b10; //`HTRANS_NONSEQ;
//       if (burst_length>=16)     begin HBURST <= 3'b111; ln=16; end//`HBURST_INCR16;
//       else if (burst_length>=8) begin HBURST <= 3'b101; ln= 8; end//`HBURST_INCR8;
//       else if (burst_length>=4) begin HBURST <= 3'b011; ln= 4; end//`HBURST_INCR4;
//       else              begin HBURST <= 3'b001; ln=burst_length; end//`HBURST_INCR;
//       HWRITE <= 1'b1; //`HWRITE_WRITE;
//       case (size)
//       1:  HSIZE <= 3'b000; //`HSIZE_BYTE;
//       2:  HSIZE <= 3'b001; //`HSIZE_HWORD;
//       4:  HSIZE <= 3'b010; //`HSIZE_WORD;
//       default: begin
//                status = 1;
//                $display("%04d %m ERROR: unsupported transfer size: %d-byte", $time, size);
//                end
//       endcase
       lock_addr  = addr;
       beat = 0;
       for (i=0; i<ln-1; i=i+1) begin
           @ (posedge HCLK);
           while (HREADY==1'b0) @ (posedge HCLK);
           if (i>=(ln-3)) HBUSREQ <= 1'b0;
           HWDATA <= data_burst_write[beat]<<(8*lock_addr[1:0]); // little-endian
           HADDR  <= HADDR + size;
           HTRANS <= 2'b11; //`HTRANS_SEQ;
           lock_addr = lock_addr + size;
           beat = beat + 1;
           while (HREADY==1'b0) @ (posedge HCLK);
           if (HRESP!=2'b00) begin //`HRESP_OKAY
               status = 1;
               $display("%04d %m ERROR: non OK response write", $time);
           end
       end
       @ (posedge HCLK);
       while (HREADY==0) @ (posedge HCLK);
       HWDATA <= data_burst_write[beat]<<(8*lock_addr[1:0]);
       if (HRESP!=2'b00) begin //`HRESP_OKAY
           status = 1;
           $display("%04d %m ERROR: non OK response write", $time);
       end
       if (ln==burst_length) begin
           HTRANS  <= 0;
           HBUSREQ <= 1'b0;
       end
       burst_length = burst_length - ln;
       //j = j+ln;
      
    end
    @ (posedge HCLK);
    while (HREADY==0) @ (posedge HCLK);
    if (HRESP!=2'b00) begin //`HRESP_OKAY
        status = 1;
        $display("%04d %m ERROR: non OK response write", $time);
    end
end
endtask

