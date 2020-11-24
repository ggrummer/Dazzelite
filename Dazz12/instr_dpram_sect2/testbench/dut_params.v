localparam FAMILY = "iCE40UP";
localparam MEM_ID = "instr_dpram_sect2";
localparam MEM_SIZE = "32,256";
localparam WADDR_DEPTH = 256;
localparam WDATA_WIDTH = 32;
localparam RADDR_DEPTH = 256;
localparam RDATA_WIDTH = 32;
localparam WADDR_WIDTH = 8;
localparam REGMODE = "noreg";
localparam RADDR_WIDTH = 8;
localparam OUTPUT_CLK_EN = 0;
localparam RESETMODE = "sync";
localparam BYTE_ENABLE = 0;
localparam BYTE_WIDTH = 1;
localparam BYTE_SIZE = 8;
localparam ECC_ENABLE = 0;
localparam INIT_MODE = "mem_file";
localparam INIT_FILE = "misc/shootenballs_instr_dpram_sect2_copy.mem";
localparam INIT_FILE_FORMAT = "hex";
localparam INIT_VALUE_00 = "0x80505000811010705000400041701070405040404030402040104000500000000x100000004000000000008000800F00008F0FAF008FC080C080AF800F20000000";
localparam INIT_VALUE_01 = "0x40304020805050008110107050004020401080505000811010705000401040000x800088E010000000400000000000800080C010000000400000000000800080AF";
localparam INIT_VALUE_02 = "0x10705000405040408050500081101070500040404030805050008110107050000x0000000080008F0F100000004000000000008000AF0010000000400000000000";
localparam INIT_VALUE_03 = "0x000000000000000000000000000000000000000000000000000020008FF281100x00000000000000000000000000000000000000000000000000000000A0004000";
localparam INIT_VALUE_04 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_05 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_06 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_07 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_08 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_09 = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0A = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0B = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0C = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0D = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0E = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_0F = "0x00000000000000000000000000000000000000000000000000000000000000000x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_10 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_11 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_12 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_13 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_14 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_15 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_16 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_17 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_18 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_19 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1A = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1B = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1C = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1D = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1E = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_1F = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_20 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_21 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_22 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_23 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_24 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_25 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_26 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_27 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_28 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_29 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2A = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2B = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2C = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2D = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2E = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_2F = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_30 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_31 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_32 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_33 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_34 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_35 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_36 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_37 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_38 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_39 = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3A = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3B = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3C = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3D = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3E = "0x0000000000000000000000000000000000000000000000000000000000000000";
localparam INIT_VALUE_3F = "0x0000000000000000000000000000000000000000000000000000000000000000";
`define ICE40UP