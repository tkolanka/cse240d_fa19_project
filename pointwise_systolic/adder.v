`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:17:34 PM
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module adder #(
	parameter						IN1_BITWIDTH						= 32,
	parameter						IN2_BITWIDTH						= 32,
	parameter						OUT_BITWIDTH						= 32
)(
	input																adder_en,
	input							[IN1_BITWIDTH		-1: 0]			in_1,
	input							[IN2_BITWIDTH		-1: 0]			in_2,
	output							[OUT_BITWIDTH       -1: 0]			out
);
	
	wire		signed				[IN1_BITWIDTH		-1: 0]			_in_1;
	wire		signed				[IN2_BITWIDTH		-1: 0]			_in_2;
	reg			signed				[OUT_BITWIDTH       -1: 0]			_res;
	
	assign							_in_1 				=				in_1;
	assign							_in_2 				= 				in_2;

	always @ (*) begin
		if (adder_en == 1)
			_res 											=				_in_1 + _in_2;
	end
	assign 							out 				= 				 _res;
		
endmodule