library IEEE;
use IEEE.std_logic_1164.all;

entity susto_no_tatu is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        iniciar     : in  std_logic;
        echo_01     : in  std_logic;
        echo_02     : in  std_logic;
        echo_11     : in  std_logic;
        echo_12     : in  std_logic;
        dificuldade : in  std_logic;
        botoes      : in  std_logic_vector(5 downto 0);
        trigger_01  : out std_logic;
        trigger_02  : out std_logic;
        trigger_11  : out std_logic;
        trigger_12  : out std_logic;
        pwm_tatu_00 : out std_logic;
        pwm_tatu_01 : out std_logic;
        pwm_tatu_02 : out std_logic;
        pwm_tatu_10 : out std_logic;
        pwm_tatu_11 : out std_logic;
        pwm_tatu_12 : out std_logic;
        serial      : out std_logic;
        vidas       : out std_logic_vector (1 downto 0);
        pontuacao1  : out std_logic_vector (6 downto 0);
        pontuacao2  : out std_logic_vector (6 downto 0)
    );
end entity susto_no_tatu;

architecture rtl of susto_no_tatu is

    component circuito_tapa_no_tatu is
        port (
        clock       : in std_logic;
        reset       : in std_logic;
        iniciar     : in std_logic;
        botoes      : in std_logic_vector(5 downto 0);
        dificuldade : in std_logic;
        leds        : out std_logic_vector(5 downto 0);
        fimDeJogo   : out std_logic;
        vidas       : out std_logic_vector (1 downto 0);
        display1    : out std_logic_vector (6 downto 0);
        display2    : out std_logic_vector (6 downto 0);
        serial      : out std_logic;
        -- Sinais de depuração
        db_estado       : out std_logic_vector (6 downto 0);
        db_jogadaFeita  : out std_logic;
        db_jogadaValida : out std_logic;
        db_timeout      : out std_logic;
        db_ini          : out std_logic
        );
    end component;

    component servo_tatu is
        port (
            clock : in  std_logic;
            reset : in  std_logic;
            tatus : in  std_logic_vector(2 downto 0);
            pwm0  : out std_logic;
            pwm1  : out std_logic;
            pwm2  : out std_logic
        );
    end component servo_tatu;

    component medidor_jogada is
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
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component medidor_jogada;

    signal s_fim_de_jogo: std_logic;
    signal s_tatus: std_logic_vector(5 downto 0);
    signal s_tatus_selecionados, s_botoes_selecionados: std_logic_vector(5 downto 0);

begin

    TAPA_NO_TATU: circuito_tapa_no_tatu
        port map (
        clock       => clock,
        reset       => reset,
        iniciar     => iniciar,
        botoes      => s_botoes_selecionados,
        dificuldade => dificuldade,
        leds        => s_tatus,
        fimDeJogo   => s_fim_de_jogo,
        vidas       => vidas,
        display1    => pontuacao1,
        display2    => pontuacao2,
        serial      => serial,
        -- Sinais de depuração
        db_estado       => open,
        db_jogadaFeita  => open,
        db_jogadaValida => open,
        db_timeout      => open,
        db_ini          => open
        );


    SERVO_TATU_0: servo_tatu
        port map (
            clock => clock,
            reset => reset,
            tatus => s_tatus(2 downto 0),
            pwm0  => pwm_tatu_00,
            pwm1  => pwm_tatu_01,
            pwm2  => pwm_tatu_02,
        );

    SERVO_TATU_1: servo_tatu
        port map (
            clock => clock,
            reset => reset,
            tatus => s_tatus(5 downto 3),
            pwm0  => pwm_tatu_10,
            pwm1  => pwm_tatu_11,
            pwm2  => pwm_tatu_12,
        );

    MEDIDOR_JOGADA_0: medidor_jogada
        port map (
            clock     => clock,
            reset     => reset,
            inicia    => iniciar,
            fim_de_jogo => s_fim_de_jogo,
            echo1     => echo_01,
            echo2     => echo_02,
            trigger1  => trigger_01,
            trigger2  => trigger_02,
            tatus     => s_tatus_selecionados(2 downtto 0),
            db_estado_hcsr04_1 => open,
            db_estado_hcsr04_2 => open,
            db_estado => open -- estado da UC
        );

    MEDIDOR_JOGADA_1: medidor_jogada
        port map (
            clock     => clock,
            reset     => reset,
            inicia    => iniciar,
            fim_de_jogo => s_fim_de_jogo,
            echo1     => echo_11,
            echo2     => echo_12,
            trigger1  => trigger_11,
            trigger2  => trigger_12,
            tatus     => s_tatus_selecionados(5 downtto 3),
            db_estado_hcsr04_1 => open,
            db_estado_hcsr04_2 => open,
            db_estado => open -- estado da UC
        );

    s_botoes_selecionados <= botoes or s_tatus_selecionados;

end architecture rtl;
