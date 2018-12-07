`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module BufferMuxControllerTest #(
	parameter 	DATA_WIDTH = 40
); 

	task passTest;
		input actualOut, expectedOut;
		input [`STRLEN*8:0] testType;
		inout [7:0] passed;
	
		if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
		else $display ("%s failed: %d should be %d", testType, 	actualOut, expectedOut);
	endtask
	
	task allPassed;
		input [7:0] passed;
		input [7:0] numTests;
		
		if(passed == numTests) $display ("All tests passed");
		else $display("Some tests failed");
	endtask 

	task stim; 

		input reg 	new_in_full,
				new_multi_width,
				new_clk;
		output		set_in_full,
				set_multi_width,
				set_clk;

		begin 
			set_in_full = new_in_full;
			set_multi_width = new_multi_width;
			set_clk = new_clk;
		end 
	endtask 
		
	// Inputs
	reg	in_full,
		multi_width,
		clk;
	
	// Helper 
	reg [7:0] passed;

	// Outputs 
	wire out_full;

	wire [1:0] link_num;

	// Instantiate the Unit Under Test (UUT) 
	BufferMuxController #() uut (
		.in_full(in_full),
		.multi_width(multi_width),
		.clk(clk),
		.out_full(out_full),
		.link_num(link_num)
	);

	initial begin 
	// Initialize inputs 
	in_full = 0;
	multi_width = 0;
	clk = 0;
	passed = 0;

	// Test 1
	#5
	stim(0,
	0,
	1,
	in_full,
	multi_width,
	clk);
	#5
	passTest(link_num, 1, "Test 1", passed);
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
	stim(0,
	1,
	1,
	in_full,
	multi_width,
	clk);
	#5
	clk = 0;
	#5
	stim(0,
	0,
	1,
	in_full,
	multi_width,
	clk);
	#5
	clk = 0;
	#5
	clk = 1;
	#5
	clk = 0;

	// Create the rest of the test s
	#10; allPassed(passed, 1); // Adjust number of tests as is necessary 

	end 

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("BufferMuxControllerTest.vcd"); 
		$dumpvars(0,BufferMuxControllerTest);
	end 
endmodule 
