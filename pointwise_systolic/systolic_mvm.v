//
// PE systolic array organization
//
// Soroush Ghodrati
// (soghodra@eng.ucsd.edu)

`timescale 1ns/1ps

module systolic_mvm #(
	parameter					ARRAY_DIM_X									= 16,
	parameter					ARRAY_DIM_Y									= 16,
	parameter					WGT_MEM_ADDR_BITWIDTH						= 8,
	parameter					WGT_BITWIDTH								= 8,
	parameter					ACT_BITWIDTH								= 8,
	parameter					BIAS_BITWIDTH								= 32,
	parameter					ACT_MEM_DATA_BITWIDTH						= ACT_BITWIDTH * ARRAY_DIM_Y,
	parameter					PART_SUM_BITWIDTH							= 32,
	parameter					PE_INTER_BITWIDTH							= 33,
	parameter					OUT_DATA_BITWIDTH							= PART_SUM_BITWIDTH,
	parameter					PE_TRUNC_MODE								= "MSB",
	parameter					NUM_PE										= ARRAY_DIM_X * ARRAY_DIM_Y
)(
	input																	clk,
	input																	reset_pe_reg,
	input																	pe_wrt_en_reg,
	input																	pe_wmem_reset,
	input						[NUM_PE							-1: 0]		pe_wmem_read_req,
	input						[NUM_PE							-1: 0]		pe_wmem_write_req,
	input						[NUM_PE							-1: 0]		pe_ws_en,
	input						[NUM_PE							-1: 0]		pe_ws_mux,
	input						[ARRAY_DIM_Y					-1: 0]		as_en,
	input 						[ARRAY_DIM_Y					-1: 0]		as_mux,
	input 						[ARRAY_DIM_Y					-1: 0]		reset_as_reg,
	input						[NUM_PE							-1: 0]		pe_reset_ws_reg,
	input																	acc_reset,
	input																	acc_wrt_en,
	input						                  		os_en,
	input																	bias_mem_adder_en,
	input																	bias_out_sel,
	input 																	out_wr_sel,
	input																	acc_out_mem_sel,
	input						[ARRAY_DIM_X * BIAS_BITWIDTH    -1: 0]		bias_in,
	input						[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_r_addr,
	input						[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_w_addr,
	input						[NUM_PE * WGT_BITWIDTH          -1: 0]		pe_wmem_w_data,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_15,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_14,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_13,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_12,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_11,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_10,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_9,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_8,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_7,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_6,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_5,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_4,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_3,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_2,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_1,

	input						[ACT_BITWIDTH       			-1: 0]		act_in_0,

	input						[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		part_out_in,
	output						[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		data_out
);


	//Making PE weight memroy r/w addresses adn write data passes
//
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_3_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_4_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_5_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_6_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_7_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_8_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_9_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_10_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_11_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_12_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_13_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_14_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_15_15;
//
//
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_0;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_1;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_2;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_3;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_4;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_5;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_6;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_7;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_8;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_9;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_10;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_11;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_12;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_13;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_14;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_15;
//
//
	assign 						pe_wmem_r_addr_row_0          =   pe_wmem_r_addr[(0+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:0*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_1          =   pe_wmem_r_addr[(1+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:1*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_2          =   pe_wmem_r_addr[(2+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:2*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_3          =   pe_wmem_r_addr[(3+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:3*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_4          =   pe_wmem_r_addr[(4+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:4*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_5          =   pe_wmem_r_addr[(5+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:5*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_6          =   pe_wmem_r_addr[(6+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:6*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_7          =   pe_wmem_r_addr[(7+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:7*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_8          =   pe_wmem_r_addr[(8+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:8*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_9          =   pe_wmem_r_addr[(9+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:9*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_10          =   pe_wmem_r_addr[(10+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:10*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_11          =   pe_wmem_r_addr[(11+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:11*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_12          =   pe_wmem_r_addr[(12+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:12*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_13          =   pe_wmem_r_addr[(13+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:13*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_14          =   pe_wmem_r_addr[(14+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:14*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign 						pe_wmem_r_addr_row_15          =   pe_wmem_r_addr[(15+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:15*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//
//
	assign						pe_wmem_r_addr_0_0	=	pe_wmem_r_addr_row_0[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_0	=	pe_wmem_r_addr_row_1[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_0	=	pe_wmem_r_addr_row_2[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_0	=	pe_wmem_r_addr_row_3[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_0	=	pe_wmem_r_addr_row_4[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_0	=	pe_wmem_r_addr_row_5[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_0	=	pe_wmem_r_addr_row_6[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_0	=	pe_wmem_r_addr_row_7[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_0	=	pe_wmem_r_addr_row_8[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_0	=	pe_wmem_r_addr_row_9[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_0	=	pe_wmem_r_addr_row_10[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_0	=	pe_wmem_r_addr_row_11[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_0	=	pe_wmem_r_addr_row_12[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_0	=	pe_wmem_r_addr_row_13[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_0	=	pe_wmem_r_addr_row_14[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_0	=	pe_wmem_r_addr_row_15[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_1	=	pe_wmem_r_addr_row_0[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_1	=	pe_wmem_r_addr_row_1[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_1	=	pe_wmem_r_addr_row_2[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_1	=	pe_wmem_r_addr_row_3[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_1	=	pe_wmem_r_addr_row_4[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_1	=	pe_wmem_r_addr_row_5[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_1	=	pe_wmem_r_addr_row_6[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_1	=	pe_wmem_r_addr_row_7[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_1	=	pe_wmem_r_addr_row_8[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_1	=	pe_wmem_r_addr_row_9[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_1	=	pe_wmem_r_addr_row_10[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_1	=	pe_wmem_r_addr_row_11[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_1	=	pe_wmem_r_addr_row_12[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_1	=	pe_wmem_r_addr_row_13[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_1	=	pe_wmem_r_addr_row_14[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_1	=	pe_wmem_r_addr_row_15[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_2	=	pe_wmem_r_addr_row_0[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_2	=	pe_wmem_r_addr_row_1[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_2	=	pe_wmem_r_addr_row_2[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_2	=	pe_wmem_r_addr_row_3[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_2	=	pe_wmem_r_addr_row_4[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_2	=	pe_wmem_r_addr_row_5[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_2	=	pe_wmem_r_addr_row_6[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_2	=	pe_wmem_r_addr_row_7[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_2	=	pe_wmem_r_addr_row_8[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_2	=	pe_wmem_r_addr_row_9[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_2	=	pe_wmem_r_addr_row_10[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_2	=	pe_wmem_r_addr_row_11[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_2	=	pe_wmem_r_addr_row_12[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_2	=	pe_wmem_r_addr_row_13[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_2	=	pe_wmem_r_addr_row_14[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_2	=	pe_wmem_r_addr_row_15[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_3	=	pe_wmem_r_addr_row_0[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_3	=	pe_wmem_r_addr_row_1[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_3	=	pe_wmem_r_addr_row_2[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_3	=	pe_wmem_r_addr_row_3[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_3	=	pe_wmem_r_addr_row_4[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_3	=	pe_wmem_r_addr_row_5[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_3	=	pe_wmem_r_addr_row_6[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_3	=	pe_wmem_r_addr_row_7[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_3	=	pe_wmem_r_addr_row_8[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_3	=	pe_wmem_r_addr_row_9[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_3	=	pe_wmem_r_addr_row_10[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_3	=	pe_wmem_r_addr_row_11[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_3	=	pe_wmem_r_addr_row_12[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_3	=	pe_wmem_r_addr_row_13[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_3	=	pe_wmem_r_addr_row_14[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_3	=	pe_wmem_r_addr_row_15[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_4	=	pe_wmem_r_addr_row_0[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_4	=	pe_wmem_r_addr_row_1[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_4	=	pe_wmem_r_addr_row_2[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_4	=	pe_wmem_r_addr_row_3[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_4	=	pe_wmem_r_addr_row_4[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_4	=	pe_wmem_r_addr_row_5[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_4	=	pe_wmem_r_addr_row_6[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_4	=	pe_wmem_r_addr_row_7[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_4	=	pe_wmem_r_addr_row_8[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_4	=	pe_wmem_r_addr_row_9[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_4	=	pe_wmem_r_addr_row_10[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_4	=	pe_wmem_r_addr_row_11[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_4	=	pe_wmem_r_addr_row_12[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_4	=	pe_wmem_r_addr_row_13[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_4	=	pe_wmem_r_addr_row_14[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_4	=	pe_wmem_r_addr_row_15[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_5	=	pe_wmem_r_addr_row_0[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_5	=	pe_wmem_r_addr_row_1[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_5	=	pe_wmem_r_addr_row_2[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_5	=	pe_wmem_r_addr_row_3[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_5	=	pe_wmem_r_addr_row_4[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_5	=	pe_wmem_r_addr_row_5[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_5	=	pe_wmem_r_addr_row_6[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_5	=	pe_wmem_r_addr_row_7[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_5	=	pe_wmem_r_addr_row_8[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_5	=	pe_wmem_r_addr_row_9[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_5	=	pe_wmem_r_addr_row_10[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_5	=	pe_wmem_r_addr_row_11[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_5	=	pe_wmem_r_addr_row_12[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_5	=	pe_wmem_r_addr_row_13[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_5	=	pe_wmem_r_addr_row_14[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_5	=	pe_wmem_r_addr_row_15[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_6	=	pe_wmem_r_addr_row_0[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_6	=	pe_wmem_r_addr_row_1[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_6	=	pe_wmem_r_addr_row_2[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_6	=	pe_wmem_r_addr_row_3[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_6	=	pe_wmem_r_addr_row_4[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_6	=	pe_wmem_r_addr_row_5[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_6	=	pe_wmem_r_addr_row_6[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_6	=	pe_wmem_r_addr_row_7[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_6	=	pe_wmem_r_addr_row_8[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_6	=	pe_wmem_r_addr_row_9[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_6	=	pe_wmem_r_addr_row_10[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_6	=	pe_wmem_r_addr_row_11[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_6	=	pe_wmem_r_addr_row_12[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_6	=	pe_wmem_r_addr_row_13[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_6	=	pe_wmem_r_addr_row_14[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_6	=	pe_wmem_r_addr_row_15[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_7	=	pe_wmem_r_addr_row_0[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_7	=	pe_wmem_r_addr_row_1[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_7	=	pe_wmem_r_addr_row_2[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_7	=	pe_wmem_r_addr_row_3[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_7	=	pe_wmem_r_addr_row_4[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_7	=	pe_wmem_r_addr_row_5[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_7	=	pe_wmem_r_addr_row_6[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_7	=	pe_wmem_r_addr_row_7[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_7	=	pe_wmem_r_addr_row_8[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_7	=	pe_wmem_r_addr_row_9[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_7	=	pe_wmem_r_addr_row_10[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_7	=	pe_wmem_r_addr_row_11[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_7	=	pe_wmem_r_addr_row_12[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_7	=	pe_wmem_r_addr_row_13[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_7	=	pe_wmem_r_addr_row_14[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_7	=	pe_wmem_r_addr_row_15[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_8	=	pe_wmem_r_addr_row_0[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_8	=	pe_wmem_r_addr_row_1[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_8	=	pe_wmem_r_addr_row_2[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_8	=	pe_wmem_r_addr_row_3[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_8	=	pe_wmem_r_addr_row_4[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_8	=	pe_wmem_r_addr_row_5[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_8	=	pe_wmem_r_addr_row_6[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_8	=	pe_wmem_r_addr_row_7[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_8	=	pe_wmem_r_addr_row_8[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_8	=	pe_wmem_r_addr_row_9[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_8	=	pe_wmem_r_addr_row_10[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_8	=	pe_wmem_r_addr_row_11[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_8	=	pe_wmem_r_addr_row_12[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_8	=	pe_wmem_r_addr_row_13[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_8	=	pe_wmem_r_addr_row_14[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_8	=	pe_wmem_r_addr_row_15[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_9	=	pe_wmem_r_addr_row_0[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_9	=	pe_wmem_r_addr_row_1[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_9	=	pe_wmem_r_addr_row_2[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_9	=	pe_wmem_r_addr_row_3[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_9	=	pe_wmem_r_addr_row_4[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_9	=	pe_wmem_r_addr_row_5[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_9	=	pe_wmem_r_addr_row_6[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_9	=	pe_wmem_r_addr_row_7[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_9	=	pe_wmem_r_addr_row_8[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_9	=	pe_wmem_r_addr_row_9[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_9	=	pe_wmem_r_addr_row_10[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_9	=	pe_wmem_r_addr_row_11[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_9	=	pe_wmem_r_addr_row_12[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_9	=	pe_wmem_r_addr_row_13[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_9	=	pe_wmem_r_addr_row_14[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_9	=	pe_wmem_r_addr_row_15[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_10	=	pe_wmem_r_addr_row_0[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_10	=	pe_wmem_r_addr_row_1[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_10	=	pe_wmem_r_addr_row_2[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_10	=	pe_wmem_r_addr_row_3[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_10	=	pe_wmem_r_addr_row_4[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_10	=	pe_wmem_r_addr_row_5[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_10	=	pe_wmem_r_addr_row_6[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_10	=	pe_wmem_r_addr_row_7[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_10	=	pe_wmem_r_addr_row_8[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_10	=	pe_wmem_r_addr_row_9[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_10	=	pe_wmem_r_addr_row_10[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_10	=	pe_wmem_r_addr_row_11[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_10	=	pe_wmem_r_addr_row_12[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_10	=	pe_wmem_r_addr_row_13[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_10	=	pe_wmem_r_addr_row_14[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_10	=	pe_wmem_r_addr_row_15[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_11	=	pe_wmem_r_addr_row_0[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_11	=	pe_wmem_r_addr_row_1[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_11	=	pe_wmem_r_addr_row_2[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_11	=	pe_wmem_r_addr_row_3[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_11	=	pe_wmem_r_addr_row_4[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_11	=	pe_wmem_r_addr_row_5[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_11	=	pe_wmem_r_addr_row_6[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_11	=	pe_wmem_r_addr_row_7[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_11	=	pe_wmem_r_addr_row_8[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_11	=	pe_wmem_r_addr_row_9[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_11	=	pe_wmem_r_addr_row_10[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_11	=	pe_wmem_r_addr_row_11[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_11	=	pe_wmem_r_addr_row_12[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_11	=	pe_wmem_r_addr_row_13[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_11	=	pe_wmem_r_addr_row_14[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_11	=	pe_wmem_r_addr_row_15[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_12	=	pe_wmem_r_addr_row_0[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_12	=	pe_wmem_r_addr_row_1[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_12	=	pe_wmem_r_addr_row_2[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_12	=	pe_wmem_r_addr_row_3[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_12	=	pe_wmem_r_addr_row_4[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_12	=	pe_wmem_r_addr_row_5[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_12	=	pe_wmem_r_addr_row_6[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_12	=	pe_wmem_r_addr_row_7[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_12	=	pe_wmem_r_addr_row_8[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_12	=	pe_wmem_r_addr_row_9[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_12	=	pe_wmem_r_addr_row_10[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_12	=	pe_wmem_r_addr_row_11[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_12	=	pe_wmem_r_addr_row_12[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_12	=	pe_wmem_r_addr_row_13[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_12	=	pe_wmem_r_addr_row_14[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_12	=	pe_wmem_r_addr_row_15[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_13	=	pe_wmem_r_addr_row_0[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_13	=	pe_wmem_r_addr_row_1[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_13	=	pe_wmem_r_addr_row_2[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_13	=	pe_wmem_r_addr_row_3[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_13	=	pe_wmem_r_addr_row_4[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_13	=	pe_wmem_r_addr_row_5[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_13	=	pe_wmem_r_addr_row_6[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_13	=	pe_wmem_r_addr_row_7[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_13	=	pe_wmem_r_addr_row_8[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_13	=	pe_wmem_r_addr_row_9[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_13	=	pe_wmem_r_addr_row_10[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_13	=	pe_wmem_r_addr_row_11[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_13	=	pe_wmem_r_addr_row_12[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_13	=	pe_wmem_r_addr_row_13[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_13	=	pe_wmem_r_addr_row_14[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_13	=	pe_wmem_r_addr_row_15[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_14	=	pe_wmem_r_addr_row_0[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_14	=	pe_wmem_r_addr_row_1[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_14	=	pe_wmem_r_addr_row_2[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_14	=	pe_wmem_r_addr_row_3[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_14	=	pe_wmem_r_addr_row_4[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_14	=	pe_wmem_r_addr_row_5[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_14	=	pe_wmem_r_addr_row_6[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_14	=	pe_wmem_r_addr_row_7[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_14	=	pe_wmem_r_addr_row_8[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_14	=	pe_wmem_r_addr_row_9[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_14	=	pe_wmem_r_addr_row_10[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_14	=	pe_wmem_r_addr_row_11[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_14	=	pe_wmem_r_addr_row_12[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_14	=	pe_wmem_r_addr_row_13[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_14	=	pe_wmem_r_addr_row_14[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_14	=	pe_wmem_r_addr_row_15[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_0_15	=	pe_wmem_r_addr_row_0[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_1_15	=	pe_wmem_r_addr_row_1[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_2_15	=	pe_wmem_r_addr_row_2[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_3_15	=	pe_wmem_r_addr_row_3[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_4_15	=	pe_wmem_r_addr_row_4[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_5_15	=	pe_wmem_r_addr_row_5[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_6_15	=	pe_wmem_r_addr_row_6[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_7_15	=	pe_wmem_r_addr_row_7[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_8_15	=	pe_wmem_r_addr_row_8[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_9_15	=	pe_wmem_r_addr_row_9[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_10_15	=	pe_wmem_r_addr_row_10[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_11_15	=	pe_wmem_r_addr_row_11[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_12_15	=	pe_wmem_r_addr_row_12[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_13_15	=	pe_wmem_r_addr_row_13[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_14_15	=	pe_wmem_r_addr_row_14[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_r_addr_15_15	=	pe_wmem_r_addr_row_15[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
//

//
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_0;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_1;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_2;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_3;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_4;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_5;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_6;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_7;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_8;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_9;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_10;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_11;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_12;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_13;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_14;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_3_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_4_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_5_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_6_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_7_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_8_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_9_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_10_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_11_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_12_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_13_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_14_15;
	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_15_15;
//
//
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_0;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_1;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_2;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_3;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_4;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_5;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_6;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_7;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_8;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_9;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_10;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_11;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_12;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_13;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_14;
	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_15;
//
//
	assign						pe_wmem_w_addr_row_0          =   pe_wmem_w_addr[(0+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:0*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_1          =   pe_wmem_w_addr[(1+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:1*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_2          =   pe_wmem_w_addr[(2+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:2*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_3          =   pe_wmem_w_addr[(3+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:3*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_4          =   pe_wmem_w_addr[(4+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:4*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_5          =   pe_wmem_w_addr[(5+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:5*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_6          =   pe_wmem_w_addr[(6+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:6*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_7          =   pe_wmem_w_addr[(7+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:7*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_8          =   pe_wmem_w_addr[(8+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:8*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_9          =   pe_wmem_w_addr[(9+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:9*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_10          =   pe_wmem_w_addr[(10+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:10*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_11          =   pe_wmem_w_addr[(11+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:11*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_12          =   pe_wmem_w_addr[(12+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:12*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_13          =   pe_wmem_w_addr[(13+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:13*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_14          =   pe_wmem_w_addr[(14+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:14*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_addr_row_15          =   pe_wmem_w_addr[(15+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:15*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//
//
	assign						pe_wmem_w_addr_0_0	=	pe_wmem_w_addr_row_0[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_0	=	pe_wmem_w_addr_row_1[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_0	=	pe_wmem_w_addr_row_2[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_0	=	pe_wmem_w_addr_row_3[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_0	=	pe_wmem_w_addr_row_4[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_0	=	pe_wmem_w_addr_row_5[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_0	=	pe_wmem_w_addr_row_6[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_0	=	pe_wmem_w_addr_row_7[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_0	=	pe_wmem_w_addr_row_8[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_0	=	pe_wmem_w_addr_row_9[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_0	=	pe_wmem_w_addr_row_10[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_0	=	pe_wmem_w_addr_row_11[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_0	=	pe_wmem_w_addr_row_12[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_0	=	pe_wmem_w_addr_row_13[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_0	=	pe_wmem_w_addr_row_14[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_0	=	pe_wmem_w_addr_row_15[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_1	=	pe_wmem_w_addr_row_0[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_1	=	pe_wmem_w_addr_row_1[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_1	=	pe_wmem_w_addr_row_2[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_1	=	pe_wmem_w_addr_row_3[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_1	=	pe_wmem_w_addr_row_4[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_1	=	pe_wmem_w_addr_row_5[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_1	=	pe_wmem_w_addr_row_6[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_1	=	pe_wmem_w_addr_row_7[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_1	=	pe_wmem_w_addr_row_8[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_1	=	pe_wmem_w_addr_row_9[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_1	=	pe_wmem_w_addr_row_10[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_1	=	pe_wmem_w_addr_row_11[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_1	=	pe_wmem_w_addr_row_12[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_1	=	pe_wmem_w_addr_row_13[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_1	=	pe_wmem_w_addr_row_14[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_1	=	pe_wmem_w_addr_row_15[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_2	=	pe_wmem_w_addr_row_0[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_2	=	pe_wmem_w_addr_row_1[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_2	=	pe_wmem_w_addr_row_2[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_2	=	pe_wmem_w_addr_row_3[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_2	=	pe_wmem_w_addr_row_4[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_2	=	pe_wmem_w_addr_row_5[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_2	=	pe_wmem_w_addr_row_6[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_2	=	pe_wmem_w_addr_row_7[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_2	=	pe_wmem_w_addr_row_8[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_2	=	pe_wmem_w_addr_row_9[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_2	=	pe_wmem_w_addr_row_10[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_2	=	pe_wmem_w_addr_row_11[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_2	=	pe_wmem_w_addr_row_12[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_2	=	pe_wmem_w_addr_row_13[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_2	=	pe_wmem_w_addr_row_14[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_2	=	pe_wmem_w_addr_row_15[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_3	=	pe_wmem_w_addr_row_0[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_3	=	pe_wmem_w_addr_row_1[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_3	=	pe_wmem_w_addr_row_2[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_3	=	pe_wmem_w_addr_row_3[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_3	=	pe_wmem_w_addr_row_4[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_3	=	pe_wmem_w_addr_row_5[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_3	=	pe_wmem_w_addr_row_6[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_3	=	pe_wmem_w_addr_row_7[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_3	=	pe_wmem_w_addr_row_8[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_3	=	pe_wmem_w_addr_row_9[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_3	=	pe_wmem_w_addr_row_10[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_3	=	pe_wmem_w_addr_row_11[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_3	=	pe_wmem_w_addr_row_12[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_3	=	pe_wmem_w_addr_row_13[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_3	=	pe_wmem_w_addr_row_14[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_3	=	pe_wmem_w_addr_row_15[(3+1)*WGT_MEM_ADDR_BITWIDTH-1:3*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_4	=	pe_wmem_w_addr_row_0[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_4	=	pe_wmem_w_addr_row_1[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_4	=	pe_wmem_w_addr_row_2[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_4	=	pe_wmem_w_addr_row_3[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_4	=	pe_wmem_w_addr_row_4[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_4	=	pe_wmem_w_addr_row_5[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_4	=	pe_wmem_w_addr_row_6[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_4	=	pe_wmem_w_addr_row_7[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_4	=	pe_wmem_w_addr_row_8[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_4	=	pe_wmem_w_addr_row_9[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_4	=	pe_wmem_w_addr_row_10[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_4	=	pe_wmem_w_addr_row_11[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_4	=	pe_wmem_w_addr_row_12[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_4	=	pe_wmem_w_addr_row_13[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_4	=	pe_wmem_w_addr_row_14[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_4	=	pe_wmem_w_addr_row_15[(4+1)*WGT_MEM_ADDR_BITWIDTH-1:4*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_5	=	pe_wmem_w_addr_row_0[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_5	=	pe_wmem_w_addr_row_1[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_5	=	pe_wmem_w_addr_row_2[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_5	=	pe_wmem_w_addr_row_3[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_5	=	pe_wmem_w_addr_row_4[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_5	=	pe_wmem_w_addr_row_5[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_5	=	pe_wmem_w_addr_row_6[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_5	=	pe_wmem_w_addr_row_7[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_5	=	pe_wmem_w_addr_row_8[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_5	=	pe_wmem_w_addr_row_9[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_5	=	pe_wmem_w_addr_row_10[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_5	=	pe_wmem_w_addr_row_11[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_5	=	pe_wmem_w_addr_row_12[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_5	=	pe_wmem_w_addr_row_13[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_5	=	pe_wmem_w_addr_row_14[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_5	=	pe_wmem_w_addr_row_15[(5+1)*WGT_MEM_ADDR_BITWIDTH-1:5*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_6	=	pe_wmem_w_addr_row_0[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_6	=	pe_wmem_w_addr_row_1[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_6	=	pe_wmem_w_addr_row_2[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_6	=	pe_wmem_w_addr_row_3[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_6	=	pe_wmem_w_addr_row_4[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_6	=	pe_wmem_w_addr_row_5[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_6	=	pe_wmem_w_addr_row_6[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_6	=	pe_wmem_w_addr_row_7[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_6	=	pe_wmem_w_addr_row_8[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_6	=	pe_wmem_w_addr_row_9[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_6	=	pe_wmem_w_addr_row_10[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_6	=	pe_wmem_w_addr_row_11[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_6	=	pe_wmem_w_addr_row_12[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_6	=	pe_wmem_w_addr_row_13[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_6	=	pe_wmem_w_addr_row_14[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_6	=	pe_wmem_w_addr_row_15[(6+1)*WGT_MEM_ADDR_BITWIDTH-1:6*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_7	=	pe_wmem_w_addr_row_0[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_7	=	pe_wmem_w_addr_row_1[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_7	=	pe_wmem_w_addr_row_2[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_7	=	pe_wmem_w_addr_row_3[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_7	=	pe_wmem_w_addr_row_4[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_7	=	pe_wmem_w_addr_row_5[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_7	=	pe_wmem_w_addr_row_6[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_7	=	pe_wmem_w_addr_row_7[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_7	=	pe_wmem_w_addr_row_8[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_7	=	pe_wmem_w_addr_row_9[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_7	=	pe_wmem_w_addr_row_10[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_7	=	pe_wmem_w_addr_row_11[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_7	=	pe_wmem_w_addr_row_12[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_7	=	pe_wmem_w_addr_row_13[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_7	=	pe_wmem_w_addr_row_14[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_7	=	pe_wmem_w_addr_row_15[(7+1)*WGT_MEM_ADDR_BITWIDTH-1:7*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_8	=	pe_wmem_w_addr_row_0[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_8	=	pe_wmem_w_addr_row_1[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_8	=	pe_wmem_w_addr_row_2[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_8	=	pe_wmem_w_addr_row_3[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_8	=	pe_wmem_w_addr_row_4[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_8	=	pe_wmem_w_addr_row_5[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_8	=	pe_wmem_w_addr_row_6[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_8	=	pe_wmem_w_addr_row_7[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_8	=	pe_wmem_w_addr_row_8[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_8	=	pe_wmem_w_addr_row_9[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_8	=	pe_wmem_w_addr_row_10[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_8	=	pe_wmem_w_addr_row_11[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_8	=	pe_wmem_w_addr_row_12[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_8	=	pe_wmem_w_addr_row_13[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_8	=	pe_wmem_w_addr_row_14[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_8	=	pe_wmem_w_addr_row_15[(8+1)*WGT_MEM_ADDR_BITWIDTH-1:8*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_9	=	pe_wmem_w_addr_row_0[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_9	=	pe_wmem_w_addr_row_1[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_9	=	pe_wmem_w_addr_row_2[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_9	=	pe_wmem_w_addr_row_3[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_9	=	pe_wmem_w_addr_row_4[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_9	=	pe_wmem_w_addr_row_5[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_9	=	pe_wmem_w_addr_row_6[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_9	=	pe_wmem_w_addr_row_7[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_9	=	pe_wmem_w_addr_row_8[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_9	=	pe_wmem_w_addr_row_9[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_9	=	pe_wmem_w_addr_row_10[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_9	=	pe_wmem_w_addr_row_11[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_9	=	pe_wmem_w_addr_row_12[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_9	=	pe_wmem_w_addr_row_13[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_9	=	pe_wmem_w_addr_row_14[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_9	=	pe_wmem_w_addr_row_15[(9+1)*WGT_MEM_ADDR_BITWIDTH-1:9*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_10	=	pe_wmem_w_addr_row_0[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_10	=	pe_wmem_w_addr_row_1[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_10	=	pe_wmem_w_addr_row_2[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_10	=	pe_wmem_w_addr_row_3[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_10	=	pe_wmem_w_addr_row_4[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_10	=	pe_wmem_w_addr_row_5[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_10	=	pe_wmem_w_addr_row_6[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_10	=	pe_wmem_w_addr_row_7[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_10	=	pe_wmem_w_addr_row_8[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_10	=	pe_wmem_w_addr_row_9[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_10	=	pe_wmem_w_addr_row_10[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_10	=	pe_wmem_w_addr_row_11[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_10	=	pe_wmem_w_addr_row_12[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_10	=	pe_wmem_w_addr_row_13[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_10	=	pe_wmem_w_addr_row_14[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_10	=	pe_wmem_w_addr_row_15[(10+1)*WGT_MEM_ADDR_BITWIDTH-1:10*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_11	=	pe_wmem_w_addr_row_0[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_11	=	pe_wmem_w_addr_row_1[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_11	=	pe_wmem_w_addr_row_2[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_11	=	pe_wmem_w_addr_row_3[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_11	=	pe_wmem_w_addr_row_4[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_11	=	pe_wmem_w_addr_row_5[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_11	=	pe_wmem_w_addr_row_6[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_11	=	pe_wmem_w_addr_row_7[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_11	=	pe_wmem_w_addr_row_8[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_11	=	pe_wmem_w_addr_row_9[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_11	=	pe_wmem_w_addr_row_10[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_11	=	pe_wmem_w_addr_row_11[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_11	=	pe_wmem_w_addr_row_12[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_11	=	pe_wmem_w_addr_row_13[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_11	=	pe_wmem_w_addr_row_14[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_11	=	pe_wmem_w_addr_row_15[(11+1)*WGT_MEM_ADDR_BITWIDTH-1:11*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_12	=	pe_wmem_w_addr_row_0[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_12	=	pe_wmem_w_addr_row_1[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_12	=	pe_wmem_w_addr_row_2[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_12	=	pe_wmem_w_addr_row_3[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_12	=	pe_wmem_w_addr_row_4[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_12	=	pe_wmem_w_addr_row_5[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_12	=	pe_wmem_w_addr_row_6[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_12	=	pe_wmem_w_addr_row_7[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_12	=	pe_wmem_w_addr_row_8[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_12	=	pe_wmem_w_addr_row_9[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_12	=	pe_wmem_w_addr_row_10[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_12	=	pe_wmem_w_addr_row_11[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_12	=	pe_wmem_w_addr_row_12[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_12	=	pe_wmem_w_addr_row_13[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_12	=	pe_wmem_w_addr_row_14[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_12	=	pe_wmem_w_addr_row_15[(12+1)*WGT_MEM_ADDR_BITWIDTH-1:12*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_13	=	pe_wmem_w_addr_row_0[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_13	=	pe_wmem_w_addr_row_1[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_13	=	pe_wmem_w_addr_row_2[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_13	=	pe_wmem_w_addr_row_3[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_13	=	pe_wmem_w_addr_row_4[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_13	=	pe_wmem_w_addr_row_5[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_13	=	pe_wmem_w_addr_row_6[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_13	=	pe_wmem_w_addr_row_7[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_13	=	pe_wmem_w_addr_row_8[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_13	=	pe_wmem_w_addr_row_9[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_13	=	pe_wmem_w_addr_row_10[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_13	=	pe_wmem_w_addr_row_11[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_13	=	pe_wmem_w_addr_row_12[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_13	=	pe_wmem_w_addr_row_13[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_13	=	pe_wmem_w_addr_row_14[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_13	=	pe_wmem_w_addr_row_15[(13+1)*WGT_MEM_ADDR_BITWIDTH-1:13*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_14	=	pe_wmem_w_addr_row_0[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_14	=	pe_wmem_w_addr_row_1[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_14	=	pe_wmem_w_addr_row_2[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_14	=	pe_wmem_w_addr_row_3[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_14	=	pe_wmem_w_addr_row_4[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_14	=	pe_wmem_w_addr_row_5[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_14	=	pe_wmem_w_addr_row_6[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_14	=	pe_wmem_w_addr_row_7[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_14	=	pe_wmem_w_addr_row_8[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_14	=	pe_wmem_w_addr_row_9[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_14	=	pe_wmem_w_addr_row_10[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_14	=	pe_wmem_w_addr_row_11[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_14	=	pe_wmem_w_addr_row_12[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_14	=	pe_wmem_w_addr_row_13[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_14	=	pe_wmem_w_addr_row_14[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_14	=	pe_wmem_w_addr_row_15[(14+1)*WGT_MEM_ADDR_BITWIDTH-1:14*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_0_15	=	pe_wmem_w_addr_row_0[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_1_15	=	pe_wmem_w_addr_row_1[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_2_15	=	pe_wmem_w_addr_row_2[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_3_15	=	pe_wmem_w_addr_row_3[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_4_15	=	pe_wmem_w_addr_row_4[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_5_15	=	pe_wmem_w_addr_row_5[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_6_15	=	pe_wmem_w_addr_row_6[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_7_15	=	pe_wmem_w_addr_row_7[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_8_15	=	pe_wmem_w_addr_row_8[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_9_15	=	pe_wmem_w_addr_row_9[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_10_15	=	pe_wmem_w_addr_row_10[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_11_15	=	pe_wmem_w_addr_row_11[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_12_15	=	pe_wmem_w_addr_row_12[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_13_15	=	pe_wmem_w_addr_row_13[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_14_15	=	pe_wmem_w_addr_row_14[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
	assign						pe_wmem_w_addr_15_15	=	pe_wmem_w_addr_row_15[(15+1)*WGT_MEM_ADDR_BITWIDTH-1:15*WGT_MEM_ADDR_BITWIDTH];
//

//
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_0;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_1;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_2;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_3;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_4;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_5;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_6;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_7;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_8;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_9;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_10;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_11;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_12;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_13;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_14;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_3_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_4_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_5_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_6_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_7_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_8_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_9_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_10_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_11_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_12_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_13_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_14_15;
	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_15_15;
//
//
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_0;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_1;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_2;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_3;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_4;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_5;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_6;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_7;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_8;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_9;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_10;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_11;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_12;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_13;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_14;
	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_15;
//
//
	assign						pe_wmem_w_data_row_0      	=   pe_wmem_w_data[(0+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:0*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_1      	=   pe_wmem_w_data[(1+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:1*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_2      	=   pe_wmem_w_data[(2+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:2*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_3      	=   pe_wmem_w_data[(3+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:3*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_4      	=   pe_wmem_w_data[(4+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:4*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_5      	=   pe_wmem_w_data[(5+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:5*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_6      	=   pe_wmem_w_data[(6+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:6*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_7      	=   pe_wmem_w_data[(7+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:7*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_8      	=   pe_wmem_w_data[(8+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:8*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_9      	=   pe_wmem_w_data[(9+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:9*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_10      	=   pe_wmem_w_data[(10+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:10*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_11      	=   pe_wmem_w_data[(11+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:11*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_12      	=   pe_wmem_w_data[(12+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:12*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_13      	=   pe_wmem_w_data[(13+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:13*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_14      	=   pe_wmem_w_data[(14+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:14*WGT_BITWIDTH*ARRAY_DIM_X];
	assign						pe_wmem_w_data_row_15      	=   pe_wmem_w_data[(15+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:15*WGT_BITWIDTH*ARRAY_DIM_X];
//
//
	assign						pe_wmem_w_data_0_0	=	pe_wmem_w_data_row_0[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_0	=	pe_wmem_w_data_row_1[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_0	=	pe_wmem_w_data_row_2[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_0	=	pe_wmem_w_data_row_3[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_0	=	pe_wmem_w_data_row_4[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_0	=	pe_wmem_w_data_row_5[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_0	=	pe_wmem_w_data_row_6[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_0	=	pe_wmem_w_data_row_7[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_0	=	pe_wmem_w_data_row_8[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_0	=	pe_wmem_w_data_row_9[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_0	=	pe_wmem_w_data_row_10[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_0	=	pe_wmem_w_data_row_11[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_0	=	pe_wmem_w_data_row_12[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_0	=	pe_wmem_w_data_row_13[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_0	=	pe_wmem_w_data_row_14[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_0	=	pe_wmem_w_data_row_15[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_1	=	pe_wmem_w_data_row_0[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_1	=	pe_wmem_w_data_row_1[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_1	=	pe_wmem_w_data_row_2[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_1	=	pe_wmem_w_data_row_3[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_1	=	pe_wmem_w_data_row_4[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_1	=	pe_wmem_w_data_row_5[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_1	=	pe_wmem_w_data_row_6[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_1	=	pe_wmem_w_data_row_7[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_1	=	pe_wmem_w_data_row_8[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_1	=	pe_wmem_w_data_row_9[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_1	=	pe_wmem_w_data_row_10[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_1	=	pe_wmem_w_data_row_11[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_1	=	pe_wmem_w_data_row_12[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_1	=	pe_wmem_w_data_row_13[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_1	=	pe_wmem_w_data_row_14[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_1	=	pe_wmem_w_data_row_15[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_2	=	pe_wmem_w_data_row_0[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_2	=	pe_wmem_w_data_row_1[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_2	=	pe_wmem_w_data_row_2[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_2	=	pe_wmem_w_data_row_3[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_2	=	pe_wmem_w_data_row_4[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_2	=	pe_wmem_w_data_row_5[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_2	=	pe_wmem_w_data_row_6[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_2	=	pe_wmem_w_data_row_7[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_2	=	pe_wmem_w_data_row_8[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_2	=	pe_wmem_w_data_row_9[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_2	=	pe_wmem_w_data_row_10[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_2	=	pe_wmem_w_data_row_11[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_2	=	pe_wmem_w_data_row_12[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_2	=	pe_wmem_w_data_row_13[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_2	=	pe_wmem_w_data_row_14[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_2	=	pe_wmem_w_data_row_15[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_3	=	pe_wmem_w_data_row_0[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_3	=	pe_wmem_w_data_row_1[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_3	=	pe_wmem_w_data_row_2[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_3	=	pe_wmem_w_data_row_3[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_3	=	pe_wmem_w_data_row_4[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_3	=	pe_wmem_w_data_row_5[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_3	=	pe_wmem_w_data_row_6[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_3	=	pe_wmem_w_data_row_7[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_3	=	pe_wmem_w_data_row_8[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_3	=	pe_wmem_w_data_row_9[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_3	=	pe_wmem_w_data_row_10[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_3	=	pe_wmem_w_data_row_11[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_3	=	pe_wmem_w_data_row_12[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_3	=	pe_wmem_w_data_row_13[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_3	=	pe_wmem_w_data_row_14[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_3	=	pe_wmem_w_data_row_15[(3+1)*WGT_BITWIDTH-1:3*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_4	=	pe_wmem_w_data_row_0[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_4	=	pe_wmem_w_data_row_1[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_4	=	pe_wmem_w_data_row_2[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_4	=	pe_wmem_w_data_row_3[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_4	=	pe_wmem_w_data_row_4[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_4	=	pe_wmem_w_data_row_5[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_4	=	pe_wmem_w_data_row_6[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_4	=	pe_wmem_w_data_row_7[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_4	=	pe_wmem_w_data_row_8[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_4	=	pe_wmem_w_data_row_9[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_4	=	pe_wmem_w_data_row_10[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_4	=	pe_wmem_w_data_row_11[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_4	=	pe_wmem_w_data_row_12[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_4	=	pe_wmem_w_data_row_13[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_4	=	pe_wmem_w_data_row_14[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_4	=	pe_wmem_w_data_row_15[(4+1)*WGT_BITWIDTH-1:4*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_5	=	pe_wmem_w_data_row_0[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_5	=	pe_wmem_w_data_row_1[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_5	=	pe_wmem_w_data_row_2[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_5	=	pe_wmem_w_data_row_3[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_5	=	pe_wmem_w_data_row_4[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_5	=	pe_wmem_w_data_row_5[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_5	=	pe_wmem_w_data_row_6[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_5	=	pe_wmem_w_data_row_7[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_5	=	pe_wmem_w_data_row_8[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_5	=	pe_wmem_w_data_row_9[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_5	=	pe_wmem_w_data_row_10[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_5	=	pe_wmem_w_data_row_11[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_5	=	pe_wmem_w_data_row_12[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_5	=	pe_wmem_w_data_row_13[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_5	=	pe_wmem_w_data_row_14[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_5	=	pe_wmem_w_data_row_15[(5+1)*WGT_BITWIDTH-1:5*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_6	=	pe_wmem_w_data_row_0[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_6	=	pe_wmem_w_data_row_1[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_6	=	pe_wmem_w_data_row_2[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_6	=	pe_wmem_w_data_row_3[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_6	=	pe_wmem_w_data_row_4[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_6	=	pe_wmem_w_data_row_5[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_6	=	pe_wmem_w_data_row_6[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_6	=	pe_wmem_w_data_row_7[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_6	=	pe_wmem_w_data_row_8[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_6	=	pe_wmem_w_data_row_9[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_6	=	pe_wmem_w_data_row_10[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_6	=	pe_wmem_w_data_row_11[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_6	=	pe_wmem_w_data_row_12[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_6	=	pe_wmem_w_data_row_13[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_6	=	pe_wmem_w_data_row_14[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_6	=	pe_wmem_w_data_row_15[(6+1)*WGT_BITWIDTH-1:6*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_7	=	pe_wmem_w_data_row_0[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_7	=	pe_wmem_w_data_row_1[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_7	=	pe_wmem_w_data_row_2[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_7	=	pe_wmem_w_data_row_3[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_7	=	pe_wmem_w_data_row_4[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_7	=	pe_wmem_w_data_row_5[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_7	=	pe_wmem_w_data_row_6[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_7	=	pe_wmem_w_data_row_7[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_7	=	pe_wmem_w_data_row_8[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_7	=	pe_wmem_w_data_row_9[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_7	=	pe_wmem_w_data_row_10[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_7	=	pe_wmem_w_data_row_11[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_7	=	pe_wmem_w_data_row_12[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_7	=	pe_wmem_w_data_row_13[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_7	=	pe_wmem_w_data_row_14[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_7	=	pe_wmem_w_data_row_15[(7+1)*WGT_BITWIDTH-1:7*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_8	=	pe_wmem_w_data_row_0[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_8	=	pe_wmem_w_data_row_1[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_8	=	pe_wmem_w_data_row_2[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_8	=	pe_wmem_w_data_row_3[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_8	=	pe_wmem_w_data_row_4[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_8	=	pe_wmem_w_data_row_5[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_8	=	pe_wmem_w_data_row_6[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_8	=	pe_wmem_w_data_row_7[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_8	=	pe_wmem_w_data_row_8[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_8	=	pe_wmem_w_data_row_9[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_8	=	pe_wmem_w_data_row_10[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_8	=	pe_wmem_w_data_row_11[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_8	=	pe_wmem_w_data_row_12[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_8	=	pe_wmem_w_data_row_13[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_8	=	pe_wmem_w_data_row_14[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_8	=	pe_wmem_w_data_row_15[(8+1)*WGT_BITWIDTH-1:8*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_9	=	pe_wmem_w_data_row_0[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_9	=	pe_wmem_w_data_row_1[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_9	=	pe_wmem_w_data_row_2[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_9	=	pe_wmem_w_data_row_3[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_9	=	pe_wmem_w_data_row_4[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_9	=	pe_wmem_w_data_row_5[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_9	=	pe_wmem_w_data_row_6[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_9	=	pe_wmem_w_data_row_7[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_9	=	pe_wmem_w_data_row_8[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_9	=	pe_wmem_w_data_row_9[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_9	=	pe_wmem_w_data_row_10[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_9	=	pe_wmem_w_data_row_11[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_9	=	pe_wmem_w_data_row_12[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_9	=	pe_wmem_w_data_row_13[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_9	=	pe_wmem_w_data_row_14[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_9	=	pe_wmem_w_data_row_15[(9+1)*WGT_BITWIDTH-1:9*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_10	=	pe_wmem_w_data_row_0[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_10	=	pe_wmem_w_data_row_1[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_10	=	pe_wmem_w_data_row_2[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_10	=	pe_wmem_w_data_row_3[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_10	=	pe_wmem_w_data_row_4[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_10	=	pe_wmem_w_data_row_5[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_10	=	pe_wmem_w_data_row_6[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_10	=	pe_wmem_w_data_row_7[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_10	=	pe_wmem_w_data_row_8[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_10	=	pe_wmem_w_data_row_9[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_10	=	pe_wmem_w_data_row_10[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_10	=	pe_wmem_w_data_row_11[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_10	=	pe_wmem_w_data_row_12[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_10	=	pe_wmem_w_data_row_13[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_10	=	pe_wmem_w_data_row_14[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_10	=	pe_wmem_w_data_row_15[(10+1)*WGT_BITWIDTH-1:10*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_11	=	pe_wmem_w_data_row_0[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_11	=	pe_wmem_w_data_row_1[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_11	=	pe_wmem_w_data_row_2[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_11	=	pe_wmem_w_data_row_3[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_11	=	pe_wmem_w_data_row_4[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_11	=	pe_wmem_w_data_row_5[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_11	=	pe_wmem_w_data_row_6[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_11	=	pe_wmem_w_data_row_7[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_11	=	pe_wmem_w_data_row_8[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_11	=	pe_wmem_w_data_row_9[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_11	=	pe_wmem_w_data_row_10[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_11	=	pe_wmem_w_data_row_11[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_11	=	pe_wmem_w_data_row_12[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_11	=	pe_wmem_w_data_row_13[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_11	=	pe_wmem_w_data_row_14[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_11	=	pe_wmem_w_data_row_15[(11+1)*WGT_BITWIDTH-1:11*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_12	=	pe_wmem_w_data_row_0[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_12	=	pe_wmem_w_data_row_1[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_12	=	pe_wmem_w_data_row_2[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_12	=	pe_wmem_w_data_row_3[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_12	=	pe_wmem_w_data_row_4[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_12	=	pe_wmem_w_data_row_5[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_12	=	pe_wmem_w_data_row_6[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_12	=	pe_wmem_w_data_row_7[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_12	=	pe_wmem_w_data_row_8[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_12	=	pe_wmem_w_data_row_9[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_12	=	pe_wmem_w_data_row_10[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_12	=	pe_wmem_w_data_row_11[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_12	=	pe_wmem_w_data_row_12[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_12	=	pe_wmem_w_data_row_13[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_12	=	pe_wmem_w_data_row_14[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_12	=	pe_wmem_w_data_row_15[(12+1)*WGT_BITWIDTH-1:12*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_13	=	pe_wmem_w_data_row_0[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_13	=	pe_wmem_w_data_row_1[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_13	=	pe_wmem_w_data_row_2[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_13	=	pe_wmem_w_data_row_3[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_13	=	pe_wmem_w_data_row_4[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_13	=	pe_wmem_w_data_row_5[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_13	=	pe_wmem_w_data_row_6[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_13	=	pe_wmem_w_data_row_7[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_13	=	pe_wmem_w_data_row_8[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_13	=	pe_wmem_w_data_row_9[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_13	=	pe_wmem_w_data_row_10[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_13	=	pe_wmem_w_data_row_11[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_13	=	pe_wmem_w_data_row_12[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_13	=	pe_wmem_w_data_row_13[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_13	=	pe_wmem_w_data_row_14[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_13	=	pe_wmem_w_data_row_15[(13+1)*WGT_BITWIDTH-1:13*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_14	=	pe_wmem_w_data_row_0[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_14	=	pe_wmem_w_data_row_1[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_14	=	pe_wmem_w_data_row_2[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_14	=	pe_wmem_w_data_row_3[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_14	=	pe_wmem_w_data_row_4[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_14	=	pe_wmem_w_data_row_5[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_14	=	pe_wmem_w_data_row_6[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_14	=	pe_wmem_w_data_row_7[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_14	=	pe_wmem_w_data_row_8[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_14	=	pe_wmem_w_data_row_9[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_14	=	pe_wmem_w_data_row_10[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_14	=	pe_wmem_w_data_row_11[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_14	=	pe_wmem_w_data_row_12[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_14	=	pe_wmem_w_data_row_13[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_14	=	pe_wmem_w_data_row_14[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_14	=	pe_wmem_w_data_row_15[(14+1)*WGT_BITWIDTH-1:14*WGT_BITWIDTH];
	assign						pe_wmem_w_data_0_15	=	pe_wmem_w_data_row_0[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_1_15	=	pe_wmem_w_data_row_1[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_2_15	=	pe_wmem_w_data_row_2[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_3_15	=	pe_wmem_w_data_row_3[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_4_15	=	pe_wmem_w_data_row_4[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_5_15	=	pe_wmem_w_data_row_5[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_6_15	=	pe_wmem_w_data_row_6[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_7_15	=	pe_wmem_w_data_row_7[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_8_15	=	pe_wmem_w_data_row_8[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_9_15	=	pe_wmem_w_data_row_9[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_10_15	=	pe_wmem_w_data_row_10[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_11_15	=	pe_wmem_w_data_row_11[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_12_15	=	pe_wmem_w_data_row_12[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_13_15	=	pe_wmem_w_data_row_13[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_14_15	=	pe_wmem_w_data_row_14[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
	assign						pe_wmem_w_data_15_15	=	pe_wmem_w_data_row_15[(15+1)*WGT_BITWIDTH-1:15*WGT_BITWIDTH];
//
//
	wire																	pe_wmem_read_req_0_0;
	wire																	pe_wmem_read_req_1_0;
	wire																	pe_wmem_read_req_2_0;
	wire																	pe_wmem_read_req_3_0;
	wire																	pe_wmem_read_req_4_0;
	wire																	pe_wmem_read_req_5_0;
	wire																	pe_wmem_read_req_6_0;
	wire																	pe_wmem_read_req_7_0;
	wire																	pe_wmem_read_req_8_0;
	wire																	pe_wmem_read_req_9_0;
	wire																	pe_wmem_read_req_10_0;
	wire																	pe_wmem_read_req_11_0;
	wire																	pe_wmem_read_req_12_0;
	wire																	pe_wmem_read_req_13_0;
	wire																	pe_wmem_read_req_14_0;
	wire																	pe_wmem_read_req_15_0;
	wire																	pe_wmem_read_req_0_1;
	wire																	pe_wmem_read_req_1_1;
	wire																	pe_wmem_read_req_2_1;
	wire																	pe_wmem_read_req_3_1;
	wire																	pe_wmem_read_req_4_1;
	wire																	pe_wmem_read_req_5_1;
	wire																	pe_wmem_read_req_6_1;
	wire																	pe_wmem_read_req_7_1;
	wire																	pe_wmem_read_req_8_1;
	wire																	pe_wmem_read_req_9_1;
	wire																	pe_wmem_read_req_10_1;
	wire																	pe_wmem_read_req_11_1;
	wire																	pe_wmem_read_req_12_1;
	wire																	pe_wmem_read_req_13_1;
	wire																	pe_wmem_read_req_14_1;
	wire																	pe_wmem_read_req_15_1;
	wire																	pe_wmem_read_req_0_2;
	wire																	pe_wmem_read_req_1_2;
	wire																	pe_wmem_read_req_2_2;
	wire																	pe_wmem_read_req_3_2;
	wire																	pe_wmem_read_req_4_2;
	wire																	pe_wmem_read_req_5_2;
	wire																	pe_wmem_read_req_6_2;
	wire																	pe_wmem_read_req_7_2;
	wire																	pe_wmem_read_req_8_2;
	wire																	pe_wmem_read_req_9_2;
	wire																	pe_wmem_read_req_10_2;
	wire																	pe_wmem_read_req_11_2;
	wire																	pe_wmem_read_req_12_2;
	wire																	pe_wmem_read_req_13_2;
	wire																	pe_wmem_read_req_14_2;
	wire																	pe_wmem_read_req_15_2;
	wire																	pe_wmem_read_req_0_3;
	wire																	pe_wmem_read_req_1_3;
	wire																	pe_wmem_read_req_2_3;
	wire																	pe_wmem_read_req_3_3;
	wire																	pe_wmem_read_req_4_3;
	wire																	pe_wmem_read_req_5_3;
	wire																	pe_wmem_read_req_6_3;
	wire																	pe_wmem_read_req_7_3;
	wire																	pe_wmem_read_req_8_3;
	wire																	pe_wmem_read_req_9_3;
	wire																	pe_wmem_read_req_10_3;
	wire																	pe_wmem_read_req_11_3;
	wire																	pe_wmem_read_req_12_3;
	wire																	pe_wmem_read_req_13_3;
	wire																	pe_wmem_read_req_14_3;
	wire																	pe_wmem_read_req_15_3;
	wire																	pe_wmem_read_req_0_4;
	wire																	pe_wmem_read_req_1_4;
	wire																	pe_wmem_read_req_2_4;
	wire																	pe_wmem_read_req_3_4;
	wire																	pe_wmem_read_req_4_4;
	wire																	pe_wmem_read_req_5_4;
	wire																	pe_wmem_read_req_6_4;
	wire																	pe_wmem_read_req_7_4;
	wire																	pe_wmem_read_req_8_4;
	wire																	pe_wmem_read_req_9_4;
	wire																	pe_wmem_read_req_10_4;
	wire																	pe_wmem_read_req_11_4;
	wire																	pe_wmem_read_req_12_4;
	wire																	pe_wmem_read_req_13_4;
	wire																	pe_wmem_read_req_14_4;
	wire																	pe_wmem_read_req_15_4;
	wire																	pe_wmem_read_req_0_5;
	wire																	pe_wmem_read_req_1_5;
	wire																	pe_wmem_read_req_2_5;
	wire																	pe_wmem_read_req_3_5;
	wire																	pe_wmem_read_req_4_5;
	wire																	pe_wmem_read_req_5_5;
	wire																	pe_wmem_read_req_6_5;
	wire																	pe_wmem_read_req_7_5;
	wire																	pe_wmem_read_req_8_5;
	wire																	pe_wmem_read_req_9_5;
	wire																	pe_wmem_read_req_10_5;
	wire																	pe_wmem_read_req_11_5;
	wire																	pe_wmem_read_req_12_5;
	wire																	pe_wmem_read_req_13_5;
	wire																	pe_wmem_read_req_14_5;
	wire																	pe_wmem_read_req_15_5;
	wire																	pe_wmem_read_req_0_6;
	wire																	pe_wmem_read_req_1_6;
	wire																	pe_wmem_read_req_2_6;
	wire																	pe_wmem_read_req_3_6;
	wire																	pe_wmem_read_req_4_6;
	wire																	pe_wmem_read_req_5_6;
	wire																	pe_wmem_read_req_6_6;
	wire																	pe_wmem_read_req_7_6;
	wire																	pe_wmem_read_req_8_6;
	wire																	pe_wmem_read_req_9_6;
	wire																	pe_wmem_read_req_10_6;
	wire																	pe_wmem_read_req_11_6;
	wire																	pe_wmem_read_req_12_6;
	wire																	pe_wmem_read_req_13_6;
	wire																	pe_wmem_read_req_14_6;
	wire																	pe_wmem_read_req_15_6;
	wire																	pe_wmem_read_req_0_7;
	wire																	pe_wmem_read_req_1_7;
	wire																	pe_wmem_read_req_2_7;
	wire																	pe_wmem_read_req_3_7;
	wire																	pe_wmem_read_req_4_7;
	wire																	pe_wmem_read_req_5_7;
	wire																	pe_wmem_read_req_6_7;
	wire																	pe_wmem_read_req_7_7;
	wire																	pe_wmem_read_req_8_7;
	wire																	pe_wmem_read_req_9_7;
	wire																	pe_wmem_read_req_10_7;
	wire																	pe_wmem_read_req_11_7;
	wire																	pe_wmem_read_req_12_7;
	wire																	pe_wmem_read_req_13_7;
	wire																	pe_wmem_read_req_14_7;
	wire																	pe_wmem_read_req_15_7;
	wire																	pe_wmem_read_req_0_8;
	wire																	pe_wmem_read_req_1_8;
	wire																	pe_wmem_read_req_2_8;
	wire																	pe_wmem_read_req_3_8;
	wire																	pe_wmem_read_req_4_8;
	wire																	pe_wmem_read_req_5_8;
	wire																	pe_wmem_read_req_6_8;
	wire																	pe_wmem_read_req_7_8;
	wire																	pe_wmem_read_req_8_8;
	wire																	pe_wmem_read_req_9_8;
	wire																	pe_wmem_read_req_10_8;
	wire																	pe_wmem_read_req_11_8;
	wire																	pe_wmem_read_req_12_8;
	wire																	pe_wmem_read_req_13_8;
	wire																	pe_wmem_read_req_14_8;
	wire																	pe_wmem_read_req_15_8;
	wire																	pe_wmem_read_req_0_9;
	wire																	pe_wmem_read_req_1_9;
	wire																	pe_wmem_read_req_2_9;
	wire																	pe_wmem_read_req_3_9;
	wire																	pe_wmem_read_req_4_9;
	wire																	pe_wmem_read_req_5_9;
	wire																	pe_wmem_read_req_6_9;
	wire																	pe_wmem_read_req_7_9;
	wire																	pe_wmem_read_req_8_9;
	wire																	pe_wmem_read_req_9_9;
	wire																	pe_wmem_read_req_10_9;
	wire																	pe_wmem_read_req_11_9;
	wire																	pe_wmem_read_req_12_9;
	wire																	pe_wmem_read_req_13_9;
	wire																	pe_wmem_read_req_14_9;
	wire																	pe_wmem_read_req_15_9;
	wire																	pe_wmem_read_req_0_10;
	wire																	pe_wmem_read_req_1_10;
	wire																	pe_wmem_read_req_2_10;
	wire																	pe_wmem_read_req_3_10;
	wire																	pe_wmem_read_req_4_10;
	wire																	pe_wmem_read_req_5_10;
	wire																	pe_wmem_read_req_6_10;
	wire																	pe_wmem_read_req_7_10;
	wire																	pe_wmem_read_req_8_10;
	wire																	pe_wmem_read_req_9_10;
	wire																	pe_wmem_read_req_10_10;
	wire																	pe_wmem_read_req_11_10;
	wire																	pe_wmem_read_req_12_10;
	wire																	pe_wmem_read_req_13_10;
	wire																	pe_wmem_read_req_14_10;
	wire																	pe_wmem_read_req_15_10;
	wire																	pe_wmem_read_req_0_11;
	wire																	pe_wmem_read_req_1_11;
	wire																	pe_wmem_read_req_2_11;
	wire																	pe_wmem_read_req_3_11;
	wire																	pe_wmem_read_req_4_11;
	wire																	pe_wmem_read_req_5_11;
	wire																	pe_wmem_read_req_6_11;
	wire																	pe_wmem_read_req_7_11;
	wire																	pe_wmem_read_req_8_11;
	wire																	pe_wmem_read_req_9_11;
	wire																	pe_wmem_read_req_10_11;
	wire																	pe_wmem_read_req_11_11;
	wire																	pe_wmem_read_req_12_11;
	wire																	pe_wmem_read_req_13_11;
	wire																	pe_wmem_read_req_14_11;
	wire																	pe_wmem_read_req_15_11;
	wire																	pe_wmem_read_req_0_12;
	wire																	pe_wmem_read_req_1_12;
	wire																	pe_wmem_read_req_2_12;
	wire																	pe_wmem_read_req_3_12;
	wire																	pe_wmem_read_req_4_12;
	wire																	pe_wmem_read_req_5_12;
	wire																	pe_wmem_read_req_6_12;
	wire																	pe_wmem_read_req_7_12;
	wire																	pe_wmem_read_req_8_12;
	wire																	pe_wmem_read_req_9_12;
	wire																	pe_wmem_read_req_10_12;
	wire																	pe_wmem_read_req_11_12;
	wire																	pe_wmem_read_req_12_12;
	wire																	pe_wmem_read_req_13_12;
	wire																	pe_wmem_read_req_14_12;
	wire																	pe_wmem_read_req_15_12;
	wire																	pe_wmem_read_req_0_13;
	wire																	pe_wmem_read_req_1_13;
	wire																	pe_wmem_read_req_2_13;
	wire																	pe_wmem_read_req_3_13;
	wire																	pe_wmem_read_req_4_13;
	wire																	pe_wmem_read_req_5_13;
	wire																	pe_wmem_read_req_6_13;
	wire																	pe_wmem_read_req_7_13;
	wire																	pe_wmem_read_req_8_13;
	wire																	pe_wmem_read_req_9_13;
	wire																	pe_wmem_read_req_10_13;
	wire																	pe_wmem_read_req_11_13;
	wire																	pe_wmem_read_req_12_13;
	wire																	pe_wmem_read_req_13_13;
	wire																	pe_wmem_read_req_14_13;
	wire																	pe_wmem_read_req_15_13;
	wire																	pe_wmem_read_req_0_14;
	wire																	pe_wmem_read_req_1_14;
	wire																	pe_wmem_read_req_2_14;
	wire																	pe_wmem_read_req_3_14;
	wire																	pe_wmem_read_req_4_14;
	wire																	pe_wmem_read_req_5_14;
	wire																	pe_wmem_read_req_6_14;
	wire																	pe_wmem_read_req_7_14;
	wire																	pe_wmem_read_req_8_14;
	wire																	pe_wmem_read_req_9_14;
	wire																	pe_wmem_read_req_10_14;
	wire																	pe_wmem_read_req_11_14;
	wire																	pe_wmem_read_req_12_14;
	wire																	pe_wmem_read_req_13_14;
	wire																	pe_wmem_read_req_14_14;
	wire																	pe_wmem_read_req_15_14;
	wire																	pe_wmem_read_req_0_15;
	wire																	pe_wmem_read_req_1_15;
	wire																	pe_wmem_read_req_2_15;
	wire																	pe_wmem_read_req_3_15;
	wire																	pe_wmem_read_req_4_15;
	wire																	pe_wmem_read_req_5_15;
	wire																	pe_wmem_read_req_6_15;
	wire																	pe_wmem_read_req_7_15;
	wire																	pe_wmem_read_req_8_15;
	wire																	pe_wmem_read_req_9_15;
	wire																	pe_wmem_read_req_10_15;
	wire																	pe_wmem_read_req_11_15;
	wire																	pe_wmem_read_req_12_15;
	wire																	pe_wmem_read_req_13_15;
	wire																	pe_wmem_read_req_14_15;
	wire																	pe_wmem_read_req_15_15;
//
//
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_0;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_1;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_2;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_3;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_4;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_5;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_6;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_7;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_8;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_9;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_10;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_11;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_12;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_13;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_14;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_15;
//
//
	assign						pe_wmem_read_req_row_0      	=   pe_wmem_read_req[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_1      	=   pe_wmem_read_req[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_2      	=   pe_wmem_read_req[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_3      	=   pe_wmem_read_req[(3+1)*ARRAY_DIM_X-1:3*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_4      	=   pe_wmem_read_req[(4+1)*ARRAY_DIM_X-1:4*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_5      	=   pe_wmem_read_req[(5+1)*ARRAY_DIM_X-1:5*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_6      	=   pe_wmem_read_req[(6+1)*ARRAY_DIM_X-1:6*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_7      	=   pe_wmem_read_req[(7+1)*ARRAY_DIM_X-1:7*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_8      	=   pe_wmem_read_req[(8+1)*ARRAY_DIM_X-1:8*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_9      	=   pe_wmem_read_req[(9+1)*ARRAY_DIM_X-1:9*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_10      	=   pe_wmem_read_req[(10+1)*ARRAY_DIM_X-1:10*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_11      	=   pe_wmem_read_req[(11+1)*ARRAY_DIM_X-1:11*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_12      	=   pe_wmem_read_req[(12+1)*ARRAY_DIM_X-1:12*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_13      	=   pe_wmem_read_req[(13+1)*ARRAY_DIM_X-1:13*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_14      	=   pe_wmem_read_req[(14+1)*ARRAY_DIM_X-1:14*ARRAY_DIM_X];
	assign						pe_wmem_read_req_row_15      	=   pe_wmem_read_req[(15+1)*ARRAY_DIM_X-1:15*ARRAY_DIM_X];
//
//
	assign						pe_wmem_read_req_0_0 =	pe_wmem_read_req_row_0[(0+1)-1:0];
	assign						pe_wmem_read_req_1_0 =	pe_wmem_read_req_row_1[(0+1)-1:0];
	assign						pe_wmem_read_req_2_0 =	pe_wmem_read_req_row_2[(0+1)-1:0];
	assign						pe_wmem_read_req_3_0 =	pe_wmem_read_req_row_3[(0+1)-1:0];
	assign						pe_wmem_read_req_4_0 =	pe_wmem_read_req_row_4[(0+1)-1:0];
	assign						pe_wmem_read_req_5_0 =	pe_wmem_read_req_row_5[(0+1)-1:0];
	assign						pe_wmem_read_req_6_0 =	pe_wmem_read_req_row_6[(0+1)-1:0];
	assign						pe_wmem_read_req_7_0 =	pe_wmem_read_req_row_7[(0+1)-1:0];
	assign						pe_wmem_read_req_8_0 =	pe_wmem_read_req_row_8[(0+1)-1:0];
	assign						pe_wmem_read_req_9_0 =	pe_wmem_read_req_row_9[(0+1)-1:0];
	assign						pe_wmem_read_req_10_0 =	pe_wmem_read_req_row_10[(0+1)-1:0];
	assign						pe_wmem_read_req_11_0 =	pe_wmem_read_req_row_11[(0+1)-1:0];
	assign						pe_wmem_read_req_12_0 =	pe_wmem_read_req_row_12[(0+1)-1:0];
	assign						pe_wmem_read_req_13_0 =	pe_wmem_read_req_row_13[(0+1)-1:0];
	assign						pe_wmem_read_req_14_0 =	pe_wmem_read_req_row_14[(0+1)-1:0];
	assign						pe_wmem_read_req_15_0 =	pe_wmem_read_req_row_15[(0+1)-1:0];
	assign						pe_wmem_read_req_0_1 =	pe_wmem_read_req_row_0[(1+1)-1:1];
	assign						pe_wmem_read_req_1_1 =	pe_wmem_read_req_row_1[(1+1)-1:1];
	assign						pe_wmem_read_req_2_1 =	pe_wmem_read_req_row_2[(1+1)-1:1];
	assign						pe_wmem_read_req_3_1 =	pe_wmem_read_req_row_3[(1+1)-1:1];
	assign						pe_wmem_read_req_4_1 =	pe_wmem_read_req_row_4[(1+1)-1:1];
	assign						pe_wmem_read_req_5_1 =	pe_wmem_read_req_row_5[(1+1)-1:1];
	assign						pe_wmem_read_req_6_1 =	pe_wmem_read_req_row_6[(1+1)-1:1];
	assign						pe_wmem_read_req_7_1 =	pe_wmem_read_req_row_7[(1+1)-1:1];
	assign						pe_wmem_read_req_8_1 =	pe_wmem_read_req_row_8[(1+1)-1:1];
	assign						pe_wmem_read_req_9_1 =	pe_wmem_read_req_row_9[(1+1)-1:1];
	assign						pe_wmem_read_req_10_1 =	pe_wmem_read_req_row_10[(1+1)-1:1];
	assign						pe_wmem_read_req_11_1 =	pe_wmem_read_req_row_11[(1+1)-1:1];
	assign						pe_wmem_read_req_12_1 =	pe_wmem_read_req_row_12[(1+1)-1:1];
	assign						pe_wmem_read_req_13_1 =	pe_wmem_read_req_row_13[(1+1)-1:1];
	assign						pe_wmem_read_req_14_1 =	pe_wmem_read_req_row_14[(1+1)-1:1];
	assign						pe_wmem_read_req_15_1 =	pe_wmem_read_req_row_15[(1+1)-1:1];
	assign						pe_wmem_read_req_0_2 =	pe_wmem_read_req_row_0[(2+1)-1:2];
	assign						pe_wmem_read_req_1_2 =	pe_wmem_read_req_row_1[(2+1)-1:2];
	assign						pe_wmem_read_req_2_2 =	pe_wmem_read_req_row_2[(2+1)-1:2];
	assign						pe_wmem_read_req_3_2 =	pe_wmem_read_req_row_3[(2+1)-1:2];
	assign						pe_wmem_read_req_4_2 =	pe_wmem_read_req_row_4[(2+1)-1:2];
	assign						pe_wmem_read_req_5_2 =	pe_wmem_read_req_row_5[(2+1)-1:2];
	assign						pe_wmem_read_req_6_2 =	pe_wmem_read_req_row_6[(2+1)-1:2];
	assign						pe_wmem_read_req_7_2 =	pe_wmem_read_req_row_7[(2+1)-1:2];
	assign						pe_wmem_read_req_8_2 =	pe_wmem_read_req_row_8[(2+1)-1:2];
	assign						pe_wmem_read_req_9_2 =	pe_wmem_read_req_row_9[(2+1)-1:2];
	assign						pe_wmem_read_req_10_2 =	pe_wmem_read_req_row_10[(2+1)-1:2];
	assign						pe_wmem_read_req_11_2 =	pe_wmem_read_req_row_11[(2+1)-1:2];
	assign						pe_wmem_read_req_12_2 =	pe_wmem_read_req_row_12[(2+1)-1:2];
	assign						pe_wmem_read_req_13_2 =	pe_wmem_read_req_row_13[(2+1)-1:2];
	assign						pe_wmem_read_req_14_2 =	pe_wmem_read_req_row_14[(2+1)-1:2];
	assign						pe_wmem_read_req_15_2 =	pe_wmem_read_req_row_15[(2+1)-1:2];
	assign						pe_wmem_read_req_0_3 =	pe_wmem_read_req_row_0[(3+1)-1:3];
	assign						pe_wmem_read_req_1_3 =	pe_wmem_read_req_row_1[(3+1)-1:3];
	assign						pe_wmem_read_req_2_3 =	pe_wmem_read_req_row_2[(3+1)-1:3];
	assign						pe_wmem_read_req_3_3 =	pe_wmem_read_req_row_3[(3+1)-1:3];
	assign						pe_wmem_read_req_4_3 =	pe_wmem_read_req_row_4[(3+1)-1:3];
	assign						pe_wmem_read_req_5_3 =	pe_wmem_read_req_row_5[(3+1)-1:3];
	assign						pe_wmem_read_req_6_3 =	pe_wmem_read_req_row_6[(3+1)-1:3];
	assign						pe_wmem_read_req_7_3 =	pe_wmem_read_req_row_7[(3+1)-1:3];
	assign						pe_wmem_read_req_8_3 =	pe_wmem_read_req_row_8[(3+1)-1:3];
	assign						pe_wmem_read_req_9_3 =	pe_wmem_read_req_row_9[(3+1)-1:3];
	assign						pe_wmem_read_req_10_3 =	pe_wmem_read_req_row_10[(3+1)-1:3];
	assign						pe_wmem_read_req_11_3 =	pe_wmem_read_req_row_11[(3+1)-1:3];
	assign						pe_wmem_read_req_12_3 =	pe_wmem_read_req_row_12[(3+1)-1:3];
	assign						pe_wmem_read_req_13_3 =	pe_wmem_read_req_row_13[(3+1)-1:3];
	assign						pe_wmem_read_req_14_3 =	pe_wmem_read_req_row_14[(3+1)-1:3];
	assign						pe_wmem_read_req_15_3 =	pe_wmem_read_req_row_15[(3+1)-1:3];
	assign						pe_wmem_read_req_0_4 =	pe_wmem_read_req_row_0[(4+1)-1:4];
	assign						pe_wmem_read_req_1_4 =	pe_wmem_read_req_row_1[(4+1)-1:4];
	assign						pe_wmem_read_req_2_4 =	pe_wmem_read_req_row_2[(4+1)-1:4];
	assign						pe_wmem_read_req_3_4 =	pe_wmem_read_req_row_3[(4+1)-1:4];
	assign						pe_wmem_read_req_4_4 =	pe_wmem_read_req_row_4[(4+1)-1:4];
	assign						pe_wmem_read_req_5_4 =	pe_wmem_read_req_row_5[(4+1)-1:4];
	assign						pe_wmem_read_req_6_4 =	pe_wmem_read_req_row_6[(4+1)-1:4];
	assign						pe_wmem_read_req_7_4 =	pe_wmem_read_req_row_7[(4+1)-1:4];
	assign						pe_wmem_read_req_8_4 =	pe_wmem_read_req_row_8[(4+1)-1:4];
	assign						pe_wmem_read_req_9_4 =	pe_wmem_read_req_row_9[(4+1)-1:4];
	assign						pe_wmem_read_req_10_4 =	pe_wmem_read_req_row_10[(4+1)-1:4];
	assign						pe_wmem_read_req_11_4 =	pe_wmem_read_req_row_11[(4+1)-1:4];
	assign						pe_wmem_read_req_12_4 =	pe_wmem_read_req_row_12[(4+1)-1:4];
	assign						pe_wmem_read_req_13_4 =	pe_wmem_read_req_row_13[(4+1)-1:4];
	assign						pe_wmem_read_req_14_4 =	pe_wmem_read_req_row_14[(4+1)-1:4];
	assign						pe_wmem_read_req_15_4 =	pe_wmem_read_req_row_15[(4+1)-1:4];
	assign						pe_wmem_read_req_0_5 =	pe_wmem_read_req_row_0[(5+1)-1:5];
	assign						pe_wmem_read_req_1_5 =	pe_wmem_read_req_row_1[(5+1)-1:5];
	assign						pe_wmem_read_req_2_5 =	pe_wmem_read_req_row_2[(5+1)-1:5];
	assign						pe_wmem_read_req_3_5 =	pe_wmem_read_req_row_3[(5+1)-1:5];
	assign						pe_wmem_read_req_4_5 =	pe_wmem_read_req_row_4[(5+1)-1:5];
	assign						pe_wmem_read_req_5_5 =	pe_wmem_read_req_row_5[(5+1)-1:5];
	assign						pe_wmem_read_req_6_5 =	pe_wmem_read_req_row_6[(5+1)-1:5];
	assign						pe_wmem_read_req_7_5 =	pe_wmem_read_req_row_7[(5+1)-1:5];
	assign						pe_wmem_read_req_8_5 =	pe_wmem_read_req_row_8[(5+1)-1:5];
	assign						pe_wmem_read_req_9_5 =	pe_wmem_read_req_row_9[(5+1)-1:5];
	assign						pe_wmem_read_req_10_5 =	pe_wmem_read_req_row_10[(5+1)-1:5];
	assign						pe_wmem_read_req_11_5 =	pe_wmem_read_req_row_11[(5+1)-1:5];
	assign						pe_wmem_read_req_12_5 =	pe_wmem_read_req_row_12[(5+1)-1:5];
	assign						pe_wmem_read_req_13_5 =	pe_wmem_read_req_row_13[(5+1)-1:5];
	assign						pe_wmem_read_req_14_5 =	pe_wmem_read_req_row_14[(5+1)-1:5];
	assign						pe_wmem_read_req_15_5 =	pe_wmem_read_req_row_15[(5+1)-1:5];
	assign						pe_wmem_read_req_0_6 =	pe_wmem_read_req_row_0[(6+1)-1:6];
	assign						pe_wmem_read_req_1_6 =	pe_wmem_read_req_row_1[(6+1)-1:6];
	assign						pe_wmem_read_req_2_6 =	pe_wmem_read_req_row_2[(6+1)-1:6];
	assign						pe_wmem_read_req_3_6 =	pe_wmem_read_req_row_3[(6+1)-1:6];
	assign						pe_wmem_read_req_4_6 =	pe_wmem_read_req_row_4[(6+1)-1:6];
	assign						pe_wmem_read_req_5_6 =	pe_wmem_read_req_row_5[(6+1)-1:6];
	assign						pe_wmem_read_req_6_6 =	pe_wmem_read_req_row_6[(6+1)-1:6];
	assign						pe_wmem_read_req_7_6 =	pe_wmem_read_req_row_7[(6+1)-1:6];
	assign						pe_wmem_read_req_8_6 =	pe_wmem_read_req_row_8[(6+1)-1:6];
	assign						pe_wmem_read_req_9_6 =	pe_wmem_read_req_row_9[(6+1)-1:6];
	assign						pe_wmem_read_req_10_6 =	pe_wmem_read_req_row_10[(6+1)-1:6];
	assign						pe_wmem_read_req_11_6 =	pe_wmem_read_req_row_11[(6+1)-1:6];
	assign						pe_wmem_read_req_12_6 =	pe_wmem_read_req_row_12[(6+1)-1:6];
	assign						pe_wmem_read_req_13_6 =	pe_wmem_read_req_row_13[(6+1)-1:6];
	assign						pe_wmem_read_req_14_6 =	pe_wmem_read_req_row_14[(6+1)-1:6];
	assign						pe_wmem_read_req_15_6 =	pe_wmem_read_req_row_15[(6+1)-1:6];
	assign						pe_wmem_read_req_0_7 =	pe_wmem_read_req_row_0[(7+1)-1:7];
	assign						pe_wmem_read_req_1_7 =	pe_wmem_read_req_row_1[(7+1)-1:7];
	assign						pe_wmem_read_req_2_7 =	pe_wmem_read_req_row_2[(7+1)-1:7];
	assign						pe_wmem_read_req_3_7 =	pe_wmem_read_req_row_3[(7+1)-1:7];
	assign						pe_wmem_read_req_4_7 =	pe_wmem_read_req_row_4[(7+1)-1:7];
	assign						pe_wmem_read_req_5_7 =	pe_wmem_read_req_row_5[(7+1)-1:7];
	assign						pe_wmem_read_req_6_7 =	pe_wmem_read_req_row_6[(7+1)-1:7];
	assign						pe_wmem_read_req_7_7 =	pe_wmem_read_req_row_7[(7+1)-1:7];
	assign						pe_wmem_read_req_8_7 =	pe_wmem_read_req_row_8[(7+1)-1:7];
	assign						pe_wmem_read_req_9_7 =	pe_wmem_read_req_row_9[(7+1)-1:7];
	assign						pe_wmem_read_req_10_7 =	pe_wmem_read_req_row_10[(7+1)-1:7];
	assign						pe_wmem_read_req_11_7 =	pe_wmem_read_req_row_11[(7+1)-1:7];
	assign						pe_wmem_read_req_12_7 =	pe_wmem_read_req_row_12[(7+1)-1:7];
	assign						pe_wmem_read_req_13_7 =	pe_wmem_read_req_row_13[(7+1)-1:7];
	assign						pe_wmem_read_req_14_7 =	pe_wmem_read_req_row_14[(7+1)-1:7];
	assign						pe_wmem_read_req_15_7 =	pe_wmem_read_req_row_15[(7+1)-1:7];
	assign						pe_wmem_read_req_0_8 =	pe_wmem_read_req_row_0[(8+1)-1:8];
	assign						pe_wmem_read_req_1_8 =	pe_wmem_read_req_row_1[(8+1)-1:8];
	assign						pe_wmem_read_req_2_8 =	pe_wmem_read_req_row_2[(8+1)-1:8];
	assign						pe_wmem_read_req_3_8 =	pe_wmem_read_req_row_3[(8+1)-1:8];
	assign						pe_wmem_read_req_4_8 =	pe_wmem_read_req_row_4[(8+1)-1:8];
	assign						pe_wmem_read_req_5_8 =	pe_wmem_read_req_row_5[(8+1)-1:8];
	assign						pe_wmem_read_req_6_8 =	pe_wmem_read_req_row_6[(8+1)-1:8];
	assign						pe_wmem_read_req_7_8 =	pe_wmem_read_req_row_7[(8+1)-1:8];
	assign						pe_wmem_read_req_8_8 =	pe_wmem_read_req_row_8[(8+1)-1:8];
	assign						pe_wmem_read_req_9_8 =	pe_wmem_read_req_row_9[(8+1)-1:8];
	assign						pe_wmem_read_req_10_8 =	pe_wmem_read_req_row_10[(8+1)-1:8];
	assign						pe_wmem_read_req_11_8 =	pe_wmem_read_req_row_11[(8+1)-1:8];
	assign						pe_wmem_read_req_12_8 =	pe_wmem_read_req_row_12[(8+1)-1:8];
	assign						pe_wmem_read_req_13_8 =	pe_wmem_read_req_row_13[(8+1)-1:8];
	assign						pe_wmem_read_req_14_8 =	pe_wmem_read_req_row_14[(8+1)-1:8];
	assign						pe_wmem_read_req_15_8 =	pe_wmem_read_req_row_15[(8+1)-1:8];
	assign						pe_wmem_read_req_0_9 =	pe_wmem_read_req_row_0[(9+1)-1:9];
	assign						pe_wmem_read_req_1_9 =	pe_wmem_read_req_row_1[(9+1)-1:9];
	assign						pe_wmem_read_req_2_9 =	pe_wmem_read_req_row_2[(9+1)-1:9];
	assign						pe_wmem_read_req_3_9 =	pe_wmem_read_req_row_3[(9+1)-1:9];
	assign						pe_wmem_read_req_4_9 =	pe_wmem_read_req_row_4[(9+1)-1:9];
	assign						pe_wmem_read_req_5_9 =	pe_wmem_read_req_row_5[(9+1)-1:9];
	assign						pe_wmem_read_req_6_9 =	pe_wmem_read_req_row_6[(9+1)-1:9];
	assign						pe_wmem_read_req_7_9 =	pe_wmem_read_req_row_7[(9+1)-1:9];
	assign						pe_wmem_read_req_8_9 =	pe_wmem_read_req_row_8[(9+1)-1:9];
	assign						pe_wmem_read_req_9_9 =	pe_wmem_read_req_row_9[(9+1)-1:9];
	assign						pe_wmem_read_req_10_9 =	pe_wmem_read_req_row_10[(9+1)-1:9];
	assign						pe_wmem_read_req_11_9 =	pe_wmem_read_req_row_11[(9+1)-1:9];
	assign						pe_wmem_read_req_12_9 =	pe_wmem_read_req_row_12[(9+1)-1:9];
	assign						pe_wmem_read_req_13_9 =	pe_wmem_read_req_row_13[(9+1)-1:9];
	assign						pe_wmem_read_req_14_9 =	pe_wmem_read_req_row_14[(9+1)-1:9];
	assign						pe_wmem_read_req_15_9 =	pe_wmem_read_req_row_15[(9+1)-1:9];
	assign						pe_wmem_read_req_0_10 =	pe_wmem_read_req_row_0[(10+1)-1:10];
	assign						pe_wmem_read_req_1_10 =	pe_wmem_read_req_row_1[(10+1)-1:10];
	assign						pe_wmem_read_req_2_10 =	pe_wmem_read_req_row_2[(10+1)-1:10];
	assign						pe_wmem_read_req_3_10 =	pe_wmem_read_req_row_3[(10+1)-1:10];
	assign						pe_wmem_read_req_4_10 =	pe_wmem_read_req_row_4[(10+1)-1:10];
	assign						pe_wmem_read_req_5_10 =	pe_wmem_read_req_row_5[(10+1)-1:10];
	assign						pe_wmem_read_req_6_10 =	pe_wmem_read_req_row_6[(10+1)-1:10];
	assign						pe_wmem_read_req_7_10 =	pe_wmem_read_req_row_7[(10+1)-1:10];
	assign						pe_wmem_read_req_8_10 =	pe_wmem_read_req_row_8[(10+1)-1:10];
	assign						pe_wmem_read_req_9_10 =	pe_wmem_read_req_row_9[(10+1)-1:10];
	assign						pe_wmem_read_req_10_10 =	pe_wmem_read_req_row_10[(10+1)-1:10];
	assign						pe_wmem_read_req_11_10 =	pe_wmem_read_req_row_11[(10+1)-1:10];
	assign						pe_wmem_read_req_12_10 =	pe_wmem_read_req_row_12[(10+1)-1:10];
	assign						pe_wmem_read_req_13_10 =	pe_wmem_read_req_row_13[(10+1)-1:10];
	assign						pe_wmem_read_req_14_10 =	pe_wmem_read_req_row_14[(10+1)-1:10];
	assign						pe_wmem_read_req_15_10 =	pe_wmem_read_req_row_15[(10+1)-1:10];
	assign						pe_wmem_read_req_0_11 =	pe_wmem_read_req_row_0[(11+1)-1:11];
	assign						pe_wmem_read_req_1_11 =	pe_wmem_read_req_row_1[(11+1)-1:11];
	assign						pe_wmem_read_req_2_11 =	pe_wmem_read_req_row_2[(11+1)-1:11];
	assign						pe_wmem_read_req_3_11 =	pe_wmem_read_req_row_3[(11+1)-1:11];
	assign						pe_wmem_read_req_4_11 =	pe_wmem_read_req_row_4[(11+1)-1:11];
	assign						pe_wmem_read_req_5_11 =	pe_wmem_read_req_row_5[(11+1)-1:11];
	assign						pe_wmem_read_req_6_11 =	pe_wmem_read_req_row_6[(11+1)-1:11];
	assign						pe_wmem_read_req_7_11 =	pe_wmem_read_req_row_7[(11+1)-1:11];
	assign						pe_wmem_read_req_8_11 =	pe_wmem_read_req_row_8[(11+1)-1:11];
	assign						pe_wmem_read_req_9_11 =	pe_wmem_read_req_row_9[(11+1)-1:11];
	assign						pe_wmem_read_req_10_11 =	pe_wmem_read_req_row_10[(11+1)-1:11];
	assign						pe_wmem_read_req_11_11 =	pe_wmem_read_req_row_11[(11+1)-1:11];
	assign						pe_wmem_read_req_12_11 =	pe_wmem_read_req_row_12[(11+1)-1:11];
	assign						pe_wmem_read_req_13_11 =	pe_wmem_read_req_row_13[(11+1)-1:11];
	assign						pe_wmem_read_req_14_11 =	pe_wmem_read_req_row_14[(11+1)-1:11];
	assign						pe_wmem_read_req_15_11 =	pe_wmem_read_req_row_15[(11+1)-1:11];
	assign						pe_wmem_read_req_0_12 =	pe_wmem_read_req_row_0[(12+1)-1:12];
	assign						pe_wmem_read_req_1_12 =	pe_wmem_read_req_row_1[(12+1)-1:12];
	assign						pe_wmem_read_req_2_12 =	pe_wmem_read_req_row_2[(12+1)-1:12];
	assign						pe_wmem_read_req_3_12 =	pe_wmem_read_req_row_3[(12+1)-1:12];
	assign						pe_wmem_read_req_4_12 =	pe_wmem_read_req_row_4[(12+1)-1:12];
	assign						pe_wmem_read_req_5_12 =	pe_wmem_read_req_row_5[(12+1)-1:12];
	assign						pe_wmem_read_req_6_12 =	pe_wmem_read_req_row_6[(12+1)-1:12];
	assign						pe_wmem_read_req_7_12 =	pe_wmem_read_req_row_7[(12+1)-1:12];
	assign						pe_wmem_read_req_8_12 =	pe_wmem_read_req_row_8[(12+1)-1:12];
	assign						pe_wmem_read_req_9_12 =	pe_wmem_read_req_row_9[(12+1)-1:12];
	assign						pe_wmem_read_req_10_12 =	pe_wmem_read_req_row_10[(12+1)-1:12];
	assign						pe_wmem_read_req_11_12 =	pe_wmem_read_req_row_11[(12+1)-1:12];
	assign						pe_wmem_read_req_12_12 =	pe_wmem_read_req_row_12[(12+1)-1:12];
	assign						pe_wmem_read_req_13_12 =	pe_wmem_read_req_row_13[(12+1)-1:12];
	assign						pe_wmem_read_req_14_12 =	pe_wmem_read_req_row_14[(12+1)-1:12];
	assign						pe_wmem_read_req_15_12 =	pe_wmem_read_req_row_15[(12+1)-1:12];
	assign						pe_wmem_read_req_0_13 =	pe_wmem_read_req_row_0[(13+1)-1:13];
	assign						pe_wmem_read_req_1_13 =	pe_wmem_read_req_row_1[(13+1)-1:13];
	assign						pe_wmem_read_req_2_13 =	pe_wmem_read_req_row_2[(13+1)-1:13];
	assign						pe_wmem_read_req_3_13 =	pe_wmem_read_req_row_3[(13+1)-1:13];
	assign						pe_wmem_read_req_4_13 =	pe_wmem_read_req_row_4[(13+1)-1:13];
	assign						pe_wmem_read_req_5_13 =	pe_wmem_read_req_row_5[(13+1)-1:13];
	assign						pe_wmem_read_req_6_13 =	pe_wmem_read_req_row_6[(13+1)-1:13];
	assign						pe_wmem_read_req_7_13 =	pe_wmem_read_req_row_7[(13+1)-1:13];
	assign						pe_wmem_read_req_8_13 =	pe_wmem_read_req_row_8[(13+1)-1:13];
	assign						pe_wmem_read_req_9_13 =	pe_wmem_read_req_row_9[(13+1)-1:13];
	assign						pe_wmem_read_req_10_13 =	pe_wmem_read_req_row_10[(13+1)-1:13];
	assign						pe_wmem_read_req_11_13 =	pe_wmem_read_req_row_11[(13+1)-1:13];
	assign						pe_wmem_read_req_12_13 =	pe_wmem_read_req_row_12[(13+1)-1:13];
	assign						pe_wmem_read_req_13_13 =	pe_wmem_read_req_row_13[(13+1)-1:13];
	assign						pe_wmem_read_req_14_13 =	pe_wmem_read_req_row_14[(13+1)-1:13];
	assign						pe_wmem_read_req_15_13 =	pe_wmem_read_req_row_15[(13+1)-1:13];
	assign						pe_wmem_read_req_0_14 =	pe_wmem_read_req_row_0[(14+1)-1:14];
	assign						pe_wmem_read_req_1_14 =	pe_wmem_read_req_row_1[(14+1)-1:14];
	assign						pe_wmem_read_req_2_14 =	pe_wmem_read_req_row_2[(14+1)-1:14];
	assign						pe_wmem_read_req_3_14 =	pe_wmem_read_req_row_3[(14+1)-1:14];
	assign						pe_wmem_read_req_4_14 =	pe_wmem_read_req_row_4[(14+1)-1:14];
	assign						pe_wmem_read_req_5_14 =	pe_wmem_read_req_row_5[(14+1)-1:14];
	assign						pe_wmem_read_req_6_14 =	pe_wmem_read_req_row_6[(14+1)-1:14];
	assign						pe_wmem_read_req_7_14 =	pe_wmem_read_req_row_7[(14+1)-1:14];
	assign						pe_wmem_read_req_8_14 =	pe_wmem_read_req_row_8[(14+1)-1:14];
	assign						pe_wmem_read_req_9_14 =	pe_wmem_read_req_row_9[(14+1)-1:14];
	assign						pe_wmem_read_req_10_14 =	pe_wmem_read_req_row_10[(14+1)-1:14];
	assign						pe_wmem_read_req_11_14 =	pe_wmem_read_req_row_11[(14+1)-1:14];
	assign						pe_wmem_read_req_12_14 =	pe_wmem_read_req_row_12[(14+1)-1:14];
	assign						pe_wmem_read_req_13_14 =	pe_wmem_read_req_row_13[(14+1)-1:14];
	assign						pe_wmem_read_req_14_14 =	pe_wmem_read_req_row_14[(14+1)-1:14];
	assign						pe_wmem_read_req_15_14 =	pe_wmem_read_req_row_15[(14+1)-1:14];
	assign						pe_wmem_read_req_0_15 =	pe_wmem_read_req_row_0[(15+1)-1:15];
	assign						pe_wmem_read_req_1_15 =	pe_wmem_read_req_row_1[(15+1)-1:15];
	assign						pe_wmem_read_req_2_15 =	pe_wmem_read_req_row_2[(15+1)-1:15];
	assign						pe_wmem_read_req_3_15 =	pe_wmem_read_req_row_3[(15+1)-1:15];
	assign						pe_wmem_read_req_4_15 =	pe_wmem_read_req_row_4[(15+1)-1:15];
	assign						pe_wmem_read_req_5_15 =	pe_wmem_read_req_row_5[(15+1)-1:15];
	assign						pe_wmem_read_req_6_15 =	pe_wmem_read_req_row_6[(15+1)-1:15];
	assign						pe_wmem_read_req_7_15 =	pe_wmem_read_req_row_7[(15+1)-1:15];
	assign						pe_wmem_read_req_8_15 =	pe_wmem_read_req_row_8[(15+1)-1:15];
	assign						pe_wmem_read_req_9_15 =	pe_wmem_read_req_row_9[(15+1)-1:15];
	assign						pe_wmem_read_req_10_15 =	pe_wmem_read_req_row_10[(15+1)-1:15];
	assign						pe_wmem_read_req_11_15 =	pe_wmem_read_req_row_11[(15+1)-1:15];
	assign						pe_wmem_read_req_12_15 =	pe_wmem_read_req_row_12[(15+1)-1:15];
	assign						pe_wmem_read_req_13_15 =	pe_wmem_read_req_row_13[(15+1)-1:15];
	assign						pe_wmem_read_req_14_15 =	pe_wmem_read_req_row_14[(15+1)-1:15];
	assign						pe_wmem_read_req_15_15 =	pe_wmem_read_req_row_15[(15+1)-1:15];
//
//
	wire																	pe_wmem_write_req_0_0;
	wire																	pe_wmem_write_req_1_0;
	wire																	pe_wmem_write_req_2_0;
	wire																	pe_wmem_write_req_3_0;
	wire																	pe_wmem_write_req_4_0;
	wire																	pe_wmem_write_req_5_0;
	wire																	pe_wmem_write_req_6_0;
	wire																	pe_wmem_write_req_7_0;
	wire																	pe_wmem_write_req_8_0;
	wire																	pe_wmem_write_req_9_0;
	wire																	pe_wmem_write_req_10_0;
	wire																	pe_wmem_write_req_11_0;
	wire																	pe_wmem_write_req_12_0;
	wire																	pe_wmem_write_req_13_0;
	wire																	pe_wmem_write_req_14_0;
	wire																	pe_wmem_write_req_15_0;
	wire																	pe_wmem_write_req_0_1;
	wire																	pe_wmem_write_req_1_1;
	wire																	pe_wmem_write_req_2_1;
	wire																	pe_wmem_write_req_3_1;
	wire																	pe_wmem_write_req_4_1;
	wire																	pe_wmem_write_req_5_1;
	wire																	pe_wmem_write_req_6_1;
	wire																	pe_wmem_write_req_7_1;
	wire																	pe_wmem_write_req_8_1;
	wire																	pe_wmem_write_req_9_1;
	wire																	pe_wmem_write_req_10_1;
	wire																	pe_wmem_write_req_11_1;
	wire																	pe_wmem_write_req_12_1;
	wire																	pe_wmem_write_req_13_1;
	wire																	pe_wmem_write_req_14_1;
	wire																	pe_wmem_write_req_15_1;
	wire																	pe_wmem_write_req_0_2;
	wire																	pe_wmem_write_req_1_2;
	wire																	pe_wmem_write_req_2_2;
	wire																	pe_wmem_write_req_3_2;
	wire																	pe_wmem_write_req_4_2;
	wire																	pe_wmem_write_req_5_2;
	wire																	pe_wmem_write_req_6_2;
	wire																	pe_wmem_write_req_7_2;
	wire																	pe_wmem_write_req_8_2;
	wire																	pe_wmem_write_req_9_2;
	wire																	pe_wmem_write_req_10_2;
	wire																	pe_wmem_write_req_11_2;
	wire																	pe_wmem_write_req_12_2;
	wire																	pe_wmem_write_req_13_2;
	wire																	pe_wmem_write_req_14_2;
	wire																	pe_wmem_write_req_15_2;
	wire																	pe_wmem_write_req_0_3;
	wire																	pe_wmem_write_req_1_3;
	wire																	pe_wmem_write_req_2_3;
	wire																	pe_wmem_write_req_3_3;
	wire																	pe_wmem_write_req_4_3;
	wire																	pe_wmem_write_req_5_3;
	wire																	pe_wmem_write_req_6_3;
	wire																	pe_wmem_write_req_7_3;
	wire																	pe_wmem_write_req_8_3;
	wire																	pe_wmem_write_req_9_3;
	wire																	pe_wmem_write_req_10_3;
	wire																	pe_wmem_write_req_11_3;
	wire																	pe_wmem_write_req_12_3;
	wire																	pe_wmem_write_req_13_3;
	wire																	pe_wmem_write_req_14_3;
	wire																	pe_wmem_write_req_15_3;
	wire																	pe_wmem_write_req_0_4;
	wire																	pe_wmem_write_req_1_4;
	wire																	pe_wmem_write_req_2_4;
	wire																	pe_wmem_write_req_3_4;
	wire																	pe_wmem_write_req_4_4;
	wire																	pe_wmem_write_req_5_4;
	wire																	pe_wmem_write_req_6_4;
	wire																	pe_wmem_write_req_7_4;
	wire																	pe_wmem_write_req_8_4;
	wire																	pe_wmem_write_req_9_4;
	wire																	pe_wmem_write_req_10_4;
	wire																	pe_wmem_write_req_11_4;
	wire																	pe_wmem_write_req_12_4;
	wire																	pe_wmem_write_req_13_4;
	wire																	pe_wmem_write_req_14_4;
	wire																	pe_wmem_write_req_15_4;
	wire																	pe_wmem_write_req_0_5;
	wire																	pe_wmem_write_req_1_5;
	wire																	pe_wmem_write_req_2_5;
	wire																	pe_wmem_write_req_3_5;
	wire																	pe_wmem_write_req_4_5;
	wire																	pe_wmem_write_req_5_5;
	wire																	pe_wmem_write_req_6_5;
	wire																	pe_wmem_write_req_7_5;
	wire																	pe_wmem_write_req_8_5;
	wire																	pe_wmem_write_req_9_5;
	wire																	pe_wmem_write_req_10_5;
	wire																	pe_wmem_write_req_11_5;
	wire																	pe_wmem_write_req_12_5;
	wire																	pe_wmem_write_req_13_5;
	wire																	pe_wmem_write_req_14_5;
	wire																	pe_wmem_write_req_15_5;
	wire																	pe_wmem_write_req_0_6;
	wire																	pe_wmem_write_req_1_6;
	wire																	pe_wmem_write_req_2_6;
	wire																	pe_wmem_write_req_3_6;
	wire																	pe_wmem_write_req_4_6;
	wire																	pe_wmem_write_req_5_6;
	wire																	pe_wmem_write_req_6_6;
	wire																	pe_wmem_write_req_7_6;
	wire																	pe_wmem_write_req_8_6;
	wire																	pe_wmem_write_req_9_6;
	wire																	pe_wmem_write_req_10_6;
	wire																	pe_wmem_write_req_11_6;
	wire																	pe_wmem_write_req_12_6;
	wire																	pe_wmem_write_req_13_6;
	wire																	pe_wmem_write_req_14_6;
	wire																	pe_wmem_write_req_15_6;
	wire																	pe_wmem_write_req_0_7;
	wire																	pe_wmem_write_req_1_7;
	wire																	pe_wmem_write_req_2_7;
	wire																	pe_wmem_write_req_3_7;
	wire																	pe_wmem_write_req_4_7;
	wire																	pe_wmem_write_req_5_7;
	wire																	pe_wmem_write_req_6_7;
	wire																	pe_wmem_write_req_7_7;
	wire																	pe_wmem_write_req_8_7;
	wire																	pe_wmem_write_req_9_7;
	wire																	pe_wmem_write_req_10_7;
	wire																	pe_wmem_write_req_11_7;
	wire																	pe_wmem_write_req_12_7;
	wire																	pe_wmem_write_req_13_7;
	wire																	pe_wmem_write_req_14_7;
	wire																	pe_wmem_write_req_15_7;
	wire																	pe_wmem_write_req_0_8;
	wire																	pe_wmem_write_req_1_8;
	wire																	pe_wmem_write_req_2_8;
	wire																	pe_wmem_write_req_3_8;
	wire																	pe_wmem_write_req_4_8;
	wire																	pe_wmem_write_req_5_8;
	wire																	pe_wmem_write_req_6_8;
	wire																	pe_wmem_write_req_7_8;
	wire																	pe_wmem_write_req_8_8;
	wire																	pe_wmem_write_req_9_8;
	wire																	pe_wmem_write_req_10_8;
	wire																	pe_wmem_write_req_11_8;
	wire																	pe_wmem_write_req_12_8;
	wire																	pe_wmem_write_req_13_8;
	wire																	pe_wmem_write_req_14_8;
	wire																	pe_wmem_write_req_15_8;
	wire																	pe_wmem_write_req_0_9;
	wire																	pe_wmem_write_req_1_9;
	wire																	pe_wmem_write_req_2_9;
	wire																	pe_wmem_write_req_3_9;
	wire																	pe_wmem_write_req_4_9;
	wire																	pe_wmem_write_req_5_9;
	wire																	pe_wmem_write_req_6_9;
	wire																	pe_wmem_write_req_7_9;
	wire																	pe_wmem_write_req_8_9;
	wire																	pe_wmem_write_req_9_9;
	wire																	pe_wmem_write_req_10_9;
	wire																	pe_wmem_write_req_11_9;
	wire																	pe_wmem_write_req_12_9;
	wire																	pe_wmem_write_req_13_9;
	wire																	pe_wmem_write_req_14_9;
	wire																	pe_wmem_write_req_15_9;
	wire																	pe_wmem_write_req_0_10;
	wire																	pe_wmem_write_req_1_10;
	wire																	pe_wmem_write_req_2_10;
	wire																	pe_wmem_write_req_3_10;
	wire																	pe_wmem_write_req_4_10;
	wire																	pe_wmem_write_req_5_10;
	wire																	pe_wmem_write_req_6_10;
	wire																	pe_wmem_write_req_7_10;
	wire																	pe_wmem_write_req_8_10;
	wire																	pe_wmem_write_req_9_10;
	wire																	pe_wmem_write_req_10_10;
	wire																	pe_wmem_write_req_11_10;
	wire																	pe_wmem_write_req_12_10;
	wire																	pe_wmem_write_req_13_10;
	wire																	pe_wmem_write_req_14_10;
	wire																	pe_wmem_write_req_15_10;
	wire																	pe_wmem_write_req_0_11;
	wire																	pe_wmem_write_req_1_11;
	wire																	pe_wmem_write_req_2_11;
	wire																	pe_wmem_write_req_3_11;
	wire																	pe_wmem_write_req_4_11;
	wire																	pe_wmem_write_req_5_11;
	wire																	pe_wmem_write_req_6_11;
	wire																	pe_wmem_write_req_7_11;
	wire																	pe_wmem_write_req_8_11;
	wire																	pe_wmem_write_req_9_11;
	wire																	pe_wmem_write_req_10_11;
	wire																	pe_wmem_write_req_11_11;
	wire																	pe_wmem_write_req_12_11;
	wire																	pe_wmem_write_req_13_11;
	wire																	pe_wmem_write_req_14_11;
	wire																	pe_wmem_write_req_15_11;
	wire																	pe_wmem_write_req_0_12;
	wire																	pe_wmem_write_req_1_12;
	wire																	pe_wmem_write_req_2_12;
	wire																	pe_wmem_write_req_3_12;
	wire																	pe_wmem_write_req_4_12;
	wire																	pe_wmem_write_req_5_12;
	wire																	pe_wmem_write_req_6_12;
	wire																	pe_wmem_write_req_7_12;
	wire																	pe_wmem_write_req_8_12;
	wire																	pe_wmem_write_req_9_12;
	wire																	pe_wmem_write_req_10_12;
	wire																	pe_wmem_write_req_11_12;
	wire																	pe_wmem_write_req_12_12;
	wire																	pe_wmem_write_req_13_12;
	wire																	pe_wmem_write_req_14_12;
	wire																	pe_wmem_write_req_15_12;
	wire																	pe_wmem_write_req_0_13;
	wire																	pe_wmem_write_req_1_13;
	wire																	pe_wmem_write_req_2_13;
	wire																	pe_wmem_write_req_3_13;
	wire																	pe_wmem_write_req_4_13;
	wire																	pe_wmem_write_req_5_13;
	wire																	pe_wmem_write_req_6_13;
	wire																	pe_wmem_write_req_7_13;
	wire																	pe_wmem_write_req_8_13;
	wire																	pe_wmem_write_req_9_13;
	wire																	pe_wmem_write_req_10_13;
	wire																	pe_wmem_write_req_11_13;
	wire																	pe_wmem_write_req_12_13;
	wire																	pe_wmem_write_req_13_13;
	wire																	pe_wmem_write_req_14_13;
	wire																	pe_wmem_write_req_15_13;
	wire																	pe_wmem_write_req_0_14;
	wire																	pe_wmem_write_req_1_14;
	wire																	pe_wmem_write_req_2_14;
	wire																	pe_wmem_write_req_3_14;
	wire																	pe_wmem_write_req_4_14;
	wire																	pe_wmem_write_req_5_14;
	wire																	pe_wmem_write_req_6_14;
	wire																	pe_wmem_write_req_7_14;
	wire																	pe_wmem_write_req_8_14;
	wire																	pe_wmem_write_req_9_14;
	wire																	pe_wmem_write_req_10_14;
	wire																	pe_wmem_write_req_11_14;
	wire																	pe_wmem_write_req_12_14;
	wire																	pe_wmem_write_req_13_14;
	wire																	pe_wmem_write_req_14_14;
	wire																	pe_wmem_write_req_15_14;
	wire																	pe_wmem_write_req_0_15;
	wire																	pe_wmem_write_req_1_15;
	wire																	pe_wmem_write_req_2_15;
	wire																	pe_wmem_write_req_3_15;
	wire																	pe_wmem_write_req_4_15;
	wire																	pe_wmem_write_req_5_15;
	wire																	pe_wmem_write_req_6_15;
	wire																	pe_wmem_write_req_7_15;
	wire																	pe_wmem_write_req_8_15;
	wire																	pe_wmem_write_req_9_15;
	wire																	pe_wmem_write_req_10_15;
	wire																	pe_wmem_write_req_11_15;
	wire																	pe_wmem_write_req_12_15;
	wire																	pe_wmem_write_req_13_15;
	wire																	pe_wmem_write_req_14_15;
	wire																	pe_wmem_write_req_15_15;
//
//
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_0;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_1;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_2;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_3;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_4;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_5;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_6;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_7;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_8;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_9;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_10;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_11;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_12;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_13;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_14;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_15;
//
//
	assign						pe_wmem_write_req_row_0      	=   pe_wmem_write_req[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_1      	=   pe_wmem_write_req[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_2      	=   pe_wmem_write_req[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_3      	=   pe_wmem_write_req[(3+1)*ARRAY_DIM_X-1:3*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_4      	=   pe_wmem_write_req[(4+1)*ARRAY_DIM_X-1:4*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_5      	=   pe_wmem_write_req[(5+1)*ARRAY_DIM_X-1:5*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_6      	=   pe_wmem_write_req[(6+1)*ARRAY_DIM_X-1:6*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_7      	=   pe_wmem_write_req[(7+1)*ARRAY_DIM_X-1:7*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_8      	=   pe_wmem_write_req[(8+1)*ARRAY_DIM_X-1:8*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_9      	=   pe_wmem_write_req[(9+1)*ARRAY_DIM_X-1:9*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_10      	=   pe_wmem_write_req[(10+1)*ARRAY_DIM_X-1:10*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_11      	=   pe_wmem_write_req[(11+1)*ARRAY_DIM_X-1:11*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_12      	=   pe_wmem_write_req[(12+1)*ARRAY_DIM_X-1:12*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_13      	=   pe_wmem_write_req[(13+1)*ARRAY_DIM_X-1:13*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_14      	=   pe_wmem_write_req[(14+1)*ARRAY_DIM_X-1:14*ARRAY_DIM_X];
	assign						pe_wmem_write_req_row_15      	=   pe_wmem_write_req[(15+1)*ARRAY_DIM_X-1:15*ARRAY_DIM_X];
//
//
	assign						pe_wmem_write_req_0_0 =	pe_wmem_write_req_row_0[(0+1)-1:0];
	assign						pe_wmem_write_req_1_0 =	pe_wmem_write_req_row_1[(0+1)-1:0];
	assign						pe_wmem_write_req_2_0 =	pe_wmem_write_req_row_2[(0+1)-1:0];
	assign						pe_wmem_write_req_3_0 =	pe_wmem_write_req_row_3[(0+1)-1:0];
	assign						pe_wmem_write_req_4_0 =	pe_wmem_write_req_row_4[(0+1)-1:0];
	assign						pe_wmem_write_req_5_0 =	pe_wmem_write_req_row_5[(0+1)-1:0];
	assign						pe_wmem_write_req_6_0 =	pe_wmem_write_req_row_6[(0+1)-1:0];
	assign						pe_wmem_write_req_7_0 =	pe_wmem_write_req_row_7[(0+1)-1:0];
	assign						pe_wmem_write_req_8_0 =	pe_wmem_write_req_row_8[(0+1)-1:0];
	assign						pe_wmem_write_req_9_0 =	pe_wmem_write_req_row_9[(0+1)-1:0];
	assign						pe_wmem_write_req_10_0 =	pe_wmem_write_req_row_10[(0+1)-1:0];
	assign						pe_wmem_write_req_11_0 =	pe_wmem_write_req_row_11[(0+1)-1:0];
	assign						pe_wmem_write_req_12_0 =	pe_wmem_write_req_row_12[(0+1)-1:0];
	assign						pe_wmem_write_req_13_0 =	pe_wmem_write_req_row_13[(0+1)-1:0];
	assign						pe_wmem_write_req_14_0 =	pe_wmem_write_req_row_14[(0+1)-1:0];
	assign						pe_wmem_write_req_15_0 =	pe_wmem_write_req_row_15[(0+1)-1:0];
	assign						pe_wmem_write_req_0_1 =	pe_wmem_write_req_row_0[(1+1)-1:1];
	assign						pe_wmem_write_req_1_1 =	pe_wmem_write_req_row_1[(1+1)-1:1];
	assign						pe_wmem_write_req_2_1 =	pe_wmem_write_req_row_2[(1+1)-1:1];
	assign						pe_wmem_write_req_3_1 =	pe_wmem_write_req_row_3[(1+1)-1:1];
	assign						pe_wmem_write_req_4_1 =	pe_wmem_write_req_row_4[(1+1)-1:1];
	assign						pe_wmem_write_req_5_1 =	pe_wmem_write_req_row_5[(1+1)-1:1];
	assign						pe_wmem_write_req_6_1 =	pe_wmem_write_req_row_6[(1+1)-1:1];
	assign						pe_wmem_write_req_7_1 =	pe_wmem_write_req_row_7[(1+1)-1:1];
	assign						pe_wmem_write_req_8_1 =	pe_wmem_write_req_row_8[(1+1)-1:1];
	assign						pe_wmem_write_req_9_1 =	pe_wmem_write_req_row_9[(1+1)-1:1];
	assign						pe_wmem_write_req_10_1 =	pe_wmem_write_req_row_10[(1+1)-1:1];
	assign						pe_wmem_write_req_11_1 =	pe_wmem_write_req_row_11[(1+1)-1:1];
	assign						pe_wmem_write_req_12_1 =	pe_wmem_write_req_row_12[(1+1)-1:1];
	assign						pe_wmem_write_req_13_1 =	pe_wmem_write_req_row_13[(1+1)-1:1];
	assign						pe_wmem_write_req_14_1 =	pe_wmem_write_req_row_14[(1+1)-1:1];
	assign						pe_wmem_write_req_15_1 =	pe_wmem_write_req_row_15[(1+1)-1:1];
	assign						pe_wmem_write_req_0_2 =	pe_wmem_write_req_row_0[(2+1)-1:2];
	assign						pe_wmem_write_req_1_2 =	pe_wmem_write_req_row_1[(2+1)-1:2];
	assign						pe_wmem_write_req_2_2 =	pe_wmem_write_req_row_2[(2+1)-1:2];
	assign						pe_wmem_write_req_3_2 =	pe_wmem_write_req_row_3[(2+1)-1:2];
	assign						pe_wmem_write_req_4_2 =	pe_wmem_write_req_row_4[(2+1)-1:2];
	assign						pe_wmem_write_req_5_2 =	pe_wmem_write_req_row_5[(2+1)-1:2];
	assign						pe_wmem_write_req_6_2 =	pe_wmem_write_req_row_6[(2+1)-1:2];
	assign						pe_wmem_write_req_7_2 =	pe_wmem_write_req_row_7[(2+1)-1:2];
	assign						pe_wmem_write_req_8_2 =	pe_wmem_write_req_row_8[(2+1)-1:2];
	assign						pe_wmem_write_req_9_2 =	pe_wmem_write_req_row_9[(2+1)-1:2];
	assign						pe_wmem_write_req_10_2 =	pe_wmem_write_req_row_10[(2+1)-1:2];
	assign						pe_wmem_write_req_11_2 =	pe_wmem_write_req_row_11[(2+1)-1:2];
	assign						pe_wmem_write_req_12_2 =	pe_wmem_write_req_row_12[(2+1)-1:2];
	assign						pe_wmem_write_req_13_2 =	pe_wmem_write_req_row_13[(2+1)-1:2];
	assign						pe_wmem_write_req_14_2 =	pe_wmem_write_req_row_14[(2+1)-1:2];
	assign						pe_wmem_write_req_15_2 =	pe_wmem_write_req_row_15[(2+1)-1:2];
	assign						pe_wmem_write_req_0_3 =	pe_wmem_write_req_row_0[(3+1)-1:3];
	assign						pe_wmem_write_req_1_3 =	pe_wmem_write_req_row_1[(3+1)-1:3];
	assign						pe_wmem_write_req_2_3 =	pe_wmem_write_req_row_2[(3+1)-1:3];
	assign						pe_wmem_write_req_3_3 =	pe_wmem_write_req_row_3[(3+1)-1:3];
	assign						pe_wmem_write_req_4_3 =	pe_wmem_write_req_row_4[(3+1)-1:3];
	assign						pe_wmem_write_req_5_3 =	pe_wmem_write_req_row_5[(3+1)-1:3];
	assign						pe_wmem_write_req_6_3 =	pe_wmem_write_req_row_6[(3+1)-1:3];
	assign						pe_wmem_write_req_7_3 =	pe_wmem_write_req_row_7[(3+1)-1:3];
	assign						pe_wmem_write_req_8_3 =	pe_wmem_write_req_row_8[(3+1)-1:3];
	assign						pe_wmem_write_req_9_3 =	pe_wmem_write_req_row_9[(3+1)-1:3];
	assign						pe_wmem_write_req_10_3 =	pe_wmem_write_req_row_10[(3+1)-1:3];
	assign						pe_wmem_write_req_11_3 =	pe_wmem_write_req_row_11[(3+1)-1:3];
	assign						pe_wmem_write_req_12_3 =	pe_wmem_write_req_row_12[(3+1)-1:3];
	assign						pe_wmem_write_req_13_3 =	pe_wmem_write_req_row_13[(3+1)-1:3];
	assign						pe_wmem_write_req_14_3 =	pe_wmem_write_req_row_14[(3+1)-1:3];
	assign						pe_wmem_write_req_15_3 =	pe_wmem_write_req_row_15[(3+1)-1:3];
	assign						pe_wmem_write_req_0_4 =	pe_wmem_write_req_row_0[(4+1)-1:4];
	assign						pe_wmem_write_req_1_4 =	pe_wmem_write_req_row_1[(4+1)-1:4];
	assign						pe_wmem_write_req_2_4 =	pe_wmem_write_req_row_2[(4+1)-1:4];
	assign						pe_wmem_write_req_3_4 =	pe_wmem_write_req_row_3[(4+1)-1:4];
	assign						pe_wmem_write_req_4_4 =	pe_wmem_write_req_row_4[(4+1)-1:4];
	assign						pe_wmem_write_req_5_4 =	pe_wmem_write_req_row_5[(4+1)-1:4];
	assign						pe_wmem_write_req_6_4 =	pe_wmem_write_req_row_6[(4+1)-1:4];
	assign						pe_wmem_write_req_7_4 =	pe_wmem_write_req_row_7[(4+1)-1:4];
	assign						pe_wmem_write_req_8_4 =	pe_wmem_write_req_row_8[(4+1)-1:4];
	assign						pe_wmem_write_req_9_4 =	pe_wmem_write_req_row_9[(4+1)-1:4];
	assign						pe_wmem_write_req_10_4 =	pe_wmem_write_req_row_10[(4+1)-1:4];
	assign						pe_wmem_write_req_11_4 =	pe_wmem_write_req_row_11[(4+1)-1:4];
	assign						pe_wmem_write_req_12_4 =	pe_wmem_write_req_row_12[(4+1)-1:4];
	assign						pe_wmem_write_req_13_4 =	pe_wmem_write_req_row_13[(4+1)-1:4];
	assign						pe_wmem_write_req_14_4 =	pe_wmem_write_req_row_14[(4+1)-1:4];
	assign						pe_wmem_write_req_15_4 =	pe_wmem_write_req_row_15[(4+1)-1:4];
	assign						pe_wmem_write_req_0_5 =	pe_wmem_write_req_row_0[(5+1)-1:5];
	assign						pe_wmem_write_req_1_5 =	pe_wmem_write_req_row_1[(5+1)-1:5];
	assign						pe_wmem_write_req_2_5 =	pe_wmem_write_req_row_2[(5+1)-1:5];
	assign						pe_wmem_write_req_3_5 =	pe_wmem_write_req_row_3[(5+1)-1:5];
	assign						pe_wmem_write_req_4_5 =	pe_wmem_write_req_row_4[(5+1)-1:5];
	assign						pe_wmem_write_req_5_5 =	pe_wmem_write_req_row_5[(5+1)-1:5];
	assign						pe_wmem_write_req_6_5 =	pe_wmem_write_req_row_6[(5+1)-1:5];
	assign						pe_wmem_write_req_7_5 =	pe_wmem_write_req_row_7[(5+1)-1:5];
	assign						pe_wmem_write_req_8_5 =	pe_wmem_write_req_row_8[(5+1)-1:5];
	assign						pe_wmem_write_req_9_5 =	pe_wmem_write_req_row_9[(5+1)-1:5];
	assign						pe_wmem_write_req_10_5 =	pe_wmem_write_req_row_10[(5+1)-1:5];
	assign						pe_wmem_write_req_11_5 =	pe_wmem_write_req_row_11[(5+1)-1:5];
	assign						pe_wmem_write_req_12_5 =	pe_wmem_write_req_row_12[(5+1)-1:5];
	assign						pe_wmem_write_req_13_5 =	pe_wmem_write_req_row_13[(5+1)-1:5];
	assign						pe_wmem_write_req_14_5 =	pe_wmem_write_req_row_14[(5+1)-1:5];
	assign						pe_wmem_write_req_15_5 =	pe_wmem_write_req_row_15[(5+1)-1:5];
	assign						pe_wmem_write_req_0_6 =	pe_wmem_write_req_row_0[(6+1)-1:6];
	assign						pe_wmem_write_req_1_6 =	pe_wmem_write_req_row_1[(6+1)-1:6];
	assign						pe_wmem_write_req_2_6 =	pe_wmem_write_req_row_2[(6+1)-1:6];
	assign						pe_wmem_write_req_3_6 =	pe_wmem_write_req_row_3[(6+1)-1:6];
	assign						pe_wmem_write_req_4_6 =	pe_wmem_write_req_row_4[(6+1)-1:6];
	assign						pe_wmem_write_req_5_6 =	pe_wmem_write_req_row_5[(6+1)-1:6];
	assign						pe_wmem_write_req_6_6 =	pe_wmem_write_req_row_6[(6+1)-1:6];
	assign						pe_wmem_write_req_7_6 =	pe_wmem_write_req_row_7[(6+1)-1:6];
	assign						pe_wmem_write_req_8_6 =	pe_wmem_write_req_row_8[(6+1)-1:6];
	assign						pe_wmem_write_req_9_6 =	pe_wmem_write_req_row_9[(6+1)-1:6];
	assign						pe_wmem_write_req_10_6 =	pe_wmem_write_req_row_10[(6+1)-1:6];
	assign						pe_wmem_write_req_11_6 =	pe_wmem_write_req_row_11[(6+1)-1:6];
	assign						pe_wmem_write_req_12_6 =	pe_wmem_write_req_row_12[(6+1)-1:6];
	assign						pe_wmem_write_req_13_6 =	pe_wmem_write_req_row_13[(6+1)-1:6];
	assign						pe_wmem_write_req_14_6 =	pe_wmem_write_req_row_14[(6+1)-1:6];
	assign						pe_wmem_write_req_15_6 =	pe_wmem_write_req_row_15[(6+1)-1:6];
	assign						pe_wmem_write_req_0_7 =	pe_wmem_write_req_row_0[(7+1)-1:7];
	assign						pe_wmem_write_req_1_7 =	pe_wmem_write_req_row_1[(7+1)-1:7];
	assign						pe_wmem_write_req_2_7 =	pe_wmem_write_req_row_2[(7+1)-1:7];
	assign						pe_wmem_write_req_3_7 =	pe_wmem_write_req_row_3[(7+1)-1:7];
	assign						pe_wmem_write_req_4_7 =	pe_wmem_write_req_row_4[(7+1)-1:7];
	assign						pe_wmem_write_req_5_7 =	pe_wmem_write_req_row_5[(7+1)-1:7];
	assign						pe_wmem_write_req_6_7 =	pe_wmem_write_req_row_6[(7+1)-1:7];
	assign						pe_wmem_write_req_7_7 =	pe_wmem_write_req_row_7[(7+1)-1:7];
	assign						pe_wmem_write_req_8_7 =	pe_wmem_write_req_row_8[(7+1)-1:7];
	assign						pe_wmem_write_req_9_7 =	pe_wmem_write_req_row_9[(7+1)-1:7];
	assign						pe_wmem_write_req_10_7 =	pe_wmem_write_req_row_10[(7+1)-1:7];
	assign						pe_wmem_write_req_11_7 =	pe_wmem_write_req_row_11[(7+1)-1:7];
	assign						pe_wmem_write_req_12_7 =	pe_wmem_write_req_row_12[(7+1)-1:7];
	assign						pe_wmem_write_req_13_7 =	pe_wmem_write_req_row_13[(7+1)-1:7];
	assign						pe_wmem_write_req_14_7 =	pe_wmem_write_req_row_14[(7+1)-1:7];
	assign						pe_wmem_write_req_15_7 =	pe_wmem_write_req_row_15[(7+1)-1:7];
	assign						pe_wmem_write_req_0_8 =	pe_wmem_write_req_row_0[(8+1)-1:8];
	assign						pe_wmem_write_req_1_8 =	pe_wmem_write_req_row_1[(8+1)-1:8];
	assign						pe_wmem_write_req_2_8 =	pe_wmem_write_req_row_2[(8+1)-1:8];
	assign						pe_wmem_write_req_3_8 =	pe_wmem_write_req_row_3[(8+1)-1:8];
	assign						pe_wmem_write_req_4_8 =	pe_wmem_write_req_row_4[(8+1)-1:8];
	assign						pe_wmem_write_req_5_8 =	pe_wmem_write_req_row_5[(8+1)-1:8];
	assign						pe_wmem_write_req_6_8 =	pe_wmem_write_req_row_6[(8+1)-1:8];
	assign						pe_wmem_write_req_7_8 =	pe_wmem_write_req_row_7[(8+1)-1:8];
	assign						pe_wmem_write_req_8_8 =	pe_wmem_write_req_row_8[(8+1)-1:8];
	assign						pe_wmem_write_req_9_8 =	pe_wmem_write_req_row_9[(8+1)-1:8];
	assign						pe_wmem_write_req_10_8 =	pe_wmem_write_req_row_10[(8+1)-1:8];
	assign						pe_wmem_write_req_11_8 =	pe_wmem_write_req_row_11[(8+1)-1:8];
	assign						pe_wmem_write_req_12_8 =	pe_wmem_write_req_row_12[(8+1)-1:8];
	assign						pe_wmem_write_req_13_8 =	pe_wmem_write_req_row_13[(8+1)-1:8];
	assign						pe_wmem_write_req_14_8 =	pe_wmem_write_req_row_14[(8+1)-1:8];
	assign						pe_wmem_write_req_15_8 =	pe_wmem_write_req_row_15[(8+1)-1:8];
	assign						pe_wmem_write_req_0_9 =	pe_wmem_write_req_row_0[(9+1)-1:9];
	assign						pe_wmem_write_req_1_9 =	pe_wmem_write_req_row_1[(9+1)-1:9];
	assign						pe_wmem_write_req_2_9 =	pe_wmem_write_req_row_2[(9+1)-1:9];
	assign						pe_wmem_write_req_3_9 =	pe_wmem_write_req_row_3[(9+1)-1:9];
	assign						pe_wmem_write_req_4_9 =	pe_wmem_write_req_row_4[(9+1)-1:9];
	assign						pe_wmem_write_req_5_9 =	pe_wmem_write_req_row_5[(9+1)-1:9];
	assign						pe_wmem_write_req_6_9 =	pe_wmem_write_req_row_6[(9+1)-1:9];
	assign						pe_wmem_write_req_7_9 =	pe_wmem_write_req_row_7[(9+1)-1:9];
	assign						pe_wmem_write_req_8_9 =	pe_wmem_write_req_row_8[(9+1)-1:9];
	assign						pe_wmem_write_req_9_9 =	pe_wmem_write_req_row_9[(9+1)-1:9];
	assign						pe_wmem_write_req_10_9 =	pe_wmem_write_req_row_10[(9+1)-1:9];
	assign						pe_wmem_write_req_11_9 =	pe_wmem_write_req_row_11[(9+1)-1:9];
	assign						pe_wmem_write_req_12_9 =	pe_wmem_write_req_row_12[(9+1)-1:9];
	assign						pe_wmem_write_req_13_9 =	pe_wmem_write_req_row_13[(9+1)-1:9];
	assign						pe_wmem_write_req_14_9 =	pe_wmem_write_req_row_14[(9+1)-1:9];
	assign						pe_wmem_write_req_15_9 =	pe_wmem_write_req_row_15[(9+1)-1:9];
	assign						pe_wmem_write_req_0_10 =	pe_wmem_write_req_row_0[(10+1)-1:10];
	assign						pe_wmem_write_req_1_10 =	pe_wmem_write_req_row_1[(10+1)-1:10];
	assign						pe_wmem_write_req_2_10 =	pe_wmem_write_req_row_2[(10+1)-1:10];
	assign						pe_wmem_write_req_3_10 =	pe_wmem_write_req_row_3[(10+1)-1:10];
	assign						pe_wmem_write_req_4_10 =	pe_wmem_write_req_row_4[(10+1)-1:10];
	assign						pe_wmem_write_req_5_10 =	pe_wmem_write_req_row_5[(10+1)-1:10];
	assign						pe_wmem_write_req_6_10 =	pe_wmem_write_req_row_6[(10+1)-1:10];
	assign						pe_wmem_write_req_7_10 =	pe_wmem_write_req_row_7[(10+1)-1:10];
	assign						pe_wmem_write_req_8_10 =	pe_wmem_write_req_row_8[(10+1)-1:10];
	assign						pe_wmem_write_req_9_10 =	pe_wmem_write_req_row_9[(10+1)-1:10];
	assign						pe_wmem_write_req_10_10 =	pe_wmem_write_req_row_10[(10+1)-1:10];
	assign						pe_wmem_write_req_11_10 =	pe_wmem_write_req_row_11[(10+1)-1:10];
	assign						pe_wmem_write_req_12_10 =	pe_wmem_write_req_row_12[(10+1)-1:10];
	assign						pe_wmem_write_req_13_10 =	pe_wmem_write_req_row_13[(10+1)-1:10];
	assign						pe_wmem_write_req_14_10 =	pe_wmem_write_req_row_14[(10+1)-1:10];
	assign						pe_wmem_write_req_15_10 =	pe_wmem_write_req_row_15[(10+1)-1:10];
	assign						pe_wmem_write_req_0_11 =	pe_wmem_write_req_row_0[(11+1)-1:11];
	assign						pe_wmem_write_req_1_11 =	pe_wmem_write_req_row_1[(11+1)-1:11];
	assign						pe_wmem_write_req_2_11 =	pe_wmem_write_req_row_2[(11+1)-1:11];
	assign						pe_wmem_write_req_3_11 =	pe_wmem_write_req_row_3[(11+1)-1:11];
	assign						pe_wmem_write_req_4_11 =	pe_wmem_write_req_row_4[(11+1)-1:11];
	assign						pe_wmem_write_req_5_11 =	pe_wmem_write_req_row_5[(11+1)-1:11];
	assign						pe_wmem_write_req_6_11 =	pe_wmem_write_req_row_6[(11+1)-1:11];
	assign						pe_wmem_write_req_7_11 =	pe_wmem_write_req_row_7[(11+1)-1:11];
	assign						pe_wmem_write_req_8_11 =	pe_wmem_write_req_row_8[(11+1)-1:11];
	assign						pe_wmem_write_req_9_11 =	pe_wmem_write_req_row_9[(11+1)-1:11];
	assign						pe_wmem_write_req_10_11 =	pe_wmem_write_req_row_10[(11+1)-1:11];
	assign						pe_wmem_write_req_11_11 =	pe_wmem_write_req_row_11[(11+1)-1:11];
	assign						pe_wmem_write_req_12_11 =	pe_wmem_write_req_row_12[(11+1)-1:11];
	assign						pe_wmem_write_req_13_11 =	pe_wmem_write_req_row_13[(11+1)-1:11];
	assign						pe_wmem_write_req_14_11 =	pe_wmem_write_req_row_14[(11+1)-1:11];
	assign						pe_wmem_write_req_15_11 =	pe_wmem_write_req_row_15[(11+1)-1:11];
	assign						pe_wmem_write_req_0_12 =	pe_wmem_write_req_row_0[(12+1)-1:12];
	assign						pe_wmem_write_req_1_12 =	pe_wmem_write_req_row_1[(12+1)-1:12];
	assign						pe_wmem_write_req_2_12 =	pe_wmem_write_req_row_2[(12+1)-1:12];
	assign						pe_wmem_write_req_3_12 =	pe_wmem_write_req_row_3[(12+1)-1:12];
	assign						pe_wmem_write_req_4_12 =	pe_wmem_write_req_row_4[(12+1)-1:12];
	assign						pe_wmem_write_req_5_12 =	pe_wmem_write_req_row_5[(12+1)-1:12];
	assign						pe_wmem_write_req_6_12 =	pe_wmem_write_req_row_6[(12+1)-1:12];
	assign						pe_wmem_write_req_7_12 =	pe_wmem_write_req_row_7[(12+1)-1:12];
	assign						pe_wmem_write_req_8_12 =	pe_wmem_write_req_row_8[(12+1)-1:12];
	assign						pe_wmem_write_req_9_12 =	pe_wmem_write_req_row_9[(12+1)-1:12];
	assign						pe_wmem_write_req_10_12 =	pe_wmem_write_req_row_10[(12+1)-1:12];
	assign						pe_wmem_write_req_11_12 =	pe_wmem_write_req_row_11[(12+1)-1:12];
	assign						pe_wmem_write_req_12_12 =	pe_wmem_write_req_row_12[(12+1)-1:12];
	assign						pe_wmem_write_req_13_12 =	pe_wmem_write_req_row_13[(12+1)-1:12];
	assign						pe_wmem_write_req_14_12 =	pe_wmem_write_req_row_14[(12+1)-1:12];
	assign						pe_wmem_write_req_15_12 =	pe_wmem_write_req_row_15[(12+1)-1:12];
	assign						pe_wmem_write_req_0_13 =	pe_wmem_write_req_row_0[(13+1)-1:13];
	assign						pe_wmem_write_req_1_13 =	pe_wmem_write_req_row_1[(13+1)-1:13];
	assign						pe_wmem_write_req_2_13 =	pe_wmem_write_req_row_2[(13+1)-1:13];
	assign						pe_wmem_write_req_3_13 =	pe_wmem_write_req_row_3[(13+1)-1:13];
	assign						pe_wmem_write_req_4_13 =	pe_wmem_write_req_row_4[(13+1)-1:13];
	assign						pe_wmem_write_req_5_13 =	pe_wmem_write_req_row_5[(13+1)-1:13];
	assign						pe_wmem_write_req_6_13 =	pe_wmem_write_req_row_6[(13+1)-1:13];
	assign						pe_wmem_write_req_7_13 =	pe_wmem_write_req_row_7[(13+1)-1:13];
	assign						pe_wmem_write_req_8_13 =	pe_wmem_write_req_row_8[(13+1)-1:13];
	assign						pe_wmem_write_req_9_13 =	pe_wmem_write_req_row_9[(13+1)-1:13];
	assign						pe_wmem_write_req_10_13 =	pe_wmem_write_req_row_10[(13+1)-1:13];
	assign						pe_wmem_write_req_11_13 =	pe_wmem_write_req_row_11[(13+1)-1:13];
	assign						pe_wmem_write_req_12_13 =	pe_wmem_write_req_row_12[(13+1)-1:13];
	assign						pe_wmem_write_req_13_13 =	pe_wmem_write_req_row_13[(13+1)-1:13];
	assign						pe_wmem_write_req_14_13 =	pe_wmem_write_req_row_14[(13+1)-1:13];
	assign						pe_wmem_write_req_15_13 =	pe_wmem_write_req_row_15[(13+1)-1:13];
	assign						pe_wmem_write_req_0_14 =	pe_wmem_write_req_row_0[(14+1)-1:14];
	assign						pe_wmem_write_req_1_14 =	pe_wmem_write_req_row_1[(14+1)-1:14];
	assign						pe_wmem_write_req_2_14 =	pe_wmem_write_req_row_2[(14+1)-1:14];
	assign						pe_wmem_write_req_3_14 =	pe_wmem_write_req_row_3[(14+1)-1:14];
	assign						pe_wmem_write_req_4_14 =	pe_wmem_write_req_row_4[(14+1)-1:14];
	assign						pe_wmem_write_req_5_14 =	pe_wmem_write_req_row_5[(14+1)-1:14];
	assign						pe_wmem_write_req_6_14 =	pe_wmem_write_req_row_6[(14+1)-1:14];
	assign						pe_wmem_write_req_7_14 =	pe_wmem_write_req_row_7[(14+1)-1:14];
	assign						pe_wmem_write_req_8_14 =	pe_wmem_write_req_row_8[(14+1)-1:14];
	assign						pe_wmem_write_req_9_14 =	pe_wmem_write_req_row_9[(14+1)-1:14];
	assign						pe_wmem_write_req_10_14 =	pe_wmem_write_req_row_10[(14+1)-1:14];
	assign						pe_wmem_write_req_11_14 =	pe_wmem_write_req_row_11[(14+1)-1:14];
	assign						pe_wmem_write_req_12_14 =	pe_wmem_write_req_row_12[(14+1)-1:14];
	assign						pe_wmem_write_req_13_14 =	pe_wmem_write_req_row_13[(14+1)-1:14];
	assign						pe_wmem_write_req_14_14 =	pe_wmem_write_req_row_14[(14+1)-1:14];
	assign						pe_wmem_write_req_15_14 =	pe_wmem_write_req_row_15[(14+1)-1:14];
	assign						pe_wmem_write_req_0_15 =	pe_wmem_write_req_row_0[(15+1)-1:15];
	assign						pe_wmem_write_req_1_15 =	pe_wmem_write_req_row_1[(15+1)-1:15];
	assign						pe_wmem_write_req_2_15 =	pe_wmem_write_req_row_2[(15+1)-1:15];
	assign						pe_wmem_write_req_3_15 =	pe_wmem_write_req_row_3[(15+1)-1:15];
	assign						pe_wmem_write_req_4_15 =	pe_wmem_write_req_row_4[(15+1)-1:15];
	assign						pe_wmem_write_req_5_15 =	pe_wmem_write_req_row_5[(15+1)-1:15];
	assign						pe_wmem_write_req_6_15 =	pe_wmem_write_req_row_6[(15+1)-1:15];
	assign						pe_wmem_write_req_7_15 =	pe_wmem_write_req_row_7[(15+1)-1:15];
	assign						pe_wmem_write_req_8_15 =	pe_wmem_write_req_row_8[(15+1)-1:15];
	assign						pe_wmem_write_req_9_15 =	pe_wmem_write_req_row_9[(15+1)-1:15];
	assign						pe_wmem_write_req_10_15 =	pe_wmem_write_req_row_10[(15+1)-1:15];
	assign						pe_wmem_write_req_11_15 =	pe_wmem_write_req_row_11[(15+1)-1:15];
	assign						pe_wmem_write_req_12_15 =	pe_wmem_write_req_row_12[(15+1)-1:15];
	assign						pe_wmem_write_req_13_15 =	pe_wmem_write_req_row_13[(15+1)-1:15];
	assign						pe_wmem_write_req_14_15 =	pe_wmem_write_req_row_14[(15+1)-1:15];
	assign						pe_wmem_write_req_15_15 =	pe_wmem_write_req_row_15[(15+1)-1:15];
//
//
	wire																	pe_ws_en_0_0;
	wire																	pe_ws_en_1_0;
	wire																	pe_ws_en_2_0;
	wire																	pe_ws_en_3_0;
	wire																	pe_ws_en_4_0;
	wire																	pe_ws_en_5_0;
	wire																	pe_ws_en_6_0;
	wire																	pe_ws_en_7_0;
	wire																	pe_ws_en_8_0;
	wire																	pe_ws_en_9_0;
	wire																	pe_ws_en_10_0;
	wire																	pe_ws_en_11_0;
	wire																	pe_ws_en_12_0;
	wire																	pe_ws_en_13_0;
	wire																	pe_ws_en_14_0;
	wire																	pe_ws_en_15_0;
	wire																	pe_ws_en_0_1;
	wire																	pe_ws_en_1_1;
	wire																	pe_ws_en_2_1;
	wire																	pe_ws_en_3_1;
	wire																	pe_ws_en_4_1;
	wire																	pe_ws_en_5_1;
	wire																	pe_ws_en_6_1;
	wire																	pe_ws_en_7_1;
	wire																	pe_ws_en_8_1;
	wire																	pe_ws_en_9_1;
	wire																	pe_ws_en_10_1;
	wire																	pe_ws_en_11_1;
	wire																	pe_ws_en_12_1;
	wire																	pe_ws_en_13_1;
	wire																	pe_ws_en_14_1;
	wire																	pe_ws_en_15_1;
	wire																	pe_ws_en_0_2;
	wire																	pe_ws_en_1_2;
	wire																	pe_ws_en_2_2;
	wire																	pe_ws_en_3_2;
	wire																	pe_ws_en_4_2;
	wire																	pe_ws_en_5_2;
	wire																	pe_ws_en_6_2;
	wire																	pe_ws_en_7_2;
	wire																	pe_ws_en_8_2;
	wire																	pe_ws_en_9_2;
	wire																	pe_ws_en_10_2;
	wire																	pe_ws_en_11_2;
	wire																	pe_ws_en_12_2;
	wire																	pe_ws_en_13_2;
	wire																	pe_ws_en_14_2;
	wire																	pe_ws_en_15_2;
	wire																	pe_ws_en_0_3;
	wire																	pe_ws_en_1_3;
	wire																	pe_ws_en_2_3;
	wire																	pe_ws_en_3_3;
	wire																	pe_ws_en_4_3;
	wire																	pe_ws_en_5_3;
	wire																	pe_ws_en_6_3;
	wire																	pe_ws_en_7_3;
	wire																	pe_ws_en_8_3;
	wire																	pe_ws_en_9_3;
	wire																	pe_ws_en_10_3;
	wire																	pe_ws_en_11_3;
	wire																	pe_ws_en_12_3;
	wire																	pe_ws_en_13_3;
	wire																	pe_ws_en_14_3;
	wire																	pe_ws_en_15_3;
	wire																	pe_ws_en_0_4;
	wire																	pe_ws_en_1_4;
	wire																	pe_ws_en_2_4;
	wire																	pe_ws_en_3_4;
	wire																	pe_ws_en_4_4;
	wire																	pe_ws_en_5_4;
	wire																	pe_ws_en_6_4;
	wire																	pe_ws_en_7_4;
	wire																	pe_ws_en_8_4;
	wire																	pe_ws_en_9_4;
	wire																	pe_ws_en_10_4;
	wire																	pe_ws_en_11_4;
	wire																	pe_ws_en_12_4;
	wire																	pe_ws_en_13_4;
	wire																	pe_ws_en_14_4;
	wire																	pe_ws_en_15_4;
	wire																	pe_ws_en_0_5;
	wire																	pe_ws_en_1_5;
	wire																	pe_ws_en_2_5;
	wire																	pe_ws_en_3_5;
	wire																	pe_ws_en_4_5;
	wire																	pe_ws_en_5_5;
	wire																	pe_ws_en_6_5;
	wire																	pe_ws_en_7_5;
	wire																	pe_ws_en_8_5;
	wire																	pe_ws_en_9_5;
	wire																	pe_ws_en_10_5;
	wire																	pe_ws_en_11_5;
	wire																	pe_ws_en_12_5;
	wire																	pe_ws_en_13_5;
	wire																	pe_ws_en_14_5;
	wire																	pe_ws_en_15_5;
	wire																	pe_ws_en_0_6;
	wire																	pe_ws_en_1_6;
	wire																	pe_ws_en_2_6;
	wire																	pe_ws_en_3_6;
	wire																	pe_ws_en_4_6;
	wire																	pe_ws_en_5_6;
	wire																	pe_ws_en_6_6;
	wire																	pe_ws_en_7_6;
	wire																	pe_ws_en_8_6;
	wire																	pe_ws_en_9_6;
	wire																	pe_ws_en_10_6;
	wire																	pe_ws_en_11_6;
	wire																	pe_ws_en_12_6;
	wire																	pe_ws_en_13_6;
	wire																	pe_ws_en_14_6;
	wire																	pe_ws_en_15_6;
	wire																	pe_ws_en_0_7;
	wire																	pe_ws_en_1_7;
	wire																	pe_ws_en_2_7;
	wire																	pe_ws_en_3_7;
	wire																	pe_ws_en_4_7;
	wire																	pe_ws_en_5_7;
	wire																	pe_ws_en_6_7;
	wire																	pe_ws_en_7_7;
	wire																	pe_ws_en_8_7;
	wire																	pe_ws_en_9_7;
	wire																	pe_ws_en_10_7;
	wire																	pe_ws_en_11_7;
	wire																	pe_ws_en_12_7;
	wire																	pe_ws_en_13_7;
	wire																	pe_ws_en_14_7;
	wire																	pe_ws_en_15_7;
	wire																	pe_ws_en_0_8;
	wire																	pe_ws_en_1_8;
	wire																	pe_ws_en_2_8;
	wire																	pe_ws_en_3_8;
	wire																	pe_ws_en_4_8;
	wire																	pe_ws_en_5_8;
	wire																	pe_ws_en_6_8;
	wire																	pe_ws_en_7_8;
	wire																	pe_ws_en_8_8;
	wire																	pe_ws_en_9_8;
	wire																	pe_ws_en_10_8;
	wire																	pe_ws_en_11_8;
	wire																	pe_ws_en_12_8;
	wire																	pe_ws_en_13_8;
	wire																	pe_ws_en_14_8;
	wire																	pe_ws_en_15_8;
	wire																	pe_ws_en_0_9;
	wire																	pe_ws_en_1_9;
	wire																	pe_ws_en_2_9;
	wire																	pe_ws_en_3_9;
	wire																	pe_ws_en_4_9;
	wire																	pe_ws_en_5_9;
	wire																	pe_ws_en_6_9;
	wire																	pe_ws_en_7_9;
	wire																	pe_ws_en_8_9;
	wire																	pe_ws_en_9_9;
	wire																	pe_ws_en_10_9;
	wire																	pe_ws_en_11_9;
	wire																	pe_ws_en_12_9;
	wire																	pe_ws_en_13_9;
	wire																	pe_ws_en_14_9;
	wire																	pe_ws_en_15_9;
	wire																	pe_ws_en_0_10;
	wire																	pe_ws_en_1_10;
	wire																	pe_ws_en_2_10;
	wire																	pe_ws_en_3_10;
	wire																	pe_ws_en_4_10;
	wire																	pe_ws_en_5_10;
	wire																	pe_ws_en_6_10;
	wire																	pe_ws_en_7_10;
	wire																	pe_ws_en_8_10;
	wire																	pe_ws_en_9_10;
	wire																	pe_ws_en_10_10;
	wire																	pe_ws_en_11_10;
	wire																	pe_ws_en_12_10;
	wire																	pe_ws_en_13_10;
	wire																	pe_ws_en_14_10;
	wire																	pe_ws_en_15_10;
	wire																	pe_ws_en_0_11;
	wire																	pe_ws_en_1_11;
	wire																	pe_ws_en_2_11;
	wire																	pe_ws_en_3_11;
	wire																	pe_ws_en_4_11;
	wire																	pe_ws_en_5_11;
	wire																	pe_ws_en_6_11;
	wire																	pe_ws_en_7_11;
	wire																	pe_ws_en_8_11;
	wire																	pe_ws_en_9_11;
	wire																	pe_ws_en_10_11;
	wire																	pe_ws_en_11_11;
	wire																	pe_ws_en_12_11;
	wire																	pe_ws_en_13_11;
	wire																	pe_ws_en_14_11;
	wire																	pe_ws_en_15_11;
	wire																	pe_ws_en_0_12;
	wire																	pe_ws_en_1_12;
	wire																	pe_ws_en_2_12;
	wire																	pe_ws_en_3_12;
	wire																	pe_ws_en_4_12;
	wire																	pe_ws_en_5_12;
	wire																	pe_ws_en_6_12;
	wire																	pe_ws_en_7_12;
	wire																	pe_ws_en_8_12;
	wire																	pe_ws_en_9_12;
	wire																	pe_ws_en_10_12;
	wire																	pe_ws_en_11_12;
	wire																	pe_ws_en_12_12;
	wire																	pe_ws_en_13_12;
	wire																	pe_ws_en_14_12;
	wire																	pe_ws_en_15_12;
	wire																	pe_ws_en_0_13;
	wire																	pe_ws_en_1_13;
	wire																	pe_ws_en_2_13;
	wire																	pe_ws_en_3_13;
	wire																	pe_ws_en_4_13;
	wire																	pe_ws_en_5_13;
	wire																	pe_ws_en_6_13;
	wire																	pe_ws_en_7_13;
	wire																	pe_ws_en_8_13;
	wire																	pe_ws_en_9_13;
	wire																	pe_ws_en_10_13;
	wire																	pe_ws_en_11_13;
	wire																	pe_ws_en_12_13;
	wire																	pe_ws_en_13_13;
	wire																	pe_ws_en_14_13;
	wire																	pe_ws_en_15_13;
	wire																	pe_ws_en_0_14;
	wire																	pe_ws_en_1_14;
	wire																	pe_ws_en_2_14;
	wire																	pe_ws_en_3_14;
	wire																	pe_ws_en_4_14;
	wire																	pe_ws_en_5_14;
	wire																	pe_ws_en_6_14;
	wire																	pe_ws_en_7_14;
	wire																	pe_ws_en_8_14;
	wire																	pe_ws_en_9_14;
	wire																	pe_ws_en_10_14;
	wire																	pe_ws_en_11_14;
	wire																	pe_ws_en_12_14;
	wire																	pe_ws_en_13_14;
	wire																	pe_ws_en_14_14;
	wire																	pe_ws_en_15_14;
	wire																	pe_ws_en_0_15;
	wire																	pe_ws_en_1_15;
	wire																	pe_ws_en_2_15;
	wire																	pe_ws_en_3_15;
	wire																	pe_ws_en_4_15;
	wire																	pe_ws_en_5_15;
	wire																	pe_ws_en_6_15;
	wire																	pe_ws_en_7_15;
	wire																	pe_ws_en_8_15;
	wire																	pe_ws_en_9_15;
	wire																	pe_ws_en_10_15;
	wire																	pe_ws_en_11_15;
	wire																	pe_ws_en_12_15;
	wire																	pe_ws_en_13_15;
	wire																	pe_ws_en_14_15;
	wire																	pe_ws_en_15_15;
//
//
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_0;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_1;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_2;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_3;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_4;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_5;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_6;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_7;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_8;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_9;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_10;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_11;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_12;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_13;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_14;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_15;
//
//
	assign						pe_ws_en_row_0      	=       	pe_ws_en[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
	assign						pe_ws_en_row_1      	=       	pe_ws_en[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
	assign						pe_ws_en_row_2      	=       	pe_ws_en[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
	assign						pe_ws_en_row_3      	=       	pe_ws_en[(3+1)*ARRAY_DIM_X-1:3*ARRAY_DIM_X];
	assign						pe_ws_en_row_4      	=       	pe_ws_en[(4+1)*ARRAY_DIM_X-1:4*ARRAY_DIM_X];
	assign						pe_ws_en_row_5      	=       	pe_ws_en[(5+1)*ARRAY_DIM_X-1:5*ARRAY_DIM_X];
	assign						pe_ws_en_row_6      	=       	pe_ws_en[(6+1)*ARRAY_DIM_X-1:6*ARRAY_DIM_X];
	assign						pe_ws_en_row_7      	=       	pe_ws_en[(7+1)*ARRAY_DIM_X-1:7*ARRAY_DIM_X];
	assign						pe_ws_en_row_8      	=       	pe_ws_en[(8+1)*ARRAY_DIM_X-1:8*ARRAY_DIM_X];
	assign						pe_ws_en_row_9      	=       	pe_ws_en[(9+1)*ARRAY_DIM_X-1:9*ARRAY_DIM_X];
	assign						pe_ws_en_row_10      	=       	pe_ws_en[(10+1)*ARRAY_DIM_X-1:10*ARRAY_DIM_X];
	assign						pe_ws_en_row_11      	=       	pe_ws_en[(11+1)*ARRAY_DIM_X-1:11*ARRAY_DIM_X];
	assign						pe_ws_en_row_12      	=       	pe_ws_en[(12+1)*ARRAY_DIM_X-1:12*ARRAY_DIM_X];
	assign						pe_ws_en_row_13      	=       	pe_ws_en[(13+1)*ARRAY_DIM_X-1:13*ARRAY_DIM_X];
	assign						pe_ws_en_row_14      	=       	pe_ws_en[(14+1)*ARRAY_DIM_X-1:14*ARRAY_DIM_X];
	assign						pe_ws_en_row_15      	=       	pe_ws_en[(15+1)*ARRAY_DIM_X-1:15*ARRAY_DIM_X];
//
//
	assign						pe_ws_en_0_0 =	    	pe_ws_en_row_0[(0+1)-1:0];
	assign						pe_ws_en_1_0 =	    	pe_ws_en_row_1[(0+1)-1:0];
	assign						pe_ws_en_2_0 =	    	pe_ws_en_row_2[(0+1)-1:0];
	assign						pe_ws_en_3_0 =	    	pe_ws_en_row_3[(0+1)-1:0];
	assign						pe_ws_en_4_0 =	    	pe_ws_en_row_4[(0+1)-1:0];
	assign						pe_ws_en_5_0 =	    	pe_ws_en_row_5[(0+1)-1:0];
	assign						pe_ws_en_6_0 =	    	pe_ws_en_row_6[(0+1)-1:0];
	assign						pe_ws_en_7_0 =	    	pe_ws_en_row_7[(0+1)-1:0];
	assign						pe_ws_en_8_0 =	    	pe_ws_en_row_8[(0+1)-1:0];
	assign						pe_ws_en_9_0 =	    	pe_ws_en_row_9[(0+1)-1:0];
	assign						pe_ws_en_10_0 =	    	pe_ws_en_row_10[(0+1)-1:0];
	assign						pe_ws_en_11_0 =	    	pe_ws_en_row_11[(0+1)-1:0];
	assign						pe_ws_en_12_0 =	    	pe_ws_en_row_12[(0+1)-1:0];
	assign						pe_ws_en_13_0 =	    	pe_ws_en_row_13[(0+1)-1:0];
	assign						pe_ws_en_14_0 =	    	pe_ws_en_row_14[(0+1)-1:0];
	assign						pe_ws_en_15_0 =	    	pe_ws_en_row_15[(0+1)-1:0];
	assign						pe_ws_en_0_1 =	    	pe_ws_en_row_0[(1+1)-1:1];
	assign						pe_ws_en_1_1 =	    	pe_ws_en_row_1[(1+1)-1:1];
	assign						pe_ws_en_2_1 =	    	pe_ws_en_row_2[(1+1)-1:1];
	assign						pe_ws_en_3_1 =	    	pe_ws_en_row_3[(1+1)-1:1];
	assign						pe_ws_en_4_1 =	    	pe_ws_en_row_4[(1+1)-1:1];
	assign						pe_ws_en_5_1 =	    	pe_ws_en_row_5[(1+1)-1:1];
	assign						pe_ws_en_6_1 =	    	pe_ws_en_row_6[(1+1)-1:1];
	assign						pe_ws_en_7_1 =	    	pe_ws_en_row_7[(1+1)-1:1];
	assign						pe_ws_en_8_1 =	    	pe_ws_en_row_8[(1+1)-1:1];
	assign						pe_ws_en_9_1 =	    	pe_ws_en_row_9[(1+1)-1:1];
	assign						pe_ws_en_10_1 =	    	pe_ws_en_row_10[(1+1)-1:1];
	assign						pe_ws_en_11_1 =	    	pe_ws_en_row_11[(1+1)-1:1];
	assign						pe_ws_en_12_1 =	    	pe_ws_en_row_12[(1+1)-1:1];
	assign						pe_ws_en_13_1 =	    	pe_ws_en_row_13[(1+1)-1:1];
	assign						pe_ws_en_14_1 =	    	pe_ws_en_row_14[(1+1)-1:1];
	assign						pe_ws_en_15_1 =	    	pe_ws_en_row_15[(1+1)-1:1];
	assign						pe_ws_en_0_2 =	    	pe_ws_en_row_0[(2+1)-1:2];
	assign						pe_ws_en_1_2 =	    	pe_ws_en_row_1[(2+1)-1:2];
	assign						pe_ws_en_2_2 =	    	pe_ws_en_row_2[(2+1)-1:2];
	assign						pe_ws_en_3_2 =	    	pe_ws_en_row_3[(2+1)-1:2];
	assign						pe_ws_en_4_2 =	    	pe_ws_en_row_4[(2+1)-1:2];
	assign						pe_ws_en_5_2 =	    	pe_ws_en_row_5[(2+1)-1:2];
	assign						pe_ws_en_6_2 =	    	pe_ws_en_row_6[(2+1)-1:2];
	assign						pe_ws_en_7_2 =	    	pe_ws_en_row_7[(2+1)-1:2];
	assign						pe_ws_en_8_2 =	    	pe_ws_en_row_8[(2+1)-1:2];
	assign						pe_ws_en_9_2 =	    	pe_ws_en_row_9[(2+1)-1:2];
	assign						pe_ws_en_10_2 =	    	pe_ws_en_row_10[(2+1)-1:2];
	assign						pe_ws_en_11_2 =	    	pe_ws_en_row_11[(2+1)-1:2];
	assign						pe_ws_en_12_2 =	    	pe_ws_en_row_12[(2+1)-1:2];
	assign						pe_ws_en_13_2 =	    	pe_ws_en_row_13[(2+1)-1:2];
	assign						pe_ws_en_14_2 =	    	pe_ws_en_row_14[(2+1)-1:2];
	assign						pe_ws_en_15_2 =	    	pe_ws_en_row_15[(2+1)-1:2];
	assign						pe_ws_en_0_3 =	    	pe_ws_en_row_0[(3+1)-1:3];
	assign						pe_ws_en_1_3 =	    	pe_ws_en_row_1[(3+1)-1:3];
	assign						pe_ws_en_2_3 =	    	pe_ws_en_row_2[(3+1)-1:3];
	assign						pe_ws_en_3_3 =	    	pe_ws_en_row_3[(3+1)-1:3];
	assign						pe_ws_en_4_3 =	    	pe_ws_en_row_4[(3+1)-1:3];
	assign						pe_ws_en_5_3 =	    	pe_ws_en_row_5[(3+1)-1:3];
	assign						pe_ws_en_6_3 =	    	pe_ws_en_row_6[(3+1)-1:3];
	assign						pe_ws_en_7_3 =	    	pe_ws_en_row_7[(3+1)-1:3];
	assign						pe_ws_en_8_3 =	    	pe_ws_en_row_8[(3+1)-1:3];
	assign						pe_ws_en_9_3 =	    	pe_ws_en_row_9[(3+1)-1:3];
	assign						pe_ws_en_10_3 =	    	pe_ws_en_row_10[(3+1)-1:3];
	assign						pe_ws_en_11_3 =	    	pe_ws_en_row_11[(3+1)-1:3];
	assign						pe_ws_en_12_3 =	    	pe_ws_en_row_12[(3+1)-1:3];
	assign						pe_ws_en_13_3 =	    	pe_ws_en_row_13[(3+1)-1:3];
	assign						pe_ws_en_14_3 =	    	pe_ws_en_row_14[(3+1)-1:3];
	assign						pe_ws_en_15_3 =	    	pe_ws_en_row_15[(3+1)-1:3];
	assign						pe_ws_en_0_4 =	    	pe_ws_en_row_0[(4+1)-1:4];
	assign						pe_ws_en_1_4 =	    	pe_ws_en_row_1[(4+1)-1:4];
	assign						pe_ws_en_2_4 =	    	pe_ws_en_row_2[(4+1)-1:4];
	assign						pe_ws_en_3_4 =	    	pe_ws_en_row_3[(4+1)-1:4];
	assign						pe_ws_en_4_4 =	    	pe_ws_en_row_4[(4+1)-1:4];
	assign						pe_ws_en_5_4 =	    	pe_ws_en_row_5[(4+1)-1:4];
	assign						pe_ws_en_6_4 =	    	pe_ws_en_row_6[(4+1)-1:4];
	assign						pe_ws_en_7_4 =	    	pe_ws_en_row_7[(4+1)-1:4];
	assign						pe_ws_en_8_4 =	    	pe_ws_en_row_8[(4+1)-1:4];
	assign						pe_ws_en_9_4 =	    	pe_ws_en_row_9[(4+1)-1:4];
	assign						pe_ws_en_10_4 =	    	pe_ws_en_row_10[(4+1)-1:4];
	assign						pe_ws_en_11_4 =	    	pe_ws_en_row_11[(4+1)-1:4];
	assign						pe_ws_en_12_4 =	    	pe_ws_en_row_12[(4+1)-1:4];
	assign						pe_ws_en_13_4 =	    	pe_ws_en_row_13[(4+1)-1:4];
	assign						pe_ws_en_14_4 =	    	pe_ws_en_row_14[(4+1)-1:4];
	assign						pe_ws_en_15_4 =	    	pe_ws_en_row_15[(4+1)-1:4];
	assign						pe_ws_en_0_5 =	    	pe_ws_en_row_0[(5+1)-1:5];
	assign						pe_ws_en_1_5 =	    	pe_ws_en_row_1[(5+1)-1:5];
	assign						pe_ws_en_2_5 =	    	pe_ws_en_row_2[(5+1)-1:5];
	assign						pe_ws_en_3_5 =	    	pe_ws_en_row_3[(5+1)-1:5];
	assign						pe_ws_en_4_5 =	    	pe_ws_en_row_4[(5+1)-1:5];
	assign						pe_ws_en_5_5 =	    	pe_ws_en_row_5[(5+1)-1:5];
	assign						pe_ws_en_6_5 =	    	pe_ws_en_row_6[(5+1)-1:5];
	assign						pe_ws_en_7_5 =	    	pe_ws_en_row_7[(5+1)-1:5];
	assign						pe_ws_en_8_5 =	    	pe_ws_en_row_8[(5+1)-1:5];
	assign						pe_ws_en_9_5 =	    	pe_ws_en_row_9[(5+1)-1:5];
	assign						pe_ws_en_10_5 =	    	pe_ws_en_row_10[(5+1)-1:5];
	assign						pe_ws_en_11_5 =	    	pe_ws_en_row_11[(5+1)-1:5];
	assign						pe_ws_en_12_5 =	    	pe_ws_en_row_12[(5+1)-1:5];
	assign						pe_ws_en_13_5 =	    	pe_ws_en_row_13[(5+1)-1:5];
	assign						pe_ws_en_14_5 =	    	pe_ws_en_row_14[(5+1)-1:5];
	assign						pe_ws_en_15_5 =	    	pe_ws_en_row_15[(5+1)-1:5];
	assign						pe_ws_en_0_6 =	    	pe_ws_en_row_0[(6+1)-1:6];
	assign						pe_ws_en_1_6 =	    	pe_ws_en_row_1[(6+1)-1:6];
	assign						pe_ws_en_2_6 =	    	pe_ws_en_row_2[(6+1)-1:6];
	assign						pe_ws_en_3_6 =	    	pe_ws_en_row_3[(6+1)-1:6];
	assign						pe_ws_en_4_6 =	    	pe_ws_en_row_4[(6+1)-1:6];
	assign						pe_ws_en_5_6 =	    	pe_ws_en_row_5[(6+1)-1:6];
	assign						pe_ws_en_6_6 =	    	pe_ws_en_row_6[(6+1)-1:6];
	assign						pe_ws_en_7_6 =	    	pe_ws_en_row_7[(6+1)-1:6];
	assign						pe_ws_en_8_6 =	    	pe_ws_en_row_8[(6+1)-1:6];
	assign						pe_ws_en_9_6 =	    	pe_ws_en_row_9[(6+1)-1:6];
	assign						pe_ws_en_10_6 =	    	pe_ws_en_row_10[(6+1)-1:6];
	assign						pe_ws_en_11_6 =	    	pe_ws_en_row_11[(6+1)-1:6];
	assign						pe_ws_en_12_6 =	    	pe_ws_en_row_12[(6+1)-1:6];
	assign						pe_ws_en_13_6 =	    	pe_ws_en_row_13[(6+1)-1:6];
	assign						pe_ws_en_14_6 =	    	pe_ws_en_row_14[(6+1)-1:6];
	assign						pe_ws_en_15_6 =	    	pe_ws_en_row_15[(6+1)-1:6];
	assign						pe_ws_en_0_7 =	    	pe_ws_en_row_0[(7+1)-1:7];
	assign						pe_ws_en_1_7 =	    	pe_ws_en_row_1[(7+1)-1:7];
	assign						pe_ws_en_2_7 =	    	pe_ws_en_row_2[(7+1)-1:7];
	assign						pe_ws_en_3_7 =	    	pe_ws_en_row_3[(7+1)-1:7];
	assign						pe_ws_en_4_7 =	    	pe_ws_en_row_4[(7+1)-1:7];
	assign						pe_ws_en_5_7 =	    	pe_ws_en_row_5[(7+1)-1:7];
	assign						pe_ws_en_6_7 =	    	pe_ws_en_row_6[(7+1)-1:7];
	assign						pe_ws_en_7_7 =	    	pe_ws_en_row_7[(7+1)-1:7];
	assign						pe_ws_en_8_7 =	    	pe_ws_en_row_8[(7+1)-1:7];
	assign						pe_ws_en_9_7 =	    	pe_ws_en_row_9[(7+1)-1:7];
	assign						pe_ws_en_10_7 =	    	pe_ws_en_row_10[(7+1)-1:7];
	assign						pe_ws_en_11_7 =	    	pe_ws_en_row_11[(7+1)-1:7];
	assign						pe_ws_en_12_7 =	    	pe_ws_en_row_12[(7+1)-1:7];
	assign						pe_ws_en_13_7 =	    	pe_ws_en_row_13[(7+1)-1:7];
	assign						pe_ws_en_14_7 =	    	pe_ws_en_row_14[(7+1)-1:7];
	assign						pe_ws_en_15_7 =	    	pe_ws_en_row_15[(7+1)-1:7];
	assign						pe_ws_en_0_8 =	    	pe_ws_en_row_0[(8+1)-1:8];
	assign						pe_ws_en_1_8 =	    	pe_ws_en_row_1[(8+1)-1:8];
	assign						pe_ws_en_2_8 =	    	pe_ws_en_row_2[(8+1)-1:8];
	assign						pe_ws_en_3_8 =	    	pe_ws_en_row_3[(8+1)-1:8];
	assign						pe_ws_en_4_8 =	    	pe_ws_en_row_4[(8+1)-1:8];
	assign						pe_ws_en_5_8 =	    	pe_ws_en_row_5[(8+1)-1:8];
	assign						pe_ws_en_6_8 =	    	pe_ws_en_row_6[(8+1)-1:8];
	assign						pe_ws_en_7_8 =	    	pe_ws_en_row_7[(8+1)-1:8];
	assign						pe_ws_en_8_8 =	    	pe_ws_en_row_8[(8+1)-1:8];
	assign						pe_ws_en_9_8 =	    	pe_ws_en_row_9[(8+1)-1:8];
	assign						pe_ws_en_10_8 =	    	pe_ws_en_row_10[(8+1)-1:8];
	assign						pe_ws_en_11_8 =	    	pe_ws_en_row_11[(8+1)-1:8];
	assign						pe_ws_en_12_8 =	    	pe_ws_en_row_12[(8+1)-1:8];
	assign						pe_ws_en_13_8 =	    	pe_ws_en_row_13[(8+1)-1:8];
	assign						pe_ws_en_14_8 =	    	pe_ws_en_row_14[(8+1)-1:8];
	assign						pe_ws_en_15_8 =	    	pe_ws_en_row_15[(8+1)-1:8];
	assign						pe_ws_en_0_9 =	    	pe_ws_en_row_0[(9+1)-1:9];
	assign						pe_ws_en_1_9 =	    	pe_ws_en_row_1[(9+1)-1:9];
	assign						pe_ws_en_2_9 =	    	pe_ws_en_row_2[(9+1)-1:9];
	assign						pe_ws_en_3_9 =	    	pe_ws_en_row_3[(9+1)-1:9];
	assign						pe_ws_en_4_9 =	    	pe_ws_en_row_4[(9+1)-1:9];
	assign						pe_ws_en_5_9 =	    	pe_ws_en_row_5[(9+1)-1:9];
	assign						pe_ws_en_6_9 =	    	pe_ws_en_row_6[(9+1)-1:9];
	assign						pe_ws_en_7_9 =	    	pe_ws_en_row_7[(9+1)-1:9];
	assign						pe_ws_en_8_9 =	    	pe_ws_en_row_8[(9+1)-1:9];
	assign						pe_ws_en_9_9 =	    	pe_ws_en_row_9[(9+1)-1:9];
	assign						pe_ws_en_10_9 =	    	pe_ws_en_row_10[(9+1)-1:9];
	assign						pe_ws_en_11_9 =	    	pe_ws_en_row_11[(9+1)-1:9];
	assign						pe_ws_en_12_9 =	    	pe_ws_en_row_12[(9+1)-1:9];
	assign						pe_ws_en_13_9 =	    	pe_ws_en_row_13[(9+1)-1:9];
	assign						pe_ws_en_14_9 =	    	pe_ws_en_row_14[(9+1)-1:9];
	assign						pe_ws_en_15_9 =	    	pe_ws_en_row_15[(9+1)-1:9];
	assign						pe_ws_en_0_10 =	    	pe_ws_en_row_0[(10+1)-1:10];
	assign						pe_ws_en_1_10 =	    	pe_ws_en_row_1[(10+1)-1:10];
	assign						pe_ws_en_2_10 =	    	pe_ws_en_row_2[(10+1)-1:10];
	assign						pe_ws_en_3_10 =	    	pe_ws_en_row_3[(10+1)-1:10];
	assign						pe_ws_en_4_10 =	    	pe_ws_en_row_4[(10+1)-1:10];
	assign						pe_ws_en_5_10 =	    	pe_ws_en_row_5[(10+1)-1:10];
	assign						pe_ws_en_6_10 =	    	pe_ws_en_row_6[(10+1)-1:10];
	assign						pe_ws_en_7_10 =	    	pe_ws_en_row_7[(10+1)-1:10];
	assign						pe_ws_en_8_10 =	    	pe_ws_en_row_8[(10+1)-1:10];
	assign						pe_ws_en_9_10 =	    	pe_ws_en_row_9[(10+1)-1:10];
	assign						pe_ws_en_10_10 =	    	pe_ws_en_row_10[(10+1)-1:10];
	assign						pe_ws_en_11_10 =	    	pe_ws_en_row_11[(10+1)-1:10];
	assign						pe_ws_en_12_10 =	    	pe_ws_en_row_12[(10+1)-1:10];
	assign						pe_ws_en_13_10 =	    	pe_ws_en_row_13[(10+1)-1:10];
	assign						pe_ws_en_14_10 =	    	pe_ws_en_row_14[(10+1)-1:10];
	assign						pe_ws_en_15_10 =	    	pe_ws_en_row_15[(10+1)-1:10];
	assign						pe_ws_en_0_11 =	    	pe_ws_en_row_0[(11+1)-1:11];
	assign						pe_ws_en_1_11 =	    	pe_ws_en_row_1[(11+1)-1:11];
	assign						pe_ws_en_2_11 =	    	pe_ws_en_row_2[(11+1)-1:11];
	assign						pe_ws_en_3_11 =	    	pe_ws_en_row_3[(11+1)-1:11];
	assign						pe_ws_en_4_11 =	    	pe_ws_en_row_4[(11+1)-1:11];
	assign						pe_ws_en_5_11 =	    	pe_ws_en_row_5[(11+1)-1:11];
	assign						pe_ws_en_6_11 =	    	pe_ws_en_row_6[(11+1)-1:11];
	assign						pe_ws_en_7_11 =	    	pe_ws_en_row_7[(11+1)-1:11];
	assign						pe_ws_en_8_11 =	    	pe_ws_en_row_8[(11+1)-1:11];
	assign						pe_ws_en_9_11 =	    	pe_ws_en_row_9[(11+1)-1:11];
	assign						pe_ws_en_10_11 =	    	pe_ws_en_row_10[(11+1)-1:11];
	assign						pe_ws_en_11_11 =	    	pe_ws_en_row_11[(11+1)-1:11];
	assign						pe_ws_en_12_11 =	    	pe_ws_en_row_12[(11+1)-1:11];
	assign						pe_ws_en_13_11 =	    	pe_ws_en_row_13[(11+1)-1:11];
	assign						pe_ws_en_14_11 =	    	pe_ws_en_row_14[(11+1)-1:11];
	assign						pe_ws_en_15_11 =	    	pe_ws_en_row_15[(11+1)-1:11];
	assign						pe_ws_en_0_12 =	    	pe_ws_en_row_0[(12+1)-1:12];
	assign						pe_ws_en_1_12 =	    	pe_ws_en_row_1[(12+1)-1:12];
	assign						pe_ws_en_2_12 =	    	pe_ws_en_row_2[(12+1)-1:12];
	assign						pe_ws_en_3_12 =	    	pe_ws_en_row_3[(12+1)-1:12];
	assign						pe_ws_en_4_12 =	    	pe_ws_en_row_4[(12+1)-1:12];
	assign						pe_ws_en_5_12 =	    	pe_ws_en_row_5[(12+1)-1:12];
	assign						pe_ws_en_6_12 =	    	pe_ws_en_row_6[(12+1)-1:12];
	assign						pe_ws_en_7_12 =	    	pe_ws_en_row_7[(12+1)-1:12];
	assign						pe_ws_en_8_12 =	    	pe_ws_en_row_8[(12+1)-1:12];
	assign						pe_ws_en_9_12 =	    	pe_ws_en_row_9[(12+1)-1:12];
	assign						pe_ws_en_10_12 =	    	pe_ws_en_row_10[(12+1)-1:12];
	assign						pe_ws_en_11_12 =	    	pe_ws_en_row_11[(12+1)-1:12];
	assign						pe_ws_en_12_12 =	    	pe_ws_en_row_12[(12+1)-1:12];
	assign						pe_ws_en_13_12 =	    	pe_ws_en_row_13[(12+1)-1:12];
	assign						pe_ws_en_14_12 =	    	pe_ws_en_row_14[(12+1)-1:12];
	assign						pe_ws_en_15_12 =	    	pe_ws_en_row_15[(12+1)-1:12];
	assign						pe_ws_en_0_13 =	    	pe_ws_en_row_0[(13+1)-1:13];
	assign						pe_ws_en_1_13 =	    	pe_ws_en_row_1[(13+1)-1:13];
	assign						pe_ws_en_2_13 =	    	pe_ws_en_row_2[(13+1)-1:13];
	assign						pe_ws_en_3_13 =	    	pe_ws_en_row_3[(13+1)-1:13];
	assign						pe_ws_en_4_13 =	    	pe_ws_en_row_4[(13+1)-1:13];
	assign						pe_ws_en_5_13 =	    	pe_ws_en_row_5[(13+1)-1:13];
	assign						pe_ws_en_6_13 =	    	pe_ws_en_row_6[(13+1)-1:13];
	assign						pe_ws_en_7_13 =	    	pe_ws_en_row_7[(13+1)-1:13];
	assign						pe_ws_en_8_13 =	    	pe_ws_en_row_8[(13+1)-1:13];
	assign						pe_ws_en_9_13 =	    	pe_ws_en_row_9[(13+1)-1:13];
	assign						pe_ws_en_10_13 =	    	pe_ws_en_row_10[(13+1)-1:13];
	assign						pe_ws_en_11_13 =	    	pe_ws_en_row_11[(13+1)-1:13];
	assign						pe_ws_en_12_13 =	    	pe_ws_en_row_12[(13+1)-1:13];
	assign						pe_ws_en_13_13 =	    	pe_ws_en_row_13[(13+1)-1:13];
	assign						pe_ws_en_14_13 =	    	pe_ws_en_row_14[(13+1)-1:13];
	assign						pe_ws_en_15_13 =	    	pe_ws_en_row_15[(13+1)-1:13];
	assign						pe_ws_en_0_14 =	    	pe_ws_en_row_0[(14+1)-1:14];
	assign						pe_ws_en_1_14 =	    	pe_ws_en_row_1[(14+1)-1:14];
	assign						pe_ws_en_2_14 =	    	pe_ws_en_row_2[(14+1)-1:14];
	assign						pe_ws_en_3_14 =	    	pe_ws_en_row_3[(14+1)-1:14];
	assign						pe_ws_en_4_14 =	    	pe_ws_en_row_4[(14+1)-1:14];
	assign						pe_ws_en_5_14 =	    	pe_ws_en_row_5[(14+1)-1:14];
	assign						pe_ws_en_6_14 =	    	pe_ws_en_row_6[(14+1)-1:14];
	assign						pe_ws_en_7_14 =	    	pe_ws_en_row_7[(14+1)-1:14];
	assign						pe_ws_en_8_14 =	    	pe_ws_en_row_8[(14+1)-1:14];
	assign						pe_ws_en_9_14 =	    	pe_ws_en_row_9[(14+1)-1:14];
	assign						pe_ws_en_10_14 =	    	pe_ws_en_row_10[(14+1)-1:14];
	assign						pe_ws_en_11_14 =	    	pe_ws_en_row_11[(14+1)-1:14];
	assign						pe_ws_en_12_14 =	    	pe_ws_en_row_12[(14+1)-1:14];
	assign						pe_ws_en_13_14 =	    	pe_ws_en_row_13[(14+1)-1:14];
	assign						pe_ws_en_14_14 =	    	pe_ws_en_row_14[(14+1)-1:14];
	assign						pe_ws_en_15_14 =	    	pe_ws_en_row_15[(14+1)-1:14];
	assign						pe_ws_en_0_15 =	    	pe_ws_en_row_0[(15+1)-1:15];
	assign						pe_ws_en_1_15 =	    	pe_ws_en_row_1[(15+1)-1:15];
	assign						pe_ws_en_2_15 =	    	pe_ws_en_row_2[(15+1)-1:15];
	assign						pe_ws_en_3_15 =	    	pe_ws_en_row_3[(15+1)-1:15];
	assign						pe_ws_en_4_15 =	    	pe_ws_en_row_4[(15+1)-1:15];
	assign						pe_ws_en_5_15 =	    	pe_ws_en_row_5[(15+1)-1:15];
	assign						pe_ws_en_6_15 =	    	pe_ws_en_row_6[(15+1)-1:15];
	assign						pe_ws_en_7_15 =	    	pe_ws_en_row_7[(15+1)-1:15];
	assign						pe_ws_en_8_15 =	    	pe_ws_en_row_8[(15+1)-1:15];
	assign						pe_ws_en_9_15 =	    	pe_ws_en_row_9[(15+1)-1:15];
	assign						pe_ws_en_10_15 =	    	pe_ws_en_row_10[(15+1)-1:15];
	assign						pe_ws_en_11_15 =	    	pe_ws_en_row_11[(15+1)-1:15];
	assign						pe_ws_en_12_15 =	    	pe_ws_en_row_12[(15+1)-1:15];
	assign						pe_ws_en_13_15 =	    	pe_ws_en_row_13[(15+1)-1:15];
	assign						pe_ws_en_14_15 =	    	pe_ws_en_row_14[(15+1)-1:15];
	assign						pe_ws_en_15_15 =	    	pe_ws_en_row_15[(15+1)-1:15];
//
//
	wire																	pe_ws_mux_0_0;
	wire																	pe_ws_mux_1_0;
	wire																	pe_ws_mux_2_0;
	wire																	pe_ws_mux_3_0;
	wire																	pe_ws_mux_4_0;
	wire																	pe_ws_mux_5_0;
	wire																	pe_ws_mux_6_0;
	wire																	pe_ws_mux_7_0;
	wire																	pe_ws_mux_8_0;
	wire																	pe_ws_mux_9_0;
	wire																	pe_ws_mux_10_0;
	wire																	pe_ws_mux_11_0;
	wire																	pe_ws_mux_12_0;
	wire																	pe_ws_mux_13_0;
	wire																	pe_ws_mux_14_0;
	wire																	pe_ws_mux_15_0;
	wire																	pe_ws_mux_0_1;
	wire																	pe_ws_mux_1_1;
	wire																	pe_ws_mux_2_1;
	wire																	pe_ws_mux_3_1;
	wire																	pe_ws_mux_4_1;
	wire																	pe_ws_mux_5_1;
	wire																	pe_ws_mux_6_1;
	wire																	pe_ws_mux_7_1;
	wire																	pe_ws_mux_8_1;
	wire																	pe_ws_mux_9_1;
	wire																	pe_ws_mux_10_1;
	wire																	pe_ws_mux_11_1;
	wire																	pe_ws_mux_12_1;
	wire																	pe_ws_mux_13_1;
	wire																	pe_ws_mux_14_1;
	wire																	pe_ws_mux_15_1;
	wire																	pe_ws_mux_0_2;
	wire																	pe_ws_mux_1_2;
	wire																	pe_ws_mux_2_2;
	wire																	pe_ws_mux_3_2;
	wire																	pe_ws_mux_4_2;
	wire																	pe_ws_mux_5_2;
	wire																	pe_ws_mux_6_2;
	wire																	pe_ws_mux_7_2;
	wire																	pe_ws_mux_8_2;
	wire																	pe_ws_mux_9_2;
	wire																	pe_ws_mux_10_2;
	wire																	pe_ws_mux_11_2;
	wire																	pe_ws_mux_12_2;
	wire																	pe_ws_mux_13_2;
	wire																	pe_ws_mux_14_2;
	wire																	pe_ws_mux_15_2;
	wire																	pe_ws_mux_0_3;
	wire																	pe_ws_mux_1_3;
	wire																	pe_ws_mux_2_3;
	wire																	pe_ws_mux_3_3;
	wire																	pe_ws_mux_4_3;
	wire																	pe_ws_mux_5_3;
	wire																	pe_ws_mux_6_3;
	wire																	pe_ws_mux_7_3;
	wire																	pe_ws_mux_8_3;
	wire																	pe_ws_mux_9_3;
	wire																	pe_ws_mux_10_3;
	wire																	pe_ws_mux_11_3;
	wire																	pe_ws_mux_12_3;
	wire																	pe_ws_mux_13_3;
	wire																	pe_ws_mux_14_3;
	wire																	pe_ws_mux_15_3;
	wire																	pe_ws_mux_0_4;
	wire																	pe_ws_mux_1_4;
	wire																	pe_ws_mux_2_4;
	wire																	pe_ws_mux_3_4;
	wire																	pe_ws_mux_4_4;
	wire																	pe_ws_mux_5_4;
	wire																	pe_ws_mux_6_4;
	wire																	pe_ws_mux_7_4;
	wire																	pe_ws_mux_8_4;
	wire																	pe_ws_mux_9_4;
	wire																	pe_ws_mux_10_4;
	wire																	pe_ws_mux_11_4;
	wire																	pe_ws_mux_12_4;
	wire																	pe_ws_mux_13_4;
	wire																	pe_ws_mux_14_4;
	wire																	pe_ws_mux_15_4;
	wire																	pe_ws_mux_0_5;
	wire																	pe_ws_mux_1_5;
	wire																	pe_ws_mux_2_5;
	wire																	pe_ws_mux_3_5;
	wire																	pe_ws_mux_4_5;
	wire																	pe_ws_mux_5_5;
	wire																	pe_ws_mux_6_5;
	wire																	pe_ws_mux_7_5;
	wire																	pe_ws_mux_8_5;
	wire																	pe_ws_mux_9_5;
	wire																	pe_ws_mux_10_5;
	wire																	pe_ws_mux_11_5;
	wire																	pe_ws_mux_12_5;
	wire																	pe_ws_mux_13_5;
	wire																	pe_ws_mux_14_5;
	wire																	pe_ws_mux_15_5;
	wire																	pe_ws_mux_0_6;
	wire																	pe_ws_mux_1_6;
	wire																	pe_ws_mux_2_6;
	wire																	pe_ws_mux_3_6;
	wire																	pe_ws_mux_4_6;
	wire																	pe_ws_mux_5_6;
	wire																	pe_ws_mux_6_6;
	wire																	pe_ws_mux_7_6;
	wire																	pe_ws_mux_8_6;
	wire																	pe_ws_mux_9_6;
	wire																	pe_ws_mux_10_6;
	wire																	pe_ws_mux_11_6;
	wire																	pe_ws_mux_12_6;
	wire																	pe_ws_mux_13_6;
	wire																	pe_ws_mux_14_6;
	wire																	pe_ws_mux_15_6;
	wire																	pe_ws_mux_0_7;
	wire																	pe_ws_mux_1_7;
	wire																	pe_ws_mux_2_7;
	wire																	pe_ws_mux_3_7;
	wire																	pe_ws_mux_4_7;
	wire																	pe_ws_mux_5_7;
	wire																	pe_ws_mux_6_7;
	wire																	pe_ws_mux_7_7;
	wire																	pe_ws_mux_8_7;
	wire																	pe_ws_mux_9_7;
	wire																	pe_ws_mux_10_7;
	wire																	pe_ws_mux_11_7;
	wire																	pe_ws_mux_12_7;
	wire																	pe_ws_mux_13_7;
	wire																	pe_ws_mux_14_7;
	wire																	pe_ws_mux_15_7;
	wire																	pe_ws_mux_0_8;
	wire																	pe_ws_mux_1_8;
	wire																	pe_ws_mux_2_8;
	wire																	pe_ws_mux_3_8;
	wire																	pe_ws_mux_4_8;
	wire																	pe_ws_mux_5_8;
	wire																	pe_ws_mux_6_8;
	wire																	pe_ws_mux_7_8;
	wire																	pe_ws_mux_8_8;
	wire																	pe_ws_mux_9_8;
	wire																	pe_ws_mux_10_8;
	wire																	pe_ws_mux_11_8;
	wire																	pe_ws_mux_12_8;
	wire																	pe_ws_mux_13_8;
	wire																	pe_ws_mux_14_8;
	wire																	pe_ws_mux_15_8;
	wire																	pe_ws_mux_0_9;
	wire																	pe_ws_mux_1_9;
	wire																	pe_ws_mux_2_9;
	wire																	pe_ws_mux_3_9;
	wire																	pe_ws_mux_4_9;
	wire																	pe_ws_mux_5_9;
	wire																	pe_ws_mux_6_9;
	wire																	pe_ws_mux_7_9;
	wire																	pe_ws_mux_8_9;
	wire																	pe_ws_mux_9_9;
	wire																	pe_ws_mux_10_9;
	wire																	pe_ws_mux_11_9;
	wire																	pe_ws_mux_12_9;
	wire																	pe_ws_mux_13_9;
	wire																	pe_ws_mux_14_9;
	wire																	pe_ws_mux_15_9;
	wire																	pe_ws_mux_0_10;
	wire																	pe_ws_mux_1_10;
	wire																	pe_ws_mux_2_10;
	wire																	pe_ws_mux_3_10;
	wire																	pe_ws_mux_4_10;
	wire																	pe_ws_mux_5_10;
	wire																	pe_ws_mux_6_10;
	wire																	pe_ws_mux_7_10;
	wire																	pe_ws_mux_8_10;
	wire																	pe_ws_mux_9_10;
	wire																	pe_ws_mux_10_10;
	wire																	pe_ws_mux_11_10;
	wire																	pe_ws_mux_12_10;
	wire																	pe_ws_mux_13_10;
	wire																	pe_ws_mux_14_10;
	wire																	pe_ws_mux_15_10;
	wire																	pe_ws_mux_0_11;
	wire																	pe_ws_mux_1_11;
	wire																	pe_ws_mux_2_11;
	wire																	pe_ws_mux_3_11;
	wire																	pe_ws_mux_4_11;
	wire																	pe_ws_mux_5_11;
	wire																	pe_ws_mux_6_11;
	wire																	pe_ws_mux_7_11;
	wire																	pe_ws_mux_8_11;
	wire																	pe_ws_mux_9_11;
	wire																	pe_ws_mux_10_11;
	wire																	pe_ws_mux_11_11;
	wire																	pe_ws_mux_12_11;
	wire																	pe_ws_mux_13_11;
	wire																	pe_ws_mux_14_11;
	wire																	pe_ws_mux_15_11;
	wire																	pe_ws_mux_0_12;
	wire																	pe_ws_mux_1_12;
	wire																	pe_ws_mux_2_12;
	wire																	pe_ws_mux_3_12;
	wire																	pe_ws_mux_4_12;
	wire																	pe_ws_mux_5_12;
	wire																	pe_ws_mux_6_12;
	wire																	pe_ws_mux_7_12;
	wire																	pe_ws_mux_8_12;
	wire																	pe_ws_mux_9_12;
	wire																	pe_ws_mux_10_12;
	wire																	pe_ws_mux_11_12;
	wire																	pe_ws_mux_12_12;
	wire																	pe_ws_mux_13_12;
	wire																	pe_ws_mux_14_12;
	wire																	pe_ws_mux_15_12;
	wire																	pe_ws_mux_0_13;
	wire																	pe_ws_mux_1_13;
	wire																	pe_ws_mux_2_13;
	wire																	pe_ws_mux_3_13;
	wire																	pe_ws_mux_4_13;
	wire																	pe_ws_mux_5_13;
	wire																	pe_ws_mux_6_13;
	wire																	pe_ws_mux_7_13;
	wire																	pe_ws_mux_8_13;
	wire																	pe_ws_mux_9_13;
	wire																	pe_ws_mux_10_13;
	wire																	pe_ws_mux_11_13;
	wire																	pe_ws_mux_12_13;
	wire																	pe_ws_mux_13_13;
	wire																	pe_ws_mux_14_13;
	wire																	pe_ws_mux_15_13;
	wire																	pe_ws_mux_0_14;
	wire																	pe_ws_mux_1_14;
	wire																	pe_ws_mux_2_14;
	wire																	pe_ws_mux_3_14;
	wire																	pe_ws_mux_4_14;
	wire																	pe_ws_mux_5_14;
	wire																	pe_ws_mux_6_14;
	wire																	pe_ws_mux_7_14;
	wire																	pe_ws_mux_8_14;
	wire																	pe_ws_mux_9_14;
	wire																	pe_ws_mux_10_14;
	wire																	pe_ws_mux_11_14;
	wire																	pe_ws_mux_12_14;
	wire																	pe_ws_mux_13_14;
	wire																	pe_ws_mux_14_14;
	wire																	pe_ws_mux_15_14;
	wire																	pe_ws_mux_0_15;
	wire																	pe_ws_mux_1_15;
	wire																	pe_ws_mux_2_15;
	wire																	pe_ws_mux_3_15;
	wire																	pe_ws_mux_4_15;
	wire																	pe_ws_mux_5_15;
	wire																	pe_ws_mux_6_15;
	wire																	pe_ws_mux_7_15;
	wire																	pe_ws_mux_8_15;
	wire																	pe_ws_mux_9_15;
	wire																	pe_ws_mux_10_15;
	wire																	pe_ws_mux_11_15;
	wire																	pe_ws_mux_12_15;
	wire																	pe_ws_mux_13_15;
	wire																	pe_ws_mux_14_15;
	wire																	pe_ws_mux_15_15;
//
//
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_0;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_1;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_2;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_3;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_4;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_5;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_6;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_7;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_8;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_9;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_10;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_11;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_12;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_13;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_14;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_15;
//
//
	assign						pe_ws_mux_row_0      	= 			pe_ws_mux[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
	assign						pe_ws_mux_row_1      	= 			pe_ws_mux[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
	assign						pe_ws_mux_row_2      	= 			pe_ws_mux[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
	assign						pe_ws_mux_row_3      	= 			pe_ws_mux[(3+1)*ARRAY_DIM_X-1:3*ARRAY_DIM_X];
	assign						pe_ws_mux_row_4      	= 			pe_ws_mux[(4+1)*ARRAY_DIM_X-1:4*ARRAY_DIM_X];
	assign						pe_ws_mux_row_5      	= 			pe_ws_mux[(5+1)*ARRAY_DIM_X-1:5*ARRAY_DIM_X];
	assign						pe_ws_mux_row_6      	= 			pe_ws_mux[(6+1)*ARRAY_DIM_X-1:6*ARRAY_DIM_X];
	assign						pe_ws_mux_row_7      	= 			pe_ws_mux[(7+1)*ARRAY_DIM_X-1:7*ARRAY_DIM_X];
	assign						pe_ws_mux_row_8      	= 			pe_ws_mux[(8+1)*ARRAY_DIM_X-1:8*ARRAY_DIM_X];
	assign						pe_ws_mux_row_9      	= 			pe_ws_mux[(9+1)*ARRAY_DIM_X-1:9*ARRAY_DIM_X];
	assign						pe_ws_mux_row_10      	= 			pe_ws_mux[(10+1)*ARRAY_DIM_X-1:10*ARRAY_DIM_X];
	assign						pe_ws_mux_row_11      	= 			pe_ws_mux[(11+1)*ARRAY_DIM_X-1:11*ARRAY_DIM_X];
	assign						pe_ws_mux_row_12      	= 			pe_ws_mux[(12+1)*ARRAY_DIM_X-1:12*ARRAY_DIM_X];
	assign						pe_ws_mux_row_13      	= 			pe_ws_mux[(13+1)*ARRAY_DIM_X-1:13*ARRAY_DIM_X];
	assign						pe_ws_mux_row_14      	= 			pe_ws_mux[(14+1)*ARRAY_DIM_X-1:14*ARRAY_DIM_X];
	assign						pe_ws_mux_row_15      	= 			pe_ws_mux[(15+1)*ARRAY_DIM_X-1:15*ARRAY_DIM_X];
//
//
	assign						pe_ws_mux_0_0 =  		pe_ws_mux_row_0[(0+1)-1:0];
	assign						pe_ws_mux_1_0 =  		pe_ws_mux_row_1[(0+1)-1:0];
	assign						pe_ws_mux_2_0 =  		pe_ws_mux_row_2[(0+1)-1:0];
	assign						pe_ws_mux_3_0 =  		pe_ws_mux_row_3[(0+1)-1:0];
	assign						pe_ws_mux_4_0 =  		pe_ws_mux_row_4[(0+1)-1:0];
	assign						pe_ws_mux_5_0 =  		pe_ws_mux_row_5[(0+1)-1:0];
	assign						pe_ws_mux_6_0 =  		pe_ws_mux_row_6[(0+1)-1:0];
	assign						pe_ws_mux_7_0 =  		pe_ws_mux_row_7[(0+1)-1:0];
	assign						pe_ws_mux_8_0 =  		pe_ws_mux_row_8[(0+1)-1:0];
	assign						pe_ws_mux_9_0 =  		pe_ws_mux_row_9[(0+1)-1:0];
	assign						pe_ws_mux_10_0 =  		pe_ws_mux_row_10[(0+1)-1:0];
	assign						pe_ws_mux_11_0 =  		pe_ws_mux_row_11[(0+1)-1:0];
	assign						pe_ws_mux_12_0 =  		pe_ws_mux_row_12[(0+1)-1:0];
	assign						pe_ws_mux_13_0 =  		pe_ws_mux_row_13[(0+1)-1:0];
	assign						pe_ws_mux_14_0 =  		pe_ws_mux_row_14[(0+1)-1:0];
	assign						pe_ws_mux_15_0 =  		pe_ws_mux_row_15[(0+1)-1:0];
	assign						pe_ws_mux_0_1 =  		pe_ws_mux_row_0[(1+1)-1:1];
	assign						pe_ws_mux_1_1 =  		pe_ws_mux_row_1[(1+1)-1:1];
	assign						pe_ws_mux_2_1 =  		pe_ws_mux_row_2[(1+1)-1:1];
	assign						pe_ws_mux_3_1 =  		pe_ws_mux_row_3[(1+1)-1:1];
	assign						pe_ws_mux_4_1 =  		pe_ws_mux_row_4[(1+1)-1:1];
	assign						pe_ws_mux_5_1 =  		pe_ws_mux_row_5[(1+1)-1:1];
	assign						pe_ws_mux_6_1 =  		pe_ws_mux_row_6[(1+1)-1:1];
	assign						pe_ws_mux_7_1 =  		pe_ws_mux_row_7[(1+1)-1:1];
	assign						pe_ws_mux_8_1 =  		pe_ws_mux_row_8[(1+1)-1:1];
	assign						pe_ws_mux_9_1 =  		pe_ws_mux_row_9[(1+1)-1:1];
	assign						pe_ws_mux_10_1 =  		pe_ws_mux_row_10[(1+1)-1:1];
	assign						pe_ws_mux_11_1 =  		pe_ws_mux_row_11[(1+1)-1:1];
	assign						pe_ws_mux_12_1 =  		pe_ws_mux_row_12[(1+1)-1:1];
	assign						pe_ws_mux_13_1 =  		pe_ws_mux_row_13[(1+1)-1:1];
	assign						pe_ws_mux_14_1 =  		pe_ws_mux_row_14[(1+1)-1:1];
	assign						pe_ws_mux_15_1 =  		pe_ws_mux_row_15[(1+1)-1:1];
	assign						pe_ws_mux_0_2 =  		pe_ws_mux_row_0[(2+1)-1:2];
	assign						pe_ws_mux_1_2 =  		pe_ws_mux_row_1[(2+1)-1:2];
	assign						pe_ws_mux_2_2 =  		pe_ws_mux_row_2[(2+1)-1:2];
	assign						pe_ws_mux_3_2 =  		pe_ws_mux_row_3[(2+1)-1:2];
	assign						pe_ws_mux_4_2 =  		pe_ws_mux_row_4[(2+1)-1:2];
	assign						pe_ws_mux_5_2 =  		pe_ws_mux_row_5[(2+1)-1:2];
	assign						pe_ws_mux_6_2 =  		pe_ws_mux_row_6[(2+1)-1:2];
	assign						pe_ws_mux_7_2 =  		pe_ws_mux_row_7[(2+1)-1:2];
	assign						pe_ws_mux_8_2 =  		pe_ws_mux_row_8[(2+1)-1:2];
	assign						pe_ws_mux_9_2 =  		pe_ws_mux_row_9[(2+1)-1:2];
	assign						pe_ws_mux_10_2 =  		pe_ws_mux_row_10[(2+1)-1:2];
	assign						pe_ws_mux_11_2 =  		pe_ws_mux_row_11[(2+1)-1:2];
	assign						pe_ws_mux_12_2 =  		pe_ws_mux_row_12[(2+1)-1:2];
	assign						pe_ws_mux_13_2 =  		pe_ws_mux_row_13[(2+1)-1:2];
	assign						pe_ws_mux_14_2 =  		pe_ws_mux_row_14[(2+1)-1:2];
	assign						pe_ws_mux_15_2 =  		pe_ws_mux_row_15[(2+1)-1:2];
	assign						pe_ws_mux_0_3 =  		pe_ws_mux_row_0[(3+1)-1:3];
	assign						pe_ws_mux_1_3 =  		pe_ws_mux_row_1[(3+1)-1:3];
	assign						pe_ws_mux_2_3 =  		pe_ws_mux_row_2[(3+1)-1:3];
	assign						pe_ws_mux_3_3 =  		pe_ws_mux_row_3[(3+1)-1:3];
	assign						pe_ws_mux_4_3 =  		pe_ws_mux_row_4[(3+1)-1:3];
	assign						pe_ws_mux_5_3 =  		pe_ws_mux_row_5[(3+1)-1:3];
	assign						pe_ws_mux_6_3 =  		pe_ws_mux_row_6[(3+1)-1:3];
	assign						pe_ws_mux_7_3 =  		pe_ws_mux_row_7[(3+1)-1:3];
	assign						pe_ws_mux_8_3 =  		pe_ws_mux_row_8[(3+1)-1:3];
	assign						pe_ws_mux_9_3 =  		pe_ws_mux_row_9[(3+1)-1:3];
	assign						pe_ws_mux_10_3 =  		pe_ws_mux_row_10[(3+1)-1:3];
	assign						pe_ws_mux_11_3 =  		pe_ws_mux_row_11[(3+1)-1:3];
	assign						pe_ws_mux_12_3 =  		pe_ws_mux_row_12[(3+1)-1:3];
	assign						pe_ws_mux_13_3 =  		pe_ws_mux_row_13[(3+1)-1:3];
	assign						pe_ws_mux_14_3 =  		pe_ws_mux_row_14[(3+1)-1:3];
	assign						pe_ws_mux_15_3 =  		pe_ws_mux_row_15[(3+1)-1:3];
	assign						pe_ws_mux_0_4 =  		pe_ws_mux_row_0[(4+1)-1:4];
	assign						pe_ws_mux_1_4 =  		pe_ws_mux_row_1[(4+1)-1:4];
	assign						pe_ws_mux_2_4 =  		pe_ws_mux_row_2[(4+1)-1:4];
	assign						pe_ws_mux_3_4 =  		pe_ws_mux_row_3[(4+1)-1:4];
	assign						pe_ws_mux_4_4 =  		pe_ws_mux_row_4[(4+1)-1:4];
	assign						pe_ws_mux_5_4 =  		pe_ws_mux_row_5[(4+1)-1:4];
	assign						pe_ws_mux_6_4 =  		pe_ws_mux_row_6[(4+1)-1:4];
	assign						pe_ws_mux_7_4 =  		pe_ws_mux_row_7[(4+1)-1:4];
	assign						pe_ws_mux_8_4 =  		pe_ws_mux_row_8[(4+1)-1:4];
	assign						pe_ws_mux_9_4 =  		pe_ws_mux_row_9[(4+1)-1:4];
	assign						pe_ws_mux_10_4 =  		pe_ws_mux_row_10[(4+1)-1:4];
	assign						pe_ws_mux_11_4 =  		pe_ws_mux_row_11[(4+1)-1:4];
	assign						pe_ws_mux_12_4 =  		pe_ws_mux_row_12[(4+1)-1:4];
	assign						pe_ws_mux_13_4 =  		pe_ws_mux_row_13[(4+1)-1:4];
	assign						pe_ws_mux_14_4 =  		pe_ws_mux_row_14[(4+1)-1:4];
	assign						pe_ws_mux_15_4 =  		pe_ws_mux_row_15[(4+1)-1:4];
	assign						pe_ws_mux_0_5 =  		pe_ws_mux_row_0[(5+1)-1:5];
	assign						pe_ws_mux_1_5 =  		pe_ws_mux_row_1[(5+1)-1:5];
	assign						pe_ws_mux_2_5 =  		pe_ws_mux_row_2[(5+1)-1:5];
	assign						pe_ws_mux_3_5 =  		pe_ws_mux_row_3[(5+1)-1:5];
	assign						pe_ws_mux_4_5 =  		pe_ws_mux_row_4[(5+1)-1:5];
	assign						pe_ws_mux_5_5 =  		pe_ws_mux_row_5[(5+1)-1:5];
	assign						pe_ws_mux_6_5 =  		pe_ws_mux_row_6[(5+1)-1:5];
	assign						pe_ws_mux_7_5 =  		pe_ws_mux_row_7[(5+1)-1:5];
	assign						pe_ws_mux_8_5 =  		pe_ws_mux_row_8[(5+1)-1:5];
	assign						pe_ws_mux_9_5 =  		pe_ws_mux_row_9[(5+1)-1:5];
	assign						pe_ws_mux_10_5 =  		pe_ws_mux_row_10[(5+1)-1:5];
	assign						pe_ws_mux_11_5 =  		pe_ws_mux_row_11[(5+1)-1:5];
	assign						pe_ws_mux_12_5 =  		pe_ws_mux_row_12[(5+1)-1:5];
	assign						pe_ws_mux_13_5 =  		pe_ws_mux_row_13[(5+1)-1:5];
	assign						pe_ws_mux_14_5 =  		pe_ws_mux_row_14[(5+1)-1:5];
	assign						pe_ws_mux_15_5 =  		pe_ws_mux_row_15[(5+1)-1:5];
	assign						pe_ws_mux_0_6 =  		pe_ws_mux_row_0[(6+1)-1:6];
	assign						pe_ws_mux_1_6 =  		pe_ws_mux_row_1[(6+1)-1:6];
	assign						pe_ws_mux_2_6 =  		pe_ws_mux_row_2[(6+1)-1:6];
	assign						pe_ws_mux_3_6 =  		pe_ws_mux_row_3[(6+1)-1:6];
	assign						pe_ws_mux_4_6 =  		pe_ws_mux_row_4[(6+1)-1:6];
	assign						pe_ws_mux_5_6 =  		pe_ws_mux_row_5[(6+1)-1:6];
	assign						pe_ws_mux_6_6 =  		pe_ws_mux_row_6[(6+1)-1:6];
	assign						pe_ws_mux_7_6 =  		pe_ws_mux_row_7[(6+1)-1:6];
	assign						pe_ws_mux_8_6 =  		pe_ws_mux_row_8[(6+1)-1:6];
	assign						pe_ws_mux_9_6 =  		pe_ws_mux_row_9[(6+1)-1:6];
	assign						pe_ws_mux_10_6 =  		pe_ws_mux_row_10[(6+1)-1:6];
	assign						pe_ws_mux_11_6 =  		pe_ws_mux_row_11[(6+1)-1:6];
	assign						pe_ws_mux_12_6 =  		pe_ws_mux_row_12[(6+1)-1:6];
	assign						pe_ws_mux_13_6 =  		pe_ws_mux_row_13[(6+1)-1:6];
	assign						pe_ws_mux_14_6 =  		pe_ws_mux_row_14[(6+1)-1:6];
	assign						pe_ws_mux_15_6 =  		pe_ws_mux_row_15[(6+1)-1:6];
	assign						pe_ws_mux_0_7 =  		pe_ws_mux_row_0[(7+1)-1:7];
	assign						pe_ws_mux_1_7 =  		pe_ws_mux_row_1[(7+1)-1:7];
	assign						pe_ws_mux_2_7 =  		pe_ws_mux_row_2[(7+1)-1:7];
	assign						pe_ws_mux_3_7 =  		pe_ws_mux_row_3[(7+1)-1:7];
	assign						pe_ws_mux_4_7 =  		pe_ws_mux_row_4[(7+1)-1:7];
	assign						pe_ws_mux_5_7 =  		pe_ws_mux_row_5[(7+1)-1:7];
	assign						pe_ws_mux_6_7 =  		pe_ws_mux_row_6[(7+1)-1:7];
	assign						pe_ws_mux_7_7 =  		pe_ws_mux_row_7[(7+1)-1:7];
	assign						pe_ws_mux_8_7 =  		pe_ws_mux_row_8[(7+1)-1:7];
	assign						pe_ws_mux_9_7 =  		pe_ws_mux_row_9[(7+1)-1:7];
	assign						pe_ws_mux_10_7 =  		pe_ws_mux_row_10[(7+1)-1:7];
	assign						pe_ws_mux_11_7 =  		pe_ws_mux_row_11[(7+1)-1:7];
	assign						pe_ws_mux_12_7 =  		pe_ws_mux_row_12[(7+1)-1:7];
	assign						pe_ws_mux_13_7 =  		pe_ws_mux_row_13[(7+1)-1:7];
	assign						pe_ws_mux_14_7 =  		pe_ws_mux_row_14[(7+1)-1:7];
	assign						pe_ws_mux_15_7 =  		pe_ws_mux_row_15[(7+1)-1:7];
	assign						pe_ws_mux_0_8 =  		pe_ws_mux_row_0[(8+1)-1:8];
	assign						pe_ws_mux_1_8 =  		pe_ws_mux_row_1[(8+1)-1:8];
	assign						pe_ws_mux_2_8 =  		pe_ws_mux_row_2[(8+1)-1:8];
	assign						pe_ws_mux_3_8 =  		pe_ws_mux_row_3[(8+1)-1:8];
	assign						pe_ws_mux_4_8 =  		pe_ws_mux_row_4[(8+1)-1:8];
	assign						pe_ws_mux_5_8 =  		pe_ws_mux_row_5[(8+1)-1:8];
	assign						pe_ws_mux_6_8 =  		pe_ws_mux_row_6[(8+1)-1:8];
	assign						pe_ws_mux_7_8 =  		pe_ws_mux_row_7[(8+1)-1:8];
	assign						pe_ws_mux_8_8 =  		pe_ws_mux_row_8[(8+1)-1:8];
	assign						pe_ws_mux_9_8 =  		pe_ws_mux_row_9[(8+1)-1:8];
	assign						pe_ws_mux_10_8 =  		pe_ws_mux_row_10[(8+1)-1:8];
	assign						pe_ws_mux_11_8 =  		pe_ws_mux_row_11[(8+1)-1:8];
	assign						pe_ws_mux_12_8 =  		pe_ws_mux_row_12[(8+1)-1:8];
	assign						pe_ws_mux_13_8 =  		pe_ws_mux_row_13[(8+1)-1:8];
	assign						pe_ws_mux_14_8 =  		pe_ws_mux_row_14[(8+1)-1:8];
	assign						pe_ws_mux_15_8 =  		pe_ws_mux_row_15[(8+1)-1:8];
	assign						pe_ws_mux_0_9 =  		pe_ws_mux_row_0[(9+1)-1:9];
	assign						pe_ws_mux_1_9 =  		pe_ws_mux_row_1[(9+1)-1:9];
	assign						pe_ws_mux_2_9 =  		pe_ws_mux_row_2[(9+1)-1:9];
	assign						pe_ws_mux_3_9 =  		pe_ws_mux_row_3[(9+1)-1:9];
	assign						pe_ws_mux_4_9 =  		pe_ws_mux_row_4[(9+1)-1:9];
	assign						pe_ws_mux_5_9 =  		pe_ws_mux_row_5[(9+1)-1:9];
	assign						pe_ws_mux_6_9 =  		pe_ws_mux_row_6[(9+1)-1:9];
	assign						pe_ws_mux_7_9 =  		pe_ws_mux_row_7[(9+1)-1:9];
	assign						pe_ws_mux_8_9 =  		pe_ws_mux_row_8[(9+1)-1:9];
	assign						pe_ws_mux_9_9 =  		pe_ws_mux_row_9[(9+1)-1:9];
	assign						pe_ws_mux_10_9 =  		pe_ws_mux_row_10[(9+1)-1:9];
	assign						pe_ws_mux_11_9 =  		pe_ws_mux_row_11[(9+1)-1:9];
	assign						pe_ws_mux_12_9 =  		pe_ws_mux_row_12[(9+1)-1:9];
	assign						pe_ws_mux_13_9 =  		pe_ws_mux_row_13[(9+1)-1:9];
	assign						pe_ws_mux_14_9 =  		pe_ws_mux_row_14[(9+1)-1:9];
	assign						pe_ws_mux_15_9 =  		pe_ws_mux_row_15[(9+1)-1:9];
	assign						pe_ws_mux_0_10 =  		pe_ws_mux_row_0[(10+1)-1:10];
	assign						pe_ws_mux_1_10 =  		pe_ws_mux_row_1[(10+1)-1:10];
	assign						pe_ws_mux_2_10 =  		pe_ws_mux_row_2[(10+1)-1:10];
	assign						pe_ws_mux_3_10 =  		pe_ws_mux_row_3[(10+1)-1:10];
	assign						pe_ws_mux_4_10 =  		pe_ws_mux_row_4[(10+1)-1:10];
	assign						pe_ws_mux_5_10 =  		pe_ws_mux_row_5[(10+1)-1:10];
	assign						pe_ws_mux_6_10 =  		pe_ws_mux_row_6[(10+1)-1:10];
	assign						pe_ws_mux_7_10 =  		pe_ws_mux_row_7[(10+1)-1:10];
	assign						pe_ws_mux_8_10 =  		pe_ws_mux_row_8[(10+1)-1:10];
	assign						pe_ws_mux_9_10 =  		pe_ws_mux_row_9[(10+1)-1:10];
	assign						pe_ws_mux_10_10 =  		pe_ws_mux_row_10[(10+1)-1:10];
	assign						pe_ws_mux_11_10 =  		pe_ws_mux_row_11[(10+1)-1:10];
	assign						pe_ws_mux_12_10 =  		pe_ws_mux_row_12[(10+1)-1:10];
	assign						pe_ws_mux_13_10 =  		pe_ws_mux_row_13[(10+1)-1:10];
	assign						pe_ws_mux_14_10 =  		pe_ws_mux_row_14[(10+1)-1:10];
	assign						pe_ws_mux_15_10 =  		pe_ws_mux_row_15[(10+1)-1:10];
	assign						pe_ws_mux_0_11 =  		pe_ws_mux_row_0[(11+1)-1:11];
	assign						pe_ws_mux_1_11 =  		pe_ws_mux_row_1[(11+1)-1:11];
	assign						pe_ws_mux_2_11 =  		pe_ws_mux_row_2[(11+1)-1:11];
	assign						pe_ws_mux_3_11 =  		pe_ws_mux_row_3[(11+1)-1:11];
	assign						pe_ws_mux_4_11 =  		pe_ws_mux_row_4[(11+1)-1:11];
	assign						pe_ws_mux_5_11 =  		pe_ws_mux_row_5[(11+1)-1:11];
	assign						pe_ws_mux_6_11 =  		pe_ws_mux_row_6[(11+1)-1:11];
	assign						pe_ws_mux_7_11 =  		pe_ws_mux_row_7[(11+1)-1:11];
	assign						pe_ws_mux_8_11 =  		pe_ws_mux_row_8[(11+1)-1:11];
	assign						pe_ws_mux_9_11 =  		pe_ws_mux_row_9[(11+1)-1:11];
	assign						pe_ws_mux_10_11 =  		pe_ws_mux_row_10[(11+1)-1:11];
	assign						pe_ws_mux_11_11 =  		pe_ws_mux_row_11[(11+1)-1:11];
	assign						pe_ws_mux_12_11 =  		pe_ws_mux_row_12[(11+1)-1:11];
	assign						pe_ws_mux_13_11 =  		pe_ws_mux_row_13[(11+1)-1:11];
	assign						pe_ws_mux_14_11 =  		pe_ws_mux_row_14[(11+1)-1:11];
	assign						pe_ws_mux_15_11 =  		pe_ws_mux_row_15[(11+1)-1:11];
	assign						pe_ws_mux_0_12 =  		pe_ws_mux_row_0[(12+1)-1:12];
	assign						pe_ws_mux_1_12 =  		pe_ws_mux_row_1[(12+1)-1:12];
	assign						pe_ws_mux_2_12 =  		pe_ws_mux_row_2[(12+1)-1:12];
	assign						pe_ws_mux_3_12 =  		pe_ws_mux_row_3[(12+1)-1:12];
	assign						pe_ws_mux_4_12 =  		pe_ws_mux_row_4[(12+1)-1:12];
	assign						pe_ws_mux_5_12 =  		pe_ws_mux_row_5[(12+1)-1:12];
	assign						pe_ws_mux_6_12 =  		pe_ws_mux_row_6[(12+1)-1:12];
	assign						pe_ws_mux_7_12 =  		pe_ws_mux_row_7[(12+1)-1:12];
	assign						pe_ws_mux_8_12 =  		pe_ws_mux_row_8[(12+1)-1:12];
	assign						pe_ws_mux_9_12 =  		pe_ws_mux_row_9[(12+1)-1:12];
	assign						pe_ws_mux_10_12 =  		pe_ws_mux_row_10[(12+1)-1:12];
	assign						pe_ws_mux_11_12 =  		pe_ws_mux_row_11[(12+1)-1:12];
	assign						pe_ws_mux_12_12 =  		pe_ws_mux_row_12[(12+1)-1:12];
	assign						pe_ws_mux_13_12 =  		pe_ws_mux_row_13[(12+1)-1:12];
	assign						pe_ws_mux_14_12 =  		pe_ws_mux_row_14[(12+1)-1:12];
	assign						pe_ws_mux_15_12 =  		pe_ws_mux_row_15[(12+1)-1:12];
	assign						pe_ws_mux_0_13 =  		pe_ws_mux_row_0[(13+1)-1:13];
	assign						pe_ws_mux_1_13 =  		pe_ws_mux_row_1[(13+1)-1:13];
	assign						pe_ws_mux_2_13 =  		pe_ws_mux_row_2[(13+1)-1:13];
	assign						pe_ws_mux_3_13 =  		pe_ws_mux_row_3[(13+1)-1:13];
	assign						pe_ws_mux_4_13 =  		pe_ws_mux_row_4[(13+1)-1:13];
	assign						pe_ws_mux_5_13 =  		pe_ws_mux_row_5[(13+1)-1:13];
	assign						pe_ws_mux_6_13 =  		pe_ws_mux_row_6[(13+1)-1:13];
	assign						pe_ws_mux_7_13 =  		pe_ws_mux_row_7[(13+1)-1:13];
	assign						pe_ws_mux_8_13 =  		pe_ws_mux_row_8[(13+1)-1:13];
	assign						pe_ws_mux_9_13 =  		pe_ws_mux_row_9[(13+1)-1:13];
	assign						pe_ws_mux_10_13 =  		pe_ws_mux_row_10[(13+1)-1:13];
	assign						pe_ws_mux_11_13 =  		pe_ws_mux_row_11[(13+1)-1:13];
	assign						pe_ws_mux_12_13 =  		pe_ws_mux_row_12[(13+1)-1:13];
	assign						pe_ws_mux_13_13 =  		pe_ws_mux_row_13[(13+1)-1:13];
	assign						pe_ws_mux_14_13 =  		pe_ws_mux_row_14[(13+1)-1:13];
	assign						pe_ws_mux_15_13 =  		pe_ws_mux_row_15[(13+1)-1:13];
	assign						pe_ws_mux_0_14 =  		pe_ws_mux_row_0[(14+1)-1:14];
	assign						pe_ws_mux_1_14 =  		pe_ws_mux_row_1[(14+1)-1:14];
	assign						pe_ws_mux_2_14 =  		pe_ws_mux_row_2[(14+1)-1:14];
	assign						pe_ws_mux_3_14 =  		pe_ws_mux_row_3[(14+1)-1:14];
	assign						pe_ws_mux_4_14 =  		pe_ws_mux_row_4[(14+1)-1:14];
	assign						pe_ws_mux_5_14 =  		pe_ws_mux_row_5[(14+1)-1:14];
	assign						pe_ws_mux_6_14 =  		pe_ws_mux_row_6[(14+1)-1:14];
	assign						pe_ws_mux_7_14 =  		pe_ws_mux_row_7[(14+1)-1:14];
	assign						pe_ws_mux_8_14 =  		pe_ws_mux_row_8[(14+1)-1:14];
	assign						pe_ws_mux_9_14 =  		pe_ws_mux_row_9[(14+1)-1:14];
	assign						pe_ws_mux_10_14 =  		pe_ws_mux_row_10[(14+1)-1:14];
	assign						pe_ws_mux_11_14 =  		pe_ws_mux_row_11[(14+1)-1:14];
	assign						pe_ws_mux_12_14 =  		pe_ws_mux_row_12[(14+1)-1:14];
	assign						pe_ws_mux_13_14 =  		pe_ws_mux_row_13[(14+1)-1:14];
	assign						pe_ws_mux_14_14 =  		pe_ws_mux_row_14[(14+1)-1:14];
	assign						pe_ws_mux_15_14 =  		pe_ws_mux_row_15[(14+1)-1:14];
	assign						pe_ws_mux_0_15 =  		pe_ws_mux_row_0[(15+1)-1:15];
	assign						pe_ws_mux_1_15 =  		pe_ws_mux_row_1[(15+1)-1:15];
	assign						pe_ws_mux_2_15 =  		pe_ws_mux_row_2[(15+1)-1:15];
	assign						pe_ws_mux_3_15 =  		pe_ws_mux_row_3[(15+1)-1:15];
	assign						pe_ws_mux_4_15 =  		pe_ws_mux_row_4[(15+1)-1:15];
	assign						pe_ws_mux_5_15 =  		pe_ws_mux_row_5[(15+1)-1:15];
	assign						pe_ws_mux_6_15 =  		pe_ws_mux_row_6[(15+1)-1:15];
	assign						pe_ws_mux_7_15 =  		pe_ws_mux_row_7[(15+1)-1:15];
	assign						pe_ws_mux_8_15 =  		pe_ws_mux_row_8[(15+1)-1:15];
	assign						pe_ws_mux_9_15 =  		pe_ws_mux_row_9[(15+1)-1:15];
	assign						pe_ws_mux_10_15 =  		pe_ws_mux_row_10[(15+1)-1:15];
	assign						pe_ws_mux_11_15 =  		pe_ws_mux_row_11[(15+1)-1:15];
	assign						pe_ws_mux_12_15 =  		pe_ws_mux_row_12[(15+1)-1:15];
	assign						pe_ws_mux_13_15 =  		pe_ws_mux_row_13[(15+1)-1:15];
	assign						pe_ws_mux_14_15 =  		pe_ws_mux_row_14[(15+1)-1:15];
	assign						pe_ws_mux_15_15 =  		pe_ws_mux_row_15[(15+1)-1:15];
//
//
	wire																	pe_reset_ws_reg_0_0;
	wire																	pe_reset_ws_reg_1_0;
	wire																	pe_reset_ws_reg_2_0;
	wire																	pe_reset_ws_reg_3_0;
	wire																	pe_reset_ws_reg_4_0;
	wire																	pe_reset_ws_reg_5_0;
	wire																	pe_reset_ws_reg_6_0;
	wire																	pe_reset_ws_reg_7_0;
	wire																	pe_reset_ws_reg_8_0;
	wire																	pe_reset_ws_reg_9_0;
	wire																	pe_reset_ws_reg_10_0;
	wire																	pe_reset_ws_reg_11_0;
	wire																	pe_reset_ws_reg_12_0;
	wire																	pe_reset_ws_reg_13_0;
	wire																	pe_reset_ws_reg_14_0;
	wire																	pe_reset_ws_reg_15_0;
	wire																	pe_reset_ws_reg_0_1;
	wire																	pe_reset_ws_reg_1_1;
	wire																	pe_reset_ws_reg_2_1;
	wire																	pe_reset_ws_reg_3_1;
	wire																	pe_reset_ws_reg_4_1;
	wire																	pe_reset_ws_reg_5_1;
	wire																	pe_reset_ws_reg_6_1;
	wire																	pe_reset_ws_reg_7_1;
	wire																	pe_reset_ws_reg_8_1;
	wire																	pe_reset_ws_reg_9_1;
	wire																	pe_reset_ws_reg_10_1;
	wire																	pe_reset_ws_reg_11_1;
	wire																	pe_reset_ws_reg_12_1;
	wire																	pe_reset_ws_reg_13_1;
	wire																	pe_reset_ws_reg_14_1;
	wire																	pe_reset_ws_reg_15_1;
	wire																	pe_reset_ws_reg_0_2;
	wire																	pe_reset_ws_reg_1_2;
	wire																	pe_reset_ws_reg_2_2;
	wire																	pe_reset_ws_reg_3_2;
	wire																	pe_reset_ws_reg_4_2;
	wire																	pe_reset_ws_reg_5_2;
	wire																	pe_reset_ws_reg_6_2;
	wire																	pe_reset_ws_reg_7_2;
	wire																	pe_reset_ws_reg_8_2;
	wire																	pe_reset_ws_reg_9_2;
	wire																	pe_reset_ws_reg_10_2;
	wire																	pe_reset_ws_reg_11_2;
	wire																	pe_reset_ws_reg_12_2;
	wire																	pe_reset_ws_reg_13_2;
	wire																	pe_reset_ws_reg_14_2;
	wire																	pe_reset_ws_reg_15_2;
	wire																	pe_reset_ws_reg_0_3;
	wire																	pe_reset_ws_reg_1_3;
	wire																	pe_reset_ws_reg_2_3;
	wire																	pe_reset_ws_reg_3_3;
	wire																	pe_reset_ws_reg_4_3;
	wire																	pe_reset_ws_reg_5_3;
	wire																	pe_reset_ws_reg_6_3;
	wire																	pe_reset_ws_reg_7_3;
	wire																	pe_reset_ws_reg_8_3;
	wire																	pe_reset_ws_reg_9_3;
	wire																	pe_reset_ws_reg_10_3;
	wire																	pe_reset_ws_reg_11_3;
	wire																	pe_reset_ws_reg_12_3;
	wire																	pe_reset_ws_reg_13_3;
	wire																	pe_reset_ws_reg_14_3;
	wire																	pe_reset_ws_reg_15_3;
	wire																	pe_reset_ws_reg_0_4;
	wire																	pe_reset_ws_reg_1_4;
	wire																	pe_reset_ws_reg_2_4;
	wire																	pe_reset_ws_reg_3_4;
	wire																	pe_reset_ws_reg_4_4;
	wire																	pe_reset_ws_reg_5_4;
	wire																	pe_reset_ws_reg_6_4;
	wire																	pe_reset_ws_reg_7_4;
	wire																	pe_reset_ws_reg_8_4;
	wire																	pe_reset_ws_reg_9_4;
	wire																	pe_reset_ws_reg_10_4;
	wire																	pe_reset_ws_reg_11_4;
	wire																	pe_reset_ws_reg_12_4;
	wire																	pe_reset_ws_reg_13_4;
	wire																	pe_reset_ws_reg_14_4;
	wire																	pe_reset_ws_reg_15_4;
	wire																	pe_reset_ws_reg_0_5;
	wire																	pe_reset_ws_reg_1_5;
	wire																	pe_reset_ws_reg_2_5;
	wire																	pe_reset_ws_reg_3_5;
	wire																	pe_reset_ws_reg_4_5;
	wire																	pe_reset_ws_reg_5_5;
	wire																	pe_reset_ws_reg_6_5;
	wire																	pe_reset_ws_reg_7_5;
	wire																	pe_reset_ws_reg_8_5;
	wire																	pe_reset_ws_reg_9_5;
	wire																	pe_reset_ws_reg_10_5;
	wire																	pe_reset_ws_reg_11_5;
	wire																	pe_reset_ws_reg_12_5;
	wire																	pe_reset_ws_reg_13_5;
	wire																	pe_reset_ws_reg_14_5;
	wire																	pe_reset_ws_reg_15_5;
	wire																	pe_reset_ws_reg_0_6;
	wire																	pe_reset_ws_reg_1_6;
	wire																	pe_reset_ws_reg_2_6;
	wire																	pe_reset_ws_reg_3_6;
	wire																	pe_reset_ws_reg_4_6;
	wire																	pe_reset_ws_reg_5_6;
	wire																	pe_reset_ws_reg_6_6;
	wire																	pe_reset_ws_reg_7_6;
	wire																	pe_reset_ws_reg_8_6;
	wire																	pe_reset_ws_reg_9_6;
	wire																	pe_reset_ws_reg_10_6;
	wire																	pe_reset_ws_reg_11_6;
	wire																	pe_reset_ws_reg_12_6;
	wire																	pe_reset_ws_reg_13_6;
	wire																	pe_reset_ws_reg_14_6;
	wire																	pe_reset_ws_reg_15_6;
	wire																	pe_reset_ws_reg_0_7;
	wire																	pe_reset_ws_reg_1_7;
	wire																	pe_reset_ws_reg_2_7;
	wire																	pe_reset_ws_reg_3_7;
	wire																	pe_reset_ws_reg_4_7;
	wire																	pe_reset_ws_reg_5_7;
	wire																	pe_reset_ws_reg_6_7;
	wire																	pe_reset_ws_reg_7_7;
	wire																	pe_reset_ws_reg_8_7;
	wire																	pe_reset_ws_reg_9_7;
	wire																	pe_reset_ws_reg_10_7;
	wire																	pe_reset_ws_reg_11_7;
	wire																	pe_reset_ws_reg_12_7;
	wire																	pe_reset_ws_reg_13_7;
	wire																	pe_reset_ws_reg_14_7;
	wire																	pe_reset_ws_reg_15_7;
	wire																	pe_reset_ws_reg_0_8;
	wire																	pe_reset_ws_reg_1_8;
	wire																	pe_reset_ws_reg_2_8;
	wire																	pe_reset_ws_reg_3_8;
	wire																	pe_reset_ws_reg_4_8;
	wire																	pe_reset_ws_reg_5_8;
	wire																	pe_reset_ws_reg_6_8;
	wire																	pe_reset_ws_reg_7_8;
	wire																	pe_reset_ws_reg_8_8;
	wire																	pe_reset_ws_reg_9_8;
	wire																	pe_reset_ws_reg_10_8;
	wire																	pe_reset_ws_reg_11_8;
	wire																	pe_reset_ws_reg_12_8;
	wire																	pe_reset_ws_reg_13_8;
	wire																	pe_reset_ws_reg_14_8;
	wire																	pe_reset_ws_reg_15_8;
	wire																	pe_reset_ws_reg_0_9;
	wire																	pe_reset_ws_reg_1_9;
	wire																	pe_reset_ws_reg_2_9;
	wire																	pe_reset_ws_reg_3_9;
	wire																	pe_reset_ws_reg_4_9;
	wire																	pe_reset_ws_reg_5_9;
	wire																	pe_reset_ws_reg_6_9;
	wire																	pe_reset_ws_reg_7_9;
	wire																	pe_reset_ws_reg_8_9;
	wire																	pe_reset_ws_reg_9_9;
	wire																	pe_reset_ws_reg_10_9;
	wire																	pe_reset_ws_reg_11_9;
	wire																	pe_reset_ws_reg_12_9;
	wire																	pe_reset_ws_reg_13_9;
	wire																	pe_reset_ws_reg_14_9;
	wire																	pe_reset_ws_reg_15_9;
	wire																	pe_reset_ws_reg_0_10;
	wire																	pe_reset_ws_reg_1_10;
	wire																	pe_reset_ws_reg_2_10;
	wire																	pe_reset_ws_reg_3_10;
	wire																	pe_reset_ws_reg_4_10;
	wire																	pe_reset_ws_reg_5_10;
	wire																	pe_reset_ws_reg_6_10;
	wire																	pe_reset_ws_reg_7_10;
	wire																	pe_reset_ws_reg_8_10;
	wire																	pe_reset_ws_reg_9_10;
	wire																	pe_reset_ws_reg_10_10;
	wire																	pe_reset_ws_reg_11_10;
	wire																	pe_reset_ws_reg_12_10;
	wire																	pe_reset_ws_reg_13_10;
	wire																	pe_reset_ws_reg_14_10;
	wire																	pe_reset_ws_reg_15_10;
	wire																	pe_reset_ws_reg_0_11;
	wire																	pe_reset_ws_reg_1_11;
	wire																	pe_reset_ws_reg_2_11;
	wire																	pe_reset_ws_reg_3_11;
	wire																	pe_reset_ws_reg_4_11;
	wire																	pe_reset_ws_reg_5_11;
	wire																	pe_reset_ws_reg_6_11;
	wire																	pe_reset_ws_reg_7_11;
	wire																	pe_reset_ws_reg_8_11;
	wire																	pe_reset_ws_reg_9_11;
	wire																	pe_reset_ws_reg_10_11;
	wire																	pe_reset_ws_reg_11_11;
	wire																	pe_reset_ws_reg_12_11;
	wire																	pe_reset_ws_reg_13_11;
	wire																	pe_reset_ws_reg_14_11;
	wire																	pe_reset_ws_reg_15_11;
	wire																	pe_reset_ws_reg_0_12;
	wire																	pe_reset_ws_reg_1_12;
	wire																	pe_reset_ws_reg_2_12;
	wire																	pe_reset_ws_reg_3_12;
	wire																	pe_reset_ws_reg_4_12;
	wire																	pe_reset_ws_reg_5_12;
	wire																	pe_reset_ws_reg_6_12;
	wire																	pe_reset_ws_reg_7_12;
	wire																	pe_reset_ws_reg_8_12;
	wire																	pe_reset_ws_reg_9_12;
	wire																	pe_reset_ws_reg_10_12;
	wire																	pe_reset_ws_reg_11_12;
	wire																	pe_reset_ws_reg_12_12;
	wire																	pe_reset_ws_reg_13_12;
	wire																	pe_reset_ws_reg_14_12;
	wire																	pe_reset_ws_reg_15_12;
	wire																	pe_reset_ws_reg_0_13;
	wire																	pe_reset_ws_reg_1_13;
	wire																	pe_reset_ws_reg_2_13;
	wire																	pe_reset_ws_reg_3_13;
	wire																	pe_reset_ws_reg_4_13;
	wire																	pe_reset_ws_reg_5_13;
	wire																	pe_reset_ws_reg_6_13;
	wire																	pe_reset_ws_reg_7_13;
	wire																	pe_reset_ws_reg_8_13;
	wire																	pe_reset_ws_reg_9_13;
	wire																	pe_reset_ws_reg_10_13;
	wire																	pe_reset_ws_reg_11_13;
	wire																	pe_reset_ws_reg_12_13;
	wire																	pe_reset_ws_reg_13_13;
	wire																	pe_reset_ws_reg_14_13;
	wire																	pe_reset_ws_reg_15_13;
	wire																	pe_reset_ws_reg_0_14;
	wire																	pe_reset_ws_reg_1_14;
	wire																	pe_reset_ws_reg_2_14;
	wire																	pe_reset_ws_reg_3_14;
	wire																	pe_reset_ws_reg_4_14;
	wire																	pe_reset_ws_reg_5_14;
	wire																	pe_reset_ws_reg_6_14;
	wire																	pe_reset_ws_reg_7_14;
	wire																	pe_reset_ws_reg_8_14;
	wire																	pe_reset_ws_reg_9_14;
	wire																	pe_reset_ws_reg_10_14;
	wire																	pe_reset_ws_reg_11_14;
	wire																	pe_reset_ws_reg_12_14;
	wire																	pe_reset_ws_reg_13_14;
	wire																	pe_reset_ws_reg_14_14;
	wire																	pe_reset_ws_reg_15_14;
	wire																	pe_reset_ws_reg_0_15;
	wire																	pe_reset_ws_reg_1_15;
	wire																	pe_reset_ws_reg_2_15;
	wire																	pe_reset_ws_reg_3_15;
	wire																	pe_reset_ws_reg_4_15;
	wire																	pe_reset_ws_reg_5_15;
	wire																	pe_reset_ws_reg_6_15;
	wire																	pe_reset_ws_reg_7_15;
	wire																	pe_reset_ws_reg_8_15;
	wire																	pe_reset_ws_reg_9_15;
	wire																	pe_reset_ws_reg_10_15;
	wire																	pe_reset_ws_reg_11_15;
	wire																	pe_reset_ws_reg_12_15;
	wire																	pe_reset_ws_reg_13_15;
	wire																	pe_reset_ws_reg_14_15;
	wire																	pe_reset_ws_reg_15_15;
//
//
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_0;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_1;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_2;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_3;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_4;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_5;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_6;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_7;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_8;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_9;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_10;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_11;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_12;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_13;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_14;
	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_15;
//
//
	assign						pe_reset_ws_reg_row_0      	=   pe_reset_ws_reg[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_1      	=   pe_reset_ws_reg[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_2      	=   pe_reset_ws_reg[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_3      	=   pe_reset_ws_reg[(3+1)*ARRAY_DIM_X-1:3*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_4      	=   pe_reset_ws_reg[(4+1)*ARRAY_DIM_X-1:4*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_5      	=   pe_reset_ws_reg[(5+1)*ARRAY_DIM_X-1:5*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_6      	=   pe_reset_ws_reg[(6+1)*ARRAY_DIM_X-1:6*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_7      	=   pe_reset_ws_reg[(7+1)*ARRAY_DIM_X-1:7*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_8      	=   pe_reset_ws_reg[(8+1)*ARRAY_DIM_X-1:8*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_9      	=   pe_reset_ws_reg[(9+1)*ARRAY_DIM_X-1:9*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_10      	=   pe_reset_ws_reg[(10+1)*ARRAY_DIM_X-1:10*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_11      	=   pe_reset_ws_reg[(11+1)*ARRAY_DIM_X-1:11*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_12      	=   pe_reset_ws_reg[(12+1)*ARRAY_DIM_X-1:12*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_13      	=   pe_reset_ws_reg[(13+1)*ARRAY_DIM_X-1:13*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_14      	=   pe_reset_ws_reg[(14+1)*ARRAY_DIM_X-1:14*ARRAY_DIM_X];
	assign						pe_reset_ws_reg_row_15      	=   pe_reset_ws_reg[(15+1)*ARRAY_DIM_X-1:15*ARRAY_DIM_X];
//
//
	assign						pe_reset_ws_reg_0_0 =   pe_reset_ws_reg_row_0[(0+1)-1:0];
	assign						pe_reset_ws_reg_1_0 =   pe_reset_ws_reg_row_1[(0+1)-1:0];
	assign						pe_reset_ws_reg_2_0 =   pe_reset_ws_reg_row_2[(0+1)-1:0];
	assign						pe_reset_ws_reg_3_0 =   pe_reset_ws_reg_row_3[(0+1)-1:0];
	assign						pe_reset_ws_reg_4_0 =   pe_reset_ws_reg_row_4[(0+1)-1:0];
	assign						pe_reset_ws_reg_5_0 =   pe_reset_ws_reg_row_5[(0+1)-1:0];
	assign						pe_reset_ws_reg_6_0 =   pe_reset_ws_reg_row_6[(0+1)-1:0];
	assign						pe_reset_ws_reg_7_0 =   pe_reset_ws_reg_row_7[(0+1)-1:0];
	assign						pe_reset_ws_reg_8_0 =   pe_reset_ws_reg_row_8[(0+1)-1:0];
	assign						pe_reset_ws_reg_9_0 =   pe_reset_ws_reg_row_9[(0+1)-1:0];
	assign						pe_reset_ws_reg_10_0 =   pe_reset_ws_reg_row_10[(0+1)-1:0];
	assign						pe_reset_ws_reg_11_0 =   pe_reset_ws_reg_row_11[(0+1)-1:0];
	assign						pe_reset_ws_reg_12_0 =   pe_reset_ws_reg_row_12[(0+1)-1:0];
	assign						pe_reset_ws_reg_13_0 =   pe_reset_ws_reg_row_13[(0+1)-1:0];
	assign						pe_reset_ws_reg_14_0 =   pe_reset_ws_reg_row_14[(0+1)-1:0];
	assign						pe_reset_ws_reg_15_0 =   pe_reset_ws_reg_row_15[(0+1)-1:0];
	assign						pe_reset_ws_reg_0_1 =   pe_reset_ws_reg_row_0[(1+1)-1:1];
	assign						pe_reset_ws_reg_1_1 =   pe_reset_ws_reg_row_1[(1+1)-1:1];
	assign						pe_reset_ws_reg_2_1 =   pe_reset_ws_reg_row_2[(1+1)-1:1];
	assign						pe_reset_ws_reg_3_1 =   pe_reset_ws_reg_row_3[(1+1)-1:1];
	assign						pe_reset_ws_reg_4_1 =   pe_reset_ws_reg_row_4[(1+1)-1:1];
	assign						pe_reset_ws_reg_5_1 =   pe_reset_ws_reg_row_5[(1+1)-1:1];
	assign						pe_reset_ws_reg_6_1 =   pe_reset_ws_reg_row_6[(1+1)-1:1];
	assign						pe_reset_ws_reg_7_1 =   pe_reset_ws_reg_row_7[(1+1)-1:1];
	assign						pe_reset_ws_reg_8_1 =   pe_reset_ws_reg_row_8[(1+1)-1:1];
	assign						pe_reset_ws_reg_9_1 =   pe_reset_ws_reg_row_9[(1+1)-1:1];
	assign						pe_reset_ws_reg_10_1 =   pe_reset_ws_reg_row_10[(1+1)-1:1];
	assign						pe_reset_ws_reg_11_1 =   pe_reset_ws_reg_row_11[(1+1)-1:1];
	assign						pe_reset_ws_reg_12_1 =   pe_reset_ws_reg_row_12[(1+1)-1:1];
	assign						pe_reset_ws_reg_13_1 =   pe_reset_ws_reg_row_13[(1+1)-1:1];
	assign						pe_reset_ws_reg_14_1 =   pe_reset_ws_reg_row_14[(1+1)-1:1];
	assign						pe_reset_ws_reg_15_1 =   pe_reset_ws_reg_row_15[(1+1)-1:1];
	assign						pe_reset_ws_reg_0_2 =   pe_reset_ws_reg_row_0[(2+1)-1:2];
	assign						pe_reset_ws_reg_1_2 =   pe_reset_ws_reg_row_1[(2+1)-1:2];
	assign						pe_reset_ws_reg_2_2 =   pe_reset_ws_reg_row_2[(2+1)-1:2];
	assign						pe_reset_ws_reg_3_2 =   pe_reset_ws_reg_row_3[(2+1)-1:2];
	assign						pe_reset_ws_reg_4_2 =   pe_reset_ws_reg_row_4[(2+1)-1:2];
	assign						pe_reset_ws_reg_5_2 =   pe_reset_ws_reg_row_5[(2+1)-1:2];
	assign						pe_reset_ws_reg_6_2 =   pe_reset_ws_reg_row_6[(2+1)-1:2];
	assign						pe_reset_ws_reg_7_2 =   pe_reset_ws_reg_row_7[(2+1)-1:2];
	assign						pe_reset_ws_reg_8_2 =   pe_reset_ws_reg_row_8[(2+1)-1:2];
	assign						pe_reset_ws_reg_9_2 =   pe_reset_ws_reg_row_9[(2+1)-1:2];
	assign						pe_reset_ws_reg_10_2 =   pe_reset_ws_reg_row_10[(2+1)-1:2];
	assign						pe_reset_ws_reg_11_2 =   pe_reset_ws_reg_row_11[(2+1)-1:2];
	assign						pe_reset_ws_reg_12_2 =   pe_reset_ws_reg_row_12[(2+1)-1:2];
	assign						pe_reset_ws_reg_13_2 =   pe_reset_ws_reg_row_13[(2+1)-1:2];
	assign						pe_reset_ws_reg_14_2 =   pe_reset_ws_reg_row_14[(2+1)-1:2];
	assign						pe_reset_ws_reg_15_2 =   pe_reset_ws_reg_row_15[(2+1)-1:2];
	assign						pe_reset_ws_reg_0_3 =   pe_reset_ws_reg_row_0[(3+1)-1:3];
	assign						pe_reset_ws_reg_1_3 =   pe_reset_ws_reg_row_1[(3+1)-1:3];
	assign						pe_reset_ws_reg_2_3 =   pe_reset_ws_reg_row_2[(3+1)-1:3];
	assign						pe_reset_ws_reg_3_3 =   pe_reset_ws_reg_row_3[(3+1)-1:3];
	assign						pe_reset_ws_reg_4_3 =   pe_reset_ws_reg_row_4[(3+1)-1:3];
	assign						pe_reset_ws_reg_5_3 =   pe_reset_ws_reg_row_5[(3+1)-1:3];
	assign						pe_reset_ws_reg_6_3 =   pe_reset_ws_reg_row_6[(3+1)-1:3];
	assign						pe_reset_ws_reg_7_3 =   pe_reset_ws_reg_row_7[(3+1)-1:3];
	assign						pe_reset_ws_reg_8_3 =   pe_reset_ws_reg_row_8[(3+1)-1:3];
	assign						pe_reset_ws_reg_9_3 =   pe_reset_ws_reg_row_9[(3+1)-1:3];
	assign						pe_reset_ws_reg_10_3 =   pe_reset_ws_reg_row_10[(3+1)-1:3];
	assign						pe_reset_ws_reg_11_3 =   pe_reset_ws_reg_row_11[(3+1)-1:3];
	assign						pe_reset_ws_reg_12_3 =   pe_reset_ws_reg_row_12[(3+1)-1:3];
	assign						pe_reset_ws_reg_13_3 =   pe_reset_ws_reg_row_13[(3+1)-1:3];
	assign						pe_reset_ws_reg_14_3 =   pe_reset_ws_reg_row_14[(3+1)-1:3];
	assign						pe_reset_ws_reg_15_3 =   pe_reset_ws_reg_row_15[(3+1)-1:3];
	assign						pe_reset_ws_reg_0_4 =   pe_reset_ws_reg_row_0[(4+1)-1:4];
	assign						pe_reset_ws_reg_1_4 =   pe_reset_ws_reg_row_1[(4+1)-1:4];
	assign						pe_reset_ws_reg_2_4 =   pe_reset_ws_reg_row_2[(4+1)-1:4];
	assign						pe_reset_ws_reg_3_4 =   pe_reset_ws_reg_row_3[(4+1)-1:4];
	assign						pe_reset_ws_reg_4_4 =   pe_reset_ws_reg_row_4[(4+1)-1:4];
	assign						pe_reset_ws_reg_5_4 =   pe_reset_ws_reg_row_5[(4+1)-1:4];
	assign						pe_reset_ws_reg_6_4 =   pe_reset_ws_reg_row_6[(4+1)-1:4];
	assign						pe_reset_ws_reg_7_4 =   pe_reset_ws_reg_row_7[(4+1)-1:4];
	assign						pe_reset_ws_reg_8_4 =   pe_reset_ws_reg_row_8[(4+1)-1:4];
	assign						pe_reset_ws_reg_9_4 =   pe_reset_ws_reg_row_9[(4+1)-1:4];
	assign						pe_reset_ws_reg_10_4 =   pe_reset_ws_reg_row_10[(4+1)-1:4];
	assign						pe_reset_ws_reg_11_4 =   pe_reset_ws_reg_row_11[(4+1)-1:4];
	assign						pe_reset_ws_reg_12_4 =   pe_reset_ws_reg_row_12[(4+1)-1:4];
	assign						pe_reset_ws_reg_13_4 =   pe_reset_ws_reg_row_13[(4+1)-1:4];
	assign						pe_reset_ws_reg_14_4 =   pe_reset_ws_reg_row_14[(4+1)-1:4];
	assign						pe_reset_ws_reg_15_4 =   pe_reset_ws_reg_row_15[(4+1)-1:4];
	assign						pe_reset_ws_reg_0_5 =   pe_reset_ws_reg_row_0[(5+1)-1:5];
	assign						pe_reset_ws_reg_1_5 =   pe_reset_ws_reg_row_1[(5+1)-1:5];
	assign						pe_reset_ws_reg_2_5 =   pe_reset_ws_reg_row_2[(5+1)-1:5];
	assign						pe_reset_ws_reg_3_5 =   pe_reset_ws_reg_row_3[(5+1)-1:5];
	assign						pe_reset_ws_reg_4_5 =   pe_reset_ws_reg_row_4[(5+1)-1:5];
	assign						pe_reset_ws_reg_5_5 =   pe_reset_ws_reg_row_5[(5+1)-1:5];
	assign						pe_reset_ws_reg_6_5 =   pe_reset_ws_reg_row_6[(5+1)-1:5];
	assign						pe_reset_ws_reg_7_5 =   pe_reset_ws_reg_row_7[(5+1)-1:5];
	assign						pe_reset_ws_reg_8_5 =   pe_reset_ws_reg_row_8[(5+1)-1:5];
	assign						pe_reset_ws_reg_9_5 =   pe_reset_ws_reg_row_9[(5+1)-1:5];
	assign						pe_reset_ws_reg_10_5 =   pe_reset_ws_reg_row_10[(5+1)-1:5];
	assign						pe_reset_ws_reg_11_5 =   pe_reset_ws_reg_row_11[(5+1)-1:5];
	assign						pe_reset_ws_reg_12_5 =   pe_reset_ws_reg_row_12[(5+1)-1:5];
	assign						pe_reset_ws_reg_13_5 =   pe_reset_ws_reg_row_13[(5+1)-1:5];
	assign						pe_reset_ws_reg_14_5 =   pe_reset_ws_reg_row_14[(5+1)-1:5];
	assign						pe_reset_ws_reg_15_5 =   pe_reset_ws_reg_row_15[(5+1)-1:5];
	assign						pe_reset_ws_reg_0_6 =   pe_reset_ws_reg_row_0[(6+1)-1:6];
	assign						pe_reset_ws_reg_1_6 =   pe_reset_ws_reg_row_1[(6+1)-1:6];
	assign						pe_reset_ws_reg_2_6 =   pe_reset_ws_reg_row_2[(6+1)-1:6];
	assign						pe_reset_ws_reg_3_6 =   pe_reset_ws_reg_row_3[(6+1)-1:6];
	assign						pe_reset_ws_reg_4_6 =   pe_reset_ws_reg_row_4[(6+1)-1:6];
	assign						pe_reset_ws_reg_5_6 =   pe_reset_ws_reg_row_5[(6+1)-1:6];
	assign						pe_reset_ws_reg_6_6 =   pe_reset_ws_reg_row_6[(6+1)-1:6];
	assign						pe_reset_ws_reg_7_6 =   pe_reset_ws_reg_row_7[(6+1)-1:6];
	assign						pe_reset_ws_reg_8_6 =   pe_reset_ws_reg_row_8[(6+1)-1:6];
	assign						pe_reset_ws_reg_9_6 =   pe_reset_ws_reg_row_9[(6+1)-1:6];
	assign						pe_reset_ws_reg_10_6 =   pe_reset_ws_reg_row_10[(6+1)-1:6];
	assign						pe_reset_ws_reg_11_6 =   pe_reset_ws_reg_row_11[(6+1)-1:6];
	assign						pe_reset_ws_reg_12_6 =   pe_reset_ws_reg_row_12[(6+1)-1:6];
	assign						pe_reset_ws_reg_13_6 =   pe_reset_ws_reg_row_13[(6+1)-1:6];
	assign						pe_reset_ws_reg_14_6 =   pe_reset_ws_reg_row_14[(6+1)-1:6];
	assign						pe_reset_ws_reg_15_6 =   pe_reset_ws_reg_row_15[(6+1)-1:6];
	assign						pe_reset_ws_reg_0_7 =   pe_reset_ws_reg_row_0[(7+1)-1:7];
	assign						pe_reset_ws_reg_1_7 =   pe_reset_ws_reg_row_1[(7+1)-1:7];
	assign						pe_reset_ws_reg_2_7 =   pe_reset_ws_reg_row_2[(7+1)-1:7];
	assign						pe_reset_ws_reg_3_7 =   pe_reset_ws_reg_row_3[(7+1)-1:7];
	assign						pe_reset_ws_reg_4_7 =   pe_reset_ws_reg_row_4[(7+1)-1:7];
	assign						pe_reset_ws_reg_5_7 =   pe_reset_ws_reg_row_5[(7+1)-1:7];
	assign						pe_reset_ws_reg_6_7 =   pe_reset_ws_reg_row_6[(7+1)-1:7];
	assign						pe_reset_ws_reg_7_7 =   pe_reset_ws_reg_row_7[(7+1)-1:7];
	assign						pe_reset_ws_reg_8_7 =   pe_reset_ws_reg_row_8[(7+1)-1:7];
	assign						pe_reset_ws_reg_9_7 =   pe_reset_ws_reg_row_9[(7+1)-1:7];
	assign						pe_reset_ws_reg_10_7 =   pe_reset_ws_reg_row_10[(7+1)-1:7];
	assign						pe_reset_ws_reg_11_7 =   pe_reset_ws_reg_row_11[(7+1)-1:7];
	assign						pe_reset_ws_reg_12_7 =   pe_reset_ws_reg_row_12[(7+1)-1:7];
	assign						pe_reset_ws_reg_13_7 =   pe_reset_ws_reg_row_13[(7+1)-1:7];
	assign						pe_reset_ws_reg_14_7 =   pe_reset_ws_reg_row_14[(7+1)-1:7];
	assign						pe_reset_ws_reg_15_7 =   pe_reset_ws_reg_row_15[(7+1)-1:7];
	assign						pe_reset_ws_reg_0_8 =   pe_reset_ws_reg_row_0[(8+1)-1:8];
	assign						pe_reset_ws_reg_1_8 =   pe_reset_ws_reg_row_1[(8+1)-1:8];
	assign						pe_reset_ws_reg_2_8 =   pe_reset_ws_reg_row_2[(8+1)-1:8];
	assign						pe_reset_ws_reg_3_8 =   pe_reset_ws_reg_row_3[(8+1)-1:8];
	assign						pe_reset_ws_reg_4_8 =   pe_reset_ws_reg_row_4[(8+1)-1:8];
	assign						pe_reset_ws_reg_5_8 =   pe_reset_ws_reg_row_5[(8+1)-1:8];
	assign						pe_reset_ws_reg_6_8 =   pe_reset_ws_reg_row_6[(8+1)-1:8];
	assign						pe_reset_ws_reg_7_8 =   pe_reset_ws_reg_row_7[(8+1)-1:8];
	assign						pe_reset_ws_reg_8_8 =   pe_reset_ws_reg_row_8[(8+1)-1:8];
	assign						pe_reset_ws_reg_9_8 =   pe_reset_ws_reg_row_9[(8+1)-1:8];
	assign						pe_reset_ws_reg_10_8 =   pe_reset_ws_reg_row_10[(8+1)-1:8];
	assign						pe_reset_ws_reg_11_8 =   pe_reset_ws_reg_row_11[(8+1)-1:8];
	assign						pe_reset_ws_reg_12_8 =   pe_reset_ws_reg_row_12[(8+1)-1:8];
	assign						pe_reset_ws_reg_13_8 =   pe_reset_ws_reg_row_13[(8+1)-1:8];
	assign						pe_reset_ws_reg_14_8 =   pe_reset_ws_reg_row_14[(8+1)-1:8];
	assign						pe_reset_ws_reg_15_8 =   pe_reset_ws_reg_row_15[(8+1)-1:8];
	assign						pe_reset_ws_reg_0_9 =   pe_reset_ws_reg_row_0[(9+1)-1:9];
	assign						pe_reset_ws_reg_1_9 =   pe_reset_ws_reg_row_1[(9+1)-1:9];
	assign						pe_reset_ws_reg_2_9 =   pe_reset_ws_reg_row_2[(9+1)-1:9];
	assign						pe_reset_ws_reg_3_9 =   pe_reset_ws_reg_row_3[(9+1)-1:9];
	assign						pe_reset_ws_reg_4_9 =   pe_reset_ws_reg_row_4[(9+1)-1:9];
	assign						pe_reset_ws_reg_5_9 =   pe_reset_ws_reg_row_5[(9+1)-1:9];
	assign						pe_reset_ws_reg_6_9 =   pe_reset_ws_reg_row_6[(9+1)-1:9];
	assign						pe_reset_ws_reg_7_9 =   pe_reset_ws_reg_row_7[(9+1)-1:9];
	assign						pe_reset_ws_reg_8_9 =   pe_reset_ws_reg_row_8[(9+1)-1:9];
	assign						pe_reset_ws_reg_9_9 =   pe_reset_ws_reg_row_9[(9+1)-1:9];
	assign						pe_reset_ws_reg_10_9 =   pe_reset_ws_reg_row_10[(9+1)-1:9];
	assign						pe_reset_ws_reg_11_9 =   pe_reset_ws_reg_row_11[(9+1)-1:9];
	assign						pe_reset_ws_reg_12_9 =   pe_reset_ws_reg_row_12[(9+1)-1:9];
	assign						pe_reset_ws_reg_13_9 =   pe_reset_ws_reg_row_13[(9+1)-1:9];
	assign						pe_reset_ws_reg_14_9 =   pe_reset_ws_reg_row_14[(9+1)-1:9];
	assign						pe_reset_ws_reg_15_9 =   pe_reset_ws_reg_row_15[(9+1)-1:9];
	assign						pe_reset_ws_reg_0_10 =   pe_reset_ws_reg_row_0[(10+1)-1:10];
	assign						pe_reset_ws_reg_1_10 =   pe_reset_ws_reg_row_1[(10+1)-1:10];
	assign						pe_reset_ws_reg_2_10 =   pe_reset_ws_reg_row_2[(10+1)-1:10];
	assign						pe_reset_ws_reg_3_10 =   pe_reset_ws_reg_row_3[(10+1)-1:10];
	assign						pe_reset_ws_reg_4_10 =   pe_reset_ws_reg_row_4[(10+1)-1:10];
	assign						pe_reset_ws_reg_5_10 =   pe_reset_ws_reg_row_5[(10+1)-1:10];
	assign						pe_reset_ws_reg_6_10 =   pe_reset_ws_reg_row_6[(10+1)-1:10];
	assign						pe_reset_ws_reg_7_10 =   pe_reset_ws_reg_row_7[(10+1)-1:10];
	assign						pe_reset_ws_reg_8_10 =   pe_reset_ws_reg_row_8[(10+1)-1:10];
	assign						pe_reset_ws_reg_9_10 =   pe_reset_ws_reg_row_9[(10+1)-1:10];
	assign						pe_reset_ws_reg_10_10 =   pe_reset_ws_reg_row_10[(10+1)-1:10];
	assign						pe_reset_ws_reg_11_10 =   pe_reset_ws_reg_row_11[(10+1)-1:10];
	assign						pe_reset_ws_reg_12_10 =   pe_reset_ws_reg_row_12[(10+1)-1:10];
	assign						pe_reset_ws_reg_13_10 =   pe_reset_ws_reg_row_13[(10+1)-1:10];
	assign						pe_reset_ws_reg_14_10 =   pe_reset_ws_reg_row_14[(10+1)-1:10];
	assign						pe_reset_ws_reg_15_10 =   pe_reset_ws_reg_row_15[(10+1)-1:10];
	assign						pe_reset_ws_reg_0_11 =   pe_reset_ws_reg_row_0[(11+1)-1:11];
	assign						pe_reset_ws_reg_1_11 =   pe_reset_ws_reg_row_1[(11+1)-1:11];
	assign						pe_reset_ws_reg_2_11 =   pe_reset_ws_reg_row_2[(11+1)-1:11];
	assign						pe_reset_ws_reg_3_11 =   pe_reset_ws_reg_row_3[(11+1)-1:11];
	assign						pe_reset_ws_reg_4_11 =   pe_reset_ws_reg_row_4[(11+1)-1:11];
	assign						pe_reset_ws_reg_5_11 =   pe_reset_ws_reg_row_5[(11+1)-1:11];
	assign						pe_reset_ws_reg_6_11 =   pe_reset_ws_reg_row_6[(11+1)-1:11];
	assign						pe_reset_ws_reg_7_11 =   pe_reset_ws_reg_row_7[(11+1)-1:11];
	assign						pe_reset_ws_reg_8_11 =   pe_reset_ws_reg_row_8[(11+1)-1:11];
	assign						pe_reset_ws_reg_9_11 =   pe_reset_ws_reg_row_9[(11+1)-1:11];
	assign						pe_reset_ws_reg_10_11 =   pe_reset_ws_reg_row_10[(11+1)-1:11];
	assign						pe_reset_ws_reg_11_11 =   pe_reset_ws_reg_row_11[(11+1)-1:11];
	assign						pe_reset_ws_reg_12_11 =   pe_reset_ws_reg_row_12[(11+1)-1:11];
	assign						pe_reset_ws_reg_13_11 =   pe_reset_ws_reg_row_13[(11+1)-1:11];
	assign						pe_reset_ws_reg_14_11 =   pe_reset_ws_reg_row_14[(11+1)-1:11];
	assign						pe_reset_ws_reg_15_11 =   pe_reset_ws_reg_row_15[(11+1)-1:11];
	assign						pe_reset_ws_reg_0_12 =   pe_reset_ws_reg_row_0[(12+1)-1:12];
	assign						pe_reset_ws_reg_1_12 =   pe_reset_ws_reg_row_1[(12+1)-1:12];
	assign						pe_reset_ws_reg_2_12 =   pe_reset_ws_reg_row_2[(12+1)-1:12];
	assign						pe_reset_ws_reg_3_12 =   pe_reset_ws_reg_row_3[(12+1)-1:12];
	assign						pe_reset_ws_reg_4_12 =   pe_reset_ws_reg_row_4[(12+1)-1:12];
	assign						pe_reset_ws_reg_5_12 =   pe_reset_ws_reg_row_5[(12+1)-1:12];
	assign						pe_reset_ws_reg_6_12 =   pe_reset_ws_reg_row_6[(12+1)-1:12];
	assign						pe_reset_ws_reg_7_12 =   pe_reset_ws_reg_row_7[(12+1)-1:12];
	assign						pe_reset_ws_reg_8_12 =   pe_reset_ws_reg_row_8[(12+1)-1:12];
	assign						pe_reset_ws_reg_9_12 =   pe_reset_ws_reg_row_9[(12+1)-1:12];
	assign						pe_reset_ws_reg_10_12 =   pe_reset_ws_reg_row_10[(12+1)-1:12];
	assign						pe_reset_ws_reg_11_12 =   pe_reset_ws_reg_row_11[(12+1)-1:12];
	assign						pe_reset_ws_reg_12_12 =   pe_reset_ws_reg_row_12[(12+1)-1:12];
	assign						pe_reset_ws_reg_13_12 =   pe_reset_ws_reg_row_13[(12+1)-1:12];
	assign						pe_reset_ws_reg_14_12 =   pe_reset_ws_reg_row_14[(12+1)-1:12];
	assign						pe_reset_ws_reg_15_12 =   pe_reset_ws_reg_row_15[(12+1)-1:12];
	assign						pe_reset_ws_reg_0_13 =   pe_reset_ws_reg_row_0[(13+1)-1:13];
	assign						pe_reset_ws_reg_1_13 =   pe_reset_ws_reg_row_1[(13+1)-1:13];
	assign						pe_reset_ws_reg_2_13 =   pe_reset_ws_reg_row_2[(13+1)-1:13];
	assign						pe_reset_ws_reg_3_13 =   pe_reset_ws_reg_row_3[(13+1)-1:13];
	assign						pe_reset_ws_reg_4_13 =   pe_reset_ws_reg_row_4[(13+1)-1:13];
	assign						pe_reset_ws_reg_5_13 =   pe_reset_ws_reg_row_5[(13+1)-1:13];
	assign						pe_reset_ws_reg_6_13 =   pe_reset_ws_reg_row_6[(13+1)-1:13];
	assign						pe_reset_ws_reg_7_13 =   pe_reset_ws_reg_row_7[(13+1)-1:13];
	assign						pe_reset_ws_reg_8_13 =   pe_reset_ws_reg_row_8[(13+1)-1:13];
	assign						pe_reset_ws_reg_9_13 =   pe_reset_ws_reg_row_9[(13+1)-1:13];
	assign						pe_reset_ws_reg_10_13 =   pe_reset_ws_reg_row_10[(13+1)-1:13];
	assign						pe_reset_ws_reg_11_13 =   pe_reset_ws_reg_row_11[(13+1)-1:13];
	assign						pe_reset_ws_reg_12_13 =   pe_reset_ws_reg_row_12[(13+1)-1:13];
	assign						pe_reset_ws_reg_13_13 =   pe_reset_ws_reg_row_13[(13+1)-1:13];
	assign						pe_reset_ws_reg_14_13 =   pe_reset_ws_reg_row_14[(13+1)-1:13];
	assign						pe_reset_ws_reg_15_13 =   pe_reset_ws_reg_row_15[(13+1)-1:13];
	assign						pe_reset_ws_reg_0_14 =   pe_reset_ws_reg_row_0[(14+1)-1:14];
	assign						pe_reset_ws_reg_1_14 =   pe_reset_ws_reg_row_1[(14+1)-1:14];
	assign						pe_reset_ws_reg_2_14 =   pe_reset_ws_reg_row_2[(14+1)-1:14];
	assign						pe_reset_ws_reg_3_14 =   pe_reset_ws_reg_row_3[(14+1)-1:14];
	assign						pe_reset_ws_reg_4_14 =   pe_reset_ws_reg_row_4[(14+1)-1:14];
	assign						pe_reset_ws_reg_5_14 =   pe_reset_ws_reg_row_5[(14+1)-1:14];
	assign						pe_reset_ws_reg_6_14 =   pe_reset_ws_reg_row_6[(14+1)-1:14];
	assign						pe_reset_ws_reg_7_14 =   pe_reset_ws_reg_row_7[(14+1)-1:14];
	assign						pe_reset_ws_reg_8_14 =   pe_reset_ws_reg_row_8[(14+1)-1:14];
	assign						pe_reset_ws_reg_9_14 =   pe_reset_ws_reg_row_9[(14+1)-1:14];
	assign						pe_reset_ws_reg_10_14 =   pe_reset_ws_reg_row_10[(14+1)-1:14];
	assign						pe_reset_ws_reg_11_14 =   pe_reset_ws_reg_row_11[(14+1)-1:14];
	assign						pe_reset_ws_reg_12_14 =   pe_reset_ws_reg_row_12[(14+1)-1:14];
	assign						pe_reset_ws_reg_13_14 =   pe_reset_ws_reg_row_13[(14+1)-1:14];
	assign						pe_reset_ws_reg_14_14 =   pe_reset_ws_reg_row_14[(14+1)-1:14];
	assign						pe_reset_ws_reg_15_14 =   pe_reset_ws_reg_row_15[(14+1)-1:14];
	assign						pe_reset_ws_reg_0_15 =   pe_reset_ws_reg_row_0[(15+1)-1:15];
	assign						pe_reset_ws_reg_1_15 =   pe_reset_ws_reg_row_1[(15+1)-1:15];
	assign						pe_reset_ws_reg_2_15 =   pe_reset_ws_reg_row_2[(15+1)-1:15];
	assign						pe_reset_ws_reg_3_15 =   pe_reset_ws_reg_row_3[(15+1)-1:15];
	assign						pe_reset_ws_reg_4_15 =   pe_reset_ws_reg_row_4[(15+1)-1:15];
	assign						pe_reset_ws_reg_5_15 =   pe_reset_ws_reg_row_5[(15+1)-1:15];
	assign						pe_reset_ws_reg_6_15 =   pe_reset_ws_reg_row_6[(15+1)-1:15];
	assign						pe_reset_ws_reg_7_15 =   pe_reset_ws_reg_row_7[(15+1)-1:15];
	assign						pe_reset_ws_reg_8_15 =   pe_reset_ws_reg_row_8[(15+1)-1:15];
	assign						pe_reset_ws_reg_9_15 =   pe_reset_ws_reg_row_9[(15+1)-1:15];
	assign						pe_reset_ws_reg_10_15 =   pe_reset_ws_reg_row_10[(15+1)-1:15];
	assign						pe_reset_ws_reg_11_15 =   pe_reset_ws_reg_row_11[(15+1)-1:15];
	assign						pe_reset_ws_reg_12_15 =   pe_reset_ws_reg_row_12[(15+1)-1:15];
	assign						pe_reset_ws_reg_13_15 =   pe_reset_ws_reg_row_13[(15+1)-1:15];
	assign						pe_reset_ws_reg_14_15 =   pe_reset_ws_reg_row_14[(15+1)-1:15];
	assign						pe_reset_ws_reg_15_15 =   pe_reset_ws_reg_row_15[(15+1)-1:15];
//
//
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_0;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_1;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_2;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_3;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_4;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_5;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_6;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_7;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_8;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_9;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_10;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_11;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_12;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_13;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_14;
	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_15;
//
//
	assign						_act_in_row_0 				=   act_in_0;
	assign						_act_in_row_1 				=   act_in_1;
	assign						_act_in_row_2 				=   act_in_2;
	assign						_act_in_row_3 				=   act_in_3;
	assign						_act_in_row_4 				=   act_in_4;
	assign						_act_in_row_5 				=   act_in_5;
	assign						_act_in_row_6 				=   act_in_6;
	assign						_act_in_row_7 				=   act_in_7;
	assign						_act_in_row_8 				=   act_in_8;
	assign						_act_in_row_9 				=   act_in_9;
	assign						_act_in_row_10 				=   act_in_10;
	assign						_act_in_row_11 				=   act_in_11;
	assign						_act_in_row_12 				=   act_in_12;
	assign						_act_in_row_13 				=   act_in_13;
	assign						_act_in_row_14 				=   act_in_14;
	assign						_act_in_row_15 				=   act_in_15;
//
//
	wire 																	as_en_row_0;
	wire 																	as_en_row_1;
	wire 																	as_en_row_2;
	wire 																	as_en_row_3;
	wire 																	as_en_row_4;
	wire 																	as_en_row_5;
	wire 																	as_en_row_6;
	wire 																	as_en_row_7;
	wire 																	as_en_row_8;
	wire 																	as_en_row_9;
	wire 																	as_en_row_10;
	wire 																	as_en_row_11;
	wire 																	as_en_row_12;
	wire 																	as_en_row_13;
	wire 																	as_en_row_14;
	wire 																	as_en_row_15;
//
//
	assign						as_en_row_0					=	as_en[(0+1)-1:0];
	assign						as_en_row_1					=	as_en[(1+1)-1:1];
	assign						as_en_row_2					=	as_en[(2+1)-1:2];
	assign						as_en_row_3					=	as_en[(3+1)-1:3];
	assign						as_en_row_4					=	as_en[(4+1)-1:4];
	assign						as_en_row_5					=	as_en[(5+1)-1:5];
	assign						as_en_row_6					=	as_en[(6+1)-1:6];
	assign						as_en_row_7					=	as_en[(7+1)-1:7];
	assign						as_en_row_8					=	as_en[(8+1)-1:8];
	assign						as_en_row_9					=	as_en[(9+1)-1:9];
	assign						as_en_row_10					=	as_en[(10+1)-1:10];
	assign						as_en_row_11					=	as_en[(11+1)-1:11];
	assign						as_en_row_12					=	as_en[(12+1)-1:12];
	assign						as_en_row_13					=	as_en[(13+1)-1:13];
	assign						as_en_row_14					=	as_en[(14+1)-1:14];
	assign						as_en_row_15					=	as_en[(15+1)-1:15];
//
//
	wire																	as_mux_row_0;
	wire																	as_mux_row_1;
	wire																	as_mux_row_2;
	wire																	as_mux_row_3;
	wire																	as_mux_row_4;
	wire																	as_mux_row_5;
	wire																	as_mux_row_6;
	wire																	as_mux_row_7;
	wire																	as_mux_row_8;
	wire																	as_mux_row_9;
	wire																	as_mux_row_10;
	wire																	as_mux_row_11;
	wire																	as_mux_row_12;
	wire																	as_mux_row_13;
	wire																	as_mux_row_14;
	wire																	as_mux_row_15;
//
//
	assign						as_mux_row_0					=	as_mux[(0+1)-1:0];
	assign						as_mux_row_1					=	as_mux[(1+1)-1:1];
	assign						as_mux_row_2					=	as_mux[(2+1)-1:2];
	assign						as_mux_row_3					=	as_mux[(3+1)-1:3];
	assign						as_mux_row_4					=	as_mux[(4+1)-1:4];
	assign						as_mux_row_5					=	as_mux[(5+1)-1:5];
	assign						as_mux_row_6					=	as_mux[(6+1)-1:6];
	assign						as_mux_row_7					=	as_mux[(7+1)-1:7];
	assign						as_mux_row_8					=	as_mux[(8+1)-1:8];
	assign						as_mux_row_9					=	as_mux[(9+1)-1:9];
	assign						as_mux_row_10					=	as_mux[(10+1)-1:10];
	assign						as_mux_row_11					=	as_mux[(11+1)-1:11];
	assign						as_mux_row_12					=	as_mux[(12+1)-1:12];
	assign						as_mux_row_13					=	as_mux[(13+1)-1:13];
	assign						as_mux_row_14					=	as_mux[(14+1)-1:14];
	assign						as_mux_row_15					=	as_mux[(15+1)-1:15];
//
//
	wire																	reset_as_reg_row_0;
	wire																	reset_as_reg_row_1;
	wire																	reset_as_reg_row_2;
	wire																	reset_as_reg_row_3;
	wire																	reset_as_reg_row_4;
	wire																	reset_as_reg_row_5;
	wire																	reset_as_reg_row_6;
	wire																	reset_as_reg_row_7;
	wire																	reset_as_reg_row_8;
	wire																	reset_as_reg_row_9;
	wire																	reset_as_reg_row_10;
	wire																	reset_as_reg_row_11;
	wire																	reset_as_reg_row_12;
	wire																	reset_as_reg_row_13;
	wire																	reset_as_reg_row_14;
	wire																	reset_as_reg_row_15;
//
//
	assign						reset_as_reg_row_0			=	reset_as_reg[(0+1)-1:0];
	assign						reset_as_reg_row_1			=	reset_as_reg[(1+1)-1:1];
	assign						reset_as_reg_row_2			=	reset_as_reg[(2+1)-1:2];
	assign						reset_as_reg_row_3			=	reset_as_reg[(3+1)-1:3];
	assign						reset_as_reg_row_4			=	reset_as_reg[(4+1)-1:4];
	assign						reset_as_reg_row_5			=	reset_as_reg[(5+1)-1:5];
	assign						reset_as_reg_row_6			=	reset_as_reg[(6+1)-1:6];
	assign						reset_as_reg_row_7			=	reset_as_reg[(7+1)-1:7];
	assign						reset_as_reg_row_8			=	reset_as_reg[(8+1)-1:8];
	assign						reset_as_reg_row_9			=	reset_as_reg[(9+1)-1:9];
	assign						reset_as_reg_row_10			=	reset_as_reg[(10+1)-1:10];
	assign						reset_as_reg_row_11			=	reset_as_reg[(11+1)-1:11];
	assign						reset_as_reg_row_12			=	reset_as_reg[(12+1)-1:12];
	assign						reset_as_reg_row_13			=	reset_as_reg[(13+1)-1:13];
	assign						reset_as_reg_row_14			=	reset_as_reg[(14+1)-1:14];
	assign						reset_as_reg_row_15			=	reset_as_reg[(15+1)-1:15];
//
//------------- input stationary logic
//
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_0;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_1;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_2;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_3;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_4;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_5;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_6;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_7;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_8;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_9;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_10;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_11;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_12;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_13;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_14;
	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_15;
//
//
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_0;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_1;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_2;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_3;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_4;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_5;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_6;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_7;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_8;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_9;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_10;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_11;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_12;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_13;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_14;
	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_15;
//
//
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_0 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_0),
		.wrt_en 														(as_en_row_0),
		.data_in 														(_act_in_row_0),
		.data_out 														(_act_in_row_reg_0)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_1 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_1),
		.wrt_en 														(as_en_row_1),
		.data_in 														(_act_in_row_1),
		.data_out 														(_act_in_row_reg_1)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_2 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_2),
		.wrt_en 														(as_en_row_2),
		.data_in 														(_act_in_row_2),
		.data_out 														(_act_in_row_reg_2)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_3 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_3),
		.wrt_en 														(as_en_row_3),
		.data_in 														(_act_in_row_3),
		.data_out 														(_act_in_row_reg_3)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_4 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_4),
		.wrt_en 														(as_en_row_4),
		.data_in 														(_act_in_row_4),
		.data_out 														(_act_in_row_reg_4)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_5 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_5),
		.wrt_en 														(as_en_row_5),
		.data_in 														(_act_in_row_5),
		.data_out 														(_act_in_row_reg_5)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_6 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_6),
		.wrt_en 														(as_en_row_6),
		.data_in 														(_act_in_row_6),
		.data_out 														(_act_in_row_reg_6)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_7 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_7),
		.wrt_en 														(as_en_row_7),
		.data_in 														(_act_in_row_7),
		.data_out 														(_act_in_row_reg_7)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_8 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_8),
		.wrt_en 														(as_en_row_8),
		.data_in 														(_act_in_row_8),
		.data_out 														(_act_in_row_reg_8)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_9 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_9),
		.wrt_en 														(as_en_row_9),
		.data_in 														(_act_in_row_9),
		.data_out 														(_act_in_row_reg_9)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_10 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_10),
		.wrt_en 														(as_en_row_10),
		.data_in 														(_act_in_row_10),
		.data_out 														(_act_in_row_reg_10)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_11 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_11),
		.wrt_en 														(as_en_row_11),
		.data_in 														(_act_in_row_11),
		.data_out 														(_act_in_row_reg_11)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_12 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_12),
		.wrt_en 														(as_en_row_12),
		.data_in 														(_act_in_row_12),
		.data_out 														(_act_in_row_reg_12)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_13 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_13),
		.wrt_en 														(as_en_row_13),
		.data_in 														(_act_in_row_13),
		.data_out 														(_act_in_row_reg_13)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_14 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_14),
		.wrt_en 														(as_en_row_14),
		.data_in 														(_act_in_row_14),
		.data_out 														(_act_in_row_reg_14)
	);
	register #(
		.BIT_WIDTH 														(ACT_BITWIDTH)
	) register_as_row_15 (
		.clk 															(clk),
		.reset 															(reset_as_reg_row_15),
		.wrt_en 														(as_en_row_15),
		.data_in 														(_act_in_row_15),
		.data_out 														(_act_in_row_reg_15)
	);
//
//
	always @ (*) begin
		if (as_en_row_0 == 0) begin
			act_in_row_0 	=	_act_in_row_0;
		end
		if (as_en_row_0 == 1 && as_mux_row_0 == 1) begin
			act_in_row_0 	=	_act_in_row_0;
		end
		if (as_en_row_0 == 1 && as_mux_row_0 == 0) begin
			act_in_row_0    =   _act_in_row_reg_0;
		end
	end
	always @ (*) begin
		if (as_en_row_1 == 0) begin
			act_in_row_1 	=	_act_in_row_1;
		end
		if (as_en_row_1 == 1 && as_mux_row_1 == 1) begin
			act_in_row_1 	=	_act_in_row_1;
		end
		if (as_en_row_1 == 1 && as_mux_row_1 == 0) begin
			act_in_row_1    =   _act_in_row_reg_1;
		end
	end
	always @ (*) begin
		if (as_en_row_2 == 0) begin
			act_in_row_2 	=	_act_in_row_2;
		end
		if (as_en_row_2 == 1 && as_mux_row_2 == 1) begin
			act_in_row_2 	=	_act_in_row_2;
		end
		if (as_en_row_2 == 1 && as_mux_row_2 == 0) begin
			act_in_row_2    =   _act_in_row_reg_2;
		end
	end
	always @ (*) begin
		if (as_en_row_3 == 0) begin
			act_in_row_3 	=	_act_in_row_3;
		end
		if (as_en_row_3 == 1 && as_mux_row_3 == 1) begin
			act_in_row_3 	=	_act_in_row_3;
		end
		if (as_en_row_3 == 1 && as_mux_row_3 == 0) begin
			act_in_row_3    =   _act_in_row_reg_3;
		end
	end
	always @ (*) begin
		if (as_en_row_4 == 0) begin
			act_in_row_4 	=	_act_in_row_4;
		end
		if (as_en_row_4 == 1 && as_mux_row_4 == 1) begin
			act_in_row_4 	=	_act_in_row_4;
		end
		if (as_en_row_4 == 1 && as_mux_row_4 == 0) begin
			act_in_row_4    =   _act_in_row_reg_4;
		end
	end
	always @ (*) begin
		if (as_en_row_5 == 0) begin
			act_in_row_5 	=	_act_in_row_5;
		end
		if (as_en_row_5 == 1 && as_mux_row_5 == 1) begin
			act_in_row_5 	=	_act_in_row_5;
		end
		if (as_en_row_5 == 1 && as_mux_row_5 == 0) begin
			act_in_row_5    =   _act_in_row_reg_5;
		end
	end
	always @ (*) begin
		if (as_en_row_6 == 0) begin
			act_in_row_6 	=	_act_in_row_6;
		end
		if (as_en_row_6 == 1 && as_mux_row_6 == 1) begin
			act_in_row_6 	=	_act_in_row_6;
		end
		if (as_en_row_6 == 1 && as_mux_row_6 == 0) begin
			act_in_row_6    =   _act_in_row_reg_6;
		end
	end
	always @ (*) begin
		if (as_en_row_7 == 0) begin
			act_in_row_7 	=	_act_in_row_7;
		end
		if (as_en_row_7 == 1 && as_mux_row_7 == 1) begin
			act_in_row_7 	=	_act_in_row_7;
		end
		if (as_en_row_7 == 1 && as_mux_row_7 == 0) begin
			act_in_row_7    =   _act_in_row_reg_7;
		end
	end
	always @ (*) begin
		if (as_en_row_8 == 0) begin
			act_in_row_8 	=	_act_in_row_8;
		end
		if (as_en_row_8 == 1 && as_mux_row_8 == 1) begin
			act_in_row_8 	=	_act_in_row_8;
		end
		if (as_en_row_8 == 1 && as_mux_row_8 == 0) begin
			act_in_row_8    =   _act_in_row_reg_8;
		end
	end
	always @ (*) begin
		if (as_en_row_9 == 0) begin
			act_in_row_9 	=	_act_in_row_9;
		end
		if (as_en_row_9 == 1 && as_mux_row_9 == 1) begin
			act_in_row_9 	=	_act_in_row_9;
		end
		if (as_en_row_9 == 1 && as_mux_row_9 == 0) begin
			act_in_row_9    =   _act_in_row_reg_9;
		end
	end
	always @ (*) begin
		if (as_en_row_10 == 0) begin
			act_in_row_10 	=	_act_in_row_10;
		end
		if (as_en_row_10 == 1 && as_mux_row_10 == 1) begin
			act_in_row_10 	=	_act_in_row_10;
		end
		if (as_en_row_10 == 1 && as_mux_row_10 == 0) begin
			act_in_row_10    =   _act_in_row_reg_10;
		end
	end
	always @ (*) begin
		if (as_en_row_11 == 0) begin
			act_in_row_11 	=	_act_in_row_11;
		end
		if (as_en_row_11 == 1 && as_mux_row_11 == 1) begin
			act_in_row_11 	=	_act_in_row_11;
		end
		if (as_en_row_11 == 1 && as_mux_row_11 == 0) begin
			act_in_row_11    =   _act_in_row_reg_11;
		end
	end
	always @ (*) begin
		if (as_en_row_12 == 0) begin
			act_in_row_12 	=	_act_in_row_12;
		end
		if (as_en_row_12 == 1 && as_mux_row_12 == 1) begin
			act_in_row_12 	=	_act_in_row_12;
		end
		if (as_en_row_12 == 1 && as_mux_row_12 == 0) begin
			act_in_row_12    =   _act_in_row_reg_12;
		end
	end
	always @ (*) begin
		if (as_en_row_13 == 0) begin
			act_in_row_13 	=	_act_in_row_13;
		end
		if (as_en_row_13 == 1 && as_mux_row_13 == 1) begin
			act_in_row_13 	=	_act_in_row_13;
		end
		if (as_en_row_13 == 1 && as_mux_row_13 == 0) begin
			act_in_row_13    =   _act_in_row_reg_13;
		end
	end
	always @ (*) begin
		if (as_en_row_14 == 0) begin
			act_in_row_14 	=	_act_in_row_14;
		end
		if (as_en_row_14 == 1 && as_mux_row_14 == 1) begin
			act_in_row_14 	=	_act_in_row_14;
		end
		if (as_en_row_14 == 1 && as_mux_row_14 == 0) begin
			act_in_row_14    =   _act_in_row_reg_14;
		end
	end
	always @ (*) begin
		if (as_en_row_15 == 0) begin
			act_in_row_15 	=	_act_in_row_15;
		end
		if (as_en_row_15 == 1 && as_mux_row_15 == 1) begin
			act_in_row_15 	=	_act_in_row_15;
		end
		if (as_en_row_15 == 1 && as_mux_row_15 == 0) begin
			act_in_row_15    =   _act_in_row_reg_15;
		end
	end
//
//
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_0;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_1;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_2;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_3;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_4;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_5;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_6;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_7;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_8;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_9;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_10;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_11;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_12;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_13;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_14;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_3_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_4_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_5_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_6_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_7_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_8_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_9_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_10_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_11_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_12_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_13_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_14_15;
	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_15_15;
//
//
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_3_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_4_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_5_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_6_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_7_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_8_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_9_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_10_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_11_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_12_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_13_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_14_15;
	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_15_15;
//
//
	assign						part_sum_in_0_0				=  	0;
	assign						part_sum_in_0_1				=  	0;
	assign						part_sum_in_0_2				=  	0;
	assign						part_sum_in_0_3				=  	0;
	assign						part_sum_in_0_4				=  	0;
	assign						part_sum_in_0_5				=  	0;
	assign						part_sum_in_0_6				=  	0;
	assign						part_sum_in_0_7				=  	0;
	assign						part_sum_in_0_8				=  	0;
	assign						part_sum_in_0_9				=  	0;
	assign						part_sum_in_0_10				=  	0;
	assign						part_sum_in_0_11				=  	0;
	assign						part_sum_in_0_12				=  	0;
	assign						part_sum_in_0_13				=  	0;
	assign						part_sum_in_0_14				=  	0;
	assign						part_sum_in_0_15				=  	0;
//
/*<(pe_temp.v, PeBuilder.py, pe_params.json, pe.v)>*/
//
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_0),
		.write_req_w_mem													(pe_wmem_write_req_0_0),
		.ws_en																(pe_ws_en_0_0),
		.ws_mux																(pe_ws_mux_0_0),
		.reset_ws_reg 														(pe_reset_ws_reg_0_0),
		.r_addr_w_mem														(pe_wmem_r_addr_0_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_0),
		.w_data_w_mem 														(pe_wmem_w_data_0_0),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_0),
		.sum_out															(part_sum_out_0_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_0),
		.write_req_w_mem													(pe_wmem_write_req_1_0),
		.ws_en																(pe_ws_en_1_0),
		.ws_mux																(pe_ws_mux_1_0),
		.reset_ws_reg 														(pe_reset_ws_reg_1_0),
		.r_addr_w_mem														(pe_wmem_r_addr_1_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_0),
		.w_data_w_mem 														(pe_wmem_w_data_1_0),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_0),
		.sum_out															(part_sum_out_1_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_0),
		.write_req_w_mem													(pe_wmem_write_req_2_0),
		.ws_en																(pe_ws_en_2_0),
		.ws_mux																(pe_ws_mux_2_0),
		.reset_ws_reg 														(pe_reset_ws_reg_2_0),
		.r_addr_w_mem														(pe_wmem_r_addr_2_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_0),
		.w_data_w_mem 														(pe_wmem_w_data_2_0),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_0),
		.sum_out															(part_sum_out_2_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_0),
		.write_req_w_mem													(pe_wmem_write_req_3_0),
		.ws_en																(pe_ws_en_3_0),
		.ws_mux																(pe_ws_mux_3_0),
		.reset_ws_reg 														(pe_reset_ws_reg_3_0),
		.r_addr_w_mem														(pe_wmem_r_addr_3_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_0),
		.w_data_w_mem 														(pe_wmem_w_data_3_0),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_0),
		.sum_out															(part_sum_out_3_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_0),
		.write_req_w_mem													(pe_wmem_write_req_4_0),
		.ws_en																(pe_ws_en_4_0),
		.ws_mux																(pe_ws_mux_4_0),
		.reset_ws_reg 														(pe_reset_ws_reg_4_0),
		.r_addr_w_mem														(pe_wmem_r_addr_4_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_0),
		.w_data_w_mem 														(pe_wmem_w_data_4_0),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_0),
		.sum_out															(part_sum_out_4_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_0),
		.write_req_w_mem													(pe_wmem_write_req_5_0),
		.ws_en																(pe_ws_en_5_0),
		.ws_mux																(pe_ws_mux_5_0),
		.reset_ws_reg 														(pe_reset_ws_reg_5_0),
		.r_addr_w_mem														(pe_wmem_r_addr_5_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_0),
		.w_data_w_mem 														(pe_wmem_w_data_5_0),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_0),
		.sum_out															(part_sum_out_5_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_0),
		.write_req_w_mem													(pe_wmem_write_req_6_0),
		.ws_en																(pe_ws_en_6_0),
		.ws_mux																(pe_ws_mux_6_0),
		.reset_ws_reg 														(pe_reset_ws_reg_6_0),
		.r_addr_w_mem														(pe_wmem_r_addr_6_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_0),
		.w_data_w_mem 														(pe_wmem_w_data_6_0),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_0),
		.sum_out															(part_sum_out_6_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_0),
		.write_req_w_mem													(pe_wmem_write_req_7_0),
		.ws_en																(pe_ws_en_7_0),
		.ws_mux																(pe_ws_mux_7_0),
		.reset_ws_reg 														(pe_reset_ws_reg_7_0),
		.r_addr_w_mem														(pe_wmem_r_addr_7_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_0),
		.w_data_w_mem 														(pe_wmem_w_data_7_0),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_0),
		.sum_out															(part_sum_out_7_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_0),
		.write_req_w_mem													(pe_wmem_write_req_8_0),
		.ws_en																(pe_ws_en_8_0),
		.ws_mux																(pe_ws_mux_8_0),
		.reset_ws_reg 														(pe_reset_ws_reg_8_0),
		.r_addr_w_mem														(pe_wmem_r_addr_8_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_0),
		.w_data_w_mem 														(pe_wmem_w_data_8_0),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_0),
		.sum_out															(part_sum_out_8_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_0),
		.write_req_w_mem													(pe_wmem_write_req_9_0),
		.ws_en																(pe_ws_en_9_0),
		.ws_mux																(pe_ws_mux_9_0),
		.reset_ws_reg 														(pe_reset_ws_reg_9_0),
		.r_addr_w_mem														(pe_wmem_r_addr_9_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_0),
		.w_data_w_mem 														(pe_wmem_w_data_9_0),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_0),
		.sum_out															(part_sum_out_9_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_0),
		.write_req_w_mem													(pe_wmem_write_req_10_0),
		.ws_en																(pe_ws_en_10_0),
		.ws_mux																(pe_ws_mux_10_0),
		.reset_ws_reg 														(pe_reset_ws_reg_10_0),
		.r_addr_w_mem														(pe_wmem_r_addr_10_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_0),
		.w_data_w_mem 														(pe_wmem_w_data_10_0),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_0),
		.sum_out															(part_sum_out_10_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_0),
		.write_req_w_mem													(pe_wmem_write_req_11_0),
		.ws_en																(pe_ws_en_11_0),
		.ws_mux																(pe_ws_mux_11_0),
		.reset_ws_reg 														(pe_reset_ws_reg_11_0),
		.r_addr_w_mem														(pe_wmem_r_addr_11_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_0),
		.w_data_w_mem 														(pe_wmem_w_data_11_0),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_0),
		.sum_out															(part_sum_out_11_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_0),
		.write_req_w_mem													(pe_wmem_write_req_12_0),
		.ws_en																(pe_ws_en_12_0),
		.ws_mux																(pe_ws_mux_12_0),
		.reset_ws_reg 														(pe_reset_ws_reg_12_0),
		.r_addr_w_mem														(pe_wmem_r_addr_12_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_0),
		.w_data_w_mem 														(pe_wmem_w_data_12_0),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_0),
		.sum_out															(part_sum_out_12_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_0),
		.write_req_w_mem													(pe_wmem_write_req_13_0),
		.ws_en																(pe_ws_en_13_0),
		.ws_mux																(pe_ws_mux_13_0),
		.reset_ws_reg 														(pe_reset_ws_reg_13_0),
		.r_addr_w_mem														(pe_wmem_r_addr_13_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_0),
		.w_data_w_mem 														(pe_wmem_w_data_13_0),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_0),
		.sum_out															(part_sum_out_13_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_0),
		.write_req_w_mem													(pe_wmem_write_req_14_0),
		.ws_en																(pe_ws_en_14_0),
		.ws_mux																(pe_ws_mux_14_0),
		.reset_ws_reg 														(pe_reset_ws_reg_14_0),
		.r_addr_w_mem														(pe_wmem_r_addr_14_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_0),
		.w_data_w_mem 														(pe_wmem_w_data_14_0),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_0),
		.sum_out															(part_sum_out_14_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_0 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_0),
		.write_req_w_mem													(pe_wmem_write_req_15_0),
		.ws_en																(pe_ws_en_15_0),
		.ws_mux																(pe_ws_mux_15_0),
		.reset_ws_reg 														(pe_reset_ws_reg_15_0),
		.r_addr_w_mem														(pe_wmem_r_addr_15_0),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_0),
		.w_data_w_mem 														(pe_wmem_w_data_15_0),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_0),
		.sum_out															(part_sum_out_15_0)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_1),
		.write_req_w_mem													(pe_wmem_write_req_0_1),
		.ws_en																(pe_ws_en_0_1),
		.ws_mux																(pe_ws_mux_0_1),
		.reset_ws_reg 														(pe_reset_ws_reg_0_1),
		.r_addr_w_mem														(pe_wmem_r_addr_0_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_1),
		.w_data_w_mem 														(pe_wmem_w_data_0_1),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_1),
		.sum_out															(part_sum_out_0_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_1),
		.write_req_w_mem													(pe_wmem_write_req_1_1),
		.ws_en																(pe_ws_en_1_1),
		.ws_mux																(pe_ws_mux_1_1),
		.reset_ws_reg 														(pe_reset_ws_reg_1_1),
		.r_addr_w_mem														(pe_wmem_r_addr_1_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_1),
		.w_data_w_mem 														(pe_wmem_w_data_1_1),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_1),
		.sum_out															(part_sum_out_1_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_1),
		.write_req_w_mem													(pe_wmem_write_req_2_1),
		.ws_en																(pe_ws_en_2_1),
		.ws_mux																(pe_ws_mux_2_1),
		.reset_ws_reg 														(pe_reset_ws_reg_2_1),
		.r_addr_w_mem														(pe_wmem_r_addr_2_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_1),
		.w_data_w_mem 														(pe_wmem_w_data_2_1),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_1),
		.sum_out															(part_sum_out_2_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_1),
		.write_req_w_mem													(pe_wmem_write_req_3_1),
		.ws_en																(pe_ws_en_3_1),
		.ws_mux																(pe_ws_mux_3_1),
		.reset_ws_reg 														(pe_reset_ws_reg_3_1),
		.r_addr_w_mem														(pe_wmem_r_addr_3_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_1),
		.w_data_w_mem 														(pe_wmem_w_data_3_1),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_1),
		.sum_out															(part_sum_out_3_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_1),
		.write_req_w_mem													(pe_wmem_write_req_4_1),
		.ws_en																(pe_ws_en_4_1),
		.ws_mux																(pe_ws_mux_4_1),
		.reset_ws_reg 														(pe_reset_ws_reg_4_1),
		.r_addr_w_mem														(pe_wmem_r_addr_4_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_1),
		.w_data_w_mem 														(pe_wmem_w_data_4_1),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_1),
		.sum_out															(part_sum_out_4_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_1),
		.write_req_w_mem													(pe_wmem_write_req_5_1),
		.ws_en																(pe_ws_en_5_1),
		.ws_mux																(pe_ws_mux_5_1),
		.reset_ws_reg 														(pe_reset_ws_reg_5_1),
		.r_addr_w_mem														(pe_wmem_r_addr_5_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_1),
		.w_data_w_mem 														(pe_wmem_w_data_5_1),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_1),
		.sum_out															(part_sum_out_5_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_1),
		.write_req_w_mem													(pe_wmem_write_req_6_1),
		.ws_en																(pe_ws_en_6_1),
		.ws_mux																(pe_ws_mux_6_1),
		.reset_ws_reg 														(pe_reset_ws_reg_6_1),
		.r_addr_w_mem														(pe_wmem_r_addr_6_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_1),
		.w_data_w_mem 														(pe_wmem_w_data_6_1),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_1),
		.sum_out															(part_sum_out_6_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_1),
		.write_req_w_mem													(pe_wmem_write_req_7_1),
		.ws_en																(pe_ws_en_7_1),
		.ws_mux																(pe_ws_mux_7_1),
		.reset_ws_reg 														(pe_reset_ws_reg_7_1),
		.r_addr_w_mem														(pe_wmem_r_addr_7_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_1),
		.w_data_w_mem 														(pe_wmem_w_data_7_1),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_1),
		.sum_out															(part_sum_out_7_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_1),
		.write_req_w_mem													(pe_wmem_write_req_8_1),
		.ws_en																(pe_ws_en_8_1),
		.ws_mux																(pe_ws_mux_8_1),
		.reset_ws_reg 														(pe_reset_ws_reg_8_1),
		.r_addr_w_mem														(pe_wmem_r_addr_8_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_1),
		.w_data_w_mem 														(pe_wmem_w_data_8_1),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_1),
		.sum_out															(part_sum_out_8_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_1),
		.write_req_w_mem													(pe_wmem_write_req_9_1),
		.ws_en																(pe_ws_en_9_1),
		.ws_mux																(pe_ws_mux_9_1),
		.reset_ws_reg 														(pe_reset_ws_reg_9_1),
		.r_addr_w_mem														(pe_wmem_r_addr_9_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_1),
		.w_data_w_mem 														(pe_wmem_w_data_9_1),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_1),
		.sum_out															(part_sum_out_9_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_1),
		.write_req_w_mem													(pe_wmem_write_req_10_1),
		.ws_en																(pe_ws_en_10_1),
		.ws_mux																(pe_ws_mux_10_1),
		.reset_ws_reg 														(pe_reset_ws_reg_10_1),
		.r_addr_w_mem														(pe_wmem_r_addr_10_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_1),
		.w_data_w_mem 														(pe_wmem_w_data_10_1),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_1),
		.sum_out															(part_sum_out_10_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_1),
		.write_req_w_mem													(pe_wmem_write_req_11_1),
		.ws_en																(pe_ws_en_11_1),
		.ws_mux																(pe_ws_mux_11_1),
		.reset_ws_reg 														(pe_reset_ws_reg_11_1),
		.r_addr_w_mem														(pe_wmem_r_addr_11_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_1),
		.w_data_w_mem 														(pe_wmem_w_data_11_1),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_1),
		.sum_out															(part_sum_out_11_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_1),
		.write_req_w_mem													(pe_wmem_write_req_12_1),
		.ws_en																(pe_ws_en_12_1),
		.ws_mux																(pe_ws_mux_12_1),
		.reset_ws_reg 														(pe_reset_ws_reg_12_1),
		.r_addr_w_mem														(pe_wmem_r_addr_12_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_1),
		.w_data_w_mem 														(pe_wmem_w_data_12_1),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_1),
		.sum_out															(part_sum_out_12_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_1),
		.write_req_w_mem													(pe_wmem_write_req_13_1),
		.ws_en																(pe_ws_en_13_1),
		.ws_mux																(pe_ws_mux_13_1),
		.reset_ws_reg 														(pe_reset_ws_reg_13_1),
		.r_addr_w_mem														(pe_wmem_r_addr_13_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_1),
		.w_data_w_mem 														(pe_wmem_w_data_13_1),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_1),
		.sum_out															(part_sum_out_13_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_1),
		.write_req_w_mem													(pe_wmem_write_req_14_1),
		.ws_en																(pe_ws_en_14_1),
		.ws_mux																(pe_ws_mux_14_1),
		.reset_ws_reg 														(pe_reset_ws_reg_14_1),
		.r_addr_w_mem														(pe_wmem_r_addr_14_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_1),
		.w_data_w_mem 														(pe_wmem_w_data_14_1),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_1),
		.sum_out															(part_sum_out_14_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_1 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_1),
		.write_req_w_mem													(pe_wmem_write_req_15_1),
		.ws_en																(pe_ws_en_15_1),
		.ws_mux																(pe_ws_mux_15_1),
		.reset_ws_reg 														(pe_reset_ws_reg_15_1),
		.r_addr_w_mem														(pe_wmem_r_addr_15_1),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_1),
		.w_data_w_mem 														(pe_wmem_w_data_15_1),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_1),
		.sum_out															(part_sum_out_15_1)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_2),
		.write_req_w_mem													(pe_wmem_write_req_0_2),
		.ws_en																(pe_ws_en_0_2),
		.ws_mux																(pe_ws_mux_0_2),
		.reset_ws_reg 														(pe_reset_ws_reg_0_2),
		.r_addr_w_mem														(pe_wmem_r_addr_0_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_2),
		.w_data_w_mem 														(pe_wmem_w_data_0_2),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_2),
		.sum_out															(part_sum_out_0_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_2),
		.write_req_w_mem													(pe_wmem_write_req_1_2),
		.ws_en																(pe_ws_en_1_2),
		.ws_mux																(pe_ws_mux_1_2),
		.reset_ws_reg 														(pe_reset_ws_reg_1_2),
		.r_addr_w_mem														(pe_wmem_r_addr_1_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_2),
		.w_data_w_mem 														(pe_wmem_w_data_1_2),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_2),
		.sum_out															(part_sum_out_1_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_2),
		.write_req_w_mem													(pe_wmem_write_req_2_2),
		.ws_en																(pe_ws_en_2_2),
		.ws_mux																(pe_ws_mux_2_2),
		.reset_ws_reg 														(pe_reset_ws_reg_2_2),
		.r_addr_w_mem														(pe_wmem_r_addr_2_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_2),
		.w_data_w_mem 														(pe_wmem_w_data_2_2),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_2),
		.sum_out															(part_sum_out_2_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_2),
		.write_req_w_mem													(pe_wmem_write_req_3_2),
		.ws_en																(pe_ws_en_3_2),
		.ws_mux																(pe_ws_mux_3_2),
		.reset_ws_reg 														(pe_reset_ws_reg_3_2),
		.r_addr_w_mem														(pe_wmem_r_addr_3_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_2),
		.w_data_w_mem 														(pe_wmem_w_data_3_2),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_2),
		.sum_out															(part_sum_out_3_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_2),
		.write_req_w_mem													(pe_wmem_write_req_4_2),
		.ws_en																(pe_ws_en_4_2),
		.ws_mux																(pe_ws_mux_4_2),
		.reset_ws_reg 														(pe_reset_ws_reg_4_2),
		.r_addr_w_mem														(pe_wmem_r_addr_4_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_2),
		.w_data_w_mem 														(pe_wmem_w_data_4_2),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_2),
		.sum_out															(part_sum_out_4_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_2),
		.write_req_w_mem													(pe_wmem_write_req_5_2),
		.ws_en																(pe_ws_en_5_2),
		.ws_mux																(pe_ws_mux_5_2),
		.reset_ws_reg 														(pe_reset_ws_reg_5_2),
		.r_addr_w_mem														(pe_wmem_r_addr_5_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_2),
		.w_data_w_mem 														(pe_wmem_w_data_5_2),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_2),
		.sum_out															(part_sum_out_5_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_2),
		.write_req_w_mem													(pe_wmem_write_req_6_2),
		.ws_en																(pe_ws_en_6_2),
		.ws_mux																(pe_ws_mux_6_2),
		.reset_ws_reg 														(pe_reset_ws_reg_6_2),
		.r_addr_w_mem														(pe_wmem_r_addr_6_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_2),
		.w_data_w_mem 														(pe_wmem_w_data_6_2),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_2),
		.sum_out															(part_sum_out_6_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_2),
		.write_req_w_mem													(pe_wmem_write_req_7_2),
		.ws_en																(pe_ws_en_7_2),
		.ws_mux																(pe_ws_mux_7_2),
		.reset_ws_reg 														(pe_reset_ws_reg_7_2),
		.r_addr_w_mem														(pe_wmem_r_addr_7_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_2),
		.w_data_w_mem 														(pe_wmem_w_data_7_2),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_2),
		.sum_out															(part_sum_out_7_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_2),
		.write_req_w_mem													(pe_wmem_write_req_8_2),
		.ws_en																(pe_ws_en_8_2),
		.ws_mux																(pe_ws_mux_8_2),
		.reset_ws_reg 														(pe_reset_ws_reg_8_2),
		.r_addr_w_mem														(pe_wmem_r_addr_8_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_2),
		.w_data_w_mem 														(pe_wmem_w_data_8_2),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_2),
		.sum_out															(part_sum_out_8_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_2),
		.write_req_w_mem													(pe_wmem_write_req_9_2),
		.ws_en																(pe_ws_en_9_2),
		.ws_mux																(pe_ws_mux_9_2),
		.reset_ws_reg 														(pe_reset_ws_reg_9_2),
		.r_addr_w_mem														(pe_wmem_r_addr_9_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_2),
		.w_data_w_mem 														(pe_wmem_w_data_9_2),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_2),
		.sum_out															(part_sum_out_9_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_2),
		.write_req_w_mem													(pe_wmem_write_req_10_2),
		.ws_en																(pe_ws_en_10_2),
		.ws_mux																(pe_ws_mux_10_2),
		.reset_ws_reg 														(pe_reset_ws_reg_10_2),
		.r_addr_w_mem														(pe_wmem_r_addr_10_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_2),
		.w_data_w_mem 														(pe_wmem_w_data_10_2),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_2),
		.sum_out															(part_sum_out_10_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_2),
		.write_req_w_mem													(pe_wmem_write_req_11_2),
		.ws_en																(pe_ws_en_11_2),
		.ws_mux																(pe_ws_mux_11_2),
		.reset_ws_reg 														(pe_reset_ws_reg_11_2),
		.r_addr_w_mem														(pe_wmem_r_addr_11_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_2),
		.w_data_w_mem 														(pe_wmem_w_data_11_2),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_2),
		.sum_out															(part_sum_out_11_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_2),
		.write_req_w_mem													(pe_wmem_write_req_12_2),
		.ws_en																(pe_ws_en_12_2),
		.ws_mux																(pe_ws_mux_12_2),
		.reset_ws_reg 														(pe_reset_ws_reg_12_2),
		.r_addr_w_mem														(pe_wmem_r_addr_12_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_2),
		.w_data_w_mem 														(pe_wmem_w_data_12_2),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_2),
		.sum_out															(part_sum_out_12_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_2),
		.write_req_w_mem													(pe_wmem_write_req_13_2),
		.ws_en																(pe_ws_en_13_2),
		.ws_mux																(pe_ws_mux_13_2),
		.reset_ws_reg 														(pe_reset_ws_reg_13_2),
		.r_addr_w_mem														(pe_wmem_r_addr_13_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_2),
		.w_data_w_mem 														(pe_wmem_w_data_13_2),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_2),
		.sum_out															(part_sum_out_13_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_2),
		.write_req_w_mem													(pe_wmem_write_req_14_2),
		.ws_en																(pe_ws_en_14_2),
		.ws_mux																(pe_ws_mux_14_2),
		.reset_ws_reg 														(pe_reset_ws_reg_14_2),
		.r_addr_w_mem														(pe_wmem_r_addr_14_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_2),
		.w_data_w_mem 														(pe_wmem_w_data_14_2),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_2),
		.sum_out															(part_sum_out_14_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_2 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_2),
		.write_req_w_mem													(pe_wmem_write_req_15_2),
		.ws_en																(pe_ws_en_15_2),
		.ws_mux																(pe_ws_mux_15_2),
		.reset_ws_reg 														(pe_reset_ws_reg_15_2),
		.r_addr_w_mem														(pe_wmem_r_addr_15_2),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_2),
		.w_data_w_mem 														(pe_wmem_w_data_15_2),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_2),
		.sum_out															(part_sum_out_15_2)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_3),
		.write_req_w_mem													(pe_wmem_write_req_0_3),
		.ws_en																(pe_ws_en_0_3),
		.ws_mux																(pe_ws_mux_0_3),
		.reset_ws_reg 														(pe_reset_ws_reg_0_3),
		.r_addr_w_mem														(pe_wmem_r_addr_0_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_3),
		.w_data_w_mem 														(pe_wmem_w_data_0_3),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_3),
		.sum_out															(part_sum_out_0_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_3),
		.write_req_w_mem													(pe_wmem_write_req_1_3),
		.ws_en																(pe_ws_en_1_3),
		.ws_mux																(pe_ws_mux_1_3),
		.reset_ws_reg 														(pe_reset_ws_reg_1_3),
		.r_addr_w_mem														(pe_wmem_r_addr_1_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_3),
		.w_data_w_mem 														(pe_wmem_w_data_1_3),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_3),
		.sum_out															(part_sum_out_1_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_3),
		.write_req_w_mem													(pe_wmem_write_req_2_3),
		.ws_en																(pe_ws_en_2_3),
		.ws_mux																(pe_ws_mux_2_3),
		.reset_ws_reg 														(pe_reset_ws_reg_2_3),
		.r_addr_w_mem														(pe_wmem_r_addr_2_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_3),
		.w_data_w_mem 														(pe_wmem_w_data_2_3),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_3),
		.sum_out															(part_sum_out_2_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_3),
		.write_req_w_mem													(pe_wmem_write_req_3_3),
		.ws_en																(pe_ws_en_3_3),
		.ws_mux																(pe_ws_mux_3_3),
		.reset_ws_reg 														(pe_reset_ws_reg_3_3),
		.r_addr_w_mem														(pe_wmem_r_addr_3_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_3),
		.w_data_w_mem 														(pe_wmem_w_data_3_3),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_3),
		.sum_out															(part_sum_out_3_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_3),
		.write_req_w_mem													(pe_wmem_write_req_4_3),
		.ws_en																(pe_ws_en_4_3),
		.ws_mux																(pe_ws_mux_4_3),
		.reset_ws_reg 														(pe_reset_ws_reg_4_3),
		.r_addr_w_mem														(pe_wmem_r_addr_4_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_3),
		.w_data_w_mem 														(pe_wmem_w_data_4_3),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_3),
		.sum_out															(part_sum_out_4_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_3),
		.write_req_w_mem													(pe_wmem_write_req_5_3),
		.ws_en																(pe_ws_en_5_3),
		.ws_mux																(pe_ws_mux_5_3),
		.reset_ws_reg 														(pe_reset_ws_reg_5_3),
		.r_addr_w_mem														(pe_wmem_r_addr_5_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_3),
		.w_data_w_mem 														(pe_wmem_w_data_5_3),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_3),
		.sum_out															(part_sum_out_5_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_3),
		.write_req_w_mem													(pe_wmem_write_req_6_3),
		.ws_en																(pe_ws_en_6_3),
		.ws_mux																(pe_ws_mux_6_3),
		.reset_ws_reg 														(pe_reset_ws_reg_6_3),
		.r_addr_w_mem														(pe_wmem_r_addr_6_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_3),
		.w_data_w_mem 														(pe_wmem_w_data_6_3),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_3),
		.sum_out															(part_sum_out_6_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_3),
		.write_req_w_mem													(pe_wmem_write_req_7_3),
		.ws_en																(pe_ws_en_7_3),
		.ws_mux																(pe_ws_mux_7_3),
		.reset_ws_reg 														(pe_reset_ws_reg_7_3),
		.r_addr_w_mem														(pe_wmem_r_addr_7_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_3),
		.w_data_w_mem 														(pe_wmem_w_data_7_3),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_3),
		.sum_out															(part_sum_out_7_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_3),
		.write_req_w_mem													(pe_wmem_write_req_8_3),
		.ws_en																(pe_ws_en_8_3),
		.ws_mux																(pe_ws_mux_8_3),
		.reset_ws_reg 														(pe_reset_ws_reg_8_3),
		.r_addr_w_mem														(pe_wmem_r_addr_8_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_3),
		.w_data_w_mem 														(pe_wmem_w_data_8_3),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_3),
		.sum_out															(part_sum_out_8_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_3),
		.write_req_w_mem													(pe_wmem_write_req_9_3),
		.ws_en																(pe_ws_en_9_3),
		.ws_mux																(pe_ws_mux_9_3),
		.reset_ws_reg 														(pe_reset_ws_reg_9_3),
		.r_addr_w_mem														(pe_wmem_r_addr_9_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_3),
		.w_data_w_mem 														(pe_wmem_w_data_9_3),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_3),
		.sum_out															(part_sum_out_9_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_3),
		.write_req_w_mem													(pe_wmem_write_req_10_3),
		.ws_en																(pe_ws_en_10_3),
		.ws_mux																(pe_ws_mux_10_3),
		.reset_ws_reg 														(pe_reset_ws_reg_10_3),
		.r_addr_w_mem														(pe_wmem_r_addr_10_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_3),
		.w_data_w_mem 														(pe_wmem_w_data_10_3),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_3),
		.sum_out															(part_sum_out_10_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_3),
		.write_req_w_mem													(pe_wmem_write_req_11_3),
		.ws_en																(pe_ws_en_11_3),
		.ws_mux																(pe_ws_mux_11_3),
		.reset_ws_reg 														(pe_reset_ws_reg_11_3),
		.r_addr_w_mem														(pe_wmem_r_addr_11_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_3),
		.w_data_w_mem 														(pe_wmem_w_data_11_3),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_3),
		.sum_out															(part_sum_out_11_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_3),
		.write_req_w_mem													(pe_wmem_write_req_12_3),
		.ws_en																(pe_ws_en_12_3),
		.ws_mux																(pe_ws_mux_12_3),
		.reset_ws_reg 														(pe_reset_ws_reg_12_3),
		.r_addr_w_mem														(pe_wmem_r_addr_12_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_3),
		.w_data_w_mem 														(pe_wmem_w_data_12_3),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_3),
		.sum_out															(part_sum_out_12_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_3),
		.write_req_w_mem													(pe_wmem_write_req_13_3),
		.ws_en																(pe_ws_en_13_3),
		.ws_mux																(pe_ws_mux_13_3),
		.reset_ws_reg 														(pe_reset_ws_reg_13_3),
		.r_addr_w_mem														(pe_wmem_r_addr_13_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_3),
		.w_data_w_mem 														(pe_wmem_w_data_13_3),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_3),
		.sum_out															(part_sum_out_13_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_3),
		.write_req_w_mem													(pe_wmem_write_req_14_3),
		.ws_en																(pe_ws_en_14_3),
		.ws_mux																(pe_ws_mux_14_3),
		.reset_ws_reg 														(pe_reset_ws_reg_14_3),
		.r_addr_w_mem														(pe_wmem_r_addr_14_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_3),
		.w_data_w_mem 														(pe_wmem_w_data_14_3),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_3),
		.sum_out															(part_sum_out_14_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_3 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_3),
		.write_req_w_mem													(pe_wmem_write_req_15_3),
		.ws_en																(pe_ws_en_15_3),
		.ws_mux																(pe_ws_mux_15_3),
		.reset_ws_reg 														(pe_reset_ws_reg_15_3),
		.r_addr_w_mem														(pe_wmem_r_addr_15_3),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_3),
		.w_data_w_mem 														(pe_wmem_w_data_15_3),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_3),
		.sum_out															(part_sum_out_15_3)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_4),
		.write_req_w_mem													(pe_wmem_write_req_0_4),
		.ws_en																(pe_ws_en_0_4),
		.ws_mux																(pe_ws_mux_0_4),
		.reset_ws_reg 														(pe_reset_ws_reg_0_4),
		.r_addr_w_mem														(pe_wmem_r_addr_0_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_4),
		.w_data_w_mem 														(pe_wmem_w_data_0_4),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_4),
		.sum_out															(part_sum_out_0_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_4),
		.write_req_w_mem													(pe_wmem_write_req_1_4),
		.ws_en																(pe_ws_en_1_4),
		.ws_mux																(pe_ws_mux_1_4),
		.reset_ws_reg 														(pe_reset_ws_reg_1_4),
		.r_addr_w_mem														(pe_wmem_r_addr_1_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_4),
		.w_data_w_mem 														(pe_wmem_w_data_1_4),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_4),
		.sum_out															(part_sum_out_1_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_4),
		.write_req_w_mem													(pe_wmem_write_req_2_4),
		.ws_en																(pe_ws_en_2_4),
		.ws_mux																(pe_ws_mux_2_4),
		.reset_ws_reg 														(pe_reset_ws_reg_2_4),
		.r_addr_w_mem														(pe_wmem_r_addr_2_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_4),
		.w_data_w_mem 														(pe_wmem_w_data_2_4),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_4),
		.sum_out															(part_sum_out_2_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_4),
		.write_req_w_mem													(pe_wmem_write_req_3_4),
		.ws_en																(pe_ws_en_3_4),
		.ws_mux																(pe_ws_mux_3_4),
		.reset_ws_reg 														(pe_reset_ws_reg_3_4),
		.r_addr_w_mem														(pe_wmem_r_addr_3_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_4),
		.w_data_w_mem 														(pe_wmem_w_data_3_4),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_4),
		.sum_out															(part_sum_out_3_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_4),
		.write_req_w_mem													(pe_wmem_write_req_4_4),
		.ws_en																(pe_ws_en_4_4),
		.ws_mux																(pe_ws_mux_4_4),
		.reset_ws_reg 														(pe_reset_ws_reg_4_4),
		.r_addr_w_mem														(pe_wmem_r_addr_4_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_4),
		.w_data_w_mem 														(pe_wmem_w_data_4_4),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_4),
		.sum_out															(part_sum_out_4_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_4),
		.write_req_w_mem													(pe_wmem_write_req_5_4),
		.ws_en																(pe_ws_en_5_4),
		.ws_mux																(pe_ws_mux_5_4),
		.reset_ws_reg 														(pe_reset_ws_reg_5_4),
		.r_addr_w_mem														(pe_wmem_r_addr_5_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_4),
		.w_data_w_mem 														(pe_wmem_w_data_5_4),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_4),
		.sum_out															(part_sum_out_5_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_4),
		.write_req_w_mem													(pe_wmem_write_req_6_4),
		.ws_en																(pe_ws_en_6_4),
		.ws_mux																(pe_ws_mux_6_4),
		.reset_ws_reg 														(pe_reset_ws_reg_6_4),
		.r_addr_w_mem														(pe_wmem_r_addr_6_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_4),
		.w_data_w_mem 														(pe_wmem_w_data_6_4),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_4),
		.sum_out															(part_sum_out_6_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_4),
		.write_req_w_mem													(pe_wmem_write_req_7_4),
		.ws_en																(pe_ws_en_7_4),
		.ws_mux																(pe_ws_mux_7_4),
		.reset_ws_reg 														(pe_reset_ws_reg_7_4),
		.r_addr_w_mem														(pe_wmem_r_addr_7_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_4),
		.w_data_w_mem 														(pe_wmem_w_data_7_4),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_4),
		.sum_out															(part_sum_out_7_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_4),
		.write_req_w_mem													(pe_wmem_write_req_8_4),
		.ws_en																(pe_ws_en_8_4),
		.ws_mux																(pe_ws_mux_8_4),
		.reset_ws_reg 														(pe_reset_ws_reg_8_4),
		.r_addr_w_mem														(pe_wmem_r_addr_8_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_4),
		.w_data_w_mem 														(pe_wmem_w_data_8_4),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_4),
		.sum_out															(part_sum_out_8_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_4),
		.write_req_w_mem													(pe_wmem_write_req_9_4),
		.ws_en																(pe_ws_en_9_4),
		.ws_mux																(pe_ws_mux_9_4),
		.reset_ws_reg 														(pe_reset_ws_reg_9_4),
		.r_addr_w_mem														(pe_wmem_r_addr_9_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_4),
		.w_data_w_mem 														(pe_wmem_w_data_9_4),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_4),
		.sum_out															(part_sum_out_9_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_4),
		.write_req_w_mem													(pe_wmem_write_req_10_4),
		.ws_en																(pe_ws_en_10_4),
		.ws_mux																(pe_ws_mux_10_4),
		.reset_ws_reg 														(pe_reset_ws_reg_10_4),
		.r_addr_w_mem														(pe_wmem_r_addr_10_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_4),
		.w_data_w_mem 														(pe_wmem_w_data_10_4),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_4),
		.sum_out															(part_sum_out_10_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_4),
		.write_req_w_mem													(pe_wmem_write_req_11_4),
		.ws_en																(pe_ws_en_11_4),
		.ws_mux																(pe_ws_mux_11_4),
		.reset_ws_reg 														(pe_reset_ws_reg_11_4),
		.r_addr_w_mem														(pe_wmem_r_addr_11_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_4),
		.w_data_w_mem 														(pe_wmem_w_data_11_4),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_4),
		.sum_out															(part_sum_out_11_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_4),
		.write_req_w_mem													(pe_wmem_write_req_12_4),
		.ws_en																(pe_ws_en_12_4),
		.ws_mux																(pe_ws_mux_12_4),
		.reset_ws_reg 														(pe_reset_ws_reg_12_4),
		.r_addr_w_mem														(pe_wmem_r_addr_12_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_4),
		.w_data_w_mem 														(pe_wmem_w_data_12_4),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_4),
		.sum_out															(part_sum_out_12_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_4),
		.write_req_w_mem													(pe_wmem_write_req_13_4),
		.ws_en																(pe_ws_en_13_4),
		.ws_mux																(pe_ws_mux_13_4),
		.reset_ws_reg 														(pe_reset_ws_reg_13_4),
		.r_addr_w_mem														(pe_wmem_r_addr_13_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_4),
		.w_data_w_mem 														(pe_wmem_w_data_13_4),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_4),
		.sum_out															(part_sum_out_13_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_4),
		.write_req_w_mem													(pe_wmem_write_req_14_4),
		.ws_en																(pe_ws_en_14_4),
		.ws_mux																(pe_ws_mux_14_4),
		.reset_ws_reg 														(pe_reset_ws_reg_14_4),
		.r_addr_w_mem														(pe_wmem_r_addr_14_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_4),
		.w_data_w_mem 														(pe_wmem_w_data_14_4),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_4),
		.sum_out															(part_sum_out_14_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_4 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_4),
		.write_req_w_mem													(pe_wmem_write_req_15_4),
		.ws_en																(pe_ws_en_15_4),
		.ws_mux																(pe_ws_mux_15_4),
		.reset_ws_reg 														(pe_reset_ws_reg_15_4),
		.r_addr_w_mem														(pe_wmem_r_addr_15_4),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_4),
		.w_data_w_mem 														(pe_wmem_w_data_15_4),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_4),
		.sum_out															(part_sum_out_15_4)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_5),
		.write_req_w_mem													(pe_wmem_write_req_0_5),
		.ws_en																(pe_ws_en_0_5),
		.ws_mux																(pe_ws_mux_0_5),
		.reset_ws_reg 														(pe_reset_ws_reg_0_5),
		.r_addr_w_mem														(pe_wmem_r_addr_0_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_5),
		.w_data_w_mem 														(pe_wmem_w_data_0_5),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_5),
		.sum_out															(part_sum_out_0_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_5),
		.write_req_w_mem													(pe_wmem_write_req_1_5),
		.ws_en																(pe_ws_en_1_5),
		.ws_mux																(pe_ws_mux_1_5),
		.reset_ws_reg 														(pe_reset_ws_reg_1_5),
		.r_addr_w_mem														(pe_wmem_r_addr_1_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_5),
		.w_data_w_mem 														(pe_wmem_w_data_1_5),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_5),
		.sum_out															(part_sum_out_1_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_5),
		.write_req_w_mem													(pe_wmem_write_req_2_5),
		.ws_en																(pe_ws_en_2_5),
		.ws_mux																(pe_ws_mux_2_5),
		.reset_ws_reg 														(pe_reset_ws_reg_2_5),
		.r_addr_w_mem														(pe_wmem_r_addr_2_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_5),
		.w_data_w_mem 														(pe_wmem_w_data_2_5),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_5),
		.sum_out															(part_sum_out_2_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_5),
		.write_req_w_mem													(pe_wmem_write_req_3_5),
		.ws_en																(pe_ws_en_3_5),
		.ws_mux																(pe_ws_mux_3_5),
		.reset_ws_reg 														(pe_reset_ws_reg_3_5),
		.r_addr_w_mem														(pe_wmem_r_addr_3_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_5),
		.w_data_w_mem 														(pe_wmem_w_data_3_5),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_5),
		.sum_out															(part_sum_out_3_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_5),
		.write_req_w_mem													(pe_wmem_write_req_4_5),
		.ws_en																(pe_ws_en_4_5),
		.ws_mux																(pe_ws_mux_4_5),
		.reset_ws_reg 														(pe_reset_ws_reg_4_5),
		.r_addr_w_mem														(pe_wmem_r_addr_4_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_5),
		.w_data_w_mem 														(pe_wmem_w_data_4_5),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_5),
		.sum_out															(part_sum_out_4_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_5),
		.write_req_w_mem													(pe_wmem_write_req_5_5),
		.ws_en																(pe_ws_en_5_5),
		.ws_mux																(pe_ws_mux_5_5),
		.reset_ws_reg 														(pe_reset_ws_reg_5_5),
		.r_addr_w_mem														(pe_wmem_r_addr_5_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_5),
		.w_data_w_mem 														(pe_wmem_w_data_5_5),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_5),
		.sum_out															(part_sum_out_5_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_5),
		.write_req_w_mem													(pe_wmem_write_req_6_5),
		.ws_en																(pe_ws_en_6_5),
		.ws_mux																(pe_ws_mux_6_5),
		.reset_ws_reg 														(pe_reset_ws_reg_6_5),
		.r_addr_w_mem														(pe_wmem_r_addr_6_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_5),
		.w_data_w_mem 														(pe_wmem_w_data_6_5),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_5),
		.sum_out															(part_sum_out_6_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_5),
		.write_req_w_mem													(pe_wmem_write_req_7_5),
		.ws_en																(pe_ws_en_7_5),
		.ws_mux																(pe_ws_mux_7_5),
		.reset_ws_reg 														(pe_reset_ws_reg_7_5),
		.r_addr_w_mem														(pe_wmem_r_addr_7_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_5),
		.w_data_w_mem 														(pe_wmem_w_data_7_5),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_5),
		.sum_out															(part_sum_out_7_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_5),
		.write_req_w_mem													(pe_wmem_write_req_8_5),
		.ws_en																(pe_ws_en_8_5),
		.ws_mux																(pe_ws_mux_8_5),
		.reset_ws_reg 														(pe_reset_ws_reg_8_5),
		.r_addr_w_mem														(pe_wmem_r_addr_8_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_5),
		.w_data_w_mem 														(pe_wmem_w_data_8_5),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_5),
		.sum_out															(part_sum_out_8_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_5),
		.write_req_w_mem													(pe_wmem_write_req_9_5),
		.ws_en																(pe_ws_en_9_5),
		.ws_mux																(pe_ws_mux_9_5),
		.reset_ws_reg 														(pe_reset_ws_reg_9_5),
		.r_addr_w_mem														(pe_wmem_r_addr_9_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_5),
		.w_data_w_mem 														(pe_wmem_w_data_9_5),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_5),
		.sum_out															(part_sum_out_9_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_5),
		.write_req_w_mem													(pe_wmem_write_req_10_5),
		.ws_en																(pe_ws_en_10_5),
		.ws_mux																(pe_ws_mux_10_5),
		.reset_ws_reg 														(pe_reset_ws_reg_10_5),
		.r_addr_w_mem														(pe_wmem_r_addr_10_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_5),
		.w_data_w_mem 														(pe_wmem_w_data_10_5),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_5),
		.sum_out															(part_sum_out_10_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_5),
		.write_req_w_mem													(pe_wmem_write_req_11_5),
		.ws_en																(pe_ws_en_11_5),
		.ws_mux																(pe_ws_mux_11_5),
		.reset_ws_reg 														(pe_reset_ws_reg_11_5),
		.r_addr_w_mem														(pe_wmem_r_addr_11_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_5),
		.w_data_w_mem 														(pe_wmem_w_data_11_5),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_5),
		.sum_out															(part_sum_out_11_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_5),
		.write_req_w_mem													(pe_wmem_write_req_12_5),
		.ws_en																(pe_ws_en_12_5),
		.ws_mux																(pe_ws_mux_12_5),
		.reset_ws_reg 														(pe_reset_ws_reg_12_5),
		.r_addr_w_mem														(pe_wmem_r_addr_12_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_5),
		.w_data_w_mem 														(pe_wmem_w_data_12_5),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_5),
		.sum_out															(part_sum_out_12_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_5),
		.write_req_w_mem													(pe_wmem_write_req_13_5),
		.ws_en																(pe_ws_en_13_5),
		.ws_mux																(pe_ws_mux_13_5),
		.reset_ws_reg 														(pe_reset_ws_reg_13_5),
		.r_addr_w_mem														(pe_wmem_r_addr_13_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_5),
		.w_data_w_mem 														(pe_wmem_w_data_13_5),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_5),
		.sum_out															(part_sum_out_13_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_5),
		.write_req_w_mem													(pe_wmem_write_req_14_5),
		.ws_en																(pe_ws_en_14_5),
		.ws_mux																(pe_ws_mux_14_5),
		.reset_ws_reg 														(pe_reset_ws_reg_14_5),
		.r_addr_w_mem														(pe_wmem_r_addr_14_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_5),
		.w_data_w_mem 														(pe_wmem_w_data_14_5),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_5),
		.sum_out															(part_sum_out_14_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_5 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_5),
		.write_req_w_mem													(pe_wmem_write_req_15_5),
		.ws_en																(pe_ws_en_15_5),
		.ws_mux																(pe_ws_mux_15_5),
		.reset_ws_reg 														(pe_reset_ws_reg_15_5),
		.r_addr_w_mem														(pe_wmem_r_addr_15_5),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_5),
		.w_data_w_mem 														(pe_wmem_w_data_15_5),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_5),
		.sum_out															(part_sum_out_15_5)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_6),
		.write_req_w_mem													(pe_wmem_write_req_0_6),
		.ws_en																(pe_ws_en_0_6),
		.ws_mux																(pe_ws_mux_0_6),
		.reset_ws_reg 														(pe_reset_ws_reg_0_6),
		.r_addr_w_mem														(pe_wmem_r_addr_0_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_6),
		.w_data_w_mem 														(pe_wmem_w_data_0_6),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_6),
		.sum_out															(part_sum_out_0_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_6),
		.write_req_w_mem													(pe_wmem_write_req_1_6),
		.ws_en																(pe_ws_en_1_6),
		.ws_mux																(pe_ws_mux_1_6),
		.reset_ws_reg 														(pe_reset_ws_reg_1_6),
		.r_addr_w_mem														(pe_wmem_r_addr_1_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_6),
		.w_data_w_mem 														(pe_wmem_w_data_1_6),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_6),
		.sum_out															(part_sum_out_1_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_6),
		.write_req_w_mem													(pe_wmem_write_req_2_6),
		.ws_en																(pe_ws_en_2_6),
		.ws_mux																(pe_ws_mux_2_6),
		.reset_ws_reg 														(pe_reset_ws_reg_2_6),
		.r_addr_w_mem														(pe_wmem_r_addr_2_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_6),
		.w_data_w_mem 														(pe_wmem_w_data_2_6),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_6),
		.sum_out															(part_sum_out_2_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_6),
		.write_req_w_mem													(pe_wmem_write_req_3_6),
		.ws_en																(pe_ws_en_3_6),
		.ws_mux																(pe_ws_mux_3_6),
		.reset_ws_reg 														(pe_reset_ws_reg_3_6),
		.r_addr_w_mem														(pe_wmem_r_addr_3_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_6),
		.w_data_w_mem 														(pe_wmem_w_data_3_6),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_6),
		.sum_out															(part_sum_out_3_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_6),
		.write_req_w_mem													(pe_wmem_write_req_4_6),
		.ws_en																(pe_ws_en_4_6),
		.ws_mux																(pe_ws_mux_4_6),
		.reset_ws_reg 														(pe_reset_ws_reg_4_6),
		.r_addr_w_mem														(pe_wmem_r_addr_4_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_6),
		.w_data_w_mem 														(pe_wmem_w_data_4_6),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_6),
		.sum_out															(part_sum_out_4_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_6),
		.write_req_w_mem													(pe_wmem_write_req_5_6),
		.ws_en																(pe_ws_en_5_6),
		.ws_mux																(pe_ws_mux_5_6),
		.reset_ws_reg 														(pe_reset_ws_reg_5_6),
		.r_addr_w_mem														(pe_wmem_r_addr_5_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_6),
		.w_data_w_mem 														(pe_wmem_w_data_5_6),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_6),
		.sum_out															(part_sum_out_5_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_6),
		.write_req_w_mem													(pe_wmem_write_req_6_6),
		.ws_en																(pe_ws_en_6_6),
		.ws_mux																(pe_ws_mux_6_6),
		.reset_ws_reg 														(pe_reset_ws_reg_6_6),
		.r_addr_w_mem														(pe_wmem_r_addr_6_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_6),
		.w_data_w_mem 														(pe_wmem_w_data_6_6),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_6),
		.sum_out															(part_sum_out_6_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_6),
		.write_req_w_mem													(pe_wmem_write_req_7_6),
		.ws_en																(pe_ws_en_7_6),
		.ws_mux																(pe_ws_mux_7_6),
		.reset_ws_reg 														(pe_reset_ws_reg_7_6),
		.r_addr_w_mem														(pe_wmem_r_addr_7_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_6),
		.w_data_w_mem 														(pe_wmem_w_data_7_6),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_6),
		.sum_out															(part_sum_out_7_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_6),
		.write_req_w_mem													(pe_wmem_write_req_8_6),
		.ws_en																(pe_ws_en_8_6),
		.ws_mux																(pe_ws_mux_8_6),
		.reset_ws_reg 														(pe_reset_ws_reg_8_6),
		.r_addr_w_mem														(pe_wmem_r_addr_8_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_6),
		.w_data_w_mem 														(pe_wmem_w_data_8_6),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_6),
		.sum_out															(part_sum_out_8_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_6),
		.write_req_w_mem													(pe_wmem_write_req_9_6),
		.ws_en																(pe_ws_en_9_6),
		.ws_mux																(pe_ws_mux_9_6),
		.reset_ws_reg 														(pe_reset_ws_reg_9_6),
		.r_addr_w_mem														(pe_wmem_r_addr_9_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_6),
		.w_data_w_mem 														(pe_wmem_w_data_9_6),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_6),
		.sum_out															(part_sum_out_9_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_6),
		.write_req_w_mem													(pe_wmem_write_req_10_6),
		.ws_en																(pe_ws_en_10_6),
		.ws_mux																(pe_ws_mux_10_6),
		.reset_ws_reg 														(pe_reset_ws_reg_10_6),
		.r_addr_w_mem														(pe_wmem_r_addr_10_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_6),
		.w_data_w_mem 														(pe_wmem_w_data_10_6),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_6),
		.sum_out															(part_sum_out_10_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_6),
		.write_req_w_mem													(pe_wmem_write_req_11_6),
		.ws_en																(pe_ws_en_11_6),
		.ws_mux																(pe_ws_mux_11_6),
		.reset_ws_reg 														(pe_reset_ws_reg_11_6),
		.r_addr_w_mem														(pe_wmem_r_addr_11_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_6),
		.w_data_w_mem 														(pe_wmem_w_data_11_6),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_6),
		.sum_out															(part_sum_out_11_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_6),
		.write_req_w_mem													(pe_wmem_write_req_12_6),
		.ws_en																(pe_ws_en_12_6),
		.ws_mux																(pe_ws_mux_12_6),
		.reset_ws_reg 														(pe_reset_ws_reg_12_6),
		.r_addr_w_mem														(pe_wmem_r_addr_12_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_6),
		.w_data_w_mem 														(pe_wmem_w_data_12_6),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_6),
		.sum_out															(part_sum_out_12_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_6),
		.write_req_w_mem													(pe_wmem_write_req_13_6),
		.ws_en																(pe_ws_en_13_6),
		.ws_mux																(pe_ws_mux_13_6),
		.reset_ws_reg 														(pe_reset_ws_reg_13_6),
		.r_addr_w_mem														(pe_wmem_r_addr_13_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_6),
		.w_data_w_mem 														(pe_wmem_w_data_13_6),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_6),
		.sum_out															(part_sum_out_13_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_6),
		.write_req_w_mem													(pe_wmem_write_req_14_6),
		.ws_en																(pe_ws_en_14_6),
		.ws_mux																(pe_ws_mux_14_6),
		.reset_ws_reg 														(pe_reset_ws_reg_14_6),
		.r_addr_w_mem														(pe_wmem_r_addr_14_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_6),
		.w_data_w_mem 														(pe_wmem_w_data_14_6),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_6),
		.sum_out															(part_sum_out_14_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_6 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_6),
		.write_req_w_mem													(pe_wmem_write_req_15_6),
		.ws_en																(pe_ws_en_15_6),
		.ws_mux																(pe_ws_mux_15_6),
		.reset_ws_reg 														(pe_reset_ws_reg_15_6),
		.r_addr_w_mem														(pe_wmem_r_addr_15_6),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_6),
		.w_data_w_mem 														(pe_wmem_w_data_15_6),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_6),
		.sum_out															(part_sum_out_15_6)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_7),
		.write_req_w_mem													(pe_wmem_write_req_0_7),
		.ws_en																(pe_ws_en_0_7),
		.ws_mux																(pe_ws_mux_0_7),
		.reset_ws_reg 														(pe_reset_ws_reg_0_7),
		.r_addr_w_mem														(pe_wmem_r_addr_0_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_7),
		.w_data_w_mem 														(pe_wmem_w_data_0_7),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_7),
		.sum_out															(part_sum_out_0_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_7),
		.write_req_w_mem													(pe_wmem_write_req_1_7),
		.ws_en																(pe_ws_en_1_7),
		.ws_mux																(pe_ws_mux_1_7),
		.reset_ws_reg 														(pe_reset_ws_reg_1_7),
		.r_addr_w_mem														(pe_wmem_r_addr_1_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_7),
		.w_data_w_mem 														(pe_wmem_w_data_1_7),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_7),
		.sum_out															(part_sum_out_1_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_7),
		.write_req_w_mem													(pe_wmem_write_req_2_7),
		.ws_en																(pe_ws_en_2_7),
		.ws_mux																(pe_ws_mux_2_7),
		.reset_ws_reg 														(pe_reset_ws_reg_2_7),
		.r_addr_w_mem														(pe_wmem_r_addr_2_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_7),
		.w_data_w_mem 														(pe_wmem_w_data_2_7),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_7),
		.sum_out															(part_sum_out_2_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_7),
		.write_req_w_mem													(pe_wmem_write_req_3_7),
		.ws_en																(pe_ws_en_3_7),
		.ws_mux																(pe_ws_mux_3_7),
		.reset_ws_reg 														(pe_reset_ws_reg_3_7),
		.r_addr_w_mem														(pe_wmem_r_addr_3_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_7),
		.w_data_w_mem 														(pe_wmem_w_data_3_7),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_7),
		.sum_out															(part_sum_out_3_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_7),
		.write_req_w_mem													(pe_wmem_write_req_4_7),
		.ws_en																(pe_ws_en_4_7),
		.ws_mux																(pe_ws_mux_4_7),
		.reset_ws_reg 														(pe_reset_ws_reg_4_7),
		.r_addr_w_mem														(pe_wmem_r_addr_4_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_7),
		.w_data_w_mem 														(pe_wmem_w_data_4_7),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_7),
		.sum_out															(part_sum_out_4_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_7),
		.write_req_w_mem													(pe_wmem_write_req_5_7),
		.ws_en																(pe_ws_en_5_7),
		.ws_mux																(pe_ws_mux_5_7),
		.reset_ws_reg 														(pe_reset_ws_reg_5_7),
		.r_addr_w_mem														(pe_wmem_r_addr_5_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_7),
		.w_data_w_mem 														(pe_wmem_w_data_5_7),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_7),
		.sum_out															(part_sum_out_5_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_7),
		.write_req_w_mem													(pe_wmem_write_req_6_7),
		.ws_en																(pe_ws_en_6_7),
		.ws_mux																(pe_ws_mux_6_7),
		.reset_ws_reg 														(pe_reset_ws_reg_6_7),
		.r_addr_w_mem														(pe_wmem_r_addr_6_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_7),
		.w_data_w_mem 														(pe_wmem_w_data_6_7),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_7),
		.sum_out															(part_sum_out_6_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_7),
		.write_req_w_mem													(pe_wmem_write_req_7_7),
		.ws_en																(pe_ws_en_7_7),
		.ws_mux																(pe_ws_mux_7_7),
		.reset_ws_reg 														(pe_reset_ws_reg_7_7),
		.r_addr_w_mem														(pe_wmem_r_addr_7_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_7),
		.w_data_w_mem 														(pe_wmem_w_data_7_7),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_7),
		.sum_out															(part_sum_out_7_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_7),
		.write_req_w_mem													(pe_wmem_write_req_8_7),
		.ws_en																(pe_ws_en_8_7),
		.ws_mux																(pe_ws_mux_8_7),
		.reset_ws_reg 														(pe_reset_ws_reg_8_7),
		.r_addr_w_mem														(pe_wmem_r_addr_8_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_7),
		.w_data_w_mem 														(pe_wmem_w_data_8_7),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_7),
		.sum_out															(part_sum_out_8_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_7),
		.write_req_w_mem													(pe_wmem_write_req_9_7),
		.ws_en																(pe_ws_en_9_7),
		.ws_mux																(pe_ws_mux_9_7),
		.reset_ws_reg 														(pe_reset_ws_reg_9_7),
		.r_addr_w_mem														(pe_wmem_r_addr_9_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_7),
		.w_data_w_mem 														(pe_wmem_w_data_9_7),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_7),
		.sum_out															(part_sum_out_9_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_7),
		.write_req_w_mem													(pe_wmem_write_req_10_7),
		.ws_en																(pe_ws_en_10_7),
		.ws_mux																(pe_ws_mux_10_7),
		.reset_ws_reg 														(pe_reset_ws_reg_10_7),
		.r_addr_w_mem														(pe_wmem_r_addr_10_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_7),
		.w_data_w_mem 														(pe_wmem_w_data_10_7),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_7),
		.sum_out															(part_sum_out_10_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_7),
		.write_req_w_mem													(pe_wmem_write_req_11_7),
		.ws_en																(pe_ws_en_11_7),
		.ws_mux																(pe_ws_mux_11_7),
		.reset_ws_reg 														(pe_reset_ws_reg_11_7),
		.r_addr_w_mem														(pe_wmem_r_addr_11_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_7),
		.w_data_w_mem 														(pe_wmem_w_data_11_7),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_7),
		.sum_out															(part_sum_out_11_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_7),
		.write_req_w_mem													(pe_wmem_write_req_12_7),
		.ws_en																(pe_ws_en_12_7),
		.ws_mux																(pe_ws_mux_12_7),
		.reset_ws_reg 														(pe_reset_ws_reg_12_7),
		.r_addr_w_mem														(pe_wmem_r_addr_12_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_7),
		.w_data_w_mem 														(pe_wmem_w_data_12_7),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_7),
		.sum_out															(part_sum_out_12_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_7),
		.write_req_w_mem													(pe_wmem_write_req_13_7),
		.ws_en																(pe_ws_en_13_7),
		.ws_mux																(pe_ws_mux_13_7),
		.reset_ws_reg 														(pe_reset_ws_reg_13_7),
		.r_addr_w_mem														(pe_wmem_r_addr_13_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_7),
		.w_data_w_mem 														(pe_wmem_w_data_13_7),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_7),
		.sum_out															(part_sum_out_13_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_7),
		.write_req_w_mem													(pe_wmem_write_req_14_7),
		.ws_en																(pe_ws_en_14_7),
		.ws_mux																(pe_ws_mux_14_7),
		.reset_ws_reg 														(pe_reset_ws_reg_14_7),
		.r_addr_w_mem														(pe_wmem_r_addr_14_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_7),
		.w_data_w_mem 														(pe_wmem_w_data_14_7),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_7),
		.sum_out															(part_sum_out_14_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_7 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_7),
		.write_req_w_mem													(pe_wmem_write_req_15_7),
		.ws_en																(pe_ws_en_15_7),
		.ws_mux																(pe_ws_mux_15_7),
		.reset_ws_reg 														(pe_reset_ws_reg_15_7),
		.r_addr_w_mem														(pe_wmem_r_addr_15_7),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_7),
		.w_data_w_mem 														(pe_wmem_w_data_15_7),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_7),
		.sum_out															(part_sum_out_15_7)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_8),
		.write_req_w_mem													(pe_wmem_write_req_0_8),
		.ws_en																(pe_ws_en_0_8),
		.ws_mux																(pe_ws_mux_0_8),
		.reset_ws_reg 														(pe_reset_ws_reg_0_8),
		.r_addr_w_mem														(pe_wmem_r_addr_0_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_8),
		.w_data_w_mem 														(pe_wmem_w_data_0_8),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_8),
		.sum_out															(part_sum_out_0_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_8),
		.write_req_w_mem													(pe_wmem_write_req_1_8),
		.ws_en																(pe_ws_en_1_8),
		.ws_mux																(pe_ws_mux_1_8),
		.reset_ws_reg 														(pe_reset_ws_reg_1_8),
		.r_addr_w_mem														(pe_wmem_r_addr_1_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_8),
		.w_data_w_mem 														(pe_wmem_w_data_1_8),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_8),
		.sum_out															(part_sum_out_1_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_8),
		.write_req_w_mem													(pe_wmem_write_req_2_8),
		.ws_en																(pe_ws_en_2_8),
		.ws_mux																(pe_ws_mux_2_8),
		.reset_ws_reg 														(pe_reset_ws_reg_2_8),
		.r_addr_w_mem														(pe_wmem_r_addr_2_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_8),
		.w_data_w_mem 														(pe_wmem_w_data_2_8),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_8),
		.sum_out															(part_sum_out_2_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_8),
		.write_req_w_mem													(pe_wmem_write_req_3_8),
		.ws_en																(pe_ws_en_3_8),
		.ws_mux																(pe_ws_mux_3_8),
		.reset_ws_reg 														(pe_reset_ws_reg_3_8),
		.r_addr_w_mem														(pe_wmem_r_addr_3_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_8),
		.w_data_w_mem 														(pe_wmem_w_data_3_8),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_8),
		.sum_out															(part_sum_out_3_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_8),
		.write_req_w_mem													(pe_wmem_write_req_4_8),
		.ws_en																(pe_ws_en_4_8),
		.ws_mux																(pe_ws_mux_4_8),
		.reset_ws_reg 														(pe_reset_ws_reg_4_8),
		.r_addr_w_mem														(pe_wmem_r_addr_4_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_8),
		.w_data_w_mem 														(pe_wmem_w_data_4_8),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_8),
		.sum_out															(part_sum_out_4_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_8),
		.write_req_w_mem													(pe_wmem_write_req_5_8),
		.ws_en																(pe_ws_en_5_8),
		.ws_mux																(pe_ws_mux_5_8),
		.reset_ws_reg 														(pe_reset_ws_reg_5_8),
		.r_addr_w_mem														(pe_wmem_r_addr_5_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_8),
		.w_data_w_mem 														(pe_wmem_w_data_5_8),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_8),
		.sum_out															(part_sum_out_5_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_8),
		.write_req_w_mem													(pe_wmem_write_req_6_8),
		.ws_en																(pe_ws_en_6_8),
		.ws_mux																(pe_ws_mux_6_8),
		.reset_ws_reg 														(pe_reset_ws_reg_6_8),
		.r_addr_w_mem														(pe_wmem_r_addr_6_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_8),
		.w_data_w_mem 														(pe_wmem_w_data_6_8),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_8),
		.sum_out															(part_sum_out_6_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_8),
		.write_req_w_mem													(pe_wmem_write_req_7_8),
		.ws_en																(pe_ws_en_7_8),
		.ws_mux																(pe_ws_mux_7_8),
		.reset_ws_reg 														(pe_reset_ws_reg_7_8),
		.r_addr_w_mem														(pe_wmem_r_addr_7_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_8),
		.w_data_w_mem 														(pe_wmem_w_data_7_8),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_8),
		.sum_out															(part_sum_out_7_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_8),
		.write_req_w_mem													(pe_wmem_write_req_8_8),
		.ws_en																(pe_ws_en_8_8),
		.ws_mux																(pe_ws_mux_8_8),
		.reset_ws_reg 														(pe_reset_ws_reg_8_8),
		.r_addr_w_mem														(pe_wmem_r_addr_8_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_8),
		.w_data_w_mem 														(pe_wmem_w_data_8_8),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_8),
		.sum_out															(part_sum_out_8_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_8),
		.write_req_w_mem													(pe_wmem_write_req_9_8),
		.ws_en																(pe_ws_en_9_8),
		.ws_mux																(pe_ws_mux_9_8),
		.reset_ws_reg 														(pe_reset_ws_reg_9_8),
		.r_addr_w_mem														(pe_wmem_r_addr_9_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_8),
		.w_data_w_mem 														(pe_wmem_w_data_9_8),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_8),
		.sum_out															(part_sum_out_9_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_8),
		.write_req_w_mem													(pe_wmem_write_req_10_8),
		.ws_en																(pe_ws_en_10_8),
		.ws_mux																(pe_ws_mux_10_8),
		.reset_ws_reg 														(pe_reset_ws_reg_10_8),
		.r_addr_w_mem														(pe_wmem_r_addr_10_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_8),
		.w_data_w_mem 														(pe_wmem_w_data_10_8),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_8),
		.sum_out															(part_sum_out_10_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_8),
		.write_req_w_mem													(pe_wmem_write_req_11_8),
		.ws_en																(pe_ws_en_11_8),
		.ws_mux																(pe_ws_mux_11_8),
		.reset_ws_reg 														(pe_reset_ws_reg_11_8),
		.r_addr_w_mem														(pe_wmem_r_addr_11_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_8),
		.w_data_w_mem 														(pe_wmem_w_data_11_8),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_8),
		.sum_out															(part_sum_out_11_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_8),
		.write_req_w_mem													(pe_wmem_write_req_12_8),
		.ws_en																(pe_ws_en_12_8),
		.ws_mux																(pe_ws_mux_12_8),
		.reset_ws_reg 														(pe_reset_ws_reg_12_8),
		.r_addr_w_mem														(pe_wmem_r_addr_12_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_8),
		.w_data_w_mem 														(pe_wmem_w_data_12_8),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_8),
		.sum_out															(part_sum_out_12_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_8),
		.write_req_w_mem													(pe_wmem_write_req_13_8),
		.ws_en																(pe_ws_en_13_8),
		.ws_mux																(pe_ws_mux_13_8),
		.reset_ws_reg 														(pe_reset_ws_reg_13_8),
		.r_addr_w_mem														(pe_wmem_r_addr_13_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_8),
		.w_data_w_mem 														(pe_wmem_w_data_13_8),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_8),
		.sum_out															(part_sum_out_13_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_8),
		.write_req_w_mem													(pe_wmem_write_req_14_8),
		.ws_en																(pe_ws_en_14_8),
		.ws_mux																(pe_ws_mux_14_8),
		.reset_ws_reg 														(pe_reset_ws_reg_14_8),
		.r_addr_w_mem														(pe_wmem_r_addr_14_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_8),
		.w_data_w_mem 														(pe_wmem_w_data_14_8),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_8),
		.sum_out															(part_sum_out_14_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_8 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_8),
		.write_req_w_mem													(pe_wmem_write_req_15_8),
		.ws_en																(pe_ws_en_15_8),
		.ws_mux																(pe_ws_mux_15_8),
		.reset_ws_reg 														(pe_reset_ws_reg_15_8),
		.r_addr_w_mem														(pe_wmem_r_addr_15_8),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_8),
		.w_data_w_mem 														(pe_wmem_w_data_15_8),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_8),
		.sum_out															(part_sum_out_15_8)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_9),
		.write_req_w_mem													(pe_wmem_write_req_0_9),
		.ws_en																(pe_ws_en_0_9),
		.ws_mux																(pe_ws_mux_0_9),
		.reset_ws_reg 														(pe_reset_ws_reg_0_9),
		.r_addr_w_mem														(pe_wmem_r_addr_0_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_9),
		.w_data_w_mem 														(pe_wmem_w_data_0_9),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_9),
		.sum_out															(part_sum_out_0_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_9),
		.write_req_w_mem													(pe_wmem_write_req_1_9),
		.ws_en																(pe_ws_en_1_9),
		.ws_mux																(pe_ws_mux_1_9),
		.reset_ws_reg 														(pe_reset_ws_reg_1_9),
		.r_addr_w_mem														(pe_wmem_r_addr_1_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_9),
		.w_data_w_mem 														(pe_wmem_w_data_1_9),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_9),
		.sum_out															(part_sum_out_1_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_9),
		.write_req_w_mem													(pe_wmem_write_req_2_9),
		.ws_en																(pe_ws_en_2_9),
		.ws_mux																(pe_ws_mux_2_9),
		.reset_ws_reg 														(pe_reset_ws_reg_2_9),
		.r_addr_w_mem														(pe_wmem_r_addr_2_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_9),
		.w_data_w_mem 														(pe_wmem_w_data_2_9),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_9),
		.sum_out															(part_sum_out_2_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_9),
		.write_req_w_mem													(pe_wmem_write_req_3_9),
		.ws_en																(pe_ws_en_3_9),
		.ws_mux																(pe_ws_mux_3_9),
		.reset_ws_reg 														(pe_reset_ws_reg_3_9),
		.r_addr_w_mem														(pe_wmem_r_addr_3_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_9),
		.w_data_w_mem 														(pe_wmem_w_data_3_9),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_9),
		.sum_out															(part_sum_out_3_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_9),
		.write_req_w_mem													(pe_wmem_write_req_4_9),
		.ws_en																(pe_ws_en_4_9),
		.ws_mux																(pe_ws_mux_4_9),
		.reset_ws_reg 														(pe_reset_ws_reg_4_9),
		.r_addr_w_mem														(pe_wmem_r_addr_4_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_9),
		.w_data_w_mem 														(pe_wmem_w_data_4_9),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_9),
		.sum_out															(part_sum_out_4_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_9),
		.write_req_w_mem													(pe_wmem_write_req_5_9),
		.ws_en																(pe_ws_en_5_9),
		.ws_mux																(pe_ws_mux_5_9),
		.reset_ws_reg 														(pe_reset_ws_reg_5_9),
		.r_addr_w_mem														(pe_wmem_r_addr_5_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_9),
		.w_data_w_mem 														(pe_wmem_w_data_5_9),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_9),
		.sum_out															(part_sum_out_5_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_9),
		.write_req_w_mem													(pe_wmem_write_req_6_9),
		.ws_en																(pe_ws_en_6_9),
		.ws_mux																(pe_ws_mux_6_9),
		.reset_ws_reg 														(pe_reset_ws_reg_6_9),
		.r_addr_w_mem														(pe_wmem_r_addr_6_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_9),
		.w_data_w_mem 														(pe_wmem_w_data_6_9),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_9),
		.sum_out															(part_sum_out_6_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_9),
		.write_req_w_mem													(pe_wmem_write_req_7_9),
		.ws_en																(pe_ws_en_7_9),
		.ws_mux																(pe_ws_mux_7_9),
		.reset_ws_reg 														(pe_reset_ws_reg_7_9),
		.r_addr_w_mem														(pe_wmem_r_addr_7_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_9),
		.w_data_w_mem 														(pe_wmem_w_data_7_9),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_9),
		.sum_out															(part_sum_out_7_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_9),
		.write_req_w_mem													(pe_wmem_write_req_8_9),
		.ws_en																(pe_ws_en_8_9),
		.ws_mux																(pe_ws_mux_8_9),
		.reset_ws_reg 														(pe_reset_ws_reg_8_9),
		.r_addr_w_mem														(pe_wmem_r_addr_8_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_9),
		.w_data_w_mem 														(pe_wmem_w_data_8_9),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_9),
		.sum_out															(part_sum_out_8_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_9),
		.write_req_w_mem													(pe_wmem_write_req_9_9),
		.ws_en																(pe_ws_en_9_9),
		.ws_mux																(pe_ws_mux_9_9),
		.reset_ws_reg 														(pe_reset_ws_reg_9_9),
		.r_addr_w_mem														(pe_wmem_r_addr_9_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_9),
		.w_data_w_mem 														(pe_wmem_w_data_9_9),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_9),
		.sum_out															(part_sum_out_9_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_9),
		.write_req_w_mem													(pe_wmem_write_req_10_9),
		.ws_en																(pe_ws_en_10_9),
		.ws_mux																(pe_ws_mux_10_9),
		.reset_ws_reg 														(pe_reset_ws_reg_10_9),
		.r_addr_w_mem														(pe_wmem_r_addr_10_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_9),
		.w_data_w_mem 														(pe_wmem_w_data_10_9),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_9),
		.sum_out															(part_sum_out_10_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_9),
		.write_req_w_mem													(pe_wmem_write_req_11_9),
		.ws_en																(pe_ws_en_11_9),
		.ws_mux																(pe_ws_mux_11_9),
		.reset_ws_reg 														(pe_reset_ws_reg_11_9),
		.r_addr_w_mem														(pe_wmem_r_addr_11_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_9),
		.w_data_w_mem 														(pe_wmem_w_data_11_9),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_9),
		.sum_out															(part_sum_out_11_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_9),
		.write_req_w_mem													(pe_wmem_write_req_12_9),
		.ws_en																(pe_ws_en_12_9),
		.ws_mux																(pe_ws_mux_12_9),
		.reset_ws_reg 														(pe_reset_ws_reg_12_9),
		.r_addr_w_mem														(pe_wmem_r_addr_12_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_9),
		.w_data_w_mem 														(pe_wmem_w_data_12_9),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_9),
		.sum_out															(part_sum_out_12_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_9),
		.write_req_w_mem													(pe_wmem_write_req_13_9),
		.ws_en																(pe_ws_en_13_9),
		.ws_mux																(pe_ws_mux_13_9),
		.reset_ws_reg 														(pe_reset_ws_reg_13_9),
		.r_addr_w_mem														(pe_wmem_r_addr_13_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_9),
		.w_data_w_mem 														(pe_wmem_w_data_13_9),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_9),
		.sum_out															(part_sum_out_13_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_9),
		.write_req_w_mem													(pe_wmem_write_req_14_9),
		.ws_en																(pe_ws_en_14_9),
		.ws_mux																(pe_ws_mux_14_9),
		.reset_ws_reg 														(pe_reset_ws_reg_14_9),
		.r_addr_w_mem														(pe_wmem_r_addr_14_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_9),
		.w_data_w_mem 														(pe_wmem_w_data_14_9),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_9),
		.sum_out															(part_sum_out_14_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_9 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_9),
		.write_req_w_mem													(pe_wmem_write_req_15_9),
		.ws_en																(pe_ws_en_15_9),
		.ws_mux																(pe_ws_mux_15_9),
		.reset_ws_reg 														(pe_reset_ws_reg_15_9),
		.r_addr_w_mem														(pe_wmem_r_addr_15_9),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_9),
		.w_data_w_mem 														(pe_wmem_w_data_15_9),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_9),
		.sum_out															(part_sum_out_15_9)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_10),
		.write_req_w_mem													(pe_wmem_write_req_0_10),
		.ws_en																(pe_ws_en_0_10),
		.ws_mux																(pe_ws_mux_0_10),
		.reset_ws_reg 														(pe_reset_ws_reg_0_10),
		.r_addr_w_mem														(pe_wmem_r_addr_0_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_10),
		.w_data_w_mem 														(pe_wmem_w_data_0_10),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_10),
		.sum_out															(part_sum_out_0_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_10),
		.write_req_w_mem													(pe_wmem_write_req_1_10),
		.ws_en																(pe_ws_en_1_10),
		.ws_mux																(pe_ws_mux_1_10),
		.reset_ws_reg 														(pe_reset_ws_reg_1_10),
		.r_addr_w_mem														(pe_wmem_r_addr_1_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_10),
		.w_data_w_mem 														(pe_wmem_w_data_1_10),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_10),
		.sum_out															(part_sum_out_1_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_10),
		.write_req_w_mem													(pe_wmem_write_req_2_10),
		.ws_en																(pe_ws_en_2_10),
		.ws_mux																(pe_ws_mux_2_10),
		.reset_ws_reg 														(pe_reset_ws_reg_2_10),
		.r_addr_w_mem														(pe_wmem_r_addr_2_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_10),
		.w_data_w_mem 														(pe_wmem_w_data_2_10),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_10),
		.sum_out															(part_sum_out_2_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_10),
		.write_req_w_mem													(pe_wmem_write_req_3_10),
		.ws_en																(pe_ws_en_3_10),
		.ws_mux																(pe_ws_mux_3_10),
		.reset_ws_reg 														(pe_reset_ws_reg_3_10),
		.r_addr_w_mem														(pe_wmem_r_addr_3_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_10),
		.w_data_w_mem 														(pe_wmem_w_data_3_10),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_10),
		.sum_out															(part_sum_out_3_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_10),
		.write_req_w_mem													(pe_wmem_write_req_4_10),
		.ws_en																(pe_ws_en_4_10),
		.ws_mux																(pe_ws_mux_4_10),
		.reset_ws_reg 														(pe_reset_ws_reg_4_10),
		.r_addr_w_mem														(pe_wmem_r_addr_4_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_10),
		.w_data_w_mem 														(pe_wmem_w_data_4_10),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_10),
		.sum_out															(part_sum_out_4_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_10),
		.write_req_w_mem													(pe_wmem_write_req_5_10),
		.ws_en																(pe_ws_en_5_10),
		.ws_mux																(pe_ws_mux_5_10),
		.reset_ws_reg 														(pe_reset_ws_reg_5_10),
		.r_addr_w_mem														(pe_wmem_r_addr_5_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_10),
		.w_data_w_mem 														(pe_wmem_w_data_5_10),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_10),
		.sum_out															(part_sum_out_5_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_10),
		.write_req_w_mem													(pe_wmem_write_req_6_10),
		.ws_en																(pe_ws_en_6_10),
		.ws_mux																(pe_ws_mux_6_10),
		.reset_ws_reg 														(pe_reset_ws_reg_6_10),
		.r_addr_w_mem														(pe_wmem_r_addr_6_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_10),
		.w_data_w_mem 														(pe_wmem_w_data_6_10),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_10),
		.sum_out															(part_sum_out_6_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_10),
		.write_req_w_mem													(pe_wmem_write_req_7_10),
		.ws_en																(pe_ws_en_7_10),
		.ws_mux																(pe_ws_mux_7_10),
		.reset_ws_reg 														(pe_reset_ws_reg_7_10),
		.r_addr_w_mem														(pe_wmem_r_addr_7_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_10),
		.w_data_w_mem 														(pe_wmem_w_data_7_10),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_10),
		.sum_out															(part_sum_out_7_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_10),
		.write_req_w_mem													(pe_wmem_write_req_8_10),
		.ws_en																(pe_ws_en_8_10),
		.ws_mux																(pe_ws_mux_8_10),
		.reset_ws_reg 														(pe_reset_ws_reg_8_10),
		.r_addr_w_mem														(pe_wmem_r_addr_8_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_10),
		.w_data_w_mem 														(pe_wmem_w_data_8_10),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_10),
		.sum_out															(part_sum_out_8_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_10),
		.write_req_w_mem													(pe_wmem_write_req_9_10),
		.ws_en																(pe_ws_en_9_10),
		.ws_mux																(pe_ws_mux_9_10),
		.reset_ws_reg 														(pe_reset_ws_reg_9_10),
		.r_addr_w_mem														(pe_wmem_r_addr_9_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_10),
		.w_data_w_mem 														(pe_wmem_w_data_9_10),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_10),
		.sum_out															(part_sum_out_9_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_10),
		.write_req_w_mem													(pe_wmem_write_req_10_10),
		.ws_en																(pe_ws_en_10_10),
		.ws_mux																(pe_ws_mux_10_10),
		.reset_ws_reg 														(pe_reset_ws_reg_10_10),
		.r_addr_w_mem														(pe_wmem_r_addr_10_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_10),
		.w_data_w_mem 														(pe_wmem_w_data_10_10),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_10),
		.sum_out															(part_sum_out_10_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_10),
		.write_req_w_mem													(pe_wmem_write_req_11_10),
		.ws_en																(pe_ws_en_11_10),
		.ws_mux																(pe_ws_mux_11_10),
		.reset_ws_reg 														(pe_reset_ws_reg_11_10),
		.r_addr_w_mem														(pe_wmem_r_addr_11_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_10),
		.w_data_w_mem 														(pe_wmem_w_data_11_10),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_10),
		.sum_out															(part_sum_out_11_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_10),
		.write_req_w_mem													(pe_wmem_write_req_12_10),
		.ws_en																(pe_ws_en_12_10),
		.ws_mux																(pe_ws_mux_12_10),
		.reset_ws_reg 														(pe_reset_ws_reg_12_10),
		.r_addr_w_mem														(pe_wmem_r_addr_12_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_10),
		.w_data_w_mem 														(pe_wmem_w_data_12_10),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_10),
		.sum_out															(part_sum_out_12_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_10),
		.write_req_w_mem													(pe_wmem_write_req_13_10),
		.ws_en																(pe_ws_en_13_10),
		.ws_mux																(pe_ws_mux_13_10),
		.reset_ws_reg 														(pe_reset_ws_reg_13_10),
		.r_addr_w_mem														(pe_wmem_r_addr_13_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_10),
		.w_data_w_mem 														(pe_wmem_w_data_13_10),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_10),
		.sum_out															(part_sum_out_13_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_10),
		.write_req_w_mem													(pe_wmem_write_req_14_10),
		.ws_en																(pe_ws_en_14_10),
		.ws_mux																(pe_ws_mux_14_10),
		.reset_ws_reg 														(pe_reset_ws_reg_14_10),
		.r_addr_w_mem														(pe_wmem_r_addr_14_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_10),
		.w_data_w_mem 														(pe_wmem_w_data_14_10),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_10),
		.sum_out															(part_sum_out_14_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_10 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_10),
		.write_req_w_mem													(pe_wmem_write_req_15_10),
		.ws_en																(pe_ws_en_15_10),
		.ws_mux																(pe_ws_mux_15_10),
		.reset_ws_reg 														(pe_reset_ws_reg_15_10),
		.r_addr_w_mem														(pe_wmem_r_addr_15_10),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_10),
		.w_data_w_mem 														(pe_wmem_w_data_15_10),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_10),
		.sum_out															(part_sum_out_15_10)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_11),
		.write_req_w_mem													(pe_wmem_write_req_0_11),
		.ws_en																(pe_ws_en_0_11),
		.ws_mux																(pe_ws_mux_0_11),
		.reset_ws_reg 														(pe_reset_ws_reg_0_11),
		.r_addr_w_mem														(pe_wmem_r_addr_0_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_11),
		.w_data_w_mem 														(pe_wmem_w_data_0_11),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_11),
		.sum_out															(part_sum_out_0_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_11),
		.write_req_w_mem													(pe_wmem_write_req_1_11),
		.ws_en																(pe_ws_en_1_11),
		.ws_mux																(pe_ws_mux_1_11),
		.reset_ws_reg 														(pe_reset_ws_reg_1_11),
		.r_addr_w_mem														(pe_wmem_r_addr_1_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_11),
		.w_data_w_mem 														(pe_wmem_w_data_1_11),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_11),
		.sum_out															(part_sum_out_1_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_11),
		.write_req_w_mem													(pe_wmem_write_req_2_11),
		.ws_en																(pe_ws_en_2_11),
		.ws_mux																(pe_ws_mux_2_11),
		.reset_ws_reg 														(pe_reset_ws_reg_2_11),
		.r_addr_w_mem														(pe_wmem_r_addr_2_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_11),
		.w_data_w_mem 														(pe_wmem_w_data_2_11),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_11),
		.sum_out															(part_sum_out_2_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_11),
		.write_req_w_mem													(pe_wmem_write_req_3_11),
		.ws_en																(pe_ws_en_3_11),
		.ws_mux																(pe_ws_mux_3_11),
		.reset_ws_reg 														(pe_reset_ws_reg_3_11),
		.r_addr_w_mem														(pe_wmem_r_addr_3_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_11),
		.w_data_w_mem 														(pe_wmem_w_data_3_11),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_11),
		.sum_out															(part_sum_out_3_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_11),
		.write_req_w_mem													(pe_wmem_write_req_4_11),
		.ws_en																(pe_ws_en_4_11),
		.ws_mux																(pe_ws_mux_4_11),
		.reset_ws_reg 														(pe_reset_ws_reg_4_11),
		.r_addr_w_mem														(pe_wmem_r_addr_4_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_11),
		.w_data_w_mem 														(pe_wmem_w_data_4_11),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_11),
		.sum_out															(part_sum_out_4_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_11),
		.write_req_w_mem													(pe_wmem_write_req_5_11),
		.ws_en																(pe_ws_en_5_11),
		.ws_mux																(pe_ws_mux_5_11),
		.reset_ws_reg 														(pe_reset_ws_reg_5_11),
		.r_addr_w_mem														(pe_wmem_r_addr_5_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_11),
		.w_data_w_mem 														(pe_wmem_w_data_5_11),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_11),
		.sum_out															(part_sum_out_5_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_11),
		.write_req_w_mem													(pe_wmem_write_req_6_11),
		.ws_en																(pe_ws_en_6_11),
		.ws_mux																(pe_ws_mux_6_11),
		.reset_ws_reg 														(pe_reset_ws_reg_6_11),
		.r_addr_w_mem														(pe_wmem_r_addr_6_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_11),
		.w_data_w_mem 														(pe_wmem_w_data_6_11),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_11),
		.sum_out															(part_sum_out_6_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_11),
		.write_req_w_mem													(pe_wmem_write_req_7_11),
		.ws_en																(pe_ws_en_7_11),
		.ws_mux																(pe_ws_mux_7_11),
		.reset_ws_reg 														(pe_reset_ws_reg_7_11),
		.r_addr_w_mem														(pe_wmem_r_addr_7_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_11),
		.w_data_w_mem 														(pe_wmem_w_data_7_11),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_11),
		.sum_out															(part_sum_out_7_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_11),
		.write_req_w_mem													(pe_wmem_write_req_8_11),
		.ws_en																(pe_ws_en_8_11),
		.ws_mux																(pe_ws_mux_8_11),
		.reset_ws_reg 														(pe_reset_ws_reg_8_11),
		.r_addr_w_mem														(pe_wmem_r_addr_8_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_11),
		.w_data_w_mem 														(pe_wmem_w_data_8_11),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_11),
		.sum_out															(part_sum_out_8_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_11),
		.write_req_w_mem													(pe_wmem_write_req_9_11),
		.ws_en																(pe_ws_en_9_11),
		.ws_mux																(pe_ws_mux_9_11),
		.reset_ws_reg 														(pe_reset_ws_reg_9_11),
		.r_addr_w_mem														(pe_wmem_r_addr_9_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_11),
		.w_data_w_mem 														(pe_wmem_w_data_9_11),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_11),
		.sum_out															(part_sum_out_9_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_11),
		.write_req_w_mem													(pe_wmem_write_req_10_11),
		.ws_en																(pe_ws_en_10_11),
		.ws_mux																(pe_ws_mux_10_11),
		.reset_ws_reg 														(pe_reset_ws_reg_10_11),
		.r_addr_w_mem														(pe_wmem_r_addr_10_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_11),
		.w_data_w_mem 														(pe_wmem_w_data_10_11),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_11),
		.sum_out															(part_sum_out_10_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_11),
		.write_req_w_mem													(pe_wmem_write_req_11_11),
		.ws_en																(pe_ws_en_11_11),
		.ws_mux																(pe_ws_mux_11_11),
		.reset_ws_reg 														(pe_reset_ws_reg_11_11),
		.r_addr_w_mem														(pe_wmem_r_addr_11_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_11),
		.w_data_w_mem 														(pe_wmem_w_data_11_11),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_11),
		.sum_out															(part_sum_out_11_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_11),
		.write_req_w_mem													(pe_wmem_write_req_12_11),
		.ws_en																(pe_ws_en_12_11),
		.ws_mux																(pe_ws_mux_12_11),
		.reset_ws_reg 														(pe_reset_ws_reg_12_11),
		.r_addr_w_mem														(pe_wmem_r_addr_12_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_11),
		.w_data_w_mem 														(pe_wmem_w_data_12_11),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_11),
		.sum_out															(part_sum_out_12_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_11),
		.write_req_w_mem													(pe_wmem_write_req_13_11),
		.ws_en																(pe_ws_en_13_11),
		.ws_mux																(pe_ws_mux_13_11),
		.reset_ws_reg 														(pe_reset_ws_reg_13_11),
		.r_addr_w_mem														(pe_wmem_r_addr_13_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_11),
		.w_data_w_mem 														(pe_wmem_w_data_13_11),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_11),
		.sum_out															(part_sum_out_13_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_11),
		.write_req_w_mem													(pe_wmem_write_req_14_11),
		.ws_en																(pe_ws_en_14_11),
		.ws_mux																(pe_ws_mux_14_11),
		.reset_ws_reg 														(pe_reset_ws_reg_14_11),
		.r_addr_w_mem														(pe_wmem_r_addr_14_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_11),
		.w_data_w_mem 														(pe_wmem_w_data_14_11),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_11),
		.sum_out															(part_sum_out_14_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_11 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_11),
		.write_req_w_mem													(pe_wmem_write_req_15_11),
		.ws_en																(pe_ws_en_15_11),
		.ws_mux																(pe_ws_mux_15_11),
		.reset_ws_reg 														(pe_reset_ws_reg_15_11),
		.r_addr_w_mem														(pe_wmem_r_addr_15_11),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_11),
		.w_data_w_mem 														(pe_wmem_w_data_15_11),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_11),
		.sum_out															(part_sum_out_15_11)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_12),
		.write_req_w_mem													(pe_wmem_write_req_0_12),
		.ws_en																(pe_ws_en_0_12),
		.ws_mux																(pe_ws_mux_0_12),
		.reset_ws_reg 														(pe_reset_ws_reg_0_12),
		.r_addr_w_mem														(pe_wmem_r_addr_0_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_12),
		.w_data_w_mem 														(pe_wmem_w_data_0_12),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_12),
		.sum_out															(part_sum_out_0_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_12),
		.write_req_w_mem													(pe_wmem_write_req_1_12),
		.ws_en																(pe_ws_en_1_12),
		.ws_mux																(pe_ws_mux_1_12),
		.reset_ws_reg 														(pe_reset_ws_reg_1_12),
		.r_addr_w_mem														(pe_wmem_r_addr_1_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_12),
		.w_data_w_mem 														(pe_wmem_w_data_1_12),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_12),
		.sum_out															(part_sum_out_1_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_12),
		.write_req_w_mem													(pe_wmem_write_req_2_12),
		.ws_en																(pe_ws_en_2_12),
		.ws_mux																(pe_ws_mux_2_12),
		.reset_ws_reg 														(pe_reset_ws_reg_2_12),
		.r_addr_w_mem														(pe_wmem_r_addr_2_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_12),
		.w_data_w_mem 														(pe_wmem_w_data_2_12),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_12),
		.sum_out															(part_sum_out_2_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_12),
		.write_req_w_mem													(pe_wmem_write_req_3_12),
		.ws_en																(pe_ws_en_3_12),
		.ws_mux																(pe_ws_mux_3_12),
		.reset_ws_reg 														(pe_reset_ws_reg_3_12),
		.r_addr_w_mem														(pe_wmem_r_addr_3_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_12),
		.w_data_w_mem 														(pe_wmem_w_data_3_12),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_12),
		.sum_out															(part_sum_out_3_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_12),
		.write_req_w_mem													(pe_wmem_write_req_4_12),
		.ws_en																(pe_ws_en_4_12),
		.ws_mux																(pe_ws_mux_4_12),
		.reset_ws_reg 														(pe_reset_ws_reg_4_12),
		.r_addr_w_mem														(pe_wmem_r_addr_4_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_12),
		.w_data_w_mem 														(pe_wmem_w_data_4_12),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_12),
		.sum_out															(part_sum_out_4_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_12),
		.write_req_w_mem													(pe_wmem_write_req_5_12),
		.ws_en																(pe_ws_en_5_12),
		.ws_mux																(pe_ws_mux_5_12),
		.reset_ws_reg 														(pe_reset_ws_reg_5_12),
		.r_addr_w_mem														(pe_wmem_r_addr_5_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_12),
		.w_data_w_mem 														(pe_wmem_w_data_5_12),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_12),
		.sum_out															(part_sum_out_5_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_12),
		.write_req_w_mem													(pe_wmem_write_req_6_12),
		.ws_en																(pe_ws_en_6_12),
		.ws_mux																(pe_ws_mux_6_12),
		.reset_ws_reg 														(pe_reset_ws_reg_6_12),
		.r_addr_w_mem														(pe_wmem_r_addr_6_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_12),
		.w_data_w_mem 														(pe_wmem_w_data_6_12),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_12),
		.sum_out															(part_sum_out_6_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_12),
		.write_req_w_mem													(pe_wmem_write_req_7_12),
		.ws_en																(pe_ws_en_7_12),
		.ws_mux																(pe_ws_mux_7_12),
		.reset_ws_reg 														(pe_reset_ws_reg_7_12),
		.r_addr_w_mem														(pe_wmem_r_addr_7_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_12),
		.w_data_w_mem 														(pe_wmem_w_data_7_12),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_12),
		.sum_out															(part_sum_out_7_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_12),
		.write_req_w_mem													(pe_wmem_write_req_8_12),
		.ws_en																(pe_ws_en_8_12),
		.ws_mux																(pe_ws_mux_8_12),
		.reset_ws_reg 														(pe_reset_ws_reg_8_12),
		.r_addr_w_mem														(pe_wmem_r_addr_8_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_12),
		.w_data_w_mem 														(pe_wmem_w_data_8_12),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_12),
		.sum_out															(part_sum_out_8_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_12),
		.write_req_w_mem													(pe_wmem_write_req_9_12),
		.ws_en																(pe_ws_en_9_12),
		.ws_mux																(pe_ws_mux_9_12),
		.reset_ws_reg 														(pe_reset_ws_reg_9_12),
		.r_addr_w_mem														(pe_wmem_r_addr_9_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_12),
		.w_data_w_mem 														(pe_wmem_w_data_9_12),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_12),
		.sum_out															(part_sum_out_9_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_12),
		.write_req_w_mem													(pe_wmem_write_req_10_12),
		.ws_en																(pe_ws_en_10_12),
		.ws_mux																(pe_ws_mux_10_12),
		.reset_ws_reg 														(pe_reset_ws_reg_10_12),
		.r_addr_w_mem														(pe_wmem_r_addr_10_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_12),
		.w_data_w_mem 														(pe_wmem_w_data_10_12),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_12),
		.sum_out															(part_sum_out_10_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_12),
		.write_req_w_mem													(pe_wmem_write_req_11_12),
		.ws_en																(pe_ws_en_11_12),
		.ws_mux																(pe_ws_mux_11_12),
		.reset_ws_reg 														(pe_reset_ws_reg_11_12),
		.r_addr_w_mem														(pe_wmem_r_addr_11_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_12),
		.w_data_w_mem 														(pe_wmem_w_data_11_12),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_12),
		.sum_out															(part_sum_out_11_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_12),
		.write_req_w_mem													(pe_wmem_write_req_12_12),
		.ws_en																(pe_ws_en_12_12),
		.ws_mux																(pe_ws_mux_12_12),
		.reset_ws_reg 														(pe_reset_ws_reg_12_12),
		.r_addr_w_mem														(pe_wmem_r_addr_12_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_12),
		.w_data_w_mem 														(pe_wmem_w_data_12_12),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_12),
		.sum_out															(part_sum_out_12_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_12),
		.write_req_w_mem													(pe_wmem_write_req_13_12),
		.ws_en																(pe_ws_en_13_12),
		.ws_mux																(pe_ws_mux_13_12),
		.reset_ws_reg 														(pe_reset_ws_reg_13_12),
		.r_addr_w_mem														(pe_wmem_r_addr_13_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_12),
		.w_data_w_mem 														(pe_wmem_w_data_13_12),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_12),
		.sum_out															(part_sum_out_13_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_12),
		.write_req_w_mem													(pe_wmem_write_req_14_12),
		.ws_en																(pe_ws_en_14_12),
		.ws_mux																(pe_ws_mux_14_12),
		.reset_ws_reg 														(pe_reset_ws_reg_14_12),
		.r_addr_w_mem														(pe_wmem_r_addr_14_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_12),
		.w_data_w_mem 														(pe_wmem_w_data_14_12),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_12),
		.sum_out															(part_sum_out_14_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_12 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_12),
		.write_req_w_mem													(pe_wmem_write_req_15_12),
		.ws_en																(pe_ws_en_15_12),
		.ws_mux																(pe_ws_mux_15_12),
		.reset_ws_reg 														(pe_reset_ws_reg_15_12),
		.r_addr_w_mem														(pe_wmem_r_addr_15_12),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_12),
		.w_data_w_mem 														(pe_wmem_w_data_15_12),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_12),
		.sum_out															(part_sum_out_15_12)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_13),
		.write_req_w_mem													(pe_wmem_write_req_0_13),
		.ws_en																(pe_ws_en_0_13),
		.ws_mux																(pe_ws_mux_0_13),
		.reset_ws_reg 														(pe_reset_ws_reg_0_13),
		.r_addr_w_mem														(pe_wmem_r_addr_0_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_13),
		.w_data_w_mem 														(pe_wmem_w_data_0_13),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_13),
		.sum_out															(part_sum_out_0_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_13),
		.write_req_w_mem													(pe_wmem_write_req_1_13),
		.ws_en																(pe_ws_en_1_13),
		.ws_mux																(pe_ws_mux_1_13),
		.reset_ws_reg 														(pe_reset_ws_reg_1_13),
		.r_addr_w_mem														(pe_wmem_r_addr_1_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_13),
		.w_data_w_mem 														(pe_wmem_w_data_1_13),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_13),
		.sum_out															(part_sum_out_1_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_13),
		.write_req_w_mem													(pe_wmem_write_req_2_13),
		.ws_en																(pe_ws_en_2_13),
		.ws_mux																(pe_ws_mux_2_13),
		.reset_ws_reg 														(pe_reset_ws_reg_2_13),
		.r_addr_w_mem														(pe_wmem_r_addr_2_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_13),
		.w_data_w_mem 														(pe_wmem_w_data_2_13),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_13),
		.sum_out															(part_sum_out_2_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_13),
		.write_req_w_mem													(pe_wmem_write_req_3_13),
		.ws_en																(pe_ws_en_3_13),
		.ws_mux																(pe_ws_mux_3_13),
		.reset_ws_reg 														(pe_reset_ws_reg_3_13),
		.r_addr_w_mem														(pe_wmem_r_addr_3_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_13),
		.w_data_w_mem 														(pe_wmem_w_data_3_13),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_13),
		.sum_out															(part_sum_out_3_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_13),
		.write_req_w_mem													(pe_wmem_write_req_4_13),
		.ws_en																(pe_ws_en_4_13),
		.ws_mux																(pe_ws_mux_4_13),
		.reset_ws_reg 														(pe_reset_ws_reg_4_13),
		.r_addr_w_mem														(pe_wmem_r_addr_4_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_13),
		.w_data_w_mem 														(pe_wmem_w_data_4_13),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_13),
		.sum_out															(part_sum_out_4_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_13),
		.write_req_w_mem													(pe_wmem_write_req_5_13),
		.ws_en																(pe_ws_en_5_13),
		.ws_mux																(pe_ws_mux_5_13),
		.reset_ws_reg 														(pe_reset_ws_reg_5_13),
		.r_addr_w_mem														(pe_wmem_r_addr_5_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_13),
		.w_data_w_mem 														(pe_wmem_w_data_5_13),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_13),
		.sum_out															(part_sum_out_5_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_13),
		.write_req_w_mem													(pe_wmem_write_req_6_13),
		.ws_en																(pe_ws_en_6_13),
		.ws_mux																(pe_ws_mux_6_13),
		.reset_ws_reg 														(pe_reset_ws_reg_6_13),
		.r_addr_w_mem														(pe_wmem_r_addr_6_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_13),
		.w_data_w_mem 														(pe_wmem_w_data_6_13),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_13),
		.sum_out															(part_sum_out_6_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_13),
		.write_req_w_mem													(pe_wmem_write_req_7_13),
		.ws_en																(pe_ws_en_7_13),
		.ws_mux																(pe_ws_mux_7_13),
		.reset_ws_reg 														(pe_reset_ws_reg_7_13),
		.r_addr_w_mem														(pe_wmem_r_addr_7_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_13),
		.w_data_w_mem 														(pe_wmem_w_data_7_13),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_13),
		.sum_out															(part_sum_out_7_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_13),
		.write_req_w_mem													(pe_wmem_write_req_8_13),
		.ws_en																(pe_ws_en_8_13),
		.ws_mux																(pe_ws_mux_8_13),
		.reset_ws_reg 														(pe_reset_ws_reg_8_13),
		.r_addr_w_mem														(pe_wmem_r_addr_8_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_13),
		.w_data_w_mem 														(pe_wmem_w_data_8_13),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_13),
		.sum_out															(part_sum_out_8_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_13),
		.write_req_w_mem													(pe_wmem_write_req_9_13),
		.ws_en																(pe_ws_en_9_13),
		.ws_mux																(pe_ws_mux_9_13),
		.reset_ws_reg 														(pe_reset_ws_reg_9_13),
		.r_addr_w_mem														(pe_wmem_r_addr_9_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_13),
		.w_data_w_mem 														(pe_wmem_w_data_9_13),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_13),
		.sum_out															(part_sum_out_9_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_13),
		.write_req_w_mem													(pe_wmem_write_req_10_13),
		.ws_en																(pe_ws_en_10_13),
		.ws_mux																(pe_ws_mux_10_13),
		.reset_ws_reg 														(pe_reset_ws_reg_10_13),
		.r_addr_w_mem														(pe_wmem_r_addr_10_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_13),
		.w_data_w_mem 														(pe_wmem_w_data_10_13),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_13),
		.sum_out															(part_sum_out_10_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_13),
		.write_req_w_mem													(pe_wmem_write_req_11_13),
		.ws_en																(pe_ws_en_11_13),
		.ws_mux																(pe_ws_mux_11_13),
		.reset_ws_reg 														(pe_reset_ws_reg_11_13),
		.r_addr_w_mem														(pe_wmem_r_addr_11_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_13),
		.w_data_w_mem 														(pe_wmem_w_data_11_13),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_13),
		.sum_out															(part_sum_out_11_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_13),
		.write_req_w_mem													(pe_wmem_write_req_12_13),
		.ws_en																(pe_ws_en_12_13),
		.ws_mux																(pe_ws_mux_12_13),
		.reset_ws_reg 														(pe_reset_ws_reg_12_13),
		.r_addr_w_mem														(pe_wmem_r_addr_12_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_13),
		.w_data_w_mem 														(pe_wmem_w_data_12_13),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_13),
		.sum_out															(part_sum_out_12_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_13),
		.write_req_w_mem													(pe_wmem_write_req_13_13),
		.ws_en																(pe_ws_en_13_13),
		.ws_mux																(pe_ws_mux_13_13),
		.reset_ws_reg 														(pe_reset_ws_reg_13_13),
		.r_addr_w_mem														(pe_wmem_r_addr_13_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_13),
		.w_data_w_mem 														(pe_wmem_w_data_13_13),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_13),
		.sum_out															(part_sum_out_13_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_13),
		.write_req_w_mem													(pe_wmem_write_req_14_13),
		.ws_en																(pe_ws_en_14_13),
		.ws_mux																(pe_ws_mux_14_13),
		.reset_ws_reg 														(pe_reset_ws_reg_14_13),
		.r_addr_w_mem														(pe_wmem_r_addr_14_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_13),
		.w_data_w_mem 														(pe_wmem_w_data_14_13),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_13),
		.sum_out															(part_sum_out_14_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_13 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_13),
		.write_req_w_mem													(pe_wmem_write_req_15_13),
		.ws_en																(pe_ws_en_15_13),
		.ws_mux																(pe_ws_mux_15_13),
		.reset_ws_reg 														(pe_reset_ws_reg_15_13),
		.r_addr_w_mem														(pe_wmem_r_addr_15_13),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_13),
		.w_data_w_mem 														(pe_wmem_w_data_15_13),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_13),
		.sum_out															(part_sum_out_15_13)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_14),
		.write_req_w_mem													(pe_wmem_write_req_0_14),
		.ws_en																(pe_ws_en_0_14),
		.ws_mux																(pe_ws_mux_0_14),
		.reset_ws_reg 														(pe_reset_ws_reg_0_14),
		.r_addr_w_mem														(pe_wmem_r_addr_0_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_14),
		.w_data_w_mem 														(pe_wmem_w_data_0_14),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_14),
		.sum_out															(part_sum_out_0_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_14),
		.write_req_w_mem													(pe_wmem_write_req_1_14),
		.ws_en																(pe_ws_en_1_14),
		.ws_mux																(pe_ws_mux_1_14),
		.reset_ws_reg 														(pe_reset_ws_reg_1_14),
		.r_addr_w_mem														(pe_wmem_r_addr_1_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_14),
		.w_data_w_mem 														(pe_wmem_w_data_1_14),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_14),
		.sum_out															(part_sum_out_1_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_14),
		.write_req_w_mem													(pe_wmem_write_req_2_14),
		.ws_en																(pe_ws_en_2_14),
		.ws_mux																(pe_ws_mux_2_14),
		.reset_ws_reg 														(pe_reset_ws_reg_2_14),
		.r_addr_w_mem														(pe_wmem_r_addr_2_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_14),
		.w_data_w_mem 														(pe_wmem_w_data_2_14),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_14),
		.sum_out															(part_sum_out_2_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_14),
		.write_req_w_mem													(pe_wmem_write_req_3_14),
		.ws_en																(pe_ws_en_3_14),
		.ws_mux																(pe_ws_mux_3_14),
		.reset_ws_reg 														(pe_reset_ws_reg_3_14),
		.r_addr_w_mem														(pe_wmem_r_addr_3_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_14),
		.w_data_w_mem 														(pe_wmem_w_data_3_14),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_14),
		.sum_out															(part_sum_out_3_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_14),
		.write_req_w_mem													(pe_wmem_write_req_4_14),
		.ws_en																(pe_ws_en_4_14),
		.ws_mux																(pe_ws_mux_4_14),
		.reset_ws_reg 														(pe_reset_ws_reg_4_14),
		.r_addr_w_mem														(pe_wmem_r_addr_4_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_14),
		.w_data_w_mem 														(pe_wmem_w_data_4_14),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_14),
		.sum_out															(part_sum_out_4_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_14),
		.write_req_w_mem													(pe_wmem_write_req_5_14),
		.ws_en																(pe_ws_en_5_14),
		.ws_mux																(pe_ws_mux_5_14),
		.reset_ws_reg 														(pe_reset_ws_reg_5_14),
		.r_addr_w_mem														(pe_wmem_r_addr_5_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_14),
		.w_data_w_mem 														(pe_wmem_w_data_5_14),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_14),
		.sum_out															(part_sum_out_5_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_14),
		.write_req_w_mem													(pe_wmem_write_req_6_14),
		.ws_en																(pe_ws_en_6_14),
		.ws_mux																(pe_ws_mux_6_14),
		.reset_ws_reg 														(pe_reset_ws_reg_6_14),
		.r_addr_w_mem														(pe_wmem_r_addr_6_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_14),
		.w_data_w_mem 														(pe_wmem_w_data_6_14),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_14),
		.sum_out															(part_sum_out_6_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_14),
		.write_req_w_mem													(pe_wmem_write_req_7_14),
		.ws_en																(pe_ws_en_7_14),
		.ws_mux																(pe_ws_mux_7_14),
		.reset_ws_reg 														(pe_reset_ws_reg_7_14),
		.r_addr_w_mem														(pe_wmem_r_addr_7_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_14),
		.w_data_w_mem 														(pe_wmem_w_data_7_14),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_14),
		.sum_out															(part_sum_out_7_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_14),
		.write_req_w_mem													(pe_wmem_write_req_8_14),
		.ws_en																(pe_ws_en_8_14),
		.ws_mux																(pe_ws_mux_8_14),
		.reset_ws_reg 														(pe_reset_ws_reg_8_14),
		.r_addr_w_mem														(pe_wmem_r_addr_8_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_14),
		.w_data_w_mem 														(pe_wmem_w_data_8_14),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_14),
		.sum_out															(part_sum_out_8_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_14),
		.write_req_w_mem													(pe_wmem_write_req_9_14),
		.ws_en																(pe_ws_en_9_14),
		.ws_mux																(pe_ws_mux_9_14),
		.reset_ws_reg 														(pe_reset_ws_reg_9_14),
		.r_addr_w_mem														(pe_wmem_r_addr_9_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_14),
		.w_data_w_mem 														(pe_wmem_w_data_9_14),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_14),
		.sum_out															(part_sum_out_9_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_14),
		.write_req_w_mem													(pe_wmem_write_req_10_14),
		.ws_en																(pe_ws_en_10_14),
		.ws_mux																(pe_ws_mux_10_14),
		.reset_ws_reg 														(pe_reset_ws_reg_10_14),
		.r_addr_w_mem														(pe_wmem_r_addr_10_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_14),
		.w_data_w_mem 														(pe_wmem_w_data_10_14),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_14),
		.sum_out															(part_sum_out_10_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_14),
		.write_req_w_mem													(pe_wmem_write_req_11_14),
		.ws_en																(pe_ws_en_11_14),
		.ws_mux																(pe_ws_mux_11_14),
		.reset_ws_reg 														(pe_reset_ws_reg_11_14),
		.r_addr_w_mem														(pe_wmem_r_addr_11_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_14),
		.w_data_w_mem 														(pe_wmem_w_data_11_14),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_14),
		.sum_out															(part_sum_out_11_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_14),
		.write_req_w_mem													(pe_wmem_write_req_12_14),
		.ws_en																(pe_ws_en_12_14),
		.ws_mux																(pe_ws_mux_12_14),
		.reset_ws_reg 														(pe_reset_ws_reg_12_14),
		.r_addr_w_mem														(pe_wmem_r_addr_12_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_14),
		.w_data_w_mem 														(pe_wmem_w_data_12_14),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_14),
		.sum_out															(part_sum_out_12_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_14),
		.write_req_w_mem													(pe_wmem_write_req_13_14),
		.ws_en																(pe_ws_en_13_14),
		.ws_mux																(pe_ws_mux_13_14),
		.reset_ws_reg 														(pe_reset_ws_reg_13_14),
		.r_addr_w_mem														(pe_wmem_r_addr_13_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_14),
		.w_data_w_mem 														(pe_wmem_w_data_13_14),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_14),
		.sum_out															(part_sum_out_13_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_14),
		.write_req_w_mem													(pe_wmem_write_req_14_14),
		.ws_en																(pe_ws_en_14_14),
		.ws_mux																(pe_ws_mux_14_14),
		.reset_ws_reg 														(pe_reset_ws_reg_14_14),
		.r_addr_w_mem														(pe_wmem_r_addr_14_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_14),
		.w_data_w_mem 														(pe_wmem_w_data_14_14),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_14),
		.sum_out															(part_sum_out_14_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_14 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_14),
		.write_req_w_mem													(pe_wmem_write_req_15_14),
		.ws_en																(pe_ws_en_15_14),
		.ws_mux																(pe_ws_mux_15_14),
		.reset_ws_reg 														(pe_reset_ws_reg_15_14),
		.r_addr_w_mem														(pe_wmem_r_addr_15_14),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_14),
		.w_data_w_mem 														(pe_wmem_w_data_15_14),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_14),
		.sum_out															(part_sum_out_15_14)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_0_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_0_15),
		.write_req_w_mem													(pe_wmem_write_req_0_15),
		.ws_en																(pe_ws_en_0_15),
		.ws_mux																(pe_ws_mux_0_15),
		.reset_ws_reg 														(pe_reset_ws_reg_0_15),
		.r_addr_w_mem														(pe_wmem_r_addr_0_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_0_15),
		.w_data_w_mem 														(pe_wmem_w_data_0_15),
		.act_in 															(act_in_row_0),
		.sum_in																(part_sum_in_0_15),
		.sum_out															(part_sum_out_0_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_1_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_1_15),
		.write_req_w_mem													(pe_wmem_write_req_1_15),
		.ws_en																(pe_ws_en_1_15),
		.ws_mux																(pe_ws_mux_1_15),
		.reset_ws_reg 														(pe_reset_ws_reg_1_15),
		.r_addr_w_mem														(pe_wmem_r_addr_1_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_1_15),
		.w_data_w_mem 														(pe_wmem_w_data_1_15),
		.act_in 															(act_in_row_1),
		.sum_in																(part_sum_in_1_15),
		.sum_out															(part_sum_out_1_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_2_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_2_15),
		.write_req_w_mem													(pe_wmem_write_req_2_15),
		.ws_en																(pe_ws_en_2_15),
		.ws_mux																(pe_ws_mux_2_15),
		.reset_ws_reg 														(pe_reset_ws_reg_2_15),
		.r_addr_w_mem														(pe_wmem_r_addr_2_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_2_15),
		.w_data_w_mem 														(pe_wmem_w_data_2_15),
		.act_in 															(act_in_row_2),
		.sum_in																(part_sum_in_2_15),
		.sum_out															(part_sum_out_2_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_3_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_3_15),
		.write_req_w_mem													(pe_wmem_write_req_3_15),
		.ws_en																(pe_ws_en_3_15),
		.ws_mux																(pe_ws_mux_3_15),
		.reset_ws_reg 														(pe_reset_ws_reg_3_15),
		.r_addr_w_mem														(pe_wmem_r_addr_3_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_3_15),
		.w_data_w_mem 														(pe_wmem_w_data_3_15),
		.act_in 															(act_in_row_3),
		.sum_in																(part_sum_in_3_15),
		.sum_out															(part_sum_out_3_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_4_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_4_15),
		.write_req_w_mem													(pe_wmem_write_req_4_15),
		.ws_en																(pe_ws_en_4_15),
		.ws_mux																(pe_ws_mux_4_15),
		.reset_ws_reg 														(pe_reset_ws_reg_4_15),
		.r_addr_w_mem														(pe_wmem_r_addr_4_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_4_15),
		.w_data_w_mem 														(pe_wmem_w_data_4_15),
		.act_in 															(act_in_row_4),
		.sum_in																(part_sum_in_4_15),
		.sum_out															(part_sum_out_4_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_5_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_5_15),
		.write_req_w_mem													(pe_wmem_write_req_5_15),
		.ws_en																(pe_ws_en_5_15),
		.ws_mux																(pe_ws_mux_5_15),
		.reset_ws_reg 														(pe_reset_ws_reg_5_15),
		.r_addr_w_mem														(pe_wmem_r_addr_5_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_5_15),
		.w_data_w_mem 														(pe_wmem_w_data_5_15),
		.act_in 															(act_in_row_5),
		.sum_in																(part_sum_in_5_15),
		.sum_out															(part_sum_out_5_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_6_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_6_15),
		.write_req_w_mem													(pe_wmem_write_req_6_15),
		.ws_en																(pe_ws_en_6_15),
		.ws_mux																(pe_ws_mux_6_15),
		.reset_ws_reg 														(pe_reset_ws_reg_6_15),
		.r_addr_w_mem														(pe_wmem_r_addr_6_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_6_15),
		.w_data_w_mem 														(pe_wmem_w_data_6_15),
		.act_in 															(act_in_row_6),
		.sum_in																(part_sum_in_6_15),
		.sum_out															(part_sum_out_6_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_7_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_7_15),
		.write_req_w_mem													(pe_wmem_write_req_7_15),
		.ws_en																(pe_ws_en_7_15),
		.ws_mux																(pe_ws_mux_7_15),
		.reset_ws_reg 														(pe_reset_ws_reg_7_15),
		.r_addr_w_mem														(pe_wmem_r_addr_7_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_7_15),
		.w_data_w_mem 														(pe_wmem_w_data_7_15),
		.act_in 															(act_in_row_7),
		.sum_in																(part_sum_in_7_15),
		.sum_out															(part_sum_out_7_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_8_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_8_15),
		.write_req_w_mem													(pe_wmem_write_req_8_15),
		.ws_en																(pe_ws_en_8_15),
		.ws_mux																(pe_ws_mux_8_15),
		.reset_ws_reg 														(pe_reset_ws_reg_8_15),
		.r_addr_w_mem														(pe_wmem_r_addr_8_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_8_15),
		.w_data_w_mem 														(pe_wmem_w_data_8_15),
		.act_in 															(act_in_row_8),
		.sum_in																(part_sum_in_8_15),
		.sum_out															(part_sum_out_8_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_9_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_9_15),
		.write_req_w_mem													(pe_wmem_write_req_9_15),
		.ws_en																(pe_ws_en_9_15),
		.ws_mux																(pe_ws_mux_9_15),
		.reset_ws_reg 														(pe_reset_ws_reg_9_15),
		.r_addr_w_mem														(pe_wmem_r_addr_9_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_9_15),
		.w_data_w_mem 														(pe_wmem_w_data_9_15),
		.act_in 															(act_in_row_9),
		.sum_in																(part_sum_in_9_15),
		.sum_out															(part_sum_out_9_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_10_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_10_15),
		.write_req_w_mem													(pe_wmem_write_req_10_15),
		.ws_en																(pe_ws_en_10_15),
		.ws_mux																(pe_ws_mux_10_15),
		.reset_ws_reg 														(pe_reset_ws_reg_10_15),
		.r_addr_w_mem														(pe_wmem_r_addr_10_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_10_15),
		.w_data_w_mem 														(pe_wmem_w_data_10_15),
		.act_in 															(act_in_row_10),
		.sum_in																(part_sum_in_10_15),
		.sum_out															(part_sum_out_10_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_11_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_11_15),
		.write_req_w_mem													(pe_wmem_write_req_11_15),
		.ws_en																(pe_ws_en_11_15),
		.ws_mux																(pe_ws_mux_11_15),
		.reset_ws_reg 														(pe_reset_ws_reg_11_15),
		.r_addr_w_mem														(pe_wmem_r_addr_11_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_11_15),
		.w_data_w_mem 														(pe_wmem_w_data_11_15),
		.act_in 															(act_in_row_11),
		.sum_in																(part_sum_in_11_15),
		.sum_out															(part_sum_out_11_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_12_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_12_15),
		.write_req_w_mem													(pe_wmem_write_req_12_15),
		.ws_en																(pe_ws_en_12_15),
		.ws_mux																(pe_ws_mux_12_15),
		.reset_ws_reg 														(pe_reset_ws_reg_12_15),
		.r_addr_w_mem														(pe_wmem_r_addr_12_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_12_15),
		.w_data_w_mem 														(pe_wmem_w_data_12_15),
		.act_in 															(act_in_row_12),
		.sum_in																(part_sum_in_12_15),
		.sum_out															(part_sum_out_12_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_13_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_13_15),
		.write_req_w_mem													(pe_wmem_write_req_13_15),
		.ws_en																(pe_ws_en_13_15),
		.ws_mux																(pe_ws_mux_13_15),
		.reset_ws_reg 														(pe_reset_ws_reg_13_15),
		.r_addr_w_mem														(pe_wmem_r_addr_13_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_13_15),
		.w_data_w_mem 														(pe_wmem_w_data_13_15),
		.act_in 															(act_in_row_13),
		.sum_in																(part_sum_in_13_15),
		.sum_out															(part_sum_out_13_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_14_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_14_15),
		.write_req_w_mem													(pe_wmem_write_req_14_15),
		.ws_en																(pe_ws_en_14_15),
		.ws_mux																(pe_ws_mux_14_15),
		.reset_ws_reg 														(pe_reset_ws_reg_14_15),
		.r_addr_w_mem														(pe_wmem_r_addr_14_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_14_15),
		.w_data_w_mem 														(pe_wmem_w_data_14_15),
		.act_in 															(act_in_row_14),
		.sum_in																(part_sum_in_14_15),
		.sum_out															(part_sum_out_14_15)
	);
	pe #(
		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
		.ACT_BITWIDTH														(ACT_BITWIDTH),
		.WGT_BITWIDTH 														(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
	) pe_15_15 (
		.clk																(clk),
		.reset_reg															(reset_pe_reg),
		.wrt_en_reg															(pe_wrt_en_reg),
		.reset_w_mem 														(pe_wmem_reset),
		.read_req_w_mem														(pe_wmem_read_req_15_15),
		.write_req_w_mem													(pe_wmem_write_req_15_15),
		.ws_en																(pe_ws_en_15_15),
		.ws_mux																(pe_ws_mux_15_15),
		.reset_ws_reg 														(pe_reset_ws_reg_15_15),
		.r_addr_w_mem														(pe_wmem_r_addr_15_15),
		.w_addr_w_mem 														(pe_wmem_w_addr_15_15),
		.w_data_w_mem 														(pe_wmem_w_data_15_15),
		.act_in 															(act_in_row_15),
		.sum_in																(part_sum_in_15_15),
		.sum_out															(part_sum_out_15_15)
	);
//
//
	assign						part_sum_in_1_0 	=	part_sum_out_0_0;
	assign						part_sum_in_2_0 	=	part_sum_out_1_0;
	assign						part_sum_in_3_0 	=	part_sum_out_2_0;
	assign						part_sum_in_4_0 	=	part_sum_out_3_0;
	assign						part_sum_in_5_0 	=	part_sum_out_4_0;
	assign						part_sum_in_6_0 	=	part_sum_out_5_0;
	assign						part_sum_in_7_0 	=	part_sum_out_6_0;
	assign						part_sum_in_8_0 	=	part_sum_out_7_0;
	assign						part_sum_in_9_0 	=	part_sum_out_8_0;
	assign						part_sum_in_10_0 	=	part_sum_out_9_0;
	assign						part_sum_in_11_0 	=	part_sum_out_10_0;
	assign						part_sum_in_12_0 	=	part_sum_out_11_0;
	assign						part_sum_in_13_0 	=	part_sum_out_12_0;
	assign						part_sum_in_14_0 	=	part_sum_out_13_0;
	assign						part_sum_in_15_0 	=	part_sum_out_14_0;
	assign						part_sum_in_1_1 	=	part_sum_out_0_1;
	assign						part_sum_in_2_1 	=	part_sum_out_1_1;
	assign						part_sum_in_3_1 	=	part_sum_out_2_1;
	assign						part_sum_in_4_1 	=	part_sum_out_3_1;
	assign						part_sum_in_5_1 	=	part_sum_out_4_1;
	assign						part_sum_in_6_1 	=	part_sum_out_5_1;
	assign						part_sum_in_7_1 	=	part_sum_out_6_1;
	assign						part_sum_in_8_1 	=	part_sum_out_7_1;
	assign						part_sum_in_9_1 	=	part_sum_out_8_1;
	assign						part_sum_in_10_1 	=	part_sum_out_9_1;
	assign						part_sum_in_11_1 	=	part_sum_out_10_1;
	assign						part_sum_in_12_1 	=	part_sum_out_11_1;
	assign						part_sum_in_13_1 	=	part_sum_out_12_1;
	assign						part_sum_in_14_1 	=	part_sum_out_13_1;
	assign						part_sum_in_15_1 	=	part_sum_out_14_1;
	assign						part_sum_in_1_2 	=	part_sum_out_0_2;
	assign						part_sum_in_2_2 	=	part_sum_out_1_2;
	assign						part_sum_in_3_2 	=	part_sum_out_2_2;
	assign						part_sum_in_4_2 	=	part_sum_out_3_2;
	assign						part_sum_in_5_2 	=	part_sum_out_4_2;
	assign						part_sum_in_6_2 	=	part_sum_out_5_2;
	assign						part_sum_in_7_2 	=	part_sum_out_6_2;
	assign						part_sum_in_8_2 	=	part_sum_out_7_2;
	assign						part_sum_in_9_2 	=	part_sum_out_8_2;
	assign						part_sum_in_10_2 	=	part_sum_out_9_2;
	assign						part_sum_in_11_2 	=	part_sum_out_10_2;
	assign						part_sum_in_12_2 	=	part_sum_out_11_2;
	assign						part_sum_in_13_2 	=	part_sum_out_12_2;
	assign						part_sum_in_14_2 	=	part_sum_out_13_2;
	assign						part_sum_in_15_2 	=	part_sum_out_14_2;
	assign						part_sum_in_1_3 	=	part_sum_out_0_3;
	assign						part_sum_in_2_3 	=	part_sum_out_1_3;
	assign						part_sum_in_3_3 	=	part_sum_out_2_3;
	assign						part_sum_in_4_3 	=	part_sum_out_3_3;
	assign						part_sum_in_5_3 	=	part_sum_out_4_3;
	assign						part_sum_in_6_3 	=	part_sum_out_5_3;
	assign						part_sum_in_7_3 	=	part_sum_out_6_3;
	assign						part_sum_in_8_3 	=	part_sum_out_7_3;
	assign						part_sum_in_9_3 	=	part_sum_out_8_3;
	assign						part_sum_in_10_3 	=	part_sum_out_9_3;
	assign						part_sum_in_11_3 	=	part_sum_out_10_3;
	assign						part_sum_in_12_3 	=	part_sum_out_11_3;
	assign						part_sum_in_13_3 	=	part_sum_out_12_3;
	assign						part_sum_in_14_3 	=	part_sum_out_13_3;
	assign						part_sum_in_15_3 	=	part_sum_out_14_3;
	assign						part_sum_in_1_4 	=	part_sum_out_0_4;
	assign						part_sum_in_2_4 	=	part_sum_out_1_4;
	assign						part_sum_in_3_4 	=	part_sum_out_2_4;
	assign						part_sum_in_4_4 	=	part_sum_out_3_4;
	assign						part_sum_in_5_4 	=	part_sum_out_4_4;
	assign						part_sum_in_6_4 	=	part_sum_out_5_4;
	assign						part_sum_in_7_4 	=	part_sum_out_6_4;
	assign						part_sum_in_8_4 	=	part_sum_out_7_4;
	assign						part_sum_in_9_4 	=	part_sum_out_8_4;
	assign						part_sum_in_10_4 	=	part_sum_out_9_4;
	assign						part_sum_in_11_4 	=	part_sum_out_10_4;
	assign						part_sum_in_12_4 	=	part_sum_out_11_4;
	assign						part_sum_in_13_4 	=	part_sum_out_12_4;
	assign						part_sum_in_14_4 	=	part_sum_out_13_4;
	assign						part_sum_in_15_4 	=	part_sum_out_14_4;
	assign						part_sum_in_1_5 	=	part_sum_out_0_5;
	assign						part_sum_in_2_5 	=	part_sum_out_1_5;
	assign						part_sum_in_3_5 	=	part_sum_out_2_5;
	assign						part_sum_in_4_5 	=	part_sum_out_3_5;
	assign						part_sum_in_5_5 	=	part_sum_out_4_5;
	assign						part_sum_in_6_5 	=	part_sum_out_5_5;
	assign						part_sum_in_7_5 	=	part_sum_out_6_5;
	assign						part_sum_in_8_5 	=	part_sum_out_7_5;
	assign						part_sum_in_9_5 	=	part_sum_out_8_5;
	assign						part_sum_in_10_5 	=	part_sum_out_9_5;
	assign						part_sum_in_11_5 	=	part_sum_out_10_5;
	assign						part_sum_in_12_5 	=	part_sum_out_11_5;
	assign						part_sum_in_13_5 	=	part_sum_out_12_5;
	assign						part_sum_in_14_5 	=	part_sum_out_13_5;
	assign						part_sum_in_15_5 	=	part_sum_out_14_5;
	assign						part_sum_in_1_6 	=	part_sum_out_0_6;
	assign						part_sum_in_2_6 	=	part_sum_out_1_6;
	assign						part_sum_in_3_6 	=	part_sum_out_2_6;
	assign						part_sum_in_4_6 	=	part_sum_out_3_6;
	assign						part_sum_in_5_6 	=	part_sum_out_4_6;
	assign						part_sum_in_6_6 	=	part_sum_out_5_6;
	assign						part_sum_in_7_6 	=	part_sum_out_6_6;
	assign						part_sum_in_8_6 	=	part_sum_out_7_6;
	assign						part_sum_in_9_6 	=	part_sum_out_8_6;
	assign						part_sum_in_10_6 	=	part_sum_out_9_6;
	assign						part_sum_in_11_6 	=	part_sum_out_10_6;
	assign						part_sum_in_12_6 	=	part_sum_out_11_6;
	assign						part_sum_in_13_6 	=	part_sum_out_12_6;
	assign						part_sum_in_14_6 	=	part_sum_out_13_6;
	assign						part_sum_in_15_6 	=	part_sum_out_14_6;
	assign						part_sum_in_1_7 	=	part_sum_out_0_7;
	assign						part_sum_in_2_7 	=	part_sum_out_1_7;
	assign						part_sum_in_3_7 	=	part_sum_out_2_7;
	assign						part_sum_in_4_7 	=	part_sum_out_3_7;
	assign						part_sum_in_5_7 	=	part_sum_out_4_7;
	assign						part_sum_in_6_7 	=	part_sum_out_5_7;
	assign						part_sum_in_7_7 	=	part_sum_out_6_7;
	assign						part_sum_in_8_7 	=	part_sum_out_7_7;
	assign						part_sum_in_9_7 	=	part_sum_out_8_7;
	assign						part_sum_in_10_7 	=	part_sum_out_9_7;
	assign						part_sum_in_11_7 	=	part_sum_out_10_7;
	assign						part_sum_in_12_7 	=	part_sum_out_11_7;
	assign						part_sum_in_13_7 	=	part_sum_out_12_7;
	assign						part_sum_in_14_7 	=	part_sum_out_13_7;
	assign						part_sum_in_15_7 	=	part_sum_out_14_7;
	assign						part_sum_in_1_8 	=	part_sum_out_0_8;
	assign						part_sum_in_2_8 	=	part_sum_out_1_8;
	assign						part_sum_in_3_8 	=	part_sum_out_2_8;
	assign						part_sum_in_4_8 	=	part_sum_out_3_8;
	assign						part_sum_in_5_8 	=	part_sum_out_4_8;
	assign						part_sum_in_6_8 	=	part_sum_out_5_8;
	assign						part_sum_in_7_8 	=	part_sum_out_6_8;
	assign						part_sum_in_8_8 	=	part_sum_out_7_8;
	assign						part_sum_in_9_8 	=	part_sum_out_8_8;
	assign						part_sum_in_10_8 	=	part_sum_out_9_8;
	assign						part_sum_in_11_8 	=	part_sum_out_10_8;
	assign						part_sum_in_12_8 	=	part_sum_out_11_8;
	assign						part_sum_in_13_8 	=	part_sum_out_12_8;
	assign						part_sum_in_14_8 	=	part_sum_out_13_8;
	assign						part_sum_in_15_8 	=	part_sum_out_14_8;
	assign						part_sum_in_1_9 	=	part_sum_out_0_9;
	assign						part_sum_in_2_9 	=	part_sum_out_1_9;
	assign						part_sum_in_3_9 	=	part_sum_out_2_9;
	assign						part_sum_in_4_9 	=	part_sum_out_3_9;
	assign						part_sum_in_5_9 	=	part_sum_out_4_9;
	assign						part_sum_in_6_9 	=	part_sum_out_5_9;
	assign						part_sum_in_7_9 	=	part_sum_out_6_9;
	assign						part_sum_in_8_9 	=	part_sum_out_7_9;
	assign						part_sum_in_9_9 	=	part_sum_out_8_9;
	assign						part_sum_in_10_9 	=	part_sum_out_9_9;
	assign						part_sum_in_11_9 	=	part_sum_out_10_9;
	assign						part_sum_in_12_9 	=	part_sum_out_11_9;
	assign						part_sum_in_13_9 	=	part_sum_out_12_9;
	assign						part_sum_in_14_9 	=	part_sum_out_13_9;
	assign						part_sum_in_15_9 	=	part_sum_out_14_9;
	assign						part_sum_in_1_10 	=	part_sum_out_0_10;
	assign						part_sum_in_2_10 	=	part_sum_out_1_10;
	assign						part_sum_in_3_10 	=	part_sum_out_2_10;
	assign						part_sum_in_4_10 	=	part_sum_out_3_10;
	assign						part_sum_in_5_10 	=	part_sum_out_4_10;
	assign						part_sum_in_6_10 	=	part_sum_out_5_10;
	assign						part_sum_in_7_10 	=	part_sum_out_6_10;
	assign						part_sum_in_8_10 	=	part_sum_out_7_10;
	assign						part_sum_in_9_10 	=	part_sum_out_8_10;
	assign						part_sum_in_10_10 	=	part_sum_out_9_10;
	assign						part_sum_in_11_10 	=	part_sum_out_10_10;
	assign						part_sum_in_12_10 	=	part_sum_out_11_10;
	assign						part_sum_in_13_10 	=	part_sum_out_12_10;
	assign						part_sum_in_14_10 	=	part_sum_out_13_10;
	assign						part_sum_in_15_10 	=	part_sum_out_14_10;
	assign						part_sum_in_1_11 	=	part_sum_out_0_11;
	assign						part_sum_in_2_11 	=	part_sum_out_1_11;
	assign						part_sum_in_3_11 	=	part_sum_out_2_11;
	assign						part_sum_in_4_11 	=	part_sum_out_3_11;
	assign						part_sum_in_5_11 	=	part_sum_out_4_11;
	assign						part_sum_in_6_11 	=	part_sum_out_5_11;
	assign						part_sum_in_7_11 	=	part_sum_out_6_11;
	assign						part_sum_in_8_11 	=	part_sum_out_7_11;
	assign						part_sum_in_9_11 	=	part_sum_out_8_11;
	assign						part_sum_in_10_11 	=	part_sum_out_9_11;
	assign						part_sum_in_11_11 	=	part_sum_out_10_11;
	assign						part_sum_in_12_11 	=	part_sum_out_11_11;
	assign						part_sum_in_13_11 	=	part_sum_out_12_11;
	assign						part_sum_in_14_11 	=	part_sum_out_13_11;
	assign						part_sum_in_15_11 	=	part_sum_out_14_11;
	assign						part_sum_in_1_12 	=	part_sum_out_0_12;
	assign						part_sum_in_2_12 	=	part_sum_out_1_12;
	assign						part_sum_in_3_12 	=	part_sum_out_2_12;
	assign						part_sum_in_4_12 	=	part_sum_out_3_12;
	assign						part_sum_in_5_12 	=	part_sum_out_4_12;
	assign						part_sum_in_6_12 	=	part_sum_out_5_12;
	assign						part_sum_in_7_12 	=	part_sum_out_6_12;
	assign						part_sum_in_8_12 	=	part_sum_out_7_12;
	assign						part_sum_in_9_12 	=	part_sum_out_8_12;
	assign						part_sum_in_10_12 	=	part_sum_out_9_12;
	assign						part_sum_in_11_12 	=	part_sum_out_10_12;
	assign						part_sum_in_12_12 	=	part_sum_out_11_12;
	assign						part_sum_in_13_12 	=	part_sum_out_12_12;
	assign						part_sum_in_14_12 	=	part_sum_out_13_12;
	assign						part_sum_in_15_12 	=	part_sum_out_14_12;
	assign						part_sum_in_1_13 	=	part_sum_out_0_13;
	assign						part_sum_in_2_13 	=	part_sum_out_1_13;
	assign						part_sum_in_3_13 	=	part_sum_out_2_13;
	assign						part_sum_in_4_13 	=	part_sum_out_3_13;
	assign						part_sum_in_5_13 	=	part_sum_out_4_13;
	assign						part_sum_in_6_13 	=	part_sum_out_5_13;
	assign						part_sum_in_7_13 	=	part_sum_out_6_13;
	assign						part_sum_in_8_13 	=	part_sum_out_7_13;
	assign						part_sum_in_9_13 	=	part_sum_out_8_13;
	assign						part_sum_in_10_13 	=	part_sum_out_9_13;
	assign						part_sum_in_11_13 	=	part_sum_out_10_13;
	assign						part_sum_in_12_13 	=	part_sum_out_11_13;
	assign						part_sum_in_13_13 	=	part_sum_out_12_13;
	assign						part_sum_in_14_13 	=	part_sum_out_13_13;
	assign						part_sum_in_15_13 	=	part_sum_out_14_13;
	assign						part_sum_in_1_14 	=	part_sum_out_0_14;
	assign						part_sum_in_2_14 	=	part_sum_out_1_14;
	assign						part_sum_in_3_14 	=	part_sum_out_2_14;
	assign						part_sum_in_4_14 	=	part_sum_out_3_14;
	assign						part_sum_in_5_14 	=	part_sum_out_4_14;
	assign						part_sum_in_6_14 	=	part_sum_out_5_14;
	assign						part_sum_in_7_14 	=	part_sum_out_6_14;
	assign						part_sum_in_8_14 	=	part_sum_out_7_14;
	assign						part_sum_in_9_14 	=	part_sum_out_8_14;
	assign						part_sum_in_10_14 	=	part_sum_out_9_14;
	assign						part_sum_in_11_14 	=	part_sum_out_10_14;
	assign						part_sum_in_12_14 	=	part_sum_out_11_14;
	assign						part_sum_in_13_14 	=	part_sum_out_12_14;
	assign						part_sum_in_14_14 	=	part_sum_out_13_14;
	assign						part_sum_in_15_14 	=	part_sum_out_14_14;
	assign						part_sum_in_1_15 	=	part_sum_out_0_15;
	assign						part_sum_in_2_15 	=	part_sum_out_1_15;
	assign						part_sum_in_3_15 	=	part_sum_out_2_15;
	assign						part_sum_in_4_15 	=	part_sum_out_3_15;
	assign						part_sum_in_5_15 	=	part_sum_out_4_15;
	assign						part_sum_in_6_15 	=	part_sum_out_5_15;
	assign						part_sum_in_7_15 	=	part_sum_out_6_15;
	assign						part_sum_in_8_15 	=	part_sum_out_7_15;
	assign						part_sum_in_9_15 	=	part_sum_out_8_15;
	assign						part_sum_in_10_15 	=	part_sum_out_9_15;
	assign						part_sum_in_11_15 	=	part_sum_out_10_15;
	assign						part_sum_in_12_15 	=	part_sum_out_11_15;
	assign						part_sum_in_13_15 	=	part_sum_out_12_15;
	assign						part_sum_in_14_15 	=	part_sum_out_13_15;
	assign						part_sum_in_15_15 	=	part_sum_out_14_15;
//
//
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_0;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_1;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_2;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_3;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_4;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_5;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_6;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_7;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_8;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_9;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_10;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_11;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_12;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_13;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_14;
	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_15;
//
//
	assign						systolic_col_data_0 	=			part_sum_out_15_0;
	assign						systolic_col_data_1 	=			part_sum_out_15_1;
	assign						systolic_col_data_2 	=			part_sum_out_15_2;
	assign						systolic_col_data_3 	=			part_sum_out_15_3;
	assign						systolic_col_data_4 	=			part_sum_out_15_4;
	assign						systolic_col_data_5 	=			part_sum_out_15_5;
	assign						systolic_col_data_6 	=			part_sum_out_15_6;
	assign						systolic_col_data_7 	=			part_sum_out_15_7;
	assign						systolic_col_data_8 	=			part_sum_out_15_8;
	assign						systolic_col_data_9 	=			part_sum_out_15_9;
	assign						systolic_col_data_10 	=			part_sum_out_15_10;
	assign						systolic_col_data_11 	=			part_sum_out_15_11;
	assign						systolic_col_data_12 	=			part_sum_out_15_12;
	assign						systolic_col_data_13 	=			part_sum_out_15_13;
	assign						systolic_col_data_14 	=			part_sum_out_15_14;
	assign						systolic_col_data_15 	=			part_sum_out_15_15;
//
//
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_0;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_1;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_2;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_3;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_4;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_5;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_6;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_7;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_8;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_9;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_10;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_11;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_12;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_13;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_14;
	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_15;
//
//
	assign						bias_col_0			= 			bias_in[(0+1)*BIAS_BITWIDTH-1:0*BIAS_BITWIDTH];
	assign						bias_col_1			= 			bias_in[(1+1)*BIAS_BITWIDTH-1:1*BIAS_BITWIDTH];
	assign						bias_col_2			= 			bias_in[(2+1)*BIAS_BITWIDTH-1:2*BIAS_BITWIDTH];
	assign						bias_col_3			= 			bias_in[(3+1)*BIAS_BITWIDTH-1:3*BIAS_BITWIDTH];
	assign						bias_col_4			= 			bias_in[(4+1)*BIAS_BITWIDTH-1:4*BIAS_BITWIDTH];
	assign						bias_col_5			= 			bias_in[(5+1)*BIAS_BITWIDTH-1:5*BIAS_BITWIDTH];
	assign						bias_col_6			= 			bias_in[(6+1)*BIAS_BITWIDTH-1:6*BIAS_BITWIDTH];
	assign						bias_col_7			= 			bias_in[(7+1)*BIAS_BITWIDTH-1:7*BIAS_BITWIDTH];
	assign						bias_col_8			= 			bias_in[(8+1)*BIAS_BITWIDTH-1:8*BIAS_BITWIDTH];
	assign						bias_col_9			= 			bias_in[(9+1)*BIAS_BITWIDTH-1:9*BIAS_BITWIDTH];
	assign						bias_col_10			= 			bias_in[(10+1)*BIAS_BITWIDTH-1:10*BIAS_BITWIDTH];
	assign						bias_col_11			= 			bias_in[(11+1)*BIAS_BITWIDTH-1:11*BIAS_BITWIDTH];
	assign						bias_col_12			= 			bias_in[(12+1)*BIAS_BITWIDTH-1:12*BIAS_BITWIDTH];
	assign						bias_col_13			= 			bias_in[(13+1)*BIAS_BITWIDTH-1:13*BIAS_BITWIDTH];
	assign						bias_col_14			= 			bias_in[(14+1)*BIAS_BITWIDTH-1:14*BIAS_BITWIDTH];
	assign						bias_col_15			= 			bias_in[(15+1)*BIAS_BITWIDTH-1:15*BIAS_BITWIDTH];
//
//
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_0;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_1;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_2;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_3;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_4;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_5;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_6;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_7;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_8;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_9;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_10;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_11;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_12;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_13;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_14;
	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_15;
//
//
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_0 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_0),
		.part_sum_out 														(acc_out_col_0)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_1 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_1),
		.part_sum_out 														(acc_out_col_1)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_2 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_2),
		.part_sum_out 														(acc_out_col_2)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_3 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_3),
		.part_sum_out 														(acc_out_col_3)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_4 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_4),
		.part_sum_out 														(acc_out_col_4)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_5 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_5),
		.part_sum_out 														(acc_out_col_5)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_6 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_6),
		.part_sum_out 														(acc_out_col_6)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_7 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_7),
		.part_sum_out 														(acc_out_col_7)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_8 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_8),
		.part_sum_out 														(acc_out_col_8)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_9 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_9),
		.part_sum_out 														(acc_out_col_9)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_10 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_10),
		.part_sum_out 														(acc_out_col_10)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_11 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_11),
		.part_sum_out 														(acc_out_col_11)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_12 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_12),
		.part_sum_out 														(acc_out_col_12)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_13 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_13),
		.part_sum_out 														(acc_out_col_13)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_14 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_14),
		.part_sum_out 														(acc_out_col_14)
	);
	accumulator #(
		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
	) accumulator_col_15 (
		.clk																(clk),
		.reset 																(acc_reset),
		.wrt_en 															(acc_wrt_en),
		.acc_logic 															(os_en),
		.part_sum_in 														(systolic_col_data_15),
		.part_sum_out 														(acc_out_col_15)
	);
//
//
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_0;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_1;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_2;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_3;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_4;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_5;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_6;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_7;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_8;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_9;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_10;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_11;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_12;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_13;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_14;
	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_15;
//
//
	assign						part_out_in_col_0 		= 		part_out_in[(0+1)*PART_SUM_BITWIDTH-1:0*PART_SUM_BITWIDTH];
	assign						part_out_in_col_1 		= 		part_out_in[(1+1)*PART_SUM_BITWIDTH-1:1*PART_SUM_BITWIDTH];
	assign						part_out_in_col_2 		= 		part_out_in[(2+1)*PART_SUM_BITWIDTH-1:2*PART_SUM_BITWIDTH];
	assign						part_out_in_col_3 		= 		part_out_in[(3+1)*PART_SUM_BITWIDTH-1:3*PART_SUM_BITWIDTH];
	assign						part_out_in_col_4 		= 		part_out_in[(4+1)*PART_SUM_BITWIDTH-1:4*PART_SUM_BITWIDTH];
	assign						part_out_in_col_5 		= 		part_out_in[(5+1)*PART_SUM_BITWIDTH-1:5*PART_SUM_BITWIDTH];
	assign						part_out_in_col_6 		= 		part_out_in[(6+1)*PART_SUM_BITWIDTH-1:6*PART_SUM_BITWIDTH];
	assign						part_out_in_col_7 		= 		part_out_in[(7+1)*PART_SUM_BITWIDTH-1:7*PART_SUM_BITWIDTH];
	assign						part_out_in_col_8 		= 		part_out_in[(8+1)*PART_SUM_BITWIDTH-1:8*PART_SUM_BITWIDTH];
	assign						part_out_in_col_9 		= 		part_out_in[(9+1)*PART_SUM_BITWIDTH-1:9*PART_SUM_BITWIDTH];
	assign						part_out_in_col_10 		= 		part_out_in[(10+1)*PART_SUM_BITWIDTH-1:10*PART_SUM_BITWIDTH];
	assign						part_out_in_col_11 		= 		part_out_in[(11+1)*PART_SUM_BITWIDTH-1:11*PART_SUM_BITWIDTH];
	assign						part_out_in_col_12 		= 		part_out_in[(12+1)*PART_SUM_BITWIDTH-1:12*PART_SUM_BITWIDTH];
	assign						part_out_in_col_13 		= 		part_out_in[(13+1)*PART_SUM_BITWIDTH-1:13*PART_SUM_BITWIDTH];
	assign						part_out_in_col_14 		= 		part_out_in[(14+1)*PART_SUM_BITWIDTH-1:14*PART_SUM_BITWIDTH];
	assign						part_out_in_col_15 		= 		part_out_in[(15+1)*PART_SUM_BITWIDTH-1:15*PART_SUM_BITWIDTH];
//
//
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_0;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_1;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_2;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_3;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_4;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_5;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_6;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_7;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_8;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_9;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_10;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_11;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_12;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_13;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_14;
	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_15;
//
//
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_0;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_1;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_2;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_3;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_4;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_5;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_6;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_7;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_8;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_9;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_10;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_11;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_12;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_13;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_14;
	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_15;
//

	always @ (*) begin
		if (bias_out_sel == 0) begin
//
			bias_out_opnd_col_0		=		part_out_in_col_0;
			bias_out_opnd_col_1		=		part_out_in_col_1;
			bias_out_opnd_col_2		=		part_out_in_col_2;
			bias_out_opnd_col_3		=		part_out_in_col_3;
			bias_out_opnd_col_4		=		part_out_in_col_4;
			bias_out_opnd_col_5		=		part_out_in_col_5;
			bias_out_opnd_col_6		=		part_out_in_col_6;
			bias_out_opnd_col_7		=		part_out_in_col_7;
			bias_out_opnd_col_8		=		part_out_in_col_8;
			bias_out_opnd_col_9		=		part_out_in_col_9;
			bias_out_opnd_col_10		=		part_out_in_col_10;
			bias_out_opnd_col_11		=		part_out_in_col_11;
			bias_out_opnd_col_12		=		part_out_in_col_12;
			bias_out_opnd_col_13		=		part_out_in_col_13;
			bias_out_opnd_col_14		=		part_out_in_col_14;
			bias_out_opnd_col_15		=		part_out_in_col_15;
//
		end
		if (bias_out_sel == 1) begin
//
			bias_out_opnd_col_0       =  		bias_col_0;
			bias_out_opnd_col_1       =  		bias_col_1;
			bias_out_opnd_col_2       =  		bias_col_2;
			bias_out_opnd_col_3       =  		bias_col_3;
			bias_out_opnd_col_4       =  		bias_col_4;
			bias_out_opnd_col_5       =  		bias_col_5;
			bias_out_opnd_col_6       =  		bias_col_6;
			bias_out_opnd_col_7       =  		bias_col_7;
			bias_out_opnd_col_8       =  		bias_col_8;
			bias_out_opnd_col_9       =  		bias_col_9;
			bias_out_opnd_col_10       =  		bias_col_10;
			bias_out_opnd_col_11       =  		bias_col_11;
			bias_out_opnd_col_12       =  		bias_col_12;
			bias_out_opnd_col_13       =  		bias_col_13;
			bias_out_opnd_col_14       =  		bias_col_14;
			bias_out_opnd_col_15       =  		bias_col_15;
//
		end
	end

	always @ (*) begin
		if (acc_out_mem_sel == 0) begin
//
			acc_out_mem_opnd_col_0    =		part_out_in_col_0;
			acc_out_mem_opnd_col_1    =		part_out_in_col_1;
			acc_out_mem_opnd_col_2    =		part_out_in_col_2;
			acc_out_mem_opnd_col_3    =		part_out_in_col_3;
			acc_out_mem_opnd_col_4    =		part_out_in_col_4;
			acc_out_mem_opnd_col_5    =		part_out_in_col_5;
			acc_out_mem_opnd_col_6    =		part_out_in_col_6;
			acc_out_mem_opnd_col_7    =		part_out_in_col_7;
			acc_out_mem_opnd_col_8    =		part_out_in_col_8;
			acc_out_mem_opnd_col_9    =		part_out_in_col_9;
			acc_out_mem_opnd_col_10    =		part_out_in_col_10;
			acc_out_mem_opnd_col_11    =		part_out_in_col_11;
			acc_out_mem_opnd_col_12    =		part_out_in_col_12;
			acc_out_mem_opnd_col_13    =		part_out_in_col_13;
			acc_out_mem_opnd_col_14    =		part_out_in_col_14;
			acc_out_mem_opnd_col_15    =		part_out_in_col_15;
//
		end
		if (acc_out_mem_sel == 1) begin
//
			acc_out_mem_opnd_col_0       =  	acc_out_col_0;
			acc_out_mem_opnd_col_1       =  	acc_out_col_1;
			acc_out_mem_opnd_col_2       =  	acc_out_col_2;
			acc_out_mem_opnd_col_3       =  	acc_out_col_3;
			acc_out_mem_opnd_col_4       =  	acc_out_col_4;
			acc_out_mem_opnd_col_5       =  	acc_out_col_5;
			acc_out_mem_opnd_col_6       =  	acc_out_col_6;
			acc_out_mem_opnd_col_7       =  	acc_out_col_7;
			acc_out_mem_opnd_col_8       =  	acc_out_col_8;
			acc_out_mem_opnd_col_9       =  	acc_out_col_9;
			acc_out_mem_opnd_col_10       =  	acc_out_col_10;
			acc_out_mem_opnd_col_11       =  	acc_out_col_11;
			acc_out_mem_opnd_col_12       =  	acc_out_col_12;
			acc_out_mem_opnd_col_13       =  	acc_out_col_13;
			acc_out_mem_opnd_col_14       =  	acc_out_col_14;
			acc_out_mem_opnd_col_15       =  	acc_out_col_15;
//
		end
	end

//
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_0;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_1;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_2;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_3;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_4;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_5;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_6;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_7;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_8;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_9;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_10;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_11;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_12;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_13;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_14;
	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_15;
//
//
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_0;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_1;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_2;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_3;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_4;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_5;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_6;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_7;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_8;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_9;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_10;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_11;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_12;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_13;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_14;
	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_15;
//
//
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_0 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_0),
		.in_2 																(bias_out_opnd_col_0),
		.out 																(adder_out_col_0)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_1 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_1),
		.in_2 																(bias_out_opnd_col_1),
		.out 																(adder_out_col_1)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_2 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_2),
		.in_2 																(bias_out_opnd_col_2),
		.out 																(adder_out_col_2)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_3 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_3),
		.in_2 																(bias_out_opnd_col_3),
		.out 																(adder_out_col_3)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_4 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_4),
		.in_2 																(bias_out_opnd_col_4),
		.out 																(adder_out_col_4)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_5 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_5),
		.in_2 																(bias_out_opnd_col_5),
		.out 																(adder_out_col_5)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_6 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_6),
		.in_2 																(bias_out_opnd_col_6),
		.out 																(adder_out_col_6)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_7 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_7),
		.in_2 																(bias_out_opnd_col_7),
		.out 																(adder_out_col_7)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_8 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_8),
		.in_2 																(bias_out_opnd_col_8),
		.out 																(adder_out_col_8)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_9 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_9),
		.in_2 																(bias_out_opnd_col_9),
		.out 																(adder_out_col_9)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_10 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_10),
		.in_2 																(bias_out_opnd_col_10),
		.out 																(adder_out_col_10)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_11 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_11),
		.in_2 																(bias_out_opnd_col_11),
		.out 																(adder_out_col_11)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_12 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_12),
		.in_2 																(bias_out_opnd_col_12),
		.out 																(adder_out_col_12)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_13 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_13),
		.in_2 																(bias_out_opnd_col_13),
		.out 																(adder_out_col_13)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_14 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_14),
		.in_2 																(bias_out_opnd_col_14),
		.out 																(adder_out_col_14)
	);
	adder #(
		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
	) adder_col_15 (
		.adder_en 															(bias_mem_adder_en),
		.in_1 																(acc_out_mem_opnd_col_15),
		.in_2 																(bias_out_opnd_col_15),
		.out 																(adder_out_col_15)
	);
//
//Figure out if we need a register here or not (probably not becayse we have out mem!)
	always @(*) begin

		if (out_wr_sel == 0) begin
//
			systolic_data_out_col_0 	= acc_out_col_0;
			systolic_data_out_col_1 	= acc_out_col_1;
			systolic_data_out_col_2 	= acc_out_col_2;
			systolic_data_out_col_3 	= acc_out_col_3;
			systolic_data_out_col_4 	= acc_out_col_4;
			systolic_data_out_col_5 	= acc_out_col_5;
			systolic_data_out_col_6 	= acc_out_col_6;
			systolic_data_out_col_7 	= acc_out_col_7;
			systolic_data_out_col_8 	= acc_out_col_8;
			systolic_data_out_col_9 	= acc_out_col_9;
			systolic_data_out_col_10 	= acc_out_col_10;
			systolic_data_out_col_11 	= acc_out_col_11;
			systolic_data_out_col_12 	= acc_out_col_12;
			systolic_data_out_col_13 	= acc_out_col_13;
			systolic_data_out_col_14 	= acc_out_col_14;
			systolic_data_out_col_15 	= acc_out_col_15;
//
		end
		if (out_wr_sel == 1) begin
//
			systolic_data_out_col_0 	= adder_out_col_0;
			systolic_data_out_col_1 	= adder_out_col_1;
			systolic_data_out_col_2 	= adder_out_col_2;
			systolic_data_out_col_3 	= adder_out_col_3;
			systolic_data_out_col_4 	= adder_out_col_4;
			systolic_data_out_col_5 	= adder_out_col_5;
			systolic_data_out_col_6 	= adder_out_col_6;
			systolic_data_out_col_7 	= adder_out_col_7;
			systolic_data_out_col_8 	= adder_out_col_8;
			systolic_data_out_col_9 	= adder_out_col_9;
			systolic_data_out_col_10 	= adder_out_col_10;
			systolic_data_out_col_11 	= adder_out_col_11;
			systolic_data_out_col_12 	= adder_out_col_12;
			systolic_data_out_col_13 	= adder_out_col_13;
			systolic_data_out_col_14 	= adder_out_col_14;
			systolic_data_out_col_15 	= adder_out_col_15;
//
		end
	end

	assign						data_out 					   =  			{systolic_data_out_col_15,systolic_data_out_col_14,systolic_data_out_col_13,systolic_data_out_col_12,systolic_data_out_col_11,systolic_data_out_col_10,systolic_data_out_col_9,systolic_data_out_col_8,systolic_data_out_col_7,systolic_data_out_col_6,systolic_data_out_col_5,systolic_data_out_col_4,systolic_data_out_col_3,systolic_data_out_col_2,systolic_data_out_col_1,systolic_data_out_col_0};

endmodule


//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 11/21/2019 11:17:34 PM
//// Design Name: 
//// Module Name: systolic_mvm
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//module systolic_mvm #(
//	parameter					ARRAY_DIM_X									= 3,
//	parameter					ARRAY_DIM_Y									= 3,
//	parameter					WGT_MEM_ADDR_BITWIDTH						= 8,
//	parameter					WGT_BITWIDTH								= 8,
//	parameter					ACT_BITWIDTH								= 8,
//	parameter					BIAS_BITWIDTH								= 32,
//	parameter					ACT_MEM_DATA_BITWIDTH						= ACT_BITWIDTH * ARRAY_DIM_Y,
//	parameter					PART_SUM_BITWIDTH							= 32,
//	parameter					PE_INTER_BITWIDTH							= 33,
//	parameter					OUT_DATA_BITWIDTH							= PART_SUM_BITWIDTH,
//	parameter					PE_TRUNC_MODE								= "MSB",
//	parameter					NUM_PE										= ARRAY_DIM_X * ARRAY_DIM_Y
//)(
//	input																	clk,
//	input																	reset_pe_reg,
//	input																	pe_wrt_en_reg,
//	input																	pe_wmem_reset,
//	input						[NUM_PE							-1: 0]		pe_wmem_read_req,
//	input						[NUM_PE							-1: 0]		pe_wmem_write_req,
//	input						[NUM_PE							-1: 0]		pe_ws_en,
//	input						[NUM_PE							-1: 0]		pe_ws_mux,
//	input						[ARRAY_DIM_Y					-1: 0]		as_en,
//	input 						[ARRAY_DIM_Y					-1: 0]		as_mux,
//	input 						[ARRAY_DIM_Y					-1: 0]		reset_as_reg,
//	input						[NUM_PE							-1: 0]		pe_reset_ws_reg,
//	input																	acc_reset,
//	input																	acc_wrt_en,
//	input						[ARRAY_DIM_X					-1: 0]		os_en,
//	input																	bias_mem_adder_en,
//	input																	bias_out_sel,
//	input 																	out_wr_sel,
//	input																	acc_out_mem_sel,
//	input						[ARRAY_DIM_X * BIAS_BITWIDTH    -1: 0]		bias_in,
//	input						[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_r_addr,
//	input						[NUM_PE * WGT_MEM_ADDR_BITWIDTH -1: 0]		pe_wmem_w_addr,
//	input						[NUM_PE * WGT_BITWIDTH          -1: 0]		pe_wmem_w_data,

//	input						[ACT_BITWIDTH       			-1: 0]		act_in_2,

//	input						[ACT_BITWIDTH       			-1: 0]		act_in_1,

//	input						[ACT_BITWIDTH       			-1: 0]		act_in_0,

//	input						[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		part_out_in,
//	output						[ARRAY_DIM_X*OUT_DATA_BITWIDTH  -1: 0]		data_out
//);


//	//Making PE weight memroy r/w addresses adn write data passes
////
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_0_2;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_1_2;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_r_addr_2_2;
////
////
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_0;
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_1;
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_r_addr_row_2;
////
////
//	assign 						pe_wmem_r_addr_row_0          =   pe_wmem_r_addr[(0+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:0*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//	assign 						pe_wmem_r_addr_row_1          =   pe_wmem_r_addr[(1+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:1*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//	assign 						pe_wmem_r_addr_row_2          =   pe_wmem_r_addr[(2+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:2*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
////
////
//	assign						pe_wmem_r_addr_0_0	=	pe_wmem_r_addr_row_0[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_1_0	=	pe_wmem_r_addr_row_1[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_2_0	=	pe_wmem_r_addr_row_2[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_0_1	=	pe_wmem_r_addr_row_0[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_1_1	=	pe_wmem_r_addr_row_1[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_2_1	=	pe_wmem_r_addr_row_2[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_0_2	=	pe_wmem_r_addr_row_0[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_1_2	=	pe_wmem_r_addr_row_1[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_r_addr_2_2	=	pe_wmem_r_addr_row_2[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
////

////
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_0;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_1;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_0_2;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_1_2;
//	wire						[WGT_MEM_ADDR_BITWIDTH			-1: 0]		pe_wmem_w_addr_2_2;
////
////
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_0;
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_1;
//	wire						[ARRAY_DIM_X*WGT_MEM_ADDR_BITWIDTH -1: 0]	pe_wmem_w_addr_row_2;
////
////
//	assign						pe_wmem_w_addr_row_0          =   pe_wmem_w_addr[(0+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:0*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//	assign						pe_wmem_w_addr_row_1          =   pe_wmem_w_addr[(1+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:1*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
//	assign						pe_wmem_w_addr_row_2          =   pe_wmem_w_addr[(2+1)*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X-1:2*WGT_MEM_ADDR_BITWIDTH*ARRAY_DIM_X];
////
////
//	assign						pe_wmem_w_addr_0_0	=	pe_wmem_w_addr_row_0[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_1_0	=	pe_wmem_w_addr_row_1[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_2_0	=	pe_wmem_w_addr_row_2[(0+1)*WGT_MEM_ADDR_BITWIDTH-1:0*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_0_1	=	pe_wmem_w_addr_row_0[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_1_1	=	pe_wmem_w_addr_row_1[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_2_1	=	pe_wmem_w_addr_row_2[(1+1)*WGT_MEM_ADDR_BITWIDTH-1:1*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_0_2	=	pe_wmem_w_addr_row_0[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_1_2	=	pe_wmem_w_addr_row_1[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
//	assign						pe_wmem_w_addr_2_2	=	pe_wmem_w_addr_row_2[(2+1)*WGT_MEM_ADDR_BITWIDTH-1:2*WGT_MEM_ADDR_BITWIDTH];
////

////
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_0;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_0;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_0;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_1;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_1;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_1;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_0_2;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_1_2;
//	wire						[WGT_BITWIDTH			        -1: 0]		pe_wmem_w_data_2_2;
////
////
//	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_0;
//	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_1;
//	wire						[ARRAY_DIM_X*WGT_BITWIDTH       -1: 0]	    pe_wmem_w_data_row_2;
////
////
//	assign						pe_wmem_w_data_row_0      	=   pe_wmem_w_data[(0+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:0*WGT_BITWIDTH*ARRAY_DIM_X];
//	assign						pe_wmem_w_data_row_1      	=   pe_wmem_w_data[(1+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:1*WGT_BITWIDTH*ARRAY_DIM_X];
//	assign						pe_wmem_w_data_row_2      	=   pe_wmem_w_data[(2+1)*WGT_BITWIDTH*ARRAY_DIM_X-1:2*WGT_BITWIDTH*ARRAY_DIM_X];
////
////
//	assign						pe_wmem_w_data_0_0	=	pe_wmem_w_data_row_0[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_1_0	=	pe_wmem_w_data_row_1[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_2_0	=	pe_wmem_w_data_row_2[(0+1)*WGT_BITWIDTH-1:0*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_0_1	=	pe_wmem_w_data_row_0[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_1_1	=	pe_wmem_w_data_row_1[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_2_1	=	pe_wmem_w_data_row_2[(1+1)*WGT_BITWIDTH-1:1*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_0_2	=	pe_wmem_w_data_row_0[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_1_2	=	pe_wmem_w_data_row_1[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
//	assign						pe_wmem_w_data_2_2	=	pe_wmem_w_data_row_2[(2+1)*WGT_BITWIDTH-1:2*WGT_BITWIDTH];
////
////
//	wire																	pe_wmem_read_req_0_0;
//	wire																	pe_wmem_read_req_1_0;
//	wire																	pe_wmem_read_req_2_0;
//	wire																	pe_wmem_read_req_0_1;
//	wire																	pe_wmem_read_req_1_1;
//	wire																	pe_wmem_read_req_2_1;
//	wire																	pe_wmem_read_req_0_2;
//	wire																	pe_wmem_read_req_1_2;
//	wire																	pe_wmem_read_req_2_2;
////
////
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_0;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_1;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_read_req_row_2;
////
////
//	assign						pe_wmem_read_req_row_0      	=   pe_wmem_read_req[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
//	assign						pe_wmem_read_req_row_1      	=   pe_wmem_read_req[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
//	assign						pe_wmem_read_req_row_2      	=   pe_wmem_read_req[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
////
////
//	assign						pe_wmem_read_req_0_0 =	pe_wmem_read_req_row_0[(0+1)-1:0];
//	assign						pe_wmem_read_req_1_0 =	pe_wmem_read_req_row_1[(0+1)-1:0];
//	assign						pe_wmem_read_req_2_0 =	pe_wmem_read_req_row_2[(0+1)-1:0];
//	assign						pe_wmem_read_req_0_1 =	pe_wmem_read_req_row_0[(1+1)-1:1];
//	assign						pe_wmem_read_req_1_1 =	pe_wmem_read_req_row_1[(1+1)-1:1];
//	assign						pe_wmem_read_req_2_1 =	pe_wmem_read_req_row_2[(1+1)-1:1];
//	assign						pe_wmem_read_req_0_2 =	pe_wmem_read_req_row_0[(2+1)-1:2];
//	assign						pe_wmem_read_req_1_2 =	pe_wmem_read_req_row_1[(2+1)-1:2];
//	assign						pe_wmem_read_req_2_2 =	pe_wmem_read_req_row_2[(2+1)-1:2];
////
////
//	wire																	pe_wmem_write_req_0_0;
//	wire																	pe_wmem_write_req_1_0;
//	wire																	pe_wmem_write_req_2_0;
//	wire																	pe_wmem_write_req_0_1;
//	wire																	pe_wmem_write_req_1_1;
//	wire																	pe_wmem_write_req_2_1;
//	wire																	pe_wmem_write_req_0_2;
//	wire																	pe_wmem_write_req_1_2;
//	wire																	pe_wmem_write_req_2_2;
////
////
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_0;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_1;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_wmem_write_req_row_2;
////
////
//	assign						pe_wmem_write_req_row_0      	=   pe_wmem_write_req[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
//	assign						pe_wmem_write_req_row_1      	=   pe_wmem_write_req[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
//	assign						pe_wmem_write_req_row_2      	=   pe_wmem_write_req[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
////
////
//	assign						pe_wmem_write_req_0_0 =	pe_wmem_write_req_row_0[(0+1)-1:0];
//	assign						pe_wmem_write_req_1_0 =	pe_wmem_write_req_row_1[(0+1)-1:0];
//	assign						pe_wmem_write_req_2_0 =	pe_wmem_write_req_row_2[(0+1)-1:0];
//	assign						pe_wmem_write_req_0_1 =	pe_wmem_write_req_row_0[(1+1)-1:1];
//	assign						pe_wmem_write_req_1_1 =	pe_wmem_write_req_row_1[(1+1)-1:1];
//	assign						pe_wmem_write_req_2_1 =	pe_wmem_write_req_row_2[(1+1)-1:1];
//	assign						pe_wmem_write_req_0_2 =	pe_wmem_write_req_row_0[(2+1)-1:2];
//	assign						pe_wmem_write_req_1_2 =	pe_wmem_write_req_row_1[(2+1)-1:2];
//	assign						pe_wmem_write_req_2_2 =	pe_wmem_write_req_row_2[(2+1)-1:2];
////
////
//	wire																	pe_ws_en_0_0;
//	wire																	pe_ws_en_1_0;
//	wire																	pe_ws_en_2_0;
//	wire																	pe_ws_en_0_1;
//	wire																	pe_ws_en_1_1;
//	wire																	pe_ws_en_2_1;
//	wire																	pe_ws_en_0_2;
//	wire																	pe_ws_en_1_2;
//	wire																	pe_ws_en_2_2;
////
////
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_0;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_1;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_en_row_2;
////
////
//	assign						pe_ws_en_row_0      	=       	pe_ws_en[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
//	assign						pe_ws_en_row_1      	=       	pe_ws_en[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
//	assign						pe_ws_en_row_2      	=       	pe_ws_en[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
////
////
//	assign						pe_ws_en_0_0 =	    	pe_ws_en_row_0[(0+1)-1:0];
//	assign						pe_ws_en_1_0 =	    	pe_ws_en_row_1[(0+1)-1:0];
//	assign						pe_ws_en_2_0 =	    	pe_ws_en_row_2[(0+1)-1:0];
//	assign						pe_ws_en_0_1 =	    	pe_ws_en_row_0[(1+1)-1:1];
//	assign						pe_ws_en_1_1 =	    	pe_ws_en_row_1[(1+1)-1:1];
//	assign						pe_ws_en_2_1 =	    	pe_ws_en_row_2[(1+1)-1:1];
//	assign						pe_ws_en_0_2 =	    	pe_ws_en_row_0[(2+1)-1:2];
//	assign						pe_ws_en_1_2 =	    	pe_ws_en_row_1[(2+1)-1:2];
//	assign						pe_ws_en_2_2 =	    	pe_ws_en_row_2[(2+1)-1:2];
////
////
//	wire																	pe_ws_mux_0_0;
//	wire																	pe_ws_mux_1_0;
//	wire																	pe_ws_mux_2_0;
//	wire																	pe_ws_mux_0_1;
//	wire																	pe_ws_mux_1_1;
//	wire																	pe_ws_mux_2_1;
//	wire																	pe_ws_mux_0_2;
//	wire																	pe_ws_mux_1_2;
//	wire																	pe_ws_mux_2_2;
////
////
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_0;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_1;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_ws_mux_row_2;
////
////
//	assign						pe_ws_mux_row_0      	= 			pe_ws_mux[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
//	assign						pe_ws_mux_row_1      	= 			pe_ws_mux[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
//	assign						pe_ws_mux_row_2      	= 			pe_ws_mux[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
////
////
//	assign						pe_ws_mux_0_0 =  		pe_ws_mux_row_0[(0+1)-1:0];
//	assign						pe_ws_mux_1_0 =  		pe_ws_mux_row_1[(0+1)-1:0];
//	assign						pe_ws_mux_2_0 =  		pe_ws_mux_row_2[(0+1)-1:0];
//	assign						pe_ws_mux_0_1 =  		pe_ws_mux_row_0[(1+1)-1:1];
//	assign						pe_ws_mux_1_1 =  		pe_ws_mux_row_1[(1+1)-1:1];
//	assign						pe_ws_mux_2_1 =  		pe_ws_mux_row_2[(1+1)-1:1];
//	assign						pe_ws_mux_0_2 =  		pe_ws_mux_row_0[(2+1)-1:2];
//	assign						pe_ws_mux_1_2 =  		pe_ws_mux_row_1[(2+1)-1:2];
//	assign						pe_ws_mux_2_2 =  		pe_ws_mux_row_2[(2+1)-1:2];
////
////
//	wire																	pe_reset_ws_reg_0_0;
//	wire																	pe_reset_ws_reg_1_0;
//	wire																	pe_reset_ws_reg_2_0;
//	wire																	pe_reset_ws_reg_0_1;
//	wire																	pe_reset_ws_reg_1_1;
//	wire																	pe_reset_ws_reg_2_1;
//	wire																	pe_reset_ws_reg_0_2;
//	wire																	pe_reset_ws_reg_1_2;
//	wire																	pe_reset_ws_reg_2_2;
////
////
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_0;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_1;
//	wire						[ARRAY_DIM_X       -1: 0]				    pe_reset_ws_reg_row_2;
////
////
//	assign						pe_reset_ws_reg_row_0      	=   pe_reset_ws_reg[(0+1)*ARRAY_DIM_X-1:0*ARRAY_DIM_X];
//	assign						pe_reset_ws_reg_row_1      	=   pe_reset_ws_reg[(1+1)*ARRAY_DIM_X-1:1*ARRAY_DIM_X];
//	assign						pe_reset_ws_reg_row_2      	=   pe_reset_ws_reg[(2+1)*ARRAY_DIM_X-1:2*ARRAY_DIM_X];
////
////
//	assign						pe_reset_ws_reg_0_0 =   pe_reset_ws_reg_row_0[(0+1)-1:0];
//	assign						pe_reset_ws_reg_1_0 =   pe_reset_ws_reg_row_1[(0+1)-1:0];
//	assign						pe_reset_ws_reg_2_0 =   pe_reset_ws_reg_row_2[(0+1)-1:0];
//	assign						pe_reset_ws_reg_0_1 =   pe_reset_ws_reg_row_0[(1+1)-1:1];
//	assign						pe_reset_ws_reg_1_1 =   pe_reset_ws_reg_row_1[(1+1)-1:1];
//	assign						pe_reset_ws_reg_2_1 =   pe_reset_ws_reg_row_2[(1+1)-1:1];
//	assign						pe_reset_ws_reg_0_2 =   pe_reset_ws_reg_row_0[(2+1)-1:2];
//	assign						pe_reset_ws_reg_1_2 =   pe_reset_ws_reg_row_1[(2+1)-1:2];
//	assign						pe_reset_ws_reg_2_2 =   pe_reset_ws_reg_row_2[(2+1)-1:2];
////
////
//	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_0;
//	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_1;
//	wire						[ACT_BITWIDTH	  -1: 0]					_act_in_row_2;
////
////
//	assign						_act_in_row_0 				=   act_in_0;
//	assign						_act_in_row_1 				=   act_in_1;
//	assign						_act_in_row_2 				=   act_in_2;
////
////
//	wire 																	as_en_row_0;
//	wire 																	as_en_row_1;
//	wire 																	as_en_row_2;
////
////
//	assign						as_en_row_0					=	as_en[(0+1)-1:0];
//	assign						as_en_row_1					=	as_en[(1+1)-1:1];
//	assign						as_en_row_2					=	as_en[(2+1)-1:2];
////
////
//	wire																	as_mux_row_0;
//	wire																	as_mux_row_1;
//	wire																	as_mux_row_2;
////
////
//	assign						as_mux_row_0					=	as_mux[(0+1)-1:0];
//	assign						as_mux_row_1					=	as_mux[(1+1)-1:1];
//	assign						as_mux_row_2					=	as_mux[(2+1)-1:2];
////
////
//	wire																	reset_as_reg_row_0;
//	wire																	reset_as_reg_row_1;
//	wire																	reset_as_reg_row_2;
////
////
//	assign						reset_as_reg_row_0			=	reset_as_reg[(0+1)-1:0];
//	assign						reset_as_reg_row_1			=	reset_as_reg[(1+1)-1:1];
//	assign						reset_as_reg_row_2			=	reset_as_reg[(2+1)-1:2];
////
////------------- input stationary logic
////
//	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_0;
//	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_1;
//	wire					   [ACT_BITWIDTH	  -1: 0]	                _act_in_row_reg_2;
////
////
//	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_0;
//	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_1;
//	reg						   [ACT_BITWIDTH	  -1: 0]	                act_in_row_2;
////
////
//	register #(
//		.BIT_WIDTH 														(ACT_BITWIDTH)
//	) register_as_row_0 (
//		.clk 															(clk),
//		.reset 															(reset_as_reg_row_0),
//		.wrt_en 														(as_en_row_0),
//		.data_in 														(_act_in_row_0),
//		.data_out 														(_act_in_row_reg_0)
//	);
//	register #(
//		.BIT_WIDTH 														(ACT_BITWIDTH)
//	) register_as_row_1 (
//		.clk 															(clk),
//		.reset 															(reset_as_reg_row_1),
//		.wrt_en 														(as_en_row_1),
//		.data_in 														(_act_in_row_1),
//		.data_out 														(_act_in_row_reg_1)
//	);
//	register #(
//		.BIT_WIDTH 														(ACT_BITWIDTH)
//	) register_as_row_2 (
//		.clk 															(clk),
//		.reset 															(reset_as_reg_row_2),
//		.wrt_en 														(as_en_row_2),
//		.data_in 														(_act_in_row_2),
//		.data_out 														(_act_in_row_reg_2)
//	);
////
////
//	always @ (*) begin
//		if (as_en_row_0 == 0) begin
//			act_in_row_0 	=	_act_in_row_0;
//		end
//		if (as_en_row_0 == 1 && as_mux_row_0 == 1) begin
//			act_in_row_0 	=	_act_in_row_0;
//		end
//		if (as_en_row_0 == 1 && as_mux_row_0 == 0) begin
//			act_in_row_0    =   _act_in_row_reg_0;
//		end
//	end
//	always @ (*) begin
//		if (as_en_row_1 == 0) begin
//			act_in_row_1 	=	_act_in_row_1;
//		end
//		if (as_en_row_1 == 1 && as_mux_row_1 == 1) begin
//			act_in_row_1 	=	_act_in_row_1;
//		end
//		if (as_en_row_1 == 1 && as_mux_row_1 == 0) begin
//			act_in_row_1    =   _act_in_row_reg_1;
//		end
//	end
//	always @ (*) begin
//		if (as_en_row_2 == 0) begin
//			act_in_row_2 	=	_act_in_row_2;
//		end
//		if (as_en_row_2 == 1 && as_mux_row_2 == 1) begin
//			act_in_row_2 	=	_act_in_row_2;
//		end
//		if (as_en_row_2 == 1 && as_mux_row_2 == 0) begin
//			act_in_row_2    =   _act_in_row_reg_2;
//		end
//	end
////
////
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_0;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_0;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_0;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_1;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_1;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_1;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_0_2;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_1_2;
//	wire						[PART_SUM_BITWIDTH    			-1: 0]		part_sum_in_2_2;
////
////
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_0;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_0;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_0;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_1;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_1;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_1;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_0_2;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_1_2;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		part_sum_out_2_2;
////
////
//	assign						part_sum_in_0_0				=  	0;
//	assign						part_sum_in_0_1				=  	0;
//	assign						part_sum_in_0_2				=  	0;
////
///*<(pe_temp.v, PeBuilder.py, pe_params.json, pe.v)>*/
////
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_0_0 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_0_0),
//		.write_req_w_mem													(pe_wmem_write_req_0_0),
//		.ws_en																(pe_ws_en_0_0),
//		.ws_mux																(pe_ws_mux_0_0),
//		.reset_ws_reg 														(pe_reset_ws_reg_0_0),
//		.r_addr_w_mem														(pe_wmem_r_addr_0_0),
//		.w_addr_w_mem 														(pe_wmem_w_addr_0_0),
//		.w_data_w_mem 														(pe_wmem_w_data_0_0),
//		.act_in 															(act_in_row_0),
//		.sum_in																(part_sum_in_0_0),
//		.sum_out															(part_sum_out_0_0)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_1_0 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_1_0),
//		.write_req_w_mem													(pe_wmem_write_req_1_0),
//		.ws_en																(pe_ws_en_1_0),
//		.ws_mux																(pe_ws_mux_1_0),
//		.reset_ws_reg 														(pe_reset_ws_reg_1_0),
//		.r_addr_w_mem														(pe_wmem_r_addr_1_0),
//		.w_addr_w_mem 														(pe_wmem_w_addr_1_0),
//		.w_data_w_mem 														(pe_wmem_w_data_1_0),
//		.act_in 															(act_in_row_1),
//		.sum_in																(part_sum_in_1_0),
//		.sum_out															(part_sum_out_1_0)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_2_0 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_2_0),
//		.write_req_w_mem													(pe_wmem_write_req_2_0),
//		.ws_en																(pe_ws_en_2_0),
//		.ws_mux																(pe_ws_mux_2_0),
//		.reset_ws_reg 														(pe_reset_ws_reg_2_0),
//		.r_addr_w_mem														(pe_wmem_r_addr_2_0),
//		.w_addr_w_mem 														(pe_wmem_w_addr_2_0),
//		.w_data_w_mem 														(pe_wmem_w_data_2_0),
//		.act_in 															(act_in_row_2),
//		.sum_in																(part_sum_in_2_0),
//		.sum_out															(part_sum_out_2_0)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_0_1 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_0_1),
//		.write_req_w_mem													(pe_wmem_write_req_0_1),
//		.ws_en																(pe_ws_en_0_1),
//		.ws_mux																(pe_ws_mux_0_1),
//		.reset_ws_reg 														(pe_reset_ws_reg_0_1),
//		.r_addr_w_mem														(pe_wmem_r_addr_0_1),
//		.w_addr_w_mem 														(pe_wmem_w_addr_0_1),
//		.w_data_w_mem 														(pe_wmem_w_data_0_1),
//		.act_in 															(act_in_row_0),
//		.sum_in																(part_sum_in_0_1),
//		.sum_out															(part_sum_out_0_1)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_1_1 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_1_1),
//		.write_req_w_mem													(pe_wmem_write_req_1_1),
//		.ws_en																(pe_ws_en_1_1),
//		.ws_mux																(pe_ws_mux_1_1),
//		.reset_ws_reg 														(pe_reset_ws_reg_1_1),
//		.r_addr_w_mem														(pe_wmem_r_addr_1_1),
//		.w_addr_w_mem 														(pe_wmem_w_addr_1_1),
//		.w_data_w_mem 														(pe_wmem_w_data_1_1),
//		.act_in 															(act_in_row_1),
//		.sum_in																(part_sum_in_1_1),
//		.sum_out															(part_sum_out_1_1)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_2_1 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_2_1),
//		.write_req_w_mem													(pe_wmem_write_req_2_1),
//		.ws_en																(pe_ws_en_2_1),
//		.ws_mux																(pe_ws_mux_2_1),
//		.reset_ws_reg 														(pe_reset_ws_reg_2_1),
//		.r_addr_w_mem														(pe_wmem_r_addr_2_1),
//		.w_addr_w_mem 														(pe_wmem_w_addr_2_1),
//		.w_data_w_mem 														(pe_wmem_w_data_2_1),
//		.act_in 															(act_in_row_2),
//		.sum_in																(part_sum_in_2_1),
//		.sum_out															(part_sum_out_2_1)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_0_2 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_0_2),
//		.write_req_w_mem													(pe_wmem_write_req_0_2),
//		.ws_en																(pe_ws_en_0_2),
//		.ws_mux																(pe_ws_mux_0_2),
//		.reset_ws_reg 														(pe_reset_ws_reg_0_2),
//		.r_addr_w_mem														(pe_wmem_r_addr_0_2),
//		.w_addr_w_mem 														(pe_wmem_w_addr_0_2),
//		.w_data_w_mem 														(pe_wmem_w_data_0_2),
//		.act_in 															(act_in_row_0),
//		.sum_in																(part_sum_in_0_2),
//		.sum_out															(part_sum_out_0_2)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_1_2 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_1_2),
//		.write_req_w_mem													(pe_wmem_write_req_1_2),
//		.ws_en																(pe_ws_en_1_2),
//		.ws_mux																(pe_ws_mux_1_2),
//		.reset_ws_reg 														(pe_reset_ws_reg_1_2),
//		.r_addr_w_mem														(pe_wmem_r_addr_1_2),
//		.w_addr_w_mem 														(pe_wmem_w_addr_1_2),
//		.w_data_w_mem 														(pe_wmem_w_data_1_2),
//		.act_in 															(act_in_row_1),
//		.sum_in																(part_sum_in_1_2),
//		.sum_out															(part_sum_out_1_2)
//	);
//	pe #(
//		.MEM_ADDR_BITWIDTH													(WGT_MEM_ADDR_BITWIDTH),
//		.ACT_BITWIDTH														(ACT_BITWIDTH),
//		.WGT_BITWIDTH 														(WGT_BITWIDTH),
//		.SUM_IN_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.INTER_BITWIDTH														(PE_INTER_BITWIDTH),
//		.TRUNCATION_MODE 													(PE_TRUNC_MODE)
//	) pe_2_2 (
//		.clk																(clk),
//		.reset_reg															(reset_pe_reg),
//		.wrt_en_reg															(pe_wrt_en_reg),
//		.reset_w_mem 														(pe_wmem_reset),
//		.read_req_w_mem														(pe_wmem_read_req_2_2),
//		.write_req_w_mem													(pe_wmem_write_req_2_2),
//		.ws_en																(pe_ws_en_2_2),
//		.ws_mux																(pe_ws_mux_2_2),
//		.reset_ws_reg 														(pe_reset_ws_reg_2_2),
//		.r_addr_w_mem														(pe_wmem_r_addr_2_2),
//		.w_addr_w_mem 														(pe_wmem_w_addr_2_2),
//		.w_data_w_mem 														(pe_wmem_w_data_2_2),
//		.act_in 															(act_in_row_2),
//		.sum_in																(part_sum_in_2_2),
//		.sum_out															(part_sum_out_2_2)
//	);
////
////
//	assign						part_sum_in_1_0 	=	part_sum_out_0_0;
//	assign						part_sum_in_2_0 	=	part_sum_out_1_0;
//	assign						part_sum_in_1_1 	=	part_sum_out_0_1;
//	assign						part_sum_in_2_1 	=	part_sum_out_1_1;
//	assign						part_sum_in_1_2 	=	part_sum_out_0_2;
//	assign						part_sum_in_2_2 	=	part_sum_out_1_2;
////
////
//	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_0;
//	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_1;
//	wire						[PART_SUM_BITWIDTH			 	-1: 0]		systolic_col_data_2;
////
////
//	assign						systolic_col_data_0 	=			part_sum_out_2_0;
//	assign						systolic_col_data_1 	=			part_sum_out_2_1;
//	assign						systolic_col_data_2 	=			part_sum_out_2_2;
////
////
//	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_0;
//	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_1;
//	wire						[BIAS_BITWIDTH 					-1: 0]		bias_col_2;
////
////
//	assign						bias_col_0			= 			bias_in[(0+1)*BIAS_BITWIDTH-1:0*BIAS_BITWIDTH];
//	assign						bias_col_1			= 			bias_in[(1+1)*BIAS_BITWIDTH-1:1*BIAS_BITWIDTH];
//	assign						bias_col_2			= 			bias_in[(2+1)*BIAS_BITWIDTH-1:2*BIAS_BITWIDTH];
////
////
//	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_0;
//	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_1;
//	wire						[PART_SUM_BITWIDTH   			-1: 0]		acc_out_col_2;
////
////
//	accumulator #(
//		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
//	) accumulator_col_0 (
//		.clk																(clk),
//		.reset 																(acc_reset),
//		.wrt_en 															(acc_wrt_en),
//		.acc_logic 															(os_en[0]),
//		.part_sum_in 														(systolic_col_data_0),
//		.part_sum_out 														(acc_out_col_0)
//	);
//	accumulator #(
//		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
//	) accumulator_col_1 (
//		.clk																(clk),
//		.reset 																(acc_reset),
//		.wrt_en 															(acc_wrt_en),
//		.acc_logic 															(os_en[1]),
//		.part_sum_in 														(systolic_col_data_1),
//		.part_sum_out 														(acc_out_col_1)
//	);
//	accumulator #(
//		.IN_SUM_BITWIDTH 													(PART_SUM_BITWIDTH),
//		.ACC_DATA_BITWIDTH 													(PART_SUM_BITWIDTH)
//	) accumulator_col_2 (
//		.clk																(clk),
//		.reset 																(acc_reset),
//		.wrt_en 															(acc_wrt_en),
//		.acc_logic 															(os_en[2]),
//		.part_sum_in 														(systolic_col_data_2),
//		.part_sum_out 														(acc_out_col_2)
//	);
////
////
//	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_0;
//	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_1;
//	wire 						[PART_SUM_BITWIDTH				-1: 0]		part_out_in_col_2;
////
////
//	assign						part_out_in_col_0 		= 		part_out_in[(0+1)*PART_SUM_BITWIDTH-1:0*PART_SUM_BITWIDTH];
//	assign						part_out_in_col_1 		= 		part_out_in[(1+1)*PART_SUM_BITWIDTH-1:1*PART_SUM_BITWIDTH];
//	assign						part_out_in_col_2 		= 		part_out_in[(2+1)*PART_SUM_BITWIDTH-1:2*PART_SUM_BITWIDTH];
////
////
//	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_0;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_1;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		bias_out_opnd_col_2;
////
////
//	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_0;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_1;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		acc_out_mem_opnd_col_2;
////

//	always @ (*) begin
//		if (bias_out_sel == 0) begin
////
//			bias_out_opnd_col_0		=		part_out_in_col_0;
//			bias_out_opnd_col_1		=		part_out_in_col_1;
//			bias_out_opnd_col_2		=		part_out_in_col_2;
////
//		end
//		if (bias_out_sel == 1) begin
////
//			bias_out_opnd_col_0       =  		bias_col_0;
//			bias_out_opnd_col_1       =  		bias_col_1;
//			bias_out_opnd_col_2       =  		bias_col_2;
////
//		end
//	end

//	always @ (*) begin
//		if (acc_out_mem_sel == 0) begin
////
//			acc_out_mem_opnd_col_0    =		part_out_in_col_0;
//			acc_out_mem_opnd_col_1    =		part_out_in_col_1;
//			acc_out_mem_opnd_col_2    =		part_out_in_col_2;
////
//		end
//		if (acc_out_mem_sel == 1) begin
////
//			acc_out_mem_opnd_col_0       =  	acc_out_col_0;
//			acc_out_mem_opnd_col_1       =  	acc_out_col_1;
//			acc_out_mem_opnd_col_2       =  	acc_out_col_2;
////
//		end
//	end

////
//	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_0;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_1;
//	reg							[PART_SUM_BITWIDTH				-1: 0]		systolic_data_out_col_2;
////
////
//	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_0;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_1;
//	wire						[PART_SUM_BITWIDTH				-1: 0]		adder_out_col_2;
////
////
//	adder #(
//		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
//		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
//		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
//	) adder_col_0 (
//		.adder_en 															(bias_mem_adder_en),
//		.in_1 																(acc_out_mem_opnd_col_0),
//		.in_2 																(bias_out_opnd_col_0),
//		.out 																(adder_out_col_0)
//	);
//	adder #(
//		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
//		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
//		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
//	) adder_col_1 (
//		.adder_en 															(bias_mem_adder_en),
//		.in_1 																(acc_out_mem_opnd_col_1),
//		.in_2 																(bias_out_opnd_col_1),
//		.out 																(adder_out_col_1)
//	);
//	adder #(
//		.IN1_BITWIDTH 														(PART_SUM_BITWIDTH),
//		.IN2_BITWIDTH 														(BIAS_BITWIDTH),
//		.OUT_BITWIDTH 														(PART_SUM_BITWIDTH)
//	) adder_col_2 (
//		.adder_en 															(bias_mem_adder_en),
//		.in_1 																(acc_out_mem_opnd_col_2),
//		.in_2 																(bias_out_opnd_col_2),
//		.out 																(adder_out_col_2)
//	);
////
////Figure out if we need a register here or not (probably not becayse we have out mem!)
//	always @(*) begin

//		if (out_wr_sel == 0) begin
////
//			systolic_data_out_col_0 	= acc_out_col_0;
//			systolic_data_out_col_1 	= acc_out_col_1;
//			systolic_data_out_col_2 	= acc_out_col_2;
////
//		end
//		if (out_wr_sel == 1) begin
////
//			systolic_data_out_col_0 	= adder_out_col_0;
//			systolic_data_out_col_1 	= adder_out_col_1;
//			systolic_data_out_col_2 	= adder_out_col_2;
////
//		end
//	end

//	assign						data_out 					   =  			{systolic_data_out_col_2,systolic_data_out_col_1,systolic_data_out_col_0};

//endmodule