// ============================================================================
// File Name   : fpga_vga.v
// Module Name : fpga_vga
// Description : Top-level for DE10-Standard VGA display
//               - PLL to generate 25.175MHz pixel clock from 50MHz
//               - VGA timing controller
//               - Color bar pattern generator
// ============================================================================

module fpga_vga (
    // Clock and reset
    input  wire        CLOCK_50,      // 50MHz system clock (PIN_AF14)
    input  wire [3:0]  KEY,           // Buttons (KEY[0] is reset, active-low)

    // VGA output
    output wire        VGA_CLK,       // Pixel clock to DAC
    output wire        VGA_HS,        // Horizontal sync (active-low)
    output wire        VGA_VS,        // Vertical sync (active-low)
    output wire [7:0]  VGA_R,         // Red channel (8-bit)
    output wire [7:0]  VGA_G,         // Green channel (8-bit)
    output wire [7:0]  VGA_B,         // Blue channel (8-bit)
    output wire        VGA_BLANK_N,   // Blank (active-low during blanking)
    output wire        VGA_SYNC_N     // Sync control (tie high for RGB mode)
);

    // Internal signals
    wire        clk_pix;              // 25.175MHz pixel clock
    wire        pll_locked;           // PLL lock indicator
    wire        rst_n;                // System reset (active-low)
    wire [9:0]  pixel_x;
    wire [9:0]  pixel_y;
    wire        video_on;
    wire        hsync;
    wire        vsync;
    wire [7:0]  rgb_r, rgb_g, rgb_b;

    // Reset: KEY[0] active-low
    assign rst_n = KEY[0];

    // ========================================================================
    // 1. PLL: Generate 25.175MHz from 50MHz
    // ========================================================================
    // NOTE: You must have created pll_25m175 IP in Quartus (IP Catalog)
    //       with input 50MHz and output 25.175MHz
    pll_25m175 u_pll (
        .refclk   (CLOCK_50),
        .rst      (~rst_n),           // PLL reset is active-high
        .outclk_0 (clk_pix),
        .locked   (pll_locked)
    );

    // ========================================================================
    // 2. VGA Timing: Generate sync signals and pixel coordinates
    // ========================================================================
    vga_timing u_vga_timing (
        .clk_25m175 (clk_pix),
        .rst_n      (rst_n),
        .hsync      (hsync),
        .vsync      (vsync),
        .video_on   (video_on),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y)
    );

    // ========================================================================
    // 3. Color Bar Pattern: Generate RGB based on pixel position
    // ========================================================================
    color_bar_pattern u_pattern (
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y),
        .video_on (video_on),
        .vga_r    (rgb_r),
        .vga_g    (rgb_g),
        .vga_b    (rgb_b)
    );

    // ========================================================================
    // 4. VGA DAC Interface
    // ========================================================================
    assign VGA_CLK      = clk_pix;              // Pixel clock to DAC
    assign VGA_HS       = hsync;                // Horizontal sync
    assign VGA_VS       = vsync;                // Vertical sync
    assign VGA_R        = rgb_r;                // Red data
    assign VGA_G        = rgb_g;                // Green data
    assign VGA_B        = rgb_b;                // Blue data
    assign VGA_BLANK_N  = ~(~video_on);         // blank_n active-low (= video_on)
    assign VGA_SYNC_N   = 1'b1;                 // Tie high: separate sync mode

endmodule
