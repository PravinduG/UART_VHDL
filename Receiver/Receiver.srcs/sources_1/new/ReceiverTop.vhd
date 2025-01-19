----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2025 02:12:51 PM
-- Design Name: 
-- Module Name: ReceiverTop - Behavioral
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

entity ReceiverTop is
		Port ( 
						CLK																			: in STD_LOGIC
					;	RESET 																	: in STD_LOGIC
					;	DATA_IN																	: in STD_LOGIC
					; TX_READY																: in STD_LOGIC							
					; RX_DATA																	: out STD_LOGIC_VECTOR(7 downto 0)
					; RX_READY																: out STD_LOGIC				
					);
end ReceiverTop;

architecture Behavioral of ReceiverTop is
type RX_STATES is (IDLE, RECEIVING, STOP);
signal cur_state																		: RX_STATES;
signal rx_data_o																		: std_logic_vector(7 downto 0);
signal rx_ready_o																		: std_logic;
signal rx_state																			: integer;
signal sample_clk																		: std_logic;
signal sample_clk_bk																: std_logic;
signal rx_error																			: std_logic;
signal actual_state																	: RX_STATES; 																			-- for dbg
-- signal rx_data_in																		: std_logic_vector(7 downto 0);

begin
	sample_clk_gen : process(CLK, RESET)
	begin
	sample_clk_bk																			<= sample_clk;
		if(RESET = '1') then 
			sample_clk																		<= '0';
			sample_clk_bk																	<= '0';
		elsif (falling_edge(CLK)) then 
			sample_clk																		<= '1';
		elsif	(rising_edge(CLK)) then 
			sample_clk																		<= '0';
		end if;
			
	end process;
	
	rx_proc	: process(CLK, RESET, DATA_IN, TX_READY)
	begin 
	actual_state																			<= cur_state; 																		-- for dbg
	RX_DATA																						<= rx_data_o;
	RX_READY																					<= rx_ready_o;
		if (RESET = '1') then 
			cur_state																			<= IDLE;
			rx_error																			<= '0';
		elsif(sample_clk = '1' and sample_clk_bk = '0') then  																						-- Try rising_edge(sample_clk)
			case cur_state is 
				when IDLE =>
					rx_state																	<= 0;
					
					if (TX_READY = '1' and DATA_IN = '0') then 
						rx_ready_o															<= '0';
						rx_data_o																<= (others => '0');																-- Data kept till next tx begins
						cur_state																<= RECEIVING;
						rx_state																<= 1;
						rx_error																<= '0';
					elsif (TX_READY = '0' and DATA_IN = '0') then 
						rx_error																<= '1';
						rx_ready_o															<= '0';
					end if;

				when RECEIVING =>
					if (rx_state = 8) then 
						cur_state																<= STOP;
					end if;
																							
					rx_data_o																	<= DATA_IN & rx_data_o(7 downto 1);
					rx_state																	<= rx_state + 1;
					
					-- rx_data_o(8 - rx_state) <= DATA_IN; Which would be better?
					
					
				when STOP =>
					if (DATA_IN = '1' and rx_state = 9) then 
						cur_state																<= IDLE;
						rx_ready_o															<= '1';
						rx_state																<= 0;
					elsif (DATA_IN = '0' and rx_state = 9) then 
						rx_error																<= '1';
						rx_ready_o															<= '0';
						cur_state																<= IDLE;
					end if;

			end case;
		end if;
	end process;


end Behavioral;
