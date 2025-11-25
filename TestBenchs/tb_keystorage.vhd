library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_key_storage is
end tb_key_storage;

architecture Behavioral of tb_key_storage is

    -- Componente bajo prueba
    component key_storage
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            config_mode: in  STD_LOGIC;
            key_in     : in  STD_LOGIC_VECTOR(3 downto 0);
            store_key  : in  STD_LOGIC;
            stored_key : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Señales del TB
    signal clk         : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal config_mode : STD_LOGIC := '0';
    signal key_in      : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal store_key   : STD_LOGIC := '0';
    signal stored_key  : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Instancia del DUT
    uut: key_storage
        port map(
            clk        => clk,
            reset      => reset,
            config_mode=> config_mode,
            key_in     => key_in,
            store_key  => store_key,
            stored_key => stored_key
        );

    -- Reloj 10 ns
    clk <= not clk after 5 ns;

    -- Estímulos
    stim_proc: process
    begin
        report "========== INICIO SIMULACION KEY STORAGE ==========";

        -- RESET
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 1) Intentar guardar sin config_mode (NO debe guardarse)
        key_in <= "1010";
        store_key <= '1';
        wait for 10 ns;
        store_key <= '0';
        wait for 20 ns;

        -- 2) Activar modo configuración y guardar clave
        config_mode <= '1';
        key_in <= "1100";
        store_key <= '1';
        wait for 10 ns;
        store_key <= '0';
        wait for 20 ns;

        -- 3) Intentar sobrescribir sin config_mode (NO debe hacerlo)
        config_mode <= '0';
        key_in <= "0011";
        store_key <= '1';
        wait for 10 ns;
        store_key <= '0';
        wait for 20 ns;

        -- 4) Guardar nueva clave en modo configuración
        config_mode <= '1';
        key_in <= "0111";
        store_key <= '1';
        wait for 10 ns;
        store_key <= '0';
        wait for 20 ns;

        report "========== FIN SIMULACION KEY STORAGE ==========";
        wait;
    end process;

end Behavioral;
