// ============================================================================
// File Name   : led_chaser.v
// Project     : LED Chaser Project
// Target Board: Terasic DE10-Standard (5CSXFC6D6F31C6N)
// Description : Top module - 8-State FSM LED Chaser
// ============================================================================

module led_chaser (
    input  wire       CLOCK_50,    // Clock hệ thống 50MHz (PIN_AF14)
    input  wire       KEY0_rst_n,  // Reset tích cực thấp (PIN_AJ4)
    output reg  [7:0] LEDR         // 8 LED đỏ trên board
);

    // Tín hiệu nối giữa clk_divider và FSM
    wire clk_en;

    // 1. Instantiate bộ chia xung clock (Clock Divider)
    clk_divider #(
        .CLK_FREQ(50_000_000),
        .TARGET_FREQ(4)
    ) u_clk_divider (
        .clk    (CLOCK_50),
        .rst_n  (KEY0_rst_n),
        .clk_en (clk_en)
    );

    // Định nghĩa 8 trạng thái FSM (Sequential Encoding)
    localparam [2:0] S0 = 3'b000,
                     S1 = 3'b001,
                     S2 = 3'b010,
                     S3 = 3'b011,
                     S4 = 3'b100,
                     S5 = 3'b101,
                     S6 = 3'b110,
                     S7 = 3'b111;

    reg [2:0] current_state, next_state;

    // 2. FSM State Register (Chuyển trạng thái khi có clk_en)
    always @(posedge CLOCK_50 or negedge KEY0_rst_n) begin
        if (!KEY0_rst_n) begin
            current_state <= S0;
        end else if (clk_en) begin
            current_state <= next_state;
        end
    end

    // 3. FSM Next State Logic (Mạch tổ hợp)
    always @(*) begin
        case (current_state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = S4;
            S4: next_state = S5;
            S5: next_state = S6;
            S6: next_state = S7;
            S7: next_state = S0;
            default: next_state = S0;
        endcase
    end

    // 4. Output Logic (Mỗi state bật đúng 1 LED)
    always @(*) begin
        case (current_state)
            S0: LEDR = 8'b0000_0001; // LEDR[0] sáng
            S1: LEDR = 8'b0000_0010; // LEDR[1] sáng
            S2: LEDR = 8'b0000_0100; // LEDR[2] sáng
            S3: LEDR = 8'b0000_1000; // LEDR[3] sáng
            S4: LEDR = 8'b0001_0000; // LEDR[4] sáng
            S5: LEDR = 8'b0010_0000; // LEDR[5] sáng
            S6: LEDR = 8'b0100_0000; // LEDR[6] sáng
            S7: LEDR = 8'b1000_0000; // LEDR[7] sáng
            default: LEDR = 8'b0000_0001;
        endcase
    end

endmodule