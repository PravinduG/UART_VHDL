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
signal clk                                          : std_logic;
signal reset                                        : std_logic;
constant clk_period                                 : time := 10ns;
signal baud_rate_i                                  : std_logic_vector(3 downto 0) := x"3";
signal tx_data_i                                    : std_logic_vector(7 downto 0);
signal tx_done                                      : std_logic := '0';

-- Transmitter
signal baud_divisor_sel_reg													: std_logic_vector(3 downto 0):= x"d";
signal tx_control_reg                               : std_logic_vector(31 downto 0) := x"00000000";
signal rx_control_reg                               : std_logic_vector(31 downto 0) := (others => '0');
signal tx_data                                      : std_logic_vector(7 downto 0) := (others => '0');
signal rx                                           : std_logic := '0';
signal tx                                           : std_logic;
signal rx_data                                      : std_logic_vector(7 downto 0) := (others => '0');
signal tx_status_reg                                : std_logic_vector(31 downto 0) := (others => '0');
signal rx_status_reg                                : std_logic_vector(31 downto 0) := (others => '0'); 



component UARTTop is
         Port ( 
                        CLK                         : in STD_LOGIC
                      ; RESET                       : in STD_LOGIC
											;	BAUD_DIVISOR_SEL						: in STD_LOGIC_VECTOR(3 downto 0)
                      ; TX_CONTROL                  : in STD_LOGIC_VECTOR(31 downto 0)
                      ; RX_CONTROL                  : in STD_LOGIC_VECTOR(31 downto 0)
                      ; TX_DATA                     : in STD_LOGIC_VECTOR(7 downto 0)
                      ; RX                          : in STD_LOGIC
                      ; TX                          : out STD_LOGIC
                      ; RX_DATA                     : out STD_LOGIC_VECTOR(7 downto 0)
                      ; TX_STATUS                   : out STD_LOGIC_VECTOR(31 downto 0)
                      ; RX_STATUS                   : out STD_LOGIC_VECTOR(31 downto 0)
                      );
end component;

begin

	rx                                               	<= tx;

	inst_uut : UARTTop
			port map(
											CLK                           => clk
										,	RESET                         => reset
										,	BAUD_DIVISOR_SEL							=> baud_divisor_sel_reg
										,	TX_CONTROL                    => tx_control_reg
										,	RX_CONTROL                    => rx_control_reg 
										,	TX_DATA                       => tx_data				
										,	RX                            => rx
										,	TX                            => tx						
										,	RX_DATA                       => rx_data
										,	TX_STATUS                     => tx_status_reg	
										,	RX_STATUS                     => rx_status_reg 
											);

	clk_gen : process
	begin
			clk                                           <= '1';
			wait for clk_period / 2;
			clk                                           <= '0';
			wait for clk_period / 2;
	end process;

	reset_proc : process
	begin
			reset                                         <= '1';
			wait for 50ns;
			reset                                         <= '0';
			wait;
	end process; 
		
	tx_proc : process(clk, reset)
	begin
			if (reset = '1') then 
					tx_control_reg(8)                         <= '0';
			elsif (rising_edge(clk)) then 
				if (tx_done = '0') then 
					if (rx_status_reg(12) = '0') then 
							tx_control_reg(0)                     <= '1';
							rx_control_reg(0)                     <= '1';
					else 
							tx_control_reg(0)                     <= '0';
							rx_control_reg(0)                     <= '0';
					end if;
					tx_control_reg(8)                         <= not tx_status_reg(4);
					if (not tx_status_reg(4) ='1') then 
							if (tx_data /= x"20") then 
									tx_data                           <= std_logic_vector(unsigned(tx_data) + 1);	
							else 
									tx_data                           <= (others => '0');
									tx_control_reg(8)                 <= '0';
									tx_done                           <= '1';
							end if;
					end if;
				end if;
			end if;
	end process;

	rx_proc : process(clk, reset)
	begin
			if (reset = '1') then 
					rx_control_reg(4)                         <= '0';
			elsif (rising_edge(clk)) then 
					rx_control_reg(8)                         <= not rx_status_reg(8);
			end if;
			
	end process;
		
end Behavioral;
