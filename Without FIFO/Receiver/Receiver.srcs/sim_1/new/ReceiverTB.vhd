----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2025 03:14:20 PM
-- Design Name: 
-- Module Name: ReceiverTB - Behavioral
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

entity ReceiverTB is
--  Port ( );
end ReceiverTB;

architecture Behavioral of ReceiverTB is



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
signal clk 																					: std_logic;
signal sample_clk																		: std_logic;
signal reset 																				: std_logic;
constant clk_period																	: time:=10ns;
signal data_in																			: std_logic;
signal rx_data 																			: std_logic_vector(7 downto 0);
signal rx_control_reg																: std_logic_vector(31 downto 0);
signal rx_status_reg																: std_logic_vector(31 downto 0);

begin

	inst_rx : ReceiverTop 
			port map( 
								CLK																	=> clk 
							,	RESET 															=> reset 
							,	DATA_IN															=> data_in
							, RX_CONTROL													=> rx_control_reg
							, RX_DATA															=> rx_data 
							, RX_STATUS 													=> rx_status_reg
							);
	clk_gen : process
	begin
		clk                                							<= '1';
		wait for clk_period/2;
	  clk 																						<= '0';
		wait for clk_period/2;
	end process;
	
	sample_clk_gen : process
	begin 
		sample_clk																			<= '0';
		wait for 104us;
		sample_clk																			<= '1';
		wait for 104us;
	end process;
	
	reset_proc : process
	begin
		reset 																					<= '1';
		wait for 50ns;
		reset 																					<= '0';
		wait;
	end process;
	
	sim_proc : process
	begin
		data_in																			<= '1';
		rx_control_reg															<= x"30000000";
		wait for 200us;
		data_in																			<= '0';
		rx_control_reg															<= x"30000001";
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		rx_control_reg															<= x"30000000";
		
		wait for 100us;
		rx_control_reg															<= x"30000001";
		data_in																			<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		rx_control_reg															<= x"30000000";
		
		wait for 100us;
		data_in																			<= '0';
		
		wait for 100us;
		rx_control_reg															<= x"30000001";
		data_in																			<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		rx_control_reg															<= x"30000000";
		
		wait for 100us;
		rx_control_reg															<= x"30000001";
		data_in																			<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '0';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		wait for 104us;
		data_in 																		<= '1';
		rx_control_reg															<= x"30000001";
		
		
		wait;
	end process;


end Behavioral;
