import re
print ("===============================================================\n")
print ("===============PROJECT GEN BUS AHB/AHB-Lite==============\n")
print ("    Author: Dinh Duc Anh             Nickname: Stublid_20th01  \n")
print ("===============================================================\n")
print("[User guide] gen_bus_ahb [options]\n")
print("             --type=AHB-Lite/AHB              AMBA AHB-Lite\n")
print("             --number_master=num                      number of Masters\n")
print("             --number_slave=num                       number of Slave\n  ")
print("             --output_name=str                        name of Design\n   ")
print("Number of Master and Slave must higher than 2\n")
command = input("----> ")


pattern = r"--type=([^\s]+)\s+--number_master=(\d+)\s+--number_slave=(\d+)\s+--output_name=([^\s]+)"

matches = re.search(pattern, command)

if matches:
    bus_opt = matches.group(1)
    numM = int(matches.group(2))    #type of integer for numM
    numS = int(matches.group(3))    #type of integer for numS
    bus_name = matches.group(4)
    
if(bus_opt == "AHB"):
    if (numM < 2 or numS < 2):
        print("[[Error]]:Number of Master or Slave not valid!!!!\n")
        print("[[Error]]:---Please update the relevant values---\n")
elif(bus_opt == "AHB-Lite"):
    if(numS < 2):
        print("[[Error]]:Number of  Slave not valid!\n")
        print("[[Error]]:---Please update the relevant values---\n")
    
if (bus_opt != "AHB-Lite" and bus_opt != "AHB"):
    print("[[Error]]: Option of Bus not Valid!\n")
    print("[[Error]]:---Please update the relevant values---\n")

import module_arbiter
import module_ahb_m2s
import module_ahb_lite
import module_ahb_decoder
import module_ahb_s2m

def gen_ahb_amba_core( numM, numS, bus_name):
    i = 0
    start=0x00000000
    size =0x00010000

    with open(bus_name +".v", "w") as fo:
        fo.write("//---------------------------------------------------------------------------\n")
        fo.write("module {}\n".format(bus_name))
        fo.write("     #(parameter P_numM={} // num of masters\n".format(numM))
        fo.write("               , P_numS={} // num of slaves\n".format(numS))
        for i in range(numS):
            fo.write("               , P_HSEL{}_START=32'h{:08X}, P_HSEL{}_SIZE=32'h{:08X}\n".format(i, start, i, size))
            start += 0x01000000 if numS > 16 else 0x10000000
        fo.write("               )\n")
        fo.write("(\n")
        fo.write("        input   wire         HRESETn\n")
        fo.write("      , input   wire         HCLK\n")

        for i in range(numM):
         fo.write("      , input   wire         M{}_HBUSREQ\n".format(i))
        fo.write("      , output  wire         M{}_HGRANT\n".format(i))
        fo.write("      , input   wire  [31:0] M{}_HADDR\n".format(i))
        fo.write("      , input   wire  [ 1:0] M{}_HTRANS\n".format(i))
        fo.write("      , input   wire  [ 2:0] M{}_HSIZE\n".format(i))
        fo.write("      , input   wire  [ 2:0] M{}_HBURST\n".format(i))
        fo.write("      , input   wire  [ 3:0] M{}_HPROT\n".format(i))
        fo.write("      , input   wire         M{}_HLOCK\n".format(i))
        fo.write("      , input   wire         M{}_HWRITE\n".format(i))
        fo.write("      , input   wire  [31:0] M{}_HWDATA\n".format(i))

        fo.write("      , output  wire  [31:0] M_HRDATA\n")
        fo.write("      , output  wire  [ 1:0] M_HRESP\n")
        fo.write("      , output  wire         M_HREADY\n")
        fo.write("      , output  wire  [31:0] S_HADDR\n")
        fo.write("      , output  wire         S_HWRITE\n")
        fo.write("      , output  wire  [ 1:0] S_HTRANS\n")
        fo.write("      , output  wire  [ 2:0] S_HSIZE\n")
        fo.write("      , output  wire  [ 2:0] S_HBURST\n")
        fo.write("      , output  wire  [31:0] S_HWDATA\n")
        fo.write("      , output  wire  [ 3:0] S_HPROT\n")
        fo.write("      , output  wire         S_HREADY\n")
        fo.write("      , output  wire  [ 3:0] S_HMASTER\n")
        fo.write("      , output  wire         S_HMASTLOCK\n")

        for i in range(numS):
            fo.write("      , output  wire         S{}_HSEL\n".format(i))
            fo.write("      , input   wire         S{}_HREADY\n".format(i))
            fo.write("      , input   wire  [ 1:0] S{}_HRESP\n".format(i))
            fo.write("      , input   wire  [31:0] S{}_HRDATA\n".format(i))
            fo.write("      , input   wire  [15:0] S{}_HSPLIT\n".format(i))

        fo.write("      , input   wire         REMAP\n")
        fo.write(");\n")
        fo.write("  ahb_arbiter #(.NUMM({}),.NUMS({}))\n".format( numM, numS))
        fo.write("  u_ahb_arbiter (\n")
        fo.write("         .HRESETn   (HRESETn    )\n")
        fo.write("       , .HCLK      (HCLK       )\n")
        fo.write("       , .HBUSREQ   ({")
        fo.write("M{}_HBUSREQ".format(numM-1))
        for i in range(numM-2, -1, -1):
            fo.write(",M{}_HBUSREQ".format(i))
        fo.write("})\n");
        
        fo.write("       , .HGRANT   ({")
        fo.write("M{}_HGRANT".format(numM-1))
        for i in range(numM-2, -1, -1):
            fo.write(",M{}_HGRANT".format(i))
        fo.write("})\n");
        
        fo.write("       , .HMASTER   (S_HMASTER  )\n")
        
        fo.write("       , .HLOCK     ({")
        fo.write("M{}_HLOCK".format(numM-1))
        for i in range(numM-2, -1, -1):
            fo.write(",M{}_HLOCK".format(i))
        fo.write("})\n");
        
        fo.write("       , .HREADY    (M_HREADY   )\n")
        fo.write("       , .HMASTLOCK (S_HMASTLOCK)\n")
        
        fo.write("       , .HSPLIT    ({")
        fo.write("S{}_HSPLIT".format(numS-1))
        for i in range(numS-2, -1, -1):
         fo.write(",S{}_HSPLIT".format(i))
        fo.write("})\n");
        fo.write("  );\n")
        fo.write("  wire  [31:0] M_HADDR;\n")
        fo.write("  wire  [ 1:0] M_HTRANS;\n")
        fo.write("  wire  [ 2:0] M_HSIZE;\n")
        fo.write("  wire  [ 2:0] M_HBURST;\n")
        fo.write("  wire  [ 3:0] M_HPROT;\n")
        fo.write("  wire         M_HWRITE;\n")
        fo.write("  wire  [31:0] M_HWDATA;\n")
        fo.write("  ahb_m2s_m{} u_ahb_m2s (\n".format( numM))
        fo.write("       .HRESETn  (HRESETn    )\n")
        fo.write("     , .HCLK     (HCLK       )\n")
        fo.write("     , .HREADY   (M_HREADY   )\n")
        fo.write("     , .HMASTER  (S_HMASTER  )\n")
        fo.write("     , .HADDR    (M_HADDR    )\n")
        fo.write("     , .HPROT    (M_HPROT    )\n")
        fo.write("     , .HTRANS   (M_HTRANS   )\n")
        fo.write("     , .HWRITE   (M_HWRITE   )\n")
        fo.write("     , .HSIZE    (M_HSIZE    )\n")
        fo.write("     , .HBURST   (M_HBURST   )\n")
        fo.write("     , .HWDATA   (M_HWDATA   )\n")

        for i in range(numM):
            fo.write("     , .HADDR{}   (M{}_HADDR  )\n".format(i, i))
            fo.write("     , .HPROT{}   (M{}_HPROT  )\n".format(i, i))
            fo.write("     , .HTRANS{}  (M{}_HTRANS )\n".format(i, i))
            fo.write("     , .HWRITE{}  (M{}_HWRITE )\n".format(i, i))
            fo.write("     , .HSIZE{}   (M{}_HSIZE  )\n".format(i, i))
            fo.write("     , .HBURST{}  (M{}_HBURST )\n".format(i, i))
            fo.write("     , .HWDATA{}  (M{}_HWDATA )\n".format(i, i))

        fo.write("  );\n")
        fo.write("  ahb_lite_s{} #(.P_NUM({})\n".format( numS, numS))

        for i in range(numS):
            fo.write("               ,.P_HSEL{}_START(P_HSEL{}_START), .P_HSEL{}_SIZE(P_HSEL{}_SIZE)\n".format(i, i, i, i))

        fo.write("               )\n")
        fo.write("  u_ahb_lite (\n")
        fo.write("       .HRESETn   (HRESETn  )\n")
        fo.write("     , .HCLK      (HCLK     )\n")
        fo.write("     , .M_HADDR   (M_HADDR  )\n")
        fo.write("     , .M_HTRANS  (M_HTRANS )\n")
        fo.write("     , .M_HWRITE  (M_HWRITE )\n")
        fo.write("     , .M_HSIZE   (M_HSIZE  )\n")
        fo.write("     , .M_HBURST  (M_HBURST )\n")
        fo.write("     , .M_HPROT   (M_HPROT  )\n")
        fo.write("     , .M_HWDATA  (M_HWDATA )\n")
        fo.write("     , .M_HRDATA  (M_HRDATA )\n")
        fo.write("     , .M_HRESP   (M_HRESP  )\n")
        fo.write("     , .M_HREADY  (M_HREADY )\n")
        fo.write("     , .S_HADDR   (S_HADDR  )\n")
        fo.write("     , .S_HTRANS  (S_HTRANS )\n")
        fo.write("     , .S_HSIZE   (S_HSIZE  )\n")
        fo.write("     , .S_HBURST  (S_HBURST )\n")
        fo.write("     , .S_HWRITE  (S_HWRITE )\n")
        fo.write("     , .S_HPROT   (S_HPROT  )\n")
        fo.write("     , .S_HWDATA  (S_HWDATA )\n")
        fo.write("     , .S_HREADY  (S_HREADY )\n")

        for i in range(numS):
            fo.write("     , .S{}_HSEL   (S{}_HSEL  )\n".format(i, i))
            fo.write("     , .S{}_HRDATA (S{}_HRDATA)\n".format(i, i))
            fo.write("     , .S{}_HRESP  (S{}_HRESP )\n".format(i, i))
            fo.write("     , .S{}_HREADY (S{}_HREADY)\n".format(i, i))

        fo.write("     , .REMAP     (REMAP    )\n")
        fo.write("  );\n")
        fo.write("endmodule\n")
        fo.write("//---------------------------------------------------------------------------\n")


if bus_opt == "AHB":
    gen_ahb_amba_core(numM, numS, bus_name)
    module_arbiter.gen_ahb_arbiter( numM, numS,bus_name)
    module_ahb_m2s.gen_ahb_m2s( numM, bus_name)
    module_ahb_lite.gen_ahb_lite(bus_opt, numS, bus_name)
    
elif bus_opt == "AHB-Lite":
    module_ahb_lite.gen_ahb_lite(bus_opt, numS, bus_name) 
    
print("hi my name is =====\n")

