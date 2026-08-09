// ============================================================
// Module    : uart_top.v
// Project   : DE10-Standard_FPGA_EKB / 04_Projects/UART
// Volume ref: Volume IV - Peripherals and IO, Chapter 1
// Author    : Nguyen Gia Huy
// Description : Top module UART Echo using DE10-Standard Golden Top GPIO bus
// Dependencies: uart_rx.v, uart_tx.v
// ============================================================

module uart_top #(
    parameter CLK_FREQ  = 50_000_000, // Tần số Clock 50MHz
    parameter BAUD_RATE = 115_200     // Baud Rate 115200 bps
) (
    input  wire        CLOCK_50,  // Tín hiệu Clock 50MHz từ board (PIN_AF14)
    input  wire [3:0]  KEY,       // KEY[0] làm Reset active-low (PIN_AJ4)
    output wire [9:0]  LEDR,      // 10 đèn LED đỏ trên board (PIN_V16..PIN_Y21)
    inout  wire [35:0] GPIO       // Bus I/O 36-pin mở rộng (đã gán chân sẵn trong QSF)
);

    wire clk   = CLOCK_50;
    wire rst_n = KEY[0];

    // Tín hiệu nội bộ kết nối khối UART với bus GPIO
    wire rx_line;
    wire tx_line;
    wire [7:0] rx_data_w;
    wire       rx_done_w;
    wire       tx_busy_w;

    // ============================================================
    // ÁNH XẠ CHÂN TRỰC TIẾP TRONG VERILOG (Direct Pin Mapping)
    // ============================================================
    // GPIO[0] đóng vai trò Output -> Xuất tín hiệu TX ra ngoài
    // GPIO[1] đóng vai trò Input  -> Nhận tín hiệu RX vào FPGA
    assign GPIO[0] = tx_line;
    assign rx_line = GPIO[1];

    // Khối nhận UART RX
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_line(rx_line),
        .rx_data(rx_data_w),
        .rx_done(rx_done_w)
    );

    // Khối truyền UART TX (Chế độ Echo Loopback: Tự động gửi lại byte vừa nhận)
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(rx_done_w),
        .tx_data(rx_data_w),
        .tx_busy(tx_busy_w),
        .tx_line(tx_line)
    );

    // Hiển thị mã Binary của byte nhận được lên 8 LEDR[7:0]
    reg [7:0] led_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 8'h00;
        end else if (rx_done_w) begin
            led_reg <= rx_data_w;
        end
    end

    assign LEDR[7:0] = led_reg;
    assign LEDR[9:8] = 2'b00; // Tắt 2 LED thừa

endmodule