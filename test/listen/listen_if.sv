
interface	listen_if(input	clk	,output	logic	finish	,	output	logic	err)	;
logic	core_rst_n ;		
logic [63:0]	handshake_tdata ;	
logic [7:0]	handshake_tkeep ;	
logic 	handshake_tvalid;	
logic 	handshake_tready;	
logic 	handshake_tlast	;	

logic [31:0]	Req_Connect ;		
logic [31:0]	Res_Connect ;		
logic [31:0]	Req_Close	;	
logic [31:0]	Res_Close	;	
logic [31:0]	Snd_Buffer_Size ;	
logic [31:0]	Rev_Buffer_Size	;	
logic [31:0]	FlightFlagSize ;	
logic [31:0]	MSSize;	
logic [31:0]	INIT_SEQ ;
logic [31:0]	Max_PktSize ;		
logic [31:0]	Max_PayloadSize ;	
logic [31:0]	Expiration_counter ;	
logic [31:0]	Bandwidth ;		
logic [31:0]	DeliveryRate ;		
logic [31:0]	AckSeqNo ;		
logic [31:0]	LastAckTime ;		
logic [31:0]	SYNInterval ;		
logic [31:0]	RRT ;			
logic [31:0]	RTTVar ;		
logic [31:0]	MinNakInt;		
logic [31:0]	MinExpInt;		
logic [31:0]	ACKInt;			
logic [31:0]	NAKInt;			
logic [31:0]	PktCount;		
logic [31:0]	LightACKCount ;		
logic [31:0]	TargetTime ;		
logic [31:0]	TimeDiff;		

logic [31:0]	PeerISN ;		
logic [31:0]	RcvLastAck ;		
logic [31:0]	RcvLastAckAck ;		
logic [31:0]	RcvCurrSeqNo ;		
logic [31:0]	LastDecSeq  ;		
logic [31:0]	SndLastAck  ;		
logic [31:0]	SndLastDataAck ;	
logic [31:0]	SndCurrSeqNo ;		
logic [31:0]	SndLastAck2  ;		
logic [31:0]	SndLastAck2Time ;	
logic [31:0]	FlowWindowSize ;	
logic [31:0]	LastRspTime;		
logic [31:0]	NextACKTime;		
logic [31:0]	NextNACKtime;		
logic [63:0]	req_tdata	;	
logic [7:0]	req_tkeep	;	
logic 	req_tvalid	;	
logic 	req_tready	;	
logic 	req_tlast	;	



modport	TB_UNIT_ST(
	input	clk	,
	handshake_tready	,
	Res_Connect	,
	Res_Close	,
	Max_PktSize	,	Max_PayloadSize	,	Expiration_counter	,	Bandwidth		,	DeliveryRate		,	AckSeqNo		,
	LastAckTime	,	SYNInterval	,	RRT			,	RTTVar			,	MinNakInt		,	MinExpInt		,
	ACKInt		,	NAKInt		,	PktCount		,	LightACKCount		,	TargetTime		,	TimeDiff		,
	PeerISN		,	RcvLastAck	,	RcvLastAckAck		,	RcvCurrSeqNo		,	LastDecSeq		,	SndLastAck		,
	SndLastDataAck 	,	SndCurrSeqNo 	,	SndLastAck2  		,	SndLastAck2Time 	,	FlowWindowSize		,	LastRspTime		,		
	NextACKTime	,	NextNACKtime	,		
	req_tdata	,	req_tkeep	,	req_tvalid		,	req_tlast		,
	output	core_rst_n	,
	handshake_tdata	,	handshake_tkeep	,	handshake_tvalid	,	handshake_tlast	,
	Req_Close	,
	Req_Connect	,
	Snd_Buffer_Size	,	Rev_Buffer_Size	,	FlightFlagSize		,	MSSize	,	INIT_SEQ ,
	req_tready

);

modport	DUT(
	input	clk	,	core_rst_n	,
	handshake_tdata	,	handshake_tkeep	,	handshake_tvalid	,	handshake_tlast	,
	Req_Close	,
	Req_Connect	,
	Snd_Buffer_Size	,	Rev_Buffer_Size	,	FlightFlagSize		,	MSSize	,
	req_tready	,
	output		handshake_tready	,
	Res_Connect	,
	Res_Close	,
	Max_PktSize	,	Max_PayloadSize	,	Expiration_counter	,	Bandwidth		,	DeliveryRate		,	AckSeqNo		,
	LastAckTime	,	SYNInterval	,	RRT			,	RTTVar			,	MinNakInt		,	MinExpInt		,
	ACKInt		,	NAKInt		,	PktCount		,	LightACKCount		,	TargetTime		,	TimeDiff		,
	PeerISN		,	RcvLastAck	,	RcvLastAckAck		,	RcvCurrSeqNo		,	LastDecSeq		,	SndLastAck		,
	SndLastDataAck 	,	SndCurrSeqNo 	,	SndLastAck2  		,	SndLastAck2Time 	,	FlowWindowSize		,	LastRspTime		,		
	NextACKTime	,	NextNACKtime	,		
	req_tdata	,	req_tkeep	,	req_tvalid		,	req_tlast		
);

modport	AS(
	input	clk	,	core_rst_n	,
	handshake_tdata	,	handshake_tkeep	,	handshake_tvalid	,	handshake_tlast	,
	Req_Close	,
	Req_Connect	,
	Snd_Buffer_Size	,	Rev_Buffer_Size	,	FlightFlagSize		,	MSSize	,
	req_tready	,
	handshake_tready,
	Res_Connect	,
	Res_Close	,
	Max_PktSize	,	Max_PayloadSize	,	Expiration_counter	,	Bandwidth		,	DeliveryRate		,	AckSeqNo		,
	LastAckTime	,	SYNInterval	,	RRT			,	RTTVar			,	MinNakInt		,	MinExpInt		,
	ACKInt		,	NAKInt		,	PktCount		,	LightACKCount		,	TargetTime		,	TimeDiff		,
	PeerISN		,	RcvLastAck	,	RcvLastAckAck		,	RcvCurrSeqNo		,	LastDecSeq		,	SndLastAck		,
	SndLastDataAck 	,	SndCurrSeqNo 	,	SndLastAck2  		,	SndLastAck2Time 	,	FlowWindowSize		,	LastRspTime		,		
	NextACKTime	,	NextNACKtime	,		
	req_tdata	,	req_tkeep	,	req_tvalid		,	req_tlast		,
	output	err
);





endinterface
