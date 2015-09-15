module	as_decode(	decode_if.AS  AS);


task	dump_log(input	string	filename);
	int fid= $fopen("as_decode.log","w");
    $fdisplay(fid,"[as_decode]  %s \n",filename);
    AS.err =  1 ;
    $fclose(fid);

endtask

initial
begin
	AS.err =  0 ;
end

/*
	sequence
*/
sequence	SEQ_TYPE(TYPE);

		@(posedge	AS.clk)	(AS.in_tready &&	AS.in_tvalid &&    AS.in_tdata == TYPE) ;
endsequence

sequence	SEQ_OUT_AXI(MAX,en);
		@(posedge	AS.clk) ##[0:5] (en  ##[0:10] AS.out_tready)[*MAX] ##0  AS.out_tlast	;
endsequence

property	PACK_P;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h0)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.Data_en);
endproperty

property	HANDSHAKE_P;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8000_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.Handshake_en);
endproperty

property	KEEP_ALIVE_P	;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8001_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.Keep_live_en);

endproperty

property	ACK_P	;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8002_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.ACK_en);
endproperty

property	NAK_P	;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8003_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.NAK_en);
endproperty	

property	CLOSE_P;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8005_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.CLOSE_en);
	
endproperty

property	ACK2_P	;
		disable	iff(!AS.core_rst_n)
		SEQ_TYPE(64'h8006_0000_0000_0000)	|->	SEQ_OUT_AXI(10,AS.out_tvalid && AS.ACK2_en);
endproperty


AS_PACK:	assert	property(PACK_P)	else	dump_log("AS_PACK");
AS_HANDSHAKE:	assert	property(HANDSHAKE_P)	else	dump_log("AS_HANDSHAKE");
AS_KEEP_ALIVE:	assert	property(KEEP_ALIVE_P)	else	dump_log("AS_KEEP_ALIVE");
AS_ACK:			assert	property(ACK_P)	else		dump_log("AS_ACK");
AS_NAK:			assert	property(NAK_P)	else		dump_log("AS_NAK");
AS_CLOSE:		assert	property(CLOSE_P)	else	dump_log("AS_CLOSE");
AS_ACK2:		assert	property(ACK2_P)	else	dump_log("AS_ACK2");


endmodule