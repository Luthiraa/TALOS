`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("maxpool.vcd");
        $dumpvars(0, maxpool);
    end

endmodule