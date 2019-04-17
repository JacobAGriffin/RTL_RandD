`timescale 1ns / 1ps 
`default_nettype none 

module OLR_Sorter (
	sorted_header,
	pass_through_payload,
	ready,
	in_data_header,
	in_data_payload,
	next_ready,
	reset,
	clk
); 

// Declare input ports 
	input [135:0]	in_data_header;		// Input data from the PCIe physical layer
	input [39:0]	in_data_payload;  
	input 		next_ready, 	  		// Flag from the Egress stage stating that it is ready to receive data 
	      		reset,
	      		clk; 
// Declare output ports 	
	output reg [103:0]	sorted_header; 		
	output reg [39:0]	pass_through_payload;  	 
	output reg 		ready; 

// Declare middle ports 
	reg [135:0]	temporary_reg;
	reg [127:0]	header_holder;
	reg [103:0]	adjusted_completion_header; 		// Newly formatted header bits for output to ILR 
	reg [39:0]	payload_holder,
		  	payload_register;
	reg [9:0]	payload_counter; 		// Payload counter set to the length and everytime you output a payload subtract 1 						 	   from it
	reg 		reset_register; 
	reg 		use_next_ready,			// Register that holds the input next_ready 
	    		payload_control,			// Flag stating if there is payload present
	    		header_control,
	    		ready_to_depart;						 

	always @(posedge clk)
	begin 
		// Set inputs to registers 
		temporary_reg = in_data_header; 
		payload_holder = in_data_payload;
		use_next_ready = next_ready; 
		reset_register = reset; 
		
		#1 
		// Reset block 
		if (reset_register)
		begin 
		// Reset all the variables (middle ports and outputs) 
		sorted_header = 104'b0; 		
		pass_through_payload = 40'b0; 
		ready = 1'b1; 
		temporary_reg = 136'b0; 
		header_holder = 128'b0;
		adjusted_completion_header = 104'b0; 		 
		payload_holder = 40'b0;
		payload_register = 40'b0;
		payload_counter = 10'b0; 		
		reset_register = 1'b0;
		use_next_ready = 1'b0;			 
	   	payload_control = 1'b0;			
	    	header_control = 1'b0;
	   	ready_to_depart = 1'b0;
		end 

		// When ready(Ready once I output data or when I hit reset signal) 
		// Set middle registers and create the completion header  
		if (temporary_reg != 1'b0 && ready == 1'b1 && header_control == 1'b0 && payload_control == 1'b0) 
		begin 
			header_holder = temporary_reg[127:0];
			header_control = 1'b1;  
			adjusted_completion_header[103] = temporary_reg[135];
			adjusted_completion_header[100:98] = temporary_reg[132:130]; 
			adjusted_completion_header[97:96] = temporary_reg[129:128];
		
			// If it's a memory read, set variables to handle the payload and form completion header 
			if (header_holder [28:24] == 5'b00000 && (header_holder [31:29] == 3'b000 || header_holder [31:29] == 3'b001))
			begin
				payload_control = 1'b1; 
				payload_counter[9:0] = header_holder[9:0]; 

				// Set Length field
				adjusted_completion_header [28:0] = header_holder [28:0];
				
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
	
	
				// Set various other direct transfer headers
				//adjusted_completion_header [28:12] = header_holder [28:12];
				//adjusted_completion_header [15] = 1'b0;				 
	
				// Set fmt field to 010 for a read request
				adjusted_completion_header [31:29] = 3'b010; 
				
				// Set byte count & BCM fields
				casex (header_holder [39:32])
					8'b00001xx1: adjusted_completion_header [44:32] = 13'd4;
 					8'b000001x1: adjusted_completion_header [44:32] = 13'd3;
					8'b00001x10: adjusted_completion_header [44:32] = 13'd3;
					8'b00000011: adjusted_completion_header [44:32] = 13'd2;
					8'b00000110: adjusted_completion_header [44:32] = 13'd2;
					8'b00001100: adjusted_completion_header [44:32] = 13'd2;
					8'b00000001: adjusted_completion_header [44:32] = 13'd1;
					8'b00000010: adjusted_completion_header [44:32] = 13'd1;
					8'b00000100: adjusted_completion_header [44:32] = 13'd1;
					8'b00001000: adjusted_completion_header [44:32] = 13'd1;
					8'b00000000: adjusted_completion_header [44:32] = 13'd1;
					8'b1xxxxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4);
					8'b01xxxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd1;
					8'b001xxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd2;
					8'b0001xxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd3;
					8'b1xxxxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd1;
					8'b01xxxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd2;
					8'b001xxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd3;
					8'b0001xx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd4;
					8'b1xxxx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd2;
					8'b01xxx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd3;
					8'b001xx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd4;
					8'b0001x100: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd5;
					8'b1xxx1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd3;
					8'b01xx1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd4;
					8'b001x1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd5;
					8'b00011000: adjusted_completion_header [44:32] = (header_holder [9:0] * 3'd4) - 13'd6;
					default: adjusted_completion_header [44:32] = 0;
				endcase
				
				// Set completion status bits to default
				adjusted_completion_header [47:45] = adjusted_completion_header [100:98];
	
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
	
				// Setting lower 2 bits of lower address 
				casex (header_holder [35:32])
					4'b0000: adjusted_completion_header [65:64] = 2'b00;  
					4'bxxx1: adjusted_completion_header [65:64] = 2'b00; 
					4'bxx10: adjusted_completion_header [65:64] = 2'b01; 
					4'bx100: adjusted_completion_header [65:64] = 2'b10;
					4'b1000: adjusted_completion_header [65:64] = 2'b11;
					default: adjusted_completion_header [65:64] = 2'bzz; 
 				endcase 
	
				//setting upper 5 bits of lower address (pulls from different areas on 32 vs 64 bit address)
				if (header_holder [29] == 1'b0) // 32 bit address 
					begin
						adjusted_completion_header [70:66] = header_holder [70:66]; // Setting the lower address field 
					end 	
				else // 64 bit address 
					begin
						adjusted_completion_header [70:66] = header_holder [102:98]; // Setting the lower address field 
					end 
	
				// Set R (routing bit) to 0 for now**	
				adjusted_completion_header [71] = 1'b0;
	
				// Set tag field
 				adjusted_completion_header [79:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:80] = header_holder [63:48];
				end

			//Memory write request
			else if (header_holder [28:24] == 5'b00000 && (header_holder [31:29] == 3'b010 || header_holder [31:29] == 3'b011))
			begin

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
				
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
	
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
	
				// Set fmt field to 000 for a write request
				adjusted_completion_header [31:29] = 3'b000; 
				
				// Set byte count & BCM fields
				adjusted_completion_header [44:32] = 13'b0000000000011;
			
				// Set completion status bits to default
				adjusted_completion_header [47:45] = adjusted_completion_header [100:98];
	
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
	
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000;
	
				// Set R (routing bit) to don't care for now**	
				adjusted_completion_header [71] = 1'b0;
	
				// Set tag field
 				adjusted_completion_header [79:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:80] = header_holder [63:48];
			end 
				
			// I/O request
			else if (header_holder [28:24] == 5'b00010)
			begin 

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
				
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
		
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
		
				// Set fmt field to 0x0 for a read request
				adjusted_completion_header [31:29] = 3'b000; 
					
				// Set byte count & BCM fields
				adjusted_completion_header [44:32] = 13'b0000000111111;
					
				// Set completion status bits to default
				adjusted_completion_header [47:45] = adjusted_completion_header [100:98];
		
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
		
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000; 

				// Set R field (R field in configuration header is bit 64) 
				adjusted_completion_header [71] = 1'b0; 
		
				// Set tag field
 				adjusted_completion_header [79:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:80] = header_holder [63:48];
			end 
	
			 //Configuration request
		        else if (header_holder [28:24] == 5'b00100 || header_holder [28:24] == 5'b00101) 
			begin 

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
					
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
		
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
		
				// Set fmt field to 000 for a read request
				adjusted_completion_header [31:29] = 3'b000; 
					
				// Set byte count & BCM fields
				adjusted_completion_header [44:32] = 13'b000000000011;
					
				// Set completion status bits to default
				adjusted_completion_header [47:45] = adjusted_completion_header [100:98];
		
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
		
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000; 

				// Set R field (R field in configuration header is bit 64) 
				adjusted_completion_header [71] = 1'b0; 
		
				// Set tag field
	 			adjusted_completion_header [79:72] = header_holder [47:40];
		
				// Set requester ID 
				adjusted_completion_header [95:80] = header_holder [63:48];
	
			end
			// Set flag to show that the completion header is complete 
			ready_to_depart = 1'b1; 
			adjusted_completion_header[102:98] = 5'b0;
			
		end 
		
		// If data is ready to depart and egress is ready, output data 
		if (ready_to_depart == 1'b1 && use_next_ready == 1'b1 && header_control == 1'b1)
		begin 
			sorted_header = adjusted_completion_header;
			adjusted_completion_header = 104'b0; 
			header_holder = 127'b0;
			header_control = 1'b0;
			ready_to_depart = 1'b0;
			ready = 1'b1; 
		end 

		// If there is payload, handle it 
		if(payload_control == 1'b1 && payload_holder != 1'b0 && ready == 1'b1 && header_control == 1'b0)
		begin 
			payload_register = payload_holder; 
			ready_to_depart = 1'b1;  
			payload_counter = payload_counter - 1'b1; 
			ready = 1'b0;
		end 

		if (ready_to_depart == 1'b1 && use_next_ready == 1'b1 && payload_control == 1'b1 && header_control == 1'b0)
		begin 
			pass_through_payload = payload_register; 
			payload_register = 1'b0;
			ready_to_depart = 1'b0;
			ready = 1'b1; 

			if (payload_counter == 1'b0)
			begin 
				payload_control = 1'b0;
			end 
		end 
		// If there is no payload, do the next header 

		if(ready == 1'b1 && (temporary_reg != 1'b0 || payload_holder != 1'b0))
		begin
			ready = 1'b0;
		end

		if(ready == 1'b0 && temporary_reg == 1'b0 && payload_holder == 1'b0 && payload_register == 1'b0 && adjusted_completion_header == 0)
		begin
			ready = 1'b1;
		end
	
		if(use_next_ready == 1'b0)
		begin
			sorted_header = 104'b0;
			pass_through_payload = 40'b0;
		end
		
	end 
endmodule 
