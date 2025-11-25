library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_display_controller is
end tb_display_controller;
architecture Behavioral of tb_display_controller is
    -- Componente bajo prueba
    component display_controller is
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

    -- Señales
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
    signal an           : STD_LOGIC_VECTOR(3 downto 0);
    signal seg          : STD_LOGIC_VECTOR(6 downto 0);
begin
    -- Instancia del módulo
    uut: display_controller
        port map(
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

    -- Generador de reloj (10 ns -> 100 MHz)
    clk <= not clk after 5 ns;

    -- Estímulos
    stim_proc: process
    begin
        report "========== INICIO SIMULACION DISPLAY ==========";

        -- RESET
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 50 ns;
        -- Cambios de dígitos
        digit0 <= "0101";  -- 5
        digit1 <= "0110";  -- 6
        digit2 <= "0111";  -- 7
        digit3 <= "1000";  -- 8
        wait for 100 ns;

        -- Deshabilitar algunos dígitos
        enable1 <= '0';
        enable3 <= '0';
        wait for 100 ns;

        -- Activar modo especial
        special_mode <= '1';
        wait for 100 ns;

        -- Probar nuevamente todos habilitados
        enable1 <= '1';
        enable3 <= '1';
        special_mode <= '0';
        wait for 100 ns;

        report "========== FIN SIMULACION DISPLAY ==========";
        wait;
    end process;
end Behavioral;     
