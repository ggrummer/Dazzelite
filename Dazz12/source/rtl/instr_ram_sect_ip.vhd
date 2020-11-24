----------------------------------------------------------------------
-- Create Date: 04/11/2020 
-- Module Name: instr_ram_sect_ip - rtl
-- By: Grant Grummer
-- 
-- Description: Four 256 x 32 banks of dual port RAMs, using 
--			 eight 256 x 16 iCE40 ENRs
-- 
-- Revision: 0.0
-- 
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
--USE ieee.std_logic_unsigned.all;


entity instr_ram_sect_ip is
   Port (
		reset8	: IN  STD_LOGIC;
		rclk  	: IN  STD_LOGIC;
		ren   	: IN  STD_LOGIC;
		raddr 	: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		rdata 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		wclk  	: IN  STD_LOGIC;
		wen   	: IN  STD_LOGIC;
		waddr 	: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		wdata 	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end instr_ram_sect_ip;


architecture rtl of instr_ram_sect_ip is
	
	
	component instr_dpram_sect0 is
		port(
			wr_clk_i : 		in std_logic;
			rd_clk_i : 		in std_logic;
			rst_i : 			in std_logic;
			wr_clk_en_i : 	in std_logic;
			rd_en_i : 		in std_logic;
			rd_clk_en_i : 	in std_logic;
			wr_en_i : 		in std_logic;
			wr_data_i : 	in std_logic_vector(31 downto 0);
			wr_addr_i : 	in std_logic_vector(7 downto 0);
			rd_addr_i : 	in std_logic_vector(7 downto 0);
			rd_data_o : 	out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	component instr_dpram_sect1 is
		port(
			wr_clk_i : 		in std_logic;
			rd_clk_i : 		in std_logic;
			rst_i : 			in std_logic;
			wr_clk_en_i : 	in std_logic;
			rd_en_i : 		in std_logic;
			rd_clk_en_i : 	in std_logic;
			wr_en_i : 		in std_logic;
			wr_data_i : 	in std_logic_vector(31 downto 0);
			wr_addr_i : 	in std_logic_vector(7 downto 0);
			rd_addr_i : 	in std_logic_vector(7 downto 0);
			rd_data_o : 	out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	component instr_dpram_sect2 is
		port(
			wr_clk_i : 		in std_logic;
			rd_clk_i : 		in std_logic;
			rst_i : 			in std_logic;
			wr_clk_en_i : 	in std_logic;
			rd_en_i : 		in std_logic;
			rd_clk_en_i : 	in std_logic;
			wr_en_i : 		in std_logic;
			wr_data_i : 	in std_logic_vector(31 downto 0);
			wr_addr_i : 	in std_logic_vector(7 downto 0);
			rd_addr_i : 	in std_logic_vector(7 downto 0);
			rd_data_o : 	out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	component instr_dpram_sect3 is
		port(
			wr_clk_i : 		in std_logic;
			rd_clk_i : 		in std_logic;
			rst_i : 			in std_logic;
			wr_clk_en_i : 	in std_logic;
			rd_en_i : 		in std_logic;
			rd_clk_en_i : 	in std_logic;
			wr_en_i : 		in std_logic;
			wr_data_i : 	in std_logic_vector(31 downto 0);
			wr_addr_i : 	in std_logic_vector(7 downto 0);
			rd_addr_i : 	in std_logic_vector(7 downto 0);
			rd_data_o : 	out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	signal ren0	: std_logic;
	signal ren1	: std_logic;
	signal ren2	: std_logic;
	signal ren3	: std_logic;
	signal wen0	: std_logic;
	signal wen1	: std_logic;
	signal wen2	: std_logic;
	signal wen3	: std_logic;
	signal rdata0 : std_logic_vector (31 downto 0);
	signal rdata1 : std_logic_vector (31 downto 0);
	signal rdata2 : std_logic_vector (31 downto 0);
	signal rdata3 : std_logic_vector (31 downto 0);
	
	
begin
	
	
	ren0 <= ren and (not raddr(9)) and (not raddr(8));
	ren1 <= ren and (not raddr(9)) and (raddr(8));
	ren2 <= ren and (raddr(9)) and (not raddr(8));
	ren3 <= ren and (raddr(9)) and (raddr(8));
	wen0 <= wen and (not waddr(9)) and (not waddr(8));
	wen1 <= wen and (not waddr(9)) and (waddr(8));
	wen2 <= wen and (waddr(9)) and (not waddr(8));
	wen3 <= wen and (waddr(9)) and (waddr(8));
	
	rdata <= rdata0 when (raddr(9) = '0' and raddr(8) = '0') else
				rdata1 when (raddr(9) = '0' and raddr(8) = '1') else
				rdata2 when (raddr(9) = '1' and raddr(8) = '0') else
				rdata3;
	
	
	dp_ram256x32_inst0 : instr_dpram_sect0 
		port map(
			wr_clk_i		=> wclk,
			rd_clk_i		=> rclk,
			rst_i			=> reset8,
			wr_clk_en_i	=> wen0,
			rd_en_i		=> ren0,
			rd_clk_en_i	=> ren0,
			wr_en_i		=> wen0,
			wr_data_i	=> wdata,
			wr_addr_i	=> waddr(7 downto 0),
			rd_addr_i	=> raddr(7 downto 0),
			rd_data_o	=> rdata0
		);
	
	
	dp_ram256x32_inst1 : instr_dpram_sect1 
		port map(
			wr_clk_i		=> wclk,
			rd_clk_i		=> rclk,
			rst_i			=> reset8,
			wr_clk_en_i	=> wen1,
			rd_en_i		=> ren1,
			rd_clk_en_i	=> ren1,
			wr_en_i		=> wen1,
			wr_data_i	=> wdata,
			wr_addr_i	=> waddr(7 downto 0),
			rd_addr_i	=> raddr(7 downto 0),
			rd_data_o	=> rdata1
		);
	
	
	dp_ram256x32_inst2 : instr_dpram_sect2 
		port map(
			wr_clk_i		=> wclk,
			rd_clk_i		=> rclk,
			rst_i			=> reset8,
			wr_clk_en_i	=> wen2,
			rd_en_i		=> ren2,
			rd_clk_en_i	=> ren2,
			wr_en_i		=> wen2,
			wr_data_i	=> wdata,
			wr_addr_i	=> waddr(7 downto 0),
			rd_addr_i	=> raddr(7 downto 0),
			rd_data_o	=> rdata2
		);
	
	
	dp_ram256x32_inst3 : instr_dpram_sect3 
		port map(
			wr_clk_i		=> wclk,
			rd_clk_i		=> rclk,
			rst_i			=> reset8,
			wr_clk_en_i	=> wen3,
			rd_en_i		=> ren3,
			rd_clk_en_i	=> ren3,
			wr_en_i		=> wen3,
			wr_data_i	=> wdata,
			wr_addr_i	=> waddr(7 downto 0),
			rd_addr_i	=> raddr(7 downto 0),
			rd_data_o	=> rdata3
		);
	
	
end rtl;