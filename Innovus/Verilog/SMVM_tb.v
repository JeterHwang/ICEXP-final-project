`timescale 1ns/10ps
`define CYCLE 20
`define HCYCLE 10
`define ENDCYCLE 100000
`define dataIn1 "../../tb/dat/ipv_in.dat"
`define dataIn2 "../../tb/dat/matrix_in.dat"
`define dataIn3 "../../tb/dat/vector_in.dat"
`define dataIn4 "../../tb/dat/columnIndex_in.dat"
`define golden  "../../tb/dat/data_out.dat" 


`ifdef APR
    `include "../Verilog/SMVM_apr.v"
    `define SDF
    `define SDFFILE "../Verilog/SMVM_apr.sdf"
`endif
`ifdef SDF
    `include "../design/CHIP_syn.v"
    `define SDF
	`define SDFFILE "../../syn/SMVM_syn.sdf"
`endif

module SMVM_tb;
    parameter k = 4;
    parameter non_zero = 32880;
    parameter row = 9'd256;
    parameter col = 9'd256;

    reg clk;
    reg reset_n;
    
    reg ipv_val;
    reg [7:0] matrix_val;
    reg [8:0] column_index;

    reg ipv_in;
    reg [7:0] val_in;
    reg in_valid;

    wire [2:0] inst_i_NULL;
    wire [5:0] data_b_NULL;
    wire out_valid;
    wire [11:0] data_out;
    wire [2:0] out_NULL;

    reg [23:0] golden [0:row-1];
    reg [11:0] H_golden; 

    integer i;
    integer err_num;
    integer count; 
    integer ipv, matrix, vector, columnIndex;

    CHIP Top(
        .clk_p_i(clk),
        .reset_n_i(reset_n),
        .data_a_i(val_in),
        .data_b_i({data_b_NULL, in_valid, ipv_in}),
        .inst_i(inst_i_NULL),
        .data_o({out_NULL, out_valid, data_out})
    );

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, Top);
    `endif
    
    initial begin
        $fsdbDumpfile("top.fsdb");            
        $fsdbDumpvars(0, SMVM_tb,"+mda");
        $readmemb(`golden, golden);

        ipv         = $fopen(`dataIn1, "r");
        matrix      = $fopen(`dataIn2, "r");
        vector      = $fopen(`dataIn3, "r");
        columnIndex = $fopen(`dataIn4, "r");

        if (ipv == 0 || matrix == 0 || vector == 0) begin
            $display("Cannot read input file !!");
            $finish;
        end

        $display("------------------------------------------------------------\n");
        $display("START!!! Simulation Start .....\n");
        $display("------------------------------------------------------------\n");

        clk = 0;
        count = 0;
        reset_n = 1;
        #(`CYCLE) reset_n = 0;
        #(1.0 * `CYCLE) begin
            reset_n = 1;   
        end
        
        err_num = 0;
        @(negedge clk) begin
            in_valid = 1'b1;
            val_in = row[8:1];
            ipv_in = row[0];
        end
        @(negedge clk) begin
            val_in = col[8:1];
            ipv_in = col[0];
        end
        for(i = 0 ; i < col; i = i + 1) begin
            @(negedge clk) begin
                $fscanf(vector, "%b\n", val_in);
            end
        end
            
        for(i = 0; i < non_zero; i = i + 1) begin
            @(negedge clk) begin // value / ipv input 
                $fscanf(matrix, "%b\n", matrix_val); 
                $fscanf(columnIndex, "%b\n", column_index);
                $fscanf(ipv, "%b\n", ipv_val);
                ipv_in = ipv_val;
                val_in = matrix_val;
            end 
            if(i == non_zero - 1) begin // columnIndex input 
                @(negedge clk) begin  // last input
                    val_in = column_index[8:1];
                    ipv_in = column_index[0];
                    in_valid = 1'b0;  
                end    
            end
            else begin
                @(negedge clk) begin 
                    val_in = column_index[8:1];
                    ipv_in = column_index[0];
                end    
            end 
        end  
    end

    always @(negedge clk) begin
        if(out_valid) begin
            // decide golden
            if(count & 1) begin
                H_golden = golden[count >> 1][11:0];
            end
            else begin
                H_golden = golden[count >> 1][23:12];
            end

            // answer 
            if(H_golden !== data_out) begin
                if(err_num === 0)
                    $display("Error!!\n");
                if(count & 1) begin
                    $display("Case %d LSB: got %13b while %13b expected!!\n", (count >> 1), data_out, H_golden);    
                end
                else begin
                    $display("Case %d MSB: got %13b while %13b expected!!\n", (count >> 1), data_out, H_golden);    
                end
                err_num = err_num + 1;
            end
            count = count + 1;
        end
        else begin
            count = count;
        end
    end

    always @(count) begin
        if(count == row * 2) begin
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
    end

    initial begin
        #(`CYCLE * `ENDCYCLE)
        $display("============================================================\n");
        $display("Simulation time is longer than expected.");
        $display("The test result is .....FAIL :(\n");
        $display("============================================================\n");
        $finish;
    end

    always #(`HCYCLE) clk = ~clk;

endmodule