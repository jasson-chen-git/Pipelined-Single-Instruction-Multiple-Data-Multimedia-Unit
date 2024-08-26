library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity the_cpu_reborn is
    port(
        clk: in std_logic;
        filename: in string;
        
        instr, opcode, func, field: out std_logic_vector(24 downto 0);
        rs1_data, rs2_data, rs3_data, 
        mux_data1, mux_data2, mux_data3, mux_data,
        alu_in1, alu_in2, alu_in3, alu_out,
        wb_data: out std_logic_vector(127 downto 0);
        WE, select1, select2, select3: out std_logic;
        rd: out std_logic_vector(4 downto 0);
        
        sel: in integer;
        o: out std_logic_vector(127 downto 0);
        last : out std_logic_vector(127 downto 0)
    );
end the_cpu_reborn;

architecture structural of the_cpu_reborn is
    signal one, two, twelve, seventeen: std_logic_vector(24 downto 0);
    signal three, four, five, six, seven, eight, nine, ten, eleven, thirteen, sixteen: std_logic_vector(127 downto 0);
    signal fourteen, s1, s2, s3: std_logic;
    signal fifteen: std_logic_vector(4 downto 0);
    
    signal reg_data: std_logic_vector(127 downto 0);
begin
    
    U1: entity instruction_buffer   port map(clk => clk, asmfile => filename,
                                                instruction => one);
    
    U2: entity if_id_stage_reg      port map(clk => clk, instr => one,
                                                opcode => two);
    
    U3: entity reg_file             port map(opcode => two, WE => fourteen, rd => fifteen, data => sixteen,
                                                data1 => three, data2 => four, data3 => five,
                                                sel => sel, o => o, last => last);
    
    U4: entity id_ex_stage_reg      port map(clk => clk, opcode => two, d1in => three, d2in => four, d3in => five,
                                                func => twelve, d1out => six, d2out => seven, d3out => eight);
    
    U5: entity mux                  port map(s1 => s1, s2 => s2, s3 => s3, d1m => six, d2m => seven, d3m => eight, data => sixteen,
                                                rs1 => nine, rs2 => ten, rs3 => eleven);
    
    U6: entity alu                  port map(inp1 => nine, inp2 => ten, inp3 => eleven, OP => twelve,
                                                outp => thirteen);
    
    U7: entity ex_wb_stage_reg      port map(clk => clk, func => twelve, dataEX => thirteen,
                                                field => seventeen, dataWB => sixteen, WE => fourteen, rd => fifteen);
    
    U8: entity forward_unit         port map(instr => twelve, opcode => seventeen,
                                                s1 => s1, s2 => s2, s3 => s3);
    
    
    --  STAGE 1 - INSTRUCTION FETCH                                            
    instr <= one;
    
    --  STAGE 2 - INSTRUCTION DECODE
    opcode <= two;
    rs1_data <= three;
    rs2_data <= four;
    rs3_data <= five;
    
    --  STAGE 3 - EXECUTION / FORWARD
    func <= twelve;
    mux_data1 <= six;
    mux_data2 <= seven;
    mux_data3 <= eight;
    mux_data <= sixteen;
    select1 <= s1;
    select2 <= s2;
    select3 <= s3;
    alu_in1 <= nine;
    alu_in2 <= ten;
    alu_in3 <= eleven;
    alu_out <= thirteen;
    
    --  STAGE 4 - WRITEBACK / FORWARD
    field <= seventeen;
    WE <= fourteen;
    rd <= fifteen;
    wb_data <= sixteen;
    
end architecture;
