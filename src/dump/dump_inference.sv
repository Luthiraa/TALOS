`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("inference.vcd");
        $dumpvars(0, inference);
    end

endmodule