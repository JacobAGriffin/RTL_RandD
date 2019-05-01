`timescale 1ns / 1ps 
`default_nettype none 

module OLR_Ingress(
	header_out,
	payload_out,
	ready1,
	ready2,
	payload_in,
	header_in,
	completionstatus_in,
	clk,
	reset,
	sorter_ready
);

// Declare inputs 
	input [34:0] 	header_in;	// Completion header from upstream HSB
	input [31:0]	payload_in;	// Payload from Hardware Subunit
	input [3:0]	completionstatus_in;	//Completion type from Hardware Subunit
	input		clk,	// clock signal
			reset,	//reset signal
			sorter_ready;	// ready signal from downstream Sorter
	
// Declare output ports		    	
	output reg [135:0]	header_out;		//Concatenated input header that is outputted to Sorter to be formed into complete TLP
	output reg [39:0]	payload_out;	// Output payload to Sorter
	output reg 		ready1,		// Ready signal to alert HSIB subsystem that the OLR is ready for header input
				ready2;			// Ready signal to alert Hardware Subunit that the OLR is ready for header input
 
// Declare Middle Ports 

	reg [135:0]	header_register;
	reg [39:0]	header_temp_register,
			payload_register;	
	reg [31:0]	payload_temp_register;
	reg [9:0]	payload_counter,
			mem_write_ready_counter;
	reg [3:0]	completionstatus_temp_register;
	reg [2:0]	header_counter;
	reg		reset_register,
			sorter_ready_register,
			header_control,
			payload_control,
			mem_write_ready_control,
			mem_write_compstatus_wait,
			ready_to_depart;
	

// Module Instantiation

always @(posedge clk)
begin	

	reset_register = reset;
	sorter_ready_register = sorter_ready;
	header_temp_register = header_in;
	payload_temp_register = payload_in;
	completionstatus_temp_register = completionstatus_in;
	#1

	//initialization sequence
	if(reset_register == 1'b1)
	begin
		header_out = 136'b0;
		payload_out = 40'b0;
		ready1 = 1'b1;
		ready2 = 1'b0;
		header_register = 136'b0;
		payload_register = 32'b0;
		payload_counter = 10'b0;
		completionstatus_temp_register = 3'b0;
		header_counter = 3'b0;
		reset_register = 1'b0;
		sorter_ready_register = 1'b0;
		header_control = 1'b0;
		payload_control = 1'b0;
		ready_to_depart = 1'b0;
		mem_write_ready_counter = 10'b0;
		mem_write_ready_control = 1'b0;
		mem_write_compstatus_wait = 1'b0;
	end	

	else
	begin
		//initial header input
		if(header_control == 1'b0 && payload_control == 1'b0 && ready1 == 1'b1 && header_temp_register != 1'b0 && mem_write_ready_control == 0)
		begin
			header_register [31:0] = header_temp_register[31:0];				// Header
			header_register [135] = header_temp_register[34];				// Header of the Header bits
			header_register [129:128] = header_temp_register[33:32];			// Header of the Header bits
			header_counter = 3'b01;
			header_control = 1'b1;
			ready1 = 1'b0;
			
			if(header_register [28:24] == 5'b00000 && (header_register [31:29] == 3'b000 || header_register [31:29] == 3'b001))
			begin
				payload_control = 1'b1;
				payload_counter = header_register[9:0];
			end

		end
		else if (header_control == 1'b1 && header_counter > 3'b0 && ready1 == 1'b1 && header_temp_register != 1'b0)
		begin
			//reads in the 2nd header
			if(header_counter == 3'b001)
			begin
				header_register [63:32] = header_temp_register[31:0];
				header_counter = header_counter + 1'b1;
				ready1 = 1;
			end

			//reads in the 3rd header
			else if(header_counter == 3'b010)
			begin
				header_register [95:64] = header_temp_register[31:0];

				if(header_register[29] == 1'b0)
				begin
					ready1 = 1'b0;
					header_counter = 2'b0;
				end
			
				else if(header_register[29] == 1'b1)
				begin
					ready1 = 1'b1;
					header_counter = header_counter + 1'b1;
				end
			end
		 
			else if (header_counter == 2'b11)
			begin
				header_register [127:96] = header_temp_register[31:0];
				header_counter = 1'b0;
				ready1 = 1'b0;
			end

			if (header_counter == 2'b00 && mem_write_ready_control == 1'b0)
			begin
				 ready2 = 1'b1;
			end
		end

		//handle Memory write payloads
		if (mem_write_ready_control == 1'b1 && ready1 == 1'b0 && mem_write_ready_counter != 10'b0)
		begin
			ready1 = 1'b1;
			mem_write_ready_counter = mem_write_ready_counter - 1'b1;
			if(mem_write_ready_counter == 1'b0)
			begin
				mem_write_ready_control = 1'b0;
				mem_write_compstatus_wait = 1'b1;
				ready1 = 1'b0;
			end
		end
		else if (mem_write_ready_control == 1'b1 && ready1 == 1'b1 && header_temp_register != 40'b0)
		begin
			ready1 = 1'b0;
		end

		else if(header_register [28:24] == 5'b00000 && (header_register [31:29] == 3'b010 || header_register [31:29] == 3'b011) && header_counter == 3'b0 && mem_write_ready_control == 1'b0 && mem_write_ready_counter == 10'b0 && mem_write_compstatus_wait == 1'b0)
		begin
			mem_write_ready_control = 1'b1;
			mem_write_ready_counter = header_register[9:0] + 1'b1;
		end

		//completion status
		if (completionstatus_temp_register != 4'b0 && ready2 == 1'b1 && header_control == 1'b1)
		begin
			header_register[132:130] = completionstatus_temp_register[2:0];
			ready2 = 1'b0;
			ready_to_depart = 1'b1;
			mem_write_compstatus_wait = 1'b0;

			if (payload_control == 1'b1)
			begin
				payload_register[31:0] = payload_temp_register;
				payload_register[33:32] = header_register[129:128];		// LINK NUMBER
				payload_counter = payload_counter - 1'b1;
			end
		end


		// PAYLOAD
		else if (payload_temp_register != 32'b0 && payload_control == 1'b1 && ready2 == 1'b1 && header_control == 1'b0)
		begin
			payload_register[31:0] = payload_temp_register;
			payload_register[33:32] = header_register[129:128];		// LINK NUMBER
			payload_counter = payload_counter - 1'b1;
			ready_to_depart = 1'b1;

			if (payload_counter > 1'b0)
			begin
				payload_register[39] = 1'b1;
			end

			else if (payload_counter == 1'b0)
			begin
				payload_register[39] = 1'b0;
			end

		end


		// OUTPUT HEADER
		if (ready_to_depart == 1'b1 && sorter_ready_register == 1'b1 && header_control == 1'b1)
		begin
			header_out = header_register;
			header_control = 1'b0;
			if(payload_control == 1'b1)
			begin
				ready_to_depart = 1'b1;
			end
			else if(payload_control == 1'b0)
			begin
				ready_to_depart = 1'b0;
				header_register = 1'b0;
				ready1 = 1'b1;
			end
		end

		// OUTPUT PAYLOAD
		else if (ready_to_depart == 1'b1 && sorter_ready_register == 1'b1 && payload_control == 1'b1 && header_control == 1'b0 && header_out == 136'b0)
		begin
			

			payload_out = payload_register;
			payload_register = 0;
			ready_to_depart = 1'b0;

			if (payload_counter > 10'b0)
			begin
				ready2 = 1'b1;
			end
			else if (payload_counter == 10'b0)
			begin
				payload_control = 1'b0;
				ready1 = 1'b1;
				header_register = 1'b0;
			end
		end
		

		//if the ready signals are low, drop the output
		if (sorter_ready_register == 1'b0)
		begin
			header_out = 136'b0;
			payload_out = 40'b0;
		end

		if (ready1 == 1'b1 && (header_counter > 0 || ready_to_depart == 1'b1) && header_temp_register != 40'b0)
		begin
			ready1 = 1'b0;
		end

		else if(ready1 == 1'b0 && header_counter > 0 && header_temp_register == 40'b0)
		begin
			ready1 = 1'b1;
		end
		
		if (ready2 == 1'b1 && payload_temp_register != 32'b0)
		begin
			ready2 = 1'b0;
		end


	end
end
endmodule
















 
