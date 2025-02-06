----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 05:07:36 PM
-- Design Name: 
-- Module Name: BaudGenTB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BaudGenTB is
--  Port ( );
end BaudGenTB;

architecture Behavioral of BaudGenTB is
signal clk 																					: std_logic;
signal reset 																				: std_logic;
constant clk_period																	: time:=10ns;
signal baud_cycles																	: std_logic_vector(15 downto 0);
signal baud_clk																			: std_logic;
signal baud_clk_reset																: std_logic;


component BaudGenTop is
    Port ( 	CLK 																		: in STD_LOGIC
          ;	RESET 																	: in STD_LOGIC
					; BAUD_CLK_RESET													: in STD_LOGIC
					; BAUD_CYCLES_REQ													: in STD_LOGIC_VECTOR(15 downto 0) -- How many main clock cycles for each baud clock cycle
          ; BAUD_CLK      													: out STD_LOGIC
					);
end component;

begin
	inst_uut : BaudGenTop
		port map(
							CLK																	=> clk
						, RESET 															=> reset
						, BAUD_CLK_RESET											=> baud_clk_reset
						, BAUD_CYCLES_REQ 										=> baud_cycles
						, BAUD_CLK														=> baud_clk
						);
	
	clk_gen : process
	begin
		clk																						<= '1';
		wait for clk_period/2;
		clk																						<= '0';
		wait for clk_period/2;
	end process;
	
	reset_proc : process
	begin
		reset																					<= '1';
		wait for 50ns;
		reset																					<= '0';
		wait;
	end process;
	
	sim_proc : process
	begin
		baud_cycles																		<= "0010100010110000";
		baud_clk_reset																<= '0';
		wait for 5ms;
		baud_cycles																		<= "0001010001011000";
		wait for 1ms;
		baud_clk_reset																<= '1';
		wait for 50000ns;
		baud_clk_reset																<= '0';
		wait;
	end process;


end Behavioral;
