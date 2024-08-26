library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;  

entity reg_file is 
	port(
	   opcode: in std_logic_vector(24 downto 0);
	   WE: in std_logic;
	   rd: in std_logic_vector(4 downto 0);
	   data: in std_logic_vector(127 downto 0);
	   
	   data1, data2, data3 : out std_logic_vector(127 downto 0);
	   
	   sel: in integer;
	   o: out std_logic_vector(127 downto 0);
	   last : out std_logic_vector(127 downto 0)
	); 
end reg_file; 

architecture Behavioral of reg_file is
    type registers is array (0 to 31) of std_logic_vector(127 downto 0);
    signal registerfile: registers := (others => (others => '0'));    
begin
    write: process (WE, rd, data)
    begin
        if WE = '1' then
            registerfile(to_integer(unsigned(rd))) <= data;
        end if;
    end process;
    
    read: process(all)
    begin
        data1 <= registerfile(to_integer(unsigned(opcode(9 downto 5))));
        data2 <= registerfile(to_integer(unsigned(opcode(14 downto 10))));
        data3 <= registerfile(to_integer(unsigned(opcode(19 downto 15))));
        
        --  if load instruction then read address is different
        if opcode(24) = '0' then
            data1 <= registerfile(to_integer(unsigned(opcode(4 downto 0))));
        end if;
    end process;
    
    o <= registerfile(sel);
    last <= registerfile(31); 
end Behavioral;
