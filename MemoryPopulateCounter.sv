/*This module writes to s_mem by listening for a start signal, then outputing numbers 8'h00 to 8'hFF with wren turnt high.
 *It outputs a finish signal when done transmitting and returns to idle state
 */
module MemoryPopulateCounter(clk, count, wren, start, finish);

input clk, start;
output wren, finish;
output logic [7:0] count;

logic [3:0] state;

parameter idle = 4'b00_00;
parameter write = 4'b01_10;
parameter finished = 4'b10_01;

//output signals assigned to state bits
assign finish = state[0];
assign wren = state[1];

//state transition always block
always_ff@(posedge clk)
	case(state)
	idle: 
		begin
			if(start) state <= write;
		end
	
	write:
		begin
			if(count >= 8'hFF) state <= finished;
		end
	
	finished: state <= idle;
	
	default: state <= idle;
	
	endcase

//registered output
//TODO: maybe combine this with the state transition always block?
always_ff@(posedge clk)
	case(state)
	idle: count <= 0;
	write: count <= count + 1'b1;
	finished: count <= 0;
	default: count <= 0;
	
	endcase

endmodule
	
