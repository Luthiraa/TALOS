`timescale 1ns/1ps
`default_nettype none

module division #(
    parameter DATA_WIDTH = 32,
    parameter FRAC_WIDTH = 16 
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    start,
    input  logic [DATA_WIDTH-1:0]   dividend,
    input  logic [DATA_WIDTH-1:0]   divisor,
    output logic [DATA_WIDTH-1:0]   quotient,
    output logic [DATA_WIDTH-1:0]   remainder,
    output logic                    valid,
    output logic                    ready,
    output logic                    divide_by_zero
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        DIVIDE  = 2'b01,
        DONE    = 2'b10
    } state_t;
    
    state_t current_state;
    
    // Internal registers
    logic [DATA_WIDTH-1:0] work_dividend;
    logic [DATA_WIDTH-1:0] work_divisor;
    logic [DATA_WIDTH-1:0] work_quotient;
    logic [DATA_WIDTH-1:0] work_remainder;
    logic [5:0] counter;
    
    // Combinational outputs
    assign divide_by_zero = (divisor == 0) && start;
    assign ready = (current_state == IDLE);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            work_dividend <= 0;
            work_divisor <= 0;
            work_quotient <= 0;
            work_remainder <= 0;
            counter <= 0;
            valid <= 0;
            quotient <= 0;
            remainder <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    valid <= 0;
                    if (start && !divide_by_zero) begin
                        work_dividend <= dividend;
                        work_divisor <= divisor;
                        work_quotient <= 0;
                        work_remainder <= 0;
                        counter <= 0;
                        current_state <= DIVIDE;
                    end
                end
                
                DIVIDE: begin
                    // Left shift remainder and bring in next bit from dividend
                    work_remainder <= (work_remainder << 1) | ((work_dividend >> (DATA_WIDTH-1-counter)) & 1'b1);
                    
                    // Check if we can subtract
                    if (((work_remainder << 1) | ((work_dividend >> (DATA_WIDTH-1-counter)) & 1'b1)) >= work_divisor) begin
                        work_remainder <= ((work_remainder << 1) | ((work_dividend >> (DATA_WIDTH-1-counter)) & 1'b1)) - work_divisor;
                        work_quotient[DATA_WIDTH-1-counter] <= 1'b1;
                    end else begin
                        work_quotient[DATA_WIDTH-1-counter] <= 1'b0;
                    end
                    
                    counter <= counter + 1;
                    
                    if (counter == DATA_WIDTH - 1) begin
                        current_state <= DONE;
                    end
                end
                
                DONE: begin
                    quotient <= work_quotient;
                    remainder <= work_remainder;
                    valid <= 1;
                    current_state <= IDLE;
                end
                
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

endmodule

`default_nettype wire