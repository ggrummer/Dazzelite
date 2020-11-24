----------------------------------------------------------------------
-- Create Date: 04/06/2013 10:12:49 PM
-- Module Name: fade - rtl
-- By: Grant Grummer
-- 
-- Description: replaces the LED brightness, in the set_lites module,  
--    with the brightness value created in this module. A fade in and
--    out pattern is the result. 
-- 
-- Revision 0.01 - File Created
-- Revision 0.02 - Added fading signal which is asserted when fade 
--    count is not 0
-- Revision 0.3 - Added a way to speed up fading by counting in bigger
--    increments
-- Revision 0.4 - Added a lower limit to the main counter
-- Revision 0.5 - Added an upper count limit
--
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;


entity fade is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           prog_busy   : in STD_LOGIC;
           fading      : out STD_LOGIC;
           fade_en     : out STD_LOGIC;
           fade_data   : out STD_LOGIC_VECTOR (7 downto 0);
           fade_done   : out STD_LOGIC);
end fade;


architecture rtl of fade is

   type fadesm_type is (INIT,START,DONE);
   
   signal fadesm    : fadesm_type;
   signal cnt_on    : STD_LOGIC;
   signal cnt_up    : STD_LOGIC;
	signal cnt_updly : STD_LOGIC;
   signal cnt_en    : STD_LOGIC;
	signal cnt_dly   : STD_LOGIC;
   signal main_en   : STD_LOGIC;
   signal count     : STD_LOGIC_VECTOR (7 downto 0);
   signal cnt_by    : STD_LOGIC_VECTOR (1 downto 0);
	signal cnt_lolim : STD_LOGIC_VECTOR (1 downto 0);
	signal cnt_uplim : STD_LOGIC_VECTOR (1 downto 0);
   signal incr2     : STD_LOGIC_VECTOR (7 downto 0);
	signal loestlim  : STD_LOGIC_VECTOR (7 downto 0);
	signal lolim     : STD_LOGIC_VECTOR (7 downto 0);
	signal uplim	  : STD_LOGIC_VECTOR (7 downto 0);
   signal cnt_max   : STD_LOGIC_VECTOR (7 downto 0);
   signal cnt_min   : STD_LOGIC_VECTOR (7 downto 0);


begin

   
   fade_en   <= main_en;
   fade_data <= count;
   
   
   fade_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         cnt_en    <= '0';
         main_en   <= '0';
         cnt_on    <= '0';
         fade_done <= '0'; 
         fadesm    <= INIT;
         cnt_by    <= "00";
			cnt_uplim <= "00";
			cnt_lolim <= "00";
      elsif rising_edge(clk8) then
         case fadesm is
         when INIT =>
            fade_done <= '0';
            cnt_on    <= cmd_data(12); -- was cmd_data(0)
            cnt_by    <= cmd_data(21 downto 20);
				cnt_uplim <= cmd_data(23 downto 22);
				cnt_lolim <= cmd_data(25 downto 24);
            if (cmd_inst = x"7") then
               fadesm <= START;
            end if;
            if (prog_busy = '1') then
               main_en <= '0';
            end if;
         when START =>
            if (cnt_on = '1') then
               main_en <= '1';
            else
               main_en <= '0';
            end if;
            cnt_en <= '1';
            fadesm <= DONE;
         when DONE => 
            cnt_en    <= '0';
            fade_done <= '1';
            fadesm    <= INIT;
         when others => 
            fadesm <= INIT;
         end case;
      end if;
   end process;
   
   
   -- up/down counter with a count limit of 192
   count_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         count  	 <= x"00";
         cnt_up 	 <= '1';
			cnt_updly <= '1';
      elsif rising_edge(clk8) then
         cnt_updly <= cnt_up;
			if (main_en = '0' or prog_busy = '1' or (incr2 /= cnt_min)) then
            count  <= x"00";
            cnt_up <= '1';
         elsif (cnt_en = '1') then
            
            -- cnt_max for Synthesis, 0B for simulation
            if (count >= cnt_max) then
               cnt_up <= '0';
            elsif (count <= cnt_min or count <= lolim) then 
               cnt_up <= '1';
            end if;
            
            if (cnt_up = '1') then
               count <= count + incr2;
            else
               count <= count - incr2;
            end if;
            
         end if; 
      end if;
   end process;
   
   
   -- assert signal when count is not at it's lower limit
   zero_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         fading <= '0';
      elsif rising_edge(clk8) then
         if (main_en = '0' or prog_busy = '1' or count = loestlim or 
			--if (main_en = '0' or prog_busy = '1' or count = x"00" or 
			(cnt_updly = '0' and cnt_up = '1')) then
            fading <= '0';
         else
            fading <= '1';
         end if;
      end if;
   end process;
   
   
   -- create an upper count limit
   upper_limit_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         uplim <= x"C0";
      elsif rising_edge(clk8) then
         if (cnt_en = '1') then
            case cnt_uplim is
            when "00" =>
               uplim <= x"C0";
            when "01" =>
               uplim <= x"80";
            when "10" =>
               uplim <= x"60";
            when "11" =>
               uplim <= x"40";
            when others => 
               uplim <= x"C0";
            end case;
         end if;
      end if;
   end process;
	
	
	-- speed up fading by counting in bigger increments
   pow_of_2_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         incr2   <= x"01";
         cnt_max <= x"BF";
         cnt_min <= x"01";
      elsif rising_edge(clk8) then
         if (cnt_en = '1') then
            
            -- computes power of 2 up to a limit of 64
            case cnt_by is
            when "00" =>
               incr2 <= x"01";
            when "01" =>
               incr2 <= x"02";
            when "10" =>
               incr2 <= x"04";
            when "11" =>
               incr2 <= x"08";
            when others => 
               incr2 <= x"01";
            end case;
            
            -- computes maximum count and minimum count
            -- don't need cnt_max right a way so its OK to take a few
            -- cnt_en
            cnt_max <= uplim - incr2; 
            -- must zero count when incr2 changes
            cnt_min <= incr2;
            
         end if;
      end if;
   end process;
	
	
	-- create a lower limit for the main counter
   lower_limit_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         lolim 	<= x"01";
			loestlim <= x"00";
      elsif rising_edge(clk8) then
			cnt_dly <= cnt_en;
			if (cnt_en = '1') then
            case cnt_lolim is
            when "00" =>
               lolim <= x"01";
            when "01" =>
               lolim <= x"04";
            when "10" =>
               lolim <= x"08";
            when "11" =>
               lolim <= x"10";
            when others => 
               lolim <= x"01";
            end case;
         end if;
			if (cnt_dly = '1') then
				loestlim <= lolim - incr2;
			end if;
      end if;
   end process;
   
   
end rtl;