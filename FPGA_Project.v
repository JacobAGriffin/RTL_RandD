`timescale 1ns / 1ps 
`default_nettype none 

module FPGA_Project (
	clk,
	reset,
	OLB_ready0,
	OLB_ready1,		
	OLB_ready2,
	OLB_ready3,
 	in_data0,
	in_data1,
	in_data2,
	in_data3,
	out_data0,
	out_data1,
	out_data2,
	out_data3,
	ILR0_ready,
	ILR1_ready,
	ILR2_ready,
	ILR3_ready
); 

	// Declare input ports

	input 	clk,
				reset,
				OLB_ready0,
				OLB_ready1,
				OLB_ready2,
				OLB_ready3;
	input	[31:0] 	in_data0,
						in_data1,
						in_data2,
						in_data3;
		
	// Declare output ports

	output [31:0]	out_data0, 	// PCIe lane 0 data
						out_data1, 	// PCIe lane 1 data
						out_data2, 	// PCIe lane 2 data
						out_data3; 	// PCIe lane 3 data
	output	ILR0_ready, // PCIe lane 0 ready signal
				ILR1_ready, // PCIe lane 1 ready signal
				ILR2_ready, // PCIe lane 2 ready signal
				ILR3_ready; // PCIe lane 3 ready signal

	// Declare Middle Ports

	wire	[34:0]	data_I0_B0,
			data_I0_B1,
			data_I0_B2,
			data_I1_B0,
			data_I1_B1,
			data_I1_B2,
			data_I2_B0,
			data_I2_B1,
			data_I2_B2,
			data_I3_B0,
			data_I3_B1,
			data_I3_B2,
			data_B0,
			data_B1,
			data_B2,
			data_B3,
			data_O0_B0,
			data_O0_B1,
			data_O0_B2,
			data_O0_B3,
			data_O1_B0,
			data_O1_B1,
			data_O1_B2,
			data_O1_B3,
			data_O2_B0,
			data_O2_B1,
			data_O2_B2,
			data_O2_B3,
			data_O3_B0,
			data_O3_B1,
			data_O3_B2,
			data_O3_B3,
			data_OLB0,
			data_OLB1,
			data_OLB2,
			data_OLB3;

	wire	[31:0]	data_HS0_O0,
			data_HS1_O1,
			data_HS2_O2,
			data_HS3_O3;
	
	wire	[3:0]	cs_HS0_O0,
			cs_HS1_O1,
			cs_HS2_O2,
			cs_HS3_O3;

	wire	ready_I0_B0,
		ready_I0_B1,
		ready_I0_B2,
		ready_I1_B0,
		ready_I1_B1,
		ready_I1_B2,
		ready_I2_B0,
		ready_I2_B1,
		ready_I2_B2,
		ready_I3_B0,
		ready_I3_B1,
		ready_I3_B2,
		ready_B0_O0,
		ready_B1_O1,
		ready_B2_O2,
		ready_B3_O3,
		ready_HS0_O0,
		ready_HS1_O1,
		ready_HS2_O2,
		ready_HS3_O3,
		ready_O0_B0,
		ready_O0_B1,
		ready_O0_B2,
		ready_O0_B3,
		ready_O1_B0,
		ready_O1_B1,
		ready_O1_B2,
		ready_O1_B3,
		ready_O2_B0,
		ready_O2_B1,
		ready_O2_B2,
		ready_O2_B3,
		ready_O3_B0,
		ready_O3_B1,
		ready_O3_B2,
		ready_O3_B3;

	//Generate Block
	
	ILR #(
		0
	) ILR0 (
		.data_out0(data_I0_B0),
		.data_out1(data_I0_B1),
		.data_out2(data_I0_B2),
		.ready(ILR0_ready),
		.data_in(in_data0),
		.clk(clk),
		.reset(reset),
		.buffer_ready0(ready_I0_B0),
		.buffer_ready1(ready_I0_B1),
		.buffer_ready2(ready_I0_B2)
	);
	
	ILR #(
		1
	) ILR1 (
		.data_out0(data_I1_B0),
		.data_out1(data_I1_B1),
		.data_out2(data_I1_B2),
		.ready(ILR1_ready),
		.data_in(in_data1),
		.clk(clk),
		.reset(reset),
		.buffer_ready0(ready_I1_B0),
		.buffer_ready1(ready_I1_B1),
		.buffer_ready2(ready_I1_B2)
	);
	
	ILR #(
		2
	) ILR2 (
		.data_out0(data_I2_B0),
		.data_out1(data_I2_B1),
		.data_out2(data_I2_B2),
		.ready(ILR2_ready),
		.data_in(in_data2),
		.clk(clk),
		.reset(reset),
		.buffer_ready0(ready_I2_B0),
		.buffer_ready1(ready_I2_B1),
		.buffer_ready2(ready_I2_B2)
	);
	
	ILR #(
		3
	) ILR3 (
		.data_out0(data_I3_B0),
		.data_out1(data_I3_B1),
		.data_out2(data_I3_B2),
		.ready(ILR3_ready),
		.data_in(in_data3),
		.clk(clk),
		.reset(reset),
		.buffer_ready0(ready_I3_B0),
		.buffer_ready1(ready_I3_B1),
		.buffer_ready2(ready_I3_B2)
	);

	Buffer HSB0 (
		.clk(clk),
		.reset(reset),
		.in_ready(ready_B0_O0),
		.in_data0(data_I0_B0),
		.ready0(ready_I0_B0),
		.in_data1(data_I1_B0),
		.ready1(ready_I1_B0),
		.in_data2(data_I2_B0),
		.ready2(ready_I2_B0),
		.in_data3(data_I3_B0),
		.ready3(ready_I3_B0),
		.out_data(data_B0)
	);

	Buffer HSB1 (
		.clk(clk),
		.reset(reset),
		.in_ready(ready_B1_O1),
		.in_data0(data_I0_B1),
		.ready0(ready_I0_B1),
		.in_data1(data_I1_B1),
		.ready1(ready_I1_B1),
		.in_data2(data_I2_B1),
		.ready2(ready_I2_B1),
		.in_data3(data_I3_B1),
		.ready3(ready_I3_B1),
		.out_data(data_B1)
	);

	Buffer HSB2 (
		.clk(clk),
		.reset(reset),
		.in_ready(ready_B2_O2),
		.in_data0(data_I0_B2),
		.ready0(ready_I0_B2),
		.in_data1(data_I1_B2),
		.ready1(ready_I1_B2),
		.in_data2(data_I2_B2),
		.ready2(ready_I2_B2),
		.in_data3(data_I3_B2),
		.ready3(ready_I3_B2),
		.out_data(data_B2)
	);
	
	HardwareSubunit #(
		5
	) HardwareSubunit0 (
		.clk(clk),
		.reset(reset),
		.in_data(data_B0),
		.next_ready(ready_HS0_O0),
		.out_data(data_HS0_O0),
		.completion_status(cs_HS0_O0)
	);
	
	HardwareSubunit #(
		25
	) HardwareSubunit1 (
		.clk(clk),
		.reset(reset),
		.in_data(data_B1),
		.next_ready(ready_HS1_O1),
		.out_data(data_HS1_O1),
		.completion_status(cs_HS1_O1)
	);
	
	HardwareSubunit #(
		100
	) HardwareSubunit2 (
		.clk(clk),
		.reset(reset),
		.in_data(data_B2),
		.next_ready(ready_HS2_O2),
		.out_data(data_HS2_O2),
		.completion_status(cs_HS2_O2)
	);
	
	OLR OLR0 (
		.clk(clk),
		.reset(reset),
		.header_in(data_B0),
		.payload_in(data_HS0_O0),
		.completion_status(cs_HS0_O0),
		.buffer_ready0(ready_O0_B0),
		.buffer_ready1(ready_O0_B1),
		.buffer_ready2(ready_O0_B2),
		.buffer_ready3(ready_O0_B3),
		.data_out0(data_O0_B0),
		.data_out1(data_O0_B1),
		.data_out2(data_O0_B2),
		.data_out3(data_O0_B3),
		.ready_buffer(ready_B0_O0),
		.ready_subunit(ready_HS0_O0)
	);
	
	OLR OLR1 (
		.clk(clk),
		.reset(reset),
		.header_in(data_B1),
		.payload_in(data_HS1_O1),
		.completion_status(cs_HS1_O1),
		.buffer_ready0(ready_O1_B0),
		.buffer_ready1(ready_O1_B1),
		.buffer_ready2(ready_O1_B2),
		.buffer_ready3(ready_O1_B3),
		.data_out0(data_O1_B0),
		.data_out1(data_O1_B1),
		.data_out2(data_O1_B2),
		.data_out3(data_O1_B3),
		.ready_buffer(ready_B1_O1),
		.ready_subunit(ready_HS1_O1)
	);
	
	OLR OLR2 (
		.clk(clk),
		.reset(reset),
		.header_in(data_B2),
		.payload_in(data_HS2_O2),
		.completion_status(cs_HS2_O2),
		.buffer_ready0(ready_O2_B0),
		.buffer_ready1(ready_O2_B1),
		.buffer_ready2(ready_O2_B2),
		.buffer_ready3(ready_O2_B3),
		.data_out0(data_O2_B0),
		.data_out1(data_O2_B1),
		.data_out2(data_O2_B2),
		.data_out3(data_O2_B3),
		.ready_buffer(ready_B2_O2),
		.ready_subunit(ready_HS2_O2)
	);

	Buffer OLB0 (
		.clk(clk),
		.reset(reset),
		.in_ready(OLB_ready0),
		.in_data0(data_O0_B0),
		.ready0(ready_O0_B0),
		.in_data1(data_O1_B0),
		.ready1(ready_O1_B0),
		.in_data2(data_O2_B0),
		.ready2(ready_O2_B0),
		.in_data3(35'b0),
		.ready3(),
		.out_data(data_OLB0)
	);

	Buffer OLB1 (
		.clk(clk),
		.reset(reset),
		.in_ready(OLB_ready1),
		.in_data0(data_O0_B1),
		.ready0(ready_O0_B1),
		.in_data1(data_O1_B1),
		.ready1(ready_O1_B1),
		.in_data2(data_O2_B1),
		.ready2(ready_O2_B1),
		.in_data3(35'b0),
		.ready3(),
		.out_data(data_OLB1)
	);

	Buffer OLB2 (
		.clk(clk),
		.reset(reset),
		.in_ready(OLB_ready2),
		.in_data0(data_O0_B2),
		.ready0(ready_O0_B2),
		.in_data1(data_O1_B2),
		.ready1(ready_O1_B2),
		.in_data2(data_O2_B2),
		.ready2(ready_O2_B2),
		.in_data3(35'b0),
		.ready3(),
		.out_data(data_OLB2)
	);

	Buffer OLB3 (
		.clk(clk),
		.reset(reset),
		.in_ready(OLB_ready3),
		.in_data0(data_O0_B3),
		.ready0(ready_O0_B3),
		.in_data1(data_O1_B3),
		.ready1(ready_O1_B3),
		.in_data2(data_O2_B3),
		.ready2(ready_O2_B3),
		.in_data3(35'b0),
		.ready3(),
		.out_data(data_OLB3)
	);

	//Assign Statements

	assign out_data0 = data_OLB0[31:0];
	assign out_data1 = data_OLB1[31:0];
	assign out_data2 = data_OLB2[31:0];
	assign out_data3 = data_OLB3[31:0];

	//Always Blocks

endmodule
