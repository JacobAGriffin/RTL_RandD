`timescale 1ns / 1ps

module InputLinkRouter(ready, header_array0, header_array1, header_array2, header_array3, payload_array0, payload_array1, payload_array2, payload_array3, transmit_link_output_buffer_full, hardware_subunit_input_buffer_full, clk, in_data);
	input	transmit_link_output_buffer_full;    	// Flag stating that the output buffer is full, stalls the corresponding lane
	input	[3:0] hardware_subunit_input_buffer_full; 	// Flag stating that the input buffer is full, stalls all lanes
	input   clk;
	input 	[31:0] in_data; 	    	// Input data 
	input   buffer_ready0;
	input   buffer_ready1;
	input   buffer_ready2;
	input   buffer_ready3;
	output wire ready;
	output wire [39:0] header_array0;
	output wire [39:0] header_array1;
	output wire [39:0] header_array2;
	output wire [39:0] header_array3;
	output wire [39:0] payload_array0;
	output wire [39:0] payload_array1;
	output wire [39:0] payload_array2;
	output wire [39:0] payload_array3;
   
	//Ingress-Sorter Wires
	wire [31:0] payload_bus1;
	wire ready1;
	wire [127:0] header_bus;
   

	//Sorter-Egress Wires
	wire [95:0] sorted_header_bus;
	wire [31:0] payload_bus2;
	wire [2:0]  link_destination;
	wire ready2;

	//Ingress Module
  	InputLinkRouterIngress ingress(payload_bus1, ready, header_bus, transmit_link_ourput_buffer_full, hardware_subunit_input_buffer_full, clk, in_data, ready1);	
   
	//Sorter Module
	Header_Sorter sorter(sorted_header_bus, payload_bus2, link_destination, ready2, header_bus, payload_bus1, ready1, clk);
   
   	//Egress Module
   	InputLinkRouterEgress egress(ready2, header_array0, header_array1, header_array2, header_array3, payload_array0, payload_array1, payload_array2, payload_array3, sorted_header_bus, payload_bus2, buffer_ready0, buffer_ready1, buffer_ready2, buffer_ready3, link_destination, clk);
 
endmodule

