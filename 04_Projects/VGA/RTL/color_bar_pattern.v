module color_bar_pattern (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire       video_on,
    output reg  [7:0] vga_r,
    output reg  [7:0] vga_g,
    output reg  [7:0] vga_b
);

    always @(*) begin
        if (!video_on) begin
            vga_r = 8'h00; vga_g = 8'h00; vga_b = 8'h00;
        end else begin
            if (pixel_x < 80)        begin vga_r = 8'hFF; vga_g = 8'hFF; vga_b = 8'hFF; end // Trắng
            else if (pixel_x < 160)  begin vga_r = 8'hFF; vga_g = 8'hFF; vga_b = 8'h00; end // Vàng
            else if (pixel_x < 240)  begin vga_r = 8'h00; vga_g = 8'hFF; vga_b = 8'hFF; end // Xanh lơ (Cyan)
            else if (pixel_x < 320)  begin vga_r = 8'h00; vga_g = 8'hFF; vga_b = 8'h00; end // Xanh lá
            else if (pixel_x < 400)  begin vga_r = 8'hFF; vga_g = 8'h00; vga_b = 8'hFF; end // Tím (Magenta)
            else if (pixel_x < 480)  begin vga_r = 8'hFF; vga_g = 8'h00; vga_b = 8'h00; end // Đỏ
            else if (pixel_x < 560)  begin vga_r = 8'h00; vga_g = 8'h00; vga_b = 8'hFF; end // Xanh dương
            else                     begin vga_r = 8'h00; vga_g = 8'h00; vga_b = 8'h00; end // Đen
        end
    end

endmodule