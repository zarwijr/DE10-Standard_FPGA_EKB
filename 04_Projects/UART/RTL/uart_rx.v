// ============================================================
// Module    : uart_rx.v
// Project   : DE10-Standard_FPGA_EKB / 04_Projects/UART
// Volume ref: Volume IV - Peripherals and IO, Chapter 1
// Author    : Nguyen Gia Huy
// Description : UART receiver (8N1 format, configurable baud rate)
//               - Co dong bo hoa 2 tang (double flop synchronizer)
//                 de tranh metastability tren rx_line.
//               - Lay mau du lieu tai giua moi bit de tang do tin cay.
//               - rx_done la xung 1 chu ky clock bao du lieu da san sang.
// Dependencies: none
// ============================================================

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000, // Tan so Clock dau vao (50 MHz)
    parameter BAUD_RATE = 115_200     // Toc do Baud muc tieu (115200 bps)
) (
    input  wire       clk,            // System Clock (50MHz)
    input  wire       rst_n,          // Reset bat dong bo (active low)
    input  wire       rx_line,        // Duong nhan du lieu noi tiep UART RX
    output reg  [7:0] rx_data,        // Byte du lieu 8-bit nhan duoc
    output reg        rx_done         // Xung 1 chu ky clock khi rx_data hop le
);

    // So chu ky clock cho 1 bit va cho nua bit (dung de canh giua bit)
    localparam CLKS_PER_BIT      = CLK_FREQ / BAUD_RATE;
    localparam HALF_CLKS_PER_BIT = CLKS_PER_BIT / 2;

    // Khai bao trang thai FSM
    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    // Bo dong bo hoa 2 tang cho tin hieu rx_line (chong metastability)
    reg rx_sync0, rx_sync1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx_line;
            rx_sync1 <= rx_sync0;
        end
    end
    wire rx_in = rx_sync1; // Tin hieu rx_line da duoc dong bo hoa

    // Thanh ghi noi bo
    reg [1:0]  state_reg;
    reg [15:0] clk_cnt_reg;
    reg [2:0]  bit_idx_reg;
    reg [7:0]  rx_data_reg;

    // FSM Dieu khien nhan UART 8N1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg   <= S_IDLE;
            clk_cnt_reg <= 16'd0;
            bit_idx_reg <= 3'd0;
            rx_data_reg <= 8'd0;
            rx_data     <= 8'd0;
            rx_done     <= 1'b0;
        end else begin
            rx_done <= 1'b0; // Mac dinh = 0, chi len '1' dung 1 chu ky khi hoan tat

            case (state_reg)
                S_IDLE: begin
                    clk_cnt_reg <= 16'd0;
                    bit_idx_reg <= 3'd0;
                    if (rx_in == 1'b0) begin // Phat hien canh xuong -> nghi ngo Start bit
                        state_reg <= S_START;
                    end
                end

                S_START: begin
                    // Cho den giua Start bit de xac nhan day khong phai xung nhieu (glitch)
                    if (clk_cnt_reg == HALF_CLKS_PER_BIT - 1) begin
                        if (rx_in == 1'b0) begin
                            clk_cnt_reg <= 16'd0; // Reset dem, bat dau lay mau du lieu
                            state_reg   <= S_DATA;
                        end else begin
                            state_reg <= S_IDLE; // Start bit gia -> quay ve IDLE
                        end
                    end else begin
                        clk_cnt_reg <= clk_cnt_reg + 1'b1;
                    end
                end

                S_DATA: begin
                    // Lay mau tai giua moi bit du lieu (LSB truoc)
                    if (clk_cnt_reg == CLKS_PER_BIT - 1) begin
                        clk_cnt_reg <= 16'd0;
                        rx_data_reg[bit_idx_reg] <= rx_in;
                        if (bit_idx_reg == 3'd7) begin
                            state_reg <= S_STOP;
                        end else begin
                            bit_idx_reg <= bit_idx_reg + 1'b1;
                        end
                    end else begin
                        clk_cnt_reg <= clk_cnt_reg + 1'b1;
                    end
                end

                S_STOP: begin
                    // Cho du 1 bit Stop roi chot du lieu ra ngoai + bao rx_done
                    if (clk_cnt_reg == CLKS_PER_BIT - 1) begin
                        state_reg <= S_IDLE;
                        rx_data   <= rx_data_reg;
                        rx_done   <= 1'b1; // Xung bao du lieu hop le (1 chu ky)
                    end else begin
                        clk_cnt_reg <= clk_cnt_reg + 1'b1;
                    end
                end

                default: state_reg <= S_IDLE;
            endcase
        end
    end

endmodule