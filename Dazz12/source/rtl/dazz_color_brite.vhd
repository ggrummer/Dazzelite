------------------------------------------------------------------------
-- Create Date: 04/8/2020 
-- Module Name: dazz_color_brite - rtl
-- By: Grant Grummer
-- 
-- Description: Math for converting the GE LED Lites protocol to 
--    neopixel protocol.
--    
--    1) Multiply brightness (8 bits) times color (4 bits) = 12 bits
--		2) Divide by 16 to get 8 bit result
--    Need to do this for each of the 3 colors.
-- 
-- Revision: 0.0
-- Revision: 0.1 added brignteness control to dazz_color.vhd
-- 
-----------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity dazz_color_brite is
   Port ( 
      clk8        : in STD_LOGIC;
      reset8      : in STD_LOGIC;
      frame_start : in STD_LOGIC;
      frame_data  : in STD_LOGIC_VECTOR (25 downto 0);
		brite_sel   : in STD_LOGIC_VECTOR (1 downto 0);
      neo_start   : out STD_LOGIC;
      neo_data    : out STD_LOGIC_VECTOR (23 downto 0));
end dazz_color_brite;


architecture rtl of dazz_color_brite is


   COMPONENT mult8x8
      PORT (
			clk  : IN STD_LOGIC;
			ce	  : IN STD_LOGIC;
			a_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			b_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			prod : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
   END COMPONENT;
   
   
   type startsm_type is (INIT,MULTEN,INC,DONE);
   
   signal startsm      	: startsm_type;
   
   signal input_green 	: std_logic_vector (7 downto 0);
   signal input_red     : std_logic_vector (7 downto 0);
   signal input_blue    : std_logic_vector (7 downto 0);
	
	signal mult_green 	: std_logic_vector (15 downto 0);
   signal mult_red     	: std_logic_vector (15 downto 0);
   signal mult_blue    	: std_logic_vector (15 downto 0);
   
   signal neo_green    	: std_logic_vector (11 downto 0);
   signal neo_red      	: std_logic_vector (11 downto 0);
   signal neo_blue     	: std_logic_vector (11 downto 0);
	
	signal briteness		: std_logic_vector (7 downto 0);
	
	signal start_dly		: std_logic;
   
   
begin


   briteness <= frame_data (19 downto 12) when brite_sel = "00"
		else '0' & frame_data (19 downto 13) when brite_sel = "01"
		else "00" & frame_data (19 downto 14) when brite_sel = "10"
		else frame_data (18 downto 12) & '0' when (brite_sel = "11" and frame_data (19) = '0')
		else x"FF" when (brite_sel = "11" and frame_data (19) = '1');
	
	
	input_green	<= x"0" & frame_data (7 downto 4);
	input_red	<= x"0" & frame_data (3 downto 0);
	input_blue	<= x"0" & frame_data (11 downto 8);
	
	
	-- multiply brightness times each color
	mult_green_0 : mult8x8
      PORT MAP (
         clk  => clk8,
         a_in => briteness,
         b_in => input_green,
         ce   => frame_start,
         prod => mult_green
      );
   
   mult_red_0 : mult8x8
      PORT MAP (
         clk  => clk8,
         a_in => briteness,
         b_in => input_red,
         ce   => frame_start,
         prod => mult_red
      );
   
   mult_blue_0 : mult8x8
      PORT MAP (
         clk  => clk8,
         a_in => briteness,
         b_in => input_blue,
         ce   => frame_start,
         prod => mult_blue
      );
   
   
   -- remove the upper 4 bits because they're all zero
	neo_green <= mult_green(11 downto 0);
	neo_red	 <= mult_red(11 downto 0);
	neo_blue	 <= mult_blue(11 downto 0);
      
   
   -- create a start signal
   -- allow for multiply register latency
   start_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         start_dly <= '0';
			neo_start <= '0';
      elsif rising_edge(clk8) then
         start_dly <= frame_start;
			neo_start <= start_dly;
		end if;
   end process;
   
   
   -- divide by 16
	-- data byte order, of the lites, is selected here
   neo_data <= neo_green(11 DOWNTO 4) & neo_red(11 DOWNTO 4) & neo_blue(11 DOWNTO 4)
      when TYPE_OF_LITE > 1 
      else  neo_red(11 DOWNTO 4) & neo_green(11 DOWNTO 4) & neo_blue(11 DOWNTO 4);
   
   
end rtl;