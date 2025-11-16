library IEEE;                                -- librería lógica
use IEEE.STD_LOGIC_1164.ALL;                 -- tipos estándar
use IEEE.NUMERIC_STD.ALL;                    -- aritmética entero

entity lock_timer is
    Generic (
        LOCK_TIME : integer := 30            -- tiempo bloqueo
    );
    Port (
        clk       : in  STD_LOGIC;           -- reloj entrada
        reset     : in  STD_LOGIC;           -- reset global
        enable_1hz: in  STD_LOGIC;           -- pulso 1hz
        start     : in  STD_LOGIC;           -- iniciar conteo
        time_left : out integer range 0 to LOCK_TIME;  -- tiempo resta
        time_up   : out STD_LOGIC            -- tiempo acabado
    );
end lock_timer;

architecture Behavioral of lock_timer is
    signal counter : integer range 0 to LOCK_TIME := 0;     -- contador tiempo
    signal running : STD_LOGIC := '0';                      -- estado activo
    signal start_prev : STD_LOGIC := '0';                   -- start previo
    signal time_up_internal : STD_LOGIC := '0';             -- pulso interno
    
begin

    process(clk, reset)                       -- proceso principal
    begin
        if reset = '1' then                   -- reset activo
            counter    <= 0;                  -- reinicio total
            running    <= '0';                -- parar conteo
            start_prev <= '0';                -- limpiar previo
            time_up_internal <= '0';          -- limpiar pulso
            
        elsif rising_edge(clk) then           -- flanco subida
            start_prev <= start;              -- guardar previo
            
            time_up_internal <= '0';          -- limpiar pulso
            
            if start = '1' and start_prev = '0' then    -- flanco start
                counter <= LOCK_TIME;         -- cargar valor
                running <= '1';               -- activar timer
                
            elsif running = '1' and enable_1hz = '1' then   -- contar 1hz
                if counter > 0 then           -- tiempo > cero
                    counter <= counter - 1;   -- restar uno
                else
                    running <= '0';           -- detener timer
                    time_up_internal <= '1';  -- pulso fin
                end if;
            end if;
        end if;
    end process;
    
    time_left <= counter;                     -- salida tiempo
    time_up <= time_up_internal;              -- salida pulso

end Behavioral;

