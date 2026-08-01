module vga_timing (
    input  wire       clk_25m175, 
    input  wire       rst_n,
    output reg        hsync, 
    output reg        vsync, 
    output reg        video_on,
    output reg  [9:0] pixel_x, 
    output reg  [9:0] pixel_y
);

    // Thông số VESA 640x480@60Hz
    parameter H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2, V_BACK = 33, V_TOTAL = 525;

    // Bộ đếm H (0..799) và V (0..524)
    always @(posedge clk_25m175 or negedge rst_n) begin
        if (!rst_n) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end else begin
            if (pixel_x == H_TOTAL - 1) begin
                pixel_x <= 0;
                if (pixel_y == V_TOTAL - 1)
                    pixel_y <= 0;
                else
                    pixel_y <= pixel_y + 1;
            end else begin
                pixel_x <= pixel_x + 1;
            end
        end
    end

    // Sinh tín hiệu hsync, vsync (Active Low) và video_on
    always @(posedge clk_25m175 or negedge rst_n) begin
        if (!rst_n) begin
            hsync    <= 1'b1;
            vsync    <= 1'b1;
            video_on <= 1'b0;
        end else begin
            hsync <= ~((pixel_x >= H_DISPLAY + H_FRONT) && (pixel_x < H_DISPLAY + H_FRONT + H_SYNC));
            vsync <= ~((pixel_y >= V_DISPLAY + V_FRONT) && (pixel_y < V_DISPLAY + V_FRONT + V_SYNC));
            video_on <= (pixel_x < H_DISPLAY) && (pixel_y < V_DISPLAY);
        end
    end
endmodule