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
-- UARTTop -------------------------------------------------------
-- Use BAUD_SELECT to select baud rate using the following key:
-- case TX_CONTROL(31 downto 28) is
--         when x"1"     			=> baud_divisor <= x"05161";  --    2400
--         when x"2"     			=> baud_divisor <= x"028b0";  --    4800
--         when x"3"     			=> baud_divisor <= x"01458";  --    9600
--         when x"4"     			=> baud_divisor <= x"00d90";  --   14400
--         when x"5"     			=> baud_divisor <= x"00a2c";  --   19200
--         when x"6"     			=> baud_divisor <= x"006c8";  --   28800
--         when x"7"     			=> baud_divisor <= x"00516";  --   38400 
--         when x"8"     			=> baud_divisor <= x"00364";  --   57600
--         when x"9"     			=> baud_divisor <= x"0028b";  --   76800
--         when x"a"     			=> baud_divisor <= x"001b2";  --  115200
--         when x"b"     			=> baud_divisor <= x"000d9";  --  230400
--         when x"c"     			=> baud_divisor <= x"0006c";  --  460800
--         when x"d"     			=> baud_divisor <= x"00036";  --  921600
--         when others   			=> baud_divisor <= x"001b2";  --  115200 (default)
-- end case;
------------------------------------------------------------------
-- Transmitter ---------------------------------------------------
-- TX_CONTROL 								-> 31 - 28 : baud divisor select
-- 																		 0 : enable transmission
-- TX_STATUS									-> 			 0 : transmission ongoing (tx_ongoing)
------------------------------------------------------------------
-- Receiver ------------------------------------------------------
-- RX_CONTROL 								-> 31 - 28 : baud divisor select
-- 																		 0 : RX_ENABLE is tx_ongoing ie TX_STATUS(0)
-- RX_STATUS									-> 			 4 : rx_error 
--																		 0 : received data ready (RX_READY)
------------------------------------------------------------------


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
						; TX_CONTROL														: in STD_LOGIC_VECTOR(31 downto 0)
						; RX_CONTROL														: in STD_LOGIC_VECTOR(31 downto 0)
						; TX_DATA																: in STD_LOGIC_VECTOR(7 downto 0)
						; RX_DATA 															: out STD_LOGIC_VECTOR(7 downto 0)
						; TX_STATUS															: out STD_LOGIC_VECTOR(31 downto 0)
						; RX_STATUS															: out STD_LOGIC_VECTOR(31 downto 0)
						);
end UARTTop;

architecture Behavioral of UARTTop is

-- For TransmitterTop
signal tx_data_i																		: std_logic_vector(7 downto 0);
signal tx_control_reg																: std_logic_vector(31 downto 0);
signal tx_status_reg																: std_logic_vector(31 downto 0);											
signal tx_o																					: std_logic;											-- Output bit stream. Connects to Rx of ReceiverTop
signal tx_busy																			: std_logic;											-- When transmitter is transmitting. Same as tx_ongoing.

-- For ReceiverTop
signal rx_data_o																		: std_logic_vector(7 downto 0);
signal rx_control_reg																: std_logic_vector(31 downto 0);
signal rx_status_reg																: std_logic_vector(31 downto 0);
signal rx_busy																			: std_logic;
signal rx_error																			: std_logic;


-- Transmitter
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

-- Receiver 

component ReceiverTop is
		Port ( 
						CLK																			: in STD_LOGIC
					;	RESET 																	: in STD_LOGIC
					;	DATA_IN																	: in STD_LOGIC
					; RX_CONTROL															: in STD_LOGIC_VECTOR(31 downto 0)
					; RX_DATA																	: out STD_LOGIC_VECTOR(7 downto 0)
					; RX_STATUS																: out STD_LOGIC_VECTOR(31 downto 0)
					);
end component;

begin
	RX_STATUS																					<= rx_status_reg;
	TX_STATUS																					<= tx_status_reg;
	rx_busy																						<= rx_status_reg(0);
	rx_error																					<= rx_status_reg(4);
	tx_busy																						<= tx_status_reg(0);
	tx_control_reg																		<= TX_CONTROL;
	rx_control_reg							 											<= RX_CONTROL(31 downto 1) & tx_busy; -- Concatenate baud rate select and tx_busy
	tx_data_i																					<= TX_DATA;
	RX_DATA                                           <= rx_data_o;
							
	inst_Tx	: TransmitterTop
		port map( 
					  		CLK 																=> CLK 
					  	,	RESET 															=> RESET  
					  	, TX_DATA															=> tx_data_i
					  	, TX_CONTROL													=> tx_control_reg
					  	, TX																	=> tx_o
					  	, TX_STATUS														=> tx_status_reg 
					  	);
							
	inst_Rx : ReceiverTop
		port map ( 
								CLK																	=> CLK
							,	RESET 															=> RESET
							,	DATA_IN															=> tx_o
							, RX_CONTROL													=> rx_control_reg
							, RX_DATA															=> rx_data_o
							, RX_STATUS														=> rx_status_reg
							);
							
	

end Behavioral;
