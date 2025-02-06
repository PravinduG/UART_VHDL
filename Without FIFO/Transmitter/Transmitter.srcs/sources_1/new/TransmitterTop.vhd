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
-- TX_CONTROL 								-> 31 - 28 : baud divisor select
-- 																		 0 : TX_ENABLE
-- TX_STATUS									-> 			 0 : tx_ongoing
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
						CLK 																		: in STD_LOGIC																			-- Connects to main clock
          ;	RESET 																	: in STD_LOGIC																			
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_CONTROL															: in STD_LOGIC_VECTOR(31 downto 0) 									-- 31 downto 28 gets baud divisor
					; TX																			: out STD_LOGIC	
					; TX_STATUS																: out STD_LOGIC_VECTOR(31 downto 0)
				  );
end TransmitterTop;

architecture Behavioral of TransmitterTop is
type TX_STATES is (IDLE, DATA, STOP);
signal cur_state																		: TX_STATES;
signal tx_ongoing																		: std_logic;
signal tx_data_i																		: std_logic_vector(7 downto 0);
signal tx_o																					: std_logic;
signal tx_state																			: integer;
signal actual_tx_state															: TX_STATES;																				-- dbg

--	tx_clk
signal tx_enable 																		: std_logic;
signal baud_divisor																	: unsigned(19 downto 0);
signal baud_counter 																: unsigned(19 downto 0);
signal tx_clk																				: std_logic;
signal tx_clk_bk																		: std_logic;

begin

	set_baud_divisor : process(TX_CONTROL(31 downto 28))
  begin
    case TX_CONTROL(31 downto 28) is
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
	
	tx_clock_gen : process(CLK, RESET, TX_CONTROL) 
	begin
		if (RESET = '1') then 
			baud_counter																	<= (others => '0');
			tx_clk																				<= '0';
			tx_clk_bk 																		<= '0';
		elsif(rising_edge(CLK)) then 
			tx_clk_bk																				<= tx_clk;
			if (baud_counter >= baud_divisor) then 
				tx_clk																			<= not tx_clk;
				baud_counter																<= (others => '0');
			else 
				baud_counter																<= baud_counter + 1;
			end if;
		end if;
	end process;
																			
	tx_proc : process (CLK, RESET, TX_CONTROL, tx_clk, tx_clk_bk)
	begin
		actual_tx_state																	<= cur_state;
		if (RESET = '1') then 
			tx_ongoing																		<= '0';
			cur_state																			<= IDLE;
			tx_data_i																			<= (others => '0');
			tx_o																					<= '1';	
			tx_state 																			<= 0;
			TX_STATUS																			<= (others => '0');
		elsif(rising_edge(CLK)) then 																																				
			TX																						<= tx_o;
			TX_STATUS(0)																	<= tx_ongoing;
			tx_enable																			<= TX_CONTROL(0);
			if (tx_clk = '1' and tx_clk_bk = '0') then 																													-- tx_clk transition
				case cur_state is
					when IDLE =>
						tx_ongoing																<= '0';
						tx_o																			<= '1';																							-- No transmission. Back here for stop bit
						tx_state																	<= 0;
						if (tx_enable = '1') then 
							cur_state																<= DATA;
							tx_ongoing															<= '1';																							-- Transmission begins
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
						tx_ongoing																<= '0';	-- Since we use this output to pull down TX_ENABLE, we need this here. if it's in IDLE, this will never become
																															-- 0 as it will constantly satisfy the if condition there
				end case;
			end if;
		end if;
	end process;
	


end Behavioral;
