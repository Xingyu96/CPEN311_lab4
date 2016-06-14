
//module to perform task 2b, outputs decrypted message
module simple_decrypt(start, finish, clk, rom_addr, rom_data, write_ram, ram_addr, ram_data, ram_data_out, decrypted_data, write_decrypted, decrypt_addr);

input clk, start;
input logic [7:0] rom_data, ram_data;
output write_ram, finish, write_decrypted;
output logic [7:0] rom_addr, ram_addr, ram_data_out, decrypt_addr, decrypted_data; 

logic [7:0] state;
logic [7:0] i, j, S_i, S_j, encrypted, f, k, xor_done;

parameter idle = 8'b00000_000; 
parameter init_vals = 8'b00001_000; 
parameter check_k = 8'b00010_000; 
parameter increment_i = 8'b00011_000; 
parameter set_address_i_read = 8'b00100_000; 
parameter wait_1a = 8'b00101_000; 
parameter wait_1b = 8'b00110_000; 
parameter read_s_i = 8'b00111_000; 
parameter j_plus_S_i = 8'b01000_000; 
parameter set_address_j_read = 8'b01001_000; 
parameter wait_2a = 8'b01010_000; 
parameter wait_2b = 8'b01011_000; 
parameter read_s_j = 8'b01100_000; 
parameter prep_s_i = 8'b01101_000; 
parameter write_addr_j = 8'b01110_001; //Write to s_mem 
parameter prep_s_j = 8'b01111_000; 
parameter write_addr_i = 8'b10000_001; //Write to s_mem 
parameter s_i_plus_s_j = 8'b10001_000; 
parameter wait_3a = 8'b10010_000; 
parameter wait_3b = 8'b10011_000; 
parameter read_f = 8'b10100_000; 
parameter set_address_k_read = 8'b10101_000; 
parameter wait_4a = 8'b10110_000; 
parameter wait_4b = 8'b10111_000; 
parameter read_encrypted = 8'b11000_000; 
parameter XOR_f_encrypted = 8'b11001_000; 
parameter prep_write_decrypted = 8'b11010_000; 
parameter write_to_decrypted = 8'b11011_100; //Write to decrypted ram 
parameter increment_k = 8'b11100_000; 
parameter finished = 8'b11101_010; 

//output signals assigned to state bits
assign write_ram = state[0];
assign finish = state[1];
assign write_decrypted = state[2];

//Next state logic 
always_ff @(posedge clk) begin 
	case(state) 
	
		idle: 				  if (start) state <= init_vals;  
		init_vals:       	  state <= check_k; 
		check_k: 			  if (k>8'd31) state <= finished; 
							  else state <= increment_i; 
		increment_i: 		  state <= set_address_i_read; 
		set_address_i_read:   state <= wait_1a; 
		wait_1a: 			  state <= wait_1b; 
		wait_1b: 			  state <= read_s_i; 
		read_s_i: 			  state <= j_plus_S_i; 
		j_plus_S_i: 		  state <= set_address_j_read;
		set_address_j_read:   state <= wait_2a; 
		wait_2a: 			  state <= wait_2b; 
		wait_2b: 			  state <= read_s_j; 
		read_s_j: 			  state <= prep_s_i; 
		prep_s_i: 			  state <= write_addr_j; 
		write_addr_j: 		  state <= prep_s_j; 
		prep_s_j: 			  state <= write_addr_i; 
		write_addr_i: 		  state <= s_i_plus_s_j; 
		s_i_plus_s_j:         state <= wait_3a; 
		wait_3a: 			  state <= wait_3b; 
		wait_3b: 			  state <= read_f; 
		read_f: 			  state <= set_address_k_read; 
		set_address_k_read:   state <= wait_4a; 
		wait_4a: 			  state <= wait_4b; 
		wait_4b: 			  state <= read_encrypted; 
		read_encrypted: 	  state <= XOR_f_encrypted; 
		XOR_f_encrypted:	  state <= prep_write_decrypted; 
		prep_write_decrypted: state <= write_to_decrypted; 
		write_to_decrypted:   state <= increment_k; 
		increment_k:          state <= check_k; 
		finished: 			  state <= idle; 
		
		default: state <= idle; 
	endcase 
end 

//Output logic 		
always_ff @(posedge clk) begin 
	case(state) 
	
	//Initialize i, j, k to 0
	init_vals: begin 
				i <= 8'd0; ///////////////////////
				j <= 8'd0; ///////////////////////
				k <= 8'd0; ///////////////////////
				ram_addr <= ram_addr; 
				S_i <= S_i; 
				S_j <= S_j; 
				ram_data_out <= ram_data_out; 
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
			   end 
	
	//i = i + 1
	increment_i: begin 
					i <= i + 8'd1; ///////////////////////
					j <= j; 
					k <= k; 
					ram_addr <= ram_addr; 
					S_i <= S_i; 
					S_j <= S_j; 
					ram_data_out <= ram_data_out; 
					f <= f; 
					rom_addr <= rom_addr; 
					encrypted <= encrypted; 
					xor_done <= xor_done; 
					decrypted_data <= decrypted_data; 
					decrypt_addr <= decrypt_addr;
				end 
	
	//Set address to read s[i] 
	set_address_i_read: begin 
							i <= i; 
							j <= j; 
							k <= k; 
							ram_addr <= i; ///////////////////////
							S_i <= S_i; 
							S_j <= S_j; 
							ram_data_out <= ram_data_out; 
							f <= f; 
							rom_addr <= rom_addr; 
							encrypted <= encrypted; 
							xor_done <= xor_done; 
							decrypted_data <= decrypted_data; 
							decrypt_addr <= decrypt_addr;
						end 
	//Read s[i] 				
	read_s_i: begin 
				i <= i; 
				j <= j; 
				k <= k; 
				ram_addr <= ram_addr; 
				S_i <= ram_data; ///////////////////////
				S_j <= S_j; 
				ram_data_out <= ram_data_out; 
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr; 
			 end 
	
	//j = j + s[i] 
	j_plus_S_i: begin
				i <= i;
				j <= j + S_i; ///////////////////////
				k <= k; 
				ram_addr <= ram_addr; 
				S_i <= S_i; 
				S_j <= S_j; 
				ram_data_out <= ram_data_out; 
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
				end 
				 
	//Prep to read address j 
	set_address_j_read: begin 
						i <= i; 
						j <= j; 
						k <= k; 
						ram_addr <= j; ///////////////////////
						S_i <= S_i; 
						S_j <= S_j; 
						ram_data_out <= ram_data_out; 
						f <= f; 
						rom_addr <= rom_addr; 
						encrypted <= encrypted; 
						xor_done <= xor_done; 
						decrypted_data <= decrypted_data; 
						decrypt_addr <= decrypt_addr;
						end 	
	
	//Read s[j] 
	read_s_j: begin 
				i <= i; 
				j <= j; 
				k <= k; 
				ram_addr <= ram_addr; 
				S_i <= S_i; 
				S_j <= ram_data; ///////////////////////
				ram_data_out <= ram_data_out; 
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
				end 
				
	//Write s[i] to j
	prep_s_i: begin 
				i <= i; 
				j <= j; 
				k <= k; 
				ram_addr <= j; ///////////////////////
				S_i <= S_i; 
				S_j <= S_j; 
				ram_data_out <= S_i; ///////////////////////
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
			  end 
	
	//Write s[j] to i
	prep_s_j: begin 
				i <= i; 
				j <= j; 
				k <= k;
				ram_addr <= i; ///////////////////////
				S_i <= S_i; 
				S_j <= S_j; 
				ram_data_out <= S_j; ///////////////////////
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
			  end 
	
	//read s[s[i] + s[j]]
	s_i_plus_s_j: begin 
					i <= i; 
					j <= j; 
					k <= k;
					ram_addr <= S_i + S_j; ///////////////////////
					S_i <= S_i; 
					S_j <= S_j; 
					ram_data_out <= ram_data_out; 
					f <= f; 
					rom_addr <= rom_addr; 
					encrypted <= encrypted; 
					xor_done <= xor_done; 
					decrypted_data <= decrypted_data; 
					decrypt_addr <= decrypt_addr;
				  end 
	
	//read into f 			  
	read_f: begin 
			i <= i; 
			j <= j; 
			k <= k; 
			ram_addr <= ram_addr; 
			S_i <= S_i; 
			S_j <= S_j; 
			ram_data_out <= ram_data_out;
			f <= ram_data; ///////////////////////
			rom_addr <= rom_addr; 
			encrypted <= encrypted; 
			xor_done <= xor_done; 
			decrypted_data <= decrypted_data; 
			decrypt_addr <= decrypt_addr;
			end 
			
	//read encrypted[k]
	set_address_k_read: begin 
						i <= i; 
						j <= j; 
						k <= k; 
						ram_addr <= ram_addr; 
						S_i <= S_i; 
						S_j <= S_j; 
						ram_data_out <= ram_data_out; 
						f <= f; 
						rom_addr <= k; ///////////////////////
						encrypted <= encrypted; 
						xor_done <= xor_done; 
						decrypted_data <= decrypted_data; 
						decrypt_addr <= decrypt_addr;
						end 
		
	//read encrypted[k]
	read_encrypted: begin 
					i <= i; 
					j <= j; 
					k <= k; 
					ram_addr <= ram_addr; 
					S_i <= S_i; 
					S_j <= S_j; 
					ram_data_out <= ram_data_out; 
					f <= f; 
					rom_addr <= rom_addr;
					encrypted <= rom_data; ///////////////////////
					xor_done <= xor_done; 
					decrypted_data <= decrypted_data; 
					decrypt_addr <= decrypt_addr;
					end 
	
	//f^encrypted[k]
	XOR_f_encrypted: begin 
						i <= i; 
						j <= j; 
						k <= k; 
						ram_addr <= ram_addr; 
						S_i <= S_i; 
						S_j <= S_j; 
						ram_data_out <= ram_data_out; 
						f <= f; 
						rom_addr <= rom_addr; 
						encrypted <= encrypted; 
						xor_done <= f^encrypted; /////////////////////// 
						decrypted_data <= decrypted_data; 
						decrypt_addr <= decrypt_addr;
					end 
	
	//Write f^encrypted[k] to decrypt[k]
	prep_write_decrypted: begin 
							i <= i; 
							j <= j; 
							k <= k; 
							ram_addr <= ram_addr; 
							S_i <= S_i; 
							S_j <= S_j; 
							ram_data_out <= ram_data_out; 
							f <= f; 
							rom_addr <= rom_addr; 
							encrypted <= encrypted; 
							xor_done <= xor_done; 
							decrypted_data <= xor_done; ///////////////////////
							decrypt_addr <= k; ///////////////////////
						  end 
	//k = k + 1 
	increment_k: begin 
					i <= i; 
					j <= j;
					k <= k + 8'd1; ///////////////////////
					ram_addr <= ram_addr; 
					S_i <= S_i; 
					S_j <= S_j; 
					ram_data_out <= ram_data_out; 
					f <= f; 
					rom_addr <= rom_addr; 
					encrypted <= encrypted; 
					xor_done <= xor_done; 
					decrypted_data <= decrypted_data; 
					decrypt_addr <= decrypt_addr;
				end 
				
	default: begin 
				i <= i; 
				j <= j; 
				k <= k; 
				ram_addr <= ram_addr; 
				S_i <= S_i; 
				S_j <= S_j; 
				ram_data_out <= ram_data_out; 
				f <= f; 
				rom_addr <= rom_addr; 
				encrypted <= encrypted; 
				xor_done <= xor_done; 
				decrypted_data <= decrypted_data; 
				decrypt_addr <= decrypt_addr;
			 end 
	endcase 

end 
		
endmodule

//parameters
/*
parameter idle = 				8'b00000_000;
parameter increment_i = 		8'b00001_000;
parameter fetchS_i = 			8'b00010_000;
parameter read_s1 = 			8'b00011_000;
parameter j_plus_S_i = 			8'b00100_000;
parameter fetchS_j = 			8'b00101_000;
parameter wait_s2 = 			8'b00110_000;
parameter write_Si_to_Sj = 		8'b00111_001;
parameter write_Sj_to_Si = 		8'b01000_001;
parameter set_f_1 = 			8'b01001_000;
parameter set_f_2 = 			8'b01010_000;
parameter fetch_encrypted_k = 	8'b01011_000;
parameter output_decrypted = 	8'b01100_100;
parameter increment_k = 		8'b01101_000;
parameter check_k = 			8'b01110_000;
parameter finished = 			8'b01111_010;
parameter wait_1a = 8'b10000_000; 
parameter wait_1b = 8'b10001_000; */


		//Always block controling outputs and internal connections	
/*always_ff @(posedge clk) begin
case(state)
	idle: 
	
	//i = i + 1
	increment_i: begin
		i <= i + 1'b1; 
		end
	//get S[i], data comes in on next cycle
	fetchS_i: begin
		ram_addr <= i;
		end
	
	wait_1a: 
	
	wait_1b:
	
	//S[i] comes
	read_s1: begin
		S_i <= ram_data;	
		end
	//j = j + s[i]
	j_plus_S_i: begin
		j <= j + S_i;
		end
	//get S[j], data comes in on next cycle
	fetchS_j: begin
		ram_addr <= j;
		end
	//S[j] comes
	wait_s2: begin
		S_j <= ram_data;		//S[j] comes in	
		end
	//write S[i] into S[j]
	write_Si_to_Sj: begin
		write_ram_data <= S_i;
		ram_addr <= j;
		end
	//write S[j] to S[i]
	write_Sj_to_Si: begin
		ram_addr <= i;
		write_ram_data <= S_j;
		end
	//perform f = s[(s[i] + s[j])]
	//first set read address, wait a cycle for data to come in
	set_f_1: begin
		ram_addr <= S_i + S_j;
		end
	set_f_2: begin
 		S_SiplusSj <= ram_data;
		f <= S_SiplusSj;
		end
		
	fetch_encrypted_k: begin
		rom_addr <= k;
		end
	output_decrypted: begin
		decrypted_data <= (f ^ rom_data);
		out_addr <= k;
		end
	increment_k: begin
		k <= k + 1'b1;
		end
	check_k: begin end
	
	finished: begin end
	
	default: begin end
endcase
end*/


//state transition always block 
/*always_ff @(posedge clk) begin

case(state)
	idle: 
		begin
		if(start) state <= increment_i;
		end
	increment_i: 		state <= fetchS_i;
	fetchS_i: 			state <= wait_1a;
	wait_1a: 		 	state <= wait_1b; 
	wait_1b: 			state <= read_s1; 
	read_s1:			state <= j_plus_S_i;
	j_plus_S_i: 		state <= fetchS_j;
	fetchS_j: 			state <= wait_s2;
	wait_s2:			state <= write_Si_to_Sj;
	write_Si_to_Sj: 	state <= write_Sj_to_Si;
	write_Sj_to_Si:		state <= set_f_1;
	set_f_1:			state <= set_f_2;	
	set_f_2:			state <= fetch_encrypted_k;
	fetch_encrypted_k:	state <= output_decrypted;	
	output_decrypted:	state <= increment_k;
	increment_k:		state <= check_k;
	check_k:
		begin
		if(k >= 8'h16)	state <= finished;
		else			state <= increment_i;
		end
	finished:				state <= idle;
	default: 			state <= idle;
endcase
end*/

		
	
		
		
	
	
	
	