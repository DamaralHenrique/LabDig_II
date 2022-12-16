library IEEE;
use IEEE.std_logic_1164.all;

entity exp5_trena is
    port (
        clock        : in std_logic;
        reset        : in std_logic;
        mensurar     : in std_logic;
        echo         : in std_logic;
		  modo         : in std_logic;
        trigger      : out std_logic;
        saida_serial : out std_logic;
        medida0      : out std_logic_vector (6 downto 0);
        medida1      : out std_logic_vector (6 downto 0);
        medida2      : out std_logic_vector (6 downto 0);
        pronto       : out std_logic;
        db_estado      : out std_logic_vector (6 downto 0);
        db_hcrs_estado : out std_logic_vector (6 downto 0);
        db_tx_estado   : out std_logic_vector (6 downto 0)
    );
end entity exp5_trena;

architecture arch of exp5_trena is

    component exp5_uc is
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            mensurar      : in  std_logic;
            hcdsr_pronto  : in  std_logic;
            tx_pronto     : in  std_logic;
            -- Saidas pra interface_hcsr04
            medir         : out std_logic;
            -- Saidas pro tx
            partida       : out std_logic;
            escolha_ascii : out std_logic_vector (1 downto 0);
            -- Saidas pro exp5_trena
            fim           : out std_logic;
            db_estado     : out std_logic_vector(3 downto 0)
        );
    end component exp5_uc;

    component exp5_fd is
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
    end component exp5_fd;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;
	 
	 component edge_detector 
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
    end component;
    
    signal s_medir, s_mensurar_auto, s_partida, s_mensurar_ed, s_mensurar: std_logic;
    signal s_escolha: std_logic_vector (1 downto 0);
    signal s_dados_ascii: std_logic_vector (6 downto 0);
    signal s_medida: std_logic_vector(11 downto 0);
    signal s_hcdsr_pronto, s_tx_pronto: std_logic;
    signal s_db_estado, s_db_hcrs_estado, s_db_tx_estado: std_logic_vector(3 downto 0);

begin

	s_mensurar <= s_mensurar_ed when modo='0' else s_mensurar_auto;
	
    uc: exp5_uc
        port map (
            clock         => clock,
            reset         => reset,
            mensurar      => s_mensurar,
            hcdsr_pronto  => s_hcdsr_pronto,
            tx_pronto     => s_tx_pronto,
            medir         => s_medir,
            partida       => s_partida,
            escolha_ascii => s_escolha,
            fim           => pronto,
            db_estado     => s_db_estado
        );

    fd: exp5_fd
        port map (
            clock        => clock,
            reset        => reset,
            -- Sinais pro interface_hcsr04
            medir        => s_medir,
            echo         => echo,
            medida       => s_medida,
            trigger      => trigger,
            hcsr_pronto  => s_hcdsr_pronto,
            db_hcrs_estado => s_db_hcrs_estado,
            -- Sinais pra tx_serial_7E2
            partida      => s_partida,
            tx_pronto    => s_tx_pronto,
            saida_serial => saida_serial,
            db_tx_estado => s_db_tx_estado,
            -- Sinais do mux
            mux_escolha  => s_escolha,
				-- Sinal do modo
			   modo         => modo,
			   medir_auto   => s_mensurar_auto
        );
		  
	 ED: edge_detector 
		 port map (  
			  clock     => clock,
			  signal_in => mensurar,
			  output    => s_mensurar_ed
		 );

    STATE_HEX: hex7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );

    HCRS_STATE_HEX: hex7seg
        port map (
            hexa => s_db_hcrs_estado,
            sseg => db_hcrs_estado
        );

    TX_STATE_HEX: hex7seg
        port map (
            hexa => s_db_tx_estado,
            sseg => db_tx_estado
        );

    MEDIDA0_HEX: hex7seg
        port map (
            hexa => s_medida(3 downto 0),
            sseg => medida0
        );

    MEDIDA1_HEX: hex7seg
        port map(
            hexa => s_medida(7 downto 4),
            sseg => medida1
        );

    MEDIDA2_HEX: hex7seg
        port map (
            hexa => s_medida(11 downto 8),
            sseg => medida2
        );

end architecture;
