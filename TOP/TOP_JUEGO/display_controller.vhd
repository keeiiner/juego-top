library IEEE;                     -- librerías básicas
use IEEE.STD_LOGIC_1164.ALL;      -- lógica estándar
use IEEE.NUMERIC_STD.ALL;         -- aritmética unsigned

library work;                     -- librería local
use work.all;                     -- todo importado

entity display_controller is
Port (
    clk          : in STD_LOGIC;                     -- reloj sistema
    reset        : in STD_LOGIC;                     -- reset global
    digit0       : in STD_LOGIC_VECTOR(3 downto 0);  -- dígito 0
    digit1       : in STD_LOGIC_VECTOR(3 downto 0);  -- dígito 1
    digit2       : in STD_LOGIC_VECTOR(3 downto 0);  -- dígito 2
    digit3       : in STD_LOGIC_VECTOR(3 downto 0);  -- dígito 3
    enable0      : in STD_LOGIC;                     -- habilitar 0
    enable1      : in STD_LOGIC;                     -- habilitar 1
    enable2      : in STD_LOGIC;                     -- habilitar 2
    enable3      : in STD_LOGIC;                     -- habilitar 3
    special_mode : in STD_LOGIC;                     -- modo especial
    an           : out STD_LOGIC_VECTOR(3 downto 0); -- ánodos salida
    seg          : out STD_LOGIC_VECTOR(6 downto 0)  -- segmentos out
);
end display_controller;

architecture Behavioral of display_controller is
    
    component seven_seg_decoder is
        Port (
            digit        : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito dec
            special_char : in  STD_LOGIC;                    -- char esp
            seg          : out STD_LOGIC_VECTOR(6 downto 0)  -- segm out
        );
    end component;
    
    signal refresh_counter : unsigned(17 downto 0) := (others => '0'); -- contador mux
    signal digit_select    : STD_LOGIC_VECTOR(1 downto 0);            -- selector dig
    signal current_digit   : STD_LOGIC_VECTOR(3 downto 0);            -- dígito actual
    signal current_an      : STD_LOGIC_VECTOR(3 downto 0);            -- ánodo actual
    
begin
    
    decoder: seven_seg_decoder port map(
        digit        => current_digit,   -- entra dígito
        special_char => special_mode,    -- modo especial
        seg          => seg              -- salida seg
    );
    
    process(clk, reset)                  -- refresco mux
    begin
        if reset = '1' then
            refresh_counter <= (others => '0'); -- contador cero
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1; -- incrementar
        end if;
    end process;
    
    digit_select <= std_logic_vector(refresh_counter(17 downto 16)); -- bits mux
    
    process(digit_select, digit0, digit1, digit2, digit3, 
            enable0, enable1, enable2, enable3)
    begin
        case digit_select is
            
            when "00" =>                     -- dígito 0
                current_digit <= digit0;     -- asignar d0
                if enable0 = '1' then
                    current_an <= "1110";    -- activar d0
                else
                    current_an <= "1111";    -- apagar todos
                end if;
            
            when "01" =>                     -- dígito 1
                current_digit <= digit1;     -- asignar d1
                if enable1 = '1' then
                    current_an <= "1101";    -- activar d1
                else
                    current_an <= "1111";    -- apagar todos
                end if;
            
            when "10" =>                     -- dígito 2
                current_digit <= digit2;     -- asignar d2
                if enable2 = '1' then
                    current_an <= "1011";    -- activar d2
                else
                    current_an <= "1111";    -- apagar todos
                end if;
            
            when "11" =>                     -- dígito 3
                current_digit <= digit3;     -- asignar d3
                if enable3 = '1' then
                    current_an <= "0111";    -- activar d3
                else
                    current_an <= "1111";    -- apagar todos
                end if;
            
            when others =>                   -- caso inválido
                current_an <= "1111";        -- desactivar
                current_digit <= "0000";     -- cero
        end case;
    end process;
    
    an <= current_an;                       -- salida ánodos

end Behavioral;
