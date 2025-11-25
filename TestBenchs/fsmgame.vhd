library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_game_fsm is
end tb_game_fsm;

architecture Behavioral of tb_game_fsm is

    -- Componente a probar
    component game_fsm
        Port (
            clk              : in  STD_LOGIC;
            reset            : in  STD_LOGIC;
            access_granted   : in  STD_LOGIC;
            btn_guess        : in  STD_LOGIC;
            user_guess       : in  STD_LOGIC_VECTOR(3 downto 0);
            target_number    : in  STD_LOGIC_VECTOR(3 downto 0);
            attempts_left    : in  integer range 0 to 5;
            msg_timer_done   : in  STD_LOGIC;
            lock_timer_done  : in  STD_LOGIC;
            generate_number  : out STD_LOGIC;
            decr_attempts    : out STD_LOGIC;
            reload_attempts  : out STD_LOGIC;
            start_msg_timer  : out STD_LOGIC;
            start_lock_timer : out STD_LOGIC;
            game_state_out   : out integer range 0 to 4;
            comparison_result: out integer range 0 to 2
        );
    end component;


    -- Señales internas
    signal clk            : STD_LOGIC := '0';
    signal reset          : STD_LOGIC := '0';
    signal access_granted : STD_LOGIC := '0';
    signal btn_guess      : STD_LOGIC := '0';
    signal user_guess     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal target_number  : STD_LOGIC_VECTOR(3 downto 0) := "0101"; -- el número correcto será 5
    signal attempts_left  : integer range 0 to 5 := 5;
    signal msg_timer_done : STD_LOGIC := '0';
    signal lock_timer_done: STD_LOGIC := '0';

    signal generate_number  : STD_LOGIC;
    signal decr_attempts    : STD_LOGIC;
    signal reload_attempts  : STD_LOGIC;
    signal start_msg_timer  : STD_LOGIC;
    signal start_lock_timer : STD_LOGIC;
    signal game_state_out   : integer range 0 to 4;
    signal comparison_result: integer range 0 to 2;

begin

    --------------------------------------------------------------------
    -- Generador de reloj
    --------------------------------------------------------------------
    clk <= not clk after 10 ns;

    --------------------------------------------------------------------
    -- Instancia del DUT
    --------------------------------------------------------------------
    dut: game_fsm
        port map (
            clk              => clk,
            reset            => reset,
            access_granted   => access_granted,
            btn_guess        => btn_guess,
            user_guess       => user_guess,
            target_number    => target_number,
            attempts_left    => attempts_left,
            msg_timer_done   => msg_timer_done,
            lock_timer_done  => lock_timer_done,
            generate_number  => generate_number,
            decr_attempts    => decr_attempts,
            reload_attempts  => reload_attempts,
            start_msg_timer  => start_msg_timer,
            start_lock_timer => start_lock_timer,
            game_state_out   => game_state_out,
            comparison_result=> comparison_result
        );

    --------------------------------------------------------------------
    -- Estímulos de simulación
    --------------------------------------------------------------------
    stim_proc : process
    begin
        report "===== INICIO SIMULACION game_fsm =====";

        -- Reset inicial
        reset <= '1';
        wait for 40 ns;
        reset <= '0';

        -- Usuario obtiene acceso
        access_granted <= '1';
        wait for 20 ns;
        access_granted <= '0';

        -- Ahora está en PLAYING

        -- Intento fallido (bajo)
        user_guess <= "0011";  -- 3 < 5
        attempts_left <= 5;
        btn_guess <= '1';
        wait for 20 ns;
        btn_guess <= '0';
        wait for 40 ns;

        -- Intento fallido (alto)
        user_guess <= "1000"; -- 8 > 5
        attempts_left <= 4;
        btn_guess <= '1';
        wait for 20 ns;
        btn_guess <= '0';
        wait for 40 ns;

        -- Último intento fallido para entrar en FAIL_MSG
        user_guess <= "0001";
        attempts_left <= 1;
        btn_guess <= '1';
        wait for 20 ns;
        btn_guess <= '0';
        wait for 40 ns;

        -- Mensaje finaliza
        msg_timer_done <= '1';
        wait for 20 ns;
        msg_timer_done <= '0';

        -- El sistema entra en estado BLOCKED
        wait for 50 ns;

        -- Bloqueo termina
        lock_timer_done <= '1';
        wait for 20 ns;
        lock_timer_done <= '0';

        -- Nuevo acceso
        access_granted <= '1';
        wait for 20 ns;
        access_granted <= '0';

        -- Acierto
        user_guess <= "0101"; -- correcto
        attempts_left <= 5;
        btn_guess <= '1';
        wait for 20 ns;
        btn_guess <= '0';

        -- Finaliza mensaje de victoria
        msg_timer_done <= '1';
        wait for 20 ns;
        msg_timer_done <= '0';

        report "===== FIN SIMULACION game_fsm =====";
        wait;
    end process;

end Behavioral;

