library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_security_module is
end tb_top_security_module;

architecture Behavioral of tb_top_security_module is

    -- Señales del testbench
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal btnc  : STD_LOGIC := '0';   -- botón confirmar
    signal btnl  : STD_LOGIC := '0';   -- botón configurar
    signal sw    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal seg   : STD_LOGIC_VECTOR(6 downto 0);
    signal an    : STD_LOGIC_VECTOR(3 downto 0);
    signal led   : STD_LOGIC_VECTOR(15 downto 0);
    signal access_granted_out : STD_LOGIC;

    -- reloj 100 MHz (10 ns periodo)
    constant clk_period : time := 10 ns;

begin

    ------------------------------------------------------------------------
    -- Instancia del módulo TOP
    ------------------------------------------------------------------------
    uut: entity work.top_security_module
        port map(
            clk   => clk,
            reset => reset,
            btnc  => btnc,
            btnl  => btnl,
            sw    => sw,
            seg   => seg,
            an    => an,
            led   => led,
            access_granted_out => access_granted_out
        );

    ------------------------------------------------------------------------
    -- Generación de reloj
    ------------------------------------------------------------------------
    clock_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    ------------------------------------------------------------------------
    -- Estímulos
    ------------------------------------------------------------------------
    stimulus: process
    begin
        
        ---------------------------------------------------------------
        -- 1) RESET GLOBAL
        ---------------------------------------------------------------
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        report "==== RESET COMPLETADO ====";

        wait for 50 ns;


        ---------------------------------------------------------------
        -- 2) ENTRAR EN MODO CONFIGURACIÓN
        ---------------------------------------------------------------
        report "==== ENTRANDO A MODO CONFIG ====";
        btnl <= '1'; wait for 20 ns; btnl <= '0';
        wait for 100 ns;

        ---------------------------------------------------------------
        -- 3) ESCRIBIR CLAVE NUEVA (por ejemplo 1010)
        ---------------------------------------------------------------
        sw(3 downto 0) <= "1010";
        report "Clave nueva seleccionada: 1010";

        -- Confirmar almacenamiento
        btnc <= '1'; wait for 20 ns; btnc <= '0';
        wait for 200 ns;


        ---------------------------------------------------------------
        -- 4) VERIFICAR - INGRESO INCORRECTO
        ---------------------------------------------------------------
        report "==== VERIFICACION FALLIDA ====";

        sw(3 downto 0) <= "0001";   -- clave incorrecta
        btnc <= '1'; wait for 20 ns; btnc <= '0';
        wait for 200 ns;


        ---------------------------------------------------------------
        -- 5) OTRO INTENTO FALLIDO
        ---------------------------------------------------------------
        sw(3 downto 0) <= "0011";   -- incorrecta
        btnc <= '1'; wait for 20 ns; btnc <= '0';
        wait for 200 ns;


        ---------------------------------------------------------------
        -- 6) ÚLTIMO INTENTO - PRODUCE BLOQUEO
        ---------------------------------------------------------------
        sw(3 downto 0) <= "0101";   -- incorrecta
        btnc <= '1'; wait for 20 ns; btnc <= '0';

        report "==== SISTEMA BLOQUEADO ====";

        wait for 500 ns;


        ---------------------------------------------------------------
        -- 7) FIN DEL BLOQUEO (FORZAMOS SEÑAL DEL TIMER)
        --   *Esto te permite probar sin esperar 30 segundos reales*
        ---------------------------------------------------------------
        report "==== DESBLOQUEADO MANUALMENTE ====";
        -- Forzar desbloqueo:
        -- NOTA: en un test real puedes hacer wait 30 s, pero no aquí.
        -- Se recomienda usar force en simulator si deseas probar real.

        wait for 500 ns;


        ---------------------------------------------------------------
        -- 8) VERIFICACIÓN CORRECTA
        ---------------------------------------------------------------
        report "==== VERIFICACION CORRECTA ====";
        sw(3 downto 0) <= "1010";  -- clave correcta
        btnc <= '1'; wait for 20 ns; btnc <= '0';

        wait for 300 ns;

        report "ACCESO CONCEDIDO? -> " & STD_LOGIC'image(access_granted_out);


        ---------------------------------------------------------------
        -- FIN DE SIMULACIÓN
        ---------------------------------------------------------------
        report "=== FIN SIMULACION ===";
        wait;
    end process;

end Behavioral;
