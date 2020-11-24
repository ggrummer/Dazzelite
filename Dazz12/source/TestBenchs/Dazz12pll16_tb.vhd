-----------------------------------------------------------------------
-- Create Date: 10/28/2020
-- Module Name: dazz12pll16_tb - behavioral
-- By: Grant Grummer
-- 
-- Description: test bench for the PLL in the dazzelite design 
-- 
-- Revision: 0.0
-- 
-----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dazz12pll16_tb is
end dazz12pll16_tb;

architecture Behavioral of dazz12pll16_tb is


   component Dazz12pll16 is
		port(
			ref_clk_i: in std_logic;
			rst_n_i: in std_logic;
			lock_o: out std_logic;
			outcore_o: out std_logic;
			outglobal_o: out std_logic
		);
	end component;
	
	
	signal osc12tb   		: std_logic;
	signal rst       		: std_logic;
	
	signal ref_clk_i		: std_logic;
	signal rst_n_i			: std_logic;
	signal lock_o			: std_logic;
	signal outcore_o		: std_logic;
	signal outglobal_o	: std_logic;
	
	
begin
	
	
	pll_0 : Dazz12pll16 
		port map(
			ref_clk_i	=> ref_clk_i,
			rst_n_i		=> rst_n_i, -- Active Low
			lock_o		=> lock_o,
			outcore_o	=> outcore_o,
			outglobal_o	=> outglobal_o
	);
	
	
	-- 12 MHz clock
   osc12_proc : process
   begin
       loop
         osc12tb <= '0';
         wait for 41.67 ns;
         osc12tb <= '1';
         wait for 41.67 ns;
       end loop;
       wait;
   end process;
	
  
   rst			<= '0', '1' after 250 ns;
	ref_clk_i	<= osc12tb;
	rst_n_i		<= rst;
	
	
	dazz12pll16_test_proc : process 
   begin
      
      wait for 10 us;
      assert false
         report "Dazzelite PLL Simulation Done " & cr
         severity failure;
      wait;
   end process;


end Behavioral;
	