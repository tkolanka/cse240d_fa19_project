`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:17:34 PM
// Design Name: 
// Module Name: accumulator
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

module accumulator #(

	parameter				 IN_SUM_BITWIDTH					 = 32,
	parameter				 ACC_DATA_BITWIDTH					 = 32

)(
	input														clk,
	input														reset,
	input														wrt_en,
	input														acc_logic,
	input					[IN_SUM_BITWIDTH   - 	1 : 0]		part_sum_in,
	
	output					[ACC_DATA_BITWIDTH - 	1 : 0]		part_sum_out
);
		
	wire		signed		[IN_SUM_BITWIDTH   - 	1 : 0]		_in_opnd;
	reg			signed		[ACC_DATA_BITWIDTH - 	1 : 0]		temp;
	
	assign 		_in_opnd = part_sum_in;
	
	always @ (posedge clk) begin
     	if (reset == 1)
        	temp <= 0;
      	if (wrt_en == 1 && acc_logic == 1)
          	temp <= temp + _in_opnd;
      	if (wrt_en == 1 && acc_logic == 0)
	      	temp <= _in_opnd;
    end

    assign part_sum_out = temp;
	
endmodule