//MAPTABLE_level_1
module Map_table_L1 #(parameter k = 4)(
        clk,
        rst,
        en,
        IPV_in,
        L1_out,
        L2_in,
        IPV_out);
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
    assign L2_in_w[32*k-1:32*k-16]    = ((IPV_in == 4'd0)||(IPV_in == 4'd1)||(IPV_in == 4'd2)||(IPV_in == 4'd3))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV_in == 4'd4)||(IPV_in == 4'd5))                                    ? (L1_out[16*k-17:16*k-32]):
                                        (IPV_in == 4'd6)                                                        ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-17:32*k-32]   = ((IPV_in == 4'd0)||(IPV_in == 4'd1)||(IPV_in == 4'd2)||(IPV_in == 4'd3))? (L1_out[16*k-17:16*k-32]): 
                                        ((IPV_in == 4'd4)||(IPV_in == 4'd5))                                    ? (L1_out[16*k-33:16*k-48]):
                                        (IPV_in == 4'd6)                                                        ? (L1_out[16*k-49:0])      : (16'b0) ;  
    assign L2_in_w[32*k-33:32*k-48]   = ((IPV_in == 4'd0)||(IPV_in == 4'd2))                                    ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-49:32*k-64]   = ((IPV_in == 4'd0)||(IPV_in == 4'd2))                                    ? (L1_out[16*k-49:0])      : (16'b0) ; 
    assign L2_in_w[32*k-65:32*k-80]   = ((IPV_in == 4'd4)||(IPV_in == 4'd5)||(IPV_in == 4'd6)||(IPV_in == 4'd7))? (L1_out[16*k-1:16*k-16]) : 
                                        ((IPV_in == 4'd1)||(IPV_in == 4'd3))                                    ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-81:32*k-96]   = ((IPV_in == 4'd1)||(IPV_in == 4'd3)||(IPV_in == 4'd4)||(IPV_in == 4'd5))? (L1_out[16*k-49:0])      : 
                                        ((IPV_in == 4'd6)||(IPV_in == 4'd7))                                    ? (L1_out[16*k-17:16*k-32]): (16'b0) ; 
    assign L2_in_w[32*k-97:32*k-112]  = (IPV_in == 4'd7)                                                        ? (L1_out[16*k-33:16*k-48]): (16'b0) ; 
    assign L2_in_w[32*k-113:0]        = (IPV_in == 4'd7)                                                        ? (L1_out[16*k-49:0])      : (16'b0) ; 


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