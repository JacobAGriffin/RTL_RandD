`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module BufferMemoryTest #(
	parameter DATA_WIDTH = 40,
	parameter DATA_DEPTH = 4096
);

	task passTest;
		input [DATA_WIDTH-1:0] actualOut, expectedOut;
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
		input [DATA_WIDTH-1:0] newIn_data; 
		output setClk; 
		output setReset;
		output set_next_ready;
		output [DATA_WIDTH-1:0] setIn_data; 
	
		begin
			setClk = newClk; 
			setReset = newReset; 
			set_next_ready = new_next_ready; 
			setIn_data = newIn_data; 
			
		end 

	endtask

	// Inputs
	reg clk;
	reg reset;
	reg next_ready;
	reg [DATA_WIDTH-1:0] in_data;

	// Outputs
	wire [DATA_WIDTH-1:0] out_data;
	wire empty;
	wire full;
	wire ready;

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	BufferMemory #(
		40,
		5
	) uut (
		.out_data (out_data),
		.empty (empty),
		.full (full),
		.ready (ready),
		.clk (clk),
		.reset (reset),
		.next_ready (next_ready),
		.in_data (in_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		next_ready = 0;
		in_data = 40'h0;
		passed = 0;
		
		// Test1
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h1,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);
		
		// Test2
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h2,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		1,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);
		
		// Test3
		#5
		clk = 1;
		#5
		stim(0,
		0,
		1,
		40'h3,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		1,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);
		
		// Test4
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h4,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		1,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);
		
		// Test5
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h5,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		1,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);
		
		// Test6
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h6,
		clk,
		reset,
		next_ready,
		in_data);
		#5
		clk = 1;
		#5
		stim(0,
		0,
		0,
		40'h0,
		clk,
		reset,
		next_ready,
		in_data);

		#5; allPassed(passed, 10);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferMemoryTest.vcd"); 
		$dumpvars(0,BufferMemoryTest);
	end 
endmodule 

