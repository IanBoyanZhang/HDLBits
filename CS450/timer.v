module top_module(
  input clk,
  input load,
  input [9:0] data,
  output tc
);
  reg [9:0] data_;

  always @(posedge clk) begin
    if (load) begin
      data_ <= data;
    end else if (data_ != 10'b0)begin
      data_ <= data_ - 10'b1;
    end
  end

  assign tc = data_== 10'b0;
endmodule
