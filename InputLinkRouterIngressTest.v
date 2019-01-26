`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module InputLinkRouterIngressTest #(
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
		input newnext_ready;
		output settransmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
		output [3:0] sethardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
		output setclk;
		output [DATA_WIDTH-1:0] setin_data;
		output setnext_ready;
		begin 
			settransmit_link_output_buffer_full = newtransmit_link_output_buffer_full; 
			sethardware_subunit_input_buffer_full = newhardware_subunit_input_buffer_full;
			setclk = newclk;
			setin_data = newin_data;
			setnext_ready = newnext_ready;
			
		end 

	endtask

// Declare inputs 
	reg transmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
	reg [3:0] hardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
	reg clk;
	reg [DATA_WIDTH-1:0] in_data; 	    	// Input data
	reg next_ready; 
	
// Declare output ports		    	
	wire 	[DATA_WIDTH-1:0] payload_out; 	// Output data
	wire 	ready;
	wire	[127:0] header_out;

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	InputLinkRouterIngress #(
		0,
		32,
		0,
	) uut (
		.payload_out (payload_out),
		.ready (ready),
		.header_out (header_out),
		.transmit_link_output_buffer_full (transmit_link_output_buffer_full),
		.hardware_subunit_input_buffer_full (hardware_subunit_input_buffer_full),
		.clk (clk),
		.in_data (in_data),
		.next_ready (next_ready)
	);

	initial begin
		// Initialize Inputs
		transmit_link_output_buffer_full = 0;
		hardware_subunit_input_buffer_full = 0;
		clk = 0;
		in_data = 32'h00000000;
		passed = 0;
		
		// Test1 to test 3DW no payload & Testing to ensure headers will complete before sending
		stim(0,		//Allow 1 cycle for system to setup
		0,
		1,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//First 32 bit input
		0,
		0,
		32'h0000000F,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear input data
		0,		//Raise next_ready flag to ensure system does not output until header is completed
		0,
		32'h00000000,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Second 32 bit input
		0,
		0,
		32'h22222222,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
				passTest(header_out, 128'h0, "Test 1", passed);		//Testing that output stays low until 			
		#5									//header is completed
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Final 32 bit input
		0,
		0,
		32'h33333333,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,	
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Next Stage is ready for new information
		0,	
		0,
		32'h00000000,	
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
				passTest(header_out, 128'h0000000033333333222222220F000000, "Test 2", passed); //Checking output data
		clk = 1;
		#5
		stim(0,		//Dropping next_ready
		0,
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
				passTest(header_out, 128'h0, "Test 3", passed);		//Testing that output is cleared when next_ready drops
		clk = 0;
		#5
		clk = 1; 
		#5
		clk = 0;	//Time buffer to separate tests 	
		#5
		clk = 1;
		#5
		




		// Test2, to test 4DW header no payload
		stim(0,		//load in initial 32 bits for header
		0,
		0,
		32'h0044442F,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,	
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0; 
		#5
		clk = 1;
		#5
		stim(0,		//input second 32 bits of header
		0,
		0,
		32'h55555555,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,	
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//input third 32 bits of header
		0,
		0,
		32'h66666666,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,	
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//input fourth 32 bits of header
		0,
		0,
		32'h77777777,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,		//set the next_ready flag for data output
		0,
		32'h00000000,	
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
				passTest(header_out, 128'h7777777766666666555555552F444400, "Test 4", passed); //Checking output data
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,		//clear the next_ready flag as well
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
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
		#5		//buffer between stages



		//Test3 
		//Used to test a header with payload
		stim(0,		//input first 32 bits of header
		0,
		0,
		32'h0200006F,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//clear data from first 32 bits
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//input second set of 32 bits
		0,
		0,
		32'h11111111,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1; 
		#5
		stim(0,		//clear second set of 32 bits
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5		
		clk = 1;
		#5
		clk = 0;
		#5		
		clk = 1;
		#5
		stim(0,		//set third set of 32 bits
		0,		//also setting next_ready to ensure output doesn't go when it isn't supposed to
		0,
		32'h22222222,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
				passTest(header_out, 128'h0, "Test 5", passed); //Checking output data
		clk = 1; 
		#5		
		stim(0,		//clear third set of 32 header bits
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1; 
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//input last set of 32 header bits
		0,		//set next_ready to test if headers are output correctly
		0,
		32'h33333333,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1; 
		#5
		clk = 0; 
		#5
				passTest(header_out, 128'h3333333322222222111111116F000002, "Test 6", passed); //Checking output data
		clk = 1; 
		#5
		stim(0,		//clear last set of 32 header bits
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5		
		stim(0,		//input first payload
		0,		//set next_ready to test if payload is output correctly
		0,
		32'h40404040,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0;
		#5
				passTest(payload_out, 32'h40404040, "Test 7", passed); //Checking output data
		clk = 1;
		#5		
		stim(0,		//clear first payload data and next_ready
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//input second set of payload
		0,		//set next_ready to test that last payload is output correctly
		0,
		32'h50505050,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0;
		#5
				passTest(payload_out, 32'h50505050, "Test 8", passed); //Checking output data
		clk = 1;
		#5
		stim(0,		//clear all inputs
		0,		//will test if all outputs are cleared from the module
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5		
		clk = 0;
		#5
		clk = 1;
		#5

		// Test4 
		//redo of Test 1, to ensure that post-payload cycles work correctly
		stim(0,		//Allow 1 cycle for system to setup
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//First 32 bit input
		0,
		0,
		32'h0000000F,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear input data
		0,		//Raise next_ready flag to ensure system does not output until header is completed
		0,
		32'h00000000,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Second 32 bit input
		0,
		0,
		32'h22222222,
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready); 			
		#5				
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,
		0,
		32'h00000000,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Final 32 bit input
		0,
		0,
		32'h33333333,
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Clear the input data
		0,	
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(0,		//Next Stage is ready for new information
		0,	
		0,
		32'h00000000,	
		1,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
				passTest(header_out, 128'h0000000033333333222222220F000000, "Test 9", passed); //Checking output data
		clk = 1;
		#5
		stim(0,		//Dropping next_ready
		0,
		0,
		32'h00000000,	
		0,
		transmit_link_output_buffer_full,
		hardware_subunit_input_buffer_full,
		clk,
		in_data,
		next_ready);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
				passTest(header_out, 128'h0, "Test 10", passed);		//Testing that output is cleared when next_ready drops
		clk = 0;
		#5
		clk = 1; 
		#5
		clk = 0; 	
		#5
		clk = 1;
		#5
		
				



		#10; allPassed(passed, 10);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("InputLinkRouterIngressTest.vcd"); 
		$dumpvars(0,InputLinkRouterIngressTest);
	end 
endmodule 

