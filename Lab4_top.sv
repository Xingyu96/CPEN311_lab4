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
//assign secret_key = 23'h000249; 

//Task 2b
logic start_decrypt, end_decrypt, write_ram, decrypt_wren;
logic [7:0] rom_addr, rom_data, ram_addr, ram_data, decrypted_data, decrypt_addr, echo_decrypt;

//Task 3 
logic start_decode, success, failure; 
logic [7:0] decode_addr, decrypted_address; 
logic secret_key_flag; 

assign secret_key[23:22] = 2'b0; 

parameter idle = 12'b00000_0000000; 
parameter init_secret_key = 12'b00001_0000000; 
parameter populate_RAM = 12'b00010_0000001; 
parameter encrypt_RAM = 12'b00011_0000010;
parameter decrypt_ROM = 12'b00100_0000100;
parameter decode = 12'b00101_0001000;
parameter inc_secret_key = 12'b00110_0000000;  
parameter code_decrypted = 12'b10000_0000000; 
parameter decrypt_failed = 12'b01000_0000000; 

parameter max_key = 22'h3FFFFF; //Maximum value represented by 21 bits 


assign start_pop = state[0]; 
assign start_encrypt = state[1]; 
assign start_decrypt = state[2];
assign start_decode = state[3]; 

SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst0(.ssOut(HEX0), .nIn(secret_key[3:0]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst1(.ssOut(HEX1), .nIn(secret_key[7:4]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst2(.ssOut(HEX2), .nIn(secret_key[11:8]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst3(.ssOut(HEX3), .nIn(secret_key[15:12]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst4(.ssOut(HEX4), .nIn(secret_key[19:16]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst5(.ssOut(HEX5), .nIn(secret_key[23:20]));


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
						.outAddress(encrypt_address)
						
					  );

//Task 2b
//fsm taking care of loop in 2b. Decrypt	  

simple_decrypt decrypt (
						.start(start_decrypt), 
						.finish(end_decrypt), 
						.clk(CLOCK_50),  
						.rom_addr(rom_addr), 
						.rom_data(rom_data), 
						.write_ram(write_ram), 
						.ram_addr(ram_addr), 
						.ram_data(mem_out), 
						.ram_data_out(ram_data), 
						.decrypted_data(decrypted_data),
						.write_decrypted(decrypt_wren), 
						.decrypt_addr(decrypted_address)

						);


//32x8 rom containing secret message
rom secret_message	(
					.address(rom_addr),
					.clock(CLOCK_50),
					.q(rom_data)
					);

//32x8 ram containing decrypted message			
decrypted_ram ram2  (
					.address(decrypt_addr),
					.clock(CLOCK_50),
					.data(decrypted_data),
					.wren(decrypt_wren),
					.q(echo_decrypt)
					);
					
decode_rc4 read		(
					.clk(CLOCK_50), 
					.start(start_decode), 
					.success(success), 
					.failure(failure), 
					.data(echo_decrypt),
					.address(decode_addr) 
					); 
				  

//Main state machine 
always_ff @(posedge CLOCK_50) begin 
	case(state) 
	
	idle: if(!KEY[0]) state <= init_secret_key; 
	
	init_secret_key: state <= populate_RAM; 
	
	populate_RAM: if(end_pop) state <= encrypt_RAM;   
	
	encrypt_RAM: if(end_encrypt) state <= decrypt_ROM; 

	decrypt_ROM: if(end_decrypt) state <= decode; 

	decode: if(success) state <= code_decrypted; 
			else if (failure) state <= inc_secret_key; 
			
	inc_secret_key: if (secret_key_flag) state <= decrypt_failed;
					else state <= populate_RAM; 

	decrypt_failed: state <= decrypt_failed; 
	
	code_decrypted: state <= code_decrypted; 
	
	default: state <= idle; 
	
	endcase 
end 

//Output logic 
always_ff @(posedge CLOCK_50) begin 
	case(state) 
	
	init_secret_key: begin 
						mem_address <= mem_address; 
						mem_data <= mem_data; 
						write_enable <= write_enable; 
						secret_key[21:0] <= 22'b0; 
						decrypt_addr <= decrypt_addr; 
						secret_key_flag <= 1'b0; 
						LEDR <= 10'b0; 
					 end 
		
	populate_RAM: begin 
				  mem_address <= count_address; 
				  mem_data <= count_address; 
				  write_enable <= count_wren; 
				  secret_key[21:0] <= secret_key[21:0]; 
				  decrypt_addr <= decrypt_addr; 
				  secret_key_flag <= secret_key_flag; 
				  LEDR <= LEDR; 
				  end 
				  
	encrypt_RAM: begin 
				 mem_address <= encrypt_address; 
				 mem_data <= encrypt_data; 
				 write_enable <= encrypt_wren; 
				 secret_key[21:0] <= secret_key[21:0];  
				 decrypt_addr <= decrypt_addr; 
				 secret_key_flag <= secret_key_flag; 
				 LEDR <= LEDR; 
				 end 
	
	decrypt_ROM: begin
				 mem_address <= ram_addr;
				 mem_data <= ram_data;
				 write_enable <= write_ram;
				 secret_key[21:0] <= secret_key[21:0]; 
				 decrypt_addr <= decrypted_address; 
				 secret_key_flag <= secret_key_flag; 
				 LEDR <= LEDR; 
				 end
	
	decode: 	begin
				 mem_address <= mem_address; 
				 mem_data <= mem_data; 
				 write_enable <= write_enable; 
				 secret_key[21:0] <= secret_key[21:0]; 
				 decrypt_addr <= decode_addr; 
				 secret_key_flag <= secret_key_flag; 
				 LEDR <= LEDR; 
				end 
				
	inc_secret_key: begin 
					 mem_address <= mem_address; 
					 mem_data <= mem_data; 
					 write_enable <= write_enable; 
					 secret_key[21:0] <= secret_key[21:0] + 22'd1; 
					 decrypt_addr <= decrypt_addr; 
					 if (secret_key[21:0] == max_key) secret_key_flag <= 1'b1; 
					 else secret_key_flag <= 1'b0; 
					 LEDR <= LEDR; 
					end 
					
	decrypt_failed: begin 
					 mem_address <= mem_address; 
					 mem_data <= mem_data; 
					 write_enable <= write_enable; 
					 secret_key[21:0] <= secret_key[21:0]; 
					 decrypt_addr <= decrypt_addr; 
					 secret_key_flag <= secret_key_flag; 
					 LEDR <= 10'b00000_00001;  
					 end 
					 
	code_decrypted: begin 
					 mem_address <= mem_address; 
					 mem_data <= mem_data; 
					 write_enable <= write_enable; 
					 secret_key[21:0] <= secret_key[21:0]; 
					 decrypt_addr <= decrypt_addr; 
					 secret_key_flag <= secret_key_flag; 
					 LEDR <= 10'b00000_00010;  
					 end  		
	default: begin 
			 mem_address <= mem_address; 
			 mem_data <= mem_data; 
			 write_enable <= write_enable; 
			 secret_key[21:0] <= secret_key[21:0]; 
			 decrypt_addr <= decrypt_addr; 
			 secret_key_flag <= secret_key_flag; 
			 LEDR <= LEDR; 
			 end 
	endcase 
end 

endmodule 