----------------------------------------------------------------------------------
-- Create Date: 09/8/2014 08:46:52 PM
-- Module Name: dazz_neo_main - rtl
-- By: Grant Grummer
-- 
-- Description: format the data word for transmition to neopixel lites
-- 
-- Revision: 0.0
-- Revision: 0.1 added brightness select push button
-- 
----------------------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity dazz_neo_main is
   Port ( 
		clk8        	: in STD_LOGIC;
      clkfast     	: in STD_LOGIC;
      reset8      	: in STD_LOGIC;
      ce1         	: in STD_LOGIC;
      frame_start 	: in STD_LOGIC;
      frame_data  	: in STD_LOGIC_VECTOR (25 downto 0);
		brite_sel_n		: in STD_LOGIC;
		buf_en			: out STD_LOGIC;
      neo_busy    	: out STD_LOGIC;
      tx_data     	: out STD_LOGIC
	);
end dazz_neo_main;


architecture rtl of dazz_neo_main is
   
   
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
	
	
	COMPONENT dazz_color_brite
      PORT (
         clk8        : in STD_LOGIC;
			reset8      : in STD_LOGIC;
			frame_start : in STD_LOGIC;
			frame_data  : in STD_LOGIC_VECTOR (25 downto 0);
			brite_sel   : in STD_LOGIC_VECTOR (1 downto 0);
			neo_start	: out STD_LOGIC;
			neo_data    : out STD_LOGIC_VECTOR (23 downto 0)
      );
   END COMPONENT;
	
	
	COMPONENT sftbyn
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         frame_start : in STD_LOGIC;
         frame_data  : in STD_LOGIC_VECTOR (25 downto 0);
         sftbynum    : in STD_LOGIC_VECTOR (7 downto 0);
         sftbymax    : in STD_LOGIC_VECTOR (7 downto 0);
         neo_addr    : out STD_LOGIC_VECTOR (7 downto 0)
      );
   END COMPONENT;
	
	
	COMPONENT neo_ctrl
      PORT (
         clk8        : in STD_LOGIC;
         reset8      : in STD_LOGIC;
         frame_start : in STD_LOGIC;
         fm_busy     : in STD_LOGIC;
         neo_busy    : out STD_LOGIC;
         fm_go       : out STD_LOGIC
      );
   END COMPONENT;
   
   
   COMPONENT neo_dpr
      PORT (
			rclk  : IN  STD_LOGIC;
			ren   : IN  STD_LOGIC;
			raddr : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			rdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			wclk  : IN  STD_LOGIC;
			wen   : IN  STD_LOGIC;
			waddr : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			wdata : IN  STD_LOGIC_VECTOR(23 DOWNTO 0)
      );
   END COMPONENT;
   
   
   COMPONENT neo_framer
      PORT (
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
   END COMPONENT;
   
   
   signal neo_start    : std_logic;
   signal neo_data     : std_logic_vector (23 downto 0);
   signal neo_addr     : std_logic_vector (7 downto 0);
	signal fm_go        : std_logic;
   signal fm_busy      : std_logic;
	signal psh_butt_b	  : std_logic;
	signal brite_sel	  : std_logic_vector (1 downto 0);
   signal dp_data      : std_logic_vector (23 downto 0);
   signal dp_addr      : std_logic_vector (7 downto 0);
   signal dp_rd_en     : std_logic;

   
begin


	buf_en		<= reset8;
	
	psh_butt_b <= not brite_sel_n;
   
   
   brite_sw_0 : star_sw
      PORT MAP (
         clk8        => clk8,
			ce1			=> ce1,
         reset8      => reset8,
         psh_butt    => psh_butt_b,
         disp_addr   => brite_sel,
         chng_disp   => OPEN
      );
	
	
	dazz_color_brite_0 : dazz_color_brite
      PORT MAP (
         clk8        => clk8,
			reset8      => reset8,
			frame_start => frame_start,
			frame_data  => frame_data,
			brite_sel	=> brite_sel,
			neo_start   => neo_start,
			neo_data    => neo_data
      );
	
	
	sftbyn_0 : sftbyn
      PORT MAP (
         clk8        => clk8,
         reset8      => reset8,
         frame_start => frame_start,
         frame_data  => frame_data,
         sftbynum    => SFTBYNUM,
         sftbymax    => SFTBYMAX,
         neo_addr    => neo_addr
      );
	
	
	neo_ctrl_0 : neo_ctrl
      PORT MAP (
         clk8        => clk8,
         reset8      => reset8,
         frame_start => frame_start,
         fm_busy     => fm_busy,
         neo_busy    => neo_busy,
         fm_go       => fm_go
      );
	
   
   neo_dpr_0 : neo_dpr
      PORT MAP (
			rclk  	=> clkfast,
			ren   	=> dp_rd_en,
			raddr 	=> dp_addr,
			rdata 	=> dp_data,
			wclk  	=> clk8,
			wen   	=> neo_start,
			waddr 	=> neo_addr,
			wdata 	=> neo_data
      );
	
   
   neo_framer_0 : neo_framer
      PORT MAP (
         clkfast     => clkfast,
         reset8      => reset8,
         ce1         => ce1,
         dp_rd_en    => dp_rd_en,
         dp_addr     => dp_addr,
         dp_data     => dp_data,
         fm_busy     => fm_busy,
         fm_go       => fm_go,
         neo_size    => TOTAL_MINUS1,
         tx_data     => tx_data
      );
      

end rtl;
