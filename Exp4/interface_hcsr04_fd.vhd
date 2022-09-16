library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_fd is
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
end entity;

architecture rtl of interface_hcsr04_fd is

    component contador_cm is
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
            pronto  : out std_logic
        );
      end component contador_cm;

    component gerador_pulso is
        generic (
            largura: integer:= 25
        );
        port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
        );
    end component gerador_pulso;

    component registrador_n is
        generic (
           constant N: integer := 11
        );
        port (
           clock  : in  std_logic;
           clear  : in  std_logic;
           enable : in  std_logic;
           D      : in  std_logic_vector (N-1 downto 0);
           Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component registrador_n;


    signal s_D: std_logic_vector(11 downto 0);
    signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);

begin

    CONTADOR_CM: contador_cm
        generic map (
            R => 1, -- dummy
            N => 1  -- dummy
        );
        port (
            clock   => clock,
            reset   => zera,
            pulso   => pulso,
            digito0 => s_digito0,
            digito1 => s_digito1,
            digito2 => s_digito2,
            pronto  => fim_medida
        );

    GERADOR_DE_PULSO: gerador_pulso
        generic map (
            largura => 10 -- dummy
        );
        port map (
            clock  => clock,
            reset  => zera,
            gera   => gera,
            para   => '0',
            pulso  => trigger,
            pronto => open
        );
    
        REGISTRADOR: registrador_n 
        generic map (
            N => 10
        ) 
        port map (
            clock  => clock, 
            clear  => zera, 
            enable => registra, 
            D      => s_D, 
            Q      => distancia
        );

    s_D <= s_digito2 & s_digito1 & s_digito0;

end architecture rtl;
