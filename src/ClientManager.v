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
	input	[63:0]	handshake_tdata_i ,					//%	握手数据包
	input	[7:0]	handshake_tkeep_i ,					//%	握手包字节使能
	input			handshake_tvalid_i,					//%	握手包有效信号
	output			handshake_tready_o,					//%	握手包就绪信号
	input			handshake_tlast_i,					//%	握手包结束信号

	
	input	Req_Connect_i ,								//%	连接请求
	output	Res_Connect_o ,								//% 连接回应
	input	Req_Close_i	,								//%	关闭请求
	output	Res_Close_o	,								//%	关闭回应
	input	[31:0]	Snd_Buffer_Size_i ,					//%	发送buffer大小
	input	[31:0]	Rev_Buffer_Size_i	,				//%	接收buffer大小
	input	[31:0]	FlightFlagSize_i ,					//%	最大流量窗口大小
	input	[31:0]	MSSize_i ,							//%	最大包大小
	output	[31:0]	Max_PktSize_o ,						//%	最大包大小
	output	[31:0]	Max_PayloadSize_o ,					//% 最大负载数据大小
	output	[31:0]	Expiration_counter_o ,				//%	EXP-timer计数器
	output	[31:0]	Bandwidth_o ,						//%	带宽的预估值，1秒1个包
	output	[31:0]	DeliveryRate_o ,					//%	包到达的速率（接收端）
	output	[31:0]	AckSeqNo_o ,						//%	最后ACK的序列号
	output	[31:0]	LastAckTime_o ,						//%	最后LAST的ACK时间戳
	output	[31:0]	SYNInterval_o ,						//%	同步（SYN）周期
	output	[31:0]	RRT_o ,								//%	往返时延的均值
	output	[31:0]	RTTVar_o ,							//%	往返时延的方差
	output	[31:0]	MinNakInt_o ,						//%	最小NAK周期
	output	[31:0]	MinExpInt_o ,						//%	最小EXP周期
	output	[31:0]	ACKInt_o ,							//%	ACK 发送周期
	output	[31:0]	NAKInt_o ,							//%	NAK 发送周期
	output	[31:0]	PktCount_o ,						//%	packet counter for ACK
	output	[31:0]	LightACKCount_o ,					//%	light ACK 计数器
	output	[31:0]	TargetTime_o ,						//%	下个Packet发送时间				
	output	[31:0]	TimeDiff_o ,						//%	aggregate difference in inter-packet time   
	
	output	[31:0]	PeerISN_o ,							//%	对端初始化的数据包序列号
	output	[31:0]	RcvLastAck_o ,						//%	接收端 最后发送ACK（数据包序列号）
	output	[31:0]	RcvLastAckAck_o ,					//%	接收端 最后发送ACK 被ACK的（数据）序列号
	output	[31:0]	RcvCurrSeqNo_o ,					//%	最大的接收的序列号
	output	[31:0]	LastDecSeq_o  ,						//%	Sequence number sent last decrease occurs 
	output	[31:0]	SndLastAck_o  ,						//%	Last ACK received
	output	[31:0]	SndLastDataAck_o ,					//%	The real last ACK that updates the sender buffer and loss list		
	output	[31:0]	SndCurrSeqNo_o ,					//%	The largest sequence number that has been sent
	output	[31:0]	SndLastAck2_o  ,					//%	Last ACK2 sent back 
	output	[31:0]	SndLastAck2Time_o ,					//%	Last time of ACK2 sent back
	output	[31:0]	FlowWindowSize_o ,					//%	SND list  size
	
	output	[31:0]	LastRspTime_o,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
	output	[31:0]	NextACKTime_o,						//%	用于ACK Timers
	output	[31:0]	NextNACKtime_o,						//%	用于NACK Timers
	
	output	[63:0]	req_tdata_o	,						//%	请求握手数据包
	output	[7:0]	req_tkeep_o	,						//%	请求握手数据使能信号
	output			req_tvalid_o	,					//%	请求握手数据有效信号
	input			req_tready_i	,					//%	请求握手数据就绪信号
	input			req_tlast_i							//%	请求握手数据结束信号
	
	input	close_tvalid_i	,							//%	关闭控制包有效
	input	[63:0]	close_tdata_i		,				//%	关闭控制数据包
	input	[7:0]	close_tkeep_i		,				//%	关闭控制使能信号
	input	close_tlast_i				,				//%	关闭控制结束信号
	output	close_tready_o								//%	关闭控制就绪信号
);



connect  connect_inst(
		.core_clk(core_clk),
		.core_rst_n(core_rst_n),
		.handshake_tdata_i(handshake_tdata_i) ,
		.handshake_tkeep_i(handshake_tkeep_i) ,
		.handshake_tvalid_i(handshake_tvalid_i),
		.handshake_tready_o(handshake_tready_o),
		.handshake_tlast_i(handshake_tlast_i),
		
		.Req_Connect_i(Req_Connect_i),								
		.Res_Connect_o(Res_Connect_o),										
		.Snd_Buffer_Size_i(Snd_Buffer_Size_i),					
		.Rev_Buffer_Size_i(Rev_Buffer_Size_i),					
		.FlightFlagSize_i(FlightFlagSize_i),			
		.MSSize_i(MSSize_i),
		.Max_PktSize_o(Max_PktSize_o) ,						
		.Max_PayloadSize_o(Max_PayloadSize_o) ,
		.Expiration_counter_o(Expiration_counter_o),
		.Bandwidth_o(Bandwidth_o) ,
		.DeliveryRate_o(DeliveryRate_o),
		.AckSeqNo_o(AckSeqNo_o),
		.LastAckTime_o(LastAckTime_o),
		.SYNInterval_o(SYNInterval_o),
		.RRT_o(RRT_o) ,
		.RTTVar_o(RTTVar_o) ,
		.MinNakInt_o(MinNakInt_o),
		.MinExpInt_o(MinExpInt_o),
		.ACKInt_o(ACKInt_o),
		.NAKInt_o(NAKInt_o),
		.PktCount_o(PktCount_o),
		.LightACKCount_o(LightACKCount_o),
		.TargetTime_o(TargetTime_o),
		.TimeDiff_o(TimeDiff_o),
		.PeerISN_o(PeerISN_o) ,							
		.RcvLastAck_o(RcvLastAck_o) ,					
		.RcvLastAckAck_o(RcvLastAckAck_o) ,					
		.RcvCurrSeqNo_o(RcvCurrSeqNo_o) ,					
		.LastDecSeq_o(LastDecSeq_o)  ,						 
		.SndLastAck_o(SndLastAck_o)  ,						
		.SndLastDataAck_o(SndLastDataAck_o),							
		.SndCurrSeqNo_o(SndCurrSeqNo_o) ,						
		.SndLastAck2_o(SndLastAck2_o) ,						
		.SndLastAck2Time_o(SndLastAck2Time_o) ,					
		.FlowWindowSize_o(FlowWindowSize_o) ,
		.LastRspTime_o(LastRspTime_o),
		.NextACKTime_o(NextACKTime_o),
		.NextNACKtime_o(NextNACKtime_o),
		
		.req_tdata_o(req_tdata_o),
		.req_tkeep_o(req_tkeep_o),
		.req_tvalid_o(req_tvalid_o),
		.req_tready_i(req_tready_o),
		.req_tlast_o(req_tlast_o)
);



ProcessClose	ProcessClose_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	

	.close_tvalid_i(close_tvalid_i),
	.close_tdata_i(close_tdata_i),
	.close_tkeep_i(close_tkeep_i),
	.close_tlast_i(close_tlast_i),
	.close_tready_o(close_tready_o)
);



close	close_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	
	
	
	.Req_Close_i(Req_Close),
	.Res_Close_o(Res_Close)

);
EXPtimer	EXPtimer_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),


);






endmodule