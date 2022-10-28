library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_jogada is
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
            zera_medida     : out std_logic;
            zera_espera     : out std_logic;
            conta_espera    : out std_logic;
            medir           : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0) 
        );
        end medidor_jogada_uc;

    component interface_hcsr04_fd is
        port (
            clock      : in  std_logic;
            zera       : in  std_logic;
            pulso      : in  std_logic; -- echo
            gera       : in  std_logic;
            registra   : in  std_logic;
            distancia  : out std_logic_vector(11 downto 0);
            fim_medida : out std_logic;
            trigger    : out std_logic
        );
    end component;

    signal s_fim_espera, s_zera_medida, s_zera_espera, s_conta_espera, s_medir : std_logic;
    signal s_pronto_hcsr04_1, s_pronto_hcsr04_2 : std_logic;

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
            zera_medida     => s_zera_medida,
            zera_espera     => s_zera_espera,
            conta_espera    => s_conta_espera,
            medir           => s_medir,
            db_estado       => db_estado
        );

    FD: interface_hcsr04_fd
        port map ( 
            clock       => clock,
            zera        => s_zera,
            pulso       => echo,
            gera        => s_gera,
            registra    => s_registra,
            distancia   => medida,
            fim_medida  => s_fim_medida,
            trigger     => trigger
        );

end architecture rtl;
