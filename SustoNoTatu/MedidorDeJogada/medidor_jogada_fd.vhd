library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_jogada_fd is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        zera_medida     : in std_logic;
        registra_medida : in std_logic;
        zera_espera     : in std_logic;
        conta_espera    : in std_logic;
        medir           : in std_logic;
        echo1           : in std_logic;
        echo2           : in std_logic;
        trigger         : out std_logic;
        pronto_hcsr04_1 : out std_logic;
        pronto_hcsr04_2 : out std_logic;
        db_estado_hcsr04_1 : out std_logic_vector(3 downto 0);
        db_estado_hcsr04_2 : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of medidor_jogada_fd is

    entity interface_hcsr04 is
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
    end entity interface_hcsr04;

    signal s_medida1, s_medida2: std_logic_vector(11 downto 0);

begin

    MEDIDOR_1: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => medir,
            echo      => echo1,
            trigger   => trigger,
            medida    => s_medida1, -- 3 digitos BCD
            pronto    => pronto_hcsr04_1,
            db_estado => db_estado_hcsr04_1,
        );

    MEDIDOR_2: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => medir,
            echo      => echo2,
            trigger   => trigger,
            medida    => s_medida2, -- 3 digitos BCD
            pronto    => pronto_hcsr04_2,
            db_estado => db_estado_hcsr04_2,
        );

end architecture rtl;
