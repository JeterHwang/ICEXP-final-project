`timescale 1ns/1ps
`define CYCLE 10
`define HCYCLE 5
`define ENDCYCLE 100000
`define dataIn1 "dat/ipv_in.dat"
`define dataIn2 "dat/matrix_in.dat"
`define dataIn3 "dat/vector_in.dat"
`define dataIn4 "dat/columnIndex_in.dat"
//`define golden  "dat/vov_out.dat"  

module SMVM_tb;
    parameter k = 4;
    parameter non_zero = 496;
    parameter row = 32;
    parameter col = 32;

    reg clk;
    reg reset_n;
    
    reg ipv_val;
    reg signed [31:0] matrix_val;
    reg signed [31:0] column_index;

    reg ipv_in;
    reg [7:0] val_in;
    reg [2:0] col_in;

    wire out_valid;
    wire signed [13:0] data_out;

    reg [k-1:0] golden;
    reg [15:0]  count; 

    integer i;
    integer err_num;
    integer ipv, matrix, vector, columnIndex;

    SMVM Top(
        .clk(clk),
        .rst_n(reset_n),
        .val_in(val_in),
        .col_in(col_in),
        .ipv_in(ipv_in),
        .out_valid(out_valid),
        .data_out(data_out)
    );

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("top.fsdb");            
        $fsdbDumpvars(0, SMVM_tb,"+mda");

        ipv         = $fopen(`dataIn1, "r");
        matrix      = $fopen(`dataIn2, "r");
        vector      = $fopen(`dataIn3, "r");
        columnIndex = $fopen(`dataIn4, "r");

        if (ipv == 0 || matrix == 0 || vector == 0) begin
            $display("Cannot read input file !!");
            $finish;
        end

        clk = 0;
        reset_n = 1;
        #(`CYCLE) reset_n = 0;
        #(1 * `CYCLE) begin
            reset_n = 1;   
        end
        
        err_num = 0;
        @(posedge clk) begin
            val_in = row;
            col_in = col;
        end
        for(i = 0 ; i < col; i = i + 1) begin
            @(posedge clk) begin
                $fscanf(vector, "%d\n", val_in);
            end
        end
            
        for(i = 0; i < non_zero; i = i + 1) begin
            @(posedge clk) begin
                $fscanf(matrix, "%d\n", matrix_val); 
                $fscanf(columnIndex, "%d\n", column_index);
                $fscanf(ipv, "%d\n", ipv_val);
                ipv_in = ipv_val;
                val_in = matrix_val[7:0];
            end 
            @(posedge clk) begin
                val_in = column_index[11:4];
                ipv_in = column_index[3];
                col_in = column_index[2:0];
            end
        end
        @(posedge out_valid) begin
            for(i = 0; i < row; i = i + 1) begin
                if()
            end    
        end
        
        if(err_num == 0) begin
            $display("===========================================The Simulation result is PASS===========================================");
			$display("                                                     .,*//(((//*,.                                ");          
			$display("                                             *(##((((((((((((###((((((##(.                                  ");
			$display("                                       ./##((#####(((((((O*      .(#(((((((##*                              ");
			$display("                                   ./#((((O.       *O(((#           /((((((((((#(                           ");
			$display("                                 ##(((((#.           (##             *#(((((((((((#,                        ");
			$display("                              *#(((((((#/             //              *(((((((((((((#*                      ");
			$display("                            /((((((((((#    (@&        (  .(/*(,       #((((((((((((((#,                    ");
			$display("                          /(((((((((((((   ,& ((       O (.     (      (.*/##(((((((((((#                   ");
			$display("                        .#(((((((((((((#   .&O       O/              /       #O#(((((((#,                 ");
			$display("                       (#(((((((((((#(,**    (/        **.            /    .(*     ##(((((#.                ");
			$display("                      /((((((((((#,     ,,           (OOOOOO/       ,/  .(,          (#((((#,               ");
			$display("                     #(((((#OOO*          **       ,OOO/*#OOO&(((/,  *(           ,(/. #((((#               ");
			$display("                    ,(((((((#.   .*(/.       .,**,.#OO#  /OOOO(   */.        ,(/.  .,*, ,((((/              ");
			$display("                   .#((((((/           .*(/.       /OOOOOOOOOO,         .(/.     (.     .((#,             ");
			$display("                   ((((((#*                         .OOOOOOOO      .//,                   ,(((#             ");
			$display("                   #((((#.    ..,*/((((/*..             .(.                                #((#             ");
			$display("                   #(((#/,((/(/                          /,          ((//**,,...           #((#.            ");
			$display("                   #(((O*              .,/(/             ,/                               .##(#.            ");
			$display("                   #((#      .*((/*.                      (                              /**#(#*/((/*       ");
			$display("                   #((O  ..                               ( .,,**///**,,..             (/  *#(#       ,*    ");
			$display("                   #(((*                           ,/#OOOOOOOOOOOOOOOOOOOOOOOOOOOO&/,      (((O         (   ");
			$display("                   /#((O(                   ,(OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO(        O(#(          ,  ");
			$display("                   .#((#,,(.         .*#OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO(        ,((#.         .,  ");
			$display("                    ,(((O     ..,&OO)OOO              Success! !!         OO)OOOO         #((,          (   ");
			$display("                     #(((/       .OOOOOOOOOOOOOOOOOOOOOOO#(//////////((OOOOOOOO(         #((O(.       /,    ");
			$display("                      (((#(        /OOOOOOOOOOOO&O(/////////////////////////#&(         ,((O((((##O/,       ");
			$display("                       #(((*         (OOOOOOO(//////////////////////////////#.         *#(O(((((((#         ");
			$display("                        *(((#          /OO#///////////////////////////////(*          ,#(O(((((((#*         ");
			$display("                         .#((#.          .((////////////////////////////(/           /##O((((((((/          ");
			$display("                           /#((*            .##//////////////////////(#.            ((#(((((((((#           ");
			$display("            ,(*...,(*        (#(#,              .(#(/////////////(#/.              O(#(((((((((#            ");
			$display("          ,,         ,(        /O(#,                   ..,,,,.     ..,*//(##OOOOOOO&((((((((((#             ");
			$display("         *,            *         .(#((.      ..,,*/(##OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO((((((((((              ");
			$display("         (             #(((((####(//OOOOOOOOOOOOOOOOOOOO#OO*..,,**((/*,..  *O((((((((((((#/               ");
			$display("         /,            #(((((((((((((((#O&OOOO&(/*,...   #/,.,*((((((.         /#(((O(((((#.                ");
			$display("          *.         .#((((((((((((((((((((((/          /(*..,(O#,..*.           #((#((((/                  ");
			$display("            */,   .(O((((((((((((((((((((((#*            (.../OO#...(            ,O((#(#.                   ");
			$display("                   .(#(((((((((((((((((((((,             .(....(*..#.             /((O.                     ");
			$display("                       /##((((((((((((((((#                 ,((#(,                .#(#      ,/(((*.         ");
			$display("                           ,(##((((((((((#(                .,*/(((((///********#   O(#   //        ,(       ");
			$display("                                .(##(((((#/    .*((/*..                        (.  O(#./*            /*     ");
			$display("                                    (((((((    ,                               (   #(OO               ,.    ");
			$display("                                   ,O(((((#    (.                             ,.  ((((                 (    ");
			$display("                               *(..OO((((((O.   (                            **  #((#                  /.   ");
			$display("                             /*  /#(O(((((((#,   /*                         (  .#((O.                  *,   ");
			$display("                           ,(   .#((((((((((((#,   //                    *(   (((((/                   /,   ");
			$display("                          ,.    ((((((((((((((((#(.   *(/.         .,/(,   *O(((((#.                   (.   ");
			$display("                         /*     #((((((((((((((((((#O/,                ,(#((((((((O                    /    ");
			$display("                         *      #((((((((((((((((((((((((#########O##(((((((((((((#                   *     ");
			$display("                        /       ((((((((((((((((((((((((((((((((((((((((((((((((((#.                 ,/     ");
			$display("                        (        #(((((((((((((((((((((((((((((((((((((((((((((((((/                .*      ");
			$display("                        (         (((((((((((((((((((((((##(/*,..        ..,*((###(#/              /*       ");
			$display("                        *           .##(((((((((((###*.                              (           *(         ");
			$display("                         /                  (                                          /(,...,//.           ");
			$display("                          *.              /.                                                                ");
			$display("                            */.       .(/                                                                   ");
			$display("                                .,,,.                                                                       ");
        end
        else begin
            $display(" ");
            $display("============================================================\n");
            $display("There are total %4d errors in the data memory", err_num);
            $display("The test result is .....FAIL :(\n");
            $display("============================================================\n");
        end
        
        $finish;
    end

    initial begin
        #(`CYCLE * `ENDCYCLE)
        $display("============================================================\n");
        $display("Simulation time is longer than expected.");
        $display("The test result is .....FAIL :(\n");
        $display("============================================================\n");
        $finish;
    end

endmodule