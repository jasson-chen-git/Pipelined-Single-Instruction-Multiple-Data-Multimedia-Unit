library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library std;
use std.textio.all; 
use work.all; 

entity test is
end entity test;

architecture sim of test is
	-- Signals for the Instruction Buffer
	constant period : time := 100ns;
	signal clk : std_logic := '0';
	signal count: integer := 0;	
	 
--	signal instruction : std_logic_vector(24 downto 0) := (others => '0');
	constant filename: string := "C:\Users\Jason\Documents\345\asmcode.txt"; -- FILE NAME
    constant BL_STR: string :="                                              "&LF;
    constant outputfile: string := "C:\Users\Jason\Documents\345\resultfile.txt";
    constant expectedfile: string := "C:\Users\Jason\Documents\345\expected_results.txt";
    
    signal instr, opcode, func, field:  std_logic_vector(24 downto 0);
    signal rs1_data, rs2_data, rs3_data, 
    mux_data1, mux_data2, mux_data3, mux_data,
    alu_in1, alu_in2, alu_in3, alu_out,
    wb_data: std_logic_vector(127 downto 0);
    signal WE, select1, select2, select3:  std_logic;
    signal rd: std_logic_vector(4 downto 0);
    
    signal sel: integer := 0;
    signal o: std_logic_vector(127 downto 0);
    signal last: std_logic_vector(127 downto 0);
    
    type filltype is (NOFILL, ZEROFILL);
    function to_dstring (
        value:      in integer;
        field:      in width := 0;
        just:       in side := RIGHT;
        fill:       in filltype := NOFILL
    ) return string is
        variable retstr: string (1 to field);
    begin
        if field = 0 then
            return integer'image(value);
        elsif field < integer'image(value)'length then 
            retstr := (others => '#');
        elsif fill = NOFILL  or just = LEFT then
            retstr := justify (integer'image(value), just, field);
        else  -- fill = ZEROFILL and just = RIGHT, field >= image length
            retstr  := justify (integer'image(abs value), just, field);
            for i in retstr'range loop
                if retstr(i) = ' ' then
                    retstr(i) := '0';
                end if;
            end loop;
            if value < 0 then
                retstr(1) := '-';
            end if;
        end if;
        return retstr;
    end function to_dstring;
    
begin
	UUT1: entity the_cpu_reborn port map (clk => clk, filename => filename, 
	       instr => instr, opcode => opcode, func => func, field => field,
	       rs1_data => rs1_data, rs2_data => rs2_data, rs3_data => rs3_data,
	       mux_data1 => mux_data1, mux_data2 => mux_data2, mux_data3 => mux_data3, mux_data => mux_data,
	       alu_in1 => alu_in1, alu_in2 => alu_in2, alu_in3 => alu_in3, alu_out => alu_out,
	       wb_data => wb_data,
	       WE => WE, select1 => select1, select2 => select2, select3 => select3, rd => rd,
	       sel => sel, o => o, last => last);
	
	InstructionBufferTest : process
		variable i : integer := 0;
	begin	 
		for i in 0 to 67 * 2 - 1 loop
			clk <= not clk;
			if(i mod 2 = 0) then
			     count <= count + 1;
			end if;
			report "INSTRUCTION " & (to_string(count)) severity note; 
			-- NOTE: to_string FUNCTION REQUIRES VHDL-2008. GO TO DESIGN TAB >> SETTINGS >> COMPILATION >> VHDL >> CHANGE STANDARD VERSION TO VHDL-2008
			wait for period/2;
		end loop;
		wait;
	end process; 
	
	resultheader: process
	   file result_file: text;
	   variable line_contents: line;
	   variable open_status: file_open_status;
	   
	begin
	   file_open(open_status, result_file, outputfile, WRITE_MODE);
	   if open_status = open_ok then
	       write(line_contents, string'("                                                                                       **********************************"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *                                *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *           RESULT FILE          *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *                                *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       **********************************"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'(""));
	       writeline(result_file, line_contents);
	       write(line_contents, string'(""));
	       writeline(result_file, line_contents);
	   end if;
	   file_close(result_file);
	   wait;    
	end process;
	
	resultfile: process(clk)
	   file result_file: text;
	   variable line_contents: line;
	   variable open_status: file_open_status;
	   variable r1, r2, r3, ro: integer;
	begin
	   r1 := to_integer(unsigned(opcode(9 downto 5)));
	   r2 := to_integer(unsigned(opcode(14 downto 10)));
	   r3 := to_integer(unsigned(opcode(19 downto 15)));
	   ro := to_integer(unsigned(rd));
	
	   if rising_edge(clk) then
	       file_open(open_status, result_file, outputfile, APPEND_MODE);
	       if(open_status = open_ok) then
	           write(line_contents, string'("====================="));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("      Cycle " & integer'image(count)));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("====================="));
	           writeline(result_file, line_contents);
	           write(line_contents, string'(""));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||             STAGE 1 - FETCH            ||             STAGE 2 - DECODE            ||                               STAGE 3 - EXECUTE                              ||           STAGE 4 - WRITEBACK           ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||========================================||=========================================||==============================================================================||=========================================||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("|| instruction: " & to_string(instr) & " || opcode: " & to_string(opcode) & "       || function: " & to_string(func) & "  || S1: " & to_string(select1) & "       S2: " & to_string(select2) & "       S3: " & to_string(select3) & "        || field: " & to_string(field) & "        ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||                                        || R[" & to_dstring(r1, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs1_data) & " || M1: " & to_hstring(mux_data1) & " || A1: " & to_hstring(alu_in1) & " || WE: " & to_string(WE) & "                                   ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||                                        || R[" & to_dstring(r2, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs2_data) & " || M2: " & to_hstring(mux_data2) & " || A2: " & to_hstring(alu_in2) & " || RD: " & to_dstring(ro, 2, RIGHT, ZEROFILL) & "                                  ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||                                        || R[" & to_dstring(r3, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs3_data) & " || M3: " & to_hstring(mux_data3) & " || A3: " & to_hstring(alu_in3) & " || R[" & to_dstring(ro, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(wb_data) & " ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||                                        ||                                         || FD: " & to_hstring(mux_data1) & " || AO: " & to_hstring(alu_out) & " ||                                         ||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("||========================================||=========================================||==============================================================================||=========================================||"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'("     R[RS] = RS DATA     M = MUX INPUT DATA     FD = FORWARD DATA     S = SELECT BIT    A = ALU INPUT DATA     AO = ALU OUTPUT     WE = WRITE ENABLE     RD = WRITE DESTINATION     R[RD] = WRITE DATA"));
	           writeline(result_file, line_contents);
	           write(line_contents, string'(""));
	           writeline(result_file, line_contents);
	           write(line_contents, string'(""));
	           writeline(result_file, line_contents);
	           write(line_contents, string'(""));
	           writeline(result_file, line_contents);
	       else
	           report "File could not be opened" severity error;
	       end if;
	       file_close(result_file);
	   end if;
    end process;

    printregfile: process(count, sel)
        file result_file: text;
        variable line_contents: line;
        variable open_status: file_open_status;
        variable data: std_logic_vector(127 downto 0);
    begin
        file_open(open_status, result_file, outputfile, APPEND_MODE);
        if(open_status = open_ok) then
            if count = 67 then
                if sel = 0 then
                    write(line_contents, string'(""));
                    writeline(result_file, line_contents);
                    write(line_contents, string'(""));
                    writeline(result_file, line_contents);
                    write(line_contents, string'(""));
                    writeline(result_file, line_contents);
                end if;
                
                if sel < 32 then
                    if sel = 0 then
                        write(line_contents, string'("=========================="));
                        writeline(result_file, line_contents);
                        write(line_contents, string'(" FINAL STATE OF REGISTERS"));
                        writeline(result_file, line_contents);
                        write(line_contents, string'("=========================="));
                        writeline(result_file, line_contents);
                        write(line_contents, string'(""));
                        writeline(result_file, line_contents);
                        write(line_contents, string'("==========================================="));
                        writeline(result_file, line_contents);
                        
                    else
                        write(line_contents, string'("|| R" & to_dstring(sel - 1, 2, RIGHT, ZEROFILL) & ": " & to_hstring(o) & " ||"));
                        writeline(result_file, line_contents);
                    end if;
                    if sel < 31 then
                        sel <= sel + 1;
                    end if;
                    if sel = 31 then
                        write(line_contents, string'("|| R" & to_dstring(31, 2, RIGHT, ZEROFILL) & ": " & to_hstring(o) & " ||"));
                        writeline(result_file, line_contents);
                        write(line_contents, string'("=========================================="));
                        writeline(result_file, line_contents);
                    end if;
                end if;
            end if;
        end if;
        file_close(result_file);
    end process;      
end sim;