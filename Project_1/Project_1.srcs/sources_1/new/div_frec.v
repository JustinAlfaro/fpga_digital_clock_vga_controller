// -----------------------------------------------------------------------------
// Module      : div_freq
// Description : Generic frequency divider. Generates an output clock pulse
//               (one CLK100MHZ cycle wide) every DIVISOR input cycles.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   clk_in  - Input clock
//   rst     - Synchronous active-high reset
//   clk_out - Output pulse (1 cycle wide) at clk_in / DIVISOR
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module div_freq #(
    parameter integer DIVISOR = 100_000_000  // Default: 100 MHz -> 1 Hz
)(
    input  wire clk_in,
    input  wire rst,
    output reg  clk_out
);

    localparam integer COUNT_MAX = DIVISOR - 1;

    integer count;

    always @(posedge clk_in) begin
        if (rst) begin
            count   <= 0;
            clk_out <= 1'b0;
        end else begin
            if (count == COUNT_MAX) begin
                count   <= 0;
                clk_out <= 1'b1;
            end else begin
                count   <= count + 1;
                clk_out <= 1'b0;
            end
        end
    end

endmodule
