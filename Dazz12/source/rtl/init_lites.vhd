----------------------------------------------------------------------------
-- Create Date: 04/06/2013 10:26:46 PM
-- Module Name: control - rtl
-- By: Grant Grummer
--  
-- Description: provide each lite with an address in old GE lites.  Also
--    used to blank out all the lites.
-- 
-- Revision 0.1 - File Created
-- Revision 0.2 - Added max number of lites input
-- Revision 0.3 - Changed to a synchronous reset
-- 
----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity init_lites is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           frame_busy  : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           sizeplus1   : in STD_LOGIC_VECTOR (7 downto 0);
           init_done   : out STD_LOGIC;
           init_data   : out STD_LOGIC_VECTOR (25 downto 0);
           init_go     : out STD_LOGIC);
end init_lites;

architecture rtl of init_lites is

   type initsm_type is (INITINIT,STARTINIT,LOOPINIT,INCINIT,DONEINIT,ENDINIT);
   
   constant ZEROS   : std_logic_vector (19 DOWNTO 0) := (others => '0');
   
   signal initsm    : initsm_type;
   signal low_addr  : std_logic_vector (5 DOWNTO 0);


begin

   init_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				init_done <= '0';
				init_data <= (others => '0');
				init_go   <= '0'; 
				low_addr  <= (others => '0');
				initsm    <= INITINIT;
			else
				case initsm is
				when INITINIT =>
					init_done <= '0';
					init_data <= (others => '0');
					init_go   <= '0'; 
					low_addr  <= (others => '0');
					initsm <= STARTINIT;  -- start right after reset
				when STARTINIT =>
					init_data <= low_addr & ZEROS;
					init_go   <= '1';
					if frame_busy = '1' then
						initsm <= LOOPINIT;
					end if;
				when LOOPINIT =>
					init_go  <= '0';
					-- test for max address
					if (frame_busy = '0' and low_addr = sizeplus1(5 downto 0)) then
						initsm <= DONEINIT;
					elsif frame_busy = '0' then -- address < max
						initsm <= INCINIT;
					end if;
				when INCINIT =>
					low_addr <= low_addr + '1';
					initsm   <= STARTINIT;
				when DONEINIT =>
					init_done <= '1';
					initsm    <= ENDINIT;
				when ENDINIT => -- stay here until reset or reinitialize command
					init_done <= '0';
					init_data <= (others => '0');
					init_go   <= '0'; 
					low_addr  <= (others => '0');
					if (cmd_inst = x"0") then -- reinitialize
						initsm <= INITINIT;
					end if;
				when others => 
					initsm <= INITINIT;
				end case;
			end if;
      end if;
   end process;

end rtl;
