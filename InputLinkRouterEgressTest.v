`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module InputLinkRouterEgressTest #(
	parameter LINK_NUMBER = 4,
	parameter DATA_WIDTH = 64,
	parameter SUBUNIT_QUANTITY = 4
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

		input [95:0] newheader_in;
		input [31:0] newpayload_in;
		input newbuffer_ready0;
		input newbuffer_ready1;
		input newbuffer_ready2;
		input newbuffer_ready3;
		input [2:0] newlink_destination;
		input newclk;
		
 		output [95:0] setheader_in;
		output [31:0] setpayload_in;
		output setbuffer_ready0;
		output setbuffer_ready1;
		output setbuffer_ready2;
		output setbuffer_ready3;
		output [2:0] setlink_destination;
		output setclk;
		begin 
			setheader_in = newheader_in;
			setpayload_in = newpayload_in;
			setbuffer_ready0 = newbuffer_ready0;
			setbuffer_ready1 = newbuffer_ready1;
			setbuffer_ready2 = newbuffer_ready2;
			setbuffer_ready3 = newbuffer_ready3;
			setlink_destination = newlink_destination;
			setclk = newclk;
		end 

	endtask

// Declare inputs 
		reg [95:0] header_in;
		reg [31:0] payload_in;
		reg buffer_ready0;
		reg buffer_ready1;
		reg buffer_ready2;
		reg buffer_ready3; 
		reg [2:0] link_destination;
		reg clk;
	
// Declare output ports		    	
		reg ready;
		reg [39:0] header_array0;
		reg [39:0] header_array1;
		reg [39:0] header_array2;
		reg [39:0] header_array3;
		reg [31:0] payload_array0;
		reg [31:0] payload_array1;
		reg [31:0] payload_array2;
		reg [31:0] payload_array3;

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	InputLinkRouterEgress #(
		4,
		64,
		4
	) uut (
		.header_in (header_in),
		.payload_in (payload_in),
		.buffer_ready0 (buffer_ready0),
		.buffer_ready1 (buffer_ready1),
		.buffer_ready2 (buffer_ready2),
		.buffer_ready3 (buffer_ready3),
		.link_destination (link_destination),
		.clk (clk)
	);

	initial begin
		// Initialize Inputs
		header_in = 96'h000000000000000000000000;
		payload_in = 32'h00000000;
		buffer_ready0 = 0;
		buffer_ready1 = 0;
		buffer_ready2 = 0;
		buffer_ready3 = 0;
		link_destination = 0;
		clk = 1;		


		// Test1- Testing a simple input with no payload, link_number = 3
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h222222221111111111110000,	//input header and link destination
		32'h00000000,
		0,
		0,
		0,
		0,
		4,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		clk = 0;
		stim(96'h0000000000000000000000,	//clear inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that header will not output to wrong link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that header will not output to wrong link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that header will not output to wrong link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that header will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		
		//iterate second set of header data
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs in anticipation for second iteration of headers
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the second header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the second header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//iterate third and final set of header data
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the third header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the third header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs, in anticipation for next instruction set
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5




















		// Test 2- Repeat of test 1 a simple input with no payload, link_number = 2
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h444444443333333333330000,	//input header and link destination
		32'h00000000,
		0,
		0,
		0,
		0,
		3,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		clk = 0;
		stim(96'h0000000000000000000000,	//clear inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that header will not output to wrong link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that header will not output to wrong link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that header will not output to wrong link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that header will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		
		//iterate second set of header data
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs in anticipation for second iteration of headers
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the second header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the second header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//iterate third and final set of header data
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the third header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the third header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs, in anticipation for next instruction set
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



















		// Test 3 - Repeat of test 1 a simple input with no payload, link_number = 1
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h777777776666666635550000,	//input header and link destination
		32'h00000000,
		0,
		0,
		0,
		0,
		2,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		clk = 0;
		stim(96'h0000000000000000000000,	//clear inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that header will not output to wrong link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that header will not output to wrong link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that header will not output to wrong link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that header will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		
		//iterate second set of header data
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs in anticipation for second iteration of headers
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the second header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the second header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//iterate third and final set of header data
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the third header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the third header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs, in anticipation for next instruction set
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



















		// Test 4 - Repeat of test 1 a simple input with no payload, link_number = 1
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h101010109999999983880000,	//input header and link destination
		32'h00000000,
		0,
		0,
		0,
		0,
		1,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		clk = 0;
		stim(96'h0000000000000000000000,	//clear inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that header will not output to wrong link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that header will not output to wrong link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that header will not output to wrong link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that header will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		
		//iterate second set of header data
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs in anticipation for second iteration of headers
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the second header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the second header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//iterate third and final set of header data
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the third header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the third header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs, in anticipation for next instruction set
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



















		// Test 5 - Sample header, payload, and link_number = 1
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h222222221111111140000002,	//input header and link destination
		32'h00000000,
		0,
		0,
		0,
		0,
		1,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0; 
		#5
		clk = 1;
		#5
		clk = 0;
		stim(96'h0000000000000000000000,	//clear inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that header will not output to wrong link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that header will not output to wrong link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that header will not output to wrong link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that header will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		
		//iterate second set of header data
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs in anticipation for second iteration of headers
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the second header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the second header set will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the second header set will output to correct link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//clear all inputs
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//iterate third and final set of header data
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the third header set will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the third header set will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



		//introduce first payload
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the third header set will not output to incorrect link
		32'h12345678,				//introduce first payload
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready3 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready1 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready0 to test that the payload will output to the correct link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(96'h0000000000000000000000,	//input next payload data
		32'h40404040,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		1,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h0000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



















		//Test 6 - payload test, link number 1
		stim(96'h333333332222222241110003,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		2,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hFFFFFFFF,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hA0A0A0A0,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000001,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		1,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5


















		//Test 7 - payload test, link number 2
		stim(96'h333333332222222241110002,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		3,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hFFFFFFFF,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hA0A0A0A0,
		0,
		0,
		1,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5



















		//Test 8 - final payload test, link number 3
		stim(96'h333333332222222241110002,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		1,
		4,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hFFFFFFFF,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'hA0A0A0A0,
		0,
		0,
		0,
		1,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		stim(96'h000000000000000000000000,	//set buffer_ready2 to test that the payload will not output to incorrect link
		32'h00000000,
		0,
		0,
		0,
		0,
		0,
		0,
		header_in,
		payload_in,
		buffer_ready0,
		buffer_ready1,
		buffer_ready2,
		buffer_ready3,
		link_destination,
		clk);
		#5
		clk = 1;		
		#5
		clk = 0;
		#5
		clk = 1; 
		#5
		#10; allPassed(passed, 2);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("InputLinkRouterEgressTest.vcd"); 
		$dumpvars(0,InputLinkRouterEgressTest);
	end 
endmodule 
