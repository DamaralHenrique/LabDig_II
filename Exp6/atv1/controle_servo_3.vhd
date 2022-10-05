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

entity controle_servo_3 is
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
end controle_servo_3;

architecture rtl of controle_servo_3 is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 50Hz 
                                                  -- ou periodo de 20ms
  constant ANGULO_MAXIMO : integer := 180;
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_angle      : integer range 0 to ANGULO_MAXIMO-1;
  signal s_pwm        : std_logic;

begin

  process(clock, reset, s_posicao)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      s_pwm    <= '0';
      posicao_pwm <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_pwm) then
          s_pwm  <= '1';
        else
          s_pwm  <= '0';
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
      when "000"  => s_posicao <=  35000;  -- pulso de   0.7 ms (20°)
      when "001"  => s_posicao <=  45700;  -- pulso de 0.914 ms (40°)
      when "010"  => s_posicao <=  56450;  -- pulso de 1.129 ms (60°)
      when "011"  => s_posicao <=  67150;  -- pulso de 1.343 ms (80°)
      when "100"  => s_posicao <=  77850;  -- pulso de 1.557 ms (100°)
      when "101"  => s_posicao <=  88550;  -- pulso de 1.771 ms (120°)
      when "110"  => s_posicao <=  99300;  -- pulso de 1.986 ms (140°)
      when "111"  => s_posicao <= 110000;  -- pulso de   2.2 ms (160°)
      when others => s_posicao <=      0;  -- nulo (saida 0)
    end case;

    case posicao is
      when "000"  => s_angle <=  20;  -- pulso de   0.7 ms (20°)
      when "001"  => s_angle <=  40;  -- pulso de 0.914 ms (40°)
      when "010"  => s_angle <=  60;  -- pulso de 1.129 ms (60°)
      when "011"  => s_angle <=  80;  -- pulso de 1.343 ms (80°)
      when "100"  => s_angle <= 100;  -- pulso de 1.557 ms (100°)
      when "101"  => s_angle <= 120;  -- pulso de 1.771 ms (120°)
      when "110"  => s_angle <= 140;  -- pulso de 1.986 ms (140°)
      when "111"  => s_angle <= 160;  -- pulso de   2.2 ms (160°)
      when others => s_angle <=   0;  -- nulo (saida 0)
    end case;
  end process;

  pwm   <= s_pwm;
  angle <= std_logic_vector(to_unsigned(s_angle / 100,         4)) &
           std_logic_vector(to_unsigned((s_angle / 10) mod 10, 4)) &
           std_logic_vector(to_unsigned(s_angle mod 10,        4));

  db_posicao <= posicao;
  db_reset <= reset;
  db_pwm <= s_pwm;
  
end rtl;
