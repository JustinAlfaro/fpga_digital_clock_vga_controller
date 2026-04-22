// -----------------------------------------------------------------------------
// Module      : bg_generator
// Description : Combinational background color generator. Produces a deep-space
//               themed background: dark navy gradient with a subtle horizontal
//               band effect and corner vignette. Uses only h_count and v_count.
//               Output is 12-bit RGB (4-4-4 format): {R[3:0], G[3:0], B[3:0]}.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   h_count  - Horizontal pixel coordinate [9:0] (0-639)
//   v_count  - Vertical pixel coordinate [9:0] (0-479)
//   bg_color - Output background color [11:0] = {R,G,B} 4 bits each
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module bg_generator (
    input  wire [9:0]  h_count,
    input  wire [9:0]  v_count,
    output reg  [11:0] bg_color
);

    // ----- Gradient parameters -----------------------------------------------
    // Vertical gradient: dark navy at top (v=0) → deep teal at center → navy again
    // Horizontal: slight purple tint on left half
    // Decorative bands: thin horizontal lines every 60 pixels

    reg [3:0] r, g, b;

    // Distance from center (normalized approximation)
    wire [9:0] dist_v = (v_count < 10'd240) ? (10'd240 - v_count) : (v_count - 10'd240);
    wire [9:0] dist_h = (h_count < 10'd320) ? (10'd320 - h_count) : (h_count - 10'd320);

    // Band flag: true for every 60th row band (2 pixels wide)
    wire band = (v_count[5:0] < 6'd2);

    // Quadrant for color variation
    wire left_half = (h_count < 10'd320);

    always @(*) begin
        // Base color: deep navy/space blue
        r = 4'd1;
        g = 4'd1;
        b = 4'd3;

        // Vertical gradient: more blue toward center
        if (dist_v < 10'd60) begin
            r = 4'd1;
            g = 4'd2;
            b = 4'd5;
        end else if (dist_v < 10'd120) begin
            r = 4'd1;
            g = 4'd1;
            b = 4'd4;
        end

        // Add purple tint on left half
        if (left_half) begin
            r = r + 4'd1;
        end

        // Decorative subtle scan line bands
        if (band) begin
            r = (r > 4'd0) ? r - 4'd1 : 4'd0;
            g = (g > 4'd0) ? g - 4'd1 : 4'd0;
            b = (b > 4'd0) ? b - 4'd1 : 4'd0;
        end

        // Bright accent stripe at y = 240 (center horizontal line)
        if (v_count == 10'd240 || v_count == 10'd241) begin
            r = 4'd2;
            g = 4'd3;
            b = 4'd8;
        end

        // Vignette: darken corners when far from center both axes
        if (dist_v > 10'd180 && dist_h > 10'd200) begin
            r = 4'd0;
            g = 4'd0;
            b = 4'd1;
        end

        bg_color = {r, g, b};
    end

endmodule
