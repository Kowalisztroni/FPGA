----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.05.2025 15:57:28
-- Design Name: 
-- Module Name: tb_jednostka_arytmetyczna - Behavioral
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


use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_jednostka_arytmetyczna is
--  Port ( );
end tb_jednostka_arytmetyczna;

architecture Behavioral of tb_jednostka_arytmetyczna is
-- komponenty

   component jednostka_arytmetyczna 
        Port ( IN_A : in signed(7 downto 0);
               IN_B : in signed(7 downto 0);
               IN_OPERAND : in STD_LOGIC_VECTOR (1 downto 0);
               OUT_RESULT : out signed (15 downto 0));
end component;

-- sygnaly

    signal    IN_A : signed(7 downto 0);
    signal    IN_B : signed(7 downto 0);
    signal    IN_OPERAND :  STD_LOGIC_VECTOR (1 downto 0);
    signal    OUT_RESULT :  signed (15 downto 0);

-- funkcja do zamiany operatora na kod binarny

function operator_to_code(op : character) return std_logic_vector is
begin
    case op is
        when '+' => return "00";
        when '-' => return "01";
        when '*' => return "10";
        when '/' => return "11";
        when others => return "00";
     end case;
end function;
        
begin
    -- instancja jednostki
    uut: jednostka_arytmetyczna port map (
        IN_A => IN_A,
        IN_B => IN_B,
        IN_OPERAND => IN_OPERAND,
        OUT_RESULT => OUT_RESULT
 );   

 -- Proces symulacji
    stim_proc: process
        file input_file : text open read_mode is "dane_wejsciowe.txt";
        file output_file : text open write_mode is "wyniki.txt";
        variable input_line : line;
        variable output_line : line;
        variable liczba1, liczba2 : integer;
        variable operator : character;
        variable wynik : integer;
        variable spacja : character;
        
    begin
        -- Odczytaj dane z pliku wejściowego i wykonaj obliczenia
        while not endfile(input_file) loop
            readline(input_file, input_line);
            
            -- Parsowanie linii: liczba1 operator liczba2
            read(input_line, liczba1);
            read(input_line, operator);
            read(input_line, liczba2);
            
            -- Konwersja na sygnały VHDL
            IN_A <= to_signed(liczba1, 8);
            IN_B <= to_signed(liczba2, 8);
            IN_OPERAND <= operator_to_code(operator);
            
            -- Oczekiwanie na wynik (symulacja kombinacyjna)
            wait for 10 ns;
            
            -- Zapisz wynik do pliku
            wynik := to_integer(OUT_RESULT);
            write(output_line, liczba1);
            write(output_line, operator);
            write(output_line, liczba2);
            write(output_line, string'(" = "));
            write(output_line, wynik);
            writeline(output_file, output_line);
            
            -- Wyświetl na konsoli
            report "Operacja: " & integer'image(liczba1) & " " & operator & " " & 
                   integer'image(liczba2) & " = " & integer'image(wynik);
        end loop;
        
        file_close(input_file);
        file_close(output_file);
        
       
        wait;
    end process;
end Behavioral;
