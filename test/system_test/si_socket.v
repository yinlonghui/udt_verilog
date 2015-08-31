module	si_socket(
	input	core_clk ,
	input	core_rst_n ,
	
	input	Req_Connect ,
	output	reg	Res_Connect ,
	
	input	Req_Close	,
	output	reg	Res_Close	,
	output	reg	Peer_Req_Close ,
	input		Peer_Res_Close ,	
	input	state_ready,
	output	reg	state_valid ,
	output	reg	[31:0]	udt_state
);


integer	State	,	next_State	;

localparam		S_IDLE	=	1	,
				S_RES_CONNECT	=	2	,
				S_WRITE_CONNECTED	=	3 ,
				S_CONNECT_WAIT		=	4 ,
				S_RES_CLOSE			=	5 ,
				S_WRITE_CLOSED		=	6 ,
				S_CLOSE_WAIT		=	7 ;
				

always@(posedge	core_clk or negedge	core_rst_n)
begin
	if(!core_rst_n)
		State	<=	S_IDLE ;
	else
		State	<=	next_State	;
end

always@(*)
begin
	case(State)
		S_IDLE:
			if(Req_Connect)
				next_State =	S_RES_CONNECT ;
			else
				next_State	=	S_IDLE	;
		S_RES_CONNECT:
			next_State	=	S_WRITE_CONNECTED	;
		S_WRITE_CONNECTED:
			if(state_ready)
				next_State	=	S_CONNECT_WAIT ;
			else
				next_State	=	S_WRITE_CONNECTED ;
		S_CONNECT_WAIT:
			if(Req_Close)
				next_State	=	S_RES_CLOSE ;
			else
				next_State	=	S_CONNECT_WAIT ;
		S_RES_CLOSE:
			next_State	=	S_WRITE_CLOSED ;
		S_WRITE_CLOSED:
			if(state_ready)
				next_State = S_CLOSE_WAIT ;
			else
				next_State = S_WRITE_CLOSED ;
		S_CLOSE_WAIT:
			next_State	=	S_IDLE	;
	
	default:
		next_State	=	'bx ;
	endcase
end

always@(posedge	core_clk	or negedge	core_rst_n)
begin
	if(!core_rst_n)begin
		Res_Connect	<=	0	;
		Res_Close	<=	0	;
		Peer_Req_Close	<=	0	;
		state_valid	<=	0	;
		udt_state	<=	32'h0	;
	end
	else	begin
		case(next_State)
			S_IDLE:
			begin
				Res_Connect	<=	0	;
				Res_Close	<=	0	;
				Peer_Req_Close	<=	0	;
				state_valid	<=	0	;
				udt_state	<=	32'h0	;
			end
			S_RES_CONNECT:
			begin
				Res_Connect <=	1	;
			end
			S_WRITE_CONNECTED:
			begin
				Res_Connect <=	0	;
				udt_state	<=	32'h0000_0010 ;
				state_valid	<=	1	;
			end
			S_CONNECT_WAIT:
			begin
				state_valid	<=	0	;
			end	
			S_RES_CLOSE:
			begin
				Res_Close	<=	1	;
			end
			S_WRITE_CLOSED:
			begin
				Res_Close	<=	0	;
				udt_state	<=	32'h0000_1000 ;
				state_valid	<=	1	;
			end
			S_CLOSE_WAIT:
			begin
				state_valid	<=	0	;
			end
		endcase
	end

end

endmodule