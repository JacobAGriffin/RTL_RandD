`timescale 1ns / 1ps 
`default_nettype none 

module HardwareSubunit #(
	parameter DELAY = 25
) (
	clk,
	reset,
	in_data,
	next_ready,
	out_data,
	completion_status
);

	// Declare input ports

	input	[34:0] 	in_data;
	input 	clk,
		reset,
		next_ready;
		
	// Declare output ports

	output reg [31:0] out_data; 	// Output data
	output reg [3:0] completion_status;

	// Declare Middle Ports
	
	reg [63:0]	address; //address of data to be accessed
	reg [31:0]	middle_in_data,
			old_data;
	reg [9:0]		payload_length; //Amount of payload to write or to read
	reg [7:0]		TLP_TFMT,	//Type and Format fields of TLP
						delay_counter;	//Counts up to DELAY
	reg [1:0]		TLP_counter;	//How many more TLP's are coming
	reg 	middle_next_ready,
		broken,
		middle_reset,
		size;		//1 if TLP is 128, 0 if TLP is 96

	//Generate Block

	//Assign Statements

	//Always Blocks
	
	always @(posedge clk)
	begin
		middle_in_data = in_data[31:0];
		middle_next_ready = next_ready;
		middle_reset = reset;
		#1
		if (middle_reset == 1'b1)
		begin
			address = 64'b0;
			middle_in_data = 32'b0;
			old_data = 32'b0;
			payload_length = 10'b0;
			TLP_TFMT = 8'b0;
			delay_counter = 0;
			TLP_counter = 2'b0;
			middle_next_ready = 1'b0;
			size = 1'b0;
			out_data = 32'b0;
			completion_status = 4'b0;
			broken = 1'b0;
		end
		else 
		begin
			if (middle_in_data != 0 && payload_length == 0 && TLP_counter == 0 && delay_counter == 0) //Start of TLP packet
			begin
				TLP_TFMT = middle_in_data[31:24];
				if (TLP_TFMT[4:0] == 5'b00000) //memory request
				begin
					if (TLP_TFMT[7:5] == 3'b000) //96-bit memory read
					begin
						TLP_counter = 2'b10;
						size = 1'b0;
					end
					else if (TLP_TFMT[7:5] == 3'b001) //128-bit memory read
					begin
						TLP_counter = 2'b11;
						size = 1'b1;
					end
					else if (TLP_TFMT[7:5] == 3'b010) //96-bit memory write
					begin
						TLP_counter = 2'b10;
						size = 1'b0;
					end
					else if (TLP_TFMT[7:5] == 3'b011) //128-bit memory write
					begin
						TLP_counter = 2'b11;
						size = 1'b1;
					end
					payload_length = middle_in_data[9:0]; //size of payload
				end
				else if (TLP_TFMT[4:0] == 5'b00010) //IO request
				begin
					size = 1'b0;
					TLP_counter = 2'b10;
					payload_length = 0;
				end
				else if (TLP_TFMT[4:0] == 5'b00100 || TLP_TFMT[4:0] == 5'b00101) //configuration request
				begin
					size = 1'b0;
					TLP_counter = 2'b10;
					payload_length = 0;
				end
				else //unknown TLP type
				begin
					broken = 1'b1;
				end
			end
			else if (old_data != middle_in_data && middle_in_data != 0 && TLP_counter != 0) //finish reading TLP
			begin
				TLP_counter = TLP_counter - 1'b1;
				if (TLP_TFMT[4:0] != 5'b00100 && TLP_TFMT[4:0] != 5'b00101) //not a configuration
				begin
					if (size == 1'b1 && TLP_counter == 2'b01) //128-bit memory request
					begin
						address[63:32] = middle_in_data;
					end
					if (TLP_counter == 2'b00)
					begin
							address[31:0] = middle_in_data;
							delay_counter = DELAY; //set delay
					end
				end
				else //set configuration delay
				begin
					delay_counter = DELAY; //set delay
				end
			end
			else if (TLP_counter == 0 && (payload_length != 0 || delay_counter !=0)) //handling payload
			begin
				if (TLP_TFMT[4:0] == 5'b00000 && (TLP_TFMT[7:5] == 3'b000 || TLP_TFMT[7:5] == 3'b001)) //memory read
				begin
					if (delay_counter != 0)
					begin
						delay_counter = delay_counter - 1; //decrement delay
					end
					else if (delay_counter == 0 && payload_length != 0 && middle_next_ready == 1 && out_data == 0)
					begin
						out_data = ~(address[47:16]);
						payload_length = payload_length - 1'b1;
						completion_status = 4'b1000;
					end
					if (payload_length == 0)
					begin
						address = 64'b0;
						TLP_TFMT = 8'b0;
						TLP_counter = 2'b0;
						size = 1'b0;
					end
				end
				else if ((TLP_TFMT[4:0] == 5'b00000 && (TLP_TFMT[7:5] == 3'b010 || TLP_TFMT[7:5] == 3'b011)) || TLP_TFMT[4:0] == 5'b00010 || TLP_TFMT[4:0] == 5'b00100 || TLP_TFMT[4:0] == 5'b00101) //memory write, IO, or Configuration
				begin
					if (old_data != middle_in_data && middle_in_data != 0 && delay_counter == DELAY && payload_length != 0)
					begin
						payload_length = payload_length - 1'b1;
					end
					else if (payload_length == 0)
					begin
						delay_counter = delay_counter - 1; //decrement delay
					end
					if (middle_next_ready == 1 && delay_counter == 0)
					begin
						out_data = 32'b0;
						completion_status = 4'b1000;
						address = 64'b0;
						TLP_TFMT = 8'b0;
						TLP_counter = 2'b0;
						size = 1'b0;
					end
				end
			end


			if (old_data != middle_in_data)
			begin
				old_data = middle_in_data;
			end
			
			if (middle_next_ready == 0)
			begin
				out_data = 32'b0;
				completion_status = 4'b0;
			end
		end
	end

endmodule
