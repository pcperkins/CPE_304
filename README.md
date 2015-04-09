# CPE_304
Microcontroller for Final Design Project

The requirements for the microcontroller are listed below.
Memory
	The microcontroller shall be Von Neumann architecture.
	The microcontroller shall have 255 4-bit memory locations.
	The program will be input by initializing memory locations (i.e., program shall be uploaded in software, not in hardware).
	Operation
	The microcontroller shall utilize the on-board clock.
	The microcontroller shall have an option to execute the program one clock tick at a time.
	The microcontroller shall use an 8-bit program counter and a 4-bit bus.
	There shall be a reset switch that will return the program counter to 0.
	Registers and I/O
The microcontroller shall have a 4-bit working register, instruction register, status register.
The status register shall contain a zero flag at bit 0 (LSB), and a carry flag at bit 1, both of which must be output on LEDs. 
There shall be 8 LEDs to display the program counter. 
    -note: I don't think we have enough I/O for this, so I'm having the 7 segment LEDs display the PC.
There shall be 4 LEDs to display the current accumulator (working register).
There shall be 4 data in switches for data input (use toggle switches).
There shall be 4 data out LEDs.

Code  	Mnemonic  Flags	Description	                        PC Change
0000	  NOP         - 	No operation  	                      +1
0001  	MOVMEM	    Z	  Move memory to acc.	                  +3
0010  	MOVACC	    -	  Move accumulator to memory	          +3
0011  	MOVIMM	    Z 	Move immediate to acc.	              +2
0100  	ADDMEM	   Z,C	Add memory to acc.      	            +3
0101  	SUBMEM	   Z,C	Subtract memory from acc.	            +3
0110  	CLEARREG	  Z 	Clear selected register	              +2
0111  	RARTC	      C 	Rotate acc. right through carry       +1
1000  	RALTC	      C 	Rotate acc. left through carry	      +1
1001  	JMPCS	      - 	Jump if carry set	                    +3
1010  	JMPCC	      - 	Jump if carry clear	                  +3
1011  	JMPZS	      - 	Jump if zero set	                    +3
1100	  JMPZC	      - 	Jump if zero clear	                  +3
1101  	COMPACC	    Z 	Complement acc.	                      +1
1110	  DIN	        Z 	Input Data to acc.         	          +1
1111	  DOUT	      - 	Output data from acc.       	        +1
