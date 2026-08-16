`timescale 1ns/1ps

module ahb_master (
    input  HCLK,
    input  Hresetn,
    output reg Hwrite,
    output reg Hreadyin,
    output reg [1:0]  Htrans,
    output reg [31:0] Haddr,
    output reg [31:0] Hwdata,
    input  [1:0]  Hresp,
    input  [31:0] Hrdata,
    input  Hreadyout
);

    localparam IDLE_T   = 2'b00;
    localparam BUSY_T   = 2'b01;
    localparam NONSEQ_T = 2'b10;
    localparam SEQ_T    = 2'b11;

    reg stop_burst;

    reg [31:0] rd_buffer [0:31];
    integer    rd_count;

    initial begin
        Hwrite     = 0;
        Hreadyin   = 0;
        Htrans     = IDLE_T;
        Haddr      = 0;
        Hwdata     = 0;
        stop_burst = 0;
        rd_count   = 0;
    end
   task ahb_burst_and_single_write(input [31:0] addr,
     input [2:0] Hsize,
      input [2:0] Hburst
      );
    
        integer inc;
        reg [31:0] curr_addr;
        integer Hinc;
        integer i;
begin
        curr_addr = addr;
        case(Hsize)
        3'b000: inc = 1;
        3'b001: inc = 2;
        3'b010: inc = 4;

        endcase
        case(Hburst)
        3'b010: Hinc = 4;
        3'b011: Hinc = 4;
        3'b100: Hinc = 8;
        3'b101: Hinc = 8;
        3'b110: Hinc = 16;
        3'b111: Hinc = 16;
        endcase
        if(Hburst[0]==1'b1)
        begin
        if(Hburst==3'b001)
        begin
            @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b1;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
           
            forever
             begin
             @(posedge HCLK);
             curr_addr =curr_addr+inc;
            Haddr    = curr_addr;
            Hwrite   = 1'b1;
            Htrans   = SEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
           
            if(stop_burst==1'b1)
            begin
                 Hwrite = 1'b0;
                 Htrans = IDLE_T;
                 disable ahb_burst_and_single_write;
            end

             end
        end
        else
        begin
       @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b1;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
           for(i=1;i<Hinc;i=i+1)
             begin
             @(posedge HCLK);
             curr_addr =curr_addr+inc;
            Haddr    = curr_addr;
            Hwrite   = 1'b1;
            Htrans   = SEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
            
            if(i==Hinc-1)
            begin
                 Htrans = IDLE_T;
                 Hwrite = 1'b0;
             end
             end
        end
        end
        else if(Hburst==3'b000)
        begin
            @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b1;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
            @(posedge HCLK);
            Htrans   = IDLE_T;   
            Hwdata   = $random;     
            
            @(posedge HCLK);
            Hwrite = 1'b0;
        end
        else
        begin
         begin
       @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b1;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
            
            for(i=1;i<Hinc;i=i+1)
             begin
             @(posedge HCLK);
            case (Hburst)
                3'b010: case(Hsize)

                3'b000: curr_addr = {curr_addr[31:2], curr_addr[1:0] + 2'd1};

                3'b001: curr_addr = {curr_addr[31:3], curr_addr[2:0] + 3'd2};

                3'b010: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd4};

                3'b011: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd8};

                endcase
                3'b100: case(Hsize)

                3'b000: curr_addr = {curr_addr[31:3], curr_addr[2:0] + 3'd1};

                3'b001: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd2};

                3'b010: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd4};

                3'b011: curr_addr = {curr_addr[31:6], curr_addr[5:0] + 6'd8};
                endcase
                3'b110:  case(Hsize)

                    3'b000: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd1};

                    3'b001: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd2};

                    3'b010: curr_addr = {curr_addr[31:6], curr_addr[5:0] + 6'd4};

                    3'b011: curr_addr = {curr_addr[31:7], curr_addr[6:0] + 7'd8};
                endcase
            endcase
            Haddr=curr_addr;
            Hwrite   = 1'b1;
            Htrans   = SEQ_T;
            Hreadyin = 1'b1;
             @(posedge HCLK);
            Htrans   = SEQ_T;
            Hwdata   = $random;
            if(i==Hinc-1)
            begin
                 Htrans = IDLE_T;
                 Hwrite = 1'b0;
            end
            end
            end
        end
    end
  endtask
    task ahb_burst_and_single_read(input [31:0] addr,
     input [2:0] Hsize, input [2:0] Hburst);
        integer inc;
        reg [31:0] curr_addr;
        integer Hinc;
        integer i;
        begin
        curr_addr = addr;
        rd_count  = 0;
       case(Hsize)
        3'b000: inc = 1;
        3'b001: inc = 2;
        3'b010: inc = 4;
        endcase
        case(Hburst)
        3'b010: Hinc = 4;
        3'b011: Hinc = 4;
        3'b100: Hinc = 8;
        3'b101: Hinc = 8;
        3'b110: Hinc = 16;
        3'b111: Hinc = 16;
        endcase
        if(Hburst[0]==1'b1)
        begin
            if(Hburst==3'b001)
            begin
                @(posedge HCLK);
                Haddr    = addr;
                Hwrite   = 1'b0;
                Htrans   = NONSEQ_T;
                Hreadyin = 1'b1;
                @(posedge HCLK);
                Htrans   = SEQ_T;
                rd_buffer[rd_count] = Hrdata;
                rd_count = rd_count + 1;
                forever
                begin
                    @(posedge HCLK);
                    curr_addr = curr_addr + inc;
                    Haddr    = curr_addr;
                    Hwrite   = 1'b0;
                    Htrans   = SEQ_T;
                    Hreadyin = 1'b1;
                    @(posedge HCLK);
                    Htrans   = SEQ_T;
                    rd_buffer[rd_count] = Hrdata;
                    rd_count = rd_count + 1;
                    if(stop_burst==1'b1)
                    begin
                        Htrans = IDLE_T;
                        disable ahb_burst_and_single_read;
                    end
                end
            end
            else
            begin
               
                @(posedge HCLK);
                Haddr    = addr;
                Hwrite   = 1'b0;
                Htrans   = NONSEQ_T;
                Hreadyin = 1'b1;
                @(posedge HCLK);
                Htrans   = SEQ_T;
                rd_buffer[rd_count] = Hrdata;
                rd_count = rd_count + 1;
                for(i=1;i<Hinc;i=i+1)
                begin
                    @(posedge HCLK);
                    curr_addr = curr_addr + inc;
                    Haddr    = curr_addr;
                    Hwrite   = 1'b0;
                    Htrans   = SEQ_T;
                    Hreadyin = 1'b1;
                    @(posedge HCLK);
                    Htrans   = SEQ_T;
                    rd_buffer[rd_count] = Hrdata;
                    rd_count = rd_count + 1;
                    if(i==Hinc-1)
                        Htrans = IDLE_T;
                end
            end
        end
        else if(Hburst==3'b000)
        begin 
            @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b0;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
            @(posedge HCLK);
            Htrans   = IDLE_T;
            @(posedge HCLK);
            rd_buffer[0] = Hrdata;
            rd_count = 1;
        end
        else
        begin
            @(posedge HCLK);
            Haddr    = addr;
            Hwrite   = 1'b0;
            Htrans   = NONSEQ_T;
            Hreadyin = 1'b1;
            @(posedge HCLK);
            Htrans   = SEQ_T;
            rd_buffer[rd_count] = Hrdata;
            rd_count = rd_count + 1;
            for(i=1;i<Hinc;i=i+1)
            begin
                @(posedge HCLK);
                case (Hburst)
                    3'b010: case(Hsize)
                        3'b000: curr_addr = {curr_addr[31:2], curr_addr[1:0] + 2'd1};
                        3'b001: curr_addr = {curr_addr[31:3], curr_addr[2:0] + 3'd2};
                        3'b010: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd4};
                        3'b011: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd8};
                    endcase
                    3'b100: case(Hsize)
                        3'b000: curr_addr = {curr_addr[31:3], curr_addr[2:0] + 3'd1};
                        3'b001: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd2};
                        3'b010: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd4};
                        3'b011: curr_addr = {curr_addr[31:6], curr_addr[5:0] + 6'd8};
                    endcase
                    3'b110: case(Hsize)
                        3'b000: curr_addr = {curr_addr[31:4], curr_addr[3:0] + 4'd1};
                        3'b001: curr_addr = {curr_addr[31:5], curr_addr[4:0] + 5'd2};
                        3'b010: curr_addr = {curr_addr[31:6], curr_addr[5:0] + 6'd4};
                        3'b011: curr_addr = {curr_addr[31:7], curr_addr[6:0] + 7'd8};
                    endcase
                endcase
                Haddr    = curr_addr;
                Hwrite   = 1'b0;
                Htrans   = SEQ_T;
                Hreadyin = 1'b1;
                @(posedge HCLK);
                Htrans   = SEQ_T;
                rd_buffer[rd_count] = Hrdata;
                rd_count = rd_count + 1;
                if(i==Hinc-1)
                    Htrans = IDLE_T;
            end
        end
    end
    endtask
endmodule