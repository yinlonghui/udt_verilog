//%	@file	mutexValue.v
//%	@brief	本文件定义mutexValue模块

//%	mutexValue模块处理

module	mutexValue
#(
	parameter	WITDH	=	32 ,
	parameter	WR_NUM	=	4  ,
	parameter	RD_NUM  =	2
)(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	input	[WITDH*WR_NUM-1:0]		value_i ,			//%	写互斥值
	input	[WR_NUM-1:0]			valid_i ,			//%	写有效
	output	[WR_NUM-1:0]			ready_o ,			//% 写就绪
	output	[RD_NUM-1:0]			valid_o ,			//%	互斥值发生了改变
	input	[RD_NUM-1:0]			ready_i ,			//%	读就绪
	output	[RD_NUM*WITDH-1:0]		value_o				//%	读互斥值
);


endmodule