------------------------------------------------------------------------
-- Create Date: 04/8/2020 
-- Module Name: mult8x8 - rtl
-- By: Grant Grummer
-- 
-- Description: 8x8 multiplier, with both inputs & outputs registered.
--    Inferencing Lattice iCE40 DSPs. 
-- 
-- Revision: 0.0
-- 
-----------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;


ENTITY mult8x8 IS
	PORT (
		clk  : IN STD_LOGIC;
		ce	  : IN STD_LOGIC;
		a_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		b_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		prod : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END mult8x8;


ARCHITECTURE rtl OF mult8x8 IS


	component pmi_mult is 
		generic ( 
			pmi_dataa_width : integer := 8; 
			pmi_datab_width : integer := 8; 
			pmi_sign : string := "off"; 
			pmi_additional_pipeline : integer := 0; 
			pmi_input_reg : string := "off"; 
			pmi_output_reg : string := "off"; 
			pmi_family : string := "common"; 
			pmi_implementation : string := "DSP"; 
			module_type : string := "pmi_mult" 
		); 
		port ( 
			Clock : in std_logic; 
			ClkEn : in std_logic; 
			Aclr : in std_logic; 
			DataA : in std_logic_vector((pmi_dataa_width-1) downto 0); 
			DataB : in std_logic_vector((pmi_datab_width-1) downto 0); 
			Result : out std_logic_vector((pmi_dataa_width + pmi_datab_width - 1) downto 0) 
		); 
	end component pmi_mult;

	
BEGIN
	
	mult8x8_inst : pmi_mult
	generic map (
		pmi_dataa_width         => 8,  -- integer
		pmi_datab_width         => 8,  -- integer
		pmi_sign                => "off",  -- "on"|"off"
		pmi_additional_pipeline => 0,  -- integer
		pmi_input_reg           => "on",  -- "on"|"off"
		pmi_output_reg          => "on",  -- "on"|"off"
		pmi_family              => "iCE40UP",  -- "iCE40UP" | "common"
		pmi_implementation      => "DSP"   -- "DSP"|"LUT"
	)
	port map (
		DataA  => a_in,  -- I:
		DataB  => b_in,  -- I:
		Clock  => clk,  -- I:
		ClkEn  => ce,  -- I:
		Aclr   => '0',  -- I:
		Result => prod   -- O:
	);
	
END rtl;