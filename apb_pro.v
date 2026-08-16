module apb_pro (
    input HCLK,
    input Hresetn,
    input valid,
    input Hwrite,         
    input [31:0] Haddr1,
    input [31:0] Haddr2,
    input [31:0] Hwdata1,
    input [31:0] Hwdata2,
    input Hwritereg,
    input Hwritereg2,
    input [2:0]  tempselx,

    output reg Pwrite,
    output reg Penable,
    output reg [2:0]  Pselx,
    output reg [31:0] Paddr,
    output reg [31:0] Pwdata,
    input      [31:0] Prdata,       
    output reg Hreadyout,

    output [31:0] Prdata_bridge 
);
    assign Prdata_bridge = Prdata;
    parameter st_idle     = 3'd0,
              st_wwait    = 3'd1,
              st_write    = 3'd2,
              st_writep   = 3'd3,
              st_wenable  = 3'd4,
              st_wenablep = 3'd5,
              st_read     = 3'd6,
              st_renable  = 3'd7;

    reg [2:0] state, next_state;
    always @(posedge HCLK or negedge Hresetn) begin
        if (!Hresetn)
            state <= st_idle;
        else
            state <= next_state;
    end
    always @(*) begin
        next_state = state; 
        case (state)
            st_idle: begin
                if (valid && Hwrite)
                    next_state = st_wwait;
                else if (valid && !Hwrite)
                    next_state = st_read;
                else
                    next_state = st_idle;
            end

            st_wwait: begin
                if (valid)
                    next_state = st_writep;
                else
                    next_state = st_write;
            end

            st_write: begin
                if (valid)
                    next_state = st_wenablep;
                else
                    next_state = st_wenable;
            end

            st_writep: begin
                next_state = st_wenablep;
            end

            st_wenablep: begin
                if (valid && Hwritereg2)
                    next_state = st_writep;
                else if (!valid && Hwritereg2)
                    next_state = st_write;
                else
                    next_state = st_read; 
            end
            st_wenable: begin
                if (!valid)
                    next_state = st_idle;
                else if (valid && Hwrite)
                    next_state = st_wwait;
                else 
                    next_state = st_read;
            end
            st_read: begin
                next_state = st_renable;
            end
            st_renable: begin
                if (valid && !Hwrite)
                    next_state = st_read;
                else if (!valid)
                    next_state = st_idle;
                else
                    next_state = st_wwait;
            end
           default: next_state = st_idle;
        endcase
    end
   always @(*) begin
     case (state)
            st_idle: begin
                Hreadyout = 1'b1;
                Pselx        = 3'b000;
                Pwrite       = 1'b0;
                Penable      = 1'b0;
                Hreadyout    = 1'b0;
                Paddr        = 32'd0;
                Pwdata       = 32'd0;
            end

            st_wwait: begin
                Paddr     = Haddr1;
                Pselx     = tempselx;
                Penable   = 1'b0;
                
            end
            
            st_writep: begin
                Paddr   = Haddr2;
                Pwdata  = Hwdata1;
                Pwrite  = Hwritereg2;
                Pselx   = tempselx;
                Penable = 1'b0;
                Hreadyout = 1'b1;
            end
           st_wenablep: begin
                Pselx     = tempselx;
                Penable   = 1'b1;
                Hreadyout = 1'b0;
            end

            st_write: begin
                Paddr   = Haddr2;
                Pwdata  = Hwdata1;
                Pwrite  = Hwritereg2;
                Pselx   = tempselx;
                Penable = 1'b0;
                Hreadyout = 1'b1;
            end

            st_wenable: begin
                Pselx     = tempselx;
                Penable   = 1'b1;
                Hreadyout = 1'b0;
            end

            st_read: begin
                Paddr   = Haddr1;
                Pwrite  = Hwritereg;
                Pselx   = tempselx;
                Penable = 1'b0;
                Hreadyout = 1'b1;
            end

            st_renable: begin
                Pselx     = tempselx;
                Penable   = 1'b1;
                Hreadyout = 1'b0;
            end
            default: ;
        endcase
    end
endmodule