library ieee;
use ieee.std_logic_1164.all;

entity comparador_distancia is
  port (
    A   : in std_logic_vector(11 downto 0);
    B   : in std_logic_vector(11 downto 0);
    C   : in std_logic_vector(11 downto 0); -- C > B
    btw : out std_logic -- A está entre B e C
  );
end entity comparador_distancia;

architecture dataflow of comparador_distancia is

    component comparador_85 is
        port (
          A : in std_logic_vector(3 downto 0);
          B : in std_logic_vector(3 downto 0);
          i_AGTB : in  std_logic;
          i_ALTB : in  std_logic;
          i_AEQB : in  std_logic;
          o_AGTB : out std_logic;
          o_ALTB : out std_logic;
          o_AEQB : out std_logic
        );
      end component;

      signal AGTB_2, ALTB_2, AEQB_2, AGTB_1, ALTB_1, AEQB_1, AGTB_0, ALTB_0, AEQB_0 : std_logic;
      signal AGTC_2, ALTC_2, AEQC_2, AGTC_1, ALTC_1, AEQC_1, AGTC_0, ALTC_0, AEQC_0 : std_logic;

begin

  COMPARADOR_B_0: comparador_85
    port map (
      A      => A(3 downto 0),
      B      => B(3 downto 0),
      i_AGTB => '0',
      i_ALTB => '0',
      i_AEQB => '0',
      o_AGTB => AGTB_0,
      o_ALTB => ALTB_0,
      o_AEQB => AEQB_0
    );
    
  COMPARADOR_B_1: comparador_85
    port map (
      A      => A(7 downto 4),
      B      => B(7 downto 4),
      i_AGTB => AGTB_0,
      i_ALTB => ALTB_0,
      i_AEQB => AEQB_0,
      o_AGTB => AGTB_1,
      o_ALTB => ALTB_1,
      o_AEQB => AEQB_1
    );
    
  COMPARADOR_B_2: comparador_85
    port map (
      A      => A(11 downto 8),
      B      => B(11 downto 8),
      i_AGTB => AGTB_1,
      i_ALTB => ALTB_1,
      i_AEQB => AEQB_1,
      o_AGTB => AGTB_2,
      o_ALTB => open,
      o_AEQB => AEQB_2
    );

  COMPARADOR_C_2: comparador_85
    port map (
      A      => A(11 downto 8),
      B      => C(11 downto 8),
      i_AGTB => AGTC_1,
      i_ALTB => ALTC_1,
      i_AEQB => AEQC_1,
      o_AGTB => open,
      o_ALTB => ALTC_2,
      o_AEQB => AEQC_2
    );

  COMPARADOR_C_1: comparador_85
    port map (
      A      => A(7 downto 4),
      B      => C(7 downto 4),
      i_AGTB => AGTC_0,
      i_ALTB => ALTC_0,
      i_AEQB => AEQC_0,
      o_AGTB => AGTC_1,
      o_ALTB => ALTC_1,
      o_AEQB => AEQC_1
    );

  COMPARADOR_C_0: comparador_85
    port map (
      A      => A(3 downto 0),
      B      => C(3 downto 0),
      i_AGTB => '0',
      i_ALTB => '0',
      i_AEQB => '0',
      o_AGTB => AGTC_0,
      o_ALTB => ALTC_0,
      o_AEQB => AEQC_0
    );

    -- Para A estar entre B e C (B<C), ele deve ser maior ou igual a B e menor ou igual a C
    btw <= (AGTB_2 or AEQB_2) and (ALTC_2 or AEQC_2);
  
end architecture dataflow;
