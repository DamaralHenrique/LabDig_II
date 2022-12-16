------------------------------------------------------------------
-- Arquivo   : tx_serial_7E2.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito base da experiencia 2 
--             > implementa configuracao 7E2
--             > 
--             > componente edge_detector (U4) trata pulsos largos
--             > da entrada PARTIDA (veja linha 139)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao do codigo
--     04/09/2022  3.0     Henrique Matheus  refatoracao do codigo
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_7E2 is
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
end entity;

architecture tx_serial_7E2_arch of tx_serial_7E2 is     
    component tx_serial_uc 
    port ( 
        clock   : in  std_logic;
        reset   : in  std_logic;
        partida : in  std_logic;
        tick    : in  std_logic;
        fim     : in  std_logic;
        zera    : out std_logic;
        conta   : out std_logic;
        carrega : out std_logic;
        desloca : out std_logic;
        pronto  : out std_logic;
        d_estado: out std_logic_vector(3 downto 0)
    );
    end component;

    component tx_serial_7E2_fd 
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        zera         : in  std_logic;
        conta        : in  std_logic;
        carrega      : in  std_logic;
        desloca      : in  std_logic;
        dados_ascii  : in  std_logic_vector (7 downto 0);
        saida_serial : out std_logic;
        fim          : out std_logic
    );
    end component;
    
    component contador_m
    generic (
        constant M : integer; 
        constant N : integer 
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

    signal s_reset: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
    signal s_saida_serial: std_logic;
    signal s_dados_ascii: std_logic_vector (7 downto 0);
    signal s_estado: std_logic_vector(3 downto 0);

begin

    -- sinais reset e partida ativos em alto
    s_reset   <= reset;
    s_dados_ascii(6 downto 0) <= dados_ascii; -- Dados a serem enviados
    s_dados_ascii(7) <= dados_ascii(0) xor dados_ascii(1) xor dados_ascii(2) xor dados_ascii(3) -- Sinal de pareamento par
	                    xor dados_ascii(4) xor dados_ascii(5) xor dados_ascii(6); 

    U1_UC: tx_serial_uc 
           port map (
               clock    => clock, 
               reset    => s_reset, 
               partida  => partida, 
               tick     => s_tick, 
               fim      => s_fim,
               zera     => s_zera, 
               conta    => s_conta, 
               carrega  => s_carrega, 
               desloca  => s_desloca, 
               pronto   => pronto,
               d_estado => s_estado
           );

    U2_FD: tx_serial_7E2_fd 
           port map (
               clock        => clock, 
               reset        => s_reset, 
               zera         => s_zera, 
               conta        => s_conta, 
               carrega      => s_carrega, 
               desloca      => s_desloca, 
               dados_ascii  => s_dados_ascii, 
               saida_serial => s_saida_serial, 
               fim          => s_fim
           );

    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK: contador_m 
             generic map (
                 M => 434, -- 115.200 bauds
                 N => 13
             ) 
             port map (
                 clock => clock, 
                 zera  => s_zera, 
                 conta => '1', 
                 Q     => open, 
                 fim   => s_tick,
                 meio  => open
             );

    -- saida
    saida_serial <= s_saida_serial;

    -- sinais de depuração
    db_estado <= s_estado;
    db_partida <= partida;
    db_saida_serial <= s_saida_serial;

end architecture;

