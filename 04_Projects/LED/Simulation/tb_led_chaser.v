`timescale 1ns / 1ps

module tb_led_chaser;

    reg        tb_CLOCK_50;
    reg        tb_KEY0_rst_n;
    wire [7:0] tb_LEDR;

    // Instantiate DUT (Device Under Test)
    led_chaser u_dut (
        .CLOCK_50   (tb_CLOCK_50),
        .KEY0_rst_n (tb_KEY0_rst_n),
        .LEDR       (tb_LEDR)
    );

    // Override tham số để tăng tốc mô phỏng (1 tick mỗi 5 chu kỳ clock)
    defparam u_dut.u_clk_divider.CLK_FREQ    = 5;
    defparam u_dut.u_clk_divider.TARGET_FREQ = 1;

    // Tạo xung clock 50MHz (T = 20ns => đảo trạng thái mỗi 10ns)
    always #10 tb_CLOCK_50 = ~tb_CLOCK_50;

    initial begin
        // Khởi tạo
        tb_CLOCK_50   = 1'b0;
        tb_KEY0_rst_n = 1'b0; // Kích hoạt Reset ban đầu

        #50;
        tb_KEY0_rst_n = 1'b1; // Tháo Reset

        // Mô phỏng đủ 2 chu kỳ chạy 8 trạng thái (16 lần chuyển state)
        #2000;

        // Thử nghiệm Reset đột ngột
        $display("[%0t ns] Test Asynchronous Reset...", $time);
        tb_KEY0_rst_n = 1'b0;
        #40;
        tb_KEY0_rst_n = 1'b1;

        #1000;
        $display("[%0t ns] Simulation Completed Successfully!", $time);
        $finish;
    end

endmodule