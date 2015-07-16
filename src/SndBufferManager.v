//%	@file	SndBufferManager.v
//%	@brief	本文件定义SndBufferManager模块

//%	@brief	SndBufferManager是发送缓存管理器

module	SndBufferManager#(
	parameter	C_S_AXI_ID_WIDTH  = 8'd4 ,				//% 定义ID位宽
	parameter	C_S_AXI_DATA_WIDTH = 32'd512,			//%	定义数据位宽
	parameter	C_S_AXI_ADDR_WIDTH = 32'd32 ,			//%	定义地址位宽
	parameter	SndBuffer_START	=	32'h0	,			//%	定义发送起始位置
	parameter	SndBuffer_MAX_OFFESET	=	32'h1000		//%	定义发送最大位移
)(
	input	core_clk	,	//%	时钟信号
	input	core_rst_n	,	//%	时钟复位信号(低有效)
	
	
	input	[63:0]	sndbuffer_tdata_i,					//%	发送缓存数据据包
	input	[7:0]	sndbuffer_tkeep_i,					//%	发送缓存数据字节使能
	input			sndbuffer_tvalid_i,					//%	发送缓存数据据包有效信号
	output			sndbuffer_tready_o,					//%	发送缓存数据据包就绪信号
	input			sndbuffer_tlast_i,					//%	发送缓存数据据包结束信号
	
	input	[31:0]	ACK_data_offset_i	,				//%	ACK位移
	output			ACK_data_ready_o	,				//%	ACK就绪
	input			ACK_data_valid_i	,				//%	ACK有效
	
	input			first_snd_valid_i	,				//%	第一次发送有效信号
	output			first_snd_ready_o	,				//%	第一次发送就绪信号
	
	input	[31:0]	retransmit_offset_i	,				//%	重发位移信号
	input			retransmit_valid_i	,				//%	重发有效信号
	output			retransmit_ready_o  ,
	
	input			Max_PayloadSize_i	,				//%	最大负载信号
	input			Max_PayloadSize_valid ,				//%	最大负载有效信号
	
	
	output	[63:0]	first_data_tdata_o	,				//%	第一次发送数据包
	output	[7:0]	first_data_tkeep_o	,				//%	第一次发送数据字节使能
	output			first_data_tvalid_o	,				//%	第一次发送数据有效信号
	input			first_data_tready_i	,				//%	第一次发送数据就绪信号
	output			first_data_tlast	,				//%	第一次发送数据包结束
	
	
	output	[63:0]	retransmit_tdata_o	,				//%	重发数据包
	output	[7:0]	retransmit_tkeep_o	,				//%	重发数据包字节使能
	output			retransmit_tlast_o	,				//%	重发数据包结束信号
	output			retransmit_tvalid_o	,				//%	重发数据包有效信号
	input			retransmit_tready_i	,				//%	重发数据包就绪信号
	
	input			buffer_size_ready_i	,				//%	缓存大小就绪信号
	output			buffer_size_valid_o ,				//%	缓存大小有效信号
	output	[31:0]	buffer_size_o	,					//%	缓存大小
	
	output  [C_S_AXI_ID_WIDTH-1:0]s_axi_awid,			//%	DDR3-写地址ID
	output  [C_S_AXI_ADDR_WIDTH-1:0]s_axi_awaddr,		//%	DDR3-写地址
	output  [7:0]s_axi_awlen,							//%	DDR3-突发式写的长度
	output  [2:0]s_axi_awsize,							//%	DDR3-突发式写的大小
	output  [1:0]s_axi_awburst,							//%	DDR3-突发式写的类型
	output  [0:0]s_axi_awlock,							//%	DDR3-写锁类型
	output  [3:0]s_axi_awcache,							//%	DDR3-写Cache类型
	output  [2:0]s_axi_awprot,							//%	DDR3-写保护类型
	output  [3:0]s_axi_awqos,							//%	DDR3-unknown port
	output  s_axi_awvalid,								//%	DDR3-写地址有效
	input	s_axi_awready,								//%	DDR3-写地址就绪
	output  [C_S_AXI_DATA_WIDTH-1:0]s_axi_wdata,		//%	DDR3-写数据
	output  [(C_S_AXI_DATA_WIDTH/8)-1:0]s_axi_wstrb,	//%	DDR3-写数据字节时能
	output  s_axi_wlast,								//%	DDR3-写结束
	output  s_axi_wvalid,								//%	DDR3-写数据有效
	input	s_axi_wready,								//%	DDR3-写数据就绪
	output  s_axi_bready,								//%	DDR3-写应答就绪
	input	[C_S_AXI_ID_WIDTH-1:0]s_axi_bid,			//%	DDR3-应答ID
	input	[1:0]s_axi_bresp,							//%	DDR3-写数据应答
	input	s_axi_bvalid,								//%	DDR3-写应答有效
	
	output  [C_S_AXI_ID_WIDTH-1:0]s_axi_arid,			//%	DDR3-读地址ID
	output  [C_S_AXI_ADDR_WIDTH-1:0]s_axi_araddr,		//%	DDR3-读地址
	output  [7:0]s_axi_arlen,							//%	DDR3-突发式读的长度
	output  [2:0]s_axi_arsize,							//%	DDR3-突发式读的大小
	output  [1:0]s_axi_arburst,							//%	DDR3-突发式读的类型
	output  [0:0]s_axi_arlock,							//%	DDR3-读锁类型
	output  [3:0]s_axi_arcache,							//%	DDR3-读Cache类型
	output  [2:0]s_axi_arprot,							//%	DDR3-读保护类型
	output  [3:0]s_axi_arqos,							//%	DDR3-unknown port
	output  s_axi_arvalid,								//%	DDR3-读地址有效
	input	s_axi_arready,								//%	DDR3-读地址就绪
	output  s_axi_rready,								//%	DDR3-读数据就绪
	input	[C_S_AXI_ID_WIDTH-1:0]s_axi_rid,			//%	DDR3-读ID
	input	[C_S_AXI_DATA_WIDTH-1:0]s_axi_rdata,		//%	DDR3-读数据
	input	[1:0]s_axi_rresp,							//%	DDR3-读应答
	input	s_axi_rlast,								//%	DDR3-读结束
	input	s_axi_rvalid,								//%	DDR3-读有效
	input	init_calib_complete							//% DDR3-初始化完成
	
);



endmodule