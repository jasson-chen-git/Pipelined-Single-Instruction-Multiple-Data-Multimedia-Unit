library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux is
    port(
        s1, s2, s3: in std_logic;
        d1m, d2m, d3m: in std_logic_vector(127 downto 0);
        data: in std_logic_vector(127 downto 0);
        
        rs1, rs2, rs3: out std_logic_vector(127 downto 0)
    );
end mux;

architecture Behavioral of mux is
begin
    data_selection: process(all)
    begin
        rs1 <= d1m;
        rs2 <= d2m;
        rs3 <= d3m;
        if s1 = '1' then rs1 <= data; end if;
        if s2 = '1' then rs2 <= data; end if;
        if s3 = '1' then rs3 <= data; end if;
    end process;
end Behavioral;
