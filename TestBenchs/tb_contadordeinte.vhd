library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_game_attempt_counter is
end tb_game_attempt_counter;

architecture Behavioral of tb_game_attempt_counter is

    -- Componente a probar
    component game_attempt_counter
        Generic (
            MAX_ATTEMPTS : integer := 5
        );
        Port (
            clk            : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            decrement      : in  STD_LOGIC;
            reload         : in  STD_LOGIC;
            attempts_left  : out integer range 0 to MAX_ATTEMPTS;
            attempts_zero  : out STD_LOGIC
        );
    end component;

    -- Señales del testbench
    signal clk         : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal decrement   : STD_LOGIC := '0';
    signal reload      : STD_LOGIC := '0';
    signal attempts_left : integer range 0 to 5;
    signal attempts_zero : STD_LOGIC;

begin

    --------------------------------------------------------------------
    -- Generar reloj
    --------------------------------------------------------------------
    clk <= not clk after 10 ns;  -- frecuencia 50 MHz aprox.

    --------------------------------------------------------------------
    -- Instancia del DUT (Device Under Test)
    --------------------------------------------------------------------
    dut: game_attempt_counter
        generic map (MAX_ATTEMPTS => 5)
        port map (
            clk           => clk,
            reset         => reset,
            decrement     => decrement,
            reload        => reload,
            attempts_left => attempts_left,
            attempts_zero => attempts_zero
        );

    --------------------------------------------------------------------
    -- Estímulos de prueba
    --------------------------------------------------------------------
    stim: process
    begin
        report "==== INICIO DE SIMULACION ====";

        -- 1) Reset inicial
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2) Probar decrementos
        report "Decrementando intentos...";
        decrement <= '1';
        wait for 20 ns;
        decrement <= '0';
        wait for 20 ns;

        decrement <= '1';
        wait for 20 ns;
        decrement <= '0';
        wait for 20 ns;

        decrement <= '1';
        wait for 20 ns;
        decrement <= '0';
        wait for 20 ns;

        decrement <= '1';
        wait for 20 ns;
        decrement <= '0';
        wait for 20 ns;

        decrement <= '1';
        wait for 20 ns;
        decrement <= '0';
        wait for 20 ns;

        -- 3) Probar cuando llega a CERO
        report "Intentos en cero, verificando attempts_zero...";

        wait for 40 ns;

        -- 4) Recargar intentos
        report "Recargando intentos...";
        reload <= '1';
        wait for 20 ns;
        reload <= '0';

        wait for 40 ns;

        report "==== FIN DE SIMULACION ====";
        wait;
    end process;

end Behavioral;
