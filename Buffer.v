`timescale 1ns / 1ps 
`default_nettype none 

module Buffer (
	clk,
	reset,
	in_ready,
	in_data0,
	ready0,
	in_data1,
	ready1,
	in_data2,
	ready2,
	in_data3,
	ready3,
	out_data
); 

	// Declare input ports

	input 	clk,
		reset,
		in_ready;
	input	[34:0] 	in_data0,
					in_data1,
					in_data2,
					in_data3;
		
	// Declare output ports

	output	[34:0] out_data; 	// Output data
	output	ready0,
		ready1,
		ready2,
		ready3;

	// Declare Middle Ports

	wire [34:0] mux_memblock_data_passer;
	wire memblock_mux_full_passer;
	wire memblock_mux_ready_passer;
	wire empty;

	//Initial Block

	//Generate Block

	BufferMemory memory_block (
		.out_data(out_data),
		.empty(empty),
		.full(memblock_mux_full_passer),
		.ready(memblock_mux_ready_passer),
		.clk(clk),
		.reset(reset),
		.next_ready(in_ready),
		.in_data(mux_memblock_data_passer)
	);

	BufferMux buffer_mux (
		.clk(clk),
		.reset(reset),
		.next_ready(memblock_mux_ready_passer),
		.mem_full(memblock_mux_full_passer),
		.in_data0(in_data0),
		.ready0(ready0),
		.in_data1(in_data1),
		.ready1(ready1),
		.in_data2(in_data2),
		.ready2(ready2),
		.in_data3(in_data3),
		.ready3(ready3),
		.out_data(mux_memblock_data_passer)
	); 

	//Assign Statements

	//Always Blocks

endmodule
