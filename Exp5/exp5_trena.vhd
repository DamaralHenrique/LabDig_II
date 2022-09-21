entity exp5_trena is
    port (
    clock    : in std_logic;
    reset    : in std_logic;
    mensurar : in std_logic;
    echo     : in std_logic;
    trigger      : out std_logic;
    saida_serial : out std_logic;
    medida0      : out std_logic_vector (6 downto 0);
    medida1      : out std_logic_vector (6 downto 0);
    medida2      : out std_logic_vector (6 downto 0);
    pronto       : out std_logic;
    db_estado    : out std_logic_vector (6 downto 0)
    );
   end entity exp5_trena;
   