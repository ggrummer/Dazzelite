----------------------------------------------------------------------
-- Create Date: 01/15/2020 
-- Module Name: rainbow - rtl
-- By: Grant Grummer
-- 
-- Description: replaces the LED color, in the set_lites module,  
--    with the color value created in this module. A rainbow 
--    pattern is the result. 
-- 
-- Revision 0.0 - File Created
-- 
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;


entity rainbow is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           prog_busy   : in STD_LOGIC;
           rbow_en     : out STD_LOGIC;
           rbow_data   : out STD_LOGIC_VECTOR (11 downto 0);
           rbow_done   : out STD_LOGIC);
end rainbow;


architecture rtl of rainbow is

   type rbowsm_type is (INIT,START,DONE);
   
   signal rbowsm    : rbowsm_type;
   signal cnt_on    : STD_LOGIC;
   signal cnt_en    : STD_LOGIC;
   signal main_en   : STD_LOGIC;
	
   constant cnt_max   : STD_LOGIC_VECTOR (3 downto 0) := x"E";
   constant cnt_min   : STD_LOGIC_VECTOR (3 downto 0) := x"1";
	
	signal red_en		: STD_LOGIC;
	signal grn_en		: STD_LOGIC;
	signal blu_en		: STD_LOGIC;
	signal red_en_lat : STD_LOGIC;
	signal grn_en_lat : STD_LOGIC;
	signal blu_en_lat : STD_LOGIC;
	signal red_cnt_up	: STD_LOGIC;
	signal grn_cnt_up	: STD_LOGIC;
	signal blu_cnt_up	: STD_LOGIC;
	signal red_cnt		: STD_LOGIC_VECTOR (3 downto 0);
	signal grn_cnt		: STD_LOGIC_VECTOR (3 downto 0);
	signal blu_cnt		: STD_LOGIC_VECTOR (3 downto 0);


begin

   
   rbow_en   <= main_en;
   rbow_data <= blu_cnt & grn_cnt & red_cnt;
   
   
   rbow_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         cnt_en    <= '0';
         main_en   <= '0';
         cnt_on    <= '0';
         rbow_done <= '0'; 
         rbowsm    <= INIT;
      elsif rising_edge(clk8) then
         case rbowsm is
         when INIT =>
            rbow_done <= '0';
            cnt_on    <= cmd_data(12);
            if (cmd_inst = x"B") then
               rbowsm <= START;
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
            rbowsm <= DONE;
         when DONE => 
            cnt_en    <= '0';
            rbow_done <= '1';
            rbowsm    <= INIT;
         when others => 
            rbowsm <= INIT;
         end case;
      end if;
   end process;
   
   
	-- red counter
	red_count_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         red_cnt  	<= x"F";
			red_cnt_up	<= '0';
			red_en_lat	<= '1';
			grn_en		<= '1';
		elsif rising_edge(clk8) then
         if (main_en = '0' or prog_busy = '1') then
				red_cnt  	<= x"F";
				red_cnt_up	<= '0';
				red_en_lat	<= '1';
				grn_en		<= '1';
			elsif (cnt_en = '1' and (red_en = '1' or red_en_lat = '1')) then
			
				if (red_cnt >= cnt_max) then
               red_cnt_up <= '0';
            elsif (red_cnt <= cnt_min) then
               red_cnt_up <= '1';
            end if;
            
            if (red_cnt_up = '1') then
               red_cnt <= red_cnt + '1';
            else
               red_cnt <= red_cnt - '1';
            end if;
				
				if (red_en = '1') then
					red_en_lat <= '1';
				elsif (red_cnt = x"1" and red_cnt_up = '0') then
					red_en_lat <= '0';
				end if;
				
				if (red_cnt = cnt_max and red_cnt_up = '1') then
					grn_en <= '1';
				else
					grn_en <= '0';
				end if;
				
			end if; 
      end if;
   end process;
	
	
	-- green counter
	green_count_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         grn_cnt  	<= x"0";
			grn_cnt_up	<= '1';
			grn_en_lat	<= '0';
			blu_en		<= '0';
		elsif rising_edge(clk8) then
         if (main_en = '0' or prog_busy = '1') then
				grn_cnt  	<= x"0";
				grn_cnt_up	<= '1';
				grn_en_lat	<= '0';
				blu_en		<= '0';
			elsif (cnt_en = '1' and (grn_en = '1' or grn_en_lat = '1')) then
			
				if (grn_cnt >= cnt_max) then
               grn_cnt_up <= '0';
            elsif (grn_cnt <= cnt_min) then
               grn_cnt_up <= '1';
            end if;
            
            if (grn_cnt_up = '1') then
               grn_cnt <= grn_cnt + '1';
            else
               grn_cnt <= grn_cnt - '1';
            end if;
				
				if (grn_en = '1') then
					grn_en_lat <= '1';
				elsif (grn_cnt = x"1" and grn_cnt_up = '0') then
					grn_en_lat <= '0';
				end if;
				
				if (grn_cnt = cnt_max and grn_cnt_up = '1') then
					blu_en <= '1';
				else
					blu_en <= '0';
				end if;
				
			end if; 
      end if;
   end process;
	
	
	-- blue counter
	blue_count_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         blu_cnt  	<= x"0";
			blu_cnt_up	<= '1';
			blu_en_lat	<= '0';
			red_en		<= '0';
		elsif rising_edge(clk8) then
         if (main_en = '0' or prog_busy = '1') then
				blu_cnt  	<= x"0";
				blu_cnt_up	<= '1';
				blu_en_lat	<= '0';
				red_en		<= '0';
			elsif (cnt_en = '1' and (blu_en = '1' or blu_en_lat = '1')) then
			
				if (blu_cnt >= cnt_max) then
               blu_cnt_up <= '0';
            elsif (blu_cnt <= cnt_min) then
               blu_cnt_up <= '1';
            end if;
            
            if (blu_cnt_up = '1') then
               blu_cnt <= blu_cnt + '1';
            else
               blu_cnt <= blu_cnt - '1';
            end if;
				
				if (blu_en = '1') then
					blu_en_lat <= '1';
				elsif (blu_cnt = x"1" and blu_cnt_up = '0') then
					blu_en_lat <= '0';
				end if;
				
				if (blu_cnt = cnt_max and blu_cnt_up = '1') then
					red_en <= '1';
				else
					red_en <= '0';
				end if;
				
			end if; 
      end if;
   end process;
   
   
end rtl;