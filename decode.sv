module decode_rc4(clk, start, success, failure, data, address, key, new_key); 

input start, clk; 
input [7:0] data; 
input [23:0] key; 
output success, failure; 
output [7:0] address; 
output [23:0] new_key; 

logic [5:0] state; 
logic [7:0] test_data, i;

parameter idle = 6'b0000_00; 
parameter init_vals = 6'b0001_00; 
parameter check_i = 6'b0010_00; 
parameter set_address = 6'b0011_00; 
parameter wait_1 = 6'b0100_00; 
parameter wait_2 = 6'b0101_00; 
parameter read_data = 6'b0110_00; 
parameter check_in_range = 6'b0111_00; 
parameter inc_i = 6'b1000_00; 
parameter check_eq_32 = 6'b1001_00; 
parameter inc_secret_key = 6'b1010_00; 
parameter failed = 6'b1011_01; 
parameter succeeded = 6'b1100_10; 

assign failure = state[0]; 
assign success = state[1];  

always_ff@(posedge clk) begin 
	case(state) 
	
	idle: if (start) state <= init_vals; 
	
	init_vals: state <= check_i; 
	
	check_i: if (i>8'd31) state <= succeeded; 
			 else state <= set_address; 
			 
	set_address: state <= wait_1; 
	
	wait_1: state <= wait_2; 
	
	wait_2: state <= read_data; 
	
	read_data: state <= check_in_range; 
	
	check_in_range: if (test_data<8'd97 || test_data>8'd122) state <= check_eq_32; 
					else state <= inc_i; 
					
	check_eq_32: if(test_data == 8'd32) state <= inc_i; 
				 else state <= inc_secret_key; 
				 
	inc_secret_key: state <= failed; 
	
	failed: state <= idle; 
	
	succeeded: state <= idle; 
	
	default: state <= idle; 
	
	endcase 
end 

always_ff@(posedge clk) begin 
	case(state) 
	
	init_vals: begin 
				i <= 8'b0; 
				new_key <= key; 
				test_data <= test_data; 
				address <= address; 
			  end 
			  
	set_address: begin 
					i <= i; 
					new_key <= new_key; 
					test_data <= test_data; 
					address <= i; 
				 end 
				 
	read_data: begin 
				i <= i; 
				new_key <= new_key; 
				test_data <= data; 
				address <= address; 
			  end 
			  
	inc_secret_key: begin 
					 i <= i; 
					 new_key <= new_key + 24'd1;
					 test_data <= test_data; 
					 address <= address; 
					end 
					
	endcase 
	
end 
	

