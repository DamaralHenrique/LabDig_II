library ieee;
use ieee.std_logic_1164.all;

entity exp5_uc is 
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        mensurar      : in  std_logic;
        hcdsr_pronto  : in  std_logic;
        tx_pronto     : in  std_logic;
        -- Saidas pra interface_hcsr04
        medir         : out std_logic;
        -- Saidas pro tx
        partida       : out std_logic;
        escolha_ascii : out std_logic_vector (1 downto 0);
        -- Saidas pro exp5_trena
        fim           : out std_logic;
        db_estado     : out std_logic_vector(3 downto 0)
    );
end exp5_uc;

architecture fsm_arch of exp5_uc is
    type tipo_estado is (inicial, aguarda_medida, transmite_centena, espera_centena,
                         transmite_dezena, espera_dezena, transmite_unidade, espera_unidade,
								 envia_unidade, transmite_hashtag, espera_hashtag, final);
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
    process (mensurar, hcdsr_pronto, tx_pronto, Eatual) 
    begin
      case Eatual is
        when inicial => if mensurar='1' then Eprox <= aguarda_medida;
                        else                 Eprox <= inicial;
                        end if;

        when aguarda_medida => if hcdsr_pronto='1' then Eprox <= transmite_centena;
                               else                     Eprox <= aguarda_medida;
                               end if;

        when transmite_centena => Eprox <= espera_centena;

        when espera_centena => if tx_pronto='1' then Eprox <= transmite_dezena;
                               else                  Eprox <= espera_centena;
                               end if;

        when transmite_dezena => Eprox <= espera_dezena;

        when espera_dezena => if tx_pronto='1' then Eprox <= transmite_unidade;
                              else                  Eprox <= espera_dezena;
                              end if;

        when transmite_unidade => Eprox <= espera_unidade;

        when espera_unidade => if tx_pronto='1' then Eprox <= transmite_hashtag;
                               else                  Eprox <= espera_unidade;
                               end if;

        when transmite_hashtag => Eprox <= espera_hashtag;

        when espera_hashtag => if tx_pronto='1' then Eprox <= final;
                         else                  Eprox <= espera_hashtag;
                         end if;

        when final =>           Eprox <= inicial;

        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
    with Eatual select
        medir <= '1' when aguarda_medida, 
                 '0' when others;
    with Eatual select 
        partida <= '1' when transmite_centena | transmite_dezena | transmite_unidade | transmite_hashtag, 
                   '0' when others;
    with Eatual select
        escolha_ascii <= "11" when transmite_centena | espera_centena, -- Centena
                         "10" when transmite_dezena | espera_dezena, -- Dezena
                         "01" when transmite_unidade | espera_unidade, -- Unidade
                         "00" when others; -- #
    with Eatual select
        fim <= '1' when final, 
               '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when aguarda_medida, 
                   "0010" when transmite_centena, 
                   "0011" when espera_centena,
                   "0100" when transmite_dezena, 
                   "0101" when espera_dezena, 
                   "0110" when transmite_unidade,
                   "0111" when envia_unidade,
                   "1000" when transmite_hashtag,
                   "1001" when espera_hashtag,
                   "1111" when final, 
                   "1110" when others;

end architecture fsm_arch;
