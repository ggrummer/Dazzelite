-----------------------------------------------------------------------
-- Create Date: 03/20/2019 10:56:12 PM
-- Module Name: dazz_top_simple_tb - behavioral
-- By: Grant Grummer
-- 
-- Description: test bench for top level for dazzelite design 
-- 
-- Revision: 0.0
-- 
-----------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.std_logic_arith.all;
-- USE ieee.std_logic_unsigned.all;


entity dazz_top_simple_tb is
end dazz_top_simple_tb;

architecture Behavioral of dazz_top_simple_tb is

   COMPONENT dazz_top
      PORT (
			disp_sel_n  : in  STD_LOGIC;
			brite_sel_n : in  STD_LOGIC;
			uart_data   : in  STD_LOGIC;
			rst_n			: in  STD_LOGIC;
			osc12		   : in  STD_LOGIC;
			pwr_off		: in  STD_LOGIC;
			buf_en		: out STD_LOGIC;
			tx_data     : out STD_LOGIC
      );
   END COMPONENT;
   
	
	signal osc12tb   		: std_logic;
	
	signal disp_sel_n 	: std_logic;
	signal brite_sel_n 	: std_logic;
	signal uart_data 		: std_logic;
	signal rst_n			: std_logic;
	signal osc12 			: std_logic;
	signal pwr_off 			: std_logic;
   signal buf_en     	: std_logic;
   signal tx_data    	: STD_LOGIC;
   

begin

   dazz_top_0 : dazz_top
      PORT MAP (
			disp_sel_n  => disp_sel_n,
			brite_sel_n => brite_sel_n,
			uart_data  	=> uart_data,
			rst_n			=> rst_n,
			osc12  		=> osc12,
			pwr_off  	=> pwr_off,
			buf_en		=> buf_en,
         tx_data     => tx_data
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
	
	osc12 <= osc12tb;
   
	
	dazzlite_test_proc : process 
   begin
      disp_sel_n  <= '1';
		brite_sel_n <= '1';
		uart_data   <= '1';
		rst_n			<= '0';
		pwr_off  	<= '0';
      
		wait for 250 ns;
		rst_n <= '1';
		
		wait for 90 ms; -- wait for init to complete
      
      wait for 100 ms;
      assert false
         report "Star LED Lites Simple Simulation Done " & cr
         severity failure;
      wait;
   end process;


end Behavioral;
