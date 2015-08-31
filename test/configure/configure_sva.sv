module	tb_configure_sva(configure_if.ASSERTION  as);


task	dump_log(input	string	filename);
	int fid= $fopen("assertion_configure.log","w");
    $fdisplay(fid,"[tb_configure]  %s \n",filename);
    as.err =  1 ;
    $fclose(fid);

endtask



initial
begin
	as.err =  0 ;
end



sequence	address0userwrite(AD);
	
    @(posedge	as.clk)  (as.ctrl_s_axi_awvalid  && as.ctrl_s_axi_awready  , AD = as.ctrl_s_axi_awaddr );
endsequence

sequence	address0data0(MAX,ADDRESS,ID,value);
	reg	[31:0]	item	;
	@(posedge	as.clk)	 (  ##[0:1] as.ctrl_s_axi_wvalid  , item =  as.ctrl_s_axi_wdata) ##[0:5] as.ctrl_s_axi_wready == 1 ##[0:5] as.ctrl_s_axi_bready  ##[0:5] 
	as.ctrl_s_axi_bvalid == 1 && (( ADDRESS == ID && item <= MAX ? as.ctrl_s_axi_bresp == 2'b00 && item == value : as.ctrl_s_axi_bresp == 2'b11 && value== 32'hffff_ffff) || (ADDRESS != ID )|| (ADDRESS > 32'h6 &&as.ctrl_s_axi_bresp == 2'b01 )) ;
endsequence
/**	property Max	MMS  	*/
property	address0;
	reg	[31:0]	AD ;
	disable	iff(!as.rst_n)
	address0userwrite(AD)  |->  address0data0(32'd8000,AD,32'h0,as.MSSize)  ;
endproperty

/**	property Send	buffer	size	*/
property	address1;
	reg	[31:0]	AD ;
	disable	iff(!as.rst_n)
	address0userwrite(AD)  |->  address0data0(32'd8192,AD,32'h1,as.Snd_Buffer_Size)  ;
endproperty
/** property	Receiver	buffer	size */
property	address2;
	reg	[31:0]	AD ;
	disable	iff(!as.rst_n)
	address0userwrite(AD)  |->  address0data0(32'd8192,AD,32'h2,as.Rev_Buffer_Size)  ;
endproperty
/** property	Flight Flag size*/
property	address3;
	reg	[31:0]	AD ;
	disable	iff(!as.rst_n)
	address0userwrite(AD)  |->  address0data0(32'd256000,AD,32'h3,as.FlightFlagSize)  ;
endproperty
/** property	INIT Sequence Number*/
property	address4;
	reg	[31:0]	AD ;
	disable	iff(!as.rst_n)
	address0userwrite(AD)  |->  address0data0(32'd1000000,AD,32'h4,as.INIT_SEQ);
endproperty


/**	assertion	Max	MMS   */
assert_address0:	assert	property(address0)   else dump_log("assert_address0");
/** assertion	Receiver	buffer	size */
assert_address1:	assert	property(address1)   else dump_log("assert_address1");
/** assertion	Receiver	buffer	size */
assert_address2:	assert	property(address2)   else dump_log("assert_address2");
/** assertion	Flight Flag size*/
assert_address3:	assert	property(address3)   else dump_log("assert_address3");
/** assertion	INIT Sequence Number*/
assert_address4:	assert	property(address4)   else dump_log("assert_address4");
/*
	断言AXI写信号
*/
property	axi_write;
	disable	iff(!as.rst_n)
	@(posedge	as.clk)	as.ctrl_s_axi_awvalid |-> (##[0:10] as.ctrl_s_axi_awready   ##[0:10] as.ctrl_s_axi_wvalid ##[0:10] as.ctrl_s_axi_wready   ##[0:10] as.ctrl_s_axi_bready ##[0:10] as.ctrl_s_axi_bvalid ) ;

endproperty

assert_axi_write:	assert	property(axi_write)	 else dump_log("assert_axi_write");

property	axi_read;
	disable	iff(!as.rst_n)
	@(posedge	as.clk)	as.ctrl_s_axi_arvalid |-> (##[0:10] as.ctrl_s_axi_arready ##[0:10] as.ctrl_s_axi_rready ##[0:10] as.ctrl_s_axi_rvalid ) ;
endproperty

assert_axi_read:	assert	property(axi_read)	else dump_log("assert_axi_rd");
					

endmodule