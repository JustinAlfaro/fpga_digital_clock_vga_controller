// -----------------------------------------------------------------------------
// Module      : vram_writer
// Description : Sequential FSM that redraws the entire 640x480 VRAM once per
//               redraw request. Runs at 100 MHz; a full frame takes 307 200
//               cycles (~3.07 ms, well within the 1-second update window).
//               For each pixel the combinational outputs of bg_generator and
//               text_renderer are merged: text foreground takes priority.
//               Signals bg_color and pixel_on/text_color come from external
//               combinational modules driven by the writer's own h_wr/v_wr.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// -----------------------------------------------------------------------------
// Ports:
//   clk          - 100 MHz system clock
//   rst          - Synchronous active-high reset
//   redraw_req   - Pulse: triggers a full-frame redraw (connect to tick_1hz
//                  OR to any button-press event)
//   -- bg_generator interface (combinational, driven by h_wr / v_wr) --
//   h_wr         - Current write column [9:0] exposed to bg_generator
//   v_wr         - Current write row    [9:0] exposed to text_renderer
//   bg_color     - 12-bit background color from bg_generator
//   -- text_renderer interface --
//   pixel_on     - 1 if current pixel is a character foreground
//   text_color   - 12-bit text color from text_renderer
//   -- BRAM Port B interface --
//   bram_addr    - Write address to BRAM port B [18:0]
//   bram_din     - Write data to BRAM port B [11:0]
//   bram_we      - Write enable for BRAM port B
//   -- Status --
//   drawing      - High while a redraw is in progress
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module vram_writer (
    input  wire        clk,
    input  wire        rst,
    input  wire        redraw_req,

    // Pixel coordinate outputs for combinational modules
    output reg  [9:0]  h_wr,
    output reg  [9:0]  v_wr,

    // Color inputs from combinational modules
    input  wire [11:0] bg_color,
    input  wire        pixel_on,
    input  wire [11:0] text_color,

    // BRAM port B
    output reg  [18:0] bram_addr,
    output reg  [11:0] bram_din,
    output reg         bram_we,

    output reg         drawing
);

    // FSM states
    localparam [1:0]
        IDLE = 2'd0,
        DRAW = 2'd1,
        DONE = 2'd2;

    reg [1:0] state;

    // Pixel address (linear 0..307199)
    reg [18:0] px_addr;

    // Screen dimensions
    localparam H_MAX = 10'd639;
    localparam V_MAX = 10'd479;

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            h_wr     <= 10'd0;
            v_wr     <= 10'd0;
            px_addr  <= 19'd0;
            bram_we  <= 1'b0;
            drawing  <= 1'b0;
        end else begin
            bram_we <= 1'b0; // Default

            case (state)
                IDLE: begin
                    drawing <= 1'b0;
                    if (redraw_req) begin
                        h_wr    <= 10'd0;
                        v_wr    <= 10'd0;
                        px_addr <= 19'd0;
                        state   <= DRAW;
                        drawing <= 1'b1;
                    end
                end

                DRAW: begin
                    drawing   <= 1'b1;
                    bram_addr <= px_addr;
                    bram_din  <= pixel_on ? text_color : bg_color;
                    bram_we   <= 1'b1;

                    // Advance pixel coordinates
                    if (h_wr == H_MAX) begin
                        h_wr <= 10'd0;
                        if (v_wr == V_MAX) begin
                            // Frame complete
                            state <= DONE;
                        end else begin
                            v_wr <= v_wr + 10'd1;
                        end
                    end else begin
                        h_wr <= h_wr + 10'd1;
                    end

                    if (px_addr == 19'd307199)
                        px_addr <= 19'd0;
                    else
                        px_addr <= px_addr + 19'd1;
                end

                DONE: begin
                    drawing <= 1'b0;
                    bram_we <= 1'b0;
                    if (redraw_req) begin
                        h_wr    <= 10'd0;
                        v_wr    <= 10'd0;
                        px_addr <= 19'd0;
                        state   <= DRAW;
                        drawing <= 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
