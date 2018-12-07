`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module InputLinkRouterTest #(
	parameter LINK_NUMBER = 0,
	parameter DATA_WIDTH = 32,
	parameter SUBUNIT_QUANTITY = 0
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

		input newtransmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
		input [3:0] newhardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
		input newclk;
		input [DATA_WIDTH-1:0] newin_data;
		input newop_complete; 
		input newnext_ready;
		output settransmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
		output [3:0] sethardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
		output setclk;
		output [DATA_WIDTH-1:0] setin_data;
		output setop_complete;
		output setnext_ready;
		begin 
			settransmit_link_output_buffer_full = newtransmit_link_output_buffer_full; 
			sethardware_subunit_input_buffer_full = newhardware_subunit_input_buffer_full;
			setclk = newclk;
			setin_data = newin_data;
			setop_complete = newop_complete; 
			setnext_ready = newnext_ready;
			
		end 

	endtask

// Declare inputs 
	reg	transmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
	reg	[3:0] hardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
	reg   clk;
	reg [DATA_WIDTH-1:0] in_data; 	    	// Input data
	reg op_complete;
	reg next_ready; 
	
// Declare output ports		    	
	wire 	[DATA_WIDTH-1:0] out_data; 	// Output data
	wire 	ready;
	wire	[127:0] header_out;

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	InputLinkRouter #(
		0,
		32,
		0,
		0
	) uut (
		.out_data (out_data),
		.ready (ready),
		.header_out (header_out),
		.transmit_link_output_buffer_full (transmit_link_output_buffer_full),
		.hardware_subunit_input_buffer_full (hardware_subunit_input_buffer_full),
		.clk (clk),
		.in_data (in_data),
		.op_complete (op_complete),
		.next_ready (next_ready)
	);

	initial begin
		// Initialize Inputs
		transmit_link_output_buffer_full = 0;
		hardware_subunit_input_buffer_full = 0;
		clk = 0;
		in_data = 32'h00000000;
		passed = 0;
		op_complete = 0;
		
		// Test1
		stim(0,
		0,
		1,
		32'h0050ADFF,
		0,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		op_complete,
		next_ready);
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		passTest(header_out, 32'h0, "Test 1", passed);
		passTest(out_data, 32'h0, "Test 2", passed);
		stim(0,
		0,
		1,
		32'h0,
		0,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		op_complete,
		next_ready);
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		stim(0,
		0,
		1,
		32'h02F8D309,
		1,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		op_complete,
		next_ready);
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		#5
		clk = 0; // Change clock between tests
		#5
		clk = 1; // Change clock between tests
		passTest(header_out, 32'h09D3F802, "Test 1", passed);
		passTest(out_data, 64'h09D3F80209D3F802, "Test 2", passed);


		#10; allPassed(passed, 2);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("InputLinkRouterTest.vcd"); 
		$dumpvars(0,InputLinkRouterTest);
	end 
endmodule 

