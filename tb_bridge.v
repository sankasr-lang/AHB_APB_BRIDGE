`timescale 1ns/1ps
module tb_ahb_master;

    reg HCLK;
    reg Hresetn;
    wire Hwrite;
    wire Hreadyin;
    wire [1:0]  Htrans;
    wire [31:0] Haddr;
    wire [31:0] Hwdata;
    wire [1:0]  Hresp;
    wire [31:0] Hrdata;
    wire Hreadyout;
    wire Pwrite;
    wire Penable;
    wire [2:0]  Pselx;
    wire [31:0] Paddr;
    wire [31:0] Pwdata;
    reg  [31:0] Prdata;
    top_ahb_apb_bridge dut (
        .HCLK      (HCLK),
        .Hresetn   (Hresetn),
        .Hwrite    (Hwrite),
        .Hreadyin  (Hreadyin),
        .Htrans    (Htrans),
        .Haddr     (Haddr),
        .Hwdata    (Hwdata),
        .Hresp     (Hresp),
        .Hrdata    (Hrdata),
        .Hreadyout (Hreadyout),
        .Pwrite    (Pwrite),
        .Penable   (Penable),
        .Pselx     (Pselx),
        .Paddr     (Paddr),
        .Pwdata    (Pwdata),
        .Prdata    (Prdata)
    );

    ahb_master u_master (
        .HCLK      (HCLK),
        .Hresetn   (Hresetn),
        .Hwrite    (Hwrite),
        .Hreadyin  (Hreadyin),
        .Htrans    (Htrans),
        .Haddr     (Haddr),
        .Hwdata    (Hwdata),
        .Hresp     (Hresp),
        .Hrdata    (Hrdata),
        .Hreadyout (Hreadyout)
    );

    initial HCLK = 0;
    always #5 HCLK = ~HCLK;
    always @(*) begin
        if (top_ahb_apb_bridge.u_apb_pro.state == top_ahb_apb_bridge.u_apb_pro.st_renable)
            Prdata = $random;
    end
    initial begin
        Prdata  = 32'h0;
        Hresetn = 0;
        repeat (5) @(posedge HCLK);
        Hresetn = 1;
        repeat (2) @(posedge HCLK);
        u_master.ahb_burst_and_single_write(32'h8000_0004, 3'b010, 3'b000);
        repeat (5) @(posedge HCLK);
        u_master.ahb_burst_and_single_read(32'h8000_0008, 3'b010, 3'b000);
        repeat (5) @(posedge HCLK);
         u_master.ahb_burst_and_single_write(32'h8000_0010, 3'b010, 3'b011);
        repeat (5) @(posedge HCLK);
        u_master.ahb_burst_and_single_read(32'h8000_0020, 3'b010, 3'b011);
        repeat (5) @(posedge HCLK);
        u_master.ahb_burst_and_single_write(32'h8000_0034, 3'b010, 3'b010);
        repeat (5) @(posedge HCLK);
        u_master.ahb_burst_and_single_read(32'h8800_0048, 3'b010, 3'b010);
        repeat (10) @(posedge HCLK);
        $display("=== SIM DONE ===");
        $finish;
    end
    initial begin
        $dumpfile("tb_ahb_master.vcd");
        $dumpvars(0, tb_ahb_master);
    end

endmodule