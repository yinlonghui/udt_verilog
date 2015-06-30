﻿
//% @file   udt_interface.v
//% @brief  本文件定义UDT接口模块.
//% @details  version 0.1


//% 
//% @details   

module  udt_interface #(
	parameter	C_S_AXI_ID_WIDTH  = 8'd4 ,				//% 定义ID位宽
	parameter	C_S_AXI_DATA_WIDTH = 32'd512,			//%	定义数据位宽
	parameter	C_S_AXI_ADDR_WIDTH = 32'd32 ,			//%	定义地址位宽
	parameter	FPGA_MAC_SRC	= 48'hba0203040506,		//%	定义源MAC地址
	parameter	FPGA_MAC_DES	= 48'hffffffffffff,		//%	定义目的MAC地址
	parameter	FPGA_IP_SRC		= 32'hc0a8006f,			//%	定义源IP地址
	parameter	FPGA_IP_DES_DEAFAULT = 32'hc0a800ff,	//%	定义目的默认IP地址 (广播)
	parameter	PORT	=	32'd 10086					//%	定义监听端口号
)(

	input	ctrl_s_axi_aclk,							//% 控制寄存器-时钟信号
	input   ctrl_s_axi_aresetn,							//% 控制寄存器-复位信号
	input	[31:0]	ctrl_s_axi_awaddr,					//%	控制寄存器-写地址信号
	input	ctrl_s_axi_awvalid,							//% 控制寄存器-写地址有效
	output	ctrl_s_axi_awready,							//%	控制寄存器-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,					//%	控制寄存器-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,					//%	控制寄存器-写操作字节使能
	input	ctrl_s_axi_wvalid,							//%	控制寄存器-写数据有效
	output	ctrl_s_axi_wready,							//%	控制寄存器-写数据就绪
	output	[1:0]	ctrl_s_axi_bresp,					//%	控制寄存器-写数据应答
	output	ctrl_s_axi_bvalid,							//%	控制寄存器-写应答有效
	input	ctrl_s_axi_bready,							//%	控制寄存器-写应答就绪
	input   [31:0]	ctrl_s_axi_araddr,					//% 控制寄存器-读地址信号
	input	ctrl_s_axi_arvalid,							//% 控制寄存器-读地址有效
	output	ctrl_s_axi_arready,							//% 控制寄存器-读地址就绪
	output  [31:0]	ctrl_s_axi_rdata,					//%	控制寄存器-读操作数据
	output	[1:0]	ctrl_s_axi_rresp,					//%	控制寄存器-读数据应答
	output	ctrl_s_axi_rvalid,							//%	控制寄存器-读数据有效
	input	ctrl_s_axi_rready,							//%	控制寄存器-读数据就绪
	
	input	tx_axis_aclk,								//% UDT传输数据-发送时钟信号
	input	tx_axis_aresetn,							//% UDT传输数据-发送复位信号（低有效）
	input	tx_axis_tvalid,								//%	UDT传输数据-发送数据有效
	output	tx_axis_tready,								//%	UDT传输数据-发送数据就绪
	input	[63:0]	tx_axis_tdata,						//%	UDT传输数据-发送数据包
	input	[7:0]	tx_axis_tkeep,						//%	UDT传输数据-发送数据字节有效
	input	tx_axis_tlast,								//%	UDT传输数据-发送数据包结束
	
	input	rx_axis_aclk,								//%	UDT传输数据-接收时钟信号
	input	rx_axis_aresetn,							//%	UDT传输数据-接收复位信号（低有效）
	output	rx_axis_tvalid,								//%	UDT传输数据-接收数据有效
	input	rx_axis_tready,								//%	UDT传输数据-接收数据就绪
	output	rx_axis_tdata,								//%	UDT传输数据-接收数据包
	output	rx_axis_tkeep,								//%	UDT传输数据-接收数据字节有效
	output	rx_axis_tlast,								//%	UDT传输数据-接收数据包结束
	
	input		udp_clk	,								//%	UDP传输数据-UDP时钟(156Mhz)
	input		udp_areset,								//%	UDP传输数据-UDP复位(高复位)	
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
	input	[47:0]	udp_rx_mac_src   ,					//%	UDP传输数据-接收源MAC地址
	input	[47:0]	udp_rx_mac_dest  ,					//%	UDP传输数据-接收目的MAC地址
	input	[31:0]	udp_rx_ip_src    ,					//%	UDP传输数据-接收源IP地址
	input	[31:0] udp_rx_ip_dest   ,					//%	UDP传输数据-接收目的IP地址
	input	[15:0] udp_rx_port_src  ,					//%	UDP传输数据-接收源端口号
	input	[15:0] udp_rx_port_dest ,					//%	UDP传输数据-接收目的端口号
	
	
	input		ui_clk	,								//%	DDR3-时钟信号
	input		ui_aresetn	,							//%	DDR3-复位信号（低有效）
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


/*	
*		fifo   asyc  fifo   UDT->SEND
*/

wire	core_udt_tx_axis_tvalid;
wire	core_udt_tx_axis_tready;
wire	[63:0]	core_udt_tx_axis_tdata;
wire	[7:0]	core_udt_tx_axis_tkeep;
wire	core_udt_tx_axis_tlast;

wire	[31:0]	fifo_udt_tx_inst_data_count;
wire	[31:0]	fifo_udt_tx_inst_wr_data_count;
wire	[31:0]	fifo_udt_tx_inst_rd_data_count;

wire	fifo_tx_axis_tready ;
assign	tx_axis_tready = fifo_tx_axis_tready ; // &&   udt连接正常 && 没有发送关闭UDT操作



axis_data_fifo_64_asyn	fifo_udt_tx_inst(
	.s_axis_aclk(tx_axis_aclk),
	.s_axis_aresetn(tx_axis_aresetn),
	
	.m_axis_aclk(ui_clk),
	.m_axis_aresetn(ui_aresetn),
	
	.s_axis_tvalid(tx_axis_tvalid), 
	.s_axis_tready(fifo_tx_axis_tready), 
	.s_axis_tdata(tx_axis_tdata), 
	.s_axis_tkeep(tx_axis_tkeep), 
	.s_axis_tlast(tx_axis_tlast), 
	.m_axis_tvalid(core_udt_tx_axis_tvalid), 
	.m_axis_tready(core_udt_tx_axis_tready), 
	.m_axis_tdata(core_udt_tx_axis_tdata), 
	.m_axis_tkeep(core_udt_tx_axis_tkeep), 
	.m_axis_tlast(core_udt_tx_axis_tlast), 
	.axis_data_count(fifo_udt_tx_inst_data_count), 
	.axis_wr_data_count(fifo_udt_tx_inst_wr_data_count), 
	.axis_rd_data_count(fifo_udt_tx_inst_rd_data_count)
);

/*	fifo   asyc	 fifo	UDT->RECV	*/
wire	core_udt_rx_axis_tvalid;
wire	core_udt_rx_axis_tready;
wire	[63:0]	core_udt_rx_axis_tdata;
wire	[7:0]	core_udt_rx_axis_tkeep;
wire	core_udt_rx_axis_tlast;

wire	[31:0]	fifo_udt_rx_inst_data_count;
wire	[31:0]	fifo_udt_rx_inst_wr_data_count;
wire	[31:0]	fifo_udt_rx_inst_rd_data_count;


axis_data_fifo_64_asyn	fifo_udt_rx_inst(
	.s_axis_aclk(ui_clk),
	.s_axis_aresetn(ui_aresetn),
	
	.m_axis_aclk(rx_axis_aclk),
	.m_axis_aresetn(rx_axis_aresetn),
	
	.s_axis_tvalid(core_udt_rx_axis_tvalid), 
	.s_axis_tready(core_udt_rx_axis_tready), 
	.s_axis_tdata(core_udt_rx_axis_tdata), 
	.s_axis_tkeep(core_udt_rx_axis_tkeep), 
	.s_axis_tlast(core_udt_rx_axis_tlast), 
	
	.m_axis_tvalid(rx_axis_tvalid), 
	.m_axis_tready(rx_axis_tready), 
	.m_axis_tdata(rx_axis_tdata), 
	.m_axis_tkeep(rx_axis_tkeep), 
	.m_axis_tlast(rx_axis_tlast), 
	.axis_data_count(fifo_udt_rx_inst_data_count), 
	.axis_wr_data_count(fifo_udt_rx_inst_wr_data_count), 
	.axis_rd_data_count(fifo_udt_rx_inst_rd_data_count)
);
/*	asyc  fifo   UDP->IN_DATA	*/


/*	asyc	 fifo	UDP->OUT_DATA	*/



/*	asyc	fifo	UDP-IP 	address	*/


/*	asyc	fifo	UDP-IP	address	*/

configure	con_inst(
	.ctrl_s_axi_aclk(ctrl_s_axi_aclk),							
	.ctrl_s_axi_aresetn(ctrl_s_axi_aresetn),							
	.ctrl_s_axi_awaddr(ctrl_s_axi_awaddr),					
	.ctrl_s_axi_awvalid(ctrl_s_axi_awvalid),							
	.ctrl_s_axi_awready(ctrl_s_axi_awready),							
	.ctrl_s_axi_wdata(ctrl_s_axi_wdata),					
	.ctrl_s_axi_wstrb(ctrl_s_axi_wstrb),					
	.ctrl_s_axi_wvalid(ctrl_s_axi_wvalid),							
	.ctrl_s_axi_wready(ctrl_s_axi_wready),							
	.ctrl_s_axi_bresp(ctrl_s_axi_bresp),					
	.ctrl_s_axi_bvalid(ctrl_s_axi_bvalid),							
	.ctrl_s_axi_bready(ctrl_s_axi_bready),							
	.ctrl_s_axi_araddr(ctrl_s_axi_araddr),					
	.ctrl_s_axi_arvalid(ctrl_s_axi_arvalid),							
	.ctrl_s_axi_arready(ctrl_s_axi_arready),						
	.ctrl_s_axi_rdata(ctrl_s_axi_rdata),					
	.ctrl_s_axi_rresp(ctrl_s_axi_rresp),					
	.ctrl_s_axi_rvalid(ctrl_s_axi_rvalid),							
	.ctrl_s_axi_rready(ctrl_s_axi_rready),				

);

endmodule