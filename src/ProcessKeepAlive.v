//%	@file	ProcessKeepAlive.v
//%	@brief	本文件定义ProcessKeepAlive模块



//%	本模块是处理keep-alive控制包
//% @details	



module	ProcessKeepAlive(
	input	core_clk,							//%	核心模块时钟
	input	core_rst_n,							//%	核心模块复位(低信号复位)
	input	[63:0]	processKeepAlive_tdata ,					//%	ACK2数据包
	input	[7:0]	processKeepAlive_tkeep ,					//%	ACK2包字节使能
	input			processKeepAlive_tvalid,					//%	ACK2包有效信号
	output			processKeepAlive_tready,					//%	ACK2包就绪信号
	input			processKeepAlive_tlast					//%	ACK2包结束信号

);






endmodule