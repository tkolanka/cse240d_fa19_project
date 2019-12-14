`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 09:46:29 PM
// Design Name: 
// Module Name: systolic_standard_test
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

module systolic_standard_test();
parameter					ARRAY_DIM_X						= 16;
	parameter					ARRAY_DIM_Y						= 16;
	parameter					WGT_MEM_ADDR_BITWIDTH			= 8;
	parameter					WGT_BITWIDTH					= 8;
	parameter					ACT_BITWIDTH					= 8;
	parameter					BIAS_BITWIDTH					= 32;
	parameter					ACT_MEM_DATA_BITWIDTH			= ACT_BITWIDTH * ARRAY_DIM_Y;
	parameter					PART_SUM_BITWIDTH				= 32;
	parameter					PE_INTER_BITWIDTH				= 33;
	parameter					OUT_DATA_BITWIDTH				= 32;
	parameter					PE_TRUNC_MODE					= "MSB";
	parameter					NUM_PE							= ARRAY_DIM_X * ARRAY_DIM_Y;

	reg																		clk;
	reg																		reset_pe_reg;
	reg																		pe_wrt_en_reg;
	reg																		pe_wmem_reset;
	reg							[NUM_PE							-1: 0]		pe_wmem_read_req;
	reg							[NUM_PE							-1: 0]		pe_wmem_write_req;
	reg							[NUM_PE							-1: 0]		pe_ws_en;
	reg							[NUM_PE							-1: 0]		pe_ws_mux;
	reg							[ARRAY_DIM_Y					-1: 0]		as_en;
	reg	 						[ARRAY_DIM_Y					-1: 0]		as_mux;
	reg	 						[ARRAY_DIM_Y					-1: 0]		reset_as_reg;
	reg							[NUM_PE							-1: 0]		pe_reset_ws_reg;
	reg																		acc_reset;
	reg																		acc_wrt_en;
	reg																		os_en;
	reg																		bias_mem_adder_en;
	reg																		bias_out_sel;
	reg	 																	out_wr_sel;
	reg																		acc_out_mem_sel;
	reg							[ARRAY_DIM_X * BIAS_BITWIDTH    -1: 0]		bias_in;
	reg							[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_r_addr;
	reg							[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_w_addr;
	reg							[NUM_PE * WGT_BITWIDTH          -1: 0]		pe_wmem_w_data;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_15;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_14;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_13;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_12;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_11;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_10;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_9;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_8;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_7;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_6;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_5;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_4;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_3;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_2;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_1;
	reg							[ACT_BITWIDTH   			    -1: 0]		act_in_0;
	reg							[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		part_out_in;
	wire						[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		data_out;

	systolic_mvm #(
		.ARRAY_DIM_X 													(ARRAY_DIM_X),
		.ARRAY_DIM_Y 													(ARRAY_DIM_Y),
		.WGT_MEM_ADDR_BITWIDTH 											(WGT_MEM_ADDR_BITWIDTH),
		.WGT_BITWIDTH 													(WGT_BITWIDTH),
		.ACT_BITWIDTH 													(ACT_BITWIDTH),
		.BIAS_BITWIDTH 													(BIAS_BITWIDTH),
		.PART_SUM_BITWIDTH 												(PART_SUM_BITWIDTH),
		.PE_INTER_BITWIDTH 												(PE_INTER_BITWIDTH),
		.OUT_DATA_BITWIDTH	 											(OUT_DATA_BITWIDTH),
		.PE_TRUNC_MODE 													(PE_TRUNC_MODE)
	) UUT (
		.clk 															(clk),
		.reset_pe_reg 													(reset_pe_reg),
		.pe_wrt_en_reg 													(pe_wrt_en_reg),
		.pe_wmem_reset 													(pe_wmem_reset),
		.pe_wmem_read_req 												(pe_wmem_read_req),
		.pe_wmem_write_req 												(pe_wmem_write_req),
		.pe_ws_en 														(pe_ws_en),
		.pe_ws_mux 														(pe_ws_mux),
		.as_en 															(as_en),
		.as_mux															(as_mux),
		.reset_as_reg 													(reset_as_reg),
		.pe_reset_ws_reg 												(pe_reset_ws_reg),
		.acc_reset 														(acc_reset),
		.acc_wrt_en 													(acc_wrt_en),
		.os_en		 													(os_en),
		.bias_mem_adder_en 												(bias_mem_adder_en),
		.bias_out_sel 													(bias_out_sel),
		.out_wr_sel 													(out_wr_sel),
		.acc_out_mem_sel 												(acc_out_mem_sel),
		.bias_in 														(bias_in),
		.pe_wmem_r_addr 												(pe_wmem_r_addr),
		.pe_wmem_w_addr 												(pe_wmem_w_addr),
		.pe_wmem_w_data 												(pe_wmem_w_data),
		.act_in_15 														(act_in_15),
		.act_in_14 														(act_in_14),
		.act_in_13 														(act_in_13),
		.act_in_12 														(act_in_12),
		.act_in_11 														(act_in_11),
		.act_in_10 														(act_in_10),
		.act_in_9 														(act_in_9),
		.act_in_8 														(act_in_8),
		.act_in_7 														(act_in_7),
		.act_in_6 														(act_in_6),
		.act_in_5 														(act_in_5),
		.act_in_4 														(act_in_4),
		.act_in_3 														(act_in_3),
		.act_in_2 														(act_in_2),
		.act_in_1 														(act_in_1),
		.act_in_0 														(act_in_0),
		.part_out_in 													(part_out_in),
		.data_out 														(data_out)
	);

	parameter		CLK_PERIOD		  = 10;
	parameter       WGT_WRITES        = 72;
	parameter		NUM_WRITES 		  = 4;
	parameter       ACT_WRITES        = 338688;
	parameter       ITERS             = ACT_WRITES / (48*9);
	parameter       ACT_OFFSET        = ACT_WRITES / 9;
	parameter       OUT_CHANNELS = 64;
	parameter       FILTER_SIZE = 9;
	parameter       LOOP_ITER    = OUT_CHANNELS / ARRAY_DIM_X;

	always
        #(CLK_PERIOD / 2)  clk   =   ~ clk;

	reg  			[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]	wgt_addr 	[0:WGT_WRITES-1];
	reg				[NUM_PE * WGT_BITWIDTH          -1: 0]	wgt_data 	[0:WGT_WRITES-1];
	reg				[ARRAY_DIM_Y * ACT_BITWIDTH     -1: 0]	act_data 	[0:ACT_WRITES-1];
	reg				[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]	wgt_read_addr 	[0:WGT_WRITES-1];
	// reg				[ARRAY_DIM_X * BIAS_BITWIDTH    -1: 0]	bias_data		[0:NUM_WRITES-1];

//	reg				[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]  part_sum_temp;

    reg             [ARRAY_DIM_X*OUT_DATA_BITWIDTH - 1: 0] output_buffer [0: ITERS-1][0: -1][0: LOOP_ITER-1];
    reg done;

	initial begin
		$readmemb("standard_weighta_shaped.mem", wgt_addr);
		$readmemb("standard_weightd_shaped.mem", wgt_data);
		$readmemb("standard_act_shaped.mem", act_data);
		$readmemb("standard_weighta_shaped.mem", wgt_read_addr);
		// $readmemb("//Mac/Home/Documents/pegasus.code/hardware/pegasus_hardware/systolic_mvm/bias_data.txt", bias_data);

//		act_in_0 		=			act_data[3][ACT_BITWIDTH -1:0];
//		act_in_1 		=			act_data[3][2*ACT_BITWIDTH -1:ACT_BITWIDTH];
//		act_in_2 		=			act_data[3][3*ACT_BITWIDTH -1:2*ACT_BITWIDTH];
        act_in_0        =           8'b0;
        act_in_1        =           8'b0;
        act_in_2        =           8'b0;
        act_in_3        =           8'b0;
        act_in_4        =           8'b0;
        act_in_5        =           8'b0;
        act_in_6        =           8'b0;
        act_in_7        =           8'b0;
        act_in_8        =           8'b0;
        act_in_9        =           8'b0;
        act_in_10        =           8'b0;
        act_in_11        =           8'b0;
        act_in_12        =           8'b0;
        act_in_13        =           8'b0;
        act_in_14        =           8'b0;
        act_in_15        =           8'b0;
        
		// act_in_3 		=			act_data[3][4*ACT_BITWIDTH -1:3*ACT_BITWIDTH];
		$display("act 0", $signed(act_in_0));
		$display("act 1", $signed(act_in_1));
		$display("act 2", $signed(act_in_2));
		$display("act 3", $signed(act_in_3));
	end


integer									i, j, k, l, index, index1, index2, a;

	initial begin
		clk		= 	0;
		reset_pe_reg  = 1;
		pe_wrt_en_reg 	 =  0;
		pe_wmem_reset = 1;
		pe_wmem_read_req = 0;
		pe_wmem_write_req = 0;
		pe_ws_en          = 0;
		pe_ws_mux         = {256{1'b1}};
		pe_reset_ws_reg   = 1;
		as_en 			  = 0;
		as_mux 			  = {256{1'b1}};
		reset_as_reg 	  = {16{1'b1}};
		acc_reset         = 1;
		acc_wrt_en        = 0;
		os_en 			  = 0;
		bias_mem_adder_en = 0;
		bias_out_sel      = 1;
		out_wr_sel 		  = 0;
		acc_out_mem_sel   = 1;
		pe_wmem_r_addr    = 0;
		pe_wmem_w_addr    = 0;
		pe_wmem_w_data    = 0;
		part_out_in = 0;
        done = 0;

		#CLK_PERIOD;
		#CLK_PERIOD;
		pe_reset_ws_reg   = 0;
		pe_wmem_reset     = 0;
		reset_as_reg	  = 0;
		#CLK_PERIOD;
		pe_wmem_write_req = {256{1'b1}};
		
		for (i=0; i < WGT_WRITES; i = i+1) begin
				pe_wmem_w_addr = wgt_addr[i];
				pe_wmem_w_data = wgt_data[i];
				#CLK_PERIOD;
		end
		
		reset_pe_reg  = 0;
		pe_wrt_en_reg 	 =  1;
		pe_wmem_write_req = 0;
		acc_reset = 0;
		#CLK_PERIOD;
		#CLK_PERIOD;

for (a=0; a < FILTER_SIZE; a=a+1) begin

for (l=0; l < LOOP_ITER; l=l+1) begin

    pe_wmem_read_req = {256{1'b1}};
    pe_wmem_r_addr = wgt_read_addr[2*l + a*9];
    pe_ws_en          = {256{1'b1}};

    #CLK_PERIOD;
    pe_wmem_read_req = {256{1'b0}};
//    #CLK_PERIOD;
    
    pe_ws_en          = {256{1'b0}};
    pe_ws_mux         = {256{1'b0}};
    
for (k=0; k < ITERS; k=k+1) begin	   
	for (j=0; j < 16*3; j = j+1) begin	     
        index = k*48 + j;    
		act_in_15 = act_data[index + a*ACT_OFFSET][16*ACT_BITWIDTH - 1: 15*ACT_BITWIDTH];
        act_in_14 = act_data[index + a*ACT_OFFSET][15*ACT_BITWIDTH - 1: 14*ACT_BITWIDTH];
        act_in_13 = act_data[index + a*ACT_OFFSET][14*ACT_BITWIDTH - 1: 13*ACT_BITWIDTH];
        act_in_12 = act_data[index + a*ACT_OFFSET][13*ACT_BITWIDTH - 1: 12*ACT_BITWIDTH];
        act_in_11 = act_data[index + a*ACT_OFFSET][12*ACT_BITWIDTH - 1: 11*ACT_BITWIDTH];
        act_in_10 = act_data[index + a*ACT_OFFSET][11*ACT_BITWIDTH - 1: 10*ACT_BITWIDTH];
        act_in_9 = act_data[index + a*ACT_OFFSET][10*ACT_BITWIDTH - 1: 9*ACT_BITWIDTH];
        act_in_8 = act_data[index + a*ACT_OFFSET][9*ACT_BITWIDTH - 1: 8*ACT_BITWIDTH];
        act_in_7 = act_data[index + a*ACT_OFFSET][8*ACT_BITWIDTH - 1: 7*ACT_BITWIDTH];
        act_in_6 = act_data[index + a*ACT_OFFSET][7*ACT_BITWIDTH - 1: 6*ACT_BITWIDTH];
        act_in_5 = act_data[index + a*ACT_OFFSET][6*ACT_BITWIDTH - 1: 5*ACT_BITWIDTH];
        act_in_4 = act_data[index + a*ACT_OFFSET][5*ACT_BITWIDTH - 1: 4*ACT_BITWIDTH];
        act_in_3 = act_data[index + a*ACT_OFFSET][4*ACT_BITWIDTH - 1: 3*ACT_BITWIDTH];
        act_in_2 = act_data[index + a*ACT_OFFSET][3*ACT_BITWIDTH - 1: 2*ACT_BITWIDTH];
        act_in_1 = act_data[index + a*ACT_OFFSET][2*ACT_BITWIDTH - 1: 1*ACT_BITWIDTH];
        act_in_0 = act_data[index + a*ACT_OFFSET][1*ACT_BITWIDTH - 1: 0*ACT_BITWIDTH];
        
        acc_wrt_en = 1'b1;
        
        if ((k%2 == 0) && (j == 15)) begin
            pe_wmem_read_req = {256{1'b1}};
            pe_wmem_r_addr = wgt_read_addr[2*l + 1];
            pe_ws_en          = {256{1'b1}};
        end
        
        if ((k%2 == 1) && (j == 15)) begin
            pe_wmem_read_req = {256{1'b1}};
            pe_wmem_r_addr = wgt_read_addr[2*l];
            pe_ws_en          = {256{1'b1}};
        end
        
        #CLK_PERIOD;
        
        if (((k%2 == 0) && (j == 15)) || ((k%2 == 1) && (j == 15))) begin
            pe_wmem_read_req = {256{1'b0}};
            pe_ws_en          = {256{1'b0}};
            pe_ws_mux         = {256{1'b0}};
        end
        
        if (j < 16) begin
            out_wr_sel = 0;
            bias_mem_adder_en = 0;
        end
        else begin
            out_wr_sel = 1;
            bias_mem_adder_en = 1;
            bias_out_sel = 0;
            acc_out_mem_sel = 1;
        end
        
        
        if (((j > 16) && (a == 0)) || (a > 0)) begin
            index2 = 16 - (j % 16);
            index2 = (index2 == 16) ? 0 : index2;
            part_out_in = output_buffer[index2][k][l];
        end
        
        if (j >= 1) begin
            index1 = 16 - (j % 16);
            index1 = (index1 == 16) ? 0 : index1;
            output_buffer[index1][k][l] = data_out;
        end
        
    end
end
end
end
done = 1;
#CLK_PERIOD;
#CLK_PERIOD;
#CLK_PERIOD;

$finish;
end
endmodule