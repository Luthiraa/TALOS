// `timescale 1ns/1ps
// `default_nettype none

// module inference #(
//     parameter IMG_HEIGHT = 4,
//     parameter IMG_WIDTH = 4,
//     parameter NO_KERNELS = 2,
//     parameter KERNEL_SIZE = 3
// )(
//     input  logic             clk,
//     input  logic             rst_n,
//     input  logic             enable,
//     input  logic [31:0]  img[IMG_HEIGHT*IMG_WIDTH-1:0],  // Fixed: logic instead of reg, 8-bit per pixel
//     input  logic [31:0] kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
//     // input  logic signed [31:0] weights[PREV_NEURONS-1:0][NO_NEURONS-1:0]
//     output logic complete
// );
//     // Local parameters
//     localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
//     localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

//     // CNN Layer
//     logic [NO_KERNELS-1:0] cnn_complete;
//     // logic mpenable; // maxpool enable
//     // assign mpenable = &cnn_complete;

//     logic [31:0] count;
//     assign count = 0;
//     logic temp;
//     assign temp = 0;
//     logic signed [31:0] ker[KERNEL_SIZE*KERNEL_SIZE-1:0];
//     wire signed [31:0] x[CONV_SIZE-1:0];
//     // assign x = 0;

//     // initial begin
//     //     for (int i = 0; i < CONV_SIZE; i++) begin
//     //         x[i] = 32'b0;
//     //     end
//     // end


//     always_comb begin
//         for (int i = 0; i < KERNEL_ELEMENTS; i++) begin
//             ker[i] <= kernels[i]; // First kernel: elements 0-8
//         end
//     end

//     logic k;
//     cnn #(
//         .IMG_HEIGHT(IMG_HEIGHT),
//         .IMG_WIDTH(IMG_WIDTH),
//         .KERNEL_SIZE(KERNEL_SIZE)
//     ) cnn_inst (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(enable),
//         .img(img),
//         .kernel(ker),
//         .x(x),
//         .complete(k)
//     );

//     // assign x = cnn_inst.row1;
    
//     // always_ff @(posedge clk or negedge rst_n) begin
//     //     if (!rst_n) begin
//     //         count <= 0;
//     //     end else if (enable) begin
//     //         if(count < NO_KERNELS) begin
//     //             if(temp == 0) begin
//     //                 ker <= kernels[count*KERNEL_ELEMENTS-1:(count+1)*KERNEL_ELEMENTS-1];
//     //                 temp <= 1;
//     //                 out <= 0;
//     //             end
//     //             else if(temp == 1) begin
//     //                 temp <= 0;
//     //                 cnn #(
//     //                     .IMG_HEIGHT(IMG_HEIGHT),
//     //                     .IMG_WIDTH(IMG_WIDTH),
//     //                     .KERNEL_SIZE(KERNEL_SIZE)
//     //                 ) cnn_inst (
//     //                     .clk(clk),
//     //                     .rst_n(rst_n),
//     //                     .enable(enable),
//     //                     .img(img),
//     //                     .kernel(ker),
//     //                     .convimg(out),
//     //                     .complete(cnn_complete[count])
//     //                 );
//     //                 count <= count + 1;
//     //             end
//     //         end
//     //     end
//     // end

//     // Maxpool
//     logic mpenable;
//     assign mpenable = &cnn_complete;


//     // Debug: Individual array elements as separate signals for GTKWave
//     // These will show up as separate signals in GTKWave
//     logic signed [31:0] x_elem_0, x_elem_1, x_elem_2, x_elem_3, x_elem_4, x_elem_5;
//     logic signed [31:0] x_elem_6, x_elem_7, x_elem_8, x_elem_9, x_elem_10, x_elem_11;
//     logic signed [31:0] x_elem_12, x_elem_13, x_elem_14, x_elem_15;
    
//     always_comb begin
//         x_elem_0 = x[0];
//         x_elem_1 = x[1];
//         x_elem_2 = x[2];
//         x_elem_3 = x[3];
//         // if (CONV_SIZE >= 5)  x_elem_4 = x[4];
//         // if (CONV_SIZE >= 6)  x_elem_5 = x[5];
//         // if (CONV_SIZE >= 7)  x_elem_6 = x[6];
//         // if (CONV_SIZE >= 8)  x_elem_7 = x[7];
//         // if (CONV_SIZE >= 9)  x_elem_8 = x[8];
//         // if (CONV_SIZE >= 10) x_elem_9 = x[9];
//         // if (CONV_SIZE >= 11) x_elem_10 = x[10];
//         // if (CONV_SIZE >= 12) x_elem_11 = x[11];
//         // if (CONV_SIZE >= 13) x_elem_12 = x[12];
//         // if (CONV_SIZE >= 14) x_elem_13 = x[13];
//         // if (CONV_SIZE >= 15) x_elem_14 = x[14];
//         // if (CONV_SIZE >= 16) x_elem_15 = x[15];
//     end

//     // Debug: Kernel elements as separate signals
//     logic signed [31:0] ker_0, ker_1, ker_2, ker_3, ker_4, ker_5, ker_6, ker_7, ker_8;
//     always_comb begin
//         ker_0 = ker[0]; ker_1 = ker[1]; ker_2 = ker[2];
//         ker_3 = ker[3]; ker_4 = ker[4]; ker_5 = ker[5];
//         ker_6 = ker[6]; ker_7 = ker[7]; ker_8 = ker[8];
//     end

//     assign complete = k;

        
// endmodule

// `timescale 1ns/1ps
// `default_nettype none

// module inference #(
//     parameter IMG_HEIGHT = 6,
//     parameter IMG_WIDTH = 6,
//     parameter NO_KERNELS = 2,        // Number of CNN blocks to instantiate
//     parameter KERNEL_SIZE = 3,
//     parameter MAXPOOL_KERNEL = 2
// )(
//     input  logic             clk,
//     input  logic             rst_n,
//     input  logic             enable,
//     input  logic signed [31:0]      img[IMG_HEIGHT*IMG_WIDTH-1:0],
//     input  logic signed [31:0]      kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
//     output wire              complete
// );

//     localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
//     localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1;
//     localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

//     // Completion signals from each CNN block
//     logic [NO_KERNELS-1:0] cnn_complete;
    
//     wire mp_enable;
//     assign mp_enable = &cnn_complete;
//     logic [NO_KERNELS-1:0] mp_complete;
//     wire flatten_enable;
//     assign flatten_enable = &mp_complete;

//     logic [NO_KERNELS-1:0] flatten_complete;

//     logic signed [31:0] flattend[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];

//     // Generate multiple CNN blocks
//     genvar i;
//     generate
//         for (i = 0; i < NO_KERNELS; i = i + 1) begin : gen_cnn
            
//             // Kernel for this CNN block
//             logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
//             // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
//             // Output from this CNN block
//             wire signed [31:0] x[CONV_SIZE-1:0];
//             // wire signed [31:0][(MAXPOOL_SIZE*MAXPOOL_SIZE)-1:0]convimg;
            
//             // // Extract kernel weights for this block
//             always_comb begin
//                 for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
//                     ker[j] <= kernels[i*KERNEL_ELEMENTS + j];
//                 end
//             end
            
//             // CNN instance
//             cnn #(
//                 .IMG_HEIGHT(IMG_HEIGHT),
//                 .IMG_WIDTH(IMG_WIDTH),
//                 .KERNEL_SIZE(KERNEL_SIZE)
//             ) cnn_inst (
//                 .clk(clk),
//                 .rst_n(rst_n),
//                 .enable(enable),
//                 .img(img),
//                 .kernel(ker),
//                 .x(x),
//                 .complete(cnn_complete[i])
//             );

//             maxpool #(
//                 .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//                 .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1),
//                 .KERNEL_SIZE(MAXPOOL_KERNEL)
//             ) ma_inst (
//                 .clk(clk),
//                 .rst_n(rst_n),
//                 .enable(mp_enable),
//                 .img(x),
//                 // .convimg(convimg),
//                 .complete(mp_complete[i])
//             );

//             // flatten #(
//             //     .HEIGHT(MAXPOOL_SIZE),
//             //     .WIDTH(MAXPOOL_SIZE),
//             //     .MAPS(NO_KERNELS),
//             //     .MAP(i)
//             // ) fl_inst (
//             //     .clk(clk),
//             //     .rst_n(rst_n),
//             //     .enable(flatten_enable),
//             //     .cnnmaps(ma_inst.convimg[0]),
//             //     // .flat(flattend),
//             //     .done(flatten_complete[i])
//             // );

//             always_comb begin
//                 for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE; k = k+1) begin
//                     if(flatten_enable) begin
//                         flattend[MAXPOOL_SIZE*MAXPOOL_SIZE*i+k] <= ma_inst.convimg[k];
//                     end
//                 end
//             end

//         end
//     endgenerate

//     // assign complete = &flatten_complete;
//     assign complete = &mp_complete;
//     wire [7:0]g;
//     assign g = gen_cnn[0].cnn_inst.x[0];


//     wire [31:0] cc;
//     assign cc = flattend[0];
//     wire [31:0] aa;
//     assign aa = flattend[1];
//     wire [31:0] bb;
//     assign bb = flattend[2];

//     // wire mp_enable;
//     // assign mp_enable = &cnn_complete;
//     // logic [NO_KERNELS-1:0] mp_complete;

//     // localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1);
//     // genvar a;
//     // generate
//     //     for (a = 0; a < NO_KERNELS; a = a + 1) begin : gen_max
            
//     //         // // Kernel for this CNN block
//     //         // logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
//     //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
//     //         // Output from this CNN block
//     //         logic [31:0] convimg[MAXPOOL_SIZE * MAXPOOL_SIZE - 1:0];

//     //         // // // Extract kernel weights for this block
//     //         // always_comb begin
//     //         //     for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
//     //         //         ker[j] <= kernels[a*KERNEL_ELEMENTS + j];
//     //         //     end
//     //         // end
            
//     //         // CNN instance
//     //         maxpool #(
//     //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//     //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1)
//     //         ) ma_inst (
//     //             .clk(clk),
//     //             .rst_n(rst_n),
//     //             .enable(mp_enable),
//     //             .img(gen_cnn[a].cnn_inst.x),
//     //             .convimg(convimg),
//     //             .complete(mp_complete[a])
//     //         );
            
//     //     end
//     // endgenerate

   
// endmodule


`timescale 1ns/1ps
`default_nettype none

module inference #(
    parameter IMG_HEIGHT = 28,
    parameter IMG_WIDTH = 28,
    parameter NO_KERNELS = 4,        // Number of CNN blocks to instantiate
    parameter KERNEL_SIZE = 3,
    parameter MAXPOOL_KERNEL = 2,
    parameter NO_NEURONS = 2,
    parameter ACTIVATION = 0,
    parameter LINEAR_SIZE = ((((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic signed [31:0]      img[IMG_HEIGHT*IMG_WIDTH-1:0],
    input  logic signed [31:0]      kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
    input logic signed [31:0] weights[NO_NEURONS*NO_KERNELS*LINEAR_SIZE*LINEAR_SIZE-1:0],
    input logic signed [31:0] biases[NO_NEURONS-1:0],
    output wire              complete
);

    localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
    localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1;
    localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

    // Completion signals
    logic [NO_KERNELS-1:0] cnn_complete;
    logic [NO_KERNELS-1:0] mp_complete;
    wire mp_enable;
    assign mp_enable = &cnn_complete;

    logic signed [31:0] ker1[0:KERNEL_ELEMENTS-1];
    logic signed [31:0] ker2[0:KERNEL_ELEMENTS-1];
    logic signed [31:0] ker3[0:KERNEL_ELEMENTS-1];
    logic signed [31:0] ker4[0:KERNEL_ELEMENTS-1];

    always_comb begin
        for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
            ker1[j] = kernels[0*KERNEL_ELEMENTS + j];
            ker2[j] = kernels[1*KERNEL_ELEMENTS + j];
            ker3[j] = kernels[2*KERNEL_ELEMENTS + j];
            ker4[j] = kernels[3*KERNEL_ELEMENTS + j];
        end
    end

    cnn #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) cnn_ins0 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .img(img),
        .kernel(ker1),
        // .x(x),
        .complete(cnn_complete[0])
    );

    maxpool #(
        .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
        .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
        .KERNEL_SIZE(MAXPOOL_KERNEL)
    ) ma_ins0 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mp_enable),
        .img(cnn_ins0.x),
        // .convimg(convimg),
        .complete(mp_complete[0])
    );


    cnn #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) cnn_ins1 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .img(img),
        .kernel(ker2),
        // .x(x),
        .complete(cnn_complete[1])
    );

    maxpool #(
        .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
        .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
        .KERNEL_SIZE(MAXPOOL_KERNEL)
    ) ma_ins1 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mp_enable),
        .img(cnn_ins1.x),
        // .convimg(convimg),
        .complete(mp_complete[1])
    );

    cnn #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) cnn_ins2 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .img(img),
        .kernel(ker3),
        // .x(x),
        .complete(cnn_complete[2])
    );

    maxpool #(
        .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
        .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
        .KERNEL_SIZE(MAXPOOL_KERNEL)
    ) ma_ins2 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mp_enable),
        .img(cnn_ins2.x),
        // .convimg(convimg),
        .complete(mp_complete[2])
    );

    cnn #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) cnn_ins3 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .img(img),
        .kernel(ker4),
        // .x(x),
        .complete(cnn_complete[3])
    );

    maxpool #(
        .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
        .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
        .KERNEL_SIZE(MAXPOOL_KERNEL)
    ) ma_ins3 (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mp_enable),
        .img(cnn_ins3.x),
        // .convimg(convimg),
        .complete(mp_complete[3])
    );

    logic signed [31:0] flatten[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];
    wire flatten_enable;
    logic flatten_complete;
    assign flatten_enable = &mp_complete;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flatten_complete <= 0;
            for (int i = 0; i < MAXPOOL_SIZE*MAXPOOL_SIZE; i++) begin
                flatten[i] <= 0;
                flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
                flatten[2*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
                flatten[3*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
            end
        end else if (flatten_enable) begin
            for (int i = 0; i < MAXPOOL_SIZE*MAXPOOL_SIZE; i++) begin
                flatten[i] <= ma_ins0.convimg[i];
                flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins1.convimg[i];
                flatten[2*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins2.convimg[i];
                flatten[3*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins3.convimg[i];
            end
            flatten_complete <= 1;
        end else begin
            flatten_complete <= 0;
        end
    end

    logic signed [31:0] w1[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
    logic signed [31:0] w2[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
    logic signed [31:0] b1;
    logic signed [31:0] b2;
    always_comb begin
        for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS; k = k+1) begin
            w1[k] = weights[k];
            w2[k] = weights[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
        end
        b1 = biases[0];
        b2 = biases[1];
    end

    logic neuron_st;
    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            neuron_st <= 0;
        end
        else begin
            if(flatten_complete) begin
                neuron_st <= 1;
            end
        end
    end

    logic [NO_NEURONS-1:0] neurons_comp;
    neuron #(
        .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
    ) n_ins0 (
        .clk(clk),
        .rst_n(rst_n),
        .activation(ACTIVATION),
        .inputlayer(flatten),
        .weights(w1),
        .bias(b1),
        .enable(neuron_st),
        .complete(neurons_comp[0])
    );

    neuron #(
        .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
    ) n_ins1 (
        .clk(clk),
        .rst_n(rst_n),
        .activation(ACTIVATION),
        .inputlayer(flatten),
        .weights(w2),
        .bias(b2),
        .enable(neuron_st),
        .complete(neurons_comp[1])
    );

    wire signed [31:0] l = n_ins0.outputneuron;
    wire signed [31:0] m = n_ins1.outputneuron;



    wire [31:0]f1 = flatten[0];
    wire [31:0]f2 = flatten[1]; 
    wire [31:0]f3 = flatten[MAXPOOL_SIZE*MAXPOOL_SIZE];
    wire [31:0]f4 = flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+1];



    assign complete = &neurons_comp;


    // wire mp_enable;
    // assign mp_enable = &cnn_complete;
    // logic [NO_KERNELS-1:0] mp_complete;
    // wire flatten_enable;
    // assign flatten_enable = &mp_complete;

    // logic [NO_KERNELS-1:0] flatten_complete;

    // logic signed [31:0] flattend[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];

    // // Generate multiple CNN blocks
    // genvar i;
    // generate
    //     for (i = 0; i < NO_KERNELS; i = i + 1) begin : gen_cnn
            
    //         // Kernel for this CNN block
    //         logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
    //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
    //         // Output from this CNN block
    //         wire signed [31:0] x[CONV_SIZE-1:0];
    //         // wire signed [31:0][(MAXPOOL_SIZE*MAXPOOL_SIZE)-1:0]convimg;
            
    //         // // Extract kernel weights for this block
    //         always_comb begin
    //             for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
    //                 ker[j] <= kernels[i*KERNEL_ELEMENTS + j];
    //             end
    //         end
            
    //         // CNN instance
    //         cnn #(
    //             .IMG_HEIGHT(IMG_HEIGHT),
    //             .IMG_WIDTH(IMG_WIDTH),
    //             .KERNEL_SIZE(KERNEL_SIZE)
    //         ) cnn_inst (
    //             .clk(clk),
    //             .rst_n(rst_n),
    //             .enable(enable),
    //             .img(img),
    //             .kernel(ker),
    //             .x(x),
    //             .complete(cnn_complete[i])
    //         );

    //         maxpool #(
    //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
    //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1),
    //             .KERNEL_SIZE(MAXPOOL_KERNEL)
    //         ) ma_inst (
    //             .clk(clk),
    //             .rst_n(rst_n),
    //             .enable(mp_enable),
    //             .img(x),
    //             // .convimg(convimg),
    //             .complete(mp_complete[i])
    //         );

    //         // flatten #(
    //         //     .HEIGHT(MAXPOOL_SIZE),
    //         //     .WIDTH(MAXPOOL_SIZE),
    //         //     .MAPS(NO_KERNELS),
    //         //     .MAP(i)
    //         // ) fl_inst (
    //         //     .clk(clk),
    //         //     .rst_n(rst_n),
    //         //     .enable(flatten_enable),
    //         //     .cnnmaps(ma_inst.convimg[0]),
    //         //     // .flat(flattend),
    //         //     .done(flatten_complete[i])
    //         // );

    //         always_comb begin
    //             for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE; k = k+1) begin
    //                 if(flatten_enable) begin
    //                     flattend[MAXPOOL_SIZE*MAXPOOL_SIZE*i+k] <= ma_inst.convimg[k];
    //                 end
    //             end
    //         end

    //     end
    // endgenerate

    // // assign complete = &flatten_complete;
    // assign complete = &mp_complete;
    // wire [7:0]g;
    // assign g = gen_cnn[0].cnn_inst.x[0];


    // wire [31:0] cc;
    // assign cc = flattend[0];
    // wire [31:0] aa;
    // assign aa = flattend[1];
    // wire [31:0] bb;
    // assign bb = flattend[2];

    // // wire mp_enable;
    // // assign mp_enable = &cnn_complete;
    // // logic [NO_KERNELS-1:0] mp_complete;

    // // localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1);
    // // genvar a;
    // // generate
    // //     for (a = 0; a < NO_KERNELS; a = a + 1) begin : gen_max
            
    // //         // // Kernel for this CNN block
    // //         // logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
    // //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
    // //         // Output from this CNN block
    // //         logic [31:0] convimg[MAXPOOL_SIZE * MAXPOOL_SIZE - 1:0];

    // //         // // // Extract kernel weights for this block
    // //         // always_comb begin
    // //         //     for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
    // //         //         ker[j] <= kernels[a*KERNEL_ELEMENTS + j];
    // //         //     end
    // //         // end
            
    // //         // CNN instance
    // //         maxpool #(
    // //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
    // //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1)
    // //         ) ma_inst (
    // //             .clk(clk),
    // //             .rst_n(rst_n),
    // //             .enable(mp_enable),
    // //             .img(gen_cnn[a].cnn_inst.x),
    // //             .convimg(convimg),
    // //             .complete(mp_complete[a])
    // //         );
            
    // //     end
    // // endgenerate

   
endmodule