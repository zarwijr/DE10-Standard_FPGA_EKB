// ============================================================================
// File Name   : tb_vga_timing.v
// Description : Testbench for vga_timing module
//               Verifies sync generation and pixel coordinate outputs
// ============================================================================

`timescale 1ns / 1ps

module tb_vga_timing ();
    reg         clk_25m;
    reg         rst_n;
    wire        hsync;
    wire        vsync;
    wire        video_on;
    wire [9:0]  pixel_x;
    wire [9:0]  pixel_y;

    // Instantiate DUT
    vga_timing uut (
        .clk_25m175 (clk_25m),
        .rst_n      (rst_n),
        .hsync      (hsync),
        .vsync      (vsync),
        .video_on   (video_on),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y)
    );

    // Clock: 25.175MHz (period ~39.72ns, use 40ns for simplicity)
    always #20 clk_25m = ~clk_25m;

    initial begin
        clk_25m = 0;
        rst_n = 0;

        // Reset for 100ns
        #100 rst_n = 1;

        // Simulate for ~2 frames (2 * 525 * 800 * 40ns ≈ 33.6ms)
        // But we'll just run a short test
        #1000000;  // Run for ~1 microsecond worth of simulation

        $display("VGA Timing Test Complete");
        $display("  Final pixel_x = %d, pixel_y = %d", pixel_x, pixel_y);
        $display("  video_on = %b, hsync = %b, vsync = %b", video_on, hsync, vsync);

        $stop;
    end

    // Optional: Monitor every line start and frame start
    always @(posedge clk_25m) begin
        if (pixel_x == 0 && pixel_y == 0 && rst_n == 1'b1)
            $display("Frame start at time %t", $time);
        else if (pixel_x == 0 && pixel_y > 0)
            $display("  Line %d starts at time %t", pixel_y, $time);
    end

endmodule
