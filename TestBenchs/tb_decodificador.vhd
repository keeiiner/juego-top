library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_seven_seg_decoder is
end tb_seven_seg_decoder;

architecture Behavioral of tb_seven_seg_decoder is
    
    component seven_seg_decoder is
        Port (
            digit        : in  STD_LOGIC_VECTOR(3 downto 0);
            special_char : in  STD_LOGIC;
            seg          : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal digit        : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal special_char : STD_LOGIC := '0';
    signal seg          : STD_LOGIC_VECTOR(6 downto 0);

    -- convertir vector a texto (para ver en consola)
    function to_string(s : std_logic_vector) return string is
        variable result : string (1 to s'length);
    begin
        for i in s'range loop
            result(i - s'low + 1) := character'VALUE(std_ulogic'IMAGE(s(i))(2));
        end loop;
        return result;
    end function;

begin
    
    uut: seven_seg_decoder
        port map(
            digit        => digit,
            special_char => special_char,
            seg          => seg
        );

    process
    begin
        report "========== INICIO SIMULACION SEVEN SEG DECODER ==========";

        ------------------------------------------------------------
        -- MODO NORMAL: probar todos los dígitos 0000-1111
        ------------------------------------------------------------
        special_char <= '0';
        for i in 0 to 15 loop
            digit <= std_logic_vector(to_unsigned(i, 4));
            wait for 20 ns;
            report "NORMAL  digit=" & integer'image(i) &
                   "  seg=" & to_string(seg);
        end loop;

        ------------------------------------------------------------
        -- MODO ESPECIAL
        ------------------------------------------------------------
        special_char <= '1';
        for i in 0 to 15 loop
            digit <= std_logic_vector(to_unsigned(i, 4));
            wait for 20 ns;
            report "SPECIAL digit=" & integer'image(i) &
                   "  seg=" & to_string(seg);
        end loop;

        report "========== FIN SIMULACION SEVEN SEG DECODER ==========";
        wait;
    end process;

end Behavioral;

