//%	@file	udt_core.v
//%	@brief	本文定义UDT核心模块
//% @details

//%	本模块例化各个功能模块
//% @details


module	udt_core(
	input	core_clk	,								//% 	udt模块时钟信号
	input	core_rst_n	,								//%	udt模块复位信号
		
	input		udp_tx_tready    ,						//%	UDP传输数据-发送数据就绪
	output		udp_tx_tvalid    ,						//%	UDP传输数据-发送数据有效
	output		udp_tx_tlast     ,						//%	UDP传输数据-发送数据结束
	output	[ 7:0]	udp_tx_tkeep     ,					//%	UDP传输数据-发送数据字节有效
	output	[63:0]	udp_tx_tdata     ,					//%	UDP传输数据-发送数据包
	output	[47:0]	udp_tx_mac_src   ,					//%	UDP传输数据-发送源MAC地址
	output	[47:0]	udp_tx_mac_dest  ,					//%	UDP传输数据-发送目的MAC地址
	output	[31:0]	udp_tx_ip_src    ,					//%	UDP传输数据-发送源IP地址
	output	[31:0]	udp_tx_ip_dest    ,					//%	UDP传输数据-发送目的IP地址
	output	[15:0]	udp_tx_port_src   ,					//%	UDP传输数据-发送源端口号
	output	[15:0]	udp_tx_port_dest,					//%	UDP传输数据-发送目的端口号
	
	output		udp_rx_tready    ,						//%	UDP传输数据-接收数据就绪
	input       udp_rx_tvalid    ,						//%	UDP传输数据-接收数据有效
	input		udp_rx_tlast     ,						//%	UDP传输数据-接收数据包结束
	input	[ 7:0]	udp_rx_tkeep     ,					//%	UDP传输数据-接收数据字节有效
	input 	[63:0]	udp_rx_tdata     ,					//%	UDP传输数据-接收数据包
	
	
	input	tx_axis_tvalid,								//%	UDT传输数据-发送数据有效
	output	tx_axis_tready,								//%	UDT传输数据-发送数据就绪
	input	[63:0]	tx_axis_tdata,						//%	UDT传输数据-发送数据包
	input	[7:0]	tx_axis_tkeep,						//%	UDT传输数据-发送数据字节有效
	input	tx_axis_tlast,								//%	UDT传输数据-发送数据包结束
	
	
	output	rx_axis_tvalid,								//%	UDT传输数据-接收数据有效
	input	rx_axis_tready,								//%	UDT传输数据-接收数据就绪
	output	rx_axis_tdata,								//%	UDT传输数据-接收数据包
	output	rx_axis_tkeep,								//%	UDT传输数据-接收数据字节有效
	output	rx_axis_tlast,								//%	UDT传输数据-接收数据包结束
		
		
	output	[31:0]	udt_state ,							//%	连接状态
	output	state_valid,								//%	连接状态有效
	input	state_ready,								//%	连接状态就绪
	
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
	input	[511:0]s_axi_rdata,							//%	DDR3-读数据
	input	[1:0]s_axi_rresp,							//%	DDR3-读应答
	input	s_axi_rlast,								//%	DDR3-读结束
	input	s_axi_rvalid,								//%	DDR3-读有效
	input	init_calib_complete							//% DDR3-初始化完成


);


endmodule