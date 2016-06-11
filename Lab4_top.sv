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

logic [11:0] state;  

//Inputs to s_mem 
logic [7:0] mem_address, mem_data; 
logic write_enable, mem_out, write_finish;  

//Task 1 
logic start_pop, end_pop, count_wren; 
logic [7:0] count_address; 

//Task 2a 
logic [23:0] secret_key;
logic start_encrypt, end_encrypt, encrypt_wren, read_mem;  
logic [7:0] encrypt_address, encrypt_data;  
assign secret_key = {14'b0, SW}; //Temporary, will need to change for task 3  


parameter idle = 12'b00000_0000000; 
parameter populate_RAM = 12'b00001_0000001; 
parameter encrypt_RAM = 12'b00010_0000010;
parameter finished = 12'b10000_0000000;   

assign start_pop = state[0]; 
assign start_encrypt = state[1]; 

//Task 1 
s_memory memory(
				.address(mem_address),
				.clock(CLOCK_50),
				.data(mem_data), 
				.wren(write_enable),
				.q(mem_out) 
				); 
				
MemoryPopulateCounter counter	(
								 .clk(CLOCK_50),
								 .count(count_address),
								 .start(start_pop), 
								 .wren(count_wren), 
								 .finish(end_pop)
								); 


//Task 2						
shuffle_array encrypt (
						.clk(CLOCK_50), 
						.start(start_encrypt), 
						.finish(end_encrypt), 
						.key(secret_key),  
						.read(read_mem), 
						.original_mem(mem_out), 
						.scrambled_mem(mem_out),  
						.write(encrypt_wren),
						.output_data(encrypt_data), 
						.outAddress(encrypt_address)
					  );
					  
//Main state machine 
always_ff @(posedge CLOCK_50) begin 
	case(state) 
	
	idle: if(KEY[0]) state <= populate_RAM; 
	
	populate_RAM: if(end_pop) state <= encrypt_RAM; 
	
	encrypt_RAM: if(end_encrypt) state <= finished; //change when additional states are added 
	
	finished: state <= idle; 
	
	default: state <= idle; 
	
	endcase 
end 

//Output logic 
always_ff @(posedge CLOCK_50) begin 
	case(state) 
		
	populate_RAM: begin 
				  mem_address <= count_address; 
				  mem_data <= count_address; 
				  write_enable <= count_wren; 
				  end 
				  
	encrypt_RAM: begin 
				 if(read_mem || encrypt_wren) mem_address <= encrypt_address; 
				 else mem_address <= 8'bx; //Do not read or write unless prompted 
				 mem_data <= encrypt_data; 
				 write_enable <= encrypt_wren; 
				 end 
				 
	default: begin 
			 mem_address <= mem_address; 
			 mem_data <= mem_data; 
			 write_enable <= write_enable; 
			 end 
	endcase 
end 

endmodule 