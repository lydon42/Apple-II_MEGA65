library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use STD.textio.ALL;

entity spram is

	generic 
	(
		ADDR_WIDTH : natural := 14;
		DATA_WIDTH : natural := 8;
		INIT_FILE  : string  := ""
	);

	port 
	(
		clock     : in  std_logic;
		address   : in  std_logic_vector((ADDR_WIDTH - 1) downto 0) := (others => '0');
		data	  : in  std_logic_vector((DATA_WIDTH - 1) downto 0) := (others => '0');
		wren      : in  std_logic := '0';
		q         : out std_logic_vector((DATA_WIDTH - 1) downto 0)
	);

end spram;

architecture rtl of spram is

	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(0 to 2**ADDR_WIDTH-1) of word_t;

   impure function read_romfile(rom_file_name : in string) return memory_t is
      file     rom_file  : text;
      variable line_v    : line;
      variable rom_v     : memory_t;
   begin
      file_open(rom_file, rom_file_name, read_mode);
      for i in memory_t'range loop
         if not endfile(rom_file) then
            readline(rom_file, line_v);
            hread(line_v, rom_v(i));
         end if;
      end loop;
      return rom_v;
   end function;

	shared variable ram : memory_t := read_romfile("../" & INIT_FILE & ".hex");
	
	signal q0 : std_logic_vector((DATA_WIDTH - 1) downto 0);
	
begin

	q<= q0;

	-- WR Port
	process(clock) begin
		if(rising_edge(clock)) then 
			if(wren = '1') then
				ram(to_integer(unsigned(address))) := data;
			end if;
			q0 <= ram(to_integer(unsigned(address)));
		end if;
	end process;

end rtl;
