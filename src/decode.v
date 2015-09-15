//%	@file	decode.v
//%	@brief	本文件定义decode模块
//%	@details

//%	本模块解码对端的UDP帧协议
//% @details
//%		UDT协议包格式：
//%			控制包：
//%			Handshake:
//%			Keep-live:
//%			NAK:
//%			CLOSE:
//%			ACK:
//%			Light-ACK
//%			ACK2:
//%			数据包：
//%		解析出对应内容,发送到相应的处理模块


module	decode
#(

	parameter	C_S_AXI_DATA_WIDTH	=	64	
)(
	input	core_clk ,								//%	时钟
	input	core_rst_n ,							//%	复位
	input	[C_S_AXI_DATA_WIDTH-1:0]	in_tdata,	//%	UDP数据包
	input	[C_S_AXI_DATA_WIDTH/8-1:0]	in_tkeep,	//%	UDP字节使能
	input	in_tvalid , 							//%	UDP包有效
	output	reg	in_tready	,						//%	UDP包就绪
	input	in_tlast	,							//%	UDP包结束
	
	output	reg	[C_S_AXI_DATA_WIDTH-1:0]	out_tdata ,	//%	输出包
	output	reg	out_tlast ,								//%	输出包结束
	output	reg	out_tvalid	,							//%	输出包有效
	output	reg	[C_S_AXI_DATA_WIDTH/8-1:0]	out_tkeep ,	//%	输出包使能
	input	out_tready,									//%	输出包就绪

	output	reg	Data_en	,								//%	数据有效 1
	output	reg	ACK_en	,								//%	ACK包有效 2
	output	reg	ACK2_en	,								//%	ACK2包有效	3	
	output	reg	Keep_live_en ,							//%	Keep-live包有效	4
	output	reg	NAK_en	,								//%	NAK包有效	5	
	output	reg	Handshake_en , 							//%	握手包有效	6
	output	reg	CLOSE_en	 ,							//%	关闭信号	7
	output	reg	error		 	
);
integer	State	,	Next_State	;

localparam		S_IDLE	=	1	,
				S_TPYE	=	2	,
				S_TYPE_WAIT	=	3	,
				S_RD_DATA	=	4	,
				S_RD_DATA_WAIT	=	5	,
				S_DATA_OUT	=	6	,
				S_DATA_OUT_WAIT	=	7	,
				S_LAST			=	8	,
				S_ERR			=	9	;
				
				
parameter	S_PACK	=	3'b000	;
parameter	S_ACK	=	3'b001	;
parameter	S_ACK2	=	3'b010	;
parameter	S_KEEP_ALIVE	=	3'b011	;
parameter	S_NAK	=	3'b100	;
parameter	S_HANDSHAKE	=	3'b101	;
parameter	S_CLOSE		=	3'b110	;
parameter	S_ERROR		=	3'b111	;

reg	[2:0]	type_reg	;

always@(posedge	core_clk	or	negedge	core_rst_n	)
begin
	if(!core_rst_n)
		State	<=	S_IDLE	;
	else
		State	<=	Next_State	;
end

always@(*)
begin
	case(State)
	S_IDLE:
	begin
		if(in_tvalid)
			Next_State	=	S_TPYE	;
		else
			Next_State	=	S_IDLE	;
	end		
	S_TPYE:
	begin
		Next_State	=	S_TYPE_WAIT	;
	end
	S_TYPE_WAIT:
	begin
		if(S_ERROR == type_reg)
			Next_State	=	S_ERR	;
		else
			Next_State	=	S_RD_DATA	;
	end
	S_RD_DATA:
	begin
		if(in_tlast && out_tready)
			Next_State	=	S_LAST	;
		else	if(in_tvalid)
			Next_State	=	S_DATA_OUT	;
		else
			Next_State	=	S_RD_DATA_WAIT	;
	end
	S_RD_DATA_WAIT:
	begin
		if(in_tlast && out_tready)
			Next_State	=	S_LAST	;
		else	if(in_tvalid)
			Next_State	=	S_DATA_OUT	;
		else
			Next_State	=	S_RD_DATA_WAIT	;
	end
	S_DATA_OUT:
	begin
		if(out_tready)
			Next_State	=	S_RD_DATA	;
		else
			Next_State	=	S_DATA_OUT_WAIT	;
	end
	S_DATA_OUT_WAIT:
	begin
		if(out_tready)
			Next_State	=	S_RD_DATA	;
		else
			Next_State	=	S_DATA_OUT_WAIT	;
	end
	S_LAST:
	begin
		if(out_tready)
			Next_State	=	S_IDLE	;
		else
			Next_State	=	S_LAST	;
	end
	S_ERR:
	begin
		Next_State	=	S_ERR	;
	end
	default:
		Next_State	=	'bx	;
	endcase
end

always@(posedge	core_clk	or	negedge	core_rst_n)
begin
	if(!core_rst_n)
	begin
		in_tready	<=	0;
		out_tdata	<=	64'b0 ;
		out_tlast	<=	0;
		out_tvalid	<=	0;
		out_tkeep	<=	0;
		Data_en		<=	0;
		ACK_en		<=	0;
		ACK2_en		<=	0;
		Keep_live_en	<=	0;
		NAK_en			<=	0;
		Handshake_en	<=	0;
		CLOSE_en		<=	0;		
		error			<=	0;
		type_reg		<=	0;
	end
	else
	begin
		case(Next_State)
			S_IDLE:
			begin
				in_tready	<=	0;
				out_tdata	<=	64'b0 ;
				out_tlast	<=	0;
				out_tvalid	<=	0;
				out_tkeep	<=	0;
				Data_en		<=	0;
				ACK_en		<=	0;
				ACK2_en		<=	0;
				Keep_live_en	<=	0;
				NAK_en			<=	0;
				Handshake_en	<=	0;
				CLOSE_en		<=	0;	
				type_reg		<=	0;
				
			end
			S_TPYE:
			begin
				in_tready	<=	1	;
				if(in_tdata[63] == 1 )	begin
					case(in_tdata[62:48])
						15'h0:	type_reg	<=	S_HANDSHAKE		;
						15'h1:	type_reg	<=	S_KEEP_ALIVE ;
						15'h2:	type_reg	<=	S_ACK	;
						15'h3:	type_reg	<=	S_NAK	;
						15'h5:	type_reg	<=	S_CLOSE	;
						15'h6:	type_reg	<=	S_ACK2	;
					default:
						type_reg	<=	S_ERROR ;
					endcase
				end
				else
					type_reg	<=	S_PACK	;
				
			end
			S_TYPE_WAIT:
			begin
				in_tready	<=	0	;
			end
			S_RD_DATA:
			begin
				in_tready	<=	1;
				out_tdata	<=	in_tdata	;
				out_tkeep	<=	in_tkeep	;
				out_tlast	<=	0			;
				Data_en		<=	0;
				ACK_en		<=	0;
				ACK2_en		<=	0;
				Keep_live_en	<=	0;
				NAK_en			<=	0;
				Handshake_en	<=	0;
			end
			S_RD_DATA_WAIT:
			begin
				out_tdata	<=	in_tdata	;
				out_tkeep	<=	in_tkeep	;
			end
			S_DATA_OUT:
			begin
				in_tready	<=	0	;
				out_tvalid	<=	1	;
				case(type_reg)
					S_PACK:		Data_en	<= 1 ;
					S_HANDSHAKE:	Handshake_en	<=	1;
					S_KEEP_ALIVE:	Keep_live_en	<=	1	;
					S_ACK:			ACK_en	<=	1	;
					S_NAK:			NAK_en	<=	1   ;
					S_CLOSE:		CLOSE_en	<=	1	;
					S_ACK2:			ACK2_en		<=	1	;
				endcase
			end
			S_DATA_OUT_WAIT:
			begin
			end
			S_LAST:
			begin
				out_tlast	<=	1	;
				out_tvalid	<=	1	;
				in_tready	<=	0	;
				case(type_reg)
					S_PACK:		Data_en	<= 1 ;
					S_HANDSHAKE:	Handshake_en	<=	1;
					S_KEEP_ALIVE:	Keep_live_en	<=	1	;
					S_ACK:			ACK_en	<=	1	;
					S_NAK:			NAK_en	<=	1   ;
					S_CLOSE:		CLOSE_en	<=	1	;
					S_ACK2:			ACK2_en		<=	1	;
				endcase
			end
			S_ERR:
			begin
				error	<=	1;
			end
			
		endcase
	
	end
end
endmodule

