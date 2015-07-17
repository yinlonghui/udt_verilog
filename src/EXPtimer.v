//%	@file	EXPtimer.v
//%	@brief	本文件定义EXPtimer模块

//%	EXPtimer模块是EXP包计数器
//%	@detail
//%	EXP定时器的事件处理流程：
//%	1 将所有未应答的包，追加到发送端丢失链表里。
//%	2 如果3分钟已经流逝，或者ExpCount > 16并且自从上次ExpCount复位为1后又流逝了至少3秒时，关闭UDT连接，然后退出。
//%	3 如果发送端丢失链表是空的，发送一个Keep-alive控制包给对等实体。
//%	4 ExpCount自增1。


module	EXPtimer(
	input	core_clk	,	//%	时钟信号
	input	core_rst_n	,	//%	时钟复位信号(低有效)

);




endmodule