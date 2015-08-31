`timescale 1ps/1ps

module	udt_top_test(
    input   clk,
	input	clk_156 ,
	output	reg	finish	,
	output	reg	assert_err
) ;



wire [63:0] ch3_tx_axis_tdata;
wire [7:0]  ch3_tx_axis_tkeep;
wire        ch3_tx_axis_tvalid;
wire        ch3_tx_axis_tlast;
wire        ch3_tx_axis_tready;
wire [63:0] ch3_rx_axis_tdata;
wire [7:0]  ch3_rx_axis_tkeep;
wire        ch3_rx_axis_tvalid;
wire        ch3_rx_axis_tlast;
wire        ch3_rx_axis_tready;
logic	areset ;
logic	core_rst_c ;

task  ARESET();
int	i	=	50 ;
areset	=	0	;
while(i!=0)
begin
	@(posedge	clk_156);
	i	=	i - 1 ;
end
areset	=	1	;
i	=	10	;
while(i!=0)
begin
	@(posedge	clk_156);
	i	=	i - 1 ;
end
areset	=	0	;
endtask

task	CORE_RST();
int	i	=	50	;
core_rst_c	=	0	;
while(i!=0)
begin
	@(posedge	clk_156);
	i	=	i - 1 ;
end
core_rst_c	=	1	;
i	=	10	;
while(i!=0)
begin
	@(posedge	clk_156);
	i	=	i - 1 ;
end
core_rst_c	=	0	;
endtask
task	delay();
	int count = 10000 ;
	while(count != 0) 
	begin
		@(posedge	clk);
		count = count - 1 ;
	end
endtask

initial
begin
	core_rst_c	=	0 ;
	areset	=	0	;
	ARESET();
	CORE_RST();
    delay();
end

server_mac	dut_server_inst(

	.areset         ( areset             ),
    .clk156         ( clk156             ),
    
    .ref_200M       ( clk          ),
    .core_rst_c     ( core_rst_c         ),

    
    .mac_rx_axis_tready ( ch3_rx_axis_tready ),
    .mac_rx_axis_tvalid ( ch3_rx_axis_tvalid ),
    .mac_rx_axis_tlast  ( ch3_rx_axis_tlast  ),
    .mac_rx_axis_tkeep  ( ch3_rx_axis_tkeep  ),
    .mac_rx_axis_tdata  ( ch3_rx_axis_tdata  ),

    .mac_tx_axis_tready ( ch3_tx_axis_tready ),
    .mac_tx_axis_tvalid ( ch3_tx_axis_tvalid ),
    .mac_tx_axis_tlast  ( ch3_tx_axis_tlast  ),
    .mac_tx_axis_tkeep  ( ch3_tx_axis_tkeep  ),
    .mac_tx_axis_tdata  ( ch3_tx_axis_tdata  ),
	.finish(finish),
	.err(assert_err)

);

client_mac	dut_client_inst(
	.areset         ( areset             ),
    .clk156         ( clk156             ),
    
    .ref_200M       ( clk          ),
    .core_rst_c     ( core_rst_c         ),

    
    .mac_rx_axis_tready ( ch3_tx_axis_tready ),
    .mac_rx_axis_tvalid ( ch3_tx_axis_tvalid ),
    .mac_rx_axis_tlast  ( ch3_tx_axis_tlast  ),
    .mac_rx_axis_tkeep  ( ch3_tx_axis_tkeep  ),
    .mac_rx_axis_tdata  ( ch3_tx_axis_tdata  ),

    .mac_tx_axis_tready ( ch3_rx_axis_tready ),
    .mac_tx_axis_tvalid ( ch3_rx_axis_tvalid ),
    .mac_tx_axis_tlast  ( ch3_rx_axis_tlast  ),
    .mac_tx_axis_tkeep  ( ch3_rx_axis_tkeep  ),
    .mac_tx_axis_tdata  ( ch3_rx_axis_tdata  )



);

endmodule