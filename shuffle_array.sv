module shuffle_array(clk, start, finish, read, key, write, input_data, output_data, outAddress); 

input clk, start; 
//input press; //For debugging 
input [23:0] key;  
input [7:0] input_data;
//output [7:0] LED;  
output finish, read, write; 
output [7:0] outAddress, output_data; 
 
logic [7:0] state; 
logic [7:0] i_mod_3, i, j, data_i, data_j, secret_key_byte; 

parameter idle = 8'b00000_000; 
parameter init_vals = 8'b00001_000; 
parameter check_i = 8'b00010_000; 
parameter mod_i = 8'b00011_000; 
parameter determine_key = 8'b00100_000; 
parameter set_values_for_read_1 = 8'b00101_000;
parameter read_s_mem = 8'b00110_010; //Read signal 
parameter add_comps = 8'b00111_000;
parameter set_values_for_read_2 = 8'b01000_000;  
parameter read_s_mem_2 = 8'b01001_010; //Read signal  
parameter store_values = 8'b01010_000;
parameter set_values_for_write_1 = 8'b01011_000;  
parameter write_s_i = 8'b01100_100; //Write signal
parameter set_values_for_write_2 = 8'b1101_000;  
parameter write_s_j = 8'b01110_100; //Write signal 
parameter inc_i = 8'b01111_000; 
parameter finished = 8'b10000_001; 
parameter additional_wait_1 = 8'b10001_000; 
parameter additional_wait_2 = 8'b10010_000; 

assign finish = state[0]; 
assign write = state[2]; 

//assign LED = input_data; 

always_ff @(posedge clk) begin 
	case(state) 
	
		idle: if(start) state <= init_vals; 
		
		init_vals: state <= check_i; 
		
		check_i: if (i>=8'h04) state <= finished; 
				 else state <= mod_i; //Temporary, testing only 
				 
		mod_i: state <= determine_key; 
		
		determine_key: state <= set_values_for_read_1; 
		
		set_values_for_read_1: state <= read_s_mem; 
		
		//additional_wait_1: state <= read_s_mem; 
				
		read_s_mem: state <= add_comps; 
		
		add_comps: state <= set_values_for_read_2;

		set_values_for_read_2: state <= read_s_mem_2; 
		
		//additional_wait_2: state <= read_s_mem_2; 

		read_s_mem_2: state <= set_values_for_write_1; 

		set_values_for_write_1: state <= write_s_i; 
		
		write_s_i: state <= set_values_for_write_2; 
		
		set_values_for_write_2: state <= write_s_j; 
		
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
	
	//Set address to i
	set_values_for_read_1:  begin 
							i <= i; 
							j <= j;
							i_mod_3 <= i_mod_3; 
							secret_key_byte <= secret_key_byte; 
							data_i <= data_i; 
							data_j <= data_j; 
							outAddress <= 8'h05;  
							output_data <= output_data; 
							end 
	//Read s[i] 
	read_s_mem: begin 
				i <= i; 
				j <= j;
				i_mod_3 <= i_mod_3; 
				secret_key_byte <= secret_key_byte; 
				data_i <= input_data; 
				data_j <= data_j; 
				outAddress <= outAddress;  
				output_data <= output_data; 
				end 
	
	//j = j + s[i] + key[i%3] 
	add_comps: begin 
			   i <= i; 
			   j <= (j + data_i + secret_key_byte); 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   end 
	
	//Set address to be read 
	set_values_for_read_2: begin 
						  i <= i; 
						  j <= j;
						  i_mod_3 <= i_mod_3; 
						  secret_key_byte <= secret_key_byte; 
						  data_i <= data_i; 
						  data_j <= data_j; 	 
						  outAddress <= j;
						  output_data <= output_data; 
						  end 	
	//Read s[j] 
	read_s_mem_2: begin 
				  i <= i; 
				  j <= j;
				  i_mod_3 <= i_mod_3; 
				  secret_key_byte <= secret_key_byte; 
				  data_i <= data_i; 
				  data_j <= input_data; 	 
				  outAddress <= outAddress;
				  output_data <= output_data; 
				  end 				  
					
	//Write s[i] to address j 
	//Write signal goes high 1 clock cycle later 
	set_values_for_write_1: begin 
							   i <= i; 
							   j <= j; 
							   i_mod_3 <= i_mod_3; 
							   secret_key_byte <= secret_key_byte; 
							   data_i <= data_i; 
							   data_j <= data_j; 
							   outAddress <= j; 
							   output_data <= data_i; //data_i 
							  end 
	/*						  
	write_s_i: 				begin 
							   i <= i; 
							   j <= j; 
							   i_mod_3 <= i_mod_3; 
							   secret_key_byte <= secret_key_byte; 
							   data_i <= data_i; 
							   data_j <= data_j; 
							   outAddress <= outAddress; 
							   output_data <= output_data; 
							  end */
	//Write s[j] to address i	   
	//Write signal goes high next clock cycle 
	set_values_for_write_2: begin 
						   i <= i; 
						   j <= j; 
						   i_mod_3 <= i_mod_3; 
						   secret_key_byte <= secret_key_byte; 
						   data_i <= data_i; 
						   data_j <= data_j; 
						   outAddress <= i; 
						   output_data <= data_j; //data_j 
						   end 
	//i += 1		   
	inc_i: begin 
		   i <= i + 8'd1; 
		   j <= j; 
		   i_mod_3 <= i_mod_3; 
		   secret_key_byte <= secret_key_byte; 
		   data_i <= data_i; 
		   data_j <= data_j; 
		   outAddress <= outAddress; 
		   output_data <= output_data; 
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
		   
	
		   
		
		