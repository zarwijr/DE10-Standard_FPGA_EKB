// ============================================================================
// File Name   : vga_timing.v
// Module Name : vga_timing
// Description : VGA timing generator for 640x480@60Hz (25.175MHz clock)
//               Generates HSYNC, VSYNC, pixel coordinates (x, y), and video_on
// ============================================================================

module vga_timing (
    input  wire        clk_25m175,   // Pixel clock 25.175MHz
    input  wire        rst_n,         // Active-low reset
    output reg         hsync,         // Horizontal sync (active-low)
    output reg         vsync,         // Vertical sync (active-low)
    output wire        video_on,      // Active high during display area
    output wire [9:0]  pixel_x,       // X coordinate (0..799)
    output wire [9:0]  pixel_y        // Y coordinate (0..524)
);

    // VESA 640x480@60Hz timing parameters
    parameter H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2, V_BACK = 33, V_TOTAL = 525;

    reg [9:0] h_count;
    reg [9:0] v_count;

    // Horizontal and vertical counters
    always @(posedge clk_25m175 or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Generate HSYNC (active-low during sync pulse)
    always @(posedge clk_25m175 or negedge rst_n) begin
        if (!rst_n)
            hsync <= 1'b1;
        else
            hsync <= ~((h_count >= H_DISPLAY + H_FRONT) && 
                       (h_count <  H_DISPLAY + H_FRONT + H_SYNC));
    end

    // Generate VSYNC (active-low during sync pulse)
    always @(posedge clk_25m175 or negedge rst_n) begin
        if (!rst_n)
            vsync <= 1'b1;
        else
            vsync <= ~((v_count >= V_DISPLAY + V_FRONT) && 
                       (v_count <  V_DISPLAY + V_FRONT + V_SYNC));
    end

    // Pixel coordinates and video enable
    assign pixel_x = h_count;
    assign pixel_y = v_count;
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

endmodule
