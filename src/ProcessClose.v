//%	@file	ProcessClose.v
//% @brief	本文件定义了ProcessClose 模块


//%	ProcessClose模块是处理CLOSE控制包

module	ProcessClose(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	output	[31:0]	udt_state_o ,						//%	连接状态
	output	state_valid_o ,								//%	连接状态有效
	input	state_ready_i ,								//% 连接状态就绪
	input	close_tvalid_i	,							//%	关闭控制包有效
	input	[63:0]	close_tdata_i		,					//%	关闭控制数据包
	input	[7:0]	close_tkeep_i		,					//%	关闭控制使能信号
	input	close_tlast_i				,					//%	关闭控制结束信号
	output	close_tready_o								//%	关闭控制就绪信号
);



endmodule