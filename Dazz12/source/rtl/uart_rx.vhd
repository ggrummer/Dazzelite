----------------------------------------------------------------------------------
-- Create Date: 01/08/2014 10:26:46 PM
-- Module Name: uart_rx - rtl
--  
-- Description: receive serial UART data and output data bytes.  Recovered clock
--    re-locks to every negative edge of data.
-- 
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rx is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           uart_data   : in STD_LOGIC;
           rx_data     : out STD_LOGIC_VECTOR (7 downto 0);
           rx_valid    : out STD_LOGIC);
end uart_rx;

architecture rtl of uart_rx is

   
   signal din_dly1  : STD_LOGIC;
   signal din_dly2  : STD_LOGIC;
   signal din_dly3  : STD_LOGIC;
   signal din_dly4  : STD_LOGIC;
   signal din_dly5  : STD_LOGIC;
   
   signal clk114_en : STD_LOGIC;
   signal clk_cnt   : STD_LOGIC_VECTOR (2 downto 0);
   
   signal edge_det  : STD_LOGIC;
   signal neg_edge  : STD_LOGIC;
   signal rx_clk_en : STD_LOGIC;
   signal bit_num   : integer range 0 to 10;
   signal samp_num  : STD_LOGIC_VECTOR (3 downto 0);
   signal start     : STD_LOGIC;


begin
   
   
   -- divide 800 kHz input clock by 7
   clk117_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         clk114_en <= '0';
         clk_cnt   <= (others => '0');
      elsif rising_edge(clk8) then
         if clk_cnt = "110" then
            clk_cnt   <= "000";
            clk114_en <= '1';
         else
            clk_cnt   <= clk_cnt + '1';
            clk114_en <= '0';
         end if;
      end if;
   end process;
   
   
   -- detect a negatve edge on the input serial data
   -- glitch supression included
   neg_edge_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         din_dly1 <= '1';
         din_dly2 <= '1';
         din_dly3 <= '1';
         din_dly4 <= '1';
         din_dly5 <= '1';
         edge_det <= '0';
         neg_edge <= '0'; 
      elsif rising_edge(clk8) then
         if clk114_en = '1' then
         
            din_dly1 <= uart_data;
            din_dly2 <= din_dly1;
            din_dly3 <= din_dly2;
            din_dly4 <= din_dly3;
            din_dly5 <= din_dly4;
            neg_edge <= edge_det;
            
            if (uart_data = '0' and din_dly1 = '0' and din_dly2 = '0' 
               and din_dly3 = '1' and din_dly4 = '1' and din_dly5 = '1') then
               edge_det <= '1';
            else
               edge_det <= '0';
            end if;
            
         end if;
      end if;
   end process;
   
   
   -- clock enable at center of input data
   rx_clk_en_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         rx_clk_en <= '0';
      elsif rising_edge(clk8) then
         if clk114_en = '1' then
            if (neg_edge = '1' and start = '0') then
               rx_clk_en <= '1';
            elsif (samp_num = x"B") then
               rx_clk_en <= '1';
            else
               rx_clk_en <= '0';
            end if;
         end if;
      end if;
   end process;
   
   
   -- count samples (12 per bit)
   cnt_samp_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         samp_num <= x"0";
         start    <= '0';
      elsif rising_edge(clk8) then
         if (clk114_en = '1') then
         
            if (rx_clk_en = '1' and start = '0' and bit_num = 0) then
               start <= '1'; -- initial start bit
            elsif (rx_clk_en = '1' and bit_num = 8) then
               start <= '0'; -- stop bit
            elsif (rx_clk_en = '1' and bit_num = 9) then
               start <= '1'; -- re-start when only one stop bit
            end if;
            
            if (neg_edge = '1' and start = '0') then
               samp_num <= x"0";
            elsif (samp_num = x"B") then
               samp_num <= x"0";
            elsif (start = '1') then
               samp_num <= samp_num + '1';
            end if;
            
         end if;
      end if;
   end process;
   
   
   --- count bits and put them into output data
   cnt_bits_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         rx_data  <= x"00";
         rx_valid <= '0';
         bit_num  <= 0;
      elsif rising_edge(clk8) then
         if (clk114_en = '1') then
            if (rx_clk_en = '1') then
            
               if (start = '0') then
                  bit_num <= 0;
               else 
                  bit_num <= bit_num + 1;
               end if;
               
               if (start = '1' and bit_num <= 7) then
                  rx_data(bit_num) <= din_dly1;
               end if;
               
            end if;
               
            if (bit_num = 8) then
               rx_valid <= '1';
            else
               rx_valid <= '0';
            end if;
               
         end if;
      end if;
   end process;
   

end rtl;
