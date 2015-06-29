//% @file   configure.v
//%	@brief	 本文件定义配置寄存器模块
//% @details 


//% 配置寄存器模块主要介于BRAM和用户AXI-LITE之间，用于用户使用UDT寄存器管理UDT
//% @details
//%	配置参数：
//%		1、配置状态寄存器标识为成功再进行2步骤
//%		2、检查是否已经UDT建立连接:
//%			2.1若已经建立连接，则将配置状态寄存器表示错误状态（连接）
//%			2.2 若未建立连接，则检查参数是否在正确的范围内
//%				2.2.1 若在正确的范围，则向写入相应的参数，然后将配置状态寄存器标识为成功配置
//%				2.2.2 若不在正确的范围，则将配置状态寄存器表示错误状态（越界）
//%	建立连接:
//%		-检查连接寄存器的状态：
//%			1、若UDT连接状态寄存器为正在连接或者连接成功状态，则将UDT连接状态寄存器改为连接失败，发送给Socket Manager关闭连接的操作
//%			2、若UDT连接状态寄存器为关闭状态或者未打开状态，将UDT连接状态寄存器改为正在连接状态，发送给Socket Manager打开连接的操作
//%	关闭连接：
//%			1、若UDT连接状态为关闭，则将UDT连接状态寄存器改为关闭失败
//%			2、若UDT连接状态为连接，向Socket Manager发送关闭连接操作，等待UDT关闭，更新连接寄存器标识为关闭
//%	读状态寄存器：
//%			AXI-LITE（读操作）直接读取BRAM
module    configure (
	input	ctrl_s_axi_aclk,							//% 用户-时钟信号
	input   ctrl_s_axi_aresetn,							//% 用户-复位信号
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
	
	input	[31:0]	ctrl_s_axi_awaddr,					//%	BRAM存储器-写地址信号
	input	ctrl_s_axi_awvalid,							//% BRAM存储器-写地址有效
	output	ctrl_s_axi_awready,							//%	BRAM存储器-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,					//%	BRAM存储器-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,					//%	BRAM存储器-写操作字节使能
	input	ctrl_s_axi_wvalid,							//%	BRAM存储器-写数据有效
	output	ctrl_s_axi_wready,							//%	BRAM存储器-写数据就绪
	output	[1:0]	ctrl_s_axi_bresp,					//%	BRAM存储器-写数据应答
	output	ctrl_s_axi_bvalid,							//%	BRAM存储器-写应答有效
	input	ctrl_s_axi_bready,							//%	BRAM存储器-写应答就绪
	input   [31:0]	ctrl_s_axi_araddr,					//% BRAM存储器-读地址信号
	input	ctrl_s_axi_arvalid,							//% BRAM存储器-读地址有效
	output	ctrl_s_axi_arready,							//% BRAM存储器-读地址就绪
	output  [31:0]	ctrl_s_axi_rdata,					//%	BRAM存储器-读操作数据
	output	[1:0]	ctrl_s_axi_rresp,					//%	BRAM存储器-读数据应答
	output	ctrl_s_axi_rvalid,							//%	BRAM存储器-读数据有效
	input	ctrl_s_axi_rready,							//%	BRAM存储器-读数据就绪
	
	input	[31:0]	udt_state ,							//%	连接状态
	input	state_valid,								//%	连接状态有效
	output	state_ready,								//%	连接状态就绪
);




endmodule