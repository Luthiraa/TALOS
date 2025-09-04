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
    
    // Conv bias memory interface  
    input  logic [1:0] conv_bias_idx,      // 0-3 for 4 biases
    output logic signed [7:0] conv_bias_data,
    
    // FC weight memory interface
    input  logic [3:0]  fc_neuron_idx,     // 0-9 for 10 neurons
    input  logic [9:0]  fc_weight_idx,     // 0-675 for 676 inputs (reduced for synthesis)
    output logic signed [7:0] fc_weight_data,
    
    // FC bias memory interface
    input  logic [3:0] fc_bias_idx,        // 0-9 for 10 biases
    output logic signed [7:0] fc_bias_data
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

    // Conv Biases ROM
    logic signed [7:0] conv_biases_rom [0:3];
    initial begin
        conv_biases_rom[0] = -1;   // Filter 0 bias
        conv_biases_rom[1] = -53;  // Filter 1 bias
        conv_biases_rom[2] = -15;  // Filter 2 bias
        conv_biases_rom[3] = 3;    // Filter 3 bias
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

    // Memory access logic
    always_comb begin
        // Conv weight access
        if (conv_filter_idx < 4 && conv_weight_idx < 9)
            conv_weight_data = conv_weights_rom[conv_filter_idx][conv_weight_idx];
        else
            conv_weight_data = 8'sd0;
            
        // Conv bias access
        if (conv_bias_idx < 4)
            conv_bias_data = conv_biases_rom[conv_bias_idx];
        else
            conv_bias_data = 8'sd0;
            
        // FC weight access (limited to 64 weights per neuron for synthesis)
        if (fc_neuron_idx < 10 && fc_weight_idx < 64)
            fc_weight_data = fc_weights_rom[fc_neuron_idx][fc_weight_idx];
        else
            fc_weight_data = 8'sd0;
            
        // FC bias access
        if (fc_bias_idx < 10)
            fc_bias_data = fc_biases_rom[fc_bias_idx];
        else
            fc_bias_data = 8'sd0;
    end

endmodule