`timescale 1ns / 1ps 
`default_nettype none 

module BufferMemory #(
	parameter DATA_WIDTH = 40, // Adjust to include header bits
	parameter DATA_DEPTH = 4096
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
	input	clk, 			// Clock Signal
		reset,			// Reset flag
		next_ready;		// next_ready flag

	input [DATA_WIDTH-1:0] in_data; // Input data 
		
	// Declare output ports
	output wire	empty, 		// Flag for when the buffer is empty
			full; 		// Flag for when the buffer is full
	output reg	ready; 		// ready flag

	output reg [DATA_WIDTH-1:0] out_data; 	// Output data

	// Declare Middle Ports
	wire [DATA_DEPTH-1:0] 	empty_array,
				write_array;
	wire write;

	wire [DATA_WIDTH-1:0] 	data_passer [DATA_DEPTH-1:0];

	reg out;

	//Initial Block

	initial
	begin
		out = 0;
		ready = 0;
	end

	//Generate Block

	genvar j;
	generate
	for (j = 0; j < DATA_DEPTH; j = j + 1)
	begin
		if (j == 0)
		begin
			BufferMemorySubBlock #(DATA_WIDTH) memory_block //Generates first register block
			(
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.write(write_array[j]),
				.in_empty(~write),
				.in_data(in_data)
			);
		end

		else if (j == DATA_DEPTH-1)
		begin
			BufferMemorySubBlock #(DATA_WIDTH) memory_block //Generates last register blocks
			(
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.write(write_array[j]),
				.in_empty(empty_array[j-1]),
				.in_data(data_passer[j-1])
			);
		end

		else
		begin
			BufferMemorySubBlock #(DATA_WIDTH) memory_block //Generates middle register block
			(
				.out_empty(empty_array[j]),
				.out_data(data_passer[j]),
				.clk(clk),
				.reset(reset),
				.write(write_array[j]),
				.in_empty(empty_array[j-1]),
				.in_data(data_passer[j-1])
			);
		end
	end
	endgenerate

	//Assign Statements

	assign empty = (empty_array == {DATA_DEPTH{1'b1}}); //Empty flag logic

	assign full = (empty_array == {DATA_DEPTH{1'b0}}); //Full flag logic

	assign write_array = ((next_ready * {DATA_DEPTH{1'b1}}) | (write * empty_array) | (write * (write_array>>1))); //Write logic for each of the subblocks

	assign write = (in_data != 0);

	//Always Blocks

	always @(posedge clk)
	begin
		if (next_ready == 1)
		begin
			out = 1;
		end
		else
		begin
			out = 0;
		end
	end

	always @(negedge clk)
	begin
		if (out == 1)
		begin
			out_data = data_passer[DATA_DEPTH-1];
			out = 0;
		end
		else
		begin
			out_data = {DATA_DEPTH{1'b0}};
		end
		if (full == 1 || in_data != 0)
		begin
			ready = 0;
		end
		else if (in_data == 0)
		begin
			ready = 1;
		end
	end

endmodule
