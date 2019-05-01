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
	input [31:0] 	data_in;		//incoming data stream
	input		clk,			//clock signal
			reset,			//resets the ILR to a ready state, always need to start a test with a reset
			buffer_ready0,		//ready signal originating from buffer 0(configuration in this instance)
			buffer_ready1,		//ready signal originating from buffer 1(memory operations in this instance)
			buffer_ready2;		//ready signal originating from buffer 2(I/O operations)
	
// Declare output ports		    	
	output reg [34:0]	data_out0,	//output data stream to buffer 0 (35 bits to account for extra flags included)
				data_out1,	//output data stream to buffer 1
				data_out2;	//output data stream to buffer 2
	output reg 		ready;		//ready signal to the Testbench to signal when the ILR is ready to receive data
 
// Declare Middle Ports 
	reg [34:0] 	middle_register;	//register that takes data from the temporary register, and holds TLP and flag blocks prior to output
	reg [31:0]	input_register;		//temporary register that holds input TLP information
	reg [9:0]	payload_counter;	//specifies the amount of payload in memory writes, used to ensure the correct amount of payload is passed through
	reg [2:0]	header_counter;		//specifies whether the header is 96 or 128 bits long, used to ensure that correct amount of header is passed
	reg [1:0]	TLP_TFMT;		//specifies what type of TLP is being passed, used to route the TLP to the correct lane
	reg 		reset_register,		//register that holds the reset signal
			buffer0_register,	//when buffer 0 ready signal is received, it is written into this register, this also helps provide the necessary delay used in the timing scheme
			buffer1_register,	//when buffer 1 ready signal is received, it is written into this register, this also helps provide the necessary delay used in the timing scheme
			buffer2_register,	//when buffer 2 ready signal is received, it is written into this register, this also helps provide the necessary delay used in the timing scheme
			header_control,		//specifies whether header is currently being handled or not, is set on the first header received and stays high until the last header is output
			payload_control,	//specifies whether the ILR has handled all of the incoming payload on the current TLP (if any), when header control and payload control are 0, the next incoming data set will be the beginning of a new TLP
			ready_to_depart,	//when the necessary flags have been attached to the current data being held, this is set high so the ILR knows it can output the data
			buffer_ready_stale0,	//this flag and stale 1 and stale 2 is used to ensure the timing scheme works correctly 
			buffer_ready_stale1,	//there was a bug, where the buffer would signal ready at the same time as data would be received, and it would cause the data
			buffer_ready_stale2,	//to be output too late (and not be picked up by the buffer)
			internal_reset;		//if there is a invalid TLP (shouldn't happen, but incase there is) reset the system and wait for a valid one

// Module Instantiation

always @(posedge clk)
begin	
	//always set the input buffers to read from the input data lines (this data is not always used however)
	reset_register = reset;
	input_register = data_in;
	buffer0_register = buffer_ready0;
	buffer1_register = buffer_ready1;
	buffer2_register = buffer_ready2;
	//#1 to simulate the functionality of a physical system(can be removed on physical implementations)
	#1
	
	//initialization sequence
	//resets the ILR to the beginning state, this is always needed to clear x's at the beginnging of simulation
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
			middle_register [31:0] = input_register;	//read in the header data
			middle_register [33:32] = LINK_NUMBER;		//set the originating lane assignment flags (LINK_NUMBER set in FPGA_Project.v)
			middle_register [34] = 1'b1;			//set the multiwidth flag high
			ready_to_depart = 1'b1;				//now that all flags and data are read in, this can be departed
			ready = 1'b0;					//tell the testbench the ILR is not ready until this data has been sent to the buffer

			//The next sections determine where the TLP is to be routed to

			//Configuration request parameters
			if(middle_register [28:24] == 5'b00100 || middle_register [28:24] == 5'b00101)
			begin
				TLP_TFMT = 2'b01;		//Configurations go to hardware subunit 0 in our design
				header_control = 1'b1;		//set header_control as we have read in a header
				header_counter = 3'b011;	//configurations are always 96 bits, therefore set header_counter to 3
			end
		
			//Memory Write request parameters
			else if(middle_register [28:24] == 5'b00000 && (middle_register [31:29] == 3'b010 || middle_register [31:29] == 3'b011))
			begin
				TLP_TFMT = 2'b10;				//memory writes go to hardware subunit 1 in our design
				header_control = 1'b1;				//set header_control as we have read in a header
				header_counter = 3'b011 + middle_register[29];	//memory write can be either 96 or 128 bits, bit 29 on the initial TLP specifies which, therefore it is used to set header_counter 
				payload_counter = middle_register[9:0];		//memory write should contain payload, therefore set payload counter to the expected amount of payload
				if(payload_counter != 0)
				begin	
					payload_control = 1'b1;			//if we have payload, set payload control until it is all sent through
				end
			end

			//Memory Read request parameters
			else if(middle_register [28:24] == 5'b00000 && (middle_register [31:29] == 3'b000 || middle_register [31:29] == 3'b001))
			begin
				TLP_TFMT = 2'b10;				//memory reads also go to hardware subunit 1 in our design
				header_control = 1'b1;				//set header_control as we have read in header
				header_counter = 3'b011 + middle_register[29];	//memory read can be either 96 or 128 bits, bit 29 on the initial TLP specifies which, therefore it is used to set header_counter
			end 
		
			//I/O request parameters
			else if(middle_register [28:24] == 5'b00010)
			begin
				TLP_TFMT = 2'b11;				//I/O operations go to hardware subunit 2 in our design
				header_control = 1'b1;				//set header_control as we have read in header
				header_counter = 3'b011;			//I/O will always be 96 bits, therefore set header_counter to 3
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
			middle_register [31:0] = input_register;	//read in subsequent header or payload data		
			middle_register [33:32] = LINK_NUMBER;		//set the originating lane flags (LINK_NUMBER set in FPGA_Project.v) 
			ready_to_depart = 1'b1;				//set the payload to be ready to depart
			ready = 1'b0;					//turn ready low until the current block of data is output

			//on the last cycle, drop Multi-Width flag
			if(header_counter == 3'b001 && payload_counter == 10'b0)	
			begin
				middle_register [34] = 1'b0;		//if this is the last header, and there is no payload then signal that this is the last block of data in this TLP
			end
			
			else if(header_counter == 1'b0 && payload_counter == 10'b0000000001)
			begin
				middle_register[34] = 1'b0;		//else, if this is the last payload, then signal that this is the last block of data in the TLP
			end
		
			//if it is not the last cycle, leave Multi-Width flag high
			else
			begin
				middle_register[34] = 1'b1;		//otherwise, if it is not the last block of data then leave the multiwidth flag high
			end
		end



		//if the ready signals from the buffers are low, drop the output
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
			data_out0 <= middle_register;		//output the data (set data onto output line)
			ready_to_depart = 1'b0;			//no longer ready to depart as data is now gone
			middle_register <= 1'b0;		//clear the middle register to read in new data
			header_counter = header_counter - 1'b1;	//subtract one from the header_counter(configurations have no payload)
			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;		//if there is no more header data, drop header control so the ILR knows the next block of data is a new TLP 
				TLP_TFMT <= 1'b0;		//clear the register that specifies which lane the TLP is to go to
			end
		end
		
		//if output conditions for buffer1 are met, output data
		else if(buffer1_register == 1'b1 && ready_to_depart == 1'b1 && TLP_TFMT == 2'b10 && buffer_ready_stale1 != 1'b1 && (header_control == 1'b1 || payload_control == 1'b1))
		begin
			data_out1 <= middle_register;					//output the data
			ready_to_depart = 1'b0;						//no longer ready to depart as data is now gone
			middle_register <= 35'b0;					//clear the middle register to read in new data
			if(header_control == 1'b1)
			begin
				header_counter = header_counter - 1'b1;			//as long as we are still handling headers, subtract one from the counter until it hits 0 (signaling all header data has been output)
			end
			else if(header_control == 1'b0 && payload_control == 1'b1)
			begin
				payload_counter = payload_counter - 1'b1;		//if we are no longer handling headers, but instead payload then subtract one from the payload counter until it reaches 0 
			end

			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;					//if we have finished outputting header, drop header_control
				if(payload_counter == 10'b0)	
				begin
					payload_control <= 1'b0;			//if we have also finished outputting payload, drop payload_control
					TLP_TFMT <= 2'b00;				//after header and payload have been finished, reset the destination flags
				end
			end
		end

		//if output conditions for buffer2 are met, output data
		else if(buffer2_register == 1'b1 && ready_to_depart == 1'b1 && TLP_TFMT == 2'b11 && buffer_ready_stale2 != 1'b1)
		begin
			data_out2 <= middle_register;			//output the data
			ready_to_depart = 1'b0;				//no longer ready to depart as data is now gone
			middle_register <= 35'b0;			//clear the middle register to read in new data
			header_counter = header_counter - 1'b1;		//subtract one from the header_counter (until it is 0)
			if(header_counter == 3'b0)
			begin
				header_control <= 1'b0;			//when all header has been output, drop header_control to signal the next 32 bit block will be a new TLP
				TLP_TFMT <= 2'b0;			//reset the destination flags
			end
		end

		//if not ready to depart(i.e. are not holding data) then signal that the ILR is ready to handle more data
		else if(ready_to_depart != 1'b1)
		begin
			ready <= 1'b1;
		end
	
		//if we are currently ready, and ready_to_depart is high then we should not be ready (this is here as a bug fix)
		if(ready == 1'b1 && ready_to_depart == 1'b1)
		begin
			ready <= 1'b0;
		end

		//once buffers have been high for one cycle, they are stale and we do not want to output to them
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
