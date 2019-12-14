module SIMD_execution #(parameter NUM_PE=16,
						parameter DATA_WIDTH=8,
						parameter OUT_DATA_WIDTH=32
						)
						(
						input clk,
						input reset,
						input first_data,
						//flattened arrays
						input [NUM_PE*DATA_WIDTH - 1:0] Kernel,
						input [NUM_PE*DATA_WIDTH - 1:0] Input_Act,
						output [NUM_PE*OUT_DATA_WIDTH - 1:0] Result
	);

    reg [NUM_PE*DATA_WIDTH - 1:0] Kernel_internal;
    reg [NUM_PE*DATA_WIDTH - 1:0] Input_Act_internal;
    reg [NUM_PE*OUT_DATA_WIDTH - 1:0] Result_internal;

	genvar i;
	generate
		for (i=0; i<16; i=i+1) begin : pe_generate
			PE #(DATA_WIDTH, OUT_DATA_WIDTH) processing_element (
				.clk(clk),
				.reset(reset),
				.first_data(first_data),
				.k(Kernel[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH]),
				.in(Input_Act[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH]),
				.sum(Result[(i+1)*OUT_DATA_WIDTH-1: i*OUT_DATA_WIDTH])
			);
		end
	endgenerate

endmodule