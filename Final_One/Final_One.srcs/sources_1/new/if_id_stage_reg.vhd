library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity if_id_stage_reg is 
    port(             
        clk: in std_logic; 
        instr: in std_logic_vector(24 downto 0);  
        
        opcode: out std_logic_vector(24 downto 0)
    ); 
end entity;  

architecture behavioral of if_id_stage_reg is     
begin     
    if_id: process(clk)
    begin 
        if rising_edge(clk) then 
            opcode <= instr; 
        end if ; 
    end process; 
end behavioral;