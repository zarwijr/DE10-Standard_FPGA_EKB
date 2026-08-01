`timescale 1ns/1ps
module tb_vga_timing();
    reg clk_25m;
    reg rst_n;
    wire hsync, vsync, video_on;
    wire [9:0] pixel_x, pixel_y;

    vga_timing uut (
        .clk_25m175(clk_25m),
        .rst_n(rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // Tạo clock 25.175MHz (~39.7ns period)
    always #19.85 clk_25m = ~clk_25m;

    initial begin
        clk_25m = 0;
        rst_n = 0;
        #100 rst_n = 1;
        
        // Mô phỏng chạy một khoảng thời gian đủ dài để quét vài khung hình
        #20000000;
        $stop;
    end
endmodule