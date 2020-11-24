----------------------------------------------------------------------------------
-- Create Date: 09/9/2014 08:46:52 AM
-- Module Name: neo_framer - rtl
-- By: Grant Grummer
-- 
-- Description: bit level protocol for neopixel lites
-- 
-- Revision: 0.1 changed from a 40 MHz clock to an 8 MHz clock
-- Revision: 0.2 added a generic to select version of neopixel lites
-- Revision: 0.3 remove the generic and added a package
-- Revision: 0.4 reduced number of states in bit_proc
-- 
----------------------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity neo_framer is
   Port ( 
      clkfast     : in STD_LOGIC;
      reset8      : in STD_LOGIC;
      ce1         : in STD_LOGIC;
      dp_data     : in STD_LOGIC_VECTOR (23 downto 0);
      dp_addr     : out STD_LOGIC_VECTOR (7 downto 0);
      dp_rd_en    : out STD_LOGIC;
      fm_go       : in STD_LOGIC;
      neo_size    : in STD_LOGIC_VECTOR (7 downto 0);
      fm_busy     : out STD_LOGIC;
      tx_data     : out STD_LOGIC
   );
end neo_framer;


architecture rtl of neo_framer is
   
   constant HI0_2812  : std_logic_vector (3 DOWNTO 0) := "0001"; -- 375 ns 
   constant LO0_2812  : std_logic_vector (3 DOWNTO 0) := "0101"; -- 875 ns
   constant HI1_2812  : std_logic_vector (3 DOWNTO 0) := "0100"; -- 750 ns
   constant LO1_2812  : std_logic_vector (3 DOWNTO 0) := "0010"; -- 500 ns 
   
   constant HI0_2811  : std_logic_vector (3 DOWNTO 0) := "0000"; -- 250 ns 
   constant LO0_2811  : std_logic_vector (3 DOWNTO 0) := "0110"; -- 1.0 us
   constant HI1_2811  : std_logic_vector (3 DOWNTO 0) := "0100"; -- 750 ns
   constant LO1_2811  : std_logic_vector (3 DOWNTO 0) := "0010"; -- 500 ns
   
   signal HI0CNT      : std_logic_vector (3 DOWNTO 0);
   signal LO0CNT      : std_logic_vector (3 DOWNTO 0);
   signal HI1CNT      : std_logic_vector (3 DOWNTO 0);
   signal LO1CNT      : std_logic_vector (3 DOWNTO 0);
   
   type ctrlsm_type    is (INIT,START,VAL1,VAL0,INC,INTER,SENT,DONE);
   type par2sersm_type is (INIT,GO,LOAD,DEC,DONE);
   type bitsm_type     is (INIT,START,DEC_HI,DEC_LO);
   type intersm_type   is (INIT,INC,HI5,LO5,DONE);
   
   signal ctrlsm      : ctrlsm_type;
   signal par2sersm   : par2sersm_type;
   signal bitsm       : bitsm_type;
   signal intersm     : intersm_type;
   
   signal go1         : STD_LOGIC;
   signal go2         : STD_LOGIC;
   signal ce1_sync1   : STD_LOGIC;
   signal ce1_sync2   : STD_LOGIC;
   signal addr        : STD_LOGIC_VECTOR (7 downto 0);
   signal valid       : STD_LOGIC;
   signal interframe  : STD_LOGIC;
   signal dbit        : INTEGER range 0 to 23;
   signal dataword    : STD_LOGIC_VECTOR (23 downto 0);
   signal databit     : STD_LOGIC;
   signal gobit       : STD_LOGIC;
   signal cnthi       : STD_LOGIC_VECTOR (3 DOWNTO 0);
   signal cntlo       : STD_LOGIC_VECTOR (3 DOWNTO 0);
   signal nextbit     : STD_LOGIC;
   signal ten_us      : STD_LOGIC_VECTOR (2 downto 0);
   signal pixel_sent  : STD_LOGIC;
   signal frame_sent  : STD_LOGIC;
   
   
begin
   
   
   -- mux to select LED lites prococol
   HI0CNT <= HI0_2812 when TYPE_OF_LITE = 2 else HI0_2811;
   LO0CNT <= LO0_2812 when TYPE_OF_LITE = 2 else LO0_2811;
   HI1CNT <= HI1_2812 when TYPE_OF_LITE = 2 else HI1_2811;
   LO1CNT <= LO1_2812 when TYPE_OF_LITE = 2 else LO1_2811;
   
   
   -- sync neo_go and ce1 control input to 8 MHz clock
   -- neo_size is pretty much static so it doesn't need to be synced
   go_proc : process (reset8, clkfast)
   begin
      if (reset8 = '1') then
         go1       <= '0';
         go2       <= '0';
         ce1_sync1 <= '0';
         ce1_sync2 <= '0';
      elsif rising_edge(clkfast) then
         go1       <= fm_go;
         go2       <= go1;
         ce1_sync1 <= ce1;
         ce1_sync2 <= ce1_sync1;
      end if;
   end process;
   
   
   -- high level control of framer
   ctrl_proc : process (reset8, clkfast)
   begin
      if reset8 = '1' then
         addr       <= x"00"; 
         dp_rd_en   <= '0';
         fm_busy    <= '0';
         valid      <= '0';
         interframe <= '0';
         ctrlsm     <= INIT;
      elsif rising_edge(clkfast) then
         case ctrlsm is
         when INIT =>
            addr       <= x"00"; 
            dp_rd_en   <= '0';
            fm_busy    <= '0';
            valid      <= '0';
            interframe <= '0';
            if (go2 = '1') then
               ctrlsm <= START;
            end if;
         when START =>
            dp_rd_en <= '1';
            fm_busy  <= '1';
            ctrlsm   <= VAL1;
         when VAL1 =>
            valid  <= '1';
            ctrlsm <= VAL0;
         when VAL0 =>
            -- valid <= '0'; -- old setting
            if (pixel_sent = '1') then
               ctrlsm <= INC;
            end if;
         when INC =>
            if (addr < neo_size) then
               addr   <= addr + '1';
               ctrlsm <= START; -- loop to get next data word
            else
               ctrlsm <= INTER; -- no more data words
            end if;
         when INTER =>
            valid      <= '0'; -- new change
            interframe <= '1';
            ctrlsm     <= SENT;
         when SENT =>
            interframe <= '0';
            if (frame_sent = '1') then
               ctrlsm <= DONE;
            end if;
         when DONE => 
            fm_busy <= '0'; 
            ctrlsm  <= INIT;
         when others => 
            ctrlsm <= INIT;
         end case;
      end if;
   end process;
   
   dp_addr <= addr;
   
   
   -- parellel to serial data converter
   par2ser_proc : process (reset8, clkfast)
   begin
      if reset8 = '1' then
         dataword   <= x"000000";
         databit    <= '0';         
         dbit       <= 23;
         gobit      <= '0';
         pixel_sent <= '0';
         par2sersm  <= INIT;
      elsif rising_edge(clkfast) then
         case par2sersm is
         when INIT =>
            dbit       <= 23; 
            gobit      <= '0';
            pixel_sent <= '0';
            if (valid = '1') then
               par2sersm <= GO;
            end if;
         when GO =>
            dataword  <= dp_data; 
            gobit     <= '1';
            par2sersm <= LOAD;
         when LOAD =>
            databit    <= dataword(dbit); 
            pixel_sent <= '0';
            if (nextbit = '1') then
               par2sersm <= DEC;
            end if;
         when DEC => 
            if (dbit = 1) then
               dbit       <= dbit - 1;
               pixel_sent <= '1';
               par2sersm  <= GO; -- loop through all 24 data bits
            elsif (dbit = 0) then
               par2sersm  <= DONE; -- exit loop
            else
               dbit       <= dbit - 1;
               par2sersm  <= GO; -- loop through all 24 data bits
            end if;
         when DONE => 
            gobit      <= '0';
            par2sersm  <= INIT;
         when others => 
            par2sersm <= INIT;
         end case;
      end if;
   end process;
   
   
   -- format a bit into proper waveform
   bit_proc : process (reset8, clkfast)
   begin
      if reset8 = '1' then
         tx_data <= '0';
         nextbit <= '0';
         cnthi   <= "0000";
         cntlo   <= "0000";
         bitsm   <= INIT;
      elsif rising_edge(clkfast) then
         case bitsm is
         when INIT =>
            if (gobit = '1') then
               bitsm <= START;
            end if;
         when START =>
            tx_data   <= '1';
            nextbit   <= '1';
            bitsm     <= DEC_HI;
            if (databit = '0') then
               cnthi <= hi0cnt;
               cntlo <= lo0cnt;
            else
               cnthi <= hi1cnt;
               cntlo <= lo1cnt;
            end if;
         when DEC_HI =>
            nextbit <= '0';
            if (cnthi /= 0) then -- loop in state until cnthi = 0
               cnthi <= cnthi - '1'; 
            else
               bitsm <= DEC_LO;
            end if;
         when DEC_LO =>
            tx_data <= '0';
            if (cntlo /= 0) then -- loop in state until cntlo = 0
               cntlo <= cntlo - '1'; 
            else
               bitsm <= INIT;
            end if;
         when others => 
            bitsm <= INIT;
         end case;
      end if;
   end process;
   
   
   -- create inter frame gap of greater than 50 us
   inter_proc : process (reset8, clkfast)
   begin
      if reset8 = '1' then
         ten_us     <= "000"; 
         frame_sent <= '0';
         intersm    <= INIT;
      elsif rising_edge(clkfast) then
         case intersm is
         when INIT =>
            ten_us     <= "000"; 
            frame_sent <= '0';
            if (interframe = '1') then
               intersm <= HI5;
            end if;
         when HI5 =>
            if (ce1_sync2 = '1') then
               intersm <= LO5;
            end if;
         when LO5 =>
            if (ce1_sync2 = '0') then
               intersm <= INC;
            end if;
         when INC =>
            ten_us <= ten_us + '1'; 
            if (ten_us = "110") then
               intersm <= DONE;
            else
               intersm <= HI5;
            end if;
         when DONE => 
            frame_sent <= '1'; 
            intersm    <= INIT;
         when others => 
            intersm <= INIT;
         end case;
      end if;
   end process;
   
   
end rtl;
   