`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15

module BufferMuxTest;


	task passTest;
		input [34:0] actualOut, expectedOut;
		input [`STRLEN*8:0] testType;
		inout [7:0] passed;
	
		if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
		else $display ("%s failed: %d should be %d", testType, actualOut, expectedOut);
	endtask
	
	task allPassed;
		input [7:0] passed;
		input [7:0] numTests;
		
		if(passed == numTests) $display ("All tests passed");
		else $display("Some tests failed");
	endtask
	
	task stim;
		input new_clk;
		input new_reset;
		input new_next_ready;
		input new_mem_full;
		input [34:0]new_in_data0;
		input [34:0]new_in_data1;
		input [34:0]new_in_data2;
		input [34:0]new_in_data3;
		output set_clk;
		output set_reset;
		output set_next_ready;
		output set_mem_full;
		output [34:0]set_in_data0;
		output [34:0]set_in_data1;
		output [34:0]set_in_data2;
		output [34:0]set_in_data3;
		
		begin
			set_clk = new_clk;
			set_reset = new_reset;
			set_next_ready = new_next_ready;
			set_mem_full = new_mem_full;
			set_in_data0 = new_in_data0;
			set_in_data1 = new_in_data1;
			set_in_data2 = new_in_data2;
			set_in_data3 = new_in_data3;
		end
	endtask
	
	// Inputs
	reg	clk,
		reset,
		next_ready,
		mem_full;
	reg [34:0]	in_data0,
			in_data1,
			in_data2,
			in_data3;

	//helper
	reg [7:0] passed;

	// Outputs
	wire	ready0,
		ready1,
		ready2,
		ready3;
	wire [34:0] out_data;

	// Instantiate the Unit Under Test (UUT)
	BufferMux uut (
		.clk(clk),
		.reset(reset),
		.next_ready(next_ready),
		.mem_full(mem_full),
		.in_data0(in_data0),
		.ready0(ready0),
		.in_data1(in_data1),
		.ready1(ready1),
		.in_data2(in_data2),
		.ready2(ready2),
		.in_data3(in_data3),
		.ready3(ready3),
		.out_data(out_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		next_ready = 1;
		mem_full = 0;
		in_data0 = 35'h0;
		in_data1 = 35'h0;
		in_data2 = 35'h0;
		in_data3 = 35'h0;
		passed = 0;

		#5
		clk = 1;
		#1
		reset = 0;
		#4
		clk = 0;
		#5

		//test1
		stim(1,
		0,
		1,
		0,
		35'h0,
		35'h0,
		35'h0,
		35'h0,
		clk,
		reset,
		next_ready,
		mem_full,
		in_data0,
		in_data1,
		in_data2,
		in_data3);
		#5
		clk = 0;
		#5
		clk = 1;
		#1
		stim(1,
		0,
		1,
		0,
		35'h400000000,
		35'h0,
		35'h0,
		35'h0,
		clk,
		reset,
		next_ready,
		mem_full,
		in_data0,
		in_data1,
		in_data2,
		in_data3);
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
		0,
		0,
		35'h0,
		35'h0,
		35'h0,
		35'h0,
		clk,
		reset,
		next_ready,
		mem_full,
		in_data0,
		in_data1,
		in_data2,
		in_data3);
		#4
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		//test2
		clk = 1;
		#1
		stim(1,
		0,
		1,
		0,
		35'h2FFFFFFFF,
		35'h0,
		35'h0,
		35'h0,
		clk,
		reset,
		next_ready,
		mem_full,
		in_data0,
		in_data1,
		in_data2,
		in_data3);
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
		0,
		0,
		35'h0,
		35'h0,
		35'h0,
		35'h0,
		clk,
		reset,
		next_ready,
		mem_full,
		in_data0,
		in_data1,
		in_data2,
		in_data3);
		#4
		clk = 0;
		#5

		//Cycle Clock
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5;
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferMuxTest.vcd"); 
		$dumpvars(0,BufferMuxTest);
	end
         

endmodule
