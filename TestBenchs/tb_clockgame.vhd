library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_clock_dividesr is
end tb_clock_dividesr;

architecture Behavioral of tb_clock_dividesr is

    -- Parámetro reducido para observar fácilmente los pulsos
    constant DIVISOR_SIM : integer := 10;

    signal clk_in     : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal enable_out : STD_LOGIC;

    -- Período del reloj de simulación
    constant clk_period : time := 10 ns;

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

begin

    -- Instancia del módulo
    uut: clock_divider
        generic map (
            DIVISOR => DIVISOR_SIM
        )
        port map (
            clk_in     => clk_in,
            reset      => reset,
            enable_out => enable_out
        );

    -- Generación del reloj
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Estado inicial
        reset <= '1';
        wait for 50 ns;

        reset <= '0';
        report "Reset desactivado, iniciando conteo";

        -- Ejecutar por varios ciclos para ver pulsos
        wait for 300 ns;

        -- Activar reset en medio de la operación
        report "Aplicando reset nuevamente";
        reset <= '1';
        wait for 40 ns;

        reset <= '0';
        report "Reinicio completado";

        wait for 300 ns;

        report "Fin de la simulación";
        wait;
    end process;

end Behavioral;


