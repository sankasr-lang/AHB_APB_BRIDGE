module ahb_slave (
    input HCLK,
    input Hresetn,
    input Hwrite,
    input Hreadyin,
    input [1:0]  Htrans,
    input [31:0] Haddr,
    input [31:0] Hwdata,
    output [1:0]  Hresp,
    output [31:0] Hrdata,
    output reg valid,
    output reg [31:0] Haddr1,
    output reg [31:0] Haddr2,
    output reg [31:0] Hwdata1,
    output reg [31:0] Hwdata2,
    output reg Hwritereg,
    output reg Hwritereg2,
    output reg [2:0] tempselx,

   
    input [31:0] Prdata_bridge
);
   assign Hresp = 2'b00;

    always @(*) begin
        if ((Haddr >= 32'h8000_0000 && Haddr <= 32'h8C00_0000) &&
            (Htrans == 2'b10 || Htrans == 2'b11) && Hreadyin == 1'b1)
            valid = 1'b1;
        else
            valid = 1'b0;
    end

    always @(*) begin
        if (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000)
            tempselx = 3'b001;
        else if (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000)
            tempselx = 3'b010;
        else if (Haddr >= 32'h8800_0000 && Haddr < 32'h8C00_0000)
            tempselx = 3'b100;
        else
            tempselx = 3'b000;
    end
     always @(posedge HCLK or negedge Hresetn) begin
        if (!Hresetn) begin
            Haddr1     <= 32'd0;
            Haddr2     <= 32'd0;
            Hwdata1    <= 32'd0;
            Hwdata2    <= 32'd0;
            Hwritereg  <= 1'b0;
            Hwritereg2 <= 1'b0;
        end
       else   begin
            Haddr2     <= Haddr1;
            Haddr1     <= Haddr;

            Hwdata2    <= Hwdata1;
            Hwdata1    <= Hwdata;

            Hwritereg2 <= Hwritereg;
            Hwritereg  <= Hwrite;
        end
    end
   assign Hrdata = Prdata_bridge;
  endmodule