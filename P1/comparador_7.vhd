library IEEE;
use IEEE.std_logic_1164.all;

entity comparador_7 is
    port (
        D1    : in std_logic_vector(6 downto 0);
		  D2    : in std_logic_vector(6 downto 0);
		  igual : out std_logic
    );
end entity;

architecture rtl of comparador_7 is

begin

    igual <= not ((D1(0) xor D2(0)) or
						(D1(1) xor D2(1)) or
						(D1(2) xor D2(2)) or
						(D1(3) xor D2(3)) or
						(D1(4) xor D2(4)) or
						(D1(5) xor D2(5)) or
						(D1(6) xor D2(6)));

end architecture rtl;
