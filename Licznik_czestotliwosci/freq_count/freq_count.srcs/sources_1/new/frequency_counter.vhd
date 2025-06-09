library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FrequencyCounter is
    Port (
        CLK100MHZ : in STD_LOGIC;
        JB : in STD_LOGIC_VECTOR(1 to 10);  
        SEG : out STD_LOGIC_VECTOR(6 downto 0);
        AN  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end FrequencyCounter;

architecture Behavioral of FrequencyCounter is
    signal one_sec : STD_LOGIC := '0';
    signal disp_clk : STD_LOGIC := '0';
    signal pulse_cnt : INTEGER := 0;
    signal display_value : INTEGER := 0;
    signal digit_index : INTEGER range 0 to 7 := 0;
    signal current_digit_value : INTEGER range 0 to 9 := 0;
    signal JB1_sync1, JB1_sync2 : STD_LOGIC := '0';
    signal JB1_prev : STD_LOGIC := '0';

    component ClockDivider
        Port (CLK100MHZ : in STD_LOGIC; ONE_SEC : out STD_LOGIC);
    end component;

    component DisplayClockDivider
        Port (CLK100MHZ : in STD_LOGIC; DISP_CLK : out STD_LOGIC);
    end component;

begin
    ClockDiv_Inst : ClockDivider port map (CLK100MHZ => CLK100MHZ, ONE_SEC => one_sec);
    DispClk_Inst : DisplayClockDivider port map (CLK100MHZ => CLK100MHZ, DISP_CLK => disp_clk);

    process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            JB1_sync1 <= JB(1);
            JB1_sync2 <= JB1_sync1;
        end if;
    end process;

    process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if JB1_prev = '0' and JB1_sync2 = '1' then
                pulse_cnt <= pulse_cnt + 1;
            end if;
            JB1_prev <= JB1_sync2;

            if one_sec = '1' then
                display_value <= pulse_cnt;
                pulse_cnt <= 0;
            end if;
        end if;
    end process;

    process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if disp_clk = '1' then
                digit_index <= (digit_index + 1) mod 8;
            end if;
        end if;
    end process;

    process (digit_index)
    begin
        case digit_index is
            when 0 => AN <= "11111110";
            when 1 => AN <= "11111101";
            when 2 => AN <= "11111011";
            when 3 => AN <= "11110111";
            when 4 => AN <= "11101111";
            when 5 => AN <= "11011111";
            when 6 => AN <= "10111111";
            when 7 => AN <= "01111111";
        end case;
    end process;

    process (digit_index, display_value)
    begin
        case digit_index is
            when 0 => current_digit_value <= display_value mod 10;
            when 1 => current_digit_value <= (display_value / 10) mod 10;
            when 2 => current_digit_value <= (display_value / 100) mod 10;
            when 3 => current_digit_value <= (display_value / 1000) mod 10;
            when 4 => current_digit_value <= (display_value / 10000) mod 10;
            when 5 => current_digit_value <= (display_value / 100000) mod 10;
            when 6 => current_digit_value <= (display_value / 1000000) mod 10;
            when 7 => current_digit_value <= (display_value / 10000000) mod 10;
        end case;
    end process;

    process (current_digit_value)
    begin
        case current_digit_value is
            when 0 => SEG <= "1000000";
            when 1 => SEG <= "1111001";
            when 2 => SEG <= "0100100";
            when 3 => SEG <= "0110000";
            when 4 => SEG <= "0011001";
            when 5 => SEG <= "0010010";
            when 6 => SEG <= "0000010";
            when 7 => SEG <= "1111000";
            when 8 => SEG <= "0000000";
            when 9 => SEG <= "0010000";
            when others => SEG <= "1111111";
        end case;
    end process;

end Behavioral;