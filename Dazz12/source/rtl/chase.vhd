----------------------------------------------------------------------
-- Create Date: 04/06/2013 10:12:49 PM
-- Module Name: chase - rtl
-- By: Grant Grummer
-- 
-- Description: changes an address offset in set_lites module, which
--    is used to create a chase pattern. 
-- 
-- Revision 0.01 - File Created
-- Revision 0.02 - Added fading signal which halts count when asserted
-- Revision 0.03 - Added support for changing the number of lites used
-- Revision 0.04 - Changed getting the number of lites from a command
--    to a package
-- Revision 0.05 - Changed to a synchronous reset
-- Revision 0.06 - Added a configurable step size
-- 
----------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity chase is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           prog_busy   : in STD_LOGIC;
           fading      : in STD_LOGIC;
           offset      : out STD_LOGIC_VECTOR (5 downto 0);
           neo_size    : out STD_LOGIC_VECTOR (7 downto 0);
           sizeplus1   : out STD_LOGIC_VECTOR (7 downto 0);
           chase_done  : out STD_LOGIC);
end chase;


architecture rtl of chase is

   
   type chasesm_type is (INIT,JUMP,START,DONE);
   
   signal chasesm    : chasesm_type;
   signal cnt_up     : STD_LOGIC;
   signal cnt_clear  : STD_LOGIC;
   signal cnt_en     : STD_LOGIC;
   signal jump_en    : STD_LOGIC;
	signal ch_done    : STD_LOGIC;
   signal count      : STD_LOGIC_VECTOR (7 downto 0);
	signal step       : STD_LOGIC_VECTOR (7 downto 0);
	signal size       : STD_LOGIC_VECTOR (7 downto 0);
	signal leap       : STD_LOGIC_VECTOR (7 downto 0);


begin

   
   -- offset presently limited to 64 lites, 
   -- can be 256 max with lots of system changes
   offset    <= count(5 downto 0);
   
   -- provide number of lites info to neopixel framer, set_lites
   sizeplus1 <= TOTAL_LITES;
   neo_size  <= TOTAL_MINUS1; 
   
   chase_done <= ch_done;
   
   
   chase_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				jump_en	  <= '0';
				cnt_en     <= '0';
				ch_done    <= '0'; 
				cnt_up     <= '1';
				cnt_clear  <= '1';
				chasesm    <= INIT;
			else
				case chasesm is
				when INIT =>
					ch_done   <= '0';
					cnt_up    <= cmd_data(12); 
					cnt_clear <= cmd_data(13);
					step		 <= cmd_data(27 downto 20);
					if cmd_inst = x"5" then
						chasesm <= JUMP;
					end if;
				when JUMP =>
					jump_en <= '1';
					chasesm <= START;
				when START =>
					jump_en <= '0';
					cnt_en  <= '1';
					chasesm <= DONE;
				when DONE => 
					cnt_en  <= '0';
					ch_done <= '1';
					chasesm <= INIT;
				when others => 
					chasesm <= INIT;
				end case;
			end if;
      end if;
   end process;
   
   
   -- calculate jump size
	jump_proc : process (reset8, prog_busy, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1' or prog_busy = '1') then
				size <= x"00";
				leap <= x"00";
			else
				if (jump_en = '1') then
					if (step = x"00") then 
						-- backwards compatable to rev 0.05
						size <= x"01";
						leap <= count + '1'; 
					else
						size <= step;
						leap <= count + step;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	
	-- up/down counter
   count_proc : process (reset8, prog_busy, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1' or prog_busy = '1') then
				count <= x"00";
			else
				if cnt_en = '1' then
					if cnt_clear = '1' then
						count <= x"00";
					elsif fading = '1' then
						-- don't change count while fade is active
						count <= count; 
					elsif cnt_up = '1' then
						if (leap > TOTAL_MINUS1) then
							count <= leap - TOTAL_LITES;
						else
							count <= leap;
						end if;
					else
						if (count >= size) then
							count <= count - size;
						else
							count <= TOTAL_LITES - leap;
						end if;
					end if;
				end if;
			end if;
      end if;
   end process;
   
   
end rtl;