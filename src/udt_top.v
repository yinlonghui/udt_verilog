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
	parameter	PORT	=	32'd 10086					//%	定义监听端口
	
/*
    parameter   RX_DES_PORT  = 16'd10086 ,
    parameter   TX_SRC_PORT  = 16'd4096 ,
    parameter   TX_DES_PORT  = 16'd8191 ,
    parameter   TX_DES_IP    = 32'hc0a8006f  //  192.168.0.111
*/
)
(

	input			areset,				
	input			clk156,				
	
	
	input			user_clk	,		
	input			user_rst_n	,		
	
	input			core_clk	,		
	input			core_rst_n	,		
	
	
	input	tx_axis_tvalid,				
	output	tx_axis_tready,				
	input	[63:0]	tx_axis_tdata,		
	input	[7:0]	tx_axis_tkeep,		
	
	input	tx_axis_tlast,				
	output	rx_axis_tvalid,				
	input	rx_axis_tready,				
	output	[63:0]	rx_axis_tdata,				
	output	[7:0]   rx_axis_tkeep,		
	output	rx_axis_tlast,				
    
	input	[31:0]	ctrl_s_axi_awaddr,	
	input	ctrl_s_axi_awvalid,			
	output	ctrl_s_axi_awready,			
	input	[31:0]	ctrl_s_axi_wdata,	
	input	[3:0]	ctrl_s_axi_wstrb,
	input	ctrl_s_axi_wvalid,			
	output	ctrl_s_axi_wready,			
	output	[1:0]	ctrl_s_axi_bresp,	
	output	ctrl_s_axi_bvalid,			
	input	ctrl_s_axi_bready,			
	input   [31:0]	ctrl_s_axi_araddr,	
	input	ctrl_s_axi_arvalid,			
	output	ctrl_s_axi_arready,			
	output  [31:0]	ctrl_s_axi_rdata,	
	output	[1:0]	ctrl_s_axi_rresp,	
	output	ctrl_s_axi_rvalid,			
	input	ctrl_s_axi_rready,			
	
	
	output			mac_rx_axis_tready,
	input			mac_rx_axis_tvalid,
	input			mac_rx_axis_tlast,
	input  [ 7:0]	mac_rx_axis_tkeep,
	input  [63:0]	mac_rx_axis_tdata,	

	input			mac_tx_axis_tready,
	output			mac_tx_axis_tvalid,	
	output			mac_tx_axis_tlast,			
	output [ 7:0]	mac_tx_axis_tkeep,	
	output [63:0]	mac_tx_axis_tdata	
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
	//assign udp_rx_tready = 1 ;
	
	
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
	
	.m_axis_aclk(clk156),
	.m_axis_aresetn(!areset),
	
	.s_axis_tvalid(tx_axis_tvalid), 
	.s_axis_tready(tx_axis_tready), 
	.s_axis_tdata(tx_axis_tdata), 
	.s_axis_tkeep(tx_axis_tkeep), 
	.s_axis_tlast(tx_axis_tlast), 
	
	.m_axis_tvalid(udp_tx_tvalid), 
	.m_axis_tready(udp_tx_tready), 
	.m_axis_tdata(udp_tx_tdata), 
	.m_axis_tkeep(udp_tx_tkeep), 
	.m_axis_tlast(udp_tx_tlast), 
	
	.axis_data_count(fifo1_data_count), 
	.axis_wr_data_count(fifo1_wr_data_count), 
	.axis_rd_data_count(fifo1_rd_data_count)
);
  	wire	[31:0]	fifo2_data_count;
	wire	[31:0]	fifo2_wr_data_count;
	wire	[31:0]	fifo2_rd_data_count;
	
  axis_data_fifo_64_asyn	fifo_udt_rx_inst(
  
	.s_axis_aclk(clk156),
	.s_axis_aresetn(!areset),
	
	.m_axis_aclk(user_clk),
	.m_axis_aresetn(user_rst_n),
	
	.s_axis_tvalid(udp_rx_tvalid), 
	.s_axis_tready(udp_rx_tready), 
	.s_axis_tdata(udp_rx_tdata), 
	.s_axis_tkeep(udp_rx_tkeep), 
	.s_axis_tlast(udp_rx_tlast),
	
	
	.m_axis_tvalid(rx_axis_tvalid), 
	.m_axis_tready(rx_axis_tready), 
	.m_axis_tdata(rx_axis_tdata), 
	.m_axis_tkeep(rx_axis_tkeep), 
	.m_axis_tlast(rx_axis_tlast), 
	
	.axis_data_count(fifo2_data_count), 
	.axis_wr_data_count(fifo2_wr_data_count), 
	.axis_rd_data_count(fifo2_rd_data_count)
);	

(* mark_debug = "TRUE" *)	wire	[31:0]	Snd_Buffer_Size ;
(* mark_debug = "TRUE" *)	wire	[31:0]	Rev_Buffer_Size	;
(* mark_debug = "TRUE" *)	wire	[31:0]	FlightFlagSize	;
(* mark_debug = "TRUE" *)	wire	[31:0]	MSSize;
(* mark_debug = "TRUE" *)	wire	[31:0]	INIT_SEQ ;

wire	[31:0]	udt_state ;
wire	state_valid	;
wire	state_ready ;
wire	Req_Connect	;
wire	Res_Connect	;
wire	Req_Close	;
wire	Res_Close	;
wire	Peer_Req_Close	;
wire	Peer_Res_Close	;
wire	user_valid	;
wire	user_ready	;
assign	user_ready = 0 ;

configure	configure_inst(
	.ctrl_s_axi_aclk(user_clk),							
	.ctrl_s_axi_aresetn(user_rst_n),	
	
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
	
	.udt_state(udt_state) ,					
	.state_valid(state_valid),					
	.state_ready(state_ready),							
	
	
	.Req_Connect(Req_Connect) ,					
	.Res_Connect(Res_Connect) ,						
	
	.Req_Close(Req_Close),						
	.Res_Close(Res_Close),								
	
	.Peer_Req_Close(Peer_Req_Close) ,						
	.Peer_Res_Close(Peer_Res_Close) ,
	
	.user_valid(user_valid)	,
	.user_ready(user_ready)	,						

	
	
	.Snd_Buffer_Size(Snd_Buffer_Size) ,					
	.Rev_Buffer_Size(Rev_Buffer_Size),				
	.FlightFlagSize(FlightFlagSize) ,					
	.MSSize(MSSize)	,							
	.INIT_SEQ(INIT_SEQ)							
);
si_socket	si_inst(
	.core_clk(user_clk)	,
	.core_rst_n(user_rst_n),
	.udt_state(udt_state) ,					
	.state_valid(state_valid),					
	.state_ready(state_ready),	
	.Req_Connect(Req_Connect) ,					
	.Res_Connect(Res_Connect) ,						
	
	.Req_Close(Req_Close),						
	.Res_Close(Res_Close),								
	
	.Peer_Req_Close(Peer_Req_Close) ,						
	.Peer_Res_Close(Peer_Res_Close) 


);
  
  
endmodule