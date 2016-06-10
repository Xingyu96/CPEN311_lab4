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
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;
	
	COMPONENT Lab4_top IS 
	PORT 
		(
		    CLOCK_50            : in  std_logic;  -- Clock pin
			KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
			SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
			LEDR : out std_logic_vector(9 downto 0);  -- red lights
			HEX0 : out std_logic_vector(6 downto 0);
			HEX1 : out std_logic_vector(6 downto 0);
			HEX2 : out std_logic_vector(6 downto 0);
			HEX3 : out std_logic_vector(6 downto 0);
			HEX4 : out std_logic_vector(6 downto 0);
			HEX5 : out std_logic_vector(6 downto 0)
		);
	END COMPONENT; 
   
    -- clock and reset signals  
	 signal clk, reset_n : std_logic;										

begin

    clk <= CLOCK_50;
    reset_n <= KEY(3);

end RTL;

architecture top_level of ksa is 
	COMPONENT Lab4_top IS 
	PORT 
		(
		    CLOCK_50            : in  std_logic;  -- Clock pin
			KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
			SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
			LEDR : out std_logic_vector(9 downto 0);  -- red lights
			HEX0 : out std_logic_vector(6 downto 0);
			HEX1 : out std_logic_vector(6 downto 0);
			HEX2 : out std_logic_vector(6 downto 0);
			HEX3 : out std_logic_vector(6 downto 0);
			HEX4 : out std_logic_vector(6 downto 0);
			HEX5 : out std_logic_vector(6 downto 0)
		);
	END COMPONENT; 
	
begin 
	
	top_level_module : Lab4_top PORT MAP (
								 CLOCK_50 => CLOCK_50,
								 KEY => KEY,	
								 SW => SW, 
								 LEDR => LEDR, 
								 HEX0 => HEX0,
								 HEX1 => HEX1, 
								 HEX2 => HEX2, 
								 HEX3 => HEX3, 
								 HEX4 => HEX4, 
								 HEX5 => HEX5 
								 ); 
	
end top_level; 
		


