library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_lock_timer is
end tb_lock_timer;

architecture Behavioral of tb_lock_timer is

    -- Parámetro reducido para simulación rápida
    constant LOCK_T : integer := 5;

    component lock_timer is
        Generic (
            LOCK_TIME : integer := 30
        );
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            enable_1hz: in  STD_LOGIC;
            start     : in  STD_LOGIC;
            time_left : out integer range 0 to LOCK_TIME;
            time_up   : out STD_LOGIC
        );
    end component;

    -- Señales
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal enable_1hz : STD_LOGIC := '0';
    signal start      : STD_LOGIC := '0';
    signal time_left  : integer range 0 to LOCK_T;
    signal time_up    : STD_LOGIC;

begin

    -- Instancia del temporizador
    uut: lock_timer
        generic map(LOCK_TIME => LOCK_T)
        port map(
            clk        => clk,
            reset      => reset,
            enable_1hz => enable_1hz,
            start      => start,
            time_left  => time_left,
            time_up    => time_up
        );

    -- Reloj de 10 ns
    clk <= not clk after 5 ns;

    -- Pulso de 1 Hz simulado (real: 1 pulso por segundo, aquí: cada 20 ns)
    process
    begin
        wait for 20 ns;
        enable_1hz <= '1';
        wait for 10 ns;
        enable_1hz <= '0';
    end process;

    -- Estímulos de prueba
    stim_proc: process
    begin
        report "========== INICIO SIMULACION LOCK TIMER ==========";

        -- RESET
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 30 ns;

        -- Iniciar conteo (flanco start)
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Esperar a que termine el conteo
        wait for 200 ns;

        -- Iniciar nuevamente
        start <= '1';
        wait for 10 ns;
        start <= '0';

        wait for 200 ns;

        report "========== FIN SIMULACION LOCK TIMER ==========";
        wait;
    end process;

end Behavioral;

