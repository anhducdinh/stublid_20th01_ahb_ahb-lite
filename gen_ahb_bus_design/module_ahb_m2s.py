def gen_ahb_m2s( numM, bus_name):
    with open( bus_name + ".v", "a") as fo:
        fo.write("//---------------------------------------------------------------------------\n")
        fo.write("module ahb_m2s_m%d\n" % ( numM))
        fo.write("(\n")
        fo.write("       input   wire          HRESETn\n")
        fo.write("     , input   wire          HCLK\n")
        fo.write("     , input   wire          HREADY\n")
        fo.write("     , input   wire  [ 3:0]  HMASTER\n")
        fo.write("     , output  reg   [31:0]  HADDR\n")
        fo.write("     , output  reg   [ 3:0]  HPROT\n")
        fo.write("     , output  reg   [ 1:0]  HTRANS\n")
        fo.write("     , output  reg           HWRITE\n")
        fo.write("     , output  reg   [ 2:0]  HSIZE\n")
        fo.write("     , output  reg   [ 2:0]  HBURST\n")
        fo.write("     , output  reg   [31:0]  HWDATA\n")
        for i in range(numM):
            fo.write("     , input   wire  [31:0]  HADDR%d\n" % i)
            fo.write("     , input   wire  [ 3:0]  HPROT%d\n" % i)
            fo.write("     , input   wire  [ 1:0]  HTRANS%d\n" % i)
            fo.write("     , input   wire          HWRITE%d\n" % i)
            fo.write("     , input   wire  [ 2:0]  HSIZE%d\n" % i)
            fo.write("     , input   wire  [ 2:0]  HBURST%d\n" % i)
            fo.write("     , input   wire  [31:0]  HWDATA%d\n" % i)
        fo.write(");\n")
        fo.write("       reg [3:0] hmaster_delay=4'h0;\n")
        fo.write("       always @ (posedge HCLK or negedge HRESETn) begin\n")
        fo.write("           if (HRESETn==1'b0) begin\n")
        fo.write("                hmaster_delay <= 4'b0;\n")
        fo.write("           end else begin\n")
        fo.write("                if (HREADY) begin\n")
        fo.write("                   hmaster_delay <= HMASTER;\n")
        fo.write("                end\n")
        fo.write("           end\n")
        fo.write("       end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HADDR%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
         fo.write("           4'h%X: HADDR = HADDR%d;\n" % (i, i))
        fo.write("           default: HADDR = ~32'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HPROT%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
            fo.write("           4'h%X: HPROT = HPROT%d;\n" % (i, i))
        fo.write("           default: HPROT = 4'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HTRANS%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
            fo.write("           4'h%X: HTRANS = HTRANS%d;\n" % (i, i))
        fo.write("           default: HTRANS = 2'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HWRITE%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
            fo.write("           4'h%X: HWRITE = HWRITE%d;\n" % (i, i))
        fo.write("           default: HWRITE = 1'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HSIZE%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
            fo.write("           4'h%X: HSIZE = HSIZE%d;\n" % (i, i))
        fo.write("           default: HSIZE = 3'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (HMASTER")
        for i in range(numM):
            fo.write(" or HBURST%d" % i)
        fo.write(") begin\n")
        fo.write("           case (HMASTER)\n")
        for i in range(numM):
            fo.write("           4'h%X: HBURST = HBURST%d;\n" % (i, i))
        fo.write("           default: HBURST = 3'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("       always @ (hmaster_delay")
        for i in range(numM):
            fo.write(" or HWDATA%d" % i)
        fo.write(") begin\n")
        fo.write("           case (hmaster_delay)\n")
        for i in range(numM):
            fo.write("           4'h%X: HWDATA = HWDATA%d;\n" % (i, i))
        fo.write("           default: HWDATA = 3'b0;\n")
        fo.write("           endcase\n")
        fo.write("        end\n")
        fo.write("endmodule\n")
        fo.write("//---------------------------------------------------------------------------\n")
        return 0




