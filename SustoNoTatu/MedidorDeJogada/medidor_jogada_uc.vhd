--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_uc.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : unidade de controle do circuito de interface com
--             sensor de distancia
--             
--             implementa arredondamento da medida
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     03/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity medidor_jogada_uc is 
    port ( 
        clock            : in  std_logic;
        reset            : in  std_logic;
        inicia           : in  std_logic;
        pronto_hcsr04_1  : in  std_logic;
        pronto_hcsr04_2  : in  std_logic;
        fim_espera       : in  std_logic;
        fim_de_jogo      : in  std_logic;
        zera_medida     : out std_logic;
        zera_espera     : out std_logic;
        conta_espera    : out std_logic;
        medir           : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0) 
    );
end medidor_jogada_uc;

architecture fsm_arch of medidor_jogada_uc is
    type tipo_estado is (inicial, medida, espera_medida, espera);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (medir, echo, fim_medida, Eatual) 
    begin
      case Eatual is
        when inicial =>         if inicia='1' then Eprox <= medida;
                                else               Eprox <= inicial;
                                end if;
        when medida =>          Eprox <= espera_medida;
        when espera_medida =>   if pronto_hcsr04_1='1' and pronto_hcsr04_1='1' then Eprox <= espera;
                                else                                                Eprox <= espera_medida;
                                end if;
        when espera =>          if fim_espera='0' and fim_de_jogo='0' then Eprox <= espera;
                                if fim_espera='1' and fim_de_jogo='0' then Eprox <= medida;
                                else                                       Eprox <= inicial;
                                end if;
        when others =>          Eprox <= inicial;
      end case;
    end process;

    -- saidas de controle
    with Eatual select 
        zera_medida <= '1' when preparacao, '0' when others;
    with Eatual select
        medir <= '1' when medida, '0' when others;
    with Eatual select
        zera_espera <= '1' when medida, '0' when others;
    with Eatual select
        conta_espera <= '1' when espera, '0' when others;

    with Eatual select
        db_estado <= "0001" when inicial, 
                     "0010" when medida, 
                     "0011" when espera_medida,
                     "0100" when processa, 
                     "0101" when espera,
                     "0000" when others;

end architecture fsm_arch;
