module PE #(
				parameter DATA_WIDTH=8,
				parameter OUT_DATA_WIDTH=32
			)
			(
				input clk,
				input reset,
				input first_data,
				input signed [DATA_WIDTH-1: 0] k,
				input signed [DATA_WIDTH-1: 0] in,
				output signed [OUT_DATA_WIDTH - 1:0] sum 
			);
	
	reg signed [OUT_DATA_WIDTH - 1:0] partial_sum;
	
	always @(posedge clk) begin
		if(reset)
			partial_sum <= 0;
		else if(first_data)
			partial_sum <= k * in;
		else
			partial_sum <= partial_sum + (k * in);
	end

	assign sum = partial_sum; 
	
endmodule