library IEEE;                         -- librerías básicas
use IEEE.STD_LOGIC_1164.ALL;          -- lógica estándar
use IEEE.NUMERIC_STD.ALL;             -- aritmética unsigned

library work;                         -- librería work
use work.all;                         -- usar work

entity top_game_only is
    Port (
        clk   : in  STD_LOGIC;                       -- reloj 100MHz
        reset : in  STD_LOGIC;                       -- reset global
        btnc  : in  STD_LOGIC;                       -- botón intento
        btnr  : in  STD_LOGIC;                       -- botón reinicio
        sw    : in  STD_LOGIC_VECTOR(15 downto 0);   -- switches entrada
        seg   : out STD_LOGIC_VECTOR(6 downto 0);    -- display seg
        an    : out STD_LOGIC_VECTOR(3 downto 0);    -- ánodos display
        led   : out STD_LOGIC_VECTOR(15 downto 0)    -- leds salida
    );
end top_game_only;

architecture Behavioral of top_game_only is
    
    -- ==================== COMPONENTES ====================
    
    component clock_divider is
        Generic (DIVISOR : integer := 100_000_000);   -- divisor clk
        Port (
            clk_in     : in  STD_LOGIC;               -- clk entrada
            reset      : in  STD_LOGIC;               -- reset
            enable_out : out STD_LOGIC                -- pulso salida
        );
    end component;
    
component prng_4bit is
    Port (
        clk      : in  STD_LOGIC;                    -- clk
        reset    : in  STD_LOGIC;                    -- reset
        gen_new  : in  STD_LOGIC;                    -- generar nuevo
        random   : out STD_LOGIC_VECTOR(3 downto 0)  -- número aleatorio
    );
end component;
    
    component game_attempt_counter is
        Generic (MAX_ATTEMPTS : integer := 5);       -- intentos max
        Port (
            clk           : in  STD_LOGIC;           -- clk
            reset         : in  STD_LOGIC;           -- reset
            decrement     : in  STD_LOGIC;           -- restar intento
            reload        : in  STD_LOGIC;           -- recargar
            attempts_left : out integer range 0 to 5;-- intentos restantes
            attempts_zero : out STD_LOGIC            -- cero intentos
        );
    end component;
    
    component message_timer is
        Port (
            clk       : in  STD_LOGIC;               -- clk
            reset     : in  STD_LOGIC;               -- reset
            enable_1hz: in  STD_LOGIC;               -- pulso 1Hz
            start     : in  STD_LOGIC;               -- iniciar timer
            time_up   : out STD_LOGIC                -- tiempo terminado
        );
    end component;
    
    component lock_timer is
        Generic (LOCK_TIME : integer := 15);         -- tiempo bloqueo
        Port (
            clk       : in  STD_LOGIC;               -- clk
            reset     : in  STD_LOGIC;               -- reset
            enable_1hz: in  STD_LOGIC;               -- pulso 1Hz
            start     : in  STD_LOGIC;               -- iniciar bloqueo
            time_left : out integer range 0 to 15;   -- tiempo restante
            time_up   : out STD_LOGIC                -- bloqueo terminado
        );
    end component;
    
component game_fsm is
    Port (
        clk              : in  STD_LOGIC;            -- clk
        reset            : in  STD_LOGIC;            -- reset
        access_granted   : in  STD_LOGIC;            -- acceso dado
        btn_guess        : in  STD_LOGIC;            -- botón intento
        user_guess       : in  STD_LOGIC_VECTOR(3 downto 0); -- número usuario
        target_number    : in  STD_LOGIC_VECTOR(3 downto 0); -- número objetivo
        attempts_left    : in  integer range 0 to 5; -- intentos restantes
        msg_timer_done   : in  STD_LOGIC;            -- msg finalizado
        lock_timer_done  : in  STD_LOGIC;            -- bloqueo finalizado
        generate_number  : out STD_LOGIC;            -- generar número
        decr_attempts    : out STD_LOGIC;            -- restar intento
        reload_attempts  : out STD_LOGIC;            -- recargar intentos
        start_msg_timer  : out STD_LOGIC;            -- iniciar mensaje
        start_lock_timer : out STD_LOGIC;            -- iniciar bloqueo
        game_state_out   : out integer range 0 to 4; -- estado juego
        comparison_result: out integer range 0 to 2  -- comparación
    );
end component;
    
    component display_controller is
        Port (
            clk          : in  STD_LOGIC;            -- clk
            reset        : in  STD_LOGIC;            -- reset
            digit0       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 0
            digit1       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 1
            digit2       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 2
            digit3       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 3
            enable0      : in  STD_LOGIC;            -- habilitar 0
            enable1      : in  STD_LOGIC;            -- habilitar 1
            enable2      : in  STD_LOGIC;            -- habilitar 2
            enable3      : in  STD_LOGIC;            -- habilitar 3
            special_mode : in  STD_LOGIC;            -- modo especial
            an           : out STD_LOGIC_VECTOR(3 downto 0); -- ánodos
            seg          : out STD_LOGIC_VECTOR(6 downto 0)  -- segmentos
        );
    end component;
    
    -- ==================== SEÑALES ====================
    
    signal enable_1hz : STD_LOGIC;                    -- pulso 1Hz
    
    signal access_granted_sim : STD_LOGIC;            -- acceso simulado
    signal btnr_prev          : STD_LOGIC := '0';     -- btn previo
    signal btnr_pulse         : STD_LOGIC := '0';     -- pulso btn
    
    signal target_number   : STD_LOGIC_VECTOR(3 downto 0); -- objetivo
    signal generate_number : STD_LOGIC;                    -- generar
    
    signal decr_attempts    : STD_LOGIC;              -- restar intento
    signal reload_attempts  : STD_LOGIC;              -- recargar
    signal attempts_left    : integer range 0 to 5;   -- intentos
    
    signal start_msg_timer  : STD_LOGIC;              -- iniciar msg
    signal msg_timer_done   : STD_LOGIC;              -- msg listo
    signal start_lock_timer : STD_LOGIC;              -- iniciar lock
    signal lock_time_left   : integer range 0 to 15;  -- tiempo lock
    signal lock_time_up     : STD_LOGIC;              -- lock finalizado
    
    signal game_state       : integer range 0 to 4;   -- estado
    signal comparison_result: integer range 0 to 2;   -- comparación
    
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0); -- dígitos
    signal special_mode : STD_LOGIC;                 -- modo especial
    
begin
    
    -- ==================== SIMULACIÓN DE ACCESO ====================
    
    process(clk, reset)                                -- proceso acceso
    begin
        if reset = '1' then                            -- reset total
            btnr_prev  <= '0';
            btnr_pulse <= '0';
            access_granted_sim <= '0';
        elsif rising_edge(clk) then                    -- flanco clk
            btnr_prev  <= btnr;                       -- guardar previo
            btnr_pulse <= btnr and not btnr_prev;     -- detectar pulso
            
            if btnr_pulse = '1' then                  -- si pulsa
                access_granted_sim <= '1';            -- activar acceso
            elsif game_state = 0 then                 -- si idle
                access_granted_sim <= '0';            -- desactivar
            end if;
        end if;
    end process;
    
    -- ==================== INSTANCIACIONES ====================
    
    clk_div: clock_divider                            -- divisor clk
        generic map (DIVISOR => 100_000_000)
        port map (
            clk_in     => clk,
            reset      => reset,
            enable_out => enable_1hz
        );
    
prng: prng_4bit                                       -- generador num
    port map (
        clk      => clk,
        reset    => reset,
        gen_new  => generate_number,
        random   => target_number
    );
    
attempt_cnt: game_attempt_counter                     -- contador
    generic map (MAX_ATTEMPTS => 5)
    port map (
        clk           => clk,
        reset         => reset,
        decrement     => decr_attempts,
        reload        => reload_attempts,
        attempts_left => attempts_left,
        attempts_zero => open
    );
    
msg_timer: message_timer                              -- timer msg
    port map (
        clk        => clk,
        reset      => reset,
        enable_1hz => enable_1hz,
        start      => start_msg_timer,
        time_up    => msg_timer_done
    );
    
game_lock_timer: lock_timer                          -- timer bloqueo
    generic map (LOCK_TIME => 15)
    port map (
        clk        => clk,
        reset      => reset,
        enable_1hz => enable_1hz,
        start      => start_lock_timer,
        time_left  => lock_time_left,
        time_up    => lock_time_up
    );
    
game_control: game_fsm                               -- FSM juego
    port map (
        clk              => clk,
        reset            => reset,
        access_granted   => access_granted_sim,
        btn_guess        => btnc,
        user_guess       => sw(3 downto 0),
        target_number    => target_number,
        attempts_left    => attempts_left,
        msg_timer_done   => msg_timer_done,
        lock_timer_done  => lock_time_up,
        generate_number  => generate_number,
        decr_attempts    => decr_attempts,
        reload_attempts  => reload_attempts,
        start_msg_timer  => start_msg_timer,
        start_lock_timer => start_lock_timer,
        game_state_out   => game_state,
        comparison_result=> comparison_result
    );
    
display_ctrl: display_controller                      -- display ctrl
    port map (
        clk     => clk,
        reset   => reset,
        digit0  => digit0,
        digit1  => digit1,
        digit2  => digit2,
        digit3  => digit3,
        enable0 => '1',
        special_mode => special_mode,
        enable1 => '1',
        enable2 => '1',
        enable3 => '1',
        an      => an,
        seg     => seg
    );
    
process(game_state, comparison_result, lock_time_left) -- display logica
begin
    digit0 <= "1111";                     -- apagar
    digit1 <= "1111";                     -- apagar
    digit2 <= "1111";                     -- apagar
    digit3 <= "1111";                     -- apagar
    special_mode <= '0';                  -- modo normal
    
    case game_state is                    -- estados juego
        
        when 0 =>                         -- idle
            special_mode <= '1';          -- modo especial
            digit3 <= "0110";             -- guion
            digit2 <= "0110";             -- guion
            digit1 <= "0110";             -- guion
            digit0 <= "0110";             -- guion
        
        when 1 =>                         -- jugando
            special_mode <= '0';          -- modo normal
            case comparison_result is
                when 0 =>
                    digit3 <= "0101";     -- S
                    digit2 <= "0001";     -- U
                    digit1 <= "1011";     -- b
                    digit0 <= "1110";     -- E
                when 1 =>
                    digit3 <= "1011";     -- b
                    digit2 <= "1010";     -- A
                    digit1 <= "0001";     -- J
                    digit0 <= "1010";     -- A
                when 2 =>
                    digit1 <= "0000";     -- O
                    digit0 <= "1101";     -- H
                when others =>
                    digit3 <= "0110";     -- -
                    digit2 <= "0110";     -- -
                    digit1 <= "0110";     -- -
                    digit0 <= "0110";     -- -
            end case;
        
        when 2 =>                         -- ganar
            special_mode <= '0';
            digit1 <= "0000";             -- O
            digit0 <= "1101";             -- H
        
        when 3 =>                         -- fail
            special_mode <= '1';
            digit3 <= "0111";             -- F
            digit2 <= "1010";             -- A
            digit1 <= "0001";             -- I
            digit0 <= "1100";             -- L
        
        when 4 =>                         -- bloqueo
            special_mode <= '0';
            digit3 <= std_logic_vector(to_unsigned(lock_time_left / 10, 4)); -- decena
            digit2 <= std_logic_vector(to_unsigned(lock_time_left mod 10, 4)); -- unidad
        
        when others =>
            special_mode <= '0';
    end case;
end process;
    
process(attempts_left, game_state)        -- leds intentos
begin
    led <= (others => '0');               -- apagar leds
    
    for i in 0 to 4 loop                  -- marcar intentos
        if i < attempts_left then
            led(15 - i) <= '1';
        end if;
    end loop;
    
    if game_state = 4 then                -- bloqueo led
        led(0) <= '1';
    end if;
end process;

end Behavioral;
