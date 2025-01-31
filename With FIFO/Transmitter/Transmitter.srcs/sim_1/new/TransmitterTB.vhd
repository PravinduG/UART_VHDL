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
signal tx_control_reg 															: std_logic_vector(35 downto 0):=x"00000000";
signal tx_status_reg																: std_logic_vector(31 downto 0);
signal rd_counter																		: integer:=0;
signal flag																					: integer:=4;

type data_set_val is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22, S23);
signal current_state : data_set_val := S0;  -- Initial state

component TransmitterTop is
    Port ( 
						CLK 																		: in STD_LOGIC																			-- Connects to main clock
          ;	RESET 																	: in STD_LOGIC																			
					; TX_DATA																	: in STD_LOGIC_VECTOR(7 downto 0)
					; TX_CONTROL															: in STD_LOGIC_VECTOR(35 downto 0) 									-- 31 downto 28 gets baud divisor
					; TX																			: out STD_LOGIC	
					; TX_STATUS																: out STD_LOGIC_VECTOR(31 downto 0)
				  );
end component;



begin
	inst_TX : TransmitterTop
		port map (
								CLK 																=> clk																							
							,	RESET 															=> reset																						
							, TX_DATA															=> tx_data															
							, TX_CONTROL													=> tx_control_reg																	
							, TX																	=> tx
							, TX_STATUS														=> tx_status_reg																			 
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
	
  control_reg_update : process(clk)
	begin
		if (rising_edge(clk) and reset = '0') then 
			if (current_state = S23) then 
				tx_control_reg(8)														<= '0';
			else 
				tx_control_reg(8) 													<= not tx_status_reg(4);
			end if;
		end if;
	end process;
	
	fifo_proc : process(clk, reset)
	begin
		if (reset = '1') then 
				current_state 															<= S0;  -- Initial state
		elsif (rising_edge(clk)) then 
			case current_state is
					when S0  => 
							tx_data <= "10000000";
							if tx_status_reg(flag)= '0' then
									current_state <= S1;
							end if;
					when S1  => 
							tx_data <= "00000001";
							if tx_status_reg(flag)= '0' then
									current_state <= S2;
							end if;
					when S2  => 
							tx_data <= "00000010";
							if tx_status_reg(flag)= '0' then
									current_state <= S3;
							end if;
					when S3  => 
							tx_data <= "00000011";
							if tx_status_reg(flag)= '0' then
									current_state <= S4;
							end if;
					when S4  => 
							tx_data <= "00000100";
							if tx_status_reg(flag)= '0' then
									current_state <= S5;
							end if;
					when S5  => 
							tx_data <= "00000101";
							if tx_status_reg(flag)= '0' then
									current_state <= S6;
							end if;
					when S6  => 
							tx_data <= "00000110";
							if tx_status_reg(flag)= '0' then
									current_state <= S7;
							end if;
					when S7  => 
							tx_data <= "00000111";
							if tx_status_reg(flag)= '0' then
									current_state <= S8;
							end if;
					when S8  => 
							tx_data <= "00001000";
							if tx_status_reg(flag)= '0' then
									current_state <= S9;
							end if;
					when S9  => 
							tx_data <= "00001001";
							if tx_status_reg(flag)= '0' then
									current_state <= S10;
							end if;
					when S10 => 
							tx_data <= "00001010";
							if tx_status_reg(flag)= '0' then
									current_state <= S11;
							end if;
					when S11 => 
							tx_data <= "00001011";
							if tx_status_reg(flag)= '0' then
									current_state <= S12;
							end if;
					when S12 => 
							tx_data <= "00001100";
							if tx_status_reg(flag)= '0' then
									current_state <= S13;
							end if;
					when S13 => 
							tx_data <= "00001101";
							if tx_status_reg(flag)= '0' then
									current_state <= S14;
							end if;
					when S14 => 
							tx_data <= "00001110";
							if tx_status_reg(flag)= '0' then
									current_state <= S15;
							end if;
					when S15 => 
							tx_data <= "00001111";
							if tx_status_reg(flag)= '0' then
									current_state <= S16;
							end if;
					when S16 => 
							tx_data <= "00010000";
							if tx_status_reg(flag)= '0' then
									current_state <= S17;
							end if;
					when S17 => 
							tx_data <= "00010001";
							if tx_status_reg(flag)= '0' then
									current_state <= S18;
							end if;
					when S18 => 
							tx_data <= "00010010";
							if tx_status_reg(flag)= '0' then
									current_state <= S19;
							end if;
					when S19 => 
							tx_data <= "00010011";
							if tx_status_reg(flag)= '0' then
									current_state <= S20;
							end if;
					when S20 => 
							tx_data <= "00010100";
							if tx_status_reg(flag)= '0' then
									current_state <= S21;
							end if;
					when S21 => 
							tx_data <= "00010101";
							if tx_status_reg(flag)= '0' then
									current_state <= S22;
							end if;
					when S22 => 
							tx_data <= "00010110";
							if tx_status_reg(flag)= '0' then
									current_state <= S23;  -- Loop back to S0
					
							end if;
					when S23 =>
						null;
					when others => 
							tx_data <= "11111111";
							if tx_status_reg(flag)= '0' then
									current_state <= S0;
							end if;
			end case;
		end if;
	end process;
	
	
	tx_proc : process(clk, reset, tx_status_reg, tx_control_reg) 
	begin
		if (reset = '1') then 
			tx_control_reg(0)															<= '0';		
		elsif (rising_edge(clk)) then 
			tx_control_reg(0)															<= '1';
		end if;
	end process;
end Behavioral;
