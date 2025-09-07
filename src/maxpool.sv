`timescale 1ns/1ps
`default_nettype none

module maxpool #(
    parameter IMG_HEIGHT = 26, // Size for MNIST images
    parameter IMG_WIDTH = 26,
    parameter KERNEL_SIZE = 2, // Kernel size for custom CNN model
    parameter OUT_H       = ((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1,
    parameter OUT_W       = ((IMG_WIDTH  - KERNEL_SIZE) >> 1) + 1,
    parameter OUT_ELEMS   = OUT_H * OUT_W
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic signed   [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0],
    output logic signed [31:0] convimg[OUT_ELEMS-1:0],
    output logic complete

);
    // tracks current no of convolutions
    logic [31:0] convolutions = 0;

    logic [31:0] hor_align = 0;
    logic [31:0] vert_align = 0;
    logic [31:0] out_hor_align = 0;
    logic [31:0] out_ver_align = 0;
    logic [31:0] filter_oper = 0;

    // total no of convolution operations
    wire [31:0] total_conv = (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1) * (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1); 
    wire [31:0] total_filter_ops = KERNEL_SIZE * KERNEL_SIZE;

    // hor kernel
    logic [31:0] kernel_hor = 0;
    logic [31:0] kernel_vert = 0;
    

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            complete <= '0; // active low synchronous reset
            for (int i = 0; i < OUT_ELEMS; i++) begin  // 4 elements for 2x2 output
                convimg[i] <= 8'b0;
            end
            kernel_hor <= 0;
            kernel_vert <= 0;
            hor_align <= 0;
            vert_align <= 0;
            filter_oper <= 0;
        end else if (enable && !complete) begin
            if (convolutions < total_conv) begin
                if(hor_align < IMG_WIDTH - KERNEL_SIZE + 1) begin
                    if(filter_oper < total_filter_ops) begin
                        if(kernel_hor < KERNEL_SIZE) begin
                            if(filter_oper == 0) begin
                                convimg[out_ver_align * (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1) + out_hor_align] <= img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align];
                            end
                            else begin  
                                convimg[out_ver_align * (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1) + out_hor_align] <= convimg[out_ver_align * (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1) + out_hor_align] < img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align] ? img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align]:convimg[out_ver_align * (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1) + out_hor_align];
                            end
                            kernel_hor <= kernel_hor + 1;
                            filter_oper <= filter_oper + 1;
                        end
                        else begin
                            kernel_vert <= kernel_vert + 1;
                            kernel_hor <= 0;
                        end
                    end
                    else begin
                        hor_align <= hor_align + 2;
                        out_hor_align <= out_hor_align + 1;
                        filter_oper <= 0;
                        convolutions <= convolutions + 1;
                        kernel_hor <= 0;
                        kernel_vert <= 0;
                    end

                end else if (vert_align < IMG_HEIGHT - KERNEL_SIZE + 1) begin
                    vert_align <= vert_align + 2;
                    out_ver_align <= out_ver_align + 1;
                    hor_align <= 0;
                    out_hor_align <= 0;
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

    // wire [7:0] row1 = img[0];  // All 8 bits of first element
    // wire [7:0] row2 = img[1];  // All 8 bits of second element
    // wire [7:0] row3 = img[2];  // All 8 bits of third element
    // wire [7:0] row4 = img[3];  // All 8 bits of fourth element


    // wire [7:0] row5 = img[4];  // All 8 bits of first element
    // wire [7:0] row6 = img[5];  // All 8 bits of second element
    // wire [7:0] row7 = img[6];  // All 8 bits of third element
    // wire [7:0] row8 = img[7];
    // wire [7:0] a = vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align;
    // wire [7:0] b = convimg[vert_align * (IMG_WIDTH - KERNEL_SIZE + 1) + hor_align];
    // wire [7:0] c = kernel[kernel_vert*KERNEL_SIZE+kernel_hor];
    // wire [7:0] d = kernel[kernel_vert*KERNEL_SIZE+kernel_hor];
    // wire [7:0] e =img[(vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align];
    // wire [7:0] f = (vert_align+kernel_vert)*IMG_WIDTH+kernel_hor+hor_align;


    wire signed [31:0] a = convimg[0];
    wire signed [31:0] b = convimg[1];
    wire signed [31:0] c = convimg[2];
    wire signed [31:0] d = convimg[3];
    wire signed [31:0] e = convimg[4];
    wire signed [31:0] f = convimg[5];
    wire signed [31:0] g = convimg[6];
    wire signed [31:0] h = convimg[7];

    

endmodule