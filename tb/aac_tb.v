`timescale 1ns/1ps
`define CYCLE 10
`define HCYCLE 5
`define ENDCYCLE 1000
`define dataIn1 "dat/aac_data1.dat"
`define dataIn2 "dat/aac_data2.dat"
`define golden  "dat/aac_ans.dat"  

module aac_tb;
    
    reg clk;
    reg reset_n;
    reg aac_i;
    reg signed [23:0] A;
    reg signed [23:0] golden;

    wire signed [23:0] out;

    integer i;
    integer err_num;
    integer data1, data2, ans;

    AAC aac(
        .clk(clk),
        .reset_n(reset_n),
        .aac(aac_i),
        .A_i(A),
        .out(out)
    );

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("aac.fsdb");            
        $fsdbDumpvars(0,aac_tb,"+mda");

        data1 = $fopen(`dataIn1, "r");
        data2 = $fopen(`dataIn2, "r");
        ans   = $fopen(`golden, "r");
        if (data1 == 0 || data2 == 0 || ans == 0) begin
            $display("Cannot read input file !!");
            $finish;
        end

        clk = 0;
        reset_n = 1;
        #(`CYCLE) reset_n = 0;
        #(2 * `CYCLE) begin
            reset_n = 1;
            A = 24'd0;            
        end
        
        err_num = 0;
        for(i = 0; i < 10; i = i + 1) begin
            @(negedge clk) begin
                if(i < 9) begin
                    $fscanf(data1, "%h\n", A); 
                    $fscanf(data2, "%b\n", aac_i);
                    if ($feof(data1) || $feof(data2)) begin
                        $display("Reach end of file :( ");
                    end
                end
                $fscanf(ans, "%h\n", golden);
                if(golden !== out) begin
                    if(err_num == 0) 
                        $display("Error !!");
                    $display("Case %d: Expected %d, but got %d", i, golden, out);
                    err_num = err_num + 1;
                end
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