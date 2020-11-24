----------------------------------------------------------------------
-- Create Date: 07/17/2020
-- Module Name: clk48to8s - rtl
--
-- Description: use the internal 48 MHz clock from the PLL to make 
--		an internal 8 MHz clock, 800 kHz clock, 100 kHz clock enable,
--		and a reset
-- 
-- Revision:0.0
-- 
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity clk48to8s is
   Port ( 
      soft_reset	: in STD_LOGIC;  -- command based reset
		pll_48		: in STD_LOGIC;  -- 48 MHz input from PLL
		lock			: in STD_LOGIC;  -- PLL lock signal
      clkfast   	: out STD_LOGIC; -- 8 MHz clock output
      clk8      	: out STD_LOGIC; -- 800 KHz clock output 
      ce1       	: out STD_LOGIC; -- 100 KHz pulse
      reset8    	: out STD_LOGIC  -- internal logic reset
   );
end clk48to8s;


architecture rtl of clk48to8s is
	
	
	constant RSTMAX	: std_logic_vector (3 DOWNTO 0) := x"d"; -- count to 13
	constant C800MAX	: std_logic_vector (4 DOWNTO 0) := "11101"; -- count to 29
	constant PLSMAX	: std_logic_vector (2 DOWNTO 0) := "111"; -- count to 7
	
	signal ringreg1	: std_logic := '0';
	signal ringreg2	: std_logic := '0';
	signal ringreg3	: std_logic := '0';
	signal clkfastint	: std_logic := '0';
	signal clk8int   	: std_logic;
   signal clkcnt    	: std_logic_vector (4 DOWNTO 0) := "00000";
	signal ce1cnt    	: std_logic_vector (2 DOWNTO 0) := "000";
   signal resetint  	: std_logic := '1';
	signal reset8int  : std_logic := '1';
   signal resetcnt  	: std_logic_vector (3 DOWNTO 0) := x"0";
   signal reset8cnt 	: std_logic_vector (3 DOWNTO 0) := x"0";
    
    
begin
	
	
	clkfast 		<= ringreg3;
	clk8			<= clk8int;
	reset8		<= reset8int;
   
	
	-- make an 8 MHz clock
	clkfast_proc : process (lock, pll_48)
	begin
		if rising_edge(pll_48) then
			if (lock = '0') then
				ringreg1 <= '0';
				ringreg2 <= '0';
				ringreg3 <= '0';
			else
				ringreg1 <= not ringreg3;
				ringreg2 <= ringreg1;
				ringreg3 <= ringreg2;
			end if;
		end if;
	end process;
	
	
	-- make an 800 kHz clock
   clk8_proc : process (lock, pll_48)
   begin
      if rising_edge(pll_48) then
			if (lock = '0') then
				clkcnt  <= "00000";
				clk8int <= '0';
			else
				clkcnt <= clkcnt + 1;
				if (clkcnt = C800MAX) then
					clk8int <= not clk8int;
					clkcnt  <= "00000";
				end if;
			end if;
      end if;
   end process;
            

   -- make a reset to go with the 800 kHz clock
   reset8_proc : process (lock, clk8int)
   begin
      if rising_edge(clk8int) then
			if (lock = '0') then
				reset8cnt <= "0000";
				reset8int <= '1';
			else
				if soft_reset = '1' then
					reset8cnt <= "0000";
					reset8int <= '1';
				elsif (reset8cnt = RSTMAX) then
					reset8int <= '0'; -- stay here until the next reset
				else
					reset8int <= '1';
					reset8cnt <= reset8cnt + '1';
				end if;
			end if;
		end if;
    end process;
	 
	 
	 -- make a 100 kHz clock enable pulse
	clock_enable_proc : process (lock, clk8int)
	begin
		if rising_edge(clk8int) then
			if (lock = '0') then
				ce1cnt <= "000";
				ce1    <= '0';
			else
				ce1cnt <= ce1cnt + '1';
				if ce1cnt = PLSMAX then
						 ce1 <= '1';
					else
						 ce1 <= '0';
					end if;
			end if;
		end if;
    end process;


end rtl;
