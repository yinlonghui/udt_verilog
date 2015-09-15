`timescale	1ps/1ps
module	tb_decode(decode_if.TB TB);

logic	en	;

/*
	¸´Î»
*/
task	RST_IN();
integer	i	;
en				=	0	;
TB.in_tvalid	=	0	;

TB.in_tdata		=	64'h0	;
TB.core_rst_n = 1 ;
while( i != 0 ) begin
    	@(posedge	TB.clk);
    	i = i - 1 ;
    end
    i =  50 ;   
	while( i != 0 )
	begin
		@(posedge	TB.clk);
		i = i - 1 ;
		TB.core_rst_n = 0 ;
	end
	en	=	1	;
	TB.core_rst_n = 1 ;
	i = 10 ;
	while( i != 0 ) begin
        @(posedge	TB.clk);
        i = i - 1 ;
    end
endtask
/*
	
*/
task	SEND_PACK(
	input	[15:0]	ttype	,
	input	[31:0]	NUM	
);
	integer		j	;
	j	=	0	;
	TB.in_tvalid	=	1	;
	TB.in_tdata		=	{ttype,48'h0};
	TB.in_tkeep		=	8'b11111111	;
	TB.in_tlast		=	0 ;
	@(posedge	TB.clk);
	while(!TB.in_tready)	@(posedge	TB.clk);
	TB.in_tdata		=	64'h8111_0000_0000_0000	;
	while(	j	!=	NUM)
	begin
		TB.in_tvalid	=	1	;
		TB.in_tdata		=	TB.in_tdata + 64'h1	;
		TB.in_tkeep		=	8'b11111111	;	
		if(j + 1 == NUM)
		TB.in_tlast		=	1 ;
		@(posedge	TB.clk)	;
		while(!TB.in_tready)	@(posedge	TB.clk)	;
		j	=	j	+	1	;
		
	end	
	TB.in_tvalid	=	0	;
	TB.in_tlast		=	0	;
	@(posedge	TB.clk);


endtask
initial
begin
	TB.finish	=	0;
	RST_IN();
	SEND_PACK(16'h8000,32'd10);
	SEND_PACK(16'h8001,32'd10);
	SEND_PACK(16'h8002,32'd10);
	SEND_PACK(16'h8003,32'd10);
	SEND_PACK(16'h8005,32'd10);
	SEND_PACK(16'h8006,32'd10);
	SEND_PACK(16'h0000,32'd10);
	TB.finish	=	1;

end

initial
begin
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
	DECODE_PACK(en&TB.out_tvalid,32'd10);
end


task	DECODE_PACK(
	input	decode_valid	,
	input	[63:0]	NUM		
);
	integer	j	=	0	;
	TB.out_tready	=	1	;
	while(!decode_valid)	@(posedge	TB.clk);

	while(j < NUM || TB.out_tlast)
	begin
		TB.out_tready	=	1	;
		@(posedge	TB.clk);
		while(!decode_valid)@(posedge	TB.clk);
		TB.out_tready	=	0	;
		@(posedge	TB.clk);
		@(posedge	TB.clk);
		j	=	j	+	1	;
	end
endtask

endmodule	