// `timescale 1ns/1ps
// `default_nettype none

// module flatten #(
//     parameter HEIGHT = 3,
//     parameter WIDTH  = 3,
//     parameter MAPS   = 2
// )(
//     input  logic             clk,
//     input  logic             rst_n,
//     input  logic             enable,
//     input  logic [31:0]                cnnmaps[HEIGHT*WIDTH-1:0],
//     output logic             [31:0] flat[MAPS*HEIGHT*WIDTH-1:0],
//     output logic             done
// );

//     wire [31:0] total = MAPS*HEIGHT*WIDTH;
//     wire [31:0] total_per_map = HEIGHT*WIDTH;
//     reg [31:0] count = 0;
//     reg [31:0] count_per_map = 0;
//     reg [31:0] map = 0;
//     reg [31:0] x = 0;
//     reg [31:0] y = 0;

//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             count <= 0;
//             count_per_map <= 0;
//             map <= 0;
//             x <= 0;
//             y <= 0;
//         end else if (enable) begin
//             if(count < total) begin
//                 if(count_per_map < total_per_map) begin
//                     if(x < WIDTH) begin
//                         count <= count + 1;
//                         count_per_map <= count_per_map + 1;
//                         flat[map*total_per_map+y*WIDTH+x] <= cnnmaps[map][y*WIDTH+x];
//                         x <= x + 1;
//                     end
//                     else begin
//                         y <= y + 1;
//                         x <= 0;
//                     end
//                 end
//                 else begin
//                     x <= 0;
//                     y <= 0;
//                     map <= map + 1;
//                     count_per_map <= 0;
//                 end
//             end
//             else begin
//                 done <= 1;
//             end
//         end
//         else begin
//             done <= 0;
//         end
//     end

//     // wire [31:0] a = cnnmaps[0][0];
//     // wire [31:0] b = cnnmaps[0][1];
//     // wire [31:0] c = cnnmaps[0][2];
//     // wire [31:0] d = cnnmaps[0][3];
//     // wire [31:0] e = cnnmaps[0][4];
//     // wire [31:0] f = cnnmaps[0][5];

//     wire [31:0] a = flat[0];
//     wire [31:0] b = flat[1];
//     wire [31:0] c = flat[2];
//     wire [31:0] d = flat[3];
//     wire [31:0] e = flat[4];
//     wire [31:0] f = flat[5];
//     wire [31:0] g = flat[6];
//     wire [31:0] h = flat[7];
//     wire [31:0] i = flat[8];
//     wire [31:0] k = flat[9];
//     wire [31:0] l = flat[10];
//     wire [31:0] m = flat[11];
//     wire [31:0] n = flat[12];
//     wire [31:0] o = flat[13];
//     wire [31:0] p = flat[14];
//     wire [31:0] q = flat[15];
//     wire [31:0] r = flat[16];
//     wire [31:0] s = flat[17];

// endmodule


// `timescale 1ns/1ps
// `default_nettype none

// module flatten #(
//     parameter HEIGHT = 3,
//     parameter WIDTH  = 3,
//     parameter MAPS = 2,
//     parameter MAP = 1
// )(
//     input  logic             clk,
//     input  logic             rst_n,
//     input  logic             enable,
//     input  logic signed [31:0]                cnnmaps[HEIGHT*WIDTH-1:0],
//     output logic signed           [31:0] flat[MAPS*HEIGHT*WIDTH:0],
//     output logic             done
// );

//     localparam TOTAL_ELEM = HEIGHT * WIDTH;
//     logic [31:0] x;
//     logic [31:0] y;
//     logic [31:0] count;

//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             count <= 0;
//             x <= 0;
//             y <= 0;
//         end else if (enable) begin
//             if(count < TOTAL_ELEM) begin
//                 if(x < WIDTH) begin
//                     flat[MAP*TOTAL_ELEM+x*WIDTH+y] <= cnnmaps[x*WIDTH+y];
//                     x <= x + 1;
//                     count <= count + 1;
//                 end
//                 else begin
//                     x <= 0;
//                     y <= y + 1;
//                 end
//             end
//             else begin
//                 done <= 1;
//             end
//         end
//         else begin
//             done <= 0;
//         end
//     end

//     // wire [31:0] a = cnnmaps[0][0];
//     // wire [31:0] b = cnnmaps[0][1];
//     // wire [31:0] c = cnnmaps[0][2];
//     // wire [31:0] d = cnnmaps[0][3];
//     // wire [31:0] e = cnnmaps[0][4];
//     // wire [31:0] f = cnnmaps[0][5];

//     wire [31:0] a = flat[0];
//     wire [31:0] b = flat[1];
//     wire [31:0] c = flat[2];
//     wire [31:0] d = flat[3];
//     wire [31:0] e = flat[4];
//     wire [31:0] f = flat[5];
//     wire [31:0] g = flat[6];
//     wire [31:0] h = flat[7];
//     wire [31:0] i = flat[8];
//     wire [31:0] k = flat[9];
//     wire [31:0] l = flat[10];
//     wire [31:0] m = flat[11];
//     wire [31:0] n = flat[12];
//     wire [31:0] o = flat[13];
//     wire [31:0] p = flat[14];
//     wire [31:0] q = flat[15];
//     wire [31:0] r = flat[16];
//     wire [31:0] s = flat[17];

// endmodule


`timescale 1ns/1ps
`default_nettype none

module flatten #(
    parameter IMG_HEIGHT = 13,
    parameter IMG_WIDTH  = 13,
    parameter MAPS = 4,
    parameter MAP = 0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic signed [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0],
    output logic signed [31:0] flat[MAPS*HEIGHT*WIDTH:0],
    output logic  done
);

    localparam TOTAL_ELEM = HEIGHT * WIDTH;
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            x <= 0;
            y <= 0;
        end else if (enable) begin
            if(count < TOTAL_ELEM) begin
                if(x < WIDTH) begin
                    flat[MAP*TOTAL_ELEM+x*WIDTH+y] <= cnnmaps[x*WIDTH+y];
                    x <= x + 1;
                    count <= count + 1;
                end
                else begin
                    x <= 0;
                    y <= y + 1;
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

    // wire [31:0] a = cnnmaps[0][0];
    // wire [31:0] b = cnnmaps[0][1];
    // wire [31:0] c = cnnmaps[0][2];
    // wire [31:0] d = cnnmaps[0][3];
    // wire [31:0] e = cnnmaps[0][4];
    // wire [31:0] f = cnnmaps[0][5];

    wire [31:0] a = flat[0];
    wire [31:0] b = flat[1];
    wire [31:0] c = flat[2];
    wire [31:0] d = flat[3];
    wire [31:0] e = flat[4];
    wire [31:0] f = flat[5];
    wire [31:0] g = flat[6];
    wire [31:0] h = flat[7];
    wire [31:0] i = flat[8];
    wire [31:0] k = flat[9];
    wire [31:0] l = flat[10];
    wire [31:0] m = flat[11];
    wire [31:0] n = flat[12];
    wire [31:0] o = flat[13];
    wire [31:0] p = flat[14];
    wire [31:0] q = flat[15];
    wire [31:0] r = flat[16];
    wire [31:0] s = flat[17];

endmodule