`timescale 1ns / 1ps 
`default_nettype none 

module BufferMemorySubBlock #(
	parameter DATA_WIDTH = 40 // Adjust to include header bits
) (
	out_empty,
	out_data,
	clk,
	reset,
	write,
	in_empty,
	in_data
); 

// Declare input ports

input 	clk, 			// Clock signal
	write,			// Write flag
	reset,			// Reset flag
	in_empty;		// Empty flag


input [DATA_WIDTH-1:0] in_data; // Input data 
	
// Declare output ports

output reg out_empty;		// Status of memory block

output reg [DATA_WIDTH-1:0] out_data; 	// Output data

//Initial Blocks

initial
begin
	out_data <= {DATA_WIDTH{1'b0}};
	out_empty <= 1'b1;
end

//Assign Statements

//Always Blocks

always @(posedge clk)
begin
// Resetting buffer memory if reset flag is 1
	if (reset == 1)
	begin
		out_data <= 0;
		out_empty <= 1;
	end

	else if (reset == 0 && write == 1)
	begin
		out_data <= in_data;
		out_empty <= in_empty;
	end
end

endmodule 
