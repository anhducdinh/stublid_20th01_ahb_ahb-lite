def gen_ahb_decoder(num, bus_name):
    start = 0x00000000
    size = 0x00010000
    with open( bus_name + ".v", "a") as fo:
    
        fo.write("//---------------------------------------------------------------------------\n")
        fo.write(f"module ahb_decoder_s{num}\n")
        fo.write(f"     #(parameter P_NUM        ={num}\n")
        for i in range(num):
            fo.write(f"               , P_HSEL{i}_START=32'h{start:08X}, P_HSEL{i}_SIZE=32'h{size:08X}\n")
            fo.write(f"               , P_HSEL{i}_END  =P_HSEL{i}_START+P_HSEL{i}_SIZE\n")
            start += 0x01000000 if num > 16 else 0x10000000
        fo.write(f"               )\n")
        fo.write("(\n")
        fo.write("       input   wire [31:0] HADDR\n")
        fo.write("     , output  wire        HSELd // default slave\n")
        for i in range(num):
            fo.write(f"     , output  wire        HSEL{i}\n")
        fo.write("     , input   wire        REMAP\n")
        fo.write(");\n")
        fo.write(f"   wire [{num-1}:0] ihsel;\n")
        fo.write("   wire       ihseld = ~|ihsel;\n")
        fo.write("   assign HSELd = ihseld;\n")
        fo.write(f"   assign HSEL0 = (REMAP) ? ihsel[1] : ihsel[0];\n")
        fo.write(f"   assign HSEL1 = (REMAP) ? ihsel[0] : ihsel[1];\n")
        for i in range(2, num):
            fo.write(f"   assign HSEL{i} = ihsel[{i}];\n")
        for i in range(num):
            fo.write(f"   assign ihsel[{i}] = ((P_NUM>{i})&&(HADDR>=P_HSEL{i}_START)&&(HADDR<P_HSEL{i}_END)) ? 1'b1 : 1'b0;\n")
        fo.write("endmodule\n")
        fo.write("//---------------------------------------------------------------------------\n")
        return 0