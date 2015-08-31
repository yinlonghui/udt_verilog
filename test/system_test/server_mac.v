module	server_mac(
	input	clk156 ,
	input	areset ,
	
	input	ref_200M ,
	input	core_rst_c ,

	output			mac_rx_axis_tready,
	input			mac_rx_axis_tvalid,
	input			mac_rx_axis_tlast,
	input  [ 7:0]	mac_rx_axis_tkeep,
	input  [63:0]	mac_rx_axis_tdata,	

	input			mac_tx_axis_tready,
	output			mac_tx_axis_tvalid,	
	output			mac_tx_axis_tlast,			
	output [ 7:0]	mac_tx_axis_tkeep,	
	output [63:0]	mac_tx_axis_tdata,
	output			finish ,
	output			err
);


wire	tx_axis_tvalid ;
wire	tx_axis_tready ;
wire	tx_axis_tlast	;
wire	[7:0]	tx_axis_tkeep	;
wire	[63:0]	tx_axis_tdata	;

wire	rx_axis_tvalid	;
wire	rx_axis_tready	;
wire	rx_axis_tlast	;
wire	[7:0]	rx_axis_tkeep;
wire	[63:0]	rx_axis_tdata;
wire	[31:0]	ctrl_s_axi_awaddr ;
wire	ctrl_s_axi_awvalid	;
wire	ctrl_s_axi_awready	;
wire	[31:0]	ctrl_s_axi_wdata	;
wire	[3:0]	ctrl_s_axi_wstrb	;
wire	ctrl_s_axi_wvalid	;
wire	ctrl_s_axi_wready	;
wire	[1:0]	ctrl_s_axi_bresp	;
wire	ctrl_s_axi_bvalid	;
wire	ctrl_s_axi_bready	;

wire	[31:0]	ctrl_s_axi_araddr ;
wire	ctrl_s_axi_arvalid	;
wire	ctrl_s_axi_arready	;
wire	[31:0]	ctrl_s_axi_rdata	;
wire	[1:0]	ctrl_s_axi_rresp	;
wire	ctrl_s_axi_rvalid	;
wire	ctrl_s_axi_rready	;

udt_top  udt_top(
    .areset         ( areset             ),
    .clk156         ( clk156             ),
    
    .core_clk       ( ref_200M          ),
    .core_rst_n     ( !core_rst_c         ),
    
    .user_clk       ( ref_200M  ),
    .user_rst_n     ( !core_rst_c ),
    
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tdata(tx_axis_tdata),
    
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tdata(rx_axis_tdata),
	
	.ctrl_s_axi_awaddr(ctrl_s_axi_awaddr),
    .ctrl_s_axi_awvalid(ctrl_s_axi_awvalid),
	.ctrl_s_axi_awready(ctrl_s_axi_awready) ,
	.ctrl_s_axi_wdata(ctrl_s_axi_wdata),
	.ctrl_s_axi_wstrb(ctrl_s_axi_wstrb),
	.ctrl_s_axi_wvalid(ctrl_s_axi_wvalid),
    .ctrl_s_axi_wready(ctrl_s_axi_wready) ,
	.ctrl_s_axi_bresp(ctrl_s_axi_bresp) ,
	.ctrl_s_axi_bvalid(ctrl_s_axi_bvalid) ,
	.ctrl_s_axi_bready(ctrl_s_axi_bready) ,
	.ctrl_s_axi_araddr(ctrl_s_axi_araddr) ,
	.ctrl_s_axi_arvalid(ctrl_s_axi_arvalid),
	.ctrl_s_axi_arready(ctrl_s_axi_arready) ,
	.ctrl_s_axi_rdata(ctrl_s_axi_rdata) ,
	.ctrl_s_axi_rresp(ctrl_s_axi_rresp) ,
	.ctrl_s_axi_rvalid(ctrl_s_axi_rvalid),
	.ctrl_s_axi_rready(ctrl_s_axi_rready),

    
    .mac_rx_axis_tready ( mac_rx_axis_tready ),
    .mac_rx_axis_tvalid ( mac_rx_axis_tvalid ),
    .mac_rx_axis_tlast  ( mac_rx_axis_tlast  ),
    .mac_rx_axis_tkeep  ( mac_rx_axis_tkeep  ),
    .mac_rx_axis_tdata  ( mac_rx_axis_tdata  ),

    .mac_tx_axis_tready ( mac_tx_axis_tready ),
    .mac_tx_axis_tvalid ( mac_tx_axis_tvalid ),
    .mac_tx_axis_tlast  ( mac_tx_axis_tlast  ),
    .mac_tx_axis_tkeep  ( mac_tx_axis_tkeep  ),
    .mac_tx_axis_tdata  ( mac_tx_axis_tdata  )
 );
 ctrl_reg	ctrl_inst(
 	.core_clk(ref_200M),
	.core_rst_n(!core_rst_c)	,

	.ctrl_s_axi_awaddr(ctrl_s_axi_awaddr),	
	.ctrl_s_axi_awvalid(ctrl_s_axi_awvalid),			
	.ctrl_s_axi_awready(ctrl_s_axi_awready),			
	.ctrl_s_axi_wdata(ctrl_s_axi_wdata),	
	.ctrl_s_axi_wstrb(ctrl_s_axi_wstrb),
	.ctrl_s_axi_wvalid(ctrl_s_axi_wvalid),			
	.ctrl_s_axi_wready(ctrl_s_axi_wready),			
	.ctrl_s_axi_bresp(ctrl_s_axi_bresp),	
	.ctrl_s_axi_bvalid(ctrl_s_axi_bvalid),			
	.ctrl_s_axi_bready(ctrl_s_axi_bready),			
	.ctrl_s_axi_araddr(ctrl_s_axi_araddr),	
	.ctrl_s_axi_arvalid(ctrl_s_axi_arvalid),			
	.ctrl_s_axi_arready(ctrl_s_axi_arready),			
	.ctrl_s_axi_rdata(ctrl_s_axi_rdata),	
	.ctrl_s_axi_rresp(ctrl_s_axi_rresp),	
	.ctrl_s_axi_rvalid(ctrl_s_axi_rvalid),			
	.ctrl_s_axi_rready(ctrl_s_axi_rready),
	.finish(finish),
	.err(err)
 
 
 );
endmodule