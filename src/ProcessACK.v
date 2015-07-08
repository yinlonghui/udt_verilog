//%	@file	ProcessACK.v
//%	@brief	本文件定义ProcessACK模块



//%	本模块是处理ACK控制包
//% @details	



module	ProcessACK(
	input	core_clk,							//%	核心模块时钟
	input	core_rst_n,							//%	核心模块复位(低信号复位)
	input	[63:0]	ACK_tdata ,					//%	ACK数据包
	input	[7:0]	ACK_tkeep ,					//%	ACK包字节使能
	input			ACK_tvalid,					//%	ACK包有效信号
	output			ACK_tready,					//%	ACK包就绪信号
	input			ACK_tlast					//%	ACK包结束信号



);






endmodule