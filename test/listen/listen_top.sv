module	listen_top(input	clk	,	output	finish	,output	assert_err );

listen_if	lis_if(clk,finish,assert_err);

listen_sva	sva_inst(lis_if.AS);

tb_listen	tb_unite(lis_if.TB_UNIT_ST);


listen		dut_inst(
	
	lis_if.clk ,
	lis_if.core_rst_n ,		
	lis_if.handshake_tdata ,	
	lis_if.handshake_tkeep ,	
	lis_if.handshake_tvalid,	
	lis_if.handshake_tready,	
	lis_if.handshake_tlast	,	
	lis_if.Req_Connect ,		
	lis_if.Res_Connect ,		
	lis_if.Req_Close	,	
	lis_if.Res_Close	,	
	lis_if.Snd_Buffer_Size ,	
	lis_if.Rev_Buffer_Size	,	
	lis_if.FlightFlagSize ,	
	lis_if.MSSize,
	lis_if.INIT_SEQ ,
	lis_if.Max_PktSize ,		
	lis_if.Max_PayloadSize ,	
	lis_if.Expiration_counter ,	
	lis_if.Bandwidth ,		
	lis_if.DeliveryRate ,		
	lis_if.AckSeqNo ,		
	lis_if.LastAckTime ,		
	lis_if.SYNInterval ,		
	lis_if.RRT ,			
	lis_if.RTTVar ,		
	lis_if.MinNakInt,		
	lis_if.MinExpInt,		
	lis_if.ACKInt,			
	lis_if.NAKInt,			
	lis_if.PktCount,		
	lis_if.LightACKCount ,		
	lis_if.TargetTime ,		
	lis_if.TimeDiff,		
	lis_if.PeerISN ,		
	lis_if.RcvLastAck ,		
	lis_if.RcvLastAckAck ,		
	lis_if.RcvCurrSeqNo ,		
	lis_if.LastDecSeq  ,		
	lis_if.SndLastAck  ,		
	lis_if.SndLastDataAck ,	
	lis_if.SndCurrSeqNo ,		
	lis_if.SndLastAck2  ,		
	lis_if.SndLastAck2Time ,	
	lis_if.FlowWindowSize ,	
	lis_if.LastRspTime,		
	lis_if.NextACKTime,		
	lis_if.NextNACKtime,
	lis_if.NEG_MSSize  ,
	lis_if.req_tdata	,	
	lis_if.req_tkeep	,	
	lis_if.req_tvalid	,	
	lis_if.req_tready	,	
	lis_if.req_tlast		


);


endmodule
