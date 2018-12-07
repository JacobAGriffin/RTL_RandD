`timescale 1ns / 1ps 
`default_nettype none 

// OLR VERILOG FILE***

module OutputLinkRouter #(
	parameter DATA_WIDTH = 64,
	parameter completer_ID = 16'hFFFF
) (
	buffer_in,
	payload_bus,
	completer_status,
	buffer_ready,
	subunit_stall,
	output_buffer_full,
	ready,
	header_array,
	payload_array
); 

// Declare input ports 
	input [39:0] buffer_in;					// unprocessed input header from buffer (8 bit created header + 32 bit 1/3 part of completion header
	input [63:0] payload_bus;				// payload from given subunit 
	input [1:0] completer_status;				// completer status inputted from subunit
	
	// Flags
	input buffer_ready;					// ready flag from downstream buffer
	input subunit_stall;					// flag from upstream subunit, stall if high
	input output_buffer_full;				// flag from output buffer if full, stall if high
	
// Declare output ports
	
	output reg ready;					// ready flag for downstream and upstream buffers
	output reg [31:0] header_array [3:0];			// output array for headers, 4 lanes wide
	output reg [31:0] payload_array [3:0];			// output array for payloads, 4 lanes wide

	
// Declare middle ports

	// Data Ports
	reg [31:0] header_packet [2:0];				// where header will be stored and analyzed before outputting
	reg [31:0] payload1, payload2;				// where each payload will be stored before outputting to bus
	reg [31:0] payload_out;					// output payload bus

	// Header Ports
	reg [31:0] header_bus;					// bus to put header from input buffer
	reg [9:0] length;					// length of payload, if any.  will still be 1 if there is none
	reg [1:0] link_number;					// link number to be retreived from header and then used to determine lane processing
	reg [2:0] completion_status;				// completion status to be retreived from completion header and then compared to completer status from subunit

	// Flags
	reg payload_hold;					// flag to hold retreival of new payload until current 2 payloads are processed
	reg expected_completion;				// flag will go high if comparison between completion & completer returns expected - they MATCH
	reg payload_present;					// payload present flag from header
	reg header_complete;					// flag high when header is completely read/filled


// Module Instantiation



// Initialize controls
initial
begin
	payload_control = 0;
	header_control = 0;
	header_complete = 0;
	ready = 1;
end

//RETRIEVING HEADER, COMPLETION STATUS CALCULATION/COMPARISON, PAYLOAD RETRIEVAL
always @(posedge clk)
begin
	header_bus = buffer_in[31:0];						// sort header
	link_number = buffer_in[33:32];						// link number attached to header in 33rd and 32nd bits
		
		
	if (header_control > 0)						// 2nd stage of header retreiver
	begin
		if (header_control == 1)				// middle 32 bit packet of header contains completion status
		begin
			completion_status = header_bus[15:13];
			case (completion_status)
	      			3'b000:					// Successful Completion
	      			begin
	      				compl_status_pass = 0;

					case(completer_status)
					2'b0x:					// Unsupported
					begin
					  	expected_completion = 0;
					end
					2'b10:					// Supported, uncompleted
					begin
						expected_completion = 0;
					end
					2'b11:					// Supported, completed *EXPECTED*
					begin
						expected_completion = 1;
					end
					endcase
	      			end
				3'b001:					// Completion Status unsupported request
				begin
					compl_status_pass = 1;		// Do not get payload

					case(completer_status)
					2'b0x:					// Unsupported *EXPECTED*
					begin
					  	expected_completion = 1;
					end
					2'b1x:					// Supported, uncompleted
					begin
						expected_completion = 0;
					end
			      		endcase
			      	end
		      		3'b010:					// Configuration Request Retry Status
		      		begin
		      			compl_status_pass = 1;		// Do not get payload
	
					case(completer_status)
					2'b0x:					// Unsupported *EXPECTED*
					begin
					  	expected_completion = 1;
					end
					2'b1x:					// Supported, uncompleted or completed
					begin
						expected_completion = 0;
					end
			      		endcase
		      
		      		end 
		      		3'b100:					// Completer Abort, will never get this expected completion status
		      		begin
				end
				default: compl_status_pass = 1;
			endcase 
			
		end

		header_packet[3 - header_control] = header_bus;							// Creating each header packet (0,1,2) from bus
		header_control = header_control - 1;								// Header control counter

		if (expected_completion == 0)									// Check if unexpected output, if there is, throw ABORT into header
		begin
			compl_status_pass = 1;									// skip headers, since it is an ABORT
			header_packet[1][15:13] = 3'b100;							// Completion status set to ABORT, internal error in subunit
		end
		if (header_control == 0)
		begin
			header_complete = 1;									// Header retreival is complete
		end
	end

	else if (length > 0 && payload present == 1 && compl_status_pass == 0 && payload _hold == 0)			// payload processing
	begin
		if (payload_counter <= length)
		begin
			payload1 = payload_bus[64:32];
			payload2 = payload_bus[31:0];
			payload_counter = payload_counter + 1;
			payload_hold = 1;
		end
		else if (payload_counter > length)
		begin
			payload_counter = 0;
		end

	end

	else if (header_control == 0 && header_complete == 0)				// First stage of header retreiver system
	begin
		header_packet[0] = header_bus;						// Initial header packet retreival
		payload_present = header_bus[30];					// checking header for payload present flag
		length = header_bus[9:0];						// retreiving length of payload (if any)
		header_control = 2;
	end
	


end
// Header completion check
// Input payload processing, setting to output payload bus
always @(negedge clk)
begin
	if (header_complete == 1)
	begin
		header_complete = 0;							// RST header complete flag
		header_packet[1][31:16] = completer_ID;					// Completer ID given as parameter from specific subunit
	end
	
	if (payload_counter > 0 && compl_status_pass == 0)				// retreive both payloads for 2 clock cycles each before resetting to grab two more
	begin
		if (payload_ready < 2)
		begin
			payload_out = payload1;
			payload_ready = payload_ready + 1;
		end
		else if (payload_ready < 4)
		begin
			payload_out = payload2;
			payload_ready = payload_ready + 1;
		end
		else if (payload_ready == 4)
		begin
			payload_ready = 0;
			payload_hold = 0;
		end
	end

// output according to link number
always @(negedge clk)
	  if (ready == 1 && buffer_ready == 1  && subunit_stall == 0 && output_buffer_full == 0 && compl_status_pass == 0)
	  begin
	    write <= 1;
	    
	    case (link_number)
	      2'b00:
	      begin
		payload_array[0] = payload_out;						// payload_array is FINAL destination
		header_array[0] = header_packet;					// header_array is FINAL destination		
	      end
	      2'b01:
	      begin
		payload_array[1] = payload_out;
		header_array[1] = header_packet;
	      end
	      2'b10:
	      begin
		payload_array[2] = payload_out;
		header_array[2] = header_packet;
	      end
	      2'b11:
	      begin
		payload_array[3] = payload_out;
		header_array[3] = header_packet;
	      end
	    endcase
	  end

	else if (ready == 1  && subunit_stall = 0 && output_buffer_full == 0 && compl_status_pass == 1)			// ONLY header, when there's no payload
	  begin
	    write <= 1;
	    
	    case (link_number)
	      2'b00:
	      begin
		header_array[0] = header_packet;
	      end
	      2'b01:
	      begin
		header_array[1] = header_packet;
	      end
	      2'b10:
	      begin
		header_array[2] = header_packet;
	      end
	      2'b11:
	      begin
		header_array[3] = header_packet;
	      end
	    endcase
	  end

end

