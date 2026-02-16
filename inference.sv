// // `timescale 1ns/1ps
// // `default_nettype none

// // module inference #(
// //     parameter IMG_HEIGHT = 4,
// //     parameter IMG_WIDTH = 4,
// //     parameter NO_KERNELS = 2,
// //     parameter KERNEL_SIZE = 3
// // )(
// //     input  logic             clk,
// //     input  logic             rst_n,
// //     input  logic             enable,
// //     input  logic [31:0]  img[IMG_HEIGHT*IMG_WIDTH-1:0],  // Fixed: logic instead of reg, 8-bit per pixel
// //     input  logic [31:0] kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
// //     // input  logic signed [31:0] weights[PREV_NEURONS-1:0][NO_NEURONS-1:0]
// //     output logic complete
// // );
// //     // Local parameters
// //     localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
// //     localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

// //     // CNN Layer
// //     logic [NO_KERNELS-1:0] cnn_complete;
// //     // logic mpenable; // maxpool enable
// //     // assign mpenable = &cnn_complete;

// //     logic [31:0] count;
// //     assign count = 0;
// //     logic temp;
// //     assign temp = 0;
// //     logic signed [31:0] ker[KERNEL_SIZE*KERNEL_SIZE-1:0];
// //     wire signed [31:0] x[CONV_SIZE-1:0];
// //     // assign x = 0;

// //     // initial begin
// //     //     for (int i = 0; i < CONV_SIZE; i++) begin
// //     //         x[i] = 32'b0;
// //     //     end
// //     // end


// //     always_comb begin
// //         for (int i = 0; i < KERNEL_ELEMENTS; i++) begin
// //             ker[i] <= kernels[i]; // First kernel: elements 0-8
// //         end
// //     end

// //     logic k;
// //     cnn #(
// //         .IMG_HEIGHT(IMG_HEIGHT),
// //         .IMG_WIDTH(IMG_WIDTH),
// //         .KERNEL_SIZE(KERNEL_SIZE)
// //     ) cnn_inst (
// //         .clk(clk),
// //         .rst_n(rst_n),
// //         .enable(enable),
// //         .img(img),
// //         .kernel(ker),
// //         .x(x),
// //         .complete(k)
// //     );

// //     // assign x = cnn_inst.row1;
    
// //     // always_ff @(posedge clk or negedge rst_n) begin
// //     //     if (!rst_n) begin
// //     //         count <= 0;
// //     //     end else if (enable) begin
// //     //         if(count < NO_KERNELS) begin
// //     //             if(temp == 0) begin
// //     //                 ker <= kernels[count*KERNEL_ELEMENTS-1:(count+1)*KERNEL_ELEMENTS-1];
// //     //                 temp <= 1;
// //     //                 out <= 0;
// //     //             end
// //     //             else if(temp == 1) begin
// //     //                 temp <= 0;
// //     //                 cnn #(
// //     //                     .IMG_HEIGHT(IMG_HEIGHT),
// //     //                     .IMG_WIDTH(IMG_WIDTH),
// //     //                     .KERNEL_SIZE(KERNEL_SIZE)
// //     //                 ) cnn_inst (
// //     //                     .clk(clk),
// //     //                     .rst_n(rst_n),
// //     //                     .enable(enable),
// //     //                     .img(img),
// //     //                     .kernel(ker),
// //     //                     .convimg(out),
// //     //                     .complete(cnn_complete[count])
// //     //                 );
// //     //                 count <= count + 1;
// //     //             end
// //     //         end
// //     //     end
// //     // end

// //     // Maxpool
// //     logic mpenable;
// //     assign mpenable = &cnn_complete;


// //     // Debug: Individual array elements as separate signals for GTKWave
// //     // These will show up as separate signals in GTKWave
// //     logic signed [31:0] x_elem_0, x_elem_1, x_elem_2, x_elem_3, x_elem_4, x_elem_5;
// //     logic signed [31:0] x_elem_6, x_elem_7, x_elem_8, x_elem_9, x_elem_10, x_elem_11;
// //     logic signed [31:0] x_elem_12, x_elem_13, x_elem_14, x_elem_15;
    
// //     always_comb begin
// //         x_elem_0 = x[0];
// //         x_elem_1 = x[1];
// //         x_elem_2 = x[2];
// //         x_elem_3 = x[3];
// //         // if (CONV_SIZE >= 5)  x_elem_4 = x[4];
// //         // if (CONV_SIZE >= 6)  x_elem_5 = x[5];
// //         // if (CONV_SIZE >= 7)  x_elem_6 = x[6];
// //         // if (CONV_SIZE >= 8)  x_elem_7 = x[7];
// //         // if (CONV_SIZE >= 9)  x_elem_8 = x[8];
// //         // if (CONV_SIZE >= 10) x_elem_9 = x[9];
// //         // if (CONV_SIZE >= 11) x_elem_10 = x[10];
// //         // if (CONV_SIZE >= 12) x_elem_11 = x[11];
// //         // if (CONV_SIZE >= 13) x_elem_12 = x[12];
// //         // if (CONV_SIZE >= 14) x_elem_13 = x[13];
// //         // if (CONV_SIZE >= 15) x_elem_14 = x[14];
// //         // if (CONV_SIZE >= 16) x_elem_15 = x[15];
// //     end

// //     // Debug: Kernel elements as separate signals
// //     logic signed [31:0] ker_0, ker_1, ker_2, ker_3, ker_4, ker_5, ker_6, ker_7, ker_8;
// //     always_comb begin
// //         ker_0 = ker[0]; ker_1 = ker[1]; ker_2 = ker[2];
// //         ker_3 = ker[3]; ker_4 = ker[4]; ker_5 = ker[5];
// //         ker_6 = ker[6]; ker_7 = ker[7]; ker_8 = ker[8];
// //     end

// //     assign complete = k;

        
// // endmodule

// // `timescale 1ns/1ps
// // `default_nettype none

// // module inference #(
// //     parameter IMG_HEIGHT = 6,
// //     parameter IMG_WIDTH = 6,
// //     parameter NO_KERNELS = 2,        // Number of CNN blocks to instantiate
// //     parameter KERNEL_SIZE = 3,
// //     parameter MAXPOOL_KERNEL = 2
// // )(
// //     input  logic             clk,
// //     input  logic             rst_n,
// //     input  logic             enable,
// //     input  logic signed [31:0]      img[IMG_HEIGHT*IMG_WIDTH-1:0],
// //     input  logic signed [31:0]      kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
// //     output wire              complete
// // );

// //     localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
// //     localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1;
// //     localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

// //     // Completion signals from each CNN block
// //     logic [NO_KERNELS-1:0] cnn_complete;
    
// //     wire mp_enable;
// //     assign mp_enable = &cnn_complete;
// //     logic [NO_KERNELS-1:0] mp_complete;
// //     wire flatten_enable;
// //     assign flatten_enable = &mp_complete;

// //     logic [NO_KERNELS-1:0] flatten_complete;

// //     logic signed [31:0] flattend[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];

// //     // Generate multiple CNN blocks
// //     genvar i;
// //     generate
// //         for (i = 0; i < NO_KERNELS; i = i + 1) begin : gen_cnn
            
// //             // Kernel for this CNN block
// //             logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
// //             // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
// //             // Output from this CNN block
// //             wire signed [31:0] x[CONV_SIZE-1:0];
// //             // wire signed [31:0][(MAXPOOL_SIZE*MAXPOOL_SIZE)-1:0]convimg;
            
// //             // // Extract kernel weights for this block
// //             always_comb begin
// //                 for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
// //                     ker[j] <= kernels[i*KERNEL_ELEMENTS + j];
// //                 end
// //             end
            
// //             // CNN instance
// //             cnn #(
// //                 .IMG_HEIGHT(IMG_HEIGHT),
// //                 .IMG_WIDTH(IMG_WIDTH),
// //                 .KERNEL_SIZE(KERNEL_SIZE)
// //             ) cnn_inst (
// //                 .clk(clk),
// //                 .rst_n(rst_n),
// //                 .enable(enable),
// //                 .img(img),
// //                 .kernel(ker),
// //                 .x(x),
// //                 .complete(cnn_complete[i])
// //             );

// //             maxpool #(
// //                 .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
// //                 .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1),
// //                 .KERNEL_SIZE(MAXPOOL_KERNEL)
// //             ) ma_inst (
// //                 .clk(clk),
// //                 .rst_n(rst_n),
// //                 .enable(mp_enable),
// //                 .img(x),
// //                 // .convimg(convimg),
// //                 .complete(mp_complete[i])
// //             );

// //             // flatten #(
// //             //     .HEIGHT(MAXPOOL_SIZE),
// //             //     .WIDTH(MAXPOOL_SIZE),
// //             //     .MAPS(NO_KERNELS),
// //             //     .MAP(i)
// //             // ) fl_inst (
// //             //     .clk(clk),
// //             //     .rst_n(rst_n),
// //             //     .enable(flatten_enable),
// //             //     .cnnmaps(ma_inst.convimg[0]),
// //             //     // .flat(flattend),
// //             //     .done(flatten_complete[i])
// //             // );

// //             always_comb begin
// //                 for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE; k = k+1) begin
// //                     if(flatten_enable) begin
// //                         flattend[MAXPOOL_SIZE*MAXPOOL_SIZE*i+k] <= ma_inst.convimg[k];
// //                     end
// //                 end
// //             end

// //         end
// //     endgenerate

// //     // assign complete = &flatten_complete;
// //     assign complete = &mp_complete;
// //     wire [7:0]g;
// //     assign g = gen_cnn[0].cnn_inst.x[0];


// //     wire [31:0] cc;
// //     assign cc = flattend[0];
// //     wire [31:0] aa;
// //     assign aa = flattend[1];
// //     wire [31:0] bb;
// //     assign bb = flattend[2];

// //     // wire mp_enable;
// //     // assign mp_enable = &cnn_complete;
// //     // logic [NO_KERNELS-1:0] mp_complete;

// //     // localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1);
// //     // genvar a;
// //     // generate
// //     //     for (a = 0; a < NO_KERNELS; a = a + 1) begin : gen_max
            
// //     //         // // Kernel for this CNN block
// //     //         // logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
// //     //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
// //     //         // Output from this CNN block
// //     //         logic [31:0] convimg[MAXPOOL_SIZE * MAXPOOL_SIZE - 1:0];

// //     //         // // // Extract kernel weights for this block
// //     //         // always_comb begin
// //     //         //     for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
// //     //         //         ker[j] <= kernels[a*KERNEL_ELEMENTS + j];
// //     //         //     end
// //     //         // end
            
// //     //         // CNN instance
// //     //         maxpool #(
// //     //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
// //     //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1)
// //     //         ) ma_inst (
// //     //             .clk(clk),
// //     //             .rst_n(rst_n),
// //     //             .enable(mp_enable),
// //     //             .img(gen_cnn[a].cnn_inst.x),
// //     //             .convimg(convimg),
// //     //             .complete(mp_complete[a])
// //     //         );
            
// //     //     end
// //     // endgenerate

   
// // endmodule


// `timescale 1ns/1ps
// `default_nettype none

// module inference #(
//     parameter IMG_HEIGHT = 28,
//     parameter IMG_WIDTH = 28,
//     parameter NO_KERNELS = 4,        // Number of CNN blocks to instantiate
//     parameter KERNEL_SIZE = 3,
//     parameter MAXPOOL_KERNEL = 2,
//     parameter NO_NEURONS = 10,
//     parameter ACTIVATION = 0,
//     parameter LINEAR_SIZE = ((((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1)
// )(
//     input  logic             clk,
//     input  logic             rst_n,
//     input  logic             enable,
//     input  logic signed [31:0]      img[IMG_HEIGHT*IMG_WIDTH-1:0],
//     input  logic signed [31:0]      kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
//     input logic signed [31:0] weights[NO_NEURONS*NO_KERNELS*LINEAR_SIZE*LINEAR_SIZE-1:0],
//     input logic signed [31:0] biases[NO_NEURONS-1:0],
//     output wire              complete
// );

//     localparam CONV_SIZE = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
//     localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1;
//     localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;

//     // Completion signals
//     logic [NO_KERNELS-1:0] cnn_complete;
//     logic [NO_KERNELS-1:0] mp_complete;
//     wire mp_enable;
//     assign mp_enable = &cnn_complete;

// //     logic signed [31:0] ker1[0:KERNEL_ELEMENTS-1];
//     logic signed [31:0] ker2[0:KERNEL_ELEMENTS-1];
//     logic signed [31:0] ker3[0:KERNEL_ELEMENTS-1];
//     logic signed [31:0] ker4[0:KERNEL_ELEMENTS-1];

//     // Explicit wires for CNN outputs
//     // logic signed [31:0] cnn0_out [ (IMG_HEIGHT-KERNEL_SIZE+1)*(IMG_WIDTH-KERNEL_SIZE+1)-1:0 ];
//     // logic signed [31:0] cnn1_out [ (IMG_HEIGHT-KERNEL_SIZE+1)*(IMG_WIDTH-KERNEL_SIZE+1)-1:0 ];
//     // logic signed [31:0] cnn2_out [ (IMG_HEIGHT-KERNEL_SIZE+1)*(IMG_WIDTH-KERNEL_SIZE+1)-1:0 ];
//     // logic signed [31:0] cnn3_out [ (IMG_HEIGHT-KERNEL_SIZE+1)*(IMG_WIDTH-KERNEL_SIZE+1)-1:0 ];

//     always_comb begin
//         for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
//             ker1[j] = kernels[0*KERNEL_ELEMENTS + j];
//             ker2[j] = kernels[1*KERNEL_ELEMENTS + j];
//             ker3[j] = kernels[2*KERNEL_ELEMENTS + j];
//             ker4[j] = kernels[3*KERNEL_ELEMENTS + j];
//         end
//     end

//     cnn #(
//         .IMG_HEIGHT(IMG_HEIGHT),
//         .IMG_WIDTH(IMG_WIDTH),
//         .KERNEL_SIZE(KERNEL_SIZE)
//     ) cnn_ins0 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(enable),
//         .img(img),
//         .kernel(ker1),
//         .x(cnn0_out),
//         .complete(cnn_complete[0])
//     );

//     maxpool #(
//         .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//         .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
//         .KERNEL_SIZE(MAXPOOL_KERNEL)
//     ) ma_ins0 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(mp_enable),
//         .img(cnn0_out),
        // .convimg(convimg),
//         .complete(mp_complete[0])
//     );


//     cnn #(
//         .IMG_HEIGHT(IMG_HEIGHT),
//         .IMG_WIDTH(IMG_WIDTH),
//         .KERNEL_SIZE(KERNEL_SIZE)
//     ) cnn_ins1 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(enable),
//         .img(img),
//         .kernel(ker2),
//         .x(cnn1_out),
//         .complete(cnn_complete[1])
//     );

//     maxpool #(
//         .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//         .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
//         .KERNEL_SIZE(MAXPOOL_KERNEL)
//     ) ma_ins1 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(mp_enable),
//         .img(cnn1_out),
        // .convimg(convimg),
//         .complete(mp_complete[1])
//     );

//     cnn #(
//         .IMG_HEIGHT(IMG_HEIGHT),
//         .IMG_WIDTH(IMG_WIDTH),
//         .KERNEL_SIZE(KERNEL_SIZE)
//     ) cnn_ins2 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(enable),
//         .img(img),
//         .kernel(ker3),
//         .x(cnn2_out),
//         .complete(cnn_complete[2])
//     );

//     maxpool #(
//         .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//         .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
//         .KERNEL_SIZE(MAXPOOL_KERNEL)
//     ) ma_ins2 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(mp_enable),
//         .img(cnn2_out),
        // .convimg(convimg),
//         .complete(mp_complete[2])
//     );

//     cnn #(
//         .IMG_HEIGHT(IMG_HEIGHT),
//         .IMG_WIDTH(IMG_WIDTH),
//         .KERNEL_SIZE(KERNEL_SIZE)
//     ) cnn_ins3 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(enable),
//         .img(img),
//         .kernel(ker4),
//         .x(cnn3_out),
//         .complete(cnn_complete[3])
//     );

//     maxpool #(
//         .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//         .IMG_WIDTH(IMG_WIDTH - KERNEL_SIZE + 1),
//         .KERNEL_SIZE(MAXPOOL_KERNEL)
//     ) ma_ins3 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .enable(mp_enable),
//         .img(cnn3_out),
        // .convimg(convimg),
//         .complete(mp_complete[3])
//     );

//     logic signed [31:0] flatten[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];
//     wire flatten_enable;
//     logic flatten_complete;
//     assign flatten_enable = &mp_complete;
//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             flatten_complete <= 0;
//             for (int i = 0; i < MAXPOOL_SIZE*MAXPOOL_SIZE; i++) begin
//                 flatten[i] <= 0;
//                 flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
//                 flatten[2*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
//                 flatten[3*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= 0;
//             end
//         end else if (flatten_enable) begin
//             for (int i = 0; i < MAXPOOL_SIZE*MAXPOOL_SIZE; i++) begin
//                 flatten[i] <= ma_ins0.convimg[i];
//                 flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins1.convimg[i];
//                 flatten[2*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins2.convimg[i];
//                 flatten[3*MAXPOOL_SIZE*MAXPOOL_SIZE+i] <= ma_ins3.convimg[i];
//             end
//             flatten_complete <= 1;
//         end else begin
//             flatten_complete <= 0;
//         end
//     end

//     logic signed [31:0] w1[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w2[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w3[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w4[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w5[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w6[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w7[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w8[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w9[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] w10[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS-1:0];
//     logic signed [31:0] b1;
//     logic signed [31:0] b2;
//     logic signed [31:0] b3;
//     logic signed [31:0] b4;
//     logic signed [31:0] b5;
//     logic signed [31:0] b6;
//     logic signed [31:0] b7;
//     logic signed [31:0] b8;
//     logic signed [31:0] b9;
//     logic signed [31:0] b10;
//     always_comb begin
//         for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS; k = k+1) begin
//             w1[k] = weights[k];
//             w2[k] = weights[MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w3[k] = weights[2*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w4[k] = weights[3*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w5[k] = weights[4*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w6[k] = weights[5*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w7[k] = weights[6*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w8[k] = weights[7*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w9[k] = weights[8*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//             w10[k] = weights[9*MAXPOOL_SIZE*MAXPOOL_SIZE*NO_KERNELS+k];
//         end
//         b1 = biases[0];
//         b2 = biases[1];
//         b3 = biases[2];
//         b4 = biases[3];
//         b5 = biases[4];
//         b6 = biases[5];
//         b7 = biases[6];
//         b8 = biases[7];
//         b9 = biases[8];
//         b10 = biases[9];
//     end

//     logic neuron_st;
//     always_ff @ (posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             neuron_st <= 0;
//         end
//         else begin
//             if(flatten_complete) begin
//                 neuron_st <= 1;
//             end
//         end
//     end

//     logic [NO_NEURONS-1:0] neurons_comp;
//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins0 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w1),
//         .bias(b1),
//         .enable(neuron_st),
//         .complete(neurons_comp[0])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins1 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w2),
//         .bias(b2),
//         .enable(neuron_st),
//         .complete(neurons_comp[1])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins2 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w3),
//         .bias(b3),
//         .enable(neuron_st),
//         .complete(neurons_comp[2])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins3 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w4),
//         .bias(b4),
//         .enable(neuron_st),
//         .complete(neurons_comp[3])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins4 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w5),
//         .bias(b5),
//         .enable(neuron_st),
//         .complete(neurons_comp[4])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins5 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w6),
//         .bias(b6),
//         .enable(neuron_st),
//         .complete(neurons_comp[5])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins6 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w7),
//         .bias(b7),
//         .enable(neuron_st),
//         .complete(neurons_comp[6])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins7 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w8),
//         .bias(b8),
//         .enable(neuron_st),
//         .complete(neurons_comp[7])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins8 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w9),
//         .bias(b9),
//         .enable(neuron_st),
//         .complete(neurons_comp[8])
//     );

//     neuron #(
//         .PREV_NEURONS(NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE)
//     ) n_ins9 (
//         .clk(clk),
//         .rst_n(rst_n),
//         .activation(ACTIVATION),
//         .inputlayer(flatten),
//         .weights(w10),
//         .bias(b10),
//         .enable(neuron_st),
//         .complete(neurons_comp[9])
//     );

//     wire signed [31:0] o1 = n_ins0.outputneuron;
//     wire signed [31:0] o2 = n_ins1.outputneuron;
//     wire signed [31:0] o3 = n_ins2.outputneuron;
//     wire signed [31:0] o4 = n_ins3.outputneuron;
//     wire signed [31:0] o5 = n_ins4.outputneuron;
//     wire signed [31:0] o6 = n_ins5.outputneuron;
//     wire signed [31:0] o7 = n_ins6.outputneuron;
//     wire signed [31:0] o8 = n_ins7.outputneuron;
//     wire signed [31:0] o9 = n_ins8.outputneuron;
//     wire signed [31:0] o10 = n_ins9.outputneuron;



//     wire [31:0]f1 = flatten[0];
//     wire [31:0]f2 = flatten[1]; 
//     wire [31:0]f3 = flatten[MAXPOOL_SIZE*MAXPOOL_SIZE];
//     wire [31:0]f4 = flatten[MAXPOOL_SIZE*MAXPOOL_SIZE+1];



//     assign complete = &neurons_comp;


//     // wire mp_enable;
//     // assign mp_enable = &cnn_complete;
//     // logic [NO_KERNELS-1:0] mp_complete;
//     // wire flatten_enable;
//     // assign flatten_enable = &mp_complete;

//     // logic [NO_KERNELS-1:0] flatten_complete;

//     // logic signed [31:0] flattend[NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0];

//     // // Generate multiple CNN blocks
//     // genvar i;
//     // generate
//     //     for (i = 0; i < NO_KERNELS; i = i + 1) begin : gen_cnn
            
//     //         // Kernel for this CNN block
//     //         logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
//     //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
//     //         // Output from this CNN block
//     //         wire signed [31:0] x[CONV_SIZE-1:0];
//     //         // wire signed [31:0][(MAXPOOL_SIZE*MAXPOOL_SIZE)-1:0]convimg;
            
//     //         // // Extract kernel weights for this block
//     //         always_comb begin
//     //             for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
//     //                 ker[j] <= kernels[i*KERNEL_ELEMENTS + j];
//     //             end
//     //         end
            
//     //         // CNN instance
//     //         cnn #(
//     //             .IMG_HEIGHT(IMG_HEIGHT),
//     //             .IMG_WIDTH(IMG_WIDTH),
//     //             .KERNEL_SIZE(KERNEL_SIZE)
//     //         ) cnn_inst (
//     //             .clk(clk),
//     //             .rst_n(rst_n),
//     //             .enable(enable),
//     //             .img(img),
//     //             .kernel(ker),
//     //             .x(x),
//     //             .complete(cnn_complete[i])
//     //         );

//     //         maxpool #(
//     //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//     //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1),
//     //             .KERNEL_SIZE(MAXPOOL_KERNEL)
//     //         ) ma_inst (
//     //             .clk(clk),
//     //             .rst_n(rst_n),
//     //             .enable(mp_enable),
//     //             .img(x),
//     //             // .convimg(convimg),
//     //             .complete(mp_complete[i])
//     //         );

//     //         // flatten #(
//     //         //     .HEIGHT(MAXPOOL_SIZE),
//     //         //     .WIDTH(MAXPOOL_SIZE),
//     //         //     .MAPS(NO_KERNELS),
//     //         //     .MAP(i)
//     //         // ) fl_inst (
//     //         //     .clk(clk),
//     //         //     .rst_n(rst_n),
//     //         //     .enable(flatten_enable),
//     //         //     .cnnmaps(ma_inst.convimg[0]),
//     //         //     // .flat(flattend),
//     //         //     .done(flatten_complete[i])
//     //         // );

//     //         always_comb begin
//     //             for (int k = 0; k < MAXPOOL_SIZE*MAXPOOL_SIZE; k = k+1) begin
//     //                 if(flatten_enable) begin
//     //                     flattend[MAXPOOL_SIZE*MAXPOOL_SIZE*i+k] <= ma_inst.convimg[k];
//     //                 end
//     //             end
//     //         end

//     //     end
//     // endgenerate

//     // // assign complete = &flatten_complete;
//     // assign complete = &mp_complete;
//     // wire [7:0]g;
//     // assign g = gen_cnn[0].cnn_inst.x[0];


//     // wire [31:0] cc;
//     // assign cc = flattend[0];
//     // wire [31:0] aa;
//     // assign aa = flattend[1];
//     // wire [31:0] bb;
//     // assign bb = flattend[2];

//     // // wire mp_enable;
//     // // assign mp_enable = &cnn_complete;
//     // // logic [NO_KERNELS-1:0] mp_complete;

//     // // localparam MAXPOOL_SIZE = (((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1);
//     // // genvar a;
//     // // generate
//     // //     for (a = 0; a < NO_KERNELS; a = a + 1) begin : gen_max
            
//     // //         // // Kernel for this CNN block
//     // //         // logic signed [31:0] ker[KERNEL_ELEMENTS-1:0];
//     // //         // assign ker = kernels[i*KERNEL_ELEMENTS:(i+1)*KERNEL_ELEMENTS-1];
            
//     // //         // Output from this CNN block
//     // //         logic [31:0] convimg[MAXPOOL_SIZE * MAXPOOL_SIZE - 1:0];

//     // //         // // // Extract kernel weights for this block
//     // //         // always_comb begin
//     // //         //     for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
//     // //         //         ker[j] <= kernels[a*KERNEL_ELEMENTS + j];
//     // //         //     end
//     // //         // end
            
//     // //         // CNN instance
//     // //         maxpool #(
//     // //             .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
//     // //             .IMG_WIDTH(IMG_HEIGHT - KERNEL_SIZE + 1)
//     // //         ) ma_inst (
//     // //             .clk(clk),
//     // //             .rst_n(rst_n),
//     // //             .enable(mp_enable),
//     // //             .img(gen_cnn[a].cnn_inst.x),
//     // //             .convimg(convimg),
//     // //             .complete(mp_complete[a])
//     // //         );
            
//     // //     end
//     // // endgenerate

   
// endmodule































`timescale 1ns/1ps
`default_nettype none

module inference #(
    parameter IMG_HEIGHT     = 28,
    parameter IMG_WIDTH      = 28,
    parameter NO_KERNELS     = 4,        // keep 4 passes
    parameter KERNEL_SIZE    = 3,
    parameter MAXPOOL_KERNEL = 2,
    parameter NO_NEURONS     = 1,
    parameter ACTIVATION     = 0,
    parameter LINEAR_SIZE    = ((((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1)
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    enable,
    input  wire signed [31:0]      img[IMG_HEIGHT*IMG_WIDTH-1:0],
    input  wire signed [31:0]      kernels[NO_KERNELS*KERNEL_SIZE*KERNEL_SIZE-1:0],
    output wire                    complete,
    output wire signed [31:0]      o0,
	 output wire signed [31:0] y,
	 output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5,
	 input wire display_en,
	 input wire [9:0] SW
);

    localparam CONV_SIZE       = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1);
    localparam MAXPOOL_SIZE    = (((IMG_HEIGHT - KERNEL_SIZE + 1) - MAXPOOL_KERNEL) >> 1) + 1;
    localparam KERNEL_ELEMENTS = KERNEL_SIZE * KERNEL_SIZE;
    localparam int CH_SIZE     = MAXPOOL_SIZE * MAXPOOL_SIZE;          // e.g., 169
    localparam int PREV_NEURONS= NO_KERNELS * CH_SIZE;                 // e.g., 676

    // ---------------- KERNEL SELECTOR (one CNN reused 4 times) ----------------
    logic [1:0] ker_sel = 0;
    logic signed [31:0] ker_bus[0:KERNEL_ELEMENTS-1];

    // ---------------- 4-pass controller ----------------
    typedef enum logic [2:0] {S_IDLE, S_CLEAR, S_CNN, S_POOL, S_GAP, S_DONE} st_t;
    st_t st;
    logic cnn_en_r, mp_en_r, clear_accum_r;
    logic complete_r;

    wire cnn_enable = cnn_en_r;

    always_comb begin
        for (int j = 0; j < KERNEL_ELEMENTS; j = j+1) begin
            unique case (ker_sel)
                2'd0: ker_bus[j] = kernels[0*KERNEL_ELEMENTS + j];
                2'd1: ker_bus[j] = kernels[1*KERNEL_ELEMENTS + j];
                2'd2: ker_bus[j] = kernels[2*KERNEL_ELEMENTS + j];
                default: ker_bus[j] = kernels[3*KERNEL_ELEMENTS + j];
            endcase
        end
    end

    // ---------------- SINGLE CNN (reused) ----------------
    wire signed [31:0] cnn_out[CONV_SIZE-1:0];
    // Allow CNN instance to drive completion; do not tie-off to constant
    wire cnn_complete;
//	 logic signed [31:0] y;

    // Drive CNN enable from state machine to allow reset between passes
    // Keep CNN enabled until Maxpool is done (P_FEED) so cnn_complete stays high

    cnn #(
        .IMG_HEIGHT(IMG_HEIGHT),
        .IMG_WIDTH (IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) cnn_ins (
        .clk(clk),
        .rst_n(rst_n),
        .enable(cnn_enable),
        .img(img),
        .kernel(ker_bus),
        .x(cnn_out),
        .complete(cnn_complete)
//		,.y(y)
    );

    // ---------------- ONE maxpool (stream-only) ----------------
    // single stream wires
    // wire               mp_v;
    // wire signed [31:0] mp_d;
    // wire               mp_done;
    // wire               mp_r;

    // enable maxpool when the current CNN pass is complete (one-cycle delayed to avoid same-cycle read/write hazards)
    // logic mp_enable_d;
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) mp_enable_d <= 1'b0;
    //     else        mp_enable_d <= cnn_complete;
    // end
    wire mp_enable_this = mp_en_r;

    wire [NO_KERNELS-1:0] mp_complete; // kept for compatibility (bit 0 used)
    assign mp_complete[NO_KERNELS-1:1] = '0;

    // Maxpool streaming signals
    // wire               mp_v;
    // wire signed [31:0] mp_d;
    // wire               mp_done;

    logic signed [63:0] neuron0;
	 logic signed [31:0] outmax [675:0];
    
    maxpool #(
        .IMG_HEIGHT(IMG_HEIGHT - KERNEL_SIZE + 1),
        .IMG_WIDTH (IMG_WIDTH  - KERNEL_SIZE + 1),
        .KERNEL_SIZE(MAXPOOL_KERNEL)
        // .STREAM_ONLY(1)
    ) ma_ins (
        .clk(clk), 
        .rst_n(rst_n), 
        .enable(mp_enable_this),
        .pass_sel(ker_sel),
        .clear_accum(clear_accum_r),
        .img(cnn_out),
        .convimg(outmax),
        .neuron0(neuron0),
        .complete(mp_complete[0])
//		  ,.a(y)
    );

        // ---------------- 4-pass FSM: CNN(pass)->maxpool(pass) x4 ----------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            st            <= S_IDLE;
            ker_sel        <= 2'd0;
            cnn_en_r       <= 1'b0;
            mp_en_r        <= 1'b0;
            clear_accum_r  <= 1'b0;
            complete_r     <= 1'b0;
        end else begin
            if (!enable) begin
                st            <= S_IDLE;
                ker_sel        <= 2'd0;
                cnn_en_r       <= 1'b0;
                mp_en_r        <= 1'b0;
                clear_accum_r  <= 1'b0;
                complete_r     <= 1'b0;
            end else begin
                unique case (st)
                    S_IDLE: begin
                        ker_sel       <= 2'd0;
                        cnn_en_r      <= 1'b0;
                        mp_en_r       <= 1'b0;
                        clear_accum_r <= 1'b1;   // clear neuron accumulators while maxpool disabled
                        complete_r    <= 1'b0;
                        st           <= S_CLEAR;
                    end

                    S_CLEAR: begin
                        clear_accum_r <= 1'b0;
                        cnn_en_r      <= 1'b1;   // start CNN for ker_sel=0
                        st           <= S_CNN;
                    end

                    S_CNN: begin
                        if (cnn_complete) begin
                            cnn_en_r <= 1'b0;    // stop/reset CNN counters (output array holds results)
                            mp_en_r  <= 1'b1;    // run maxpool+MAC for this pass
                            st      <= S_POOL;
                        end
                    end

                    S_POOL: begin
                        if (mp_complete[0]) begin
                            mp_en_r <= 1'b0;     // force maxpool counters/complete to reset
                            st     <= S_GAP;
                        end
                    end

                    S_GAP: begin
                        if (ker_sel == 2'd3) begin
                            complete_r <= 1'b1;
                            st        <= S_DONE;
                        end else begin
                            ker_sel   <= ker_sel + 2'd1;  // next kernel/channel
                            cnn_en_r  <= 1'b1;            // start next CNN pass
                            st       <= S_CNN;
                        end
                    end

                    default: begin // S_DONE
                        cnn_en_r      <= 1'b0;
                        mp_en_r       <= 1'b0;
                        clear_accum_r <= 1'b0;
                    end
                endcase
            end
        end
    end


    // // ---------------- Bias + Neuron stream (unchanged) ----------------
    // // logic signed [31:0] BIAS_INIT [0:NO_NEURONS-1] = '{
    // //     32'sh0005_0000
    // // };
    // logic signed [31:0] bias_arr;
    // logic signed [31:0] bias_arr0;
    // // Constant bias: use continuous assign to avoid empty always_comb sensitivity
    // assign bias_arr0 = 32'sh0005_0000;

    // logic ns_enable;
    // logic ns_in_valid;
    // logic signed [31:0] ns_in_data;
    // logic                n_ready   [0:NO_NEURONS-1];
    // logic                n_complete[0:NO_NEURONS-1];
    // logic signed [31:0]  n_out     [0:NO_NEURONS-1];
    // wire  ns_all_ready = n_ready[0];

    // neuron #(.PREV_NEURONS(PREV_NEURONS), .WEIGHTS_MIF("fc_w_neuron0.mif")) n0 (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .enable(ns_enable),
    //     .activation(0),
    //     .in_valid(ns_in_valid),
    //     .in_data(ns_in_data),
    //     .in_ready(n_ready[0]),
    //     .bias(bias_arr0),
    //     .outputneuron(n_out[0]),
    //     .complete(n_complete[0])
    // );

    // // ---------------- Pass controller (same passes, single stream) ----------------
    // typedef enum logic [2:0] {P_IDLE, P_CONV, P_POOL, P_FEED, P_NEXT, P_WAIT_NEURON, P_DONE} pst_t;
    // pst_t pst;
    // logic [1:0] pass;

    // // single back-pressure
    // assign mp_r = ns_all_ready;

    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         pst         <= P_IDLE;
    //         ker_sel     <= 2'd0;
    //         pass        <= 2'd0;
    //         ns_enable   <= 1'b0;
    //         ns_in_valid <= 1'b0;
    //         ns_in_data  <= '0;
    //     end else begin
    //         unique case (pst)
    //             P_IDLE: begin
    //                 ns_enable   <= 1'b0;
    //                 ns_in_valid <= 1'b0;
    //                 ker_sel     <= 2'd0;
    //                 pass        <= 2'd0;
    //                 if (enable) pst <= P_CONV;
    //             end
    //             P_CONV: begin
    //                 // run CNN for the selected kernel
    //                 if (cnn_complete) pst <= P_POOL;
    //             end
    //             P_POOL: begin
    //                 // start feeding pooled stream to neuron(s)
    //                 ns_enable <= 1'b1;
    //                 pst <= P_FEED;
    //             end
    //             P_FEED: begin
    //                 ns_in_valid <= mp_v;
    //                 ns_in_data  <= mp_d;
    //                 if (mp_done) begin
    //                     ns_in_valid <= 1'b0;
    //                     pst <= (pass == 2'd3) ? P_WAIT_NEURON : P_NEXT;
    //                 end
    //             end
    //             P_NEXT: begin
    //                 pass    <= pass + 2'd1;
    //                 ker_sel <= pass + 2'd1;   // next kernel
    //                 pst     <= P_CONV;
    //             end
    //             P_WAIT_NEURON: begin
    //                 if (n_complete[0]) begin
    //                     ns_enable <= 1'b0;
    //                     pst <= P_DONE;
    //                 end
    //             end
    //             default: begin // P_DONE
    //                 ns_in_valid <= 1'b0;
    //             end
    //         endcase
    //     end
    // end

    // Signal completion at the end of the full pipeline (neuron complete), not just CNN
    assign complete = complete_r;
    assign o0 = neuron0;
	 assign y = outmax[0];
	 
	 function automatic [6:0] hex7(input logic [3:0] nib);
        case (nib)
            4'h0: hex7 = 7'b1000000;
            4'h1: hex7 = 7'b1111001;
            4'h2: hex7 = 7'b0100100;
            4'h3: hex7 = 7'b0110000;
            4'h4: hex7 = 7'b0011001;
            4'h5: hex7 = 7'b0010010;
            4'h6: hex7 = 7'b0000010;
            4'h7: hex7 = 7'b1111000;
            4'h8: hex7 = 7'b0000000;
            4'h9: hex7 = 7'b0010000;
            4'hA: hex7 = 7'b0001000;
            4'hB: hex7 = 7'b0000011;
            4'hC: hex7 = 7'b1000110;
            4'hD: hex7 = 7'b0100001;
            4'hE: hex7 = 7'b0000110;
            4'hF: hex7 = 7'b0001110;
            default: hex7 = 7'b1111111;
        endcase
    endfunction
	 
	 wire [31:0]k;
	 assign k = outmax[SW[4:2]];
	 
	 assign HEX0 = display_en ? hex7(k[11:8]) : 7'b1111111;
    assign HEX1 = display_en ? hex7(k[15:12]) : 7'b1111111;
    assign HEX2 = display_en ? hex7(k[19:16]) : 7'b1111111;
    assign HEX3 = display_en ? hex7(k[23:20]) : 7'b1111111;
    // Show fractional part (bits 15:8) on HEX5..HEX4 after delay; else blank
    assign HEX4 = display_en ? hex7(k[27:24]) : 7'b1111111;
    assign HEX5 = display_en ? hex7(k[31:28]) : 7'b1111111;

endmodule

