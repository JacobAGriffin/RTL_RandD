`timescale 1ns / 1ps 
`default_nettype none 

module OLR_Egress (
	data_out0,
	data_out1,
	data_out2,
	data_out3,
	ready,
	header_in,
	payload_in,
	clk,
	reset,
	buffer_ready0,
	buffer_ready1,
	buffer_ready2,
	buffer_ready3
);

// Declare inputs 
	input [103:0] 	header_in;
	input [39:0]	payload_in;
	input		clk,
			reset,
			buffer_ready0,
			buffer_ready1,
			buffer_ready2,
			buffer_ready3;
	
// Declare output ports		    	
	output reg [34:0]	data_out0,
				data_out1,
				data_out2,
				data_out3;
	output reg 		ready;
 
// Declare Middle Ports 
	reg [103:0]	header_register,
			header_temp_register;	
	reg [39:0]	payload_temp_register,
			payload_register;
	reg [9:0]	payload_counter;
	reg [1:0]	header_counter,
			lane_number;
	reg		reset_register,
			header_control,
			payload_control,
			ready_to_depart,
			buffer0_register,
			buffer1_register,
			buffer2_register,
			buffer3_register,
			buffer_ready_stale0,
			buffer_ready_stale1,
			buffer_ready_stale2,
			buffer_ready_stale3;	

// Module Instantiation

always @(posedge clk)
begin	
	reset_register = reset;
	buffer0_register = buffer_ready0;
	buffer1_register = buffer_ready1;
	buffer2_register = buffer_ready2;
	buffer3_register = buffer_ready3;
	header_temp_register = header_in;
	payload_temp_register = payload_in;
	#1
	
	//initialization sequence
	if(reset_register == 1'b1)
	begin
		data_out0 = 35'b0;
		data_out1 = 35'b0;
		data_out2 = 35'b0;
		data_out3 = 35'b0;
		ready = 1'b0;
		header_register = 104'b0;
		payload_register = 40'b0;
		buffer0_register = 1'b0;
		buffer1_register = 1'b0;
		buffer2_register = 1'b0;
		buffer3_register = 1'b0;
		buffer_ready_stale0 = 1'b0;
		buffer_ready_stale1 = 1'b0;
		buffer_ready_stale2 = 1'b0;
		buffer_ready_stale3 = 1'b0;
		header_control = 1'b0;
		payload_control = 1'b0;
		ready_to_depart = 1'b0;
		ready = 1'b1;
		lane_number = 2'b0;
		header_counter = 2'b0;
		payload_counter = 10'b0;
	end

	else	
	begin	
		//HEADER packet setup
		if(header_control == 1'b0 && payload_control == 1'b0 && ready == 1'b1 && header_temp_register != 104'b0)
		begin
			header_register = header_temp_register;
			lane_number = header_register[97:96];
			header_control = 1'b1;
			header_counter = 2'b11;
			ready_to_depart = 1'b1;

			//Memory Read request parameters
			if(header_register [28:24] == 5'b00000 && (header_register [31:29] == 3'b010 || header_register [31:29] == 3'b011))
			begin
				payload_counter = header_register[9:0];
				payload_control = 1'b1;
			end 
		end

		// PAYLOAD
		if (payload_temp_register != 32'b0 && payload_control == 1'b1 && ready == 1'b1)
		begin
			payload_register[31:0] = payload_temp_register[31:0];
			payload_register[33:32] = lane_number;		// LINK NUMBER
			ready_to_depart = 1'b1;
		end

		//if output conditions for buffer0 are met, output data
		if(buffer0_register == 1'b1 && ready_to_depart == 1'b1 && lane_number == 2'b00 && buffer_ready_stale0 == 0)
		begin

			if (header_counter == 2'b11)
			begin
				data_out0 = {3'b100, header_register[31:0]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b10)
			begin
				data_out0 = {3'b100, header_register[63:32]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b1)
			begin
				data_out0 = {3'b100, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b0)
			begin
				data_out0 = {3'b0, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (payload_control == 1'b1 && payload_counter > 0)
			begin
				payload_counter = payload_counter - 1'b1;
				if (payload_counter > 0)
				begin
					data_out0 = {3'b100, payload_register[31:0]};
				end
				else if (payload_counter == 0)
				begin
					data_out0 = {3'b0, payload_register[31:0]};
				end
				payload_register = 40'b0;
			end
			
			if (header_counter == 3'b0 && payload_counter != 10'b0)
			begin
				header_control = 1'b0;
				header_register = 104'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end
			else if (header_counter == 3'b0 && payload_counter == 10'b0)
			begin
				header_control = 1'b0;
				payload_control = 1'b0;
				lane_number = 2'b0;
				payload_register = 40'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end
		end

		//if output conditions for buffer1 are met, output data
		if(buffer1_register == 1'b1 && ready_to_depart == 1'b1 && lane_number == 2'b01 && buffer_ready_stale1 == 0)
		begin
			if (header_counter == 2'b11)
			begin
				data_out1 = {3'b100, header_register[31:0]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b10)
			begin
				data_out1 = {3'b100, header_register[63:32]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b1)
			begin
				data_out1 = {3'b100, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b0)
			begin
				data_out1 = {3'b0, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (payload_control == 1'b1 && payload_counter > 0)
			begin
				payload_counter = payload_counter - 1'b1;
				if (payload_counter > 0)
				begin
					data_out1 = {3'b100, payload_register[31:0]};
				end
				else if (payload_counter == 0)
				begin
					data_out1 = {3'b0, payload_register[31:0]};
				end
				payload_register = 40'b0;
			end
			
			if (header_counter == 3'b0 && payload_counter != 10'b0)
			begin
				header_control = 1'b0;
				header_register = 104'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end
			else if (header_counter == 3'b0 && payload_counter == 10'b0)
			begin
				header_control = 1'b0;
				payload_control = 1'b0;
				lane_number = 2'b0;
				payload_register = 40'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end	
			
		end
	
		//if output conditions for buffer2 are met, output data
		if(buffer2_register == 1'b1 && ready_to_depart == 1'b1 && lane_number == 2'b10 && buffer_ready_stale2 == 0)
		begin
			if (header_counter == 2'b11)
			begin
				data_out2 = {3'b100, header_register[31:0]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b10)
			begin
				data_out2 = {3'b100, header_register[63:32]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b1)
			begin
				data_out2 = {3'b100, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b0)
			begin
				data_out2 = {3'b0, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (payload_control == 1'b1 && payload_counter > 0)
			begin
				payload_counter = payload_counter - 1'b1;
				if (payload_counter > 0)
				begin
					data_out2 = {3'b100, payload_register[31:0]};
				end
				else if (payload_counter == 0)
				begin
					data_out2 = {3'b0, payload_register[31:0]};
				end
				payload_register = 40'b0;
			end

			if (header_counter == 3'b0 && payload_counter != 10'b0)
			begin
				header_control = 1'b0;
				header_register = 104'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end
			else if (header_counter == 3'b0 && payload_counter == 10'b0)
			begin
				header_control = 1'b0;
				payload_control = 1'b0;
				lane_number = 2'b0;
				payload_register = 40'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end	
			
		end

		//if output conditions for buffer3 are met, output data
		if(buffer3_register == 1'b1 && ready_to_depart == 1'b1 && lane_number == 2'b11 && buffer_ready_stale3 == 0)
		begin
			if (header_counter == 2'b11)
			begin
				data_out3 = {3'b100, header_register[31:0]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b10)
			begin
				data_out3 = {3'b100, header_register[63:32]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b1)
			begin
				data_out3 = {3'b100, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (header_counter == 2'b01 && payload_control == 1'b0)
			begin
				data_out3 = {3'b0, header_register[95:64]};
				header_counter = header_counter - 1'b1;
			end
			else if (payload_control == 1'b1 && payload_counter > 0)
			begin
				payload_counter = payload_counter - 1'b1;
				if (payload_counter > 0)
				begin
					data_out3 = {3'b100, payload_register[31:0]};
				end
				else if (payload_counter == 0)
				begin
					data_out3 = {3'b0, payload_register[31:0]};
				end
				payload_register = 40'b0;
			end
			
			if (header_counter == 3'b0 && payload_counter != 10'b0)
			begin
				header_control = 1'b0;
				header_register = 104'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end
			else if (header_counter == 3'b0 && payload_counter == 10'b0)
			begin
				header_control = 1'b0;
				payload_control = 1'b0;
				lane_number = 2'b0;
				payload_register = 40'b0;
				ready_to_depart = 1'b0;
				ready = 1;
			end	
			
		end

		//if the ready signals are low, drop the output
		if(buffer0_register == 1'b0)
		begin
			data_out0 = 35'b0;
		end
		
		if(buffer1_register == 1'b0)
		begin
			data_out1 = 35'b0;
		end

		if(buffer2_register == 1'b0)
		begin
			data_out2 = 35'b0;
		end
		
		if(buffer3_register == 1'b0)
		begin
			data_out3 = 35'b0;
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

		if(buffer3_register == 1'b1)
		begin
			buffer_ready_stale3 = 1'b1;
		end
		else
		begin
			buffer_ready_stale3 = 1'b0;
		end

		if(ready == 1'b1 && ready_to_depart == 1'b1)
		begin
			ready = 1'b0;
		end

		if(ready_to_depart == 1'b1 && header_control == 1'b1 && (data_out0 != 0 || data_out1 != 0 || data_out2 != 0 || data_out3 != 0))
		begin
			ready_to_depart = 1'b0;
		end

		else if(ready_to_depart == 1'b0 && header_control == 1'b1)
		begin
			ready_to_depart = 1'b1;
		end
	end
end
endmodule































 
