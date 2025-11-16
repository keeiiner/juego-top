library IEEE;                                        -- librería lógica
use IEEE.STD_LOGIC_1164.ALL;                         -- tipos estándar
use IEEE.NUMERIC_STD.ALL;                            -- aritmética entero

entity security_fsm is
    Port (
        clk           : in  STD_LOGIC;               -- reloj entrada
        reset         : in  STD_LOGIC;               -- reset global
        btn_config    : in  STD_LOGIC;               -- botón config
        btn_confirm   : in  STD_LOGIC;               -- botón confirmar
        key_input     : in  STD_LOGIC_VECTOR(3 downto 0);  -- clave ingreso
        stored_key    : in  STD_LOGIC_VECTOR(3 downto 0);  -- clave guardada
        attempts_left : in  integer range 0 to 3;    -- intentos quedan
        lock_time_up  : in  STD_LOGIC;               -- bloqueo finaliza
        config_mode   : out STD_LOGIC;               -- activar config
        store_key     : out STD_LOGIC;               -- guardar clave
        decr_attempts : out STD_LOGIC;               -- bajar intento
        reload_attempts: out STD_LOGIC;              -- recargar intentos
        start_lock    : out STD_LOGIC;               -- iniciar bloqueo
        access_granted: out STD_LOGIC;               -- acceso logrado
        current_state_out : out integer range 0 to 3 -- estado actual
    );
end security_fsm;

architecture Behavioral of security_fsm is
    type state_type is (CONFIG, VERIFY, BLOCKED, ACCESS_GRANTED_ST);  -- lista estados
    signal current_state, next_state : state_type := VERIFY;           -- estado actual

    signal btn_config_prev  : STD_LOGIC := '0';      -- config previo
    signal btn_confirm_prev : STD_LOGIC := '0';      -- confirm previo
    signal btn_config_pulse : STD_LOGIC := '0';      -- pulso config
    signal btn_confirm_pulse: STD_LOGIC := '0';      -- pulso confirm
    
begin
    
    --------------------------------------------------------------------
    -- Detección flancos botones
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then                          -- reset botones
            btn_config_prev <= '0';                  -- limpiar previo
            btn_confirm_prev <= '0';                 -- limpiar previo
            btn_config_pulse <= '0';                 -- limpiar pulso
            btn_confirm_pulse <= '0';                -- limpiar pulso
        elsif rising_edge(clk) then                  -- flanco reloj
            btn_config_prev <= btn_config;           -- actualizar previo
            btn_confirm_prev <= btn_confirm;         -- actualizar previo
            
            btn_config_pulse <= btn_config and not btn_config_prev;   -- flanco config
            btn_confirm_pulse <= btn_confirm and not btn_confirm_prev;-- flanco confirm
        end if;
    end process;
    
    --------------------------------------------------------------------
    -- Registro estado actual
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then                          -- reset estado
            current_state <= VERIFY;                 -- volver verificar
        elsif rising_edge(clk) then                  -- flanco reloj
            current_state <= next_state;             -- siguiente estado
        end if;
    end process;
    
    --------------------------------------------------------------------
    -- Lógica combinacional FSM
    --------------------------------------------------------------------
    process(current_state, btn_config_pulse, btn_confirm_pulse, 
            key_input, stored_key, attempts_left, lock_time_up)
    begin
        next_state <= current_state;                 -- estado por defecto
        config_mode <= '0';                          -- config apagado
        store_key <= '0';                            -- no guardar
        decr_attempts <= '0';                        -- no bajar
        reload_attempts <= '0';                      -- no recargar
        start_lock <= '0';                           -- no bloquear
        access_granted <= '0';                       -- acceso negado
        current_state_out <= 0;                      -- salida base
        
        case current_state is
            
            ----------------------------------------------------------------
            -- CONFIGURACIÓN
            ----------------------------------------------------------------
            when CONFIG =>
                config_mode <= '1';                  -- activar config
                current_state_out <= 0;              -- mostrar estado
                
                if btn_confirm_pulse = '1' then      -- confirmar clave
                    store_key <= '1';                -- guardar clave
                    reload_attempts <= '1';          -- recargar intentos
                    next_state <= VERIFY;            -- volver verificar
                end if;
            
            ----------------------------------------------------------------
            -- VERIFICACIÓN
            ----------------------------------------------------------------
            when VERIFY =>
                current_state_out <= 1;              -- mostrar verificar
                
                if btn_config_pulse = '1' then       -- entrar config
                    next_state <= CONFIG;            -- ir config
                    
                elsif btn_confirm_pulse = '1' then   -- verificar clave
                    if key_input = stored_key then   -- clave correcta
                        next_state <= ACCESS_GRANTED_ST; -- ir acceso
                        reload_attempts <= '1';      -- recargar intentos
                    else
                        decr_attempts <= '1';        -- intento fallido
                        if attempts_left = 1 then    -- último intento
                            next_state <= BLOCKED;   -- ir bloqueo
                            start_lock <= '1';       -- iniciar tiempo
                        end if;
                    end if;
                end if;
            
            ----------------------------------------------------------------
            -- BLOQUEADO
            ----------------------------------------------------------------
            when BLOCKED =>
                current_state_out <= 2;              -- mostrar bloqueo
                
                if lock_time_up = '1' then           -- tiempo acabado
                    reload_attempts <= '1';          -- recargar intentos
                    next_state <= VERIFY;            -- volver verificar
                end if;
            
            ----------------------------------------------------------------
            -- ACCESO CONCEDIDO
            ----------------------------------------------------------------
            when ACCESS_GRANTED_ST =>
                current_state_out <= 3;              -- mostrar acceso
                access_granted <= '1';               -- acceso activo
            
            ----------------------------------------------------------------
            -- DEFAULT
            ----------------------------------------------------------------
            when others =>
                next_state <= VERIFY;                -- fallback seguro
                current_state_out <= 0;              -- estado base
                
        end case;
    end process;

end Behavioral;
