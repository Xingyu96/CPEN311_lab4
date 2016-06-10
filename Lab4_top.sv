module Lab4_top (

input CLOCK_50,
input [3:0] KEY, 
input [9:0] SW, 
output [9:0] LEDR,
output [6:0] HEX0, 
output [6:0] HEX1, 
output [6:0] HEX2, 
output [6:0] HEX3, 
output [6:0] HEX4, 
output [6:0] HEX5

); 

wire [7:0] write_address, write_data; 
wire write_enable, mem_out, write_finish;  

s_memory memory(
				.address(write_address),
				.clock(CLOCK_50),
				.data(write_address),
				.wren(write_enable),
				.q(mem_out) 
				); 
				
MemoryPopulateCounter counter	(
								 .clk(CLOCK_50),
								 .count(write_address),
								 .start(KEY[0]), 
								 .wren(write_enable), 
								 .finish(write_finish)
								); 
								
endmodule 