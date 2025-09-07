`timescale 1ns/1ps
`default_nettype none

module neuron #(
    parameter PREV_NEURONS = 676 // Size for Previous Layer Neurons
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic             activation,
    input  logic signed [31:0] inputlayer[PREV_NEURONS-1:0],
    input  logic signed [31:0] weights[PREV_NEURONS-1:0],
    input  logic signed [31:0] bias,
    output logic signed [31:0] outputneuron,
    output logic complete

);
    logic [31:0] operation = 0;
    logic [31:0] sum = 0;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            complete <= 0; // active low synchronous reset
            outputneuron <= 0;
            operation <= 0;
            sum <= 0;
        end else if (enable && !complete) begin
            if(operation == 0) begin
                sum <= sum + weights[operation] * inputlayer[operation] + bias;
                operation <= operation + 1;

            end
            else if(operation < PREV_NEURONS) begin
                sum <= sum + weights[operation] * inputlayer[operation];
                operation <= operation + 1;
            end
            else begin
                complete <= 1;
                if(!activation) begin
                    outputneuron <= sum;
                end
                else begin
                    outputneuron <= (sum[31] != 1);
                end
            end
        end
    end

endmodule