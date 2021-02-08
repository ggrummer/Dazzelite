----------------------------------------------------------------------------------
-- Create Date: 11/06/2015 08:46:52 AM
-- Module Name: chase_tb - Behavioral
-- By: Grant Grummer
-- 
-- Description: simulation for chase module.
-- 
-- Revision: 0.0
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity chase_tb is
end chase_tb;


architecture Behavioral of chase_tb is

   COMPONENT chase
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         prog_busy   : in STD_LOGIC;
         fading      : in STD_LOGIC;
         offset      : out STD_LOGIC_VECTOR (5 downto 0);
         neo_size    : out STD_LOGIC_VECTOR (7 downto 0);
         sizeplus1   : out STD_LOGIC_VECTOR (7 downto 0);
         chase_done  : out STD_LOGIC);
   END COMPONENT;
   
   
   signal clk8tb     : std_logic;
   signal rst        : std_logic;
   
   signal clk8       : std_logic;
   signal reset8     : std_logic;
   signal cmd_inst   : std_logic_VECTOR (3 downto 0);
   signal cmd_data   : std_logic_VECTOR (27 downto 0);
   signal prog_busy  : std_logic;
   signal fading     : std_logic;
   signal offset     : std_logic_VECTOR (5 downto 0);
   signal neo_size   : std_logic_VECTOR (7 downto 0);
   signal sizeplus1  : std_logic_VECTOR (7 downto 0);
   signal chase_done : std_logic;
   

begin

   chase_0 : chase
      PORT MAP(
         clk8        => clk8,
         reset8      => reset8,
         cmd_inst    => cmd_inst,
         cmd_data    => cmd_data,
         prog_busy   => prog_busy,
         fading      => fading,
         offset      => offset,
         neo_size    => neo_size,
         sizeplus1   => sizeplus1,
         chase_done  => chase_done
      );
   
   
   clk8    <= clk8tb;
   reset8  <= rst;
  
   rst     <= '1', '0' after 3750 ns;
  
  
   -- 800 KHz clock
   clk8_proc : process
   begin
       loop
         clk8tb <= '0';
         wait for 625 ns;
         clk8tb <= '1';
         wait for 625 ns;
       end loop;
       wait;
   end process;
  
 
   chase_test_proc : process
   begin
      prog_busy <= '0';
      fading    <= '0'; 
      cmd_inst  <= (others => '0');
      cmd_data  <= (others => '0');
      wait for 6 us;
      wait until rising_edge(clk8tb);
      wait for 2 ns;
      wait for 5 us;
      
		-- send chase commands with an increment of 1
      for I in 0 to 70 loop
         cmd_inst <= x"5"; -- chase instruction
         cmd_data <= x"0001000"; -- increment chase
         wait for 2.5 us;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 10 us;
      end loop;
		
		cmd_inst <= x"5"; -- chase instruction
		cmd_data <= x"0002000"; -- zero offset
		wait for 2.5 us;
		cmd_inst <= x"F"; -- null instruction
		cmd_data <= x"0000000"; 
		wait for 20 us;
		
		-- send chase commands with an decrement of -1
      for I in 0 to 70 loop
         cmd_inst <= x"5"; -- chase instruction
         cmd_data <= x"0000000"; -- decrement chase
         wait for 2.5 us;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 10 us;
      end loop;
		
		cmd_inst <= x"5"; -- chase instruction
		cmd_data <= x"0002000"; -- zero offset
		wait for 2.5 us;
		cmd_inst <= x"F"; -- null instruction
		cmd_data <= x"0000000"; 
		wait for 20 us;
		
		-- send chase commands with an increment of 4
      for I in 0 to 70 loop
         cmd_inst <= x"5"; -- chase instruction
         cmd_data <= x"0401000"; -- increment chase
         wait for 2.5 us;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
			wait for 10 us;
      end loop;
      
		cmd_inst <= x"5"; -- chase instruction
		cmd_data <= x"0002000"; -- zero offset
		wait for 2.5 us;
		cmd_inst <= x"F"; -- null instruction
		cmd_data <= x"0000000"; 
		wait for 20 us;
		
		-- send chase commands with an decrement of 4
      for I in 0 to 70 loop
         cmd_inst <= x"5"; -- chase instruction
         cmd_data <= x"0400000"; -- decrement chase
         wait for 2.5 us;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
			wait for 10 us;
      end loop;
      
		cmd_inst <= x"5"; -- chase instruction
		cmd_data <= x"0002000"; -- zero offset
		wait for 2.5 us;
		cmd_inst <= x"F"; -- null instruction
		cmd_data <= x"0000000"; 
		wait for 20 us;
		
      wait for 20 us;
      -- end test
      assert false
         report "Chase Simulation Done " & cr
         severity failure;
      wait;
   end process;


end Behavioral;
