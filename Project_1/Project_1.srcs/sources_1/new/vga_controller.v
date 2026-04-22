// -----------------------------------------------------------------------------
// Module      : vga_controller
// Description : Generates VGA sync signals and pixel coordinates for
//               640x480 @ 60 Hz. Advances on tick_25mhz (clock enable from
//               a 100MHz domain). HSYNC and VSYNC are active-low per standard.
//
//   Horizontal timing (pixels at 25 MHz):
//     Visible: 640 | Front porch: 16 | Sync: 96 | Back porch: 48 | Total: 800
//   Vertical timing (lines):
//     Visible: 480 | Front porch: 10 | Sync:  2 | Back porch: 33 | Total: 525
//
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   clk        - System clock (100 MHz)
//   rst        - Synchronous active-high reset
//   tick_25mhz - Pixel clock enable (one pulse per 4 clk cycles = 25 MHz)
//   hsync      - Horizontal sync (active-low)
//   vsync      - Vertical sync (active-low)
//   blank      - High when outside visible area (pixels should be black)
//   h_count    - Current horizontal pixel [9:0] (0-799, visible 0-639)
//   v_count    - Current vertical line [9:0] (0-524, visible 0-479)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module vga_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire        tick_25mhz,
    output reg         hsync,
    output reg         vsync,
    output wire        blank,
    output reg  [9:0]  h_count,
    output reg  [9:0]  v_count
);

    // Horizontal timing constants
    localparam H_VISIBLE     = 10'd640;
    localparam H_FRONT_PORCH = 10'd16;
    localparam H_SYNC_WIDTH  = 10'd96;
    localparam H_BACK_PORCH  = 10'd48;
    localparam H_TOTAL       = 10'd800;

    // Vertical timing constants
    localparam V_VISIBLE     = 10'd480;
    localparam V_FRONT_PORCH = 10'd10;
    localparam V_SYNC_WIDTH  = 10'd2;
    localparam V_BACK_PORCH  = 10'd33;
    localparam V_TOTAL       = 10'd525;

    // Sync pulse boundaries
    localparam H_SYNC_START = H_VISIBLE + H_FRONT_PORCH;           // 656
    localparam H_SYNC_END   = H_VISIBLE + H_FRONT_PORCH + H_SYNC_WIDTH; // 752
    localparam V_SYNC_START = V_VISIBLE + V_FRONT_PORCH;           // 490
    localparam V_SYNC_END   = V_VISIBLE + V_FRONT_PORCH + V_SYNC_WIDTH; // 492

    // Horizontal counter
    always @(posedge clk) begin
        if (rst) begin
            h_count <= 10'd0;
        end else if (tick_25mhz) begin
            if (h_count == H_TOTAL - 1)
                h_count <= 10'd0;
            else
                h_count <= h_count + 10'd1;
        end
    end

    // Vertical counter — increments at end of each horizontal line
    always @(posedge clk) begin
        if (rst) begin
            v_count <= 10'd0;
        end else if (tick_25mhz && (h_count == H_TOTAL - 1)) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 10'd0;
            else
                v_count <= v_count + 10'd1;
        end
    end

    // HSYNC (active-low)
    always @(posedge clk) begin
        if (rst)
            hsync <= 1'b1;
        else if (tick_25mhz)
            hsync <= ~((h_count >= H_SYNC_START) && (h_count < H_SYNC_END));
    end

    // VSYNC (active-low)
    always @(posedge clk) begin
        if (rst)
            vsync <= 1'b1;
        else if (tick_25mhz)
            vsync <= ~((v_count >= V_SYNC_START) && (v_count < V_SYNC_END));
    end

    // Blank: outside visible area
    assign blank = (h_count >= H_VISIBLE) || (v_count >= V_VISIBLE);

endmodule
