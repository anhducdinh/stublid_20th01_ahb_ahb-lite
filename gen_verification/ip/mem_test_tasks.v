//// AMBA AHB TASK TO GENERATE TRANSACTIONS ///
/// ******************** 	SCENARIO LIST   **************///
// single_trasfer_test(addr_start_addr[idy], addr_end[idy], 4);
// burst_transfer_test(addr_start_addr[idy], addr_end[idy], 4);

/// Creater : Phuc Nguyen -- Last Updated: 4/Jun/2023
//  Modified and review: Thanh Vo


task single_trasfer_test; 
	input [31:0] start_addr_addr;  // start_addr address
	input [31:0] end_addr; // end address
	input [ 2:0] size_data;   // data size: 1, 2, 4
//------------------
	reg [1:0] status;
	integer i, error, seed;
	reg [31:0] mask_data, write_data, read_data, expect, data_expected;
begin
// 		Single transfer operation older verion 

//		error = 0;
//		seed = 7;
//		mask_data = get_mask(size_data);
//		for (i=start_addr_addr; i<(end_addr-size_data+1); i=i+size_data) begin
//			dataW = {$random(seed)}&mask_data; 
//			ahb_write(i, dataW, size_data, status); 
//			ahb_read(i, dataR, size_data, status); 
//			dataR = dataR&mask_data;
//			if (dataW!==dataR) begin
//			   $display("[%04d] Signal transfer failed, dataR:%x and dataW:%x not match", $time, i, dataR, dataW);
//			   error = error+1;
//			end
//		end
//		if (error==0)
//			   $display("[%04d] %m   RAW %x-%x %d-byte test OK", $time, start_addr_addr, end_addr, size_data);
		//-------------------------------------------------------------
		error = 0;
		seed = 1;
		mask_data = get_mask(size_data);
		for (i=start_addr_addr; i<(end_addr-size_data+1); i=i+size_data) begin
			write_data = {$random(seed)}&mask_data; 
			ahb_write(i, write_data, size_data, status);
		end
		seed = 1;
		for (i=start_addr_addr; i<(end_addr-size_data+1); i=i+size_data) begin
			ahb_read(i, read_data, size_data, status); 
			read_data = read_data&mask_data;
			data_expected = {$random(seed)}&mask_data; 
//			$display("[%04d]  check data 1: %x", $time, dataR);
//			$display("[%04d]  check data 2: %x", $time, data_expected);
			if (read_data!==data_expected) begin
			   error = error+1;
			end
		end
		if (error==0)
			   $display("[%04d] %m Single transfer successfully with data size = %x", $time, size_data);
	    else   $display("[%04d]  Read data:%x and expected read data: %x not match", $time, read_data, data_expected);
end
endtask

//-----------------------------------------------------
// burst transfer test
// Added by Phuc Nguyen 
task burst_transfer_test;
	input [31:0] start_addr; // start_addr address
	input [31:0] end_addr;// end address
	input [ 7:0] burst_length;  // burst burst_lengthth
	input [ 2:0] size_data;   // data size: 1, 2, 4
	integer i, j, error, seed;
	reg [ 1:0] status;
	reg [31:0] expect;
	reg [ 2:0] hburst;
begin
	  case (burst_length)
	   4: hburst = 3'b011;
	   8: hburst = 3'b101;
	  16: hburst = 3'b111;
	  endcase
	  error = 0;
	  if (end_addr>(start_addr+burst_length*size_data)) begin
		 seed  = 111;
		 // Generate address data and write burst data
		 for (i=start_addr; i<(end_addr-(burst_length*size_data)+1); i=i+burst_length*size_data) begin
			 for (j=0; j<burst_length; j=j+1) begin
				 data_burst_write[j] = $random(seed);
			 end
			 @ (posedge HCLK);
			 // send write burst data to task wite burst
			 ahb_write_burst(i, hburst, status);
		 end
		 seed  = 111;
		 // Generate address data and read burst data
		 for (i=start_addr; i<(end_addr-(burst_length*size_data)+1); i=i+burst_length*size_data) begin
			 @ (posedge HCLK);
			 // get read burst data to task wite burst
			 ahb_read_burst(i, hburst, status);
			 for (j=0; j<burst_length; j=j+1) begin
				 expect = $random(seed);
				 if (data_burst_read[j] != expect) begin
					error = error+1;
					$display("[%04d] At address: %m, ahb_read_burst: %x and expected ahb_read_burst: %x not match", $time, i, data_burst_read[j], expect);
				 end
			 end
			 @ (posedge HCLK);
		 end
		 if (error==0)
			 $display("[%04d] %m burst transfer operation successfully with size data: %x", $time, size_data);
	  end else begin
		  $display("[%04d] burst transfer operation failed with size data: %x", $time, size_data);
	  end
end
endtask
//-----------------------------------------------------
function [31:0] get_mask;
input [2:0] size;
begin
	 case (size)
	 3'd1: get_mask = 32'h0000_00FF;   //  HSIZE <= 3'b000; BYTE;
	 3'd2: get_mask = 32'h0000_FFFF;   //  HSIZE <= 3'b001; HALF-WORD;
	 3'd4: get_mask = 32'hFFFF_FFFF;   //  HSIZE <= 3'b010; WORD;
	 endcase
end
endfunction


