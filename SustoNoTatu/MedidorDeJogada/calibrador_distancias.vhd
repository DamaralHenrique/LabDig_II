library ieee;
use ieee.std_logic_1164.all;

entity calibrador_distancias is
    port (
        calibrar             : in std_logic;
        medida_calibrada_0_D : out std_logic_vector(11 downto 0);
        medida_calibrada_0_E : out std_logic_vector(11 downto 0);
        medida_calibrada_1_D : out std_logic_vector(11 downto 0);
        medida_calibrada_1_E : out std_logic_vector(11 downto 0);
        medida_calibrada_2_D : out std_logic_vector(11 downto 0);
        medida_calibrada_2_E : out std_logic_vector(11 downto 0);
        fim_calibracao       : out std_logic
    );
end entity calibrador_distancias;

architecture arch of calibrador_distancias is
    component calibrador_distancias_uc is 
        port ( 
            clock                : in  std_logic;
            reset                : in  std_logic;
            calibrar             : in  std_logic;
            fim1                 : in  std_logic;
            fim2                 : in  std_logic;
            fim3                 : in  std_logic;
            medir                : out std_logic;
            registra1            : out std_logic;
            registra2            : out std_logic;
            registra3            : out std_logic;
            reset_calibrador     : out std_logic;
            fim_calibracao       : out std_logic;
            db_estado            : out std_logic_vector(3 downto 0) 
        );
    end component;

    component calibrador_distancias_fd is
        port (
            
        );
    end component;
   
  
end architecture arch;
