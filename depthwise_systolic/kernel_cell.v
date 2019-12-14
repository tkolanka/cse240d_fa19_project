`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 12:01:38 PM
// Design Name: 
// Module Name: kcell
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
// modularize code if possible later

module kcell #(
        parameter DATA_WIDTH = 8,
        parameter OUT_DATA_WIDTH = 32,
        parameter DIMX = 3,
        parameter DIMY = 3,
        parameter NUM_CELLS = DIMX * DIMY
    )(
        input clk,
        input reset,
        input [DIMY*DATA_WIDTH - 1: 0] act_data,
        input [NUM_CELLS*DATA_WIDTH - 1: 0] wgt_data,
        input [NUM_CELLS - 1: 0] wgt_load_gbl,
        input [OUT_DATA_WIDTH - 1: 0] result_in,
        output [OUT_DATA_WIDTH - 1: 0] result,
        output [DIMY*DATA_WIDTH - 1: 0] act_out
    );
    
    wire [DATA_WIDTH - 1: 0] act_in_0, act_in_1, act_in_2;
    assign act_in_0 = act_data[3*DATA_WIDTH -1: 2*DATA_WIDTH];
    assign act_in_1 = act_data[2*DATA_WIDTH -1: 1*DATA_WIDTH];
    assign act_in_2 = act_data[1*DATA_WIDTH -1: 0*DATA_WIDTH];
    
    wire [DATA_WIDTH - 1: 0] wgt_data_00, wgt_data_01, wgt_data_02;
    wire [DATA_WIDTH - 1: 0] wgt_data_10, wgt_data_11, wgt_data_12;
    wire [DATA_WIDTH - 1: 0] wgt_data_20, wgt_data_21, wgt_data_22;
    
    assign wgt_data_00 = wgt_data[9*DATA_WIDTH -1: 8*DATA_WIDTH];
    assign wgt_data_01 = wgt_data[8*DATA_WIDTH -1: 7*DATA_WIDTH];
    assign wgt_data_02 = wgt_data[7*DATA_WIDTH -1: 6*DATA_WIDTH];
    
    assign wgt_data_10 = wgt_data[6*DATA_WIDTH -1: 5*DATA_WIDTH];
    assign wgt_data_11 = wgt_data[5*DATA_WIDTH -1: 4*DATA_WIDTH];
    assign wgt_data_12 = wgt_data[4*DATA_WIDTH -1: 3*DATA_WIDTH];
    
    assign wgt_data_20 = wgt_data[3*DATA_WIDTH -1: 2*DATA_WIDTH];
    assign wgt_data_21 = wgt_data[2*DATA_WIDTH -1: 1*DATA_WIDTH];
    assign wgt_data_22 = wgt_data[1*DATA_WIDTH -1: 0*DATA_WIDTH];
    
    wire [OUT_DATA_WIDTH - 1: 0] macc_out_00, macc_out_01, macc_out_02;
    wire [OUT_DATA_WIDTH - 1: 0] macc_out_10, macc_out_11, macc_out_12;
    wire [OUT_DATA_WIDTH - 1: 0] macc_out_20, macc_out_21, macc_out_22;
    
    wire [DATA_WIDTH - 1: 0] act_out_00, act_out_01, act_out_02;
    wire [DATA_WIDTH - 1: 0] act_out_10, act_out_11, act_out_12;
    wire [DATA_WIDTH - 1: 0] act_out_20, act_out_21, act_out_22;
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_00 (
        .clk(clk),
        .reset(reset),
        .act(act_in_0),
        .wgt_load(wgt_load_gbl[0]),
        .wgt_data(wgt_data_00),
        .macc_in(0),
        .macc_out(macc_out_00),
        .act_out(act_out_00)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_01 (
        .clk(clk),
        .reset(reset),
        .act(act_out_00),
        .wgt_load(wgt_load_gbl[1]),
        .wgt_data(wgt_data_01),
        .macc_in(macc_out_00),
        .macc_out(macc_out_01),
        .act_out(act_out_01)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_02 (
        .clk(clk),
        .reset(reset),
        .act(act_out_01),
        .wgt_load(wgt_load_gbl[2]),
        .wgt_data(wgt_data_02),
        .macc_in(macc_out_01),
        .macc_out(macc_out_02),
        .act_out(act_out_02)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_10 (
        .clk(clk),
        .reset(reset),
        .act(act_in_1),
        .wgt_load(wgt_load_gbl[3]),
        .wgt_data(wgt_data_10),
        .macc_in(0),
        .macc_out(macc_out_10),
        .act_out(act_out_10)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_11 (
        .clk(clk),
        .reset(reset),
        .act(act_out_10),
        .wgt_load(wgt_load_gbl[4]),
        .wgt_data(wgt_data_11),
        .macc_in(macc_out_10),
        .macc_out(macc_out_11),
        .act_out(act_out_11)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_12 (
        .clk(clk),
        .reset(reset),
        .act(act_out_11),
        .wgt_load(wgt_load_gbl[5]),
        .wgt_data(wgt_data_12),
        .macc_in(macc_out_11),
        .macc_out(macc_out_12),
        .act_out(act_out_12)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_20 (
        .clk(clk),
        .reset(reset),
        .act(act_in_2),
        .wgt_load(wgt_load_gbl[6]),
        .wgt_data(wgt_data_20),
        .macc_in(0),
        .macc_out(macc_out_20),
        .act_out(act_out_20)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_21 (
        .clk(clk),
        .reset(reset),
        .act(act_out_20),
        .wgt_load(wgt_load_gbl[7]),
        .wgt_data(wgt_data_21),
        .macc_in(macc_out_20),
        .macc_out(macc_out_21),
        .act_out(act_out_21)
    );
    
    bcell #(DATA_WIDTH, OUT_DATA_WIDTH) cell_22 (
        .clk(clk),
        .reset(reset),
        .act(act_out_21),
        .wgt_load(wgt_load_gbl[8]),
        .wgt_data(wgt_data_22),
        .macc_in(macc_out_21),
        .macc_out(macc_out_22),
        .act_out(act_out_22)
    );
    
    assign act_out = {act_out_00, act_out_11, act_out_22};
    
    assign result = result_in + macc_out_22 + macc_out_11 + macc_out_00;
    
endmodule