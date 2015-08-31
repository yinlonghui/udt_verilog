
interface   configure_if(input  clk , output logic finish , output  logic err) ;

//  AXI-LITE WRITE CHANNEL
	logic	[31:0]	ctrl_s_axi_awaddr  ;
	logic	ctrl_s_axi_awvalid  , ctrl_s_axi_wvalid  , ctrl_s_axi_bready;
	logic	[3:0]	ctrl_s_axi_wstrb ;
	logic	[31:0]	ctrl_s_axi_wdata ;
	logic	ctrl_s_axi_awready , ctrl_s_axi_wready , ctrl_s_axi_bvalid ;
	logic	[1:0]	ctrl_s_axi_bresp ;
//	AXI-LITE READ CHANNEL
	logic	[31:0]	ctrl_s_axi_araddr ;
	logic	ctrl_s_axi_arvalid , ctrl_s_axi_rready 	;
	logic	ctrl_s_axi_arready , ctrl_s_axi_rvalid ;
	logic	[1:0]	ctrl_s_axi_rresp ;
	logic	[31:0]	ctrl_s_axi_rdata ;
	
	
	logic	[31:0]	udt_state ;
	logic	state_valid ,  state_ready ;
	logic	Res_Connect ,Res_Close, Peer_Req_Close ,user_ready , Req_Connect	,	Req_Close ,  Peer_Res_Close , user_valid ;
	
	logic	[31:0]	Snd_Buffer_Size , Rev_Buffer_Size , FlightFlagSize, MSSize ,INIT_SEQ;
	
	logic	rst_n ;
	
 
	modport TB_UNIT_SI (
				input  clk , 
				ctrl_s_axi_awready , ctrl_s_axi_wready ,ctrl_s_axi_bresp ,ctrl_s_axi_bvalid ,
				ctrl_s_axi_arready , ctrl_s_axi_rresp , ctrl_s_axi_rvalid , ctrl_s_axi_rdata ,
				Snd_Buffer_Size	, Rev_Buffer_Size , FlightFlagSize , MSSize , INIT_SEQ ,
				state_ready	,	
				Req_Connect	,	Req_Close , 
				Peer_Res_Close , user_valid ,
				output	rst_n,
				ctrl_s_axi_awaddr ,ctrl_s_axi_awvalid ,ctrl_s_axi_wdata ,ctrl_s_axi_wstrb ,ctrl_s_axi_wvalid, ctrl_s_axi_bready , 
				ctrl_s_axi_araddr ,ctrl_s_axi_arvalid ,ctrl_s_axi_rready ,
				udt_state ,state_valid,
				Res_Connect ,Res_Close, 
				Peer_Req_Close ,user_ready ,
				finish
	);
 
 
	modport	DUT( input clk , rst_n , 
				ctrl_s_axi_awaddr ,ctrl_s_axi_awvalid ,ctrl_s_axi_wdata ,ctrl_s_axi_wstrb ,ctrl_s_axi_wvalid, ctrl_s_axi_bready , 
				ctrl_s_axi_araddr ,ctrl_s_axi_arvalid ,ctrl_s_axi_rready ,
				udt_state ,state_valid,
				Res_Connect ,Res_Close, 
				Peer_Req_Close ,user_ready ,
				output	ctrl_s_axi_awready , ctrl_s_axi_wready ,ctrl_s_axi_bresp ,ctrl_s_axi_bvalid ,
				ctrl_s_axi_arready , ctrl_s_axi_rresp , ctrl_s_axi_rvalid , ctrl_s_axi_rdata ,
				state_ready	,	
				Req_Connect	,	Req_Close , 
				Peer_Res_Close , user_valid ,
				Snd_Buffer_Size	, Rev_Buffer_Size , FlightFlagSize , MSSize , INIT_SEQ 
				);
				
	modport	ASSERTION(
				input clk , rst_n , 
				ctrl_s_axi_awaddr ,ctrl_s_axi_awvalid ,ctrl_s_axi_wdata ,ctrl_s_axi_wstrb ,ctrl_s_axi_wvalid, ctrl_s_axi_bready , 
				ctrl_s_axi_araddr ,ctrl_s_axi_arvalid ,ctrl_s_axi_rready ,
				udt_state ,state_valid,
				Res_Connect ,Res_Close, 
				Peer_Req_Close ,user_ready ,
				ctrl_s_axi_awready , ctrl_s_axi_wready ,ctrl_s_axi_bresp ,ctrl_s_axi_bvalid ,
				ctrl_s_axi_arready , ctrl_s_axi_rresp , ctrl_s_axi_rvalid , ctrl_s_axi_rdata ,
				state_ready	,	
				Req_Connect	,	Req_Close , 
				Peer_Res_Close , user_valid ,
				Snd_Buffer_Size	, Rev_Buffer_Size , FlightFlagSize , MSSize , INIT_SEQ ,
				output err
	
	);
		
endinterface    