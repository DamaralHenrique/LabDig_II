library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_uc is 
    port ( 
        clock        : in  std_logic;
        reset        : in  std_logic;
        pulso        : in  std_logic; -- echo
        tick         : in  std_logic;
        arredonda    : in  std_logic;
        s_zera_tick  : out std_logic;
        s_conta_tick : out std_logic;
        s_zera_bcd   : out std_logic;
        s_conta_bcd  : out std_logic;
        fim          : out std_logic;
        db_estado    : out std_logic_vector(3 downto 0) 
    );
end contador_cm_uc;

architecture fsm_arch of contador_cm_uc is
    type tipo_estado is (inicial, conta_tick, conta_bcd, verifica_arredonda, final);
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
    process (pulso, tick, arredonda, Eatual) 
    begin
      case Eatual is
        when inicial =>             if pulso='1' then Eprox <= conta_tick;
                                    else              Eprox <= inicial;
                                    end if;
        when conta_tick =>          if pulso='1' and tick='1' then Eprox <= conta_bcd;
                                    elsif pulso='0' then           Eprox <= verifica_arredonda;
                                    else                           Eprox <= conta_tick;
                                    end if;
        when conta_bcd =>           if pulso='0' then Eprox <= final;
                                    else              Eprox <= conta_tick;
                                    end if;
        when verifica_arredonda =>  if arredonda='0' then Eprox <= final;
                                    else                  Eprox <= conta_bcd;
                                    end if;
        when final =>               Eprox <= inicial;
        when others =>              Eprox <= inicial;
      end case;
    end process;

    -- saidas de controle
    with Eatual select 
        s_zera_tick <= '1' when inicial | conta_bcd, 
                       '0' when others;
    with Eatual select
        s_conta_tick <= '1' when conta_tick, 
                        '0' when others;
    with Eatual select
        s_zera_bcd <= '1' when inicial, 
                      '0' when others;
    with Eatual select
        s_conta_bcd <= '1' when conta_bcd, 
                       '0' when others;
    with Eatual select
        fim <= '1' when final, 
               '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when conta_tick, 
                   "0010" when conta_bcd, 
                   "0011" when verifica_arredonda,
                   "0100" when final, 
                   "0101" when others;
end architecture fsm_arch;
