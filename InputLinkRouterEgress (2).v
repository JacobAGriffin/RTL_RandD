`timescale 1ns / 1ps 
`default_nettype none 

module InputLinkRouterEgress #(
	parameter DATA_WIDTH = 64,
	parameter LINK_NUMBER = 4,
	parameter SUBUNIT_QUANTITY = 4
) (
	ready,
	header_array0,
	header_array1,
	header_array2,
	header_array3,
	payload_array0,
	payload_array1,
	payload_array2,
	payload_array3,
	header_in,
	payload_in,
	buffer_ready0,
	buffer_ready1,
	buffer_ready2,
	buffer_ready3,
	link_destination,
	clk
); 

// Declare input ports 
	input [95:0] header_in;
	input [31:0] payload_in;
	input buffer_ready0;
	input buffer_ready1;
	input buffer_ready2;
	input buffer_ready3;
	input [2:0] link_destination;
	input clk;
	
// Declare output ports
	output reg ready;
	output reg [39:0] header_array0;
	output reg [39:0] header_array1;
	output reg [39:0] header_array2;
	output reg [39:0] header_array3;
	output reg [39:0] payload_array0;
	output reg [39:0] payload_array1;
	output reg [39:0] payload_array2;
	output reg [39:0] payload_array3;

	
// Declare middle ports
	reg header_received;
	reg [95:0] header_holder;
	reg [1:0] header_counter;
	reg [31:0] payload_holder;
	reg payload_received;
	reg payload_control;
	reg [9:0] payload_counter;
	reg incoming_header;
	reg incoming_payload;
	reg [2:0] link_destination_holder;
	reg buffer0_ready_flag;
	reg buffer1_ready_flag;
	reg buffer2_ready_flag;
	reg buffer3_ready_flag;
	reg output_wait;

// Module Instantiation



// Initialize controls
initial
begin
	header_received = 0;
	header_holder = 0;
	header_counter = 0;
	payload_holder = 0;
	payload_received = 0;
	payload_control = 0;
	payload_counter = 0;
	ready = 0;
	header_array0 = 0;
	header_array1 = 0;
	header_array2 = 0;
	header_array3 = 0;
	payload_array0 = 0;
	payload_array1 = 0;
	payload_array2 = 0;
	payload_array3 = 0;
	incoming_header = 0;
	incoming_payload = 0;
	link_destination_holder = 0;
	buffer0_ready_flag = 0;
	buffer1_ready_flag = 0;
	buffer2_ready_flag = 0;
	buffer3_ready_flag = 0;
	output_wait = 0;
end

always @(posedge clk)
begin

	//if ready for next header, and last TLP is complete, grab the next header
	if(ready == 1 && payload_control == 0 && header_received == 0 && header_in)
	begin
		header_holder = header_in;
		payload_control = header_in[30];
		payload_counter = header_in[9:0];
		header_counter = 3;
		header_received = 1;
	end
	
	//if there is payload, and header is complete, then grab the next payload
	if(ready == 1 && header_received == 0 && payload_control == 1 && payload_received == 0)
	begin
		payload_holder = payload_in;
	end

	//if payload holder has a payload, set the payload_received flag
	if(payload_holder != 0)
	begin
		payload_received = 1;
	end

	//flag manipulation for ready signal control
	if(header_in != 0)
	begin
		incoming_header = 1;
	end
	else if(header_in == 0)
	begin
		incoming_header = 0;
	end
	
	//flag manipulation for ready signal control
	if(payload_in != 0)
	begin
		incoming_payload = 1;
	end
	else if(payload_in == 0)
	begin
		incoming_payload = 0;
	end

	//transfer the link_destination to its corresponding register
	if(link_destination != 0)
	begin
		link_destination_holder = link_destination;
	end

	//buffer 0 flag set and clear
	if(buffer_ready0 == 1)
	begin
		buffer0_ready_flag = 1;
	end
	else if(buffer_ready0 == 0)
	begin
		buffer0_ready_flag = 0;
	end

	//buffer 1 flag set and clear
	if(buffer_ready1 == 1)
	begin
		buffer1_ready_flag = 1;
	end
	else if(buffer_ready1 == 0)
	begin
		buffer1_ready_flag = 0;
	end

	//buffer 2 flag set and clear
	if(buffer_ready2 == 1)
	begin
		buffer2_ready_flag = 1;
	end
	else if(buffer_ready2 == 0)
	begin
		buffer2_ready_flag = 0;
	end

	//buffer 3 flag set and clear
	if(buffer_ready3 == 1)
	begin
		buffer3_ready_flag = 1;
	end
	else if(buffer_ready3 == 0)
	begin
		buffer3_ready_flag = 0;
	end


end

	
always @(negedge clk)
begin
	//if we have header, begin the egress process
	if(header_received == 1)
	begin
		//first iteration of header egress
		if(header_counter == 3)
		begin
			case(link_destination_holder)
				//if link_destination for this TLP is 0, and buffer 0 is ready, then output first 32 bits of header and relevant flags
				(3'b001):
				begin
					if(buffer0_ready_flag == 1)
					begin
					 	header_array0 [31:0] = header_holder [31:0];
						header_array0 [39] = 1;
						header_array0 [38:34] = 0;
						header_array0 [33:32] = link_destination_holder-1;
						header_counter = header_counter -1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 1, and buffer 1 is ready, then output first 32 bits of header and relevant flags
				(3'b010):
				begin
					if(buffer1_ready_flag == 1)
					begin
						header_array1 [31:0] = header_holder [31:0];
						header_array1 [39] = 1;
						header_array1 [38:34] = 0;
						header_array1 [33:32] = link_destination_holder-1;
						header_counter = header_counter -1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 2, and buffer 2 is ready, then output first 32 bits of header and relevant flags
				(3'b011):
				begin
					if(buffer2_ready_flag == 1)
					begin
				 		header_array2 [31:0] = header_holder [31:0];
						header_array2 [39] = 1;
						header_array2 [38:34] = 0;
						header_array2 [33:32] = link_destination_holder-1;
						header_counter = header_counter -1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 3, and buffer 3 is ready, then output first 32 bits of header and relevant flags
				(3'b100):
				begin
					if(buffer3_ready_flag == 1)
					begin
				 		header_array3 [31:0] = header_holder [31:0];
						header_array3 [39] = 1;
						header_array3 [38:34] = 0;
						header_array3 [33:32] = link_destination_holder-1;
						header_counter = header_counter -1;
						output_wait = 1;
 					end
				end

				default:
				begin
				end 
			endcase		
		end

		//second iteration of header egress
		else if(header_counter == 2)
		begin
			case(link_destination_holder)
				//if link_destination for this TLP is 0, and buffer 0 is ready, then output second set of header
				(3'b001):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer0_ready_flag == 1 && output_wait == 0)	
					begin
						header_array0 = {8'h00, header_holder [63:32]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 1, and buffer 1 is ready, then output second set of header
				(3'b010):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer1_ready_flag == 1 && output_wait == 0)
					begin
						header_array1 = {8'h00, header_holder [63:32]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 2, and buffer 2 is ready, then output second set of header
				(3'b011):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer2_ready_flag == 1 && output_wait == 0)
					begin
						header_array2 = {8'h00, header_holder [63:32]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 3, and buffer 3 is ready, then output second set of header
				(3'b100):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait =  0;
					end
					else if(buffer3_ready_flag == 1 && output_wait == 0)
					begin
						header_array3 = {8'h00, header_holder [63:32]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end
				default:
				begin
				end
			endcase
		end
		
		//third iteration of header egress
		else if(header_counter == 1)
		begin
			case(link_destination_holder)
				//if link_destination for this TLP is 0, and buffer 0 is ready, then output final set of header
				(3'b001):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer0_ready_flag == 1 && output_wait == 0)
					begin
						header_array0 = {8'h00, header_holder [95:64]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 1, and buffer 1 is ready, then output final set of header
				(3'b010):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer1_ready_flag == 1 && output_wait == 0)
					begin
						header_array1 = {8'h00, header_holder [95:64]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 2, and buffer 2 is ready, then output final set of header
				(3'b011):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer2_ready_flag == 1 && output_wait == 0)
					begin
						header_array2 = {8'h00, header_holder [95:64]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end

				//if link_destination for this TLP is 3, and buffer 3 is ready, then output final set of header
				(3'b100):
				begin
					//output_wait is used to ensure proper timing of outputs
					if(output_wait == 1)
					begin
						output_wait = 0;
					end
					else if(buffer3_ready_flag == 1 && output_wait == 0)
					begin
						header_array3 = {8'h00, header_holder [95:64]};
						header_counter = header_counter - 1;
						output_wait = 1;
					end
				end
				default:
				begin
				end
			endcase
		end

		//final iteration of header egress, clearing the outputs and relevant flags
		else if(header_counter == 0)
		begin
			//output_wait is used to ensure proper timing of outputs
			if(output_wait == 1)
			begin
				output_wait = 0;
			end
			else if(output_wait == 0)
			begin
				header_received = 0;
				header_holder = 40'b0;
				ready = 1;
			end
			
			//if there is no payload with the TLP, link_destination_holder needs to be cleared
			if(payload_counter == 0)
			begin
				link_destination_holder = 0;
			end
		end
	end

	//if there is payload, and header has been completely output, then begin payload egress
	if(payload_received == 1)
	begin
		case(link_destination_holder)
			//if link_destination for this TLP is 0, and buffer 0 is ready, then output the current payload and iterate payload counter
			(3'b001):
			begin
				if(buffer0_ready_flag == 1)
				begin
					payload_array0 = {8'h00, payload_holder};
					payload_counter = payload_counter - 1;
					payload_received = 0;
					payload_holder = 0;
					ready = 1;
				end

				if(payload_counter == 0)
				begin
					payload_control = 0;
					link_destination_holder = 0;					
				end
			end

			//if link_destination for this TLP is 1, and buffer 1 is ready, then output the current payload and iterate payload counter
			(3'b010):
			begin
				if(buffer1_ready_flag == 1)
				begin
					payload_array1 = {8'h00, payload_holder};
					payload_counter = payload_counter - 1;
					payload_received = 0;
					payload_holder = 0;
					ready = 1;
				end

				//if there is no more payload, clear relevant flags and prepare for next TLP
				if(payload_counter == 0)
				begin
					payload_control = 0;
					link_destination_holder = 0;
				end
			end	

			//if link_destination for this TLP is 2, and buffer 2 is ready, then output the current payload and iterate payload counter
			(3'b011):
			begin
				if(buffer2_ready_flag == 1)
				begin
					payload_array2 = {8'h00, payload_holder};
					payload_counter = payload_counter - 1;
					payload_received = 0;
					payload_holder = 0;
					ready = 1;
				end

				//if there is no more payload, clear relevant flags and prepare for next TLP
				if(payload_counter == 0)
				begin
					payload_control = 0;
					link_destination_holder = 0;
				end
			end

			//if link_destination for this TLP is 3, and buffer 3 is ready, then output the current payload and iterate payload counter
			(3'b100):
			begin
				if(buffer3_ready_flag == 1)
				begin
					payload_array3 = {8'h00, payload_holder};
					payload_counter = payload_counter - 1;
					payload_received = 0;
					payload_holder = 0;
					ready = 1;
				end

				//if there is no more payload, clear relevant flags and prepare for next TLP
				if(payload_counter == 0)
				begin
					payload_control = 0;
					link_destination_holder = 0;
				end
			end

			default:
			begin
			end
		endcase
	
	end

	//if the module is clear, set ready high
	if(ready == 0 && header_counter == 0 && payload_control == 0 && header_holder == 0 && incoming_header == 0 && incoming_payload == 0)
	begin
		ready = 1;
	end

	//if data is received, clear ready
	else if(ready == 1 && (incoming_header != 0 || incoming_payload  != 0))
	begin
		ready = 0;
	end

	else if(ready == 0 && payload_received == 0 && header_received == 0)
	begin
		ready = 1;
	end

	//if buffer 0 drops the ready flag, clear the output to that buffer
	if(buffer0_ready_flag == 0)
	begin
		header_array0 = 0;
		payload_array0 = 0;
	end

	//if buffer 1 drops the ready flag, clear the output to that buffer
	if(buffer1_ready_flag == 0)
	begin
		header_array1 = 0;
		payload_array1 = 0;
	end

	//if buffer 2 drops the ready flag, clear the output to that buffer
	if(buffer2_ready_flag == 0)
	begin
		header_array2 = 0;
		payload_array2 = 0;
	end

	//if buffer 3 drops the ready flag, clear the output to that buffer
	if(buffer3_ready_flag == 0)
	begin
		header_array3 = 0;
		payload_array3 = 0;
	end
		

end		
endmodule

 







