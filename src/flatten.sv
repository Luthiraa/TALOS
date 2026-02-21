`timescale 1ns/1ps
`default_nettype none

module flatten #(
    parameter HEIGHT = 3,
    parameter WIDTH  = 3,
    parameter MAPS   = 2
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic [31:0]                cnnmaps [MAPS-1:0][HEIGHT*WIDTH-1:0],
    output reg             [31:0] flat[MAPS*HEIGHT*WIDTH-1:0],
    output logic             done
);

    wire [31:0] total = MAPS*HEIGHT*WIDTH;
    wire [31:0] total_per_map = HEIGHT*WIDTH;
    reg [31:0] count = 0;
    reg [31:0] count_per_map = 0;
    reg [31:0] map = 0;
    reg [31:0] x = 0;
    reg [31:0] y = 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            count_per_map <= 0;
            map <= 0;
            x <= 0;
            y <= 0;
        end else if (enable) begin
            if(count < total) begin
                if(count_per_map < total_per_map) begin
                    if(x < WIDTH) begin
                        count <= count + 1;
                        count_per_map <= count_per_map + 1;
                        flat[map*total_per_map+y*WIDTH+x] <= cnnmaps[map][y*WIDTH+x];
                        x <= x + 1;
                    end
                    else begin
                        y <= y + 1;
                        x <= 0;
                    end
                end
                else begin
                    x <= 0;
                    y <= 0;
                    map <= map + 1;
                    count_per_map <= 0;
                end
            end
            else begin
                done <= 1;
            end
        end
        else begin
            done <= 0;
        end
    end

endmodule