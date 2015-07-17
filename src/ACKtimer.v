//%	@file	ACKtimer.v
//%	@brief	本文件定义ACKtimer模块

//%	ACKtimer模块是ACK定时器
//%	@details	
//%		ACK定时器用于触发ACK事件.当前时间大于下次ACK发送时间,就进入处理ACK事件
//%		1、在接收端查找接收到的所有包之前的序列号：如果接收端丢失链表是空的，ACK序列号设置为LRSN+1；否则，就是在接收端丢失链表里的最小序列号。
//%		2、如果，ACK序列号等于已经被ACK2应答的最大ACK序列号，或者等于上次应答的ACK序列号并且两次应答包之间的时间间隔小于2个RTT，停止（不发送应答包）。
//%		3、分配给当前应答一个唯一的增长的ACK序列号。将RTT、RTT偏差和流量窗口大小(可用的接收端缓冲区大小)封装入ACK控制包。如果ACK定时器未触发该ACK事件，发送该ACK控制包，然后停止。
//%		4、记录当前的ACK序列号，ACK号和ACK被发送的时间。并且将ACK号和ACK被发送的时间记录进ACK历史窗口里。


module	ACKtimer(
	input	core_clk	,	//%	时钟信号
	input	core_rst_n	,	//%	时钟复位信号(低有效)
	
	input	[63:0]	currtime	,	//当前时间
	
	input			ACKInt_i	,		//	ACK 发送周期
	input			ACKInt_valid_i	,	//	ACK	发送周期 有效信号	
	output			ACKInt_ready_o	,	//	ACK	发送周期 就绪信号
	
	input			[31:0]	iniNextACKTime_i,	
	input			iniNextACKTime_valid_i,		
	output			iniNextACKTime_ready_o,
	
	output	getFirstLostSeq_ready_o	,		//%	获取第一个丢失序列就绪信号
	input	getFirstLostSeq_valid_i ,		//%	获取第一个丢失序列有效信号
	input	[31:0]	LossSeq_o	,			//%	获取第一个丢失序列号
	
	
	input	[31:0]	RcvLastAckAck_i	,		//%	接收端 最后发送ACK2（数据）序列号
	input	RcvLastAckAck_valid_i	,		//%	接收端 最后发送ACK2（数据）序列号有效信号


	input	RTT_i	,
	input	RTT
	
	
	
);


reg		[31:0] m_ullNextACKTime

endmodule