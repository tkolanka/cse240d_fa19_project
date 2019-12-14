`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 12:56:48 PM
// Design Name: 
// Module Name: dw_systolic
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

module dw_systolic #(
        parameter DATA_WIDTH = 8,
        parameter OUT_DATA_WIDTH = 32,
        parameter NUM_KCELLS = 3,
        parameter DIMX = 3,
        parameter DIMY = 3,
        parameter NUM_CELLS = DIMX * DIMY,
        parameter NUM_IN = DIMY + (NUM_KCELLS - 1)
    )(
        input clk,
        input reset,
        input [NUM_IN*DATA_WIDTH - 1: 0] act_data,
        input [NUM_CELLS*DATA_WIDTH - 1: 0] wgt_data,
        input [NUM_CELLS - 1: 0] wgt_load_gbl,
        input [NUM_KCELLS*OUT_DATA_WIDTH - 1: 0] result_in,
        output [NUM_KCELLS*OUT_DATA_WIDTH - 1: 0] result
    );
    
    wire [DIMY*DATA_WIDTH - 1: 0] act_out_0, act_out_1, act_out_2;
    wire [DIMY*DATA_WIDTH - 1: 0] act_in_0, act_in_1, act_in_2;
    
    assign act_in_0 = act_data[5*DATA_WIDTH - 1: 2*DATA_WIDTH];
    assign act_in_1 = {act_out_0[2*DATA_WIDTH - 1: 0*DATA_WIDTH], act_data[2*DATA_WIDTH - 1: 1*DATA_WIDTH]};
    assign act_in_2 = {act_out_1[2*DATA_WIDTH - 1: 0*DATA_WIDTH], act_data[1*DATA_WIDTH - 1: 0*DATA_WIDTH]};
    
    wire [OUT_DATA_WIDTH - 1: 0] result_0, result_1, result_2;
    wire [OUT_DATA_WIDTH - 1: 0] result_in_0, result_in_1, result_in_2;
    
    assign result_in_0 = result_in[3*DATA_WIDTH - 1: 2*DATA_WIDTH];
    assign result_in_1 = result_in[2*DATA_WIDTH - 1: 1*DATA_WIDTH];
    assign result_in_2 = result_in[1*DATA_WIDTH - 1: 0*DATA_WIDTH];
    
    kcell #(DATA_WIDTH, OUT_DATA_WIDTH, DIMX, DIMY, NUM_CELLS) kcell_0 (
        .clk(clk),
        .reset(reset),
        .act_data(act_in_0),
        .wgt_data(wgt_data),
        .wgt_load_gbl(wgt_load_gbl),
        .result_in(result_in_0),
        .result(result_0),
        .act_out(act_out_0)
    );
    
    kcell #(DATA_WIDTH, OUT_DATA_WIDTH, DIMX, DIMY, NUM_CELLS) kcell_1 (
        .clk(clk),
        .reset(reset),
        .act_data(act_in_1),
        .wgt_data(wgt_data),
        .wgt_load_gbl(wgt_load_gbl),
        .result_in(result_in_1),
        .result(result_1),
        .act_out(act_out_1)
    );
        
    kcell #(DATA_WIDTH, OUT_DATA_WIDTH, DIMX, DIMY, NUM_CELLS) kcell_2 (
        .clk(clk),
        .reset(reset),
        .act_data(act_in_2),
        .wgt_data(wgt_data),
        .wgt_load_gbl(wgt_load_gbl),
        .result_in(result_in_2),
        .result(result_2),
        .act_out(act_out_2)
    );
    
    assign result = {result_0, result_1, result_2};
    
endmodule