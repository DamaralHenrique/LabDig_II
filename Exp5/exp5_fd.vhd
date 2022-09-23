library IEEE;
use IEEE.std_logic_1164.all;

entity exp5_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        -- Sinais pra interface_hcsr04
        partida      : in  std_logic;
        dados_ascii  : in  std_logic_vector (6 downto 0);
        -- Sinais pro tx_serial_7E2
        medir        : in  std_logic;
        echo         : in  std_logic;
        -- Sinais de saida
        medida       : out std_logic_vector(11 downto 0);
        hcdsr_pronto : out std_logic;
        tx_pronto    : out std_logic
    );
end entity;

architecture rtl of exp5_fd is
    component interface_hcsr04 is
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
    end component interface_hcsr04;
    
    component tx_serial_7E2 is
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            partida       : in  std_logic;
            dados_ascii   : in  std_logic_vector (6 downto 0); -- Redução do tamanho da entrada
            saida_serial  : out std_logic;
            pronto        : out std_logic;
            -- Sinais de depuração
            d_tick        : out std_logic;
            d_estado      : out integer
        );
    end component tx_serial_7E2;

begin
    -- TODO: Adicionar instancias dos componentes

end architecture rtl;
