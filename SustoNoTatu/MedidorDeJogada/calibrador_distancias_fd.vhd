-- Calibrador + registradores

library IEEE;
use IEEE.std_logic_1164.all;

entity calibrador_distancias_fd is
    port (
        clock                : in  std_logic;
        reset                : in  std_logic;
        calibrando0          : in  std_logic;
        calibrando1          : in  std_logic;
        calibrando2          : in  std_logic;
        echo1                : in  std_logic;
        echo2                : in  std_logic;
        registra0            : in  std_logic;
        registra1            : in  std_logic;
        registra2            : in  std_logic;   
        reset_calibrador     : in  std_logic;         
        -- Sinais de saída
        trigger1             : out std_logic;
        trigger2             : out std_logic;
        fim0                 : out std_logic;
        fim1                 : out std_logic;
        fim2                 : out std_logic;
        medida_calibrada_0_D : out std_logic_vector(11 downto 0);
        medida_calibrada_0_E : out std_logic_vector(11 downto 0);
        medida_calibrada_1_D : out std_logic_vector(11 downto 0);
        medida_calibrada_1_E : out std_logic_vector(11 downto 0);
        medida_calibrada_2_D : out std_logic_vector(11 downto 0);
        medida_calibrada_2_E : out std_logic_vector(11 downto 0)
    );
end entity;

architecture rtl of calibrador_distancias_fd is

    component calibrador is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            calibrar  : in  std_logic;
            echo1     : in  std_logic;
            echo2     : in  std_logic;
            trigger1  : out std_logic;
            trigger2  : out std_logic;
            medida1   : out std_logic_vector(11 downto 0);
            medida2   : out std_logic_vector(11 downto 0);
            pronto    : out std_logic;
            db_estado_hcsr04_1        : out std_logic_vector(3 downto 0);
            db_estado_hcsr04_2        : out std_logic_vector(3 downto 0);
            db_pronto_estado_hcsr04_1 : out std_logic;
            db_pronto_estado_hcsr04_2 : out std_logic;
            db_medida1                : out std_logic_vector(11 downto 0);
            db_medida2                : out std_logic_vector(11 downto 0);
            db_estado                 : out std_logic_vector(3 downto 0); -- estado da UC
            db_timeout_1              : out std_logic;
            db_timeout_2              : out std_logic
        );
    end component;

    component registrador_n is
        generic (
           constant N: integer := 8 
        );
        port (
           clock  : in  std_logic;
           clear  : in  std_logic;
           enable : in  std_logic;
           D      : in  std_logic_vector (N-1 downto 0);
           Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;

    signal s_medida1, s_medida2: std_logic_vector(11 downto 0);
    signal s_reset_calibrador, s_pronto, s_calibrador: std_logic;

begin
    s_reset_calibrador <= reset or reset_calibrador;
    s_calibrar <= calibrando0 or calibrando1 or calibrando2;

    CALIBRADOR_MEDIDAS: calibrador
        port map (
            clock                     => clock,
            reset                     => s_reset_calibrador, 
            calibrar                  => s_calibrar,
            echo1                     => echo1,
            echo2                     => echo2,
            trigger1                  => trigger1,
            trigger2                  => trigger2,
            medida1                   => s_medida1,
            medida2                   => s_medida2,
            pronto                    => s_pronto,
            db_estado_hcsr04_1        => open,
            db_estado_hcsr04_2        => open,
            db_pronto_estado_hcsr04_1 => open,
            db_pronto_estado_hcsr04_2 => open,
            db_medida1                => open,
            db_medida2                => open,
            db_estado                 => open,
            db_timeout_1              => open,
            db_timeout_2              => open
        );

    REG_0D: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra0,
            D      => s_medida1,
            Q      => medida_calibrada_0_D
        );

    REG_0E: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra0,
            D      => s_medida2,
            Q      => medida_calibrada_0_E
        );

    REG_1D: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra1,
            D      => s_medida1,
            Q      => medida_calibrada_1_D
        );

    REG_1E: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra1,
            D      => s_medida2,
            Q      => medida_calibrada_1_E
        );

    REG_2D: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra2,
            D      => s_medida1,
            Q      => medida_calibrada_2_D
        );

    REG_2E: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra2,
            D      => s_medida2,
            Q      => medida_calibrada_2_E
        );

    fim0 <= calibrar0 and s_pronto;
    fim1 <= calibrar1 and s_pronto;
    fim2 <= calibrar1 and s_pronto;

end architecture rtl;
