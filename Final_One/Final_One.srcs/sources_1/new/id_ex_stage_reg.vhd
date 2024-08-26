library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity id_ex_stage_reg is 
    port(             
    clk: in std_logic; 
    opcode: in std_logic_vector(24 downto 0);
    d1in, d2in, d3in: in std_logic_vector(127 downto 0); 
    
    func: out std_logic_vector(24 downto 0); 
    d1out, d2out, d3out: out std_logic_vector(127 downto 0)
    ); 
end entity;  

architecture behavioral of id_ex_stage_reg is     
begin     
    id_ex: process(clk)
    begin 
        if rising_edge(clk) then 
            func <= opcode; 
            d1out <= d1in; 
            d2out <= d2in; 
            d3out <= d3in; 
        end if ; 
    end process; 
end behavioral; 