----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.05.2025 15:49:21
-- Design Name: 
-- Module Name: jednostka_arytmetyczna - Behavioral
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

entity jednostka_arytmetyczna is
    Port ( IN_A : in signed(7 downto 0);
           IN_B : in signed(7 downto 0);
           IN_OPERAND : in STD_LOGIC_VECTOR (1 downto 0);
           OUT_RESULT : out signed (15 downto 0));
end jednostka_arytmetyczna;

architecture Behavioral of jednostka_arytmetyczna is
begin
    process(IN_A,IN_B,IN_OPERAND)
    begin
        case IN_OPERAND is
            when "00" => -- dodawanie
                OUT_RESULT <= resize(IN_A,16) + resize(IN_B,16);
            when "01" => -- odejmowanie
                 OUT_RESULT <= resize(IN_A,16) - resize(IN_B,16);       
             when "10" => -- mnozenie
                 OUT_RESULT <= IN_A * IN_B;       
            when "11" => -- dzielnie
                if IN_B /= 0 then
                    OUT_RESULT <= resize(IN_A / IN_B, 16);
                else
                    OUT_RESULT <= (others => '0');
                end if;    
            when others =>
                OUT_RESULT <= (others => '0');
            end case;
     end process;           
end Behavioral;
