`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("neuron.vcd");
        $dumpvars(0, neuron);
    end

endmodule