//%	@file	state2axis
//%	@brief	本文件定义了state2axis模块

//%		state2axis 主要根据udt socket状态改变用户AXIS的接口
//%	@details


module	state2axis
#(
	parameter	CONNECT	=	32'h0000_0001 ,
	parameter	CLOSE	=	32'h0000_0002	
)(
	input	tx_axis_aclk,								//% UDT传输数据-发送时钟信号
	input	tx_axis_aresetn,							//% UDT传输数据-发送复位信号（低有效）
	input	tx_axis_tvalid_i,								//%	UDT传输数据-发送数据有效
	input	tx_axis_tready_i,								//%	UDT传输数据-发送数据就绪
	input	tx_axis_tlast_i,								//%	UDT传输数据-发送数据包结束
	output	reg ready_o	,								//%	AXIS就绪
	
	input	core_clk,									//%	核心模块时钟
	input	core_rst_n,									//%	核心模块复位(低信号复位)
	input	[31:0]	udt_state_i,							//%	UDT状态
	input	state_valid_i							//% UDT状态改变
);
reg	reg_state ;
reg	core_fb1_state ;
reg	core_fb2_state ;


always	@(posedge tx_axis_aclk or negedge tx_axis_aresetn)
begin
	if(!tx_axis_aresetn)
	begin
		reg_state <= 0 ;
	end	else begin
		if(tx_axis_tvalid_i == tx_axis_tready_i)
			reg_state <= 1 ;
		else	if(tx_axis_tlast)
			reg_state <= 0 ;
	end
end

always	@(posedge	core_clk)
begin
	core_fb1_state <= 	reg_state ;
	core_fb2_state <=   core_fb1_state ;
end

reg	core_ready ;
always	@(posedge	core_clk	or	negedge	core_rst_n)
begin
	if( !core_rst_n )
		core_ready <= 0 ;
	if( core_fb1_state == 0 && udt_state == CLOSE)
		core_ready <= 0 ;
	else
		core_ready <= 1 ;
end

reg	core_fb1_ready ;

always @(posedge tx_axis_aclk )
begin
	core_fb1_ready <=	core_ready ;
	ready	<=	core_fb1_ready ;
end

endmodule