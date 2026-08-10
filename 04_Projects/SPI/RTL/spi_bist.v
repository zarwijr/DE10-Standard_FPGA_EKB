// ============================================================================
// File Name   : spi_bist.v
// Module Name : spi_bist
// Project     : DE10-Standard FPGA EKB (Volume IV - SPI Loopback)
// Description : BIST Controller tự động sinh Test Pattern và so sánh kết quả
//               * Hỗ trợ parameter TEST_INTERVAL để tăng tốc Simulation
// ============================================================================

module spi_bist #(
    parameter TEST_INTERVAL = 50_000_000 // Mặc định 1 giây ở 50MHz (Dùng cho Board thật)
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,     // Tín hiệu cho phép BIST hoạt động
    
    // Giao tiếp với SPI Master
    output reg  [7:0] tx_data,
    output reg        tx_valid,
    input  wire       tx_ready,
    input  wire [7:0] master_rx_data, // Nhận từ Master
    input  wire       master_rx_valid,
    
    // Giao tiếp với SPI Slave (Kiểm chứng chiều ngược lại)
    input  wire [7:0] slave_rx_data,  // Nhận từ Slave
    input  wire       slave_rx_valid,
    
    // Tín hiệu xuất ra hiển thị (LED/HEX)
    output reg        pass_flag,
    output reg        err_flag,
    output wire [7:0] current_pattern
);

    // ---------------------------------------------------------
    // Bảng ROM chứa 8 Test Pattern kinh điển trong kiểm chứng phần cứng
    // ---------------------------------------------------------
    wire [7:0] pattern_rom [0:7];
    assign pattern_rom[0] = 8'h00; // All 0s (Stuck-at-0 test)
    assign pattern_rom[1] = 8'hFF; // All 1s (Stuck-at-1 test)
    assign pattern_rom[2] = 8'hAA; // 10101010 (Crosstalk/Toggling test)
    assign pattern_rom[3] = 8'h55; // 01010101 (Crosstalk/Toggling test)
    assign pattern_rom[4] = 8'hA5; // 10100101
    assign pattern_rom[5] = 8'h5A; // 01011010
    assign pattern_rom[6] = 8'h01; // Walking 1 (LSB)
    assign pattern_rom[7] = 8'h80; // Walking 1 (MSB)

    // Tính toán độ rộng bộ đếm Timer bằng $clog2
    localparam TIMER_WIDTH = $clog2(TEST_INTERVAL + 1);
    reg [TIMER_WIDTH-1:0] timer;
    wire tick_interval = (timer == (TEST_INTERVAL - 1));

    // ---------------------------------------------------------
    // FSM Điều khiển BIST
    // ---------------------------------------------------------
    localparam S_IDLE        = 3'd0;
    localparam S_SEND_MASTER = 3'd1;
    localparam S_WAIT_RX     = 3'd2;
    localparam S_CHECK       = 3'd3;

    reg [2:0] state;
    reg [2:0] pat_idx; // Chỉ số pattern hiện tại (0-7)
    
    // Đăng ký lưu tạm dữ liệu nhận được để đối chiếu
    reg [7:0] captured_master_rx;
    reg [7:0] captured_slave_rx;
    
    assign current_pattern = pattern_rom[pat_idx];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state              <= S_IDLE;
            timer              <= {TIMER_WIDTH{1'b0}};
            pat_idx            <= 3'd0;
            tx_data            <= 8'd0;
            tx_valid           <= 1'b0;
            pass_flag          <= 1'b0;
            err_flag           <= 1'b0;
            captured_master_rx <= 8'd0;
            captured_slave_rx  <= 8'd0;
        end else begin
            // Mặc định tắt xung kích
            tx_valid <= 1'b0;

            // Bắt sự kiện Valid từ Slave (xảy ra đồng thời hoặc xấp xỉ với Master)
            if (slave_rx_valid)  captured_slave_rx  <= slave_rx_data;
            if (master_rx_valid) captured_master_rx <= master_rx_data;

            // Timer chỉ đếm khi BIST được Enable và đang rảnh
            if (enable && (state == S_IDLE)) begin
                if (tick_interval) timer <= {TIMER_WIDTH{1'b0}};
                else               timer <= timer + 1'b1;
            end

            case (state)
                S_IDLE: begin
                    // Đủ thời gian trễ và Master rảnh rỗi -> Bắt đầu test
                    if (enable && tick_interval && tx_ready) begin
                        state <= S_SEND_MASTER;
                    end
                end

                S_SEND_MASTER: begin
                    tx_data  <= pattern_rom[pat_idx];
                    tx_valid <= 1'b1;
                    state    <= S_WAIT_RX;
                end

                S_WAIT_RX: begin
                    // Chờ cả Master và Slave báo đã nhận xong
                    if (master_rx_valid) begin
                        state <= S_CHECK;
                    end
                end

                S_CHECK: begin
                    // Bộ so sánh phần cứng (Full-Duplex Comparator)
                    // Kiểm tra cả 2 chiều: Master nhận đúng VÀ Slave nhận đúng
                    if ((captured_master_rx == pattern_rom[pat_idx]) && 
                        (captured_slave_rx  == pattern_rom[pat_idx])) begin
                        pass_flag <= 1'b1;
                        err_flag  <= 1'b0;
                    end else begin
                        pass_flag <= 1'b0;
                        err_flag  <= 1'b1;
                    end
                    
                    // Chuyển sang pattern tiếp theo (vòng lặp 0->7)
                    pat_idx <= pat_idx + 1'b1;
                    state   <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule