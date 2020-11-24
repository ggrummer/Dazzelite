----------------------------------------------------------------------------------
-- Create Date: 10/2/2015 08:46:52 AM
-- Module Name: lites_pkg - package
-- By: Grant Grummer
-- 
-- Description: Collection of constants for all lites designs. Not all constants
--		are used in all designs.
-- 
-- Revision: 0.0
-- Revision: 0.1 added support for SK6812 LEDs
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

package lites_pkg is
   
   
	-- Change the following constants to match the design being implemented
	
		-- Set NUM_OF_LITES to the total number of lites in a string/ring/matrix 
		constant NUM_OF_LITES : integer range 1 to 64 := 24;
		
		-- Constant used to shift the starting point of the bottom lite
		--     clockwise from the real zero lite
		constant SHIFTBY      : integer range 0 to 63 := 0;
		
		-- Choose the type of lite used: WS2811 vs. WS2812 or WS2812B vs. SK6812
		-- Set to 1 for WS2811 or 2 for WS2812 or WS2812B or 3 for WS2812 or SK6812
		constant TYPE_OF_LITE : integer range 0 to 3 := 3;
		
		-- Set NUM_OF_POINTS to the total number of points in a star configuration
		constant NUM_OF_POINTS : integer range 1 to 20 := 1;
		
		-- choose physical method for changing the display
		-- 0 for dip switch, 1 for push button select
		constant PB_SEL   : std_logic := '1'; 
		
		-- access the same commands a second time when lights are double sided
		-- 0 for single sided, 1 for double sided
		constant DUBSIDED	: std_logic := '0'; 
		
		
	-- Derived constants, don't change them
		
		-- Constants used to set total number of lites in design
		constant TOTAL_LITES  : std_logic_vector (7 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(NUM_OF_LITES, 8);
		constant TOTAL_MINUS1 : std_logic_vector (7 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(NUM_OF_LITES - 1, 8);
		
		-- Constants used to set location of starting lite in design
		constant SFTBYNUM : std_logic_vector (7 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(SHIFTBY, 8);
		constant SFTBYMAX : std_logic_vector (7 DOWNTO 0) := TOTAL_LITES - SFTBYNUM;
		
		-- constants used to shift the starting point of the bottom lite
		--     clockwise from the real zero lite
		-- NUM_OF_LITES is too dam big for a 6 bit SLV!
		constant ADDRCALC     : integer range 0 to 63 := NUM_OF_LITES - SHIFTBY;
		constant ADDR2BIG     : std_logic_vector (5 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(ADDRCALC, 6);
		
   
end lites_pkg;