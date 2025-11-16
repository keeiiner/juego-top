library IEEE;  -- librerías VHDL
use IEEE.STD_LOGIC_1164.ALL;  -- lógica estándar
use IEEE.NUMERIC_STD.ALL;  -- tipos numéricos

--------------------------------------------------------------------
-- Módulo: game_attempt_counter
-- Descripción: Contador intentos juego
-- Similar a attempt_counter pero para el juego
--------------------------------------------------------------------
entity game_attempt_counter is
    Generic (
        MAX_ATTEMPTS : integer := 5  -- valor máximo
    );
    Port (
        clk            : in  STD_LOGIC;  -- reloj entrada
        reset          : in  STD_LOGIC;  -- reset global
        decrement      : in  STD_LOGIC;  -- restar intento
        reload         : in  STD_LOGIC;  -- recargar valor
        attempts_left  : out integer range 0 to MAX_ATTEMPTS; -- intentos actuales
        attempts_zero  : out STD_LOGIC  -- llegó cero
    );
end game_attempt_counter;

architecture Behavioral of game_attempt_counter is
    signal counter : integer range 0 to MAX_ATTEMPTS := MAX_ATTEMPTS;  -- contador interno
    
begin
    process(clk, reset)  -- proceso contador
    begin
        if reset = '1' then
            counter <= MAX_ATTEMPTS;  -- reiniciar contador
        elsif rising_edge(clk) then  -- flanco subida
            if reload = '1' then
                counter <= MAX_ATTEMPTS;  -- recargar intentos
            elsif decrement = '1' and counter > 0 then
                counter <= counter - 1;  -- restar intento
            end if;
        end if;
    end process;
    
    attempts_left <= counter;  -- salida contador
    attempts_zero <= '1' when counter = 0 else '0';  -- comparar cero

end Behavioral;
