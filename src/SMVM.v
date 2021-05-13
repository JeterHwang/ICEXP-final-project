`include "../src/ALU_maple.v"
`include "../src/IPV_reducer.v"
module SMVM(
  input         clk,
  input         rst_n,
  input  [7:0]  val_in,
  input  [2:0]  col_in,
  input         ipv_in,
  input         in_valid,
  output        out_valid,
  output [13:0] data_out
);

///////////////////////////////////////////
/////          parameter              /////
///////////////////////////////////////////
parameter k = 4;
parameter alu_stall_cycle = 4;


// state
parameter IDLE   = 3'b000;    // no op/ input rows
parameter COL_IN = 3'b001;
parameter VEC_IN = 3'b010;    // input vector
parameter VAL_IN = 3'b011;    // input matrix value
parameter IDX_IN = 3'b100;    // input matrix column index
parameter CAL    = 3'b101;    // calculate
parameter OUT    = 3'b110;    // output

///////////////////////////////////////////
/////          reg & wire             /////
///////////////////////////////////////////

// inout
reg  [13:0] data_o;
reg         valid_o;
wire [11:0] col_idx;
assign out_valid = valid_o;
assign data_out = data_o;


// FFs
reg        [3:0] state, next_state;
reg        [7:0] counter, next_counter; // counter for vector input / CAL state
reg        [2:0] alu_in_counter, next_alu_in_counter; // count to k and send to ALU
reg        [7:0] rows, next_rows;
reg        [7:0] cols, next_cols;
reg signed [7:0] vec[0:127], next_vec[0:127]; // save vector
reg signed [7:0] val[0:k-1], next_val[0:k-1]; // k * value
reg        [7:0] col[0:k-1], next_col[0:k-1]; // k * column index
reg              ipv[0:k-1], next_ipv[0:k-1]; // k * ipv



// inter connect
// alu
wire            alu_l1_en ;
reg  [8*k-1:0]  alu_mat_in;
reg  [8*k-1:0]  alu_vec_in;
wire [16*k-1:0] alu_l1_out;
wire [32*k-1:0] alu_l2_in ;
wire [17*6-1:0] alu_l2_out;
wire [17*6-1:0] alu_l3_in ;
wire [18*5-1:0] alu_l3_out;
wire [18*4-1:0] alu_l4_in ;
wire [28*4-1:0] alu_l4_out;
wire            alu_out_valid;

// Map_table
wire [3:0] IPV_l1_in ;
wire [3:0] IPV_l1_out;
wire [3:0] IPV_l2_out;
wire [3:0] IPV_l3_out;

// AAC
wire        aac_valid_l,aac_valid_r;
wire [27:0] AAC_L,AAC_R;
  
// reducer
reg  [k-1:0]   reducer_ipv_in;
reg            reducer_in_valid;
wire [3:0]     vov;

// output
// buffer
reg  [27:0]   alu_out[0:k-1];
reg  [13:0]   output_buffer[0:2*k-1], next_output_buffer[0:2*k-1];
reg  [3:0]    output_count, next_output_count;

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
  .AAC_L(AAC_L),
  .AAC_R(AAC_R),
  .L4_in(alu_l4_in),
  .L4_out(alu_l4_out),
  .en(alu_l1_en),
  .out_valid(alu_out_valid)
);
  
  
  
// IPV_encoder encoder();
IPV_reducer reducer(
  .clk(clk),
  .rst_n(rst_n),
  .ipv_in(reducer_ipv_in),
  .in_valid(reducer_in_valid),
  .vov(vov)
);

AAC aac_l(
  .clk(clk), 
  .reset_n(rst_n), 
  .aac(aac_valid_l), 
  .A_i({{10{alu_l4_in[18*4-1]}}, alu_l4_in[18*4-1:18*4-18]}), 
  .out(AAC_L)
);
AAC aac_r(
  .clk(clk), 
  .reset_n(rst_n), 
  .aac(aac_valid_r), 
  .A_i({{10{alu_l4_in[18*4-55]}},alu_l4_in[18*4-55:0]}), 
  .out(AAC_R)
);

///////////////////////////////////////////
/////          combinational          /////
///////////////////////////////////////////

// state logic
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
      if (counter == alu_stall_cycle) next_state = OUT;
      else next_state = CAL;
    end
    OUT    : next_state = IDLE; // FIXME
    default: next_state = IDLE; 
  endcase
end


// input logic
assign col_idx = { val_in, ipv_in, col_in };
integer j;
always @(*) begin
  next_rows = rows;
  next_cols = cols;
  next_counter = counter;
  next_alu_in_counter = alu_in_counter;
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
      if (in_valid) begin
        next_rows = col_idx;
      end
      else begin
        next_rows = 0;
        next_rows = 0;
      end
    end
    COL_IN: begin
      next_cols = col_idx;
    end
    VEC_IN: begin
      // state
      if (counter == cols-1) next_counter = 0;
      else next_counter = counter + 1;

      // value
      next_vec[counter] = val_in;
    end
    VAL_IN: begin
      if (in_valid) begin
        next_val[alu_in_counter] = val_in;
        next_ipv[alu_in_counter] = ipv_in;
      end
      else begin
        next_alu_in_counter = 0;
      end
    end
    IDX_IN: begin
      if (alu_in_counter == k-1) begin
        next_alu_in_counter = 0;
      end
      else begin
        next_alu_in_counter = alu_in_counter + 1;
      end
      next_col[alu_in_counter] = col_idx;
    end
    CAL: begin
      if (counter == alu_stall_cycle) begin
        next_counter = 0;
      end
      else begin
        next_counter = counter + 1;
      end
    end
    // CAL, OUT no input
  endcase
end

// ALU L1 input logic
assign IPV_l1_in = (alu_in_counter == k-1) ? {ipv[0], ipv[1], ipv[2], ipv[3]} : 0;
integer l;
always @(*) begin
  if (alu_in_counter == k-1 && state == IDX_IN) begin
    for (l = 0; l < k; l=l+1) begin
      alu_mat_in[8*(k-l)-1 -: 8] = val[l];
      alu_vec_in[8*(k-l)-1 -: 8] = vec[col[l]];
    end
  end
  else begin
    alu_mat_in = {(8*k-1){1'b0}};
    alu_vec_in = {(8*k-1){1'b0}};
  end
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

// alu output buffer
integer n;
always @(*) begin
  for (n = 0; n < k; n=n+1) begin
    alu_out[n] = alu_l4_out[28*(4-n)-1 -:28];
  end
  if (alu_out_valid) begin
    for (n = 0; n < k; n=n+1) begin
      next_output_buffer[2*n]   = alu_out[n][27:14];
      next_output_buffer[2*n+1] = alu_out[n][13: 0];
    end
  end
  else begin
    next_output_buffer[2*k-1] = 0;
    for (n = 0; n < 2*k-1; n=n+1) begin
      next_output_buffer[n] = output_buffer[n+1];
    end
  end
end

// output logic
always @(*) begin
  next_output_count = output_count;
  if (alu_out_valid) begin
    if (vov > 0) begin
      next_output_count = vov*2-1;
      valid_o = 1'b1;
      data_o = alu_out[0][27:14];
    end
    else begin
      next_output_count = 0;
      valid_o = 1'b0;
      data_o = 0;
    end
  end
  else begin
    if (output_count > 0) begin
      valid_o = 1'b1;
      next_output_count = output_count - 1;
      data_o = output_buffer[0];
    end
    else begin
      valid_o = 1'b0;
      next_output_count = 0;
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
    alu_in_counter <= 0;
    output_count <= 0;
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

    for (i = 0; i < 2*k; i=i+1) begin
      output_buffer[i] <= 0;
    end
  end
  else begin
    state <= next_state;
    rows <= next_rows;
    cols <= next_cols;
    counter <= next_counter;
    alu_in_counter <= next_alu_in_counter;
    output_count <= next_output_count;
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

    for (i = 0; i < 2*k; i=i+1) begin
      output_buffer[i] <= next_output_buffer[i];
    end
  end
end


endmodule
