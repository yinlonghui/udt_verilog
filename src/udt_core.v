//%	@file	udt_core.v
//%	@brief	本文定义UDT核心模块
//% @details

//%	本模块例化各个功能模块
//% @details


module	udt_core
#(
	parameter	C_S_AXI_ID_WIDTH  = 8'd4 ,				//% 定义ID位宽
	parameter	C_S_AXI_DATA_WIDTH = 32'd512,			//%	定义数据位宽
	parameter	C_S_AXI_ADDR_WIDTH = 32'd32 ,			//%	定义地址位宽
	parameter	FPGA_MAC_SRC	= 48'hba0203040506,		//%	定义源MAC地址
	parameter	FPGA_MAC_DES	= 48'hffffffffffff,		//%	定义目的MAC地址
	parameter	FPGA_IP_SRC		= 32'hc0a8006f,			//%	定义源IP地址
	parameter	FPGA_IP_DES_DEAFAULT = 32'hc0a800ff,	//%	定义目的默认IP地址 (广播)
	parameter	PORT	=	32'd 10086					//%	定义监听端口号
)(
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
	input	[47:0]	udp_rx_mac_src   ,					//%	UDP传输数据-接收源MAC地址
	input	[47:0]	udp_rx_mac_dest  ,					//%	UDP传输数据-接收目的MAC地址
	input	[31:0]	udp_rx_ip_src    ,					//%	UDP传输数据-接收源IP地址
	input	[31:0] udp_rx_ip_dest   ,					//%	UDP传输数据-接收目的IP地址
	input	[15:0] udp_rx_port_src  ,					//%	UDP传输数据-接收源端口号
	input	[15:0] udp_rx_port_dest ,					//%	UDP传输数据-接收目的端口号
	
	
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
	input	Req_Connect ,								//%	连接请求
	output	Res_Connect ,								//% 连接回应
	input	Req_Close	,								//%	关闭请求
	output	Res_Close	,								//%	关闭回应
	input	[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
	input	[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
	input	[31:0]	FlightFlagSize ,					//%	最大流量窗口大小
	input	[31:0]	MSSize	,							//%	最大包大小
	
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
wire	[63:0]	trans_tx_tdata  ;
wire	[7:0]	trans_tx_tkeep  ;
wire	trans_tx_tvalid ;
wire	trans_tx_tready ;
wire	trans_tx_tlast  ;

trans_keep	udp_tx(
	.core_clk(core_clk),			
	.in_tdata(trans_tx_tdata),	
	.in_tkeep(trans_tx_tkeep),	
	.in_tvalid(trans_tx_tvalid), 		
	.in_tready(trans_tx_tready),	
	.in_tlast(trans_tx_tlast),		
	
	.out_tdata(udp_tx_tdata),	
	.out_tlast(udp_tx_tlast),		
	.out_tvalid(udp_tx_tvalid),		
	.out_keep(udp_tx_tkeep),	
	.out_tready(udp_tx_tready)
);

wire	[63:0]	trans_rx_tdata  ;
wire	[7:0]	trans_rx_tkeep  ;
wire	trans_rx_tvalid ;
wire	trans_rx_tready ;
wire	trans_rx_tlast  ;

trans_keep	udp_rx(
	.core_clk(core_clk),			
	.in_tdata(udp_rx_tdata),	
	.in_tkeep(udp_rx_tkeep),	
	.in_tvalid(udp_rx_tvalid), 		
	.in_tready(udp_rx_tready),	
	.in_tlast(udp_rx_tlast),		
	
	.out_tdata(trans_rx_tdata),	
	.out_tlast(trans_rx_tlast),		
	.out_tvalid(trans_rx_tvalid),		
	.out_keep(trans_rx_tkeep),	
	.out_tready(trans_rx_tready)
);

wire	Data_en ;
wire	ACK_en	;
wire	ACK2_en ;
wire	Keep_live_en ;
wire	NAK_en ;
wire	Handshake_en ;
wire	CLOSE_en	;

wire	[63:0] data_packet_tdata ;
wire	data_packet_tlast ;
wire	[7:0] data_packet_tkeep ;
wire	data_packet_tvalid ;
wire	data_packet_tready ;

decode	decode_inst(
	.core_clk(core_clk) ,								
	.core_rst_n(core_rst_n),					
	.in_tdata(trans_rx_tdata),	
	.in_tkeep(trans_rx_tkeep),
	.in_tvalid(trans_rx_tvalid), 
	.in_tready(trans_rx_tready),	
	.in_tlast(trans_rx_tlast),
	
	.out_tdata(data_packet_tdata),
	.out_tlast(data_packet_tlast),
	.out_tvalid(data_packet_tvalid),
	.out_tkeep(data_packet_tkeep),	
	.out_tready(data_packet_tready),		

	.Data_en(Data_en),						
	.ACK_en(ACK_en),								
	.ACK2_en(ACK2_en),						
	.Keep_live_en(Keep_live_en),							
	.NAK_en(NAK_en),								
	.Handshake_en(Handshake_en),
	.CLOSE_en(CLOSE_en)

);
wire	[31:0]udt_state ,							//%	连接状态
wire	state_valid,								//%	连接状态有效
wire	state_ready,								//%	连接状态就绪
wire	Req_Connect ,								//%	连接请求
wire	Res_Connect ,								//% 连接回应
wire	Req_Close	,								//%	关闭请求
wire	Res_Close	,								//%	关闭回应
wire	[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
wire	[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
wire	[31:0]	FlightFlagSize ,					//%	最大流量窗口大小
wire	[31:0]	MSSize,								//%	最大包大小
wire	[31:0]	Max_PktSize ,						//%	最大包大小
wire	[31:0]	Max_PayloadSize ,					//% 最大负载数据大小
wire	[31:0]	Expiration_counter ,				//%	EXP-timer计数器
wire	[31:0]	Bandwidth ,							//%	带宽的预估值，1秒1个包
wire	[31:0]	DeliveryRate ,						//%	包到达的速率（接收端）
wire	[31:0]	AckSeqNo ,							//%	最后ACK的序列号
wire	[31:0]	LastAckTime ,						//%	最后LAST的ACK时间戳
wire	[31:0]	SYNInterval ,						//%	同步（SYN）周期
wire	[31:0]	RRT ,								//%	往返时延的均值
wire	[31:0]	RTTVar ,							//%	往返时延的方差
wire	[31:0]	MinNakInt,							//%	最小NAK周期
wire	[31:0]	MinExpInt,							//%	最小EXP周期
wire	[31:0]	ACKInt,								//%	ACK 发送周期
wire	[31:0]	NAKInt,								//%	NAK 发送周期
wire	[31:0]	PktCount,							//%	packet counter for ACK
wire	[31:0]	LightACKCount ,						//%	light ACK 计数器
wire	[31:0]	TargetTime ,						//%	下个Packet发送时间				
wire	[31:0]	TimeDiff,							//%	aggregate difference in inter-packet time   
	
wire	[31:0]	PeerISN ,							//%	对端初始化的数据包序列号
wire	[31:0]	RcvLastAck ,						//%	接收端 最后发送ACK（数据包序列号）
wire	[31:0]	RcvLastAckAck ,						//%	接收端 最后发送ACK 被ACK的（数据）序列号
wire	[31:0]	RcvCurrSeqNo ,						//%	最大的接收的序列号
wire	[31:0]	LastDecSeq  ,						//%	Sequence number sent last decrease occurs 
wire	[31:0]	SndLastAck  ,						//%	Last ACK received
wire	[31:0]	SndLastDataAck ,					//%	The real last ACK that updates the sender buffer and loss list		
wire	[31:0]	SndCurrSeqNo ,						//%	The largest sequence number that has been sent
wire	[31:0]	SndLastAck2  ,						//%	Last ACK2 sent back 
wire	[31:0]	SndLastAck2Time ,					//%	Last time of ACK2 sent back
wire	[31:0]	FlowWindowSize ,						//%	SND list  size
	
wire	[31:0]	LastRspTime,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
wire	[31:0]	NextACKTime,						//%	用于ACK Timers
wire	[31:0]	NextNACKtime,						//%	用于NACK Timers
	
wire	[63:0]	req_tdata	,						//%	请求握手数据包
wire	[7:0]	req_tkeep	,						//%	请求握手数据使能信号
wire	req_tvalid	,						//%	请求握手数据有效信号
wire	req_tready	,						//%	请求握手数据就绪信号
wire	req_tlast							//%	请求握手数据结束信号	
wire	handshake_tready ;
wire	axis_lock		;
wire	NAK_tready	;
wire	DATA_tready ;
wire	ACK_tready	;
wire	ACK2_tready ;
assign	data_packet_tready =  !axis_lock && (handshake_tready || NAK_tready || DATA_tready || ACK_tready ||  ACK2_tready)；
SocketManager	socket_manger_inst(

	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	.handshake_tdata(data_packet_tdata),
	.handshake_tkeep(data_packet_tkeep),
	.handshake_tvalid(data_packet_tvalid && Handshake_en),
	.handshake_tready(handshake_tready),
	.handshake_tlast(data_packet_tlast),
	.[31:0] udt_state ,							//%	连接状态
	.state_valid,								//%	连接状态有效
	.state_ready,								//%	连接状态就绪
	.Req_Connect ,								//%	连接请求
	.Res_Connect ,								//% 连接回应
	.Req_Close	,								//%	关闭请求
	.Res_Close	,								//%	关闭回应
	.[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
	.[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
	.[31:0]	FlightFlagSize ,					//%	最大流量窗口大小
	.[31:0]	MSSize,								//%	最大包大小
	.[31:0]	Max_PktSize ,						//%	最大包大小
	.[31:0]	Max_PayloadSize ,					//% 最大负载数据大小
	.[31:0]	Expiration_counter ,				//%	EXP-timer计数器
	.[31:0]	Bandwidth ,							//%	带宽的预估值，1秒1个包
	.[31:0]	DeliveryRate ,						//%	包到达的速率（接收端）
	.[31:0]	AckSeqNo ,							//%	最后ACK的序列号
	.[31:0]	LastAckTime ,						//%	最后LAST的ACK时间戳
	.[31:0]	SYNInterval ,						//%	同步（SYN）周期
	.[31:0]	RRT ,								//%	往返时延的均值
	.[31:0]	RTTVar ,							//%	往返时延的方差
	.[31:0]	MinNakInt,							//%	最小NAK周期
	.[31:0]	MinExpInt,							//%	最小EXP周期
	.[31:0]	ACKInt,								//%	ACK 发送周期
	.[31:0]	NAKInt,								//%	NAK 发送周期
	.[31:0]	PktCount,							//%	packet counter for ACK
	.[31:0]	LightACKCount ,						//%	light ACK 计数器
	.[31:0]	TargetTime ,						//%	下个Packet发送时间				
	.[31:0]	TimeDiff,							//%	aggregate difference in inter-packet time   
	
	.[31:0]	PeerISN ,							//%	对端初始化的数据包序列号
	.[31:0]	RcvLastAck ,						//%	接收端 最后发送ACK（数据包序列号）
	.[31:0]	RcvLastAckAck ,						//%	接收端 最后发送ACK 被ACK的（数据）序列号
	.[31:0]	RcvCurrSeqNo ,						//%	最大的接收的序列号
	.[31:0]	LastDecSeq  ,						//%	Sequence number sent last decrease occurs 
	.[31:0]	SndLastAck  ,						//%	Last ACK received
	.[31:0]	SndLastDataAck ,					//%	The real last ACK that updates the sender buffer and loss list		
	.[31:0]	SndCurrSeqNo ,						//%	The largest sequence number that has been sent
	.[31:0]	SndLastAck2  ,						//%	Last ACK2 sent back 
	.[31:0]	SndLastAck2Time ,					//%	Last time of ACK2 sent back
	.[31:0]	FlowWindowSize ,						//%	SND list  size
	
	.[31:0]	LastRspTime,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
	.[31:0]	NextACKTime,						//%	用于ACK Timers
	.[31:0]	NextNACKtime,						//%	用于NACK Timers
	
	.[63:0]	req_tdata	,						//%	请求握手数据包
	.[7:0]	req_tkeep	,						//%	请求握手数据使能信号
	.req_tvalid	,						//%	请求握手数据有效信号
	.req_tready	,						//%	请求握手数据就绪信号
	.req_tlast							//%	请求握手数据结束信号	
	
	
);

//	AXI-interconnect
ProcessNAK	ProcessNAK_inst(
	.core_clk(core_clk),							
	.core_rst_n(core_rst_n),
	.NAK_tdata(data_packet_tdata),
	.NAK_tkeep(data_packet_tkeep),
	.NAK_tvalid(data_packet_tvalid && NAK_en),
	.NAK_tready(NAK_tready),	
	.NAK_tlast(data_packet_tlast)
);
ProcessData	ProcessData_inst(
	.core_clk(core_clk),							
	.core_rst_n(core_rst_n),
	.DATA_tdata(data_packet_tdata),
	.DATA_tkeep(data_packet_tkeep),
	.DATA_tvalid(data_packet_tvalid && Data_en),
	.DATA_tready(DATA_tready),	
	.DATA_tlast(data_packet_tlast)
);

ProcessACK	ProcessACK_inst(
	.core_clk(core_clk),							
	.core_rst_n(core_rst_n),
	.ACK_tdata(data_packet_tdata),
	.ACK_tkeep(data_packet_tkeep),
	.ACK_tvalid(data_packet_tvalid && Data_en),
	.ACK_tready(ACK_tready),	
	.ACK_tlast(data_packet_tlast)

);

ProcessACK2	ProcessACK2_inst(
	.core_clk(core_clk),							
	.core_rst_n(core_rst_n),
	.ACK2_tdata(data_packet_tdata),
	.ACK2_tkeep(data_packet_tkeep),
	.ACK2_tvalid(data_packet_tvalid && Data_en),
	.ACK2_tready(ACK2_tready),	
	.ACK2_tlast(data_packet_tlast)

);


endmodule