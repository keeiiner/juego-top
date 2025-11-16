library IEEE;  -- librerías VHDL
use IEEE.STD_LOGIC_1164.ALL;  -- lógica estándar
use IEEE.NUMERIC_STD.ALL;  -- tipos numéricos

entity message_timer is
    Port (
        clk       : in  STD_LOGIC;   -- reloj entrada
        reset     : in  STD_LOGIC;   -- reset global
        enable_1hz: in  STD_LOGIC;   -- pulso 1Hz
        start     : in  STD_LOGIC;   -- iniciar conteo
        time_up   : out STD_LOGIC    -- tiempo acabado
    );
end message_timer;

architecture Behavioral of message_timer is
    signal counter : integer range 0 to 3 := 0;  -- contador tiempo
    signal running : STD_LOGIC := '0';  -- estado activo
    signal start_prev : STD_LOGIC := '0';  -- flanco inicio
    signal time_up_internal : STD_LOGIC := '0';  -- señal interna
    
begin
    
    process(clk, reset)  -- proceso principal
    begin
        if reset = '1' then
            counter <= 0;  -- reinicio contador
            running <= '0';  -- detener conteo
            start_prev <= '0';  -- limpiar inicio
            time_up_internal <= '0';  -- limpiar fin
            
        elsif rising_edge(clk) then
            start_prev <= start;  -- guardar previo
            time_up_internal <= '0';  -- limpiar pulso
            
            -- Detectar inicio
            if start = '1' and start_prev = '0' then
                counter <= 3;  -- cargar valor
                running <= '1';  -- activar conteo
                
            -- Decrementar con 1Hz
            elsif running = '1' and enable_1hz = '1' then
                if counter > 0 then
                    counter <= counter - 1;  -- restar uno
                else
                    running <= '0';  -- detener
                    time_up_internal <= '1';  -- generar pulso
                end if;
            end if;
        end if;
    end process;
    
    time_up <= time_up_internal;  -- salida final

end Behavioral;
