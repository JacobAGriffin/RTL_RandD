//
//  main.cpp
//  TLP Generation: Generate TLPs and their respective completion headers
//                  and print these to a text file
//
//  Created by Kevyn Robins on 3/20/19.
//  Copyright © 2019 Kevyn Robins. All rights reserved.
//
// Assuming max payload size is 128 bytes (pg. 599 of spec. sheet)
#include <stdlib.h>     // For random number generation, etc.
#include <stdio.h>      // For printf, NULL, etc.
#include <time.h>       // For time
#include <iostream>     // To write to a file
#include <fstream>
#include <vector>
#include <algorithm>    // To reverse the decToBinary vector
using namespace std;

/* ---------- Function Declarations: ---------- */
vector<bool>* decToBinary (int n, int length);
string* printPointerVect(vector<bool>* vect);
int binaryToDec(vector<bool>* length);
string* negateVector (vector<bool>* vec);

/* --------------- Main: --------------- */
int main(int argc, const char * argv[]) {

	if (argc < 2) {
		cout << "Requires two arguments: file_number and TLP_number" << endl;
		return 0;
	}
    
    ofstream myfile, myfile_in, myfile_out, myfile_out2;
    // Generate text file called TLPgeneration.txt
     //myfile.open("/Users/kevynrobins/Desktop/ECEN 403/TLPgen_cheatsheet0.txt");
    myfile.open("TLPgen_cheatsheet" + string(argv[1]) + ".txt");
     //myfile_in.open("/Users/kevynrobins/Desktop/ECEN 403/TLPgeneration_inputs.txt");
    myfile_in.open("TLPgen_in" + string(argv[1]) + ".txt");
     //myfile_out.open("/Users/kevynrobins/Desktop/ECEN 403/TLPgeneration_outputs.txt");
    myfile_out.open("TLPgen_out" + string(argv[1]) + ".txt");
    
    srand ((unsigned int) time(NULL));     // Initialize random seed
    
    int type_array [] = {0,2,4,5};  // Predetermined values to choose from for the type field
    for (int i = 0; i < stoi(argv[2]); i++) {
        vector<bool>* header_vector = new vector<bool>; // TLP header vector of size 128-bits
        vector<bool>* completion_vector = new vector<bool>;  // Completion header vector of size 96-bits
        // Variables used in all TLPs
        int type,
        fmt =0,
        R,
        TC,
        //bits14To18,
        bit14,
        bit15,
        bits16To18,
        Attr,
        AT,
        length = 0,
        reqID,
        tag,
        lastDWBE,
        firstDWBE = 0;
        // Variables used in specific TLPs
        int address31;      // Address [31:2] field used in I/O and memory requests
        int address63;      // Address [63:32] field used in 64-bit addressing memory requests
        int R2Bit;          // Two bit R field used in I/O and Configuration requests
        int busNum,         // Variables used in configuration requests
        deviceNum,
        functionNum,
        reserved,
        extRegNum,
        regNum;
        int PH;             // PH field used in 32-bit memory addressing
        // Variables used in completion headers
        int completerID,
        complStatus,
        byteCountBCM,
        lowAddress2,
        lowAddress5,
        fmtCompl,
        ATCompl;
        string payloadString;
        
        R = 0;  // For now, R in all headers is set to 0
        
        // Generate the TYPE field
        int RandIndex4 = rand() % 4; // Pick random index to choose value from array of size 4
        int RandIndex2 = rand() % 2;  // Pick random index to choose value from array of size 2
        type = type_array[RandIndex4];
        vector<bool>* type_binary = decToBinary(type, 5);
        vector<bool>* fmt_binary = new vector<bool>;
        vector<bool>* R_binary = decToBinary(R,1);
        vector<bool>* TC_binary = new vector<bool>;
        vector<bool>* bit14_binary = new vector<bool>;
        vector<bool>* bit15_binary = new vector<bool>;
        vector<bool>* bits16To18_binary = new vector<bool>;
        vector<bool>* Attr_binary = new vector<bool>;
        vector<bool>* AT_binary = new vector<bool>;
        vector<bool>* length_binary = new vector<bool>;
        vector<bool>* reqID_binary = new vector<bool>;
        vector<bool>* tag_binary = new vector<bool>;
        vector<bool>* lastDWBE_binary = new vector<bool>;
        vector<bool>* firstDWBE_binary = new vector<bool>;
        vector<bool>* address31_binary = new vector<bool>;
        vector<bool>* R2Bit_binary = new vector<bool>;
        vector<bool>* busNum_binary = new vector<bool>;
        vector<bool>* deviceNum_binary = new vector<bool>;
        vector<bool>* functionNum_binary = new vector<bool>;
        vector<bool>* reserved_binary = new vector<bool>;
        vector<bool>* extRegNum_binary = new vector<bool>;
        vector<bool>* regNum_binary = new vector<bool>;
        vector<bool>* PH_binary = new vector<bool>;
        vector<bool>* address63_binary = new vector<bool>;
        vector<bool>* completerID_binary = new vector<bool>;
        vector<bool>* complStatus_binary = new vector<bool>;
        vector<bool>* byteCountBCM_binary = new vector<bool>;
        vector<bool>* lowAddress2_binary = new vector<bool>;
        vector<bool>* lowAddress5_binary = new vector<bool>;
        vector<bool>* fmtCompl_binary = new vector<bool>;
        vector<bool>* ATCompl_binary = new vector<bool>;
        // If type field is 00000, it is a memory read/ write request
        if (type == 0){
            // Generate the FMT field
            //int fmt_array[] = {0,1,2,3};
            fmt = rand() % 4;
            fmt_binary = decToBinary(fmt, 3);
            // Set TC field
            TC = rand() % 8;    // These bits can range from 000 to 111
            TC_binary = decToBinary(TC,3);
            // Set bits 14 to 18
            //bits14To18 = rand() % 32;   // These bits can range from 00000 to 11111 (which is 31)
            //bits14To18_binary = decToBinary(bits14To18,5);
            bit14 = rand() % 2;
            bit14_binary = decToBinary(bit14, 1);
            bit15 = 0;
            bit15_binary = decToBinary(bit15, 1);
            bits16To18 = rand() % 8;
            bits16To18_binary = decToBinary(bits16To18, 3);
            // Set Attr field
            Attr = rand() % 4;  // These bits can range from 00 to 11
            Attr_binary = decToBinary(Attr, 2);
            // Set AT field
            AT = rand() % 4;  // These bits can range from 00 to 11
            AT_binary = decToBinary(AT, 2);
            // Set length field
            length = rand() % 32 + 1;     // Can reach up to max payload size of 128 bytes (so 32 DW)
            length_binary = decToBinary(length, 10);
            // Set requester ID field
            reqID = rand() % 65536; // These 16 bits can range from all 0's to all 1's
            reqID_binary = decToBinary(reqID, 16);
            // Set tag field
            tag = rand() % 256;
            tag_binary = decToBinary(tag, 8);
            // Set last DW BE field
            lastDWBE = rand() % 16;    // These bits can range from 0000 to 1111
            lastDWBE_binary = decToBinary(lastDWBE, 4);
            // Set first DW BE field
            if (lastDWBE == 0){
                firstDWBE = rand() % 16;
            }
            else if (lastDWBE != 0){
                int firstDWBE_array [] = {1,3,5,7,9,11,13,15,2,4,8};
                int RandIndex = rand() % 11;
                firstDWBE = firstDWBE_array[RandIndex];
            }
            firstDWBE_binary = decToBinary(firstDWBE, 4);
            // 32-bit addressing of memory
            if ((fmt == 0) || (fmt == 2)){
                // Set Address[31:2] field
                address31 = rand() % 1073741824; // These bits can range from 30 bits binary all 0's to all 1's
                address31_binary = decToBinary(address31, 30);
                // Set R field (2 bits) to 00
                PH = rand() % 4;
                PH_binary = decToBinary(PH, 2);
            }
            // 64-bit addressing of memory
            if ((fmt == 1) || (fmt == 3)){
                // Set Address[63:32] field
                address63 = rand() % 4294967296; // These 32 bits can range from all 0's to all 1's
                address63_binary = decToBinary(address63, 32);
                // Set Address[31:2] field
                address31 = rand() % 1073741824; // These bits can range from 30 bits binary all 0's to all 1's
                address31_binary = decToBinary(address31, 30);
                // Set PH field (2 bits) to 00
                PH = rand() % 4;
                PH_binary = decToBinary(PH, 2);
            }
        }
        // If type field is 00010, it is I/O request
        if (type == 2){
            // Set FMT field
            int fmt_array[] = {0,2};
            fmt = fmt_array[RandIndex2];
            fmt_binary = decToBinary(fmt, 3);
            // Set TC field to 000 for I/O
            TC = 0;
            TC_binary = decToBinary(TC,3);
            // Set bits 14 to 18
            // bits14To18 = rand() % 32;   // These bits can range from 00000 to 11111 (which is 31)
            // bits14To18_binary = decToBinary(bits14To18,5);
            bit14 = rand() % 2;
            bit14_binary = decToBinary(bit14, 1);
            bit15 = 0;
            bit15_binary = decToBinary(bit15, 1);
            bits16To18 = rand() % 8;
            bits16To18_binary = decToBinary(bits16To18, 3);
            // Set Attr field to 00 for I/O
            Attr = 0;
            Attr_binary = decToBinary(Attr, 2);
            // Set AT field to 00 for I/O
            AT = 0;
            AT_binary = decToBinary(AT, 2);
            // Set length field to 0000000001 for I/O
            length = 1;
            length_binary = decToBinary(1, 10);
            // Set requester ID field
            reqID = rand() % 65536; // These bits can range from 16 bits binary all 0's to all 1's
            reqID_binary = decToBinary(reqID, 16);
            // Set tag field
            tag = rand() % 256;
            tag_binary = decToBinary(tag, 8);
            // Set last DW BE field to 0000
            lastDWBE = 0;
            lastDWBE_binary = decToBinary(lastDWBE, 4);
            // Set first DW BE field
            firstDWBE = rand() % 16; // These bits can range from 0000 to 1111
            firstDWBE_binary = decToBinary(firstDWBE, 4);
            // Set Address[31:2] field
            address31 = rand() % 1073741824; // These bits can range from 30 bits binary all 0's to all 1's
            address31_binary = decToBinary(address31, 30);
            // Set R field (2 bits) to 00
            R2Bit = 0;
            R2Bit_binary = decToBinary(R2Bit, 2);
        }
        // If type field is 00100 or 00101, it is a configuration request
        if ((type == 4) || (type == 5)){
            int fmt_array[] = {0,2};
            fmt = fmt_array[RandIndex2];
            fmt_binary = decToBinary(fmt, 3);
            // Set TC field to 000 for I/O
            TC = 0;
            TC_binary = decToBinary(TC,3);
            // Set bits 14 to 18
            // bits14To18 = rand() % 32;   // These bits can range from 00000 to 11111 (which is 31)
            // bits14To18_binary = decToBinary(bits14To18,5);
            bit14 = rand() % 2;
            bit14_binary = decToBinary(bit14, 1);
            bit15 = 0;
            bit15_binary = decToBinary(bit15, 1);
            bits16To18 = rand() % 8;
            bits16To18_binary = decToBinary(bits16To18, 3);
            // Set Attr field to 00 for I/O
            Attr = 0;
            Attr_binary = decToBinary(Attr, 2);
            // Set AT field to 00 for I/O
            AT = 0;
            AT_binary = decToBinary(AT, 2);
            // Set length field to 0000000001 for I/O
            length = 1;
            length_binary = decToBinary(1, 10);
            // Set requester ID field
            reqID = rand() % 65536; // These bits can range from 16 bits binary all 0's to all 1's
            reqID_binary = decToBinary(reqID, 16);
            // Set tag field
            tag = rand() % 256;
            tag_binary = decToBinary(tag, 8);
            // Set last DW BE field to 0000
            lastDWBE = 0;
            lastDWBE_binary = decToBinary(lastDWBE, 4);
            // Set first DW BE field
            firstDWBE = rand() % 16;    // These bits can range from 0000 to 1111
            firstDWBE_binary = decToBinary(firstDWBE, 4);
            // Set bus number field
            busNum = rand() % 256;      // These bits can range from 8 bits all 0's to all 1's
            busNum_binary = decToBinary(busNum, 8);
            // Set device number field
            deviceNum = rand() % 32;    // These bits can range from 5 bits all 0's to all 1's
            deviceNum_binary = decToBinary(deviceNum, 5);
            // Set function number field
            functionNum = rand() % 8;   // These 3 bits can range from 000 to 111
            functionNum_binary = decToBinary(functionNum, 3);
            // Set reserved field to 0000
            reserved = 0;
            reserved_binary = decToBinary(reserved, 4);
            //Set ext. reg. field
            extRegNum = rand() % 16;    // These 4 bits can range from 0000 to 1111
            extRegNum_binary = decToBinary(extRegNum, 4);
            // Set register number field
            regNum = rand() % 64;   // These 6 bits can be range from 000000 to 111111
            regNum_binary = decToBinary(regNum, 6);
            // Set R field (2 bits) to 00
            R2Bit = 0;
            R2Bit_binary = decToBinary(R2Bit, 2);
        }
        // Store the binary values in header_vector
        header_vector->insert(header_vector->begin(), length_binary->begin(), length_binary->end());
        header_vector->insert(header_vector->begin(), AT_binary->begin(), AT_binary->end());
        header_vector->insert(header_vector->begin(), Attr_binary->begin(), Attr_binary->end());
        // header_vector->insert(header_vector->begin(), bits14To18_binary->begin(), bits14To18_binary->end());
        header_vector->insert(header_vector->begin(), bit14_binary->begin(), bit14_binary->end());
        header_vector->insert(header_vector->begin(), bit15_binary->begin(), bit15_binary->end());
        header_vector->insert(header_vector->begin(), bits16To18_binary->begin(), bits16To18_binary->end());
        header_vector->insert(header_vector->begin(), R_binary->begin(), R_binary->end());
        header_vector->insert(header_vector->begin(), TC_binary->begin(), TC_binary->end());
        header_vector->insert(header_vector->begin(), R_binary->begin(), R_binary->end());
        header_vector->insert(header_vector->begin(), type_binary->begin(), type_binary->end());
        header_vector->insert(header_vector->begin(), fmt_binary->begin(), fmt_binary->end());
        header_vector->insert(header_vector->begin(), firstDWBE_binary->begin(), firstDWBE_binary->end());
        header_vector->insert(header_vector->begin(), lastDWBE_binary->begin(), lastDWBE_binary->end());
        header_vector->insert(header_vector->begin(), tag_binary->begin(), tag_binary->end());
        header_vector->insert(header_vector->begin(), reqID_binary->begin(), reqID_binary->end());
        
        if (type == 0){
            if ((fmt == 0) || (fmt == 2)){
                // 32-bit addressing
                header_vector->insert(header_vector->begin(), PH_binary->begin(), PH_binary->end());
                header_vector->insert(header_vector->begin(), address31_binary->begin(), address31_binary->end());
                
                if (length !=0) {
                    string* negatedAddress31 = negateVector(address31_binary);
                    string address31EndString = negatedAddress31->substr(0,16);
                    string onesString = string(16, '1');
                    payloadString = onesString + address31EndString;
                }
            }
            if ((fmt == 1) || (fmt == 3)){
                // 64-bit addressing
                header_vector->insert(header_vector->begin(), address63_binary->begin(), address63_binary->end());
                header_vector->insert(header_vector->begin(), PH_binary->begin(), PH_binary->end());
                header_vector->insert(header_vector->begin(), address31_binary->begin(), address31_binary->end());
                
                if (length !=0) {
                    string* negatedAddress31 = negateVector(address31_binary);
                    string* negatedAddress63 = negateVector(address63_binary);
                    string address31EndString = negatedAddress31->substr(0,16);
                    string address63EndString = negatedAddress63->substr(16);
                    payloadString = address63EndString + address31EndString;
                }
            }
        }
        if (type == 2){
            // Store binary values specific to I/O requests
            // fmt for memory read completions is 010
            fmtCompl = 0;
            fmtCompl_binary = decToBinary(fmtCompl, 3);
            // Byte count/ BCM should be 13'b0000000111111
            byteCountBCM = 63;
            byteCountBCM_binary = decToBinary(byteCountBCM, 13); // Lower address should be 7'b0
            // Lower address should be 7'b0
            lowAddress2 = 0;
            lowAddress5 = 0;
            lowAddress2_binary = decToBinary(lowAddress2, 2);
            lowAddress5_binary = decToBinary(lowAddress5, 5);
            header_vector->insert(header_vector->begin(), R2Bit_binary->begin(), R2Bit_binary->end());
            header_vector->insert(header_vector->begin(), address31_binary->begin(), address31_binary->end());
            myfile << "I/O request: " << "\n";
        }
        if ((type == 4)|| (type == 5)){
            // Store binary values specific to Configuration requests
            // fmt for memory read completions is 010
            fmtCompl = 0;
            fmtCompl_binary = decToBinary(fmtCompl, 3);
            // Byte count/ BCM should be 13'b000000000011
            byteCountBCM = 3;
            byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            // Lower address should be 7'b0
            lowAddress2 = 0;
            lowAddress5 = 0;
            lowAddress2_binary = decToBinary(lowAddress2, 2);
            lowAddress5_binary = decToBinary(lowAddress5, 5);
            header_vector->insert(header_vector->begin(), busNum_binary->begin(), busNum_binary->end());
            header_vector->insert(header_vector->begin(), deviceNum_binary->begin(), deviceNum_binary->end());
            header_vector->insert(header_vector->begin(), functionNum_binary->begin(), functionNum_binary->end());
            header_vector->insert(header_vector->begin(), reserved_binary->begin(), reserved_binary->end());
            header_vector->insert(header_vector->begin(), extRegNum_binary->begin(), extRegNum_binary->end());
            header_vector->insert(header_vector->begin(), regNum_binary->begin(), regNum_binary->end());
            header_vector->insert(header_vector->begin(), R2Bit_binary->begin(), R2Bit_binary->end());
            myfile << "Configuration request: " << "\n";
        }
        
        // Set values for completion headers
        // Set AT field to 00
        ATCompl = 0;
        ATCompl_binary = decToBinary(ATCompl, 2);
        // Set completion status to all 000
        complStatus = 0;
        complStatus_binary = decToBinary(complStatus, 3);
        // Set completer ID to 16'b1
        completerID = 65535;
        completerID_binary = decToBinary(completerID, 16);
        // Memory read requests
        if ((type == 0) && ((fmt == 0)||(fmt == 1))){
            // fmt for memory read completions is 010
            fmtCompl = 2;
            fmtCompl_binary = decToBinary(fmtCompl, 3);
            // Byte count/ BCM cases:
            // Lower address cases: Lower 2 bits and upper 5 bits
            if (firstDWBE == 0){
                lowAddress2_binary = decToBinary(0, 2);
            }
            else if (firstDWBE_binary->at(3) == 1){
                lowAddress2_binary = decToBinary(0, 2);
            }
            else if ((firstDWBE_binary->at(3) == 0) && (firstDWBE_binary->at(2) == 1)){
                lowAddress2 = 1;
                lowAddress2_binary = decToBinary(lowAddress2, 2);
            }
            else if ((firstDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 0)&&(firstDWBE_binary->at(3) == 0)){
                lowAddress2 = 2;
                lowAddress2_binary = decToBinary(lowAddress2, 2);
            }
            else if (firstDWBE == 8){
                lowAddress2 = 3;
                lowAddress2_binary = decToBinary(lowAddress2, 2);
            }
            // Setting the upper 5 bits of the lower address equal to the last 5 bits of Address[31:2]
            lowAddress5_binary = decToBinary(0, 5);
            int a = 0;
            for (int i = 25; i < 30; i++){
                lowAddress5_binary->at(a) = address31_binary->at(i);
                a++;
            }
            // Set the byte count and BCM fields
            // Case 1: 8'b00001xx1
            if ((lastDWBE == 0)&&(firstDWBE_binary->at(0) == 1)&&(firstDWBE_binary->at(3) == 1)){
                byteCountBCM = 4;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 2: 8'b000001x1
            if ((lastDWBE == 0)&&(firstDWBE_binary->at(0) == 0)&&(firstDWBE_binary->at(1) == 1)&&(firstDWBE_binary->at(3) == 1)){
                byteCountBCM = 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 3: 8'b00001x10
            if ((lastDWBE == 0)&&(firstDWBE_binary->at(0) == 1)&&(firstDWBE_binary->at(2) == 1)&&(firstDWBE_binary->at(3) == 0)){
                byteCountBCM = 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 4: 8'b00000011
            if ((lastDWBE == 0) && (firstDWBE == 3)){
                byteCountBCM = 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 5: 8'b00000110
            if ((lastDWBE == 0) && (firstDWBE == 6)){
                byteCountBCM = 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 6: 8'b00001100
            if ((lastDWBE == 0) && (firstDWBE == 12)){
                byteCountBCM = 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 7: 8'b00000001
            if ((lastDWBE == 0) && (firstDWBE == 1)){
                byteCountBCM = 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 8: 8'b00000010
            if ((lastDWBE == 0) && (firstDWBE == 2)){
                byteCountBCM = 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 9: 8'b00000100
            if ((lastDWBE == 0) && (firstDWBE == 4)){
                byteCountBCM = 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 10: 8'b00001000
            if ((lastDWBE == 0) && (firstDWBE == 8)){
                byteCountBCM = 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 11: 8'b00000000
            if ((lastDWBE == 0) && (firstDWBE == 0)){
                byteCountBCM = 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 12: 8'b1xxxxxx1 and (header_holder [9:0] * 4)
            if ((lastDWBE_binary->at(0) == 1) && (firstDWBE_binary->at(3) == 1)){
                byteCountBCM = length * 4;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 13: 8'b01xxxxx1 and (header_holder [9:0] * 4) - 1
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(3) == 1)){
                byteCountBCM = (length * 4) - 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 14: 8'b001xxxx1 and (header_holder [9:0] * 4) - 2
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 0) && (lastDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(3) == 1)){
                byteCountBCM = (length * 4) - 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 15: 8'b0001xxx1 and (header_holder [9:0] * 4) - 3
            if ((lastDWBE == 1) && (firstDWBE_binary->at(3) == 1)){
                byteCountBCM = (length * 4) - 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 16: 8'b1xxxxx10 and (header_holder [9:0] * 4) - 1
            if ((lastDWBE_binary->at(0) == 1) && (firstDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 1;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 17: 8'b01xxxx10 and (header_holder [9:0] * 4) - 2
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 18: 8'b001xxx10 and (header_holder [9:0] * 4) - 3
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 0) && (lastDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 19: 8'b0001xx10 and (header_holder [9:0] * 4) - 4
            if ((lastDWBE == 1) && (firstDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 4;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 20: 8'b1xxxx100 and (header_holder [9:0] * 4) - 2
            if ((lastDWBE_binary->at(0) == 1) && (firstDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 0) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 2;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 21: 8'b01xxx100 and (header_holder [9:0] * 4) - 3
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 0) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 22: 8'b001xx100 and (header_holder [9:0] * 4) - 4
            if ((lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 0) && (lastDWBE_binary->at(2) == 1) && (firstDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 0) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 4;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 23: 8'b0001x100 and (header_holder [9:0] * 4) - 5
            if ((lastDWBE == 1) && (firstDWBE_binary->at(1) == 1) && (firstDWBE_binary->at(2) == 0) && (firstDWBE_binary->at(3) == 0)){
                byteCountBCM = (length * 4) - 5;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 24: 8'b1xxx1000 and (header_holder [9:0] * 4) - 3
            if ((firstDWBE == 8) && (lastDWBE_binary->at(0) == 1)){
                byteCountBCM = (length * 4) - 3;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 25: 8'b01xx1000 and (header_holder [9:0] * 4) - 4
            if ((firstDWBE == 8) && (lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 1)){
                byteCountBCM = (length * 4) - 4;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 26: 8'b001x1000 and (header_holder [9:0] * 4) - 5
            if ((firstDWBE == 8) && (lastDWBE_binary->at(0) == 0) && (lastDWBE_binary->at(1) == 0) && (lastDWBE_binary->at(2) == 1)){
                byteCountBCM = (length * 4) - 5;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            // Case 27: 8'b00011000 and (header_holder [9:0] * 4) - 6
            if ((firstDWBE == 8) && (lastDWBE == 1)){
                byteCountBCM = (length * 4) - 6;
                byteCountBCM_binary = decToBinary(byteCountBCM, 13);
            }
            myfile << "Memory read request: " << "\n";
        }
        // Memory write requests
        if ((type == 0) && ((fmt == 2)||(fmt == 3))){
            // fmt for memory write completions is 000
            fmtCompl = 0;
            fmtCompl_binary = decToBinary(fmtCompl, 3);
            // Byte count/ BCM should be 13'b000000000011
            byteCountBCM = 3;
            byteCountBCM_binary = decToBinary(3, 13);
            // Lower address should be 7'b0
            lowAddress2 = 0;
            lowAddress5 = 0;
            lowAddress2_binary = decToBinary(lowAddress2, 2);
            lowAddress5_binary = decToBinary(lowAddress5, 5);
            myfile << "Memory write request: " << "\n";
        }
        
        // Store the binary values in completion_vector
        completion_vector->insert(completion_vector->begin(), length_binary->begin(), length_binary->end());
        completion_vector->insert(completion_vector->begin(), ATCompl_binary->begin(), ATCompl_binary->end());
        completion_vector->insert(completion_vector->begin(), Attr_binary->begin(), Attr_binary->end());
        // completion_vector->insert(completion_vector->begin(), bits14To18_binary->begin(), bits14To18_binary->end());
        completion_vector->insert(completion_vector->begin(), bit14_binary->begin(), bit14_binary->end());
        completion_vector->insert(completion_vector->begin(), bit15_binary->begin(), bit15_binary->end());
        completion_vector->insert(completion_vector->begin(), bits16To18_binary->begin(), bits16To18_binary->end());
        completion_vector->insert(completion_vector->begin(), R_binary->begin(), R_binary->end());
        completion_vector->insert(completion_vector->begin(), TC_binary->begin(), TC_binary->end());
        completion_vector->insert(completion_vector->begin(), R_binary->begin(), R_binary->end());
        completion_vector->insert(completion_vector->begin(), type_binary->begin(), type_binary->end());
        completion_vector->insert(completion_vector->begin(), fmtCompl_binary->begin(), fmtCompl_binary->end());
        completion_vector->insert(completion_vector->begin(), byteCountBCM_binary->begin(), byteCountBCM_binary->end());
        completion_vector->insert(completion_vector->begin(), complStatus_binary->begin(), complStatus_binary->end());
        completion_vector->insert(completion_vector->begin(), completerID_binary->begin(), completerID_binary->end());
        completion_vector->insert(completion_vector->begin(), lowAddress2_binary->begin(), lowAddress2_binary->end());
        completion_vector->insert(completion_vector->begin(), lowAddress5_binary->begin(), lowAddress5_binary->end());
        completion_vector->insert(completion_vector->begin(), R_binary->begin(), R_binary->end());
        completion_vector->insert(completion_vector->begin(), tag_binary->begin(), tag_binary->end());
        completion_vector->insert(completion_vector->begin(), reqID_binary->begin(), reqID_binary->end());
        
        // PRINT STATEMENTS FOR DEBUGGING:
        // tring typeStringCheck = (* printPointerVect(type_binary));
        // myfile << "Type (decimal): " << type << " Type (binary): " << typeStringCheck << "\n";
        // myfile << "Length: " << length << "\n";
        if((fmt == 0)||(fmt == 1)){
        myfile << "Format (fmt) should be 0 or 1: " << fmt << "\n";
        }
        if((fmt == 2)||(fmt == 3)){
            myfile << "Format (fmt) should be 2 or 3: " << fmt << "\n";
        }
        myfile << "Type should be 0: " << type << "\n";
        myfile << "Length: " << length << "\n";
        
        // Print out the TLP, payload (if needed), completion header, and payload again (if needed) in 32-bit chunks
        string headerString = (* printPointerVect(header_vector));
        string completionString = (* printPointerVect(completion_vector));
        
        if (headerString.size() == 96) {
            // Print out 3 32-bit sub strings with 32 leadings zeros
            string headerString1 = headerString.substr(0,32);
            string headerString2 = headerString.substr(32,32);
            string headerString3 = headerString.substr(64);
            string zeroString = string(32, '0');
            myfile << "TLP in 32-bit sections: " << "\n" << zeroString << "\n" << headerString3 << "\n" << headerString2 << "\n"<< headerString1 << "\n";
            myfile_in << zeroString << "\n" << headerString3 << "\n" << headerString2 << "\n"<< headerString1 << "\n";
        }
        if (headerString.size() == 128) {
            // Print out 4 32-bit sub strings
            string headerString1 = headerString.substr(0,32);
            string headerString2 = headerString.substr(32,32);
            string headerString3 = headerString.substr(64,32);
            string headerString4 = headerString.substr(96);
            myfile << "TLP in 32-bit sections: "<< "\n" << headerString4 << "\n" << headerString3 << "\n"<< headerString2 << "\n" << headerString1 << "\n";
            myfile_in << headerString4 << "\n" << headerString3 << "\n"<< headerString2 << "\n" << headerString1 << "\n";
        }
        // Print out payload of memory writes (32-bit and 64-bit addressing)
        if ( (type == 0) && ((fmt == 2) || (fmt == 3))){
            myfile << "Payload: There should be " << length << " chunks of payload " << "\n";
            for(int i = 0; i < length; i++) {
                myfile << payloadString << "\n";
                myfile_in << payloadString << "\n";
            }
        }
        // myfile << "Completion: " << completionString << "\n";
        // Print out 3 32-bit sub strings
        string completionString1 = completionString.substr(0,32);
        string completionString2 = completionString.substr(32,32);
        string completionString3 = completionString.substr(64);
        myfile << "Completion Header in 32-bit sections: " << "\n" << completionString3 << "\n" << completionString2 << "\n"<< completionString1 << "\n";
        myfile_out << completionString3 << "\n" << completionString2 << "\n"<< completionString1 << "\n";
        myfile_out2 << completionString3 << "\n" << completionString2 << "\n"<< completionString1 << "\n";
        // Print out the payload for memory reads
        if(type == 0 && length != 0 && (fmt == 0 || fmt == 1)){
            myfile << "Payload: There should be " << length << " chunks of payload " << "\n";
            for(int i = 0; i < length; i++) {
                myfile << payloadString << "\n";
                myfile_out << payloadString << "\n";
                myfile_out2 << payloadString << "\n";
            }
        }
    }
    myfile.close();
    myfile_in.close();
    myfile_out.close();
    myfile_out2.close();
    return 0;
}

/* ---------- Function Definitions: ---------- */

// Name: decToBinary
// Use: Take in an integer value and return a vector of its binary equivalent
vector<bool>* decToBinary (int n, int length) {
    vector<bool>* binaryVec = new vector<bool>;    // Vector of the binary number
    if (n == 0) {
        binaryVec->push_back(0);
    }
    while (n>0){
        binaryVec->push_back(n % 2);
        n /= 2;
    }
    reverse(binaryVec->begin(),binaryVec->end()); // Reverse vector
    while (length - binaryVec->size() > 0) {
        binaryVec->insert(binaryVec->begin(), 0);
    }
    return binaryVec;
}

// Name: printPointerVect
// Use: Take in a vector of booleans and return a string of its contents
string* printPointerVect(vector<bool>* vect) {
    string* output = new string;
    for (int i = 0; i < vect->size(); i++) {
        if (vect->at(i))
            output->push_back('1');
        else
            output->push_back('0');
    }
    return output;
}

// Name: negateVector
// Use: Take in a vector of booleans and return the negated vector
string* negateVector (vector<bool>* vec) {
    string* negatedVec = new string;
    string inputString = (* printPointerVect(vec));
    for (int i = 0; i < inputString.size(); i++) {
        if (inputString.at(i) == '1') {
            negatedVec->push_back('0');
        }
        else {
            negatedVec->push_back('1');
        }
    }
    return negatedVec;
}


