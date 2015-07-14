﻿//%	@file	ClientManager.v
//%	@brief	本文件定义client manager模块

//%	本模块是管理CLIENT端的SOCKET的链接和参数初始化的模块
//%	@details
//%		step1: configure模块配置完参数后，发送连接请求，就开始初始化部分参数：
//%				Max_PktSize	= MSSize – 28  
//%				Max_PayloadSize = Max_PktSize – UDT头 
//%				Expiration_counter = 1 ; //  用于EXP-timer
//%				Bandwidth = 1 ;
//%				DeliveryRate = 16 ;
//%				AckSeqNo =  0 ； 
//%				LastAckTime  = 0 ； 
//%				SYNInterval =  10000  us(10ms)  
//%				RRT	=	SYNInterval * 10;  
//%				RTTVar =  SYNInterval/2;  
//%				MinNakInt	=	300,000us(300ms); 
//%				MinExpInt		=	300,000us(300ms);
//%				ACKInt		=	SYNInterval ;  
//%				NAKInt		=	MinNakInt;  
//%				PktCount		=	0 ; 
//%				LightACKCount  =  1 ; 
//%				TargetTime	=	0;
//%				TimeDiff     =    0; 
//%		step2:	发送请求包，从configure获取相应的参数，如UDT_VERISON(UDT版本),SOCKET_TPYE(套节字类型), MAX_PACKET_SIZE(最大包大小),MAX_FLOW_WINDOWS_SIZE(最大流量窗口大小)、CONNECT_TYPE(接类型设置为1), SOCKET_ID (自己的Socket id).
//%				PACKET-> SOCKET_ID =  0 ;
//%				INIT_PACKET_SEQ_NUM = 0 ;
//%				Cookie值随机不从寄存器获取。
//%				LastDecSeq =  INIT_PACKET_SEQ_NUM -1 
//%				SndLastAck =  INIT_PACKET_SEQ_NUM  
//%				SndLastDataAck  =  INIT_PACKET_SEQ_NUM  // The real last ACK that updates the sender buffer and loss list
//%				SndCurrSeqNo  =   INIT_PACKET_SEQ_NUM -1  // The largest sequence number that has been sent
//%				SndLastAck2    =  INIT_PACKET_SEQ_NUM    //  Last ACK2 sent back
//%				发送请求握手包
//%				SndLastAck2Time  =  当前时间  // The time when last ACK2 was sent back
//%		step3:	若当前时间和发送请求包时间相隔250ms,则重新再发请求包，继续进行步骤2.若有新的包到达，则解析此包。
//%		step4:	
//%				若接收的包不是握手包，则为连接错误,将connect 置为0，修改状态寄存器(此处可能为UDT连接的一个BUG，因为重新配置协议的值是并不可少的，并且这个会影响发送和接收),若此包连接类型为1，则把CONNECT_TYPE接类型设置为-1 ，Cookie值为对端的Cookie值，跳转到步骤3。若此包连接类型不为1，则重新配置UDT参数，如下：
//%				MAX_PACKET_SIZE =  res-> MAX_PACKET_SIZE;
//%				Update: Max_PktSize, Max_PayloadSize
//%				FlowWindowSize =  res-> MAX_FLOW_WINDOWS_SIZE；
//%				PeerISN =  res-> INIT_PACKET_SEQ_NUM ;     /*对端初始化的数据包序列号*/
//%				RcvLastAck =  res-> INIT_PACKET_SEQ_NUM ;  /*接收端 最后发送ACK（数据包序列号）*/
//%				RcvLastAckAck = res-> INIT_PACKET_SEQ_NUM ; /*接收端 最后发送ACK 被ACK的（数据）序列号 */
//%				RcvCurrSeqNo = res-> INIT_PACKET_SEQ_NUM - 1;  /*最大的接收的序列号*/
//%				算法中各个数据类型的size由次步骤来配置，如发送BUFFER,接收BUFFER,发送丢失LIST，接收丢失LIST，ACK包历史窗口，接收历史窗口和发送历史窗口。初始化拥塞控制参数。
//%		step5:	连接完成返回连接成功的状态


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




endmodule