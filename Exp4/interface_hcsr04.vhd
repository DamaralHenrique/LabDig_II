library IEEE;
use IEEE.std_logic_1164.all;

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


architecture rtl of rx_serial_7E2 is

    component interface_hcsr04_uc is 
        port ( 
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            fim_medida : in  std_logic;
            zera       : out std_logic;
            gera       : out std_logic;
            registra   : out std_logic;
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) 
        );
    end component;

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

    signal s_fim_medida, s_zera, s_gera, s_registra : std_logic;

begin

    UC: interface_hcsr04_uc 
        port map (
            clock      => clock,
            reset      => reset,
            medir      => medir,
            echo       => echo,
            fim_medida => s_fim_medida,
            zera       => s_zera,
            gera       => s_gera,
            registra   => s_registra,
            pronto     => pronto,
            db_estado  => db_estado
        );

    FD: interface_hcsr04_fd
        port map ( 
            clock       => clock,
            zera        => s_zera,
            pulso       => s_pulso, -- echo
            gera        => s_gera,
            registra    => s_registra,
            distancia   => medida,
            fim_medida  => s_fim_medida,
            trigger     => trigger,
        );

end architecture rtl;
