library IEEE;
use IEEE.std_logic_1164.all;

entity exp5_trena is
    port (
        clock        : in std_logic;
        reset        : in std_logic;
        mensurar     : in std_logic;
        echo         : in std_logic;
        trigger      : out std_logic;
        saida_serial : out std_logic;
        medida0      : out std_logic_vector (6 downto 0);
        medida1      : out std_logic_vector (6 downto 0);
        medida2      : out std_logic_vector (6 downto 0);
        pronto       : out std_logic;
        db_estado    : out std_logic_vector (6 downto 0)
    );
end entity exp5_trena;

architecture arch of exp5_trena is
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
        );
    end component exp5_uc;

    component exp5_fd is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            -- Sinais pra interface_hcsr04
            partida      : in  std_logic;
            dados_ascii  : in  std_logic_vector (6 downto 0);
            -- Sinais pro tx_serial_7E2
            medir        : in  std_logic;
            echo         : in  std_logic;
            -- Sinais de saida
            medida       : out std_logic_vector(11 downto 0);
            hcdsr_pronto : out std_logic;
            tx_pronto    : out std_logic;
        );
    end component exp5_fd;
    
    signal s_medir, s_partida, s_fim: std_logic;
    signal s_escolha: std_logic_vector (1 downto 0);
    signal s_dados_ascii: std_logic_vector (6 downto 0);
    signal s_medida: std_logic_vector(11 downto 0);
    signal s_hcdsr_pronto, s_tx_pronto: std_logic;

begin
    uc: exp5_uc
        port map (
            clock         => clock,
            reset         => reset,
            mensurar      => mensurar,
            hcdsr_pronto  => s_hcdsr_pronto,
            tx_pronto     => s_tx_pronto,
            medir         => s_medir,
            partida       => s_partida,
            escolha_ascii => s_escolha,
            fim           => s_fim,
        );

    fd: exp5_fd
        port map (
            clock        => clock,
            reset        => reset,
            partida      => s_partida,
            dados_ascii  => s_dados_ascii,
            medir        => s_medir,
            echo         => echo,
            medida       => s_medida,
            hcdsr_pronto => s_hcdsr_pronto,
            tx_pronto    => s_tx_pronto,
        );

    mux_4x1: mux_4x1_n
        generic map(
            BITS => 7
        );
        port map( 
            D3      => open, -- TODO: add sinal centena
            D2      => open, -- TODO: add sinal dezena
            D1      => open, -- TODO: add sinal unidade
            D0      => "00100011", -- # (hex)
            SEL     => s_escolha,
            MUX_OUT => s_dados_ascii
        );

end architecture;