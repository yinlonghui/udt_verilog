`timescale 1ps/1ps

module  configure_top(
    input   clk ,
	output		finish	,
	output		assert_err
) ;

configure_if  arbif(clk ,finish ,assert_err) ;

tb_configure_sva  sva_inst(arbif.ASSERTION);

tb_configure_axi4_lite  tb_configure_inst(arbif.TB_UNIT_SI);
configure  inst(
	arbif.clk,							
	arbif.rst_n,							
	arbif.ctrl_s_axi_awaddr,					
	arbif.ctrl_s_axi_awvalid,							
	arbif.ctrl_s_axi_awready,				
	arbif.ctrl_s_axi_wdata,					
	arbif.ctrl_s_axi_wstrb,				
	arbif.ctrl_s_axi_wvalid,							
	arbif.ctrl_s_axi_wready,						
	arbif.ctrl_s_axi_bresp,				
	arbif.ctrl_s_axi_bvalid,						
	arbif.ctrl_s_axi_bready,						
	arbif.ctrl_s_axi_araddr,					
	arbif.ctrl_s_axi_arvalid,							
	arbif.ctrl_s_axi_arready,							
	arbif.ctrl_s_axi_rdata,					
	arbif.ctrl_s_axi_rresp,				
	arbif.ctrl_s_axi_rvalid,							
	arbif.ctrl_s_axi_rready,							
	arbif.udt_state ,				
	arbif.state_valid,								
	arbif.state_ready,								
	arbif.Req_Connect ,							
	arbif.Res_Connect ,								
	arbif.Req_Close	,						
	arbif.Res_Close	,								
	arbif.Peer_Req_Close ,						
	arbif.Peer_Res_Close ,
	arbif.user_valid	,							
	arbif.user_ready	,							
	arbif.Snd_Buffer_Size ,					
	arbif.Rev_Buffer_Size	,					
	arbif.FlightFlagSize ,					
	arbif.MSSize	,							
	arbif.INIT_SEQ						
);

endmodule



