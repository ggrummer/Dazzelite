----------------------------------------------------------------------------------
-- Create Date: 04/06/2013 10:12:49 PM
-- Module Name: pause - rtl
-- 
-- Description: creates a simple delay of up to 255 times 5.12 mSeconds
-- 
-- Revision 0.01 - File Created
-- Revision 0.02 - A command data of zero delay now produces a random delay
-- Revision 0.03 - Shortened duration of random delay (see cnt_main)
-- Revision 0.04 - Changed to a synchronous reset
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- library UNISIM;
-- use UNISIM.VComponents.all;


entity pause is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           ce1         : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           pause_done  : out STD_LOGIC);
end pause;


architecture rtl of pause is

   type pausesm_type is (INIT,DELAY,START,DONE);
   
   signal pausesm      : pausesm_type;
   signal cnt5en       : STD_LOGIC;
   signal cnt5done     : STD_LOGIC;
   signal cnt5ms       : STD_LOGIC_VECTOR (8 downto 0);
   signal cnt_main     : STD_LOGIC_VECTOR (7 downto 0);
   signal calc_randnum : STD_LOGIC;
   signal feedback     : STD_LOGIC;
   signal random       : STD_LOGIC_VECTOR (11 downto 0);


begin
   
   
   -- use delay from command instruction to determine how many times the 
   -- 5 ms delay should be run
   pause_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				cnt_main   <= x"00";
				pause_done <= '0'; 
				cnt5en     <= '0';
				calc_randnum <= '0';
				pausesm    <= INIT;
			else
				case pausesm is
				when INIT =>
					pause_done <= '0';
					if cmd_inst = x"1" then
						pausesm <= DELAY;
						if (cmd_data(27 downto 20) =x"00") then
							cnt_main     <= "00" & random(5 downto 0);
							calc_randnum <= '1';
						else
							cnt_main <= cmd_data(27 downto 20);
							-- cnt_main <= x"01"; -- for simulation only!
						end if;
					end if;
				when DELAY =>
					calc_randnum <= '0';
					if cnt_main = x"00" then
						pausesm <= DONE; -- exit pause
					elsif cnt5done = '0' then
						cnt5en <= '1';
					else
						cnt5en  <= '0';
						pausesm <= START;
					end if;
				when START =>
					cnt_main <= cnt_main - '1';
					pausesm  <= DELAY; -- loop
				when DONE => 
					pause_done <= '1';
					pausesm <= INIT;
				when others => 
					pausesm <= INIT;
				end case;
			end if;
		end if;
   end process;
   
   
   -- multiply 100 kHz by 512 to get a 5 msec delay
   count5ms_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				cnt5ms   <= "000000000";
				cnt5done <= '0'; 
			else
				cnt5done <= '0';
				if ce1 = '1' then
					if cnt5en = '1' then
	--               if cnt5ms = "000001111" then -- simulation only
						if cnt5ms = "111111111" then
							cnt5ms   <= "000000000";
							cnt5done <= '1';
						else
							cnt5ms <= cnt5ms + '1';
						end if;
					end if;
				end if;
			end if;
		end if;
   end process;
   
   
   feedback <= random(10) xnor random(9);
   -- random number generator
   random_num_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				random <= x"563"; -- can't have an all zero state
			else
				if (calc_randnum = '1') then
					-- shift in left the XNOR result
					random <= random(10 downto 0) & feedback;
				end if;
			end if;
		end if;
   end process;
   
   
end rtl;