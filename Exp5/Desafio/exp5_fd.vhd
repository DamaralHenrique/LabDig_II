library IEEE;
use IEEE.std_logic_1164.all;

entity exp5_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        -- Sinais pro interface_hcsr04
        medir        : in  std_logic;
        echo         : in  std_logic;
        medida       : out std_logic_vector(11 downto 0);
        trigger      : out std_logic;
        hcsr_pronto  : out std_logic;
        db_hcrs_estado : out std_logic_vector(3 downto 0);
        -- Sinais pra tx_serial_7E2
        partida      : in  std_logic;
        tx_pronto    : out std_logic;
        saida_serial : out std_logic;
        db_tx_estado : out std_logic_vector(3 downto 0);
        -- Sinais do mux
        mux_escolha  : in std_logic_vector(1 downto 0);
		  -- Sinal do modo
		  modo         : in  std_logic;
		  medir_auto   : out std_logic
    );
end entity;

architecture rtl of exp5_fd is
    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component interface_hcsr04;
    
    component tx_serial_7E2 is
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            partida       : in  std_logic;
            dados_ascii   : in  std_logic_vector (6 downto 0); -- Redução do tamanho da entrada
            saida_serial  : out std_logic;
            pronto        : out std_logic;
            -- Sinais de depuração
            d_tick        : out std_logic;
            d_estado      : out std_logic_vector(3 downto 0)
        );
    end component tx_serial_7E2;

    component  mux_4x1_n is
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
			  fim   : out std_logic
		 );
	end component;
	
	component edge_detector 
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
    end component;

    signal s_dados_ascii: std_logic_vector (6 downto 0);
    signal s_medida: std_logic_vector (11 downto 0);
	 signal s_modo_ed, s_zera_auto: std_logic;

begin
    -- TODO: Adicionar instancias dos componentes
    HCSR04: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => medir,
            echo      => echo,
            trigger   => trigger,
            medida    => s_medida,
            pronto    => hcsr_pronto,
            db_estado => db_hcrs_estado
        );

    TX_SERIAL: tx_serial_7E2
        port map (
            clock         => clock,
            reset         => reset,
            partida       => partida,
            dados_ascii   => s_dados_ascii,
            saida_serial  => saida_serial,
            pronto        => tx_pronto,
            d_tick        => open,
            d_estado      => db_tx_estado
        );

    mux_4x1: mux_4x1_n
    generic map(
        BITS => 7
    )
    port map( 
        D3      => "011" & s_medida(11 downto 8), -- Adiciona "110000" = 30 em hexadecimal (Idem para os abaixo)
        D2      => "011" & s_medida(7 downto 4),
        D1      => "011" & s_medida(3 downto 0),
        D0      => "0100011", -- # em hexadecimal (23H)
        SEL     => mux_escolha,
        MUX_OUT => s_dados_ascii
    );

    medida <= s_medida;
	 
	 ED_MODE: edge_detector 
		 port map (  
			  clock     => clock,
			  signal_in => modo,
			  output    => s_modo_ed
		 );
	 
	  CONTADOR_MEDIDA: contador_m 
		  generic map (
				M => 50000000,
				N => 26
		  ) 
		  port map (
				clock => clock, 
				zera  => s_zera_auto, 
				conta => modo, 
				Q     => open,
				fim   => medir_auto
		  );
		  
	  s_zera_auto <= s_modo_ed and (not modo);

	end architecture rtl;
