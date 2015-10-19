//%	@file	listen.v
//%	@brief	���ļ�����listenģ��



//%	��ģ���ǹ���SERVER�˵�SOCKET�����ӺͲ�����ʼ����ģ��
//%	@details
//%		ServerManager�������£�
//%		1������CLIENT�ˣ�����ͨ�ţ�ͨ��configureģ�鴴���׽���,����CLIENT�ˣ���������ͨ�ź������ӡ�
//%		2���ر�����
//%		step1: configureģ������������󣬷���listen���󣬾Ϳ�ʼ��ʼ�����ֲ�����
//%				Max_PktSize	= MSSize �C 28  
//%				Max_PayloadSize = Max_PktSize �C UDTͷ 
//%				Expiration_counter = 1 ; //  ����EXP-timer
//%				Bandwidth = 1 ;
//%				DeliveryRate = 16 ;
//%				AckSeqNo =  0 �� 
//%				LastAckTime  = 0 �� 
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
//%		step2:	�ȴ�Client�˷������󣬵õ�Client�����������źź󣬸��ݷ������ĵ�ַ����һ��cookie����packet��destination Socket ID ��һ�£����͸�Serve�ˡ�����step3
//%		step3:	�ȴ�Client�˼�������ȷ������ȷ��Client��cookie��У����ȷ�Ľ���step4�������������step3��
//%		step4:	��ʼ��ȫ�ֱ���
//%				PeerISN =  res-> INIT_PACKET_SEQ_NUM ;     /*�Զ˳�ʼ�������ݰ����к�*/
//%				RcvLastAck =  res-> INIT_PACKET_SEQ_NUM ;  /*���ն� �����ACK�����ݰ����кţ�*/
//%				RcvLastAckAck = res-> INIT_PACKET_SEQ_NUM ; /*���ն� �����ACK ��ACK�ģ����ݣ����к� */
//%				RcvCurrSeqNo = res-> INIT_PACKET_SEQ_NUM - 1;  /*���Ľ��յ����к�*/
//%				LastDecSeq  =  res-> INIT_PACKET_SEQ_NUM - 1; /* Sequence number sent last decrease occurs */
//%				SndLastAck  = res-> INIT_PACKET_SEQ_NUM;  /* Last ACK received */
//%				SndLastDataAck = res-> INIT_PACKET_SEQ_NUM; /* The real last ACK that updates the sender buffer and loss list*/
//%				SndCurrSeqNo = res-> INIT_PACKET_SEQ_NUM �C 1 // The largest sequence number that has been sent
//%				SndLastAck2  =  res-> INIT_PACKET_SEQ_NUM 
//%				SndLastAck2Time =  curr_time 
//%				SOCKET_ID  =  socket_id 
//%				PACKET-> SOCKET_ID =  Res->socket_id 
//%				m_iReqType  =  -1 
//%				FlowWindowSize =  res-> MAX_FLOW_WINDOWS_SIZE  [��ΪSND_LIST_SIZE]
//%				MSSize =  res-> MSSize <  MSSize ? res-> MSSize: MSSize ;
//%				Max_PktSize	= MSSize �C 28  				
//%				Max_PayloadSize = Max_PktSize �C UDTͷ
//%				��һϵ��ӵ�����ƵĲ���
//%		step5:   ��Client�˼��������������ְ�����SERVER�˷�����step4��ͬ���������ְ�����Client�˷����������ݣ���������Ѿ����������������ķ��ͺͽ������ݡ�






module	listen(
	input	core_clk,									//%	����ģ��ʱ��
	input	core_rst_n,									//%	����ģ�鸴λ(���źŸ�λ)
	input	[63:0]	handshake_tdata ,					//%	�������ݰ�
	input	[7:0]	handshake_tkeep ,					//%	���ְ��ֽ�ʹ��
	input			handshake_tvalid,					//%	���ְ���Ч�ź�
	output	reg		handshake_tready,					//%	���ְ������ź�
	input			handshake_tlast	,					//%	���ְ������ź�

	
	input	Req_Connect ,								//%	��������
	output	reg	Res_Connect ,								//% ���ӻ�Ӧ
	input	Req_Close	,								//%	�ر�����-��Closeģ���ṩ��
	output	reg	Res_Close	,								//%	�رջ�Ӧ
	input	[31:0]	Snd_Buffer_Size ,					//%	����buffer��С
	input	[31:0]	Rev_Buffer_Size	,					//%	����buffer��С
	input	[31:0]	FlightFlagSize ,					//%	����������ڴ�С
	input	[31:0]	MSSize,								//%	������С
	input	[31:0]	INIT_SEQ,							//%	��ʼ�����к�
	output	reg	[31:0]	Max_PktSize ,						//%	������С
	output	reg	[31:0]	Max_PayloadSize ,					//% ��������ݴ�С
	output	reg	[31:0]	Expiration_counter ,				//%	EXP-timer������
	output	reg	[31:0]	Bandwidth ,							//%	�����Ԥ��ֵ��1��1����
	output	reg	[31:0]	DeliveryRate ,						//%	����������ʣ����նˣ�
	output	reg	[31:0]	AckSeqNo ,							//%	���ACK�����к�
	output	reg	[31:0]	LastAckTime ,						//%	���LAST��ACKʱ���
	output	reg	[31:0]	SYNInterval ,						//%	ͬ����SYN������
	output	reg	[31:0]	RRT ,								//%	����ʱ�ӵľ�ֵ
	output	reg	[31:0]	RTTVar ,							//%	����ʱ�ӵķ���
	output	reg	[31:0]	MinNakInt,							//%	��СNAK����
	output	reg	[31:0]	MinExpInt,							//%	��СEXP����
	output	reg	[31:0]	ACKInt,								//%	ACK ��������
	output	reg	[31:0]	NAKInt,								//%	NAK ��������
	output	reg	[31:0]	PktCount,							//%	packet counter for ACK
	output	reg	[31:0]	LightACKCount ,						//%	light ACK ������
	output	reg	[31:0]	TargetTime ,						//%	�¸�Packet����ʱ��				
	output	reg	[31:0]	TimeDiff,							//%	aggregate difference in inter-packet time   
	
	output	reg	[31:0]	PeerISN ,							//%	�Զ˳�ʼ�������ݰ����к�
	output	reg	[31:0]	RcvLastAck ,						//%	���ն� �����ACK�����ݰ����кţ�
	output	reg	[31:0]	RcvLastAckAck ,						//%	���ն� �����ACK ��ACK�ģ����ݣ����к�
	output	reg	[31:0]	RcvCurrSeqNo ,						//%	���Ľ��յ����к�
	output	reg	[31:0]	LastDecSeq  ,						//%	Sequence number sent last decrease occurs 
	output	reg	[31:0]	SndLastAck  ,						//%	Last ACK received
	output	reg	[31:0]	SndLastDataAck ,					//%	The real last ACK that updates the sender buffer and loss list		
	output	reg	[31:0]	SndCurrSeqNo ,						//%	The largest sequence number that has been sent
	output	reg	[31:0]	SndLastAck2  ,						//%	Last ACK2 sent back 
	output	reg	[31:0]	SndLastAck2Time ,					//%	Last time of ACK2 sent back
	output	reg	[31:0]	FlowWindowSize ,						//%	SND list  size
	
	output	reg	[31:0]	LastRspTime,						//%	���һ�ζԶ���Ӧ��ʱ���������EXP Timers , ͬʱֻҪ��udp���ݵ������޸ĸñ���
	output	reg	[31:0]	NextACKTime,						//%	����ACK Timers
	output	reg	[31:0]	NextNACKtime,						//%	����NACK Timers
	
	output	reg	[63:0]	req_tdata	,						//%	�����������ݰ�
	output	reg	[7:0]	req_tkeep	,						//%	������������ʹ���ź�
	output			req_tvalid	,						//%	��������������Ч�ź�
	input			req_tready	,						//%	�����������ݾ����ź�
	output	reg			req_tlast							//%	�����������ݽ����ź�
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
			S_PARSE_HAND_1	=	4	,
			S_PARSE_HAND_1_WAIT	=	5	,
			S_PARSE_HAND_2	=	6	,
			S_PARSE_HAND_2_WAIT		=	7	,
			S_PARSE_HAND_3	=	8	,
			S_PARSE_HAND_3_WAIT		=	9	,
			S_PARSE_HAND_4	=	10	,
			S_PARSE_HAND_4_WAIT	=	11	,
			S_PARSE_HAND_5	=	12	,
			S_PARSE_HAND_5_WAIT	=	13	,
			S_PARSE_HAND_6	=	14	,
			S_PARSE_HAND_6_WAIT	=	15	,
			S_PARSE_HAND_7	=	16	,
			S_PARSE_HAND_7_WAIT	=	17	,
			S_PARSE_HAND_8	=	18	,
			S_PARSE_HAND_8_WAIT	=	19	,
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
			S_CLOSE			=		33	;
			

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
		S_PARSE_HAND_1:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_2	;
			else
				Next_State	=	S_PARSE_HAND_1_WAIT	;
		S_PARSE_HAND_1_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_2	;
			else
				Next_State	=	S_PARSE_HAND_1_WAIT	;
		S_PARSE_HAND_2:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_3	;
			else
				Next_State	=	S_PARSE_HAND_2_WAIT ;
		S_PARSE_HAND_2_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_3	;
			else
				Next_State	=	S_PARSE_HAND_2_WAIT ;
		S_PARSE_HAND_3:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_4	;
			else
				Next_State	=	S_PARSE_HAND_3_WAIT ;
		S_PARSE_HAND_3_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_4	;
			else
				Next_State	=	S_PARSE_HAND_3_WAIT ;
		S_PARSE_HAND_4:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_5	;
			else
				Next_State	=	S_PARSE_HAND_4_WAIT ;
		S_PARSE_HAND_4_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_5	;
			else
				Next_State	=	S_PARSE_HAND_4_WAIT ;
		S_PARSE_HAND_5:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_6	;
			else
				Next_State	=	S_PARSE_HAND_5_WAIT ;
		S_PARSE_HAND_5_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_6	;
			else
				Next_State	=	S_PARSE_HAND_5_WAIT ;
		
		S_PARSE_HAND_6:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_7	;
			else
				Next_State	=	S_PARSE_HAND_6_WAIT ;
		S_PARSE_HAND_6_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_7	;
			else
				Next_State	=	S_PARSE_HAND_6_WAIT ;
		S_PARSE_HAND_7:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_8	;
			else
				Next_State	=	S_PARSE_HAND_7_WAIT ;
		S_PARSE_HAND_7_WAIT:
			if(handshake_tvalid)
				Next_State	=	S_PARSE_HAND_8	;
			else
				Next_State	=	S_PARSE_HAND_7_WAIT ;
		S_PARSE_HAND_8:
			if(handshake_tvalid && !conditon) 
				Next_State	=	S_WAIT_1 ;
			else	if(handshake_tvalid)
				Next_State	=	S_WAIT_2 ;
			else
				Next_State	=	S_PARSE_HAND_8_WAIT ;
		S_PARSE_HAND_8_WAIT:
			if(handshake_tvalid && !conditon) 
				Next_State	=	S_WAIT_1 ;
			else	if(handshake_tvalid)
				Next_State	=	S_WAIT_2 ;
			else
				Next_State	=	S_PARSE_HAND_8_WAIT ;
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
				Next_State	=	S_RES_HAND_5_WAIT	;
		S_RES_HAND_6:
			if(req_tready)
				Next_State	=	S_RES_HAND_7	;
			else
				Next_State	=	S_RES_HAND_6_WAIT	;
		S_RES_HAND_7:
			if(req_tready)
				Next_State	=	S_RES_HAND_8	;
			else
				Next_State	=	S_RES_HAND_7_WAIT	;
		S_RES_HAND_8:
			if(req_tready)
				Next_State	=	S_START	;
			else
				Next_State	=	S_RES_HAND_8_WAIT	;

		S_WAIT_1:	Next_State	=	S_FIRST_RES	;
		S_WAIT_2:
			if(Peer_CONNECT_Typ == 1)
				Next_State	=	S_FIRST_RES	;
			else
				Next_State	=	S_SECOND_RES	;
		S_FIRST_RES:	Next_State	=	S_RES_HAND_1	;
		S_SECOND_RES:	Next_State	=	S_CONNECTED	;
		S_CONNECTED:	Next_State	=	S_RES_HAND_1	;
		S_CLOSE:	Next_State	=	S_IDLE		;
		default:
				NextState	=	'bx	;
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
		conditon		<=	    0;

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
				conditon		<=	0    ;
				
			end
			S_INIT:	begin
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
			end
			S_START:
			begin
			end
			S_PARSE_HAND_1:
			begin  //  NULL valid  
				handshake_tready	<=	1 ;
				Peer_type		<=	handshake_tdata[63:32] ;
				Peer_AddInfo		<=	handshake_tdata[31:0 ] ;

			end
			S_PARSE_HAND_1_WAIT:
			begin
				handshake_tready	<=	0 ;
			end
			S_PARSE_HAND_2:
			begin	
				handshake_tready	<=	1 ;
				Peer_TimeStamp		<=	handshake_tdata[63:32] ;
				Peer_Des_ID		<=	handshake_tdata[31:0 ] ;
			end
			S_PARSE_HAND_2_WAIT:
			begin
				handshake_tready	<=	0 ;
			end
			/*
			* 	32bit	load Verison..
			*	32bit	load Type... DGRAM or ...
			*/
			S_PARSE_HAND_3:
			begin
				handshake_tready	<=	1 ;
				Peer_UDT_Version	<=	handshake_tdata[63:32] ;
				Peer_Socket_type	<=	handshake_tdata[31:0 ] ;
			end
			S_PARSE_HAND_3_WAIT:
			begin
				handshake_tready	<=	0 ;
			end
			/*
			* 	32bit	init_packet_num
			* 	32bit	maximum	packet size
			*/
			S_PARSE_HAND_4:
			begin
				handshake_tready	<=	1;
				Peer_INIT_SEQ_NUM	<=	handshake_tdata[63:32] ;
				Peer_MSS		<=	handshake_tdata[31:0 ] ;
			end
			S_PARSE_HAND_4_WAIT:
			begin
				handshake_tready	<=	0;
			end
			/*
			*	32bit maximum	flow windows size
			*	32bit connect	type	
			*/
			S_PARSE_HAND_5:
			begin
				handshake_tready	<=	1;
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	handshake_tdata[63:32] ;
				Peer_CONNECT_Type		<=	handshake_tdata[31:0 ] ;
			end
			S_PARSE_HAND_5_WAIT:
			begin
				handshake_tready	<=	0;
			end
			/*
			* 	32bit	socket	ID
			* 	32bit	SYN	cookie
			*/
			S_PARSE_HAND_6:
			begin
				handshake_tready	<=	1;
				Peer_Self_ID		<=	handshake_tdata[63:32]	;
				Peer_SYN_cookie		<=	handshake_tdata[31:0]	;
			end
			S_PARSE_HAND_6_WAIT:
			begin
				handshake_tready	<=	0;
			end
			/*
			*	first 64bit of peer	IP	ADDRESS	 
			*/
			S_PARSE_HAND_7:
			begin
				handshake_tready	<=	1;
				Peer_IP_ADDRESS1	<=	handshake_tdata	;
			end
			S_PARSE_HAND_7_WAIT:
			begin
				handshake_tready	<=	0;
			end
			/*
			*	last 64bit of  peer	IP	ADDRESS	 
			*/
			S_PARSE_HAND_8:
			begin
				handshake_tready	<=	1;
				Peer_IP_ADDRESS2	<=	handshake_tdata ;
			end
			S_PARSE_HAND_8_WAIT:
			begin
				handshake_tready	<=	0;
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
				Peer_SYN_cookie		<=	32'h0		;
			end
			S_SECOND_RES:
			begin
				FlowWindowSize		<=	Peer_MAX_FLOW_WINDOWS_SIZE ;
				Peer_Self_ID		<=	32'h10			   ;
				Peer_Des_ID		<=	Peer_Self_ID	;

				if( Peer_MSS	> MSSize)
					Peer_MSS	<=	MSSize ;
				else
					MSSize		<=	Peer_MSS ;


				Peer_CONNECT_Type	<=	32'hffff_ffff			;
				Peer_MAX_FLOW_WINDOWS_SIZE	<=	( Rev_Buffer_Size < FlightFlagSize ) ?  Rev_Buffer_Size :  FlightFlagSize ;
				/*Peer_IP must be changed */


			end
			S_CONNECTED:
			begin
			/*
			*	Peer_ID  output
			*/
		       		Peer_ISN	<=	Peer_INIT_SEQ_NUM	;
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
