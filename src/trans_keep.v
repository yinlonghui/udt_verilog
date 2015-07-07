//%	@file	trans_keep.v
//%	@brief	本文件定义trans_keep模块
//%	@details

//%	本模块针对UDP帧keep是反过来的，所编写翻转模块
//% @details


module	trans_keep
(
	input	core_clk ,			//%	时钟信号
	
	input	[63:0]	in_tdata ,	//%	翻转前数据包
	input	[7:0]	in_tkeep ,	//%	翻转前数据使能信号
	input	in_tvalid , 		//%	翻转前数据有效信号
	output	reg	in_tready	,	//%	翻转前数据就绪信号
	input	in_tlast	,		//%	翻转前数据包结束信号
	
	output	reg	[63:0]	out_tdata ,	//%	翻转后数据包
	output	reg	out_tlast ,			//%	翻转后数据使能信号
	output	reg	out_tvalid	,		//%	翻转后数据有效信号
	output	reg	[7:0]	out_keep ,	//%	翻转后数据就绪信号
	input	out_tready				//%	翻转后数据包结束信号
);

always@(*)
begin
	out_keep[7]  =  in_tkeep[0] ;
	out_keep[6]  =  in_tkeep[1] ;
	out_keep[5]  =  in_tkeep[2] ;
	out_keep[4]  =  in_tkeep[3] ;
	out_keep[3]  =  in_tkeep[4] ;
	out_keep[2]  =  in_tkeep[5] ;
	out_keep[1]  =  in_tkeep[6] ;
	out_keep[0]  =  in_tkeep[7] ;

	out_tdata[7:0]  = in_tdata[63:56];
	out_tdata[15:8]  = in_tdata[55:48];
	out_tdata[23:16]  = in_tdata[47:40];
	out_tdata[31:24]  = in_tdata[39:32];
	out_tdata[39:32]  = in_tdata[31:24];
	out_tdata[47:40]  = in_tdata[23:16];
	out_tdata[55:48]  = in_tdata[15:8];
	out_tdata[63:56]  = in_tdata[7:0];
	in_tready = out_tready ;
	out_tlast = in_tlast ;
	out_tvalid = in_tvalid ;
end

endmodule