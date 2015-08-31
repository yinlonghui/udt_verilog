//%	@file   configure.v
//%	@brief	 本文件定义配置寄存器模块
//% @details 
//% 配置寄存器模块主要接收用户配置命令，以AXI-LITE协议操作BRAM，用户通过操作UDT寄存器来管理UDT
//% @details
//%	配置参数：
//%		1、配置状态寄存器标识为成功再进行2步骤
//%		2、检查是否已经UDT建立连接:
//%			2.1若已经建立连接，则将配置状态寄存器表示错误状态（连接）
//%			2.2 若未建立连接，则检查参数是否在正确的范围内
//%				2.2.1 若在正确的范围，则向写入相应的参数，然后将配置状态寄存器标识为成功配置
//%				2.2.2 若不在正确的范围，则将配置状态寄存器表示错误状态（越界）
//%	建立连接:
//%		检查连接寄存器的状态：
//%			1、若UDT连接状态寄存器为正在连接或者连接成功状态，则将UDT连接状态寄存器改为连接失败，发送给Socket Manager关闭连接的操作
//%			2、若UDT连接状态寄存器为关闭状态或者未打开状态，将UDT连接状态寄存器改为正在连接状态，发送给Socket Manager打开连接的操作
//%	关闭连接：
//%			1、若UDT连接状态为关闭，则将UDT连接状态寄存器改为关闭失败
//%			2、若UDT连接状态为连接，向Socket Manager发送关闭连接操作，等待UDT关闭，更新连接寄存器标识为关闭
//%	读状态寄存器：
//%			AXI-LITE（读操作）直接读取BRAM
//%	寄存器映射：
module    configure #(
		parameter	DEFAULT_SND_BUFFER_SIZE	=	32'd8192 ,
		parameter	DEFAULT_REV_BUFFER_SIZE =   32'd8192 ,
		parameter	DEFAULT_FLIGHT_FLAG_SIZE =	32'd256000,
		parameter	MAX_MSSize	= 32'd8000	,
		parameter	MAX_MEMORY_SIZE	=   32'd1024*1024 ,
		parameter	DEFAULT_INIT_SEQ	=	0	,
		parameter	INIT_STATE	=	32'h0000_0000 ,
		parameter	CONNECTING	=	32'h0000_0001 ,
		parameter	CONNECTED	=	32'h0000_0010 ,
		parameter	CLOSING	=	32'h0000_0100	,
		parameter	CLOSED	=	32'h0000_1000	
	
)(
	input	ctrl_s_axi_aclk,							//% 用户-时钟信号(100Mhz)
	input   ctrl_s_axi_aresetn,							//% 用户-复位信号(低信号复位)
	input	[31:0]	ctrl_s_axi_awaddr,					//%	用户-写地址信号
	input	ctrl_s_axi_awvalid,							//% 用户-写地址有效
	output	reg	ctrl_s_axi_awready,						//%	用户-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,					//%	用户-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,					//%	用户-写操作字节使能
	input	ctrl_s_axi_wvalid,							//%	用户-写数据有效
	output	reg	ctrl_s_axi_wready,						//%	用户-写数据就绪
	output	reg	[1:0]	ctrl_s_axi_bresp,				//%	用户-写数据应答
	output	reg	ctrl_s_axi_bvalid,						//%	用户-写应答有效
	input	ctrl_s_axi_bready,							//%	用户-写应答就绪
	
	input   [31:0]	ctrl_s_axi_araddr,					//% 用户-读地址信号
	input	ctrl_s_axi_arvalid,							//% 用户-读地址有效
	output	reg	ctrl_s_axi_arready,							//% 用户-读地址就绪
	output  reg [31:0]	ctrl_s_axi_rdata,					//%	用户-读操作数据
	output	reg [1:0]	ctrl_s_axi_rresp,					//%	用户-读数据应答
	output	reg	ctrl_s_axi_rvalid,							//%	用户-读数据有效
	input	ctrl_s_axi_rready,							//%	用户-读数据就绪
	
	input	[31:0]	udt_state ,							//%	连接状态
	input	state_valid,								//%	连接状态有效
	output	reg	state_ready,							//%	连接状态就绪
	
	
	output	reg	Req_Connect ,							//%	连接请求
	input	Res_Connect ,								//% 连接回应
	
	output	reg	Req_Close	,							//%	关闭请求
	input	Res_Close	,								//%	关闭回应
	
	input	Peer_Req_Close ,						
	output	reg	Peer_Res_Close ,
	
//	output	reg	user_closed	,							//%	关闭信号(使UDT-AXI-STREAM-READY无效)
	output	reg	user_valid	,							//%	关闭信号有效
	input	user_ready	,								//%	关闭信号就绪
//	output	CTRL_state_reg ,							//%	DEBUG信号
	
	
	output	reg	[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
	output	reg	[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
	output	reg [31:0]	 FlightFlagSize ,					//%	最大流量窗口大小
	output	reg [31:0]	MSSize	,							//%	最大包大小
	output	reg	[31:0]	INIT_SEQ							//%	初始化序列号

);
/*			(Snd_Buffer_Size +   Snd_Buffer_Size)*MSSize +   2*m_iFlightFlagSize*sizeof(list) < DEFAULT_FLIGHT_FLAG_SIZE */





reg	[31:0]	CTRL_state_reg ; 
reg	[31:0]	REG_address ;



(* mark_debug = "TRUE" *)	integer	CTRL_State  ;
(* mark_debug = "TRUE" *)	integer CTRL_Next_State ;
(* mark_debug = "TRUE" *)	integer	READ_CTRL_State ;
(* mark_debug = "TRUE" *)	integer READ_CTRL_Next_State ;


(* mark_debug = "TRUE" *)	reg		init_paramter ;

/*遵守AXI-LITE协议*/


localparam  CTRL_IDLE = 0 ,  
	CTRL_INIT = 1 ,	CTRL_SEL = 17 ,
	CTRL_CONNECT = 2 , CTRL_CLOSE  = 3 ,
	CTRL_SND_BUFFER = 4 , CTRL_REV_BUFFER = 5 ,CTRL_FLIGHT_SIZE = 6 , CTRL_MSSIZE = 7 , CTRL_INIT_SEQ = 8 ,
	CTRL_UNKOWN = 9 ,
	WRESP_IDLE = 10 , WRESP_OK = 11 ,WRESP_SLVERR = 12 ,WRESP_DECERR = 13 ,
	CTRL_CLOSE2CORE = 14 ,  CTRL_CONNECT2CORE = 15  ,
	CTRL_UDT_STATE  = 16 ;

			


localparam	READ_IDLE   =  1  , READ_ADDRESS  = 2 ,  READ_OK  = 3 , READ_SLVERR = 4 , READ_DECERR = 5  , RRESP_IDLE = 6;

(* mark_debug = "TRUE" *)	reg	[7:0]	sel ;
(* mark_debug = "TRUE" *)	reg			sel_en	;
(* mark_debug = "TRUE" *)	reg [31:0]	rd_sel ;

parameter	SEL_SND_PARAMETER	=	8'b0000_0001 ;
parameter	SEL_RCV_PARAMETER	=	8'b0000_0010 ;
parameter	SEL_FIGHT_SIZE		=	8'b0000_0100 ;
parameter	SEL_MSSIZE			=	8'b0000_1000 ;
parameter	SEL_INIT_SEQ		=	8'b0001_0000 ;
parameter	SEL_CONNECT			=	8'b0010_0000 ;
parameter	SEL_CLOSE			=	8'b0100_0000 ;
parameter	SEL_UNKNOW			=	8'b1000_0000 ;
/* read  channel  for AXI */

always@(posedge ctrl_s_axi_aclk or negedge ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
	begin
		user_valid <= 0 ;
		Peer_Res_Close <= 0 ;
	end
	else	if(Peer_Req_Close || Res_Close ) begin
		user_valid <= 1 ;
		Peer_Res_Close <= 0 ;
	end
	else	if(user_ready) begin
		user_valid <= 0 ;
		Peer_Res_Close <= 1 ;
	end
end

always@(posedge  ctrl_s_axi_aclk or  negedge ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
		READ_CTRL_State  <= READ_IDLE ;
	else
		READ_CTRL_State  <= READ_CTRL_Next_State ;
end

always@(*)
begin
	case(READ_CTRL_State)
		READ_IDLE:
			if(ctrl_s_axi_arvalid)
				READ_CTRL_Next_State =  READ_ADDRESS ;
			else
				READ_CTRL_Next_State =  READ_IDLE ;
		READ_ADDRESS:
			if(ctrl_s_axi_araddr > 32'h0000_0006)
				READ_CTRL_Next_State	=	READ_DECERR	;
			else
				READ_CTRL_Next_State	=	RRESP_IDLE ;
		RRESP_IDLE:
			if(rd_sel == 32'hffff_ffff)
				READ_CTRL_Next_State	=	READ_SLVERR ;
			else
				READ_CTRL_Next_State	=	READ_OK ;
		READ_DECERR:
			READ_CTRL_Next_State =  READ_IDLE ;
		READ_OK:
			READ_CTRL_Next_State =  READ_IDLE ; 
		READ_SLVERR:
			READ_CTRL_Next_State =  READ_IDLE ; 
		default:
			READ_CTRL_Next_State = 'bx ;
	endcase
	
end

always@(posedge	ctrl_s_axi_aclk or  negedge  ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
	begin
		ctrl_s_axi_arready <= 0 ;
		ctrl_s_axi_rdata	<= 32'h 0;
		ctrl_s_axi_rresp	<= 2'b0;
		ctrl_s_axi_rvalid	<= 1'b0;
//		CTRL_state_reg		<=	INIT_STATE ;
		rd_sel <= 0 ;
	end
	else
	begin
		case(READ_CTRL_Next_State)
			READ_IDLE:
			begin
				ctrl_s_axi_arready 	<= 1 ;
				ctrl_s_axi_rdata	<= 32'h 0;
				ctrl_s_axi_rresp	<= 2'b0;
				ctrl_s_axi_rvalid	<=  0;
				rd_sel <= 0 ;
			end
			READ_ADDRESS:
			begin
				case(ctrl_s_axi_araddr)
					32'h0000_0000:
						rd_sel <= MSSize ;
					32'h0000_0001:
						rd_sel <= Snd_Buffer_Size ;
					32'h0000_0002:
						rd_sel <= Rev_Buffer_Size ;
					32'h0000_0003:
						rd_sel <= FlightFlagSize ;
					32'h0000_0004:
						rd_sel <= INIT_SEQ	;
					32'h0000_0005:
						rd_sel <= CTRL_state_reg ;
					32'h0000_0006:
						rd_sel <= CTRL_state_reg ;
					default:
						rd_sel <= 32'hffff_ffff ;	
				endcase
				ctrl_s_axi_arready <= 0 ;
			end
			READ_OK:
			begin
				ctrl_s_axi_rdata <= rd_sel ;
				ctrl_s_axi_rresp <= 2'b00 ;
				ctrl_s_axi_rvalid <= 1 ;
			end
			READ_DECERR:
			begin
				ctrl_s_axi_rdata <= rd_sel ;
				ctrl_s_axi_rresp <= 2'b01 ;
				ctrl_s_axi_rvalid <= 1  ;
			end
			READ_SLVERR:
			begin
				ctrl_s_axi_rdata <= rd_sel ;
				ctrl_s_axi_rresp <= 2'b11 ;
				ctrl_s_axi_rvalid <= 1 ;
			end
		endcase
	end
end
/*	write channel for AXI */
always@(posedge	ctrl_s_axi_aclk or negedge ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
		CTRL_State	<=	CTRL_IDLE ;
	else
		CTRL_State	<=	CTRL_Next_State	;
end		


always@(*)
begin
	case(CTRL_State)
		CTRL_IDLE:
		if(init_paramter == 0 )
			CTRL_Next_State = CTRL_INIT ;
		else	if(state_valid  && init_paramter)
			CTRL_Next_State = CTRL_UDT_STATE ;
		else	if(ctrl_s_axi_awvalid && !state_valid)
			CTRL_Next_State = CTRL_SEL ;
		else
			CTRL_Next_State = CTRL_IDLE ;
		
		CTRL_SEL:
		begin
			if(sel_en && ctrl_s_axi_wvalid)
			begin
				case(sel)
				SEL_SND_PARAMETER:CTRL_Next_State = CTRL_SND_BUFFER ;
				SEL_RCV_PARAMETER:CTRL_Next_State = CTRL_REV_BUFFER ;
				SEL_FIGHT_SIZE:CTRL_Next_State = CTRL_FLIGHT_SIZE ;
				SEL_MSSIZE:CTRL_Next_State = CTRL_MSSIZE ;
				SEL_INIT_SEQ:CTRL_Next_State = CTRL_INIT_SEQ ;
				SEL_CONNECT:CTRL_Next_State = CTRL_CONNECT ;
				SEL_CLOSE:CTRL_Next_State = CTRL_CLOSE ;
				SEL_UNKNOW:CTRL_Next_State = CTRL_UNKOWN ;
				endcase
			end
			else
				CTRL_Next_State =  CTRL_SEL ;
		end
		CTRL_UDT_STATE:
		begin
			CTRL_Next_State = CTRL_IDLE ;
		end
	
		
		CTRL_INIT:
		begin
			CTRL_Next_State	=	CTRL_IDLE	;
		end
	
		CTRL_CONNECT:
		begin
			CTRL_Next_State =	WRESP_IDLE	;
				
		end
		CTRL_SND_BUFFER:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_SND_BUFFER ;
		end
		CTRL_REV_BUFFER:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_REV_BUFFER ;
		end
		CTRL_FLIGHT_SIZE:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_FLIGHT_SIZE ;
		end
		CTRL_MSSIZE:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_MSSIZE ;
		end
		
		CTRL_INIT_SEQ:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_INIT_SEQ ;
		end
		
		CTRL_CLOSE:
		begin
			//if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
			//else
			//	CTRL_Next_State =	CTRL_CLOSE ;
		end
		
		CTRL_UNKOWN:
		begin
		//	if(ctrl_s_axi_wvalid)
				CTRL_Next_State =	WRESP_IDLE	;
		//	else
		//		CTRL_Next_State =	CTRL_UNKOWN ;
		end
		WRESP_IDLE:
		begin
			if(sel <  8'b0010_0000 ) begin
				if(sel == SEL_MSSIZE && MSSize <= MAX_MSSize)
					CTRL_Next_State =	WRESP_OK ;
				else	if(	sel == SEL_SND_PARAMETER && (Snd_Buffer_Size << 3) <= MAX_MEMORY_SIZE)
					CTRL_Next_State =	WRESP_OK ;
				else	if(sel == SEL_RCV_PARAMETER &&  (Rev_Buffer_Size << 3) <= MAX_MEMORY_SIZE)
					CTRL_Next_State =	WRESP_OK ;
				else	if(sel == SEL_FIGHT_SIZE && Rev_Buffer_Size < FlightFlagSize )
					CTRL_Next_State =	WRESP_OK ;
				else	if(sel == SEL_INIT_SEQ )
					CTRL_Next_State =	WRESP_OK ;
				else
					CTRL_Next_State =	WRESP_SLVERR ;
			end  else	if(sel == SEL_CONNECT && (CTRL_state_reg == INIT_STATE || CTRL_state_reg == CLOSED))
				CTRL_Next_State =	WRESP_OK ;
			else	if(sel == SEL_CLOSE &&  CTRL_state_reg == CONNECTED )
				CTRL_Next_State = 	WRESP_OK ;
			else	if(sel == SEL_UNKNOW)
				CTRL_Next_State =	WRESP_DECERR ;
			else
				CTRL_Next_State =  WRESP_SLVERR ;
		end
		WRESP_OK:
		begin
			if( sel == SEL_CONNECT &&  ctrl_s_axi_bready)
				CTRL_Next_State = CTRL_CONNECT2CORE ;
			else	if(sel == SEL_CLOSE && ctrl_s_axi_bready)
				CTRL_Next_State = CTRL_CLOSE2CORE	;
			else	if(ctrl_s_axi_bready)
				CTRL_Next_State = CTRL_IDLE ;
			else
				CTRL_Next_State =  WRESP_OK ;
		end
		WRESP_SLVERR:
		begin
			if(ctrl_s_axi_bready)
				CTRL_Next_State = CTRL_IDLE ;
			else
				CTRL_Next_State =  WRESP_SLVERR ;
		end
		WRESP_DECERR:
		begin
			if(ctrl_s_axi_bready)
				CTRL_Next_State = CTRL_IDLE ;
			else
				CTRL_Next_State =  WRESP_DECERR ;
		end
		CTRL_CLOSE2CORE:
		begin
			if(Res_Close)
				CTRL_Next_State = CTRL_IDLE ;
			else
				CTRL_Next_State = CTRL_CLOSE2CORE ;
		end
		CTRL_CONNECT2CORE:
		begin
			if(Res_Connect)
				CTRL_Next_State = CTRL_IDLE ;
			else
				CTRL_Next_State = CTRL_CONNECT2CORE ;
		end
		default:
			CTRL_Next_State = 'bx ;
	endcase
end


always@(posedge	ctrl_s_axi_aclk or negedge	ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
	begin
		init_paramter <= 0;
		ctrl_s_axi_awready <= 0 ;
		ctrl_s_axi_wready  <= 0 ;
		ctrl_s_axi_bresp  <= 2'b00 ;
		ctrl_s_axi_bvalid <= 0 ;
		sel <= 8'b0 ;
		Snd_Buffer_Size  <= 'bx ;
		Rev_Buffer_Size	<= 'bx ;
		FlightFlagSize <= 'bx ;
		MSSize <= 'bx ;
		INIT_SEQ <= 'bx ;
		CTRL_state_reg	<=	INIT_STATE ;
		Req_Close <= 0 ;
		sel_en <= 0 ;
		state_ready <= 0 ;
		Req_Connect <= 0 ;
	end
	else	begin
		case(CTRL_Next_State)
			CTRL_IDLE:
			begin
				sel <= 8'b0 ;
				state_ready <= 0 ;
				if(init_paramter)
					ctrl_s_axi_awready <= 1 ;
				ctrl_s_axi_wready  <= 0 ;
				ctrl_s_axi_bresp  <= 2'b00 ;
				ctrl_s_axi_bvalid <= 0 ;
				Req_Close <= 0 ;
				sel_en <= 0 ;
				Req_Connect <= 0 ;
			end
			CTRL_INIT:
			begin
				init_paramter <= 1 ;
				ctrl_s_axi_awready <= 1 ;
				Snd_Buffer_Size <= DEFAULT_SND_BUFFER_SIZE ;
				Rev_Buffer_Size <= DEFAULT_REV_BUFFER_SIZE ;
				FlightFlagSize <= DEFAULT_FLIGHT_FLAG_SIZE ;
				INIT_SEQ <=  DEFAULT_INIT_SEQ ;
				MSSize <= MAX_MSSize ;
			end
			CTRL_SEL:
			begin
				ctrl_s_axi_wready <= 1 ;
//				ctrl_s_axi_awready <= 0 ;
				REG_address	<= ctrl_s_axi_awaddr ;
				if(!sel_en)begin
				case(ctrl_s_axi_awaddr)
					32'h0000_0000:	sel<=SEL_MSSIZE;
					32'h0000_0001:	sel<=SEL_SND_PARAMETER ;
					32'h0000_0002:	sel<=SEL_RCV_PARAMETER ;
					32'h0000_0003:	sel<=SEL_FIGHT_SIZE ;
					32'h0000_0004:	sel<=SEL_INIT_SEQ ;
					32'h0000_0005:	sel<=SEL_CONNECT ;
					32'h0000_0006:	sel<=SEL_CLOSE	;
					default:
						sel	<= SEL_UNKNOW ;
				endcase
				end
				sel_en	<=	1 ;
			end
			CTRL_UDT_STATE:
			begin
				if(CTRL_state_reg != 32'hffff_ffff)
					CTRL_state_reg	<= udt_state ;
			
				state_ready <= 1 ;
					
			end
			CTRL_CONNECT: 
			begin
				ctrl_s_axi_wready  <= 0 ;
				ctrl_s_axi_awready <= 0 ;
				sel <= SEL_CONNECT ;
			end
			CTRL_CLOSE:
			begin
				ctrl_s_axi_wready <= 0 ;
				ctrl_s_axi_awready <= 0 ;
				
			end
			CTRL_MSSIZE:
			begin
				ctrl_s_axi_wready <= 0 ;
				ctrl_s_axi_awready <= 0 ;
				MSSize[31:24] <= ctrl_s_axi_wdata[31:24] & {8{ctrl_s_axi_wstrb[3]}};
				MSSize[23:16] <= ctrl_s_axi_wdata[23:16] & {8{ctrl_s_axi_wstrb[2]}};
				MSSize[15:8]  <= ctrl_s_axi_wdata[15:8] & {8{ctrl_s_axi_wstrb[1]}};
				MSSize[7:0]   <= ctrl_s_axi_wdata[7:0] & {8{ctrl_s_axi_wstrb[0]}};
				
			end
			CTRL_FLIGHT_SIZE:
			begin
				ctrl_s_axi_wready <= 0 ;
				ctrl_s_axi_awready <= 0 ;
				FlightFlagSize[31:24] <= ctrl_s_axi_wdata[31:24] & {8{ctrl_s_axi_wstrb[3]}};
				FlightFlagSize[23:16] <= ctrl_s_axi_wdata[23:16] & {8{ctrl_s_axi_wstrb[2]}};
				FlightFlagSize[15:8]  <= ctrl_s_axi_wdata[15:8] & {8{ctrl_s_axi_wstrb[1]}};
				FlightFlagSize[7:0]   <= ctrl_s_axi_wdata[7:0] & {8{ctrl_s_axi_wstrb[0]}};
				
			end
			CTRL_SND_BUFFER:
			begin
				ctrl_s_axi_wready <=  0 ;
				ctrl_s_axi_awready <= 0 ;
				Snd_Buffer_Size[31:24] <= ctrl_s_axi_wdata[31:24] & {8{ctrl_s_axi_wstrb[3]}};
				Snd_Buffer_Size[23:16] <= ctrl_s_axi_wdata[23:16] & {8{ctrl_s_axi_wstrb[2]}};
				Snd_Buffer_Size[15:8]  <= ctrl_s_axi_wdata[15:8] & {8{ctrl_s_axi_wstrb[1]}};
				Snd_Buffer_Size[7:0]   <= ctrl_s_axi_wdata[7:0] & {8{ctrl_s_axi_wstrb[0]}};
				
			end
			CTRL_REV_BUFFER:
			begin
				ctrl_s_axi_wready <=  0 ;
				ctrl_s_axi_awready <= 0 ;
				Rev_Buffer_Size[31:24] <= ctrl_s_axi_wdata[31:24] & {8{ctrl_s_axi_wstrb[3]}};
				Rev_Buffer_Size[23:16] <= ctrl_s_axi_wdata[23:16] & {8{ctrl_s_axi_wstrb[2]}};
				Rev_Buffer_Size[15:8]  <= ctrl_s_axi_wdata[15:8] & {8{ctrl_s_axi_wstrb[1]}};
				Rev_Buffer_Size[7:0]   <= ctrl_s_axi_wdata[7:0] & {8{ctrl_s_axi_wstrb[0]}};
				
			end
			CTRL_INIT_SEQ:
			begin
				ctrl_s_axi_wready <=  0 ;
				ctrl_s_axi_awready <= 0 ;
				INIT_SEQ[31:24] <= ctrl_s_axi_wdata[31:24] & {8{ctrl_s_axi_wstrb[3]}};
				INIT_SEQ[23:16] <= ctrl_s_axi_wdata[23:16] & {8{ctrl_s_axi_wstrb[2]}};
				INIT_SEQ[15:8]  <= ctrl_s_axi_wdata[15:8] & {8{ctrl_s_axi_wstrb[1]}};
				INIT_SEQ[7:0]   <= ctrl_s_axi_wdata[7:0] & {8{ctrl_s_axi_wstrb[0]}};
				
			end
			WRESP_IDLE:
			begin
				sel_en <= 0 ;
				ctrl_s_axi_wready <= 0 ;
			end
			WRESP_OK:
			begin
				sel_en <= 0 ;
				ctrl_s_axi_bvalid <= 1 ;
				ctrl_s_axi_bresp  <= 2'b00 ;
			end
			WRESP_DECERR:
			begin
				sel_en <= 0 ;
				ctrl_s_axi_bvalid <= 1 ;
				ctrl_s_axi_bresp  <= 2'b11 ;
			end
			WRESP_SLVERR:
			begin
				ctrl_s_axi_bvalid <= 1 ;
				ctrl_s_axi_bresp  <= 2'b11 ;
				case(sel)
					SEL_MSSIZE:
					begin
						MSSize <= 32'hffff_ffff ;
					end
					
					SEL_SND_PARAMETER:
					begin
						Snd_Buffer_Size <= 32'hffff_ffff ;
					end
					
					SEL_RCV_PARAMETER:
					begin
						Rev_Buffer_Size  <=32'hffff_ffff ;
					end
					
					SEL_FIGHT_SIZE:
					begin
						FlightFlagSize <=32'hffff_ffff ;
					end
					SEL_INIT_SEQ:
					begin
						INIT_SEQ <=32'hffff_ffff ;
					end
					SEL_CONNECT:
					begin
						CTRL_state_reg <=32'hffff_ffff ;
					end
					SEL_CLOSE:
					begin
						CTRL_state_reg <=32'hffff_ffff ;
					end
				endcase
			end
			CTRL_CLOSE2CORE:
			begin
				ctrl_s_axi_bvalid <= 0 ;
				Req_Close <= 1 ;
				CTRL_state_reg  <= CLOSING ;
			end
			CTRL_CONNECT2CORE:
			begin
				ctrl_s_axi_bvalid <= 0 ;
				Req_Connect <= 1 ;
				CTRL_state_reg  <= CONNECTING ;
			end
		endcase
	end
end
endmodule
