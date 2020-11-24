-----------------------------------------------------------------------
-- Create Date: 11/06/2015 08:46:52 AM
-- Module Name: tasks2do_simple_tb - Behavioral
-- By: Grant Grummer
-- 
-- Description: simple simulation for tasks2do module.
-- 
-- Revision: 0.0
-- 
-----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity tasks2do_simple_tb is
end tasks2do_simple_tb;


architecture Behavioral of tasks2do_simple_tb is

   COMPONENT tasks2do
      PORT (
			clk8        : in STD_LOGIC;
			reset8      : in STD_LOGIC;
			ce1         : in STD_LOGIC;
			frame_start : out STD_LOGIC;
			frame_busy  : in STD_LOGIC;
			frame_data  : out STD_LOGIC_VECTOR (25 downto 0);
			prog_req    : in STD_LOGIC;
			prog_ack    : out STD_LOGIC;
			prog_addr   : in STD_LOGIC_VECTOR (9 downto 0);
			prog_word   : in STD_LOGIC_VECTOR (31 downto 0);
			prog_wr     : in STD_LOGIC;
			prog_busy   : in STD_LOGIC;
			neo_busy    : in STD_LOGIC;
			neo_size    : out STD_LOGIC_VECTOR (7 downto 0);
			sw          : in STD_LOGIC_VECTOR (3 downto 0);
			disp_sel_n  : in STD_LOGIC;
			led         : out STD_LOGIC_VECTOR (3 downto 0)
      );
   END COMPONENT;
   
   
   type handsm_type is (INIT,START,BUSY,DLY,DONE);
   
   signal handsm      : handsm_type;
   signal clk8tb      : std_logic;
   signal rst         : std_logic;
   signal ce1cnt      : STD_LOGIC_VECTOR (2 downto 0);
   
   signal clk8        : std_logic;
   signal reset8      : std_logic;
   signal ce1         : std_logic;
   signal frame_start : std_logic;
   signal frame_busy  : std_logic;
   signal frame_data  : STD_LOGIC_VECTOR (25 downto 0);
   signal prog_req    : STD_LOGIC;
   signal prog_ack    : STD_LOGIC;
   signal prog_addr   : STD_LOGIC_VECTOR (9 downto 0);
   signal prog_word   : STD_LOGIC_VECTOR (31 downto 0);
   signal prog_wr     : STD_LOGIC;
   signal prog_busy   : STD_LOGIC;
   signal led         : STD_LOGIC_VECTOR (3 downto 0);
   signal sw          : STD_LOGIC_VECTOR (3 downto 0);
   signal disp_sel_n  : STD_LOGIC;
   signal neo_busy    : STD_LOGIC;
   signal neo_size    : STD_LOGIC_VECTOR (7 downto 0);
   

begin

   tasks2do_0 : tasks2do
      PORT MAP (
         clk8        => clk8,
         ce1         => ce1,
         reset8      => reset8,
         frame_start => frame_start,
         frame_busy  => frame_busy,
         frame_data  => frame_data,
         prog_req    => prog_req,
         prog_ack    => prog_ack,
         prog_addr   => prog_addr,
         prog_word   => prog_word,
         prog_wr     => prog_wr,
         prog_busy   => prog_busy,
         neo_busy    => neo_busy,
         neo_size    => neo_size,
         sw          => sw,
         disp_sel_n  => disp_sel_n,
         led         => led
      );
   
   
   clk8    <= clk8tb;
   reset8  <= rst;
  
   rst     <= '1', '0' after 3750 ns;
  
  
   -- 800 KHz clock
   clk8_proc : process
   begin
       loop
         clk8tb <= '0';
         wait for 625 ns;
         clk8tb <= '1';
         wait for 625 ns;
       end loop;
       wait;
   end process;
   
   
   -- make a 100 kHz clock enable pulse
	clock_enable_proc : process (rst, clk8tb)
	begin
		if rst = '1' then
			ce1    <= '0';
			ce1cnt <= "000";
		elsif rising_edge(clk8tb) then
			ce1cnt <= ce1cnt + '1';
			if ce1cnt = "111" then
                ce1 <= '1';
            else
                ce1 <= '0';
            end if;
		end if;
    end process;
  
 
   frame_handshake_proc : process (rst, clk8tb)
   begin
      if rst = '1' then
         neo_busy    <= '0';
         frame_busy  <= '0';
         prog_req    <= '0';
         prog_addr   <= "0000000000";
         prog_word   <= x"00000000";
         prog_wr     <= '0';
         prog_busy   <= '0';
         sw          <= x"0";
         disp_sel_n  <= '1';
         handsm      <= INIT;
      elsif rising_edge(clk8tb) then
         case handsm is
         when INIT =>
            frame_busy <= '0'; 
            if (frame_start = '1') then
               handsm <= START;
            end if;
         when START =>
            handsm <= BUSY;
         when BUSY =>
            frame_busy <= '1'; 
            if (frame_start = '0') then
               handsm <= DLY;
            end if;
         when DLY =>
            handsm <= DONE;
         when DONE => 
            frame_busy <= '0'; 
            handsm     <= INIT;
         when others => 
            handsm <= INIT;
         end case;
      end if;
   end process;
   
   
   
   tasks2do_test_proc : process
   begin
      wait for 200 ms;
      -- end test
      assert false
         report "Simple tasks2do Module Simulation Done " & cr
         severity failure;
      wait;
   end process;


end Behavioral;
