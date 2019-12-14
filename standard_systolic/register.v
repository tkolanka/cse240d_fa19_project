`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:17:34 PM
// Design Name: 
// Module Name: register
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

module register #(
	parameter	BIT_WIDTH = 32
)(
    input                         clk,
    input                         reset,
    input                         wrt_en,
    input   [BIT_WIDTH -1 : 0]    data_in,
    output  [BIT_WIDTH -1 : 0]    data_out
);

    reg  [BIT_WIDTH -1 : 0] out;

    always @ (posedge clk) begin
      if (reset == 1'b1)
          out <= 0;
      else if (wrt_en == 1'b1)
          out <= data_in;
      else 
          out <= out;
    end

    assign data_out = out;

endmodule

// parameters:
// Bitwidth of the register