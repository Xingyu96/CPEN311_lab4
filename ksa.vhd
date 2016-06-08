library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR : out std_logic_vector(9 downto 0);  -- red lights
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0));
end ksa;

architecture rtl of ksa is
   --seven segment component
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut  : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn 	: IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;
	 
	 ---------------BEGIN LAB 4 COMPONENTS CODE--------------
	 
	 --s_memory component
	COMPONENT s_memory IS
	 PORT
	 (
	 	address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	 	clock		: IN STD_LOGIC  := '1';
	 	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	 	wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	 );
	END COMPONENT;
	
	
	--Counter to populate/initialize memory with values 0 - 255
	COMPONENT MemoryPopulateCounter IS
	PORT
	(
		clk	: IN STD_LOGIC;
		start	: IN STD_LOGIC;
		wren	: OUT STD_LOGIC;
		count	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		finish: OUT STD_LOGIC
	);
	END COMPONENT;
    
	---------------END LAB 4 COMPONENTS CODE--------------
	
    -- clock and reset signals  
	 signal clk_50, reset_n : std_logic;
	
	---------------BEGIN LAB 4 SIGNALS CODE--------------
	
	--signals to populate memory
	signal write_enable : std_logic;
	signal write_address : std_logic_vector (7 downto 0);
	signal mem_out : std_logic_vector (7 downto 0);
	signal write_finish : std_logic;
	
	--------------END LAB4 SIGNALS CODE-----------------

begin
    --set clk and reset_n 
    clk_50 <= CLOCK_50;
    reset_n <= KEY(3); 
	
	 ---------------LAB 4 CODE--------------
	 
	 --instantiate memory
	 Memory				: s_memory PORT MAP (address => write_address, 
																				clock => clk_50, 
																				data => write_address, 
																				wren => write_enable,
																				q => mem_out);
	--instantiate memoryPopulateCounter
	Counter		: MemoryPopulateCounter PORT MAP (clk => clk_50, 
																	start => KEY(0),
																	count => write_address,
																	wren => write_enable,
																	finish => write_finish);
	 
	 
end RTL;


