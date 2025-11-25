library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_prng_4bit is
end tb_prng_4bit;

architecture Behavioral of tb_prng_4bit is

    -- Señales de prueba
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal gen_new  : STD_LOGIC := '0';
    signal random   : STD_LOGIC_VECTOR(3 downto 0);

    -- Periodo del clock (100 MHz → 10 ns)
    constant clk_period : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    --------------------------------------------------------------------
    -- Instancia del DUT
    --------------------------------------------------------------------
    uut: entity work.prng_4bit
        port map(
            clk     => clk,
            reset   => reset,
            gen_new => gen_new,
            random  => random
        );

    --------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------
    stim_proc : process
    begin
        
        -- Reset inicial
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Generar varios números pseudoaleatorios
        ----------------------------------------------------------------
        for i in 0 to 7 loop
            -- Flanco de subida en gen_new
            gen_new <= '1';
            wait for clk_period;
            gen_new <= '0';
            
            wait for 80 ns;  -- LFSR sigue avanzando antes del siguiente capture
        end loop;

        ----------------------------------------------------------------
        -- Final simulación
        ----------------------------------------------------------------
        wait for 200 ns;
        assert false report "FIN DE LA SIMULACION" severity failure;

    end process;

end Behavioral;
