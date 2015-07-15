//%	@file	ProcessClose.v
//% @brief	本文件定义了ProcessClose 模块


//%	ProcessClose模块是处理CLOSE控制包

//%	step1:	确定数据包AXI-STREAM信号是否还有数据，若有的话，先读取完数据到last信号后，不再接收数据。若没有数据进入step2
//%	step2:	确定发送缓存是否已经发送完全，若没有，等数据数据完成后进入Step3

module	ProcessClose(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	

	
	input	close_tvalid_i	,							//%	关闭控制包有效
	input	[63:0]	close_tdata_i		,					//%	关闭控制数据包
	input	[7:0]	close_tkeep_i		,					//%	关闭控制使能信号
	input	close_tlast_i				,					//%	关闭控制结束信号
	output	close_tready_o				,				//%	关闭控制就绪信号
	input	SND_BUFFER_EMPTY_i	,		//%	发送缓冲为空
	input	REV_BUFFER_EMPTY_i			//%	接瘦缓冲为空
);



endmodule