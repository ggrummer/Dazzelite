----------------------------------------------------------------------
-- Create Date: 09/8/2014 08:46:52 PM
-- Module Name: neo_ctrl - rtl
-- By: Grant Grummer
-- 
-- Description: handshake with main lites control and
--    handshake with neopixel framer
-- 
-- Revision: 0.0
-- Revision: 0.1 obsolete
-- Revision: 0.2 changed to a synchronous reset
-- Revision: 0.3 added a simple sync for fm_busy
-- 
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity neo_ctrl is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           frame_start : in STD_LOGIC;
           fm_busy     : in STD_LOGIC;
           neo_busy    : out STD_LOGIC;
           fm_go       : out STD_LOGIC);
end neo_ctrl;


architecture rtl of neo_ctrl is
   
   type ctrlsm_type is (INIT,START,BUSY,DONE);
   
   signal ctrlsm     	: ctrlsm_type;
   signal fm_busy_sync	: STD_LOGIC;
	
   
begin
   
   
   -- simple sync of fm_busy
	fm_sync_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				fm_busy_sync <= '0'; 
			else
				fm_busy_sync <= fm_busy;
			end if;
		end if;
   end process;
	
	
	-- implement handshakes
   ctrl_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				fm_go    <= '0'; 
				neo_busy <= '0';
				ctrlsm   <= INIT;
			else
				case ctrlsm is
				when INIT =>
					fm_go    <= '0'; 
					neo_busy <= '0';
					if (frame_start = '1') then
						ctrlsm <= START;
					end if;
				when START =>
					fm_go    <= '1'; 
					neo_busy <= '1';
					ctrlsm   <= BUSY;
				when BUSY =>
					fm_go  <= '0';
					if (fm_busy_sync = '1') then
						ctrlsm <= DONE;
					end if;
				when DONE => 
					if (fm_busy_sync = '0') then
						ctrlsm <= INIT;
					end if;
				when others => 
					ctrlsm <= INIT;
				end case;
			end if;
		end if;
   end process;
   
   
end rtl;