`timescale 1ns/1ps
`define CYCLE 10
`define HCYCLE 5
`define ENDCYCLE 100000
`define dataIn "dat/ipv_in.dat"
`define golden  "dat/vov_out.dat"  

module reducer_tb;
    parameter k = 4;

    reg clk;
    reg reset_n;
    reg ipv_in;
    reg [k-1:0] golden;
    reg [15:0]  count; 

    wire [k-1:0] vov;

    integer i;
    integer err_num;
    integer data, ans;

    IPV_reducer #(.k(k)) reducer(
        .clk(clk),
        .rst_n(reset_n),
        .ipv_in(ipv_in),
        .vov(vov)
    );

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("reducer.fsdb");            
        $fsdbDumpvars(0,reducer_tb,"+mda");

        data    = $fopen(`dataIn, "r");
        ans  = $fopen(`golden, "r");
        if (data == 0 || golden == 0) begin
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
        for(i = 0; i < 8216; i = i + 1) begin
            @(negedge clk) begin
                $fscanf(data, "%b\n", ipv_in); 
                if ($feof(data)) begin
                    $display("Reach end of file :( ");
                end
                
                if(i > 2 && (i - 2) % k == 0) begin
                    $fscanf(ans, "%b\n", golden);
                    if(golden !== vov) begin
                        if(err_num == 0) 
                            $display("Error !!");
                        $display("Case %d: Expected %b, but got %b", i, golden, vov);
                        err_num = err_num + 1;
                    end    
                end
                count = i;
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