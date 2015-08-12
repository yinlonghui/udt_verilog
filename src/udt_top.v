//%	@file	udt_top.v
//%	@brief	本文件定义UDT顶层模块
//% @details

//%	本模块例化UDP模块和UDT核心模块
//% @details
`timescale 1ns/1ps
module	udt_top# (
	parameter	C_S_AXI_ID_WIDTH  = 8'd4 ,				//% 定义ID位宽
	parameter	C_S_AXI_DATA_WIDTH = 32'd512,			//%	定义数据位宽
	parameter	C_S_AXI_ADDR_WIDTH = 32'd32 ,			//%	定义地址位宽
	parameter	FPGA_MAC_SRC	= 48'hba0203040506,		//%	定义源MAC地址
	parameter	FPGA_MAC_DES	= 48'hffffffffffff,		//%	定义目的MAC地址
	parameter	FPGA_IP_SRC		= 32'hc0a8006f,			//%	定义源IP地址
	parameter	FPGA_IP_DES_DEAFAULT = 32'hc0a800ff,	//%	定义目的默认IP地址 (广播)
	parameter	PORT	=	32'd 10086					//%	定义监听端口号
	
/*
    parameter   RX_DES_PORT  = 16'd10086 ,
    parameter   TX_SRC_PORT  = 16'd4096 ,
    parameter   TX_DES_PORT  = 16'd8191 ,
    parameter   TX_DES_IP    = 32'hc0a8006f  //  192.168.0.111
*/
)
(

	input			areset,				//%	UDP复位信号(高复位)
	input			clk156,				//%	UDP时钟信号
	
	
	input			user_clk	,		//%	用户时钟
	input			user_rst_n	,		//%	用户复位信号（低复位）
	
	input			core_clk	,		//%	核心模块时钟
	input			core_rst_n	,		//%	核心模块复位信号（低复位）
	
	
	input	tx_axis_tvalid,				//%	UDT传输数据-发送-数据有效
	output	tx_axis_tready,				//%	UDT传输数据-发送-数据就绪
	input	[63:0]	tx_axis_tdata,		//%	UDT传输数据-发送-数据包
	input	[7:0]	tx_axis_tkeep,		//%	UDT传输数据-发送-数据字节有效
	input	tx_axis_tlast,				//%	UDT传输数据-发送-数据包结束

	output	rx_axis_tvalid,				//%	UDT传输数据-接收数据有效
	input	rx_axis_tready,				//%	UDT传输数据-接收数据就绪
	output	rx_axis_tdata,				//%	UDT传输数据-接收数据包
	output	[7:0]   rx_axis_tkeep,		//%	UDT传输数据-接收数据字节有效
	output	rx_axis_tlast,				//%	UDT传输数据-接收数据包结束
    
	input	[31:0]	ctrl_s_axi_awaddr,	//%	用户-写地址信号
	input	ctrl_s_axi_awvalid,			//% 用户-写地址有效
	output	ctrl_s_axi_awready,			//%	用户-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,	//%	用户-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,	//%	用户-写操作字节使能
	input	ctrl_s_axi_wvalid,			//%	用户-写数据有效
	output	ctrl_s_axi_wready,			//%	用户-写数据就绪
	output	[1:0]	ctrl_s_axi_bresp,	//%	用户-写数据应答
	output	ctrl_s_axi_bvalid,			//%	用户-写应答有效
	input	ctrl_s_axi_bready,			//%	用户-写应答就绪
	input   [31:0]	ctrl_s_axi_araddr,	//% 用户-读地址信号
	input	ctrl_s_axi_arvalid,			//% 用户-读地址有效
	output	ctrl_s_axi_arready,			//% 用户-读地址就绪
	output  [31:0]	ctrl_s_axi_rdata,	//%	用户-读操作数据
	output	[1:0]	ctrl_s_axi_rresp,	//%	用户-读数据应答
	output	ctrl_s_axi_rvalid,			//%	用户-读数据有效
	input	ctrl_s_axi_rready,			//%	用户-读数据就绪
	
	
	output			mac_rx_axis_tready, //%	接收-MAC包-就绪信号
	input			mac_rx_axis_tvalid,	//%	接收-MAC包-有效信号
	input			mac_rx_axis_tlast,	//%	接收-MAC包-结束信号
	input  [ 7:0]	mac_rx_axis_tkeep,	//%	接收-MAC包-字节有效信号
	input  [63:0]	mac_rx_axis_tdata,	//%	接收-MAC包-数据包

	input			mac_tx_axis_tready,	//%	发送-MAC包-就绪信号
	output			mac_tx_axis_tvalid,	//%	发送-MAC包-有效信号
	output			mac_tx_axis_tlast,	//%	发送-MAC包-结束信号		
	output [ 7:0]	mac_tx_axis_tkeep,	//%	发送-MAC包-字节有效信号
	output [63:0]	mac_tx_axis_tdata	//%	发送-MAC包-数据包
 );
 

(* mark_debug = "TRUE" *) wire        udp_tx_tready    ;
(* mark_debug = "TRUE" *) wire        udp_rx_tready    ;
(* mark_debug = "TRUE" *) wire        udp_tx_tvalid    ;
(* mark_debug = "TRUE" *) wire        udp_rx_tvalid    ;
(* mark_debug = "TRUE" *) wire        udp_tx_tlast     ;
(* mark_debug = "TRUE" *) wire        udp_rx_tlast     ;
(* mark_debug = "TRUE" *) wire [ 7:0] udp_tx_tkeep     ;
(* mark_debug = "TRUE" *) wire [ 7:0] udp_rx_tkeep     ;
(* mark_debug = "TRUE" *) wire [63:0] udp_tx_tdata     ;
(* mark_debug = "TRUE" *) wire [63:0] udp_rx_tdata     ;
wire [47:0] udp_tx_mac_src   ;
wire [47:0] udp_rx_mac_src   ;
wire [47:0] udp_tx_mac_dest  ;
wire [47:0] udp_rx_mac_dest  ;
wire [31:0] udp_tx_ip_src    ;
(* mark_debug = "TRUE" *) wire [31:0] udp_rx_ip_src    ;
wire [31:0] udp_tx_ip_dest   ;
(* mark_debug = "TRUE" *) wire [31:0] udp_rx_ip_dest   ;
wire [15:0] udp_tx_port_src  ;
(* mark_debug = "TRUE" *) wire [15:0] udp_rx_port_src  ;
wire [15:0] udp_tx_port_dest ;
(* mark_debug = "TRUE" *) wire [15:0] udp_rx_port_dest ;


 xg_udp_top  
   #(
    .RX_DES_PORT(PORT)
  ) xg_udp_top (
    .areset           ( areset           ),
    .clk156           ( clk156           ),

    .rx_axis_tready   ( mac_rx_axis_tready   ),
    .rx_axis_tvalid   ( mac_rx_axis_tvalid   ),
    .rx_axis_tlast    ( mac_rx_axis_tlast    ),
    .rx_axis_tkeep    ( mac_rx_axis_tkeep    ),
    .rx_axis_tdata    ( mac_rx_axis_tdata    ),

    .tx_axis_tready   ( mac_tx_axis_tready   ),
    .tx_axis_tvalid   ( mac_tx_axis_tvalid   ),
    .tx_axis_tlast    ( mac_tx_axis_tlast    ),
    .tx_axis_tkeep    ( mac_tx_axis_tkeep    ),
    .tx_axis_tdata    ( mac_tx_axis_tdata    ),
    
    .udp_rx_tready    ( udp_rx_tready    ) ,//i
    .udp_rx_tvalid    ( udp_rx_tvalid    ) ,//o
    .udp_rx_tlast     ( udp_rx_tlast     ) ,//o
    .udp_rx_tkeep     ( udp_rx_tkeep     ) ,//o
    .udp_rx_tdata     ( udp_rx_tdata     ) ,//o
    .udp_rx_mac_src   ( udp_rx_mac_src   ) ,//o
    .udp_rx_mac_dest  ( udp_rx_mac_dest  ) ,//o
    .udp_rx_ip_src    ( udp_rx_ip_src    ) ,//o
    .udp_rx_ip_dest   ( udp_rx_ip_dest   ) ,//o
    .udp_rx_port_src  ( udp_rx_port_src  ) ,//o
    .udp_rx_port_dest ( udp_rx_port_dest ) ,//o
                                         
    .udp_tx_tready    ( udp_tx_tready    ) ,//o
    .udp_tx_tvalid    ( udp_tx_tvalid    ) ,//i
    .udp_tx_tlast     ( udp_tx_tlast     ) ,//i
    .udp_tx_tkeep     ( udp_tx_tkeep     ) ,//i
    .udp_tx_tdata     ( udp_tx_tdata     ) ,//i
    .udp_tx_mac_src   ( udp_tx_mac_src   ) ,//i
    .udp_tx_mac_dest  ( udp_tx_mac_dest  ) ,//i
    .udp_tx_ip_src    ( udp_tx_ip_src    ) ,//i
    .udp_tx_ip_dest   ( udp_tx_ip_dest   ) ,//i
    .udp_tx_port_src  ( udp_tx_port_src  ) ,//i
    .udp_tx_port_dest ( udp_tx_port_dest )  //i

  );
	assign udp_tx_mac_src   = FPGA_MAC_SRC ;
	assign udp_tx_mac_dest  = FPGA_MAC_DES ;
	assign udp_tx_ip_src    = FPGA_IP_SRC    ; //192.168.0.111
	assign udp_tx_ip_dest   = FPGA_IP_DES_DEAFAULT    ;
	assign udp_tx_port_src  = PORT      ;
	assign udp_tx_port_dest = PORT      ;
	assign udp_rx_tready = 1 ;
	
	
	wire	[63:0]	core_tx_axis_tdata ;
	wire	[7:0]	core_tx_axis_tkeep ;
	wire			core_tx_axis_tvalid ;
	wire			core_tx_axis_tready ;
	wire			core_tx_axis_tlast	;

	wire	[63:0]	core_rx_axis_tdata ;
	wire	[7:0]	core_rx_axis_tkeep ;
	wire			core_rx_axis_tvalid ;
	wire			core_rx_axis_tready ;
	wire			core_rx_axis_tlast  ;
	
	
	
	
	
	wire	[31:0]	fifo1_data_count;
	wire	[31:0]	fifo1_wr_data_count;
	wire	[31:0]	fifo1_rd_data_count;
  
  axis_data_fifo_64_asyn	fifo_udt_tx_inst(
	.s_axis_aclk(user_clk),
	.s_axis_aresetn(user_rst_n),
	
	.m_axis_aclk(core_clk),
	.m_axis_aresetn(core_rst_n),
	
	.s_axis_tvalid(tx_axis_tvalid), 
	.s_axis_tready(tx_axis_tready), 
	.s_axis_tdata(tx_axis_tdata), 
	.s_axis_tkeep(tx_axis_tkeep), 
	.s_axis_tlast(tx_axis_tlast), 
	
	.m_axis_tvalid(core_tx_axis_tvalid), 
	.m_axis_tready(core_tx_axis_tready), 
	.m_axis_tdata(core_tx_axis_tdata), 
	.m_axis_tkeep(core_tx_axis_tkeep), 
	.m_axis_tlast(core_tx_axis_tlast), 
	
	.axis_data_count(fifo1_data_count), 
	.axis_wr_data_count(fifo1_wr_data_count), 
	.axis_rd_data_count(fifo1_rd_data_count)
);
  	wire	[31:0]	fifo2_data_count;
	wire	[31:0]	fifo2_wr_data_count;
	wire	[31:0]	fifo2_rd_data_count;
	
  axis_data_fifo_64_asyn	fifo_udt_rx_inst(
  
	.s_axis_aclk(core_clk),
	.s_axis_aresetn(core_rst_n),
	
	.m_axis_aclk(user_clk),
	.m_axis_aresetn(user_rst_n),
	
	.s_axis_tvalid(core_rx_axis_tvalid), 
	.s_axis_tready(core_rx_axis_tready), 
	.s_axis_tdata(core_rx_axis_tdata), 
	.s_axis_tkeep(core_rx_axis_tkeep), 
	.s_axis_tlast(core_rx_axis_tlast),
	
	
	.m_axis_tvalid(rx_axis_tvalid), 
	.m_axis_tready(rx_axis_tready), 
	.m_axis_tdata(rx_axis_tdata), 
	.m_axis_tkeep(rx_axis_tkeep), 
	.m_axis_tlast(rx_axis_tlast), 
	
	.axis_data_count(fifo2_data_count), 
	.axis_wr_data_count(fifo2_wr_data_count), 
	.axis_rd_data_count(fifo2_rd_data_count)
);	
  
  
  
endmodule