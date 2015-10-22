module	listen_sva(	listen_if.AS	as);


task	dump_log(input	string	filename);
	int fid= $fopen("assertion_listen.log","w");
    $fdisplay(fid,"[tb_listen]  %s \n",filename);
    as.err =  1 ;
    $fclose(fid);

endtask

initial
begin

	as.err	=	0 ;
end


sequence	loadtype(value);
			@(posedge	as.clk)	(as.client_type_en  &&  as.client_type == value ) ;
endsequence

sequence	result(value);
			@(posedge	as.clk)	( ##[0:32] as.serve_type_en	&&	as.serve_type	==	value);
endsequence

property	first_handshake_type;
		loadtype(32'h0) |->    result(32'h1) ;
endproperty

property	second_handshake_type ;
		loadtype(32'hffff_ffff) |->  result(32'hffff_ffff) ;
endproperty

assert_first_tpye:	assert	property(first_handshake_type)	else	dump_log("assert_first");
assert_second_tpye:	assert	property(second_handshake_type)	else	dump_log("assert second");
endmodule
