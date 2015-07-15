//%	@file	listen.v
//%	@brief	本文件定义listen模块



//%	本模块是管理SERVER端的SOCKET的链接和参数初始化的模块
//%	@details
//%		ServerManager功能如下：
//%		1、连接CLIENT端，进行通信，通过configure模块创建套接字,监听CLIENT端，三次握手通信后建立连接。
//%		2、关闭连接
//%		step1: configure模块配置完参数后，发送listen请求，就开始初始化部分参数：
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
//%		step2:	等待Client端发出请求，得到Client发到的握手信号后，根据服务器的地址产生一个cookie，把packet的destination Socket ID 改一下，发送给Serve端。进入step3
//%		step3:	等待Client端继续发出确认请求，确定Client的cookie是校验正确的进入step4，否则继续进行step3。
//%		step4:	初始化全局变量
//%				PeerISN =  res-> INIT_PACKET_SEQ_NUM ;     /*对端初始化的数据包序列号*/
//%				RcvLastAck =  res-> INIT_PACKET_SEQ_NUM ;  /*接收端 最后发送ACK（数据包序列号）*/
//%				RcvLastAckAck = res-> INIT_PACKET_SEQ_NUM ; /*接收端 最后发送ACK 被ACK的（数据）序列号 */
//%				RcvCurrSeqNo = res-> INIT_PACKET_SEQ_NUM - 1;  /*最大的接收的序列号*/
//%				LastDecSeq  =  res-> INIT_PACKET_SEQ_NUM - 1; /* Sequence number sent last decrease occurs */
//%				SndLastAck  = res-> INIT_PACKET_SEQ_NUM;  /* Last ACK received */
//%				SndLastDataAck = res-> INIT_PACKET_SEQ_NUM; /* The real last ACK that updates the sender buffer and loss list*/
//%				SndCurrSeqNo = res-> INIT_PACKET_SEQ_NUM – 1 // The largest sequence number that has been sent
//%				SndLastAck2  =  res-> INIT_PACKET_SEQ_NUM 
//%				SndLastAck2Time =  curr_time 
//%				SOCKET_ID  =  socket_id 
//%				PACKET-> SOCKET_ID =  Res->socket_id 
//%				m_iReqType  =  -1 
//%				FlowWindowSize =  res-> MAX_FLOW_WINDOWS_SIZE  [此为SND_LIST_SIZE]
//%				MSSize =  res-> MSSize <  MSSize ? res-> MSSize: MSSize ;
//%				Max_PktSize	= MSSize – 28  				
//%				Max_PayloadSize = Max_PktSize – UDT头
//%				及一系列拥塞控制的参数
//%		step5:   若Client端继续发送请求握手包，则SERVER端发送与step4相同的连接握手包。若Client端发过来的数据，则次连接已经建立，可以正常的发送和接收数据。






module	listen(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	input	[63:0]	handshake_tdata ,					//%	握手数据包
	input	[7:0]	handshake_tkeep ,					//%	握手包字节使能
	input			handshake_tvalid,					//%	握手包有效信号
	output			handshake_tready,					//%	握手包就绪信号
	input			handshake_tlast	,					//%	握手包结束信号

	
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
	
	output	[31:0]	LastRspTime,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
	output	[31:0]	NextACKTime,						//%	用于ACK Timers
	output	[31:0]	NextNACKtime,						//%	用于NACK Timers
	
	output	[63:0]	req_tdata	,						//%	请求握手数据包
	output	[7:0]	req_tkeep	,						//%	请求握手数据使能信号
	output			req_tvalid	,						//%	请求握手数据有效信号
	input			req_tready	,						//%	请求握手数据就绪信号
	input			req_tlast							//%	请求握手数据结束信号
);



endmodule