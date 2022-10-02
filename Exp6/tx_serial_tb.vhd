------------------------------------------------------------------
-- Arquivo   : tx_serial_tb.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > modelo de testbench para simulacao do circuito
--             > de transmissao serial assincrona
--             > 
--             > simula a entidade fornecida tx_serial_7E2
--             > 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_tb is
end entity;

architecture tb of tx_serial_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component tx_serial_7E2
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        partida       : in  std_logic;
        dados_ascii   : in  std_logic_vector (6 downto 0);
        saida_serial  : out std_logic;
        pronto        : out std_logic;
        -- Sinais de depuração
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in         : std_logic := '0';
  signal reset_in         : std_logic := '0';
  signal partida_in       : std_logic := '0';
  signal dados_ascii_7_in : std_logic_vector (6 downto 0) := "0000000";
  signal saida_serial_out : std_logic := '1';
  signal pronto_out       : std_logic := '0';
  signal db_partida_in    : std_logic := '0';
  signal db_saida_serial_out : std_logic := '1';
  signal db_estado_out    : std_logic_vector (3 downto 0) := "0000";

  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;    -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: tx_serial_7E2
       port map
       ( 
           clock        => clock_in,
           reset        => reset_in,
           partida      => partida_in,
           dados_ascii  => dados_ascii_7_in,
           saida_serial => saida_serial_out,
           pronto       => pronto_out,
           db_partida   => db_partida_in,
           db_saida_serial => db_saida_serial_out,
           db_estado    => db_estado_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso largo de reset com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_7_in <= "0110101"; -- x35 = '5'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 1*clockPeriod; -- pulso partida com 25 periodo de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until pronto_out='1';
	
	---- final do caso de teste 1

    -- intervalo entre casos de teste
    wait for 500*clockPeriod;
	
    ----
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso largo de reset com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_7_in <= "0110110"; -- '6'	0110110
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 1*clockPeriod; -- pulso partida com 1 periodo de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	  wait until pronto_out='1';
    ----

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
