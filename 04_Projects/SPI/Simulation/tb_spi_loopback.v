`timescale 1ns/1ps

module tb_spi_loopback;

    // Tín hiệu hệ thống
    reg         clk;
    reg  [3:0]  KEY;
    reg  [9:0]  SW;
    
    wire [9:0]  LEDR;
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // Khởi tạo Top-Level với TEST_INTERVAL nhỏ để mô phỏng cực nhanh
    spi #(
        .TEST_INTERVAL(1000) // 1000 chu kỳ @50MHz = 20 microseconds
    ) dut (
        .CLOCK_50(clk),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), 
        .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5)
    );

    // Tạo xung Clock 50MHz (Chu kỳ = 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Kịch bản Test (Stimulus)
    initial begin
        // 1. Trạng thái khởi động
        KEY = 4'b1111; // Nút nhấn nhả (Mức 1 là không nhấn)
        SW  = 10'd0;   // Tắt BIST
        
        // 2. Reset hệ thống
        #100;
        KEY[0] = 1'b0; // Nhấn Reset
        #50;
        KEY[0] = 1'b1; // Nhả Reset
        #100;

        $display("==================================================");
        $display("[SYSTEM] KHOI DONG HE THONG SPI BIST LOOPBACK");
        $display("==================================================");

        // 3. Bật BIST Controller
        SW[0] = 1'b1; 
        $display("[TIME: %0t] Bat cong tac SW[0] -> Kich hoat BIST", $time);

        // 4. Đợi giao dịch đầu tiên thành công (Kỳ vọng: PASS)
        wait(LEDR[9] == 1'b1);
        $display("[TIME: %0t] [PASS] Giao dich 1 thanh cong! (Khong co loi)", $time);
        
        // Đợi thêm 1 giao dịch nữa cho chắc chắn
        @(negedge LEDR[9]); // Chờ cờ pass tắt đi khi bắt đầu transaction mới
        wait(LEDR[9] == 1'b1);
        $display("[TIME: %0t] [PASS] Giao dich 2 thanh cong! (Khong co loi)", $time);

        // Đợi một khoảng nghỉ ngắn
        #5000; 

        // 5. BƠM LỖI (ERROR INJECTION)
        $display("--------------------------------------------------");
        $display("[TIME: %0t] [INJECT] Nhan giu KEY[1] -> Bom loi vao MISO!", $time);
        $display("--------------------------------------------------");
        KEY[1] = 1'b0; // Giả lập đứt dây / nhiễu làm đảo bit MISO

        // Đợi hệ thống bắt lỗi
        wait(LEDR[8] == 1'b1); // LEDR[8] là cờ ERROR
        $display("[TIME: %0t] [ERROR CAUGHT] He thong da phat hien loi truyen dan!", $time);

        // 6. PHỤC HỒI (RECOVERY)
        #5000;
        $display("--------------------------------------------------");
        $display("[TIME: %0t] [RECOVER] Nha KEY[1] -> Ket thuc bom loi", $time);
        $display("--------------------------------------------------");
        KEY[1] = 1'b1;

        // Đợi hệ thống tự động truyền lại đúng
        @(negedge LEDR[8]); // Chờ cờ error tắt
        wait(LEDR[9] == 1'b1); // Chờ cờ PASS sáng lại
        $display("[TIME: %0t] [PASS] He thong da khoi phuc va truyen dung tro lai!", $time);

    end

// ====================================================================
// WATCHDOG TIMEOUT: Ngăn chặn mô phỏng bị treo vĩnh viễn
// ====================================================================
initial begin
    // Quy định thời gian tối đa mô phỏng được phép chạy (ví dụ: 10ms = 10_000_000ns)
    #10_000_000; 
    
    $display("\n==================================================");
    $display("[ERROR TIMEOUT] Mo phong bi treo do kiet dieu kien wait/event!");
    $display("[ERROR TIMEOUT] Kiem tra lai logic RTL hoac tin hieu trigger.");
    $display("==================================================\n");
    
    // Dung mo phong hoac ket thuc luon
    $stop;    // Hoac dung $finish; neu muon thoat vsim ngay lap tuc
end

endmodule