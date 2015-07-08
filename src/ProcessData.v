//%	@file	ProcessData.v
//%	@brief	本文件定义ProcessData模块



//%	本模块是处理数据包
//% @details	



module ProcessData(
	input	core_clk,							//%	核心模块时钟
	input	core_rst_n,							//%	核心模块复位(低信号复位)
	input	[63:0]	DATA_tdata ,				//%	NAK数据包
	input	[7:0]	DATA_tkeep ,				//%	NAK包字节使能
	input			DATA_tvalid,				//%	NAK包有效信号
	output			DATA_tready,				//%	NAK包就绪信号
	input			DATA_tlast					//%	NAK包结束信号



);






endmodule