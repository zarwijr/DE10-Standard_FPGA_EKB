// ============================================================================
// Copyright (c) 2016 by Terasic Technologies Inc.
// ============================================================================

`define ENABLE_HPS
//`define ENABLE_HSMC

module hps(
    ///////// CLOCK /////////
    input                CLOCK2_50,
    input                CLOCK3_50,
    input                CLOCK4_50,
    input                CLOCK_50,

    ///////// KEY /////////
    input      [ 3: 0]   KEY,

    ///////// SW /////////
    input      [ 9: 0]   SW,

    ///////// LED /////////
    output     [ 9: 0]   LEDR,

    ///////// Seg7 /////////
    output     [ 6: 0]   HEX0,
    output     [ 6: 0]   HEX1,
    output     [ 6: 0]   HEX2,
    output     [ 6: 0]   HEX3,
    output     [ 6: 0]   HEX4,
    output     [ 6: 0]   HEX5,

    ///////// SDRAM /////////
    output               DRAM_CLK,
    output               DRAM_CKE,
    output     [12: 0]   DRAM_ADDR,
    output     [ 1: 0]   DRAM_BA,
    inout      [15: 0]   DRAM_DQ,
    output               DRAM_LDQM,
    output               DRAM_UDQM,
    output               DRAM_CS_N,
    output               DRAM_WE_N,
    output               DRAM_CAS_N,
    output               DRAM_RAS_N,

    ///////// Video-In /////////
    input                TD_CLK27,
    input                TD_HS,
    input                TD_VS,
    input      [ 7: 0]   TD_DATA,
    output               TD_RESET_N,

    ///////// VGA /////////
    output               VGA_CLK,
    output               VGA_HS,
    output               VGA_VS,
    output     [ 7: 0]   VGA_R,
    output     [ 7: 0]   VGA_G,
    output     [ 7: 0]   VGA_B,
    output               VGA_BLANK_N,
    output               VGA_SYNC_N,

    ///////// Audio /////////
    inout                AUD_BCLK,
    output               AUD_XCK,
    inout                AUD_ADCLRCK,
    input                AUD_ADCDAT,
    inout                AUD_DACLRCK,
    output               AUD_DACDAT,

    ///////// PS2 /////////
    inout                PS2_CLK,
    inout                PS2_CLK2,
    inout                PS2_DAT,
    inout                PS2_DAT2,

    ///////// ADC /////////
    output               ADC_SCLK,
    input                ADC_DOUT,
    output               ADC_DIN,
    output               ADC_CONVST,

    ///////// I2C for Audio and Video-In /////////
    output               FPGA_I2C_SCLK,
    inout                FPGA_I2C_SDAT,

    ///////// GPIO /////////
    inout      [35: 0]   GPIO,

`ifdef ENABLE_HPS
    ///////// HPS /////////
    inout                HPS_CONV_USB_N,
    output     [14: 0]   HPS_DDR3_ADDR,
    output     [ 2: 0]   HPS_DDR3_BA,
    output               HPS_DDR3_CAS_N,
    output               HPS_DDR3_CKE,
    output               HPS_DDR3_CK_N,
    output               HPS_DDR3_CK_P,
    output               HPS_DDR3_CS_N,
    output     [ 3: 0]   HPS_DDR3_DM,
    inout      [31: 0]   HPS_DDR3_DQ,
    inout      [ 3: 0]   HPS_DDR3_DQS_N,
    inout      [ 3: 0]   HPS_DDR3_DQS_P,
    output               HPS_DDR3_ODT,
    output               HPS_DDR3_RAS_N,
    output               HPS_DDR3_RESET_N,
    input                HPS_DDR3_RZQ,
    output               HPS_DDR3_WE_N,
    output               HPS_ENET_GTX_CLK,
    inout                HPS_ENET_INT_N,
    output               HPS_ENET_MDC,
    inout                HPS_ENET_MDIO,
    input                HPS_ENET_RX_CLK,
    input      [ 3: 0]   HPS_ENET_RX_DATA,
    input                HPS_ENET_RX_DV,
    output     [ 3: 0]   HPS_ENET_TX_DATA,
    output               HPS_ENET_TX_EN,
    inout      [ 3: 0]   HPS_FLASH_DATA,
    output               HPS_FLASH_DCLK,
    output               HPS_FLASH_NCSO,
    inout                HPS_GSENSOR_INT,
    inout                HPS_I2C1_SCLK,
    inout                HPS_I2C1_SDAT,
    inout                HPS_I2C2_SCLK,
    inout                HPS_I2C2_SDAT,
    inout                HPS_I2C_CONTROL,
    inout                HPS_KEY,
    inout                HPS_LCM_BK,
    inout                HPS_LCM_D_C,
    inout                HPS_LCM_RST_N,
    output               HPS_LCM_SPIM_CLK,
    output               HPS_LCM_SPIM_MOSI,
    input                HPS_LCM_SPIM_MISO,
    output               HPS_LCM_SPIM_SS,
    inout                HPS_LED,
    inout                HPS_LTC_GPIO,
    output               HPS_SD_CLK,
    inout                HPS_SD_CMD,
    inout      [ 3: 0]   HPS_SD_DATA,
    output               HPS_SPIM_CLK,
    input                HPS_SPIM_MISO,
    output               HPS_SPIM_MOSI,
    output               HPS_SPIM_SS,
    input                HPS_UART_RX,
    output               HPS_UART_TX,
    input                HPS_USB_CLKOUT,
    inout      [ 7: 0]   HPS_USB_DATA,
    input                HPS_USB_DIR,
    input                HPS_USB_NXT,
    output               HPS_USB_STP,
`endif /*ENABLE_HPS*/

    ///////// IR /////////
    output               IRDA_TXD,
    input                IRDA_RXD
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire         clk_65, clk_130;
wire [7:0]   vid_r, vid_g, vid_b;
wire         vid_v_sync;
wire         vid_h_sync;
wire         vid_datavalid;

wire         hps_fpga_reset_n;
wire [3:0]   fpga_debounced_buttons;
wire [9:0]   fpga_led_internal; // Khớp với độ rộng 10 bit của led_pio trong Qsys
wire [2:0]   hps_reset_req;
wire         hps_cold_reset;
wire         hps_warm_reset;
wire         hps_debug_reset;
wire [27:0]  stm_hw_events;
wire         fpga_clk_50;

assign stm_hw_events = {{4{1'b0}}, SW, fpga_led_internal[8:0], fpga_debounced_buttons};
assign fpga_clk_50   = CLOCK_50;
assign VGA_BLANK_N   = 1'b1;
assign VGA_SYNC_N    = 1'b0;
assign VGA_CLK       = clk_65;
assign {VGA_B, VGA_G, VGA_R} = {vid_b, vid_g, vid_r};
assign VGA_VS        = vid_v_sync;
assign VGA_HS        = vid_h_sync;
assign TD_RESET_N    = 1'b1;

//=======================================================
//  Structural coding
//=======================================================

// 1. Khởi tạo PLL
vga_pll vga_pll_inst(
    .refclk    (CLOCK_50),
    .rst       (1'b0),
    .outclk_0  (clk_65),
    .outclk_1  (clk_130),
    .locked    ()
);

// 2. Khởi tạo hệ thống soc_system (Đã map ĐÚNG TÊN CỔNG QSYS THỰC TẾ)
soc_system u0 (
    // Clock & Reset
    .clk_clk                                   (CLOCK_50),
    .reset_reset_n                             (1'b1),

    // HPS DDR3 Memory
    .memory_mem_a                              (HPS_DDR3_ADDR),
    .memory_mem_ba                             (HPS_DDR3_BA),
    .memory_mem_ck                             (HPS_DDR3_CK_P),
    .memory_mem_ck_n                           (HPS_DDR3_CK_N),
    .memory_mem_cke                            (HPS_DDR3_CKE),
    .memory_mem_cs_n                           (HPS_DDR3_CS_N),
    .memory_mem_ras_n                          (HPS_DDR3_RAS_N),
    .memory_mem_cas_n                          (HPS_DDR3_CAS_N),
    .memory_mem_we_n                           (HPS_DDR3_WE_N),
    .memory_mem_reset_n                        (HPS_DDR3_RESET_N),
    .memory_mem_dq                             (HPS_DDR3_DQ),
    .memory_mem_dqs                            (HPS_DDR3_DQS_P),
    .memory_mem_dqs_n                          (HPS_DDR3_DQS_N),
    .memory_mem_odt                            (HPS_DDR3_ODT),
    .memory_mem_dm                             (HPS_DDR3_DM),
    .memory_oct_rzqin                          (HPS_DDR3_RZQ),

    // HPS Ethernet
    .hps_io_hps_io_emac1_inst_TX_CLK           (HPS_ENET_GTX_CLK),
    .hps_io_hps_io_emac1_inst_TXD0             (HPS_ENET_TX_DATA[0]),
    .hps_io_hps_io_emac1_inst_TXD1             (HPS_ENET_TX_DATA[1]),
    .hps_io_hps_io_emac1_inst_TXD2             (HPS_ENET_TX_DATA[2]),
    .hps_io_hps_io_emac1_inst_TXD3             (HPS_ENET_TX_DATA[3]),
    .hps_io_hps_io_emac1_inst_RXD0             (HPS_ENET_RX_DATA[0]),
    .hps_io_hps_io_emac1_inst_MDIO             (HPS_ENET_MDIO),
    .hps_io_hps_io_emac1_inst_MDC              (HPS_ENET_MDC),
    .hps_io_hps_io_emac1_inst_RX_CTL           (HPS_ENET_RX_DV),
    .hps_io_hps_io_emac1_inst_TX_CTL           (HPS_ENET_TX_EN),
    .hps_io_hps_io_emac1_inst_RX_CLK           (HPS_ENET_RX_CLK),
    .hps_io_hps_io_emac1_inst_RXD1             (HPS_ENET_RX_DATA[1]),
    .hps_io_hps_io_emac1_inst_RXD2             (HPS_ENET_RX_DATA[2]),
    .hps_io_hps_io_emac1_inst_RXD3             (HPS_ENET_RX_DATA[3]),

    // HPS QSPI
    .hps_io_hps_io_qspi_inst_IO0               (HPS_FLASH_DATA[0]),
    .hps_io_hps_io_qspi_inst_IO1               (HPS_FLASH_DATA[1]),
    .hps_io_hps_io_qspi_inst_IO2               (HPS_FLASH_DATA[2]),
    .hps_io_hps_io_qspi_inst_IO3               (HPS_FLASH_DATA[3]),
    .hps_io_hps_io_qspi_inst_SS0               (HPS_FLASH_NCSO),
    .hps_io_hps_io_qspi_inst_CLK               (HPS_FLASH_DCLK),

    // HPS SD Card
    .hps_io_hps_io_sdio_inst_CMD               (HPS_SD_CMD),
    .hps_io_hps_io_sdio_inst_D0                (HPS_SD_DATA[0]),
    .hps_io_hps_io_sdio_inst_D1                (HPS_SD_DATA[1]),
    .hps_io_hps_io_sdio_inst_CLK               (HPS_SD_CLK),
    .hps_io_hps_io_sdio_inst_D2                (HPS_SD_DATA[2]),
    .hps_io_hps_io_sdio_inst_D3                (HPS_SD_DATA[3]),

    // HPS USB
    .hps_io_hps_io_usb1_inst_D0                (HPS_USB_DATA[0]),
    .hps_io_hps_io_usb1_inst_D1                (HPS_USB_DATA[1]),
    .hps_io_hps_io_usb1_inst_D2                (HPS_USB_DATA[2]),
    .hps_io_hps_io_usb1_inst_D3                (HPS_USB_DATA[3]),
    .hps_io_hps_io_usb1_inst_D4                (HPS_USB_DATA[4]),
    .hps_io_hps_io_usb1_inst_D5                (HPS_USB_DATA[5]),
    .hps_io_hps_io_usb1_inst_D6                (HPS_USB_DATA[6]),
    .hps_io_hps_io_usb1_inst_D7                (HPS_USB_DATA[7]),
    .hps_io_hps_io_usb1_inst_CLK               (HPS_USB_CLKOUT),
    .hps_io_hps_io_usb1_inst_STP               (HPS_USB_STP),
    .hps_io_hps_io_usb1_inst_DIR               (HPS_USB_DIR),
    .hps_io_hps_io_usb1_inst_NXT               (HPS_USB_NXT),

    // HPS LCD (SPIM0)
    .hps_io_hps_io_spim0_inst_CLK              (HPS_LCM_SPIM_CLK),
    .hps_io_hps_io_spim0_inst_MOSI             (HPS_LCM_SPIM_MOSI),
    .hps_io_hps_io_spim0_inst_MISO             (HPS_LCM_SPIM_MISO),
    .hps_io_hps_io_spim0_inst_SS0              (HPS_LCM_SPIM_SS),

    // HPS SPI (SPIM1)
    .hps_io_hps_io_spim1_inst_CLK              (HPS_SPIM_CLK),
    .hps_io_hps_io_spim1_inst_MOSI             (HPS_SPIM_MOSI),
    .hps_io_hps_io_spim1_inst_MISO             (HPS_SPIM_MISO),
    .hps_io_hps_io_spim1_inst_SS0              (HPS_SPIM_SS),

    // HPS UART
    .hps_io_hps_io_uart0_inst_RX               (HPS_UART_RX),
    .hps_io_hps_io_uart0_inst_TX               (HPS_UART_TX),

    // HPS I2C
    .hps_io_hps_io_i2c0_inst_SDA               (HPS_I2C1_SDAT),
    .hps_io_hps_io_i2c0_inst_SCL               (HPS_I2C1_SCLK),
    .hps_io_hps_io_i2c1_inst_SDA               (HPS_I2C2_SDAT),
    .hps_io_hps_io_i2c1_inst_SCL               (HPS_I2C2_SCLK),

    // PIO & Reset Connections
    .led_pio_external_connection_export       (fpga_led_internal),
    .dipsw_pio_external_connection_export      (SW),
    .button_pio_external_connection_export     (fpga_debounced_buttons),
    .hps_0_h2f_reset_reset_n                  (hps_fpga_reset_n),
    .hps_0_f2h_cold_reset_req_reset_n          (~hps_cold_reset),
    .hps_0_f2h_debug_reset_req_reset_n         (~hps_debug_reset),
    .hps_0_f2h_stm_hw_events_stm_hwevents      (stm_hw_events),
    .hps_0_f2h_warm_reset_req_reset_n          (~hps_warm_reset),

    // VGA ITC Video Interface
    .alt_vip_itc_0_clocked_video_vid_clk       (~clk_65),
    .alt_vip_itc_0_clocked_video_vid_data      ({vid_r, vid_g, vid_b}),
    .alt_vip_itc_0_clocked_video_underflow     (),
    .alt_vip_itc_0_clocked_video_vid_datavalid (vid_datavalid),
    .alt_vip_itc_0_clocked_video_vid_v_sync    (vid_v_sync),
    .alt_vip_itc_0_clocked_video_vid_h_sync    (vid_h_sync),
    .alt_vip_itc_0_clocked_video_vid_f         (),
    .alt_vip_itc_0_clocked_video_vid_h         (),
    .alt_vip_itc_0_clocked_video_vid_v         (),

    // Cổng xung nhịp VGA stream đã sửa ĐÚNG TÊN CHUẨN từ Qsys
    .vga_stream_in_clk_clk                     (clk_130)
);

// 3. Debounce cho nút bấm KEY
debounce debounce_inst (
    .clk       (fpga_clk_50),
    .reset_n   (hps_fpga_reset_n),
    .data_in   (KEY),
    .data_out  (fpga_debounced_buttons)
);
defparam debounce_inst.WIDTH = 4;
defparam debounce_inst.POLARITY = "LOW";
defparam debounce_inst.TIMEOUT = 50000;
defparam debounce_inst.TIMEOUT_WIDTH = 16;

// 4. In-System Sources & Probes (Reset)
hps_reset hps_reset_inst (
    .source_clk (fpga_clk_50),
    .source     (hps_reset_req)
);

altera_edge_detector pulse_cold_reset (
    .clk       (fpga_clk_50),
    .rst_n     (hps_fpga_reset_n),
    .signal_in (hps_reset_req[0]),
    .pulse_out (hps_cold_reset)
);
defparam pulse_cold_reset.PULSE_EXT = 6;
defparam pulse_cold_reset.EDGE_TYPE = 1;
defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
    .clk       (fpga_clk_50),
    .rst_n     (hps_fpga_reset_n),
    .signal_in (hps_reset_req[1]),
    .pulse_out (hps_warm_reset)
);
defparam pulse_warm_reset.PULSE_EXT = 2;
defparam pulse_warm_reset.EDGE_TYPE = 1;
defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_debug_reset (
    .clk       (fpga_clk_50),
    .rst_n     (hps_fpga_reset_n),
    .signal_in (hps_reset_req[2]),
    .pulse_out (hps_debug_reset)
);
defparam pulse_debug_reset.PULSE_EXT = 32;
defparam pulse_debug_reset.EDGE_TYPE = 1;
defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;

// 5. Nối tín hiệu từ Qsys ra các bóng LED vật lý
assign LEDR = fpga_led_internal;

// 6. Hiệu ứng LED 7 đoạn: Chạy từng thanh theo chuỗi a -> b -> g -> e -> d -> c -> g -> f
reg [22:0] hex_counter;
reg [2:0]  hex_seg_idx; // 8 trạng thái (0 đến 7)

always @(posedge fpga_clk_50 or negedge hps_fpga_reset_n)
begin
    if (!hps_fpga_reset_n)
    begin
        hex_counter <= 23'd0;
        hex_seg_idx <= 3'd0;
    end
    else if (hex_counter == 23'd4999999) // Chuyển bước mỗi 100ms (10Hz) cho chuyển động mượt mà
    begin
        hex_counter <= 23'd0;
        hex_seg_idx <= hex_seg_idx + 1'b1; // Tự động quay vòng 0 -> 7
    end
    else
    begin
        hex_counter <= hex_counter + 1'b1;
    end
end

// Giải mã chuỗi thanh LED (Mức 0 là SÁNG - Active LOW)
// Mã bit: {g, f, e, d, c, b, a}
reg [6:0] hex_pattern;

always @(*)
begin
    case (hex_seg_idx)
        3'd0: hex_pattern = 7'b111_1110; // Thanh a
        3'd1: hex_pattern = 7'b111_1101; // Thanh b
        3'd2: hex_pattern = 7'b011_1111; // Thanh g
        3'd3: hex_pattern = 7'b110_1111; // Thanh e
        3'd4: hex_pattern = 7'b111_0111; // Thanh d
        3'd5: hex_pattern = 7'b111_1011; // Thanh c
        3'd6: hex_pattern = 7'b011_1111; // Thanh g
        3'd7: hex_pattern = 7'b101_1111; // Thanh f
        default: hex_pattern = 7'b111_1111; // Tắt tất cả
    endcase
end

// Xuất đồng bộ ra cả 6 LED 7 đoạn
assign HEX0 = hex_pattern;
assign HEX1 = hex_pattern;
assign HEX2 = hex_pattern;
assign HEX3 = hex_pattern;
assign HEX4 = hex_pattern;
assign HEX5 = hex_pattern;

endmodule