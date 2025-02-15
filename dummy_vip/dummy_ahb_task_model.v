//------------------------------------------------------------------------------------------------
// Create and Design: ducanh         Email: ducanhld15@gmail.com
//-----------------------------------------------------------------------------------------------
// Module: dummy ahb vip model 
// Ver 1.0:        mod1.0  :  15/08/2024  : create and coding task write/read with hburst = single 
// Ver 2.0:        mod2.0  :  17/08/2024  : adds some tasks read/write with htrans = seq, hburst..
//
// Tille: if code debug or need more some feature or reduce as well as perious version, 
// you can note (Anhmode_ + "day/month/year"). Example : Anhmode_16082024
// 
//================================================================================================
//--------------------------------------------mode1.0---------------------------------------------
//================================================================================================
task ahb_write(
    input [31:0] address,
    input [31:0] data,
    input [3:0] hprot,
    input [2:0] hsize,
    input       hlock,   //Anhmode_16082024
    input [1:0] resp    // 0 :ok , 1: error, 2: retry, 3: split
);
begin
    resp = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1;
    //HLOCK = 1'b1;                    //Anhmode_16082024
    HLOCK   <= (hlock) ? 1'b1 : HLOCK; //Anhmode_16082024
    @ (posedge HCLK);
	// Wating Bus permiss Master to access to Bus and HREADY(ready to tranfer) = 1
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HBUSREQ <= 1'b0;
    HLOCK   <= (hlock) ? 1'b1 : HLOCK;   //Anhmode_16082024
    HADDR   <= addr;
    HPROT   <= hprot;   //HPROT_DATA
    HTRANS  <= 2'b10;   //HTRANS_NONSEQ; 
    HBURST  <= 3'b000;  //HBURST_SINGLE; // Define single transfer operation
    HWRITE  <= 1'b1;    //HWRITE_WRITE;
    case (hsize)
    1:  HSIZE <= 3'b000; //HSIZE <= 3'b000; BYTE;
    2:  HSIZE <= 3'b001; //HSIZE <= 3'b001; HALF-WORD;
    4:  HSIZE <= 3'b010; //HSIZE <= 3'b010; WORD;
    default: begin
             resp = 1;
             $display("%04d %m [ERROR]: SYSTEM UNSUPPORTED TRANSFER SIZE: %d-byte", $time, hsize);
             end
    endcase
    @ (posedge HCLK);
    while (HREADY!==1) @ (posedge HCLK);  //hready == 0 if hready === 1??
    HWDATA <= data<<(8*addr[1:0]); // for little-endian
    HTRANS <= 2'b0; // Return IDEL state
    @ (posedge HCLK);
    while (HREADY===0) @ (posedge HCLK);
    case (HRESP)
    2'b00: resp = 0; // OK
    2'b01: resp = 1; // ERROR
    2'b10: resp = 2; // RETRY
    2'b11: resp = 3; // SPLIT
    endcase
    if (HRESP!=2'b00) begin //if (HRESP!=`HRESP_OKAY)
         resp = 1;
         $display("%04d %m ERROR: the system hadn't OK response write", $time);
    end
end
endtask


task ahb_read(
    input [31:0] address,
    input [31:0] data,
    input [3:0] hprot,
    input [2:0] hsize,
    input       hlock,
    input [1:0] resp    // 0 :ok , 1: error, 2: retry, 3: split
);
begin
    resp = 0;
    @ (posedge HCLK);
    HBUSREQ <= 1;
    //HLOCK = 1'b1;                    //Anhmode_16082024
    HLOCK   <= (hlock) ? 1'b1 : HLOCK; //Anhmode_16082024
    @ (posedge HCLK);
	// Wating Bus permiss Master to access to Bus and HREADY(ready to tranfer) = 1
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HBUSREQ <= 1'b0;
    HLOCK   <= (hlock) ? 1'b1 : HLOCK;
    HADDR   <= addr;
    HPROT   <= hprot;   //HPROT_DATA
    HTRANS  <= 2'b10;   //HTRANS_NONSEQ; 
    HBURST  <= 3'b000;  //HBURST_SINGLE; // Define single transfer operation
    HWRITE  <= 1'b0;    //AHB READ;
    case (hsize)
    1:  HSIZE <= 3'b000; //HSIZE <= 3'b000; BYTE;
    2:  HSIZE <= 3'b001; //HSIZE <= 3'b001; HALF-WORD;
    4:  HSIZE <= 3'b010; //HSIZE <= 3'b010; WORD;
    default: begin
             resp = 1;
             $display("%04d %m [ERROR]: SYSTEM UNSUPPORTED TRANSFER SIZE: %d-byte", $time, hsize);
             end
    endcase
    @ (posedge HCLK);
    while (HREADY!==1'b1) @ (posedge HCLK);
    HTRANS <= 2'b0;
    @ (posedge HCLK);
    while (HREADY===0) @ (posedge HCLK);
    data = HRDATA>>(8*addr[1:0]); // must be blocking
    case (HRESP)
    2'b00: resp = 0; // OK
    2'b01: resp = 1; // ERROR
    2'b10: resp = 2; // RETRY
    2'b11: resp = 3; // SPLIT
    endcase
    if (resp!=2'b00) begin //if (resp!=`resp_OKAY)
        resp = 1;
        $display("%04d %m ERROR: non OK response for read", $time);
    end
end
endtask

/*
//================================================================================================
//--------------------------------------------mode2.0---------------------------------------------
//================================================================================================
task ahb_write_burst();
//--
endtask
task ahb_read_burst();
//--
endtask
*