import module_ahb_decoder
import module_ahb_s2m
import module_ahb_default_slave

def gen_ahb_lite( lite, num,bus_name):
    gen_ahb_lite_core( lite, num,bus_name)
    module_ahb_decoder.gen_ahb_decoder(num, bus_name)
    module_ahb_s2m.gen_ahb_s2m(num,bus_name)
    module_ahb_default_slave.gen_ahb_default_slave(bus_name)
    return 0
    
    
def gen_ahb_lite_core(lite, num,bus_name):
    with open(bus_name + ".v", "a") as fo:
   
        start = 0x00000000
        size = 0x00010000

        fo.write("//---------------------------------------------------------------------------\n")
        # if lite:
            # fo.write("module %s\n" % ("ahb_lite" if module == 0 else module))
        # else:
        fo.write("module ahb_lite_s%d\n" % (num))
        fo.write("#(parameter P_NUM=%d // num of slaves\n" % num)
        for i in range(num):
            fo.write("           , P_HSEL%d_START=32'h%08X, P_HSEL%d_SIZE=32'h%08X\n" % (i, start, i, size))
            start += 0x01000000 if num > 16 else 0x10000000
        fo.write("           )\n")
        fo.write("(\n")
        fo.write("    input   wire         HRESETn\n")
        fo.write("  , input   wire         HCLK\n")
        fo.write("  , input   wire  [31:0] M_HADDR\n")
        fo.write("  , input   wire  [ 1:0] M_HTRANS\n")
        fo.write("  , input   wire         M_HWRITE\n")
        fo.write("  , input   wire  [ 2:0] M_HSIZE\n")
        fo.write("  , input   wire  [ 2:0] M_HBURST\n")
        fo.write("  , input   wire  [ 3:0] M_HPROT\n")
        fo.write("  , input   wire  [31:0] M_HWDATA\n")
        fo.write("  , output  wire  [31:0] M_HRDATA\n")
        fo.write("  , output  wire  [ 1:0] M_HRESP\n")
        fo.write("  , output  wire         M_HREADY\n")
        fo.write("  , output  wire  [31:0] S_HADDR\n")
        fo.write("  , output  wire  [ 1:0] S_HTRANS\n")
        fo.write("  , output  wire  [ 2:0] S_HSIZE\n")
        fo.write("  , output  wire  [ 2:0] S_HBURST\n")
        fo.write("  , output  wire  [ 3:0] S_HPROT\n")
        fo.write("  , output  wire         S_HWRITE\n")
        fo.write("  , output  wire  [31:0] S_HWDATA\n")
        fo.write("  , output  wire         S_HREADY\n")
        for i in range(num):
            fo.write("  , output  wire         S%d_HSEL\n" % i)
            fo.write("  , input   wire         S%d_HREADY\n" % i)
            fo.write("  , input   wire  [ 1:0] S%d_HRESP\n" % i)
            fo.write("  , input   wire  [31:0] S%d_HRDATA\n" % i)
        fo.write("  , input   wire         REMAP\n")
        fo.write(");\n")
        fo.write("  wire        HSELd; // default slave\n")
        fo.write("  wire [31:0] HRDATAd;\n")
        fo.write("  wire [ 1:0] HRESPd;\n")
        fo.write("  wire        HREADYd;\n")
        fo.write("  assign S_HADDR  = M_HADDR;\n")
        fo.write("  assign S_HTRANS = M_HTRANS;\n")
        fo.write("  assign S_HSIZE  = M_HSIZE;\n")
        fo.write("  assign S_HBURST = M_HBURST;\n")
        fo.write("  assign S_HWRITE = M_HWRITE;\n")
        fo.write("  assign S_HPROT  = M_HPROT;\n")
        fo.write("  assign S_HWDATA = M_HWDATA;\n")
        fo.write("  assign S_HREADY = M_HREADY;\n")
        fo.write("  ahb_decoder_s%d\n" % ( num))
        fo.write("    #(.P_NUM(%d)\n" % num)
        for i in range(num):
            fo.write("     ,.P_HSEL%d_START(P_HSEL%d_START)" % (i, i))
            fo.write(",.P_HSEL%d_SIZE(P_HSEL%d_SIZE)\n" % (i, i))
        fo.write("     )\n")
        fo.write("  u_ahb_decoder (\n")
        fo.write("                .HADDR(M_HADDR)\n")
        fo.write("               ,.HSELd(HSELd)\n")
        for i in range(num):
            fo.write("               ,.HSEL%d(S%d_HSEL)\n" % (i, i))
        fo.write("               ,.REMAP(REMAP));\n")
        fo.write("  ahb_s2m_s%d u_ahb_s2m (\n" % ( num))
        fo.write("                .HRESETn(HRESETn)\n")
        fo.write("               ,.HCLK   (HCLK   )\n")
        fo.write("               ,.HRDATA (M_HRDATA)\n")
        fo.write("               ,.HRESP  (M_HRESP )\n")
        fo.write("               ,.HREADY (M_HREADY)\n")
        for i in range(num):
            fo.write("               ,.HSEL%d  (S%d_HSEL)\n" % (i, i))
            fo.write("               ,.HRDATA%d(S%d_HRDATA)\n" % (i, i))
            fo.write("               ,.HRESP%d (S%d_HRESP)\n" % (i, i))
            fo.write("               ,.HREADY%d(S%d_HREADY)\n" % (i, i))
        fo.write("               ,.HSELd  (HSELd  )\n")
        fo.write("               ,.HRDATAd(HRDATAd)\n")
        fo.write("               ,.HRESPd (HRESPd )\n")
        fo.write("               ,.HREADYd(HREADYd));\n")
        fo.write("  ahb_default_slave u_ahb_default_slave (\n" )
        fo.write("                .HRESETn  (HRESETn  )\n")
        fo.write("               ,.HCLK     (HCLK     )\n")
        fo.write("               ,.HSEL     (HSELd    )\n")
        fo.write("               ,.HADDR    (S_HADDR  )\n")
        fo.write("               ,.HTRANS   (S_HTRANS )\n")
        fo.write("               ,.HWRITE   (S_HWRITE )\n")
        fo.write("               ,.HSIZE    (S_HSIZE  )\n")
        fo.write("               ,.HBURST   (S_HBURST )\n")
        fo.write("               ,.HWDATA   (S_HWDATA )\n")
        fo.write("               ,.HRDATA   (HRDATAd  )\n")
        fo.write("               ,.HRESP    (HRESPd   )\n")
        fo.write("               ,.HREADYin (S_HREADY )\n")
        fo.write("               ,.HREADYout(HREADYd  ));\n")
        fo.write("endmodule\n")
        fo.write("//---------------------------------------------------------------------------\n")

    return 0

