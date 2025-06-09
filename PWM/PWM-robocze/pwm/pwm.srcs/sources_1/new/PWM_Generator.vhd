library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_Generator is
    Port ( 
        clk        : in  STD_LOGIC;                     
        reset      : in  STD_LOGIC;                     
        sw         : in  STD_LOGIC_VECTOR(3 downto 0);  
        pwm_out    : out STD_LOGIC;                     
        pmod_out   : out STD_LOGIC;                     
        aud_sd     : out STD_LOGIC;                     
        led        : out STD_LOGIC_VECTOR(3 downto 0)   
    );
end PWM_Generator;

architecture Behavioral of PWM_Generator is
    constant CLK_FREQ      : integer := 100000000;     
    constant PWM_FREQ      : integer := 100000;        
    constant PWM_PERIOD    : integer := CLK_FREQ / PWM_FREQ; 
    constant PWM_WIDTH     : integer := 10;            
    
    -- tabela wartosci sinusa
    type sine_table_type is array (0 to 255) of integer range 0 to 1023;
    constant SINE_TABLE : sine_table_type := (
        512, 525, 537, 550, 562, 575, 587, 599, 611, 624, 636, 648, 660, 671, 683, 694,
        706, 717, 728, 739, 750, 760, 771, 781, 791, 801, 811, 820, 830, 839, 848, 856,
        865, 873, 881, 889, 896, 904, 911, 918, 924, 931, 937, 943, 948, 954, 959, 964,
        968, 972, 976, 980, 983, 986, 989, 991, 993, 995, 997, 998, 999, 999, 1000, 1000,
        1000, 999, 999, 998, 997, 995, 993, 991, 989, 986, 983, 980, 976, 972, 968, 964,
        959, 954, 948, 943, 937, 931, 924, 918, 911, 904, 896, 889, 881, 873, 865, 856,
        848, 839, 830, 820, 811, 801, 791, 781, 771, 760, 750, 739, 728, 717, 706, 694,
        683, 671, 660, 648, 636, 624, 611, 599, 587, 575, 562, 550, 537, 525, 512, 499,
        487, 474, 462, 449, 437, 425, 413, 400, 388, 376, 364, 353, 341, 330, 318, 307,
        296, 285, 274, 264, 253, 243, 233, 223, 213, 204, 194, 185, 176, 168, 159, 151,
        143, 135, 128, 120, 113, 106, 100, 93, 87, 81, 76, 70, 65, 60, 56, 52,
        48, 44, 41, 38, 35, 33, 31, 29, 27, 26, 25, 25, 24, 24, 24, 25,
        25, 26, 27, 29, 31, 33, 35, 38, 41, 44, 48, 52, 56, 60, 65, 70,
        76, 81, 87, 93, 100, 106, 113, 120, 128, 135, 143, 151, 159, 168, 176, 185,
        194, 204, 213, 223, 233, 243, 253, 264, 274, 285, 296, 307, 318, 330, 341, 353,
        364, 376, 388, 400, 413, 425, 437, 449, 462, 474, 487, 499, 512, 525, 537, 550
    );
    
    -- DDS 
    signal phase_acc_3_75kHz : unsigned(31 downto 0) := (others => '0');
    signal phase_acc_2_85kHz : unsigned(31 downto 0) := (others => '0');
    
    -- incrementy fazy dla DDS
    constant PHASE_INC_3_75kHz : unsigned(31 downto 0) := to_unsigned(161061, 32);
    constant PHASE_INC_2_85kHz : unsigned(31 downto 0) := to_unsigned(122407, 32);
    
    signal dds_index_3_75   : integer range 0 to 255 := 0;  
    signal dds_index_2_85   : integer range 0 to 255 := 0;  
    
    signal pwm_counter      : integer range 0 to PWM_PERIOD-1 := 0;
    signal ramp_divider     : integer range 0 to CLK_FREQ/(2000*1024) := 0;
    signal ramp_counter     : integer range 0 to 1023 := 0;
    signal sine_divider     : integer range 0 to CLK_FREQ/(1000*256) := 0;
    signal sine_index       : integer range 0 to 255 := 0;
    signal pwm_value        : unsigned(PWM_WIDTH-1 downto 0) := (others => '0');
    signal mode             : integer range 0 to 4 := 4;  
    
begin
    -- indeksy z akumulatorow fazy
    dds_index_3_75 <= to_integer(phase_acc_3_75kHz(31 downto 24));  
    dds_index_2_85 <= to_integer(phase_acc_2_85kHz(31 downto 24));  
    
    -- generacja PWM
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_counter <= 0;
            pwm_out <= '0';
            pmod_out <= '0';
            aud_sd <= '0';  
        elsif rising_edge(clk) then
            -- licznik PWM 
            if pwm_counter = PWM_PERIOD-1 then
                pwm_counter <= 0;
            else
                pwm_counter <= pwm_counter + 1;
            end if;
            
            -- generuj PWM
            if mode = 4 then  
                pwm_out <= '0';  
                pmod_out <= '0';  
                aud_sd <= '0';   
            else
                aud_sd <= '1';
                
                if pwm_counter < to_integer(pwm_value) then
                    pwm_out <= '1';   
                    pmod_out <= '1';  
                else
                    pwm_out <= '0';   
                    pmod_out <= '0';  
                end if;
            end if;
        end if;
    end process;
    
    -- generacja przebiegow
    process(clk, reset)
    begin
        if reset = '1' then
            ramp_divider <= 0;
            ramp_counter <= 0;
            sine_divider <= 0;
            sine_index <= 0;
            phase_acc_3_75kHz <= (others => '0');
            phase_acc_2_85kHz <= (others => '0');
            pwm_value <= (others => '0');
            mode <= 4;      
            led <= "0000";  
        elsif rising_edge(clk) then
            
            -- dekoder trybu 
            if sw(0) = '1' then
                mode <= 0;      -- rampa 2kHz
                led <= "0001";  
            elsif sw(1) = '1' then
                mode <= 1;      -- sinus 1kHz
                led <= "0010";  
            elsif sw(2) = '1' then
                mode <= 2;      -- DDS sinus 3.75kHz
                led <= "0100";  
            elsif sw(3) = '1' then
                mode <= 3;      -- DDS sinus 2.85kHz
                led <= "1000";  
            else
                mode <= 4;      
                led <= "0000";  
            end if;
            
            -- generator rampy (2 kHz)
            if ramp_divider = CLK_FREQ/(2000*1024)-1 then
                ramp_divider <= 0;
                if ramp_counter = 1023 then
                    ramp_counter <= 0;  
                else
                    ramp_counter <= ramp_counter + 1;  
                end if;
            else
                ramp_divider <= ramp_divider + 1;
            end if;
            
            -- generator sinusa (1 kHz)
            if sine_divider = CLK_FREQ/(1000*256)-1 then
                sine_divider <= 0;
                if sine_index = 255 then
                    sine_index <= 0;  
                else
                    sine_index <= sine_index + 1;  
                end if;
            else
                sine_divider <= sine_divider + 1;
            end if;
            
            -- akumulatory DDS
            phase_acc_3_75kHz <= phase_acc_3_75kHz + PHASE_INC_3_75kHz;
            phase_acc_2_85kHz <= phase_acc_2_85kHz + PHASE_INC_2_85kHz;
            
            -- wybor sygnalu
            case mode is
                when 0 => 
                    pwm_value <= to_unsigned(ramp_counter, PWM_WIDTH);
                    
                when 1 => 
                    pwm_value <= to_unsigned(SINE_TABLE(sine_index), PWM_WIDTH);
                    
                when 2 => 
                    pwm_value <= to_unsigned(SINE_TABLE(dds_index_3_75), PWM_WIDTH);
                    
                when 3 => 
                    pwm_value <= to_unsigned(SINE_TABLE(dds_index_2_85), PWM_WIDTH);
                    
                when others => 
                    pwm_value <= (others => '0');
            end case;
        end if;
    end process;
    
end Behavioral;