library IEEE;                          
use IEEE.STD_LOGIC_1164.ALL;           
use IEEE.NUMERIC_STD.ALL;              

library work;                          -- librería local
use work.all;                          -- usar módulos

--------------------------------------------------------------------
-- Módulo: top_complete_system 
-- Descripción: Sistema completo que integra:
--   - top_security_module (Módulo 1)
--   - top_game_only (Módulo 2)
-- Multiplexación automática según access_granted
--------------------------------------------------------------------
entity top_complete_system is
    Port (
        clk   : in  STD_LOGIC;                -- reloj entrada
        reset : in  STD_LOGIC;                -- reset global
        btnc  : in  STD_LOGIC;                -- botón común
        btnl  : in  STD_LOGIC;                -- botón configuración
        sw    : in  STD_LOGIC_VECTOR(15 downto 0); -- switches usuario
        seg   : out STD_LOGIC_VECTOR(6 downto 0);  -- display segmentos
        an    : out STD_LOGIC_VECTOR(3 downto 0);  -- ánodos display
        led   : out STD_LOGIC_VECTOR(15 downto 0)  -- leds salida
    );
end top_complete_system;

architecture Behavioral of top_complete_system is
    
    -- ==================== COMPONENTES (TOPS) ====================
    
    component top_security_module is
        Port (
            clk                : in  STD_LOGIC;                  -- reloj seguridad
            reset              : in  STD_LOGIC;                  -- reset seguridad
            btnc               : in  STD_LOGIC;                  -- botón confirmar
            btnl               : in  STD_LOGIC;                  -- botón lock
            sw                 : in  STD_LOGIC_VECTOR(15 downto 0); -- switches clave
            seg                : out STD_LOGIC_VECTOR(6 downto 0);  -- display seg
            an                 : out STD_LOGIC_VECTOR(3 downto 0);  -- anodos seg
            led                : out STD_LOGIC_VECTOR(15 downto 0); -- leds seg
            access_granted_out : out STD_LOGIC                    -- acceso permitido
        );
    end component;
    
    component top_game_only is
        Port (
            clk   : in  STD_LOGIC;                    -- reloj juego
            reset : in  STD_LOGIC;                    -- reset juego
            btnc  : in  STD_LOGIC;                    -- botón juego
            btnr  : in  STD_LOGIC;                    -- reinicio juego
            sw    : in  STD_LOGIC_VECTOR(15 downto 0); -- switches juego
            seg   : out STD_LOGIC_VECTOR(6 downto 0);  -- display juego
            an    : out STD_LOGIC_VECTOR(3 downto 0);  -- anodos juego
            led   : out STD_LOGIC_VECTOR(15 downto 0)  -- leds juego
        );
    end component;
    
    -- ==================== SEÑALES INTERNAS ====================
    
    -- Salidas del módulo de seguridad
    signal sec_seg : STD_LOGIC_VECTOR(6 downto 0);      -- seg seguridad
    signal sec_an  : STD_LOGIC_VECTOR(3 downto 0);      -- an seguridad
    signal sec_led : STD_LOGIC_VECTOR(15 downto 0);     -- leds seguridad
    
    -- Salidas del módulo de juego
    signal game_seg : STD_LOGIC_VECTOR(6 downto 0);     -- seg juego
    signal game_an  : STD_LOGIC_VECTOR(3 downto 0);     -- an juego
    signal game_led : STD_LOGIC_VECTOR(15 downto 0);    -- leds juego
    
    -- Señal de control
    signal access_granted : STD_LOGIC := '0';           -- permiso juego
    
begin
    
    -- ==================== INSTANCIAS DE TOPS ====================
    
    -- Módulo 1: Seguridad y Autenticación
    security_top: top_security_module
        port map (
            clk                => clk,                 -- map reloj
            reset              => reset,               -- map reset
            btnc               => btnc,                -- map botón
            btnl               => btnl,                -- map lock
            sw                 => sw,                  -- map switches
            seg                => sec_seg,             -- salida display
            an                 => sec_an,              -- salida anodos
            led                => sec_led,             -- salida leds
            access_granted_out => access_granted       -- salida acceso
        );
    
    -- Módulo 2: Juego "Adivina el Número"
    game_top: top_game_only
        port map (
            clk   => clk,              -- reloj juego
            reset => reset,            -- reset juego
            btnc  => btnc,             -- botón juego
            btnr  => access_granted,   -- reinicio acceso
            sw    => sw,               -- switches juego
            seg   => game_seg,         -- display juego
            an    => game_an,          -- anodos juego
            led   => game_led          -- leds juego
        );
    
    -- ==================== MULTIPLEXACIÓN DE SALIDAS ====================
    -- Cuando access_granted='0': Mostrar seguridad
    -- Cuando access_granted='1': Mostrar juego
    
    process(access_granted, sec_seg, sec_an, sec_led, game_seg, game_an, game_led)
    begin
        if access_granted = '0' then
            -- mostrar seguridad
            seg <= sec_seg;           -- seg seguridad
            an  <= sec_an;            -- an seguridad
            led <= sec_led;           -- leds seguridad
        else
            -- mostrar juego
            seg <= game_seg;          -- seg juego
            an  <= game_an;           -- an juego
            led <= game_led;          -- leds juego
        end if;
    end process;

end Behavioral;
