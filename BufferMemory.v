`timescale 1ns / 1ps 
`default_nettype none 

module BufferMemory #(
	parameter BUFFER_DEPTH = 32
) (
	out_data,
	empty,
	full,
	ready,
	clk,
	reset,
	next_ready,
	in_data
); 

	// Declare input ports 
	input	clk,
		reset,
		next_ready;

	input [34:0] in_data;
		
	// Declare output ports
	output wire	empty,
			full;

	output reg	ready;

	output reg [34:0] out_data;

	// Declare Middle Ports
	wire [BUFFER_DEPTH-1:0] 	empty_array,
					write_array;

	wire [34:0] 	data_passer [BUFFER_DEPTH-1:0];

	reg 		middle_next_ready,
			middle_reset,
			last_next_ready;

	reg [34:0]	middle_data;

	//Generate Block

	genvar j;
	generate
	for (j = 0; j < BUFFER_DEPTH; j = j + 1)
	begin : Memory_Block
		if (j == 0)
		begin
			BufferMemorySubBlock memory_block //Generates first register block
			(
				.writing(write_array[j]),
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.in_data(middle_data),
				.in_empty(write_array[j+1])
			);
		end

		else if (j == BUFFER_DEPTH-1)
		begin
			BufferMemorySubBlock memory_block //Generates last register blocks
			(
				.writing(write_array[j]),
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.in_data(data_passer[j-1]),
				.in_empty(last_next_ready & ~middle_next_ready)
			);
		end

		else
		begin
			BufferMemorySubBlock memory_block //Generates middle register block
			(
				.writing(write_array[j]),
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.in_data(data_passer[j-1]),
				.in_empty(write_array[j+1])
			);
		end
	end
	endgenerate

	//Assign Statements

	assign empty = (empty_array == {BUFFER_DEPTH{1'b1}});

	assign full = (empty_array == {BUFFER_DEPTH{1'b0}});

	//Always Blocks

	always @(posedge clk)
	begin
		middle_data = in_data;
		middle_next_ready = next_ready;
		middle_reset = reset;
		#1
		if (middle_reset == 1)
		begin
			ready = 1;
			out_data = 0;
			middle_data = 0;
			middle_next_ready = 0;
		end
		else
		begin
			last_next_ready = middle_next_ready;
			if (middle_next_ready == 1)
			begin
				out_data = data_passer[BUFFER_DEPTH-1];
			end
			else
			begin
				out_data = 35'b0;
			end
			if (full == 1 || middle_data != 0)
			begin
				ready = 0;
			end
			else if (middle_data == 0)
			begin
				ready = 1;
			end
		end
	end

endmodule
