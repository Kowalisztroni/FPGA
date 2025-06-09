library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockDivider is
    Port (
        CLK100MHZ : in STD_LOGIC;
        ONE_SEC : out STD_LOGIC
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal clk_div : INTEGER := 0;
begin
    process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if clk_div = 99999999 then 
                clk_div <= 0;
                ONE_SEC <= '1';
            else
                clk_div <= clk_div + 1;
                ONE_SEC <= '0';
            end if;
        end if;
    end process;
end Behavioral;

