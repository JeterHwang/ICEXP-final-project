module IPV_reducer #(parameter k = 4)(
  input  clk,
  input  rst_n,
  input  ipv_in,
  input  in_valid,
  output [k-1:0] vov
);

///////////////////////////////////////////
/////          parameter              /////
///////////////////////////////////////////

parameter stall_cycle = 2;

///////////////////////////////////////////
/////          reg & wire             /////
///////////////////////////////////////////

reg [2:0] counter, next_counter; // for k max = 8
reg [k-1:0] ipv, next_ipv;
reg [k-1:0] ipv_stall[0:stall_cycle-1], next_ipv_stall[0:stall_cycle-1];

///////////////////////////////////////////
/////          combinational          /////
///////////////////////////////////////////

assign vov = ipv_stall[stall_cycle-1];

// input & state logic
always @(*) begin
  
  if (in_valid) begin
    if (counter == k-1) begin
    next_counter = 3'd0;
    end
    else begin
      next_counter = counter + 1;
    end

    if (counter == 0) begin
      next_ipv[k-2:0] = 0;
      next_ipv[k-1] = ipv_in;
    end
    else begin
      if (ipv_in) begin
        next_ipv = {1'b1, ipv[k-1:1]};
      end
      else begin
        next_ipv = ipv;
      end
    end
  end
  else begin
    next_counter = counter;
    next_ipv = ipv;
  end
  
end

// stall logic
integer i;
always @(*) begin
  for(i = 1; i < stall_cycle; i=i+1) begin
    next_ipv_stall[i] = ipv_stall[i-1];
  end
  if (counter == 0) begin
    next_ipv_stall[0] = ipv;
  end
  else begin
    next_ipv_stall[0] = 0;
  end
end

///////////////////////////////////////////
/////           sequential            /////
///////////////////////////////////////////
integer j;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter <= 0;
    for(j = 0; j < stall_cycle; j=j+1) begin
      ipv_stall[j] <= 0;
    end
    ipv <= 0;
  end
  else begin
    counter <= next_counter;
    for(j = 0; j < stall_cycle; j=j+1) begin
      ipv_stall[j] <= next_ipv_stall[j];
    end
    ipv <= next_ipv;
  end
end

endmodule
