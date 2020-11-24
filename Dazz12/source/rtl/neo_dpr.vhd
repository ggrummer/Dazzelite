----------------------------------------------------------------------------------
-- Create Date: 04/11/2020 
-- Module Name: neo_dpr - rtl
-- By: Grant Grummer
-- 
-- Description: 256 x 24 dual port RAM using two 256 x 16 RAMs 
-- 
-- Revision: 0.0
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity neo_dpr is
   Port (
		rclk  : IN  STD_LOGIC;
		ren   : IN  STD_LOGIC;
		raddr : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		rdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		wclk  : IN  STD_LOGIC;
		wen   : IN  STD_LOGIC;
		waddr : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		wdata : IN  STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
end neo_dpr;


architecture rtl of neo_dpr is

	
	component pmi_ram_dp is 
		generic ( 
			pmi_wr_addr_depth : integer := 256; 
			pmi_wr_addr_width : integer := 8; 
			pmi_wr_data_width : integer := 24; 
			pmi_rd_addr_depth : integer := 256; 
			pmi_rd_addr_width : integer := 8; 
			pmi_rd_data_width : integer := 24; 
			pmi_regmode : string := "noreg"; 
			pmi_gsr : string := "disable"; 
			pmi_resetmode : string := "sync"; 
			pmi_optimization : string := "area"; 
			pmi_init_file : string := "none"; 
			pmi_init_file_format : string := "hex"; 
			pmi_family : string := "common"; 
			module_type : string := "pmi_ram_dp" 
		); 
		port ( 
			Data : in std_logic_vector((pmi_wr_data_width-1) downto 0); 
			WrAddress : in std_logic_vector((pmi_wr_addr_width-1) downto 0); 
			RdAddress : in std_logic_vector((pmi_rd_addr_width-1) downto 0); 
			WrClock: in std_logic; 
			RdClock: in std_logic; 
			WrClockEn: in std_logic; 
			RdClockEn: in std_logic; 
			WE: in std_logic; 
			Reset: in std_logic; 
			Q : out std_logic_vector((pmi_rd_data_width-1) downto 0) 
		); 
	end component pmi_ram_dp;
	
	
	signal rdata_up     : std_logic_vector (15 downto 0);
	signal rdata_lo     : std_logic_vector (15 downto 0);
	signal wdata_up     : std_logic_vector (15 downto 0);
	signal wdata_lo     : std_logic_vector (15 downto 0);
	
	
begin
	
	
	dp_ram256x24_inst : pmi_ram_dp
	generic map (
		pmi_wr_addr_depth    => 256, -- integer
		pmi_wr_addr_width    => 8, -- integer
		pmi_wr_data_width    => 24, -- integer
		pmi_rd_addr_depth    => 256, -- integer
		pmi_rd_addr_width    => 8, -- integer
		pmi_rd_data_width    => 24, -- integer
		pmi_regmode          => "noreg", -- "reg"|"noreg"
		pmi_resetmode        => "sync", -- "async"|"sync"
		pmi_init_file        => "none", -- string
		pmi_init_file_format => "hex", -- "binary"|"hex"
		pmi_family           => "iCE40UP"  -- "iCE40UP" | "common"
	)
	port map (
		Data      => wdata,  -- I:
		WrAddress => waddr,  -- I:
		RdAddress => raddr,  -- I:
		WrClock   => wclk,  -- I:
		RdClock   => rclk,  -- I:
		WrClockEn => wen,  -- I:
		RdClockEn => ren,  -- I:
		WE        => wen,  -- I:
		Reset     => '0',  -- I:
		Q         => rdata   -- O:
	);
	
	
end rtl;