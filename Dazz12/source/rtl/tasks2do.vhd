----------------------------------------------------------------------
-- Create Date: 03/19/2019 10:12:49 PM
-- Module Name: tasks2do - rtl
-- By: Grant Grummer
-- 
-- Description: parent level of dazzelite task modules
-- 
-- Revision 0.0 - File Created
-- 
----------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity tasks2do is
    Port ( clk8        : in STD_LOGIC;
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
end tasks2do;


architecture rtl of tasks2do is

   -- Component declarations
   COMPONENT dazz_ctrl
      PORT (
        clk8        : in STD_LOGIC;
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
   END COMPONENT;
   
   
   COMPONENT init_lites
      PORT (
			clk8        : in STD_LOGIC;
			reset8      : in STD_LOGIC;
			frame_busy  : in STD_LOGIC;
			cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
			cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
			sizeplus1   : in STD_LOGIC_VECTOR (7 downto 0);
			init_done   : out STD_LOGIC;
			init_data   : out STD_LOGIC_VECTOR (25 downto 0);
			init_go     : out STD_LOGIC);
   END COMPONENT;
   
   
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
   
   
   COMPONENT chase
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         prog_busy   : in STD_LOGIC;
         fading      : in STD_LOGIC;
         offset      : out STD_LOGIC_VECTOR (5 downto 0);
         neo_size    : out STD_LOGIC_VECTOR (7 downto 0);
         sizeplus1   : out STD_LOGIC_VECTOR (7 downto 0);
         chase_done  : out STD_LOGIC);
   END COMPONENT;
         
   
   COMPONENT pause
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         ce1         : in STD_LOGIC;
         cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
         cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
         pause_done  : out STD_LOGIC);
   END COMPONENT;
	
	
	COMPONENT L2RnR2L
      PORT (
			clk8        : in STD_LOGIC;
			reset8      : in STD_LOGIC;
			frame_busy  : in STD_LOGIC;
			cmd_inst    : in STD_LOGIC_VECTOR (3 downto 0);
			cmd_data    : in STD_LOGIC_VECTOR (27 downto 0);
			neo_size    : in STD_LOGIC_VECTOR (7 downto 0);
			sizeplus1   : in STD_LOGIC_VECTOR (7 downto 0);
			l2r_done    : out STD_LOGIC;
			l2r_data    : out STD_LOGIC_VECTOR (25 downto 0);
			l2r_go      : out STD_LOGIC);
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
	
	
	COMPONENT auto_timeout
      PORT (
         clk8         : IN     STD_LOGIC;
         reset8       : IN     STD_LOGIC;
         cmd_inst     : IN     STD_LOGIC_VECTOR(3 downto 0);
         cmd_data     : IN     STD_LOGIC_VECTOR(27 downto 0);
         blackout     : OUT    STD_LOGIC;
         reload       : OUT    STD_LOGIC;
         timeout_done : OUT    STD_LOGIC
      );
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
   
   
   COMPONENT star_sw
      PORT (
         clk8         : IN     STD_LOGIC;
			ce1			 : IN     STD_LOGIC;
         reset8       : IN     STD_LOGIC;
         psh_butt     : IN     STD_LOGIC;
         disp_addr    : OUT    STD_LOGIC_VECTOR(1 downto 0);
         chng_disp    : OUT    STD_LOGIC
      );
   END COMPONENT;
   
   
   signal cmd_inst     : std_logic_vector (3 downto 0);
   signal cmd_data     : std_logic_vector (27 downto 0);
   signal shared_done  : std_logic;
   signal init_done    : std_logic;
   signal init_data    : std_logic_vector (25 downto 0);
   signal init_go      : std_logic;
   signal set_done     : std_logic;
   signal set_data     : std_logic_vector (25 downto 0);
   signal set_go       : std_logic;
   signal offset       : STD_LOGIC_VECTOR (5 downto 0);
   signal chase_done   : STD_LOGIC;
   signal pause_done   : STD_LOGIC;
	signal l2r_done     : std_logic;
   signal l2r_data     : std_logic_vector (25 downto 0);
   signal l2r_go       : std_logic;
	signal fading       : std_logic;
   signal fade_en      : std_logic;
   signal fade_data    : std_logic_vector (7 downto 0);
	signal fade_done    : std_logic;
   signal blackout     : std_logic;
   signal reload       : std_logic;
	signal timeout_done : std_logic;
   signal dual_busy    : std_logic;
   signal neo_size_int : std_logic_vector (7 downto 0);
   signal sizeplus1    : std_logic_vector (7 downto 0);
   signal disp_addr    : std_logic_vector (1 downto 0);
   signal chng_disp    : std_logic;
	signal rbow_en      : STD_LOGIC;
   signal rbow_data    : STD_LOGIC_VECTOR (11 downto 0);
   signal rbow_done    : STD_LOGIC;
	signal f_start_int  : std_logic;
	signal psh_butt     : std_logic;
   
   -- inlarge if needed then alter processes
   signal latch_start  : std_logic_vector (7 downto 0);

   
begin

   dazz_ctrl_0 : dazz_ctrl
      PORT MAP (
         clk8        => clk8,
         reset8      => reset8,
         shared_done => shared_done,
         prog_req    => prog_req,
         prog_ack    => prog_ack,
         prog_addr   => prog_addr,
         prog_word   => prog_word,
         prog_wr     => prog_wr,
         prog_busy   => prog_busy,
         blackout    => blackout,
         reload      => reload,
         sw          => sw,
         disp_addr   => disp_addr,
         chng_disp   => chng_disp,
         cmd_inst    => cmd_inst,
         cmd_data    => cmd_data,
         led         => led
      );

      
   init_0 : init_lites
      PORT MAP (
         clk8       => clk8,
         reset8     => reset8,
         frame_busy => dual_busy,
         cmd_inst   => cmd_inst,
         cmd_data   => cmd_data,
         sizeplus1  => sizeplus1,
         init_done  => init_done,
         init_data  => init_data,
         init_go    => init_go
      );
      
      
   set_lites_0 : set_lites
      PORT MAP (
         clk8       => clk8,
         reset8     => reset8,
         frame_busy => dual_busy,
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
      
   
   chase_0 : chase
      PORT MAP(
         clk8        => clk8,
         reset8      => reset8,
         cmd_inst    => cmd_inst,
         cmd_data    => cmd_data,
         prog_busy   => prog_busy,
         fading      => fading,
         offset      => offset,
         neo_size    => neo_size_int,
         sizeplus1   => sizeplus1,
         chase_done  => chase_done);
   
   
   pause_0 : pause
      PORT MAP(
         clk8        => clk8,
         reset8      => reset8,
         ce1         => ce1,
         cmd_inst    => cmd_inst,
         cmd_data    => cmd_data,
         pause_done  => pause_done);
   
   
	l2r_0 : L2RnR2L
      PORT MAP (
         clk8       => clk8,
         reset8     => reset8,
         frame_busy => dual_busy,
         cmd_inst   => cmd_inst,
         cmd_data   => cmd_data,
         neo_size   => neo_size_int,
         sizeplus1  => sizeplus1,
         l2r_done   => l2r_done,
         l2r_data   => l2r_data,
         l2r_go     => l2r_go);
	
	
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
      
   
   neo_sw_0 : star_sw
      PORT MAP (
         clk8        => clk8,
			ce1			=> ce1,
         reset8      => reset8,
         psh_butt    => psh_butt,
         disp_addr   => disp_addr,
         chng_disp   => chng_disp
      );
   
	
	timeout_0 : auto_timeout
      PORT MAP (
         clk8         => clk8,
         reset8       => reset8,
         cmd_inst     => cmd_inst,
         cmd_data     => cmd_data,
         blackout     => blackout,
         reload       => reload,
         timeout_done => timeout_done
      );
	
	
	-- add *_go and *_done when new modules are added
   combine_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				frame_start <= '0';
				f_start_int <= '0';
				shared_done <= '0'; 
				latch_start <= (others => '0');
			else
				frame_start <= f_start_int;
				if (init_go = '1' OR set_go = '1' OR l2r_go = '1') then
					f_start_int <= '1';
					latch_start <= "00000" & l2r_go & set_go & init_go;
				elsif (init_done = '1' OR set_done = '1' OR chase_done = '1' OR 
					pause_done = '1' OR l2r_done = '1' OR 
					fade_done = '1' OR timeout_done = '1' OR rbow_done = '1') then
					shared_done <= '1';
					latch_start <= (others => '0');
				else
					f_start_int <= '0';
					shared_done <= '0';
				end if;
			end if;
		end if;
    end process;
    
    
    -- add cases when new modules are added
   mux_data_proc : process (reset8, clk8)
   begin
      if rising_edge(clk8) then
			if reset8 = '1' then
				frame_data  <= (others => '0');
			else
				case latch_start is
				when "00000001" =>
					frame_data  <= init_data;
				when "00000010" =>
					frame_data  <= set_data;
				when"00000100" =>
					frame_data  <= l2r_data;
				when others => 
					frame_data  <= (others => '0');
				end case;
			end if;
		end if;
    end process;
   
   
   -- combine the 2 busys from the 2 framers
   dual_busy    <= frame_busy or neo_busy;
   
   neo_size     <= neo_size_int;
	
	psh_butt		 <= not disp_sel_n;
   
      
end rtl;
