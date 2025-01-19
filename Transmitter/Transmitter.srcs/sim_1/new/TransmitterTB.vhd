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

component TransmitterTop is
    Port ( 
						CLK 																		: in STD_LOGIC																			-- Connects to BAUD_CLK
          ;	RESET 																	: in STD_LOGIC																			
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_ENABLE																: in STD_LOGIC 																			-- Set low to begin transmit
					; TX_READY																: out STD_LOGIC 																		-- High when transmitting 
					; TX																			: out STD_LOGIC	
				  );
end component;



begin
	inst_TX : TransmitterTop
		port map (
								CLK 																=> clk																							-- Connects to BAUD_CLK
							,	RESET 															=> reset																						
							, TX_DATA															=> tx_data															
							, TX_ENABLE														=> tx_enable																				-- Set low to begin transmit
							, TX_READY														=> tx_ready																					-- High when transmitting 
							, TX																	=> tx
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
		wait for 100ns;
		tx_data																					<= "00000000";
		tx_enable																				<= '0';
		wait for 100ns;
		tx_data																					<= "00110011";
		tx_enable																				<= '1';
		wait for 90ns;
		tx_enable																				<= '0';
		wait;
	end process;
	
	
	

end Behavioral;
