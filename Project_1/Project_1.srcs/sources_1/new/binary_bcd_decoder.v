// -----------------------------------------------------------------------------
// Module      : binary_bcd_decoder
// Description : Converts an N-bit binary number to 2-digit packed BCD using
//               the Double Dabble (shift-and-add-3) algorithm. Supports values
//               0-99. Instantiated for hours (0-23), minutes/seconds (0-59).
// Author      : JustinAlfaro
// Date        : 2026-04-21
// Parameters:
//   N - Width of binary input (default 6 for range 0-59)
// -----------------------------------------------------------------------------
// Ports:
//   bin      - Binary input [N-1:0]
//   bcd_tens - Tens digit [3:0]
//   bcd_ones - Units digit [3:0]
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module binary_bcd_decoder #(
    parameter integer N = 6
)(
    input  wire [N-1:0] bin,
    output reg  [3:0]   bcd_tens,
    output reg  [3:0]   bcd_ones
);

    // Double-Dabble combinational implementation
    reg [N+7:0] work;
    integer i;

    always @(*) begin
        work = {{8{1'b0}}, bin};

        for (i = 0; i < N; i = i + 1) begin
            // Conditionally add 3 to each BCD nibble if >= 5, then shift
            if (work[N+3:N] >= 4'd5)
                work[N+3:N] = work[N+3:N] + 4'd3;
            if (work[N+7:N+4] >= 4'd5)
                work[N+7:N+4] = work[N+7:N+4] + 4'd3;
            work = work << 1;
        end

        // After N shifts: tens accumulates in upper nibble, ones in lower nibble
        bcd_tens = work[N+7:N+4];
        bcd_ones = work[N+3:N];
    end

endmodule
