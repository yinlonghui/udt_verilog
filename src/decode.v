//%	@file	decode.v
//%	@brief	本文件定义decode模块
//%	@details

//%	本模块解码对端的UDP帧协议
//% @details
//%		UDT协议包格式：
//%			控制包：
//%			Handshake:
//%			Keep-live:
//%			NAK:
//%			ACK:
//%			Light-ACK
//%			ACK2:
//%			数据包：
//%		解析出对应内容,发送到相应的处理模块


module	decode(
	input	core_clk ,								//%	时钟
	input	core_rst_n ,							//%	复位
	input	[C_S_AXI_DATA_WIDTH-1:0]	in_tdata,	//%	UDP数据包
	input	[C_S_AXI_DATA_WIDTH/8-1:0]	in_tkeep,	//%	UDP字节使能
	input	in_tvalid , 							//%	UDP包有效
	output	reg	in_tready	,						//%	UDP包就绪
	input	in_tlast	,							//%	UDP包结束
	
	output	reg	[C_S_AXI_DATA_WIDTH-1:0]	out_tdata ,	//%	输出包
	output	reg	out_tlast ,								//%	输出包结束
	output	reg	out_tvalid	,							//%	输出包有效
	output	reg	[C_S_AXI_DATA_WIDTH/8-1:0]	out_tkeep ,	//%	输出包使能
	input	out_tready,									//%	输出包就绪

	output	reg	Data_en	,								//%	数据有效
	output	reg	ACK_en	,								//%	ACK包有效
	output	reg	ACK2_en	,								//%	ACK2包有效
	output	reg	Keep_live_en ,							//%	Keep-live包有效
	output	reg	NAK_en	,								//%	NAK包有效
	output	reg	Handshake_en 							//%	握手包有效

);



endmodule

