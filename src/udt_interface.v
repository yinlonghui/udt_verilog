
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
	input	core_clk	,								//%	核心模块时钟
	input	core_rst_n	,								//%	核心模块复位信号(低复位)
	
	
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
	input	[15:0] udp_rx_port_dest 					//%	UDP传输数据-接收目的端口号
	
	output	user_closed	,								//%	关闭信号
	output	user_valid	,								//%	关闭信号有效
	input	user_ready									//%	关闭信号就绪
	
);


configure	con_inst(
	.ctrl_s_axi_aclk(core_clk),							
	.ctrl_s_axi_aresetn(core_rst_n),							
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
	
	.user_closed(user_closed),
	.user_ready(user_ready),
	.user_valid(user_valid),
	
	.udt_state(udt_state) ,							
	.state_valid(state_valid),								
	.state_ready(state_ready),	
	.Req_Connect(Req_Connect),								
	.Res_Connect(Res_Connect),						
	.Req_Close(Req_Close),	
	.Res_Close(Res_Close),					
	.Snd_Buffer_Size(Snd_Buffer_Size),					
	.Rev_Buffer_Size(Rev_Buffer_Size),					
	.FlightFlagSize(FlightFlagSize),			
	.MSSize(MSSize)	
);


endmodule