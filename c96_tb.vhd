LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
LIBRARY std;
USE std.textio.all;

ENTITY c96_tb IS
  GENERIC (
    MEM_SIZE  : positive := 96;
    ADDR_SIZE : positive := 8;
    DATA_SIZE : positive := 8
  );
END ENTITY c96_tb;

ARCHITECTURE behavioral OF c96_tb IS
  COMPONENT c96
    port(
      clk     : IN std_logic;
      init    : IN std_logic;
      dump    : IN std_logic;
      reset   : IN std_logic;
      re      : IN std_logic;
      we      : IN std_logic;
      addr    : IN std_logic_vector(7 downto 0);
      data_in : IN std_logic_vector(7 downto 0);
      output  : OUT std_logic_vector(7 downto 0)
    );
  END COMPONENT c96;
  SIGNAL clk      : std_logic := '0';
  SIGNAL init     : std_logic := '0';
  SIGNAL dump     : std_logic := '0';
  SIGNAL reset    : std_logic := '0';
  SIGNAL re       : std_logic := '0';
  SIGNAL we       : std_logic := '0';
  SIGNAL addr     : std_logic_vector(7 downto 0) := (others => '0');
  SIGNAL data_in  : std_logic_vector(7 downto 0) := (others => '0');
  SIGNAL output   : std_logic_vector(7 downto 0);

  CONSTANT clk_period : time := 10 ps;
  begin
    uut: c96 PORT MAP (
      clk => clk,
      init => init,
      dump => dump,
      reset => reset,
      re => re,
      we => we,
      addr => addr,
      data_in => data_in,
      output => output
    );

  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS clk_process;

  stim_proc : PROCESS
  FILE infile       : text;
  FILE outfile      : text;
  VARIABLE inline   : line;
  VARIABLE outline  : line;

  VARIABLE infile_addr  : std_logic_vector(ADDR_SIZE-1 DOWNTO 0);
  VARIABLE infile_data  : std_logic_vector(DATA_SIZE-1 DOWNTO 0);
  VARIABLE outfile_addr : std_logic_vector(ADDR_SIZE-1 DOWNTO 0);
  VARIABLE outfile_data : std_logic_vector(DATA_SIZE-1 DOWNTO 0);
  VARIABLE in_ops       : std_logic_vector(7 DOWNTO 0);
  VARIABLE out_ops      : std_logic_vector(7 DOWNTO 0);

  BEGIN
    addr <= "00000010";
    data_in <= "11111111";
    re <= '0';
    we <= '1';
    WAIT FOR clk_period;

    addr <= "00000010";
    re <= '1';
    we <= '0';
    WAIT FOR clk_period;
    WAIT FOR clk_period/9;
    ASSERT output = "11111111";

    reset <= '1';
    re <= '0';
    we <= '0';
    WAIT FOR clk_period;

    reset <= '0';
    re <= '1';
    addr <= "00000010";
    WAIT FOR clk_period;
    ASSERT output = "00000000";

    addr <= "00001010";
    WAIT FOR clk_period;
    ASSERT output = "00000000";

    WAIT FOR clk_period;

    init <= '1';
    re <= '0';
    we <= '0';
    WAIT FOR clk_period;

    init <= '0';
    re <= '1';
    addr <= "00000000";
    WAIT FOR clk_period;
    ASSERT output = "00000111";

    addr <= "00000001";
    WAIT FOR clk_period;
    ASSERT output = "00000111";

    addr <= "00000010";
    WAIT FOR clk_period;
    ASSERT output = "00000111";

    addr <= "00000011";
    WAIT FOR clk_period;
    ASSERT output = "00000111";

    addr <= "00000101";
    WAIT FOR clk_period;
    ASSERT output = "00000000";

    init <= '0';
    dump <= '1';

    WAIT FOR clk_period;

    file_open(infile, "memory.dat", read_mode);
    file_open(outfile, "dump.dat", read_mode);

    WHILE NOT endfile(infile) AND NOT endfile(outfile) LOOP
      readline(infile, inline);

      read(inline, in_ops);
      FOR i IN ADDR_SIZE-1 DOWNTO 0 LOOP
        infile_addr(i) := in_ops(i);
      END LOOP;

      read(inline, in_ops);
      FOR i IN DATA_SIZE-1 DOWNTO 0 LOOP
        infile_data(i) := in_ops(i);
      END LOOP;

      readline(outfile, outline);

      read(outline, out_ops);
      FOR i IN ADDR_SIZE-1 DOWNTO 0 LOOP
        outfile_addr(i) := out_ops(i);
      END LOOP;

      read(outline, out_ops);
      FOR i IN DATA_SIZE-1 DOWNTO 0 LOOP
        outfile_data(i) := out_ops(i);
      END LOOP;

      ASSERT infile_data = outfile_data;
      ASSERT infile_addr = outfile_addr;
    END LOOP;
    file_close(infile);

    WHILE NOT endfile(outfile) LOOP
      readline(outfile, outline);

      read(outline, out_ops);
      FOR i IN ADDR_SIZE-1 DOWNTO 0 LOOP
        outfile_addr(i) := out_ops(i);
      END LOOP;

      read(outline, out_ops);
      FOR i IN DATA_SIZE-1 DOWNTO 0 LOOP
        outfile_data(i) := out_ops(i);
      END LOOP;

      ASSERT outfile_data = "00000000";
    END LOOP;
    file_close(infile);

    dump <= '0';
    init <= '1';
    reset <= '1';
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    init <= '1';
    we <= '1';
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    init <= '1';
    dump <= '1';
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    init <= '0';
    dump <= '0';
    re <= '1';
    we <= '1';
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    re <= '0';
    we <= '1';
    reset <= '1';
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    re <= '1';
    we <= '0';
    reset <= '0';
    addr <= "11000000";
    data_in <= "00001111";
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    re <= '1';
    we <= '0';
    reset <= '0';
    addr <= "11111111";
    data_in <= "00001111";
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    dump <= '0';
    init <= '0';
    re <= '0';
    we <= '0';
    reset <= '0';
    addr <= "00000000";
    data_in <= "00000000";
    WAIT FOR clk_period;
    ASSERT output = "XXXXXXXX";

    REPORT "c96 testbench finished";
    WAIT;
  END PROCESS stim_proc;
END ARCHITECTURE behavioral;
