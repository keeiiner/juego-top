library IEEE;  -- librerías base
use IEEE.STD_LOGIC_1164.ALL;  -- lógica estándar
use IEEE.NUMERIC_STD.ALL;  -- aritmética segura

library work;  -- librería local
use work.all;  -- importar todo

entity top_security_module is  -- módulo principal
    Port (
        clk   : in  STD_LOGIC;  -- reloj sistema
        reset : in  STD_LOGIC;  -- reset global
        btnc  : in  STD_LOGIC;  -- botón confirmar
        btnl  : in  STD_LOGIC;  -- botón configurar
        sw    : in  STD_LOGIC_VECTOR(15 downto 0); -- switches entrada
        
        seg   : out STD_LOGIC_VECTOR(6 downto 0); -- display segmentos
        an    : out STD_LOGIC_VECTOR(3 downto 0); -- ánodos display
        led   : out STD_LOGIC_VECTOR(15 downto 0); -- leds salida
        access_granted_out : out STD_LOGIC  -- acceso final
    );
end top_security_module;

architecture Behavioral of top_security_module is  -- arquitectura top
    
    -- ==================== COMPONENTES ====================

    component clock_divider is  -- divisor reloj
        Generic (DIVISOR : integer := 100_000_000); -- divisor valor
        Port (
            clk_in     : in  STD_LOGIC; -- reloj entrada
            reset      : in  STD_LOGIC; -- reset divisor
            enable_out : out STD_LOGIC  -- pulso salida
        );
    end component;
    
    component key_storage is  -- almacena clave
        Port (
            clk        : in  STD_LOGIC; -- reloj
            reset      : in  STD_LOGIC; -- reset módulo
            config_mode: in  STD_LOGIC; -- modo configuración
            key_in     : in  STD_LOGIC_VECTOR(3 downto 0); -- clave entrada
            store_key  : in  STD_LOGIC; -- guardar clave
            stored_key : out STD_LOGIC_VECTOR(3 downto 0) -- clave guardada
        );
    end component;
    
    component attempt_counter is  -- contador intentos
        Generic (MAX_ATTEMPTS : integer := 3); -- intentos máximos
        Port (
            clk           : in  STD_LOGIC; -- reloj
            reset         : in  STD_LOGIC; -- reset intentos
            decrement     : in  STD_LOGIC; -- decrementar intento
            reload        : in  STD_LOGIC; -- recargar intentos
            attempts_left : out integer range 0 to 3; -- intentos restantes
            attempts_zero : out STD_LOGIC -- sin intentos
        );
    end component;
    
    component lock_timer is  -- temporizador bloqueo
        Generic (LOCK_TIME : integer := 30); -- tiempo bloqueo
        Port (
            clk       : in  STD_LOGIC; -- reloj
            enable_1hz: in  STD_LOGIC; -- pulso 1Hz
            reset     : in  STD_LOGIC; -- reset timer
            start     : in  STD_LOGIC; -- iniciar conteo
            time_left : out integer range 0 to 30; -- tiempo restante
            time_up   : out STD_LOGIC -- tiempo terminado
        );
    end component;
    
    component security_fsm is  -- máquina estados
        Port (
            clk              : in  STD_LOGIC; -- reloj
            reset            : in  STD_LOGIC; -- reset FSM
            btn_config       : in  STD_LOGIC; -- botón config
            btn_confirm      : in  STD_LOGIC; -- botón confirmar
            key_input        : in  STD_LOGIC_VECTOR(3 downto 0); -- clave entrada
            stored_key       : in  STD_LOGIC_VECTOR(3 downto 0); -- clave guardada
            attempts_left    : in  integer range 0 to 3; -- intentos restantes
            lock_time_up     : in  STD_LOGIC; -- fin bloqueo
            config_mode      : out STD_LOGIC; -- modo config
            store_key        : out STD_LOGIC; -- guardar clave
            decr_attempts    : out STD_LOGIC; -- restar intento
            reload_attempts  : out STD_LOGIC; -- reiniciar intentos
            start_lock       : out STD_LOGIC; -- iniciar bloqueo
            access_granted   : out STD_LOGIC; -- acceso dado
            current_state_out: out integer range 0 to 3 -- estado actual
        );
    end component;
    
    component display_controller is  -- controla display
        Port (
            clk          : in  STD_LOGIC; -- reloj
            reset        : in  STD_LOGIC; -- reset
            digit0       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 0
            digit1       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 1
            digit2       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 2
            digit3       : in  STD_LOGIC_VECTOR(3 downto 0); -- dígito 3
            enable0      : in  STD_LOGIC; -- habilitar d0
            enable1      : in  STD_LOGIC; -- habilitar d1
            enable2      : in  STD_LOGIC; -- habilitar d2
            enable3      : in  STD_LOGIC; -- habilitar d3
            special_mode : in  STD_LOGIC; -- modo especial
            an           : out STD_LOGIC_VECTOR(3 downto 0); -- ánodos
            seg          : out STD_LOGIC_VECTOR(6 downto 0) -- segmentos
        );
    end component;
    
    -- ==================== SEÑALES INTERNAS ====================

    signal enable_1hz : STD_LOGIC; -- pulso 1Hz
    
    signal stored_key_sig  : STD_LOGIC_VECTOR(3 downto 0); -- clave guardada
    signal config_mode_sig : STD_LOGIC; -- modo config
    signal store_key_sig   : STD_LOGIC; -- guardar clave
    
    signal decr_attempts   : STD_LOGIC; -- restar intento
    signal reload_attempts : STD_LOGIC; -- reiniciar intentos
    signal attempts_left   : integer range 0 to 3; -- intentos left
    signal attempts_zero   : STD_LOGIC; -- sin intentos
    
    signal start_lock : STD_LOGIC; -- iniciar bloqueo
    signal time_left  : integer range 0 to 30; -- tiempo left
    signal time_up    : STD_LOGIC; -- tiempo acabado
    
    signal access_granted : STD_LOGIC; -- acceso interno
    signal current_state  : integer range 0 to 3; -- estado actual
    
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0); -- dígitos
    signal special_mode : STD_LOGIC; -- modo especial
    
begin
    
    -- ==================== INSTANCIAS ====================

    clk_div_inst: clock_divider  -- divisor instancia
        generic map (DIVISOR => 100_000_000) -- divisor valor
        port map (
            clk_in     => clk,  -- reloj
            reset      => reset, -- reset
            enable_out => enable_1hz -- pulso 1Hz
        );
    
    key_store_inst: key_storage  -- clave instancia
        port map (
            clk         => clk,  -- reloj
            reset       => reset, -- reset
            config_mode => config_mode_sig, -- modo config
            key_in      => sw(3 downto 0), -- clave input
            store_key   => store_key_sig, -- guardar clave
            stored_key  => stored_key_sig -- clave guardada
        );
    
    attempt_cnt_inst: attempt_counter -- intentos instancia
        generic map (MAX_ATTEMPTS => 3)
        port map (
            clk           => clk, -- reloj
            reset         => reset, -- reset
            decrement     => decr_attempts, -- restar
            reload        => reload_attempts, -- recargar
            attempts_left => attempts_left, -- intentos left
            attempts_zero => attempts_zero -- sin intentos
        );
    
    lock_timer_inst: lock_timer  -- bloqueo instancia
        generic map (LOCK_TIME => 30)
        port map (
            clk        => clk,
            enable_1hz => enable_1hz,
            reset      => reset,
            start      => start_lock,
            time_left  => time_left,
            time_up    => time_up
        );
    
    security_fsm_inst: security_fsm  -- FSM instancia
        port map (
            clk              => clk,
            reset            => reset,
            btn_config       => btnl,
            btn_confirm      => btnc,
            key_input        => sw(3 downto 0),
            stored_key       => stored_key_sig,
            attempts_left    => attempts_left,
            lock_time_up     => time_up,
            config_mode      => config_mode_sig,
            store_key        => store_key_sig,
            decr_attempts    => decr_attempts,
            reload_attempts  => reload_attempts,
            start_lock       => start_lock,
            access_granted   => access_granted,
            current_state_out=> current_state
        );
    
    display_ctrl_inst: display_controller  -- display instancia
        port map (
            clk          => clk,
            reset        => reset,
            digit0       => digit0,
            digit1       => digit1,
            digit2       => digit2,
            digit3       => digit3,
            enable0      => '1',
            enable1      => '1',
            enable2      => '1',
            enable3      => '1',
            special_mode => special_mode,
            an           => an,
            seg          => seg
        );
    
    -- ==================== VISUALIZACIÓN ====================

    process(current_state, time_left, attempts_left, access_granted)
    begin
        digit0 <= "1111"; -- apagado
        digit1 <= "1111"; -- apagado
        digit2 <= "1111"; -- apagado
        digit3 <= "1111"; -- apagado
        special_mode <= '0'; -- modo normal
        
        case current_state is
            when 0 =>  -- estado config
                special_mode <= '1'; -- modo especial
                digit3 <= "0110"; -- guion
                digit2 <= "0110"; -- guion
                digit1 <= "0110"; -- guion
                digit0 <= "0110"; -- guion
                
            when 1 =>  -- estado verificar
                special_mode <= '0';
                digit0 <= std_logic_vector(to_unsigned(attempts_left, 4)); -- intentos
                
            when 2 =>  -- estado bloqueo
                special_mode <= '0';
                digit3 <= std_logic_vector(to_unsigned(time_left / 10, 4)); -- decenas
                digit2 <= std_logic_vector(to_unsigned(time_left mod 10, 4)); -- unidades
                
            when 3 =>  -- acceso ok
                special_mode <= '0';
                digit1 <= "0000"; -- O
                digit0 <= "1101"; -- H
                
            when others =>
                special_mode <= '0'; -- normal
        end case;
    end process;
    
    -- ==================== LEDS ====================

    process(config_mode_sig, attempts_left, current_state, access_granted)
    begin
        led <= (others => '0'); -- apagar leds
        
        led(15) <= config_mode_sig; -- modo config
        
        for i in 0 to 2 loop -- mostrar intentos
            if i < attempts_left then
                led(12 + i) <= '1'; -- encender
            else
                led(12 + i) <= '0'; -- apagar
            end if;
        end loop;
        
        if current_state = 2 then
            led(1) <= '1'; -- bloqueo activo
        end if;
        
        led(0) <= access_granted; -- acceso ok
    end process;
    
    access_granted_out <= access_granted; -- salida acceso

end Behavioral;
