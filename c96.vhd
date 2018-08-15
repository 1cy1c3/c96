-----------------------------------------------------------------------------------------
-- Engineer:      	Rune Krauss
-- Module Name:   	c96
-- Description:   	This memory can store 96 bytes. These bytes can be read or written. 
-- 					With a rising edge, the read or write process begins. This process is 
--					finished after one clock cycle. If a '1' is present at the reset 
--					signal, the entire memory is deleted. All values are still set to '0'. 
--					The bits `re` (read enable) and `we` (write enable) indicate whether 
--					to read or write. The affected address is in `addr`. If you want to 
--					write, the value is in `data_in`. If you want to read, the value is 
--					written to `output`. The value is stored until the next read command. 
--					To allow easy debugging, content can be written from a file 
--					"memory.dat" into memory. The signal `dump` controls the output of the 
--					memory to the file "dump.dat". If an error occurs, *XXXXXXXXXX* is at 
--					the output.
-----------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
LIBRARY std;
USE std.textio.all;

ENTITY c96 IS
  GENERIC (
    MEM_SIZE  : positive := 96;
    ADDR_SIZE : positive := 8;
    DATA_SIZE : positive := 8);
  port (
    clk     : in std_logic;
    init    : in std_logic;
    dump    : in std_logic;
    reset   : in std_logic;
    re      : in std_logic;
    we      : in std_logic;
    addr    : in std_logic_vector(7 downto 0);
    data_in : in std_logic_vector(7 downto 0);
    output  : out std_logic_vector(7 downto 0)
  );
END ENTITY c96;

ARCHITECTURE c96_impl OF c96 IS
  TYPE STORAGE IS array (0 TO MEM_SIZE-1) OF std_logic_vector(DATA_SIZE-1 DOWNTO 0);
  SHARED VARIABLE MEM : STORAGE;

  SIGNAL error        : std_logic := '0';
  SIGNAL addr_int     : integer := 0;
  SIGNAL loc_addr_int : integer := 0;
  SIGNAL loc_data_in  : std_logic_vector (DATA_SIZE-1 DOWNTO 0);
  SIGNAL loc_we       : std_logic := '0';
  SIGNAL loc_re       : std_logic := '0';

BEGIN
  addr_proc : PROCESS(addr)
  BEGIN
    addr_int <= to_integer(unsigned(addr));
  END PROCESS addr_proc;

  clk_proc : PROCESS(clk)
  FILE infile : text;
  VARIABLE inline : line;
  VARIABLE file_addr : std_logic_vector(ADDR_SIZE-1 downto 0);
  VARIABLE file_data : std_logic_vector(DATA_SIZE-1 downto 0);
  VARIABLE in_ops : std_logic_vector(7 downto 0);
  VARIABLE file_addr_int : integer := 0;
  BEGIN
    IF init = '1' AND dump = '0' AND we = '0' AND reset = '0' then
      file_open (infile, "memory.dat", read_mode);
      WHILE NOT endfile(infile) LOOP
        readline (infile, inline);
        read(inline, in_ops);
        FOR i IN ADDR_SIZE-1 DOWNTO 0 LOOP
          file_addr(i) := in_ops(i);
        END LOOP;
        read(inline, in_ops);
        FOR i IN DATA_SIZE-1 DOWNTO 0 LOOP
          file_data(i) := in_ops(i);
        END LOOP;
        file_addr_int := to_integer(unsigned(file_addr));
        IF file_addr_int > -1 AND file_addr_int < (MEM_SIZE-1) THEN
          MEM(file_addr_int) := file_data;
        END IF;
      END LOOP;
      file_close(infile);
    END IF;
    IF dump = '1' AND init = '0' THEN
      file_open(infile, "dump.dat", write_mode);
      FOR i IN 0 TO (MEM_SIZE-1) LOOP
        file_addr := std_logic_vector(to_unsigned(i, file_addr'length));
        file_data := MEM(i);
        write(inline, file_addr);
        write(inline, file_data);
        writeline(infile, inline);
      END LOOP;
      file_close(infile);
    END IF;

    IF rising_edge(clk) THEN
      error <= '0';
      IF re = '1' AND we = '1' THEN
        output <= "XXXXXXXX";
        error <= '1';
      END IF;
      IF reset = '1' AND re = '0' AND we = '0' THEN
        FOR i IN 0 TO (MEM_SIZE-1) loop
          MEM(i) := "00000000";
        END LOOP;
      END IF;
      IF reset = '1' AND (re = '1' OR we = '1') then
        output <= "XXXXXXXX";
        error <= '1';
      END IF;

      loc_data_in <= data_in;
      loc_addr_int <= addr_int;
      loc_re <= re;
      loc_we <= we;

      IF (re = '0' AND we = '1') OR (re = '1' AND we = '0') THEN
        IF addr_int < 0 OR addr_int > MEM_SIZE-1 THEN
          error <= '1';
          output <= "XXXXXXXX";
        END IF;
      END IF;
    END IF;

    IF falling_edge(clk) THEN
      IF loc_we = '1' AND error = '0' AND reset = '0' THEN
        MEM(loc_addr_int) := loc_data_in;
      END IF;
      IF loc_re = '1' AND error = '0' THEN
        output <= MEM(loc_addr_int);
      END IF;
    END IF;
  END PROCESS clk_proc;
END ARCHITECTURE c96_impl;
