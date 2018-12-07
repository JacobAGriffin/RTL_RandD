`timescale 1ns / 1ps 
`default_nettype none  

module BufferMuxController #(
	parameter 	DATA_WIDTH = 40
) (
	in_full,
	multi_width,
	clk,
	out_full,
	link_num
); 

	// Declare input ports
	input			in_full,	// Flag from buffer memory if full 
				multi_width,	// Flag from input router for multiple data 
				clk;		// Clock signal

	// Declare output ports
	output	 		out_full;	// Flag to input router for when buffer is full
	output reg [1:0] link_num;	// Flag to mux to choose link data to pass

	// Initial Block

	initial
	begin
		link_num = 2'b00;
	end

	// Assign Statement

	assign out_full = in_full;

	// Always Blocks

	always @(posedge clk)
	begin
		if (multi_width == 0)
		begin
			link_num = link_num + 1;
		end
	end

endmodule
