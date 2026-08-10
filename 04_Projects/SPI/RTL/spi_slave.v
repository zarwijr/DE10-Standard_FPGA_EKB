// ============================================================================
// File Name   : spi_slave.v
// Module Name : spi_slave
// Project     : DE10-Standard FPGA EKB (Volume IV - SPI Loopback)
// Description : FPGA Internal SPI Slave / Clock-domain edge-detected implementation.
//               * Requirement: SPI_FREQ << CLK_FREQ (e.g., 1 MHz << 50 MHz)
//               * SPI Mode 3 : CPOL=1, CPHA=1
//                              change/shift data on leading edge (falling),
//                              sample data on trailing edge (rising)
// ============================================================================

module spi_slave (
    input  wire       clk,        // System Clock (50MHz) dùng để oversampling
    input  wire       rst_n,      
    
    // User Interface 
    // tx_data phải được chuẩn bị TỪ TRƯỚC bởi BIST/Top-level
    input  wire [7:0] tx_data,    
    output reg  [7:0] rx_data,    
    output reg        rx_valid,   
    
    // SPI Physical Interface
    input  wire       spi_sclk,
    input  wire       spi_cs_n,
    input  wire       spi_mosi,
    output reg        spi_miso
);

    // ---------------------------------------------------------
    // 3-Stage Synchronizer & Edge Detection (Metastability safe)
    // ---------------------------------------------------------
    reg [2:0] sclk_sync;
    reg [2:0] cs_n_sync;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_sync <= 3'b111; // Mode 3 SCLK idle high
            cs_n_sync <= 3'b111;
        end else begin
            sclk_sync <= {sclk_sync[1:0], spi_sclk};
            cs_n_sync <= {cs_n_sync[1:0], spi_cs_n};
        end
    end

    // Phát hiện cạnh sau đồng bộ
    wire sclk_falling_edge = (sclk_sync[2:1] == 2'b10); // Leading edge
    wire sclk_rising_edge  = (sclk_sync[2:1] == 2'b01); // Trailing edge
    wire cs_n_falling_edge = (cs_n_sync[2:1] == 2'b10);
    wire cs_n_rising_edge  = (cs_n_sync[2:1] == 2'b01);

    // ---------------------------------------------------------
    // Shift Registers & Protocol Logic
    // ---------------------------------------------------------
    reg [7:0] shift_reg_tx;
    reg [7:0] shift_reg_rx;
    reg [3:0] bit_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg_tx <= 8'd0;
            shift_reg_rx <= 8'd0;
            spi_miso     <= 1'b1; 
            bit_cnt      <= 4'd0;
            rx_data      <= 8'd0;
            rx_valid     <= 1'b0;
        end else begin
            rx_valid <= 1'b0; 

            // Cạnh xuống của CS_N: Nạp sẵn Test Pattern do BIST cung cấp để chuẩn bị Full-Duplex
            if (cs_n_falling_edge) begin
                shift_reg_tx <= tx_data; 
                bit_cnt      <= 4'd0;
            end 
            else if (cs_n_sync[1] == 1'b0) begin 
                
                // Falling Edge (Leading) -> Shift Data out to MISO
                if (sclk_falling_edge) begin
                    spi_miso     <= shift_reg_tx[7]; // MSB first
                    shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
                end
                
                // Rising Edge (Trailing) -> Sample Data in from MOSI
                if (sclk_rising_edge) begin
                    shift_reg_rx <= {shift_reg_rx[6:0], spi_mosi};
                    bit_cnt      <= bit_cnt + 1'b1;
                end
            end
            
            // Cạnh lên của CS_N: Chốt dữ liệu nhận được
            if (cs_n_rising_edge) begin
                if (bit_cnt == 4'd8) begin
                    rx_data  <= shift_reg_rx;
                    rx_valid <= 1'b1;
                end
                spi_miso <= 1'b1; 
            end
        end
    end
endmodule