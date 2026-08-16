module top_ahb_apb_bridge (
    input  HCLK,
    input  Hresetn,
    input  Hwrite,
    input  Hreadyin,
    input  [1:0]  Htrans,
    input  [31:0] Haddr,
    input  [31:0] Hwdata,
    output [1:0]  Hresp,
    output [31:0] Hrdata,
    output Hreadyout,

    output Pwrite,
    output Penable,
    output [2:0]  Pselx,
    output [31:0] Paddr,
    output [31:0] Pwdata,
    input  [31:0] Prdata
);

    wire valid;
    wire [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2;
    wire Hwritereg, Hwritereg2;
    wire [2:0] tempselx;
    wire [31:0] Prdata_bridge;

    ahb_slave u_ahb_slave (
        .HCLK          (HCLK),
        .Hresetn       (Hresetn),
        .Hwrite        (Hwrite),
        .Hreadyin      (Hreadyin),
        .Htrans        (Htrans),
        .Haddr         (Haddr),
        .Hwdata        (Hwdata),
        .Hresp         (Hresp),
        .Hrdata        (Hrdata),
        .valid         (valid),
        .Haddr1        (Haddr1),
        .Haddr2        (Haddr2),
        .Hwdata1       (Hwdata1),
        .Hwdata2       (Hwdata2),
        .Hwritereg     (Hwritereg),
        .Hwritereg2    (Hwritereg2),
        .tempselx      (tempselx),
        .Prdata_bridge (Prdata_bridge)
    );

    apb_pro u_apb_pro (
        .HCLK          (HCLK),
        .Hresetn       (Hresetn),
        .valid         (valid),
        .Hwrite        (Hwrite),
        .Haddr1        (Haddr1),
        .Haddr2        (Haddr2),
        .Hwdata1       (Hwdata1),
        .Hwdata2       (Hwdata2),
        .Hwritereg     (Hwritereg),
        .Hwritereg2    (Hwritereg2),
        .tempselx      (tempselx),
        .Pwrite        (Pwrite),
        .Penable       (Penable),
        .Pselx         (Pselx),
        .Paddr         (Paddr),
        .Pwdata        (Pwdata),
        .Prdata        (Prdata),
        .Hreadyout     (Hreadyout),
        .Prdata_bridge (Prdata_bridge)
    );

endmodule