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
logic [7:0] mem_address, mem_data, mem_out; 
logic write_enable, write_finish;  

//Task 1 
logic start_pop, end_pop, count_wren; 
logic [7:0] count_address; 

//Task 2a 
logic [23:0] secret_key;
logic start_encrypt, end_encrypt, encrypt_wren;  
logic [7:0] encrypt_address, encrypt_data;  
//assign secret_key = {14'b0, SW}; //Temporary, will need to change for task 3  
assign secret_key = 23'h000249; 
//Task 2b
/*
logic end_decrypt, write_ram;
logic [7:0] decrypted_data, rom_addr, decrypt_addr, decrypt_wren, echo_decrypt, ram_addr, ram_wren;

//Task 2b
logic end_decrypt, write_ram;
logic [7:0] decrypted_data, rom_addr, decrypt_addr, decrypt_wren, echo_decrypt, ram_addr, ram_wren;

*/
parameter idle = 12'b00000_0000000; 
parameter populate_RAM = 12'b00001_0000001; 
parameter encrypt_RAM = 12'b00010_0000010;
parameter decrypt_ROM = 12'b00011_0000100;
parameter finished = 12'b10000_0000000;   
//parameter read_test = 12'b11000_0000000;

assign start_pop = state[0]; 
assign start_encrypt = state[1]; 
assign start_decrypt = state[2];

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


//Task 2a
//fsm taking care of loop in 2a. Mod and swap						
shuffle_array encrypt (
						.clk(CLOCK_50), 
						.start(start_encrypt), 
						.finish(end_encrypt), 
						.key(secret_key),  
						//.original_mem(mem_out),
						//.scrambled_mem(mem_out),
						.in_data(mem_out), 
						.write(encrypt_wren),
						.output_data(encrypt_data), 
						.outAddress(encrypt_address), 
						.LED(LEDR[7:0]), 
						.press(!KEY[1]) 
					  );

//Task 2b
//fsm taking care of loop in 2b. Decrypt	  

/*simple_decrypt decrypt (
						.start(end_encrypt), 
						.finish(end_decrypt), 
						.clk(CLOCK_50), 
						.decrypted_data(decrypted_data), 
						.rom_addr(rom_addr), 
						.rom_data(rom_data), 
						.write_ram(write_ram), 
						.ram_addr(ram_addr), 
						.ram_data(ram_data), 
						.write_decrypted(decrypt_wren), 
						.out_addr(decrypt_addr)

						);*/


//32x8 rom containing secret message
/*rom secret_message	(
					.address(rom_addr),
					.clock(CLOCK_50),
					.q(rom_data)
					);*/

//32x8 ram containing decrypted message, q signal not connected to anything				
/*decrypted_ram (
				.address(decrypt_addr),
				.clock(CLOCK_50),
				.data(decrypted_data),
				.wren(decrypt_wren),
				.q(echo_decrypt)
				);*/
				  
//assign LEDR[7:0] = mem_out; 
//Main state machine 
always_ff @(posedge CLOCK_50) begin 
	case(state) 
	
	idle: if(!KEY[0]) state <= populate_RAM; 
	
	populate_RAM: if(end_pop) state <= encrypt_RAM;   
	
	encrypt_RAM: if(end_encrypt) state <= finished; 

	
	/*decrypt_ROM: if(end_decrypt) state <= finished; //change when additional states are added 

	
	decrypt_ROM: if(end_decrypt) state <= finished; //change when additional states are added */
	
	finished: state <= finished; 
	
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
				 mem_address <= encrypt_address; 
				 mem_data <= encrypt_data; 
				 write_enable <= encrypt_wren; 
				 end 
	
	/*decrypt_ROM: begin
				 mem_address <= ram_addr;
				 mem_data <= ram_data;
				 write_enable <= write_ram;
				 end*/
				 
	/*finished: begin 
			  mem_address <= 8'h2c; 
			  mem_data <= mem_data; 
			  write_enable <= 1'b0; 
			  end */
			 
	default: begin 
			 mem_address <= mem_address; 
			 mem_data <= mem_data; 
			 write_enable <= write_enable; 
			 end 
	endcase 
end 

endmodule 