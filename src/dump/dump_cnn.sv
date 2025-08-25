`timescale 1ns/1ps
`default_nettype none

module dump();

    initial begin
        $dumpfile("cnn.vcd");
        $dumpvars(0, cnn);
    end

endmodule