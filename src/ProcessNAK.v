//%	@file	ProcessNAK.v
//%	@brief	本文件定义ProcessNAK模块



//%	本模块是处理NAK控制包
//% @details	



module	ProcessNAK(
	input	core_clk,							//%	核心模块时钟
	input	core_rst_n,							//%	核心模块复位(低信号复位)
	input	[63:0]	NAK_tdata ,					//%	NAK数据包
	input	[7:0]	NAK_tkeep ,					//%	NAK包字节使能
	input			NAK_tvalid,					//%	NAK包有效信号
	output			NAK_tready,					//%	NAK包就绪信号
	input			NAK_tlast					//%	NAK包结束信号



);






endmodule