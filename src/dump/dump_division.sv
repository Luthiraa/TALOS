`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("division.vcd");
        $dumpvars(0, division);
    end

endmodule