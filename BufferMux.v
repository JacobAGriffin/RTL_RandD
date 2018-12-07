`timescale 1ns / 1ps 
`default_nettype none 

module BufferMux #(
	parameter DATA_WIDTH = 40 // Adjust to include header bits
) (
	clk,
	in_data0,
	in_data1,
	in_data2,
	in_data3,
	selector,
	out_data
);

// Declare input ports

	input 	clk;
	input	[DATA_WIDTH-1:0] in_data0;
	input	[DATA_WIDTH-1:0] in_data1;
	input	[DATA_WIDTH-1:0] in_data2;
	input	[DATA_WIDTH-1:0] in_data3;
	input	[1:0] selector;
		
// Declare output ports

	output reg [DATA_WIDTH-1:0] out_data; 	// Output data
	output reg	ready0,
			ready1,
			ready2,
			ready3;

// Declare Middle Ports

	reg ready_wait;

//Initial Blocks

	initial
	begin
		out_data = {DATA_WIDTH{1'bz}};
		ready0 = 0;
		ready1 = 0;
		ready2 = 0;
		ready3 = 0;
		ready_wait = 1;
	end

//Always Blocks

	always @(posedge clk)
	begin
		if (ready_wait == 0)
		begin
			case (selector)
				2'b00	: 
					begin
						out_data = in_data0;
					end
				2'b01	: 
					begin
						out_data = in_data1;
					end
				2'b10	: 
					begin
						out_data = in_data2;
					end
				2'b11	: 
					begin
						out_data = in_data3;
					end
				default	: out_data = {DATA_WIDTH{1'bz}};
			endcase
		end
		else
		begin
			ready_wait = 0;
		end
	end

	always @(negedge clk)
	begin
		case (selector)
			2'b00 : 
				begin
					if (ready0 == 0)
					begin
						ready0 = 1;
						ready1 = 0;
						ready2 = 0;
						ready3 = 0;
						ready_wait = 1;
					end
					else if (in_data0 != 0)
					begin
						ready0 = 0;
					end
				end
			2'b01 : 
				begin
					if (ready1 == 0)
					begin
						ready0 = 0;
						ready1 = 1;
						ready2 = 0;
						ready3 = 0;
						ready_wait = 1;
					end
					else if (in_data1 != 0)
					begin
						ready1 = 0;
					end
				end
			2'b10 :
				begin
					if (ready2 == 0)
					begin
						ready0 = 0;
						ready1 = 0;
						ready2 = 1;
						ready3 = 0;
						ready_wait = 1;
					end
					else if (in_data2 != 0)
					begin
						ready2 = 0;
					end
				end
			2'b11 : 
				begin
					if (ready3 == 0)
					begin
						ready0 = 0;
						ready1 = 0;
						ready2 = 0;
						ready3 = 1;
						ready_wait = 1;
					end
					else if (in_data3 != 0)
					begin
						ready3 = 0;
					end
				end
		endcase
	end
endmodule
