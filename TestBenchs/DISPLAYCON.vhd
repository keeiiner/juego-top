library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_controllers is
end tb_display_controllers;

architecture Behavioral of tb_display_controllers is

    -- Componente bajo prueba
    component display_controller
        Port (
            clk          : in STD_LOGIC;
            reset        : in STD_LOGIC;
            digit0       : in STD_LOGIC_VECTOR(3 downto 0);
            digit1       : in STD_LOGIC_VECTOR(3 downto 0);
            digit2       : in STD_LOGIC_VECTOR(3 downto 0);
            digit3       : in STD_LOGIC_VECTOR(3 downto 0);
            enable0      : in STD_LOGIC;
            enable1      : in STD_LOGIC;
            enable2      : in STD_LOGIC;
            enable3      : in STD_LOGIC;
            special_mode : in STD_LOGIC;
            an           : out STD_LOGIC_VECTOR(3 downto 0);
            seg          : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Señales del testbench
    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal digit0       : STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- 0
    signal digit1       : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- 1
    signal digit2       : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- 2
    signal digit3       : STD_LOGIC_VECTOR(3 downto 0) := "0011"; -- 3

    signal enable0      : STD_LOGIC := '1';
    signal enable1      : STD_LOGIC := '1';
    signal enable2      : STD_LOGIC := '1';
    signal enable3      : STD_LOGIC := '1';

    signal special_mode : STD_LOGIC := '0';

    signal an  : STD_LOGIC_VECTOR(3 downto 0);
    signal seg : STD_LOGIC_VECTOR(6 downto 0);

begin

    --------------------------------------------------------------------
    -- Generador de reloj
    --------------------------------------------------------------------
    clk <= not clk after 10 ns;

    --------------------------------------------------------------------
    -- Instancia del DUT
    --------------------------------------------------------------------
    dut: display_controller
        port map (
            clk          => clk,
            reset        => reset,
            digit0       => digit0,
            digit1       => digit1,
            digit2       => digit2,
            digit3       => digit3,
            enable0      => enable0,
            enable1      => enable1,
            enable2      => enable2,
            enable3      => enable3,
            special_mode => special_mode,
            an           => an,
            seg          => seg
        );

    --------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------
    stim_proc : process
    begin
        
        report "===== INICIO DE SIMULACION DEL DISPLAY =====";

        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        -- Esperar algunos ciclos para ver el multiplexado
        wait for 500 us;

        -- Activar modo especial
        report "Cambiando a modo especial";
        special_mode <= '1';
        digit0 <= "0111";  -- F
        digit1 <= "1010";  -- A
        digit2 <= "0001";  -- I
        digit3 <= "1100";  -- L

        wait for 300 us;

        -- Deshabilitar algunos displays
        report "Desactivando displays 2 y 3";
        enable2 <= '0';
        enable3 <= '0';

        wait for 500 us;

        report "===== FIN DE SIMULACION =====";
        wait;
    end process;

end Behavioral;
