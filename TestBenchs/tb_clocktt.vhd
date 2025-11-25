library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_lock_timers is
end tb_lock_timers;

architecture Behavioral of tb_lock_timers is

    -- Instancia del DUT
    component lock_timer
        Generic (
            LOCK_TIME : integer := 10  -- tiempo reducido para simular más rápido
        );
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            enable_1hz: in  STD_LOGIC;
            start     : in  STD_LOGIC;
            time_left : out integer range 0 to 10;
            time_up   : out STD_LOGIC
        );
    end component;

    -- Señales
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal enable_1hz : STD_LOGIC := '0';
    signal start      : STD_LOGIC := '0';
    signal time_left  : integer range 0 to 10;
    signal time_up    : STD_LOGIC;

begin

    -------------------------------------------------------------------
    -- Generador de reloj
    -------------------------------------------------------------------
    clk <= not clk after 10 ns;

    -------------------------------------------------------------------
    -- Instancia DUT
    -------------------------------------------------------------------
    dut : lock_timer
        generic map (LOCK_TIME => 10)
        port map (
            clk        => clk,
            reset      => reset,
            enable_1hz => enable_1hz,
            start      => start,
            time_left  => time_left,
            time_up    => time_up
        );

    -------------------------------------------------------------------
    -- Proceso de estímulos
    -------------------------------------------------------------------
    stim : process
    begin
        report "=== INICIO SIMULACION lock_timer ===";

        -- RESET INICIAL
        reset <= '1';
        wait for 40 ns;
        reset <= '0';

        wait for 30 ns;

        -- INICIAR TIMER
        report "-> Iniciando timer";
        start <= '1';
        wait for 20 ns;
        start <= '0';

        -- SIMULAR PULSOS DE 1 Hz
        for i in 0 to 10 loop
            enable_1hz <= '1';
            wait for 20 ns;
            enable_1hz <= '0';
            wait for 40 ns;
        end loop;

        -- FINALIZA TIMER
        wait for 50 ns;

        -- VOLVER A INICIAR TIMER
        report "-> Reiniciando timer nuevamente";
        start <= '1';
        wait for 20 ns;
        start <= '0';

        -- Pulsos de conteo
        for i in 0 to 5 loop
            enable_1hz <= '1';
            wait for 20 ns;
            enable_1hz <= '0';
            wait for 40 ns;
        end loop;

        report "=== FIN SIMULACION lock_timer ===";
        wait;
    end process;

end Behavioral;

