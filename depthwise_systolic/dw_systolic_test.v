`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 04:18:04 PM
// Design Name: 
// Module Name: dw_systolic_test
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


module dw_systolic_test();

    parameter DATA_WIDTH =8;
    parameter OUT_DATA_WIDTH = 32;
    parameter NUM_KCELLS = 3;
    parameter DIMX = 3;
    parameter DIMY = 3;
    parameter NUM_CELLS = DIMX * DIMY;
    parameter NUM_IN = DIMY + (NUM_KCELLS - 1);
    
    reg clk;
    reg reset;
    reg [NUM_IN*DATA_WIDTH - 1: 0] act_data;
    reg [NUM_CELLS*DATA_WIDTH - 1: 0] wgt_data;
    reg [NUM_CELLS - 1: 0] wgt_load_gbl;
    reg [NUM_KCELLS*OUT_DATA_WIDTH - 1: 0] result_in;
    wire [NUM_KCELLS*OUT_DATA_WIDTH - 1: 0] result;
    
    dw_systolic #(
        .DATA_WIDTH(DATA_WIDTH),
        .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
        .NUM_KCELLS(NUM_KCELLS),
        .DIMX(DIMX),
        .DIMY(DIMY),
        .NUM_CELLS(NUM_CELLS),
        .NUM_IN(NUM_IN)
    ) UUT(
        .clk(clk),
        .reset(reset),
        .act_data(act_data),
        .wgt_data(wgt_data),
        .wgt_load_gbl(wgt_load_gbl),
        .result_in(result_in),
        .result(result)
    );

    parameter CLK_PERIOD = 5;
    parameter ACT_READS = 4005;
    
    always
        #(CLK_PERIOD / 2)  clk   =   ~ clk;
        
    reg [NUM_IN*DATA_WIDTH - 1: 0] act_data_seq[0 : ACT_READS - 1];
    reg [NUM_CELLS*DATA_WIDTH - 1: 0] wgt_data_seq[0 : 0];
    reg done;
    
    initial begin
        $readmemb("weights_dw32_writed_systolic.mem", wgt_data_seq);
        $readmemb("activations_conv1_pad_systolic.mem", act_data_seq);
    end
   
   integer i;
    
    initial begin
        clk = 0;
        reset = 1;
        wgt_load_gbl = 0;
        result_in = 0;
        done = 0;
        
        #CLK_PERIOD;
        #CLK_PERIOD;
        
        reset = 0;
        wgt_load_gbl = {9{1'b1}};
        wgt_data = wgt_data_seq[0];
        
        #CLK_PERIOD;
        
        wgt_load_gbl = 0;
        
        for(i=0; i<ACT_READS; i=i+1) begin
            act_data = act_data_seq[i];
            #CLK_PERIOD;
        end
        
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        done = 1;
        #CLK_PERIOD;
        #CLK_PERIOD;
        $finish;
    end

endmodule