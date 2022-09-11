library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_7E2 is
    port (
        clock : in std_logic;
        reset : in std_logic;
        dado_serial : in std_logic;
        dado_recebido0 : out std_logic_vector(6 downto 0);
        dado_recebido1 : out std_logic_vector(6 downto 0);
        paridade_recebida : out std_logic;
        tem_dado : out std_logic;
        paridade_ok : out std_logic;
        pronto_rx : out std_logic;
        db_estado : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of rx_serial_7E2 is

    component unidade_controle is
        port (
            clock       : in std_logic;
            reset       : in std_logic;
            dado_serial : in std_logic;
            tick        : in std_logic;
            fim         : in std_logic;
            limpaRP     : out std_logic;
            zeraC       : out std_logic;
            carregaRDS  : out std_logic;
            deslocaRDS  : out std_logic;
            contaC      : out std_logic;
            registraRP  : out std_logic;
            pronto      : out std_logic;
            tem_dado    : out std_logic;
            db_estado   : out std_logic_vector(3 downto 0)
        );
    end component;

    component fluxo_dados is
        port (
            clock       : in std_logic;
            reset       : in std_logic;
            conta       : in std_logic;
            zera        : in std_logic;
            carrega     : in std_logic;
            desloca     : in std_logic;
            dado_serial : in std_logic;
            limpa       : in std_logic;
            registra    : in std_logic;
            tick              : out std_logic;
            fim               : out std_logic;
            paridade_recebida : out std_logic;
            paridade_ok       : out std_logic;
            dados             : out std_logic_vector(7 downto 0)
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

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
    end component contador_m;

    component deslocador_n is
        generic (
            constant N : integer := 4
        );
        port (
            clock          : in  std_logic;
            reset          : in  std_logic;
            carrega        : in  std_logic; 
            desloca        : in  std_logic; 
            entrada_serial : in  std_logic; 
            dados          : in  std_logic_vector (N-1 downto 0);
            saida          : out std_logic_vector (N-1 downto 0)
        );
    end component deslocador_n;

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
    end component registrador_n;

    signal s_tick, s_fim, s_limpaRP, s_zeraC, s_carregaRDS, s_deslocaRDS, s_contaC, s_registraRP, s_tem_dado: std_logic;
    signal s_dados: std_logic_vector(7 downto 0);
    signal s_db_estado: std_logic_vector(3 downto 0);
begin

    UC: unidade_controle 
        port map (
            clock       => clock, 
            reset       => reset, 
            dado_serial => dado_serial,
            tick        => s_tick, 
            fim         => s_fim,
            limpaRP     => s_limpaRP, 
            zeraC       => s_zeraC,
            carregaRDS  => s_carregaRDS,
            deslocaRDS  => s_deslocaRDS,
            contaC      => s_contaC,
            registraRP  => s_registraRP,
            pronto      => pronto_rx,
            tem_dado    => s_tem_dado,
            db_estado   => s_db_estado
        );

    FD: fluxo_dados
        port map (
            clock       => clock,
            reset       => reset,
            conta       => s_contaC,
            zera        => s_zeraC,
            carrega     => s_carregaRDS,
            desloca     => s_deslocaRDS,
            dado_serial => dado_serial,
            limpa       => s_limpaRP,
            registra    => s_registraRP,
            tick              => s_tick,
            fim               => s_fim,
            paridade_recebida => paridade_recebida,
            paridade_ok       => paridade_ok,
            dados             => s_dados
        );

    STATE_HEX: hex7seg
        port map(
            hexa => s_db_estado,
            sseg => db_estado
        );
    
    DATA_HEX1: hex7seg
        port map(
            hexa => s_dados(3 downto 0),
            sseg => dado_recebido0
        );

    DATA_HEX2: hex7seg
        port map(
            hexa => '0' & s_dados(6 downto 4),
            sseg => dado_recebido1
        );

    tem_dado <= s_tem_dado;

end architecture rtl;
