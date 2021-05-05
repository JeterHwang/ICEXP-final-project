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
    assign en = (matrix_in[8*k-1:8*k-8] == 8'b0)? 1'b0 : 1'b1 ;

endmodule