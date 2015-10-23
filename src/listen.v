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
	output	reg		handshake_tready,					//%	握手包就绪信号
	input			handshake_tlast	,					//%	握手包结束信号

	
	input	Req_Connect ,								//%	连接请求
	output	reg	Res_Connect ,								//% 连接回应
	input	Req_Close	,								//%	关闭请求-（Close模块提供）
	output	reg	Res_Close	,								//%	关闭回应
	input	[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
	input	[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
	input	[31:0]	FlightFlagSize ,					//%	最大流量窗口大小
	input	[31:0]	MSSize,								//%	最大包大小
	input	[31:0]	INIT_SEQ,							//%	初始化序列号
	output	reg	[31:0]	Max_PktSize ,						//%	最大包大小
	output	reg	[31:0]	Max_PayloadSize ,					//% 最大负载数据大小
	output	reg	[31:0]	Expiration_counter ,				//%	EXP-timer计数器
	output	reg	[31:0]	Bandwidth ,							//%	带宽的预估值，1秒1个包
	output	reg	[31:0]	DeliveryRate ,						//%	包到达的速率（接收端）
	output	reg	[31:0]	AckSeqNo ,							//%	最后ACK的序列号
	output	reg	[31:0]	LastAckTime ,						//%	最后LAST的ACK时间戳
	output	reg	[31:0]	SYNInterval ,						//%	同步（SYN）周期
	output	reg	[31:0]	RRT ,								//%	往返时延的均值
	output	reg	[31:0]	RTTVar ,							//%	往返时延的方差
	output	reg	[31:0]	MinNakInt,							//%	最小NAK周期
	output	reg	[31:0]	MinExpInt,							//%	最小EXP周期
	output	reg	[31:0]	ACKInt,								//%	ACK 发送周期
	output	reg	[31:0]	NAKInt,								//%	NAK 发送周期
	output	reg	[31:0]	PktCount,							//%	packet counter for ACK
	output	reg	[31:0]	LightACKCount ,						//%	light ACK 计数器
	output	reg	[31:0]	TargetTime ,						//%	下个Packet发送时间				
	output	reg	[31:0]	TimeDiff,							//%	aggregate difference in inter-packet time   
	
	output	reg	[31:0]	PeerISN ,							//%	对端初始化的数据包序列号
	output	reg	[31:0]	RcvLastAck ,						//%	接收端 最后发送ACK（数据包序列号）
	output	reg	[31:0]	RcvLastAckAck ,						//%	接收端 最后发送ACK 被ACK的（数据）序列号
	output	reg	[31:0]	RcvCurrSeqNo ,						//%	最大的接收的序列号
	output	reg	[31:0]	LastDecSeq  ,						//%	Sequence number sent last decrease occurs 
	output	reg	[31:0]	SndLastAck  ,						//%	Last ACK received
	output	reg	[31:0]	SndLastDataAck ,					//%	The real last ACK that updates the sender buffer and loss list		
	output	reg	[31:0]	SndCurrSeqNo ,						//%	The largest sequence number that has been sent
	output	reg	[31:0]	SndLastAck2  ,						//%	Last ACK2 sent back 
	output	reg	[31:0]	SndLastAck2Time ,					//%	Last time of ACK2 sent back
	output	reg	[31:0]	FlowWindowSize ,						//%	SND list  size
	
	output	reg	[31:0]	LastRspTime,						//%	最后一次对端响应的时间戳。用于EXP Timers , 同时只要有udp数据到来就修改该变量
	output	reg	[31:0]	NextACKTime,						//%	用于ACK Timers
	output	reg	[31:0]	NextNACKtime,						//%	用于NACK Timers
	output	reg	[31:0]	NEG_MSSize	,
	
	output	reg	[63:0]	req_tdata	,						//%	请求握手数据包
	output	reg	[7:0]	req_tkeep	,						//%	请求握手数据使能信号
	output	reg		req_tvalid	,						//%	请求握手数据有效信号
	input			req_tready	,						//%	请求握手数据就绪信号
	output	reg			req_tlast							//%	请求握手数据结束信号
);

integer	State	,	Next_State	;

/*
*	analyzing	the handshake packet.
*/

reg	[31:0]	Peer_type	;
reg	[31:0]	Peer_AddInfo	;

reg	[31:0]	Peer_TimeStamp ;
reg	[31:0]	Peer_Des_ID	;

reg	[31:0]	Peer_UDT_Version ;
reg	[31:0]	Peer_Socket_type ;

reg	[31:0]	Peer_INIT_SEQ_NUM ;
reg	[31:0]	Peer_MSS	;

reg	[31:0]	Peer_MAX_FLOW_WINDOWS_SIZE ;
reg	[31:0]	Peer_CONNECT_Type ;

reg	[31:0]	Peer_Self_ID	;
reg	[31:0]	Peer_SYN_cookie	;

reg	[63:0]	Peer_IP_ADDRESS1 ;
reg	[63:0]	Peer_IP_ADDRESS2 ;


reg	conditon	;


localparam	S_IDLE	=	1  ,
			S_INIT	=	2  ,
			S_START	=	3  ,
			S_PARSE_HAND_1_IDLE	=	4	,
			S_PARSE_HAND_1	=	5	,
			S_PARSE_HAND_2_IDLE	=	6	,
			S_PARSE_HAND_2		=	7	,
			S_PARSE_HAND_3_IDLE	=	8	,
			S_PARSE_HAND_3		=	9	,
			S_PARSE_HAND_4_IDLE	=	10	,
			S_PARSE_HAND_4		=	11	,
			S_PARSE_HAND_5_IDLE	=	12	,
			S_PARSE_HAND_5		=	13	,
			S_PARSE_HAND_6_IDLE	=	14	,
			S_PARSE_HAND_6		=	15	,
			S_PARSE_HAND_7_IDLE	=	16	,
			S_PARSE_HAND_7		=	17	,
			S_PARSE_HAND_8_IDLE	=	18	,
			S_PARSE_HAND_8		=	19	,
			S_WAIT_1		=		20  ,
			S_RES_HAND_1	=		21	,
			S_RES_HAND_2	=		22	,
			S_RES_HAND_3	=		23	,
			S_RES_HAND_4	=		24	,
			S_RES_HAND_5	=		25	,
			S_RES_HAND_6	=		26	,
			S_RES_HAND_7	=		27	,
			S_RES_HAND_8	=		28	,
			S_WAIT_2		=		29	,
			S_FIRST_RES		=		30	,
			S_SECOND_RES		=		31	,
			S_CONNECTED		=		32	,
			S_CLOSE			=		33	,
			S_ERR			=		34	;
			

always@(posedge	core_clk	or	negedge	core_rst_n)
begin

	if(!core_rst_n)
		State	<=	S_IDLE	;
	else
		State	<=	Next_State	;
end


always@(*)
begin
	case(State)
		S_IDLE:
			if(Req_Connect)
				Next_State	=	S_INIT	;
			else
				Next_State	=	S_IDLE	;
		S_INIT:
			Next_State	=	S_START	;
		S_START:
			if( Req_Close )
				Next_State	=	S_CLOSE ;
			else	if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_1	;
			else
				Next_State	=	S_START ;
		/*
		S_PARSE_HAND_1_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_1_WAIT	;
			else
				Next_State	=	S_PARSE_HAND_1_IDLE	;
		*/
		S_PARSE_HAND_1:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_2	;
			else
				Next_State	=	S_PARSE_HAND_2_IDLE ;
		S_PARSE_HAND_2_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_2	;
			else
				Next_State	=	S_PARSE_HAND_2_IDLE ;
		S_PARSE_HAND_2:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_3	;
			else
				Next_State	=	S_PARSE_HAND_3_IDLE	;
		S_PARSE_HAND_3_IDLE:
				if(handshake_tvalid)
					Next_State	=	S_PARSE_HAND_3	;
				else
					Next_State	=	S_PARSE_HAND_3  ;
		S_PARSE_HAND_3:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_4	;
			else
				Next_State	=	S_PARSE_HAND_4_IDLE ;
		S_PARSE_HAND_4_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_4	;
			else
				Next_State	=	S_PARSE_HAND_4_IDLE	;
		S_PARSE_HAND_4:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_5	;
			else
				Next_State	=	S_PARSE_HAND_5_IDLE ;
		S_PARSE_HAND_5_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_5	;
			else
				Next_State	=	S_PARSE_HAND_5_IDLE ;
		S_PARSE_HAND_5:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_6	;
			else
				Next_State	=	S_PARSE_HAND_6_IDLE	;
		S_PARSE_HAND_6_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_6	;
			else
				Next_State	=	S_PARSE_HAND_6_IDLE ;
		S_PARSE_HAND_6:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_7	;
			else
				Next_State	=	S_PARSE_HAND_7_IDLE	;
		S_PARSE_HAND_7_IDLE:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_7	;
			else
				Next_State	=	S_PARSE_HAND_7_IDLE	;
		S_PARSE_HAND_7:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_8	;
			else
				Next_State	=	S_PARSE_HAND_8_IDLE ;
		S_PARSE_HAND_8_IDLE:
			if(handshake_tvalid && handshake_tlast)
				Next_State	=	S_PARSE_HAND_8	;
			else	if(handshake_tvalid)
				Next_State	=	S_ERR	;
			else
				Next_State	=	S_PARSE_HAND_8_IDLE ;
		
		S_PARSE_HAND_8:
			if(conditon) 
				Next_State	=	S_WAIT_1 ;
			else	
				Next_State	=	S_WAIT_2 ;
		
		S_RES_HAND_1:
			if(req_tready)
				Next_State	=	S_RES_HAND_2	;
			else
				Next_State	=	S_RES_HAND_1	;
		S_RES_HAND_2:
			if(req_tready)
				Next_State	=	S_RES_HAND_3	;
			else
				Next_State	=	S_RES_HAND_2	;
		S_RES_HAND_3:
			if(req_tready)
				Next_State	=	S_RES_HAND_4	;
			else
				Next_State	=	S_RES_HAND_3	;
		S_RES_HAND_4:
			if(req_tready)
				Next_State	=	S_RES_HAND_5	;
			else
				Next_State	=	S_RES_HAND_4	;
		S_RES_HAND_5:
			if(req_tready)
				Next_State	=	S_RES_HAND_6	;
			else
				Next_State	=	S_RES_HAND_5	;
		S_RES_HAND_6:
			if(req_tready)
				Next_State	=	S_RES_HAND_7	;
			else
				Next_State	=	S_RES_HAND_6	;
		S_RES_HAND_7:
			if(req_tready)
				Next_State	=	S_RES_HAND_8	;
			else
				Next_State	=	S_RES_HAND_7	;
		S_RES_HAND_8:
			if(req_tready)
				Next_State	=	S_START	;
			else
				Next_State	=	S_RES_HAND_8	;

		S_WAIT_1:	Next_State	=	S_FIRST_RES	;
		S_WAIT_2:
			if(Peer_CONNECT_Type == 1)
				Next_State	=	S_FIRST_RES	;
			else
				Next_State	=	S_SECOND_RES	;
		S_FIRST_RES:	Next_State	=	S_RES_HAND_1	;
		S_SECOND_RES:	Next_State	=	S_CONNECTED	;
		S_CONNECTED:	Next_State	=	S_RES_HAND_1	;
		S_CLOSE:	Next_State	=	S_IDLE		;
		S_ERR:		Next_State	=	S_ERR		;
		default:
				Next_State	=	'bx	;
	endcase

end

always@(posedge	core_clk	or	negedge	core_rst_n)
begin
	if(!core_rst_n)
	begin
		/*	all  output	reg  */
		handshake_tready	<=	0	;
		Res_Connect			<=	0	;
		Res_Close			<=	0	;
		Max_PktSize			<=	32'h0	;
		Max_PayloadSize		<=	32'h0	;
		Expiration_counter	<=	32'h0	;
		Bandwidth			<=	32'h0	;
		DeliveryRate		<=	32'h0	;
		AckSeqNo			<=	32'h0	;
		LastAckTime			<=	32'h0	;
		SYNInterval			<=	32'h0	;
		RRT					<=	32'h0	;
		RTTVar				<=	32'h0	;
		MinNakInt			<=	32'h0	;
		MinExpInt			<=	32'h0	;
		ACKInt				<=	32'h0	;
		NAKInt				<=	32'h0	;
		PktCount			<=	32'h0	;
		LightACKCount		<=	32'h0	;
		TargetTime			<=	32'h0	;
		TimeDiff			<=	32'h0	;
		PeerISN				<=	32'h0	;
		RcvLastAck			<=	32'h0	;
		RcvLastAckAck		<=	32'h0	;
		RcvCurrSeqNo		<=	32'h0	;
		LastDecSeq			<=	32'h0	;
		SndLastAck			<=	32'h0	;
		SndLastDataAck		<=	32'h0	;
		SndCurrSeqNo		<=	32'h0	;
		SndLastAck2			<=	32'h0	;
		SndLastAck2Time		<=	32'h0	;
		FlowWindowSize		<=	32'h0	;
		LastRspTime			<=	32'h0	;
		NextACKTime			<=	32'h0	;
		NextNACKtime		<=	32'h0	;
		req_tdata			<=	64'h0	;
		req_tkeep			<=	8'h0;
		req_tvalid			<=	0		;
		req_tlast			<=	0		;
		/*	temp	reg  */
		Peer_type		<=	32'h0 ;
		Peer_AddInfo		<=	32'h0 ;
		Peer_TimeStamp		<=	32'h0 ;
		Peer_Des_ID		<=	32'h0 ;
		Peer_UDT_Version	<=	32'h0 ;
		Peer_Socket_type	<=	32'h0 ;
		Peer_INIT_SEQ_NUM	<=	32'h0 ;
		Peer_MSS		<=	32'h0 ;
		Peer_MAX_FLOW_WINDOWS_SIZE	<=	32'h0;
		Peer_CONNECT_Type	<=	32'h0;
		Peer_Self_ID		<=	32'h0;
		Peer_SYN_cookie		<=	32'h0;
		Peer_IP_ADDRESS1	<=	32'h0;
		Peer_IP_ADDRESS2	<=	32'h0;
		conditon		<=	    1;
		NEG_MSSize		<=		0;
	end
	else	begin
		case	(Next_State)
			S_IDLE:	begin
			/*	all  output	reg */
				handshake_tready	<=	0	;
				Res_Connect			<=	0	;
				Res_Close			<=	0	;
				Max_PktSize			<=	32'h0	;
				Max_PayloadSize		<=	32'h0	;
				Expiration_counter	<=	32'h0	;
				Bandwidth			<=	32'h0	;
				DeliveryRate		<=	32'h0	;
				AckSeqNo			<=	32'h0	;
				LastAckTime			<=	32'h0	;
				SYNInterval			<=	32'h0	;
				RRT					<=	32'h0	;
				RTTVar				<=	32'h0	;
				MinNakInt			<=	32'h0	;
				MinExpInt			<=	32'h0	;
				ACKInt				<=	32'h0	;
				NAKInt				<=	32'h0	;
				PktCount			<=	32'h0	;
				LightACKCount		<=	32'h0	;
				TargetTime			<=	32'h0	;
				TimeDiff			<=	32'h0	;
				PeerISN				<=	32'h0	;
				RcvLastAck			<=	32'h0	;
				RcvLastAckAck		<=	32'h0	;
				RcvCurrSeqNo		<=	32'h0	;
				LastDecSeq			<=	32'h0	;
				SndLastAck			<=	32'h0	;
				SndLastDataAck		<=	32'h0	;
				SndCurrSeqNo		<=	32'h0	;
				SndLastAck2			<=	32'h0	;
				SndLastAck2Time		<=	32'h0	;
				FlowWindowSize		<=	32'h0	;
				LastRspTime			<=	32'h0	;
				NextACKTime			<=	32'h0	;
				NextNACKtime		<=	32'h0	;
				req_tdata			<=	64'h0	;
				req_tkeep			<=	8'hff	;
				req_tvalid			<=	0		;
				req_tlast			<=	0		;
			/*	temp	reg  */
				Peer_type		<=	32'h0 ;
				Peer_AddInfo		<=	32'h0 ;
				Peer_TimeStamp		<=	32'h0 ;
				Peer_Des_ID		<=	32'h0 ;
				Peer_UDT_Version	<=	32'h0 ;
				Peer_Socket_type	<=	32'h0 ;
				Peer_INIT_SEQ_NUM	<=	32'h0 ;
				Peer_MSS		<=	32'h0 ;
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	32'h0;
				Peer_CONNECT_Type	<=	32'h0;
				Peer_Self_ID		<=	32'h0;
				Peer_SYN_cookie		<=	32'h0;
				Peer_IP_ADDRESS1	<=	32'h0;
				Peer_IP_ADDRESS2	<=	32'h0;
				NEG_MSSize			<=	32'h0;
				conditon		<=	1    ;
				
			end
			S_INIT:	begin
				Res_Connect			<=	1	;
				Max_PktSize	<=	MSSize	-	32'd28	;
				Max_PayloadSize	<=	MSSize	-	32'd44	;
				Expiration_counter	<=	32'h1;
				Bandwidth		<=	32'h1;
				DeliveryRate		<=	32'h16	;
				AckSeqNo		<=	32'h0	;
				LastAckTime		<=	32'h0	;
				SYNInterval		<=	32'd 200_000_0 ;
				RRT			<=	32'd 2000_000_0 ;
				RTTVar			<=	32'd 1000_000_0 ;
				MinExpInt		<=	32'd 6000_000_0 ;
				MinNakInt		<=	32'd 6000_000_0 ;
				ACKInt			<=	32'd 200_000_0  ;
				NAKInt			<=	32'd 6000_000_0 ;
				PktCount		<=	32'h0	;
				LightACKCount		<=	32'h1	;
				TargetTime		<=	32'h0	;
				TimeDiff		<=	32'h0	;
			/*	temp	reg  */
				Peer_type		<=	32'h0 ;
				Peer_AddInfo		<=	32'h0 ;
				Peer_TimeStamp		<=	32'h0 ;
				Peer_Des_ID		<=	32'h0 ;
				Peer_UDT_Version	<=	32'h0 ;
				Peer_Socket_type	<=	32'h0 ;
				Peer_INIT_SEQ_NUM	<=	32'h0 ;
				Peer_MSS		<=	32'h0 ;
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	32'h0;
				Peer_CONNECT_Type	<=	32'h0;
				Peer_Self_ID		<=	32'h0;
				Peer_SYN_cookie		<=	32'h0;
				Peer_IP_ADDRESS1	<=	32'h0;
				Peer_IP_ADDRESS2	<=	32'h0;
				NEG_MSSize			<=	MSSize	;
			end
			S_START:
			begin
				Res_Connect			<=	0	;
				req_tlast			<=	0	;
				handshake_tready	<=	1 	;
			end
			S_PARSE_HAND_1_IDLE:
			begin  //  NULL valid  			
				handshake_tready	<=	1 ;
			end
			S_PARSE_HAND_1:
			begin
				Peer_type		<=	handshake_tdata[63:32] ;
				Peer_AddInfo		<=	handshake_tdata[31:0 ] ;
			end
			S_PARSE_HAND_2_IDLE:
			begin	
			end
			S_PARSE_HAND_2:
			begin
				Peer_TimeStamp		<=	handshake_tdata[63:32] ;
				Peer_Des_ID		<=	handshake_tdata[31:0 ] ;
			end
			/*
			* 	32bit	load Verison..
			*	32bit	load Type... DGRAM or ...
			*/
			S_PARSE_HAND_3_IDLE:
			begin
			end
			S_PARSE_HAND_3:
			begin
				//handshake_tready	<=	0 ;
				Peer_UDT_Version	<=	handshake_tdata[63:32] ;
				Peer_Socket_type	<=	handshake_tdata[31:0 ] ;
			end
			/*
			* 	32bit	init_packet_num
			* 	32bit	maximum	packet size
			*/
			S_PARSE_HAND_4_IDLE:
			begin
			end
			S_PARSE_HAND_4:
			begin
				Peer_INIT_SEQ_NUM	<=	handshake_tdata[63:32] ;
				Peer_MSS		<=	handshake_tdata[31:0 ] ;
			end
			/*
			*	32bit maximum	flow windows size
			*	32bit connect	type	
			*/
			S_PARSE_HAND_5_IDLE:
			begin
			end
			S_PARSE_HAND_5:
			begin
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	handshake_tdata[63:32] ;
				Peer_CONNECT_Type		<=	handshake_tdata[31:0 ] ;
			end
			/*
			* 	32bit	socket	ID
			* 	32bit	SYN	cookie
			*/
			S_PARSE_HAND_6_IDLE:
			begin
			end
			S_PARSE_HAND_6:
			begin
				Peer_Self_ID		<=	handshake_tdata[63:32]	;
				Peer_SYN_cookie		<=	handshake_tdata[31:0]	;
			end
			/*
			*	first 64bit of peer	IP	ADDRESS	 
			*/
			S_PARSE_HAND_7_IDLE:
			begin
			end
			S_PARSE_HAND_7:
			begin
				Peer_IP_ADDRESS1	<=	handshake_tdata	;
			end
			/*
			*	last 64bit of  peer	IP	ADDRESS	 
			*/
			S_PARSE_HAND_8_IDLE:
			begin
			end
			S_PARSE_HAND_8:
			begin
				if(Peer_CONNECT_Type == 0 )
					conditon	=	1 ;
				else
					conditon	=	0 ;
				Peer_IP_ADDRESS2	<=	handshake_tdata ;
			end

			S_RES_HAND_1:
			begin
				req_tdata		<= { Peer_type , Peer_AddInfo  } ;
				req_tkeep		<= 8'hff;
				req_tvalid		<=	1;
				handshake_tready	<=     0;

			end
			S_RES_HAND_2:
			begin
				req_tdata		<= { Peer_TimeStamp , Peer_Des_ID } ;
				req_tkeep		<= 8'hff ;
				req_tvalid		<=     1;
			end
			S_RES_HAND_3:
			begin
				req_tdata		<= {Peer_UDT_Version , Peer_Socket_type } ;
				req_tkeep		<= 8'hff  ;
				req_tvalid		<=	1 ;
			end
			S_RES_HAND_4:
			begin
				req_tdata		<= {Peer_INIT_SEQ_NUM , Peer_MSS	};
				req_tkeep		<= 8'hff  ;
				req_tvalid		<=	1 ; 
			end
			S_RES_HAND_5:
			begin
				req_tdata		<= {Peer_MAX_FLOW_WINDOWS_SIZE , Peer_CONNECT_Type } ;
				req_tkeep		<= 8'hff ;
				req_tvalid		<=	1 ;
			end
			S_RES_HAND_6:
			begin
				req_tdata		<= {Peer_Self_ID ,	Peer_SYN_cookie } ;
				req_tkeep		<= 8'hff ;
				req_tvalid		<=	1 ;
			end
			S_RES_HAND_7:
			begin
				req_tdata		<=	Peer_IP_ADDRESS1 ;
				req_tkeep		<=	8'hff ;
				req_tvalid		<=	1	;
			end
			S_RES_HAND_8:
			begin
				req_tdata		<=	Peer_IP_ADDRESS2 ;
				req_tkeep		<=	8'hff ;
				req_tvalid		<=	1	;
				req_tlast		<=	1	;
			end
			S_WAIT_1:
			begin
				req_tvalid		<=	0	;
				handshake_tready	<=	0	;
			end
			S_WAIT_2:
			begin
				req_tvalid		<=	0	;
				handshake_tready	<=	0	;
			end
			S_FIRST_RES:
			begin
				Peer_Des_ID		<=	Peer_Self_ID	;
				Peer_CONNECT_Type	<=	32'h1		;
				Peer_SYN_cookie		<=	32'h0		;
			end
			S_SECOND_RES:
			begin
				FlowWindowSize		<=	Peer_MAX_FLOW_WINDOWS_SIZE ;
				Peer_Self_ID		<=	32'h10			   ;
				Peer_Des_ID		<=	Peer_Self_ID	;

				if( Peer_MSS	> MSSize)
				begin
					Peer_MSS	<=	MSSize ;
					NEG_MSSize	<=	MSSize ;
				end
				else
				begin
					NEG_MSSize		<=	Peer_MSS ;
				end


				Peer_CONNECT_Type	<=	32'hffff_ffff			;
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	( Rev_Buffer_Size < FlightFlagSize ) ?  Rev_Buffer_Size :  FlightFlagSize ;
				/*Peer_IP must be changed */


			end
			S_CONNECTED:
			begin
			/*
			*	Peer_ID  output
			*/
		       	PeerISN	<=	Peer_INIT_SEQ_NUM	;
				Max_PktSize	<=	MSSize	-	32'd28	;
				Max_PayloadSize	<=	MSSize	-	32'd44	;
				LastDecSeq	<=	Peer_INIT_SEQ_NUM	-	32'h1	;
				SndLastAck	<=	Peer_INIT_SEQ_NUM	-	32'h1	;
				SndLastDataAck	<=	Peer_INIT_SEQ_NUM	;
				SndCurrSeqNo	<=	Peer_INIT_SEQ_NUM	;
				SndLastAck2	<=	Peer_INIT_SEQ_NUM	;
				SndLastAck2Time	<=	32'h0			;

				RcvLastAck	<=	Peer_INIT_SEQ_NUM	;
				RcvLastAckAck	<=	Peer_INIT_SEQ_NUM	-	32'h1	;
				RcvCurrSeqNo	<=	Peer_INIT_SEQ_NUM	;
			end
			S_CLOSE:
			begin
				Res_Close	<=			1	;

			end

		endcase
	end

end
endmodule
