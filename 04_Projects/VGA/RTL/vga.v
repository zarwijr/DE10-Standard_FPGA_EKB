// ============================================================================
// File Name   : vga.v
// Module Name : vga   (PHAI trung ten voi TOP_LEVEL_ENTITY "vga" trong file .qsf)
// Project     : DE10-Standard FPGA EKB (Volume IV - Chapter 4) - VGA Color Bar
// Target Board: Terasic DE10-Standard - Intel Cyclone V SoC 5CSXFC6D6F31C6N
// Description : Top-level ghep noi PLL pixel clock + vga_controller +
//               vga_pattern_generator, xuat ra cong VGA DAC (ADV7123) tren board.
//               Ten cong I/O lay dung theo file .qsf do Terasic System Builder
//               sinh ra (CLOCK_50, KEY, VGA_*).
// ============================================================================

module vga (
    // ---------------- Clock & Reset ----------------
    input  wire        CLOCK_50,   // Clock nguon 50MHz (PIN_AF14)
    input  wire [3:0]  KEY,        // KEY[0] dung lam reset, active-low

    // ---------------- VGA (ADV7123 DAC) ----------------
    output wire         VGA_HS,
    output wire         VGA_VS,
    output wire [7:0]   VGA_R,
    output wire [7:0]   VGA_G,
    output wire [7:0]   VGA_B,
    output wire         VGA_CLK,
    output wire         VGA_BLANK_N,
    output wire         VGA_SYNC_N
);

    // Reset he thong: active-low, lay tu nut nhan KEY[0]
    wire rst_n = KEY[0];

    // ------------------------------------------------------------------
    // 1) Clock pixel 25.175MHz tu CLOCK_50, dung IP ALTPLL that (Qsys/IP
    //    Catalog) da duoc sinh ra voi ten module "pll_25m175" va cac cong:
    //    refclk, rst, outclk_0, locked.
    //    LUU Y: cong "rst" cua IP ALTPLL la RESET ACTIVE-HIGH (khac voi
    //    rst_n active-low cua KEY[0]) nen phai dao ~rst_n khi dau vao.
    // ------------------------------------------------------------------
    wire clk_pixel;
    wire pll_locked;

    pll_25m175 u_pll (
        .refclk   (CLOCK_50),
        .rst      (~rst_n),
        .outclk_0 (clk_pixel),
        .locked   (pll_locked)
    );

    // Reset dong bo cho mien clock pixel (ket hop reset ngoai + trang thai PLL)
    wire rst_pixel_n = rst_n & pll_locked;

    // ------------------------------------------------------------------
    // 2) Bo dieu khien timing VGA
    // ------------------------------------------------------------------
    wire        hsync, vsync, video_on;
    wire [9:0]  pixel_x, pixel_y;

    vga_controller u_vga_ctrl (
        .i_clk_25mhz    (clk_pixel),
        .i_rst_n        (rst_pixel_n),
        .o_hsync        (hsync),
        .o_vsync        (vsync),
        .o_pixel_x      (pixel_x),
        .o_pixel_y      (pixel_y),
        .o_video_on     (video_on),
        .o_vga_clk      (VGA_CLK),
        .o_vga_blank_n  (VGA_BLANK_N),
        .o_vga_sync_n   (VGA_SYNC_N)
    );

    assign VGA_HS = hsync;
    assign VGA_VS = vsync;

    // ------------------------------------------------------------------
    // 3) Sinh pattern 8 thanh mau (color bar) theo toa do pixel
    // ------------------------------------------------------------------
    vga_pattern_generator u_pattern (
        .i_pixel_x   (pixel_x),
        .i_pixel_y   (pixel_y),
        .i_video_on  (video_on),
        .o_vga_r     (VGA_R),
        .o_vga_g     (VGA_G),
        .o_vga_b     (VGA_B)
    );

endmodule