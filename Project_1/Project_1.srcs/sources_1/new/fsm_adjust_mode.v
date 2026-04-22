// -----------------------------------------------------------------------------
// Module      : fsm_adjust_mode
// Description : Moore FSM controlling the clock adjustment mode.
//               States: RUN (normal), ADJ_HOUR, ADJ_MIN.
//               btn_mode cycles RUN→ADJ_HOUR→ADJ_MIN→RUN.
//               btn_ajuste (accept) immediately returns to RUN from any state.
//               BTNU/BTND increment/decrement the selected field.
//               Seconds reset to 0 on any state transition.
// Author      : JustinAlfaro
// Date        : 2026-04-22
// Ports:
//   clk        - System clock (100 MHz)
//   rst        - Synchronous active-high reset
//   btn_mode   - Debounced BTNC pulse (cycle state)
//   btn_up     - Debounced BTNU pulse (increment)
//   btn_down   - Debounced BTND pulse (decrement)
//   btn_ajuste - Debounced BTNR pulse (accept, return to RUN)
//   adj_hour   - High in ADJ_HOUR state
//   adj_min    - High in ADJ_MIN  state
//   sec_en     - Seconds auto-increment enable (only in RUN)
//   hour_inc   - Increment hours pulse
//   hour_dec   - Decrement hours pulse
//   min_inc    - Increment minutes pulse
//   min_dec    - Decrement minutes pulse
//   sec_rst    - Reset seconds on state transition
//   mode_leds  - 2-bit LED indicator: 00=RUN, 01=ADJ_HOUR, 10=ADJ_MIN
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module fsm_adjust_mode (
    input  wire       clk,
    input  wire       rst,
    input  wire       btn_mode,
    input  wire       btn_up,
    input  wire       btn_down,
    input  wire       btn_ajuste,
    output reg        adj_hour,
    output reg        adj_min,
    output reg        sec_en,
    output reg        hour_inc,
    output reg        hour_dec,
    output reg        min_inc,
    output reg        min_dec,
    output reg        sec_rst,
    output reg  [1:0] mode_leds
);

    localparam [1:0]
        RUN      = 2'd0,
        ADJ_HOUR = 2'd1,
        ADJ_MIN  = 2'd2;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk) begin
        if (rst) state <= RUN;
        else     state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        if (btn_ajuste) begin
            next_state = RUN; // accept from any state
        end else if (btn_mode) begin
            case (state)
                RUN:      next_state = ADJ_HOUR;
                ADJ_HOUR: next_state = ADJ_MIN;
                ADJ_MIN:  next_state = RUN;
                default:  next_state = RUN;
            endcase
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (rst) begin
            adj_hour  <= 1'b0;
            adj_min   <= 1'b0;
            sec_en    <= 1'b0;
            hour_inc  <= 1'b0;
            hour_dec  <= 1'b0;
            min_inc   <= 1'b0;
            min_dec   <= 1'b0;
            sec_rst   <= 1'b0;
            mode_leds <= 2'b00;
        end else begin
            hour_inc <= 1'b0;
            hour_dec <= 1'b0;
            min_inc  <= 1'b0;
            min_dec  <= 1'b0;
            sec_rst  <= 1'b0;

            case (state)
                RUN: begin
                    adj_hour  <= 1'b0;
                    adj_min   <= 1'b0;
                    sec_en    <= 1'b1;
                    mode_leds <= 2'b00;
                    if (btn_mode) sec_rst <= 1'b1;
                end

                ADJ_HOUR: begin
                    adj_hour  <= 1'b1;
                    adj_min   <= 1'b0;
                    sec_en    <= 1'b0;
                    mode_leds <= 2'b01;
                    hour_inc  <= btn_up;
                    hour_dec  <= btn_down;
                    if (btn_mode || btn_ajuste) sec_rst <= 1'b1;
                end

                ADJ_MIN: begin
                    adj_hour  <= 1'b0;
                    adj_min   <= 1'b1;
                    sec_en    <= 1'b0;
                    mode_leds <= 2'b10;
                    min_inc   <= btn_up;
                    min_dec   <= btn_down;
                    if (btn_mode || btn_ajuste) sec_rst <= 1'b1;
                end

                default: begin
                    adj_hour  <= 1'b0;
                    adj_min   <= 1'b0;
                    sec_en    <= 1'b1;
                    mode_leds <= 2'b00;
                end
            endcase
        end
    end

endmodule
