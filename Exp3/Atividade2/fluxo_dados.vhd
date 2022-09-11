library IEEE;
use IEEE.std_logic_1164.all;

entity fluxo_dados is
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
end entity;

architecture rtl of fluxo_dados is

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

    component testador_paridade is
        port (
            dado     : in  std_logic_vector (6 downto 0);
            paridade : in  std_logic;
            par_ok   : out std_logic;
            impar_ok : out std_logic
        );
    end component testador_paridade;

    signal s_dados, s_saida: std_logic_vector(9 downto 0);
begin

    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    CONTADOR_TICK: contador_m 
        generic map (
            M => 434, -- 115.200 bauds
            N => 13
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => '1', 
            Q     => open, 
            fim   => open,
            meio  => tick
        );

    CONTADOR_DADOS: contador_m 
        generic map (
            M => 12,
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim,
            meio  => open
        );

    DESLOCADOR: deslocador_n 
        generic map (
            N => 10
        ) 
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => dado_serial, 
            dados          => "0000000000", 
            saida          => s_saida
        );

    REGISTRADOR: registrador_n 
        generic map (
            N => 10
        ) 
        port map (
            clock  => clock, 
            clear  => limpa, 
            enable => registra, 
            D      => s_saida, 
            Q      => s_dados
        );

    PARIDADE: testador_paridade
        port map(
            dado     => s_dados(6 downto 0), 
            paridade => s_dados(7), 
            par_ok   => paridade_ok, 
            impar_ok => open
        );

    paridade_recebida <= s_dados(7);

    dados <= s_dados(7 downto 0);

end architecture rtl;
