`timescale 1ns / 1ps 
`default_nettype none 

module InputLinkRouterIngress #(
	parameter LINK_NUMBER = 0,
	parameter DATA_WIDTH = 32,
	parameter SUBUNIT_QUANTITY = 0
) (
	payload_out,
	ready,
	header_out,
	transmit_link_output_buffer_full,
	hardware_subunit_input_buffer_full,
	clk,
	in_data,
	next_ready
); 

// Declare inputs 
	input	transmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
	input	[3:0] hardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
	input   clk;
	input 	[DATA_WIDTH-1:0] in_data; 	    	// Input data 
	input	next_ready;
	
// Declare output ports		    	
	output reg 	[DATA_WIDTH-1:0] payload_out; 	// Output data
	output reg 	ready;
	output reg	[127:0] header_out;
 
// Declare Middle Ports 
	reg [9:0] length_reg; 
	reg header_complete_flag;	//flag that indicates we have received the full header from phys. layer
	reg header_format;		//Determines Header length(3DW or 4DW)
	reg [1:0] header_control;
	reg payload_present;
	reg payload_ready_to_depart;
	reg [9:0] payload_control;
	reg [DATA_WIDTH-1:0] fixed_in_data;
	reg [31:0] payload;
	reg [31:0] header [3:0];
	reg header_ready;
	reg data_clear;
	reg incoming_data;
	reg stall;

// Module Instantiation

	initial
	begin
		//initialize middle ports
		ready <= 0;
		header_control <= 0;
		payload_control <= 0;
		header_complete_flag <= 0;
		payload <= 0;
		payload_ready_to_depart <= 0;
		payload_present <= 0;
		header_format <= 0;
		fixed_in_data <= 0;
		payload_out <= 0;
		header_out <= 0;
		data_clear <= 0;
		header_ready <= 0;
		incoming_data <= 0;
		stall <= 0;
	end

	always @(posedge clk)
	begin
		//if there are no stalls, perform the next operation
		if (transmit_link_output_buffer_full == 0 && hardware_subunit_input_buffer_full == 0)
		begin
			//rearrange input bytes to correct format
			fixed_in_data[31:24] = in_data[7:0];
			fixed_in_data[23:16] = in_data[15:8];
			fixed_in_data[15:8] = in_data[23:16];
			fixed_in_data[7:0] = in_data[31:24];	
			
			//if more header data is needed, retrieve it until header is complete
			if (header_control > 0 && ready == 1 && in_data)
			begin 
				header [4-header_control - (1-header_format) ] = fixed_in_data; //place the newest set of data into the correct header slot
				header_control = header_control -1;	//iterate header_control counter

				if(header_control == 0)
				begin
					header_complete_flag = 1;	//when header is full, set header_complete_flag
					header_format = 0;		//drop header_format flag
				end	
			end 
	
			//if there is a payload, grab it one DW at a time, once the header has been completed and reformatted
			else if (payload_control > 0 && payload_present == 1 && payload_ready_to_depart == 0 && header_control == 0 && ready == 1)
			begin
				payload = fixed_in_data;	//input payload into payload register
			end
			//if there is no more header or payload data, grab the next packet when ready
			else if (header_control == 0 && header_complete_flag == 0 && in_data && payload_control == 0 && ready == 1)
			begin
				
				header[0] = fixed_in_data;
				header_format = fixed_in_data [29];	//specifies if header is 3 or 4 DW long
				payload_present = fixed_in_data [30];	//states that payload is to be anticipated		
				payload_control = fixed_in_data [9:0];	//register used to know how much payload exists
				header_control = 2 + header_format;	//header_control determines how many header fields get filled
				if(header_format == 0)
				begin
					header[3] = 0;
				end
			end

		end
		
		//if the next stage has read the data, then clear the outputs
		if(next_ready == 0)
		begin
			data_clear = 1;
		end
		
		//if the next_ready signal is received, then output header or payload data on next negedge
		if(next_ready == 1 && header_complete_flag == 1)
		begin
			header_ready = 1;
		end

		if(next_ready == 1 && payload != 0)
		begin
			payload_ready_to_depart = 1;
		end
		
		//flag manipulation for ready signal control
		if(in_data != 0)
		begin
			incoming_data = 1;
		end
		else if(in_data == 0)
		begin
			incoming_data = 0;
		end

		//flag manipulation for stalls
		if(transmit_link_output_buffer_full == 1 || hardware_subunit_input_buffer_full == 1)
		begin
			stall = 1;
		end
		
	end

	always @(negedge clk)
	begin
	//write on negative edge

		//if the next stage is ready and header has been completed, output header data and reset header
		if (header_ready == 1)
		begin
			header_complete_flag = 0;	//once header is sent off, there is no longer header data	
			header_out = {header[3], header[2], header[1], header[0]};
			header_ready = 0;
		end

		//if the header has been processed by the next stage, and is ready for payload, send the payload
		else if (payload_ready_to_depart == 1)
		begin
			payload_control = payload_control - 1;	//iterate payload counter
			header_out = 0;
			payload_out = payload;
			payload_ready_to_depart = 0;
			payload = 0;
		end
		
		//if there are no stalls, and we are not currently ready, set ready high		
		if (stall == 0 && ready == 0 && incoming_data == 0)
		begin
			ready = 1;
		end

		//if we are ready, and we read in data, then set ready low	
		else if(ready == 1 && incoming_data == 1)
		begin
			ready = 0;
		end
		
		//if data_clear flag is high, reset the flag and clear outputs
		if(data_clear == 1)
		begin
			header_out = 0;
			payload_out = 0;
			data_clear = 0;
		end

	end		
	
endmodule 
