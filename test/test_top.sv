`timescale 1ps/1ps

module	test_top;
parameter   TEST_NUM    =   32'd3 ;
wire    [3:0]	finish ;
wire    [3:0]     err ;
logic	clk ;
logic	clk_156 ;

configure_top	dut1(clk ,finish[0],err[0]);
udt_top_test	dut2(clk , clk_156 ,finish[1],err[1]);
decode_top      dut3(clk,  finish[2]    ,   err[2]);
listen_top		dut4(clk,  finish[3]    ,   err[3]);

localparam  ONE_NS      = 1000;
localparam  PER = 5*ONE_NS; 
localparam	PER_SFP		=  6.4*ONE_NS ;
    
initial	begin
    clk	=	0;
    forever	clk = #(PER/2) ~clk;
end

initial	begin
	clk_156	= 0 ;
	forever	clk_156 = #(PER_SFP) ~clk_156 ;
end

initial
begin
#(PER*1000) ;
while( finish != 4'b1111 &&  err == 4'b0000) begin
	@(posedge   clk);
end
$finish ; 
end

endmodule