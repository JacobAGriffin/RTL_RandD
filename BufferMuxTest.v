`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15

module BufferMuxTest#(
	parameter DATA_WIDTH = 40
);


	task passTest;
		input [DATA_WIDTH-1:0] actualOut, expectedOut;
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
		input [DATA_WIDTH-1:0]new_in_data0;
		input [DATA_WIDTH-1:0]new_in_data1;
		input [DATA_WIDTH-1:0]new_in_data2;
		input [DATA_WIDTH-1:0]new_in_data3;
		input [1:0]new_selector;
		output set_clk;
		output [DATA_WIDTH-1:0]set_in_data0;
		output [DATA_WIDTH-1:0]set_in_data1;
		output [DATA_WIDTH-1:0]set_in_data2;
		output [DATA_WIDTH-1:0]set_in_data3;
		output [1:0]set_selector;
		
		begin
			set_clk = new_clk;
			set_in_data0 = new_in_data0;
			set_in_data1 = new_in_data1;
			set_in_data2 = new_in_data2;
			set_in_data3 = new_in_data3;
			set_selector = new_selector;
		end
	endtask
	
	// Inputs
	reg clk;
	reg [DATA_WIDTH-1:0] in_data0;
	reg [DATA_WIDTH-1:0] in_data1;
	reg [DATA_WIDTH-1:0] in_data2;
	reg [DATA_WIDTH-1:0] in_data3;
	reg [1:0]  selector;

	//helper
	reg [7:0] passed;

	// Outputs
	wire [DATA_WIDTH-1:0] out_data;

	// Instantiate the Unit Under Test (UUT)
	BufferMux uut (
		.clk(clk),
		.in_data0(in_data0),
		.in_data1(in_data1),
		.in_data2(in_data2),
		.in_data3(in_data3),
		.selector(selector),
		.out_data(out_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		in_data0 = 40'h1;
		in_data1 = 40'h2;
		in_data2 = 40'h3;
		in_data3 = 40'h4;
		selector = 2'hz;
		passed = 0;
		#5

		//test1
		stim(1,
		40'h0,
		40'h0,
		40'h0,
		40'h0,
		2'h0,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		//test1.5
		stim(1,
		40'hABA,
		40'h2,
		40'h3,
		40'h4,
		2'h0,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
		#5
		clk = 0;
		passTest(out_data, 40'hABA, "Select 0", passed);
		#5
		stim(1,
		40'h0,
		40'h0,
		40'h0,
		40'h0,
		2'h0,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
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

		//test2
		stim(1,
		40'h1,
		40'h2,
		40'h3,
		40'h4,
		2'h1,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
		#5
		clk = 0;
		passTest(out_data, 40'h2, "Select 1", passed);
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		//test3
		stim(1,
		40'h1,
		40'h2,
		40'h3,
		40'h4,
		2'h2,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
		#5
		clk = 0;
		passTest(out_data, 40'h3, "Select 2", passed);
		#5
		clk = 1;
		#5
		clk = 0;
		#5

		//test4
		stim(1,
		40'h1,
		40'h2,
		40'h3,
		40'h4,
		2'h3,
		clk,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		selector);
		#5
		clk = 0;
		passTest(out_data, 40'h4, "Select 3", passed);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		
		#10; allPassed(passed, 4);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferMuxTest.vcd"); 
		$dumpvars(0,BufferMuxTest);
	end
         

endmodule

