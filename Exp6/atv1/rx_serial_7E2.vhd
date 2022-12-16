library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_7E2 is
    port (
        clock             : in std_logic;
        reset             : in std_logic;
        dado_serial       : in std_logic;
        dado_recebido     : out std_logic_vector(6 downto 0);
        paridade_recebida : out std_logic;
        tem_dado          : out std_logic;
        paridade_ok       : out std_logic;
        pronto_rx         : out std_logic;
        db_dado_serial    : out std_logic;
        db_estado         : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of rx_serial_7E2 is

    component rx_serial_7E2_uc is
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

    component rx_serial_7E2_fd is
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

    signal s_tick, s_fim, s_limpaRP, s_zeraC, s_carregaRDS, s_deslocaRDS, s_contaC, s_registraRP, s_tem_dado: std_logic;
    signal s_dados:     std_logic_vector(7 downto 0);
    signal s_hexa_in:   std_logic_vector(3 downto 0);
    signal s_db_estado: std_logic_vector(3 downto 0);
begin

    UC: rx_serial_7E2_uc 
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

    FD: rx_serial_7E2_fd
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
    
    tem_dado <= s_tem_dado;
    dado_recebido <= s_dados(6 downto 0);

    -- Sinais de depuração
    db_dado_serial <= dado_serial;
    db_estado <= s_db_estado;

end architecture rtl;
