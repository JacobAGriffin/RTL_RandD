`timescale 1ns / 1ps 
`default_nettype none 

module InputLinkRouter #(
	parameter LINK_NUMBER = 0,
	parameter DATA_WIDTH = 32,
	parameter SUBUNIT_QUANTITY = 0
) (
	out_data,
	ready,
	header_out,
	transmit_link_output_buffer_full,
	hardware_subunit_input_buffer_full,
	clk,
	in_data,
	op_complete,
	next_ready
); 

// Declare inputs 
	input	transmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
	input	[3:0] hardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
	input   clk;
	input [DATA_WIDTH-1:0] in_data; 	    	// Input data 
	input	op_complete;
	input	next_ready;
	
// Declare output ports		    	
	output reg 	[DATA_WIDTH-1:0] out_data; 	// Output data
	output reg 	ready;
	output reg	[127:0] header_out;
 
// Declare Middle Ports 
	reg [9:0] length_reg; 
	reg header_complete_flag;	//flag that indicates we have received the full header from phys. layer
	reg header_format;		//Determines Header length(3DW or 4DW)
	reg [1:0] header_control;
	reg payload_present;
	reg data_gone;
	reg payload_ready_to_depart;
	reg ready_wait;
	reg [9:0] payload_control;
	reg [DATA_WIDTH-1:0] fixed_in_data;
	reg [31:0] payload;
	reg [31:0] header [3:0];

// Module Instantiation

	initial
	begin
		ready <= 0;
		header_control <= 0;
		payload_control <= 0;
		header_complete_flag <= 0;
		ready_wait <= 0;
		data_gone <= 0;
		payload <= 0;
		payload_ready_to_depart <= 0;
		payload_present <= 0;
		header_format <= 0;
		fixed_in_data <= 0;
		out_data <= 0;
		header_out <= 0;
	end

	always @(posedge clk)
	begin
		
		if (transmit_link_output_buffer_full == 0 && hardware_subunit_input_buffer_full == 0 && ready_wait == 0)
		begin
			fixed_in_data[31:24] = in_data[7:0];
			fixed_in_data[23:16] = in_data[15:8];
			fixed_in_data[15:8] = in_data[23:16];
			fixed_in_data[7:0] = in_data[31:24];	
			if (header_control > 0)
			begin 
				header [4-header_control - (1-header_format) ] = fixed_in_data;
				header_control = header_control -1;
				if(header_control == 0)
				begin
					header_complete_flag = 1;
				end	
			end 
	
			else if (payload_control > 0 && payload_present == 1 && payload_ready_to_depart == 0)
			begin
				payload = fixed_in_data;
				payload_ready_to_depart = 1;
				payload_control = payload_control - 1;
			end

			else if (header_control == 0 && header_complete_flag == 0)
			begin
				header[0] = fixed_in_data;
				header_format = fixed_in_data [29];
				payload_present = fixed_in_data [30];			
				payload_control = fixed_in_data [9:0];
				header_control = 2 + header_format;
				if(header_format == 0)
				begin
					header[3] = 0;
				end
			end
		end
		if(ready_wait == 1)
		begin
			ready_wait = 0;
		end
		if(op_complete == 1)
		begin
			data_gone = 0;
		end
	end

	always @(negedge clk)
	begin

		if (header_complete_flag == 1 && next_ready == 1)
		begin
			header_complete_flag = 0;
			ready_wait = 1;
			data_gone = 1;
			header_out = {header[3], header[2], header[1], header[0]};
			header [3] = 0;
			header [2] = 0;
			header [1] = 0;
			header [0] = 0;
		end

		else if (data_gone == 0 && payload_ready_to_depart == 1 && next_ready == 1)
		begin
			out_data = payload;
			payload_ready_to_depart = 0;
			payload = 0;
		end
				
		if (transmit_link_output_buffer_full == 0 && data_gone == 0 && ready == 0)
		begin
			ready =1;
			ready_wait = 1;
		end
	
		else if(ready == 1 && in_data != 0)
		begin
			ready = 0;
		end
		
	end		
		


//multiwidth = bit 39
//link number = bit 33 and 32
//data = 31-0

	
endmodule 
