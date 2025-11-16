library IEEE;                               -- librería lógica
use IEEE.STD_LOGIC_1164.ALL;                -- tipos estándar
use IEEE.NUMERIC_STD.ALL;                   -- aritmética entero

entity attempt_counter is
    Generic (
        MAX_ATTEMPTS : integer := 3         -- intentos máximo
    );
    Port (
        clk            : in  STD_LOGIC;     -- reloj entrada
        reset          : in  STD_LOGIC;     -- reset global
        decrement      : in  STD_LOGIC;     -- bajar intento
        reload         : in  STD_LOGIC;     -- recargar intentos
        attempts_left  : out integer range 0 to MAX_ATTEMPTS;  -- intentos quedan
        attempts_zero  : out STD_LOGIC      -- sin intentos
    );
end attempt_counter;

architecture Behavioral of attempt_counter is
    -- Contador interno
    signal counter : integer range 0 to MAX_ATTEMPTS := MAX_ATTEMPTS;  -- contador actual
    
begin
    -- Proceso del contador
    process(clk, reset)                      -- lógica contador
    begin
        if reset = '1' then                 -- reset activo
            counter <= MAX_ATTEMPTS;        -- reiniciar contador
        elsif rising_edge(clk) then         -- flanco subida
            if reload = '1' then            -- recargar pedido
                counter <= MAX_ATTEMPTS;    -- cargar máximo
            elsif decrement = '1' and counter > 0 then  -- condición bajar
                counter <= counter - 1;     -- decrementar uno
            end if;
        end if;
    end process;
    
    -- Salidas
    attempts_left <= counter;               -- enviar contador
    attempts_zero <= '1' when counter = 0 else '0';  -- cero intentos

end Behavioral;

