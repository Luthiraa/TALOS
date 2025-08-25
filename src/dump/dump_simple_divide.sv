`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("simple_divide.vcd");
        $dumpvars(0, simple_divide);
    end

endmodule