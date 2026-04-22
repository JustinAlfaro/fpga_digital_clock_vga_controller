// -----------------------------------------------------------------------------
// Module      : bcd_ascii_decoder
// Description : Converts a single BCD digit (0-9) to its 7-bit ASCII code.
//               Input 4'hA is treated as ':' (0x3A). Combinational logic only.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   bcd_in   - BCD digit input [3:0] (0-9 or 4'hA for ':')
//   ascii_out - ASCII output [6:0]
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module bcd_ascii_decoder (
    input  wire [3:0] bcd_in,
    output reg  [6:0] ascii_out
);

    always @(*) begin
        case (bcd_in)
            4'd0:    ascii_out = 7'h30; // '0'
            4'd1:    ascii_out = 7'h31; // '1'
            4'd2:    ascii_out = 7'h32; // '2'
            4'd3:    ascii_out = 7'h33; // '3'
            4'd4:    ascii_out = 7'h34; // '4'
            4'd5:    ascii_out = 7'h35; // '5'
            4'd6:    ascii_out = 7'h36; // '6'
            4'd7:    ascii_out = 7'h37; // '7'
            4'd8:    ascii_out = 7'h38; // '8'
            4'd9:    ascii_out = 7'h39; // '9'
            4'hA:    ascii_out = 7'h3A; // ':'
            default: ascii_out = 7'h3F; // '?' for undefined
        endcase
    end

endmodule
