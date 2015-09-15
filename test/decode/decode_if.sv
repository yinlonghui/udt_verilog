
interface	decode_if(	input	clk	,	output	logic	finish	,	output	logic	err);

	logic	core_rst_n ;
	logic	[64-1:0]	in_tdata	;
	logic	[64/8-1:0]	in_tkeep	;
	logic	in_tvalid 	;
	logic	in_tready	;
	logic	in_tlast	;
	
	logic	[64-1:0]	out_tdata  ;
	logic	out_tlast 	;
	logic	out_tvalid	;
	logic	[64/8-1:0]	out_tkeep ;
	logic	out_tready	;

	logic	Data_en	;
	logic	ACK_en	;
	logic	ACK2_en	;
	logic	Keep_live_en ;
	logic	NAK_en	;
	logic	Handshake_en ;
	logic	CLOSE_en	 ;
	logic	error		 ;	
	
modport	DUT(
	input	clk	,	core_rst_n	,
	in_tdata	,	in_tkeep	,	in_tvalid	,	in_tlast ,
	out_tready	,
	output	in_tready	,
	out_tdata	,	out_tlast	,	out_tvalid	,	out_tkeep	,
	Data_en	,
	ACK_en	,								
	ACK2_en	,								
	Keep_live_en ,							
	NAK_en	,								
	Handshake_en , 							
	CLOSE_en	 ,							
	error		
);

modport	TB(
	input	clk ,
	in_tready	,
	out_tdata	,	out_tlast	,	out_tvalid	,	out_tkeep	,
	Data_en	,
	ACK_en	,								
	ACK2_en	,								
	Keep_live_en ,							
	NAK_en	,								
	Handshake_en , 							
	CLOSE_en	 ,							
	error	,
	output	core_rst_n	,
	in_tdata	,	in_tkeep	,	in_tvalid	,	in_tlast ,
	finish ,
	out_tready	
);

modport	AS(
	input	clk	,	core_rst_n	,
	in_tdata	,	in_tkeep	,	in_tvalid	,	in_tlast ,
	out_tready	,
	in_tready	,
	out_tdata	,	out_tlast	,	out_tvalid	,	out_tkeep	,	
	Data_en	,
	ACK_en	,								
	ACK2_en	,								
	Keep_live_en ,							
	NAK_en	,								
	Handshake_en , 							
	CLOSE_en	 ,
	output	err  

);
endinterface