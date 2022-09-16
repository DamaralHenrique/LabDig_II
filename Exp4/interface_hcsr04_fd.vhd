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


    -- registrador





    -- signal s_dados: std_logic_vector(9 downto 0);
    signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);



begin

    CONTADOR_CM: contador_cm
        generic map (
            R => 1,
            N => 1
        );
        port (
            clock   =>
            reset   =>
            pulso   =>
            digito0 =>
            digito1 =>
            digito2 =>
            pronto  =>
        );

    GERADOR_DE_PULSO: gerador_pulso
        generic map (
            largura => 25
        );
        port map (
            clock  => clock,
            reset  => reset,
            gera   => gera,
            para   => open, --???
            pulso  => trigger,
            pronto => pronto
        );
    

        -- registrador


    distancia <= s_digito2 & s_digito1 & s_digito0;

end architecture rtl;
