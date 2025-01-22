----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 08:18:40 PM
-- Design Name: 
-- Module Name: TransmitterTB - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TransmitterTB is
--  Port ( );
end TransmitterTB;

architecture Behavioral of TransmitterTB is
signal clk																					: std_logic;
signal reset 																				: std_logic;
constant clk_preiod																	: time := 10ns;
signal tx_data 																			: std_logic_vector(7 downto 0);
signal tx_enable																		: std_logic;
signal tx_ready 																		: std_logic;
signal tx 																					: std_logic;
signal tx_control_reg 															: std_logic_vector(31 downto 0);
signal tx_status_reg																: std_logic_vector(31 downto 0);

component TransmitterTop is
    Port ( 
						CLK 																		: in STD_LOGIC																			-- Connects to main clock
          ;	RESET 																	: in STD_LOGIC																			
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_CONTROL															: in STD_LOGIC_VECTOR(31 downto 0) 									-- 31 downto 28 gets baud divisor
					; TX																			: out STD_LOGIC	
					; TX_STATUS																: out STD_LOGIC_VECTOR(31 downto 0)
				  );
end component;



begin
	inst_TX : TransmitterTop
		port map (
								CLK 																=> clk																							
							,	RESET 															=> reset																						
							, TX_DATA															=> tx_data															
							, TX_CONTROL													=> tx_control_reg																	
							, TX																	=> tx
							, TX_STATUS														=> tx_status_reg																			 
							);

	clk_gen : process
	begin
		clk																							<= '1';
		wait for clk_preiod/2;
		clk																							<= '0';
		wait for clk_preiod/2;
	end process;
	
	reset_proc : process
	begin
		reset																						<= '1';
		wait for 50ns;
		reset																						<= '0';
		wait;
	end process;
	
	sim_proc : process
	begin
		wait for 200ns;
		tx_data																					<= "00110011";
		tx_control_reg																	<= x"30000001";
		wait until tx_status_reg = x"00000000";
		tx_control_reg																	<= x"30000000";
		wait for 200ns;
		tx_data																					<= "11011100";
		tx_control_reg																	<= x"30000001";
		wait until tx_status_reg = x"00000000";
		tx_control_reg																	<= x"30000000";
		wait;
	end process;
	
	
	

end Behavioral;
