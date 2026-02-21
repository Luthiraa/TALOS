`timescale 1ns/1ps
`default_nettype none

// Top-level for DE1-SoC to drive inference.sv
// - SW0: enable
// - SW1: reset_n
// - LEDR: lower 10 bits of o0 (Q16.16)
// - HEX displays: show o0 in hex (integer high 16 bits on HEX0-HEX3, frac low 16 bits on HEX4-HEX5)
module top_inference_de1 (
    input  wire         CLOCK_50,
    input  wire [9:0]   SW,
    input  wire [3:0]   KEY,
    output logic [9:0]  LEDR,
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5
);
	 wire clk_10;
	 wire pll_locked;

	 pll_10 u_pll (
	   .refclk   (CLOCK_50),
	   .rst      (~SW[1]),        // SW[1]=0 means "reset asserted" -> active-high PLL reset
	   .outclk_0 (clk_10),
	   .locked   (pll_locked)
	 );

    // Parameters matching inference module
    localparam int IMG_HEIGHT     = 28;
    localparam int IMG_WIDTH      = 28;
    localparam int NO_KERNELS     = 4;
    localparam int KERNEL_SIZE    = 3;
    localparam int MAXPOOL_KERNEL = 2;

    // Map raw controls (asynchronous to clk)
    wire clk        = clk_10;           // Use 50 MHz board clock
    wire rst_n_raw  = SW[1];              // SW1 low = reset asserted (active-low)
    wire enable_raw = SW[0];              // SW0 as enable level

    // Synchronize switches to clk to avoid metastability/glitches
    logic [1:0] rst_sync_ff;
	 logic [1:0] en_sync_ff;
	 logic [1:0] lock_sync_ff;

	 always_ff @(posedge clk) begin
	 	 lock_sync_ff <= {lock_sync_ff[0], pll_locked};  // sync lock into clk domain
	 	 rst_sync_ff  <= {rst_sync_ff[0],  rst_n_raw};
	 	 en_sync_ff   <= {en_sync_ff[0],   enable_raw};
	 end

	 wire pll_locked_s = lock_sync_ff[1];

	 // IMPORTANT: hold design in reset until PLL is locked
	 wire rst_n  = rst_sync_ff[1] & pll_locked_s;

	 wire enable = en_sync_ff[1];
    // Rising-edge start pulse from SW0
    wire start_pulse = en_sync_ff[0] & ~en_sync_ff[1];

    // Inputs to inference
    logic signed [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0];
    logic signed [31:0] kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0];

    initial begin
        // Assign MNIST image (Q16.16) to img[] (hex, two's complement)
        img[0] = 32'hffff9367;
        img[1] = 32'hffff9367;
        img[2] = 32'hffff9367;
        img[3] = 32'hffff9367;
        img[4] = 32'hffff9367;
        img[5] = 32'hffff9367;
        img[6] = 32'hffff9367;
        img[7] = 32'hffff9367;
        img[8] = 32'hffff9367;
        img[9] = 32'hffff9367;
        img[10] = 32'hffff9367;
        img[11] = 32'hffff9367;
        img[12] = 32'hffff9367;
        img[13] = 32'hffff9367;
        img[14] = 32'hffff9367;
        img[15] = 32'hffff9367;
        img[16] = 32'hffff9367;
        img[17] = 32'hffff9367;
        img[18] = 32'hffff9367;
        img[19] = 32'hffff9367;
        img[20] = 32'hffff9367;
        img[21] = 32'hffff9367;
        img[22] = 32'hffff9367;
        img[23] = 32'hffff9367;
        img[24] = 32'hffff9367;
        img[25] = 32'hffff9367;
        img[26] = 32'hffff9367;
        img[27] = 32'hffff9367;
        img[28] = 32'hffff9367;
        img[29] = 32'hffff9367;
        img[30] = 32'hffff9367;
        img[31] = 32'hffff9367;
        img[32] = 32'hffff9367;
        img[33] = 32'hffff9367;
        img[34] = 32'hffff9367;
        img[35] = 32'hffff9367;
        img[36] = 32'hffff9367;
        img[37] = 32'hffff9367;
        img[38] = 32'hffff9367;
        img[39] = 32'hffff9367;
        img[40] = 32'hffff9367;
        img[41] = 32'hffff9367;
        img[42] = 32'hffff9367;
        img[43] = 32'hffff9367;
        img[44] = 32'hffff9367;
        img[45] = 32'hffff9367;
        img[46] = 32'hffff9367;
        img[47] = 32'hffff9367;
        img[48] = 32'hffff9367;
        img[49] = 32'hffff9367;
        img[50] = 32'hffff9367;
        img[51] = 32'hffff9367;
        img[52] = 32'hffff9367;
        img[53] = 32'hffff9367;
        img[54] = 32'hffff9367;
        img[55] = 32'hffff9367;
        img[56] = 32'hffff9367;
        img[57] = 32'hffff9367;
        img[58] = 32'hffff9367;
        img[59] = 32'hffff9367;
        img[60] = 32'hffff9367;
        img[61] = 32'hffff9367;
        img[62] = 32'hffff9367;
        img[63] = 32'hffff9367;
        img[64] = 32'hffff9367;
        img[65] = 32'hffff9367;
        img[66] = 32'hffff9367;
        img[67] = 32'hffff9367;
        img[68] = 32'hffff9367;
        img[69] = 32'hffff9367;
        img[70] = 32'hffff9367;
        img[71] = 32'hffff9367;
        img[72] = 32'hffff9367;
        img[73] = 32'hffff9367;
        img[74] = 32'hffff9367;
        img[75] = 32'hffff9367;
        img[76] = 32'hffff9367;
        img[77] = 32'hffff9367;
        img[78] = 32'hffff9367;
        img[79] = 32'hffff9367;
        img[80] = 32'hffff9367;
        img[81] = 32'hffff9367;
        img[82] = 32'hffff9367;
        img[83] = 32'hffff9367;
        img[84] = 32'hffff9367;
        img[85] = 32'hffff9367;
        img[86] = 32'hffff9367;
        img[87] = 32'hffff9367;
        img[88] = 32'hffff9367;
        img[89] = 32'hffff9367;
        img[90] = 32'hffff9367;
        img[91] = 32'hffff9367;
        img[92] = 32'hffff9367;
        img[93] = 32'hffff9367;
        img[94] = 32'hffff9367;
        img[95] = 32'hffff9367;
        img[96] = 32'hffff9367;
        img[97] = 32'hffff9367;
        img[98] = 32'hffff9367;
        img[99] = 32'hffff9367;
        img[100] = 32'hffff9367;
        img[101] = 32'hffff9367;
        img[102] = 32'hffff9367;
        img[103] = 32'hffff9367;
        img[104] = 32'hffff9367;
        img[105] = 32'hffff9367;
        img[106] = 32'hffff9367;
        img[107] = 32'hffff9367;
        img[108] = 32'hffff9367;
        img[109] = 32'hffff9367;
        img[110] = 32'hffff9367;
        img[111] = 32'hffff9367;
        img[112] = 32'hffff9367;
        img[113] = 32'hffff9367;
        img[114] = 32'hffff9367;
        img[115] = 32'hffff9367;
        img[116] = 32'hffff9367;
        img[117] = 32'hffff9367;
        img[118] = 32'hffff9367;
        img[119] = 32'hffff9367;
        img[120] = 32'hffff9367;
        img[121] = 32'hffff9367;
        img[122] = 32'hffff9367;
        img[123] = 32'hffff9367;
        img[124] = 32'hffff9367;
        img[125] = 32'hffff9367;
        img[126] = 32'hffff9367;
        img[127] = 32'hffff9367;
        img[128] = 32'hffff9367;
        img[129] = 32'hffff9367;
        img[130] = 32'hffff9367;
        img[131] = 32'hffff9367;
        img[132] = 32'hffff9367;
        img[133] = 32'hffff9367;
        img[134] = 32'hffff9367;
        img[135] = 32'hffff9367;
        img[136] = 32'hffff9367;
        img[137] = 32'hffff9367;
        img[138] = 32'hffff9367;
        img[139] = 32'hffff9367;
        img[140] = 32'hffff9367;
        img[141] = 32'hffff9367;
        img[142] = 32'hffff9367;
        img[143] = 32'hffff9367;
        img[144] = 32'hffff9367;
        img[145] = 32'hffff9367;
        img[146] = 32'hffff9367;
        img[147] = 32'hffff9367;
        img[148] = 32'hffff9367;
        img[149] = 32'hffff9367;
        img[150] = 32'hffff9367;
        img[151] = 32'hffff9367;
        img[152] = 32'hffff9367;
        img[153] = 32'hffff9367;
        img[154] = 32'hffff9367;
        img[155] = 32'hffff9367;
        img[156] = 32'hffff9367;
        img[157] = 32'hffff9367;
        img[158] = 32'hffff9367;
        img[159] = 32'hffff9367;
        img[160] = 32'hffff9367;
        img[161] = 32'hffff9367;
        img[162] = 32'hffff9367;
        img[163] = 32'hffff9367;
        img[164] = 32'hffff9367;
        img[165] = 32'hffff9367;
        img[166] = 32'hffff9367;
        img[167] = 32'hffff9367;
        img[168] = 32'hffff9367;
        img[169] = 32'hffff9367;
        img[170] = 32'hffff9367;
        img[171] = 32'hffff9367;
        img[172] = 32'hffff9367;
        img[173] = 32'hffff9367;
        img[174] = 32'hffff9367;
        img[175] = 32'hffff9367;
        img[176] = 32'hffff9367;
        img[177] = 32'hffff9367;
        img[178] = 32'hffff9367;
        img[179] = 32'hffff9367;
        img[180] = 32'hffff9367;
        img[181] = 32'hffff9367;
        img[182] = 32'hffff9367;
        img[183] = 32'hffff9367;
        img[184] = 32'hffff9367;
        img[185] = 32'hffff9367;
        img[186] = 32'hffff9367;
        img[187] = 32'hffff9367;
        img[188] = 32'hffff9367;
        img[189] = 32'hffff9367;
        img[190] = 32'hffff9367;
        img[191] = 32'hffff9367;
        img[192] = 32'hffff9367;
        img[193] = 32'hffff9367;
        img[194] = 32'hffff9367;
        img[195] = 32'hffff9367;
        img[196] = 32'hffff9367;
        img[197] = 32'hffff9367;
        img[198] = 32'hffff9367;
        img[199] = 32'hffff9367;
        img[200] = 32'hffff9367;
        img[201] = 32'hffff9367;
        img[202] = 32'h0000a51c;
        img[203] = 32'h0001ee36;
        img[204] = 32'h0001997e;
        img[205] = 32'h00017f6d;
        img[206] = 32'h000056e8;
        img[207] = 32'h000008b4;
        img[208] = 32'hffff9367;
        img[209] = 32'hffff9367;
        img[210] = 32'hffff9367;
        img[211] = 32'hffff9367;
        img[212] = 32'hffff9367;
        img[213] = 32'hffff9367;
        img[214] = 32'hffff9367;
        img[215] = 32'hffff9367;
        img[216] = 32'hffff9367;
        img[217] = 32'hffff9367;
        img[218] = 32'hffff9367;
        img[219] = 32'hffff9367;
        img[220] = 32'hffff9367;
        img[221] = 32'hffff9367;
        img[222] = 32'hffff9367;
        img[223] = 32'hffff9367;
        img[224] = 32'hffff9367;
        img[225] = 32'hffff9367;
        img[226] = 32'hffff9367;
        img[227] = 32'hffff9367;
        img[228] = 32'hffff9367;
        img[229] = 32'hffff9367;
        img[230] = 32'h000266c6;
        img[231] = 32'h0002cf0b;
        img[232] = 32'h0002cf0b;
        img[233] = 32'h0002cf0b;
        img[234] = 32'h0002cf0b;
        img[235] = 32'h0002a4af;
        img[236] = 32'h00021892;
        img[237] = 32'h00021892;
        img[238] = 32'h00021892;
        img[239] = 32'h00021892;
        img[240] = 32'h00021892;
        img[241] = 32'h00021892;
        img[242] = 32'h00021892;
        img[243] = 32'h00021892;
        img[244] = 32'h0001bd56;
        img[245] = 32'h00003cd7;
        img[246] = 32'hffff9367;
        img[247] = 32'hffff9367;
        img[248] = 32'hffff9367;
        img[249] = 32'hffff9367;
        img[250] = 32'hffff9367;
        img[251] = 32'hffff9367;
        img[252] = 32'hffff9367;
        img[253] = 32'hffff9367;
        img[254] = 32'hffff9367;
        img[255] = 32'hffff9367;
        img[256] = 32'hffff9367;
        img[257] = 32'hffff9367;
        img[258] = 32'h00006db7;
        img[259] = 32'h000106dd;
        img[260] = 32'h00007e02;
        img[261] = 32'h000106dd;
        img[262] = 32'h0001a686;
        img[263] = 32'h00027711;
        img[264] = 32'h0002cf0b;
        img[265] = 32'h0002708c;
        img[266] = 32'h0002cf0b;
        img[267] = 32'h0002cf0b;
        img[268] = 32'h0002cf0b;
        img[269] = 32'h0002c202;
        img[270] = 32'h00027d95;
        img[271] = 32'h0002cf0b;
        img[272] = 32'h0002cf0b;
        img[273] = 32'h00015b95;
        img[274] = 32'hffff9367;
        img[275] = 32'hffff9367;
        img[276] = 32'hffff9367;
        img[277] = 32'hffff9367;
        img[278] = 32'hffff9367;
        img[279] = 32'hffff9367;
        img[280] = 32'hffff9367;
        img[281] = 32'hffff9367;
        img[282] = 32'hffff9367;
        img[283] = 32'hffff9367;
        img[284] = 32'hffff9367;
        img[285] = 32'hffff9367;
        img[286] = 32'hffff9367;
        img[287] = 32'hffff9367;
        img[288] = 32'hffff9367;
        img[289] = 32'hffff9367;
        img[290] = 32'hffff9367;
        img[291] = 32'hffffcacb;
        img[292] = 32'h00006a75;
        img[293] = 32'hffffc105;
        img[294] = 32'h00006db7;
        img[295] = 32'h00006db7;
        img[296] = 32'h00006db7;
        img[297] = 32'h000053a6;
        img[298] = 32'hffffd7d4;
        img[299] = 32'h00029464;
        img[300] = 32'h0002cf0b;
        img[301] = 32'h0000eccb;
        img[302] = 32'hffff9367;
        img[303] = 32'hffff9367;
        img[304] = 32'hffff9367;
        img[305] = 32'hffff9367;
        img[306] = 32'hffff9367;
        img[307] = 32'hffff9367;
        img[308] = 32'hffff9367;
        img[309] = 32'hffff9367;
        img[310] = 32'hffff9367;
        img[311] = 32'hffff9367;
        img[312] = 32'hffff9367;
        img[313] = 32'hffff9367;
        img[314] = 32'hffff9367;
        img[315] = 32'hffff9367;
        img[316] = 32'hffff9367;
        img[317] = 32'hffff9367;
        img[318] = 32'hffff9367;
        img[319] = 32'hffff9367;
        img[320] = 32'hffff9367;
        img[321] = 32'hffff9367;
        img[322] = 32'hffff9367;
        img[323] = 32'hffff9367;
        img[324] = 32'hffff9367;
        img[325] = 32'hffff9367;
        img[326] = 32'h0000a1da;
        img[327] = 32'h0002cbc9;
        img[328] = 32'h00023c6a;
        img[329] = 32'hffffce0e;
        img[330] = 32'hffff9367;
        img[331] = 32'hffff9367;
        img[332] = 32'hffff9367;
        img[333] = 32'hffff9367;
        img[334] = 32'hffff9367;
        img[335] = 32'hffff9367;
        img[336] = 32'hffff9367;
        img[337] = 32'hffff9367;
        img[338] = 32'hffff9367;
        img[339] = 32'hffff9367;
        img[340] = 32'hffff9367;
        img[341] = 32'hffff9367;
        img[342] = 32'hffff9367;
        img[343] = 32'hffff9367;
        img[344] = 32'hffff9367;
        img[345] = 32'hffff9367;
        img[346] = 32'hffff9367;
        img[347] = 32'hffff9367;
        img[348] = 32'hffff9367;
        img[349] = 32'hffff9367;
        img[350] = 32'hffff9367;
        img[351] = 32'hffff9367;
        img[352] = 32'hffff9367;
        img[353] = 32'hffffdb16;
        img[354] = 32'h00028a9d;
        img[355] = 32'h0002d24d;
        img[356] = 32'h0000a1da;
        img[357] = 32'hffff9367;
        img[358] = 32'hffff9367;
        img[359] = 32'hffff9367;
        img[360] = 32'hffff9367;
        img[361] = 32'hffff9367;
        img[362] = 32'hffff9367;
        img[363] = 32'hffff9367;
        img[364] = 32'hffff9367;
        img[365] = 32'hffff9367;
        img[366] = 32'hffff9367;
        img[367] = 32'hffff9367;
        img[368] = 32'hffff9367;
        img[369] = 32'hffff9367;
        img[370] = 32'hffff9367;
        img[371] = 32'hffff9367;
        img[372] = 32'hffff9367;
        img[373] = 32'hffff9367;
        img[374] = 32'hffff9367;
        img[375] = 32'hffff9367;
        img[376] = 32'hffff9367;
        img[377] = 32'hffff9367;
        img[378] = 32'hffff9367;
        img[379] = 32'hffff9367;
        img[380] = 32'hffff9367;
        img[381] = 32'h000137bd;
        img[382] = 32'h0002cf0b;
        img[383] = 32'h00029ae8;
        img[384] = 32'h000022c6;
        img[385] = 32'hffff9367;
        img[386] = 32'hffff9367;
        img[387] = 32'hffff9367;
        img[388] = 32'hffff9367;
        img[389] = 32'hffff9367;
        img[390] = 32'hffff9367;
        img[391] = 32'hffff9367;
        img[392] = 32'hffff9367;
        img[393] = 32'hffff9367;
        img[394] = 32'hffff9367;
        img[395] = 32'hffff9367;
        img[396] = 32'hffff9367;
        img[397] = 32'hffff9367;
        img[398] = 32'hffff9367;
        img[399] = 32'hffff9367;
        img[400] = 32'hffff9367;
        img[401] = 32'hffff9367;
        img[402] = 32'hffff9367;
        img[403] = 32'hffff9367;
        img[404] = 32'hffff9367;
        img[405] = 32'hffff9367;
        img[406] = 32'hffff9367;
        img[407] = 32'hffff9367;
        img[408] = 32'h000053a6;
        img[409] = 32'h0002bec0;
        img[410] = 32'h0002cf0b;
        img[411] = 32'h00005d6d;
        img[412] = 32'hffff9367;
        img[413] = 32'hffff9367;
        img[414] = 32'hffff9367;
        img[415] = 32'hffff9367;
        img[416] = 32'hffff9367;
        img[417] = 32'hffff9367;
        img[418] = 32'hffff9367;
        img[419] = 32'hffff9367;
        img[420] = 32'hffff9367;
        img[421] = 32'hffff9367;
        img[422] = 32'hffff9367;
        img[423] = 32'hffff9367;
        img[424] = 32'hffff9367;
        img[425] = 32'hffff9367;
        img[426] = 32'hffff9367;
        img[427] = 32'hffff9367;
        img[428] = 32'hffff9367;
        img[429] = 32'hffff9367;
        img[430] = 32'hffff9367;
        img[431] = 32'hffff9367;
        img[432] = 32'hffff9367;
        img[433] = 32'hffff9367;
        img[434] = 32'hffff9367;
        img[435] = 32'hffff9367;
        img[436] = 32'h000144c6;
        img[437] = 32'h0002cf0b;
        img[438] = 32'h0001f4ba;
        img[439] = 32'hffffa3b2;
        img[440] = 32'hffff9367;
        img[441] = 32'hffff9367;
        img[442] = 32'hffff9367;
        img[443] = 32'hffff9367;
        img[444] = 32'hffff9367;
        img[445] = 32'hffff9367;
        img[446] = 32'hffff9367;
        img[447] = 32'hffff9367;
        img[448] = 32'hffff9367;
        img[449] = 32'hffff9367;
        img[450] = 32'hffff9367;
        img[451] = 32'hffff9367;
        img[452] = 32'hffff9367;
        img[453] = 32'hffff9367;
        img[454] = 32'hffff9367;
        img[455] = 32'hffff9367;
        img[456] = 32'hffff9367;
        img[457] = 32'hffff9367;
        img[458] = 32'hffff9367;
        img[459] = 32'hffff9367;
        img[460] = 32'hffff9367;
        img[461] = 32'hffff9367;
        img[462] = 32'hffff9367;
        img[463] = 32'hffffb0ba;
        img[464] = 32'h00022f61;
        img[465] = 32'h0002bb7e;
        img[466] = 32'h00005064;
        img[467] = 32'hffff9367;
        img[468] = 32'hffff9367;
        img[469] = 32'hffff9367;
        img[470] = 32'hffff9367;
        img[471] = 32'hffff9367;
        img[472] = 32'hffff9367;
        img[473] = 32'hffff9367;
        img[474] = 32'hffff9367;
        img[475] = 32'hffff9367;
        img[476] = 32'hffff9367;
        img[477] = 32'hffff9367;
        img[478] = 32'hffff9367;
        img[479] = 32'hffff9367;
        img[480] = 32'hffff9367;
        img[481] = 32'hffff9367;
        img[482] = 32'hffff9367;
        img[483] = 32'hffff9367;
        img[484] = 32'hffff9367;
        img[485] = 32'hffff9367;
        img[486] = 32'hffff9367;
        img[487] = 32'hffff9367;
        img[488] = 32'hffff9367;
        img[489] = 32'hffff9367;
        img[490] = 32'hffff9367;
        img[491] = 32'h00012df7;
        img[492] = 32'h0002cf0b;
        img[493] = 32'h0001e46f;
        img[494] = 32'hffff9367;
        img[495] = 32'hffff9367;
        img[496] = 32'hffff9367;
        img[497] = 32'hffff9367;
        img[498] = 32'hffff9367;
        img[499] = 32'hffff9367;
        img[500] = 32'hffff9367;
        img[501] = 32'hffff9367;
        img[502] = 32'hffff9367;
        img[503] = 32'hffff9367;
        img[504] = 32'hffff9367;
        img[505] = 32'hffff9367;
        img[506] = 32'hffff9367;
        img[507] = 32'hffff9367;
        img[508] = 32'hffff9367;
        img[509] = 32'hffff9367;
        img[510] = 32'hffff9367;
        img[511] = 32'hffff9367;
        img[512] = 32'hffff9367;
        img[513] = 32'hffff9367;
        img[514] = 32'hffff9367;
        img[515] = 32'hffff9367;
        img[516] = 32'hffff9367;
        img[517] = 32'hffff9367;
        img[518] = 32'h000087c9;
        img[519] = 32'h0002c544;
        img[520] = 32'h0002a16d;
        img[521] = 32'h00004d22;
        img[522] = 32'hffff9367;
        img[523] = 32'hffff9367;
        img[524] = 32'hffff9367;
        img[525] = 32'hffff9367;
        img[526] = 32'hffff9367;
        img[527] = 32'hffff9367;
        img[528] = 32'hffff9367;
        img[529] = 32'hffff9367;
        img[530] = 32'hffff9367;
        img[531] = 32'hffff9367;
        img[532] = 32'hffff9367;
        img[533] = 32'hffff9367;
        img[534] = 32'hffff9367;
        img[535] = 32'hffff9367;
        img[536] = 32'hffff9367;
        img[537] = 32'hffff9367;
        img[538] = 32'hffff9367;
        img[539] = 32'hffff9367;
        img[540] = 32'hffff9367;
        img[541] = 32'hffff9367;
        img[542] = 32'hffff9367;
        img[543] = 32'hffff9367;
        img[544] = 32'hffff9367;
        img[545] = 32'hffffd150;
        img[546] = 32'h00026384;
        img[547] = 32'h0002cf0b;
        img[548] = 32'h0001b04d;
        img[549] = 32'hffff9367;
        img[550] = 32'hffff9367;
        img[551] = 32'hffff9367;
        img[552] = 32'hffff9367;
        img[553] = 32'hffff9367;
        img[554] = 32'hffff9367;
        img[555] = 32'hffff9367;
        img[556] = 32'hffff9367;
        img[557] = 32'hffff9367;
        img[558] = 32'hffff9367;
        img[559] = 32'hffff9367;
        img[560] = 32'hffff9367;
        img[561] = 32'hffff9367;
        img[562] = 32'hffff9367;
        img[563] = 32'hffff9367;
        img[564] = 32'hffff9367;
        img[565] = 32'hffff9367;
        img[566] = 32'hffff9367;
        img[567] = 32'hffff9367;
        img[568] = 32'hffff9367;
        img[569] = 32'hffff9367;
        img[570] = 32'hffff9367;
        img[571] = 32'hffff9367;
        img[572] = 32'hffff9d2d;
        img[573] = 32'h000228dd;
        img[574] = 32'h0002cf0b;
        img[575] = 32'h00025cff;
        img[576] = 32'h00000572;
        img[577] = 32'hffff9367;
        img[578] = 32'hffff9367;
        img[579] = 32'hffff9367;
        img[580] = 32'hffff9367;
        img[581] = 32'hffff9367;
        img[582] = 32'hffff9367;
        img[583] = 32'hffff9367;
        img[584] = 32'hffff9367;
        img[585] = 32'hffff9367;
        img[586] = 32'hffff9367;
        img[587] = 32'hffff9367;
        img[588] = 32'hffff9367;
        img[589] = 32'hffff9367;
        img[590] = 32'hffff9367;
        img[591] = 32'hffff9367;
        img[592] = 32'hffff9367;
        img[593] = 32'hffff9367;
        img[594] = 32'hffff9367;
        img[595] = 32'hffff9367;
        img[596] = 32'hffff9367;
        img[597] = 32'hffff9367;
        img[598] = 32'hffff9367;
        img[599] = 32'hffff9367;
        img[600] = 32'h00000f39;
        img[601] = 32'h0002cf0b;
        img[602] = 32'h0002cf0b;
        img[603] = 32'h00008e4d;
        img[604] = 32'hffff9367;
        img[605] = 32'hffff9367;
        img[606] = 32'hffff9367;
        img[607] = 32'hffff9367;
        img[608] = 32'hffff9367;
        img[609] = 32'hffff9367;
        img[610] = 32'hffff9367;
        img[611] = 32'hffff9367;
        img[612] = 32'hffff9367;
        img[613] = 32'hffff9367;
        img[614] = 32'hffff9367;
        img[615] = 32'hffff9367;
        img[616] = 32'hffff9367;
        img[617] = 32'hffff9367;
        img[618] = 32'hffff9367;
        img[619] = 32'hffff9367;
        img[620] = 32'hffff9367;
        img[621] = 32'hffff9367;
        img[622] = 32'hffff9367;
        img[623] = 32'hffff9367;
        img[624] = 32'hffff9367;
        img[625] = 32'hffff9367;
        img[626] = 32'hffff9367;
        img[627] = 32'hfffff86a;
        img[628] = 32'h00026d4a;
        img[629] = 32'h0002cf0b;
        img[630] = 32'h00010a1f;
        img[631] = 32'hffff96a9;
        img[632] = 32'hffff9367;
        img[633] = 32'hffff9367;
        img[634] = 32'hffff9367;
        img[635] = 32'hffff9367;
        img[636] = 32'hffff9367;
        img[637] = 32'hffff9367;
        img[638] = 32'hffff9367;
        img[639] = 32'hffff9367;
        img[640] = 32'hffff9367;
        img[641] = 32'hffff9367;
        img[642] = 32'hffff9367;
        img[643] = 32'hffff9367;
        img[644] = 32'hffff9367;
        img[645] = 32'hffff9367;
        img[646] = 32'hffff9367;
        img[647] = 32'hffff9367;
        img[648] = 32'hffff9367;
        img[649] = 32'hffff9367;
        img[650] = 32'hffff9367;
        img[651] = 32'hffff9367;
        img[652] = 32'hffff9367;
        img[653] = 32'hffff9367;
        img[654] = 32'hffff9367;
        img[655] = 32'h000144c6;
        img[656] = 32'h0002cf0b;
        img[657] = 32'h0002cf0b;
        img[658] = 32'h00003cd7;
        img[659] = 32'hffff9367;
        img[660] = 32'hffff9367;
        img[661] = 32'hffff9367;
        img[662] = 32'hffff9367;
        img[663] = 32'hffff9367;
        img[664] = 32'hffff9367;
        img[665] = 32'hffff9367;
        img[666] = 32'hffff9367;
        img[667] = 32'hffff9367;
        img[668] = 32'hffff9367;
        img[669] = 32'hffff9367;
        img[670] = 32'hffff9367;
        img[671] = 32'hffff9367;
        img[672] = 32'hffff9367;
        img[673] = 32'hffff9367;
        img[674] = 32'hffff9367;
        img[675] = 32'hffff9367;
        img[676] = 32'hffff9367;
        img[677] = 32'hffff9367;
        img[678] = 32'hffff9367;
        img[679] = 32'hffff9367;
        img[680] = 32'hffff9367;
        img[681] = 32'hffff9367;
        img[682] = 32'h00005a2a;
        img[683] = 32'h0002a7f1;
        img[684] = 32'h0002cf0b;
        img[685] = 32'h0002cf0b;
        img[686] = 32'h00003cd7;
        img[687] = 32'hffff9367;
        img[688] = 32'hffff9367;
        img[689] = 32'hffff9367;
        img[690] = 32'hffff9367;
        img[691] = 32'hffff9367;
        img[692] = 32'hffff9367;
        img[693] = 32'hffff9367;
        img[694] = 32'hffff9367;
        img[695] = 32'hffff9367;
        img[696] = 32'hffff9367;
        img[697] = 32'hffff9367;
        img[698] = 32'hffff9367;
        img[699] = 32'hffff9367;
        img[700] = 32'hffff9367;
        img[701] = 32'hffff9367;
        img[702] = 32'hffff9367;
        img[703] = 32'hffff9367;
        img[704] = 32'hffff9367;
        img[705] = 32'hffff9367;
        img[706] = 32'hffff9367;
        img[707] = 32'hffff9367;
        img[708] = 32'hffff9367;
        img[709] = 32'hffff9367;
        img[710] = 32'h00011dac;
        img[711] = 32'h0002cf0b;
        img[712] = 32'h0002cf0b;
        img[713] = 32'h00025cff;
        img[714] = 32'h000015bd;
        img[715] = 32'hffff9367;
        img[716] = 32'hffff9367;
        img[717] = 32'hffff9367;
        img[718] = 32'hffff9367;
        img[719] = 32'hffff9367;
        img[720] = 32'hffff9367;
        img[721] = 32'hffff9367;
        img[722] = 32'hffff9367;
        img[723] = 32'hffff9367;
        img[724] = 32'hffff9367;
        img[725] = 32'hffff9367;
        img[726] = 32'hffff9367;
        img[727] = 32'hffff9367;
        img[728] = 32'hffff9367;
        img[729] = 32'hffff9367;
        img[730] = 32'hffff9367;
        img[731] = 32'hffff9367;
        img[732] = 32'hffff9367;
        img[733] = 32'hffff9367;
        img[734] = 32'hffff9367;
        img[735] = 32'hffff9367;
        img[736] = 32'hffff9367;
        img[737] = 32'hffff9367;
        img[738] = 32'h00011dac;
        img[739] = 32'h0002cf0b;
        img[740] = 32'h000235e5;
        img[741] = 32'hffffce0e;
        img[742] = 32'hffff9367;
        img[743] = 32'hffff9367;
        img[744] = 32'hffff9367;
        img[745] = 32'hffff9367;
        img[746] = 32'hffff9367;
        img[747] = 32'hffff9367;
        img[748] = 32'hffff9367;
        img[749] = 32'hffff9367;
        img[750] = 32'hffff9367;
        img[751] = 32'hffff9367;
        img[752] = 32'hffff9367;
        img[753] = 32'hffff9367;
        img[754] = 32'hffff9367;
        img[755] = 32'hffff9367;
        img[756] = 32'hffff9367;
        img[757] = 32'hffff9367;
        img[758] = 32'hffff9367;
        img[759] = 32'hffff9367;
        img[760] = 32'hffff9367;
        img[761] = 32'hffff9367;
        img[762] = 32'hffff9367;
        img[763] = 32'hffff9367;
        img[764] = 32'hffff9367;
        img[765] = 32'hffff9367;
        img[766] = 32'hffff9367;
        img[767] = 32'hffff9367;
        img[768] = 32'hffff9367;
        img[769] = 32'hffff9367;
        img[770] = 32'hffff9367;
        img[771] = 32'hffff9367;
        img[772] = 32'hffff9367;
        img[773] = 32'hffff9367;
        img[774] = 32'hffff9367;
        img[775] = 32'hffff9367;
        img[776] = 32'hffff9367;
        img[777] = 32'hffff9367;
        img[778] = 32'hffff9367;
        img[779] = 32'hffff9367;
        img[780] = 32'hffff9367;
        img[781] = 32'hffff9367;
        img[782] = 32'hffff9367;
        img[783] = 32'hffff9367;

        // Assign conv kernels (Q16.16) to kernels[] (hex, two's complement)
        kernels[0] = 32'h000074df;
        kernels[1] = 32'h00006381;
        kernels[2] = 32'h00006efc;
        kernels[3] = 32'h000051ae;
        kernels[4] = 32'hffffffae;
        kernels[5] = 32'h000015b4;
        kernels[6] = 32'hffff16f7;
        kernels[7] = 32'hffff8c6c;
        kernels[8] = 32'h00001035;
        kernels[9] = 32'h00007661;
        kernels[10] = 32'hffffd48e;
        kernels[11] = 32'hffff11e0;
        kernels[12] = 32'h00008fa6;
        kernels[13] = 32'h00001dde;
        kernels[14] = 32'hffff56ad;
        kernels[15] = 32'h00003706;
        kernels[16] = 32'h00008ff4;
        kernels[17] = 32'hffffeba3;
        kernels[18] = 32'hffffc875;
        kernels[19] = 32'h00002329;
        kernels[20] = 32'h000025c7;
        kernels[21] = 32'hffff4d00;
        kernels[22] = 32'hffffd6ac;
        kernels[23] = 32'h0000ab19;
        kernels[24] = 32'hffff63c0;
        kernels[25] = 32'hffff93cc;
        kernels[26] = 32'h0000a7a1;
        kernels[27] = 32'hffff493a;
        kernels[28] = 32'hffff2936;
        kernels[29] = 32'hffff23ff;
        kernels[30] = 32'h0000944e;
        kernels[31] = 32'h00004dd3;
        kernels[32] = 32'hffff9a11;
        kernels[33] = 32'h00001f3d;
        kernels[34] = 32'h00008c81;
        kernels[35] = 32'h000060b2;
    end

    // Outputs
    wire        complete;
    wire signed [31:0] neuron_out [0:9];
    wire signed [31:0] y;

    // Latch all 10 neuron outputs when complete to keep HEX/LEDs stable
    logic signed [31:0] neuron_latched [0:9];
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 10; i++) neuron_latched[i] <= 32'sd0;
        end else if (complete) begin
            for (int i = 0; i < 10; i++) neuron_latched[i] <= neuron_out[i];
        end
    end

    // Mini control FSM to simulate reset/enable and delay the display by ~1 second
    typedef enum logic [2:0] {C_IDLE, C_HOLD_RESET, C_RELEASE_RESET, C_RUN, C_WAIT_COMPLETE, C_DELAY, C_SHOW} cst_t;
    cst_t cst;
    logic        dut_rst_n;
    logic        dut_enable;
    logic        display_en;
    logic [15:0] hold_ctr;                 // small hold counter for reset
    logic [25:0] delay_ctr;                // 26 bits enough for 50M cycles
    localparam logic [15:0] RESET_HOLD   = 16'd1024;         // ~20us at 50MHz
    localparam logic [25:0] DELAY_CYCLES = 26'd10_000_000;   // ~1s at 10MHz

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cst        <= C_IDLE;
            dut_rst_n  <= 1'b1;
            dut_enable <= 1'b0;
            display_en <= 1'b0;
            hold_ctr   <= 16'd0;
            delay_ctr  <= 26'd0;
        end else begin
            unique case (cst)
                C_IDLE: begin
                    dut_rst_n  <= 1'b1;
                    dut_enable <= 1'b0;
                    display_en <= 1'b0;
                    hold_ctr   <= 16'd0;
                    delay_ctr  <= 26'd0;
                    if (start_pulse) cst <= C_HOLD_RESET;
                end
                C_HOLD_RESET: begin
                    dut_rst_n <= 1'b0;   // assert reset to DUT for a few cycles
                    if (hold_ctr == RESET_HOLD) begin
                        hold_ctr <= 16'd0;
                        cst      <= C_RELEASE_RESET;
                    end else begin
                        hold_ctr <= hold_ctr + 16'd1;
                    end
                end
                C_RELEASE_RESET: begin
                    dut_rst_n  <= 1'b1;  // release reset
                    dut_enable <= 1'b0;  // keep disable for one cycle
                    cst        <= C_RUN;
                end
                C_RUN: begin
                    dut_enable <= 1'b1;  // run inference
                    if (complete) cst <= C_WAIT_COMPLETE;
                end
                C_WAIT_COMPLETE: begin
                    // one-cycle stable complete, then start delay counter
                    delay_ctr  <= 26'd0;
                    cst        <= C_DELAY;
                end
                C_DELAY: begin
                    if (delay_ctr == DELAY_CYCLES) begin
                        display_en <= 1'b1;
                        cst        <= C_SHOW;
                    end else begin
                        delay_ctr <= delay_ctr + 26'd1;
                    end
                end
                default: begin // C_SHOW
                    // Stay showing until next start pulse
                    if (start_pulse) begin
                        display_en <= 1'b0;
                        cst        <= C_HOLD_RESET;
                        hold_ctr   <= 16'd0;
                    end
                end
            endcase
        end
    end

    inference #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH (IMG_WIDTH),
        .NO_KERNELS(NO_KERNELS),
        .KERNEL_SIZE(KERNEL_SIZE),
        .MAXPOOL_KERNEL(MAXPOOL_KERNEL),
        .NO_NEURONS(10)
    ) dut (
        .clk(clk),
        .rst_n(dut_rst_n),
        .enable(dut_enable),
        .img(img),
        .kernels(kernels),
        .complete(complete),
        .neuron_out(neuron_out),
        .y(y)
    );

    // SW[5:2] selects which neuron (0-9) to display on HEX; values > 9 wrap to 0
    wire [3:0] nsel = SW[5:2];
    wire signed [31:0] sel_neuron = (nsel < 4'd10) ? neuron_latched[nsel] : neuron_latched[0];

    // Drive LEDs with lower 10 bits of selected neuron after delay; else blank
    assign LEDR = display_en ? sel_neuron[9:0] : 10'b0;

    // 7-seg hex display (active-low on DE1-SoC)
    function automatic [6:0] hex7(input logic [3:0] nib);
        case (nib)
            4'h0: hex7 = 7'b1000000;
            4'h1: hex7 = 7'b1111001;
            4'h2: hex7 = 7'b0100100;
            4'h3: hex7 = 7'b0110000;
            4'h4: hex7 = 7'b0011001;
            4'h5: hex7 = 7'b0010010;
            4'h6: hex7 = 7'b0000010;
            4'h7: hex7 = 7'b1111000;
            4'h8: hex7 = 7'b0000000;
            4'h9: hex7 = 7'b0010000;
            4'hA: hex7 = 7'b0001000;
            4'hB: hex7 = 7'b0000011;
            4'hC: hex7 = 7'b1000110;
            4'hD: hex7 = 7'b0100001;
            4'hE: hex7 = 7'b0000110;
            4'hF: hex7 = 7'b0001110;
            default: hex7 = 7'b1111111;
        endcase
    endfunction

    // HEX5..HEX0 show the selected neuron's 32-bit value (hex nibbles)
    assign HEX0 = display_en ? hex7(sel_neuron[3:0])   : 7'b1111111;
    assign HEX1 = display_en ? hex7(sel_neuron[7:4])   : 7'b1111111;
    assign HEX2 = display_en ? hex7(sel_neuron[11:8])  : 7'b1111111;
    assign HEX3 = display_en ? hex7(sel_neuron[15:12]) : 7'b1111111;
    assign HEX4 = display_en ? hex7(sel_neuron[19:16]) : 7'b1111111;
    assign HEX5 = display_en ? hex7(sel_neuron[23:20]) : 7'b1111111;

endmodule
