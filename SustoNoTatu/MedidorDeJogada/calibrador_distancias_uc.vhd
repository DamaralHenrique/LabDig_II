library ieee;
use ieee.std_logic_1164.all;

entity calibrador_distancias_uc is 
    port ( 
        clock                : in  std_logic;
        reset                : in  std_logic;
        calibrar             : in  std_logic;
        fim1                 : in  std_logic;
        fim2                 : in  std_logic;
        fim3                 : in  std_logic;
        medir                : out std_logic;
        registra1            : out std_logic;
        registra2            : out std_logic;
        registra3            : out std_logic;
        reset_calibrador     : out std_logic;
        fim_calibracao       : out std_logic;
        db_estado            : out std_logic_vector(3 downto 0) 
    );
end calibrador_distancias_uc;

architecture fsm_arch of calibrador_distancias_uc is
    type tipo_estado is (inicial, calibra1, registra1, espera1, calibra2, 
                         registra2, espera2, calibra3, registra3, final);
    signal Eatual, Eprox : tipo_estado;
begin

    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    process (inicia, calibrar, fim1, fim2, fim3, Eatual) 
    begin
        case Eatual is
            when inicial        => if calibrar='1'                          then Eprox <= calibra1;
                                   else                                          Eprox <= inicial;
                                   end if;
            when calibra1       => if fim1='1'                              then Eprox <= registra1;
                                   else                                          Eprox <= calibra1;
                                   end if;
            when registra1      => Eprox <= espera1;
            when espera1        => if    calibrar='1'   then Eprox <= calibra2;
                                   else                      Eprox <= espera1;
                                   end if;
            when calibra2       => if fim2='1'                              then Eprox <= registra2;
                                   else                                          Eprox <= calibra2;
                                   end if;
            when registra2      => Eprox <= espera2;
            when espera2        => if    calibrar='1'   then Eprox <= calibra3;
                                   else                      Eprox <= espera2;
                                   end if;
            when calibra3       => if fim3='1'                              then Eprox <= registra3;
                                   else                                          Eprox <= calibra3;
                                   end if;
            when registra3      => Eprox <= final;
            when final          => Eprox <= final;
            when others         => Eprox <= inicial;
        end case;
    end process;

    -- saidas de controle
    with Eatual select
        medir                <= '1' when calibra1 | calibrar2 | calibrar3,
                                '0' when others;

    with Eatual select
        registra1            <= '1' when registra1,
                                '0' when others;

    with Eatual select
        registra2            <= '1' when registra2,
                                '0' when others;

	with Eatual select
        registra3            <= '1' when registra3,
                                '0' when others;

	with Eatual select
        reset_calibrador     <= '1' when espera1 | espera2 | final,
                                '0' when others;

    with Eatual select
        fim_calibracao       <= '1' when final,
                                '0' when others;

    with Eatual select
        db_estado <= "0001" when inicial, 
                     "0010" when calibra1, 
                     "0011" when registra1,
                     "0100" when espera1,
                     "0101" when calibra2,
                     "0110" when registra2,
                     "0111" when espera2,
                     "1000" when calibra3,
                     "1001" when registra3,
					 "1010" when final,
                     "0000" when others;
end architecture fsm_arch;
