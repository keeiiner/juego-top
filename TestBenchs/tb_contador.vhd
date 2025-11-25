library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_attempt_counter is
end tb_attempt_counter;

architecture Behavioral of tb_attempt_counter is

    -- Componente bajo prueba
    component attempt_counter
        Generic (
            MAX_ATTEMPTS : integer := 3
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

    -- Señales del TB
    signal clk           : STD_LOGIC := '0';
    signal reset         : STD_LOGIC := '0';
    signal decrement     : STD_LOGIC := '0';
    signal reload        : STD_LOGIC := '0';

    signal attempts_left : integer range 0 to 3;
    signal attempts_zero : STD_LOGIC;

    -- Para convertir integer a string (útil para EDA Playground)
    function int_to_string(x : integer) return string is
        variable s : string(1 to 11);
    begin
        write(s, x);
        return s;
    end function;

begin

    -- Instancia del contador
    uut: attempt_counter
        generic map(MAX_ATTEMPTS => 3)
        port map(
            clk            => clk,
            reset          => reset,
            decrement      => decrement,
            reload         => reload,
            attempts_left  => attempts_left,
            attempts_zero  => attempts_zero
        );

    -- Generar reloj de 10 ns
    clk <= not clk after 5 ns;

    -- Estímulos
    stim_proc: process
    begin
        report "==================== INICIO DE SIMULACION ====================";

        -- 1) Reset inicial
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;
        report "Después del reset, attempts_left = " & int_to_string(attempts_left);

        -- 2) Decremento 1
        decrement <= '1';
        wait for 10 ns;
        decrement <= '0';
        wait for 10 ns;
        report "Tras decremento 1 -> attempts_left = " & int_to_string(attempts_left);

        -- 3) Decremento 2
        decrement <= '1';
        wait for 10 ns;
        decrement <= '0';
        wait for 10 ns;
        report "Tras decremento 2 -> attempts_left = " & int_to_string(attempts_left);

        -- 4) Decremento 3 (llega a cero)
        decrement <= '1';
        wait for 10 ns;
        decrement <= '0';
        wait for 10 ns;
        report "Tras decremento 3 -> attempts_left = " & int_to_string(attempts_left);
        report "attempts_zero = " & attempts_zero;

        -- 5) Intento de decrementar en 0 (NO debe bajar más)
        decrement <= '1';
        wait for 10 ns;
        decrement <= '0';
        wait for 10 ns;
        report "Intento de decrementar estando en 0 -> attempts_left = " & int_to_string(attempts_left);

        -- 6) Recarga
        reload <= '1';
        wait for 10 ns;
        reload <= '0';
        wait for 10 ns;
        report "Tras recarga -> attempts_left = " & int_to_string(attempts_left);

        report "==================== FIN DE SIMULACION ====================";

        wait;
    end process;

end Behavioral;
