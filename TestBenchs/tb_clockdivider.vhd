library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_clock_divider is
end tb_clock_divider;

architecture Behavioral of tb_clock_divider is

    -- Parámetro pequeño para simular rápido
    constant DIV_VALUE : integer := 10;

    -- Componente bajo prueba
    component clock_divider
        Generic (
            DIVISOR : integer := 100_000_000
        );
        Port (
            clk_in     : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            enable_out : out STD_LOGIC
        );
    end component;

    -- Señales para el TB
    signal clk_in     : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal enable_out : STD_LOGIC;

begin

    -- Instancia del DUT (Device Under Test)
    uut: clock_divider
        generic map (DIVISOR => DIV_VALUE)
        port map(
            clk_in     => clk_in,
            reset      => reset,
            enable_out => enable_out
        );

    -- Generador de reloj 10 ns (100 MHz)
    clk_in <= not clk_in after 5 ns;

    -- Estímulos
    stim_proc: process
    begin
        report "================= INICIO DE SIMULACION =================";

        -- RESET INICIAL
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        report "Reset liberado. Comienza el conteo del divisor.";

        -- Esperamos varios ciclos para observar pulsos
        wait for 200 ns;

        report "================= FIN DE SIMULACION ===================";
        wait;
    end process;

end Behavioral;
