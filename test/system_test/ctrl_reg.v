
module	ctrl_reg(
	input	core_clk ,
	input	core_rst_n	,

	output	reg	[31:0]	ctrl_s_axi_awaddr,	
	output	reg	ctrl_s_axi_awvalid,			
	input	ctrl_s_axi_awready,			
	
	output	reg	[31:0]	ctrl_s_axi_wdata,	
	output	reg	[3:0]	ctrl_s_axi_wstrb,
	output	reg	ctrl_s_axi_wvalid,			
	input	ctrl_s_axi_wready,			
	input	[1:0]	ctrl_s_axi_bresp,	
	input	ctrl_s_axi_bvalid,			
	output	reg	ctrl_s_axi_bready,			
	
	output	reg   [31:0]	ctrl_s_axi_araddr,	
	output	reg	ctrl_s_axi_arvalid,			
	input	ctrl_s_axi_arready,			
	input  [31:0]	ctrl_s_axi_rdata,	
	input	[1:0]	ctrl_s_axi_rresp,	
	input	ctrl_s_axi_rvalid,			
	output	reg	ctrl_s_axi_rready ,
	output	reg	finish	,
	output	reg	err		
);
(* mark_debug = "TRUE" *)	integer	next_State	;
(* mark_debug = "TRUE" *)	integer	state	;


reg	[31:0]	reg_address;
reg	[31:0]	temp_value ;
localparam	S_IDLE	=	1 ,
			S_INIT	=	2 ,
			S_W_ADDRESS	=	3 ,
			S_W_ADDRESS_WAIT	=	4 ,
			S_W_DATA	=	5 ,
			S_W_DATA_WAIT	=	6	,
			S_W_W_RESP	=	7 ,
			S_CONNECT_IDLE	=	8	,
			S_CONNECT_ADDRESS	=	9	,
			S_CONNECT_ADDRESS_WAIT	=	10 ,
			S_CONNECT_DATA			=	11	,
			S_CONNECT_DATA_WAIT		=	12	,
			S_CONNECT_RESP			=	13	,
			S_STATE_RD_CONNECT		=	14	,
			S_STATE_RD_CONNECT_ADRESS	=	15	,
			S_STATE_RD_CONNECT_ADRESS_WAIT	=	16 ,
			S_STATE_RD_CONNECT_DATA			=	17 ,
			S_CLOSE_IDLE					=	18	,
			S_CLOSE_ADDRESS					=	19	,
			S_CLOSE_ADDRESS_WAIT			=	20	,
			S_CLOSE_DATA					=	21	,
			S_CLOSE_DATA_WAIT				=	22	,
			S_CLOSE_DATA_RESP				=	29	,
			S_STATE_RD_CLOSE				=	23	,
			S_STATE_RD_CLOSE_ADDRESS		=	24	,
			S_STATE_RD_CLOSE_ADDRESS_WAIT	=	25	,
			S_STATE_RD_CLOSE_DATA			=	26	,
			S_END		=	27	,
			S_ERR		=	28	;
			
always@(posedge	core_clk or  negedge	core_rst_n)
begin
	if(!core_rst_n)
		state	<=	S_IDLE	;
	else
		state	<=	next_State	;
end

always@(*)
begin
	case(state)
		S_IDLE:	//	1
			if(ctrl_s_axi_awready)
				next_State	=	S_INIT ;
			else
				next_State	=	S_IDLE ;
		S_INIT:	//	2
			if(reg_address > 32'h0000_0004)
				next_State	=	S_CONNECT_IDLE	;
			else	if(ctrl_s_axi_awready)
				next_State	=	S_W_ADDRESS ;
			else
				next_State	=	S_INIT	;
		S_W_ADDRESS:	//		3
			if(ctrl_s_axi_wready)
				next_State	=	S_W_DATA	;
			else
				next_State	=	S_W_ADDRESS_WAIT	;
		S_W_ADDRESS_WAIT:	//	4
			if(ctrl_s_axi_wready)
				next_State	=	S_W_DATA	;
			else
				next_State	=	S_W_ADDRESS_WAIT	;
		S_W_DATA:	//	5
			if(ctrl_s_axi_bvalid)
				next_State	=	S_W_W_RESP	;
			else
				next_State	=	S_W_DATA_WAIT	;
		S_W_DATA_WAIT: 	//	6
			if(ctrl_s_axi_bvalid)
				next_State	=	S_W_W_RESP	;
			else
				next_State	=	S_W_DATA_WAIT	;
		S_W_W_RESP:	//	7
			if(ctrl_s_axi_bresp	== 	2'b00 )begin
				if(reg_address > 32'h0000_0004)
					next_State	=	S_CONNECT_IDLE ;
				else	if(!ctrl_s_axi_awready)
					next_State	=	S_INIT	;
				else	
					next_State	=	S_W_ADDRESS;
			end
			else
					next_State	=	S_ERR ;
		S_CONNECT_IDLE:	//	8
			if(ctrl_s_axi_awready)
				next_State	=	S_CONNECT_ADDRESS;
			else
				next_State	=	S_CONNECT_IDLE	;
		S_CONNECT_ADDRESS:	//	9
			if(ctrl_s_axi_wready)
				next_State	=	S_CONNECT_DATA	;
			else
				next_State	=	S_CONNECT_ADDRESS_WAIT	;
		S_CONNECT_ADDRESS_WAIT:	//	10
			if(ctrl_s_axi_wready)
				next_State	=	S_CONNECT_DATA	;
			else
				next_State	=	S_CONNECT_ADDRESS_WAIT	;
		S_CONNECT_DATA:	//	11
			if(ctrl_s_axi_bvalid)
				next_State	=	S_CONNECT_RESP	;		
			else
				next_State	=	S_CONNECT_DATA_WAIT ;
		S_CONNECT_DATA_WAIT:	//	12
			if(ctrl_s_axi_bvalid)
				next_State	=	S_CONNECT_RESP	;		
			else
				next_State	=	S_CONNECT_DATA_WAIT ;
		S_CONNECT_RESP:	//	13
				if(ctrl_s_axi_bresp	==	2'b00)
					next_State	=	S_STATE_RD_CONNECT	;
				else
					next_State	=	S_ERR	;
		S_STATE_RD_CONNECT:	//	14
			if(ctrl_s_axi_arready)
				next_State	=	S_STATE_RD_CONNECT_ADRESS	;
			else
				next_State	=	S_STATE_RD_CONNECT ;
		S_STATE_RD_CONNECT_ADRESS:	//	15
			if(ctrl_s_axi_rvalid)
				next_State	=	S_STATE_RD_CONNECT_DATA ;
			else
				next_State	=	S_STATE_RD_CONNECT_ADRESS_WAIT ;
		S_STATE_RD_CONNECT_ADRESS_WAIT:	//	16
			if(ctrl_s_axi_rvalid)
				next_State	=	S_STATE_RD_CONNECT_DATA ;
			else
				next_State	=	S_STATE_RD_CONNECT_ADRESS_WAIT ;
		S_STATE_RD_CONNECT_DATA:	//	17
			if(temp_value != 32'h0000_0010 )
				next_State	=	S_STATE_RD_CONNECT	;
			else	if(ctrl_s_axi_rresp	!=	2'b00)
				next_State	=	S_ERR	;
			else	
				next_State	=	S_CLOSE_IDLE	;
		
		S_CLOSE_IDLE:	//	18
			if(ctrl_s_axi_awready)
				next_State	=	S_CLOSE_ADDRESS ;
			else
				next_State	=	S_CLOSE_IDLE	;	
		S_CLOSE_ADDRESS:	//	19
			if(ctrl_s_axi_wready)
				next_State	=	S_CLOSE_DATA ;
			else
				next_State	=	S_CLOSE_ADDRESS_WAIT ;
		S_CLOSE_ADDRESS_WAIT:	//	20
			if(ctrl_s_axi_wready)
				next_State	=	S_CLOSE_DATA ;
			else
				next_State	=	S_CLOSE_ADDRESS_WAIT ;
		S_CLOSE_DATA:	//	21
			if(ctrl_s_axi_bvalid)
				next_State	=	S_STATE_RD_CLOSE ;
			else
				next_State	=	S_CLOSE_DATA_WAIT	;
		S_CLOSE_DATA_WAIT:	//	22
			if(ctrl_s_axi_bvalid)
				next_State	=	S_CLOSE_DATA_RESP ;
			else
				next_State	=	S_CLOSE_DATA_WAIT	;
		S_CLOSE_DATA_RESP:	//	29
			if(ctrl_s_axi_bresp	==	2'b00)		
				next_State	=	S_STATE_RD_CLOSE ;
			else
				next_State	=	S_ERR	;
		S_STATE_RD_CLOSE:	//	23
			if(ctrl_s_axi_arready)
				next_State	=	S_STATE_RD_CLOSE_ADDRESS	;
			else
				next_State	=	S_STATE_RD_CLOSE	;
		S_STATE_RD_CLOSE_ADDRESS:	//	24
			if(ctrl_s_axi_rvalid)
				next_State	=	S_STATE_RD_CLOSE_DATA	;
			else
				next_State	=	S_STATE_RD_CLOSE_ADDRESS_WAIT ;
		S_STATE_RD_CLOSE_ADDRESS_WAIT:	//	25
			if(ctrl_s_axi_rvalid)
				next_State	=	S_STATE_RD_CLOSE_DATA	;
			else
				next_State	=	S_STATE_RD_CLOSE_ADDRESS_WAIT ;
		S_STATE_RD_CLOSE_DATA:	//	26
			if(temp_value != 32'h0000_1000)
				next_State	=	S_STATE_RD_CLOSE ;
			else	if(ctrl_s_axi_rresp == 2'b00)
				next_State	=	S_END	;
			else
				next_State	=	S_ERR	;
				
		S_END:	//	27
				next_State	=	S_END	;
		S_ERR:	//	28
				next_State	=	S_ERR	;
	default:
		next_State	=	'bx ;
	endcase
end

always@(posedge	core_clk	or	negedge	core_rst_n)
begin
	if(!core_rst_n)
	begin
		ctrl_s_axi_awaddr	<=	32'h0;
		ctrl_s_axi_awvalid	<=	0	;
		
		ctrl_s_axi_wdata	<=	32'h0;
		ctrl_s_axi_wstrb	<=	4'b0;
		ctrl_s_axi_wvalid	<=	0	;
		ctrl_s_axi_bready	<=	0	;
		
		ctrl_s_axi_araddr	<=	32'h0;
		ctrl_s_axi_arvalid	<=	0	;
		ctrl_s_axi_rready	<=	0	;
		temp_value			<=	0	;
		reg_address			<=	0	;
		finish				<=	0	;
		err					<=	0	;
	
	end
	else	begin
		case(next_State)
			S_IDLE:
			begin
				ctrl_s_axi_awaddr	<=	32'h0;
				ctrl_s_axi_awvalid	<=	0	;
			
				ctrl_s_axi_wdata	<=	32'h0;
				ctrl_s_axi_wstrb	<=	4'b0;
				ctrl_s_axi_wvalid	<=	0	;
				ctrl_s_axi_bready	<=	0	;
		
				ctrl_s_axi_araddr	<=	32'h0;
				ctrl_s_axi_arvalid	<=	0	;
				ctrl_s_axi_rready	<=	0	;
		
				reg_address			<=	0	;
			end
			S_INIT:
			begin
				ctrl_s_axi_awaddr	<=	32'h0;
				ctrl_s_axi_awvalid	<=	0	;
				ctrl_s_axi_wdata	<=	32'h0;
				ctrl_s_axi_wstrb	<=	4'b0;
				ctrl_s_axi_wvalid	<=	0	;
				ctrl_s_axi_bready	<=	0	;
			end
			S_W_ADDRESS:
			begin
				ctrl_s_axi_awaddr	<=	reg_address ;
				ctrl_s_axi_awvalid	<=	1	;
			end
			S_W_ADDRESS_WAIT:
			begin
				ctrl_s_axi_awvalid	<=	0	;
			end
			S_W_DATA:
			begin
				case(reg_address)
					32'h0:	ctrl_s_axi_wdata	<=	32'd1024	;
					32'h1:	ctrl_s_axi_wdata	<=	32'd4096	;
					32'h2:	ctrl_s_axi_wdata	<=	32'd4096	;
					32'h3:	ctrl_s_axi_wdata	<=	32'd10240	;
					32'h4:	ctrl_s_axi_wdata	<=	32'd8192	;
				endcase
				ctrl_s_axi_wstrb	<=	4'b1111	;
				ctrl_s_axi_wvalid	<=	1	;
				reg_address	<=	reg_address + 32'h1;
			end
			S_W_DATA_WAIT:
			begin
				ctrl_s_axi_wvalid	<=	0	;
			end
			S_W_W_RESP:
			begin
				ctrl_s_axi_bready	<=	1 ;
			end
			S_CONNECT_IDLE:
			begin
				ctrl_s_axi_bready	<=	0 ;
			end
			S_CONNECT_ADDRESS:
			begin
				ctrl_s_axi_awaddr	<=	32'h0000_0005	;
				ctrl_s_axi_awvalid	<=	1				;
			end
			S_CONNECT_ADDRESS_WAIT:
			begin
				ctrl_s_axi_awvalid	<=	0	;
			end
			S_CONNECT_DATA:
			begin
				ctrl_s_axi_wdata	<=	0	;
				ctrl_s_axi_wstrb	<=	4'b1111	;
				ctrl_s_axi_wvalid	<=	1	;
			end
			S_CONNECT_DATA_WAIT:
			begin
				ctrl_s_axi_wvalid	<=	0	;	
			end
			S_CONNECT_RESP:
			begin
				ctrl_s_axi_bready	<=	1	;
			end
			S_STATE_RD_CONNECT:
			begin
				ctrl_s_axi_bready	<=	0	;
				ctrl_s_axi_arvalid	<=	0	;
			end
			S_STATE_RD_CONNECT_ADRESS:
			begin
				ctrl_s_axi_arvalid <=	1 ;
				ctrl_s_axi_araddr	<=	32'h0000_0005	;
			end
			S_STATE_RD_CONNECT_ADRESS_WAIT:
			begin
				ctrl_s_axi_arvalid	<=	0 ;
				temp_value			<=	ctrl_s_axi_rdata ;
			end
			S_STATE_RD_CONNECT_DATA:
			begin
				ctrl_s_axi_arvalid	<=	1 ;
				temp_value			<=	ctrl_s_axi_rdata ;
			end
			S_CLOSE_IDLE:
			begin
				ctrl_s_axi_arvalid  <=  0 ;
			end
			S_CLOSE_ADDRESS:
			begin
				ctrl_s_axi_awvalid	<= 1 ;
				ctrl_s_axi_awaddr	<=	32'h0000_0006	;
			end
			S_CLOSE_ADDRESS_WAIT:
			begin
				ctrl_s_axi_awvalid	<= 0 ;
			end
			S_CLOSE_DATA:
			begin
				ctrl_s_axi_wdata	<=	0	;
				ctrl_s_axi_wstrb	<=	4'b1111	;
				ctrl_s_axi_wvalid	<=	1	;
			end
			S_CLOSE_DATA_WAIT:
			begin
				ctrl_s_axi_wvalid	<=	0	;
			end
			S_CLOSE_DATA_RESP:
			begin
				ctrl_s_axi_bready	<=	1 ;
			end
			S_STATE_RD_CLOSE:
			begin
				ctrl_s_axi_bready	<=	0	;
				ctrl_s_axi_arvalid	<=	0	;
			end
			S_STATE_RD_CLOSE_ADDRESS:
			begin
				ctrl_s_axi_arvalid	<=	1	;
				ctrl_s_axi_araddr	<=	32'h0000_0006 ;
			end
			S_STATE_RD_CLOSE_ADDRESS_WAIT:
			begin
				ctrl_s_axi_arvalid	<=	0 ;
				temp_value			<=	ctrl_s_axi_rdata ;
			end
			S_STATE_RD_CLOSE_DATA:
			begin
				ctrl_s_axi_arvalid	<=	1 ;
				temp_value			<=	ctrl_s_axi_rdata ;
			end
			S_END:
			begin
				finish	<=	1 ;
			end
			S_ERR:
			begin
				err	<=	1 ;
			end
		endcase
	end
	

end

endmodule