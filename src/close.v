﻿//%	@file	close.v
//%	@brief	本文件定义close模块


//%			
//%	@details	关闭连接操作
//%	step1:	确定数据包AXI-STREAM信号是否还有数据，若有的话，先读取完数据到last信号后，不再接收数据。若没有数据进入step2
//%	step2:	确定发送缓存是否已经发送完全，若没有，等数据数据完成后进入Step3
//%	step3:	发送关闭信号


module(
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	
	input			close_user_req_tvalid,				//%	关闭请求信号有效(用户发起)
	output			close_req_tready,					//%	关闭请求信号就绪(用户发起)

	input			axis_tvalid	,
	input			axis_tready	,
);



end