// -----------------------------------------------------------------------------
// Module      : sync_signal
// Description : 2-stage synchronizer for asynchronous inputs (e.g. SW[15:0]).
//               Prevents metastability when crossing clock domains.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// Parameters:
//   WIDTH - Number of bits to synchronize (default 16 for SW[15:0])
// -----------------------------------------------------------------------------
// Ports:
//   clk      - Destination clock domain
//   rst      - Synchronous active-high reset
//   async_in - Asynchronous input bus
//   sync_out - Synchronized output bus
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module sync_signal #(
    parameter integer WIDTH = 16
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] async_in,
    output wire [WIDTH-1:0] sync_out
);

    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] stage1;
    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] stage2;

    always @(posedge clk) begin
        if (rst) begin
            stage1 <= {WIDTH{1'b0}};
            stage2 <= {WIDTH{1'b0}};
        end else begin
            stage1 <= async_in;
            stage2 <= stage1;
        end
    end

    assign sync_out = stage2;

endmodule
