`timescale 1ns / 1ps 
`default_nettype none 

module ILR #(
	parameter LINK_NUMBER = 0
) (
	data_out0,
	data_out1,
	data_out2,
	ready,
	data_in,
	clk,
	reset,
	buffer_ready0,
	buffer_ready1,
	buffer_ready2
);

// Declare inputs 
	input [31:0] 	data_in;
	input		clk,
			reset,
			buffer_ready0,
			buffer_ready1,
			buffer_ready2;
	
// Declare output ports		    	
	output reg [34:0]	data_out0,
				data_out1,
				data_out2;
	output reg 		ready;
 
// Declare Middle Ports 
	reg [34:0] 	middle_register;
	reg [31:0]	input_register;
	reg [9:0]	payload_counter;
	reg [2:0]	header_counter;
	reg [1:0]	TLP_TFMT;
	reg 		reset_register,
			buffer0_register,
			buffer1_register,
			buffer2_register,
			header_control,
			payload_control,
			ready_to_depart,
			buffer_ready_stale0,
			buffer_ready_stale1,
			buffer_ready_stale2,
			internal_reset;		

// Module Instantiation

always @(posedge clk)
begin	
	reset_register = reset;
	input_register = data_in;
	buffer0_register = buffer_ready0;
	buffer1_register = buffer_ready1;
	buffer2_register = buffer_ready2;
	#1
	
	//initialization sequence
	if(reset_register == 1'b1 || internal_reset == 1'b1)
	begin
		data_out0 = 35'b0;
		data_out1 = 35'b0;
		data_out2 = 35'b0;
		ready = 1'b0;
		input_register = 32'b0;
		middle_register = 35'b0;
		payload_counter = 10'b0;
		TLP_TFMT = 3'b000;
		header_counter = 3'b000;
		buffer0_register = 1'b0;
		buffer1_register = 1'b0;
		buffer2_register = 1'b0;
		header_control = 1'b0;
		payload_control = 1'b0;
		ready_to_depart = 1'b0;
		internal_reset = 1'b0;
		buffer_ready_stale0 = 1'b0;
		buffer_ready_stale1 = 1'b0;
		buffer_ready_stale2 = 1'b0;
		ready = 1'b1;
	end

	else	
	begin	
		//initial packet setup
		if(header_control == 1'b0 && payload_control == 1'b0 && ready == 1 && input_register != 0)
		begin
			middle_register [31:0] = input_register;
			middle_register [33:32] = LINK_NUMBER;
			middle_register [34] = 1'b1;
			ready_to_depart = 1'b1;
			ready = 1'b0;

			//Configuration request parameters
			if(middle_register [28:24] == 5'b00100 || middle_register [28:24] == 5'b00101)
			begin
				TLP_TFMT = 2'b01;
				header_control = 1'b1;
				header_counter = 3'b011;
			end
		
			//Memory Write request parameters
			else if(middle_register [28:24] == 5'b00000 && (middle_register [31:29] == 3'b010 || middle_register [31:29] == 3'b011))
			begin
				TLP_TFMT = 2'b10;
				header_control = 1'b1;
				header_counter = 3'b011 + middle_register[29]; 
				payload_counter = middle_register[9:0];
				if(payload_counter != 0)
				begin	
					payload_control = 1'b1;
				end
			end

			//Memory Read request parameters
			else if(middle_register [28:24] == 5'b00000 && (middle_register [31:29] == 3'b000 || middle_register [31:29] == 3'b001))
			begin
				TLP_TFMT = 2'b10;
				header_control = 1'b1;
				header_counter = 3'b011 + middle_register[29];
			end 
		
			//I/O request parameters
			else if(middle_register [28:24] == 5'b00010)
			begin
				TLP_TFMT = 2'b11;
				header_control = 1'b1;
				header_counter = 3'b011;
			end  
			
			//if it is an invalid TLP, reset
			else
			begin
				internal_reset = 1'b1;
			end   
		end

		//all subsequent packet setup
		else if((header_control == 1'b1 || payload_control == 1'b1) && ready == 1'b1 && input_register != 1'b0)
		begin
			middle_register [31:0] = input_register;
			middle_register [33:32] = LINK_NUMBER;
			ready_to_depart = 1'b1;
			ready = 1'b0;

			//on the last cycle, drop Multi-Width flag
			if(header_counter == 3'b001 && payload_counter == 10'b0)
			begin
				middle_register [34] = 1'b0;
			end
			
			else if(header_counter == 1'b0 && payload_counter == 10'b0000000001)
			begin
				middle_register[34] = 1'b0;
			end
		
			//if it is not the last cycle, leave Multi-Width flag high
			else
			begin
				middle_register[34] = 1'b1;
			end
		end

		//if the ready signals are low, drop the output
		if(buffer0_register == 1'b0)
		begin
			data_out0 <= 35'b0;
		end
		
		if(buffer1_register == 1'b0)
		begin
			data_out1 <= 35'b0;
		end

		if(buffer2_register == 1'b0)
		begin
			data_out2 <= 35'b0;
		end

		//if output conditions for buffer0 are met, output data
		if(buffer0_register == 1'b1 && ready_to_depart == 1'b1 && TLP_TFMT == 2'b01 && buffer_ready_stale0 != 1'b1)
		begin
			data_out0 <= middle_register;
			ready_to_depart = 1'b0;
			middle_register <= 1'b0;
			header_counter = header_counter - 1'b1;
			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;
				TLP_TFMT <= 1'b0;
			end
		end
		
		//if output conditions for buffer1 are met, output data
		else if(buffer1_register == 1'b1 && ready_to_depart == 1'b1 && TLP_TFMT == 2'b10 && buffer_ready_stale1 != 1'b1 && (header_control == 1'b1 || payload_control == 1'b1))
		begin
			data_out1 <= middle_register;
			ready_to_depart = 1'b0;
			middle_register <= 35'b0;
			if(header_control == 1'b1)
			begin
				header_counter = header_counter - 1'b1;
			end
			else if(header_control == 1'b0 && payload_control == 1'b1)
			begin
				payload_counter = payload_counter - 1'b1;
			end

			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;
				if(payload_counter == 10'b0)	
				begin
					payload_control <= 1'b0;
					TLP_TFMT <= 2'b00;
				end
			end
		end

		//if output conditions for buffer2 are met, output data
		else if(buffer2_register == 1'b1 && ready_to_depart == 1'b1 && TLP_TFMT == 2'b11 && buffer_ready_stale2 != 1'b1)
		begin
			data_out2 <= middle_register;
			ready_to_depart = 1'b0;
			middle_register <= 35'b0;
			header_counter = header_counter - 1'b1;
			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;
				TLP_TFMT <= 2'b0;
			end
		end

		else if(ready_to_depart != 1'b1)
		begin
			ready <= 1'b1;
		end
	
		if(ready == 1'b1 && ready_to_depart == 1'b1)
		begin
			ready <= 1'b0;
		end

		if(buffer0_register == 1'b1)
		begin
			buffer_ready_stale0 = 1'b1;
		end
		else
		begin
			buffer_ready_stale0 = 1'b0;
		end

		if(buffer1_register == 1'b1)
		begin
			buffer_ready_stale1 = 1'b1;
		end
		else
		begin
			buffer_ready_stale1 = 1'b0;
		end

		if(buffer2_register == 1'b1)
		begin
			buffer_ready_stale2 = 1'b1;
		end
		else
		begin
			buffer_ready_stale2 = 1'b0;
		end
	end
end
endmodule































 
