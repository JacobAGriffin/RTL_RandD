`timescale 1ns / 1ps 
`default_nettype none 

module Buffer #(
	parameter DATA_WIDTH = 40, // Adjust to include header bits
	parameter DATA_DEPTH = 4096
) (
	clk,
	rst,
	in_ready,
	multi_width,
	in_data0,
	ready0,
	in_data1,
	ready1,
	in_data2,
	ready2,
	in_data3,
	ready3,
	out_data,
	full
); 

	// Declare input ports

	input 	clk,
		rst,
		in_ready,
		multi_width;
	input	[DATA_WIDTH-1:0] 	in_data0,
					in_data1,
					in_data2,
					in_data3;
		
	// Declare output ports

	output	[DATA_WIDTH-1:0] out_data; 	// Output data
	output	ready0,
		ready1,
		ready2,
		ready3,
		full;

	// Declare Middle Ports

	wire [1:0] link_num_passer;
	wire [DATA_WIDTH-1:0] mux_odata_memblock_idata_passer;
	wire memoblock_rdy_mux_rdy_passer;
	wire memblock_full_mux_ctrlr_full_passer;
	wire empty;

	//Initial Block

	//Generate Block

	BufferMemory memory_block (
		.out_data(out_data),
		.empty(empty),
		.full(memblock_full_mux_ctrlr_full_passer),
		.ready(memoblock_rdy_mux_rdy_passer),
		.clk(clk),
		.reset(rst),
		.next_ready(in_ready),
		.in_data(mux_odata_memblock_idata_passer)
	);

	BufferMux buffer_mux (
		.clk(clk),
		.in_data0(in_data0),
		.ready0(ready0),
		.in_data1(in_data1),
		.ready1(ready1),
		.in_data2(in_data2),
		.ready2(ready2),
		.in_data3(in_data3),
		.ready3(ready3),
		.selector(link_num_passer),
		.out_data(mux_odata_memblock_idata_passer)
	);

	BufferMuxController buffer_mux_controller (
		.in_full(memblock_full_mux_ctrlr_full_passer),
		.multi_width(multi_width),
		.clk(clk),
		.out_full(memoblock_rdy_mux_rdy_passer),
		.link_num(link_num_passer)
	); 

	//Assign Statements

	//Always Blocks

endmodule
