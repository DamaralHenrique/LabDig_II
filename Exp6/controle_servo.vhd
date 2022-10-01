-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : circuito_pwm.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
-------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL RTL gera saída digital com modulacao pwm
--
-- parametros de configuracao da saida pwm: CONTAGEM_MAXIMA e largura_pwm
-- (considerando clock de 50MHz ou periodo de 20ns)
--
-- CONTAGEM_MAXIMA=1250 gera um sinal periodo de 4 KHz (25us)
-- entrada LARGURA controla o tempo de pulso em 1:
-- 00=0 (saida nula), 01=pulso de 1us, 10=pulso de 10us, 11=pulso de 20us
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      posicao  : in  std_logic_vector(1 downto 0);  
      controle : out std_logic;
		db_posicao: out  std_logic_vector(1 downto 0);  
      db_reset  : out std_logic
  );
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 50Hz 
                                               -- ou periodo de 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset,s_posicao)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      controle    <= '0';
      posicao_pwm <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_pwm) then
          controle  <= '1';
        else
          controle  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          posicao_pwm <= s_posicao;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao is
      when "01" =>    s_posicao <=   50000;  -- pulso de  1 ms
      when "10" =>    s_posicao <=   75000;  -- pulso de 1.5 ms
      when "11" =>    s_posicao <=  100000;  -- pulso de 2 ms
      when others =>  s_posicao <=       0;  -- nulo   saida 0
    end case;
  end process;
  
  db_posicao <= posicao;
  db_reset <= reset;
  
end rtl;