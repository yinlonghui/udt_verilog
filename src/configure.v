//% @file   configure.v
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
		parameter	DEFAULT_SND_BUFFER_SIZE	=	8192 ,
		parameter	DEFAULT_REV_BUFFER_SIZE =   8192 ,
		parameter	DEFAULT_FLIGHT_FLAG_SIZE =	256000,
		parameter	MAX_MSSize	= 8000	,
		parameter	MAX_MEMORY_SIZE	=   1024*1024 ,
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
	output	ctrl_s_axi_awready,							//%	用户-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,					//%	用户-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,					//%	用户-写操作字节使能
	input	ctrl_s_axi_wvalid,							//%	用户-写数据有效
	output	ctrl_s_axi_wready,							//%	用户-写数据就绪
	output	[1:0]	ctrl_s_axi_bresp,					//%	用户-写数据应答
	output	ctrl_s_axi_bvalid,							//%	用户-写应答有效
	input	ctrl_s_axi_bready,							//%	用户-写应答就绪
	input   [31:0]	ctrl_s_axi_araddr,					//% 用户-读地址信号
	input	ctrl_s_axi_arvalid,							//% 用户-读地址有效
	output	ctrl_s_axi_arready,							//% 用户-读地址就绪
	output  [31:0]	ctrl_s_axi_rdata,					//%	用户-读操作数据
	output	[1:0]	ctrl_s_axi_rresp,					//%	用户-读数据应答
	output	ctrl_s_axi_rvalid,							//%	用户-读数据有效
	input	ctrl_s_axi_rready,							//%	用户-读数据就绪
	
	input	[31:0]	udt_state ,							//%	连接状态
	input	state_valid,								//%	连接状态有效
	output	reg	state_ready,							//%	连接状态就绪
	
	
	output	reg	Req_Connect ,							//%	连接请求
	input	Res_Connect ,								//% 连接回应
	
	output	reg	Req_Close	,							//%	关闭请求
	input	Res_Close	,								//%	关闭回应
	
	output	reg	user_closed	,							//%	关闭信号
	output	reg	user_valid	,							//%	关闭信号有效
	input	user_ready	,								//%	关闭信号就绪
	
	
	output	reg	[31:0]	Snd_Buffer_Size ,					//%	发送buffer大小
	output	reg	[31:0]	Rev_Buffer_Size	,					//%	接收buffer大小
	output	reg [31:0]	 FlightFlagSize ,					//%	最大流量窗口大小
	output	reg [31:0]	MSSize	,							//%	最大包大小
	output	reg	[31:0]	INIT_SEQ							//%	初始化序列号

);
/*			(Snd_Buffer_Size +   Snd_Buffer_Size)*MSSize +   2*m_iFlightFlagSize*sizeof(list) < DEFAULT_FLIGHT_FLAG_SIZE */





reg	[31:0]	CTRL_state_reg ;

parameter	RIGHT_INIT		= 32'h0000_0000 ;
parameter	OUT_SND_BUFFER 	= 32'h0000_0001 ;
parameter	OUT_REV_BUFFER 	= 32'h0000_0002 ;
parameter	OUT_FLIGHT_SIZE = 32'h0000_0003 ;
parameter	OUT_MMSIZE		= 32'h0000_0004 ;
parameter	INIT_ERR_OPEN	= 32'h0000_0005 ;
parameter	INIT_ERR_CLOSE	= 32'h0000_0006 ;
parameter	REPEAT_OPEN		= 32'h0000_0007 ;
parameter	REPEAT_CLOSE	= 32'h0000_0008 ;
parameter	UNOPEN_CLOSE	= 32'h0000_0009 ;


integer	CTRL_State , CTRL_Next_State ;


localparam	CTRL_IDLE = 1 , CTRL_INIT  = 2 , CTRL_CONNECT = 3, CTRL_SND_BUFFER  = 4 , CTRL_REV_BUFFER = 5 , CTRL_FLIGHT_SIZE = 6 ,
			CTRL_MSSIZE = 7 ,  CTRL_INIT_SEQ = 8 , CTRL_CLOSE  = 9 , READ_REG = 10 , LOAD_STATE = 11 ;

always@(posedge	ctrl_s_axi_aclk or negedge	ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)
		CTRL_State <=  CTRL_IDLE ;
	else
		CTRL_State <=  CTRL_Next_State ;
end

always@(*)
begin
	case(CTRL_State)
	
		CTRL_IDLE:
		begin
			if(ctrl_s_axi_awvalid)
				CTRL_Next_State = CTRL_INIT ;
			else
				CTRL_Next_State = CTRL_IDLE	;
		end
		CTRL_INIT:
		begin
			if(ctrl_s_axi_awvalid) 
			begin
				if(ctrl_s_axi_awaddr == 32'h0000_0000)
					CTRL_Next_State = CTRL_CONNECT ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0001)
					CTRL_Next_State = CTRL_SND_BUFFER ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0002)
					CTRL_Next_State = CTRL_REV_BUFFER ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0003)
					CTRL_Next_State = CTRL_FLIGHT_SIZE ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0004)
					CTRL_Next_State = CTRL_MSSIZE:
				else	if(ctrl_s_axi_awaddr == 32'h0000_0005)
					CTRL_Next_State = CTRL_INIT_SEQ ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0006)
					CTRL_Next_State = CTRL_CLOSE ;
				else	if(ctrl_s_axi_awaddr == 32'h0000_0007)
					CTRL_Next_State = READ_REG	;	
				else
					CTRL_Next_State =   CTRL_INIT ;
			end
			else
					CTRL_Next_State =   CTRL_INIT ;
		end
		
		CTRL_CONNECT:
		begin
			if(Res_Connect == 1)  //  ||  valid connect 
				CTRL_Next_State =   CTRL_INIT ;
			else
				CTRL_Next_State = CTRL_CONNECT ;		
		end
		CTRL_SND_BUFFER:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		CTRL_REV_BUFFER:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		CTRL_FLIGHT_SIZE:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		CTRL_MSSIZE:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		CTRL_INIT_SEQ:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		CTRL_CLOSE:
		begin
			if(Res_Close) //   ||  valid close
				CTRL_Next_State <= CTRL_INIT ;
			else
				CTRL_Next_State <=	CTRL_CLOSE ;
		end
		READ_REG:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end
		LOAD_STATE:
		begin
			CTRL_Next_State <=  CTRL_INIT ;
		end

	default:
	begin
		CTRL_Next_State = 'bx ;
	end
end





always@(posedge ctrl_s_axi_aclk or negedge ctrl_s_axi_aresetn)
begin
	if(!ctrl_s_axi_aresetn)	begin
		
		Snd_Buffer_Size <=  DEFAULT_SND_BUFFER_SIZE ;
		Rev_Buffer_Size <=  DEFAULT_REV_BUFFER_SIZE ;
		FlightFlagSize  <=  DEFAULT_FLIGHT_FLAG_SIZE ;
		MSSize	<=   MAX_MSSize ;
		INIT_SEQ <= DEFAULT_INIT_SEQ  ;
		CTRL_state_reg <= RIGHT_INIT ;
	end
	else
		case(CTRL_Next_State)
		begin
			
		end
		
		
		
		endcase
	end
	

end

endmodule