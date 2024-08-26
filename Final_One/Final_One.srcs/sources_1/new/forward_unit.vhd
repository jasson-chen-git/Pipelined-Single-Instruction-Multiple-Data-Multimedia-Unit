library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity forward_unit is
    port(
        instr, opcode: in std_logic_vector(24 downto 0);
        
        s1, s2, s3: out std_logic
    );
end forward_unit;

architecture Behavioral of forward_unit is
begin
    forward: process(all)
    begin
        (s1, s2, s3) <= std_logic_vector'("000");
        
        if opcode(24 downto 15) = "1100000000" then
            -- do nothing
        elsif (opcode(24) = '0' or opcode(24) = '1') then
            -- for going into load
            if instr(24) = '0' then
                if opcode(4 downto 0) = instr(4 downto 0) then 
                    s1 <= '1';
                end if;
            -- for going into r3/r4 instructions
            else
                if opcode(4 downto 0) = instr(9 downto 5) then      -- for rd = rs1
                    s1 <= '1';
                end if;
                if opcode(4 downto 0) = instr(14 downto 10) then    -- for rd = rs2
                    s2 <= '1';
                end if;
                if opcode(4 downto 0) = instr(19 downto 15) then    -- for rd = rs3 (only in r4 instructions, r3 instructions ignores rs3 values)
                    s3 <= '1';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
