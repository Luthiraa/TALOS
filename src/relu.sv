`timescale 1ns/1ps
`default_nettype none

module relu #(
    parameter int WIDTH = 32
)(
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);
    always_comb begin
        if (in < 0) begin
            out = 0;
        end else begin
            out = in;
        end
    end
endmodule
