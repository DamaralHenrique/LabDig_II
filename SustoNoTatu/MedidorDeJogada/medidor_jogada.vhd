library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_jogada is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        inicia    : in  std_logic;
        fim_de_jogo : in  std_logic;
        echo1     : in  std_logic;
        echo2     : in  std_logic;
        trigger1  : out std_logic;
        trigger2  : out std_logic;
        tatus     : out std_logic_vector(2 downto 0);
        db_estado_hcsr04_1 : out std_logic_vector(3 downto 0);
        db_estado_hcsr04_2 : out std_logic_vector(3 downto 0);
        db_pronto_estado_hcsr04_1 : out std_logic;
        db_pronto_estado_hcsr04_2 : out std_logic;
        db_medida1 : out std_logic_vector(11 downto 0);
        db_medida2 : out std_logic_vector(11 downto 0);
        db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
end entity medidor_jogada;


architecture rtl of medidor_jogada is

    component medidor_jogada_uc is 
        port ( 
            clock            : in  std_logic;
            reset            : in  std_logic;
            inicia           : in  std_logic;
            pronto_hcsr04_1  : in  std_logic;
            pronto_hcsr04_2  : in  std_logic;
            fim_espera       : in  std_logic;
            fim_de_jogo      : in  std_logic;
            zera_espera     : out std_logic;
            conta_espera    : out std_logic;
            medir           : out std_logic;
            registra_distancia : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0)
        );
    end component;

    component medidor_jogada_fd is
        port (
            clock           : in  std_logic;
            reset           : in  std_logic;
            zera_espera     : in std_logic;
            conta_espera    : in std_logic;
            medir           : in std_logic;
            echo1           : in std_logic;
            echo2           : in std_logic;
            registra_distancia : in  std_logic;
            trigger1        : out std_logic;
            trigger2        : out std_logic;
            pronto_hcsr04_1 : out std_logic;
            pronto_hcsr04_2 : out std_logic;
            fim_espera      : out std_logic;
            tatus           : out std_logic_vector(2 downto 0);
            medida1         : out std_logic_vector(11 downto 0);
            medida2         : out std_logic_vector(11 downto 0);
            db_estado_hcsr04_1 : out std_logic_vector(3 downto 0);
            db_estado_hcsr04_2 : out std_logic_vector(3 downto 0)
        );
    end component;

    signal s_fim_espera, s_zera_medida, s_zera_espera, s_conta_espera, s_medir : std_logic;
    signal s_pronto_hcsr04_1, s_pronto_hcsr04_2, s_registra_distancia : std_logic;
    signal s_medida1, s_medida2: std_logic_vector(11 downto 0);

begin

    UC: medidor_jogada_uc 
        port map ( 
            clock           => clock,
            reset           => reset,
            inicia          => inicia,
            pronto_hcsr04_1 => s_pronto_hcsr04_1,
            pronto_hcsr04_2 => s_pronto_hcsr04_2,
            fim_espera      => s_fim_espera,
            fim_de_jogo     => fim_de_jogo,
            zera_espera     => s_zera_espera,
            conta_espera    => s_conta_espera,
            medir           => s_medir,
            registra_distancia => s_registra_distancia,
            db_estado       => db_estado
        );

    db_pronto_estado_hcsr04_1 <= s_pronto_hcsr04_1;
    db_pronto_estado_hcsr04_2 <= s_pronto_hcsr04_2;

    FD: medidor_jogada_fd
        port map (
            clock           => clock,
            reset           => reset,
            zera_espera     => s_zera_espera,
            conta_espera    => s_conta_espera,
            medir           => s_medir,
            echo1           => echo1,
            echo2           => echo2,
            registra_distancia => s_registra_distancia, 
            trigger1        => trigger1,
            trigger2        => trigger2,
            pronto_hcsr04_1 => s_pronto_hcsr04_1,
            pronto_hcsr04_2 => s_pronto_hcsr04_2,
            fim_espera      => s_fim_espera,
            tatus           => tatus,
            medida1         => db_medida1,
            medida2         => db_medida2,
            db_estado_hcsr04_1 => db_estado_hcsr04_1,
            db_estado_hcsr04_2 => db_estado_hcsr04_2
        );

end architecture rtl;
