`timescale 1ns / 1ps 
`default_nettype none 

`define STRLEN 15 

module FPGA_Project_Test;

	//task used to input data to lane 0
	task stim0; 
		input [31:0] 	newin_data0;

		output [31:0] 	setin_data0;

		begin
			setin_data0 = newin_data0;
		end
	endtask

	//task used to input data to lane 1
	task stim1; 
		input [31:0] 	newin_data1;

		output [31:0] 	setin_data1;

		begin
			setin_data1 = newin_data1;
		end
	endtask

	//task used to input data to lane 2
	task stim2; 
		input [31:0] 	newin_data2;

		output [31:0] 	setin_data2;

		begin
			setin_data2 = newin_data2;
		end
	endtask

	//task used to input data to lane 3
	task stim3; 
		input [31:0] 	newin_data3;

		output [31:0] 	setin_data3;

		begin
			setin_data3 = newin_data3;
		end
	endtask

// Declare inputs to the testbench (from the system)
	reg 	clk,
		reset,
		OLB_ready0,
		OLB_ready1,
		OLB_ready2,
		OLB_ready3;

	reg	[31:0] 	in_data0,
			in_data1,
			in_data2,
			in_data3;
		


// Declare output ports	 (to the system)	    	
	wire	[31:0]	out_data0, 	// Output data
			out_data1, 	// Output data
			out_data2, 	// Output data
			out_data3; 	// Output data
	wire	ILR0_ready,
		ILR1_ready,
		ILR2_ready,
		ILR3_ready;

	// Helper
	integer		passed0 = 0,
			passed1 = 0,
			passed2 = 0,
			passed3 = 0;
	
	// Logic Variables
	integer i = 0,			//used in clock counter
		j0 = 0,			//used for actual output vector counter
		k0 = 0,			//used for expected output vector counter
		p0 = 0,			//used for checking payload expected and actual
		j1 = 0,			//used for actual output vector counter
		k1 = 0,			//used for expected output vector counter
		p1 = 0,			//used for checking payload expected and actual
		j2 = 0,			//used for actual output vector counter
		k2 = 0,			//used for expected output vector counter
		p2 = 0,			//used for checking payload expected and actual
		j3 = 0,			//used for actual output vector counter
		k3 = 0,			//used for expected output vector counter
		p3 = 0,			//used for checking payload expected and actual
		data_stall0 = 0,	//used to ensure data stays high long enough when inputting to the pipeline
		data_stall1 = 0,	//used to ensure data stays high long enough when inputting to the pipeline
		data_stall2 = 0,	//used to ensure data stays high long enough when inputting to the pipeline
		data_stall3 = 0,	//used to ensure data stays high long enough when inputting to the pipeline
		out_stall0 = 0,		//used to ensure data is not read twice into the output file
		out_stall1 = 0,		//used to ensure data is not read twice into the output file
		out_stall2 = 0,		//used to ensure data is not read twice into the output file
		out_stall3 = 0,		//used to ensure data is not read twice into the output file
		tmp0, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp1, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp2, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp3, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp4, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp5, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp6, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		tmp7, 			//needed to ensure the fscanf function works ¯\_(ツ)_/¯
		in0_count1 = 0,		//used as TLP input indexer(from the .txt to the register)
		in0_count2 = 0,		//used to input data to the pipeline at the correct time
		out0_count1 = 0,	//used as the output indexer (from output to the output register)
		out0_count2 = 0,	//used as the second output indexer (from the output register to the output file)
		in1_count1 = 0,		//used as TLP input indexer(from the .txt to the register)
		in1_count2 = 0,		//used to input data to the pipeline at the correct time
		out1_count1 = 0,	//used as the output indexer (from output to the output register)
		out1_count2 = 0,	//used as the second output indexer (from the output register to the output file)
		in2_count1 = 0,		//used as TLP input indexer(from the .txt to the register)
		in2_count2 = 0,		//used to input data to the pipeline at the correct time
		out2_count1 = 0,	//used as the output indexer (from output to the output register)
		out2_count2 = 0,	//used as the second output indexer (from the output register to the output file)
		in3_count1 = 0,		//used as TLP input indexer(from the .txt to the register)
		in3_count2 = 0,		//used to input data to the pipeline at the correct time
		out3_count1 = 0,	//used as the output indexer (from output to the output register)
		out3_count2 = 0;	//used as the second output indexer (from the output register to the output file)

    	integer in_file0,	//file that has the randomly generated input TLPs for link 0
		in_file1,	//file that has the randomly generated input TLPs for link 1
		in_file2,	//file that has the randomly generated input TLPs for link 2
		in_file3,	//file that has the randomly generated input TLPs for link 3
		out_file0,	//file that contains the corresponding expected output TLPs for link 0
		out_file1,	//file that contains the corresponding expected output TLPs for link 1
		out_file2,	//file that contains the corresponding expected output TLPs for link 2
		out_file3;	//file that contains the corresponding expected output TLPs for link 3


	reg [31:0]	TLPin_holder0 [200000:0],		//register used to store each TLP on the input side
			TLPin_holder1 [200000:0],		//register used to store each TLP on the input side
			TLPin_holder2 [200000:0],		//register used to store each TLP on the input side
			TLPin_holder3 [200000:0],		//register used to store each TLP on the input side
			TLPout_actual0 [200000:0], 		//register used to store each TLP on the output side
			TLPout_actual1 [200000:0],		//register used to store each TLP on the output side
			TLPout_actual2 [200000:0], 		//register used to store each TLP on the output side
			TLPout_actual3 [200000:0], 		//register used to store each TLP on the output side
			TLPout_expected0 [200000:0], 		//register used to store the expected output for each TLP
			TLPout_expected1 [200000:0],		//register used to store the expected output for each TLP
			TLPout_expected2 [200000:0], 		//register used to store the expected output for each TLP
			TLPout_expected3 [200000:0]; 		//register used to store the expected output for each TLP

	// Instantiate the Unit Under Test (UUT)
	FPGA_Project uut (
		.clk(clk),
		.reset(reset),
		.OLB_ready0(OLB_ready0),
		.OLB_ready1(OLB_ready1),		
		.OLB_ready2(OLB_ready2),
		.OLB_ready3(OLB_ready3),
	 	.in_data0(in_data0),
		.in_data1(in_data1),
		.in_data2(in_data2),
		.in_data3(in_data3),
		.out_data0(out_data0),
		.out_data1(out_data1),
		.out_data2(out_data2),
		.out_data3(out_data3),
		.ILR0_ready(ILR0_ready),
		.ILR1_ready(ILR1_ready),
		.ILR2_ready(ILR2_ready),
		.ILR3_ready(ILR3_ready)
	);

////////////////////////////////////////////////////////////////////////////////////////
/*		System input initialization					      */

	initial begin
		clk = 0;
		reset = 1;
		OLB_ready0 = 1'b0;
		OLB_ready1 = 1'b0;
		OLB_ready2 = 1'b0;
		OLB_ready3 = 1'b0;
		in_data0 = 32'b0;
		in_data1 = 32'b0;
		in_data2 = 32'b0;
		in_data3 = 32'b0;
		#10
		reset = 0;
	end



////////////////////////////////////////////////////////////////////////////////////////
/*		read in TLPs from TLP generator					      */


	//This block reads in inputs from the TLP files (& will output the output TLP's when we have them)
	initial begin   
		//open each file, and prepare them to be read
		in_file0 = $fopen("TLPgen_in0.txt","r");
		in_file1 = $fopen("TLPgen_in1.txt","r");
		in_file2 = $fopen("TLPgen_in2.txt","r");
		in_file3 = $fopen("TLPgen_in3.txt","r");
		out_file0 = $fopen("TLPgen_out0.txt", "r");
		out_file1 = $fopen("TLPgen_out1.txt", "r"); 
		out_file2 = $fopen("TLPgen_out2.txt", "r"); 
		out_file3 = $fopen("TLPgen_out3.txt", "r"); 

		//read the TLPs of the input and output files and place them in their respective vector arrays
		while (!$feof(in_file0) || !$feof(in_file1) || !$feof(in_file2) || !$feof(in_file3) || !$feof(out_file0) || !$feof(out_file1) || !$feof(out_file2) || !$feof(out_file3))
		begin 
			//read in input TLPs
			tmp0 = $fscanf(in_file0,"%b",TLPin_holder0[in0_count1]); //scan each line and place the resultant in the lane 0 input vector
			if(!$feof(in_file0))
			begin
				in0_count1 = in0_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp1 = $fscanf(in_file1,"%b",TLPin_holder1[in1_count1]); //scan each line and place the resultant in the lane 1 input vector
			if(!$feof(in_file1))
			begin
				in1_count1 = in1_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp2 = $fscanf(in_file2,"%b",TLPin_holder2[in2_count1]); //scan each line and place the resultant in the lane 2 input vector
			if(!$feof(in_file2))
			begin
				in2_count1 = in2_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp3 = $fscanf(in_file3,"%b",TLPin_holder3[in3_count1]); //scan each line and place the resultant in the lane 3 input vector
			if(!$feof(in_file3))
			begin
				in3_count1 = in3_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end

			//read in expected output TLPs
			tmp4 = $fscanf(out_file0,"%b",TLPout_expected0[out0_count1]); //scan each line and place the resultant in the lane 0 input vector
			if(!$feof(out_file0))
			begin
				out0_count1 = out0_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp5 = $fscanf(out_file1,"%b",TLPout_expected1[out1_count1]); //scan each line and place the resultant in the lane 1 input vector
			if(!$feof(out_file1))
			begin
				out1_count1 = out1_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp6 = $fscanf(out_file2,"%b",TLPout_expected2[out2_count1]); //scan each line and place the resultant in the lane 2 input vector
			if(!$feof(out_file2))
			begin
				out2_count1 = out2_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
			tmp7 = $fscanf(out_file3,"%b",TLPout_expected3[out3_count1]); //scan each line and place the resultant in the lane 3 input vector
			if(!$feof(out_file3))
			begin
				out3_count1 = out3_count1 + 1;	//increment the input vector index, until all TLPs have been read in
			end
		end 
		//close all files once they have been completely read in
		$fclose(in_file0);
		$fclose(in_file1);
		$fclose(in_file2);
		$fclose(in_file3);	
		$fclose(out_file0);
		$fclose(out_file1);
		$fclose(out_file2);
		$fclose(out_file3);
		$fclose(out_file4);
		$fclose(out_file5);
		$fclose(out_file6);
		$fclose(out_file7);
	end

////////////////////////////////////////////////////////////////////////////////////////
/*		Clock manipulation				      */

	//this always block controls the clock signal, it is desired to always be cycling
	always
	begin
		#5
		clk = ~clk;
	end


////////////////////////////////////////////////////////////////////////////////////////
/*		Data input into system						      */

	//this always block inputs the TLPs into the pipeline when the ILR is ready
	always @(posedge clk)
	begin
		//Data input functions for lane 1
		if(data_stall0 == 0 && ILR0_ready == 1)
		begin
			stim0(				//stim function inputs the data
				TLPin_holder0[in0_count2],
				in_data0
			);
			data_stall0 = 1;		//hold the data high for one cycle to simulate the timing scheme
		end
		else if(data_stall0 == 1)
		begin
			data_stall0 = 0;		//drop the data stall signal so that the data can be dropped next cycle
			stim0(
				TLPin_holder0[in0_count2],
				in_data0
			);
			in0_count2 = in0_count2 + 1;	//increment the vector file index, to move to the next 32 bits of TLP
		end
		else
		begin
			in_data0 = 0;			//after the data has been high for two cycles, it can be dropped
		end

		//Data input functions for lane 1
		if(data_stall1 == 0 && ILR1_ready == 1)
		begin
			stim1(				//stim function inputs the data
				TLPin_holder1[in1_count2],
				in_data1
			);
			data_stall1 = 1;		//hold the data high for one cycle to simulate the timing scheme
		end
		else if(data_stall1 == 1)
		begin
			data_stall1 = 0;		//drop the data stall signal so that the data can be dropped next cycle
			stim1(
				TLPin_holder1[in1_count2],
				in_data1
			);
			in1_count2 = in1_count2 + 1;	//increment the vector file index, to move to the next 32 bits of TLP
		end
		else
		begin
			in_data1 = 0;			//after the data has been high for two cycles, it can be dropped
		end

		//Data input functions for lane 2
		if(data_stall2 == 0 && ILR2_ready == 1)
		begin
			stim2(				//stim function inputs the data
				TLPin_holder2[in2_count2],
				in_data2
			);
			data_stall2 = 1;		//hold the data high for one cycle to simulate the timing scheme
		end
		else if(data_stall2 == 1)
		begin
			data_stall2 = 0;		//drop the data stall signal so that the data can be dropped next cycle
			stim2(
				TLPin_holder2[in2_count2],
				in_data2
			);
			in2_count2 = in2_count2 + 1;	//increment the vector file index, to move to the next 32 bits of TLP
		end
		else
		begin
			in_data2 = 0;			//after the data has been high for two cycles, it can be dropped
		end

		//Input data functions for lane 3
		if(data_stall3 == 0 && ILR3_ready == 1)
		begin
			stim3(				//stim function inputs the data
				TLPin_holder3[in3_count2],
				in_data3
			);
			data_stall3 = 1;		//hold the data high for one cycle to simulate the timing scheme
		end
		else if(data_stall3 == 1)
		begin
			data_stall3 = 0;		//drop the data stall signal so that the data can be dropped next cycle
			stim3(
				TLPin_holder3[in3_count2],
				in_data3
			);
			in3_count2 = in3_count2 + 1;	//increment the vector file index, to move to the next 32 bits of TLP
		end
		else
		begin
			in_data3 = 0;			//after the data has been high for two cycles, it can be dropped
		end


////////////////////////////////////////////////////////////////////////////////////////
/*		Intake outputs from the system					      */

		//reading outputs for lane0
		if(out_stall0 == 0 && out_data0 != 0)
		begin
			TLPout_actual0[out0_count2] = out_data0;	//each time data is output, it is placed into it's own vector slot
			out0_count2 = out0_count2 + 1;			//this counter is then incremented for the next piece of output data
			out_stall0 = 1;					//set out_stall high so this function is not done twice for each piece of output data
		end
		else if(out_stall0 == 1)
		begin
			out_stall0 = 0;					//out_stall is then dropped after the second cycle, new data can now be read in
		end

		//reading outputs for lane1
		if(out_stall1 == 0 && out_data1 != 0)
		begin
			TLPout_actual1[out1_count2] = out_data1;	//each time data is output, it is placed into it's own vector slot
			out1_count2 = out1_count2 + 1;			//this counter is then incremented for the next piece of output data
			out_stall1 = 1;					//set out_stall high so this function is not done twice for each piece of output data
		end
		else if(out_stall1 == 1)
		begin
			out_stall1 = 0;					//out_stall is then dropped after the second cycle, new data can now be read in
		end
		
		//reading outputs for lane2
		if(out_stall2 == 0 && out_data2 != 0)
		begin
			TLPout_actual2[out2_count2] = out_data2;	//each time data is output, it is placed into it's own vector slot
			out2_count2 = out2_count2 + 1;			//this counter is then incremented for the next piece of output data
			out_stall2 = 1;					//set out_stall high so this function is not done twice for each piece of output data
		end
		else if(out_stall2 == 1)
		begin
			out_stall2 = 0;					//out_stall is then dropped after the second cycle, new data can now be read in
		end

		//reading outputs for lane3
		if(out_stall3 == 0 && out_data3 != 0)
		begin
			TLPout_actual3[out3_count2] = out_data3;	//each time data is output, it is placed into it's own vector slot
			out3_count2 = out3_count2 + 1;			//this counter is then incremented for the next piece of output data
			out_stall3 = 1;					//set out_stall high so this function is not done twice for each piece of output data
		end
		else if(out_stall3 == 1)
		begin
			out_stall3 = 0;					//out_stall is then dropped after the second cycle, new data can now be read in
		end

		
////////////////////////////////////////////////////////////////////////////////////////
/*		Stimulate the OLB_Ready buffers 				      */

		//set OLB_ready signals high until data is output, once it is they drop until the data has been read in
		if(OLB_ready0 == 0)
		begin
			OLB_ready0 = 1;
		end
		else if(out_data0 != 0)
		begin
			OLB_ready0 = 0;
		end
		
		if(OLB_ready1 == 0)
		begin
			OLB_ready1 = 1;
		end
		else if(out_data1 != 0)
		begin
			OLB_ready1 = 0;
		end

		if(OLB_ready2 == 0)
		begin
			OLB_ready2 = 1;
		end
		else if(out_data2 != 0)
		begin
			OLB_ready2 = 0;
		end

		if(OLB_ready3 == 0)
		begin
			OLB_ready3 = 1;
		end
		else if(out_data3 != 0)
		begin
			OLB_ready3 = 0;
		end
	end		



////////////////////////////////////////////////////////////////////////////////////////
/*		Comparison of outputs						      */

	//Lane 0 verification
	initial
	begin
		#1500000 //delay before the system begins to check the outputs
		if(out0_count1 != out0_count2)
		begin
			$display("Not enough output on lane 0: Out = %d, Needed = %d", out0_count2, out0_count1);	//if the amount of TLPs in actual & expected output vectors do not match up, throw this error message
		end
		else
		begin
			$display("Lane 0 has enough output: Out = %d, Needed = %d", out0_count2, out0_count1);		//if the amount of TLPs do match up, throw this success message
		end
		
		for (j0 = 0; j0 < out0_count2; j0 = j0 + 1)	//runs through each index of data that has been received from the pipeline
		begin
			for (k0 = 0; k0 < out0_count1; k0 = k0 + 1)	//this is then checked against each expected TLP
			begin
				//if the value of the indices both match (and are not 0)
				if (TLPout_actual0[j0] == TLPout_expected0[k0] && TLPout_actual0[j0] != 0 && TLPout_expected0[k0] != 0)
				begin
					TLPout_actual0[j0] = 0;		//clear the actual result
					TLPout_expected0[k0] = 0;	//clear the corresponding expected results (prevents double-dipping of the expected output file)
					passed0 = passed0 + 1;		//increment the passed counter, as these TLPs matched
					k0 = out0_count1;		//reset the expected output file index
				end
			end
		end
		$display("Lane 0 has passed = %d", passed0);		//output how many output TLP blocks matched with the expected results
	end

	
	//Lane 1 verification
	initial
	begin
		#1500000 //delay before the system begins to check the outputs
		if(out1_count1 != out1_count2)
		begin
			$display("Not enough output on lane 1: Out = %d, Needed = %d", out1_count2, out1_count1);	//if the amount of TLPs in actual & expected output vectors do not match up, throw this error message
		end
		else
		begin
			$display("Lane 1 has enough output: Out = %d, Needed = %d", out1_count2, out1_count1);		//if the amount of TLPs do match up, throw this success message
		end
		
		for (j1 = 0; j1 < out1_count2; j1 = j1 + 1)	//runs through each index of data that has been received from the pipeline
		begin
			for (k1 = 0; k1 < out1_count1; k1 = k1 + 1)	//this is then checked against each expected TLP
			begin
				//if the value of the indices both match (and are not 0)
				if (TLPout_actual1[j1] == TLPout_expected1[k1] && TLPout_actual1[j1] != 0 && TLPout_expected1[k1] != 0)
				begin
					TLPout_actual1[j1] = 0;		//clear the actual result
					TLPout_expected1[k1] = 0;	//clear the corresponding expected results (prevents double-dipping of the expected output file)
					passed1 = passed1 + 1;		//increment the passed counter, as these TLPs matched
					k1 = out1_count1;		//reset the expected output file index
				end
			end
		end
		$display("Lane 1 has passed = %d", passed1);		//output how many output TLP blocks matched with the expected results
	end


	//Lane 2 verification
	initial
	begin
		#1500000 //delay before the system begins to check the outputs
		if(out2_count1 != out2_count2)
		begin
			$display("Not enough output on lane 2: Out = %d, Needed = %d", out2_count2, out2_count1);	//if the amount of TLPs in actual & expected output vectors do not match up, throw this error message
		end
		else
		begin
			$display("Lane 2 has enough output: Out = %d, Needed = %d", out2_count2, out2_count1);		//if the amount of TLPs do match up, throw this success message
		end
		
		for (j2 = 0; j2 < out2_count2; j2 = j2 + 1)	//runs through each index of data that has been received from the pipeline
		begin
			for (k2 = 0; k2 < out2_count1; k2 = k2 + 1)	//this is then checked against each expected TLP
			begin
				//if the value of the indices both match (and are not 0)
				if (TLPout_actual2[j2] == TLPout_expected2[k2] && TLPout_actual2[j2] != 0 && TLPout_expected2[k2] != 0)
				begin
					TLPout_actual2[j2] = 0;		//clear the actual result
					TLPout_expected2[k2] = 0;	//clear the corresponding expected results (prevents double-dipping of the expected output file)
					passed2 = passed2 + 1;		//increment the passed counter, as these TLPs matched
					k2 = out2_count1;		//reset the expected output file index
				end
			end
		end
		$display("Lane 2 has passed = %d", passed2);		//output how many output TLP blocks matched with the expected results
	end


	//Lane 3 verification
	initial
	begin
		#1500000 //delay before the system begins to check the outputs
		if(out3_count1 != out3_count2)
		begin
			$display("Not enough output on lane 3: Out = %d, Needed = %d", out3_count2, out3_count1);	//if the amount of TLPs in actual & expected output vectors do not match up, throw this error message
		end
		else
		begin
			$display("Lane 3 has enough output: Out = %d, Needed = %d", out3_count2, out3_count1);		//if the amount of TLPs do match up, throw this success message
		end
		
		for (j3 = 0; j3 < out3_count2; j3 = j3 + 1)	//runs through each index of data that has been received from the pipeline
		begin
			for (k3 = 0; k3 < out3_count1; k3 = k3 + 1)	//this is then checked against each expected TLP
			begin
				//if the value of the indices both match (and are not 0)
				if (TLPout_actual3[j3] == TLPout_expected3[k3] && TLPout_actual3[j3] != 0 && TLPout_expected3[k3] != 0)
				begin
					TLPout_actual3[j3] = 0;		//clear the actual result
					TLPout_expected3[k3] = 0;	//clear the corresponding expected results (prevents double-dipping of the expected output file)
					passed3 = passed3 + 1;		//increment the passed counter, as these TLPs matched
					k3 = out3_count1;		//reset the expected output file index
				end
			end
		end
		$display("Lane 3 has passed = %d", passed3);		//output how many output TLP blocks matched with the expected results
	end

	
	initial //This initial block used to dump all wire/reg values to dump file
	begin
		$dumpfile("FPGA_Project_Test.vcd"); 
		$dumpvars(0,FPGA_Project_Test);
	end

	initial
	begin
		#1505000;  //total simulation run time
		$finish;
	end
	
endmodule 
