`timescale 1ns/1ps
`default_nettype none


module simple_divide #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [DATA_WIDTH-1:0] dividend, 
    input logic [DATA_WIDTH-1:0] divisor,
    output logic [DATA_WIDTH-1:0] quotient,
    output logic [DATA_WIDTH-1:0] remainder,
    output logic divide_by_zero
);

logic div_by_zero_comb;
assign div_by_zero_comb = (divisor == 0);

always_ff @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        quotient <= 0;
        remainder <= 0;
        divide_by_zero <= 0;
    end else if (enable) begin
        divide_by_zero <= div_by_zero_comb;
        if (div_by_zero_comb) begin
            quotient <= 0;
            remainder <= 0;
        end else begin
            quotient <= dividend / divisor;
            remainder <= dividend % divisor;
        end
    end
end

endmodule
