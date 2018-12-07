`timescale 1ns / 1ps 
`default_nettype none 

module OutputLinkRouter #(
	parameter DATA_WIDTH = 64,
	parameter LINK_NUMBER = 4,
	parameter SUBUNIT QUANTITY = 4
) (
	out_data,
	stall,
	write,
	output_buffer_full,
	subunit_stall,
	ready,
	link_number,
	in_data
); 

// Declare input ports 
	input [95:0] header_in;
	input [31:0] payload_in;
	input buffer_ready0;
	input buffer_ready1;
	input buffer_ready2;
	input buffer_ready3;
	input [1:0] link_destination;
	
// Declare output ports
	
	output reg ready;
	output reg [39:0] header_array0;
	output reg [39:0] header_array1;
	output reg [39:0] header_array2;
	output reg [39:0] header_array3;
	output reg [31:0] payload_array0;
	output reg [31:0] payload_array1;
	output reg [31:0] payload_array2;
	output reg [31:0] payload_array3;

	
// Declare middle ports
	reg ready;
	reg ready_wait;
	reg header_received;
	reg [95:0] header_holder;
	reg [1:0] header_out;
	reg headers_sent;
	reg [31:0] payload_holder;


// Module Instantiation



// Initialize controls
initial
begin
	payload_control = 0;
	header_control = 0;
	header_complete = 0;
	ready = 1;
end

always @(posedge clk)
begin
	if(ready == 1)
	begin
		header_holder = header_in;
		header_out = 2;
		header_received = 1;
		ready = 0;
	end
	
	if(ready == 1 && headers_sent == 1)
	begin
		payload_holder = payload_in;
end
	
always @(negedge clk)
begin
	if(ready == 0 && buffer_ready == 1)
	begin
		if(header_out == 2)
		begin
			case(link_destination)
				(2'b00 && buffer_ready0 == 1):
				 	header_array0 [link_destination] [31:0] = header_holder [31:0];
					header_array0 [link_destination] [39] = 1;
					header_array0 [38:34] = 0;
					header_array0 [33:32] = LINK_NUMBER;
					header_out = header_out -1;

				(2'b01 && buffer_ready1 == 1):
					header_array1 [link_destination] [31:0] = header_holder [31:0];
					header_array1 [link_destination] [39] = 1;
					header_array1 [38:34] = 0;
					header_array1 [33:32] = LINK_NUMBER;
					header_out = header_out -1;

				(2'b10 && buffer_ready2 == 1):
				 	header_array2 [link_destination] [31:0] = header_holder [31:0];
					header_array2 [link_destination] [39] = 1;
					header_array2 [38:34] = 0;
					header_array2 [33:32] = LINK_NUMBER;
					header_out = header_out -1;

				(2'b11 && buffer_ready3 == 1):
				 	header_array3 [link_destination] [31:0] = header_holder [31:0];
					header_array3 [link_destination] [39] = 1;
					header_array3 [38:34] = 0;
					header_array3 [33:32] = LINK_NUMBER;
					header_out = header_out -1;
 
			default: 
			endcase		
		end

		else if(header_out == 1)
		begin
			case(link_destination)
				(2'b00 && buffer_ready0 == 1):
					header_array0 = {0, header_holder [63:32]};
					header_out = header_out - 1;

				(2'b01 && buffer_ready1 == 1):
					header_array1 = {0, header_holder [63:32]};
					header_out = header_out - 1;

				(2'b10 && buffer_ready2 == 1):
					header_array2 = {0, header_holder [63:32]};
					header_out = header_out - 1;

				(2'b11 && buffer_ready3 == 1):
					header_array3 = {0, header_holder [63:32]};
					header_out = header_out - 1;
			default:
			endcase
		end

		else if(header_out == 0)
		begin
			case(link_destination)
				(2'b00 && buffer_ready0 == 1):
					header_array0 = {0, header_holder [95:64]};
					header_out = header_out - 1;

				(2'b01 && buffer_ready1 == 1):
					header_array1 = {0, header_holder [95:64]};
					header_out = header_out - 1;

				(2'b10 && buffer_ready2 == 1):
					header_array2 = {0, header_holder [95:64]};
					header_out = header_out - 1;

				(2'b11 && buffer_ready3 == 1):
					header_array3 = {0, header_holder [95:64]};
					header_out = header_out - 1;
				default:
				endcase
		end
endmodule

 

