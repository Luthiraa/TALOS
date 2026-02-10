`timescale 1ns/1ps
`default_nettype none

module cnn #(
    parameter IMG_HEIGHT  = 28,
    parameter IMG_WIDTH   = 28,
    parameter KERNEL_SIZE = 3
)(
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       enable,
    input  logic signed [31:0]         img    [IMG_HEIGHT*IMG_WIDTH-1:0],
    input  logic signed [31:0]         kernel [KERNEL_SIZE*KERNEL_SIZE-1:0],
    output logic signed [31:0]         x      [ (IMG_HEIGHT-KERNEL_SIZE+1)*(IMG_WIDTH-KERNEL_SIZE+1)-1:0 ],
    output wire                        complete,
	output logic signed [31:0] y
);
    // Derived sizes
    localparam int OUT_H      = (IMG_HEIGHT - KERNEL_SIZE + 1);
    localparam int OUT_W      = (IMG_WIDTH  - KERNEL_SIZE + 1);
    localparam int OUT_E      = OUT_H * OUT_W;
    localparam int TOTAL_TAPS = KERNEL_SIZE * KERNEL_SIZE;

    // Counters
    logic [31:0] hor_align, vert_align;
    logic [31:0] kernel_hor, kernel_vert;
    logic [31:0] filter_oper;
    logic [31:0] convolutions;

    // Accumulator (Q16.16)
    logic signed [31:0] conv_acc;
    // Output completion flag
    logic complete_r;

    // Single multiply per cycle (Q16.16 × Q16.16)
    logic signed [31:0] tap_pix, tap_wgt;
    logic signed [31:0] prod_q16;
    logic overflow_mul;

    always_comb begin
        tap_pix = img[ (vert_align + kernel_vert)*IMG_WIDTH + (hor_align + kernel_hor) ];
        tap_wgt = kernel[ kernel_vert*KERNEL_SIZE + kernel_hor ];
    end

    //    (* multstyle = "dsp" *)
    fxp_mul #(
        .WIIA(16), .WIFA(16),
        .WIIB(16), .WIFB(16),
        .WOI (16), .WOF (16),
        .ROUND(1)
    ) u_mul (
        .ina(tap_wgt),
        .inb(tap_pix),
        .out(prod_q16),
        .overflow(overflow_mul)
    );

    // Control
    // Drive output port from internal register to avoid procedural assignment to wire
    assign complete = complete_r;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            complete_r   <= 1'b0;
            hor_align    <= 0;
            vert_align   <= 0;
            kernel_hor   <= 0;
            kernel_vert  <= 0;
            filter_oper  <= 0;
            convolutions <= 0;
            conv_acc     <= 0;
			y <= 0;
            // Initialize CNN output buffer (prevents xxxx propagation)
            for (int i = 0; i < OUT_E; i++) begin
                x[i] <= 32'sd0;
            end
        end else if (!enable) begin
            complete_r   <= 1'b0;
            hor_align    <= 32'd0;
            vert_align   <= 32'd0;
            kernel_hor   <= 32'd0;
            kernel_vert  <= 32'd0;
            filter_oper  <= 32'd0;
            convolutions <= 32'd0;
            conv_acc     <= 32'sd0;
        end else if (!complete_r) begin
            if (convolutions < OUT_E) begin
					if (hor_align < IMG_WIDTH - KERNEL_SIZE + 1) begin
							 if (filter_oper < TOTAL_TAPS) begin
								  if (kernel_hor < KERNEL_SIZE) begin
										filter_oper <= filter_oper + 1;
										conv_acc    <= conv_acc + prod_q16;
										if(convolutions == 1) begin
											y <= conv_acc;
										end
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
                                  conv_acc <= 0;
								  convolutions <= convolutions + 1;
                                  x[ vert_align*OUT_W + hor_align ] <= conv_acc;
								  kernel_hor <= 0;
								  kernel_vert <= 0;
							 end
						end 
						else if (vert_align < IMG_WIDTH) begin
							 vert_align <= vert_align + 1;
							 hor_align <= 0;
						end

            end else begin
                complete_r <= 1'b1;
            end
        end
    end
endmodule
