----------------------------------------------------------------------------------
-- Create Date: 03/19/2019 10:26:46 PM
-- Module Name: dazz_ctrl - rtl
-- By: Grant Grummer
--  
-- Description: main routine controller
-- 
-- Revision 0.0
-- 
----------------------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity dazz_ctrl is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           shared_done : in STD_LOGIC;
           prog_req    : in STD_LOGIC;
           prog_ack    : out STD_LOGIC;
           prog_addr   : in STD_LOGIC_VECTOR (9 downto 0);
           prog_word   : in STD_LOGIC_VECTOR (31 downto 0);
           prog_wr     : in STD_LOGIC;
           prog_busy   : in STD_LOGIC;
           blackout    : in STD_LOGIC;
           reload      : in STD_LOGIC;
           sw          : in STD_LOGIC_VECTOR (3 downto 0);
           disp_addr   : in STD_LOGIC_VECTOR (1 downto 0);
           chng_disp   : in STD_LOGIC;
           cmd_inst    : out STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : out STD_LOGIC_VECTOR (27 downto 0);
           led         : out STD_LOGIC_VECTOR (3 downto 0));
end dazz_ctrl;


architecture rtl of dazz_ctrl is
	
	
	component instr_ram_sect_ip
		port (
			reset8	: IN  STD_LOGIC;
			rclk  	: IN  STD_LOGIC;
			ren   	: IN  STD_LOGIC;
			raddr 	: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			rdata 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			wclk  	: IN  STD_LOGIC;
			wen   	: IN  STD_LOGIC;
			waddr 	: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			wdata 	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;
   
   
   -- dp ram signals
   signal dpr_en     : std_logic;
   signal dpr_addr   : std_logic_vector (9 DOWNTO 0);
	signal dpr_data   : std_logic_vector (31 DOWNTO 0);
   
   -- latch signals
   signal black_lat  : std_logic;
   signal black_clr  : std_logic;
   signal reload_lat : std_logic;
   signal reload_clr : std_logic;
   
   -- dazz_ctrl state machine signals
   type ctrlsm_type is (INITCTRL,ACKCTRL,BUSYCTRL,LOADCTRL,STARTCTRL,
      SENDCTRL,WAITCTRL,LOOPCTRL,LOOPCALC,ENDLOOP,INCCTRL,ENDCTRL,RECLRCTRL,
      BLKCLRCTRL);
   signal ctrlsm     : ctrlsm_type;
   signal low_addr   : std_logic_vector (7 DOWNTO 0);
   signal loop_cnt   : std_logic_vector (7 DOWNTO 0);
   signal num_cmd    : std_logic_vector (7 DOWNTO 0);
   signal num_loop   : std_logic_vector (7 DOWNTO 0);
   signal cmd_int    : STD_LOGIC_VECTOR (3 downto 0);
   -- signal lites_addr : std_logic_vector (9 DOWNTO 0);
   
   -- test for good command signals
   signal cmd_good   : std_logic;
   signal cmd_test   : std_logic;


begin

   
	instr_ram_inst : instr_ram_sect_ip
		port map (
			reset8	=> reset8,
			rclk  	=> clk8,
			ren   	=> dpr_en, 
			raddr 	=> dpr_addr,
			rdata 	=> dpr_data,
			wclk  	=> clk8,
			wen   	=> prog_wr,
			waddr 	=> prog_addr,
			wdata 	=> prog_word
		);
	
	
	led      <= '0' & '0' & '0' & '0';
   
   cmd_inst <= cmd_int;
   
   
   -- latch signals as needed
   latch_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				black_lat  <= '0';
				reload_lat <= '0';
			else
				
				if (blackout = '1') then
					black_lat <= '1';
				elsif (black_clr = '1') then
					black_lat <= '0';
				end if;
				
				if (reload = '1' or chng_disp = '1') then
					reload_lat <= '1';
				elsif (reload_clr = '1') then
					reload_lat <= '0';
				end if;
				
         end if;
      end if;
   end process;
   
   
   -- main dazz_ctrl process
   ctrl_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if (reset8 = '1') then
				dpr_en     <= '0';
				dpr_addr   <= (others => '0');
				cmd_int    <= (others => '1'); -- do nothing
				cmd_data   <= (others => '0');
				low_addr   <= (others => '0');
				loop_cnt   <= (others => '0');
				num_cmd    <= (others => '0');
				num_loop   <= (others => '0');
				prog_ack   <= '0';
				cmd_test   <= '0';
				black_clr  <= '0';
				reload_clr <= '0';
				ctrlsm     <= INITCTRL;
			else
				case ctrlsm is
				when INITCTRL =>
					dpr_en   <= '0';
					dpr_addr <= (others => '0');
					cmd_int  <= (others => '1');
					cmd_data <= (others => '0');
					if shared_done = '1' then
						ctrlsm <= ACKCTRL; -- wait for good command to complete
					elsif (cmd_good = '0' and prog_req = '1') then
						ctrlsm <= ACKCTRL; -- if bad command, allow main_ram to reload
					end if;
				when ACKCTRL =>
					if (prog_req = '1') then
						ctrlsm <= BUSYCTRL; -- wait until main_ram is reloaded
					else
						ctrlsm <= STARTCTRL;
					end if;
				when BUSYCTRL =>
					prog_ack <= '1';
					low_addr <= (others => '0');
					loop_cnt <= (others => '0');
					if (prog_busy = '1') then
						ctrlsm <= LOADCTRL;
					end if;
				when LOADCTRL =>
					prog_ack <= '0';
					if (prog_busy = '0') then
						ctrlsm <= STARTCTRL; -- main_ram is reloaded
					end if;
				when STARTCTRL =>
					dpr_en     <= '1';
					-- dpr_addr   <= lites_addr;
					if (PB_SEL = '0') then
						dpr_addr <= (sw(1 downto 0) & low_addr);
					else
						dpr_addr <= (disp_addr & low_addr);
					end if;
					reload_clr <= '0';
					ctrlsm     <= WAITCTRL;
				when WAITCTRL =>
					ctrlsm <= SENDCTRL;
				when SENDCTRL =>
					if (prog_req = '1') then
						ctrlsm <= ENDCTRL; -- new instructions available
					elsif (reload_lat = '1') then
						ctrlsm <= ENDCTRL; -- reload instructions
					elsif (black_lat = '1') then
						cmd_int <= x"0"; -- send reinitialize command
						ctrlsm  <= BLKCLRCTRL;
					elsif (dpr_data (31 downto 28) = "0010") then -- finished
						ctrlsm <= ENDCTRL;
					elsif (dpr_data (31 downto 28) = "1000") then -- loop
						num_cmd  <= dpr_data (19 downto 12);
						num_loop <= dpr_data (27 downto 20);
						ctrlsm   <= LOOPCTRL;
					else
						cmd_int  <= dpr_data (31 downto 28);
						cmd_data <= dpr_data (27 downto 0);
						cmd_test <= '1'; -- enable command good test
						ctrlsm   <= INCCTRL;
					end if;
				when LOOPCTRL =>
					if (num_loop = x"FF" OR loop_cnt /= num_loop) then
						ctrlsm <= LOOPCALC; -- more loops to go
					else
						ctrlsm <= ENDLOOP; -- equals number of loops
					end if;
				when LOOPCALC =>
					if (num_cmd >= low_addr) then
						low_addr <= (others => '0');
					else
						low_addr <= low_addr - num_cmd; -- minus qty of commands
					end if;
					if num_loop /= x"FF" then -- allows for double loops
						loop_cnt <= loop_cnt + '1';
					end if;
					ctrlsm <= STARTCTRL; -- more loops to go
				when ENDLOOP =>
					low_addr <= low_addr + "00000001"; -- skip loop command
					loop_cnt <= (others => '0');
					ctrlsm   <= STARTCTRL;
				when INCCTRL =>
					low_addr  <= low_addr + '1'; -- go to next address
					cmd_test  <= '0';
					ctrlsm    <= INITCTRL;
				when ENDCTRL =>  -- stay here until reset or new program available
					dpr_en    <= '0';
					dpr_addr  <= (others => '0');
					cmd_int   <= (others => '1');
					cmd_data  <= (others => '0');
					low_addr  <= (others => '0');
					black_clr <= '0';
					if (prog_req = '1') then
						ctrlsm <= BUSYCTRL;
					elsif (reload_lat = '1') then
						ctrlsm <= RECLRCTRL;
					elsif (black_lat = '1') then
						ctrlsm <= SENDCTRL;
					end if;
				when RECLRCTRL =>
					reload_clr <= '1';
					if (reload_lat = '0') then
						ctrlsm <= STARTCTRL;
					end if;
				when BLKCLRCTRL =>
					black_clr <= '1';
					if (black_lat = '0') then
						ctrlsm <= ENDCTRL;
					end if;
				when others => 
					ctrlsm <= INITCTRL;
				end case;
			end if;
      end if;
   end process;
   
   
   -- when new command received, test to see if it's good
   -- remove cases when new commands are added to project
   cmd_test_proc : process (reset8, clk8)
   begin
      if (rising_edge(clk8)) then
			if (reset8 = '1') then
				cmd_good <= '1'; -- set to 1 so initialization can complete
			else
				if (cmd_test = '1') then
					case cmd_int is
					when x"A" =>
						cmd_good <= '0';
					when x"C" =>
						cmd_good <= '0';
					when x"E" =>
						cmd_good <= '0';
					when x"F" =>
						cmd_good <= '0';
					when others =>
						cmd_good <= '1';
					end case;
				end if;
			end if;
      end if;
   end process;


end rtl;
