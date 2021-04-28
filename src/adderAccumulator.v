`include "usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW01_add.v"

module AAC(clk, reset_n, A_i, out);
    input clk;
    input reset_n;
    input aac;
    input signed [23:0] A_i;  // 16-bit MV product + 8-bit(128) columns
    output signed [23:0] out;

    parameter width = 12;

    reg AAC_r, AAC_w;
    reg [11:0] MAR_r, MAR_w;
    reg [11:0] LAR_r, LAR_w; 
    reg [11:0] WR_r, WR_w;
    reg carry_r, carry_w;
    
    reg [12:0] LSB_adder_w;
    reg [11:0] MSB_adder_w;
    reg [11:0] LZAB_w;
    reg [11:0] MZAB_w;
    reg CO;

    DW01_add #(width) MSBAdder (
        .A(WR_r),
        .B(MZAB_w),
        .CI(carry_r),
        .sum(MSB_adder_w),
        .CO(CO)
    );

    always @(*) begin
        AAC_w       = aac;
        LZAB_w      = LAR_r & {12{aac}};
        MZAB_w      = MAR_r & {12{AAC_r}};
        LSB_adder_w = {1'b0, A_i[11:0]} + {1'b0, LZAB_w};
        MAR_w       = MSB_adder_w;
        LAR_w       = LSB_adder_w[11:0];
        WR_w        = A_i[23:12];
        carry_w     = LSB_adder_w[12];
    end

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            AAC_r   <= 1'b0;
            carry_r <= 1'b0;
            MAR_r   <= 12'd0;
            LAR_r   <= 12'd0;
            WR_r    <= 12'd0;
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