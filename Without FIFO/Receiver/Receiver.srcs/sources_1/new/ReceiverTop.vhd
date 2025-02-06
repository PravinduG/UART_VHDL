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
-- RX_CONTROL 								-> 31 - 28 : baud divisor select
-- 																		 0 : RX_ENABLE is TX_READY (tx_ongoing)
-- RX_STATUS									-> 			 4 : rx_error 
--																		 0 : RX_READY
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
					; RX_CONTROL															: in STD_LOGIC_VECTOR(31 downto 0)
					; RX_DATA																	: out STD_LOGIC_VECTOR(7 downto 0)
					; RX_STATUS																: out STD_LOGIC_VECTOR(31 downto 0)
					);
end ReceiverTop;

architecture Behavioral of ReceiverTop is
type RX_STATES is (IDLE, RECEIVING, STOP);
signal cur_state																		: RX_STATES;
signal rx_data_o																		: std_logic_vector(7 downto 0);
signal rx_ready_o																		: std_logic;
signal rx_state																			: integer;
signal sample_clk																		: std_logic; -- remove
signal sample_clk_bk																: std_logic; -- remove
signal rx_error																			: std_logic;
signal actual_state																	: RX_STATES; 																			-- for dbg

-- rx_clk
signal baud_divisor																	: unsigned(19 downto 0);
signal baud_counter 																: unsigned(19 downto 0);
signal rx_clk																				: std_logic;
signal rx_clk_bk																		: std_logic;
signal rx_clk_enable																: std_logic;

begin

	set_baud_divisor : process(RX_CONTROL(31 downto 28))
	begin
		case RX_CONTROL(31 downto 28) is
				when x"1"                           				=> baud_divisor <= x"05161";  --    2400
				when x"2"                           				=> baud_divisor <= x"028b0";  --    4800
				when x"3"                           				=> baud_divisor <= x"01458";  --    9600
				when x"4"                           				=> baud_divisor <= x"00d90";  --   14400
				when x"5"                           				=> baud_divisor <= x"00a2c";  --   19200
				when x"6"                           				=> baud_divisor <= x"006c8";  --   28800
				when x"7"                           				=> baud_divisor <= x"00516";  --   38400 
				when x"8"                           				=> baud_divisor <= x"00364";  --   57600
				when x"9"                           				=> baud_divisor <= x"0028b";  --   76800
				when x"a"                           				=> baud_divisor <= x"001b2";  --  115200
				when x"b"                           				=> baud_divisor <= x"000d9";  --  230400
				when x"c"                           				=> baud_divisor <= x"0006c";  --  460800
				when x"d"                           				=> baud_divisor <= x"00036";  --  921600
				when others                         				=> baud_divisor <= x"001b2";  --  115200 (default)
		end case;
	end process;
	
	
	rx_clk_gen : process(CLK, RESET, RX_CONTROL)
	begin
		if (RESET = '1' or rx_clk_enable = '0') then 
			rx_clk																				<= '0';
			rx_clk_bk																			<= '0';
			baud_counter																	<= (others => '0');
		elsif(rising_edge(CLK)) then 
			rx_clk_bk																			<= rx_clk;
			if (rx_clk_enable = '1') then 
				if (baud_counter >= baud_divisor) then 
					rx_clk																		<= not rx_clk;
					baud_counter															<= (others => '0');
				else
					baud_counter															<= baud_counter + 1;
				end if;
				
			end if;
		end if;
	end process;
	
	rx_proc	: process(CLK, RESET, DATA_IN, RX_CONTROL)
	begin 
		if (RX_CONTROL(0) = '1') then 
			rx_clk_enable																	<= '1';
		end if;
		
		if (RESET = '1') then 
			cur_state																			<= IDLE;
			rx_error																			<= '0';
			RX_STATUS																			<= (others => '0');
			rx_clk_enable																	<= '0';
		elsif(rising_edge(CLK)) then		
			actual_state																	<= cur_state; 																		-- for dbg
			RX_DATA																				<= rx_data_o;
			RX_STATUS(0)																	<= rx_ready_o;
			RX_STATUS(4)																	<= rx_error;
			if(rx_clk = '1' and rx_clk_bk = '0') then  																												-- Try rising_edge(sample_clk)
				case cur_state is 
					when IDLE =>
						rx_state																<= 0;
						if (RX_CONTROL(0) = '1' and DATA_IN = '0') then 
							rx_ready_o														<= '0';
							rx_data_o															<= (others => '0');																-- Data kept till next tx begins
							cur_state															<= RECEIVING;
							rx_state															<= 1;
							rx_error															<= '0';
						elsif (RX_CONTROL(0) = '0' and DATA_IN = '0') then 
							rx_error															<= '1';
							rx_ready_o														<= '0';
						end if;

					when RECEIVING =>
						if (rx_state = 8) then 
							cur_state															<= STOP;
						end if;
																								
						rx_data_o																<= DATA_IN & rx_data_o(7 downto 1);
						rx_state																<= rx_state + 1;

					when STOP =>
						if (DATA_IN = '1' and rx_state = 9) then 
							cur_state															<= IDLE;
							rx_ready_o														<= '1';
							rx_state															<= 0;
							rx_clk_enable													<= '0';
						elsif (DATA_IN = '0' and rx_state = 9) then 
							rx_error															<= '1';
							rx_ready_o														<= '0';
							cur_state															<= IDLE;
						end if;

				end case;
			end if;
		end if;
	end process;


end Behavioral;
