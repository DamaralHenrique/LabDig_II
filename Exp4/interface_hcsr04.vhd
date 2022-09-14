library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04 is
    port (
        clock : in std_logic;
        reset : in std_logic;
        medir : in std_logic;
        echo : in std_logic;
        trigger : out std_logic;
        medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
        pronto : out std_logic;
        db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
end entity interface_hcsr04;


architecture rtl of rx_serial_7E2 is




    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;




begin

    UC: unidade_controle 
        port map (

        );

    FD: fluxo_dados
        port map (

        );

    STATE_HEX: hex7seg
        port map(
            hexa => s_db_estado,
            sseg => db_estado
        );
    
    DATA_HEX1: hex7seg
        port map(
            hexa => s_dados(3 downto 0),
            sseg => dado_recebido0
        );

    DATA_HEX2: hex7seg
        port map(
            hexa => s_hexa_in,
            sseg => dado_recebido1
        );


end architecture rtl;