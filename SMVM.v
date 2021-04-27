module SMVM(
  input  clk,
  input  rst_n,
  input  [7:0] data_in,
  input  in_valid;
  output out_valid,
  output [14:0] data_out,
);
///////////////////////////////////////////
/////          parameter              /////
///////////////////////////////////////////
parameter k = 4;

// state
parameter IDLE   = 3'b000;    // no op/ input rows
parameter COL_IN = 3'b001;    // input cols
parameter VEC_IN = 3'b010;    // input vector
parameter VAL_IN = 3'b011;    // input value
parameter IDX_IN = 3'b100;    // input col index
parameter IPV_IN = 3'b101;    // input ipv
parameter CAL    = 3'b110;    // calculate
parameter OUT    = 3'b111;    // output

///////////////////////////////////////////
/////          reg & wire             /////
///////////////////////////////////////////

// FFs
reg        [3:0] state, next_state;
reg        [7:0] vec_count, next_vec_count; // count vector input
reg        [2:0] input_count, next_input_count; // count to k and start operation
reg        [7:0] rows, next_rows;
reg        [7:0] cols, next_cols;
reg signed [7:0] vector[0:127], next_vector[0:127];
reg signed [7:0] alu_in[0:k-1], next_alu_in[0:k-1];
reg        [7:0] col_id[0:k-1], next_col_id[0:k-1];
reg              ipv[0:k-1], next_ipv[0:k-1];

// inter connect
// reg signed [7:0] alu_l1_in;

///////////////////////////////////////////
/////           submodule             /////
///////////////////////////////////////////
Map_table_L1 map_l1();
Map_table_L2 map_l2();
Map_table_L3 map_l3();
Map_table_L4 map_l4();

ALU_L1 alu_l1();
ALU_L2 alu_l2();
ALU_L3 alu_l3();
ALU_L4 alu_l4();

IPV_encoder encoder();
IPV_reducer reducer();

AAC aac_l();
AAC aac_r();

///////////////////////////////////////////
/////          combinational          /////
///////////////////////////////////////////

// state logic
always @(*) begin
  case(state)
    IDLE   : next_state = in_valid ? COL_IN : IDLE;
    COL_IN : next_state = VAL_IN;
    VEC_IN : begin
      if (vec_count == rows-1) next_state = VAL_IN;
      else next_state = VEC_IN;
    end
    VAL_IN : next_state = in_valid ? IDX_IN : CAL;
    IDX_IN : next_state = IPV_IN;
    IPV_IN : next_state = VAL_IN;
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
    next_vector[j] = vector[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_alu_in[j] = alu_in[j];
  end
  for (j = 0; j < k; j=j+1) begin
    next_ipv[j] = ipv[j];
  end
  case(state)
    IDLE: begin
      if (in_valid) begin
        next_rows = data_in;
      end
      else begin
        next_rows = rows;
      end
    end
    COL_IN: begin
      next_cols = data_in;
    end
    VEC_IN: begin
      // state
      if (vec_count == rows-1) next_vec_count = 0;
      else next_vec_count = vec_count + 1;

      // value
      next_vector[vec_count] = data_in;
    end
    VAL_IN: begin
      // state
      if (in_valid) begin
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
      if (in_valid) begin
        next_alu_in[input_count] = data_in;
      end
    end
    IDX_IN: begin
      next_col_id[input_count] = data_in;
    end
    IPV_IN: begin
      next_ipv[input_count] = data_in[0];
    end
    // CAL, OUT no input
  endcase
end

// alu logic
always @(*) begin
  if ()
end


///////////////////////////////////////////
/////           sequential            /////
///////////////////////////////////////////
integer i;
always@ (posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    rows <= 0;
    cols <= 0;
    input_count <= 0;
    vec_count <= 0;
    for (i = 0; i < 128; i=i+1) begin
      vector[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      alu_in[i] <= 0;
    end
    for (i = 0; i < k; i=i+1) begin
      col_id[i] <= 0;
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
      vector[i] <= next_vector[i];
    end
    for (i = 0; i < k; i=i+1) begin
      alu_in[i] <= next_alu_in[i];
    end
    for (i = 0; i < k; i=i+1) begin
      col_id[i] <= next_col_id[i];
    end
    for (i = 0; i < k; i=i+1) begin
      ipv[i] <= next_ipv[i];
    end
  end
end


endmodule
