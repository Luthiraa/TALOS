//==============================================================================
// CNN Quantized Weights - Synthesizable On-Chip Memory
// Generated from quantize_weights_intermediaries.ipynb
// Model: MinimalCNN (1 Conv Layer + 1 FC Layer)
//==============================================================================

module cnn_weights_mem (
    input  logic clk,
    input  logic rst_n,
    
    // Conv weight memory interface
    input  logic [1:0] conv_filter_idx,    // 0-3 for 4 filters
    input  logic [3:0] conv_weight_idx,    // 0-8 for 3x3 kernel
    output logic signed [7:0] conv_weight_data,
    output logic [3:0] conv_weight_scale,   // Right-shift amount for scaling
    
    // Conv bias memory interface  
    input  logic [1:0] conv_bias_idx,      // 0-3 for 4 biases
    output logic signed [7:0] conv_bias_data,
    output logic [3:0] conv_bias_scale,     // Right-shift amount for scaling
    
    // FC weight memory interface
    input  logic [3:0]  fc_neuron_idx,     // 0-9 for 10 neurons
    input  logic [9:0]  fc_weight_idx,     // 0-675 for 676 inputs (reduced for synthesis)
    output logic signed [7:0] fc_weight_data,
    output logic [3:0] fc_weight_scale,     // Right-shift amount for scaling
    
    // FC bias memory interface
    input  logic [3:0] fc_bias_idx,        // 0-9 for 10 biases
    output logic signed [7:0] fc_bias_data,
    output logic [3:0] fc_bias_scale        // Right-shift amount for scaling
);

    // Conv Weights ROM - 4 filters x 9 weights each
    logic signed [7:0] conv_weights_rom [0:3][0:8];
    initial begin
        // Filter 0: 3x3 kernel flattened
        conv_weights_rom[0] = '{36, 82, -16, 42, 59, 58, -145, -108, 7};
        // Filter 1: 3x3 kernel flattened  
        conv_weights_rom[1] = '{9, 51, 36, 26, 57, -10, 76, 57, -100};
        // Filter 2: 3x3 kernel flattened
        conv_weights_rom[2] = '{-41, -79, -125, -60, -60, 92, -116, 26, 92};
        // Filter 3: 3x3 kernel flattened
        conv_weights_rom[3] = '{59, 27, -77, -11, 3, -33, -41, 6, 90};
    end

    // Conv Weight Scale Factors ROM (right-shift amounts for power-of-2 scaling)
    // Real scale: 111.95 ≈ 128 = 2^7, so quantized_weight/128 = quantized_weight >> 7
    // Scale factor = 1 / (2^shift_amount)
    logic [3:0] conv_weight_scales_rom [0:3];
    initial begin
        conv_weight_scales_rom[0] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/111.95)
        conv_weight_scales_rom[1] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/111.95)
        conv_weight_scales_rom[2] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/111.95)
        conv_weight_scales_rom[3] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/111.95)
    end

    // Conv Biases ROM
    logic signed [7:0] conv_biases_rom [0:3];
    initial begin
        conv_biases_rom[0] = -1;   // Filter 0 bias
        conv_biases_rom[1] = -53;  // Filter 1 bias
        conv_biases_rom[2] = -15;  // Filter 2 bias
        conv_biases_rom[3] = 3;    // Filter 3 bias
    end

    // Conv Bias Scale Factors ROM
    // Real scale: 239.90 ≈ 256 = 2^8, so quantized_bias/256 = quantized_bias >> 8
    logic [3:0] conv_bias_scales_rom [0:3];
    initial begin
        conv_bias_scales_rom[0] = 4'd8;  // Scale = 1/256 ≈ 0.00390625 (real: 1/239.90)
        conv_bias_scales_rom[1] = 4'd8;  // Scale = 1/256 ≈ 0.00390625 (real: 1/239.90)
        conv_bias_scales_rom[2] = 4'd8;  // Scale = 1/256 ≈ 0.00390625 (real: 1/239.90)
        conv_bias_scales_rom[3] = 4'd8;  // Scale = 1/256 ≈ 0.00390625 (real: 1/239.90)
    end

    logic signed [7:0] fc_weights_rom [0:9][0:63];
    initial begin
        // Neuron 0 weights (first 64 of 676)
        fc_weights_rom[0] = '{23, -19, 7, 8, -23, -6, 9, 7, 4, -9, 1, -18, 6, 17, -29, -20,
                             -6, -19, 15, 5, 2, 14, 22, -25, -27, -11, -12, -8, -12, -20, -12, -17,
                             -10, 2, 4, 6, 6, -13, -99, 26, -17, -7, -4, -7, -8, -5, -7, 7,
                             5, 11, 3, -55, 26, -6, 7, -9, -2, -5, -18, -6, -1, -4, 0, -4};
        // Neuron 1 weights (first 64 of 676)
        fc_weights_rom[1] = '{8, -13, -25, -16, -26, 29, 18, -20, -10, -39, -17, -14, -11, 18, 16, -25,
                             12, 15, 4, 6, -30, -4, -20, -21, -39, -40, -6, 9, 12, 7, 12, -22,
                             -27, -37, -54, -33, -50, -45, -45, -39, -18, 1, -25, -10, -8, -19, -44, -47,
                             -38, -15, -46, -77, -26, -21, -1, -12, -4, -16, -17, -38, -36, -29, -16, -37};
        // Remaining neurons with sample weights
        fc_weights_rom[2] = '{-25, -8, -17, 18, -6, -12, -15, 3, -10, -17, 11, 10, -30, -4, -7, -6,
                             12, 8, 2, 15, 20, 3, -10, -7, -38, -13, 2, -2, -7, 1, 2, 6,
                             1, 8, 12, 6, 16, -64, -36, 1, 1, -1, 5, 5, 3, 11, 7, 0,
                             -4, -13, -60, 5, 7, 20, -9, -12, 7, 5, 19, 12, 7, -10, -7, -29};
        // Initialize remaining neurons with sample data
        for (int i = 3; i < 10; i++) begin
            for (int j = 0; j < 64; j++) begin
                fc_weights_rom[i][j] = (i * j) % 127 - 64; 
            end
        end
    end

    // FC Weight Scale Factors ROM
    // Real scale: 127.97 ≈ 128 = 2^7, so quantized_weight/128 = quantized_weight >> 7
    logic [3:0] fc_weight_scales_rom [0:9];
    initial begin
        fc_weight_scales_rom[0] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[1] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[2] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[3] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[4] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[5] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[6] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[7] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[8] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
        fc_weight_scales_rom[9] = 4'd7;  // Scale = 1/128 ≈ 0.0078125 (real: 1/127.97)
    end

    // FC Biases ROM
    logic signed [7:0] fc_biases_rom [0:9];
    initial begin
        fc_biases_rom[0] = 13;   
        fc_biases_rom[1] = -15;  
        fc_biases_rom[2] = 19;   
        fc_biases_rom[3] = -28;  
        fc_biases_rom[4] = 6;    
        fc_biases_rom[5] = -22;  
        fc_biases_rom[6] = 31;   
        fc_biases_rom[7] = 41;   
        fc_biases_rom[8] = 23;   
        fc_biases_rom[9] = -11;  
    end

    // FC Bias Scale Factors ROM
    // Real scale: 1191.16 ≈ 1024 = 2^10, so quantized_bias/1024 = quantized_bias >> 10
    logic [3:0] fc_bias_scales_rom [0:9];
    initial begin
        fc_bias_scales_rom[0] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[1] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[2] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[3] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[4] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[5] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[6] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[7] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[8] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
        fc_bias_scales_rom[9] = 4'd10;  // Scale = 1/1024 ≈ 0.0009765625 (real: 1/1191.16)
    end

    // Memory access logic
    always_comb begin
        // Conv weight access
        if (conv_filter_idx < 4 && conv_weight_idx < 9) begin
            conv_weight_data = conv_weights_rom[conv_filter_idx][conv_weight_idx];
            conv_weight_scale = conv_weight_scales_rom[conv_filter_idx];
        end else begin
            conv_weight_data = 8'sd0;
            conv_weight_scale = 4'd0;
        end
            
        // Conv bias access
        if (conv_bias_idx < 4) begin
            conv_bias_data = conv_biases_rom[conv_bias_idx];
            conv_bias_scale = conv_bias_scales_rom[conv_bias_idx];
        end else begin
            conv_bias_data = 8'sd0;
            conv_bias_scale = 4'd0;
        end
            
        // FC weight access (limited to 64 weights per neuron for synthesis)
        if (fc_neuron_idx < 10 && fc_weight_idx < 64) begin
            fc_weight_data = fc_weights_rom[fc_neuron_idx][fc_weight_idx];
            fc_weight_scale = fc_weight_scales_rom[fc_neuron_idx];
        end else begin
            fc_weight_data = 8'sd0;
            fc_weight_scale = 4'd0;
        end
            
        // FC bias access
        if (fc_bias_idx < 10) begin
            fc_bias_data = fc_biases_rom[fc_bias_idx];
            fc_bias_scale = fc_bias_scales_rom[fc_bias_idx];
        end else begin
            fc_bias_data = 8'sd0;
            fc_bias_scale = 4'd0;
        end
    end

endmodule