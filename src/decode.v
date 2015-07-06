//%	@file	decode.v
//%	@brief	���ļ�����decodeģ��
//%	@details

//%	��ģ�����Զ˵�UDP֡Э��
//% @details
//%		���ư���
//%		Handshake:
//%		Keep-live:
//%		NAK:
//%		ACK:
//%			Light-ACK
//%		ACK2:
//%		���ݰ���
//%				


module	decode(
	input	core_clk ,								//%	ʱ��
	input	core_rst_n ,							//%	��λ
	input	[C_S_AXI_DATA_WIDTH-1:0]	in_tdata,	//%	UDP���ݰ�
	input	[C_S_AXI_DATA_WIDTH/8-1:0]	in_tkeep,	//%	UDP�ֽ�ʹ��
	input	in_tvalid , 							//%	UDP����Ч
	output	reg	in_tready	,						//%	UDP������
	input	in_tlast	,							//%	UDP������
	
	output	reg	[C_S_AXI_DATA_WIDTH-1:0]	out_tdata ,	//%	�����
	output	reg	out_tlast ,								//%	���������
	output	reg	out_tvalid	,							//%	�������Ч
	output	reg	[C_S_AXI_DATA_WIDTH/8-1:0]	out_keep ,	//%	�����ʹ��
	input	out_tready,									//%	���������

	output	reg	Data_en	,								//%	������Ч
	output	reg	ACK_en	,								//%	ACK����Ч
	output	reg	ACK2_en	,								//%	ACK2����Ч
	output	reg	Keep_live_en ,							//%	Keep-live����Ч
	output	reg	NAK_en	,								//%	NAK����Ч
	output	reg	Handshake_en 							//%	���ְ���Ч

);

