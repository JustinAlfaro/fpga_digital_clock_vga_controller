// -----------------------------------------------------------------------------
// Module      : mux2
// Description : Generic parametric 2-to-1 multiplexer. Combinational, zero
//               latency. WIDTH=1 gives a single-bit mux; any width supported.
// Author      : JustinAlfaro
// Date        : 2026-04-22
// Parameters:
//   WIDTH - Data path width in bits (default 1)
// Ports:
//   d0  - Input selected when sel=0
//   d1  - Input selected when sel=1
//   sel - Select signal
//   y   - Output
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module mux2 #(parameter integer WIDTH = 1) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
