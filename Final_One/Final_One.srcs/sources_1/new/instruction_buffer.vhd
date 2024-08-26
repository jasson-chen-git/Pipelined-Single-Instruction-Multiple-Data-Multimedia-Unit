library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;
library std; 
use std.textio.all;

entity instruction_buffer is
    port(
        clk: in std_logic;
        asmfile: in string;
        instruction: out std_logic_vector(24 downto 0)
    );
end instruction_buffer;

architecture Behavioral of instruction_buffer is
    signal read_finish: integer := 0; 
    signal PC: integer := 0;     
begin 																	  
    inst_buff: process(clk)
        type bin_file is array (0 to 63) of std_logic_vector(24 downto 0);	
        variable instruction_field : bin_file; 
        file read_file: text;
        variable instruction_text : line;	
        variable tempInst: std_logic_vector(24 downto 0);
        variable i: integer := 0;
	begin 
		if(read_finish = 0) then 
			file_open(read_file, asmfile, READ_MODE);
			
			while not endfile(read_file) loop
                readline(read_file, instruction_text);  -- Reads text line in file, stores line into line_contents
                read(instruction_text, tempInst);       -- Reads line_contents and stores it into a temporary variable
                instruction_field(i) := tempInst;       -- Takes the information from the temp variable and inserts it into the instBuffer(i), which is an entry in the 64 25-bit instruction set
                i := i + 1; 
            end loop; 
			
		read_finish <= 1; 
		file_close(read_file); 
		end if ; 
		
		if (rising_edge(clk) and read_finish =1) then
			if(PC < 64) then
				instruction <= instruction_field(PC); 
				PC<= PC+1; 
			end if;
		 end if;	  
	end process;
end Behavioral;
