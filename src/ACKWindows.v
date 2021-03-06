﻿//%	@file	ACKWindows.v
//%	@brief	本文件定义ACKWindows模块

//%	@brief	ACKWindows模块用于管理ACKWindows

module	ACKWindows(
	input	core_clk	,	//%	时钟信号
	input	core_rst_n	,	//%	时钟复位信号(低有效)
	
	
	input	seq_i		,	//%
	input	seq_valid_i ,	
	output	seq_ready_o	,
	
	output	ack_seq_o	,	//%
	output	ack_seq_valid_o	,
	input	ack_seq_ready_i ,
	
	output	[31:0]	RTT_o	 ,
	output	RTT_valid_o		,
	input	RTT_ready_i		,
	
	input	store_seq_i ,
	input	store_ack_i ,
	output	store_ready_o ,
	input	store_valid_i ,
	
	
	
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