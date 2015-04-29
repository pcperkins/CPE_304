library ieee;
use ieee.std_logic_1164.all;

entity Microcontroller is
	port (reset: in std_logic;
			debug_clock, debug_enable, onboard_clock : in std_logic; --on-board clock is pin 24	
			data_in : in std_logic_vector(3 downto 0); --Switches for DIN command
			data_out : out std_logic_vector(3 downto 0); -- Indicator for DOUT command
			Zero, Carry : out std_logic;	--Indicators for STATUS register 
			Accumulator : buffer std_logic_vector (3 downto 0); --Shows contents of current accumulator
			PCL : out std_logic_vector (6 downto 0); --lower nibble of the program counter
			PCH : out std_logic_vector(6 downto 0)); -- upper nibble of the program counter 
			
end Microcontroller;

architecture Microcontroller_arch of Microcontroller is

	signal instruction_register : std_logic_vector(3 downto 0);
	signal clock : std_logic; --clock signal (either debug_clock or ext_clock)
	signal Program_counter : integer := 0; --Program counter
	type storage is array(255 downto 0) of std_logic_vector(3 downto 0); --declaration of memory bank (not instantiated)
	signal mem : storage; --Actual memory bank; use this when working with memory
	signal address_sel : std_logic_vector(7 downto 0); --used to select memory address
	signal Carry_bit : bit := '0'; 
	signal Zero_bit : bit := '0'; 
	
	constant status: integer := 255; -- status register. THIS IS AN INTEGER. If you want to access
					 -- the status register, write mem(status).
	
	-- A-G values of 7-segment LEDs
	constant LED_0 : std_logic_vector(6 downto 0) := "1111110";
	constant LED_1 : std_logic_vector(6 downto 0) := "0110000";
	constant LED_2 : std_logic_vector(6 downto 0) := "1101101";
	constant LED_3 : std_logic_vector(6 downto 0) := "1111001";
	constant LED_4 : std_logic_vector(6 downto 0) := "0110011";
	constant LED_5 : std_logic_vector(6 downto 0) := "1011011";
	constant LED_6 : std_logic_vector(6 downto 0) := "1011111";
	constant LED_7 : std_logic_vector(6 downto 0) := "1110000";
	constant LED_8 : std_logic_vector(6 downto 0) := "1111111";
	constant LED_9 : std_logic_vector(6 downto 0) := "1111011";
	constant LED_A : std_logic_vector(6 downto 0) := "1110111";
	constant LED_B : std_logic_vector(6 downto 0) := "0011111";
	constant LED_C : std_logic_vector(6 downto 0) := "1001110";
	constant LED_D : std_logic_vector(6 downto 0) := "0111101";
	constant LED_E : std_logic_vector(6 downto 0) := "1001111";
	constant LED_F : std_logic_vector(6 downto 0) := "1000111";
	
	--Converts integer data type to std_logic_vector (from page 254)
		function Conv_To_Std (arg : integer; size : integer)
		 return std_logic_vector is
		 variable result: std_logic_vector(size - 1 downto 0);
		 variable temp : integer;
		 begin
			temp := arg; 
			for i in 0 to size-1 loop
				if (temp mod 2) = 1 then result(i) := '1';
				else result(i) := '0';
				end if;
				temp := temp /2;
			end loop;
		 return result;
		 end Conv_To_Std;
		 
	--converts std_logic_vector to int	 
	function Conv_to_Int (vec : std_logic_vector; size : integer)
		return integer is
		variable temp : integer := 1;
		variable result : integer := 0;
		
		begin
			for i in 0 to size - 1 loop
				if vec(i) = '1' then
					result := result + temp;
				else
					result := result;
				end if;
				temp := temp * 2;
				end loop;
			return result;
		end Conv_to_Int;
		
	function JMPCS (C : bit; prgm_count: integer; HI, LO : std_logic_vector(3 downto 0)) 
		return integer is
		variable PC : integer := prgm_count;
		variable Address : std_logic_vector(7 downto 0) := Hi & LO;
		begin
		
			case C is
				when '0' => PC := PC + 3;
				when '1' => PC := Conv_to_Int(Address, 8);
			end case;
			return PC;
	end JMPCS;
	
	function JMPCC (C : bit; prgm_count: integer; HI, LO : std_logic_vector(3 downto 0)) 
		return integer is
		variable PC : integer := prgm_count;
		variable Address : std_logic_vector(7 downto 0) := Hi & LO;
		begin
		
			case C is
				when '1' => PC := PC + 3;
				when '0' => PC := Conv_to_Int(Address, 8);
			end case;
			return PC;
	end JMPCC;
	
	function JMPZS (C : bit; prgm_count: integer; HI, LO : std_logic_vector(3 downto 0)) 
		return integer is
		variable PC : integer := prgm_count;
		variable Address : std_logic_vector(7 downto 0) := Hi & LO;
		begin
		
			case C is
				when '0' => PC := PC + 3;
				when '1' => PC := Conv_to_Int(Address, 8);
			end case;
			return PC;
	end JMPZS;
	
	function JMPZC (C : bit; prgm_count: integer; HI, LO : std_logic_vector(3 downto 0)) 
		return integer is
		variable PC : integer := prgm_count;
		variable Address : std_logic_vector(7 downto 0) := Hi & LO;
		begin
		
			case C is
				when '1' => PC := PC + 3;
				when '0' => PC := Conv_to_Int(Address, 8);
			end case;
			return PC;
	end JMPZC;
	
	begin
	--Selects whether device is in debug mode or normal and sets internal clock signal
	clock <= (debug_clock AND debug_enable) or (not debug_enable and onboard_clock);
	
	
		process (clock, reset)
	begin
		--resets microcontroller
		if(reset = '1') then
			accumulator <= "0000";
			Program_counter <= 0;
			instruction_register <= "0000";
			data_out <= "0000";
			mem(Status) <= "0000";
			
		elsif(rising_edge(clock)) then
		
			instruction_register <= mem(Program_counter); --Moves the current PC to the instruction register

			case instruction_register is --selects which opcode to run
			
			when "1001"
			=> Program_counter 
			<= JMPCS(Carry_bit, Program_Counter, mem(Program_Counter + 1), mem(Program_Counter + 2));
			when "1010"
			=> Program_counter 
			<= JMPCC(Carry_bit, Program_Counter, mem(Program_Counter + 1), mem(Program_Counter + 2));
			when "1011"
			=> Program_counter 
			<= JMPZS(Carry_bit, Program_Counter, mem(Program_Counter + 1), mem(Program_Counter + 2));
			when "1100"
			=> Program_counter 
			<= JMPZC(Carry_bit, Program_Counter, mem(Program_Counter + 1), mem(Program_Counter + 2));
			
			--Here's where you guys come in. replace [opcode] with the value of your opcode, e.g. "0000" if writing NOP

			--when [opcode]
			--[call relevant function]
			--[end function]
			--Update program counter (NOTE: update program counter OUTSIDE of function only)
			
			--when [opcode]
			--[call relevant function]
			--[end function]
			--Update Program Counter
			
			--...
			
			--when others --(use for final opcode)
			--[call relevant function]
			--[end function]
			--Update Program Counter
			when others => null; 
			
			
			
			end case;
		end if;
	end process;
	
	
	--Updates Status Register
	process(mem(status))
	begin
	Zero <= mem(Status)(0);
	Carry <= mem(Status)(1);
	end process;
	
	--updates PC indicator on 7-seg LEDs
	process(Instruction_register)
	begin
	--sets upper nibble
	case Conv_to_Std(Program_Counter, 8)(7 downto 4) is
		when "0000" =>
		PCH <= LED_0;
		when "0001" => 
		PCH <= LED_1;
		when "0010" =>
		PCH <= LED_2;
		when "0011" =>
		PCH <= LED_3;
		when "0100" =>
		PCH <= LED_4;
		when "0101" =>
		PCH <= LED_5;
		when "0110" =>
		PCH <= LED_6;
		when "0111" =>
		PCH <= LED_7;
		when "1000" =>
		PCH <= LED_8;
		when "1001" =>
		PCH <= LED_9;
		when "1010" =>
		PCH <= LED_A;
		when "1011" =>
		PCH <= LED_B;
		when "1100" =>
		PCH <= LED_C;
		when "1101" =>
		PCH <= LED_D;
		when "1110" =>
		PCH <= LED_E;
		when others =>
		PCH <= LED_F;
	end case;
	
	--sets lower nibble
	case  Conv_to_Std(Program_Counter, 8)(3 downto 0) is
		when "0000" => 
		PCL <= LED_0;
		when "0001" =>
		PCL <= LED_1;
		when "0010" =>
		PCL <= LED_2;
		when "0011" =>
		PCL <= LED_3;
		when "0100" =>
		PCL <= LED_4;
		when "0101" =>
		PCL <= LED_5;
		when "0110" =>
		PCL <= LED_6;
		when "0111" =>
		PCL <= LED_7;
		when "1000" =>
		PCL <= LED_8;
		when "1001" =>
		PCL <= LED_9;
		when "1010" =>
		PCL <= LED_A;
		when "1011" =>
		PCL <= LED_B;
		when "1100" =>
		PCL <= LED_C;
		when "1101" =>
		PCL <= LED_D;
		when "1110" =>
		PCL <= LED_E;
		when others =>
		PCL <= LED_F;
	end case;
	
	end process;
end Microcontroller_arch;
