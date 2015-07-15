//%	@file	StateManager.v
//%	@brief	本文件定义StateManager模块

//%	StateManager模块处理Socket管理器中多种状态，编码成udt_state输出
//%	@details


module	StateManager	#(
 #(
	parameter   LISTENING  =  8'b0000_0001 ,                 
	parameter	CONNECTING =  8'b0000_0010 ,			
	parameter   CONNECTED  =  8'b0000_0100 ,                  
    parameter	CLOSING    =  8'b0000_1000 ,                    
	parameter	SHUTDOWN   =  8'b0001_0000 ,                   
	parameter	BROCKEN    =  8'b0010_0000 
)(
	input	core_clk	,	//%	时钟信号
	input	core_rst_n	,	//%	时钟复位信号(低有效)
	
	
	input	listening_i ,
	input	listening_valid_i ,
	output	listening_ready_o ,

	input	connecting_i ,
	input	connecting_valid_i ,
	output	connecting_ready_o ,


	input	closing_i	,
	input	closing_valid_i	,
	output	closing_ready_o	,

	input	shutdown_i ,
	input	shutdown_valid_i ,
	output	shutdown_ready_o ,


	input	brocken_i  ,
	input	brocken_valid_i ,
	output	brocken_ready_o  ,
	
	output	s_brocken_o  ,
	output	s_brocken_valid_o ,
	input	s_brocken_ready_i ,
	
	
	output	[31:0]	udt_state_o ,
	output	state_valid_o	,
	input	state_ready_i


);



endmodule