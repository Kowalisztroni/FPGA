library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display is
    Port ( VALUE : in STD_LOGIC_VECTOR (31 downto 0);
           CLK100MHZ : in STD_LOGIC;
           reset : in STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end display;

architecture Behavioral of display is
    signal counter_reg : UNSIGNED (31 downto 0) := (others => '0');
    signal clk_div    : std_logic := '0';
    signal div_counter: integer range 0 to 49999 := 0;
    signal sel: unsigned(2 downto 0) := (others => '0');
    signal val : std_logic_vector (3 downto 0);
    
    -- Sygnał dla sekundowego licznika
    signal one_second_counter: integer range 0 to 99999999 := 0;
    
    -- Sygnały dla wartości dziesiętnych
    type bcd_array is array (7 downto 0) of std_logic_vector(3 downto 0);
    signal bcd_digits : bcd_array;
    
    -- Funkcja do konwersji binarnej na BCD (metoda Double Dabble)
    function bin_to_bcd(bin : unsigned(31 downto 0)) return bcd_array is
        variable temp : unsigned(31 downto 0);
        variable bcd : bcd_array;
        variable i : integer;
    begin
        temp := bin;
        bcd := (others => (others => '0'));
        
        for i in 0 to 31 loop
            -- Dodaj 3 do każdej cyfry BCD jeśli jest >= 5
            for j in 0 to 7 loop
                if unsigned(bcd(j)) >= 5 then
                    bcd(j) := std_logic_vector(unsigned(bcd(j)) + 3);
                end if;
            end loop;
            
            -- Przesuń wszystkie cyfry w lewo
            for j in 7 downto 1 loop
                bcd(j) := bcd(j)(2 downto 0) & bcd(j-1)(3);
            end loop;
            bcd(0) := bcd(0)(2 downto 0) & std_logic(temp(31));
            
            -- Przesuń wejście binarne w lewo
            temp := temp(30 downto 0) & '0';
        end loop;
        
        return bcd;
    end function;
    
begin

-- Licznik 32-bitowy inkrementowany co sekundę
    process(CLK100MHZ, reset)
    begin 
        if reset = '1' then
            counter_reg <= (others => '0');
            one_second_counter <= 0;   
        elsif rising_edge(CLK100MHZ) then
            if one_second_counter = 99999999 then  -- Dla zegara 100MHz to daje około 1 sekundy
                one_second_counter <= 0;
                counter_reg <= counter_reg + 1;    -- Inkrementacja co 1 sekundę
            else    
                one_second_counter <= one_second_counter + 1;
            end if;
        end if;    
    end process;
    
    -- Konwersja binarnego licznika na cyfry dziesiętne
    process(counter_reg)
    begin
        bcd_digits <= bin_to_bcd(counter_reg);
    end process;
    

-- Dzielnik zegara (1kHz) dla multipleksowania  
    process(CLK100MHZ, reset)
    begin
        if reset = '1' then
            div_counter <= 0;
            clk_div <= '0';
        elsif rising_edge(CLK100MHZ) then
            if div_counter = 49999 then
                div_counter <= 0;   
                clk_div <= not clk_div; 
            else    
                div_counter <= div_counter + 1;
            end if;
         end if;
    end process;
    
    
    -- Wybór cyfry (multipleksowanie)
    process(clk_div, reset)
    begin
        if reset = '1' then
            sel <= (others => '0');
        elsif rising_edge(clk_div) then
            sel <= sel + 1;
        end if;    
    end process;               
    
    
    -- Przypisanie wartości dziesiętnych dla każdej cyfry i sterowanie anodami
    process(sel, bcd_digits)
    begin
        AN <= (others => '1');
        
        case sel is
            when "000" =>  -- Najmniej znacząca cyfra (jedności)
                val <= bcd_digits(0);
                AN(0) <= '0';
            when "001" =>  -- Dziesiątki
                val <= bcd_digits(1);
                AN(1) <= '0';
            when "010" =>  -- Setki
                val <= bcd_digits(2);
                AN(2) <= '0';
            when "011" =>  -- Tysiące
                val <= bcd_digits(3);
                AN(3) <= '0';  
            when "100" =>  -- Dziesiątki tysięcy
                val <= bcd_digits(4);
                AN(4) <= '0';
            when "101" =>  -- Setki tysięcy
                val <= bcd_digits(5);
                AN(5) <= '0';
            when "110" =>  -- Miliony
                val <= bcd_digits(6);
                AN(6) <= '0';
            when "111" =>  -- Dziesiątki milionów
                val <= bcd_digits(7);
                AN(7) <= '0';
            when others =>
                val <= "0000";
        end case;         
    end process;            
                  
    -- Dekoder 7-segmentowy (bez zmian)
    process(val)
    begin
        case val is
            when "0000" => seg <= "0000001"; -- 0
            when "0001" => seg <= "1001111"; -- 1
            when "0010" => seg <= "0010010"; -- 2
            when "0011" => seg <= "0000110"; -- 3
            when "0100" => seg <= "1001100"; -- 4
            when "0101" => seg <= "0100100"; -- 5
            when "0110" => seg <= "0100000"; -- 6
            when "0111" => seg <= "0001111"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0000100"; -- 9
            when others => seg <= "1111111"; -- Wyłącz
        end case;
    end process;        
                
end Behavioral;
