----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/20/2025 12:35:39 PM
-- Design Name: 
-- Module Name: UARTTop - Behavioral
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

entity UARTTop is
			Port ( 
							CLK																		: in STD_LOGIC
						; RESET 																: in STD_LOGIC 
						; BAUD_RATE                             : in integer
						; TX_DATA																: in STD_LOGIC_VECTOR(7 downto 0)
						; TX_ENABLE															: in std_logic
						; TX_READY															: out STD_LOGIC
						; RX_DATA 															: out STD_LOGIC_VECTOR(7 downto 0)
						; RX_READY															: out STD_LOGIC
						);
end UARTTop;

architecture Behavioral of UARTTop is

-- For BaudGenTop
signal sample_clk																		: std_logic;											-- Sample clock for transmitter and receiver
signal baud_clk_reset_i															: std_logic;
signal baud_rate_internal														: integer;												-- Set Required Baud 
constant clk_frequency															: integer:=100000000;							-- Set clock frequency of board (Hz)
signal baud_cycles_req_i														: std_logic_vector(15 downto 0);

-- For TransmitterTop
signal tx_data_i																		: std_logic_vector(7 downto 0);
signal tx_enable_i																	: std_logic;
signal tx_ready_o																		: std_logic;											-- Connects to TX_READY of ReceiverTop. Indicates output available
signal tx_o																					: std_logic;											-- Output bit stream. Connects to Rx of ReceiverTop

-- For ReceiverTop
signal rx_data_o																		: std_logic_vector(7 downto 0);
signal rx_ready_o																		: std_logic;


-- Baud Clock Generator 
component BaudGenTop is 
		Port ( 	CLK 																		: in STD_LOGIC
          ;	RESET 																	: in STD_LOGIC
					; BAUD_CLK_RESET													: in STD_LOGIC										 -- Sync clock for when transmission begins
					; BAUD_CYCLES_REQ													: in STD_LOGIC_VECTOR(15 downto 0) -- How many main clock cycles for each baud clock cycle
          ; BAUD_CLK 			 													: out STD_LOGIC
					);
end component;

-- Transmitter
component TransmitterTop is
    Port ( 
						CLK 																		: in STD_LOGIC										-- Connects to BAUD_CLK
          ;	RESET 																	: in STD_LOGIC										
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_ENABLE																: in STD_LOGIC										-- Set low to begin transmit
					; TX_READY																: out STD_LOGIC 									-- High when transmitting 
					; TX																			: out STD_LOGIC	
				  );
end component;

-- Receiver 

component ReceiverTop is
		Port ( 
						CLK																			: in STD_LOGIC
					;	RESET 																	: in STD_LOGIC
					;	DATA_IN																	: in STD_LOGIC										-- TX of Transmitter Top
					; TX_READY																: in STD_LOGIC										-- TX_READY of Transmitter Top
					; RX_DATA																	: out STD_LOGIC_VECTOR(7 downto 0)
					; RX_READY																: out STD_LOGIC				
					);
end component;


begin
	
	
	inst_BaudGen : BaudGenTop
		port map(
							 	CLK 																=> CLK
							,	RESET 															=> RESET
							, BAUD_CLK_RESET											=> baud_clk_reset_i
							, BAUD_CYCLES_REQ											=> baud_cycles_req_i
							, BAUD_CLK 			 											=> sample_clk
							);
							
	inst_Tx	: TransmitterTop
		port map( 
					  		CLK 																=> sample_clk 
					  	,	RESET 															=> RESET  
					  	, TX_DATA															=> tx_data_i
					  	, TX_ENABLE														=> tx_enable_i
					  	, TX_READY														=> tx_ready_o 
					  	, TX																	=> tx_o 
					  	);
							
	inst_Rx : ReceiverTop
		port map ( 
								CLK																	=> sample_clk
							,	RESET 															=> RESET
							,	DATA_IN															=> tx_o
							, TX_READY														=> tx_ready_o
							, RX_DATA															=> rx_data_o
							, RX_READY														=> rx_ready_o
							);
							
		
	clk_cycle_proc : process (CLK, RESET)
	begin
		if (RESET = '1') then 
			baud_clk_reset_i															<= '0';
			tx_enable_i																		<= '0';
		elsif(rising_edge(CLK)) then
			tx_data_i																			<= TX_DATA;
			tx_enable_i																		<= TX_ENABLE;
			TX_READY																			<= tx_ready_o;
			baud_rate_internal														<= BAUD_RATE;
			baud_cycles_req_i															<= std_logic_vector(to_unsigned(clk_frequency/baud_rate_internal, 16));
			RX_DATA																				<= rx_data_o;
			RX_READY																			<= rx_ready_o;
		end if;
	end process;


end Behavioral;
