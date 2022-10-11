library IEEE;
use IEEE.std_logic_1164.all;

entity interface_rx is
    port (
        clock             : in std_logic;
        reset             : in std_logic;
        dado_serial       : in std_logic;
		modo 			  : out std_logic;
		db_estado         : out std_logic_vector(3 downto 0);
		db_estado_rx      : out std_logic_vector(3 downto 0);
		db_dado_recebido  : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of interface_rx is

	component interface_rx_uc is 
		port ( 
			clock     : in  std_logic;
			reset     : in  std_logic;
			ativo_p   : in  std_logic;
			ativo_r   : in  std_logic;
			modo      : out std_logic;
			db_estado : out std_logic_vector(3 downto 0) 
		);
	end component;

	component rx_serial_7E2 is
		 port (
			  clock             : in std_logic;
			  reset             : in std_logic;
			  dado_serial       : in std_logic;
			  dado_recebido     : out std_logic_vector(6 downto 0);
			  paridade_recebida : out std_logic;
			  tem_dado          : out std_logic;
			  paridade_ok       : out std_logic;
			  pronto_rx         : out std_logic;
			  db_dado_serial    : out std_logic;
			  db_estado         : out std_logic_vector(3 downto 0)
		 );
	end component;
	
	component comparador_7 is
		 port (
			  D1    : in std_logic_vector(6 downto 0);
			  D2    : in std_logic_vector(6 downto 0);
			  igual : out std_logic
		 );
	end component;
   

    signal s_dado_recebido: std_logic_vector(6 downto 0);
	signal s_ativo_p, s_ativo_r: std_logic;

begin

	UC: interface_rx_uc 
		port map ( 
			clock     => clock,
			reset     => reset,
			ativo_p   => s_ativo_p,
			ativo_r   => s_ativo_r,
			modo      => modo,
			db_estado => db_estado 
		);

    RX: rx_serial_7E2
		 port map (
			  clock             => clock,
			  reset             => reset,
			  dado_serial       => dado_serial,
			  dado_recebido     => s_dado_recebido,
			  paridade_recebida => open,
			  tem_dado          => open,
			  paridade_ok       => open,
			  pronto_rx         => open,
			  db_dado_serial    => open,
			  db_estado         => open
		 );
		 
	COMPARADOR_p: comparador_7
		 port map(
			  D1    => "1110000", -- p em Ascii
			  D2    => s_dado_recebido,
			  igual => s_ativo_p
		 );
		 
	COMPARADOR_r: comparador_7
		 port map(
			  D1    => "1110010", -- r em Ascii
			  D2    => s_dado_recebido,
			  igual => s_ativo_r
		 );

	db_dado_recebido <= s_dado_recebido;
		 
end architecture rtl;
