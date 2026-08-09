// ============================================================================
// File Name   : vga_pattern_generator.v
// Module Name : vga_pattern_generator
// Project     : DE10-Standard FPGA EKB (Volume IV - Chapter 4)
// Description : Sinh 8 thanh mau doc (color bar) chuan cho do phan giai 640x480
// ============================================================================

module vga_pattern_generator (
    input  wire [9:0] i_pixel_x,
    input  wire [9:0] i_pixel_y,
    input  wire       i_video_on,
    output reg  [7:0] o_vga_r,
    output reg  [7:0] o_vga_g,
    output reg  [7:0] o_vga_b
);

    // Moi thanh mau rong = 640 / 8 = 80 pixel -> dung bit [9:6] cua pixel_x
    always @(*) begin
        if (!i_video_on) begin
            o_vga_r = 8'h00;
            o_vga_g = 8'h00;
            o_vga_b = 8'h00;
        end else begin
            case (i_pixel_x[9:6])
                3'd0: begin o_vga_r = 8'hFF; o_vga_g = 8'hFF; o_vga_b = 8'hFF; end // Trang
                3'd1: begin o_vga_r = 8'hFF; o_vga_g = 8'hFF; o_vga_b = 8'h00; end // Vang
                3'd2: begin o_vga_r = 8'h00; o_vga_g = 8'hFF; o_vga_b = 8'hFF; end // Xanh lo (Cyan)
                3'd3: begin o_vga_r = 8'h00; o_vga_g = 8'hFF; o_vga_b = 8'h00; end // Xanh la
                3'd4: begin o_vga_r = 8'hFF; o_vga_g = 8'h00; o_vga_b = 8'hFF; end // Tim (Magenta)
                3'd5: begin o_vga_r = 8'hFF; o_vga_g = 8'h00; o_vga_b = 8'h00; end // Do
                3'd6: begin o_vga_r = 8'h00; o_vga_g = 8'h00; o_vga_b = 8'hFF; end // Xanh duong
                default: begin o_vga_r = 8'h00; o_vga_g = 8'h00; o_vga_b = 8'h00; end // Den
            endcase
        end
    end

endmodule