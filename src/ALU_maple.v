//ALU_level_1
`include "../src/adderAccumulator.v"

module ALU_Maple4 #(parameter k = 4) (
                  clk,
                  rst,
                  IPV_l1_in,
                  alu_mat_in,
                  alu_vec_in,
                  vov,
                  alu_l4_out,
                  alu_out_valid
    );
    /* ==================== IO ==================== */
    input                    clk,rst       ;
    input         [3:0]      IPV_l1_in     ;
    input         [8*k-1:0]  alu_mat_in    ; 
    input         [8*k-1:0]  alu_vec_in    ; 
    input         [3:0]      vov           ;
    output        [24*4-1:0] alu_l4_out    ;
    output                   alu_out_valid ; 
    /* ================= WIRE/REG ================= */
    // alu
    wire            alu_l1_en ;
    wire [2:0]      counter;
    wire [15:0]     L1_out_1,L1_out_2,L1_out_3,L1_out_4;
    wire [15:0]     L2_in_1,L2_in_2,L2_in_3,L2_in_4,L2_in_5,L2_in_6,L2_in_7,L2_in_8;
    wire [16:0]     L2_out_1,L2_out_2,L2_out_3,L2_out_4,L2_out_5,L2_out_6;
    wire [16:0]     L3_in_1,L3_in_2,L3_in_3,L3_in_4,L3_in_5,L3_in_6;
    wire [17:0]     L3_out_1,L3_out_2,L3_out_3,L3_out_4,L3_out_5;
    wire [17:0]     L4_in_1,L4_in_2,L4_in_3,L4_in_4;
    wire            alu_out_valid;

    // Map_table
    wire [3:0] IPV_l1_out;
    wire [3:0] IPV_l2_out;
    wire [3:0] IPV_l3_out;


    Map_table_L1 map_l1(
    .clk(clk),
    .rst(rst),
    .en(alu_l1_en),
    .IPV_in(IPV_l1_in) ,
    .L1_out_1(L1_out_1),
    .L1_out_2(L1_out_2),
    .L1_out_3(L1_out_3),
    .L1_out_4(L1_out_4),
    .L2_in_1(L2_in_1),
    .L2_in_2(L2_in_2),
    .L2_in_3(L2_in_3),
    .L2_in_4(L2_in_4),
    .L2_in_5(L2_in_5),
    .L2_in_6(L2_in_6),
    .L2_in_7(L2_in_7),
    .L2_in_8(L2_in_8),
    .IPV_out(IPV_l1_out)    
    );
    Map_table_L2 map_l2(
    .clk(clk),
    .rst(rst),
    .IPV_in(IPV_l1_out),
    .L2_out_1(L2_out_1),
    .L2_out_2(L2_out_2),
    .L2_out_3(L2_out_3),
    .L2_out_4(L2_out_4),
    .L2_out_5(L2_out_5),
    .L2_out_6(L2_out_6),
    .L3_in_1(L3_in_1),
    .L3_in_2(L3_in_2),
    .L3_in_3(L3_in_3),
    .L3_in_4(L3_in_4),
    .L3_in_5(L3_in_5),
    .L3_in_6(L3_in_6),
    .IPV_out(IPV_l2_out)  
    );
    Map_table_L3 map_l3(
    .clk(clk),
    .rst(rst),
    .IPV_in(IPV_l2_out),
    .L3_out_1(L3_out_1),
    .L3_out_2(L3_out_2),
    .L3_out_3(L3_out_3),
    .L3_out_4(L3_out_4),
    .L3_out_5(L3_out_5),
    .L4_in_1(L4_in_1),
    .L4_in_2(L4_in_2),
    .L4_in_3(L4_in_3),
    .L4_in_4(L4_in_4),
    .IPV_out(IPV_l3_out)  
    );


    ALU_L1 alu_l1(
    .clk(clk),
    .rst(rst),
    .matrix_in(alu_mat_in),
    .vector_in(alu_vec_in),
    .IPV(IPV_l1_in),
    .counter(counter),
    .L1_out_1(L1_out_1),
    .L1_out_2(L1_out_2),
    .L1_out_3(L1_out_3),
    .L1_out_4(L1_out_4), 
    .en(alu_l1_en)
    );
    ALU_L2 alu_l2(
    .L2_in_1(L2_in_1),
    .L2_in_2(L2_in_2),
    .L2_in_3(L2_in_3),
    .L2_in_4(L2_in_4),
    .L2_in_5(L2_in_5),
    .L2_in_6(L2_in_6),
    .L2_in_7(L2_in_7),
    .L2_in_8(L2_in_8),
    .L2_out_1(L2_out_1),
    .L2_out_2(L2_out_2),
    .L2_out_3(L2_out_3),
    .L2_out_4(L2_out_4),
    .L2_out_5(L2_out_5),
    .L2_out_6(L2_out_6)
    );
    ALU_L3 alu_l3(
    .L3_in_1(L3_in_1),
    .L3_in_2(L3_in_2),
    .L3_in_3(L3_in_3),
    .L3_in_4(L3_in_4),
    .L3_in_5(L3_in_5),
    .L3_in_6(L3_in_6),
    .L3_out_1(L3_out_1),
    .L3_out_2(L3_out_2),
    .L3_out_3(L3_out_3),
    .L3_out_4(L3_out_4),
    .L3_out_5(L3_out_5)
    );
    ALU_L4 alu_l4(
    .clk(clk),
    .rst(rst),
    .ones(vov),
    .IPV_in(IPV_l3_out),
    .L4_in_1(L4_in_1),
    .L4_in_2(L4_in_2),
    .L4_in_3(L4_in_3),
    .L4_in_4(L4_in_4),
    .L4_out(alu_l4_out),
    .en(alu_l1_en),
    .counter(counter),
    .out_valid(alu_out_valid)
    );

endmodule










module ALU_L1 #(parameter k = 4)(
              clk,
              rst,
              matrix_in,
              vector_in,
              IPV,
              counter,
              L1_out_1,
              L1_out_2,
              L1_out_3,
              L1_out_4, 
              en         
    );
    /* ==================== IO ==================== */
    input                    clk,rst   ;
    input         [8*k-1:0]  matrix_in ; 
    input         [8*k-1:0]  vector_in ; 
    input         [k-1:0]    IPV       ;
    input         [2:0]      counter   ;
    output signed [15:0]     L1_out_1  ;
    output signed [15:0]     L1_out_2  ;
    output signed [15:0]     L1_out_3  ;
    output signed [15:0]     L1_out_4  ;
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
    //assign L1_out_1 = mat_1 * vec_1;
    //assign L1_out_2 = mat_2 * vec_2;
    //assign L1_out_3 = mat_3 * vec_3;
    //assign L1_out_4 = mat_4 * vec_4;
    mul_pipeline mux1(.clk(clk),.rst(rst),.en(en),.counter(counter),.x(mat_1),.y(vec_1),.z(L1_out_1));
    mul_pipeline mux2(.clk(clk),.rst(rst),.en(en),.counter(counter),.x(mat_2),.y(vec_2),.z(L1_out_2));
    mul_pipeline mux3(.clk(clk),.rst(rst),.en(en),.counter(counter),.x(mat_3),.y(vec_3),.z(L1_out_3));
    mul_pipeline mux4(.clk(clk),.rst(rst),.en(en),.counter(counter),.x(mat_4),.y(vec_4),.z(L1_out_4));

    //signal of ready to process the new 4 bits
    //assign en = ((matrix_in[8*k-1:8*k-8] == 8'b0)&&(IPV == {k{1'b0}}))? 1'b0 : 1'b1 ;
    assign en = ((matrix_in[8*k-1:8*k-8] == 8'b0)&&(IPV == {k{1'b0}}))? 1'b0 : 1'b1 ;

endmodule

//MAPTABLE_level_1
module Map_table_L1 #(parameter k = 4)(
                clk,
                rst,
                en,
                IPV_in,
                L1_out_1,
                L1_out_2,
                L1_out_3,
                L1_out_4,
                L2_in_1,
                L2_in_2,
                L2_in_3,
                L2_in_4,
                L2_in_5,
                L2_in_6,
                L2_in_7,
                L2_in_8, 
                IPV_out        
    );
    /* ==================== IO ==================== */
    input                 clk,rst  ;
    input                 en       ;
    input          [3:0]  IPV_in   ;

    input signed   [15:0] L1_out_1 ;
    input signed   [15:0] L1_out_2 ;
    input signed   [15:0] L1_out_3 ;
    input signed   [15:0] L1_out_4 ;

    output signed  [15:0] L2_in_1 ;
    output signed  [15:0] L2_in_2 ;
    output signed  [15:0] L2_in_3 ;
    output signed  [15:0] L2_in_4 ;
    output signed  [15:0] L2_in_5 ;
    output signed  [15:0] L2_in_6 ;
    output signed  [15:0] L2_in_7 ;
    output signed  [15:0] L2_in_8 ;
    output         [3:0]  IPV_out ;
    /* ================= WIRE/REG ================= */
    reg [3:0]  IPV_r,IPV_w;
    reg [32*k-1:0] L2_in_r;
    wire[32*k-1:0] L2_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L2
    assign IPV_out = IPV_r;
    //input to ALU_L2
    assign L2_in_1   = L2_in_r[32*k-1:32*k-16]  ;
    assign L2_in_2   = L2_in_r[32*k-17:32*k-32] ;
    assign L2_in_3   = L2_in_r[32*k-33:32*k-48] ;
    assign L2_in_4   = L2_in_r[32*k-49:32*k-64] ;
    assign L2_in_5   = L2_in_r[32*k-65:32*k-80] ;
    assign L2_in_6   = L2_in_r[32*k-81:32*k-96] ;
    assign L2_in_7   = L2_in_r[32*k-97:32*k-112];
    assign L2_in_8   = L2_in_r[32*k-113:0]      ;

    //Match in/out
    wire   mem2,mem3,mem4,mem5;
    assign mem2 = (IPV_r[3:1] == 3'd4)||(IPV_r[3:1] == 3'd5);
    assign mem3 = (IPV_r[3:1] == 3'd0)||(IPV_r[3:1] == 3'd2);
    assign mem4 = (IPV_r[3:1] == 3'd1)||(IPV_r[3:1] == 3'd3);
    assign mem5 = (IPV_r[3:1] == 3'd6)||(IPV_r[3:1] == 3'd7);

    assign L2_in_w[32*k-1:32*k-16]    = (mem3||mem4)                 ? (L1_out_1): 
                                        (mem2)                       ? (L1_out_2):
                                        (IPV_r[3:1] == 3'd6)         ? (L1_out_3): (16'b0) ; 
    assign L2_in_w[32*k-17:32*k-32]   = (mem3||mem4)                 ? (L1_out_2): 
                                        (mem2)                       ? (L1_out_3):
                                        (IPV_r[3:1] == 3'd6)         ? (L1_out_4): (16'b0) ;  
    assign L2_in_w[32*k-33:32*k-48]   = (mem3)                       ? (L1_out_3): (16'b0) ; 
    assign L2_in_w[32*k-49:32*k-64]   = (mem3)                       ? (L1_out_4): (16'b0) ; 
    assign L2_in_w[32*k-65:32*k-80]   = (mem2||mem5)                 ? (L1_out_1): 
                                        (mem4)                       ? (L1_out_3): (16'b0) ; 
    assign L2_in_w[32*k-81:32*k-96]   = (mem4||mem2)                 ? (L1_out_4): 
                                        (mem5)                       ? (L1_out_2): (16'b0) ; 
    assign L2_in_w[32*k-97:32*k-112]  = (&IPV_r[3:1])                ? (L1_out_3): (16'b0) ; 
    assign L2_in_w[32*k-113:0]        = (&IPV_r[3:1])                ? (L1_out_4): (16'b0) ; 


    /* ================ Combination =============== */
    //lock IPV
    always @(*) begin
        if (en) IPV_w = IPV_in;
        else    IPV_w = IPV_r ;
    end
    /* ================ Sequencial ================ */
  always @(posedge clk or negedge rst) begin
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
              L2_in_1,
              L2_in_2,
              L2_in_3,
              L2_in_4,
              L2_in_5,
              L2_in_6,
              L2_in_7,
              L2_in_8,
              L2_out_1,
              L2_out_2,
              L2_out_3,
              L2_out_4,
              L2_out_5,
              L2_out_6
    );
    /* ==================== IO ==================== */
    input signed   [15:0] L2_in_1 ;
    input signed   [15:0] L2_in_2 ;
    input signed   [15:0] L2_in_3 ;
    input signed   [15:0] L2_in_4 ;
    input signed   [15:0] L2_in_5 ;
    input signed   [15:0] L2_in_6 ;
    input signed   [15:0] L2_in_7 ;
    input signed   [15:0] L2_in_8 ;

    output signed  [16:0] L2_out_1 ;
    output signed  [16:0] L2_out_2 ;
    output signed  [16:0] L2_out_3 ;
    output signed  [16:0] L2_out_4 ;
    output signed  [16:0] L2_out_5 ;
    output signed  [16:0] L2_out_6 ;
    /* ================== Conti =================== */
    //deco output
    assign L2_out_1  = {L2_in_1[15],L2_in_1} + {L2_in_2[15],L2_in_2}; 
    assign L2_out_2  = {L2_in_3[15],L2_in_3} + {L2_in_4[15],L2_in_4};
    assign L2_out_3  = {L2_in_5[15],L2_in_5};
    assign L2_out_4  = {L2_in_6[15],L2_in_6}; 
    assign L2_out_5  = {L2_in_7[15],L2_in_7}; 
    assign L2_out_6  = {L2_in_8[15],L2_in_8};

endmodule



//MAPTABLE_level_2
module Map_table_L2 #(parameter k = 4)(
                clk,
                rst,
                IPV_in,
                L2_out_1,
                L2_out_2,
                L2_out_3,
                L2_out_4,
                L2_out_5,
                L2_out_6,
                L3_in_1,
                L3_in_2,
                L3_in_3,
                L3_in_4,
                L3_in_5,
                L3_in_6,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         clk,rst         ;
    input         [3:0]  IPV_in   ;
    input signed  [16:0] L2_out_1 ;
    input signed  [16:0] L2_out_2 ;
    input signed  [16:0] L2_out_3 ;
    input signed  [16:0] L2_out_4 ;
    input signed  [16:0] L2_out_5 ;
    input signed  [16:0] L2_out_6 ;

    output signed  [16:0] L3_in_1 ;
    output signed  [16:0] L3_in_2 ;
    output signed  [16:0] L3_in_3 ;
    output signed  [16:0] L3_in_4 ;
    output signed  [16:0] L3_in_5 ;
    output signed  [16:0] L3_in_6 ;
    output         [3:0]  IPV_out ;
    /* ================= WIRE/REG ================= */
    reg [17*6-1:0] L3_in_r;
    wire[17*6-1:0] L3_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L3              
    assign IPV_out = IPV_in;
    //input to ALU_L3
    assign L3_in_1 = L3_in_r[17*6-1:17*6-17]  ;
    assign L3_in_2 = L3_in_r[17*6-18:17*6-34] ;
    assign L3_in_3 = L3_in_r[17*6-35:17*6-51] ;
    assign L3_in_4 = L3_in_r[17*6-52:17*6-68] ;
    assign L3_in_5 = L3_in_r[17*6-69:17*6-85] ;
    assign L3_in_6 = L3_in_r[17*6-86:0]       ;

    //Match in/out
    assign L3_in_w[17*6-1:17*6-17]    = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1)||(IPV_in[3:1] == 3'd4)) ? (L2_out_1) : (17'b0) ;
    assign L3_in_w[17*6-18:17*6-34]   = (IPV_in[3:1] == 3'd0)                                                 ? (L2_out_2): 
                                        (IPV_in[3:1] == 3'd1)                                                 ? (L2_out_3):
                                        (IPV_in[3:1] == 3'd4)                                                 ? (L2_out_4): (17'b0) ;  
    assign L3_in_w[17*6-35:17*6-51]   = ((IPV_in[3:1] == 3'd4)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6)||(&IPV_in[3:1]))? (L2_out_3): 
                                        ((IPV_in[3:1] == 3'd2)||(IPV_in[3:1] == 3'd3))                        ? (L2_out_1):
                                        (IPV_in[3:1] == 3'd1)                                                 ? (L2_out_4): (17'b0) ;
    assign L3_in_w[17*6-52:17*6-68]   = ((IPV_in[3:1] == 3'd6)||(&IPV_in[3:1]))                               ? (L2_out_4): 
                                        (IPV_in[3:1] == 3'd5)                                                 ? (L2_out_1):
                                        (IPV_in[3:1] == 3'd3)                                                 ? (L2_out_3):
                                        (IPV_in[3:1] == 3'd2)                                                 ? (L2_out_2): (17'b0) ;  
    assign L3_in_w[17*6-69:17*6-85]   = ((IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd5))                        ? (L2_out_4): 
                                        (IPV_in[3:1] == 3'd6)                                                 ? (L2_out_1):
                                        (&IPV_in[3:1])                                                        ? (L2_out_5): (17'b0) ;
    assign L3_in_w[17*6-86:0]         = (&IPV_in[3:1])                                                        ? (L2_out_6): (17'b0) ; 
    /* ================ Sequencial ================ */
  always @(posedge clk or negedge rst) begin
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
              L3_in_1,
              L3_in_2,
              L3_in_3,
              L3_in_4,
              L3_in_5,
              L3_in_6,
              L3_out_1,
              L3_out_2,
              L3_out_3,
              L3_out_4,
              L3_out_5
    );
    /* ==================== IO ==================== */
    input signed  [16:0] L3_in_1 ;
    input signed  [16:0] L3_in_2 ;
    input signed  [16:0] L3_in_3 ;
    input signed  [16:0] L3_in_4 ;
    input signed  [16:0] L3_in_5 ;
    input signed  [16:0] L3_in_6 ;

    output signed  [17:0] L3_out_1 ;
    output signed  [17:0] L3_out_2 ;
    output signed  [17:0] L3_out_3 ;
    output signed  [17:0] L3_out_4 ;
    output signed  [17:0] L3_out_5 ;
    /* ================== Conti =================== */
    assign L3_out_1  = {L3_in_1[16],L3_in_1} + {L3_in_2[16],L3_in_2} ; 
    assign L3_out_2  = {L3_in_3[16],L3_in_3} ; 
    assign L3_out_3  = {L3_in_4[16],L3_in_4} ; 
    assign L3_out_4  = {L3_in_5[16],L3_in_5} ;   
    assign L3_out_5  = {L3_in_6[16],L3_in_6} ; 

endmodule


//MAPTABLE_level_3
module Map_table_L3 #(parameter k = 4)(
                clk,
                rst,
                IPV_in,
                L3_out_1,
                L3_out_2,
                L3_out_3,
                L3_out_4,
                L3_out_5,
                L4_in_1,
                L4_in_2,
                L4_in_3,
                L4_in_4,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         clk,rst         ;
    input         [3:0]  IPV_in   ;
    input signed  [17:0] L3_out_1 ;
    input signed  [17:0] L3_out_2 ;
    input signed  [17:0] L3_out_3 ;
    input signed  [17:0] L3_out_4 ;
    input signed  [17:0] L3_out_5 ;

    output signed  [17:0] L4_in_1 ;
    output signed  [17:0] L4_in_2 ;
    output signed  [17:0] L4_in_3 ;
    output signed  [17:0] L4_in_4 ;
    output         [3:0]  IPV_out;
    /* ================= WIRE/REG ================= */
    reg [18*4-1:0] L4_in_r;
    wire[18*4-1:0] L4_in_w;
    /* ================== Conti =================== */
    //pass IPV to Map_table_L4                                     
    assign IPV_out = IPV_in;
    //input to ALU_L4
    assign L4_in_1   = L4_in_r[18*4-1:18*4-18] ;
    assign L4_in_2   = L4_in_r[18*4-19:18*4-36];
    assign L4_in_3   = L4_in_r[18*4-37:18*4-54];
    assign L4_in_4   = L4_in_r[18*4-55:0]      ;

    //Match in/out
    wire mem1;
    assign mem1 = (IPV_in[3:1] == 3'd3)||(IPV_in[3:1] == 3'd5)||(IPV_in[3:1] == 3'd6) ;
    
    assign L4_in_w[18*4-1:18*4-18]    = ((IPV_in[3:1] == 3'd0)||(IPV_in[3:1] == 3'd1))      ? L3_out_1: L3_out_2 ;
    assign L4_in_w[18*4-19:18*4-36]   = (mem1||(&IPV_in[3:1]))                              ? L3_out_3: (18'b0)  ; 
    assign L4_in_w[18*4-37:18*4-54]   = (&IPV_in[3:1])                                      ? L3_out_4: (18'b0)  ;
    assign L4_in_w[18*4-55:0]         = (mem1)                                              ? L3_out_4: 
                                        (IPV_in[3:1] == 3'd1)                               ? L3_out_2:
                                        (IPV_in[3:1] == 3'd2)                               ? L3_out_3:
                                        (IPV_in[3:1] == 3'd4)                               ? L3_out_1: 
                                        (&IPV_in[3:1])                                      ? L3_out_5: (18'b0)  ;  
    /* ================ Sequencial ================ */
  always @(posedge clk or negedge rst) begin
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
              L4_in_1,
              L4_in_2,
              L4_in_3,
              L4_in_4,
              L4_out,
              en,
              counter,
              out_valid
    );
    /* ==================== IO ==================== */
    input                    clk;
    input                    rst;
    input         [3:0]      ones;
    input         [3:0]      IPV_in;
    input signed  [17:0]     L4_in_1 ;
    input signed  [17:0]     L4_in_2 ;
    input signed  [17:0]     L4_in_3 ;
    input signed  [17:0]     L4_in_4 ;
    output        [24*4-1:0] L4_out ;
    input                    en;
    output        [2:0]      counter;
    output                   out_valid;

    /* ================= WIRE/REG ================= */
    wire signed [23:0] L4_1,L4_2,L4_3,L4_4;
    
    wire signed [23:0] AAC_L;
    wire aac_valid_l;
    
    reg  [23:0] L4_out2_r,L4_out3_r,L4_out4_r;
    wire [23:0] L4_out2_w,L4_out3_w,L4_out4_w;
    reg  [2:0] counter_r,counter_w;
    wire counter_5;
    
    /* ================= Submodules =============== */
    AAC aac_l(
        .clk(clk), 
        .reset_n(rst), 
        .aac(aac_valid_l), 
        .A_i(L4_1), 
        .out(AAC_L)
    );
    /* ================== Conti =================== */
    assign counter_5 = (counter_r==3'd5) ? 1'b1 : 1'b0;
    assign counter = counter_r;
    assign aac_valid_l = (counter_5 && (|IPV_in)) ? 1'b0 : 1'b1;
    //deco L4_in
    assign L4_1 = (counter_5 && ~IPV_in[0]) ? L4_out4_r : 
                  (counter_r==3'd4)  ? {{6{L4_in_1[17]}}, L4_in_1} : 24'd0;
    assign L4_2 = {{6{L4_in_2[17]}}, L4_in_2} ;
    assign L4_3 = {{6{L4_in_3[17]}}, L4_in_3} ;
    assign L4_4 = {{6{L4_in_4[17]}}, L4_in_4} ;
    //deco output 
    assign L4_out[24*4-1:24*4-24]   = AAC_L; 
    assign L4_out[24*4-25:24*4-48]  = (ones==4'd2)?L4_out4_r:L4_out2_r; 
    assign L4_out[24*4-49:24*4-72]  = (ones==4'd3)?L4_out4_r:L4_out3_r; 
    assign L4_out[24*4-73:0]        = L4_out4_r;
    //delay 
    assign L4_out2_w = L4_2;
    assign L4_out3_w = L4_3;
    assign L4_out4_w = L4_4; 
 
    //output is ready
    assign out_valid = (counter_5)? 1'b1 : 1'b0 ;

    /* ================ Combination =============== */
    always @(*) begin
        counter_w = counter_r;
        if (en && (~|counter_r)) counter_w = 3'd1;
        else if ((counter_r>=3'd1)&&(counter_r<3'd5)) counter_w = counter_r + 3'd1;
        else if (counter_5)    counter_w = 3'd0;
    end
    
    /* ================ Sequencial ================ */
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            L4_out2_r <= {24{1'b0}}; 
            L4_out3_r <= {24{1'b0}};
            L4_out4_r <= {24{1'b0}};
            counter_r <= 3'b0;
        end 
        else begin
            L4_out2_r <= L4_out2_w; 
            L4_out3_r <= L4_out3_w;
            L4_out4_r <= L4_out4_w;
            counter_r <= counter_w;
        end
    end
endmodule



module mul_pipeline (
    clk,
    rst,
    en,
    counter,
    x,
    y,
    z
    );
    /* ==================== IO ==================== */
    input         clk,rst;
    input         en     ;
    input         [2:0]  counter;
    input  signed [7:0]  x,y;
    output signed [15:0] z;
    /* ================= WIRE/REG ================= */
    reg  signed [15:0] sum_r,sum_w;
    wire        [6:0]  sum_1,sum_2,sum_3,sum_4,sum_5,sum_6,sum_7;
    wire        [15:0] sum_p1,sum_p2,sum_p3,sum_p4,sum_p5,sum_p6,sum_p7,sum_p8; 
    reg  signed [15:0] sum_up_r,sum_up_w;
    reg  signed [15:0] sum_down_w;
    /* ================== Conti =================== */
    assign z = (counter==3'd1) ? sum_w : 16'b0;

    assign sum_1 = x[6:0]&{7{y[0]}};
    assign sum_2 = x[6:0]&{7{y[1]}};
    assign sum_3 = x[6:0]&{7{y[2]}};
    assign sum_4 = x[6:0]&{7{y[3]}};
    assign sum_5 = x[6:0]&{7{y[4]}};
    assign sum_6 = x[6:0]&{7{y[5]}};
    assign sum_7 = x[6:0]&{7{y[6]}};

    assign sum_p1 = {7'b0,1'b1,{~{x[0]&y[7]}},sum_1};
    assign sum_p2 = {7'b0,{~{x[1]&y[7]}},sum_2,1'b0};
    assign sum_p3 = {6'b0,{~{x[2]&y[7]}},sum_3,2'b0};
    assign sum_p4 = {5'b0,{~{x[3]&y[7]}},sum_4,3'b0};
    assign sum_p5 = {4'b0,{~{x[4]&y[7]}},sum_5,4'b0};
    assign sum_p6 = {3'b0,{~{x[5]&y[7]}},sum_6,5'b0};
    assign sum_p7 = {2'b0,{~{x[6]&y[7]}},sum_7,6'b0};
    assign sum_p8 = {1'b1,{x[7]&y[7]},{~{x[7]&y[6]}},{~{x[7]&y[5]}},{~{x[7]&y[4]}},{~{x[7]&y[3]}},{~{x[7]&y[2]}},{~{x[7]&y[1]}},{~{x[7]&y[0]}},7'b0};
    /* ================ Combination =============== */
    always @(*) begin
        sum_up_w   = sum_up_r;
        if (en) begin
            sum_up_w   = sum_p5 + sum_p6 + sum_p7 + sum_p8 ;
            sum_down_w = sum_p1 + sum_p2 + sum_p3 + sum_p4 ;
        end

        sum_w = sum_r;
        if      (counter == 3'b0 && en)  sum_w = sum_r + sum_down_w ;
        else if (counter == 3'b1)        sum_w = sum_r + sum_up_r   ;
    end
    /* ================ Sequencial ================ */
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            sum_r      <= 16'b0 ; 
            sum_up_r   <= 16'b0 ; 
        end 
        else begin
            if (counter == 3'd3) begin
                sum_r      <= 16'b0 ; 
                sum_up_r   <= 16'b0 ;
            end
            else begin
                sum_r      <= sum_w ; 
                sum_up_r   <= sum_up_w ;
            end
        end
    end
endmodule
