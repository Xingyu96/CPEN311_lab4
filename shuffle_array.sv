module shuffle_array(clk, start, finish, read, key, write, original_mem, scrambled_mem, output_data, outAddress); 

input clk, start; 
input [23:0] key;  
input [7:0] original_mem, scrambled_mem; 
output finish, read, write; 
output [7:0] outAddress, output_data; 
 
logic [6:0] state; 
logic [7:0] i_mod_3, i, j, data_i, data_j; 

parameter idle = 7'b0000_000; 
parameter init_vals = 7'b0001_000; 
parameter check_i = 7'b0010_000; 
parameter mod_i = 7'b0011_000; 
parameter read_s_mem = 7'b0100_010; //Read signal 
parameter add_comps = 7'b0101_000; 
parameter read_s_mem_2 = 7'b0110_010; //Read signal  
parameter store_values = 7'b0111_000; 
parameter write_s_i = 7'b1000_100; //Write signal 
parameter write_s_j = 7'b1001_100; //Write signal 
parameter inc_i = 7'b1010_000; 
parameter finished = 7'b1011_001; 

assign finish = state[0]; 
assign read = state[1]; 
assign write = state[2]; 

always_ff @(posedge clk) begin 
	case(state) 
	
		idle: if(start) state <= init_vals; 
		
		init_vals: state <= check_i; 
		
		check_i: if (i>=8'h05) state <= finished; 
				 else state <= mod_i; 
				 
		mod_i: state <= read_s_mem; 
				
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
				data_i <= original_mem; 
				data_j <= data_j; 
				outAddress <= i;  
				output_data <= output_data; 
				end 
	
	//j = j + s[i] + key[i%3] 
	add_comps: begin 
			   i <= i; 
			   j <= j + data_i + key[i_mod_3]; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   end 
	
	//Read s[j] 
	read_s_mem_2: begin 
				  i <= i; 
				  j <= j;
				  data_i <= data_i; 
				  data_j <= scrambled_mem; 	 
				  outAddress <= j;
				  output_data <= output_data; 
				  end 				  

	//Write s[j] to address i 
	write_s_i: begin 
			   i <= i; 
			   j <= j; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= i; 
			   output_data <= data_j; 
			   end 
	
	//Write s[i] to address j	   
	write_s_j: begin 
			   i <= i; 
			   j <= j; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= j; 
			   output_data <= data_i; 
			   end 
	//i += 1		   
	inc_i: begin 
		   i <= i + 8'd1; 
		   j <= j; 
		   data_i <= data_i; 
		   data_j <= data_j; 
		   outAddress <= j; 
		   output_data <= data_i; 
		   end 
	
	//No outputs change in other states 		   
	default:   begin 
			   i <= i; 
			   j <= j; 
			   data_i <= data_i; 
			   data_j <= data_j; 
			   outAddress <= outAddress;
			   output_data <= output_data; 
			   end 
			   
	endcase 
end 

endmodule 
		   
	
		   
		
		