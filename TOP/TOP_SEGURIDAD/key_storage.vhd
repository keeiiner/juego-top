library IEEE;                           -- librería lógica
use IEEE.STD_LOGIC_1164.ALL;            -- tipos estándar

entity key_storage is
    Port (
        clk        : in  STD_LOGIC;                      -- reloj entrada
        reset      : in  STD_LOGIC;                      -- reset global
        config_mode: in  STD_LOGIC;                      -- modo config
        key_in     : in  STD_LOGIC_VECTOR(3 downto 0);  -- clave entrada
        store_key  : in  STD_LOGIC;                      -- guardar clave
        stored_key : out STD_LOGIC_VECTOR(3 downto 0)   -- clave salida
    );
end key_storage;

architecture Behavioral of key_storage is
    -- Registro interno para almacenar la clave
    signal key_reg : STD_LOGIC_VECTOR(3 downto 0) := "0000";   -- registro clave
    
begin
    -- Proceso de almacenamiento
    process(clk, reset)                   -- proceso sincron
    begin
        if reset = '1' then               -- reset activo
            key_reg <= "0000";            -- clave default
        elsif rising_edge(clk) then       -- flanco subida
            -- Solo permite guardar en modo configuración
            if config_mode = '1' and store_key = '1' then  -- condición guardar
                key_reg <= key_in;        -- guardar clave
            end if;
        end if;
    end process;
    
    -- Salida de la clave almacenada
    stored_key <= key_reg;                -- salida registro

end Behavioral;
