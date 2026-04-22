// -----------------------------------------------------------------------------
// Module      : pixel_mux
// Description : VGA output driver. Forces RGB to 0 during blanking; otherwise
//               routes the 12-bit BRAM pixel to the three 4-bit VGA channels.
//               Internally uses three mux2 instances (one per channel) so that
//               the generic multiplexer is the single source of select logic.
// Author      : JustinAlfaro
// Date        : 2026-04-22
// Ports:
//   blank      - Blanking signal (active-high = outside visible area)
//   pixel_data - 12-bit pixel from BRAM {R[3:0], G[3:0], B[3:0]}
//   vga_r      - VGA Red   output [3:0]
//   vga_g      - VGA Green output [3:0]
//   vga_b      - VGA Blue  output [3:0]
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module pixel_mux (
    input  wire        blank,
    input  wire [11:0] pixel_data,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);
    // sel=0 (blank) → 4'h0 ; sel=1 (visible) → channel data
    mux2 #(.WIDTH(4)) u_r (.d0(4'h0), .d1(pixel_data[11:8]), .sel(~blank), .y(vga_r));
    mux2 #(.WIDTH(4)) u_g (.d0(4'h0), .d1(pixel_data[7:4]),  .sel(~blank), .y(vga_g));
    mux2 #(.WIDTH(4)) u_b (.d0(4'h0), .d1(pixel_data[3:0]),  .sel(~blank), .y(vga_b));
endmodule
