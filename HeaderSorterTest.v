`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module HeaderSorterTest #(
	parameter LINK_NUMBER = 0,
	parameter DATA_WIDTH = 64
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

		input [127:0] newin_data_header;		// Input data from the PCIe physical layer
		input [31:0] newin_data_payload; 
		input newnext_ready; 
		input newclk;	
	
		output [127:0] setin_data_header;
		output [31:0] setin_data_payload; 
		output setnext_ready;
		output setclk;

		begin
			setin_data_header = newin_data_header;
			setin_data_payload = newin_data_payload; 
			setnext_ready = newnext_ready;
			setclk = newclk;
		end 	    	
	endtask 

	// Declare input ports 
	reg [127:0] in_data_header;		// Input data from the PCIe physical layer
	reg [31:0] in_data_payload; 
	reg next_ready;
	reg clk;

	// Declare output ports 
	wire [95:0] sorted_header; 		// Output data from MemoryRouting sent to ILR
	wire [31:0] pass_through_payload;
	wire [2:0] link_destination; 		// Link # corresponding to the data 

	// Helper
	reg [7:0] passed;

	// Instantiate the Unit Under Test (UUT)
	Header_Sorter #(
		0, 
		64 
	) uut (
		.sorted_header (sorted_header),
		.pass_through_payload (pass_through_payload),
		.link_destination (link_destination),
		.in_data_header (in_data_header),
		.in_data_payload (in_data_payload),
		.next_ready (next_ready),
		.clk (clk)
	);

	initial begin
		// Initialize Inputs
		in_data_header = 128'h00000000000000000000000000000000;		
		in_data_payload = 32'h00000000; 
		next_ready = 0;
		clk = 0;
		// passed = 0; 
		
		// Test1: Configuration Request 3 DW 
		stim(128'hFFFFFFFFAAAAAA0F048FC001,
		32'h00000000,
		0,
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk); 
	 
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		1,				// Set next_ready to high 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		0,				// Set next_ready to low 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5

		// Test 2: Configuration Request 4DW 

		// Test 3: IO 3DW 
		stim(128'hFFFFFFFFAAAAAA07028FC001,
		32'h00000000,
		0,
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk); 
	 
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		1,				// Set next_ready to high 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		0,				// Set next_ready to low 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5

		// Test 4: IO 4DW 

		// Test 5: Memory Read 3DW 
		stim(128'hFFFFFFFC5555550000880C00,
		32'h00000000,
		0,
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk); 
	 
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		1,				// Set next_ready to high 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5
		stim(128'h0,
		32'h00000000,
		0,				// Set next_ready to low 
		0,
		in_data_header,
		in_data_payload,
		next_ready,
		clk);
		clk = 0;
		#5
		clk = 1;
		#5
		clk = 0;
		#5
		clk = 1;
		#5 
		// Test 6: Memory Read 4DW 
		// Test 7: Memomry Write 3DW 
		// Test 8: Memory Write 4DW 

		// Extra cases when next_ready/ other flags get changed 

		// passTest(sorted_header, 96'hAAAAAA80FFFFE003048FC001, "Test 1", passed);
		// passTest(link_destination, 2'b01, "Test 2", passed);


		#10; allPassed(passed, 2);
	end

	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("HeaderSorterTest.vcd"); 
		$dumpvars(0,HeaderSorterTest);
	end 
endmodule 

