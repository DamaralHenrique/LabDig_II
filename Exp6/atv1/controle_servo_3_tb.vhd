-- controle_servo_3_tb
--
library ieee;
use ieee.std_logic_1164.all;

entity controle_servo_3_tb is
end entity;

architecture tb of controle_servo_3_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component controle_servo_3 is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        posicao    : in  std_logic_vector(2 downto 0);  
        pwm        : out std_logic;
        db_reset   : out std_logic;
        db_pwm     : out std_logic;
        db_posicao : out std_logic_vector(2 downto 0);
        angle      : out std_logic_vector(11 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in       : std_logic := '0';
  signal reset_in       : std_logic := '0';
  signal posicao_in     : std_logic_vector (2 downto 0) := "000";
  signal pwm_out        : std_logic := '0';
  signal db_reset_out   : std_logic := '0';
  signal db_pwm_out     : std_logic := '0';
  signal db_posicao_out : std_logic_vector (2 downto 0) := "000";
  signal db_angle       : std_logic_vector (11 downto 0) := "000000000000";


  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut: controle_servo_3
        port map ( 
            clock      => clock_in,
            reset      => reset_in,
            posicao    => posicao_in,
            pwm        => pwm_out,
            db_reset   => db_reset_out,
            db_pwm     => db_pwm_out,
            db_posicao => db_posicao_out,
            angle      => db_angle
        );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 ms. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- posicao=000
    posicao_in <= "000"; -- largura de pulso de 0,7 ms
    wait for 200 ms;

    -- posicao=001
    posicao_in <= "001"; -- largura de pulso de 0,914 ms
    wait for 200 ms;

    -- posicao=010
    posicao_in <= "010"; -- largura de pulso de 1,129 ms
    wait for 200 ms;

    -- posicao=011
    posicao_in <= "011"; -- largura de pulso de 1,343 ms
    wait for 200 ms;

    -- posicao=100
    posicao_in <= "100"; -- largura de pulso de 1,557 ms
    wait for 200 ms;

    -- posicao=101
    posicao_in <= "101"; -- largura de pulso de 1,771 ms
    wait for 200 ms;

    -- posicao=110
    posicao_in <= "110"; -- largura de pulso de 1,986 ms
    wait for 200 ms;

    -- posicao=111
    posicao_in <= "111"; -- largura de pulso de 2,2 ms
    wait for 200 ms;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
