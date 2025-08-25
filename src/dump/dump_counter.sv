`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter);
    end

endmodule