//ALU_level_1
`include "../src/adderAccumulator.v"
module ALU_L1 #(parameter k = 4)(
              matrix_in,
              vector_in,
              L1_out,
              IPV,
              en         
    );
    /* ==================== IO ==================== */
    input         [8*k-1:0]  matrix_in ; 
    input         [8*k-1:0]  vector_in ; 
    input         [k-1:0]    IPV       ;
    output        [16*k-1:0] L1_out    ;
    output                   en        ;
    /* ================= WIRE/REG ================= */
    wire signed [7:0] mat_1,mat_2,mat_3,mat_4;
    wire signed [7:0] vec_1,vec_2,vec_3,vec_4;
    /* ================== Conti =================== */
    //deco matrix_in
    assign mat_1 = matrix_in[8*k-1:8*k-8]  ;
    assign mat_2 = matrix_in[8*k-9:8*k-16] ;
    assign mat_3 = matrix_in[8*k-17:8*k-24];
    assign mat_4 = matrix_in[8*k-25:0]     ;

    //deco vector_in
    assign vec_1 = vector_in[8*k-1:8*k-8]  ;
    assign vec_2 = vector_in[8*k-9:8*k-16] ;
    assign vec_3 = vector_in[8*k-17:8*k-24];
    assign vec_4 = vector_in[8*k-25:0]     ;

    //deco output
    assign L1_out[16*k-1:16*k-16]  = mat_1 * vec_1;
    assign L1_out[16*k-17:16*k-32] = mat_2 * vec_2;
    assign L1_out[16*k-33:16*k-48] = mat_3 * vec_3;
    assign L1_out[16*k-49:0]       = mat_4 * vec_4;

    //signal of ready to process the new 4 bits
    assign en = ((matrix_in[8*k-1:8*k-8] == 8'b0)&&(IPV == {k{1'b0}}))? 1'b0 : 1'b1 ;

endmodule




//MAPTABLE_level_1
module Map_table_L1 #(parameter k = 4)(
                clk,
                rst,
                en,
                IPV_in,
                L1_out,
                L2_in,
                IPV_out        
    );
    /* ==================== IO ==================== */
    input          clk,rst    ;
    input          en         ;
    input   [3:0]  IPV_in     ;
    input   [16*k-1:0] L1_out ;
    output  [32*k-1:0] L2_in  ;
    output  [3:0]  IPV_out    ;
    /* ================= WIRE/REG ================= */
    reg [3:0]  IPV_r,IPV_w;
    reg [32*k-1:0] L2_in_r;
    wire[32*k-1:0] L2_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L2
    assign IPV_out = IPV_r;
    //input to ALU_L2
    assign L2_in   = L2_in_r;

    //Match in/out
    assign L2_in_w[32*k-1:32*k-16]    = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd2)||(IPV_in[3:1] == 3'd3))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5))                                    ? (L1_out[16*k-17:16*k-32]):
                                        (IPV_in[3:1] == 3'd6)                                                        ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-17:32*k-32]   = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd2)||(IPV_in[3:1] == 3'd3))? (L1_out[16*k-17:16*k-32]): 
                                        ((IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5))                                    ? (L1_out[16*k-33:16*k-48]):
                                        (IPV_in[3:1] == 3'd6)                                                        ? (L1_out[16*k-49:0])      : (16'b0) ;  
    assign L2_in_w[32*k-33:32*k-48]   = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd2))                                    ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-49:32*k-64]   = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd2))                                    ? (L1_out[16*k-49:0])      : (16'b0) ; 
    assign L2_in_w[32*k-65:32*k-80]   = ((IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6)||(IPV_in[3:1] == 3'd7))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd3))                                    ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-81:32*k-96]   = ((IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5))? (L1_out[16*k-49:0])      : 
                                        ((IPV_in[3:1] == 3'd6)||(IPV_in[3:1] == 3'd7))                                    ? (L1_out[16*k-17:16*k-32]): (16'b0) ; 
    assign L2_in_w[32*k-97:32*k-112]  = (IPV_in[3:1] == 3'd7)                                                        ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-113:0]        = (IPV_in[3:1] == 3'd7)                                                        ? (L1_out[16*k-49:0])      : (16'b0) ; 


    /* ================ Combination =============== */
    //lock IPV
    always @(*) begin
        if (en) IPV_w = IPV_in;
        else    IPV_w = IPV_r ;
    end
    /* ================ Sequencial ================ */
    always @(posedge clk) begin
        if (~rst) begin
            IPV_r   <= 4'b0;
            L2_in_r <= {(32*k){1'b0}};
        end 
        else begin
            IPV_r   <= IPV_w;
            L2_in_r <= L2_in_w;
        end
    end
endmodule





//ALU_level_2
module ALU_L2 #(parameter k = 4)(
              L2_in,
              L2_out 
    );
    /* ==================== IO ==================== */
    input  [32*k-1:0] L2_in  ;
    output [17*6-1:0] L2_out ;
    /* ================= WIRE/REG ================= */
    wire signed [15:0] L2_1,L2_2,L2_3,L2_4,L2_5,L2_6,L2_7,L2_8;
    /* ================== Conti =================== */
    //deco L2_in
    assign L2_1 = L2_in[32*k-1:32*k-16]  ;
    assign L2_2 = L2_in[32*k-17:32*k-32] ;
    assign L2_3 = L2_in[32*k-33:32*k-48] ;
    assign L2_4 = L2_in[32*k-49:32*k-64] ;
    assign L2_5 = L2_in[32*k-65:32*k-80] ;
    assign L2_6 = L2_in[32*k-81:32*k-96] ;
    assign L2_7 = L2_in[32*k-97:32*k-112];
    assign L2_8 = L2_in[32*k-113:0]      ;
    //deco output
    assign L2_out[17*6-1:17*6-17]   = L2_1 + L2_2; 
    assign L2_out[17*6-18:17*6-34]  = L2_3 + L2_4; 
    assign L2_out[17*6-35:17*6-51]  = {L2_5[15],L2_5};
    assign L2_out[17*6-52:17*6-68]  = {L2_6[15],L2_6}; 
    assign L2_out[17*6-69:17*6-85]  = {L2_7[15],L2_7}; 
    assign L2_out[17*6-86:0]        = {L2_8[15],L2_8}; 

endmodule



//MAPTABLE_level_2
module Map_table_L2 #(parameter k = 4)(
                clk,
                rst,
                IPV_in,
                L2_out,
                L3_in,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         clk,rst           ;
    input         [3:0]  IPV_in     ;
    input         [17*6-1:0] L2_out ;
    output        [17*6-1:0] L3_in  ;
    output        [3:0]  IPV_out    ;
    /* ================= WIRE/REG ================= */
    reg [17*6-1:0] L3_in_r;
    wire[17*6-1:0] L3_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L3              
    assign IPV_out = IPV_in;
    //input to ALU_L3
    assign L3_in   = L3_in_r;

    //Match in/out
    assign L3_in_w[17*6-1:17*6-17]    = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd4))         ? (L2_out[17*6-1:17*6-17]) : (17'b0) ;
    assign L3_in_w[17*6-18:17*6-34]   = (IPV_in[3:1] == 3'd0)                                               ? (L2_out[17*6-18:17*6-34]): 
                                        (IPV_in[3:1] == 3'd1)                                               ? (L2_out[17*6-35:17*6-51]):
                                        (IPV_in[3:1] == 3'd4)                                               ? (L2_out[17*6-52:17*6-68]): (17'b0) ;  
    assign L3_in_w[17*6-35:17*6-51]   = ((IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6)||(IPV_in[3:1] == 3'd7))? (L2_out[17*6-35:17*6-51]): 
                                        ((IPV_in[3:1] == 3'd2)||(IPV_in[3:1] == 3'd3))                           ? (L2_out[17*6-1:17*6-17]) :
                                        (IPV_in[3:1] == 3'd1)                                               ? (L2_out[17*6-52:17*6-68]): (17'b0) ;
    assign L3_in_w[17*6-52:17*6-68]   = ((IPV_in[3:1] == 3'd6)||(IPV_in[3:1] == 3'd7))                           ? (L2_out[17*6-52:17*6-68]): 
                                        (IPV_in[3:1] == 3'd5)                                               ? (L2_out[17*6-1:17*6-17] ):
                                        (IPV_in[3:1] == 3'd3)                                               ? (L2_out[17*6-35:17*6-51]):
                                        (IPV_in[3:1] == 3'd2)                                               ? (L2_out[17*6-18:17*6-34]): (17'b0) ;  
    assign L3_in_w[17*6-69:17*6-85]   = ((IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd5))                           ? (L2_out[17*6-52:17*6-68]): 
                                        (IPV_in[3:1] == 3'd6)                                               ? (L2_out[17*6-1:17*6-17]) :
                                        (IPV_in[3:1] == 3'd7)                                               ? (L2_out[17*6-69:17*6-85]): (17'b0) ;
    assign L3_in_w[17*6-86:0]         = (IPV_in[3:1] == 3'd7)                                               ? (L2_out[17*6-86:0])      : (17'b0) ; 
    /* ================ Sequencial ================ */
    always @(posedge clk) begin
        if (~rst) begin
            L3_in_r <= {(17*6){1'b0}}; 
        end 
        else begin
            L3_in_r <= L3_in_w;
        end
    end
endmodule



//ALU_level_3
module ALU_L3 #(parameter k = 4)(
              L3_in,
              L3_out 
    );
    /* ==================== IO ==================== */
    input  [17*6-1:0] L3_in  ;
    output [18*5-1:0] L3_out ;
    /* ================= WIRE/REG ================= */
    wire signed [16:0] L3_1,L3_2,L3_3,L3_4,L3_5,L3_6;
    /* ================== Conti =================== */
    //deco L3_in
    assign L3_1 = L3_in[17*6-1:17*6-17]  ;
    assign L3_2 = L3_in[17*6-18:17*6-34] ;
    assign L3_3 = L3_in[17*6-35:17*6-51] ;
    assign L3_4 = L3_in[17*6-52:17*6-68] ;
    assign L3_5 = L3_in[17*6-69:17*6-85] ;
    assign L3_6 = L3_in[17*6-86:0]       ;
    //deco output
    assign L3_out[18*5-1:18*5-18]   = L3_1 + L3_2     ; 
    assign L3_out[18*5-19:18*5-36]  = {L3_3[16],L3_3} ; 
    assign L3_out[18*5-37:18*5-54]  = {L3_4[16],L3_4} ; 
    assign L3_out[18*5-55:18*5-72]  = {L3_5[16],L3_5} ;  
    assign L3_out[18*5-73:0]        = {L3_6[16],L3_6} ;  

endmodule




//MAPTABLE_level_3
module Map_table_L3 #(parameter k = 4)(
                clk,
                rst,
                IPV_in,
                L3_out,
                L4_in,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         clk,rst    ;
    input         [3:0]  IPV_in;
    input         [18*5-1:0] L3_out ;
    output        [18*4-1:0] L4_in  ;
    output        [3:0]  IPV_out;
    /* ================= WIRE/REG ================= */
    reg [18*4-1:0] L4_in_r;
    wire[18*4-1:0] L4_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L4                                     
    assign IPV_out = IPV_in;
    //input to ALU_L4
    assign L4_in   = L4_in_r;

    //Match in/out
    assign L4_in_w[18*4-1:18*4-18]    = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1))                           ? L3_out[18*5-1:18*5-18] : L3_out[18*5-19:18*5-36] ;
    assign L4_in_w[18*4-19:18*4-36]   = ((IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6)||(IPV_in[3:1] == 3'd7))? L3_out[18*5-37:18*5-54]: (18'b0)        ; 
    assign L4_in_w[18*4-37:18*4-54]   = (IPV_in[3:1] == 3'd7)                                               ? L3_out[18*5-55:18*5-72]: (18'b0)                 ;

    assign L4_in_w[18*4-55:0]         = ((IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6))         ? L3_out[18*5-55:18*5-72]: 
                                        (IPV_in[3:1] == 3'd1)                                               ? L3_out[18*5-19:18*5-36]:
                                        (IPV_in[3:1] == 3'd2)                                               ? L3_out[18*5-37:18*5-54]:
                                        (IPV_in[3:1] == 3'd4)                                               ? L3_out[18*5-1:18*5-18] : 
                                        (IPV_in[3:1] == 3'd7)                                               ? L3_out[18*5-73:0]      : (18'b0)                 ;  
    /* ================ Sequencial ================ */
    always @(posedge clk) begin
        if (~rst) begin
            L4_in_r <= {(18*4){1'b0}}; 
        end 
        else begin
            L4_in_r <= L4_in_w;
        end
    end
endmodule



//ALU_level_4
module ALU_L4 #(parameter k = 4)(
              clk,
              rst,
              ones,
              IPV_in,
              L4_in,
              L4_out,
              en,
              out_valid
    );
    /* ==================== IO ==================== */
    input             clk;
    input             rst;
    input  [3:0]      ones;
    input  [3:0]      IPV_in;
    input  [18*4-1:0] L4_in  ;
    output [28*4-1:0] L4_out ;
    input             en;
    output            out_valid;

    /* ================= WIRE/REG ================= */
    wire signed [27:0] L4_1,L4_2,L4_3,L4_4;
    
    wire signed [27:0] AAC_L,AAC_R;
    wire aac_valid_l, aac_valid_r;
    
    reg  [27:0] L4_out2_r,L4_out3_r;
    wire [27:0] L4_out2_w,L4_out3_w;
    reg  [3:0] counter_r,counter_w;
    
    /* ================= Submodules =============== */
    AAC aac_l(
        .clk(clk), 
        .reset_n(rst), 
        .aac(aac_valid_l), 
        .A_i(L4_1), 
        .out(AAC_L)
    );
    AAC aac_r(
        .clk(clk), 
        .reset_n(rst), 
        .aac(aac_valid_r), 
        .A_i(L4_4), 
        .out(AAC_R)
    );

    /* ================== Conti =================== */
    assign aac_valid_l = (counter_r == 4'd4 && IPV_in != 4'b0000) ? 1'b0 : 1'b1;
    assign aac_valid_r = 1'b0;
    //deco L4_in
    assign L4_1 = ((counter_r==4'd4) && (IPV_in[0]==1'b0)) ? AAC_R : 
                (counter_r == 4'd3) ? {{10{L4_in[71]}}, L4_in[18*4-1:18*4-18]} : 28'd0;
    assign L4_2 = {{10{L4_in[53]}}, L4_in[18*4-19:18*4-36]} ;
    assign L4_3 = {{10{L4_in[35]}}, L4_in[18*4-37:18*4-54]} ;
    assign L4_4 = (counter_r == 4'd3) ? {{10{L4_in[17]}}, L4_in[18*4-55:0]} : 28'd0;
    //assign L4_4 = ((counter_r==4'd5)&&(IPV_in[0]==1'b1))?L4_in[18*4-1:18*4-18]:L4_in[18*4-55:0]  ;
    //deco output 
    assign L4_out[28*4-1:28*4-28]   = AAC_L; 
    assign L4_out[28*4-29:28*4-56]  = (ones==4'd2)?AAC_R:L4_out2_r; 
    assign L4_out[28*4-57:28*4-84]  = (ones==4'd3)?AAC_R:L4_out3_r; 
    assign L4_out[28*4-85:0]        = AAC_R;  
    //delay 
    assign L4_out2_w = {{10{L4_2[17]}},L4_2};
    assign L4_out3_w = {{10{L4_3[17]}},L4_3}; 

    //output is ready
    assign out_valid = (counter_r==4'd4)?1'b1:1'b0;

    /* ================ Combination =============== */
    always @(*) begin
        counter_w = counter_r;
        if (en && (counter_r==4'b0)) counter_w = 4'b1;
        else if ((counter_r>=4'b1)&&(counter_r<4'd4)) counter_w = counter_r + 4'b1;
        else if (counter_r==4'd4)    counter_w = 4'b0;
    end
    



    /* ================ Sequencial ================ */
    always @(posedge clk) begin
        if (~rst) begin
            L4_out2_r <= {28{1'b0}}; 
            L4_out3_r <= {28{1'b0}};
            counter_r <= 4'b0;
        end 
        else begin
            L4_out2_r <= L4_out2_w; 
            L4_out3_r <= L4_out3_w;
            counter_r <= counter_w;
        end
    end

endmodule
