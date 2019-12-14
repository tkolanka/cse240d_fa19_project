`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2019 03:44:11 PM
// Design Name: 
// Module Name: simd_test
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


module simd_test();

    parameter NUM_PE = 16;
    parameter DATA_WIDTH = 8;
    parameter OUT_DATA_WIDTH = 32;
    
    reg clk;
    reg reset;
    reg first_data;
    reg [NUM_PE*DATA_WIDTH - 1:0] Kernel;
    reg [NUM_PE*DATA_WIDTH - 1:0] Input_Act;
    wire [NUM_PE*OUT_DATA_WIDTH - 1:0] Result;

    SIMD_execution #(
        .NUM_PE(NUM_PE),
        .DATA_WIDTH(DATA_WIDTH),
        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
    ) UUT (
        .clk(clk),
        .reset(reset),
        .first_data(first_data),
        .Kernel(Kernel),
        .Input_Act(Input_Act),
        .Result(Result)
    );
    
    parameter CLK_PERIOD = 2;
    parameter NUM_READS = 25088;
    parameter FILTER_SIZE = 9;

    always
        #(CLK_PERIOD / 2) clk  =  ~ clk;

    reg [NUM_PE * DATA_WIDTH -1: 0] kernel_data[0:NUM_READS*FILTER_SIZE-1];
    reg [NUM_PE * DATA_WIDTH -1: 0] act_data[0:NUM_READS*FILTER_SIZE-1];
    reg [NUM_PE * OUT_DATA_WIDTH -1: 0] result[0:NUM_PE-1];
    reg done;
    
    initial begin
        $readmemb("weights_conv_dw32.mem", kernel_data);
        $readmemb("activations_conv_pad.mem", act_data);
    end
    
    integer i, j, index;
    
    initial begin
        clk = 0;
        reset = 1;
        first_data = 1;
        done = 0;
        
        #CLK_PERIOD;
        #CLK_PERIOD;
        
        reset = 0;
        
        #CLK_PERIOD;
        
        for (i=0; i<NUM_READS; i=i+1) begin
            for (j=0; j<FILTER_SIZE; j=j+1) begin
                if(j == 0)
                    first_data = 1;
                else
                    first_data = 0;
                    
                Kernel = kernel_data[i*FILTER_SIZE + j];
                Input_Act = act_data[i*FILTER_SIZE + j];
                
                #CLK_PERIOD;
            end
            index = i%16;
            result[index] = Result;
        end
    #CLK_PERIOD;
    #CLK_PERIOD;
    done = 1;
    #CLK_PERIOD;
    #CLK_PERIOD;    
    $finish;
    end
    
endmodule