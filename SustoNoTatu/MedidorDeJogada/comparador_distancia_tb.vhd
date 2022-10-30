library ieee;
use ieee.std_logic_1164.all;

entity comparador_distancia_tb is
end entity;

architecture tb of comparador_distancia_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component comparador_distancia is
    port (
      A   : in std_logic_vector(11 downto 0);
      B   : in std_logic_vector(11 downto 0);
      C   : in std_logic_vector(11 downto 0); -- C > B
      btw : out std_logic -- A está entre B e C
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal A_in    : std_logic_vector (11 downto 0)  := "000000000000";
  signal B_in    : std_logic_vector (11 downto 0)  := "000000000000";
  signal C_in    : std_logic_vector (11 downto 0)  := "000000000000";
  signal btw_out : std_logic := '0';

  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
  
  -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

begin
  
  -- Conecta DUT (Device Under Test)
  dut: comparador_distancia
    port map (
      A   => A_in,
      B   => B_in,
      C   => C_in,
      btw => btw_out
    );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';

    A_in <= "0001"&"0000"&"0000"; -- 100
    B_in <= "0001"&"0010"&"0000"; -- 120
    C_in <= "0010"&"0010"&"0000"; -- 220

    wait for 100ms;

    A_in <= "0001"&"0100"&"0000"; -- 140

    wait for 100ms;

    A_in <= "0010"&"0100"&"0000"; -- 140

    wait for 100ms;

    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
