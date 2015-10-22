module	tb_listen(	listen_if.TB_UNIT_ST  tb);




task	RST_OUT();
	int	  i   =  10;
	tb.core_rst_n	=	1	;
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
	tb.client_type		=	32'h0	;
	tb.client_type_en	=	0	;
	tb.serve_type		=	32'h0	;
	tb.serve_type_en	=	0	;
	
	
	while( i != 0) begin
		@(posedge	tb.clk);
		i  =  i  - 1 ;
	end
	i	=	10 ;
	tb.core_rst_n	=	0	;
	while( i != 0 ) begin
		@(posedge	tb.clk);
		i	=  i - 1 ;
	end
	i	=	10 ;
	tb.core_rst_n	=	1	;
	while( i != 0 )	begin
		@(posedge	tb.clk);
		i	=  i - 1 ;
	end
endtask



task handshake_stream(
	input	[63:0]	value ,
	input	[7:0]	keep  ,
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
	handshake_stream({32'h8000_0000,32'h0} , 8'hff , 0 );	/*  control packet  high 32 bit = 32'h8000_0000(handshake packet)  low  32 bit :additional Info = 32'h0*/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );			/*	high 32 bit :time Stamp	 and  low 32 bit : destination socket id*/
	
	handshake_stream({32'h4,32'h0} , 8'hff , 0 );			/*	high 32 bit :UDT version = 32'h4  and  low 32 bit : Socket type  (STREAM and DRAM)*/
	handshake_stream({32'h0,32'd8192} , 8'hff , 0 );		/*	high 32 bit :Initial packet sequence number = 0  and  low  32bit : Maximum 	packet size =  8000*/
	
	tb.client_type	=	0	;
	tb.client_type_en	=	1	;
	@(posedge	tb.clk);
	tb.client_type_en	=	0	;
	@(posedge	tb.clk);
	handshake_stream({32'd256000,32'h0} , 8'hff , 0 );		/*	high 32 bit : maximum flow window size = 25600	and	low	32bit:	connection type	=	0	*/
	
	handshake_stream({32'd1024,32'h0} , 8'hff , 0 );		/*	high 32 bit : self socket ID =  1024 	and  low 32 bit :	SYN  cookie */
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );			/*	IP  address IPV6  128 bit */
	handshake_stream({32'h0,32'h0} , 8'hff , 1 );			/*	*/
endtask


task	second_handshake();
	handshake_stream({32'h8000_0000,32'h0} , 8'hff , 0 );	/*  control packet  high 32 bit = 32'h8000_0000(handshake packet)  low  32 bit :additional Info = 32'h0*/
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );			/*	high 32 bit :time Stamp	 and  low 32 bit : destination socket id*/
	
	handshake_stream({32'h4,32'h0} , 8'hff , 0 );			/*	high 32 bit :UDT version = 32'h4  and  low 32 bit : Socket type  (STREAM and DRAM)*/
	handshake_stream({32'h0,32'd8192} , 8'hff , 0 );		/*	high 32 bit :Initial packet sequence number = 0  and  low  32bit : Maximum 	packet size =  8000*/
	tb.client_type	=	32'hffff_ffff ;
	tb.client_type_en	=	1	;
	@(posedge	tb.clk);
	tb.client_type_en	=	0	;
	handshake_stream({32'd256000,32'hffff_ffff} , 8'hff , 0 );		/*	high 32 bit : maximum flow window size = 25600	and	low	32bit:	connection type	=	-1	*/
	handshake_stream({32'd1024,32'h0} , 8'hff , 0 );		/*	high 32 bit : self socket ID =  1024 	and  low 32 bit :	SYN  cookie */
	handshake_stream({32'h0,32'h0} , 8'hff , 0 );			/*	IP  address IPV6  128 bit */
	handshake_stream({32'h0,32'h0} , 8'hff , 1 );			/*	*/
endtask

task	check_handshake();
	tb.req_tready  =  1  ;
	@(posedge	tb.clk);
	while(!tb.req_tvalid)	@(posedge	tb.clk);	/*  control packet  high 32 bit = 32'h8000_0000(handshake packet)  low  32 bit :additional Info = 32'h0*/
	@(posedge	tb.clk);
	while(!tb.req_tvalid)	@(posedge	tb.clk);	/*	high 32 bit :time Stamp	 and  low 32 bit : destination socket id*/
	@(posedge	tb.clk);
	while(!tb.req_tvalid)	@(posedge	tb.clk);	/*	high 32 bit :UDT version = 32'h4  and  low 32 bit : Socket type  (STREAM and DRAM)*/
	@(posedge	tb.clk);
	while(!tb.req_tvalid)	@(posedge	tb.clk);	/*	high 32 bit :Initial packet sequence number = 0  and  low  32bit : Maximum 	packet size =  8000*/
	@(posedge	tb.clk);
	while(!tb.req_tvalid)	@(posedge	tb.clk);	
	tb.serve_type		=	tb.req_tdata[31:0]	;
	tb.serve_type_en		=	1	;
	@(posedge	tb.clk);
	tb.serve_type_en		=	0	;
	while(!tb.req_tvalid  ||  !tb.req_tlast)	@(posedge	tb.clk);
	tb.req_tready	=	0	;
	@(posedge	tb.clk);

endtask
/*
*	CASE0:	all  handshake  signal  can be  success.
*/

task	process_handshake0();
	RST_OUT();
	tb.Req_Connect	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Connect)	@(posedge	tb.clk);
	tb.Req_Connect	=	0	;
	@(posedge	tb.clk);
	/*	first  handshake:	*/
	first_handshake();	
	check_handshake();
	/*	second	handshake:	*/
	second_handshake();
	check_handshake();
	
	tb.Req_Close	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Close)	@(posedge	tb.clk);
	tb.Req_Close	=	0	;
	@(posedge	tb.clk);
endtask
/*
*	CASE1:	exist  losing handshake	packet.
*/
task	process_handshake1();
	RST_OUT();
	tb.Req_Connect	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Connect)	@(posedge	tb.clk);
	tb.Req_Connect	=	0	;
	@(posedge	tb.clk);
	/*	first  handshake:	*/
	first_handshake();
	check_handshake();
	first_handshake();
	check_handshake();
	first_handshake();
	check_handshake();
	first_handshake();
	check_handshake();
	/*	second	handshake:	*/
	second_handshake();
	check_handshake();
	second_handshake();
	check_handshake();
	second_handshake();
	check_handshake();
	second_handshake();	
	check_handshake();
	tb.Req_Close	=	1	;
	@(posedge	tb.clk);
	while(!tb.Res_Close)	@(posedge	tb.clk);
	tb.Req_Close	=	0	;
	@(posedge	tb.clk);

endtask

initial
begin
	tb.finish	=	0	;
	process_handshake0();
	process_handshake1();
	tb.finish	=	1	;
end
endmodule
