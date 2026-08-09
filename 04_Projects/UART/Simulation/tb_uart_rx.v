// ============================================================
// Module    : tb_uart_rx.v
// Project   : DE10-Standard_FPGA_EKB / 04_Projects/UART
// Volume ref: Volume III - Verification and Simulation, Chapter 2
// Author    : Nguyen Gia Huy
// Description : Self-checking testbench for uart_rx module
//               (co watchdog/timeout de khong bao gio bi treo mo phong)
// ============================================================

`timescale 1ns / 1ps

module tb_uart_rx;

    localparam CLK_FREQ       = 50_000_000;
    localparam BAUD_RATE      = 115_200;
    localparam CLK_PERIOD     = 20; // 50 MHz -> 20ns
    localparam real BIT_PERIOD_NS = 1_000_000_000.0 / BAUD_RATE;

    reg        clk;
    reg        rst_n;
    reg        rx_line;
    wire [7:0] rx_data;
    wire       rx_done;

    integer error_count = 0;

    // Instantiation
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_line(rx_line),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock Generator
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Task gui 1 byte du lieu noi tiep vao rx_line
    task send_uart_byte;
        input [7:0] data_to_send;
        integer i;
        begin
            // Start bit = '0'
            rx_line = 1'b0;
            #(BIT_PERIOD_NS);

            // 8 Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_line = data_to_send[i];
                #(BIT_PERIOD_NS);
            end

            // Stop bit = '1'
            rx_line = 1'b1;
            #(BIT_PERIOD_NS);
        end
    endtask

    // Task tu kiem tra: gui 1 byte VA cho rx_done SONG SONG (fork/join)
    // -> tranh bi mat xung rx_done do rui ro ve thu tu su kien (race condition)
    // -> co timeout rieng cho tung test, khong bao gio treo vo han
    task run_rx_test;
        input [7:0] data_to_send;
        reg timeout_flag;
        begin
            timeout_flag = 1'b0;

            fork
                // Nhanh 1: phat du lieu noi tiep
                send_uart_byte(data_to_send);

                // Nhanh 2: cho xung rx_done
                begin : done_wait
                    @(posedge rx_done);
                    disable timeout_wait;
                end

                // Nhanh 3: watchdog cuc bo, neu qua thoi gian thi bao timeout
                begin : timeout_wait
                    #(BIT_PERIOD_NS * 15); // du lon hon 1 frame (10 bit)
                    timeout_flag = 1'b1;
                    disable done_wait;
                end
            join

            if (timeout_flag) begin
                $display("[FAIL] %t PS: TIMEOUT - khong nhan duoc xung rx_done sau khi gui Byte 0x%h", $time, data_to_send);
                error_count = error_count + 1;
            end else if (rx_data === data_to_send) begin
                $display("[PASS] %t PS: Module RX nhan chinh xac Byte 0x%h", $time, rx_data);
            end else begin
                $display("[FAIL] %t PS: Module RX nhan sai! Expected 0x%h, Got 0x%h", $time, data_to_send, rx_data);
                error_count = error_count + 1;
            end
        end
    endtask

    // Watchdog toan cuc: neu vi ly do nao do toan bo testbench khong ket thuc
    // dung han, chu dong ket thuc mo phong thay vi treo vo han.
    initial begin
        #(BIT_PERIOD_NS * 500);
        $display("==================================================");
        $display("   >>> GLOBAL TIMEOUT: MO PHONG BI TREO, DA BUOC KET THUC <<<   ");
        $display("==================================================");
        $finish;
    end

    initial begin
        clk     = 0;
        rst_n   = 0;
        rx_line = 1'b1; // Idle state

        $display("==================================================");
        $display("   BAT DAU KIEM CHUNG MODULE UART_RX (SELF-CHECK) ");
        $display("==================================================");

        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        // TEST CASE 1: Gui byte 0x55 ('U')
        $display("[TEST] Dang gui serial byte 0x55...");
        run_rx_test(8'h55);

        #(CLK_PERIOD * 20);

        // TEST CASE 2: Gui byte 0xA5
        $display("[TEST] Dang gui serial byte 0xA5...");
        run_rx_test(8'hA5);

        #(CLK_PERIOD * 50);

        $display("==================================================");
        if (error_count == 0) begin
            $display("   >>> TEST RESULT: ALL PASSED <<<   ");
        end else begin
            $display("   >>> TEST RESULT: FAILED (%0d errors) <<<   ", error_count);
        end
        $display("==================================================");

        $finish;
    end

endmodule