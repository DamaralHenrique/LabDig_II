library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_uc is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        fim_medida : in  std_logic;
        echo       : in  std_logic;
        db_estado  : out std_logic_vector(3 downto 0);
        gera       : out std_logic;
        pronto     : out std_logic;
        registra   : out std_logic;
        zera       : out std_logic
    );
end entity;

architecture rtl of interface_hcsr04_uc is
    -- Declaração dos estados
    type t_estado is (inicial,
                      preparacao,
                      gatilho,
                      pulso,
                      espera,
                      medida,
                      fim);
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
        inicial    when Eatual=inicial    and medir='0'       else
        preparacao when Eatual=inicial    and medir='1'       else
        gatilho    when Eatual=preparacao                     else
        gatilho    when Eatual=gatilho    and fim_gatilho='0' else
        pulso      when Eatual=gatilho    and fim_gatilho='1' else
        pulso      when Eatual=pulso      and fim_pulso='0'   else
        espera     when Eatual=pulso      and fim_pulso='1'   else
        espera     when Eatual=espera     and echo='0'        else
        medida     when Eatual=espera     and echo='1'        else
        medida     when Eatual=medida     and echo='1'        else
        fim        when Eatual=medida     and echo='0'        else
        fim        when Eatual=fim        and medir='0'       else
        preparacao when Eatual=fim        and medir='1'       else
        inicial;-- Estado padrão

    -- logica de saída (maquina de Moore)
    -- As saídas correspondentes recebem 1 nos estados declarados, e 0 caso contrário
    with Eatual select
        zera      <= '1' when preparacao,
                     '0' when others;

    with Eatual select
        trigger   <= '1' when gatilho,
                     '0' when others;

    with Eatual select
        gera     <= '1' when pulso,
                    '0' when others;

    with Eatual select
        registra <= '1' when medida,
                    '0' when others;

    with Eatual select
        pronto   <= '1' when fim,
                    '0' when others;


    -- saida de depuracao (db_estado)
    -- Adicao da saida para o estado de "esperaJogada"
    with Eatual select
        db_estado <= "0000" when inicial,    -- 00
                     "0010" when preparacao, -- 02
                     "0100" when gatilho,    -- 04
                     "0110" when pulso,      -- 06
                     "1000" when espera,     -- 08
                     "1010" when medida,     -- 0A
                     "1100" when others;     -- 0C (fim)

end architecture rtl;
