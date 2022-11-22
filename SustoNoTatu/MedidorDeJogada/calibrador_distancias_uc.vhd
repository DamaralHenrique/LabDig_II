library ieee;
use ieee.std_logic_1164.all;

entity calibrador_distancias_uc is 
    port ( 
        clock                : in  std_logic;
        reset                : in  std_logic;
        calibrar             : in  std_logic;
        fim0                 : in  std_logic;
        fim1                 : in  std_logic;
        fim2                 : in  std_logic;
        calibrar0            : out std_logic;
        calibrar1            : out std_logic;
        calibrar2            : out std_logic;
        registra0            : out std_logic;
        registra1            : out std_logic;
        registra2            : out std_logic;
        reset_calibrador     : out std_logic;
        fim_calibracao       : out std_logic;
        db_estado            : out std_logic_vector(3 downto 0) 
    );
end calibrador_distancias_uc;

architecture fsm_arch of calibrador_distancias_uc is
    type tipo_estado is (inicial, calibra0, registrando0, espera0, calibra1, 
                         registrando1, espera1, calibra2, registrando2, final);
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

    process (calibrar, fim0, fim1, fim2, Eatual) 
    begin
        case Eatual is
            when inicial        => if calibrar='1'                          then Eprox <= calibra0;
                                   else                                          Eprox <= inicial;
                                   end if;
            when calibra0       => if fim0='1'                              then Eprox <= registrando0;
                                   else                                          Eprox <= calibra0;
                                   end if;
            when registrando0   => Eprox <= espera0;
            when espera0        => if    calibrar='1'                       then Eprox <= calibra1;
                                   else                                          Eprox <= espera0;
                                   end if;
            when calibra1       => if fim1='1'                              then Eprox <= registrando1;
                                   else                                          Eprox <= calibra1;
                                   end if;
            when registrando1   => Eprox <= espera1;
            when espera1        => if    calibrar='1'                       then Eprox <= calibra2;
                                   else                                          Eprox <= espera1;
                                   end if;
            when calibra2       => if fim2='1'                              then Eprox <= registrando2;
                                   else                                          Eprox <= calibra2;
                                   end if;
            when registrando2   => Eprox <= final;
            when final          => Eprox <= final;
            when others         => Eprox <= inicial;
        end case;
    end process;

    -- saidas de controle
    with Eatual select
        calibrar0            <= '1' when calibra0,
                                '0' when others;

    with Eatual select
        calibrar1            <= '1' when calibra1,
                                '0' when others;

    with Eatual select
        calibrar2            <= '1' when calibra2,
                                '0' when others;

    with Eatual select
        registra0            <= '1' when registrando0,
                                '0' when others;

    with Eatual select
        registra1            <= '1' when registrando1,
                                '0' when others;

	with Eatual select
        registra2            <= '1' when registrando2,
                                '0' when others;

	with Eatual select
        reset_calibrador     <= '1' when espera0 | espera1 | final,
                                '0' when others;

    with Eatual select
        fim_calibracao       <= '1' when final,
                                '0' when others;

    with Eatual select
        db_estado <= "0001" when inicial, 
                     "0010" when calibra0, 
                     "0011" when registrando0,
                     "0100" when espera0,
                     "0101" when calibra1,
                     "0110" when registrando1,
                     "0111" when espera1,
                     "1000" when calibra2,
                     "1001" when registrando2,
					 "1010" when final,
                     "0000" when others;
end architecture fsm_arch;
