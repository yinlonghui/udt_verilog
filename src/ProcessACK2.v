//%	@file	ProcessACK2.v
//%	@brief	本文件定义ProcessACK2模块



//%	本模块是处理ACK2控制包
//% @details	



module	ProcessACK2(
	input	core_clk,							//%	核心模块时钟
	input	core_rst_n,							//%	核心模块复位(低信号复位)
	input	[63:0]	ACK2_tdata ,					//%	ACK2数据包
	input	[7:0]	ACK2_tkeep ,					//%	ACK2包字节使能
	input			ACK2_tvalid,					//%	ACK2包有效信号
	output			ACK2_tready,					//%	ACK2包就绪信号
	input			ACK2_tlast					//%	ACK2包结束信号



);






endmodule