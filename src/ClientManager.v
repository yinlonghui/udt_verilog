//%	@file	ClientManager.v
//%	@brief	本文件定义client manager模块

//%	本模块实例化了listen,ProcessClose,close模块，主要功能管理SERVER端SOCKET套接字，监视其状态
//%	@details
//%		ClientManager功能如下：
//%		1、向Server端发送请求，通过3次握手后，连接建立完成
//%		2、处理用户关闭连接
//%		3、处理对端关闭包


module ClientManager	(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	input	[63:0]	handshake_tdata ,					//%	握手数据包
	input	[7:0]	handshake_tkeep ,					//%	握手包字节使能
	input			handshake_tvalid,					//%	握手包有效信号
	output			handshake_tready,					//%	握手包就绪信号
	input			handshake_tlast	,					//%	握手包结束信号
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
	output	[31:0]	Max_PktSize ,						//%	最大包大小
	output	[31:0]	Max_PayloadSize ,					//% 最大负载数据大小
	output	[31:0]	Expiration_counter ,				//%	EXP-timer计数器
	output	[31:0]	Bandwidth ,							//%	带宽的预估值，1秒1个包
	output	[31:0]	DeliveryRate ,						//%	包到达的速率（接收端）
	output	[31:0]	AckSeqNo ,							//%	最后ACK的序列号
	output	[31:0]	LastAckTime ,						//%	最后LAST的ACK时间戳
	output	[31:0]	SYNInterval ,						//%	同步（SYN）周期
	output	[31:0]	RRT ,								//%	往返时延的均值
	output	[31:0]	RTTVar ,							//%	往返时延的方差
	output	[31:0]	MinNakInt,							//%	最小NAK周期
	output	[31:0]	MinExpInt,							//%	最小EXP周期
	output	[31:0]	ACKInt,								//%	ACK 发送周期
	output	[31:0]	NAKInt,								//%	NAK 发送周期
	output	[31:0]	PktCount,							//%	packet counter for ACK
	output	[31:0]	LightACKCount ,						//%	light ACK 计数器
	output	[31:0]	TargetTime ,						//%	下个Packet发送时间
	output	[31:0]	TimeDiff,							//%	aggregate difference in inter-packet time

	output	[31:0]	PeerISN ,							//%	对端初始化的数据包序列号
	output	[31:0]	RcvLastAck ,						//%	接收端 最后发送ACK（数据包序列号）
	output	[31:0]	RcvLastAckAck ,						//%	接收端 最后发送ACK 被ACK的（数据）序列号
	output	[31:0]	RcvCurrSeqNo ,						//%	最大的接收的序列号
	output	[31:0]	LastDecSeq  ,						//%	Sequence number sent last decrease occurs 
	output	[31:0]	SndLastAck  ,						//%	Last ACK received
	output	[31:0]	SndLastDataAck ,					//%	The real last ACK that updates the sender buffer and loss list		
	output	[31:0]	SndCurrSeqNo ,						//%	The largest sequence number that has been sent
	output	[31:0]	SndLastAck2  ,						//%	Last ACK2 sent back 
	output	[31:0]	SndLastAck2Time ,					//%	Last time of ACK2 sent back
	output	[31:0]	FlowWindowSize ,					//%	SND list  size
	
	output	[31:0]	LastRspTime,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
	output	[31:0]	NextACKTime,						//%	用于ACK Timers
	output	[31:0]	NextNACKtime,						//%	用于NACK Timers
	
	output	[63:0]	req_tdata	,						//%	请求握手数据包
	output	[7:0]	req_tkeep	,						//%	请求握手数据使能信号
	output			req_tvalid	,						//%	请求握手数据有效信号
	input			req_tready	,						//%	请求握手数据就绪信号
	input			req_tlast	,						//%	请求握手数据结束信号
	
	input			close_tvalid ,						//%	请求关闭有效信号
	output			close_tready						//% 请求关闭就绪信号
);

wire	[31:0]	connect_udt_state ;
wire	connect_state_valid ;
wire	connect_state_ready ;

connect  connect_inst(
		.core_clk(core_clk),
		.core_rst_n(core_rst_n),
		.handshake_tdata(handshake_tdata) ,
		.handshake_tkeep(handshake_tkeep) ,
		.handshake_tvalid(handshake_tvalid),
		.handshake_tready(handshake_tready),
		.handshake_tlast(handshake_tlast),
		.udt_state(connect_udt_state) ,							
		.state_valid(connect_state_valid),								
		.state_ready(connect_state_ready),
		.Req_Connect(Req_Connect),								
		.Res_Connect(Res_Connect),										
		.Snd_Buffer_Size(Snd_Buffer_Size),					
		.Rev_Buffer_Size(Rev_Buffer_Size),					
		.FlightFlagSize(FlightFlagSize),			
		.MSSize(MSSize),
		.Max_PktSize(Max_PktSize) ,						
		.Max_PayloadSize(Max_PayloadSize) ,
		.Expiration_counter(Expiration_counter),
		.Bandwidth(Bandwidth) ,
		.DeliveryRate(DeliveryRate),
		.AckSeqNo(AckSeqNo),
		.LastAckTime(LastAckTime),
		.SYNInterval(SYNInterval),
		.RRT(RRT) ,
		.RTTVar(RTTVar) ,
		.MinNakInt(MinNakInt),
		.MinExpInt(MinExpInt),
		.ACKInt(ACKInt),
		.NAKInt(NAKInt),
		.PktCount(PktCount),
		.LightACKCount(LightACKCount),
		.TargetTime(TargetTime),
		.TimeDiff(TimeDiff),
		.PeerISN(PeerISN) ,							
		.RcvLastAck(RcvLastAck) ,					
		.RcvLastAckAck(RcvLastAckAck) ,					
		.RcvCurrSeqNo(RcvCurrSeqNo) ,					
		.LastDecSeq(LastDecSeq)  ,						 
		.SndLastAck(SndLastAck)  ,						
		.SndLastDataAck(SndLastDataAck),							
		.SndCurrSeqNo(SndCurrSeqNo) ,						
		.SndLastAck2(SndLastAck2) ,						
		.SndLastAck2Time(SndLastAck2Time) ,					
		.FlowWindowSize(FlowWindowSize) ,
		.LastRspTime(LastRspTime),
		.NextACKTime(NextACKTime),
		.NextNACKtime(NextNACKtime),
		.req_tdata(req_tdata),
		.req_tkeep(req_tkeep),
		.req_tvalid(req_tvalid),
		.req_tready(req_tready),
		.req_tlast(req_tlast)
);



wire	[31:0]	p_c_udt_state ;
wire	p_c_state_valid ;
wire	p_c_state_ready ;

ProcessClose	ProcessClose_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	
	.udt_state_i(p_c_udt_state) ,							
	.state_valid_i(p_c_state_valid),								
	.state_ready_o(p_c_state_ready),
	.close_tvalid_i(close_tvalid),
	.close_tdata_i(close_tdata),
	.close_tkeep_i(close_tkeep),
	.close_tlast_i(close_tlast),
	.close_tready_o(close_tready)
);

wire	[31:0]	c_udt_state ;
wire	c_state_valid ;
wire	c_state_ready ;

close	close_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	
	.udt_state_i(c_udt_state) ,							
	.state_valid_i(c_state_valid),								
	.state_ready_o(c_state_ready),
	
	
	.Req_Close_i(Req_Close),
	.Res_Close_o(Res_Close)

);

mutexValue  #(
	.WR_NUM(3),
	.RD_NUM(1)
)	udt_state_inst(

	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	.value_i({connect_udt_state,p_c_udt_state,c_udt_state}),
	.valid_i({connect_state_valid,p_c_state_valid,c_state_valid}),
	.ready_o({connect_state_ready,p_c_state_ready,c_state_ready}),
	
	.ready_i(state_ready),
	.valid_o(state_valid),
	.value_o(udt_state)
	
);


endmodule