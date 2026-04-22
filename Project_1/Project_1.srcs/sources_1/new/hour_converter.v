// -----------------------------------------------------------------------------
// Module      : hour_converter
// Description : Converts a 24-hour binary counter value (0-23) to 12-hour
//               BCD digits and an AM/PM flag. Fully combinational.
//               Mapping: 0→12 AM, 1-11→1-11 AM, 12→12 PM, 13-23→1-11 PM.
// Author      : JustinAlfaro
// Date        : 2026-04-22
// Ports:
//   hours_24  - 24-hour binary input [5:0] (0-23)
//   h12_tens  - 12-hour tens BCD digit [3:0] (0 or 1)
//   h12_ones  - 12-hour ones BCD digit [3:0] (0-9)
//   is_pm     - High when PM (hours_24 >= 12)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module hour_converter (
    input  wire [5:0] hours_24,
    output wire [3:0] h12_tens,
    output wire [3:0] h12_ones,
    output wire       is_pm
);
    assign is_pm = (hours_24 >= 6'd12);

    // Map to 12h range (1-12): midnight/noon both become 12
    wire [5:0] h12 = (hours_24 == 6'd0 || hours_24 == 6'd12) ? 6'd12 :
                     (hours_24 > 6'd12)                       ? (hours_24 - 6'd12) :
                                                                 hours_24;

    assign h12_tens = (h12 >= 6'd10) ? 4'd1 : 4'd0;
    assign h12_ones = (h12 >= 6'd10) ? (h12[3:0] - 4'd10) : h12[3:0];
endmodule
