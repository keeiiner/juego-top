library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_message_timer is
end tb_message_timer;

architecture sim of tb_message_timer is

    -- Señales del testbench
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal enable_1hz : STD_LOGIC := '0';
    signal start      : STD_LOGIC := '0';
    signal time_up    : STD_LOGIC;

    -- Periodo de reloj (100 MHz = 10 ns periodo → solo para sim)
    constant CLK_PERIOD : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- GENERADOR DE RELOJ
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;


    --------------------------------------------------------------------
    -- ESTÍMULOS PARA enable_1hz
    -- Se simula un pulso de 1 Hz pero en tiempo acelerado
    --------------------------------------------------------------------
    process
    begin
        wait for 50 ns;
        enable_1hz <= '1'; wait for 20 ns;
        enable_1hz <= '0'; wait for 80 ns;

        enable_1hz <= '1'; wait for 20 ns;
        enable_1hz <= '0'; wait for 80 ns;

        enable_1hz <= '1'; wait for 20 ns;
        enable_1hz <= '0'; wait for 80 ns;

        enable_1hz <= '1'; wait for 20 ns;
        enable_1hz <= '0'; wait for 80 ns;

        wait;
    end process;


    --------------------------------------------------------------------
    -- INSTANCIA DEL DUT (Device Under Test)
    --------------------------------------------------------------------
    uut: entity work.message_timer
        port map(
            clk        => clk,
            reset      => reset,
            enable_1hz => enable_1hz,
            start      => start,
            time_up    => time_up
        );


    --------------------------------------------------------------------
    -- ESTÍMULOS PRINCIPALES
    --------------------------------------------------------------------
    stimulus : process
    begin
        
        -- RESET INICIAL
        reset <= '1';
        wait for 40 ns;
        reset <= '0';

        -- INICIAR EL CONTADOR
        start <= '1';
        wait for 20 ns;
        start <= '0';

        -- Esperar varios pulsos de enable_1hz
        wait for 500 ns;

        -- Iniciar nuevamente
        start <= '1';
        wait for 20 ns;
        start <= '0';

        wait for 500 ns;

        wait;
    end process;

end sim;
