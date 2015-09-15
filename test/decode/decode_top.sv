module	decode_top(
	input   clk ,
	output		finish	,
	output		assert_err
) ;

decode_if	deco_if(clk,finish,assert_err);
as_decode	as_inst(deco_if.AS);
tb_decode	tb_inst(deco_if.TB);
decode	dut_inst(
	deco_if.clk,						
	deco_if.core_rst_n ,							
	deco_if.in_tdata,	
	deco_if.in_tkeep,
	deco_if.in_tvalid , 						
	deco_if.in_tready	,						
	deco_if.in_tlast	,						
	
	deco_if.out_tdata ,	
	deco_if.out_tlast ,								
	deco_if.out_tvalid	,							
	deco_if.out_tkeep ,	
	deco_if.out_tready,									

	deco_if.Data_en	,								
	deco_if.ACK_en	,								
	deco_if.ACK2_en	,								
	deco_if.Keep_live_en ,							
	deco_if.NAK_en	,								
	deco_if.Handshake_en , 							
	deco_if.CLOSE_en	 ,							
	deco_if.error		 	

);

endmodule

