
//module to perform task 2b, outputs decrypted message
module simple_decrypt(start, finish, clk, decrypted_data, rom_addr, rom_data, write_ram, ram_addr, ram_data, write_decrypted, out_addr);

input clk, start;
input logic [7:0] rom_data, ram_data;
output write_ram, finish, write_decrypted;
output logic [7:0] decrypted_data, rom_addr, ram_addr, out_addr; 

logic [7:0] state;
logic [7:0] i, j, S_i, S_j, S_SiplusSj, f, k;

//parameters
parameter idle = 				8'b00000_000;
parameter increment_i = 		8'b00001_000;
parameter fetchS_i = 			8'b00010_000;
parameter wait_s1 = 			8'b00011_000;
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





//output signals assigned to state bits
assign write_ram = state[0];
assign finish = state[1];
assign write_decrypted = state[2];

//state transition always block 
always_ff @(posedge clk) begin

case(state)
	idle: 
		begin
		if(start) state <= increment_i;
		end
	increment_i: 		state <= fetchS_i;
	fetchS_i: 			state <= wait_s1;
	wait_s1:			state <= j_plus_S_i;
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
end

//Always block controling outputs and internal connections	
always_ff @(posedge clk) begin
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
	//S[i] comes
	wait_s1: begin
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
		decrypted_data <= S_i;
		ram_addr <= j;
		end
	//write S[j] to S[i]
	write_Sj_to_Si: begin
		ram_addr <= i;
		decrypted_data <= S_j;
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
end

endmodule
		
	
		
		
	
	
	
	