// ============================================================================
// File Name   : spi_master.v
// Module Name : spi_master
// Project     : DE10-Standard FPGA EKB (Volume IV - SPI Loopback)
// Description : EKB-Standard SPI Master Engine
//               SPI Mode 3: 
//                 - CPOL = 1 -> SCLK idle HIGH
//                 - CPHA = 1 -> change/shift data on leading edge (falling),
//                               sample data on trailing edge (rising)
// ============================================================================

module spi_master #(
    parameter CLK_FREQ = 50_000_000, // 50 MHz
    parameter SPI_FREQ = 1_000_000   // 1 MHz
)(
    input  wire       clk,
    input  wire       rst_n,      // Asynchronous active-low reset
    
    // User Interface (To BIST Controller)
    input  wire [7:0] tx_data,
    input  wire       tx_valid,
    output reg        tx_ready,
    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output reg        busy,
    
    // SPI Physical Interface
    output reg        spi_sclk,
    output reg        spi_cs_n,
    output reg        spi_mosi,
    input  wire       spi_miso
);

    // ---------------------------------------------------------
    // Robust Clock Divider
    // ---------------------------------------------------------
    localparam DIV_RATIO = CLK_FREQ / (2 * SPI_FREQ);
    localparam SAFE_DIV  = (DIV_RATIO > 1) ? DIV_RATIO : 1;
    localparam CNT_WIDTH = (SAFE_DIV == 1) ? 1 : $clog2(SAFE_DIV);
    
    reg [CNT_WIDTH-1:0] clk_cnt_reg;
    wire sclk_tick = (clk_cnt_reg == (SAFE_DIV - 1));

    // ---------------------------------------------------------
    // FSM States
    // ---------------------------------------------------------
    localparam S_IDLE      = 3'd0;
    localparam S_ASSERT_CS = 3'd1;
    localparam S_TRANSFER  = 3'd2;
    localparam S_DONE      = 3'd3;

    reg [2:0] state_reg;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [3:0] bit_cnt_reg;
    reg       sclk_next_state_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg           <= S_IDLE;
            tx_shift_reg        <= 8'd0;
            rx_shift_reg        <= 8'd0;
            bit_cnt_reg         <= 4'd0;
            clk_cnt_reg         <= {CNT_WIDTH{1'b0}};
            sclk_next_state_reg <= 1'b0;
            
            tx_ready            <= 1'b1;
            rx_valid            <= 1'b0;
            rx_data             <= 8'd0;
            busy                <= 1'b0;
            
            spi_sclk            <= 1'b1; // CPOL = 1 (Idle High)
            spi_cs_n            <= 1'b1; // CS inactive High
            spi_mosi            <= 1'b1;
        end else begin
            rx_valid <= 1'b0;

            if (state_reg != S_IDLE) begin
                if (sclk_tick) clk_cnt_reg <= {CNT_WIDTH{1'b0}};
                else           clk_cnt_reg <= clk_cnt_reg + 1'b1;
            end else begin
                clk_cnt_reg <= {CNT_WIDTH{1'b0}};
            end

            case (state_reg)
                S_IDLE: begin
                    spi_cs_n <= 1'b1;
                    spi_sclk <= 1'b1;
                    tx_ready <= 1'b1;
                    busy     <= 1'b0;

                    if (tx_valid) begin
                        tx_ready            <= 1'b0;
                        busy                <= 1'b1;
                        spi_cs_n            <= 1'b0; // CS Assert
                        tx_shift_reg        <= tx_data;
                        bit_cnt_reg         <= 4'd0;
                        sclk_next_state_reg <= 1'b0; 
                        state_reg           <= S_ASSERT_CS;
                    end
                end

                S_ASSERT_CS: begin
                    // Đợi nửa chu kỳ SPI Clock để thỏa mãn tCSS (CS setup time)
                    // trước khi có first SCLK leading edge
                    if (sclk_tick) begin
                        state_reg <= S_TRANSFER;
                    end
                end

                S_TRANSFER: begin
                    if (sclk_tick) begin
                        spi_sclk <= sclk_next_state_reg;
                        sclk_next_state_reg <= ~sclk_next_state_reg;

                        // CPOL=1, CPHA=1: change/shift data on leading edge (falling)
                        if (sclk_next_state_reg == 1'b0) begin
                            spi_mosi     <= tx_shift_reg[7]; 
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        end
                        
                        // CPOL=1, CPHA=1: sample data on trailing edge (rising)
                        if (sclk_next_state_reg == 1'b1) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], spi_miso}; 
                            bit_cnt_reg  <= bit_cnt_reg + 1'b1;

                            if (bit_cnt_reg == 4'd7) begin
                                state_reg <= S_DONE;
                            end
                        end
                    end
                end

                S_DONE: begin
                    if (sclk_tick) begin
                        spi_cs_n <= 1'b1; 
                        spi_sclk <= 1'b1; 
                        rx_data  <= rx_shift_reg;
                        rx_valid <= 1'b1; 
                        tx_ready <= 1'b1;
                        busy     <= 1'b0;
                        state_reg <= S_IDLE;
                    end
                end

                default: state_reg <= S_IDLE;
            endcase
        end
    end
endmodule