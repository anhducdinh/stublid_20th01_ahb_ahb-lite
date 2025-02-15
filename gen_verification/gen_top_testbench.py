import re
print ("=================GEN VERIFICATION BUS AHB/AHB-Lite=============\n")
print ("   author: Ducanh                   nickname: Stublid_20th01   \n")
print("[User guide] gen_tb_bus_ahb [options]\n")
print("             --master=num                      number of Masters\n")
print("             --slave=num                       number of Slave\n")
print("             --output=str                      name of TestBench\n")
print("Number of Master and Slave must higher than 2\n")
command = input("----> ")

pattern = r"--master=(\d+)\s+--slave=(\d+)\s+--output=([^\s]+)"

matches = re.search(pattern, command)

if matches:
    numM = int(matches.group(1))
    numS = int(matches.group(2))
    bus_name = matches.group(3)
    
if (numM < 2 or numS < 2):
        print("Error:Number of Master or Slave not valid!")
    
    
NUM_BYTES = 1024
with open(bus_name + ".v", 'a') as f:
    f.write('''//------------------------------------------------------------------------------
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
`define SIZE_IN_BYTES {}
`endif

module top;
   //---------------------------------------------------------------------------
   localparam NUM_MST={}
            , NUM_SLV={};
   //---------------------------------------------------------------------------
'''.format(NUM_BYTES, numM, numS))
    cnt_slv = 0
    startX = 0
    sizeX = hex(NUM_BYTES)[2:]
    while cnt_slv < numS:
        startX = hex(cnt_slv * NUM_BYTES)[2:]
        f.write("   localparam  P_HSEL{}_START=32'h{},P_HSEL{}_SIZE=32'h{};\n".format(cnt_slv, startX, cnt_slv, sizeX))
        cnt_slv += 1
    f.close()
content_1 = '''
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
'''.strip()

content_2 = '''
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
'''.strip()
with open(bus_name + ".v", 'a') as f:
    f.write(content_1)
   
    f.write("\namba_ahb_m{}s{}".format(numM, numS))
    f.write(" #(.P_NUMM(NUM_MST)\n")
    f.write("                  ,.P_NUMS(NUM_SLV) \n")

    cnt_slv=0
    while cnt_slv < numS:
       f.write(f'                  ,.P_HSEL{cnt_slv}_START(P_HSEL{cnt_slv}_START),.P_HSEL{cnt_slv}_SIZE(P_HSEL{cnt_slv}_SIZE)\n')
       cnt_slv += 1

    f.write("           )\n")
    f.write("   u_amba_ahb  (\n")
    f.write("        .HRESETn      (HRESETn     )\n")
    f.write("      , .HCLK         (HCLK        )\n")

    cnt_mst=0
    while cnt_mst < numM:
        f.write(f'      , .M{cnt_mst}_HBUSREQ  (M_HBUSREQ [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HGRANT   (M_HGRANT  [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HADDR    (M_HADDR   [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HTRANS   (M_HTRANS  [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HSIZE    (M_HSIZE   [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HBURST   (M_HBURST  [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HPROT    (M_HPROT   [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HLOCK    (M_HLOCK   [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HWRITE   (M_HWRITE  [{cnt_mst}])\n')
        f.write(f'      , .M{cnt_mst}_HWDATA   (M_HWDATA  [{cnt_mst}])\n')
        cnt_mst += 1

    f.write("      , .M_HRDATA    (M_HRDATA     )\n")
    f.write("      , .M_HRESP     (M_HRESP      )\n")
    f.write("      , .M_HREADY    (M_HREADY     )\n")
    f.write("      , .S_HADDR     (S_HADDR      )\n")
    f.write("      , .S_HWRITE    (S_HWRITE     )\n")
    f.write("      , .S_HTRANS    (S_HTRANS     )\n")
    f.write("      , .S_HSIZE     (S_HSIZE      )\n")
    f.write("      , .S_HBURST    (S_HBURST     )\n")
    f.write("      , .S_HWDATA    (S_HWDATA     )\n")
    f.write("      , .S_HPROT     (S_HPROT      )\n")
    f.write("      , .S_HREADY    (S_HREADY     )\n")
    f.write("      , .S_HMASTER   (S_HMASTER    )\n")
    f.write("      , .S_HMASTLOCK (S_HMASTLOCK  )\n")

    cnt_slv=0
    while cnt_slv < numS:
        f.write(f'      , .S{cnt_slv}_HSEL     (S_HSEL     [{cnt_slv}])\n')
        f.write(f'      , .S{cnt_slv}_HREADY   (S_HREADYout[{cnt_slv}])\n')
        f.write(f'      , .S{cnt_slv}_HRESP    (S_HRESP    [{cnt_slv}])\n')
        f.write(f'      , .S{cnt_slv}_HRDATA   (S_HRDATA   [{cnt_slv}])\n')
        f.write(f'      , .S{cnt_slv}_HSPLIT   (S_HSPLIT   [{cnt_slv}])\n')
        cnt_slv += 1

    f.write("      , .REMAP       (1'b0          )\n")
    f.write("   );\n")
    
    f.write(content_2)


