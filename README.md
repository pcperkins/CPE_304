# CPE_304
Microcontroller for Final Design Project

The requirements for the microcontroller are listed below. <br /><br />
<i>Memory</i><br />
	The microcontroller shall be Von Neumann architecture.<br />
	The microcontroller shall have 255 4-bit memory locations.<br />
	The program will be input by initializing memory locations (i.e., program shall be uploaded in software, not in hardware).<br /><br />
	<i>Operation</i><br />
	The microcontroller shall utilize the on-board clock.<br />
	The microcontroller shall have an option to execute the program one clock tick at a time.<br />
	The microcontroller shall use an 8-bit program counter and a 4-bit bus.<br />
	There shall be a reset switch that will return the program counter to 0.<br /><br />
	<i>Registers and I/O</i><br />
The microcontroller shall have a 4-bit working register, instruction register, status register.<br />
The status register shall contain a zero flag at bit 0 (LSB), and a carry flag at bit 1, both of which must be output on LEDs. <br />
There shall be 8 LEDs to display the program counter. <br />
    -<i>note</i>: I don't think we have enough I/O for this, so I'm having the 7 segment LEDs display the PC.<br />
There shall be 4 LEDs to display the current accumulator (working register).<br />
There shall be 4 data in switches for data input (use toggle switches).<br />
There shall be 4 data out LEDs.
