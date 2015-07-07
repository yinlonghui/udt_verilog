﻿//%	@file	server_manager.v
//%	@brief	本文件定义server manager模块


module server_manager(
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
	input	[31:0]	MSSize,								//%	最大包大小
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
	output	[31:0]	FlowWindowSize ,						//%	SND list  size
	output	[63:0]	req_tdata	,						//%	请求握手数据包
	output	[7:0]	req_tkeep	,						//%	请求握手数据使能信号
	output			req_tvalid	,						//%	请求握手数据有效信号
	input			req_tready	,						//%	请求握手数据就绪信号
	input			req_tlast							//%	请求握手数据结束信号

);




endmodule