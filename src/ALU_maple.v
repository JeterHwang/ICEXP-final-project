//ALU_level_1
module ALU_L1 #(parameter k = 4)(
              matrix_in,
              vector_in,
              L1_out,
              en         
    );
    /* ==================== IO ==================== */
    input         [8*k-1:0]  matrix_in ;
    input         [8*k-1:0]  vector_in ; 
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
    assign vec_1 = vec_in[8*k-1:8*k-8]     ;
    assign vec_2 = vec_in[8*k-9:8*k-16]    ;
    assign vec_3 = vec_in[8*k-17:8*k-24]   ;
    assign vec_4 = vec_in[8*k-25:0]        ;

    //deco output
    assign L1_out[16*k-1:16*k-16]  = mat_1 * vec_1;
    assign L1_out[16*k-17:16*k-32] = mat_2 * vec_2;
    assign L1_out[16*k-33:16*k-48] = mat_3 * vec_3;
    assign L1_out[16*k-49:0]       = mat_4 * vec_4;

    //signal of ready
    assign en = (matrix_in[8*k-1:8*k-8] == 8'b0)? 1'b0 : 1'b1 ;

endmodule




//MAPTABLE_level_1
module MPT4_L1 #(parameter k = 4)(
                en,
                IPV_in,
                L1_out,
                L2_in,
                IPV_out        
    );
    /* ==================== IO ==================== */
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
    assign L2_in_w[32*k-1:32*k-16]    = ((IPV == 4'd0)||(IPV == 4'd1)||(IPV == 4'd2)||(IPV == 4'd3))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV == 4'd4)||(IPV == 4'd5))                              ? (L1_out[16*k-17:16*k-32]):
                                        (IPV == 4'd6)                                               ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-17:32*k-32]   = ((IPV == 4'd0)||(IPV == 4'd1)||(IPV == 4'd2)||(IPV == 4'd3))? (L1_out[16*k-17:16*k-32]): 
                                        ((IPV == 4'd4)||(IPV == 4'd5))                              ? (L1_out[16*k-33:16*k-48]):
                                        (IPV == 4'd6)                                               ? (L1_out[16*k-49:0])      : (16'b0) ;  
    assign L2_in_w[32*k-33:32*k-48]   = ((IPV == 4'd0)||(IPV == 4'd2))                              ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-49:32*k-64]   = ((IPV == 4'd0)||(IPV == 4'd2))                              ? (L1_out[16*k-49:0])      : (16'b0) ; 
    assign L2_in_w[32*k-65:32*k-80]   = ((IPV == 4'd4)||(IPV == 4'd5)||(IPV == 4'd6)||(IPV == 4'd7))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV == 4'd1)||(IPV == 4'd3))                              ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-81:32*k-96]   = ((IPV == 4'd1)||(IPV == 4'd3)||(IPV == 4'd4)||(IPV == 4'd5))? (L1_out[16*k-49:0])      : 
                                        ((IPV == 4'd6)||(IPV == 4'd7))                              ? (L1_out[16*k-17:16*k-32]): (16'b0) ; 
    assign L2_in_w[32*k-97:32*k-112]  = (IPV == 4'd7)                                               ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-113:0]        = (IPV == 4'd7)                                               ? (L1_out[16*k-49:0])      : (16'b0) ; 

    assign IPV_out = IPV_r;
    /* ================ Combination =============== */
    always @(*) begin
        if (en) IPV_w = IPV   ;
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
module MPT4_L2 #(parameter k = 4)(
                IPV_in,
                L2_out,
                L3_in,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         [3:0]  IPV_in;
    input         [17*6-1:0] L2_out ;
    output        [17*6-1:0] L3_in  ;
    output        [3:0]  IPV_out;
    /* ================= WIRE/REG ================= */
    reg [17*6-1:0] L3_in_r;
    wire[17*6-1:0] L3_in_w;
    /* ================== Conti =================== */
    assign L3_in_w[17*6-1:17*k-17]    = ((IPV == 4'd0)||(IPV == 4'd1)||(IPV == 4'd4))               ? (L2_out[17*6-1:17*6-17]) : (17'b0) ;
    assign L3_in_w[17*6-18:17*k-34]   = (IPV == 4'd0)                                               ? (L2_out[17*6-18:17*6-34]): 
                                        (IPV == 4'd1)                                               ? (L2_out[17*6-35:17*6-51]):
                                        (IPV == 4'd4)                                               ? (L2_out[17*6-52:17*6-68]): (17'b0) ;  
    assign L3_in_w[17*6-35:17*k-51]   = ((IPV == 4'd4)||(IPV == 4'd5)||(IPV == 4'd6)||(IPV == 4'd7))? (L2_out[17*6-35:17*6-51]): 
                                        ((IPV == 4'd2)||(IPV == 4'd3))                              ? (L2_out[17*6-1:17*6-17]) :
                                        (IPV == 4'd1)                                               ? (L2_out[17*6-52:17*6-68]): (17'b0) ;
    assign L3_in_w[17*6-52:17*k-68]   = ((IPV == 4'd6)||(IPV == 4'd7))                              ? (L2_out[17*6-52:17*6-68]): 
                                        (IPV == 4'd5)                                               ? (L2_out[17*6-1:17*6-17] ):
                                        (IPV == 4'd3)                                               ? (L2_out[17*6-35:17*6-51]):
                                        (IPV == 4'd2)                                               ? (L2_out[17*6-18:17*6-34]): (17'b0) ;  
    assign L3_in_w[17*6-69:17*k-85]   = ((IPV == 4'd3)||(IPV == 4'd5))                              ? (L2_out[17*6-52:17*6-68]): 
                                        (IPV == 4'd6)                                               ? (L2_out[17*6-1:17*6-17]) :
                                        (IPV == 4'd7)                                               ? (L2_out[17*6-69:17*6-85]): (17'b0) ;
    assign L3_in_w[17*6-86:0]         = (IPV == 4'd7)                                               ? (L2_out[17*6-86:0])      : (17'b0) ; 
                                        
    assign IPV_out = IPV_r;
    /* ================ Sequencial ================ */
    always @(posedge clk) begin
        if (~rst) begin
            L3_in_r <= {(17 * 16){1'b0}}; 
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
module MPT4_L3 #(parameter k = 4)(
                IPV_in,
                L3_out,
                L4_in,
                IPV_out    
    );
    /* ==================== IO ==================== */
    input         [3:0]  IPV_in;
    input         [18*5-1:0] L3_out ;
    output        [18*4-1:0] L4_in  ;
    output        [3:0]  IPV_out;
    /* ================= WIRE/REG ================= */
    reg [18*4-1:0] L4_in_r;
    wire[18*4-1:0] L4_in_w;
    /* ================== Conti =================== */
    assign L4_in_w[17*6-1:17*k-17]    = ((IPV == 4'd0)||(IPV == 4'd1))                              ? L3_out[18*5-1:18*5-18] : L3_out[18*5-19:18*5-36] ;
    assign L4_in_w[17*6-18:17*k-34]   = ((IPV == 4'd3)||(IPV == 4'd5)||(IPV == 4'd6)||(IPV == 4'd7))? L3_out[18*5-37:18*5-54]: 18'b0                   ; 
    assign L4_in_w[17*6-35:17*k-51]   = (IPV == 4'd7)                                               ? L3_out[18*5-55:18*5-72]: 18'b0                   ;

    assign L4_in_w[17*6-52:17*k-68]   = ((IPV == 4'd3)||(IPV == 4'd5)||(IPV == 4'd6))               ? L3_out[18*5-55:18*5-72]: 
                                        (IPV == 4'd1)                                               ? L3_out[18*5-19:18*5-36]:
                                        (IPV == 4'd2)                                               ? L3_out[18*5-37:18*5-54]:
                                        (IPV == 4'd4)                                               ? L3_out[18*5-1:18*5-18] : 
                                        (IPV == 4'd7)                                               ? L3_out[18*5-73:0]      : 18'b0                   ;  
                                        
    assign IPV_out = IPV_r;
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