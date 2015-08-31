//%	@file	SocketManager.v
//%	@brief	本文定义Socket_Manager模块

//%	本模块根据参数例化Socket Manager模块
//%	@details	如果类型为SERVER，则为服务器模式，若为CLINET，则为客户机模式


module	SocketManager #(
	parameter	INIT_STATE	=	32'h0000_0000 ,
	parameter	CONNECTING	=	32'h0000_0001 ,
	parameter	CONNECTED	=	32'h0000_0010 ,
	parameter	CLOSING		=	32'h0000_0100	,
	parameter	CLOSED		=	32'h0000_1000	
                                
	parameter	TPYE	=	"SERVER"  // SOCK管理器类型
)
(
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
	
	output  [31:0]	udt_state_o ,						//%	连接状态
	output  state_valid_o,								//%	连接状态有效
	input	state_ready_i,								//%	连接状态就绪
	
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
	
	input	brocken_i ,
	input	brocken_valid_i ,
	output	brocken_ready_o ,
	
	output	[63:0]	req_tdata_o	,						//%	请求握手数据包
	output	[7:0]	req_tkeep_o	,						//%	请求握手数据使能信号
	output			req_tvalid_o	,					//%	请求握手数据有效信号
	input			req_tready_i	,					//%	请求握手数据就绪信号
	input			req_tlast_i							//%	请求握手数据结束信号
	
	input	close_tvalid_i	,							//%	关闭控制包有效
	input	[63:0]	close_tdata_i		,				//%	关闭控制数据包
	input	[7:0]	close_tkeep_i		,				//%	关闭控制使能信号
	input	close_tlast_i				,				//%	关闭控制结束信号
	output	close_tready_i								//%	关闭控制就绪信号


);

wire	listening_c ;
wire	listening_valid_c ;
wire	listening_ready_c ;

wire	connecting_c ;
wire	connecting_valid_c ;
wire	connecting_ready_c ;


wire	closing_c	;
wire	closing_valid_c	;
wire	closing_ready_c	;

wire	shutdown_c ;
wire	shutdown_valid_c ;
wire	shutdown_ready_c ;


wire	brocken_c  ;
wire	brocken_valid_c ;
wire	brocken_ready_c  ;


generate	

	if(TPYE	== "SERVER")	begin:SERVER_MANAGER
	
		ServerManager	sock_inst(
			.core_clk(core_clk),
			.core_rst_n(core_rst_n),
			.handshake_tdata_i(handshake_tdata_i) ,
			.handshake_tkeep_i(handshake_tkeep_i) ,
			.handshake_tvalid_i(handshake_tvalid_i),
			.handshake_tready_o(handshake_tready_o),
			.handshake_tlast_i(handshake_tlast_i),
			
			.listening_o(listening_c),
			.listening_valid_o(listening_valid_c),
			.listening_ready_i(listening_ready_c),
			
			.brocken_i(brocken_c),
			.brocken_ready_o(brocken_ready_c),
			.brocken_valid_i(brocken_valid_c),
			
			.shutdown_o(shutdown_c),
			.shutdown_valid_o(shutdown_valid_c),
			.shutdown_ready_i(shutdown_ready_c),
			
			
			.closing_o(closing_c),
			.closing_valid_o(closing_valid_c),
			.closing_ready_i(closing_ready_c),
			
			.connecting_o(connecting_c),
			.connecting_valid_o(connecting_valid_c),
			.connecting_ready_i(connecting_ready_c),
			
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
			.req_tready_i(req_tready_i),
			.req_tlast_o(req_tlast_o),
			
			.close_tvalid_i(close_tvalid_i),
			.close_tdata_i(close_tdata_i),
			.close_tkeep_i(close_tkeep_i),
			.close_tlast_i(close_tlast_i),
			.close_tready_o(close_tready_o)
		);
	
	end	else	if(TPYE ==  "CLIENT")begin:CLIENT_MANAGER
	
		ClientManager	sock_inst(
			.core_clk(core_clk),
			.core_rst_n(core_rst_n),
			.handshake_tdata_i(handshake_tdata_i) ,
			.handshake_tkeep_i(handshake_tkeep_i) ,
			.handshake_tvalid_i(handshake_tvalid_i),
			.handshake_tready_o(handshake_tready_o),
			.handshake_tlast_i(handshake_tlast_i),
		
			.listening_o(listening_c),
			.listening_valid_o(listening_valid_c),
			.listening_ready_i(listening_ready_c),
			
			.brocken_i(brocken_c),
			.brocken_ready_o(brocken_ready_c),
			.brocken_valid_i(brocken_valid_c),
			
			.shutdown_o(shutdown_c),
			.shutdown_valid_o(shutdown_valid_c),
			.shutdown_ready_i(shutdown_ready_c),
			
			
			.closing_o(closing_c),
			.closing_valid_o(closing_valid_c),
			.closing_ready_i(closing_ready_c),
			
			.connecting_o(connecting_c),
			.connecting_valid_o(connecting_valid_c),
			.connecting_ready_i(connecting_ready_c),
		
		
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
			.req_tready_i(req_tready_i),
			.req_tlast_o(req_tlast_o),
			
			.close_tvalid_i(close_tvalid_i),
			.close_tdata_i(close_tdata_i),
			.close_tkeep_i(close_tkeep_i),
			.close_tlast_i(close_tlast_i),
			.close_tready_o(close_tready_o)
			
		);
	end
endgenerate

StateManager	#(
	.LISTENING(LISTENING),
	.CONNECTING(CONNECTING),
	.CONNECTED(CONNECTED),
	.CLOSING(CLOSING),
	.SHUTDOWN(SHUTDOWN),
	.BROCKEN(BROCKEN)
)StateManager_inst(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	.listening_i(listening_c),
	.listening_valid_i(listening_valid_c),
	.listening_ready_o(listening_ready_c),
			
	.brocken_i(brocken_i),
	.brocken_ready_o(brocken_ready_o),
	.brocken_valid_i(brocken_valid_i),
			
	.shutdown_i(shutdown_c),
	.shutdown_valid_i(shutdown_valid_c),
	.shutdown_ready_o(shutdown_ready_c),
			
			
	.closing_i(closing_c),
	.closing_valid_i(closing_valid_c),
	.closing_ready_o(closing_ready_c),
			
	.connecting_i(connecting_c),
	.connecting_valid_i(connecting_valid_c),
	.connecting_ready_o(connecting_ready_c),
	
	.s_brocken_o(brocken_c),
	.s_brocken_valid_o(brocken_valid_c),
	.s_brocken_ready_i(brocken_ready_c),
	
	
	.udt_state_o(udt_state_o),
	.state_valid_o(state_valid_o),
	.state_ready_i(state_ready_i)



);


endmodule