def gen_ahb_s2m(num, bus_name):
    with open(bus_name + ".v", "a") as fo:

        fo.write("//---------------------------------------------------------------------------\n")
        fo.write(f"module ahb_s2m_s{num}\n")
        fo.write("(\n")
        fo.write("       input   wire         HRESETn\n")
        fo.write("     , input   wire         HCLK\n")
        fo.write("     , input   wire         HSELd\n")
        for i in range(num):
            fo.write(f"     , input   wire         HSEL{i}\n")
        fo.write("     , output  reg   [31:0] HRDATA\n")
        fo.write("     , output  reg   [ 1:0] HRESP\n")
        fo.write("     , output  reg          HREADY\n")
        for i in range(num):
            fo.write(f"     , input   wire  [31:0] HRDATA{i}\n")
            fo.write(f"     , input   wire  [ 1:0] HRESP{i}\n")
            fo.write(f"     , input   wire         HREADY{i}\n")
        fo.write("     , input   wire  [31:0] HRDATAd\n")
        fo.write("     , input   wire  [ 1:0] HRESPd\n")
        fo.write("     , input   wire         HREADYd\n")
        fo.write(");\n")
        for i in range(num):
            fo.write(f"  localparam D_HSEL{i} = {num+1}'h{1<<i:X};\n")
        fo.write(f"  localparam D_HSELd = {num+1}'h{1<<num:X};\n")
        fo.write(f"  wire [{num}:0] _hsel = {{HSELd")
        for i in range(num-1, -1, -1):
            fo.write(f",HSEL{i}")
        fo.write("};\n")
        fo.write(f"  reg  [{num}:0] _hsel_reg;\n")
        fo.write("  always @ (posedge HCLK or negedge HRESETn) begin\n")
        fo.write(f"    if (HRESETn==1'b0)   _hsel_reg <= {num+1}'h0;\n")
        fo.write("    else if(HREADY) _hsel_reg <= _hsel; // default HREADY must be 1'b1\n")
        fo.write("  end\n")
        fo.write("  always @ (_hsel_reg or HREADYd")
        for i in range(num):
            fo.write(f" or HREADY{i}")
        fo.write(") begin\n")
        fo.write("    case(_hsel_reg)\n")
        for i in range(num):
            fo.write(f"      D_HSEL{i}: HREADY = HREADY{i};\n")
        fo.write("      D_HSELd: HREADY = HREADYd;\n")
        fo.write("      default: HREADY = 1'b1;\n")
        fo.write("    endcase\n")
        fo.write("  end\n")
        fo.write("  always @ (_hsel_reg or HRDATAd")
        for i in range(num):
            fo.write(f" or HRDATA{i}")
        fo.write(") begin\n")
        fo.write("    case(_hsel_reg)\n")
        for i in range(num):
            fo.write(f"      D_HSEL{i}: HRDATA = HRDATA{i};\n")
        fo.write("      D_HSELd: HRDATA = HRDATAd;\n")
        fo.write("      default: HRDATA = 32'b0;\n")
        fo.write("    endcase\n")
        fo.write("  end\n")
        fo.write("  always @ (_hsel_reg or HRESPd")
        for i in range(num):
            fo.write(f" or HRESP{i}")
        fo.write(") begin\n")
        fo.write("    case(_hsel_reg)\n")
        for i in range(num):
            fo.write(f"      D_HSEL{i}: HRESP = HRESP{i};\n")
        fo.write("      D_HSELd: HRESP = HRESPd;\n")
        fo.write("      default: HRESP = 2'b01; //`HRESP_ERROR;\n")
        fo.write("    endcase\n")
        fo.write("  end\n")
        fo.write("endmodule\n")
        fo.write("//---------------------------------------------------------------------------\n")

        return 0

