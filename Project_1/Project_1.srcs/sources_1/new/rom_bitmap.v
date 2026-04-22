// -----------------------------------------------------------------------------
// Module      : rom_bitmap
// Description : Synchronous ROM storing 8x16 pixel bitmaps for characters
//               '0'–'9' (indices 0–9) and ':' (index 10). Total: 11×16 = 176
//               entries of 8 bits each. Row 0 is the topmost pixel row.
//               Vivado infers this as distributed RAM or BRAM (small enough
//               for LUTRAM). Each bit = 1 means foreground (text) pixel.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   clk       - Clock (read is registered for BRAM compatibility)
//   char_idx  - Character index [3:0]: 0–9 = digit, 10 = ':'
//   row       - Bitmap row [3:0]: 0 (top) to 15 (bottom)
//   bitmap    - 8-bit row bitmap [7:0]: bit7=leftmost pixel
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module rom_bitmap (
    input  wire        clk,
    input  wire [3:0]  char_idx,
    input  wire [3:0]  row,
    output reg  [7:0]  bitmap
);

    // ROM: 176 entries, addressed by {char_idx[3:0], row[3:0]}
    reg [7:0] font_rom [0:175];

    // Populate on simulation/synthesis initialisation
    initial begin
        // ---- '0' (index 0) rows 0-15 ----------------------------------------
        font_rom[  0] = 8'h3C; // 0011 1100
        font_rom[  1] = 8'h66; // 0110 0110
        font_rom[  2] = 8'h66; // 0110 0110
        font_rom[  3] = 8'h6E; // 0110 1110
        font_rom[  4] = 8'h76; // 0111 0110
        font_rom[  5] = 8'h66; // 0110 0110
        font_rom[  6] = 8'h66; // 0110 0110
        font_rom[  7] = 8'h66; // 0110 0110
        font_rom[  8] = 8'h66; // 0110 0110
        font_rom[  9] = 8'h66; // 0110 0110
        font_rom[ 10] = 8'h66; // 0110 0110
        font_rom[ 11] = 8'h66; // 0110 0110
        font_rom[ 12] = 8'h66; // 0110 0110
        font_rom[ 13] = 8'h66; // 0110 0110
        font_rom[ 14] = 8'h66; // 0110 0110
        font_rom[ 15] = 8'h3C; // 0011 1100

        // ---- '1' (index 1) rows 0-15 ----------------------------------------
        font_rom[ 16] = 8'h18; // 0001 1000
        font_rom[ 17] = 8'h38; // 0011 1000
        font_rom[ 18] = 8'h78; // 0111 1000
        font_rom[ 19] = 8'h18; // 0001 1000
        font_rom[ 20] = 8'h18; // 0001 1000
        font_rom[ 21] = 8'h18; // 0001 1000
        font_rom[ 22] = 8'h18; // 0001 1000
        font_rom[ 23] = 8'h18; // 0001 1000
        font_rom[ 24] = 8'h18; // 0001 1000
        font_rom[ 25] = 8'h18; // 0001 1000
        font_rom[ 26] = 8'h18; // 0001 1000
        font_rom[ 27] = 8'h18; // 0001 1000
        font_rom[ 28] = 8'h18; // 0001 1000
        font_rom[ 29] = 8'h18; // 0001 1000
        font_rom[ 30] = 8'h18; // 0001 1000
        font_rom[ 31] = 8'h7E; // 0111 1110

        // ---- '2' (index 2) rows 0-15 ----------------------------------------
        font_rom[ 32] = 8'h3C; // 0011 1100
        font_rom[ 33] = 8'h66; // 0110 0110
        font_rom[ 34] = 8'h66; // 0110 0110
        font_rom[ 35] = 8'h06; // 0000 0110
        font_rom[ 36] = 8'h06; // 0000 0110
        font_rom[ 37] = 8'h0C; // 0000 1100
        font_rom[ 38] = 8'h18; // 0001 1000
        font_rom[ 39] = 8'h30; // 0011 0000
        font_rom[ 40] = 8'h60; // 0110 0000
        font_rom[ 41] = 8'h60; // 0110 0000
        font_rom[ 42] = 8'h60; // 0110 0000
        font_rom[ 43] = 8'h60; // 0110 0000
        font_rom[ 44] = 8'h62; // 0110 0010
        font_rom[ 45] = 8'h66; // 0110 0110
        font_rom[ 46] = 8'h66; // 0110 0110
        font_rom[ 47] = 8'h7E; // 0111 1110

        // ---- '3' (index 3) rows 0-15 ----------------------------------------
        font_rom[ 48] = 8'h3C; // 0011 1100
        font_rom[ 49] = 8'h66; // 0110 0110
        font_rom[ 50] = 8'h66; // 0110 0110
        font_rom[ 51] = 8'h06; // 0000 0110
        font_rom[ 52] = 8'h06; // 0000 0110
        font_rom[ 53] = 8'h1C; // 0001 1100
        font_rom[ 54] = 8'h06; // 0000 0110
        font_rom[ 55] = 8'h06; // 0000 0110
        font_rom[ 56] = 8'h06; // 0000 0110
        font_rom[ 57] = 8'h06; // 0000 0110
        font_rom[ 58] = 8'h06; // 0000 0110
        font_rom[ 59] = 8'h06; // 0000 0110
        font_rom[ 60] = 8'h66; // 0110 0110
        font_rom[ 61] = 8'h66; // 0110 0110
        font_rom[ 62] = 8'h66; // 0110 0110
        font_rom[ 63] = 8'h3C; // 0011 1100

        // ---- '4' (index 4) rows 0-15 ----------------------------------------
        font_rom[ 64] = 8'h06; // 0000 0110
        font_rom[ 65] = 8'h0E; // 0000 1110
        font_rom[ 66] = 8'h1E; // 0001 1110
        font_rom[ 67] = 8'h36; // 0011 0110
        font_rom[ 68] = 8'h66; // 0110 0110
        font_rom[ 69] = 8'h66; // 0110 0110
        font_rom[ 70] = 8'h66; // 0110 0110
        font_rom[ 71] = 8'h7F; // 0111 1111
        font_rom[ 72] = 8'h06; // 0000 0110
        font_rom[ 73] = 8'h06; // 0000 0110
        font_rom[ 74] = 8'h06; // 0000 0110
        font_rom[ 75] = 8'h06; // 0000 0110
        font_rom[ 76] = 8'h06; // 0000 0110
        font_rom[ 77] = 8'h06; // 0000 0110
        font_rom[ 78] = 8'h06; // 0000 0110
        font_rom[ 79] = 8'h06; // 0000 0110

        // ---- '5' (index 5) rows 0-15 ----------------------------------------
        font_rom[ 80] = 8'h7E; // 0111 1110
        font_rom[ 81] = 8'h60; // 0110 0000
        font_rom[ 82] = 8'h60; // 0110 0000
        font_rom[ 83] = 8'h60; // 0110 0000
        font_rom[ 84] = 8'h60; // 0110 0000
        font_rom[ 85] = 8'h7C; // 0111 1100
        font_rom[ 86] = 8'h66; // 0110 0110
        font_rom[ 87] = 8'h06; // 0000 0110
        font_rom[ 88] = 8'h06; // 0000 0110
        font_rom[ 89] = 8'h06; // 0000 0110
        font_rom[ 90] = 8'h06; // 0000 0110
        font_rom[ 91] = 8'h06; // 0000 0110
        font_rom[ 92] = 8'h06; // 0000 0110
        font_rom[ 93] = 8'h66; // 0110 0110
        font_rom[ 94] = 8'h66; // 0110 0110
        font_rom[ 95] = 8'h3C; // 0011 1100

        // ---- '6' (index 6) rows 0-15 ----------------------------------------
        font_rom[ 96] = 8'h1C; // 0001 1100
        font_rom[ 97] = 8'h30; // 0011 0000
        font_rom[ 98] = 8'h60; // 0110 0000
        font_rom[ 99] = 8'h60; // 0110 0000
        font_rom[100] = 8'h60; // 0110 0000
        font_rom[101] = 8'h7C; // 0111 1100
        font_rom[102] = 8'h66; // 0110 0110
        font_rom[103] = 8'h66; // 0110 0110
        font_rom[104] = 8'h66; // 0110 0110
        font_rom[105] = 8'h66; // 0110 0110
        font_rom[106] = 8'h66; // 0110 0110
        font_rom[107] = 8'h66; // 0110 0110
        font_rom[108] = 8'h66; // 0110 0110
        font_rom[109] = 8'h66; // 0110 0110
        font_rom[110] = 8'h66; // 0110 0110
        font_rom[111] = 8'h3C; // 0011 1100

        // ---- '7' (index 7) rows 0-15 ----------------------------------------
        font_rom[112] = 8'h7E; // 0111 1110
        font_rom[113] = 8'h66; // 0110 0110
        font_rom[114] = 8'h06; // 0000 0110
        font_rom[115] = 8'h06; // 0000 0110
        font_rom[116] = 8'h0C; // 0000 1100
        font_rom[117] = 8'h0C; // 0000 1100
        font_rom[118] = 8'h18; // 0001 1000
        font_rom[119] = 8'h18; // 0001 1000
        font_rom[120] = 8'h18; // 0001 1000
        font_rom[121] = 8'h18; // 0001 1000
        font_rom[122] = 8'h18; // 0001 1000
        font_rom[123] = 8'h18; // 0001 1000
        font_rom[124] = 8'h18; // 0001 1000
        font_rom[125] = 8'h18; // 0001 1000
        font_rom[126] = 8'h18; // 0001 1000
        font_rom[127] = 8'h18; // 0001 1000

        // ---- '8' (index 8) rows 0-15 ----------------------------------------
        font_rom[128] = 8'h3C; // 0011 1100
        font_rom[129] = 8'h66; // 0110 0110
        font_rom[130] = 8'h66; // 0110 0110
        font_rom[131] = 8'h66; // 0110 0110
        font_rom[132] = 8'h66; // 0110 0110
        font_rom[133] = 8'h3C; // 0011 1100
        font_rom[134] = 8'h66; // 0110 0110
        font_rom[135] = 8'h66; // 0110 0110
        font_rom[136] = 8'h66; // 0110 0110
        font_rom[137] = 8'h66; // 0110 0110
        font_rom[138] = 8'h66; // 0110 0110
        font_rom[139] = 8'h66; // 0110 0110
        font_rom[140] = 8'h66; // 0110 0110
        font_rom[141] = 8'h66; // 0110 0110
        font_rom[142] = 8'h66; // 0110 0110
        font_rom[143] = 8'h3C; // 0011 1100

        // ---- '9' (index 9) rows 0-15 ----------------------------------------
        font_rom[144] = 8'h3C; // 0011 1100
        font_rom[145] = 8'h66; // 0110 0110
        font_rom[146] = 8'h66; // 0110 0110
        font_rom[147] = 8'h66; // 0110 0110
        font_rom[148] = 8'h66; // 0110 0110
        font_rom[149] = 8'h66; // 0110 0110
        font_rom[150] = 8'h66; // 0110 0110
        font_rom[151] = 8'h3E; // 0011 1110
        font_rom[152] = 8'h06; // 0000 0110
        font_rom[153] = 8'h06; // 0000 0110
        font_rom[154] = 8'h06; // 0000 0110
        font_rom[155] = 8'h06; // 0000 0110
        font_rom[156] = 8'h06; // 0000 0110
        font_rom[157] = 8'h0C; // 0000 1100
        font_rom[158] = 8'h38; // 0011 1000
        font_rom[159] = 8'h70; // 0111 0000

        // ---- ':' (index 10) rows 0-15 ----------------------------------------
        font_rom[160] = 8'h00;
        font_rom[161] = 8'h00;
        font_rom[162] = 8'h00;
        font_rom[163] = 8'h00;
        font_rom[164] = 8'h18; // 0001 1000 (upper dot)
        font_rom[165] = 8'h18; // 0001 1000
        font_rom[166] = 8'h00;
        font_rom[167] = 8'h00;
        font_rom[168] = 8'h00;
        font_rom[169] = 8'h00;
        font_rom[170] = 8'h18; // 0001 1000 (lower dot)
        font_rom[171] = 8'h18; // 0001 1000
        font_rom[172] = 8'h00;
        font_rom[173] = 8'h00;
        font_rom[174] = 8'h00;
        font_rom[175] = 8'h00;
    end

    // Synchronous read: address = char_idx * 16 + row
    always @(posedge clk) begin
        bitmap <= font_rom[{char_idx, row}];  // {4-bit char, 4-bit row} = 8-bit addr
    end

endmodule
