----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2023 07:28:13 PM
-- Design Name: 
-- Module Name: alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity alu is 
    generic(
        constant max_s16 : integer := 2**15-1;
        constant min_s16 : integer := -2**15;
        constant max_s32 : integer := 2**31-1;
        constant min_s32 : integer := -2**31;
		constant max_s64 : integer := 2**63-1;
        constant min_s64 : integer := -2**63
    );
	port(
	inp1, inp2, inp3 : in std_logic_vector(127 downto 0); 
	OP: in std_logic_vector(24 downto 0);
	
	outp: out std_logic_vector(127 downto 0)
	);
end entity; 

architecture behavioral of alu is 
begin 	
	
	alu : process (all)   
	variable immediate : std_logic_vector(15 downto 0) := OP(20 downto 5); 
	variable field : integer := to_integer(unsigned(OP(23 downto 21)))* 16;
	variable reg1 : std_logic_vector(127 downto 0);
	variable reg2 : std_logic_vector(127 downto 0);
	variable reg3 : std_logic_vector(127 downto 0);
	variable reg_out: std_logic_vector(127 downto 0);
	variable rs1, rs2, rs3, rd: std_logic_vector(4 downto 0); 
	variable shift : integer; 
	variable number: integer; 
	variable rot: integer;-- the amount to rotate for ROTW. 
	variable count: unsigned (15 downto 0) := (others => '0');
	variable temp: std_logic;
	variable temp_reg: std_logic_vector(127 downto 0);
	
	variable s16, e16, s32, e32, s64, e64 : integer; -- start and end index of 32 bit field
	
	begin 
	reg1 := inp1;
	reg2 := inp2;
	reg3 := inp3;
	field := to_integer(unsigned(OP(23 downto 21)))* 16;
	immediate  := OP(20 downto 5);
	if OP(24)='0' then 
		-- write load instructions 
		reg1(field + 15 downto field) := OP(20 downto 5);
		reg_out(127 downto 0) := reg1(127 downto 0); --- verify if this makes any sense. OR just make this input an inputoutput. 
	else 
		if OP(23)='0' then 
			case(OP(22 downto 20)) is
				
				when "000" => -- Signed Integer Multiply-Add Low with Saturation
					for i in 0 to 3 loop
					   s16 := 32*i+15; 
					   e16 := 32*i; 
					   s32 := 32*i+31; 
					   e32 := 32*i;
--					   temp := reg1(s32);
					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
					   if(reg_out(s32) = reg1(s32)) then 
						   temp := reg1(s32); 
						   reg_out(s32 downto e32) := std_logic_vector(signed(reg_out(s32 downto e32)) + signed(reg1(s32 downto e32))); 
						   if reg_out(s32) /= temp then 
							   reg_out(s32) := temp; 
							   reg_out(s32-1 downto e32):= (others => not reg_out(s32)); 
						   end if;
					   else
					       reg_out(s32 downto e32) := std_logic_vector(signed(reg_out(s32 downto e32)) + signed(reg1(s32 downto e32)));
					   end if;
                    end loop;
					   
--					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
--					   if(reg_out(s32) = reg1(s32) and 
--					   ((min_s32 - to_integer(signed(reg_out(s32 downto e32))) > to_integer(signed(reg1(s32 downto e32)))) or 
--					   (max_s32 - to_integer(signed(reg_out(s32 downto e32))) < to_integer(signed(reg1(s32 downto e32)))))) then
--					       reg_out(s32 - 1 downto e32) := (others => not(reg_out(s32)));
--					   else
--					       reg_out(s32 downto e32) := std_logic_vector(signed(reg_out(s32 downto e32)) + signed(reg1(s32 downto e32)));
--					   end if;
--					end loop;
					
				when "001" => -- Signed Integer Multiply-Add High with Saturation
					for i in 0 to 3 loop
					   s16 := 32*i+31; 
					   e16 := 32*i+16; 
					   s32 := 32*i+31; 
					   e32 := 32*i;
					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
					   if(reg_out(s32) = reg1(s32)) then 
						   temp := reg1(s32); 
						   reg_out(s32 downto e32) := std_logic_vector(signed(reg_out(s32 downto e32)) + signed(reg1(s32 downto e32))); 
						   if reg_out(s32)/= temp then 
							   reg_out(s32) := temp; 
							   reg_out(s32-1 downto e32):= (others => not reg_out(s32)); 
						   end if;
					   else
					       reg_out(s32 downto e32) := std_logic_vector(signed(reg_out(s32 downto e32)) + signed(reg1(s32 downto e32)));
					   end if;
                    end loop;
				
				when "010" => -- Signed Integer Multiply-Subtract Low with Saturation
				    for i in 0 to 3 loop
					   s16 := 32*i+15; 
					   e16 := 32*i; 
					   s32 := 32*i+31; 
					   e32 := 32*i;
					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
					   if(reg_out(s32) /= reg1(s32)) then 
						   reg_out(s32 downto e32) := std_logic_vector(signed(reg1(s32 downto e32)) - signed(reg_out(s32 downto e32))); 
						   if reg_out(s32) /= reg1(s32) then 
							   reg_out(s32) := reg1(s32); 
							   reg_out(s32-1 downto e32):= (others => not reg_out(s32)); 
						   end if;
					   else
					       reg_out(s32 downto e32) := std_logic_vector(signed(reg1(s32 downto e32)) - signed(reg_out(s32 downto e32)));
					   end if;
					end loop;
				
--					for i in 0 to 3 loop
--					   s16 := 32*i+15; 
--					   e16 := 32*i; 
--					   s32 := 32*i+31; 
--					   e32 := 32*i;
--					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
--					   if(reg_out(s32) /= reg1(s32) and ((to_integer(signed(reg1(s32 downto e32))) - min_s32 < to_integer(signed(reg_out(s32 downto e32)))) or (to_integer(signed(reg1(s32 downto e32))) - max_s32 > to_integer(signed(reg_out(s32 downto e32)))))) then
--					       reg_out(s32) := reg1(s32);
--					       reg_out(s32 - 1 downto e32) := (others => not(reg_out(s32)));
--					   else
--					       reg_out(s32 downto e32) := std_logic_vector(signed(reg1(s32 downto e32)) - signed(reg_out(s32 downto e32)));
--					   end if;
--					end loop;

				when "011" => -- Signed Integer Multiply-Subtract High with Saturation
					for i in 0 to 3 loop
					   s16 := 32*i+31; 
					   e16 := 32*i+16; 
					   s32 := 32*i+31; 
					   e32 := 32*i;
					   reg_out(s32 downto e32) := std_logic_vector((signed(reg3(s16 downto e16)) * signed(reg2(s16 downto e16))));
					   if(reg_out(s32) /= reg1(s32)) then 
						   reg_out(s32 downto e32) := std_logic_vector(signed(reg1(s32 downto e32)) - signed(reg_out(s32 downto e32))); 
						   if reg_out(s32) /= reg1(s32) then 
							   reg_out(s32) := reg1(s32); 
							   reg_out(s32-1 downto e32):= (others => not reg_out(s32)); 
						   end if;
					   else
					       reg_out(s32 downto e32) := std_logic_vector(signed(reg1(s32 downto e32)) - signed(reg_out(s32 downto e32)));
					   end if;
					end loop;
				
				when "100" => -- Signed Long Integer Multiply-Add Low with Saturation 
					for i in 0 to 1 loop
					   s32 := 64*i+31; 
					   e32 := 64*i; 
					   s64 := 64*i+63; 
					   e64 := 64*i;
					   reg_out(s64 downto e64) := std_logic_vector((signed(reg3(s32 downto e32)) * signed(reg2(s32 downto e32))));
					   if(reg_out(s64) = reg1(s64)) then 
						   temp :=reg_out(s64); 
						   reg_out(s64 downto e64) := std_logic_vector(signed(reg_out(s64 downto e64)) + signed(reg1(s64 downto e64))); 
						   if reg_out(s64 )/= temp then 
							   reg_out(s64) := temp; 
							   reg_out(s64-1 downto e64):= (others => not temp); 
						   end if;
					   else
					       reg_out(s64 downto e64) := std_logic_vector(signed(reg_out(s64 downto e64)) + signed(reg1(s64 downto e64)));
					   end if;
					end loop;
				
				when "101" => -- Signed Long Integer Multiply-Add High with Saturation
					for i in 0 to 1 loop
					   s32 := 64*i+63; 
					   e32 := 64*i+32; 
					   s64 := 64*i+63; 
					   e64 := 64*i;
					   reg_out(s64 downto e64) := std_logic_vector((signed(reg3(s32 downto e32)) * signed(reg2(s32 downto e32))));
					   if(reg_out(s64) = reg1(s64)) then 
						   temp :=reg_out(s64); 
						   reg_out(s64 downto e64) := std_logic_vector(signed(reg_out(s64 downto e64)) + signed(reg1(s64 downto e64))); 
						   if reg_out(s64 )/= temp then 
							   reg_out(s64) := temp; 
							   reg_out(s64-1 downto e64):= (others => not temp); 
						   end if;
					   else
					       reg_out(s64 downto e64) := std_logic_vector(signed(reg_out(s64 downto e64)) + signed(reg1(s64 downto e64)));
					   end if;
					end loop;
				
				when "110" => -- Signed Long Integer Multiply-Subtract Low with Saturation
					for i in 0 to 1 loop
					   s32 := 64*i+31; 
					   e32 := 64*i; 
					   s64 := 64*i+63; 
					   e64 := 64*i;
					   reg_out(s64 downto e64) := std_logic_vector((signed(reg3(s32 downto e32)) * signed(reg2(s32 downto e32))));
					   if(reg_out(s64) /= reg1(s64)) then 
						   reg_out(s64 downto e64) := std_logic_vector(signed(reg1(s64 downto e64)) - signed(reg_out(s64 downto e64))); 
						   if reg_out(s64 )/= reg1(s64) then 
							   reg_out(s64) := reg1(s64); 
							   reg_out(s64-1 downto e64):= (others => not reg1(s64)); 
						   end if;
					   else
					       reg_out(s64 downto e64) := std_logic_vector(signed(reg1(s64 downto e64)) - signed(reg_out(s64 downto e64)));
					   end if;
					end loop;
				
				when "111" => -- Signed Long Integer Multiply-Subtract High with Saturation
					for i in 0 to 1 loop
					   s32 := 64*i+63; 
					   e32 := 64*i+32; 
					   s64 := 64*i+63; 
					   e64 := 64*i;
					   reg_out(s64 downto e64) := std_logic_vector((signed(reg3(s32 downto e32)) * signed(reg2(s32 downto e32))));
					   if(reg_out(s64) /= reg1(s64)) then 
						   reg_out(s64 downto e64) := std_logic_vector(signed(reg1(s64 downto e64)) - signed(reg_out(s64 downto e64))); 
						   if reg_out(s64 )/= reg1(s64) then 
							   reg_out(s64) := reg1(s64); 
							   reg_out(s64-1 downto e64):= (others => not reg1(s64)); 
						   end if;
					   else
					       reg_out(s64 downto e64) := std_logic_vector(signed(reg1(s64 downto e64)) - signed(reg_out(s64 downto e64)));
					   end if;
					end loop;
				
				when others =>
				-- do nothing
			end case;
		 
		elsif OP(23)='1' then  -- we can replace this with Else statement. 
			-- write for R3 instruction format 
			case(OP(22 downto 15)) is -- R3 instructions  : GO OVER ALL THE TYPE CASTS. 
				
				when "00000000" => --NOP
				reg_out := (others => '0'); 
				--wait; need to just output zeros but not update anything.
				
				when "00000001" =>--SHRHI 
				--rs2 := OP(14 downto 10);  -- don't really need this 
				shift:= to_integer(unsigned(OP(13 downto 10)));  
				half_word_shift: for number in 0 to 7 loop
					reg_out((number * 16)+ (15 - shift) downto (number * 16)):= reg1((number * 16)+15 downto (number * 16) + shift); 
					reg_out ((number * 16) + 15 downto (number * 16) + (16- shift)) := (others => '0'); 
						--number := number +1; 
				end loop; 			
				
				when "00000010" => --AU
				add_unsigned_loop: for number in 0 to 3 loop
					reg_out((number * 32)+ 31 downto (number *32)) := std_logic_vector(unsigned (inp1((number * 32) + 31 downto (number *32))) + unsigned (inp2((number * 32) + 31 downto (number *32))));
					--number := number +1 ; 
				end loop; 
				
				when "00000011" => --CNT1H 
				count_1s: for i in 0 to 7 loop 
					count:= (others => '0'); 
					for j in 0 to 15 loop 
						if reg1(16* i + j) = '1' then 
							count := count + 1;
						end if;
					end loop;
					reg_out((16* i)+ 15 downto (16* i)):= std_logic_vector(count); 
				end loop; 
				
				when "00000100" => --AHS: add halfword saturated : packed 16-bit halfword signed
				add_signed_half_word_sat: for i in 0 to 7 loop
					if (reg1(16*i + 15) = reg2(16*i + 15)) and ((-32768- to_integer(signed (reg1(16*i + 15 downto 16*i))) > to_integer (signed(reg2(16*i + 15 downto 16*i))) or 32767 - to_integer(signed (reg1(16*i + 15 downto 16*i))) < to_integer(signed (reg2(16*i + 15 downto 16*i))))) then
						reg_out(16*i + 15 ) := (reg1(16*i +15));-- 
						reg_out(16*i + 14 downto 16 * i) := (others => (not(reg1(16*i +15)))); 
					else 
						reg_out(16*i + 15 downto 16*i) := std_logic_vector(signed(reg1(16*i + 15 downto 16*i)) + signed(reg2(16*i + 15 downto 16*i)));
					end if; 
				end loop;  					
--				for i in 0 to 3 loop
--					   s32 := 32*i+31; 
--					   e32 := 32*i;
--					   if(reg1(s32) = reg2(s32)) then 
--						   temp := reg1(s32); 
--						   reg_out(s32 downto e32) := std_logic_vector(signed(reg2(s32 downto e32)) + signed(reg1(s32 downto e32))); 
--						   if reg_out(s32)/= temp then 
--							   reg_out(s32) := temp; 
--							   reg_out(s32-1 downto e32):= (others => not temp); 
--						   end if;
--					   else
--					       reg_out(s32 downto e32) := std_logic_vector(signed(reg2(s32 downto e32)) + signed(reg1(s32 downto e32)));
--					   end if;
--					end loop;
				--addition with saturation of the contents of registers rs1 and rs2 . (Comments: 8 separate 16-bit values in each 128-bit register)
	
				when "00000101" => -- bit wise or of contents of rs1 and rs2 
				reg_out(127 downto 0) :=   (reg1(127 downto 0))  or (reg2(127 downto 0)); 
				
				when "00000110" => -- BCW: Broadcast the rightmost word in the contents of rs1 to all the 4 words of rd. 
				broadcast: for i in 0 to 3 loop    
					reg_out(32*i+ 31 downto 32*i) := reg1(31 downto 0);
				end loop; 
				
				when "00000111" => --max word signed placed in rd. 	MAXSW
				place_max_word: for i in 0 to 3 loop
					if to_integer(signed(reg1(32*i+ 31 downto 32*i))) >	to_integer(signed(reg2(32*i+ 31 downto 32*i))) then 
						reg_out(32*i+ 31 downto 32*i) := reg1(32*i+ 31 downto 32*i);
					else
						reg_out(32*i+ 31 downto 32*i) := reg2(32*i+ 31 downto 32*i); -- setting the second input from rs2 as the default if in case both the words are the same. 
					end if; 
				end loop; 
				
				when "00001000" => -- MINSW	
				place_min_word: for i in 0 to 3 loop
					if to_integer(signed(reg1(32*i+ 31 downto 32*i))) >	to_integer(signed(reg2(32*i+ 31 downto 32*i))) then 
						reg_out(32*i+ 31 downto 32*i) := reg2(32*i+ 31 downto 32*i); -- if the contents of rs2 is less than that of rs1 then place the words from rs2 into that corresponding position in rd. 
					else
						reg_out(32*i+ 31 downto 32*i) := reg1(32*i+ 31 downto 32*i); -- setting the first input from rs1 as the default if in case both the words are the same. 
					end if; 
				end loop; 	
				
				when "00001001" => --MLHU: multiply low unsigned:-- not sure if this is correct. Find a more efficient way of doing this.  
				multiply_low_unsigned : for i in 0 to 3 loop
					reg_out(32*i+ 31 downto 32*i) := std_logic_vector(unsigned(reg1(32*i+ 15 downto 32*i))* unsigned(reg2(32*i+ 15 downto 32*i))); 
				end loop; 
				
				when "00001010" => -- MLHSS: multiply by sign saturated: 	  -- verify this. 
				MLHSS_loop: for i in 0 to 7 loop  
				if to_integer(signed(reg2(16*i + 15 downto 16*i))) = 0 then 
					reg_out(16*i + 15 downto 16*i) := (others => '0'); 
				else 																					 -- can't be an underflow 
					if reg2(16*i + 15) = '1' and reg1(16*i + 15 downto 16*i) = x"8000" then 
						reg_out(16*i + 15 downto 16*i):=x"7FFF";
					elsif reg2(16*i + 15) = '1' then  -- if the sign that is being multiplied by is negative. 
						reg_out(16*i + 15 downto 16*i) := std_logic_vector(unsigned(not reg1(16*i + 15 downto 16*i)) + 1); 
					else -- if the signs are different 
						reg_out(16*i + 15 downto 16*i) := reg1(16*i + 15 downto 16*i);-- don't 
					end if; 
				end if; 
				end loop; 
				
				when "00001011" => --AND 
				reg_out(127 downto 0) :=   (reg1(127 downto 0))  and (reg2(127 downto 0));	  
				
				when "00001100" => --INVB: invert(flip) the bits of rs1 and place them in rd.
				reg_out(127 downto 0) :=   not (reg1(127 downto 0)); 
				
				when "00001101" => -- ROTW: Rotate bits in word. 
				rotate: for i in 0 to 3 loop   
					rot := to_integer(unsigned(reg2(32*i+4 downto 32*i)));
					if rot > 0 then 
						reg_out(32*i +31 downto 32*i +31 - rot +1 ):= reg1(32*i + rot-1 downto 32*i);  
						reg_out(32*i +31 - rot downto 32* i):= reg1(32*i +31 downto 32*i+ rot);	
					else 
						reg_out(32*i+31 downto 32*i):= reg1(32*i+31 downto 32*i);
					end if; 
				end loop; 
				
				when "00001110" => -- 	SFWU rs2- rs1
				SFWU_loop: for i in 0 to 3 loop 
				    reg_out(32*i+31 downto 32*i) := std_logic_vector(unsigned(reg2(32*i+31 downto 32*i)) - unsigned(reg1(32*i+31 downto 32*i)));
				    end loop; 
				
				when "00001111" => --SFHS
				subtract_from_halfword_sat: for i in 0 to 7 loop
					if (reg1(16*i+15) /= reg2(16*i+15)) and 
					(((to_integer(signed(reg2(16*i+15 downto 16*i))) + 32768) <  to_integer(signed(reg1(16*i+15 downto 16*i)))) or 
					((to_integer(signed(reg2(16*i+15 downto 16*i))) - 32767) > to_integer(signed(reg1(16*i+15 downto 16*i))))) then
						reg_out(16*i+15 ) := (reg2(16*i +15));-- 
						reg_out(16*i+14 downto 16*i) := (others => (not(reg2(16*i +15)))); 
					else 
						reg_out(16*i + 15 downto 16*i) := std_logic_vector(signed(reg2(16*i + 15 downto 16*i)) - signed(reg1(16*i + 15 downto 16*i)));
					end if; 
				end loop;  
				
				when others => 
				end case; 
		end if; 
	end if ; 
	outp <= reg_out; -- need to change this becuase the output isn't always just one register. Either incorporate this for every case or just generalize it.  
	end process;
end behavioral;