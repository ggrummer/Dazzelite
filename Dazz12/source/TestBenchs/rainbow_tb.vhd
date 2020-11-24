----------------------------------------------------------------------
-- Create Date: 01/15/2020
-- Module Name: rainbow_tb
-- By: Grant Grummer
-- 
-- Description: tests rainbow rtl. 
-- 
-- Revision 0.0
-- 
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;


entity rainbow_tb is
end rainbow_tb;


ARCHITECTURE rtl OF rainbow_tb IS
   
   COMPONENT rainbow
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         prog_busy   : in STD_LOGIC;
         rbow_en     : out STD_LOGIC;
         rbow_data   : out STD_LOGIC_VECTOR (11 downto 0);
         rbow_done   : out STD_LOGIC);
   END COMPONENT;
	
	signal clktb     : std_logic;
   signal rst       : std_logic;
	
	signal clk8        : STD_LOGIC;
   signal reset8      : STD_LOGIC;
   signal cmd_inst    : STD_LOGIC_VECTOR (3 downto 0);
   signal cmd_data    : STD_LOGIC_VECTOR (27 downto 0);
   signal prog_busy   : STD_LOGIC;
   signal rbow_en     : STD_LOGIC;
   signal rbow_data   : STD_LOGIC_VECTOR (11 downto 0);
   signal rbow_done   : STD_LOGIC;
   
BEGIN
   
   rainbow_0 : rainbow
		PORT MAP (
			clk8      => clk8,
			reset8    => reset8,
			cmd_inst  => cmd_inst,
			cmd_data  => cmd_data,
			prog_busy => prog_busy,
			rbow_en   => rbow_en,
			rbow_data => rbow_data,
			rbow_done => rbow_done
		);
	
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
      
         -- first rainbow instruction
         cmd_inst <= x"B"; -- rainbow instruction
         cmd_data <= x"0001000"; -- enable rainbow
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until rbow_done = '1';
         wait for 48 ns;
      
      end loop;
      
      
      for I in 0 to 200 loop
      
         -- second rainbow instruction
         cmd_inst <= x"B"; -- rainbow instruction
         cmd_data <= x"0001000"; -- enable rainbow
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until rbow_done = '1';
         wait for 48 ns;
      
      end loop;
      
      
      for I in 0 to 5 loop
      
         -- third rainbow instruction
         cmd_inst <= x"B"; -- rainbow instruction
         cmd_data <= x"0000000"; -- disable rainbow
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; -- pause 5 x delay
         wait until rbow_done = '1';
         wait for 48 ns;
      
      end loop;
      
      wait for 32 ns;
        assert false
          report "Lites Rainbow Simulation Done " & cr
          severity failure;
        wait;
     end process;
   
   
END rtl;
