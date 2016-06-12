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

parameter idle = 7'b00000_00; 
parameter init_vals = 7'b00001_00; 
parameter check_i = 7'b00010_00; 
parameter mod_i = 7'b00011_00; 
parameter determine_key = 7'b00100_00; 
parameter set_values_for_read_1 = 7'b00101_00;
parameter read_s_mem = 7'b00110_00;  
parameter add_comps = 7'b00111_00;
parameter set_values_for_read_2 = 7'b01000_00;  
parameter read_s_mem_2 = 7'b01001_00; //Read signal  
parameter store_values = 7'b01010_00;
parameter set_values_for_write_1 = 7'b01011_00;  
parameter write_s_i = 7'b01100_10; //Write signal
parameter set_values_for_write_2 = 7'b1101_00;  
parameter write_s_j = 7'b01110_10; //Write signal 
parameter inc_i = 7'b01111_00; 
parameter finished = 7'b10000_01; 


assign finish = state[0]; 
assign write = state[1]; 

//assign LED = input_data; 

always_ff @(posedge clk) begin 
	case(state) 
	
		idle: if(start) state <= init_vals; 
		
		init_vals: state <= check_i; 
		
		check_i: if (i>=8'hFF) state <= mod_i; 
				 else state <= finished; 
				 
		mod_i: state <= determine_key; 
		
		determine_key: state <= set_values_for_read_1; 
		
		set_values_for_read_1: state <= read_s_mem;  
				
		read_s_mem: state <= add_comps; 
		
		add_comps: state <= set_values_for_read_2;

		set_values_for_read_2: state <= read_s_mem_2; 

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
							outAddress <= i;  
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
	
	//Set address to j
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
		   
	
		   
		
		