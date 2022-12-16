library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is 
    port ( 
        clock         : in  std_logic;
        reset         : in  std_logic;
        partida       : in std_logic;
        conta_digito  : in std_logic;
        reset_servo   : in std_logic;
        conta_servo   : in std_logic;
        zera_ang      : in std_logic;
        medir         : in std_logic;
        fim_posicao   : in std_logic;
        conta_ang     : in std_logic;
        echo          : in std_logic;
        zera_digito   : in std_logic;
		entrada_serial: in std_logic;
        debug_sel     : in std_logic_vector(1 downto 0);
        tx_pronto        : out std_logic;
        fim_conta_digito : out std_logic;
        fim_espera_servo : out std_logic;
        hcsr_pronto      : out std_logic;
        trigger          : out std_logic;
        saida_serial     : out std_logic;
        pwm              : out std_logic;
		modo             : out std_logic;
        hex4      : out std_logic_vector(6 downto 0);
        hex3      : out std_logic_vector(6 downto 0);
        hex2      : out std_logic_vector(6 downto 0);
        hex1      : out std_logic_vector(6 downto 0);
        hex0      : out std_logic_vector(6 downto 0)
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
            db_estado : out std_logic_vector(3 downto 0); -- estado da UC
            db_estado_contador_cm : out std_logic_vector(3 downto 0)
        );
    end component interface_hcsr04;
	 
	 component interface_rx is
    port (
        clock             : in std_logic;
        reset             : in std_logic;
        dado_serial       : in std_logic;
		modo 			  : out std_logic;
		db_estado         : out std_logic_vector(3 downto 0);
		db_estado_rx      : out std_logic_vector(3 downto 0);
		db_dado_recebido  : out std_logic_vector(6 downto 0)
    );
	 end component;

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
    end component;

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
            db_posicao : out std_logic_vector(2 downto 0);
            angle      : out std_logic_vector(11 downto 0)
          );
    end component controle_servo_3;
    
    component contador_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;
	 
	
	component contadorg_updown_m is
		 generic (
			  constant M: integer := 50 -- modulo do contador
		 );
		 port (
			  clock  : in  std_logic;
			  zera_as: in  std_logic;
			  zera_s : in  std_logic;
			  conta  : in  std_logic;
			  Q      : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
			  inicio : out std_logic;
			  fim    : out std_logic;
			  meio   : out std_logic 
		);
	end component;

    component edge_detector 
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    component mux_4x1_n is
        generic (
            constant BITS: integer := 4
        );
        port( 
            D3      : in  std_logic_vector (BITS-1 downto 0);
            D2      : in  std_logic_vector (BITS-1 downto 0);
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D0      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic_vector (1 downto 0);
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
        );
    end component mux_4x1_n;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal s_medida: std_logic_vector (11 downto 0);
    signal s_dados_ascii: std_logic_vector (6 downto 0);
    signal s_posicao, s_mux_sel: std_logic_vector(2 downto 0); 
    signal s_partida_ed: std_logic; 
    signal s_angle: std_logic_vector(11 downto 0);
    signal s_D6, s_D5, s_D4, s_D2, s_D1, s_D0: std_logic_vector (6 downto 0);
    signal s_hex4, s_hex3, s_hex2, s_hex1, s_hex0: std_logic_vector (3 downto 0);
    signal s_db_estado_hcrs04, s_db_estado_contador_cm: std_logic_vector (3 downto 0);
    signal s_db_estado_interface_rx, s_db_estado_rx, s_db_estado_tx: std_logic_vector (3 downto 0);
    signal s_db_dado_recebido: std_logic_vector (6 downto 0);

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
            db_estado => s_db_estado_hcrs04,
            db_estado_contador_cm => s_db_estado_contador_cm
        );
		  
	 INTERFACE_RX_SERIAL : interface_rx
		 port map (
			clock       => clock,
            reset       => reset,
			dado_serial => entrada_serial,
			modo 	    => modo,
			db_estado   => s_db_estado_interface_rx,
			db_estado_rx => s_db_estado_rx,
			db_dado_recebido  => s_db_dado_recebido
		 );

    TX_SERIAL: tx_serial_7E2
        port map (
            clock           => clock,
            reset           => reset,
            partida         => s_partida_ed,
            dados_ascii     => s_dados_ascii,
            saida_serial    => saida_serial,
            pronto          => tx_pronto,
            db_partida      => open,
            db_saida_serial => open,
            db_estado       => s_db_estado_tx
        );

    MUX8X1: mux_8x1_n
        generic map (
            BITS => 7
        )
        port map ( 
            D0 => s_D0,
            D1 => s_D1,
            D2 => s_D2,
            D3 => "0101100", -- , em hexadecimal (2CH)
            D4 => s_D4,
            D5 => s_D5,
            D6 => s_D6,
            D7 => "0100011", -- # em hexadecimal (23H)
            SEL     => s_mux_sel,
            MUX_OUT => s_dados_ascii
        );
    
    -- Sinais auxiliares para o MUX
    s_D0 <= "011" & s_angle(11 downto 8);
    s_D1 <= "011" & s_angle(7 downto 4);
    s_D2 <= "011" & s_angle(3 downto 0);
    s_D4 <= "011" & s_medida(11 downto 8);
    s_D5 <= "011" & s_medida(7 downto 4);
    s_D6 <= "011" & s_medida(3 downto 0);

    SERVO: controle_servo_3
        port map (
            clock      => clock,
            reset      => reset,
            posicao    => s_posicao,
            pwm        => pwm,
            db_reset   => open,
            db_pwm     => open,
            db_posicao => open,
            angle      => s_angle
        );
		  
	 CONT_VAI_E_VEM: contadorg_updown_m
		 generic map (
			  M => 8
		 )
		 port map (
			  clock   => clock,
			  zera_as => zera_ang,
			  zera_s  => zera_ang,
			  conta   => conta_ang,
			  Q     => s_posicao,
			  inicio => open,
           fim   => open,
           meio  => open
		);
	 

    CONT_ESPERA_SERVO: contador_m
        generic map (
            M => 100000000,
            N => 27
        )
        port map (
            clock => clock,
            zera  => reset_servo,
            conta => conta_servo,
            Q     => open,
            fim   => fim_espera_servo,
            meio  => open
        );

    CONT_MUX_SEL: contador_m
        generic map (
            M => 8,
            N => 3
        )
        port map (
            clock => clock,
            zera  => zera_digito,
            conta => conta_digito,
            Q     => s_mux_sel,
            fim   => fim_conta_digito,
            meio  => open
        );

    PARTIDA_ED: edge_detector 
        port map (
            clock     => clock,
            signal_in => partida,
            output    => s_partida_ed
        );

    MUX_4: mux_4x1_n
        generic map (
            constant => 4
        );
        port map( 
            D3      => s_db_estado_contador_cm, -- Interface HCRS04
            D2      => "0000", -- Interface RX
            D1      => "0000", -- TX serial 7E2
            D0      => "0000", -- Controle servo
            SEL     => debug_sel,
            MUX_OUT => s_hex4
        );

    MUX_3: mux_4x1_n
        generic map (
            constant => 4
        );
        port map( 
            D3      => s_medida(11 downto 8), -- Interface HCRS04
            D2      => s_db_estado_rx, -- Interface RX
            D1      => "0000", -- TX serial 7E2
            D0      => s_angle(11 downto 8), -- Controle servo
            SEL     => debug_sel,
            MUX_OUT => s_hex3
        );]

    MUX_2: mux_4x1_n
        generic map (
            constant => 4
        );
        port map( 
            D3      => s_medida(7 downto 4), -- Interface HCRS04
            D2      => "0" & s_db_dado_recebido(6 downto 4), -- Interface RX
            D1      => "0" & s_dados_ascii(6 downto 4), -- TX serial 7E2
            D0      => s_angle(7 downto 4), -- Controle servo
            SEL     => debug_sel,
            MUX_OUT => s_hex2
        );

    MUX_1: mux_4x1_n
        generic map (
            constant => 4
        );
        port map( 
            D3      => s_medida(3 downto 0), -- Interface HCRS04
            D2      => s_db_dado_recebido(3 downto 0), -- Interface RX
            D1      => s_dados_ascii(3 downto 0), -- TX serial 7E2
            D0      => s_angle(3 downto 0), -- Controle servo
            SEL     => debug_sel,
            MUX_OUT => s_hex1
        );

    MUX_0: mux_4x1_n
        generic map (
            constant => 4
        );
        port map( 
            D3      => s_db_estado_hcrs04, -- Interface HCRS04
            D2      => s_db_estado_interface_rx, -- Interface RX
            D1      => s_db_estado_tx, -- TX serial 7E2
            D0      => "0000", -- Controle servo
            SEL     => debug_sel,
            MUX_OUT => s_hex0
        );

    HEX_4: hex7seg
        port map (
            hexa => open,
            sseg => hex4
        );

    HEX_3: hex7seg
        port map (
            hexa => open,
            sseg => hex3
        );

    HEX_2: hex7seg
        port map (
            hexa => open,
            sseg => hex2
        );

    HEX_1: hex7seg
        port map (
            hexa => open,
            sseg => hex1
        );

    HEX_0: hex7seg
        port map (
            hexa => open,
            sseg => hex0
        );
    
end architecture fsm_arch;
