// -----------------------------------------------------------------------------
// Module      : bcd_counter
// Description : Parametric BCD counter with configurable upper limit. Supports
//               auto-increment (clock enable), manual increment/decrement for
//               adjustment mode, and carry output for chaining.
// Author      : JustinAlfaro
// Date        : 2026-04-21
// Parameters:
//   MAX_VAL - Maximum count value inclusive (default 59 for min/sec)
// -----------------------------------------------------------------------------
// Ports:
//   clk        - System clock (100 MHz)
//   rst        - Synchronous active-high reset
//   clk_en     - Clock enable: auto-increments counter when high (1 Hz pulse)
//   inc        - Manual increment pulse (from FSM in adjust mode)
//   dec        - Manual decrement pulse (from FSM in adjust mode)
//   count      - Current count [5:0] (enough for 0-59)
//   carry_out  - Pulses high for one cycle when counter wraps 0 (for chaining)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module bcd_counter #(
    parameter integer MAX_VAL = 59
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       clk_en,
    input  wire       inc,
    input  wire       dec,
    output reg  [5:0] count,
    output reg        carry_out
);

    always @(posedge clk) begin
        if (rst) begin
            count     <= 6'd0;
            carry_out <= 1'b0;
        end else begin
            carry_out <= 1'b0;

            if (clk_en) begin
                if (count == MAX_VAL[5:0]) begin
                    count     <= 6'd0;
                    carry_out <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end else if (inc) begin
                if (count == MAX_VAL[5:0])
                    count <= 6'd0;
                else
                    count <= count + 1'b1;
            end else if (dec) begin
                if (count == 6'd0)
                    count <= MAX_VAL[5:0];
                else
                    count <= count - 1'b1;
            end
        end
    end

endmodule
