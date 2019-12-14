`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 11:48:10 AM
// Design Name: 
// Module Name: cell
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


module bcell #(
        parameter DATA_WIDTH = 8,
        parameter OUT_DATA_WIDTH = 32
    )(
        input clk,
        input reset,
        input signed [DATA_WIDTH - 1: 0] act,
        input wgt_load,
        input signed [DATA_WIDTH - 1: 0] wgt_data,
        input signed [OUT_DATA_WIDTH - 1: 0] macc_in,
        output [OUT_DATA_WIDTH - 1: 0] macc_out,
        output reg signed [DATA_WIDTH - 1: 0] act_out
    );
    
    reg signed [OUT_DATA_WIDTH - 1: 0] out;
    reg signed [DATA_WIDTH - 1: 0] act_prev;
    reg signed [DATA_WIDTH - 1: 0] wgt;
    
    always @ (posedge clk) begin
        if(reset) begin
            out <= 0;
            act_prev <= 0;
            wgt <= 0;
            act_out <= 0;
        end
        else if(wgt_load) begin
            wgt <= wgt_data;
            out <= out;
            act_prev <= act_prev;
            act_out <= act_out;
        end
        else begin
            out <= macc_in + act * wgt;
            act_out <= act_prev;
            act_prev <= act; 
            wgt <= wgt;
        end
    end
    
    assign macc_out = out;
    
endmodule