----------------------------------------------------------------------
-- Create Date: 02/19/2014
-- Module Name: fade_tb - upper level test bench 
-- By: Grant Grummer
-- 
-- Description: connects fade_tester with fade rtl. 
-- 
-- Revision 0.3 - test revision 0.3 and above
-- 
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;


ENTITY fade_tb IS
END fade_tb;


-- LIBRARY lites_lib;
-- USE lites_lib.ALL;


ARCHITECTURE rtl OF fade_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL clk8      : STD_LOGIC;
   SIGNAL reset8    : STD_LOGIC;
   SIGNAL cmd_inst  : STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL cmd_data  : STD_LOGIC_VECTOR(27 downto 0);
   SIGNAL prog_busy : STD_LOGIC;
   SIGNAL fading    : STD_LOGIC;
   SIGNAL fade_en   : STD_LOGIC;
   SIGNAL fade_data : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL fade_done : STD_LOGIC;


   -- Component declarations
   COMPONENT fade
      PORT (
         clk8      : IN     STD_LOGIC;
         reset8    : IN     STD_LOGIC;
         cmd_inst  : IN     STD_LOGIC_VECTOR(3 downto 0);
         cmd_data  : IN     STD_LOGIC_VECTOR(27 downto 0);
         prog_busy : IN     STD_LOGIC;
         fading    : OUT    STD_LOGIC;
         fade_en   : OUT    STD_LOGIC;
         fade_data : OUT    STD_LOGIC_VECTOR(7 downto 0);
         fade_done : OUT    STD_LOGIC
      );
   END COMPONENT;

   COMPONENT fade_tester
      PORT (
         clk8      : OUT    STD_LOGIC;
         reset8    : OUT    STD_LOGIC;
         cmd_inst  : OUT    STD_LOGIC_VECTOR(3 downto 0);
         cmd_data  : OUT    STD_LOGIC_VECTOR(27 downto 0);
         prog_busy : OUT    STD_LOGIC;
         fading    : IN     STD_LOGIC;
         fade_en   : IN     STD_LOGIC;
         fade_data : IN     STD_LOGIC_VECTOR(7 downto 0);
         fade_done : IN     STD_LOGIC
      );
   END COMPONENT;

BEGIN

         FADE_0 : fade
            PORT MAP (
               clk8      => clk8,
               reset8    => reset8,
               cmd_inst  => cmd_inst,
               cmd_data  => cmd_data,
               prog_busy => prog_busy,
               fading    => fading,
               fade_en   => fade_en,
               fade_data => fade_data,
               fade_done => fade_done
            );

         TEST_1 : fade_tester
            PORT MAP (
               clk8      => clk8,
               reset8    => reset8,
               cmd_inst  => cmd_inst,
               cmd_data  => cmd_data,
               prog_busy => prog_busy,
               fading    => fading,
               fade_en   => fade_en,
               fade_data => fade_data,
               fade_done => fade_done
            );


END rtl;