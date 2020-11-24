-----------------------------------------------------------------------------
-- Create Date: 02/15/2014
-- Module Name: rx_ctrl - rtl
--  
-- Description: takes uart data (in byte form) and writes it in to DP BRAM.
--    Once done, this data is read out of DP BRAM and written to the control module.
--    After reset, it also reads data out of DP BRAM and writes it to the
--    control module?
-- 
-- Revision 0.1 - File Created
-- Revision 0.2 - Ported to iCE40 devices
-- 
-----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;


entity rx_ctrl is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           rx_data     : in STD_LOGIC_VECTOR (7 downto 0);
           rx_valid    : in STD_LOGIC;
           prog_ack    : in STD_LOGIC;
           prog_req    : out STD_LOGIC;
           prog_addr   : out STD_LOGIC_VECTOR (9 downto 0);
           prog_word   : out STD_LOGIC_VECTOR (31 downto 0);
           prog_busy   : out STD_LOGIC;
           prog_wr     : out STD_LOGIC;
           soft_reset  : out STD_LOGIC);
end rx_ctrl;


architecture rtl of rx_ctrl is

	
	COMPONENT rx_dpr
     PORT (
		rclk  : IN  STD_LOGIC;
		ren   : IN  STD_LOGIC;
		raddr : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
		rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		wclk  : IN  STD_LOGIC;
		wen   : IN  STD_LOGIC;
		waddr : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
		wdata : IN  STD_LOGIC_VECTOR(7 DOWNTO 0)
     );
   END COMPONENT;
   
   
   -- signals for writing data into "a" side of DP BRAM
   signal val_dly1  : STD_LOGIC;
   signal val_dly2  : STD_LOGIC;
   signal val_dly3  : STD_LOGIC;
   signal val_dly4  : STD_LOGIC;
   signal addra_hi  : STD_LOGIC_VECTOR (8 downto 0);
   signal addra_lo  : STD_LOGIC_VECTOR (1 downto 0);
   signal addra     : STD_LOGIC_VECTOR (10 downto 0);
   signal dina      : STD_LOGIC_VECTOR (7 downto 0);
   signal ena       : STD_LOGIC;
   signal wea_int   : STD_LOGIC;
	signal wen		  : STD_LOGIC;
   signal load_done : STD_LOGIC;
   signal finish    : STD_LOGIC;
   signal reset_cmd : STD_LOGIC;
   
	-- signals used on "b" (read) side of DP BRAM
   signal enb       : STD_LOGIC; 
   signal addrb     : STD_LOGIC_VECTOR (8 downto 0); 
   signal doutb     : STD_LOGIC_VECTOR (31 downto 0); 
   
   -- signals for read flash protocol state machine
   type   rdsm_type is (r_init,r_req,r_busy,r_dly,r_word,r_wr,r_inc);
   signal rdsm       : rdsm_type;
   signal rd_fin     : STD_LOGIC;
   

begin
   
   
	rx_dpram_inst : rx_dpr
     PORT MAP (
      rclk  => clk8,
		ren   => enb,
		raddr => addrb,
		rdata => doutb,
		wclk  => clk8,
		wen   => wen,
		waddr => addra,
		wdata => dina
     );
	
   wen <= ena and wea_int;
	
   
-- start side "a" DP BRAM RTL (write only)
   
   -- strobes for data latching, "a" side writing, address changing
   pos_edge_det_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         val_dly1 <= '0';
         val_dly2 <= '0';
         val_dly3 <= '0';
         val_dly4 <= '0';
      elsif rising_edge(clk8) then
         val_dly1 <= rx_valid;
         -- positive edge detect
         if (rx_valid = '1' and val_dly1 = '0') then
            val_dly2 <= '1';
         else
            val_dly2 <= '0';
         end if;
         -- delayed positive edge detects
         val_dly3 <= val_dly2;
         val_dly4 <= val_dly3;
      end if;
   end process;
   
   
   -- data latch
   data_lat_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         dina <= (others => '0');
      elsif rising_edge(clk8) then
         if (val_dly2 = '1') then
            dina <= rx_data;
         end if;
      end if;
   end process;
   
   
   -- write enable
   write_en_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         wea_int <= '0';
      elsif rising_edge(clk8) then
         if (val_dly3 = '1') then
            wea_int <= '1';
         else
            wea_int <= '0';
         end if;
      end if;
   end process;
   
   ena    <= rx_valid;
   
   
   -- down counter for lowest 2 bits of address
   addra_lo_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         addra_lo <= "11";
      elsif rising_edge(clk8) then
         if (val_dly4 = '1') then
            addra_lo <= addra_lo - '1';
         elsif (load_done = '1') then
            addra_lo <= "11";
         end if;
      end if;
   end process;
   
   
   -- increase high address by one every fourth byte
   -- save the last high address
   addra_hi_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         addra_hi  <= (others => '0');
      elsif rising_edge(clk8) then
         if (val_dly4 = '1' and addra_lo = "00") then
            addra_hi  <= addra_hi + '1';
         elsif (load_done = '1') then
            addra_hi <= (others => '0');
         end if;
      end if;
   end process;
   
   addra <= addra_hi & addra_lo;
   
   
   -- indicate when done with input data
   -- look for finish command
   load_done_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         finish    <= '0';
         load_done <= '0';
      elsif rising_edge(clk8) then
         
         -- look for the finish command in the highest byte
         if (val_dly2 = '1' and addra_lo = "11" and rx_data(7 downto 4) = x"2") then
            finish <= '1';
         elsif (load_done = '1') then
            finish <= '0';
         end if;
         
         -- done when all bytes are written to memory
         if (val_dly4 = '1' and addra_lo = "00" and finish = '1') then
            load_done <= '1';
         else
            load_done <= '0';
         end if;
         
      end if;
   end process;
   
   
   -- issue a soft reset after receiving a command to do so
   -- only a reset8 can clear a soft reset
   soft_reset_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         reset_cmd  <= '0';
         soft_reset <= '0';
      elsif rising_edge(clk8) then
         
         -- look for the soft reset command in the highest byte
         if (val_dly2 = '1' and addra_lo = "11" and rx_data(7 downto 4) = x"C") then
            reset_cmd <= '1';
         end if;
         
         -- reset when all bytes in the command are received
         if (val_dly4 = '1' and addra_lo = "00" and reset_cmd = '1') then
            soft_reset <= '1';
         end if;
         
      end if;
   end process;
   
   
-- end side "a" DP BRAM RTL ----------------------------------
   
   
-- side "b" DP BRAM RTL (read only)---------------------------
   
   rd_dpram_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         prog_req   <= '0';
         prog_addr  <= (others => '0');
         prog_word  <= (others => '0');
         prog_wr    <= '0';
         prog_busy  <= '0';
         enb        <= '0'; 
         addrb      <= (others => '0');
         rd_fin     <= '0';
         rdsm       <= r_init;
      elsif rising_edge(clk8) then
         case rdsm is
         when r_init =>
            prog_req   <= '0';
            prog_addr  <= (others => '0');
            prog_word  <= (others => '0');
            prog_wr    <= '0';
            prog_busy  <= '0';
            enb        <= '0'; 
            addrb      <= (others => '0');
            rd_fin     <= '0';
            if (load_done = '1') then
               rdsm <= r_req;
            end if;
         when r_req =>
            prog_req <= '1'; -- request stop of present lites program
            if (prog_ack = '1') then
               rdsm <= r_busy;
            end if;
         when r_busy =>
            enb       <= '1'; -- start read of dpram
            prog_busy <= '1'; -- stop present lites program
            prog_req  <= '0';
            rdsm <= r_dly;
         when r_dly =>
            rdsm <= r_word;
         when r_word =>
            prog_addr <= '0' & addrb;
            prog_word <= doutb;
            rdsm <= r_wr;
            if (doutb(31 downto 28) = x"2") then
               rd_fin <= '1'; -- last command received
            end if;
         when r_wr =>
            prog_wr <= '1';
            rdsm    <= r_inc;
         when r_inc => 
            prog_wr <= '0';
            addrb   <= addrb + '1';
            if (rd_fin = '1') then
               rdsm <= r_init; -- read finished
            elsif (addrb = "111111111") then
               rdsm <= r_init; -- max address, end read now
            else
               rdsm <= r_dly; -- loop
            end if;
         when others => 
            rdsm <= r_init;
         end case;
      end if;
   end process;
   

end rtl;
