//%	@file	trans_keep.v
//%	@brief	���ļ�����trans_keepģ��
//%	@details

//%	��ģ�����UDP֡keep�Ƿ������ģ�����д��תģ��
//% @details


module	trans_keep
#(
	parameter	C_S_AXI_DATA_WIDTH = 64 
)
(
	input	core_clk ,
	
	input	[C_S_AXI_DATA_WIDTH-1:0]	in_tdata ,
	input	[C_S_AXI_DATA_WIDTH/8-1:0]	in_tkeep ,
	input	in_tvalid , 
	output	reg	in_tready	,
	input	in_tlast	,
	
	output	reg	[C_S_AXI_DATA_WIDTH-1:0]	out_tdata ,
	output	reg	out_tlast ,
	output	reg	out_tvalid	,
	output	reg	[C_S_AXI_DATA_WIDTH/8-1:0]	out_keep ,
	input	out_tready
);

always@(*)
begin
	out_keep = in_tkeep ;
	in_tready = out_tready ;
	out_tlast = in_tlast ;
	out_tdata = in_tdata ;
	out_tvalid = in_tvalid ;
end

endmodule