//%	@file	close.v
//%	@brief	本文件定义close模块


//%			
//%	@details	关闭连接操作
//%	step1:	确定数据包AXI-STREAM信号是否还有数据，若有的话，先读取完数据到last信号后，不再接收数据。若没有数据进入step2
//%	step2:	确定发送缓存是否已经发送完全，若没有，等数据数据完成后进入Step3
//%	step3:	发送关闭控制信号


module(
	input			core_clk,						//%	核心模块时钟
	input			core_rst_n,						//%	核心模块复位(低信号复位)
	
	output	[31:0]	udt_state_o ,						//%	连接状态
	output	state_valid_o ,								//%	连接状态有效
	input	state_ready_i ,								//% 连接状态就绪
	
	input			Req_Close_i,				//%	关闭请求信号有效(用户发起)
	output			Res_Close_o,				//%	关闭请求信号就绪(用户发起)
	input			SND_BUFFER_EMPTY_i	,		//%	发送缓冲为空
	input			REV_BUFFER_EMPTY_i			//%	接瘦缓冲为空
	
);



endmodule