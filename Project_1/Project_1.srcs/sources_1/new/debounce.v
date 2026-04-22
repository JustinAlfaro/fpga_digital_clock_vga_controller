// -----------------------------------------------------------------------------
// Module      : debounce
// Description : Button debouncer using a saturation counter. Output goes high
//               for exactly one clock cycle when a stable rising edge is
//               detected (button held stable HIGH for DEBOUNCE_MS).
// Author      : JustinAlfaro
// Date        : 2026-04-22
// Parameters:
//   DEBOUNCE_MS  - Debounce window in milliseconds (default 20 ms)
//   CLK_FREQ_HZ  - Input clock frequency in Hz (default 100 MHz)
// Ports:
//   clk        - System clock
//   rst        - Synchronous active-high reset
//   btn_in     - Raw (bouncy) button input
//   btn_out    - Debounced single-cycle pulse on confirmed rising edge
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module debounce #(
    parameter integer DEBOUNCE_MS  = 20,
    parameter integer CLK_FREQ_HZ  = 100_000_000
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_out
);
    localparam integer COUNT_MAX = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS - 1;
    localparam integer CNT_BITS  = $clog2(COUNT_MAX + 1);

    // Two-stage synchronizer
    reg [1:0] sync_ff;
    wire      btn_sync = sync_ff[1];

    always @(posedge clk) begin
        if (rst) sync_ff <= 2'b00;
        else     sync_ff <= {sync_ff[0], btn_in};
    end

    reg [CNT_BITS-1:0] count;
    reg                btn_prev;

    always @(posedge clk) begin
        if (rst) begin
            count    <= 0;
            btn_prev <= 1'b0;
            btn_out  <= 1'b0;
        end else begin
            btn_out <= 1'b0;
            if (btn_sync != btn_prev) begin
                count    <= 0;
                btn_prev <= btn_sync;
            end else if (count < COUNT_MAX[CNT_BITS-1:0]) begin
                count <= count + 1'b1;
                // Fire on the last increment cycle while input is stable high
                if (count == COUNT_MAX[CNT_BITS-1:0] - 1'b1 && btn_sync)
                    btn_out <= 1'b1;
            end
        end
    end

endmodule
