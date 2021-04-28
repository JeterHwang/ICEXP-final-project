`timescale 1ns/1ps
`define CYCLE 10
`define HCYCLE 5
`define ENDCYCLE 1000


module aac_tb;
    
    reg clk;
    reg reset_n;
    reg aac;
    reg signed [23:0] A;

    wire signed [23:0] out;

    AAC aac(
        .clk(clk),
        .reset_n(reset_n),
        .aac(aac),
        .A_i(A),
        .out(out)
    );

    always @(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("aac.fsdb");            
        $fsdbDumpvars(0,aac_tb,"+mda");
    end

    initial begin
        #(`CYCLE*`END_CYCLE)
        $display("============================================================\n");
        $display("Simulation time is longer than expected.");
        $display("The test result is .....FAIL :(\n");
        $display("============================================================\n");
        $finish;
    end

endmodule