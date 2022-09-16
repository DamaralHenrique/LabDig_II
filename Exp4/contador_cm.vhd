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
        pronto  : out std_logic
    );
  end entity;

  architecture rtl of interface_hcsr04_fd is

    component contador_bcd_3digitos is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
    end component contador_bcd_3digitos;

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic
    );
    end component;

    component analisa_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            valor            : in  std_logic_vector (N-1 downto 0);
            zero             : out std_logic;
            meio             : out std_logic;
            fim              : out std_logic;
            metade_superior  : out std_logic
        );
    end component analisa_m;




    -- signal s_dados: std_logic_vector(9 downto 0);
    signal s_digito : std_logic_vector(11 downto 0);



begin

    CONTADOR_BCD: contador_bcd_3digitos
    port map ( 
        clock   => clock,
        zera    => zera,
        conta   => pulso, -- Valor do echo
        digito0 => s_digito0,
        digito1 => s_digito1,
        digito2 => s_digito2,
        fim     => open
    );

    CONTADOR_M: contador_m 
        generic map (
            M => 13, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => s_digito, 
            fim   => fim
        );
    
    ANALISA_MODULO_DE_ENTRADA: analisa_m
        generic map (
            M => 50;  
            N => 6 
        );
        port map (
            valor            => s_digito,
            zero             => open,
            meio             => open,
            fim              => open,
            metade_superior  => arredonda
        );


end architecture rtl;
