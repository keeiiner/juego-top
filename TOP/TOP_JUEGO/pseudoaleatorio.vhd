library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------
-- Módulo: prng_4bit
-- Genera números pseudoaleatorios de 4 bits usando un LFSR de 8 bits.
-- El LFSR corre continuamente y el valor final se captura únicamente
-- cuando hay un flanco de subida en la señal gen_new.
--------------------------------------------------------------------
entity prng_4bit is
    Port (
        clk      : in  STD_LOGIC;                       -- Reloj principal
        reset    : in  STD_LOGIC;                       -- Reset síncrono
        gen_new  : in  STD_LOGIC;                       -- Solicitud de nuevo número
        random   : out STD_LOGIC_VECTOR(3 downto 0)     -- Número pseudoaleatorio generado
    );
end prng_4bit;

architecture Behavioral of prng_4bit is
    
    -- Registro LFSR de 8 bits (free-running)
    -- Inicializado con una semilla fija
    signal lfsr : STD_LOGIC_VECTOR(7 downto 0) := "10101100";
    
    -- Registro para almacenar el valor pseudoaleatorio final (4 bits)
    signal captured_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    -- Registro para detectar flanco de subida en gen_new
    signal gen_prev : STD_LOGIC := '0';
    
begin
    
    ----------------------------------------------------------------
    -- Proceso principal: avanza el LFSR en cada flanco de reloj.
    -- Cuando detecta flanco de subida en gen_new,
    -- copia los 4 bits menos significativos del LFSR.
    ----------------------------------------------------------------
    process(clk, reset)
        variable feedback : STD_LOGIC;
    begin
        if reset = '1' then
            -- Estado inicial al activar reset
            lfsr <= "10101100";
            captured_value <= "0000";
            gen_prev <= '0';
            
        elsif rising_edge(clk) then
            -- Guardar el estado anterior de gen_new
            gen_prev <= gen_new;
            
            -- Cálculo del bit de realimentación (polinomio de taps)
            feedback := lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3);
            
            -- Desplazamiento del LFSR (corre siempre)
            lfsr <= lfsr(6 downto 0) & feedback;
            
            -- Captura del nuevo valor si hubo flanco de subida
            if gen_new = '1' and gen_prev = '0' then
                captured_value <= lfsr(3 downto 0);
            end if;
        end if;
    end process;
    
    -- Salida estable: el valor capturado
    random <= captured_value;

end Behavioral;
