library IEEE;                         -- librerías básicas
use IEEE.STD_LOGIC_1164.ALL;          -- lógica estándar
use IEEE.NUMERIC_STD.ALL;             -- aritmética unsigned

entity seven_seg_decoder is
    Port (
        digit        : in  STD_LOGIC_VECTOR(3 downto 0); -- entrada dígito
        special_char : in  STD_LOGIC;                    -- modo especial
        seg          : out STD_LOGIC_VECTOR(6 downto 0)  -- salida seg
    );
end seven_seg_decoder;

architecture Behavioral of seven_seg_decoder is
begin
    process(digit, special_char)       -- decodificador seg
    begin
        if special_char = '1' then     -- modo especial
            case digit is              -- casos especiales
                
                when "0110" => seg <= "0111111"; -- guion
                
                when "0111" => seg <= "0001110"; -- F
                when "1010" => seg <= "0001000"; -- A
                when "0001" => seg <= "1111001"; -- I
                when "1100" => seg <= "1000111"; -- L
                
                when "1111" => seg <= "1111111"; -- off
                when others => seg <= "1111111"; -- off def
            end case;
        else                           -- modo normal
            case digit is              -- números letras
                
                when "0000" => seg <= "1000000"; -- 0
                when "0001" => seg <= "1111001"; -- 1
                when "0010" => seg <= "0100100"; -- 2
                when "0011" => seg <= "0110000"; -- 3
                when "0100" => seg <= "0011001"; -- 4
                when "0101" => seg <= "0010010"; -- 5
                when "0110" => seg <= "0000010"; -- 6
                when "0111" => seg <= "1111000"; -- 7
                when "1000" => seg <= "0000000"; -- 8
                when "1001" => seg <= "0010000"; -- 9
                
                when "1010" => seg <= "0001000"; -- A
                when "1011" => seg <= "0000011"; -- b
                when "1100" => seg <= "1000111"; -- L
                when "1101" => seg <= "0001001"; -- H
                when "1110" => seg <= "0000110"; -- E
                when "1111" => seg <= "1111111"; -- apagado
                
                when others => seg <= "1111111"; -- off
            end case;
        end if;
    end process;
end Behavioral;
