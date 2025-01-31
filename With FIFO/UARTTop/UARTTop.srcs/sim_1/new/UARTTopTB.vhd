----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/20/2025 01:01:20 PM
-- Design Name: 
-- Module Name: UARTTopTB - Behavioral
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

entity UARTTopTB is
--  Port ( );
end UARTTopTB;

architecture Behavioral of UARTTopTB is
signal clk 																					: std_logic;
signal reset 																				: std_logic;
constant clk_period																	: time:= 10ns;
signal baud_rate_i																	: std_logic_vector(3 downto 0) := x"3";
signal tx_data_i																		: std_logic_vector(7 downto 0);
signal tx_done																			: std_logic := '0';

-- Transmitter
signal T_tb_tx_control_reg													: std_logic_vector(31 downto 0) := x"a0000000";
signal T_tb_rx_control_reg													: std_logic_vector(31 downto 0) := (others => '0');
signal T_tb_tx_data																	: std_logic_vector(7 downto 0)  := (others => '0');
signal T_tb_rx																			: std_logic := '0';
signal T_tb_tx																			: std_logic;
signal T_tb_rx_data																	: std_logic_vector(7 downto 0)  := (others => '0');
signal T_tb_tx_status_reg														:	std_logic_vector(31 downto 0) := (others => '0');
signal T_tb_rx_status_reg														: std_logic_vector(31 downto 0) := (others => '0'); 
																										
-- Receiver                                       	
signal R_tb_tx_control_reg													: std_logic_vector(31 downto 0) := (others => '0');
signal R_tb_rx_control_reg													: std_logic_vector(31 downto 0) := x"a0000000";
signal R_tb_tx_data																	: std_logic_vector(7 downto 0)  := (others => '0');
signal R_tb_rx																			: std_logic := '0';
signal R_tb_tx																			: std_logic;
signal R_tb_rx_data																	: std_logic_vector(7 downto 0) 	:= (others => '0');
signal R_tb_tx_status_reg														:	std_logic_vector(31 downto 0)	:= (others => '0');
signal R_tb_rx_status_reg														: std_logic_vector(31 downto 0)	:= (others => '0');


component UARTTop is
			Port ( 
							CLK																		: in STD_LOGIC
						; RESET 																: in STD_LOGIC 
						; TX_CONTROL														: in STD_LOGIC_VECTOR(31 downto 0)
						; RX_CONTROL														: in STD_LOGIC_VECTOR(31 downto 0)
						; TX_DATA																: in STD_LOGIC_VECTOR(7 downto 0)
						; RX 																		: in STD_LOGIC
						;	TX																		: out STD_LOGIC
						; RX_DATA 															: out STD_LOGIC_VECTOR(7 downto 0)
						; TX_STATUS															: out STD_LOGIC_VECTOR(31 downto 0)
						; RX_STATUS															: out STD_LOGIC_VECTOR(31 downto 0)
						);
end component;

begin
	R_tb_rx																						<= T_tb_tx;
	

	transmitter : UARTTop
		port map(
							CLK 																	=> clk
						, RESET																	=> reset
						, TX_CONTROL														=> T_tb_tx_control_reg
						, RX_CONTROL														=> T_tb_rx_control_reg -- unused
						, TX_DATA																=> T_tb_tx_data				
						, RX																		=> T_tb_rx						 -- unused
						, TX																		=> T_tb_tx							
						, RX_DATA																=> T_tb_rx_data				 -- unused
						, TX_STATUS															=> T_tb_tx_status_reg	
						, RX_STATUS															=> T_tb_rx_status_reg	 -- unused
						);

	receiver : UARTTop
		port map(
							CLK 																	=> clk
						, RESET																	=> reset
						, TX_CONTROL														=> R_tb_tx_control_reg -- unused
						, RX_CONTROL														=> R_tb_rx_control_reg
						, TX_DATA																=> R_tb_tx_data		     -- unused		
						, RX																		=> R_tb_rx						
						, TX																		=> R_tb_tx						 -- unused
						, RX_DATA																=> R_tb_rx_data					
						, TX_STATUS															=> R_tb_tx_status_reg	 -- unused
						, RX_STATUS															=> R_tb_rx_status_reg	
						);

	clk_gen : process
	begin
		clk 																						<= '1';
		wait for clk_period/2;
		clk																							<= '0';
		wait for clk_period/2;
	end process;

	reset_proc : process
	begin
		reset																						<= '1';
		wait for 50ns;
		reset																						<= '0';
		wait;
	end process; 
	
	tx_proc : process(clk, reset, T_tb_rx_control_reg, T_tb_rx_status_reg, T_tb_tx_control_reg, T_tb_tx_status_reg, R_tb_rx_control_reg, R_tb_rx_status_reg, R_tb_tx_control_reg, R_tb_tx_status_reg)
	begin
		if (reset = '1') then 
			T_tb_tx_control_reg(8) 											<= '0';
		elsif (rising_edge(clk) and tx_done = '0') then 
			T_tb_tx_control_reg(0)											<= '1';
			T_tb_tx_control_reg(8) 											<= not T_tb_tx_status_reg(4);
			if (not T_tb_tx_status_reg(4) ='1') then 
				if (T_tb_tx_data /= x"20") then 
					T_tb_tx_data														<= std_logic_vector(unsigned(T_tb_tx_data) + 1);	
				else 
					T_tb_tx_data														<= (others => '0');
					T_tb_tx_control_reg(8) 									<= '0';
					tx_done																	<= '1';
				end if;
			end if;
		end if;
	end process;

	
	
	rx_proc : process(clk, reset, T_tb_rx_control_reg, T_tb_rx_status_reg, T_tb_tx_control_reg, T_tb_tx_status_reg, R_tb_rx_control_reg, R_tb_rx_status_reg, R_tb_tx_control_reg, R_tb_tx_status_reg)
	begin
		if (reset = '1') then 
			R_tb_rx_control_reg(4) 											<= '0';
		elsif (rising_edge(clk)) then 
			R_tb_rx_control_reg													<= R_tb_rx_control_reg(31 downto 1) & T_tb_tx_status_reg(0);
			R_tb_rx_control_reg(8) 											<= not R_tb_rx_status_reg(8);
			
		end if;
	end process;
	
	
		--	wait for 100ns;
		--	tx_data_i																				<= "00110011";
		--	tx_control_reg																	<= x"30000000";
		--	rx_control_reg																	<= x"30000000";
		--	wait for 100ns;
		--	tx_control_reg																	<= x"30000001";
		--	wait until tx_status_reg = x"00000000";
		--	tx_control_reg																	<= x"30000000";
		--	wait until rx_status_reg = x"00000001";
		--	
		--	wait for 100us;
		--	tx_data_i																				<= "11101100";
		--	tx_control_reg																	<= x"30000000";
		--	rx_control_reg																	<= x"30000000";
		--	wait for 100ns;
		--	tx_control_reg																	<= x"30000001";
		--	wait until tx_status_reg = x"00000000";
		--	tx_control_reg																	<= x"30000000";
		--	wait until rx_status_reg = x"00000001";
		--	
		--	wait for 100us;
		--	tx_data_i																				<= "00010011";
		--	tx_control_reg																	<= x"30000000";
		--	rx_control_reg																	<= x"30000000";
		--	wait for 100ns;
		--	tx_control_reg																	<= x"30000001";
		--	wait until tx_status_reg = x"00000000";
		--	tx_control_reg																	<= x"30000000";
		--	wait until rx_status_reg = x"00000001";
		--	
		--	wait for 100us;
		--	tx_data_i																				<= "10101010";
		--	tx_control_reg																	<= x"40000000";
		--	rx_control_reg																	<= x"40000000";
		--	wait for 1000us;
		--	tx_control_reg																	<= x"40000001";
		--	wait until tx_status_reg = x"00000000";
		--	tx_control_reg																	<= x"40000000";
		--	wait until rx_status_reg = x"00000001";
		
		
		--	wait for 1041800ns;
		--	tx_enable_i																			<= '0';
		--	tx_data_i																				<= (others => '0');
		--	wait for 208360ns;
		--	tx_data_i																				<= "01110101";
		--	tx_enable_i																			<= '1';
		--	wait for 1041800ns;
		--	tx_enable_i																			<= '0';
		--	tx_data_i																				<= (others => '0');
		-- wait;
	
	
end Behavioral;
