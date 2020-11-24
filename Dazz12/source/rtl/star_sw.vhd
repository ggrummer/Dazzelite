----------------------------------------------------------------------
-- Create Date: 04/16/2020
-- Module Name: star_sw - rtl
-- By: Grant Grummer
-- 
-- Description: use pushbutton switch signal to select different
-- 	display patterns
-- 
-- Revision: 0.0
-- 
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity star_sw is
   Port ( 
		clk8        : in STD_LOGIC;
		ce1         : in STD_LOGIC;
		reset8      : in STD_LOGIC;
		psh_butt    : in STD_LOGIC;
		disp_addr   : out STD_LOGIC_VECTOR (1 downto 0);
		chng_disp   : out STD_LOGIC
	);
end star_sw;


architecture rtl of star_sw is
   
   type mainsm_type is (INIT,S_HI,S_CHNG,S_LO);
   
   signal mainsm 		: mainsm_type;
	signal cnt_en  	: std_logic;
   signal addr   		: std_logic_vector (1 downto 0);
	signal done_cnt  	: std_logic;
	signal low_cnt		: std_logic_vector (14 downto 0);
   
   
begin
   
   
   disp_addr <= addr;
	
	
	-- this is the control for the deglitcher
   main_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				cnt_en    <= '0'; 
				chng_disp <= '0';
				addr		 <= "00";
				mainsm    <= INIT;
			else
				case mainsm is
				when INIT =>
					cnt_en    <= '0'; 
					chng_disp <= '0';
					if (psh_butt = '1') then
						mainsm <= S_HI;
					end if;
				when S_HI =>
					if (psh_butt = '1') then
						mainsm <= S_CHNG;
					else
						mainsm <= INIT;
					end if;
				when S_CHNG =>
					if (addr = "11") then
						addr <= "00";
					else
						addr <= addr + '1';
					end if;
					chng_disp <= '1';
					mainsm    <= S_LO;
				when S_LO => 
					if (done_cnt = '1') then
						mainsm <= INIT;
					end if;
					cnt_en <= '1'; 
				when others => 
					mainsm <= INIT;
				end case;
			end if;
		end if;
   end process;
	
	
	-- this is the main deglitcher counter
	-- the pushbutton switch signal must remain low for 2^14*10us=164ms
   cnt_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				low_cnt   <= (others => '0'); 
				done_cnt  <= '0';
			else
				
				if (cnt_en = '1' and psh_butt = '0') then
					if (ce1 = '1')then
						low_cnt <= low_cnt + '1';
					end if;
				else
					low_cnt <= (others => '0');
				end if;
				
				if (low_cnt(14) = '1') then
					done_cnt <= '1';
				else
					done_cnt <= '0';
				end if;
				
			end if;
		end if;
	end process;
			
		
end rtl;		