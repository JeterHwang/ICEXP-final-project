module AAC(clk, reset_n, aac, A_i, out);
    input clk;
    input reset_n;
    input aac;
    input signed [25:0] A_i;  // 16-bit MV product + 8-bit(128) columns
    output signed [25:0] out;

    parameter width = 12;

    reg AAC_r, AAC_w;
    reg [12:0] MAR_r, MAR_w;
    reg [12:0] LAR_r, LAR_w; 
    reg [12:0] WR_r, WR_w;
    reg carry_r, carry_w;
    
    reg [13:0] LSB_adder_w;
    reg [12:0] MSB_adder_w;
    reg [12:0] LZAB_w;
    reg [12:0] MZAB_w;

    assign out = {MSB_adder_w, LAR_r};

    always @(*) begin
        LZAB_w      = LAR_r & {13{aac}};
        MZAB_w      = MAR_r & {13{AAC_r}};

        LSB_adder_w = {1'b0, A_i[12:0]} + {1'b0, LZAB_w};
        MSB_adder_w = WR_r + MZAB_w + carry_r;

        AAC_w       = aac;
        carry_w     = LSB_adder_w[13];
        MAR_w       = MSB_adder_w;
        LAR_w       = LSB_adder_w[12:0];
        WR_w        = A_i[25:13];
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            AAC_r   <= 1'b0;
            carry_r <= 1'b0;
            MAR_r   <= 13'd0;
            LAR_r   <= 13'd0;
            WR_r    <= 13'd0;
        end
        else begin
            AAC_r   <= AAC_w;
            carry_r <= carry_w;
            MAR_r   <= MAR_w;
            LAR_r   <= LAR_w;
            WR_r    <= WR_w;
        end
    end
endmodule