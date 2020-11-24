----------------------------------------------------------------------
-- Create Date: 02/19/2014
-- Module Name: fade_tester - test bench tester
-- By: Grant Grummer
-- 
-- Description: tests fade rtl. 
-- 
-- Revision 0.5 - test revision 0.5 and above
-- 
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;


ENTITY fade_tester IS
   PORT (
      clk8      : OUT    STD_LOGIC;
      reset8    : OUT    STD_LOGIC;
      cmd_inst  : OUT    STD_LOGIC_VECTOR(3 downto 0);
      cmd_data  : OUT    STD_LOGIC_VECTOR(27 downto 0);
      prog_busy : OUT    STD_LOGIC;
      fading    : IN     STD_LOGIC;
      fade_en   : IN     STD_LOGIC;
      fade_data : IN     STD_LOGIC_VECTOR(7 downto 0);
      fade_done : IN     STD_LOGIC
   );
END fade_tester;


ARCHITECTURE rtl OF fade_tester IS
   
   signal clktb     : std_logic;
   signal rst       : std_logic;
   
BEGIN
   
   
   clk8   <= clktb;
   reset8 <= rst;
  
   rst    <= '1', '0' after 72 ns;
  
  
   clk_proc : process
   begin
     loop
       clktb <= '1';
       wait for 8 ns;
       clktb <= '0';
       wait for 8 ns;
     end loop;
     wait;
   end process;
   
   
   data_proc : process
   begin
      cmd_inst  <= (others => '1');
      cmd_data  <= (others => '0');
      prog_busy <= '0';
      wait for 145 ns;
      
      for I in 0 to 100 loop
      
         -- first fade instruction
			-- enable fade, count increment is 8, upper limit is 192,
			-- lower limit is 16
         cmd_inst <= x"7"; -- fade instruction
         cmd_data <= x"3301000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until fade_done = '1';
         wait for 48 ns;
      
      end loop;
      
      
      for I in 0 to 200 loop
      
         -- second fade instruction
			-- enable fade, count increment is 1, upper limit is 40,
			-- lower limit is 1
         cmd_inst <= x"7"; -- fade instruction
         cmd_data <= x"0C01000";
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until fade_done = '1';
         wait for 48 ns;
      
      end loop;
		
		
		for I in 0 to 160 loop
      
         -- third fade instruction
			-- enable fade, count increment is 2, upper limit is 60,
			-- lower limit is 4
         cmd_inst <= x"7"; -- fade instruction
         cmd_data <= x"1901000";
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until fade_done = '1';
         wait for 48 ns;
      
      end loop;
      
      
      for I in 0 to 5 loop
      
         -- forth fade instruction
         cmd_inst <= x"7"; -- fade instruction
         cmd_data <= x"0000000"; -- disable fade
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; -- pause 5 x delay
         wait until fade_done = '1';
         wait for 48 ns;
      
      end loop;
      
      wait for 32 ns;
        assert false
          report "Lites Fade Simulation Done " & cr
          severity failure;
        wait;
     end process;
   
   
END rtl;
