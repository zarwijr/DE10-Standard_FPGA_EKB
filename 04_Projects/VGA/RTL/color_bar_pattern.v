// ============================================================================
// File Name   : color_bar_pattern.v
// Module Name : color_bar_pattern
// Description : Generates 8 vertical color bars for testing
//               Each bar = 80 pixels (640 / 8)
// ============================================================================

module color_bar_pattern (
    input  wire [9:0]  pixel_x,      // X coordinate (0..639 active)
    input  wire [9:0]  pixel_y,      // Y coordinate (0..479 active)
    input  wire        video_on,     // Active during display area
    output reg  [7:0]  vga_r,        // Red channel (8-bit)
    output reg  [7:0]  vga_g,        // Green channel (8-bit)
    output reg  [7:0]  vga_b         // Blue channel (8-bit)
);

    always @(*) begin
        if (!video_on) begin
            vga_r = 8'h00;
            vga_g = 8'h00;
            vga_b = 8'h00;
        end else begin
            // Divide 640-pixel width into 8 bars of 80 pixels each
            if (pixel_x < 80)
                {vga_r, vga_g, vga_b} = {8'hFF, 8'hFF, 8'hFF};  // White
            else if (pixel_x < 160)
                {vga_r, vga_g, vga_b} = {8'hFF, 8'hFF, 8'h00};  // Yellow
            else if (pixel_x < 240)
                {vga_r, vga_g, vga_b} = {8'h00, 8'hFF, 8'hFF};  // Cyan
            else if (pixel_x < 320)
                {vga_r, vga_g, vga_b} = {8'h00, 8'hFF, 8'h00};  // Green
            else if (pixel_x < 400)
                {vga_r, vga_g, vga_b} = {8'hFF, 8'h00, 8'hFF};  // Magenta
            else if (pixel_x < 480)
                {vga_r, vga_g, vga_b} = {8'hFF, 8'h00, 8'h00};  // Red
            else if (pixel_x < 560)
                {vga_r, vga_g, vga_b} = {8'h00, 8'h00, 8'hFF};  // Blue
            else
                {vga_r, vga_g, vga_b} = {8'h00, 8'h00, 8'h00};  // Black
        end
    end

endmodule
