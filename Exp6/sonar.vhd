library ieee;
use ieee.std_logic_1164.all;

entity sonar is 
    port ( 
        clock        : in  std_logic;
        reset        : in  std_logic;
        ligar        : in  std_logic;
        echo         : in  std_logic;
        trigger      : out std_logic;
        pwm          : out std_logic;
        saida_serial : out std_logic;
        fim_posicao  : out std_logic;
        db_estado    : out std_logic_vector(6 downto 0)
    );
end sonar;

architecture fsm_arch of sonar is
    component sonar_uc is 
        port ( 
            clock            : in  std_logic;
            reset            : in  std_logic;
            tx_pronto        : in  std_logic;
            fim_conta_digito : in  std_logic;
            ligar            : in  std_logic;
            fim_espera_servo : in  std_logic;
            hcsr_pronto      : in  std_logic;
            fim_ang          : in  std_logic;
            partida      : out std_logic;
            conta_digito : out std_logic;
            reset_servo  : out std_logic;
            zera_ang     : out std_logic;
            medir        : out std_logic;
            fim_posicao  : out std_logic;
            conta_ang    : out std_logic;
            zera_digito  : out std_logic;
            db_estado    : out std_logic_vector(3 downto 0) 
        );
    end component sonar_uc;

    component sonar_fd is 
        port ( 
            clock        : in  std_logic;
            reset        : in  std_logic;
            partida      : in std_logic;
            conta_digito : in std_logic;
            reset_servo  : in std_logic;
            zera_ang     : in std_logic;
            medir        : in std_logic;
            fim_posicao  : in std_logic;
            conta_ang    : in std_logic;
            echo         : in std_logic;
            zera_digito  : in std_logic;
            tx_pronto        : out std_logic;
            fim_conta_digito : out std_logic;
            fim_espera_servo : out std_logic;
            hcsr_pronto      : out std_logic;
            fim_ang          : out std_logic;
            trigger          : out std_logic;
            saida_serial     : out std_logic;
            pwm              : out std_logic
        );
    end component sonar_fd;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_tx_pronto, s_fim_conta_digito, s_fim_espera_servo, s_hcsr_pronto, s_fim_ang: std_logic;
    signal s_partida, s_conta_digito, s_reset_servo, s_zera_ang, s_medir, s_fim_posicao: std_logic;
    signal s_conta_ang, s_zera_digito: std_logic;
    signal s_db_estado: std_logic_vector(3 downto 0);
begin
    UC: sonar_uc 
        port map ( 
            clock            => clock,
            reset            => reset,
            tx_pronto        => s_tx_pronto,
            fim_conta_digito => s_fim_conta_digito,
            ligar            => ligar,
            fim_espera_servo => s_fim_espera_servo,
            hcsr_pronto      => s_hcsr_pronto,
            fim_ang          => s_fim_ang,
            partida          => s_partida,
            conta_digito     => s_conta_digito,
            reset_servo      => s_reset_servo,
            zera_ang         => s_zera_ang,
            medir            => s_medir,
            fim_posicao      => s_fim_posicao,
            conta_ang        => s_conta_ang,
            zera_digito      => s_zera_digito,
            db_estado        => s_db_estado
        );

    FD: sonar_fd 
        port map ( 
            clock            => clock,
            reset            => reset,
            partida          => s_partida,
            conta_digito     => s_conta_digito,
            reset_servo      => s_reset_servo,
            zera_ang         => s_zera_ang,
            medir            => s_medir,
            fim_posicao      => s_fim_posicao,
            conta_ang        => s_conta_ang,
            echo             => echo,
            zera_digito      => s_zera_digito,
            tx_pronto        => s_tx_pronto,
            fim_conta_digito => s_fim_conta_digito,
            fim_espera_servo => s_fim_espera_servo,
            hcsr_pronto      => s_hcsr_pronto,
            fim_ang          => s_fim_ang,
            trigger          => trigger,
            saida_serial     => saida_serial,
            pwm              => pwm
        );

    STATE_HEX: hex7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );
    
end architecture fsm_arch;
