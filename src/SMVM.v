module SMVM(
  input         clk,
  input         rst_n,
  input  [7:0]  val_in,
  input  [7:0]  col_in,
  input         ipv_in,
  output        out_valid,
  output [23:0] data_out,
);

///////////////////////////////////////////
/////          parameter              /////
///////////////////////////////////////////
parameter k = 4;

// state
parameter IDLE   = 3'b000;    // no op/ input shape
parameter VEC_IN = 3'b001;    // input vector
parameter MAT_IN = 3'b010;    // input matrix
parameter CAL    = 3'b011;    // calculate
parameter OUT    = 3'b100;    // output

///////////////////////////////////////////
/////          reg & wire             /////
///////////////////////////////////////////

// FFs
reg        [3:0] state, next_state;
reg        [7:0] vec_count, next_vec_count; // count vector input
reg        [2:0] input_count, next_input_count; // count to k and start operation
reg        [7:0] rows, next_rows;
reg        [7:0] cols, next_cols;
reg signed [7:0] vec[0:127], next_vec[0:127]; // save vector
reg signed [7:0] val[0:k-1], next_val[0:k-1]; // k * value
reg        [7:0] col[0:k-1], next_col[0:k-1]; // k * column index
reg              ipv[0:k-1], next_ipv[0:k-1]; // k * ipv

// inter connect
// alu
reg           alu_l1_en ;
reg [8*k-1:0] alu_mat_in;
reg [8*k-1:0] alu_vec_in;
reg [16*k-1:0]alu_l1_out;
reg [32*k-1:0]alu_l2_in ;
reg [17*6-1:0]alu_l2_out;
reg [17*6-1:0]alu_l3_in ;
reg [18*5-1:0]alu_l3_out;
reg [18*4-1:0]alu_l4_in ;
reg [28*4-1:0]alu_l4_out ;
//Map_table
reg [3:0] IPV_l1_in ;
reg [3:0] IPV_l1_out;
reg [3:0] IPV_l2_out;
reg [3:0] IPV_l3_out;
//AAC
reg       aac_valid_l,aac_valid_r;
reg [27:0]AAC_L,AAC_R;

  
  
  
  
// reducer
reg  [k-1:0]   reducer_ipv_in;
wire [k-1:0]   vov;

///////////////////////////////////////////
/////           submodule             /////
///////////////////////////////////////////
Map_table_L1 map_l1(
  .clk(clk),
  .rst(rst_n),
  .en(alu_l1_en),
  .IPV_in(IPV_l1_in),
  .L1_out(alu_l1_out),
  .L2_in(alu_l2_in),
  .IPV_out(IPV_l1_out)    
);
Map_table_L2 map_l2(
  .clk(clk),
  .rst(rst_n),
  .IPV_in(IPV_l1_out),
  .L2_out(alu_l2_out),
  .L3_in(alu_l3_in),
  .IPV_out(IPV_l2_out)  
);
Map_table_L3 map_l3(
  .clk(clk),
  .rst(rst_n),
  .IPV_in(IPV_l2_out),
  .L3_out(alu_l3_out),
  .L4_in(alu_l4_in),
  .IPV_out(IPV_l3_out)  

);

ALU_L1 alu_l1(
  .matrix_in(alu_mat_in),
  .vector_in(alu_vec_in),
  .L1_out(alu_l1_out),
  .en(alu_l1_en)
);
ALU_L2 alu_l2(
  .L2_in(alu_l2_in),
  .L2_out(alu_l2_out) 
);
ALU_L3 alu_l3(
  .L3_in(alu_l3_in),
  .L3_out(alu_l3_out) 
);
ALU_L4 alu_l4(
  .AAC_L(AAC_L),
  .AAC_R(AAC_R),
  .L4_in(alu_l4_in),
  .L4_out(alu_l4_out) 
);
  
  
  
IPV_encoder encoder();
IPV_reducer reducer(
  .clk(clk),
  .rst_n(rst_n),
  .ipv_in(reducer_ipv_in),
  .vov(vov)
);

AAC aac_l(
  .clk(clk), 
  .reset_n(rst_n), 
  .aac(aac_valid_l), 
  .A_i({10{alu_l4_in[18*4-1]},alu_l4_in[18*4-1:18*4-18]}), 
  .out(AAC_L)
);
AAC aac_r(
  .clk(clk), 
  .reset_n(rst_n), 
  .aac(aac_valid_r), 
  .A_i({10{L4_in[18*4-55]},L4_in[18*4-55:0]}), 
  .out(AAC_R)
);

///////////////////////////////////////////
/////          combinational          /////
///////////////////////////////////////////

// state logic
always @(*) begin
  case(state)
    IDLE   : next_state = val_in ? VEC_IN : IDLE;
    VEC_IN : begin
      if (vec_count == cols-1) next_state = MAT_IN;
      else next_state = VEC_IN;
    end
    MAT_IN : next_state = val_in ? MAT_IN : CAL;
    CAL    : next_state = CAL;  // FIXME
    OUT    : next_state = IDLE; // FIXME
    default: next_state = IDLE; 
  endcase
end

// input logic
integer j;
always @(*) begin
  next_rows = rows;
  next_cols = cols;
  next_input_count = input_count;
  next_vec_count = vec_count;
  for (j = 0; j < 128; j=j+1) begin
    next_vec[j] = vec[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_val[j] = val[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_ipv[j] = ipv[j];
  end
  case(state)
    IDLE: begin
      if (val_in) begin
        next_rows = val_in;
        next_cols = col_in;
      end
      else begin
        next_rows = 0;
        next_rows = 0;
      end
    end
    VEC_IN: begin
      // state
      if (vec_count == cols-1) next_vec_count = 0;
      else next_vec_count = vec_count + 1;

      // value
      next_vec[vec_count] = data_in;
    end
    MAT_IN: begin
      // state
      if (val_in) begin
        if (input_count == k-1) begin
          next_input_count = 0;
        end
        else begin
          next_input_count = input_count + 1;
        end
      end
      else begin
        next_input_count = 0;
      end

      // value
      if (val_in) begin
        next_val[input_count] = val_in;
        next_col[input_count] = col_in;
        next_ipv[input_count] = ipv_in;
      end
    end
    // CAL, OUT no input
  endcase
end

// ALU L1 input logic
integer l;
always @(*) begin
  if (input_count == k-1) begin
    for (l = 0; l < k; l=l+1) begin
      alu_mat_in[8*(k-l)-1:8*(k-l+1)] = val[l];
      alu_vec_in[8*(k-l)-1:8*(k-l+1)] = vec[col[l]];
    end
  end
  else begin
    alu_mat_in = (8*k-1)'d0;
    alu_vec_in = (8*k-1)'d0;
  end
end

// IPV reducer input logic
always @(*) begin
  if (state == MAT_IN) begin
    reducer_ipv_in = ipv_in;
  end
  else begin
    reducer_ipv_in = 0;
  end
end


///////////////////////////////////////////
/////           sequential            /////
///////////////////////////////////////////
integer i;
always@ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    rows <= 0;
    cols <= 0;
    input_count <= 0;
    vec_count <= 0;
    for (i = 0; i < 128; i=i+1) begin
      vec[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      val[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      col[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      ipv[i] <= 0;
    end
  end
  else begin
    state <= next_state;
    rows <= next_rows;
    cols <= next_cols;
    vec_count <= next_vec_count;
    input_count <= next_input_count;
    for (i = 0; i < 128; i=i+1) begin
      vec[i] <= next_vec[i];
    end
    for (i = 0; i < k; i=i+1) begin
      val[i] <= next_val[i];
    end
    for (i = 0; i < k; i=i+1) begin
      col[i] <= next_col[i];
    end
    for (i = 0; i < k; i=i+1) begin
      ipv[i] <= next_ipv[i];
    end
  end
end


endmodule
