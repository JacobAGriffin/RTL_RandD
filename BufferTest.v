`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15

module BufferTest#(
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
		input new_in_ready;
		input new_multi_width;
		input [DATA_WIDTH-1:0]new_in_data0;
		input [DATA_WIDTH-1:0]new_in_data1;
		input [DATA_WIDTH-1:0]new_in_data2;
		input [DATA_WIDTH-1:0]new_in_data3;
		output set_clk;
		output set_in_ready;
		output set_multi_width;
		output [DATA_WIDTH-1:0]set_in_data0;
		output [DATA_WIDTH-1:0]set_in_data1;
		output [DATA_WIDTH-1:0]set_in_data2;
		output [DATA_WIDTH-1:0]set_in_data3;
		
		begin
			set_clk = new_clk;
			set_in_data0 = new_in_data0;
			set_in_data1 = new_in_data1;
			set_in_data2 = new_in_data2;
			set_in_data3 = new_in_data3;
			set_in_ready = new_in_ready;
			set_multi_width = new_multi_width;
		end
	endtask
	
	// Inputs
	reg clk;
	reg rst;
	reg in_ready;
	reg multi_width;
	reg [DATA_WIDTH-1:0] in_data0;
	reg [DATA_WIDTH-1:0] in_data1;
	reg [DATA_WIDTH-1:0] in_data2;
	reg [DATA_WIDTH-1:0] in_data3;
	reg [1:0]  selector;

	//helper
	reg [7:0] passed;

	// Outputs
	wire [DATA_WIDTH-1:0] out_data;
	wire ready0;
	wire ready1;
	wire ready2;
	wire ready3;
	wire full;

	// Instantiate the Unit Under Test (UUT)
	Buffer uut (
		.clk(clk),
		.rst(rst),
		.in_ready(in_ready),
		.multi_width(multi_width),
		.in_data0(in_data0),
		.ready0(ready0),
		.in_data1(in_data1),
		.ready1(ready1),
		.in_data2(in_data2),
		.ready2(ready2),
		.in_data3(in_data3),
		.ready3(ready3),
		.out_data(out_data),
		.full(full)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		in_ready = 0;
		multi_width = 0;
		rst = 0;
		in_data0 = 40'h0;
		in_data1 = 40'h0;
		in_data2 = 40'h0;
		in_data3 = 40'h0;
		passed = 0;
		#5

		//test1
		stim(1,
		0,
		40'h0,
		40'h0,
		40'h0,
		40'h0,
		1'b0,
		clk,
		in_ready,
		in_data0,
		in_data1,
		in_data2,
		in_data3,
		multi_width);
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
		
		#10; allPassed(passed, 0);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferTest.vcd"); 
		$dumpvars(0,BufferTest);
	end
         

endmodule

