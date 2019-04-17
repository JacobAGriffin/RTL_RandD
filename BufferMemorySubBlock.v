`timescale 1ns / 1ps 
`default_nettype none 

module BufferMemorySubBlock (
	writing,
	out_empty,
	out_data,
	clk,
	reset,
	in_data,
	in_empty
); 

// Declare input ports

input 	clk,
	reset,
	in_empty;


input [34:0] in_data;
	
// Declare output ports

output reg	out_empty,
		writing;

output reg [34:0] out_data;

//Declare Middle Ports

reg	middle_reset,
	middle_empty;

reg [34:0] middle_data;

//Assign Statements

//Always Blocks

always @(posedge clk)
begin
	middle_data = in_data;
	middle_reset = reset;
	middle_empty = in_empty;
	#1
	if (middle_reset == 1)
	begin
		out_data = 0;
		out_empty = 1;
		middle_data = 0;
		writing = 0;
	end
	else
	begin
		if (in_empty == 1)
		begin
			out_data = 35'b0;
			out_empty = 1;
		end
		if (out_empty == 1 && middle_data != 0)
		begin
			writing = 1;
			out_data = middle_data;
			out_empty = 0;
		end
		else
		begin
			writing = 0;
		end
	end
end

endmodule 
