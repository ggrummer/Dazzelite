----------------------------------------------------------------------
-- Create Date: 06/1/2020
-- Module Name: set_fade_rbow_tb
-- By: Grant Grummer
-- 
-- Description: tests set, fade & rbow rtl. 
-- 
-- Revision 0.0
-- 
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;


entity set_fade_rbow_tb is
end set_fade_rbow_tb;


ARCHITECTURE rtl OF set_fade_rbow_tb IS
   
   
	COMPONENT set_lites
      PORT (
			clk8        : in STD_LOGIC;
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
   END COMPONENT;
	
	
	COMPONENT fade
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         prog_busy   : in STD_LOGIC;
         fading      : out STD_LOGIC;
         fade_en     : out STD_LOGIC;
         fade_data   : out STD_LOGIC_VECTOR (7 downto 0);
         fade_done   : out STD_LOGIC);
   END COMPONENT;
	
	
	COMPONENT rainbow
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         prog_busy   : in STD_LOGIC;
         rbow_en     : out STD_LOGIC;
         rbow_data   : out STD_LOGIC_VECTOR (11 downto 0);
         rbow_done   : out STD_LOGIC);
   END COMPONENT;
	
	
	signal clktb     : std_logic;
   signal rst       : std_logic;
	
	signal clk8        : STD_LOGIC;
   signal reset8      : STD_LOGIC;
   signal cmd_inst    : STD_LOGIC_VECTOR (3 downto 0);
   signal cmd_data    : STD_LOGIC_VECTOR (27 downto 0);
   signal prog_busy 	 : STD_LOGIC;
	signal frame_busy  : std_logic;
	signal offset      : STD_LOGIC_VECTOR (5 downto 0);
	signal sizeplus1   : std_logic_vector (7 downto 0);
	signal set_done    : std_logic;
   signal set_data    : std_logic_vector (25 downto 0);
   signal set_go      : std_logic;
	signal fading      : std_logic;
   signal fade_en     : std_logic;
   signal fade_data   : std_logic_vector (7 downto 0);
	signal fade_done   : std_logic;
   signal rbow_en     : STD_LOGIC;
   signal rbow_data   : STD_LOGIC_VECTOR (11 downto 0);
   signal rbow_done   : STD_LOGIC;
   
BEGIN
   
   set_lites_0 : set_lites
      PORT MAP (
         clk8       => clk8,
         reset8     => reset8,
         frame_busy => frame_busy,
         cmd_inst   => cmd_inst,
         cmd_data   => cmd_data,
         offset     => offset,
         sizeplus1  => sizeplus1,
         fade_en    => fade_en,
         fade_data  => fade_data,
         fading     => fading,
			rbow_en	  => rbow_en,
			rbow_data  => rbow_data,
         set_done   => set_done,
         set_data   => set_data,
         set_go     => set_go
      );
		
	fade_0 : fade
      PORT MAP (
         clk8       => clk8,
         reset8     => reset8,
         cmd_inst    => cmd_inst,
         cmd_data    => cmd_data,
         prog_busy   => prog_busy,
         fading      => fading,
         fade_en     => fade_en,
         fade_data   => fade_data,
         fade_done   => fade_done);
	
	rainbow_0 : rainbow
		PORT MAP (
			clk8      => clk8,
			reset8    => reset8,
			cmd_inst  => cmd_inst,
			cmd_data  => cmd_data,
			prog_busy => prog_busy,
			rbow_en   => rbow_en,
			rbow_data => rbow_data,
			rbow_done => rbow_done
		);
	
   clk8   <= clktb;
   reset8 <= rst;
  
   rst    <= '1', '0' after 72 ns;
  
  
   clk_proc : process
   begin
     loop
       clktb <= '1';
       wait for 8 ns;
       clktb <= '0';
       wait for 8 ns;
     end loop;
     wait;
   end process;
   
   
   data_proc : process
   begin
      cmd_inst  	<= (others => '1');
      cmd_data  	<= (others => '0');
      prog_busy 	<= '0';
		frame_busy	<= '0';
		offset	 	<= "000000";
		sizeplus1 	<= x"07"; -- 7 leds
      wait for 145 ns;
      
      for I in 0 to 400 loop
			
			-- set LED 0 to random color
         cmd_inst <= x"3"; -- set random color instruction
         cmd_data <= x"0008001"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 1 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0108000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 2 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0208000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 3 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0308000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 4 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0408000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 5 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0508000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- set LED 6 to same color
         cmd_inst <= x"3"; -- set same color instruction
         cmd_data <= x"0608000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait for 96 ns;
			frame_busy <= '1';
			wait for 96 ns;
			frame_busy <= '0';
			wait until set_done = '1';
         wait for 48 ns;
			
			-- fade instruction
         cmd_inst <= x"7"; -- fade instruction
         cmd_data <= x"3E01000"; 
         wait for 16 ns;
         cmd_inst <= x"F"; -- null instruction
         cmd_data <= x"0000000"; 
         wait until fade_done = '1';
         wait for 48 ns;
			
		end loop;
		
		
		-- for I in 0 to 100 loop
      
         -- -- first rainbow instruction
         -- cmd_inst <= x"B"; -- rainbow instruction
         -- cmd_data <= x"0001000"; -- enable rainbow
         -- wait for 16 ns;
         -- cmd_inst <= x"F"; -- null instruction
         -- cmd_data <= x"0000000"; 
         -- wait until rbow_done = '1';
         -- wait for 48 ns;
      
      -- end loop;
      
      
      -- for I in 0 to 200 loop
      
         -- -- second rainbow instruction
         -- cmd_inst <= x"B"; -- rainbow instruction
         -- cmd_data <= x"0001000"; -- enable rainbow
         -- wait for 16 ns;
         -- cmd_inst <= x"F"; -- null instruction
         -- cmd_data <= x"0000000"; 
         -- wait until rbow_done = '1';
         -- wait for 48 ns;
      
      -- end loop;
      
      
      -- for I in 0 to 5 loop
      
         -- -- third rainbow instruction
         -- cmd_inst <= x"B"; -- rainbow instruction
         -- cmd_data <= x"0000000"; -- disable rainbow
         -- wait for 16 ns;
         -- cmd_inst <= x"F"; -- null instruction
         -- cmd_data <= x"0000000"; -- pause 5 x delay
         -- wait until rbow_done = '1';
         -- wait for 48 ns;
      
      -- end loop;
      
      wait for 32 ns;
        assert false
          report "Lites Set, Fade, Rainbow Simulation Done " & cr
          severity failure;
        wait;
     end process;
   
   
END rtl;
