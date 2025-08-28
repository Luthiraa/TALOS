`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("flatten.vcd");
        $dumpvars(0, flatten);
    end

endmodule