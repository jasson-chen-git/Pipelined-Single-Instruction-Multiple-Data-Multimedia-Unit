This project is the combination of 2 smaller tasks for a Computer Architecture Course.

The goal is to create a CPU core that will perform arithmetic based on a given opcode and write the data back to a register file.
The components that make up this project are an ALU, a register file, an instruction buffer, several stage registers (each labeled by their position in the stage), forwarding unit to detect data hazards, and a multiplexer.
There are several other files that will serve as the read/write file in which the program will read instructions/opcodes from/to. 
A python script is also provided to translate the instructions to opcodes onto a separate text file.
The output textfile is word-formatted to display the different stages and cycles in an organized fashion and the final state of the register file once the simulation is completed.
