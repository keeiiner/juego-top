library IEEE;                        
use IEEE.STD_LOGIC_1164.ALL;         
use IEEE.NUMERIC_STD.ALL;            

--------------------------------------------------------------------
-- Módulo: clock_divider
-- Genera PULSOS de enable
--------------------------------------------------------------------
entity clock_divider is
    Generic (
        DIVISOR : integer := 100_000_000  -- divisor frecuencia
    );
    Port (
        clk_in     : in  STD_LOGIC;       -- reloj entrada
        reset      : in  STD_LOGIC;       -- reset global
        enable_out : out STD_LOGIC        -- pulso salida
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : integer range 0 to DIVISOR-1 := 0;  -- contador interno
begin
    process(clk_in, reset)                 -- proceso principal
    begin
        if reset = '1' then               -- reset activo
            counter <= 0;                 -- reinicia contador
            enable_out <= '0';            -- apaga pulso
            
        elsif rising_edge(clk_in) then    -- flanco subida
            if counter = DIVISOR-1 then   -- fin conteo
                counter <= 0;             -- reinicia contador
                enable_out <= '1';        -- pulso activo
            else
                counter <= counter + 1;   -- incrementar contador
                enable_out <= '0';        -- sin pulso
            end if;
        end if;
    end process;
end Behavioral;
