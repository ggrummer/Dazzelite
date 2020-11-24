----------------------------------------------------------------------------------
-- Create Date: 04/03/2014 10:12:49 AM
-- Module Name: auto_timeout - rtl
-- By: Grant Grummer
-- 
-- Description: automatically blacks out the display when on timer expiries, 
--   restarts the display when off timer expiries and delays the time when the
--   lites turn back on.  
--   Restarts timers if instructed to do so.
-- 
-- Revision 0.01 - File Created
-- Revision 0.02 - Commented out reload of timer counts on getting a 
--    finish command.
-- Revision 1.0 - Redesigned the whole thing
-- Revision 1.1 - Increased all hour counter sizes and only allowed delay 
--    counter to run once per command.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity auto_timeout is
    Port ( clk8         : in STD_LOGIC;
           reset8       : in STD_LOGIC;
           cmd_inst     : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data     : in STD_LOGIC_VECTOR (27 downto 0);
           blackout     : out STD_LOGIC;
           reload       : out STD_LOGIC;
           timeout_done : out STD_LOGIC);
end auto_timeout;


architecture rtl of auto_timeout is

   type instrsm_type   is (i_init,i_start,i_wait);
   type timeoutsm_type is (t_init,t_dly,t_black,t_load,t_on,
   t_off,t_blk2,t_blk3,t_stop);
   
   constant SIM         : STD_LOGIC := '0'; -- set to 1 for simulation 
   -- Initial on timer value
   constant DEFAULTIME  : STD_LOGIC_VECTOR (4 downto 0) := "00000"; 
   
   signal instrsm       : instrsm_type;
   signal timeoutsm     : timeoutsm_type;
   
   signal count1, count2, count3, count4  : STD_LOGIC_VECTOR (7 downto 0);
   signal tc, tc1, tc2, tc3, tc4          : STD_LOGIC;
   signal pre_tc1, pre_tc2, pre_tc3       : STD_LOGIC;
   
   signal pulse_en      : STD_LOGIC;
   signal local_rst     : STD_LOGIC;
   
   signal count_on      : STD_LOGIC_VECTOR (4 downto 0);
   signal on_data       : STD_LOGIC_VECTOR (4 downto 0);
   signal hour_on_data  : STD_LOGIC_VECTOR (4 downto 0);
   signal done_on       : STD_LOGIC;
   signal hour_on_en    : STD_LOGIC;
   signal hour_on_reg   : STD_LOGIC;
   
   signal count_off     : STD_LOGIC_VECTOR (4 downto 0);
   signal off_data      : STD_LOGIC_VECTOR (4 downto 0);
   signal hour_off_data : STD_LOGIC_VECTOR (4 downto 0);
   signal done_off      : STD_LOGIC;
   signal hour_off_en   : STD_LOGIC;
   signal hour_off_reg  : STD_LOGIC;
   
   signal count_dly     : STD_LOGIC_VECTOR (4 downto 0);
   signal dly_data      : STD_LOGIC_VECTOR (4 downto 0);
   signal hour_dly_data : STD_LOGIC_VECTOR (4 downto 0);
   signal done_dly      : STD_LOGIC;
   signal hour_dly_en   : STD_LOGIC;
   signal hour_dly_reg  : STD_LOGIC;


begin

   
   timeout_done <= local_rst;
   
   
   -- use tc2 for simulation and tc4 for implimentation
   sim_proc : process (tc2, tc4)
   begin
      if (SIM = '1') then
         tc <= tc2; -- for simulation
      else
         tc <= tc4; -- for implimentation
      end if;
   end process;
   
   
-- generate a one hour pulse
   
   -- 3125Hz pulse generator
   count1_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
      
         if (reset8 = '1' or local_rst = '1') then
            count1  <= x"00";
            pre_tc1 <= '0';
            tc1     <= '0';
         else
         
            if (pulse_en = '0') then
               count1 <= x"00";
            else
               count1 <= count1 + '1'; -- divide by 256 
            end if;
            
            if (count1 = x"FD") then
               pre_tc1 <= '1';
            else
               pre_tc1 <= '0';
            end if;
            
            tc1 <= pre_tc1;
         
         end if;
         
      end if;
   end process;
   
   
   -- 12.5Hz pulse generator
   count2_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         
         if (reset8 = '1' or local_rst = '1') then
            count2  <= x"00";
            pre_tc2 <= '0';
            tc2     <= '0';
         else
         
            if (pulse_en = '0') then
               count2 <= x"00";
            elsif (tc1 = '1') then
               if (count2 = x"F9") then
                  count2 <= x"00"; -- divide by 250
               else
                  count2 <= count2 + '1';
               end if;
            end if;
            
            if (count2 = x"F9") then
               pre_tc2 <= '1';
            else
               pre_tc2 <= '0';
            end if;
            
            if (pre_tc1 = '1' and pre_tc2 = '1') then
               tc2 <= '1';
            else
               tc2 <= '0';
            end if;
         
         end if;
         
      end if;
   end process;
   
   
   -- 20 second pulse generator
   count3_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         
         if (reset8 = '1' or local_rst = '1') then
            count3  <= x"00";
            pre_tc3 <= '0';
            tc3     <= '0';
         else
         
            if (pulse_en = '0') then
               count3 <= x"00";
            elsif (tc2 = '1') then
               if (count3 = x"F9") then
                  count3 <= x"00"; -- divide by 250
               else
                  count3 <= count3 + '1';
               end if;
            end if;
            
            if (count3 = x"F9") then
               pre_tc3 <= '1';
            else
               pre_tc3 <= '0';
            end if;
            
            if (pre_tc1 = '1' and pre_tc2 = '1' and pre_tc3 = '1') then
               tc3 <= '1';
            else
               tc3 <= '0';
            end if;
         
         end if;
         
      end if;
   end process;
   
   
   -- one hour pulse generator
   count4_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         
         if (reset8 = '1' or local_rst = '1') then
            count4 <= x"00";
            tc4    <= '0';
         else
         
            if (pulse_en = '0') then
               count4 <= x"00";
            elsif (tc3 = '1') then
               if (count4 = x"B3") then
                  count4 <= x"00"; -- divide by 180
               else
                  count4 <= count4 + '1';
               end if;
            end if;
            
            if (pre_tc1 = '1' and pre_tc2 = '1' and pre_tc3 = '1' and
            count4 = x"B3") then
               tc4 <= '1';
            else
               tc4 <= '0';
            end if;
         
         end if;
         
      end if;
   end process;
   
-- end generation of a one hour pulse
   
   
-- begin loadable counters
   
   -- registered versions of hour_*_en
   reg_en_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         if (reset8 = '1' or local_rst = '1') then
            hour_on_reg  <= '0';
            hour_off_reg <= '0';
            hour_dly_reg <= '0';
         else
            hour_on_reg  <= hour_on_en;
            hour_off_reg <= hour_off_en;
            hour_dly_reg <= hour_dly_en;
         end if;
      end if;
   end process;
   
   
   -- on timeout loadable counter
   on_timout_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         if (reset8 = '1' or local_rst = '1') then
            count_on <= DEFAULTIME; -- default hours on
            done_on  <= '0';
         elsif (hour_on_en = '1' and hour_on_reg = '0') then
            count_on <= hour_on_data; -- load data from cmd bus
         elsif (hour_on_reg = '1') then
            if (tc = '1') then
               if (count_on(4 downto 1) = "0000") then
                  count_on <= hour_on_data;
                  done_on  <= '1';
               else
                  count_on <= count_on - '1';
                  done_on  <= '0';
               end if;
            else
               done_on <= '0';
            end if;
         end if;
      end if;
   end process;
   
   
   -- off timeout loadable counter
   off_timout_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         if (reset8 = '1' or local_rst = '1') then
            count_off <= "00000"; -- default to off
            done_off  <= '0';
         elsif (hour_off_en = '1' and hour_off_reg = '0') then
            count_off <= hour_off_data; -- load data from cmd bus
         elsif (hour_off_reg = '1') then
            if (tc = '1') then 
               if (count_off(4 downto 1) = "0000") then
                  count_off <= hour_off_data;
                  done_off  <= '1';
               else
                  count_off <= count_off - '1';
                  done_off  <= '0';
               end if;
            else
               done_off <= '0';
            end if;
         end if;
      end if;
   end process;
   
   
   -- dly timeout loadable counter
   dly_timout_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         if (reset8 = '1' or local_rst = '1') then
            count_dly <= "00000"; -- default to off
            done_dly  <= '0';
         elsif (hour_dly_en = '1' and hour_dly_reg = '0') then
            count_dly <= hour_dly_data; -- load data from cmd bus
         elsif (hour_dly_reg = '1') then
            if (tc = '1') then 
               if (count_dly(4 downto 1) = "0000") then
                  count_dly <= hour_dly_data;
                  done_dly  <= '1';
               else
                  count_dly <= count_dly - '1';
                  done_dly  <= '0';
               end if;
            else
               done_dly <= '0';
            end if;
         end if;
      end if;
   end process;
   
-- end loadable counters
         
         
   -- aquire data when valid instruction received
   -- produce a local reset
   auto_timeout_instr_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
         local_rst     <= '0'; 
         on_data       <= DEFAULTIME; -- default hours on
         off_data      <= "00000";
         dly_data      <= "00000";
         hour_on_data  <= DEFAULTIME;
         hour_off_data <= "00000";
         hour_dly_data <= "00000";
         instrsm       <= i_init;
      elsif rising_edge(clk8) then
         case instrsm is
         when i_init =>
            local_rst     <= '0';
            on_data       <= cmd_data(24 downto 20);
            off_data      <= cmd_data(16 downto 12);
            dly_data      <= cmd_data(4 downto 0);
            if (cmd_inst = x"D") then
               instrsm <= i_start;
            end if;
         when i_start =>
            local_rst     <= '1';
            hour_on_data  <= on_data;
            hour_off_data <= off_data;
            hour_dly_data <= dly_data;
            instrsm       <= i_wait;
         when i_wait =>
            local_rst     <= '0';
            if (cmd_inst /= x"D") then
               instrsm <= i_init;
            end if;
         when others => 
            instrsm <= i_init;
         end case;
      end if;
   end process;
   
   
   -- control when to turn on the lites and when to turn them off
   timeout_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
         if (reset8 = '1' or local_rst = '1') then
            pulse_en      <= '0';
            hour_on_en    <= '0';
            hour_off_en   <= '0';
            hour_dly_en   <= '0';
            blackout      <= '0';
            reload        <= '0';
            timeoutsm     <= t_init;
         else
            case timeoutsm is
            when t_init =>
               pulse_en      <= '0';
               hour_on_en    <= '0';
               hour_off_en   <= '0';
               hour_dly_en   <= '0';
               blackout      <= '0';
               reload        <= '0';
               if (hour_dly_data /= "00000") then
                  timeoutsm <= t_black; -- delay counter
               elsif (hour_dly_data = "00000" and hour_on_data /= "00000") then
                  timeoutsm <= t_on; -- on counter
               else -- (hour_dly_data = "00000" and hour_on_data = "00000") 
                  timeoutsm <= t_stop; -- autotimer done
               end if;
            when t_black =>
               pulse_en      <= '1';
               hour_dly_en   <= '1'; -- start delay timer
               --blackout      <= '1'; -- blackout display (pointless to do)
               reload        <= '0';
               timeoutsm     <= t_dly;
            when t_dly =>
               blackout <= '0';
               if (done_dly = '1') then
                  timeoutsm <= t_load; 
               end if;
            when t_load =>
               hour_off_en   <= '0';
               hour_dly_en   <= '0';
               reload        <= '1'; -- resend all commands
               if (hour_on_data /= "00000") then
                  timeoutsm <= t_on; -- on counter
               else
                  timeoutsm <= t_stop; -- autotimer done
               end if;
            when t_on =>
               pulse_en   <= '1';
               hour_on_en <= '1'; -- start on timer
               reload     <= '0';
               if (done_on = '1' and hour_off_data /= "00000") then
                  timeoutsm <= t_blk2; -- off timer
               elsif (done_on = '1' and hour_off_data = "00000") then
                  timeoutsm <= t_blk3; -- autotimer done
               end if;
            when t_blk2 =>
               hour_on_en  <= '0';
               hour_off_en <= '1'; -- start off timer
               blackout    <= '1'; -- blackout display
               timeoutsm   <= t_off;
            when t_off =>
               blackout <= '0';
               if (done_off = '1') then
                  timeoutsm <= t_load; -- loop back to turning lites on
               end if;
            when t_blk3 =>
               hour_on_en  <= '0';
               blackout    <= '1'; -- blackout display
               timeoutsm   <= t_stop;
            when t_stop =>
               hour_on_en  <= '0';
               hour_off_en <= '0';
               hour_dly_en <= '0';
               blackout    <= '0';
               reload      <= '0';
               pulse_en    <= '0';
               -- stay here until reset or new command
            when others =>
               timeoutsm <= t_init;
            end case;
         end if;
      end if;
   end process;
   
   
end rtl;