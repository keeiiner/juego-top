library IEEE;                                 -- librería lógica
use IEEE.STD_LOGIC_1164.ALL;                  -- tipos estándar
use IEEE.NUMERIC_STD.ALL;                     -- aritmética entero

entity game_fsm is
    Port (
        clk              : in  STD_LOGIC;     -- reloj entrada
        reset            : in  STD_LOGIC;     -- reset global
        access_granted   : in  STD_LOGIC;     -- acceso ok
        btn_guess        : in  STD_LOGIC;     -- botón jugar
        user_guess       : in  STD_LOGIC_VECTOR(3 downto 0); -- intento usuario
        target_number    : in  STD_LOGIC_VECTOR(3 downto 0); -- número meta
        attempts_left    : in  integer range 0 to 5;          -- intentos resto
        msg_timer_done   : in  STD_LOGIC;     -- fin mensaje
        lock_timer_done  : in  STD_LOGIC;     -- fin bloqueo
        generate_number  : out STD_LOGIC;     -- generar número
        decr_attempts    : out STD_LOGIC;     -- restar intento
        reload_attempts  : out STD_LOGIC;     -- recargar intentos
        start_msg_timer  : out STD_LOGIC;     -- iniciar mensaje
        start_lock_timer : out STD_LOGIC;     -- iniciar bloqueo
        game_state_out   : out integer range 0 to 4; -- estado juego
        comparison_result: out integer range 0 to 2   -- resultado comp
    );
end game_fsm;

architecture Behavioral of game_fsm is
    type state_type is (IDLE, PLAYING, WIN, FAIL_MSG, BLOCKED); -- estados juego
    signal current_state, next_state : state_type := IDLE;       -- estado actual
    
    signal comparison_reg : integer range 0 to 2 := 0;           -- comp registro
    
    signal btn_guess_prev  : STD_LOGIC := '0';    -- previo botón
    signal btn_guess_pulse : STD_LOGIC := '0';    -- pulso botón
    signal access_prev     : STD_LOGIC := '0';    -- previo acceso
    signal access_pulse    : STD_LOGIC := '0';    -- pulso acceso
    
begin
    
    process(clk, reset)                           -- flancos botones
    begin
        if reset = '1' then
            btn_guess_prev  <= '0';               -- limpiar previo
            btn_guess_pulse <= '0';               -- limpiar pulso
            access_prev     <= '0';               -- limpiar previo
            access_pulse    <= '0';               -- limpiar pulso
        elsif rising_edge(clk) then
            btn_guess_prev  <= btn_guess;         -- guardar previo
            btn_guess_pulse <= btn_guess and not btn_guess_prev;  -- pulso
            access_prev     <= access_granted;    -- guardar previo
            access_pulse    <= access_granted and not access_prev;-- pulso
        end if;
    end process;
    
    process(clk, reset)                           -- transición estados
    begin
        if reset = '1' then
            current_state <= IDLE;                -- volver inicio
        elsif rising_edge(clk) then
            current_state <= next_state;          -- actualizar estado
        end if;
    end process;
    
    process(clk, reset)                           -- registrar comparación
        variable guess_int, target_int : integer; -- enteros calc
    begin
        if reset = '1' then
            comparison_reg <= 0;                  -- limpiar comp
            
        elsif rising_edge(clk) then
            guess_int  := to_integer(unsigned(user_guess));   -- convertir
            target_int := to_integer(unsigned(target_number));-- convertir
            
            if current_state = PLAYING and btn_guess_pulse = '1' then
                if guess_int = target_int then
                    comparison_reg <= 2;          -- igual
                elsif guess_int < target_int then
                    comparison_reg <= 0;          -- bajo
                else
                    comparison_reg <= 1;          -- alto
                end if;
            elsif current_state = IDLE then
                comparison_reg <= 0;              -- limpiar
            end if;
        end if;
    end process;
    
    process(current_state, access_pulse, btn_guess_pulse, user_guess, 
            target_number, attempts_left, msg_timer_done, lock_timer_done)
        variable guess_int, target_int : integer; -- enteros cálculo
    begin
        next_state <= current_state;              -- estado default
        generate_number  <= '0';                  -- desactivar
        decr_attempts    <= '0';                  -- desactivar
        reload_attempts  <= '0';                  -- desactivar
        start_msg_timer  <= '0';                  -- desactivar
        start_lock_timer <= '0';                  -- desactivar
        game_state_out <= 0;                      -- salida default
        
        guess_int  := to_integer(unsigned(user_guess));   -- convertir
        target_int := to_integer(unsigned(target_number));-- convertir
        
        case current_state is
            when IDLE =>
                game_state_out <= 0;              -- estado idle
                if access_pulse = '1' then
                    generate_number <= '1';       -- generar num
                    reload_attempts <= '1';       -- recargar
                    next_state <= PLAYING;        -- pasar jugar
                end if;
            
            when PLAYING =>
                game_state_out <= 1;              -- estado jugar
                if btn_guess_pulse = '1' then
                    if guess_int = target_int then
                        start_msg_timer <= '1';   -- iniciar msg
                        next_state <= WIN;        -- estado win
                    else
                        decr_attempts <= '1';     -- restar uno
                        if attempts_left = 1 then
                            start_msg_timer <= '1'; -- iniciar msg
                            next_state <= FAIL_MSG;-- estado fallar
                        end if;
                    end if;
                end if;
            
            when WIN =>
                game_state_out <= 2;              -- estado win
                if msg_timer_done = '1' then
                    next_state <= IDLE;           -- volver inicio
                end if;
            
            when FAIL_MSG =>
                game_state_out <= 3;              -- estado fallo
                if msg_timer_done = '1' then
                    start_lock_timer <= '1';      -- iniciar bloqueo
                    next_state <= BLOCKED;        -- estado bloqueado
                end if;
            
            when BLOCKED =>
                game_state_out <= 4;              -- bloqueado
                if lock_timer_done = '1' then
                    next_state <= IDLE;           -- volver inicio
                end if;
            
            when others =>
                next_state <= IDLE;               -- default
        end case;
    end process;
    
    comparison_result <= comparison_reg;          -- salida comp

end Behavioral;
