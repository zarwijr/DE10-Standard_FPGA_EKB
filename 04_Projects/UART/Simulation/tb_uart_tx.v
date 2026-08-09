// ============================================================
// Module    : tb_uart_tx.v
// Project   : DE10-Standard_FPGA_EKB / 04_Projects/UART
// Volume ref: Volume III - Verification and Simulation, Chapter 2
// Author    : Nguyen Gia Huy
// Description : Self-checking testbench for uart_tx module
//               (bo sung watchdog/timeout de dong bo voi tb_uart_rx.v,
//                phong ngua treo mo phong neu tx_line khong bao gio
//                chuyen trang thai vi loi logic DUT)
// ============================================================

`timescale 1ns / 1ps

module tb_uart_tx;

    // Cac tham so cau hinh mo phong
    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115_200;
    localparam CLK_PERIOD = 20; // 50 MHz -> 20ns

    // Tinh thoi gian 1 bit UART (ns)
    localparam real BIT_PERIOD_NS = 1_000_000_000.0 / BAUD_RATE;

    // Signals ket noi voi DUT (Device Under Test)
    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx_busy;
    wire       tx_line;

    integer error_count = 0;

    // Khoi tao DUT
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_line(tx_line)
    );

    // Bo tao Clock 50MHz
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Task mo hinh tham chieu tu dong kiem tra du lieu truyen ra
    // (co watchdog cho buoc cho Start bit, tranh treo vo han)
    task monitor_and_check;
        input [7:0] expected_data;
        reg [7:0] rx_data;
        reg       timeout_flag;
        integer   i;
        begin
            timeout_flag = 1'b0;

            // 1. Cho Start bit (canh xuong cua tx_line), co gioi han thoi gian
            fork
                begin : evt_start
                    @(negedge tx_line);
                    disable tmo_start;
                end
                begin : tmo_start
                    #(BIT_PERIOD_NS * 15); // du lon hon 1 frame (10 bit)
                    timeout_flag = 1'b1;
                    disable evt_start;
                end
            join

            if (timeout_flag) begin
                $display("[FAIL] %t PS: TIMEOUT - khong phat hien Start bit tren tx_line", $time);
                error_count = error_count + 1;
            end else begin
                // 2. Cho 0.5 thoi gian bit de nhay vao GIUA Start bit
                #(BIT_PERIOD_NS / 2.0);
                if (tx_line !== 1'b0) begin
                    $display("[FAIL] %t PS: Start bit khong hop le (Expected 0, Got %b)", $time, tx_line);
                    error_count = error_count + 1;
                end

                // 3. Lay mau 8 bit du lieu tai vi tri giua cua moi bit
                for (i = 0; i < 8; i = i + 1) begin
                    #(BIT_PERIOD_NS);
                    rx_data[i] = tx_line;
                end

                // 4. Kiem tra Stop bit
                #(BIT_PERIOD_NS);
                if (tx_line !== 1'b1) begin
                    $display("[FAIL] %t PS: Stop bit khong hop le (Expected 1, Got %b)", $time, tx_line);
                    error_count = error_count + 1;
                end

                // 5. So sanh byte lay mau duoc voi byte mong doi
                if (rx_data === expected_data) begin
                    $display("[PASS] %t PS: Truyen thanh cong Byte 0x%h ('%c')", $time, rx_data, rx_data);
                end else begin
                    $display("[FAIL] %t PS: Sai du lieu! Expected: 0x%h, Got: 0x%h", $time, expected_data, rx_data);
                    error_count = error_count + 1;
                end
            end
        end
    endtask

    // Watchdog toan cuc: dam bao mo phong luon ket thuc, khong bao gio treo vo han
    initial begin
        #(BIT_PERIOD_NS * 500);
        $display("==================================================");
        $display("   >>> GLOBAL TIMEOUT: MO PHONG BI TREO, DA BUOC KET THUC <<<   ");
        $display("==================================================");
        $finish;
    end

    // Tien trinh gui test cases
    initial begin
        // Khoi tao tin hieu ban dau
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        $display("==================================================");
        $display("   BAT DAU KIEM CHUNG MODULE UART_TX (SELF-CHECK) ");
        $display("==================================================");

        // Reset he thong
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        // TEST CASE 1: Gui ky tu 'A' (0x41)
        fork
            begin
                @(posedge clk);
                tx_data  = 8'h41;
                tx_start = 1'b1;
                @(posedge clk);
                tx_start = 1'b0;
            end
            begin
                monitor_and_check(8'h41);
            end
        join

        #(CLK_PERIOD * 50);

        // TEST CASE 2: Gui ky tu 'K' (0x4B)
        fork
            begin
                @(posedge clk);
                tx_data  = 8'h4B;
                tx_start = 1'b1;
                @(posedge clk);
                tx_start = 1'b0;
            end
            begin
                monitor_and_check(8'h4B);
            end
        join

        #(CLK_PERIOD * 50);

        // Tong ket ket qua kiem thu
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