`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module BufferMemoryTest;

	task passTest;
		input [34:0] actualOut, expectedOut;
		input [`STRLEN*8:0] testType;
		inout [7:0] passed;
	
		if(actualOut === expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
		else $display ("%s failed: %d should be %d", testType, 	actualOut, expectedOut);
	endtask
	
	task allPassed;
		input [7:0] passed;
		input [7:0] numTests;
		
		if(passed == numTests) $display ("All tests passed");
		else $display("Some tests failed");
	endtask

	task stim; 

		input newClk; 
		input newReset;
		input new_next_ready; 
		input [34:0] newIn_data; 
		output setClk; 
		output setReset;
		output set_next_ready;
		output [34:0] setIn_data; 
	
		begin
			setClk = newClk; 
			setReset = newReset; 
			set_next_ready = new_next_ready; 
			setIn_data = newIn_data; 
			
		end 

	endtask

	// Inputs
	reg 	clk,
		reset,
		next_ready;
	reg [34:0] in_data;

	// Outputs
	wire	empty,
		full,
		ready;
	wire [34:0] out_data;

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	BufferMemory #(
		8
	) uut (
		.clk(clk),
		.reset(reset),
		.next_ready(next_ready),
		.in_data(in_data),
		.empty(empty),
		.full(full),
		.ready(ready),
		.out_data(out_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		next_ready = 0;
		in_data = 35'h0;
		passed = 0;

		#5
		clk = 1;
		#1
		reset = 0;
		#4
		clk = 0;
		#5

		// Input 1
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h1,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		// Input 2
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h2,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		// Input 3
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h3,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h3,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5

		// Input 4
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h4,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h4,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5

		// Input 5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h5,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h5,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5

		// Input 6
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h6,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h6,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		0,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		35'h0,
		clk,
		reset,
		next_ready,
		in_data);
		#4
		clk = 0;
		#10;
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferMemoryTest.vcd"); 
		$dumpvars(0,BufferMemoryTest);
	end 
endmodule 
