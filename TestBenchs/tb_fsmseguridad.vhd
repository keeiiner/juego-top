library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_security_fsm is
end tb_security_fsm;

architecture Behavioral of tb_security_fsm is

    component security_fsm is
        Port (
            clk           : in  STD_LOGIC;
            reset         : in  STD_LOGIC;
            btn_config    : in  STD_LOGIC;
            btn_confirm   : in  STD_LOGIC;
            key_input     : in  STD_LOGIC_VECTOR(3 downto 0);
            stored_key    : in  STD_LOGIC_VECTOR(3 downto 0);
            attempts_left : in  integer range 0 to 3;
            lock_time_up  : in  STD_LOGIC;
            config_mode   : out STD_LOGIC;
            store_key     : out STD_LOGIC;
            decr_attempts : out STD_LOGIC;
            reload_attempts: out STD_LOGIC;
            start_lock    : out STD_LOGIC;
            access_granted: out STD_LOGIC;
            current_state_out : out integer range 0 to 3
        );
    end component;

    -- Señales del TB
    signal clk            : STD_LOGIC := '0';
    signal reset          : STD_LOGIC := '0';
    signal btn_config     : STD_LOGIC := '0';
    signal btn_confirm    : STD_LOGIC := '0';
    signal key_input      : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal stored_key     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal attempts_left  : integer range 0 to 3 := 3;
    signal lock_time_up   : STD_LOGIC := '0';

    signal config_mode    : STD_LOGIC;
    signal store_key      : STD_LOGIC;
    signal decr_attempts  : STD_LOGIC;
    signal reload_attempts: STD_LOGIC;
    signal start_lock     : STD_LOGIC;
    signal access_granted : STD_LOGIC;
    signal current_state_out : integer range 0 to 3;

begin

    -- Instancia del módulo
    uut: security_fsm
        port map(
            clk           => clk,
            reset         => reset,
            btn_config    => btn_config,
            btn_confirm   => btn_confirm,
            key_input     => key_input,
            stored_key    => stored_key,
            attempts_left => attempts_left,
            lock_time_up  => lock_time_up,
            config_mode   => config_mode,
            store_key     => store_key,
            decr_attempts => decr_attempts,
            reload_attempts => reload_attempts,
            start_lock    => start_lock,
            access_granted => access_granted,
            current_state_out => current_state_out
        );

    -- Reloj
    clk <= not clk after 5 ns;

    stimulus: process
    begin
        report "========== INICIO SIMULACION FSM ==========";

        -- RESET
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        ----------------------------------------------------------
        -- ENTRAR A CONFIG Y GUARDAR CLAVE
        ----------------------------------------------------------
        btn_config <= '1'; wait for 10 ns; btn_config <= '0';
        wait for 50 ns;

        key_input <= "1010";  -- clave nueva
        btn_confirm <= '1'; wait for 10 ns; btn_confirm <= '0';
        wait for 50 ns;

        stored_key <= "1010"; -- simular que ya se guardó

        ----------------------------------------------------------
        -- VERIFICAR CON CLAVE CORRECTA (ACCESO OK)
        ----------------------------------------------------------
        key_input <= "1010";
        btn_confirm <= '1'; wait for 10 ns; btn_confirm <= '0';
        wait for 60 ns;

        ----------------------------------------------------------
        -- VERIFICAR CON CLAVES INCORRECTAS
        ----------------------------------------------------------
        key_input <= "0001";
        attempts_left <= 3;
        btn_confirm <= '1'; wait for 10 ns; btn_confirm <= '0';
        wait for 40 ns;

        attempts_left <= 2;
        btn_confirm <= '1'; wait for 10 ns; btn_confirm <= '0';
        wait for 40 ns;

        -- ÚLTIMO INTENTO → BLOQUEO
        attempts_left <= 1;
        key_input <= "1111";
        btn_confirm <= '1'; wait for 10 ns; btn_confirm <= '0';
        wait for 40 ns;

        -- Activar salida del timer → desbloquear
        lock_time_up <= '1'; wait for 10 ns; lock_time_up <= '0';
        wait for 60 ns;

        report "========== FIN SIMULACION FSM ==========";
        wait;
    end process;

end Behavioral;
