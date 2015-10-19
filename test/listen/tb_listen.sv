module	tb_listen(	TB_UNIT_ST  tb);


task	RST_OUT();
	int	  i   =  10;
	tb.rst_n	=	1	;
	tb.handshake_tdata	=	64'h0	;
	tb.handshake_tkeep	=	8'h0	;
	tb.handshake_tvalid	=	0		;
	tb.handshake_tlast	=	0		;
	tb.Req_Close		=	0		;
	tb.Req_Connect		=	0		;
	tb.Snd_Buffer_Size	=	32'd8192		;
	tb.Rev_Buffer_Size	=	32'd8192		;
	tb.FlightFlagSize	=	32'd256000		;
	tb.MSSize			=	32'd8000		;
	tb.INIT_SEQ			=	0		;
	tb.req_tready		=	0		;
	
	
	while( i != 0) begin
		@(posedge	tb.clk);
		i  =  i  - 1 ;
	end
	tb.rst_n	=	0	;
	while( i != 0 ) begin
		@(posedge	tb.clk);
		i	=  i - 1 ;
	end
	
	tb.rst_n	=	1	;
	while( i != 0 )	begin
		@(posedge	tb.clk);
		i	=  i - 1 ;
	end
endtask

task handshake_stream(
	input	[63:0]	value ,
	input	[3:0]	keep  ,
	input			last	
);
	tb.handshake_tdata	=	value	;
	tb.handshake_tkeep	=	keep	;
	tb.handshake_tvalid	=	1		;
	tb.handshake_tlast	=	last	;
	@(posedge	tb.clk);
	while(!tb.handshake_tready)	@(posedge	tb.clk);
	tb.handshake_tvalid	=	0		;
	@(posedge	tb.clk);
endtask

task	first_handshake();
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
endtask


task	second_handshake();
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );	/**/
endtask

task	check_first_handshake();


endtask

task	check_second_handshake();


endtask
/*
*	CASE0:	all  handshake  signal  can be  success.
*/

task	process_handshake0();
	tb.Req_Connect	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Connect)	@(posedge	tb.clk);
	tb.Req_Connect	=	0	;
	@(posedge	tb.clk);
	/*	first  handshake:	*/
	first_handshake();
	/*	check	it	peer	handshake	*/
	check_first_handshake();
	
	/*	second	handshake:	*/
	second_handshake();
	/*	check	it	peer	second	handshake	*/
	check_second_handshake();
	
	tb.Req_Close	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Close)	@(posedge	tb.clk);
	tb.Req_Close	=	0	;
	@(posedge	tb.clk);
endtask
/*
*
*/
task	process_handshake1();


endtask

endmodule
