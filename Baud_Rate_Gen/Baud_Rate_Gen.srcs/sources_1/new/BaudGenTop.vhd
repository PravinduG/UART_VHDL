----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 04:42:05 PM
-- Design Name: 
-- Module Name: BaudGenTop - Behavioral
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

entity BaudGenTop is
    Port ( 	CLK 																		: in STD_LOGIC
          ;	RESET 																	: in STD_LOGIC
					; BAUD_CLK_RESET													: in STD_LOGIC										 -- Sync clock for when transmission begins
					; BAUD_CYCLES_REQ													: in STD_LOGIC_VECTOR(15 downto 0) -- How many main clock cycles for each baud clock cycle
          ; BAUD_CLK 			 													: out STD_LOGIC
					);
end BaudGenTop;

architecture Behavioral of BaudGenTop is
signal baud_clk_o																		: std_logic;
signal baud_clk_counter															: integer;


begin
	BAUD_CLK																						<= baud_clk_o;
	clk_gen : process(CLK, RESET, BAUD_CYCLES_REQ, BAUD_CLK_RESET)
	begin
		if (RESET = '1' or BAUD_CLK_RESET = '1') then 
			baud_clk_o																			<= '0';
			baud_clk_counter																<= to_integer(unsigned(BAUD_CYCLES_REQ)/2);
		elsif(rising_edge(CLK)) then 
			if (baud_clk_counter = 0) then 
				baud_clk_o																		<= not baud_clk_o;
				baud_clk_counter															<= to_integer(unsigned(BAUD_CYCLES_REQ)/2); -- or BAUD_CYCLES_REQ(15 downto 1)
			else 
				baud_clk_counter															<= baud_clk_counter - 1;
			end if;
		end if;
	end process;


end Behavioral;
