`timescale 1ns/1ps
`default_nettype none

module cnn #(
    parameter IMG_HEIGHT = 4, // Currently only for testing I put the size as small
    parameter IMG_WIDTH = 4,
    parameter KERNEL_SIZE = 3 // Kernel size for custom CNN model 

)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  reg   [IMG_HEIGHT*IMG_WIDTH-1:0] img,
    input  logic  [31:0] kernel[KERNEL_SIZE*KERNEL_SIZE-1:0],
    output reg [31:0] convimg[0:(IMG_HEIGHT - KERNEL_SIZE + 1)*(IMG_WIDTH - KERNEL_SIZE + 1)-1],
    output logic complete

);
    // tracks current no of convolutions
    reg [7:0] convolutions = 0;

    reg [7:0] hor_align = 0;
    reg [7:0] vert_align = 0;
    reg [7:0] filter_oper = 0;

    // total no of convolution operations
    wire [7:0] total_conv = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1); 
    wire [7:0] total_filter_ops = KERNEL_SIZE * KERNEL_SIZE;

    // hor kernel
    reg [7:0] kernel_hor = 0;
    reg [7:0] kernel_vert = 0;
    

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            complete <= '0; // active low synchronous reset
            for (int i = 0; i < 4; i++) begin  // 4 elements for 2x2 output
                convimg[i] <= 8'b0;
            end
            kernel_hor = 0;
            kernel_vert = 0;
            hor_align = 0;
            vert_align = 0;
            filter_oper = 0;
        end else if (enable && !complete) begin
            if (convolutions < total_conv) begin
                if(hor_align < IMG_WIDTH - KERNEL_SIZE + 1) begin
                    if(filter_oper < total_filter_ops) begin
                        if(kernel_hor < KERNEL_SIZE) begin
                            filter_oper <= filter_oper + 1;
                            convimg[vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align] <= convimg[vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align] + kernel[kernel_vert*KERNEL_SIZE+kernel_hor] * img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align];
                            kernel_hor <= kernel_hor + 1;
                        end
                        else begin
                            kernel_vert <= kernel_vert + 1;
                            kernel_hor <= 0;
                        end
                    end
                    else begin
                        hor_align <= hor_align + 1;
                        filter_oper <= 0;
                        convolutions <= convolutions + 1;
                        kernel_hor <= 0;
                        kernel_vert <= 0;
                    end

                end else if (vert_align < IMG_WIDTH) begin
                    vert_align <= vert_align + 1;
                    hor_align <= 0;
                end
            end
            else begin
                complete = 1;
            end
        end
    end

    // wire [25:0] row1 = convimg[25:0];
    // wire [25:0] row2 = convimg[51:26];
    // wire [25:0] row3 = convimg[77:52];
    // wire [25:0] row4 = convimg[103:78];
    // wire [25:0] row5 = convimg[129:104];
    // wire [25:0] row6 = convimg[155:130];
    // wire [25:0] row7 = convimg[181:156];
    // wire [25:0] row8 = convimg[207:182];
    // wire [25:0] row9 = convimg[233:208];
    // wire [25:0] row10 = convimg[259:234];
    // wire [25:0] row11 = convimg[285:260];
    // wire [25:0] row12 = convimg[311:286];
    // wire [25:0] row13 = convimg[337:312];
    // wire [25:0] row14 = convimg[363:338];
    // wire [25:0] row15 = convimg[389:364];
    // wire [25:0] row16 = convimg[415:390];
    // wire [25:0] row17 = convimg[441:416];
    // wire [25:0] row18 = convimg[467:442];
    // wire [25:0] row19 = convimg[493:468];
    // wire [25:0] row20 = convimg[519:494];
    // wire [25:0] row21 = convimg[545:520];
    // wire [25:0] row22 = convimg[571:546];
    // wire [25:0] row23 = convimg[597:572];
    // wire [25:0] row24 = convimg[623:598];
    // wire [25:0] row25 = convimg[649:624];
    // wire [25:0] row26 = convimg[675:650];

    wire [7:0] row1 = convimg[0];  // All 8 bits of first element
    wire [7:0] row2 = convimg[1];  // All 8 bits of second element
    wire [7:0] row3 = convimg[2];  // All 8 bits of third element
    wire [7:0] row4 = convimg[3];  // All 8 bits of fourth element
    wire [7:0] a = vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align;
    wire [7:0] b = convimg[vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align];
    wire [7:0] c = kernel[kernel_vert*KERNEL_SIZE+kernel_hor];
    wire [7:0] d = kernel[kernel_vert*KERNEL_SIZE+kernel_hor];
    wire [7:0] e =img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align];
    wire [7:0] f = (vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align;

    

endmodule