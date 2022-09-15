library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_fd is
    port (
        clock      : in  std_logic;
        zera       : in  std_logic;
        pulso      : in  std_logic;
        gera       : in  std_logic;
        registra   : in  std_logic;
        distancia  : out std_logic_vector(11 downto 0);
        fim_medida : out std_logic;
        trigger    : out std_logic
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


    -- signal s_dados: std_logic_vector(9 downto 0);



begin

    CONTADOR_BITS: contador_bcd_3digitos
    port map ( 
        clock   => clock;
        zera    => reset;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );

    ANALISA_MODULO_DE_ENTRADA: analisa_m
        generic map (
            M => 50;  
            N => 6 
        );
        port map (
            valor            : in  std_logic_vector (N-1 downto 0);
            zero             : out std_logic;
            meio             : out std_logic;
            fim              : out std_logic;
            metade_superior  : out std_logic
        );

    GERADOR_DE_PULSO: gerador_pulso
        generic map (
            largura => 25
        );
        port map (
            clock  => clock;
            reset  => reset;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
        );
    
    
    
    
    -- paridade_recebida <= s_dados(7);
    -- dados <= s_dados(7 downto 0);

end architecture rtl;