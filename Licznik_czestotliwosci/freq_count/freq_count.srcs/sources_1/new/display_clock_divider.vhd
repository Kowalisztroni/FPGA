library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DisplayClockDivider is
    Port (
        CLK100MHZ : in STD_LOGIC;
        DISP_CLK : out STD_LOGIC
    );
end DisplayClockDivider;

architecture Behavioral of DisplayClockDivider is
    signal clk_div : INTEGER := 0;
begin
    process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if clk_div = 99999 then  
                clk_div <= 0;
                DISP_CLK <= '1';
            else
                clk_div <= clk_div + 1;
                DISP_CLK <= '0';
            end if;
        end if;
    end process;
end Behavioral;