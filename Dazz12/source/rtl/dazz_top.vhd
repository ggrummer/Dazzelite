----------------------------------------------------------------------------------
-- Create Date: 10/17/2020
-- Module Name: dazz_top - rtl
-- 
-- Description: top level for Dazzelite only
-- 
-- Revision: 0.0 - file created
-- 
----------------------------------------------------------------------------------


use work.lites_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dazz_top is
   Port ( 
      disp_sel_n  : in  STD_LOGIC;
		brite_sel_n : in  STD_LOGIC;
		uart_data   : in  STD_LOGIC;
		rst_n			: in  STD_LOGIC;
		osc12		   : in  STD_LOGIC;
		pwr_off		: in  STD_LOGIC;
		buf_en		: out STD_LOGIC;
      tx_data     : out STD_LOGIC
	);
end dazz_top;


architecture rtl of dazz_top is


   -- Component declarations
   component pll12to48 is
		port(
			ref_clk_i	: in std_logic;
			rst_n_i		: in std_logic;
			lock_o		: out std_logic;
			outcore_o	: out std_logic;
			outglobal_o	: out std_logic
		);
	end component;
	
	
	COMPONENT clk48to8s
      PORT (
			soft_reset	: in STD_LOGIC;
			pll_48		: in STD_LOGIC;
			lock  		: in STD_LOGIC;
			clkfast   	: out STD_LOGIC;
			clk8      	: out STD_LOGIC;
			ce1       	: out STD_LOGIC;
			reset8    	: out STD_LOGIC
		);
   END COMPONENT;
   
   
   COMPONENT dazz_neo_main
      PORT (
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
   END COMPONENT;
   
   
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
	
	
	COMPONENT uart_rx
      PORT (
        clk8        : in STD_LOGIC;
        reset8      : in STD_LOGIC;
        uart_data   : in STD_LOGIC;
        rx_data     : out STD_LOGIC_VECTOR (7 downto 0);
        rx_valid    : out STD_LOGIC
      );
   END COMPONENT;
   
   
   COMPONENT rx_ctrl
      PORT (
			clk8        : in STD_LOGIC;
			reset8      : in STD_LOGIC;
			rx_data     : in STD_LOGIC_VECTOR (7 downto 0);
			rx_valid    : in STD_LOGIC;
			prog_ack    : in STD_LOGIC;
			prog_req    : out STD_LOGIC;
			prog_addr   : out STD_LOGIC_VECTOR (9 downto 0);
			prog_word   : out STD_LOGIC_VECTOR (31 downto 0);
			prog_busy   : out STD_LOGIC;
			prog_wr     : out STD_LOGIC;
			soft_reset  : out STD_LOGIC
      );
   END COMPONENT;
   
   
   signal clk8        : std_logic;
   signal clkfast     : std_logic;
   signal ce1         : std_logic;
   signal reset8      : std_logic;
   signal frame_start : std_logic;
   signal frame_busy  : std_logic;
   signal frame_data  : STD_LOGIC_VECTOR (25 downto 0);
	signal rx_data     : STD_LOGIC_VECTOR (7 downto 0);
   signal rx_valid    : STD_LOGIC;
   signal prog_req    : STD_LOGIC;
   signal prog_ack    : STD_LOGIC;
   signal prog_addr   : STD_LOGIC_VECTOR (9 downto 0);
   signal prog_word   : STD_LOGIC_VECTOR (31 downto 0);
   signal prog_wr     : STD_LOGIC;
   signal prog_busy   : STD_LOGIC;
   signal soft_reset  : STD_LOGIC;
	signal main_reset  : STD_LOGIC;
   signal led         : STD_LOGIC_VECTOR (3 downto 0);
   signal sw          : STD_LOGIC_VECTOR (3 downto 0);
   signal neo_busy    : STD_LOGIC;
   signal neo_size    : STD_LOGIC_VECTOR (7 downto 0);
	signal pll_48		 : STD_LOGIC;
	signal lock			 : STD_LOGIC;


begin

	
	main_reset <= soft_reset or pwr_off;
	
	
	pll_0 : pll12to48 
		port map(
			ref_clk_i	=> osc12,
			rst_n_i		=> rst_n, -- Active Low
			lock_o		=> lock,
			outcore_o	=> OPEN,
			outglobal_o	=> pll_48
	);
	
	
	clks_0 : clk48to8s
      PORT MAP (
         soft_reset => main_reset,
			pll_48	  => pll_48,
			lock	  	  => lock,
         clkfast    => clkfast,
         clk8       => clk8,
         ce1        => ce1,
         reset8     => reset8
      );
   
   
   dazz_main_0 : dazz_neo_main
      PORT MAP (
         clk8        	=> clk8,
         clkfast     	=> clkfast,
         reset8      	=> reset8,
         ce1         	=> ce1,
         frame_start 	=> frame_start,
         frame_data  	=> frame_data,
			brite_sel_n		=> brite_sel_n,
			buf_en			=> buf_en,
         neo_busy    	=> neo_busy,
         tx_data     	=> tx_data
      );
   
   
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
   
	
	uart_rx_inst : uart_rx
      port map (
         clk8        => clk8,
         reset8      => reset8,
         uart_data   => uart_data,
         rx_data     => rx_data,
         rx_valid    => rx_valid
      );
   
   
   rx_ctrl_0 : rx_ctrl
      PORT MAP (
         clk8        => clk8,
         reset8      => reset8,
         rx_data     => rx_data,
         rx_valid    => rx_valid,
         prog_req    => prog_req,
         prog_ack    => prog_ack,
         prog_addr   => prog_addr,
         prog_word   => prog_word,
         prog_wr     => prog_wr,
         prog_busy   => prog_busy,
         soft_reset  => soft_reset
      );
		
	
	-- signals not used in this version of the lites projects
	sw				<= (others => '0');
	frame_busy  <= '0'; 
	
   
end rtl;
