----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 06:07:01 PM
-- Design Name: 
-- Module Name: TransmitterTop - Behavioral
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

entity TransmitterTop is
    Port ( 
						CLK 																		: in STD_LOGIC																			-- Connects to BAUD_CLK
          ;	RESET 																	: in STD_LOGIC																			
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_ENABLE																: in STD_LOGIC																			-- Set low to begin transmit
					; TX_READY																: out STD_LOGIC 																		-- High when transmitting 
					; TX																			: out STD_LOGIC	
				  );
end TransmitterTop;

architecture Behavioral of TransmitterTop is
type TX_STATES is (IDLE, DATA, STOP);
signal cur_state																		: TX_STATES;
signal tx_ready_o																		: std_logic;
signal tx_data_i																		: std_logic_vector(7 downto 0);
signal tx_o																					: std_logic;
signal tx_state																			: integer;

begin
	tx_proc : process (CLK, RESET, TX_ENABLE)
	begin

		if (RESET = '1') then 
			tx_ready_o																		<= '0';
			cur_state																			<= IDLE;
			tx_data_i																			<= (others => '0');
			tx_o																					<= '1';	
			tx_state 																			<= 0;
		elsif(rising_edge(CLK)) then 																																				-- BAUD_CLK
			TX																						<= tx_o;
			TX_READY																			<= tx_ready_o;
			case cur_state is
				when IDLE =>
					tx_ready_o																<= '0';
					tx_o																			<= '1';																							-- No transmission. Back here for stop bit
					tx_state																	<= 0;
					if (TX_ENABLE = '1') then 
						cur_state																<= DATA;
						tx_ready_o															<= '1';																							-- Transmission begins
						tx_o																		<= '0';
						tx_data_i																<= TX_DATA;																					-- Copy tx data into vector
						tx_state																<= 1;
					end if;
					
				when DATA =>
					if (tx_state = 8) then 
						cur_state 															<= STOP;
						tx_state																<= 0;
						tx_o																		<= '1';
					end if;	
					
					tx_o																			<= tx_data_i(0);
					tx_data_i																	<= '0' & tx_data_i (7 downto 1);
					tx_state																	<= tx_state + 1;
					
				when STOP =>
					tx_o																			<= '1';																							-- End bit
					cur_state																	<= IDLE;	
					tx_ready_o																<= '0';
			end case;
		end if;
	end process;
	


end Behavioral;
