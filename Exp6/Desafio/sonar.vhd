library ieee;
use ieee.std_logic_1164.all;

entity sonar is 
    port ( 
        clock        : in  std_logic;
        reset        : in  std_logic;
        ligar        : in  std_logic;
        echo         : in  std_logic;
		  entrada_serial : in std_logic;
        trigger      : out std_logic;
        pwm          : out std_logic;
        saida_serial : out std_logic;
        fim_posicao  : out std_logic;
        db_estado    : out std_logic_vector(6 downto 0);
		  db_modo      : out std_logic;
		  db_dado_1  : out std_logic_vector(6 downto 0);
		  db_dado_2  : out std_logic_vector(6 downto 0);
		  db_ativo_p : out std_logic;
		  db_ativo_r : out std_logic;
		  db_estado_rx : out std_logic_vector(6 downto 0)
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
				ativo_p : in  std_logic;
				ativo_r : in  std_logic;
            partida      : out std_logic;
            conta_digito : out std_logic;
            reset_servo  : out std_logic;
            conta_servo  : out std_logic;
            zera_ang     : out std_logic;
            medir        : out std_logic;
            fim_posicao  : out std_logic;
            conta_ang    : out std_logic;
            zera_digito  : out std_logic;
				modo         : out std_logic;
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
				  conta_servo  : in std_logic;
				  zera_ang     : in std_logic;
				  medir        : in std_logic;
				  fim_posicao  : in std_logic;
				  conta_ang    : in std_logic;
				  echo         : in std_logic;
				  zera_digito  : in std_logic;
				  entrada_serial: in std_logic;
				  tx_pronto        : out std_logic;
				  fim_conta_digito : out std_logic;
				  fim_espera_servo : out std_logic;
				  hcsr_pronto      : out std_logic;
				  trigger          : out std_logic;
				  saida_serial     : out std_logic;
				  pwm              : out std_logic;
				  ativo_p          : out std_logic;
				  ativo_r          : out std_logic;
				  db_dado_recebido : out std_logic_vector(6 downto 0);
				  db_estado_rx : out std_logic_vector(3 downto 0)
        );
    end component sonar_fd;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_tx_pronto, s_fim_conta_digito, s_fim_espera_servo, s_hcsr_pronto: std_logic;
    signal s_partida, s_conta_digito, s_reset_servo, s_zera_ang, s_medir, s_fim_posicao: std_logic;
    signal s_conta_ang, s_zera_digito, s_conta_servo: std_logic;
    signal s_db_estado: std_logic_vector(3 downto 0);
	 signal s_ativo_p, s_ativo_r: std_logic;
	 signal s_db_dado_recebido: std_logic_vector(6 downto 0);
	 signal s_db_estado_rx, s_aux: std_logic_vector(3 downto 0);
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
				ativo_p 			  => s_ativo_p,
				ativo_r 			  => s_ativo_r,
            partida          => s_partida,
            conta_digito     => s_conta_digito,
            reset_servo      => s_reset_servo,
            conta_servo      => s_conta_servo,
            zera_ang         => s_zera_ang,
            medir            => s_medir,
            fim_posicao      => s_fim_posicao,
            conta_ang        => s_conta_ang,
            zera_digito      => s_zera_digito,
				modo             => db_modo,
            db_estado        => s_db_estado
        );

    FD: sonar_fd 
        port map ( 
            clock            => clock,
            reset            => reset,
            partida          => s_partida,
            conta_digito     => s_conta_digito,
            reset_servo      => s_reset_servo,
            conta_servo      => s_conta_servo,
            zera_ang         => s_zera_ang,
            medir            => s_medir,
            fim_posicao      => s_fim_posicao,
            conta_ang        => s_conta_ang,
            echo             => echo,
            zera_digito      => s_zera_digito,
				entrada_serial   => entrada_serial,
            tx_pronto        => s_tx_pronto,
            fim_conta_digito => s_fim_conta_digito,
            fim_espera_servo => s_fim_espera_servo,
            hcsr_pronto      => s_hcsr_pronto,
            trigger          => trigger,
            saida_serial     => saida_serial,
            pwm              => pwm,
				ativo_p 			  => s_ativo_p,
				ativo_r 			  => s_ativo_r,
				db_dado_recebido => s_db_dado_recebido,
				db_estado_rx => s_db_estado_rx
        );

    STATE_HEX: hex7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );
		  
	DADO1_HEX: hex7seg
        port map (
            hexa => s_db_dado_recebido(3 downto 0),
            sseg => db_dado_1
        );
		  
	DADO2_HEX: hex7seg
        port map (
            hexa => s_aux,
            sseg => db_dado_2
        );

    s_aux <= "0" & s_db_dado_recebido(6 downto 4);
		  
	RX_STATE_HEX: hex7seg
        port map (
            hexa => s_db_estado_rx,
            sseg => db_estado_rx
        );

    fim_posicao <= s_fim_posicao;
    
end architecture fsm_arch;
