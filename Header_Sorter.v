`timescale 1ns / 1ps 
`default_nettype none 

module Header_Sorter #(
	parameter LINK_NUMBER = 0,
	parameter DATA_WIDTH = 64
) (
	sorted_header,
	pass_through_payload,
	link_destination,
	ready,
	in_data_header,
	in_data_payload,
	next_ready,
	clk
); 

// Declare input ports 
	input [127:0] in_data_header;		// Input data from the PCIe physical layer
	input [31:0] in_data_payload;  
	input next_ready;  			// Flag from the Egress stage stating that it is ready to receive data 
	input clk;

// Declare output ports 	
	output reg [95:0] sorted_header; 		
	output reg [31:0] pass_through_payload; 
	output reg [2:0] link_destination; 	// Tell next stage what hardware subunit buffer to send data to 
	output reg ready;

// Declare middle ports 
	reg [127:0] header_holder;
	reg [95:0] adjusted_completion_header; 		// Newly formatted header bits for output to ILR 
	reg [31:0] payload_holder;
	reg translation_complete;
	reg header_passed; 
	reg incoming_header; 			// Flag stating if there is header data 
	reg set_next_ready;			// Flag for use on the negedge stating if Egress stage is ready to receive data 
	reg [2:0] link_destination_holder;

// Module Instantiation
	initial
	begin
		header_holder = 0;
		adjusted_completion_header = 0;
		payload_holder = 0;
		ready = 0;
		translation_complete = 0; 
		header_passed = 0; 
		incoming_header = 0;
		set_next_ready = 0;
		sorted_header = 0;
		pass_through_payload = 0;
		link_destination = 0;
		link_destination_holder = 0;
	end

	// Read input data on the posedge 
	always @(posedge clk)
	begin 

		// If there is header data, set flag to use on negedge 
		if (in_data_header != 0) 
		begin 
			incoming_header = 1;
		end 
	
		if (in_data_header == 0)
		begin 
			incoming_header = 0; 
		end 

		// Set a flag to use in the negedge 
		if (next_ready == 1)
		begin 
			set_next_ready = 1; 
		end 
	
		if (next_ready == 0)
		begin 
			set_next_ready = 0; 
		end

		// Pass payload data into the holder variable 
		// Does this conflict with the payload holder getting passed to the output payload? 
		if (ready == 1 && translation_complete == 1 && header_passed == 1)
		begin
			payload_holder = in_data_payload; 
		end	

		// Might need another condition to check if there in_data_header and in_data_payload != 0 
		if(ready == 1 && translation_complete == 0 && in_data_header != 0) 
		begin
			header_holder = in_data_header;
 
			// Memory read request 
			if (header_holder [28:24] == 5'b00000 && (header_holder [31:29] == 3'b000 || header_holder [31:29] == 3'b001)) 
			begin 
				// Memory hardware subunit = 2 
				link_destination_holder = 3'b010; 

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
				
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
	
	
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
	
				// Set fmt field to 010 for a read request
				adjusted_completion_header [31:29] = 3'b010; 
				
				// Set byte count & BCM fields
				case (header_holder [39:32])
					8'b00001xx1: adjusted_completion_header [44:32] = 4;
 					8'b000001x1: adjusted_completion_header [44:32] = 3;
					8'b00001x10: adjusted_completion_header [44:32] = 3;
					8'b00000011: adjusted_completion_header [44:32] = 2;
					8'b00000110: adjusted_completion_header [44:32] = 2;
					8'b00001100: adjusted_completion_header [44:32] = 2;
					8'b00000001: adjusted_completion_header [44:32] = 1;
					8'b00000010: adjusted_completion_header [44:32] = 1;
					8'b00000100: adjusted_completion_header [44:32] = 1;
					8'b00001000: adjusted_completion_header [44:32] = 1;
					8'b00000000: adjusted_completion_header [44:32] = 1;
					8'b1xxxxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 4);
					8'b01xxxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 1;
					8'b001xxxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 2;
					8'b0001xxx1: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 3;
					8'b1xxxxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 1;
					8'b01xxxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 2;
					8'b001xxx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 3;
					8'b0001xx10: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 4;
					8'b1xxxx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 2;
					8'b01xxx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 3;
					8'b001xx100: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 4;
					8'b0001x100: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 5;
					8'b1xxx1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 3;
					8'b01xx1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 4;
					8'b001x1000: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 5;
					8'b00011000: adjusted_completion_header [44:32] = (header_holder [9:0] * 4) - 6;
					default: adjusted_completion_header [44:32] = 0;
				endcase
				
				// Set completion status bits to default
				adjusted_completion_header [47:45] = 3'b111;
	
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
	
				// Setting lower 2 bits of lower address 
				case (header_holder [35:32])
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
 				adjusted_completion_header [78:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:79] = header_holder [55:48];
				end
	
			//Memory write request
			else if (header_holder [28:24] == 5'b00000 && (header_holder [31:29] == 3'b010 || header_holder [31:29] == 3'b011))
			begin

				link_destination_holder = 3'b010; 

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
				
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
	
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
	
				// Set fmt field to 010 for a write request
				adjusted_completion_header [31:29] = 3'b000; 
				
				// Set byte count & BCM fields
				adjusted_completion_header [44:32] = 12'b000000000011;
			
				// Set completion status bits to default
				adjusted_completion_header [47:45] = 3'b111;
	
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
	
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000;
	
				// Set R (routing bit) to don't care for now**	
				adjusted_completion_header [71] = 1'bx;
	
				// Set tag field
 				adjusted_completion_header [78:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:79] = header_holder [55:48];
			end 
				
			// I/O request
			else if (header_holder [28:24] == 5'b00010)
			begin 
				// IO hardware subunit = 3 
				link_destination_holder = 3'b011; 

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
				adjusted_completion_header [47:45] = 3'b111;
		
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
		
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000; 

				// Set R field (R field in configuration header is bit 64) 
				adjusted_completion_header [71] = header_holder [64]; 
		
				// Set tag field
 				adjusted_completion_header [78:72] = header_holder [47:40];
	
				// Set requester ID 
				adjusted_completion_header [95:79] = header_holder [55:48];
			end 
	
			 //Configuration request
		        else if (header_holder [28:24] == 5'b00100 || header_holder [28:24] == 5'b00101) 
			begin 
				// Configuration hardware subunit = 1 
				link_destination_holder = 3'b001; 

				// Set Length field
				adjusted_completion_header [9:0] = header_holder [9:0];
					
				// Set AT field to 00
				adjusted_completion_header [11:10] = 2'b00;
		
				// Set various other direct transfer headers
				adjusted_completion_header [28:12] = header_holder [28:12]; 
		
				// Set fmt field to 000 for a read request
				adjusted_completion_header [31:29] = 3'b000; 
					
				// Set byte count & BCM fields
				adjusted_completion_header [44:32] = 12'b000000000011;
					
				// Set completion status bits to default
				adjusted_completion_header [47:45] = 3'b111;
		
				// Set completer ID to default
				adjusted_completion_header [63:48] = 16'b1111111111111111;
		
				// Set lower address
				adjusted_completion_header [70:64] = 7'b0000000; 

				// Set R field (R field in configuration header is bit 64) 
				adjusted_completion_header [71] = header_holder [64]; 
		
				// Set tag field
	 			adjusted_completion_header [79:72] = header_holder [47:40];
		
				// Set requester ID 
				adjusted_completion_header [95:80] = header_holder [63:48];
	
			end

			else 
			begin // Set completion status to 001 to signify that there was an error in the translation 
				adjusted_completion_header = 0; 
				adjusted_completion_header [48:46] = 3'b001;
			end
			
			translation_complete = 1; // Finished the completion header so set the flag to high 

		end
		end 
	
	// Write data on the negedge 
	always @(negedge clk)
	begin

		// Make an if statement to set the ready flag 
		if (ready == 0 && incoming_header == 0) 
		begin 
			ready = 1;
		end 

		// Pass through the data payload 
		if(header_passed == 1 && set_next_ready == 1)
		begin
			pass_through_payload = payload_holder; 
			header_passed = 0; // Reset header_passed here 
		end

		// Reset the ready when ready is high and there is payload/ header data 
		if(ready == 1 && incoming_header == 1)
		begin
			ready = 0; 
		end
	
		// Pass through the completion header  
		if(set_next_ready == 1 && translation_complete == 1 && header_passed == 0) 
		begin
			sorted_header = adjusted_completion_header;
			link_destination = link_destination_holder; 
			header_passed = 1; // Set the flag
			translation_complete = 0; // Reset the flag 
			adjusted_completion_header = 0; 
			header_holder = 0;
			link_destination_holder = 0;
		end

		// Drop data when next_ready == 0 
		if (set_next_ready == 0)
		begin 
			sorted_header = 0; 
			link_destination = 0;
			pass_through_payload = 0;
		end 

		
	end
endmodule
