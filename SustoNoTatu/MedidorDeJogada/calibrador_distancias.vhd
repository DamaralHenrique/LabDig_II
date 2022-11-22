library ieee;
use ieee.std_logic_1164.all;

entity calibrador_distancias is
    port (
        clock                : in  std_logic;
        reset                : in  std_logic;
        calibrar             : in  std_logic;
        echo1                : in  std_logic;
        echo2                : in  std_logic;
        trigger1             : out std_logic;
        trigger2             : out std_logic;
        medida_calibrada_0_D : out std_logic_vector(11 downto 0);
        medida_calibrada_0_E : out std_logic_vector(11 downto 0);
        medida_calibrada_1_D : out std_logic_vector(11 downto 0);
        medida_calibrada_1_E : out std_logic_vector(11 downto 0);
        medida_calibrada_2_D : out std_logic_vector(11 downto 0);
        medida_calibrada_2_E : out std_logic_vector(11 downto 0);
        fim_calibracao       : out std_logic;
        db_estado            : out std_logic_vector(3 downto 0) 
    );
end entity calibrador_distancias;

architecture arch of calibrador_distancias is
    component calibrador_distancias_uc is 
        port ( 
            clock                : in  std_logic;
            reset                : in  std_logic;
            calibrar             : in  std_logic;
            fim0                 : in  std_logic;
            fim1                 : in  std_logic;
            fim2                 : in  std_logic;
            calibrar0            : out std_logic;
            calibrar1            : out std_logic;
            calibrar2            : out std_logic;
            registra0            : out std_logic;
            registra1            : out std_logic;
            registra2            : out std_logic;
            reset_calibrador     : out std_logic;
            fim_calibracao       : out std_logic;
            db_estado            : out std_logic_vector(3 downto 0) 
        );
    end component;

    component calibrador_distancias_fd is
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
    end component;

    signal s_fim0, s_fim1, s_fim2: std_logic;
    signal s_calibrar0, s_calibrar1, s_calibrar2: std_logic;
    signal s_registra0, s_registra1, s_registra2: std_logic;
    signal s_reset_calibrador: std_logic;

begin
    UC: calibrador_distancias_uc 
        port map ( 
            clock            => clock,
            reset            => reset,
            calibrar         => calibrar,
            fim0             => s_fim0,
            fim1             => s_fim1,
            fim2             => s_fim2,
            calibrar0        => s_calibrar0,
            calibrar1        => s_calibrar1,
            calibrar2        => s_calibrar2,
            registra0        => s_registra0,
            registra1        => s_registra1,
            registra2        => s_registra2,
            reset_calibrador => s_reset_calibrador,
            fim_calibracao   => fim_calibracao,
            db_estado        => db_estado
        );

    FD: calibrador_distancias_fd
        port map ( 
            clock                => clock,
            reset                => reset,
            calibrando0          => s_calibrar0,
            calibrando1          => s_calibrar1,
            calibrando2          => s_calibrar2,
            echo1                => echo1,
            echo2                => echo2,
            registra0            => s_registra0,
            registra1            => s_registra1,
            registra2            => s_registra2, 
            reset_calibrador     => s_reset_calibrador,        
            -- Sinais de saída
            trigger1             => trigger1,
            trigger2             => trigger2,
            fim0                 => s_fim0,
            fim1                 => s_fim1,
            fim2                 => s_fim2,
            medida_calibrada_0_D => medida_calibrada_0_D,
            medida_calibrada_0_E => medida_calibrada_0_E,
            medida_calibrada_1_D => medida_calibrada_1_D,
            medida_calibrada_1_E => medida_calibrada_1_E,
            medida_calibrada_2_D => medida_calibrada_2_D,
            medida_calibrada_2_E => medida_calibrada_2_E
        );
  
end architecture arch;
