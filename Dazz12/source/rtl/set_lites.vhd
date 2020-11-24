-------------------------------------------------------------------------------
-- Create Date: 04/06/2013 10:26:46 PM
-- Module Name: set_lites - rtl
-- By: Grant Grummer
--  
-- Description: set one lite or all at once.  Uses the color in command #4 or
--    random color and/or address in command #3.  Has a color palette used by
--    random color command.  Palette can be changed via command #9.
-- 
-- Revision 0.00 - File Created
-- Revision 0.01 - Added support for chase module
-- Revision 0.02 - Added random color support under command #3 
-- Revision 0.03 - Added random address support under command #3 
-- Revision 0.04 - Added access to random color palette via command #9
-- Revision 1.0  - Changed max number of lites from 25 to 63 and random 
--    select from bit 32 to bit 64
-- Revision 1.1  - Added rainbow module (rbow) signals
-- 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;


entity set_lites is
    Port ( clk8        : in STD_LOGIC;
           reset8      : in STD_LOGIC;
           frame_busy  : in STD_LOGIC;
           cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
           cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
           offset      : in STD_LOGIC_VECTOR (5 downto 0);
           sizeplus1   : in STD_LOGIC_VECTOR (7 downto 0);
           fade_en     : in STD_LOGIC;
           fade_data   : in STD_LOGIC_VECTOR (7 downto 0);
           fading      : in STD_LOGIC;
			  rbow_en     : in STD_LOGIC;
           rbow_data   : in STD_LOGIC_VECTOR (11 downto 0);
           set_done    : out STD_LOGIC;
           set_data    : out STD_LOGIC_VECTOR (25 downto 0);
           set_go      : out STD_LOGIC);
end set_lites;


architecture rtl of set_lites is


   type setsm_type is (s_init,s_start,s_addrlim,s_num,s_dly1,s_color,
      s_dly2,s_sel,s_go,s_wait,s_end);
   signal setsm        : setsm_type;
   
   signal address      : STD_LOGIC_VECTOR (7 downto 0);
   signal addrsum      : STD_LOGIC_VECTOR (7 downto 0);
   signal offset_int   : STD_LOGIC_VECTOR (7 downto 0);
   signal rand_addr    : STD_LOGIC_VECTOR (5 downto 0);
   signal briteness    : STD_LOGIC_VECTOR (7 downto 0);
   signal color_lat    : STD_LOGIC_VECTOR (11 downto 0);
   signal set_path     : STD_LOGIC;
   signal color        : STD_LOGIC_VECTOR (11 downto 0);
   signal calc_randnum : STD_LOGIC;
   signal calc_color   : STD_LOGIC;
   signal calc_sel     : STD_LOGIC;
   signal calc_addr    : STD_LOGIC;
   signal addr64       : STD_LOGIC;
   signal feedback     : STD_LOGIC;
   signal col_done     : STD_LOGIC;
   signal random_en    : STD_LOGIC;
   signal random       : STD_LOGIC_VECTOR (11 downto 0);
   signal nx_color     : STD_LOGIC_VECTOR (11 downto 0);
   
   type palatte_type is array (0 to 15) of STD_LOGIC_VECTOR (11 downto 0);
   signal palette      : palatte_type :=
      (x"00F", x"03F", x"0CF", x"0F0", x"3F0", x"CF0", x"F00", x"F0C",
       x"00F", x"03F", x"0CF", x"0F0", x"CCC", x"33F", x"F00", x"F0C");
   
   type palsm_type is (p_init,p_we,p_pause,p_mem);
   signal palsm        : palsm_type;
   
   signal pal_addr     : STD_LOGIC_VECTOR (3 downto 0);
   signal pal_out      : STD_LOGIC_VECTOR (11 downto 0);
   signal pal_color    : STD_LOGIC_VECTOR (11 downto 0);
   signal pal_done     : STD_LOGIC;
   signal pal_we       : STD_LOGIC;
   

begin


   set_data (25 downto 20) <= addrsum(5 downto 0) when addr64 = '0' else rand_addr;
   set_data (19 downto 12) <= briteness when fade_en = '0' else fade_data;  
   set_data (11 downto 0)  <= rbow_data when rbow_en = '1' else
										color_lat when set_path = '1' else color;
   
   set_done <= col_done or pal_done;
   
   offset_int <= "00" & offset;
   
   
   set_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         col_done     <= '0';
         set_go       <= '0'; 
         address      <= (others => '0');
         briteness    <= (others => '0');
         color_lat    <= (others => '0');
         set_path     <= '0';
         addrsum      <= (others => '0');
         calc_randnum <= '0';
         calc_color   <= '0';
         calc_sel     <= '0';
         calc_addr    <= '0';
         addr64       <= '0';
         setsm        <= s_init;
      elsif rising_edge(clk8) then
         case setsm is
         when s_init =>
            col_done  <= '0';
            set_go    <= '0'; 
            addr64    <= cmd_data(26);
            address   <= "00" & cmd_data(25 downto 20);
            briteness <= cmd_data(19 downto 12);
            color_lat <= cmd_data(11 downto 0);
            if (cmd_inst = x"3") then
               -- use random color and/or address path through states
               set_path <= '0'; 
               setsm    <= s_start;
            elsif (cmd_inst = x"4") then
               set_path <= '1'; -- use command color path through states
               setsm    <= s_start;
            end if;
         when s_start =>
            addrsum <= address + offset_int; -- supports chase module
            setsm   <= s_addrlim;
         when s_addrlim =>
            if (set_path = '0' and (color_lat(0) = '1' or addr64 = '1')) then
               setsm <= s_num; -- change to new random color and/or address
            elsif (set_path = '0' and color_lat(0) = '0') then
               setsm <= s_sel; -- use present random color
            else
               setsm <= s_go; -- use color in command
            end if;
            if (addrsum >= sizeplus1) then
               addrsum <= addrsum - sizeplus1;
            end if;
         when s_num =>
            -- no address and/or color change during fade
            if (random_en = '1') then 
               calc_randnum <= '1';
            end if;
            setsm <= s_dly1;
         when s_dly1 =>
            calc_randnum <= '0';
            setsm        <= s_color;
         when s_color =>
            calc_color   <= '1';
            setsm        <= s_dly2;
         when s_dly2 =>
            calc_color <= '0';
            setsm      <= s_sel;
         when s_sel =>
            if (color_lat(0) = '1') then
               calc_sel <= '1';
            end if;
            if (addr64 = '1') then
               calc_addr <= '1';
            end if;
            setsm <= s_go;
         when s_go =>
            calc_sel  <= '0';
            calc_addr <= '0';
            set_go    <= '1';
            if frame_busy = '1' then
               setsm <= s_wait;
            end if;
         when s_wait =>
            set_go <= '0';
            if frame_busy = '0' then
               setsm <= s_end;
            end if;
         when s_end => 
            col_done <= '1';
            setsm    <= s_init;
         when others => 
            setsm <= s_init;
         end case;
      end if;
   end process;
   
   
   -- random number enable
   random_num_enable_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         random_en <= '1';
      elsif rising_edge(clk8) then
         if (fade_en = '0') then
            random_en <= '1'; -- enable when not fading
         elsif (calc_randnum = '1') then
            random_en <= '0'; -- when fading, disable after first calculation
         elsif (fading = '0') then --new
			--elsif (fade_data = x"01" and fading = '0') then
            -- when fading, re-enable when fade data first starts incrementing
            random_en <= '1'; 
         else --new
				random_en <= '0';
			end if;
      end if;
   end process;
   
   
   feedback <= random(10) xnor random(9);
   -- random number generator
   random_num_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         random <= x"563"; -- can't have an all zero state
      elsif rising_edge(clk8) then
         if (calc_randnum = '1') then
            -- shift in left the XNOR result
            random <= random(10 downto 0) & feedback;
         end if;
      end if;
   end process;
   
   
   -- based on the random number, selects from a list of available colors
   random_color_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         nx_color <= x"37C";
      elsif rising_edge(clk8) then
         if (calc_color = '1') then
            nx_color <= pal_out;
         end if;
      end if;
   end process;
   
   
   -- select output color
   sel_color_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         color <= (others => '0');
      elsif rising_edge(clk8) then
         if (calc_sel = '1') then
            color <= nx_color; --Random Color
         end if;
      end if;
   end process;
   
      
   -- select output random address
   sel_address_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         rand_addr <= (others => '0');
      elsif rising_edge(clk8) then
         if (calc_addr = '1') then
            if (random(9 downto 4) <= sizeplus1(5 downto 0)) then
               -- less than or equal max number of lites
               rand_addr <= random(9 downto 4);
            elsif (random(6) = '0') then -- random(6 downto 5) = "0x"
               rand_addr <= "000" & random(11 downto 9);
            elsif (random(5) = '0') then -- random(6 downto 5) = "10"
               rand_addr <= "010" & random(11 downto 9);
            else -- random(6 downto 5) = "11"
               rand_addr <= "001" & random(11 downto 9);
            end if;
         end if;
      end if;
   end process;
   
   
   -- write to color palette
   palette_proc : process (reset8, clk8)
   begin
      if reset8 = '1' then
         pal_done  <= '0';
         pal_addr  <= (others => '0');
         pal_color <= (others => '0');
         pal_we    <= '0';
         palsm     <= p_init;
      elsif rising_edge(clk8) then
      case palsm is
         when p_init =>
            pal_done  <= '0';
            pal_addr  <= cmd_data(23 downto 20);
            pal_color <= cmd_data(11 downto 0);
            pal_we    <= '0';
            if (cmd_inst = x"9") then
               palsm    <= p_we;
            end if;
         when p_we =>
            pal_we <= '1';
            palsm  <= p_pause;
         when p_pause =>
            pal_we   <= '0';
            palsm    <= p_mem;
         when p_mem =>
            pal_done <= '1';
            palsm    <= p_init;
         end case;
      end if;
   end process;
   
   
   -- Dual Port RAM block containing color palette
   ram_proc : process (reset8, clk8)
   begin
      if (reset8 = '1') then
			pal_out <= (others => '0');
		elsif rising_edge(clk8) then
         pal_out <= palette(conv_integer(random(3 downto 0)));
         if (pal_we = '1') then
            palette(conv_integer(pal_addr)) <= pal_color;
         end if;
      end if;
   end process;
   

end rtl;
