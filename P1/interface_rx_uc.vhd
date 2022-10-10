library ieee;
use ieee.std_logic_1164.all;

entity interface_rx_uc is 
    port ( 
        clock     : in  std_logic;
        reset     : in  std_logic;
        ativo_p   : in  std_logic;
        ativo_r   : in  std_logic;
        modo      : out std_logic;
        db_estado : out std_logic_vector(3 downto 0) 
    );
end interface_rx_uc;

architecture fsm_arch of interface_rx_uc is
    type tipo_estado is (desativo, ativo);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= desativo;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (ativo_p, ativo_r) 
    begin
      case Eatual is
        when desativo => if ativo_p='1' then Eprox <= ativo;
                         else              Eprox <= desativo;
                         end if;
        when ativo =>    if ativo_r='1' then Eprox <= desativo;
                         else                Eprox <= ativo;
                         end if;
      end case;
    end process;

    -- saidas de controle
    with Eatual select 
        modo <= '1' when ativo, 
                '0' when others;

  with Eatual select
      db_estado <= "0000" when desativo, 
                   "0001" when others;
end architecture fsm_arch;
