library ieee;
use ieee.std_logic_1164.all;

entity sonar_fd is 
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
        tx_pronto        : out std_logic;
        fim_conta_digito : out std_logic;
        ligar            : out std_logic;
        fim_espera_servo : out std_logic;
        hcsr_pronto      : out std_logic;
        fim_ang          : out std_logic;
        trigger          : out std_logic;
        saida_serial     : out std_logic;
        pwm              : out std_logic
    );
end sonar_fd;

architecture fsm_arch of sonar_fd is
    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto    : out std_logic;
            db_reset  : out std_logic;
            db_medir  : out std_logic;
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component interface_hcsr04;

    component tx_serial_7E2 is
        port (
            clock           : in  std_logic;
            reset           : in  std_logic;
            partida         : in  std_logic;
            dados_ascii     : in  std_logic_vector (6 downto 0);
            saida_serial    : out std_logic;
            pronto          : out std_logic;
            -- Sinais de depuração
            db_partida      : out std_logic;
            db_saida_serial : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0)
        );
    end component tx_serial_7E2;

    component mux_8x1_n is
        generic (
            constant BITS: integer := 4
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            D4 :     in  std_logic_vector (BITS-1 downto 0);
            D5 :     in  std_logic_vector (BITS-1 downto 0);
            D6 :     in  std_logic_vector (BITS-1 downto 0);
            D7 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (2 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    component controle_servo_3 is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic_vector(2 downto 0);  
            pwm        : out std_logic;
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(2 downto 0)
          );
      end controle_servo_3;

    signal s_medida: std_logic_vector (11 downto 0);
    signal s_dados_ascii: std_logic_vector (6 downto 0);
    signal s_posicao, s_mux_sel: std_logic_vector(2 downto 0);  
begin
    HCSR04: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => medir,
            echo      => echo,
            trigger   => trigger,
            medida    => s_medida,
            pronto    => hcsr_pronto,
            db_reset  => open,
            db_medir  => open,
            db_estado => open
        );

    TX_SERIAL: tx_serial_7E2
        port map (
            clock           => clock,
            reset           => reset,
            partida         => partida,
            dados_ascii     => s_dados_ascii,
            saida_serial    => saida_serial,
            pronto          => tx_pronto,
            db_partida      => open,
            db_saida_serial => open,
            db_estado       => open
        );

    MUX8X1: mux_8x1_n
        generic map (
            BITS => 7
        )
        port map ( 
            D0 => open,
            D1 => open,
            D2 => open,
            D3 => "0101100", -- , em hexadecimal (2CH)
            D4 => "011" & s_medida(11 downto 8), -- Adiciona "110000" = 30 em hexadecimal (Idem para os abaixo)
            D5 => "011" & s_medida(7 downto 4),
            D6 => "011" & s_medida(3 downto 0),
            D7 => "0100011", -- # em hexadecimal (23H)
            SEL     => s_mux_sel,
            MUX_OUT => open,
        );

    SERVO: controle_servo_3
        port (
            clock      => clock,
            reset      => reset,
            posicao    => s_posicao,
            pwm        => pwm,
            db_reset   => open,
            db_pwm     => open,
            db_posicao => open,
          );
      end controle_servo_3;

      -- TODO: Contador para s_posicao e s_mux_sel
      -- Saída (11 downto 0) no controle servo para sair o angulo de forma a entrar no mux (Como o s_medida)

end architecture fsm_arch;
