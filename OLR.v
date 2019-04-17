`timescale 1ns / 1ps

module OLR (
	clk,
	reset,
	header_in,
	payload_in,
	completion_status,
	buffer_ready0,
	buffer_ready1,
	buffer_ready2,
	buffer_ready3,
	data_out0,
	data_out1,
	data_out2,
	data_out3,
	ready_buffer,
	ready_subunit
);

//Define inputs to the OLR
	input [34:0]	header_in;
	input [31:0]	payload_in;
	input [3:0]	completion_status;
	input		clk,
			reset,
			buffer_ready0,
			buffer_ready1,
			buffer_ready2,
			buffer_ready3;

//Define outputs from the OLR
	output [34:0] 	data_out0,
			data_out1,
			data_out2,
			data_out3;
	output		ready_buffer,
			ready_subunit;
	
   
	//Ingress-Sorter Wires
	wire [135:0]	header_data_IS;
	wire [39:0]	payload_data_IS;
	wire		sorter_ready;
   

	//Sorter-Egress Wires
	wire [103:0]	header_data_SE;
	wire [39:0]	payload_data_SE;
	wire		egress_ready;

	//Ingress Module
	OLR_Ingress ingress(
		.header_out(header_data_IS),
		.payload_out(payload_data_IS),
		.ready1(ready_buffer),
		.ready2(ready_subunit),
		.payload_in(payload_in),
		.header_in(header_in),
		.completionstatus_in(completion_status),
		.clk(clk),
		.reset(reset),
		.sorter_ready(sorter_ready)
	);
   
	//Sorter Module
	OLR_Sorter sorter(
		.sorted_header(header_data_SE),
		.pass_through_payload(payload_data_SE),
		.ready(sorter_ready),
		.in_data_header(header_data_IS),
		.in_data_payload(payload_data_IS),
		.next_ready(egress_ready),
		.reset(reset),
		.clk(clk)
	);
   
   	//Egress Module
   	OLR_Egress egress(
		.data_out0(data_out0),
		.data_out1(data_out1),
		.data_out2(data_out2),
		.data_out3(data_out3),
		.ready(egress_ready),
		.header_in(header_data_SE),
		.payload_in(payload_data_SE),
		.clk(clk),
		.reset(reset),
		.buffer_ready0(buffer_ready0),
		.buffer_ready1(buffer_ready1),
		.buffer_ready2(buffer_ready2),
		.buffer_ready3(buffer_ready3)
	);
 
endmodule

