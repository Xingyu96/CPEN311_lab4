module shuffle_array(clk, start, finish, read, key, write, original_mem, scrambled_mem, output_data, outAddress); 

input clk, start; 
input [23:0] key;  
input [7:0] original_mem, scrambled_mem; 
output finish, read, write; 
output [7:0] outAddress, output_data; 
 
logic [6:0] state; 
logic [7:0] i_mod_3, i, j, data_i, data_j, secret_key_byte; 

parameter idle = 7'b0000_000; 
parameter init_vals = 7'b0001_000; 
parameter check_i = 7'b0010_000; 
parameter mod_i = 7'b0011_000; 
parameter determine_key = 7'b0100_000; 
parameter read_s_mem = 7'b0101_010; //Read signal 
parameter add_comps = 7'b0110_000; 
parameter read_s_mem_2 = 7'b0111_010; //Read signal  
parameter store_values = 7'b1000_000; 
parameter write_s_i = 7'b1001_100; //Write signal 
parameter write_s_j = 7'b1010_100; //Write signal 
parameter inc_i = 7'b1011_000; 
parameter finished = 7'b1100_001; 

assign finish = state[0]; 
assign read = state[1]; 
assign write = state[2]; 

always_ff @(posedge clk) begin 
	case(state) 
	
		idle: if(start) state <= init_vals; 
		
		init_vals: state <= check_i; 
		
		check_i: if (i>=8'hFF) state <= finished; 
				 else state <= mod_i; 
				 
		mod_i: state <= determine_key; 
		
		determine_key: state <= read_s_mem; 
				
		read_s_mem: state <= add_comps; 
		
		add_comps: state <= read_s_mem_2; 

		read_s_mem_2: state <= store_values; 
		
		store_values: state <= write_s_i; 
		
		write_s_i: state <= write_s_j; 
		
		write_s_j: state <= inc_i; 

		inc_i: state <= check_i;
		
		finished: state <= idle; 
		
		default state <= idle; 
		
	endcase 
end 

always_ff @(posedge clk) begin 
	case(state) 

	//Initialize i and j to 0 
	init_vals: 	begin 
				i <= 8'd0; 
				j <= 8'd0;
				i_mod_3 <= i_mod_3; 
				secret_key_byte <= secret_key_byte; 
				data_i <= data_i; 
				data_j <= data_j; 
				outAddress <= outAddress;
				output_data <= output_data; 
				end 
	
	//calculate i%3 
	mod_i: begin 
		   i <= i; 
		   j <= j; 
		   i_mod_3 <= i%3; 
		   secret_key_byte <= secret_key_byte; 
		   data_i <= data_i; 
		   data_j <= data_j;
		   outAddress <= outAddress;
		   output_data <= output_data; 
		   end 
	
	//Determine secret_key[i%3] 
	determine_key: begin 
				   i <= i; 
				   j <= j; 
				   i_mod_3 <= i_mod_3; 
				   
				   if (i_mod_3 == 2) secret_key_byte <= key[7:0]; 
				   else if (i_mod_3 == 1) secret_key_byte <= key[15:8]; 
				   else secret_key_byte <= key[23:16]; 
				   
				   data_i <= data_i; 
				   data_j <= data_j;
				   outAddress <= outAddress;
				   output_data <= output_data; 
				   end 
					
	//Read s[i] 
	read_s_mem: begin 
				i <= i; 
				j <= j;
				i_mod_3 <= i_mod_3; 
				secret_key_byte <= secret_key_byte; 
				data_i <= original_mem; 
				data_j <= data_j; 
				outAddress <= i;  
				output_data <= output_data; 
				end 
	
	//j = j + s[i] + key[i%3] 
	add_comps: begin 
			   i <= i; 
			   j <= j + data_i + secret_key_byte; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   end 
	
	//Read s[j] 
	read_s_mem_2: begin 
				  i <= i; 
				  j <= j;
				  i_mod_3 <= i_mod_3; 
				  secret_key_byte <= secret_key_byte; 
				  data_i <= data_i; 
				  data_j <= scrambled_mem; 	 
				  outAddress <= j;
				  output_data <= output_data; 
				  end 				  

	//Write s[j] to address i 
	write_s_i: begin 
			   i <= i; 
			   j <= j; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= i; 
			   output_data <= data_j; 
			   end 
	
	//Write s[i] to address j	   
	write_s_j: begin 
			   i <= i; 
			   j <= j; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= j; 
			   output_data <= data_i; 
			   end 
	//i += 1		   
	inc_i: begin 
		   i <= i + 8'd1; 
		   j <= j; 
		   i_mod_3 <= i_mod_3; 
		   secret_key_byte <= secret_key_byte; 
		   data_i <= data_i; 
		   data_j <= data_j; 
		   outAddress <= j; 
		   output_data <= data_i; 
		   end 
	
	//No outputs change in other states 		   
	default:   begin 
			   i <= i; 
			   j <= j; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   end 
			   
	endcase 
end 

endmodule 
		   
	
		   
		
		