`timescale 1ns / 1ps 
`default_nettype none 

module BufferMux (
	clk,
	reset,
	next_ready,
	mem_full,
	in_data0,
	ready0,
	in_data1,
	ready1,
	in_data2,
	ready2,
	in_data3,
	ready3,
	out_data
);

// Declare input ports

	input 	clk,
		reset,
		next_ready,
		mem_full;
	input	[34:0] 	in_data0,
			in_data1,
			in_data2,
			in_data3;
		
// Declare output ports

	output reg [34:0] out_data; 	// Output data
	output reg	ready0,
			ready1,
			ready2,
			ready3;
// Declare Middle Ports

	reg 	[1:0] selector;
	reg 	[34:0] 	middle_in_data0,
			middle_in_data1,
			middle_in_data2,
			middle_in_data3,
			muxed_data;
	reg 	middle_next_ready,
		middle_mem_full,
		multiwidth,
		middle_reset,
		data_sent,
		ready_wait,
		ready_logic;

//Always Blocks

	always @(posedge clk)
	begin
		middle_in_data0 = in_data0;
		middle_in_data1 = in_data1;
		middle_in_data2 = in_data2;
		middle_in_data3 = in_data3;
		middle_next_ready = next_ready;
		middle_mem_full = mem_full;
		middle_reset = reset;
		#1
		if (middle_reset == 1)
		begin
			out_data = 35'b0;
			ready0 = 1;
			ready1 = 0;
			ready2 = 0;
			ready3 = 0;
			selector = 2'b00;
			middle_in_data0 = 35'b0;
			middle_in_data1 = 35'b0;
			middle_in_data2 = 35'b0;
			middle_in_data3 = 35'b0;
			muxed_data = 35'b0;
			middle_next_ready = 0;
			middle_mem_full = 0;
			data_sent = 1'b0;
			multiwidth = 1'b0;
			ready_wait = 1'b1;
		end
		else
		begin
			case (selector)
				2'b00	: 
				begin
					if (middle_in_data0 != 35'b0)
					begin
						muxed_data = middle_in_data0;
						multiwidth = middle_in_data0[34];
					end
				end
				2'b01	: 
				begin
					if (middle_in_data1 != 35'b0)
					begin
						muxed_data = middle_in_data1;
						multiwidth = middle_in_data1[34];
					end
				end
				2'b10	: 
				begin
					if (middle_in_data2 != 35'b0)
					begin
						muxed_data = middle_in_data2;
						multiwidth = middle_in_data2[34];
					end
				end
				2'b11	: 
				begin
					if (middle_in_data3 != 35'b0)
					begin
						muxed_data = middle_in_data3;
						multiwidth = middle_in_data3[34];
					end
				end
				default	: out_data = 35'b0;
			endcase

			if (middle_next_ready == 1 && muxed_data != 0)
			begin
				out_data = muxed_data;
				data_sent = 1;
			end
			else
			begin
				out_data = 0;
				if (data_sent == 1)
				begin
					muxed_data = 0;
					data_sent = 0;
				end
			end


			if (multiwidth == 0 && ready_wait == 0 && muxed_data == 0)
			begin
				selector = selector + 1;
				ready_wait = 1;
			end
			else if (ready_wait == 1 && ready_logic == 1)
			begin
				ready_wait = 0;
			end

			ready_logic = (muxed_data == 0) && (out_data == 0) && (middle_mem_full == 0);

			case (selector)
				2'b00	:
					begin
						ready0 = ready_logic;
						ready1 = 0;
						ready2 = 0;
						ready3 = 0;
					end
				2'b01	:
					begin
						ready0 = 0;
						ready1 = ready_logic;
						ready2 = 0;
						ready3 = 0;
					end
				2'b10	:
					begin
						ready0 = 0;
						ready1 = 0;
						ready2 = ready_logic;
						ready3 = 0;
					end
				2'b11	:
					begin
						ready0 = 0;
						ready1 = 0;
						ready2 = 0;
						ready3 = ready_logic;
					end
			endcase
		end
	end

endmodule
