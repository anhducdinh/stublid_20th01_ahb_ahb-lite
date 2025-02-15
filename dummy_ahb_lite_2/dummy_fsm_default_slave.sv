// Create and Design : ducanh    email: ducanhld15@gmail.com
// ver 1.0 : 
// dummy design ahb 
module dummy_default_slave (
    input            HCLK,
    input            HRESETN,
    input [2:0]      HBURST,
    input [2:0]      HSIZE,
    input [31:0]     HWDATA,
    input            HWRITE,
    input            HSEL,
    input            HREADY,
    input            HRESETN,
    input [1:0]      HTRANS,
    output reg       HREADYOUT,
    output reg [1:0] HRESP ,  //AMBA AHB 2
    output wire [31:0]    HRDATA
);
 reg [1:0] state;
 parameter  IDLE = 2'b00;
 parameter  State_WRITE = 2'b01;
 parameter  State_READ  = 2'b10;
 //parameter  ILLEGRAL    = 2'b11;
assign HRDATA = 32'b0;
 always_ff @( posedge HCLK or negedge HRESETn ) begin 
    if(HRESETN) begin
        state <= IDLE;
        HREADYOUT  <=  1'b1;
        HRESP      <=  2'b00;
    end
    // the aim of default slave to respone with hreadyout and hresp 
    // 
    else begin
        case(state) 
            IDLE: begin
                if(HSEL && HREADY) begin
                    case(HTRANS)
                        2'b00, 2'b01: begin  // busy and idle
                            state   <=  IDLE
                            HREADYOUT  <=  1'b1;
                            HRESP      <=  2'b00;
                        end
                        2'b10, 2'b11: begin   // nonseq and seq
                            HREADYOUT  <=  1'b1;
                            HRESP      <=  2'b01;
                            if(HWRITE) begin
                                state   <=  State_WRITE;
                            end
                            else begin
                                state   <=  State_READ;
                            end
                        end
                    endcase
                end
                else begin
                    HREADYOUT  <=  1'b1;
                    HRESP      <=  2'b00;    
                end
            end
            State_WRITE: begin
                HREADYOUT  <=  1'b1;
                HRESP      <=  2'b01; 

            end
            State_READ: begin
                HREADYOUT  <=  1'b1;
                HRESP      <=  2'b01; 
            end
            default: 
            HREADYOUT  <=  1'b1;
            HRESP      <=  2'b00; 
        endcase
    end
    
 end
 
endmodule
