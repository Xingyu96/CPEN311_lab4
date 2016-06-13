module shuffle_array(clk, start, finish, key, write, in_data, output_data, outAddress, LED, press); 

input clk, start; 
input press; //For debugging 
input [23:0] key;  
//input [7:0] original_mem, scrambled_mem;
input [7:0] in_data; 
output [7:0] LED;  
output finish, write; 
output [7:0] outAddress, output_data; 
 
logic [6:0] state; 
logic [7:0] i_mod_3, i, j, data_i, data_j, secret_key_byte; 
logic flag; 

parameter idle = 7'b00000_00; 
parameter init_vals = 7'b00001_00; 
parameter check_i = 7'b00010_00; 
parameter mod_i = 7'b00011_00; 
parameter determine_key = 7'b00100_00; 
parameter set_values_for_read_1 = 7'b00101_00;
parameter read_s_mem = 7'b00110_00;  
parameter add_comps = 7'b00111_00;
parameter set_values_for_read_2 = 7'b01000_00;  
parameter read_s_mem_2 = 7'b01001_00;   
parameter set_values_for_write_1 = 7'b01010_00;  
parameter write_s_i = 7'b01011_10; //Write signal
parameter set_values_for_write_2 = 7'b01100_00;  
parameter write_s_j = 7'b01101_10; //Write signal 
parameter inc_i = 7'b01110_00; 
parameter finished = 7'b01111_01; 
parameter swap_vals = 7'b10000_00; 
parameter wait_1a = 7'b10001_00; 
parameter wait_1b = 7'b10010_00; 
parameter wait_2a = 7'b10011_00;
parameter wait_2b = 7'b10100_00;  


assign finish = state[0]; 
assign write = state[1]; 

assign LED = data_j; 

always_ff @(posedge clk) begin 
	case(state) 
	
		idle: if(start) state <= init_vals; 
		
		init_vals: state <= check_i; 
		
		check_i: if (flag) state <= finished; 
				 else state <= mod_i; 
				 
		mod_i: state <= determine_key; 
		
		determine_key: state <= set_values_for_read_1; 
		
		set_values_for_read_1: state <= wait_1a;

		wait_1a: state <= wait_1b; 

		wait_1b: state <= read_s_mem; 
				
		read_s_mem: state <= add_comps; 
		
		add_comps: state <= set_values_for_read_2;

		set_values_for_read_2: state <= wait_2a;

		wait_2a: state <= wait_2b; 
		
		wait_2b: state <= read_s_mem_2; 

		read_s_mem_2: state <= swap_vals; 
		
		swap_vals: state <= set_values_for_write_1; 

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
				flag <= 1'b0; 
				
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
		   if (i==8'hFF) flag <= 1'b1;
		   else flag <= 1'b0; 

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
				   flag <= flag; 
				  
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
							flag <= flag; 
						
							end 
	//Read s[i] 
	read_s_mem: begin 
				i <= i; 
				j <= j;
				i_mod_3 <= i_mod_3; 
				secret_key_byte <= secret_key_byte; 
				data_i <= in_data; 
				data_j <= data_j; 
				outAddress <= outAddress;  
				output_data <= output_data;
				flag <= flag; 	
			
				end 
	
	//j = j + s[i] + key[i%3] 
	add_comps: begin 
			   i <= i; 
			   j <= (j + data_i + secret_key_byte); 
			   //j <= i + 8'd5; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   flag <= flag; 
			
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
							flag <= flag;

						  end 	
	//Read s[j] 
	read_s_mem_2: begin 
				 i <= i; 
				j <= j;
				i_mod_3 <= i_mod_3; 
				secret_key_byte <= secret_key_byte; 
				data_i <= data_i; 
				data_j <= in_data; 
				outAddress <= outAddress;  
				output_data <= output_data;
				flag <= flag; 	
		
				  end 	
	
	
	/*swap_vals: begin 
				 i <= i; 
				  j <= j;
				  i_mod_3 <= i_mod_3; 
				  secret_key_byte <= secret_key_byte; 
				  data_i <= data_j; 
				  data_j <= data_i; 	 
				  outAddress <= outAddress;
				  output_data <= output_data; 
				  flag <= flag; */
			
				 
					
	//Write s[j] to address i 
	//Write signal goes high 1 clock cycle later 
	//s[j] -> s[i] 
	set_values_for_write_1: begin 
							   i <= i; 
							   j <= j; 
							   i_mod_3 <= i_mod_3; 
							   secret_key_byte <= secret_key_byte; 
							   data_i <= data_i; 
							   data_j <= data_j; 
							   outAddress <= j; //j ggggggggggg
							   output_data <= data_i; //data_i ggggggggggggggg
							   flag <= flag; 
							
							  end 
							  
	/*write_s_i:  begin 
			   i <= i; 
			   j <= j; 
			   i_mod_3 <= i_mod_3; 
			   secret_key_byte <= secret_key_byte; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   flag <= flag;
			
			   end */

	//temp -> s[j] 	   
	//Write signal goes high next clock cycle 
	set_values_for_write_2: begin 
						   i <= i; 
						   j <= j; 
						   i_mod_3 <= i_mod_3; 
						   secret_key_byte <= secret_key_byte; 
						   data_i <= data_i; 
						   data_j <= data_j; 
						   outAddress <= i; //i ggggggggggggggg
						   output_data <= data_j; //data_j gggggggggggggg
						   flag <= flag; 
						
						   end 
					   
	/*write_s_j: begin 
						   i <= i; 
						   j <= j; 
						   i_mod_3 <= i_mod_3; 
						   secret_key_byte <= secret_key_byte; 
						   data_i <= data_i; 
						   data_j <= data_j; 
						   outAddress <= outAddress; 
						   output_data <= output_data; //data_j 
						   flag <= flag; 
						   end */
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
		   flag <= flag; 
		
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
			   flag <= flag;
			
			   end 
			   
	endcase 
end 

endmodule 
		   
	
		   
		
		