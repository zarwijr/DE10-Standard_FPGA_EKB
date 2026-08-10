// ============================================================================
// File Name   : spi.v
// Module Name : spi
// Project     : DE10-Standard FPGA EKB (Volume IV - SPI Loopback)
// Description : Top-Level Integration (BIST + Master + Slave + Error Injector)
//               * Hỗ trợ Hardware Loopback thông qua GPIO (tùy chọn)
// ============================================================================

module spi #(
    // Khai báo Parameter ở Top để dễ ghi đè từ Testbench
    parameter TEST_INTERVAL = 50_000_000 // 1 giây
)(
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,      // KEY[0]: Reset, KEY[1]: Inject Error
    input  wire [9:0]  SW,       // SW[0]: Enable BIST
    
    // Giao diện hiển thị LED & HEX
    output wire [9:0]  LEDR,
    output wire [6:0]  HEX0,     // Master RX Data LSB
    output wire [6:0]  HEX1,     // Master RX Data MSB
    output wire [6:0]  HEX2,     // TX Pattern LSB
    output wire [6:0]  HEX3,     // TX Pattern MSB
    output wire [6:0]  HEX4,     // Blank
    output wire [6:0]  HEX5      // Blank
    
    // (Tùy chọn) Có thể đưa spi_sclk_wire, spi_cs_n_wire... ra cổng GPIO ở đây 
    // nếu muốn test External Hardware Loopback.
);

    wire clk   = CLOCK_50;
    // Rest co ban
    // wire rst_n = KEY[0];         // Active-low Reset
	 wire rst_n = rst_sync_1;

    // ---------------------------------------------------------
    // Internal Wiring
    // ---------------------------------------------------------
    wire [7:0] current_pattern;
    
    // Từ BIST sang Master
    wire [7:0] tx_data_bist;
    wire       tx_valid_bist;
    wire       tx_ready_master;
    wire [7:0] rx_data_master;
    wire       rx_valid_master;
    
    // Từ Slave sang BIST (Kiểm chứng Full-Duplex)
    wire [7:0] rx_data_slave;
    wire       rx_valid_slave;

    // Bus SPI Vật lý (Internal Loopback Mode)
    wire       spi_sclk_wire;
    wire       spi_cs_n_wire;
    wire       spi_mosi_wire;
    wire       spi_miso_slave_out;
    wire       spi_miso_master_in;

    wire       pass_flag;
    wire       err_flag;
    wire       master_busy;

	 // ---------------------------------------------------------
    // RESET SYNCHRONIZER
    // ---------------------------------------------------------
	 reg rst_sync_0, rst_sync_1;
    always @(posedge clk or negedge KEY[0]) begin
        if (!KEY[0]) begin
            rst_sync_0 <= 1'b0;
            rst_sync_1 <= 1'b0;
        end else begin
            rst_sync_0 <= 1'b1;
            rst_sync_1 <= rst_sync_0; // Đồng bộ hóa việc nhả reset với xung clk
        end
    end
	 
    // ---------------------------------------------------------
    // 1. BIST Controller (Test Engine)
    // ---------------------------------------------------------
    spi_bist #(
        .TEST_INTERVAL(TEST_INTERVAL) // Ghi đè parameter
    ) bist_inst (
        .clk             (clk),
        .rst_n           (rst_n),
        .enable          (SW[0]), // Bật/tắt BIST bằng SW[0]
        
        .tx_data         (tx_data_bist),
        .tx_valid        (tx_valid_bist),
        .tx_ready        (tx_ready_master),
        .master_rx_data  (rx_data_master),
        .master_rx_valid (rx_valid_master),
        
        .slave_rx_data   (rx_data_slave),
        .slave_rx_valid  (rx_valid_slave),
        
        .pass_flag       (pass_flag),
        .err_flag        (err_flag),
        .current_pattern (current_pattern)
    );

    // ---------------------------------------------------------
    // 2. SPI Master
    // ---------------------------------------------------------
    spi_master #(
        .CLK_FREQ(50_000_000), 
        .SPI_FREQ(1_000_000)
    ) master_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .tx_data   (tx_data_bist),
        .tx_valid  (tx_valid_bist),
        .tx_ready  (tx_ready_master),
        .rx_data   (rx_data_master),
        .rx_valid  (rx_valid_master),
        .busy      (master_busy),
        
        .spi_sclk  (spi_sclk_wire),
        .spi_cs_n  (spi_cs_n_wire),
        .spi_mosi  (spi_mosi_wire),
        .spi_miso  (spi_miso_master_in) // MISO đã qua trạm bơm lỗi
    );

    // ---------------------------------------------------------
    // 3. SPI Slave (Loopback Target)
    // ---------------------------------------------------------
    spi_slave slave_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        // Sửa lỗi Echo: Cấp trước Pattern cho Slave để nó chuẩn bị TX ở cạnh xuống đầu tiên của CS_N
        .tx_data   (current_pattern), 
        .rx_data   (rx_data_slave),
        .rx_valid  (rx_valid_slave),
        
        .spi_sclk  (spi_sclk_wire),
        .spi_cs_n  (spi_cs_n_wire),
        .spi_mosi  (spi_mosi_wire),
        .spi_miso  (spi_miso_slave_out) // MISO gốc từ Slave
    );

    // ---------------------------------------------------------
    // 4. ERROR INJECTOR (Hardware Sabotage)
    // ---------------------------------------------------------
    // Khi nhấn KEY[1] (kéo xuống mức 0), tín hiệu MISO bị đảo ngược (NOT). 
    // Điều này giả lập đường dây vật lý bị đứt hoặc nhiễu nặng, 
    // lập tức kích hoạt err_flag ở BIST.
    wire inject_error = ~KEY[1]; 
    assign spi_miso_master_in = inject_error ? ~spi_miso_slave_out : spi_miso_slave_out;

    // ---------------------------------------------------------
    // 5. User Interface (LED & HEX)
    // ---------------------------------------------------------
    // LED hiển thị trạng thái của BIST và SPI Master
    assign LEDR[9] = pass_flag;
    assign LEDR[8] = err_flag;
    assign LEDR[7] = master_busy;
    assign LEDR[6:0] = 7'd0;

    // HEX0, HEX1: Hiển thị Dữ liệu Master thu về (để so sánh)
    hex_decoder hex_rx_lsb (.bin(rx_data_master[3:0]), .seg(HEX0));
    hex_decoder hex_rx_msb (.bin(rx_data_master[7:4]), .seg(HEX1));

    // HEX2, HEX3: Hiển thị Test Pattern gốc (để đối chiếu)
    hex_decoder hex_tx_lsb (.bin(current_pattern[3:0]), .seg(HEX2));
    hex_decoder hex_tx_msb (.bin(current_pattern[7:4]), .seg(HEX3));

    // Tắt các đèn HEX không dùng
    assign HEX4 = 7'b111_1111;
    assign HEX5 = 7'b111_1111;

endmodule

// ============================================================================
// Helper Module: HEX Decoder
// ============================================================================
module hex_decoder(
    input  wire [3:0] bin,
    output reg  [6:0] seg
);
    always @(*) begin
        case (bin)
            4'h0: seg = 7'b1000000; 4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000; 4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110; 4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110; 4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule