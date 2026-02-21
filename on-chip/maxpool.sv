//`timescale 1ns/1ps 
//`default_nettype none
//
//module maxpool #(
//    parameter IMG_HEIGHT = 26, // Size for MNIST images
//    parameter IMG_WIDTH  = 26,
//    parameter KERNEL_SIZE = 2, // Kernel size for custom CNN model
//    parameter OUT_H       = ((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_W       = ((IMG_WIDTH  - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_ELEMS   = OUT_H * OUT_W,
//    parameter string WEIGHTS_MIF = "fc_w_neuron7.mif",
//    parameter string WEIGHTS_INIT_FILE = "src/fc_w_neuron0.memh"
//    // parameter bit STREAM_ONLY = 1 // only stream and do not store
// )(
//    input  logic               clk,
//    input  logic               rst_n,
//    input  logic               enable,
//    input  logic signed [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0],
//    output  logic signed [63:0] neuron0,
////    // input logic signed [31:0] neuron1,
////    // input logic signed [31:0] neuron2,
////    // input logic signed [31:0] neuron3,
////    // input logic signed [31:0] neuron4,
////    // input logic signed [31:0] neuron5,
////    // input logic signed [31:0] neuron6,
////    // input logic signed [31:0] neuron7,
////    // input logic signed [31:0] neuron8,
////    // input logic signed [31:0] neuron9,
//    output logic signed [31:0] convimg[OUT_ELEMS-1:0],
//    input  logic [1:0]         pass_sel,
//    input  logic               clear_accum,
//    // output logic               out_valid,
//    // output logic signed [31:0] out_data,
//    // input  logic               out_ready,
//    // output logic               out_done,
//    output logic               complete
//);
//    // Counters
//    logic [31:0] convolutions;
//    logic [31:0] hor_align, vert_align;
//    logic [31:0] out_hor_align, out_ver_align;
//    logic [31:0] filter_oper;
//    logic [31:0] kernel_hor, kernel_vert;
//
//    // Total operations (kernel and output levels)
//    localparam int TOTAL_CONV = OUT_H * OUT_W;
//    localparam int TOTAL_TAPS = KERNEL_SIZE * KERNEL_SIZE;
//
//    // Running max for current tile
//    logic signed [31:0] running_max;
//
//    // Stream valid register
//    // logic s_valid;
//
//    logic signed [31:0] tap;
//    always_comb tap = img[(vert_align + kernel_vert)*IMG_WIDTH + (hor_align + kernel_hor)];
//
//    // --- Tie off convimg (keeps everything else unchanged and removes "no driver" warning)
//    genvar gi;
//    generate
//      for (gi = 0; gi < OUT_ELEMS; gi++) begin : G_Z
//        assign convimg[gi] = 32'sd0;
//      end
//    endgenerate
//
//    // Weight ROM (init for FPGA via MIF, for sim via readmemh)
//    localparam int WEIGHTS_DEPTH = TOTAL_CONV*4;
//    localparam int W_ADDR_W      = (WEIGHTS_DEPTH <= 1) ? 1 : $clog2(WEIGHTS_DEPTH);
//
//    // NOTE: Quartus is most reliable when ram_init_file is a literal string.
//    // Keep WEIGHTS_MIF as a parameter for your project flow, but hardcode here for inference robustness.
//    (* ramstyle = "M10K", ram_init_file = "fc_w_neuron7.mif" *)
//    logic signed [31:0] weights_mem [0:WEIGHTS_DEPTH-1];
//
//    typedef enum logic [0:0] { ST_TAPS=1'b0, ST_ACCUM=1'b1 } st_t;
//    st_t st;
//
//    logic [W_ADDR_W-1:0] w_addr, w_addr_next;
//    logic signed [31:0]  w_q;      // registered ROM output
//    logic signed [31:0]  a_q;      // activation aligned with w_q
//
//    // Compute next ROM address on the cycle we finish taps (so the ROM output aligns properly)
//    always_comb begin
//        w_addr_next = w_addr;
//        if (enable && !complete && (convolutions < TOTAL_CONV) && (st == ST_TAPS) && (filter_oper >= TOTAL_TAPS)) begin
//            w_addr_next = (pass_sel*TOTAL_CONV) + convolutions;
//        end
//    end
//
//    // Synchronous ROM read (1-cycle). Using w_addr_next avoids the "old address" problem.
//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            w_addr <= '0;
//            w_q    <= 32'sd0;
//        end else begin
//            w_addr <= w_addr_next;
//            w_q    <= weights_mem[w_addr_next];
//        end
//    end
//
//    logic signed [63:0] w64, a64, prod64;
//
//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            // Only clear convimg when not stream-only
//            // if (!STREAM_ONLY) begin
//            //     for (int i = 0; i < OUT_ELEMS; i++) convimg[i] <= 32'sd0;
//            // end
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 32'sh8000_0000; // safer max init
//            st            <= ST_TAPS;
//            a_q           <= 32'sd0;
//            if (clear_accum) neuron0 <= 32'sd0;
//            neuron0 <= 0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'sd0;
//        end else if (!enable) begin
//            // Reset state when disabled to allow restart
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 32'sh8000_0000; // safer max init
//            st            <= ST_TAPS;
//            a_q           <= 32'sd0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'd0;
//        end else if (!complete) begin
//            // out_done <= 1'b0;
//            if (convolutions < TOTAL_CONV) begin
//                if (st == ST_TAPS) begin
//                    if (filter_oper < TOTAL_TAPS) begin
//                        // tap is now a wire, so we don't assign it here
//
//                        // if (filter_oper == 0)
//                        //     running_max <= tap;
//                        // else
//                        running_max <= (tap > running_max) ? tap : running_max;
//
//                        // advance tap indices
//                        if (kernel_hor + 32'd1 < KERNEL_SIZE) begin
//                            kernel_hor <= kernel_hor + 32'd1;
//                        end else begin
//                            kernel_hor <= 32'd0;
//                            kernel_vert <= kernel_vert + 32'd1;
//                        end
//                        filter_oper <= filter_oper + 32'd1;
//                    end
//                    // // tile done -> output once (and optionally write convimg)
//                    // else begin
//                    //     if (!STREAM_ONLY) begin
//                    //         convimg[out_ver_align*OUT_W + out_hor_align] <= running_max;
//                    //     end
//
//                    //     // stream out (honor backpressure)
//                    //     if (!s_valid) begin
//                    //         out_data <= running_max;
//                    //         s_valid  <= 1'b1;
//                    //     end
//                    //     if (s_valid && out_ready) begin
//                    //         s_valid      <= 1'b0;
//
//                    //         // reset for next tile
//                    //         running_max  <= 32'sh8000_0000;
//                    //         filter_oper  <= 32'd0;
//                    //         kernel_hor   <= 32'd0;
//                    //         kernel_vert  <= 32'd0;
//
//                    //         // stride = 2 movement
//                    //         if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                    //             hor_align     <= hor_align + 32'd2;
//                    //             out_hor_align <= out_hor_align + 32'd1;
//                    //         end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                    //             vert_align    <= vert_align + 32'd2;
//                    //             out_ver_align <= out_ver_align + 32'd1;
//                    //             hor_align     <= 32'd0;
//                    //             out_hor_align <= 32'd0;
//                    //         end
//                    //         convolutions <= convolutions + 32'd1;
//
//                    //         if (convolutions + 32'd1 == TOTAL_CONV) begin
//                    //             out_done <= 1'b1; // last element streamed
//                    //         end
//                    //     end
//                    // end
//                    else begin
//                        // finished taps -> latch activation; weight arrives in w_q next cycle (synchronous ROM)
//                        a_q <= running_max;
//                        st  <= ST_ACCUM;
//                    end
//                end else begin
//                    // st == ST_ACCUM
//                    w64    = $signed(w_q);
//                    a64    = $signed(a_q);
//                    prod64 = (w64 * a64) >>> 16;      // Q16.16
//                    neuron0 <= neuron0 + prod64;
//
//                    // neuron0 <= neuron0 + ($signed(weights_mem[(pass_sel*TOTAL_CONV) + convolutions]) * $signed(running_max)) >>> 16;
//                    running_max  <= 32'sh8000_0000;
//                    filter_oper  <= 32'd0;
//                    kernel_hor   <= 32'd0;
//                    kernel_vert  <= 32'd0;
//                    st           <= ST_TAPS;
//
//                    if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                        hor_align     <= hor_align + 32'd2;
//                        out_hor_align <= out_hor_align + 32'd1;
//                    end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                        vert_align    <= vert_align + 32'd2;
//                        out_ver_align <= out_ver_align + 32'd1;
//                        hor_align     <= 32'd0;
//                        out_hor_align <= 32'd0;
//                    end
//                    convolutions <= convolutions + 32'd1;
//                end
//            end else begin
//                complete <= 1'b1;
//            end
//        end
//    end
//
//endmodule

//`timescale 1ns/1ps 
//`default_nettype none
//
//module maxpool #(
//    parameter IMG_HEIGHT = 26, // Size for MNIST images
//    parameter IMG_WIDTH  = 26,
//    parameter KERNEL_SIZE = 2, // Kernel size for custom CNN model
//    parameter OUT_H       = ((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_W       = ((IMG_WIDTH  - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_ELEMS   = OUT_H * OUT_W,
//    parameter string WEIGHTS_MIF = "fc_w_neuron7.mif",
//    parameter string WEIGHTS_INIT_FILE = "src/fc_w_neuron0.memh"
//    // parameter bit STREAM_ONLY = 1 // only stream and do not store
// )(
//    input  logic               clk,
//    input  logic               rst_n,
//    input  logic               enable,
//    input  logic signed [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0],
//    output  logic signed [63:0] neuron0,
////    // input logic signed [31:0] neuron1,
////    // input logic signed [31:0] neuron2,
////    // input logic signed [31:0] neuron3,
////    // input logic signed [31:0] neuron4,
////    // input logic signed [31:0] neuron5,
////    // input logic signed [31:0] neuron6,
////    // input logic signed [31:0] neuron7,
////    // input logic signed [31:0] neuron8,
////    // input logic signed [31:0] neuron9,
//    output logic signed [31:0] convimg[OUT_ELEMS-1:0],
//    input  logic [1:0]         pass_sel,
//    input  logic               clear_accum,
//    // output logic               out_valid,
//    // output logic signed [31:0] out_data,
//    // input  logic               out_ready,
//    // output logic               out_done,
//    output logic               complete
////	 output wire signed [31:0] a
//);
//    // Counters
//    logic [31:0] convolutions;
//    logic [31:0] hor_align, vert_align;
//    logic [31:0] out_hor_align, out_ver_align;
//    logic [31:0] filter_oper;
//    logic [31:0] kernel_hor, kernel_vert;
//
//    // Total operations (kernel and output levels)
//    localparam int TOTAL_CONV = OUT_H * OUT_W;
//    localparam int TOTAL_TAPS = KERNEL_SIZE * KERNEL_SIZE;
//
//    // Running max for current tile
//    logic signed [31:0] running_max;
//
//    // Stream valid register
//    // logic s_valid;
//
//    logic signed [31:0] tap;
//    always_comb tap = img[(vert_align + kernel_vert)*IMG_WIDTH + (hor_align + kernel_hor)];
//
////    // --- Tie off convimg (keeps everything else unchanged and removes "no driver" warning)
////    genvar gi;
////    generate
////      for (gi = 0; gi < OUT_ELEMS; gi++) begin : G_Z
////        assign convimg[gi] = 32'sd0;
////      end
////    endgenerate
//
//    // Weight ROM (init for FPGA via MIF, for sim via readmemh)
//    localparam int WEIGHTS_DEPTH = TOTAL_CONV*4;
//    localparam int W_ADDR_W      = (WEIGHTS_DEPTH <= 1) ? 1 : $clog2(WEIGHTS_DEPTH);
//
//    // NOTE: Quartus is most reliable when ram_init_file is a literal string.
//    // Keep WEIGHTS_MIF as a parameter for your project flow, but hardcode here for inference robustness.
////    (* ramstyle = "M10K", ram_init_file = "fc_w_neuron7.mif" *)
////    logic signed [31:0] weights_mem [0:WEIGHTS_DEPTH-1];
//	 // --- FC weight ROM (IP) ---
//	 logic [9:0]         w_addr_reg;      // holds ROM address
//	 wire  [31:0]        w_q_rom;          // ROM output (registered inside IP)
//
//	 // IP ROM instance
//	 fc_w_rom u_fc_w_rom (
//	 	  .address (w_addr_reg),
//		  .clock   (clk),
//		  .q       (w_q_rom)
//	 );
//
//    typedef enum logic [0:0] { ST_TAPS=1'b0, ST_ACCUM=1'b1 } st_t;
//    st_t st;
//
////    logic [W_ADDR_W-1:0] w_addr, w_addr_next;
////    logic signed [31:0]  w_q;      // registered ROM output
//    logic signed [31:0]  a_q;      // activation aligned with w_q
////
////    // Compute next ROM address on the cycle we finish taps (so the ROM output aligns properly)
////    always_comb begin
////        w_addr_next = w_addr;
////        if (enable && !complete && (convolutions < TOTAL_CONV) && (st == ST_TAPS) && (filter_oper >= TOTAL_TAPS)) begin
////            w_addr_next = (pass_sel*TOTAL_CONV) + convolutions;
////        end
////    end
//
////    // Synchronous ROM read (1-cycle). Using w_addr_next avoids the "old address" problem.
////    always_ff @(posedge clk) begin
////        if (!rst_n) begin
////            w_addr <= '0;
////            w_q    <= 32'sd0;
////        end else begin
////            w_addr <= w_addr_next;
////            w_q    <= weights_mem[w_addr_next];
////        end
////    end
//
//    logic signed [63:0] w64, a64, prod64;
//
//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            // Only clear convimg when not stream-only
//            // if (!STREAM_ONLY) begin
//            //     for (int i = 0; i < OUT_ELEMS; i++) convimg[i] <= 32'sd0;
//            // end
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 0; // safer max init
//            st            <= ST_TAPS;
//            a_q           <= 32'sd0;
//            if (clear_accum) neuron0 <= 32'sd0;
//            neuron0 <= 0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'sd0;
//        end else if (!enable) begin
//            // Reset state when disabled to allow restart
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 0; // safer max init
//            st            <= ST_TAPS;
//            a_q           <= 32'sd0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'd0;
//        end else if (!complete) begin
//            // out_done <= 1'b0;
//            if (convolutions < TOTAL_CONV) begin
//                if (st == ST_TAPS) begin
//                    if (filter_oper < TOTAL_TAPS) begin
//                        // tap is now a wire, so we don't assign it here
//
//                        // if (filter_oper == 0)
//                        //     running_max <= tap;
//                        // else
//                        running_max <= (tap > running_max) ? tap : running_max;
//
//                        // advance tap indices
//                        if (kernel_hor + 32'd1 < KERNEL_SIZE) begin
//                            kernel_hor <= kernel_hor + 32'd1;
//                        end else begin
//                            kernel_hor <= 32'd0;
//                            kernel_vert <= kernel_vert + 32'd1;
//                        end
//                        filter_oper <= filter_oper + 32'd1;
//                    end
//                    // // tile done -> output once (and optionally write convimg)
//                    // else begin
//                    //     if (!STREAM_ONLY) begin
//                    //         convimg[out_ver_align*OUT_W + out_hor_align] <= running_max;
//                    //     end
//
//                    //     // stream out (honor backpressure)
//                    //     if (!s_valid) begin
//                    //         out_data <= running_max;
//                    //         s_valid  <= 1'b1;
//                    //     end
//                    //     if (s_valid && out_ready) begin
//                    //         s_valid      <= 1'b0;
//
//                    //         // reset for next tile
//                    //         running_max  <= 32'sh8000_0000;
//                    //         filter_oper  <= 32'd0;
//                    //         kernel_hor   <= 32'd0;
//                    //         kernel_vert  <= 32'd0;
//
//                    //         // stride = 2 movement
//                    //         if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                    //             hor_align     <= hor_align + 32'd2;
//                    //             out_hor_align <= out_hor_align + 32'd1;
//                    //         end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                    //             vert_align    <= vert_align + 32'd2;
//                    //             out_ver_align <= out_ver_align + 32'd1;
//                    //             hor_align     <= 32'd0;
//                    //             out_hor_align <= 32'd0;
//                    //         end
//                    //         convolutions <= convolutions + 32'd1;
//
//                    //         if (convolutions + 32'd1 == TOTAL_CONV) begin
//                    //             out_done <= 1'b1; // last element streamed
//                    //         end
//                    //     end
//                    // end
//                    else begin
//                        // finished taps -> latch activation; weight arrives in w_q next cycle (synchronous ROM)
////                        a_q <= running_max;
////                        st  <= ST_ACCUM;
//								// finished taps -> latch activation
//								a_q <= running_max;
//
//								// set ROM address NOW; ROM output will be valid next cycle (because q is registered)
//								w_addr_reg <= (pass_sel * TOTAL_CONV) + convolutions;  // 0..675
//
//								st <= ST_ACCUM;
//                    end
//                end else begin
//                    // st == ST_ACCUM
//						  w64    = $signed(w_q_rom);
////                    w64    = $signed(w_q);
//                    a64    = $signed(a_q);
//                    prod64 = (w64 * a64) >>> 16;      // Q16.16
//                    neuron0 <= neuron0 + prod64;
//
//                    // neuron0 <= neuron0 + ($signed(weights_mem[(pass_sel*TOTAL_CONV) + convolutions]) * $signed(running_max)) >>> 16;
//                    running_max  <= 0;
//                    filter_oper  <= 32'd0;
//                    kernel_hor   <= 32'd0;
//                    kernel_vert  <= 32'd0;
//                    st           <= ST_TAPS;
//
//                    if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                        hor_align     <= hor_align + 32'd2;
//                        out_hor_align <= out_hor_align + 32'd1;
//                    end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                        vert_align    <= vert_align + 32'd2;
//                        out_ver_align <= out_ver_align + 32'd1;
//                        hor_align     <= 32'd0;
//                        out_hor_align <= 32'd0;
//                    end
//                    convolutions <= convolutions + 32'd1;
//                end
//            end else begin
//                complete <= 1'b1;
//            end
//        end
//    end
////	 assign a = weights_mem[0];
//
//endmodule


//module maxpool #(
//    parameter IMG_HEIGHT = 26, // Size for MNIST images
//    parameter IMG_WIDTH  = 26,
//    parameter KERNEL_SIZE = 2, // Kernel size for custom CNN model
//    parameter OUT_H       = ((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_W       = ((IMG_WIDTH  - KERNEL_SIZE) >> 1) + 1,
//    parameter OUT_ELEMS   = OUT_H * OUT_W,
//    parameter string WEIGHTS_MIF = "fc_w_neuron0.mif",
//    parameter string WEIGHTS_INIT_FILE = "src/fc_w_neuron0.memh"
//    // parameter bit STREAM_ONLY = 1 // only stream and do not store
// )(
//    input  logic               clk,
//    input  logic               rst_n,
//    input  logic               enable,
//    input  logic signed [31:0] img[IMG_HEIGHT*IMG_WIDTH-1:0],
//    output  logic signed [63:0] neuron0,
//    // input logic signed [31:0] neuron1,
//    // input logic signed [31:0] neuron2,
//    // input logic signed [31:0] neuron3,
//    // input logic signed [31:0] neuron4,
//    // input logic signed [31:0] neuron5,
//    // input logic signed [31:0] neuron6,
//    // input logic signed [31:0] neuron7,
//    // input logic signed [31:0] neuron8,
//    // input logic signed [31:0] neuron9,
//    output logic signed [31:0] convimg[OUT_ELEMS-1:0],
//    input  logic [1:0]         pass_sel,
//    input  logic               clear_accum,
//    // output logic               out_valid,
//    // output logic signed [31:0] out_data,
//    // input  logic               out_ready,
//    // output logic               out_done,
//    output logic               complete
//);
//    // Counters
//    logic [31:0] convolutions;
//    logic [31:0] hor_align, vert_align;
//    logic [31:0] out_hor_align, out_ver_align;
//    logic [31:0] filter_oper;
//    logic [31:0] kernel_hor, kernel_vert;
//
//    // Total operations (kernel and output levels)
//    localparam int TOTAL_CONV = OUT_H * OUT_W;
//    localparam int TOTAL_TAPS = KERNEL_SIZE * KERNEL_SIZE;
//
//    // Running max for current tile
//    logic signed [31:0] running_max;
//
//    // Stream valid register
//    // logic s_valid;
//
//    logic signed [31:0] tap;
//    always_comb tap = img[(vert_align + kernel_vert)*IMG_WIDTH + (hor_align + kernel_hor)];
//
//    // // tie off convimg[] to zero when STREAM_ONLY=1 (no regs, no writes)
//    // generate
//    //   if (STREAM_ONLY) begin : G_TIE_OFF
//    //     genvar gi;
//    //     for (gi = 0; gi < OUT_ELEMS; gi++) begin : G_Z
//    //       assign convimg[gi] = 32'sd0;
//    //     end
//    //   end
//    // endgenerate
//
//    // Weight ROM (init for FPGA via MIF, for sim via readmemh)
//    (* ramstyle = "M10K", ram_init_file = "fc_w_neuron0.mif" *)
//    logic signed [31:0] weights_mem [0:675];
//
////    logic signed [31:0] tep = weights_mem[(pass_sel*TOTAL_CONV) + convolutions];
//
//    logic signed [63:0] w64, a64, prod64;
//
//
//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            // Only clear convimg when not stream-only
//            // if (!STREAM_ONLY) begin
//            //     for (int i = 0; i < OUT_ELEMS; i++) convimg[i] <= 32'sd0;
//            // end
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 0;
//            if (clear_accum) neuron0 <= 32'sd0;
//            neuron0 <= 0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'sd0;
//        end else if (!enable) begin
//            // Reset state when disabled to allow restart
//            complete      <= 1'b0;
//            // out_done      <= 1'b0;
//            convolutions  <= 32'd0;
//            hor_align     <= 32'd0;
//            vert_align    <= 32'd0;
//            out_hor_align <= 32'd0;
//            out_ver_align <= 32'd0;
//            filter_oper   <= 32'd0;
//            kernel_hor    <= 32'd0;
//            kernel_vert   <= 32'd0;
//            running_max   <= 0;
//            // s_valid       <= 1'b0;
//            // out_valid     <= 1'b0;
//            // out_data      <= 32'sd0;
//        end else if (!complete) begin
//            // out_done <= 1'b0;
//            if (convolutions < TOTAL_CONV) begin
//                if (filter_oper < TOTAL_TAPS) begin
//                    // tap is now a wire, so we don't assign it here
//
//                    // if (filter_oper == 0)
//                    //     running_max <= tap;
//                    // else
//                    running_max <= (tap > running_max) ? tap : running_max;
//
//                    // advance tap indices
//                    if (kernel_hor + 32'd1 < KERNEL_SIZE) begin
//                        kernel_hor <= kernel_hor + 32'd1;
//                    end else begin
//                        kernel_hor <= 32'd0;
//                        kernel_vert <= kernel_vert + 32'd1;
//                    end
//                    filter_oper <= filter_oper + 32'd1;
//                end
//                // // tile done -> output once (and optionally write convimg)
//                // else begin
//                //     if (!STREAM_ONLY) begin
//                //         convimg[out_ver_align*OUT_W + out_hor_align] <= running_max;
//                //     end
//
//                //     // stream out (honor backpressure)
//                //     if (!s_valid) begin
//                //         out_data <= running_max;
//                //         s_valid  <= 1'b1;
//                //     end
//                //     if (s_valid && out_ready) begin
//                //         s_valid      <= 1'b0;
//
//                //         // reset for next tile
//                //         running_max  <= 32'sh8000_0000;
//                //         filter_oper  <= 32'd0;
//                //         kernel_hor   <= 32'd0;
//                //         kernel_vert  <= 32'd0;
//
//                //         // stride = 2 movement
//                //         if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                //             hor_align     <= hor_align + 32'd2;
//                //             out_hor_align <= out_hor_align + 32'd1;
//                //         end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                //             vert_align    <= vert_align + 32'd2;
//                //             out_ver_align <= out_ver_align + 32'd1;
//                //             hor_align     <= 32'd0;
//                //             out_hor_align <= 32'd0;
//                //         end
//                //         convolutions <= convolutions + 32'd1;
//
//                //         if (convolutions + 32'd1 == TOTAL_CONV) begin
//                //             out_done <= 1'b1; // last element streamed
//                //         end
//                //     end
//                // end
//                else begin
//                    w64    = $signed(weights_mem[(pass_sel*TOTAL_CONV) + convolutions]);
//                    a64    = $signed(running_max);
//                    prod64 = (w64 * a64) >>> 16;      // Q16.16
//                    neuron0 <= neuron0 + prod64;
//
//                    // neuron0 <= neuron0 + ($signed(weights_mem[(pass_sel*TOTAL_CONV) + convolutions]) * $signed(running_max)) >>> 16;
//                    // running_max  <= 32'sh8000_0000;
//                    running_max  <= 0;
//                    filter_oper  <= 32'd0;
//                    kernel_hor   <= 32'd0;
//                    kernel_vert  <= 32'd0;
//                    if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
//                        hor_align     <= hor_align + 32'd2;
//                        out_hor_align <= out_hor_align + 32'd1;
//                    end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
//                        vert_align    <= vert_align + 32'd2;
//                        out_ver_align <= out_ver_align + 32'd1;
//                        hor_align     <= 32'd0;
//                        out_hor_align <= 32'd0;
//                    end
//                    convolutions <= convolutions + 32'd1;
//                end
//            end else begin
//                complete <= 1'b1;
//            end
//        end
//    end
//
//endmodule
//

`timescale 1ns/1ps
`default_nettype none

module maxpool #(
    parameter IMG_HEIGHT = 26,
    parameter IMG_WIDTH  = 26,
    parameter KERNEL_SIZE = 2,
    parameter OUT_H       = ((IMG_HEIGHT - KERNEL_SIZE) >> 1) + 1,
    parameter OUT_W       = ((IMG_WIDTH  - KERNEL_SIZE) >> 1) + 1,
    parameter OUT_ELEMS   = OUT_H * OUT_W,
    parameter string WEIGHTS_MIF = "fc_w_neuron7.mif",
    parameter string WEIGHTS_INIT_FILE = "src/fc_w_neuron0.memh"
 )(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                enable,
    input  wire signed [31:0]  img[IMG_HEIGHT*IMG_WIDTH-1:0],
    output logic signed [63:0] neurons [0:9],
    output logic signed [31:0] convimg[OUT_ELEMS*4-1:0],
    input  wire [1:0]          pass_sel,
    input  wire                clear_accum,
    output logic               complete
);

    // Counters
    logic [31:0] convolutions;
    logic [31:0] hor_align, vert_align;
    logic [31:0] out_hor_align, out_ver_align;
    logic [31:0] filter_oper;
    logic [31:0] kernel_hor, kernel_vert;

    localparam int TOTAL_CONV = OUT_H * OUT_W;
    localparam int TOTAL_TAPS = KERNEL_SIZE * KERNEL_SIZE;

    logic signed [31:0] running_max;

    logic signed [31:0] tap;
    always_comb tap = img[(vert_align + kernel_vert)*IMG_WIDTH + (hor_align + kernel_hor)];

    localparam int WEIGHTS_DEPTH = TOTAL_CONV*4;
    localparam int W_ADDR_W      = (WEIGHTS_DEPTH <= 1) ? 1 : $clog2(WEIGHTS_DEPTH);

    // --- FC weight ROMs (one per neuron, all share the same address) ---
    logic [9:0]  w_addr_reg;
    wire  [31:0] w_q [0:9];

    fc_w_rom  u_rom0 (.address(w_addr_reg), .clock(clk), .q(w_q[0]));
    fc_w_rom1 u_rom1 (.address(w_addr_reg), .clock(clk), .q(w_q[1]));
    fc_w_rom2 u_rom2 (.address(w_addr_reg), .clock(clk), .q(w_q[2]));
    fc_w_rom3 u_rom3 (.address(w_addr_reg), .clock(clk), .q(w_q[3]));
    fc_w_rom4 u_rom4 (.address(w_addr_reg), .clock(clk), .q(w_q[4]));
    fc_w_rom5 u_rom5 (.address(w_addr_reg), .clock(clk), .q(w_q[5]));
    fc_w_rom6 u_rom6 (.address(w_addr_reg), .clock(clk), .q(w_q[6]));
    fc_w_rom7 u_rom7 (.address(w_addr_reg), .clock(clk), .q(w_q[7]));
    fc_w_rom8 u_rom8 (.address(w_addr_reg), .clock(clk), .q(w_q[8]));
    fc_w_rom9 u_rom9 (.address(w_addr_reg), .clock(clk), .q(w_q[9]));

    typedef enum logic [1:0] { ST_TAPS=2'd0, ST_ADDR=2'd1, ST_ACCUM=2'd2 } st_t;
    st_t st;

    logic signed [31:0]  a_q;

    logic signed [63:0] w64, a64, prod64;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            complete      <= 1'b0;

            convolutions  <= 32'd0;
            hor_align     <= 32'd0;
            vert_align    <= 32'd0;
            out_hor_align <= 32'd0;
            out_ver_align <= 32'd0;
            filter_oper   <= 32'd0;
            kernel_hor    <= 32'd0;
            kernel_vert   <= 32'd0;

            running_max   <= 0;
            st            <= ST_TAPS;
            a_q           <= 32'sd0;
            w64           <= 64'sd0;
            a64           <= 64'sd0;
            prod64        <= 64'sd0;

            for (int n = 0; n < 10; n++) neurons[n] <= 64'sd0;
            w_addr_reg    <= 10'd0;
            for (int i = 0; i < OUT_ELEMS*4; i++) convimg[i] <= 32'sd0;

        end else if (!enable) begin
            complete      <= 1'b0;

            convolutions  <= 32'd0;
            hor_align     <= 32'd0;
            vert_align    <= 32'd0;
            out_hor_align <= 32'd0;
            out_ver_align <= 32'd0;
            filter_oper   <= 32'd0;
            kernel_hor    <= 32'd0;
            kernel_vert   <= 32'd0;

            running_max   <= 0;
            st            <= ST_TAPS;
            a_q           <= 32'sd0;
            w64           <= 64'sd0;
            a64           <= 64'sd0;
            prod64        <= 64'sd0;

            if (clear_accum) begin
                for (int n = 0; n < 10; n++) neurons[n] <= 64'sd0;
            end
        end else if (clear_accum) begin
            for (int n = 0; n < 10; n++) neurons[n] <= 64'sd0;
        end else if (!complete) begin
            w64    <= 64'sd0;
            a64    <= 64'sd0;
            prod64 <= 64'sd0;
            if (convolutions < TOTAL_CONV) begin
                if (st == ST_TAPS) begin
                    if (filter_oper < TOTAL_TAPS) begin
                        running_max <= (tap > running_max) ? tap : running_max;

                        if (kernel_hor + 32'd1 < KERNEL_SIZE) begin
                            kernel_hor <= kernel_hor + 32'd1;
                        end else begin
                            kernel_hor  <= 32'd0;
                            kernel_vert <= kernel_vert + 32'd1;
                        end
                        filter_oper <= filter_oper + 32'd1;

                        // Present ROM address on the LAST tap cycle so the
                        // 2-stage M10K pipeline (addr reg + output reg) has
                        // enough time to produce valid data by ST_ACCUM.
                        if (filter_oper == TOTAL_TAPS - 1)
                            w_addr_reg <= (pass_sel * TOTAL_CONV) + convolutions;
                    end else begin
                        a_q <= running_max;
                        st <= ST_ADDR;
                        convimg[pass_sel*TOTAL_CONV+convolutions] <= running_max;
                    end
                end else if (st == ST_ADDR) begin
                    st <= ST_ACCUM;
                end else begin
                    // ST_ACCUM: MAC for all 10 neurons in parallel
                    w64    <= $signed(w_q[0]);
                    a64    <= $signed(a_q);
                    prod64 <= ($signed(w_q[0]) * $signed(a_q)) >>> 16;

                    for (int n = 0; n < 10; n++)
                        neurons[n] <= neurons[n] + (($signed(w_q[n]) * $signed(a_q)) >>> 16);

                    running_max  <= 0;
                    filter_oper  <= 32'd0;
                    kernel_hor   <= 32'd0;
                    kernel_vert  <= 32'd0;
                    st           <= ST_TAPS;

                    if (hor_align + 32'd2 <= IMG_WIDTH - KERNEL_SIZE) begin
                        hor_align     <= hor_align + 32'd2;
                        out_hor_align <= out_hor_align + 32'd1;
                    end else if (vert_align + 32'd2 <= IMG_HEIGHT - KERNEL_SIZE) begin
                        vert_align    <= vert_align + 32'd2;
                        out_ver_align <= out_ver_align + 32'd1;
                        hor_align     <= 32'd0;
                        out_hor_align <= 32'd0;
                    end
                    convolutions <= convolutions + 32'd1;
                end
            end else begin
                complete <= 1'b1;
            end
        end
    end

endmodule
