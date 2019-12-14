`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:17:34 PM
// Design Name: 
// Module Name: pe
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

module pe #(
	parameter					MEM_ADDR_BITWIDTH				= 10,
	parameter					ACT_BITWIDTH					= 8,
	parameter					WGT_BITWIDTH					= 8,
	parameter					SUM_IN_BITWIDTH					= 32,
	parameter					INTER_BITWIDTH					= 33,
	parameter					TRUNCATION_MODE					= "MSB",
	parameter					SUM_OUT_BITWIDTH				= SUM_IN_BITWIDTH
)(
	input														clk,
	input														reset_reg,
	input														wrt_en_reg,
	input														reset_w_mem,
	input														read_req_w_mem,
	input														write_req_w_mem,
	input														ws_en,
	input														ws_mux,
	input														reset_ws_reg,
	input						[MEM_ADDR_BITWIDTH -1: 0]		r_addr_w_mem,
	input						[MEM_ADDR_BITWIDTH -1: 0]		w_addr_w_mem,
	input						[WGT_BITWIDTH      -1: 0]		w_data_w_mem,
	input						[ACT_BITWIDTH      -1: 0]		act_in,
	input						[SUM_IN_BITWIDTH   -1: 0]		sum_in,
	output						[SUM_OUT_BITWIDTH  -1: 0]		sum_out
);
	
	wire						[WGT_BITWIDTH	  -1: 0]		_wgt_read_;
	
	scratchpad #(
		.DATA_BITWIDTH											(WGT_BITWIDTH),
		.ADDR_BITWIDTH											(MEM_ADDR_BITWIDTH)
	) weight_scratchpad (
		.clk													(clk),
		.reset													(reset_w_mem),
		.read_req												(read_req_w_mem),
		.write_req   											(write_req_w_mem),
		.r_addr													(r_addr_w_mem),
		.w_addr													(w_addr_w_mem),
		.w_data													(w_data_w_mem),
		.r_data													(_wgt_read_)
	);
	
// weight-stationary logic	

	wire						[WGT_BITWIDTH	  -1: 0]		_wgt_read_reg;
	reg						    [WGT_BITWIDTH	  -1: 0]		_wgt_read;
	
	register #(
		.BIT_WIDTH										(WGT_BITWIDTH)
	) register_ws(
		.clk											(clk),
		.reset											(reset_ws_reg),
		.wrt_en											(ws_en),
		.data_in										(_wgt_read_),
		.data_out 										(_wgt_read_reg)	
		);
	always @ (*) begin	
		if (ws_en == 0) begin
			_wgt_read	=	_wgt_read_;
		end
		// if ws, at the first cycle the data directs to the macc logic,
		//but for the rest cycles will be read from the register

		if (ws_mux == 1) begin			
			_wgt_read	=	_wgt_read_;
		end
		
		if (ws_mux == 0) begin
			_wgt_read	=	_wgt_read_reg;
		end 
	end
	
	
	
	
	wire						[INTER_BITWIDTH   -1: 0]		_macc_out;
	
	macc #(
		.ACT_BITWIDTH											(ACT_BITWIDTH),
		.WGT_BITWIDTH											(WGT_BITWIDTH),
		.SUM_IN_BITWIDTH										(SUM_IN_BITWIDTH),
		.INTER_BITWIDTH											(INTER_BITWIDTH)
	) macc_inst (
		.a_in													(act_in),
		.w_in													(_wgt_read),
		.sum_in													(sum_in),
		.out													(_macc_out)
	);
		
	wire						[SUM_OUT_BITWIDTH -1: 0]		_truncator_out;
	
	truncator #(
		.TRUNCATION_MODE										(TRUNCATION_MODE),
		.DATA_IN_BITWIDTH										(INTER_BITWIDTH),
		.DATA_OUT_BITWIDTH										(SUM_OUT_BITWIDTH)
	) truncator_inst (
		.data_in												(_macc_out),
		.data_out												(_truncator_out)
	);
	
	
	register #(
		.BIT_WIDTH												(SUM_OUT_BITWIDTH)
	) register_out(
		.clk													(clk),
		.reset													(reset_reg),
		.wrt_en													(wrt_en_reg),
		.data_in												(_truncator_out),
		.data_out												(sum_out)	
	);

	
endmodule