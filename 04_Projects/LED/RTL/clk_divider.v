// ============================================================================
// File Name   : clk_divider.v
// Project     : LED Chaser Project
// Target Board: Terasic DE10-Standard (5CSXFC6D6F31C6N)
// Description : Generates a single-cycle clock enable pulse (tick) at target frequency.
// ============================================================================

module clk_divider #(
    parameter integer CLK_FREQ    = 50_000_000, // Tần số clock đầu vào (50 MHz)
    parameter integer TARGET_FREQ = 4          // Tần số xung kích phát ra (4 Hz)
)(
    input  wire clk,      // Clock hệ thống 50MHz
    input  wire rst_n,    // Reset bất đồng bộ, tích cực thấp
    output reg  clk_en    // Xung Enable (1 chu kỳ clk)
);

    localparam integer COUNT_MAX     = (CLK_FREQ / TARGET_FREQ) - 1;
    localparam integer COUNTER_WIDTH = $clog2(CLK_FREQ / TARGET_FREQ);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            clk_en  <= 1'b0;
        end else begin
            if (counter >= COUNT_MAX) begin
                counter <= {COUNTER_WIDTH{1'b0}};
                clk_en  <= 1'b1; // Phát xung enable rộng 1 chu kỳ clock
            end else begin
                counter <= counter + 1'b1;
                clk_en  <= 1'b0;
            end
        end
    end

endmodule