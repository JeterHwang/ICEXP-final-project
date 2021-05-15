`include "../src/ALU_maple.v"
`include "../src/IPV_reducer.v"
module SMVM(
  input         clk,
  input         rst_n,
  input  [7:0]  val_in,
  // input  [2:0]  col_in,
  input         ipv_in,
  input         in_valid,
  output        out_valid,
  output [12:0] data_out
);

///////////////////////////////////////////
/////          parameter              /////
///////////////////////////////////////////
parameter k = 4;
parameter k_bit = 3;
parameter alu_stall_cycle = 4;
parameter max_shape = 512;
parameter max_shape_bit = 9;


// state
parameter IDLE   = 3'd0;    // no op/ input rows
parameter COL_IN = 3'd1;
parameter VEC_IN = 3'd2;    // input vector
parameter VAL_IN = 3'd3;    // input matrix value
parameter IDX_IN = 3'd4;    // input matrix column index
parameter CAL    = 3'd5;    // calculate
parameter RST    = 3'd6;    // reset for next operation

///////////////////////////////////////////
/////          reg & wire             /////
///////////////////////////////////////////

// inout
reg  [12:0] data_o;
reg         valid_o;
wire [8:0] col_idx_concat;
assign out_valid = valid_o;
assign data_out = data_o;


// FFs
reg [3:0] state, next_state;
reg [8:0] counter, next_counter; // VEC: counter for vector input, count to cols
                                 // VAL: counter for matrix input, count to k
                                 // CAL: counter for alu stall
reg [8:0] rows, next_rows;       // save shape
reg [8:0] cols, next_cols;       // save shape
reg [7:0] vec[0:max_shape-1], next_vec[0:max_shape-1]; // save vector
reg [7:0] mat_val[0:k-1], next_mat_val[0:k-1]; // k * value
reg [8:0] col_idx[0:k-1], next_col_idx[0:k-1]; // k * column index
reg       ipv[0:k-1], next_ipv[0:k-1];         // k * ipv

reg [12:0] output_buffer[0:2*k-2], next_output_buffer[0:2*k-2];
reg [3:0]  output_counter, next_output_counter;


// inter connect
// alu
wire            alu_l1_en ;
reg  [8*k-1:0]  alu_mat_in;
reg  [8*k-1:0]  alu_vec_in;
//wire [16*k-1:0] alu_l1_out;
//wire [32*k-1:0] alu_l2_in ;
//wire [17*6-1:0] alu_l2_out;
//wire [17*6-1:0] alu_l3_in ;
//wire [18*5-1:0] alu_l3_out;
//wire [18*4-1:0] alu_l4_in ;
wire [26*4-1:0] alu_l4_out;
wire            alu_out_valid;

// Map_table
wire [3:0] IPV_l1_in ;
//wire [3:0] IPV_l1_out;
//wire [3:0] IPV_l2_out;
//wire [3:0] IPV_l3_out;
  
// reducer
reg           reducer_ipv_in;
reg           reducer_in_valid;
wire [3:0]    vov;

// alu l4 output connection
reg  [25:0]   alu_out[0:k-1];

///////////////////////////////////////////
/////           submodule             /////
///////////////////////////////////////////
/*
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
  .IPV(IPV_l1_in),
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
  .clk(clk),
  .rst(rst_n),
  .ones(vov),
  .IPV_in(IPV_l3_out),
  .L4_in(alu_l4_in),
  .L4_out(alu_l4_out),
  .en(alu_l1_en),
  .out_valid(alu_out_valid)
);
*/
ALU_Maple4(
  .clk(clk),
  .rst(rst_n),
  .IPV_l1_in(IPV_l1_in),
  .alu_mat_in(alu_mat_in),
  .alu_vec_in(alu_vec_in),
  .vov(vov),
  .alu_l4_out(alu_l4_out),
  .alu_out_valid(alu_out_valid)
);  

IPV_reducer reducer(
  .clk(clk),
  .rst_n(rst_n),
  .ipv_in(reducer_ipv_in),
  .in_valid(reducer_in_valid),
  .vov(vov)
);


///////////////////////////////////////////
/////          combinational          /////
///////////////////////////////////////////

// next state logic
always @(*) begin
  case(state)
    IDLE   : next_state = in_valid ? COL_IN : IDLE;
    COL_IN : next_state = VEC_IN;
    VEC_IN : begin
      if (counter == cols-1) next_state = VAL_IN;
      else next_state = VEC_IN;
    end
    VAL_IN : next_state = in_valid ? IDX_IN : CAL;
    IDX_IN : next_state = VAL_IN;
    CAL    : begin
      if (counter == alu_stall_cycle) next_state = RST;
      else next_state = CAL;
    end
    RST    : next_state = IDLE; // FIXME
    default: next_state = IDLE; 
  endcase
end


// input logic
assign col_idx_concat = { val_in, ipv_in };
integer j;
always @(*) begin
  next_rows = rows;
  next_cols = cols;
  next_counter = counter;
  for (j = 0; j < max_shape; j=j+1) begin
    next_vec[j] = vec[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_mat_val[j] = mat_val[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_col_idx[j] = col_idx[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_ipv[j] = ipv[j];
  end
  case(state)
    IDLE: begin
      if (in_valid) begin
        next_rows = col_idx_concat;
      end
      else begin
        next_rows = 0;
      end
    end
    COL_IN: begin
      next_cols = col_idx_concat;
    end
    VEC_IN: begin
      if (counter == cols-1) next_counter = 0;
      else next_counter = counter + 1;
      next_vec[counter] = val_in;
    end
    VAL_IN: begin
      if (in_valid) begin
        next_mat_val[counter] = val_in;
        next_ipv[counter] = ipv_in;
      end
      else begin
        counter = 0;
      end
    end
    IDX_IN: begin
      if (counter == k-1) next_counter = 0;
      else next_counter = counter + 1;
      next_col_idx[counter] = col_idx_concat;
    end
    CAL: begin
      if (counter == alu_stall_cycle) next_counter = 0;
      else next_counter = counter + 1;
    end
    RST: begin
      next_rows = 0;
      next_cols = 0;
      next_counter = 0;
      for (j = 0; j < max_shape; j=j+1) begin
        next_vec[j] = 0;
      end
      for (j = 0; j < k; j=j+1) begin
        next_mat_val[j] = 0;
      end
      for (j = 0; j < k; j=j+1) begin
        next_col_idx[j] = 0;
      end
      for (j = 0; j < k; j=j+1) begin
        next_ipv[j] = 0;
      end
    end
  endcase
end

// IPV reducer input logic
always @(*) begin
  if (state == VAL_IN) begin
    reducer_ipv_in = ipv_in;
    reducer_in_valid = 1'b1;
  end
  else begin
    reducer_ipv_in = 0;
    reducer_in_valid = 1'b0;
  end
end

// ALU L1 input logic
assign IPV_l1_in = (counter == k-1 && state == IDX_IN) ? 
                   { ipv[0], ipv[1], ipv[2], ipv[3] } :
                   { (k){1'b0} };
integer l;
always @(*) begin
  if (counter == k-1 && state == IDX_IN) begin
    for (l = 0; l < k-1; l=l+1) begin
      alu_mat_in[8*(k-l)-1 -: 8] = mat_val[l];
      alu_vec_in[8*(k-l)-1 -: 8] = vec[col_idx[l]];
    end
    alu_mat_in[7:0] = mat_val[k-1];
    alu_vec_in[7:0] = vec[col_idx_concat];
  end
  else begin
    alu_mat_in = {(8*k-1){1'b0}};
    alu_vec_in = {(8*k-1){1'b0}};
  end
end

// ALU L4 output logic
integer n;
always @(*) begin
  for (n = 0; n < k; n=n+1) begin
    alu_out[n] = alu_l4_out[26*(4-n)-1 -: 26];
  end
  if (alu_out_valid) begin
    for (n = 0; n < k-1; n=n+1) begin
      next_output_buffer[2*n]   = alu_out[n][13: 0];
      next_output_buffer[2*n+1] = alu_out[n+1][27:14];
    end
    next_output_buffer[2*k-2] = alu_out[k-1][13:0];
  end
  else begin
    next_output_buffer[2*k-2] = 0;
    for (n = 0; n < 2*k-2; n=n+1) begin
      next_output_buffer[n] = output_buffer[n+1];
    end
  end
end


// output logic
always @(*) begin
  next_output_counter = output_counter;
  if (alu_out_valid) begin
    if (vov > 0) begin
      next_output_counter = vov*2-1;
      valid_o = 1'b1;
      data_o = alu_out[0][26:13];
    end
    else begin
      next_output_counter = 0;
      valid_o = 1'b0;
      data_o = 0;
    end
  end
  else begin
    if (output_counter > 0) begin
      valid_o = 1'b1;
      next_output_counter = output_counter - 1;
      data_o = output_buffer[0];
    end
    else begin
      valid_o = 1'b0;
      next_output_counter = 0;
      data_o = 0;
    end
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
    counter <= 0;
    output_counter <= 0;
    for (i = 0; i < max_shape; i=i+1) begin
      vec[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      mat_val[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      col_idx[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      ipv[i] <= 0;
    end

    for (i = 0; i < 2*k; i=i+1) begin
      output_buffer[i] <= 0;
    end
  end
  else begin
    state <= next_state;
    rows <= next_rows;
    cols <= next_cols;
    counter <= next_counter;
    output_counter <= next_output_counter;
    for (i = 0; i < max_shape; i=i+1) begin
      vec[i] <= next_vec[i];
    end
    for (i = 0; i < k; i=i+1) begin
      mat_val[i] <= next_mat_val[i];
    end
    for (i = 0; i < k; i=i+1) begin
      col_idx[i] <= next_col_idx[i];
    end
    for (i = 0; i < k; i=i+1) begin
      ipv[i] <= next_ipv[i];
    end

    for (i = 0; i < 2*k; i=i+1) begin
      output_buffer[i] <= next_output_buffer[i];
    end
  end
end


endmodule
