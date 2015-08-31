
`timescale 1ps/1ps
module	tb_configure_axi4_lite(	configure_if.TB_UNIT_SI  tb);

logic	[31:0]	rdata ;
logic	[1:0]	resp ;

logic	[1:0]	wresp ;
	
 //   $fdisplay(fid,"[tb_configure]  %s \n",filename);
 //   $fclose(fid);

task  RST_IN();

	int  i =  10 ;
	tb.ctrl_s_axi_awvalid =  0 ;
	tb.ctrl_s_axi_wvalid =   0 ;
	tb.ctrl_s_axi_bready =   0 ;
	tb.ctrl_s_axi_arvalid =	 0 ;
	tb.ctrl_s_axi_rready  =  0 ;
	tb.ctrl_s_axi_wdata	=	32'h0 ;
	tb.ctrl_s_axi_wstrb =	4'b0000;
	
	tb.udt_state = 32'h0;
	tb.state_valid =  0 ;
	
	tb.Res_Connect =  0 ;
	tb.Res_Close =  0 ;
	
	tb.Peer_Req_Close	= 0 ;
	tb.user_ready = 0  ;
	
	tb.rst_n = 1 ;
	while( i != 0 ) begin
    	@(posedge	tb.clk);
    	i = i - 1 ;
    end
    i =  50 ;   
	while( i != 0 )
	begin
		@(posedge	tb.clk);
		i = i - 1 ;
		tb.rst_n = 0 ;
	end
	tb.rst_n = 1 ;
	i = 10 ;
	while( i != 0 ) begin
        @(posedge	tb.clk);
        i = i - 1 ;
    end
endtask

task    write_address(  input   [31:0] address ,
	input	[31:0]	value ,
	input	[3:0]	keep
);
    tb.ctrl_s_axi_awvalid = 1 ;
    tb.ctrl_s_axi_awaddr = address ;
	@(posedge	tb.clk);
    while(!tb.ctrl_s_axi_awready)   @(posedge   tb.clk);
	tb.ctrl_s_axi_awvalid = 0 ;
	tb.ctrl_s_axi_wvalid =  1 ;
	tb.ctrl_s_axi_wdata = value ;
	tb.ctrl_s_axi_wstrb = keep  ;
	while(!tb.ctrl_s_axi_wready)	@(posedge	tb.clk);
	@(posedge	tb.clk);
	tb.ctrl_s_axi_wvalid =  0 ;
	tb.ctrl_s_axi_bready =  1 ;
	@(posedge	tb.clk);
	while(!tb.ctrl_s_axi_bvalid)	@(posedge	tb.clk);
	wresp =  tb.ctrl_s_axi_bresp ;
	tb.ctrl_s_axi_bready =   0 ;
endtask

task	read_address(	input	[31:0]	address );
	tb.ctrl_s_axi_arvalid =  1  ;
	tb.ctrl_s_axi_araddr =   address ;
	@(posedge	tb.clk);
	while(!tb.ctrl_s_axi_arready)	@(posedge	tb.clk);
	tb.ctrl_s_axi_arvalid =  0   ;
	tb.ctrl_s_axi_rready =	 1	 ;
	@(posedge	tb.clk);
	while(!tb.ctrl_s_axi_rvalid)	@(posedge	tb.clk);
	rdata	= tb.ctrl_s_axi_rdata ;
	resp	= tb.ctrl_s_axi_rresp ;
	tb.ctrl_s_axi_rready =	 0	 ;
	
endtask

task	delay();
	int count = 100 ;
	while(count != 0) 
	begin
		@(posedge	tb.clk);
		count = count - 1 ;
	end
endtask

initial
begin
	int fid= $fopen("tb_configure.log","w");
	tb.finish =  0 ;

	/*	CASE 0 */
	RST_IN();
	/*	配置正确的参数			*/
	write_address(32'h0,32'h0,4'b1111);
	write_address(32'h1,32'd1024,4'b1111);
	write_address(32'h2,32'd1024,4'b1111);
	write_address(32'h3,32'd10240,4'b1111);
	write_address(32'h4,32'd10101,4'b1111);
	read_address(32'h0);
	if(rdata != 32'h0)
		$fdisplay(fid,"MMSIZE  READ ERROR0");
	read_address(32'h1);
	if(rdata != 32'd1024)
		$fdisplay(fid,"SND	BUFFER	SIZE	ERROR0");
	read_address(32'h2);
	if(rdata != 32'd1024)
		$fdisplay(fid,"REV	BUFFER	SIZE	ERROR0");
	read_address(32'h3);
	if(rdata != 32'd10240)
		$fdisplay(fid,"Flight Flags SIZE ERROR0");
	read_address(32'h4);
	if(rdata != 32'd10101)
		$fdisplay(fid,"INIT SEQ NUM ERROR0");
	/*	CASE 1: init seq num 不存在越界 */
	RST_IN();
	/*	参数越界 */
	write_address(32'h0,32'd8100,4'b1111);
	read_address(32'h0);
	if(rdata != 32'hffff_ffff || resp != 2'b11)
		$fdisplay(fid,"MMSIZE ERROR 01");
	RST_IN();
	write_address(32'h1,32'd8193,4'b1111);
	if(rdata != 32'hffff_ffff || resp != 2'b11)
		$fdisplay(fid,"SND	BUFFER ERROR 01");
	RST_IN();
	write_address(32'h2,32'd8193,4'b1111);
	if(rdata != 32'hffff_ffff || resp != 2'b11)
		$fdisplay(fid,"REV	BUFFER ERROR 01");
	RST_IN();
	write_address(32'h3,32'd256001,4'b1111);
	if(rdata != 32'hffff_ffff || resp != 2'b11)
		$fdisplay(fid,"Flight Flags size ERROR 01");
	/*	CASE2	*/
	/*	地址越界 */
	RST_IN();
	write_address(32'h10,32'h0,4'b1111);
	read_address (32'h10);
	if(rdata != 32'hffff_ffff || resp != 2'b01)
		$fdisplay(fid,"address overflow ERROR 02");
	/*	CASE3	open -> close -> open -> close*/
	RST_IN();
	write_address(32'h5,32'h0,4'b1111);
	@(posedge tb.clk);
	if(!tb.Req_Connect)
		$fdisplay(fid,"Connect REQ	FAIL 03");
	tb.Res_Connect =  1 ;
	@(posedge tb.clk);
	tb.Res_Connect =  0 ;
	delay();
	tb.udt_state = 32'h0000_0010  ;
	tb.state_valid =  1 ;
	@(posedge tb.clk);
	while(!tb.state_ready)	@(posedge	tb.clk);
	tb.state_valid =  0 ;
	tb.udt_state = 32'h0;
	
	delay();
	write_address(32'h6,32'h0,4'b1111);
	@(posedge tb.clk);
	if(!tb.Req_Close)
		$fdisplay(fid,"Close REQ	FAIL 03");
	tb.Res_Close = 1 ;
	@(posedge tb.clk);
	tb.Res_Close = 0 ;
	
	tb.udt_state = 32'h0000_1000  ;
	tb.state_valid =  1 ;
	@(posedge tb.clk);
	while(!tb.state_ready)	@(posedge	tb.clk);
	tb.state_valid =  0 ;
	tb.udt_state = 32'h0;
	
	
	
	delay();
	
	write_address(32'h5,32'h0,4'b1111);
	@(posedge	tb.clk);
	if(!tb.Req_Connect)
		$fdisplay(fid,"Connect REQ	FAIL 03");
	tb.Res_Connect =  1 ;
	@(posedge tb.clk);
	tb.Res_Connect =  0 ;
	delay();
	tb.udt_state = 32'h0000_0010  ;
	tb.state_valid =  1 ;
	@(posedge tb.clk);
	while(!tb.state_ready)	@(posedge	tb.clk);
	tb.state_valid =  0 ;
	tb.udt_state = 32'h0;
	
	delay();
	
	
	write_address(32'h6,32'h1,4'b1111);
	@(posedge	tb.clk);
	if(!tb.Req_Close)
		$fdisplay(fid,"Close REQ	FAIL 03");
	tb.Res_Close = 1 ;
	@(posedge tb.clk);
	tb.Res_Close = 0 ;
	
	tb.udt_state = 32'h0000_1000  ;
	tb.state_valid =  1 ;
	@(posedge tb.clk);
	while(!tb.state_ready)	@(posedge	tb.clk);
	tb.state_valid =  0 ;
	tb.udt_state = 32'h0;	

	/*	CASE	4  peer_close*/
	RST_IN();
	write_address(32'h5,32'h0,4'b1111);
	@(posedge tb.clk);
	if(!tb.Req_Connect)
		$fdisplay(fid,"Connect REQ	FAIL 04");
	tb.Res_Connect =  1 ;
	@(posedge tb.clk);
	tb.Res_Connect =  0 ;
	delay();
	tb.udt_state = 32'h0000_0010  ;
	tb.state_valid =  1 ;
	@(posedge	tb.clk);
	while(!tb.state_ready)	@(posedge	tb.clk);
	tb.state_valid =  0 ;
	tb.udt_state = 32'h0;
	@(posedge	tb.clk)
	tb.Peer_Req_Close = 1 ;
	@(posedge	tb.clk);
	tb.Peer_Req_Close = 0 ;
	@(posedge	tb.clk);
	if(!tb.user_valid)
		$fdisplay(fid,"User valid ERROR 04");
	tb.user_ready = 1 ;
	@(posedge	tb.clk);
	tb.user_ready = 0 ;
	@(posedge	tb.clk);
	if(!tb.Peer_Res_Close)
		$fdisplay(fid,"peer respond ERROR 04");
	
	delay();

	tb.finish =  1 ;
end


endmodule