library IEEE;
use IEEE.std_logic_1164.all;

entity contador_cm is
    generic (
        constant R : integer;
        constant N : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        pulso   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic;
        pronto  : out std_logic;
        db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
end entity;

architecture arch of contador_cm is
    component contador_cm_uc is 
        port ( 
            clock        : in  std_logic;
            reset        : in  std_logic;
            pulso        : in  std_logic; -- echo
            tick         : in  std_logic;
            arredonda    : in  std_logic;
            s_zera_tick  : out std_logic;
            s_conta_tick : out std_logic;
            s_zera_bcd   : out std_logic;
            s_conta_bcd  : out std_logic;
            fim          : out std_logic;
            db_estado    : out std_logic_vector(3 downto 0) 
        );
    end component;

    component contador_cm_fd is
        port (
            clock     : in  std_logic;
            conta_bcd : in  std_logic;
            zera_bcd  : in  std_logic;
            conta_tick: in  std_logic;
            zera_tick : in  std_logic;
            digito0   : out std_logic_vector(3 downto 0);
            digito1   : out std_logic_vector(3 downto 0);
            digito2   : out std_logic_vector(3 downto 0);
            fim       : out std_logic;
            arredonda : out std_logic;
            tick      : out std_logic
        );
    end component;

    signal s_tick, s_arredonda, s_zera_tick, 
           s_conta_tick, s_zera_bcd, s_conta_bcd : std_logic;

begin
    UC: interface_hcsr04_uc 
        port map (
            clock        => clock,
            reset        => reset,
            pulso        => pulso,
            tick         => s_tick,
            arredonda    => s_arredonda,
            s_zera_tick  => s_zera_tick,
            s_conta_tick => s_conta_tick,
            s_zera_bcd   => s_zera_bcd,
            s_conta_bcd  => s_conta_bcd,
            fim          => pronto,
            db_estado    => db_estado
        );

    FD: interface_hcsr04_fd
        port map ( 
            clock      => clock,
            conta_bcd  => s_conta_bcd,
            zera_bcd   => s_zera_bcd,
            conta_tick => s_conta_tick,
            zera_tick  => s_zera_tick,
            digito0    => digito0,
            digito1    => digito1,
            digito2    => digito2,
            fim        => fim,
            arredonda  => s_arredonda,
            tick       => s_tick
        );

end architecture arch;
