
//% @file   udt_interface.v
//% @brief  本文件定义UDT接口模块.
//% @details  


//% 
//% @details   

module  udt_interface(
	input	ctrl_s_axi_aclk,			//% 控制寄存器-时钟信号
	input   ctrl_s_axi_aresetn,			//% 控制寄存器-复位信号
	input	[31:0]	ctrl_s_axi_awaddr,	//%	控制寄存器-写地址信号
	input	ctrl_s_axi_awvalid,			//% 控制寄存器-写地址有效
	output	ctrl_s_axi_awready,			//%	控制寄存器-写地址就绪
	input	[31:0]	ctrl_s_axi_wdata,	//%	控制寄存器-写操作数据
	input	[3:0]	ctrl_s_axi_wstrb,	//%	控制寄存器-写操作字节使能
	input	ctrl_s_axi_wvalid,			//%	控制寄存器-写数据有效
	output	ctrl_s_axi_wready,			//%	控制寄存器-写数据就绪
	output	[1:0]	ctrl_s_axi_bresp	//%	控制寄存器-写数据应答
	output	ctrl_s_axi_bvalid,			//%	控制寄存器-写应答有效
	input	ctrl_s_axi_bready,			//%	控制寄存器-写应答就绪
	input   [31:0]	ctrl_s_axi_araddr,	//% 控制寄存器-读地址信号
	input	ctrl_s_axi_arvalid,			//% 控制寄存器-读地址有效
	output	ctrl_s_axi_arready,			//% 控制寄存器-读地址就绪
	output  [31:0]	ctrl_s_axi_rdata,	//%	控制寄存器-读操作数据
	output	[1:0]	ctrl_s_axi_rresp,	//%	控制寄存器-读数据应答
	output	ctrl_s_axi_rvalid,			//%	控制寄存器-读数据有效
	input	ctrl_s_axi_rready,			//%	控制寄存器-读数据就绪

	input	tx_m_axis_aclk,				//%
	input	tx_m_axis_aresetn,
	input	tx_m_axis_tvalid,
	output	tx_m_axis_tready,
	input	[63:0]	tx_m_axis_tdata,
	input	[7:0]	tx_m_axis_tkeep,
	input	tx_m_axis_tlast,
	input	rx_s_axis_aclk
	input	rx_s_axis_aresetn
	output	rx_s_axis_tvalid
	input	rx_s_axis_tready
	output	rx_s_axis_tdata
	output	rx_s_axis_tkeep
	output	rx_s_axis_tlast


);

/*	fifo   asyc  fifo  
	
*/


udt   dut ( 
	.clk(clk),
	.rst(rst)
);
endmodule