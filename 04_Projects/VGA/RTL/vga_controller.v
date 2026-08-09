// ============================================================================
// File Name   : vga_controller.v
// Module Name : vga_controller
// Project     : DE10-Standard FPGA EKB (Volume IV - Chapter 4)
// Target Board: Terasic DE10-Standard (Cyclone V SE 5CSXFC6D6F31C6)
// Description : Bo dieu khien tao tin hieu dong bo VGA chuan 640x480 @ 60Hz
//               (800 x 525 tong cong ke ca vung blanking)
// ============================================================================

module vga_controller (
    input  wire       i_clk_25mhz,   // Clock pixel (25MHz hoac 25.175MHz)
    input  wire       i_rst_n,       // Reset dong bo, active-low
    output reg        o_hsync,       // Horizontal Sync (Active Low)
    output reg        o_vsync,       // Vertical Sync (Active Low)
    output wire [9:0] o_pixel_x,     // Toa do pixel X (0..639 trong vung active)
    output wire [9:0] o_pixel_y,     // Toa do pixel Y (0..479 trong vung active)
    output wire       o_video_on,    // Bao vung hien thi hop le (active display)
    output wire       o_vga_clk,     // VGA Clock dua ra DAC ADV7123
    output wire       o_vga_blank_n, // VGA Blank (active-high khi dang active)
    output wire       o_vga_sync_n   // VGA Sync (co dinh, tri video Sync-on-RGB tat)
);

    // ------------------------------------------------------------------
    // Thong so timing chuan 640x480 @ 60Hz (VESA)
    // ------------------------------------------------------------------
    localparam H_ACTIVE      = 10'd640;
    localparam H_FRONT_PORCH = 10'd16;
    localparam H_SYNC_PULSE  = 10'd96;
    localparam H_BACK_PORCH  = 10'd48;
    localparam H_TOTAL       = 10'd800; // 640 + 16 + 96 + 48

    localparam V_ACTIVE      = 10'd480;
    localparam V_FRONT_PORCH = 10'd10;
    localparam V_SYNC_PULSE  = 10'd2;
    localparam V_BACK_PORCH  = 10'd33;
    localparam V_TOTAL       = 10'd525; // 480 + 10 + 2 + 33

    reg [9:0] h_count;
    reg [9:0] v_count;

    // ------------------------------------------------------------------
    // Bo dem ngang (H counter): 0 .. 799
    // ------------------------------------------------------------------
    always @(posedge i_clk_25mhz or negedge i_rst_n) begin
        if (!i_rst_n)
            h_count <= 10'd0;
        else if (h_count == H_TOTAL - 1'b1)
            h_count <= 10'd0;
        else
            h_count <= h_count + 1'b1;
    end

    // ------------------------------------------------------------------
    // Bo dem doc (V counter): 0 .. 524, tang moi khi het 1 dong H
    // ------------------------------------------------------------------
    always @(posedge i_clk_25mhz or negedge i_rst_n) begin
        if (!i_rst_n)
            v_count <= 10'd0;
        else if (h_count == H_TOTAL - 1'b1) begin
            if (v_count == V_TOTAL - 1'b1)
                v_count <= 10'd0;
            else
                v_count <= v_count + 1'b1;
        end
    end

    // ------------------------------------------------------------------
    // Sinh HSync / VSync (Active Low) theo front porch / sync pulse / back porch
    // ------------------------------------------------------------------
    always @(posedge i_clk_25mhz or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_hsync <= 1'b1;
            o_vsync <= 1'b1;
        end else begin
            o_hsync <= ~((h_count >= (H_ACTIVE + H_FRONT_PORCH)) &&
                         (h_count <  (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)));
            o_vsync <= ~((v_count >= (V_ACTIVE + V_FRONT_PORCH)) &&
                         (v_count <  (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)));
        end
    end

    // ------------------------------------------------------------------
    // Vung hien thi hop le + toa do pixel
    // ------------------------------------------------------------------
    assign o_video_on = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
    assign o_pixel_x  = (h_count < H_ACTIVE) ? h_count : 10'd0;
    assign o_pixel_y  = (v_count < V_ACTIVE) ? v_count : 10'd0;

    // ------------------------------------------------------------------
    // Tin hieu xuat cho DAC video ADV7123 tren DE10-Standard
    // ------------------------------------------------------------------
    assign o_vga_clk     = i_clk_25mhz;
    assign o_vga_blank_n = o_video_on;
    assign o_vga_sync_n  = 1'b1; // Co dinh muc cao cho che do RGB 3 kenh rieng

endmodule