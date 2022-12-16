library IEEE;
use IEEE.std_logic_1164.all;

entity unidade_controle is
    port (
        clock       : in std_logic;
        reset       : in std_logic;
        dado_serial : in std_logic;
        tick        : in std_logic;
        fim         : in std_logic;
        limpaRP     : out std_logic;
        zeraC       : out std_logic;
        carregaRDS  : out std_logic;
        deslocaRDS  : out std_logic;
        contaC      : out std_logic;
        registraRP  : out std_logic;
        pronto      : out std_logic;
        tem_dado    : out std_logic;
        db_estado   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of unidade_controle is
    -- Declaração dos estados
    type t_estado is (inicial,
                      preparacao,
                      espera,
                      recepcao,
                      armazenamento,
                      final,
                      dado_presente);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset) -- Processo sensível à mudança do clock e reset
    begin
        if reset='1' then -- Reset possui preferência sobre o clock e é ativo alto
            Eatual <= inicial;
        elsif clock'event and clock = '1' then -- Ocorre na borda de subida do clock
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    -- Aqui foram adicionadas as transicoes entre os novos estados
    Eprox <=
    -- Transições de origem nos estados gerais
        inicial       when Eatual=inicial       and dado_serial='1'      else
        preparacao    when Eatual=inicial       and dado_serial='0'      else
        espera        when Eatual=preparacao                             else
        espera        when Eatual=espera        and tick='0' and fim='0' else
        armazenamento when Eatual=espera        and tick='0' and fim='1' else
        recepcao      when Eatual=espera        and tick='1'             else
        espera        when Eatual=recepcao                               else
        final         when Eatual=armazenamento                          else
        dado_presente when Eatual=final                                  else
        dado_presente when Eatual=dado_presente and dado_serial='1'      else
        preparacao    when Eatual=dado_presente and dado_serial='0'      else
        inicial;-- Estado padrão

    -- logica de saída (maquina de Moore)
    -- As saídas correspondentes recebem 1 nos estados declarados, e 0 caso contrário
    with Eatual select
        limpaRP     <= '1' when preparacao,
                    '0' when others;

    with Eatual select
        zeraC     <= '1' when preparacao,
                    '0' when others;

    with Eatual select
        carregaRDS     <= '1' when preparacao,
                    '0' when others;

    with Eatual select
        deslocaRDS     <= '1' when recepcao,
                    '0' when others;

    with Eatual select
        contaC     <= '1' when recepcao,
                    '0' when others;

    with Eatual select    
        registraRP     <= '1' when armazenamento,
                    '0' when others;

    with Eatual select
        pronto     <= '1' when final,
                    '0' when others;

    with Eatual select
        tem_dado     <= '1' when dado_presente,
                    '0' when others;

    -- saida de depuracao (db_estado)
    -- Adicao da saida para o estado de "esperaJogada"
    with Eatual select
        db_estado <= "0000" when inicial,       -- 00
                     "0010" when preparacao,    -- 02
                     "0100" when espera,        -- 04
                     "0110" when recepcao,      -- 06
                     "1000" when armazenamento, -- 08
                     "1010" when final,         -- 0A
                     "1100" when others;        -- 0C (dado_presente)

end architecture rtl;
