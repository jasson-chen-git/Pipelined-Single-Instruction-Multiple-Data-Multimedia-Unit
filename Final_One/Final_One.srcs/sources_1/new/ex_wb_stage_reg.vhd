library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity ex_wb_stage_reg is 
    port(             
    clk: in std_logic; 
    func: in std_logic_vector(24 downto 0);
    dataEX: in std_logic_vector(127 downto 0);
    
    field: out std_logic_vector(24 downto 0); 
    dataWB: out std_logic_vector(127 downto 0); 
    WE: out std_logic; 
    rd: out std_logic_vector(4 downto 0)
    ); 
end entity;  

architecture behavioral of ex_wb_stage_reg is     
begin     
    ex_wb: process(clk)
    begin 
        if rising_edge(clk) then 
            field <= func;
            rd <= func(4 downto 0); 
            dataWB <= dataEX;
            WE <= '0'; 
            
            if (func(24 downto 24) = "0" or func(24 downto 23) = "10" or func(24 downto 23) = "11") then 
                WE <= '1';
            end if;
            
            if func(24 downto 15) = "1100000000" then 
                WE <= '0';
            end if;
        end if ; 
    end process; 
end behavioral; 