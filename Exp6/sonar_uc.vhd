library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_uc is 
    port ( 
        clock            : in  std_logic;
        reset            : in  std_logic;
        tx_pronto        : in  std_logic;
        fim_conta_digito : in  std_logic;
        ligar            : in  std_logic;
        fim_espera_servo : in  std_logic;
        hcdsr_pronto     : in  std_logic;
        fim_ang          : in  std_logic;
        partida      : out std_logic;
        conta_digito : out std_logic;
        reset_servo  : out std_logic;
        zera_ang     : out std_logic;
        medir        : out std_logic;
        fim_posicao  : out std_logic;
        conta_ang    : out std_logic;
        db_estado    : out std_logic_vector(3 downto 0) 
    );
end interface_hcsr04_uc;

architecture fsm_arch of interface_hcsr04_uc is
    type tipo_estado is (inicial, preparacao, aguarda_servo, 
                         mede_distancia, transmite_digito, espera_digito,
                         fim_digito, proximo_digito, verifica_angulo,
                         conta_angulo, final);
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
    process (ligar, Eatual) 
    begin
      case Eatual is
        when inicial =>         if ligar='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= aguarda_servo;
        when aguarda_servo =>   if fim_espera_servo='1' then Eprox <= mede_distancia;
                                else                         Eprox <= aguarda_servo;
                                end if;
        when mede_distancia =>  if hcdsr_pronto='1' then Eprox <= transmite_digito;
                                else              Eprox <= mede_distancia;
                                end if;
        when transmite_digito => Eprox <= espera_digito;
        when espera_digito =>   if tx_pronto='1' then Eprox <= fim_digito;
                                else                 Eprox <= espera_digito;
        when fim_digito =>      if fim_conta_digito='1' then Eprox <= verifica_angulo;
                                else                 Eprox <= proximo_digito;
                                end if;
        when proximo_digito =>  Eprox <= transmite_digito;
        when verifica_angulo => if fim_ang='0' and ligar='1' then Eprox <= conta_angulo;
                                else                              Eprox <= final;
                                end if;
        when conta_angulo =>    Eprox <= aguarda_servo;
        when final =>           if ligar='1' then Eprox <= preparacao;
                                else              Eprox <= final;
                                end if;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
    with Eatual select 
        partida <= '1' when transmite_digito, '0' when others;
    with Eatual select
        conta_digito <= '1' when proximo_digito, '0' when others;
    with Eatual select
        reset_servo <= '1' when preparacao or conta_angulo, '0' when others;
    with Eatual select
        zera_ang <= '1' when preparacao, '0' when others;
    with Eatual select 
        medir <= '1' when mede_distancia, '0' when others;
    with Eatual select
        fim_posicao <= '1' when verifica_angulo, '0' when others;
    with Eatual select
        conta_ang <= '1' when conta_angulo, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when preparacao, 
                   "0010" when aguarda_servo, 
                   "0011" when mede_distancia,
                   "0100" when transmite_digito, 
                   "0101" when espera_digito, 
                   "0110" when fim_digito,
                   "0111" when proximo_digito, 
                   "1000" when verifica_angulo, 
                   "1001" when conta_angulo,
                   "1010" when final,
                   "1111" when others;

end architecture fsm_arch;
