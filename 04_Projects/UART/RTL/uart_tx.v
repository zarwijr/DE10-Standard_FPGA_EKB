// ============================================================
// Module    : uart_tx.v
// Project   : DE10-Standard_FPGA_EKB / 04_Projects/UART
// Volume ref: Volume IV - Peripherals and IO, Chapter 1
// Author    : Nguyen Gia Huy
// Description : UART transmitter (8N1 format, configurable baud rate)
// Dependencies: none
// ============================================================

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000, // Tần số Clock đầu vào (50 MHz)
    parameter BAUD_RATE = 115_200     // Tốc độ Baud mục tiêu (115200 bps)
) (
    input  wire       clk,            // System Clock (50MHz)
    input  wire       rst_n,          // Reset bất đồng bộ (active low)
    input  wire       tx_start,       // Tín hiệu kích hoạt truyền (1 chu kỳ clock)
    input  wire [7:0] tx_data,        // Byte dữ liệu 8-bit cần gửi
    output reg        tx_busy,        // Báo bận: 1 khi đang truyền dữ liệu
    output reg        tx_line         // Đường truyền dữ liệu nối tiếp UART TX
);

    // Tính số chu kỳ clock cho 1 bit Baud Rate
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    // Khai báo trạng thái FSM (S_ + UPPERCASE)
    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    // Thanh ghi nội bộ
    reg [1:0]  state_reg;
    reg [15:0] clk_cnt_reg;
    reg [2:0]  bit_idx_reg;
    reg [7:0]  tx_data_reg;

    // Tạo xung baud_tick khi đếm đủ chu kỳ của 1 bit
    wire baud_tick = (clk_cnt_reg == CLKS_PER_BIT - 1);

    // Bộ đếm Baud Rate Generator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt_reg <= 16'd0;
        end else if (state_reg != S_IDLE) begin
            if (baud_tick)
                clk_cnt_reg <= 16'd0;
            else
                clk_cnt_reg <= clk_cnt_reg + 1'b1;
        end else begin
            clk_cnt_reg <= 16'd0;
        end
    end

    // FSM Điều khiển truyền UART 8N1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg   <= S_IDLE;
            tx_line     <= 1'b1; // Mức IDLE của UART là '1'
            tx_busy     <= 1'b0;
            bit_idx_reg <= 3'd0;
            tx_data_reg <= 8'd0;
        end else begin
            case (state_reg)
                S_IDLE: begin
                    tx_line <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        tx_data_reg <= tx_data; // Latch dữ liệu cần gửi
                        tx_busy     <= 1'b1;
                        state_reg   <= S_START;
                    end
                end

                S_START: begin
                    tx_line <= 1'b0; // Start bit = '0'
                    if (baud_tick) begin
                        state_reg   <= S_DATA;
                        bit_idx_reg <= 3'd0;
                    end
                end

                S_DATA: begin
                    tx_line <= tx_data_reg[bit_idx_reg]; // Truyền LSB trước
                    if (baud_tick) begin
                        if (bit_idx_reg == 3'd7) begin
                            state_reg <= S_STOP;
                        end else begin
                            bit_idx_reg <= bit_idx_reg + 1'b1;
                        end
                    end
                end

                S_STOP: begin
                    tx_line <= 1'b1; // Stop bit = '1'
                    if (baud_tick) begin
                        state_reg <= S_IDLE;
                        tx_busy   <= 1'b0;
                    end
                end

                default: state_reg <= S_IDLE;
            endcase
        end
    end

endmodule