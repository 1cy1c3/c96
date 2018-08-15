C96
============

# Description

This memory can store 96 bytes. These bytes can be read or written. The interface is defined as follows:

```
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
```

With a rising edge, the read or write process begins. This process is finished after one clock cycle. If a '1' is present at the reset signal, the entire memory is deleted. All values are still set to '0'. The bits `re` (read enable) and `we` (write enable) indicate whether to read or write. The affected address is in `addr`. If you want to write, the value is in `data_in`. If you want to read, the value is written to `output`. The value is stored until the next read command.

To allow easy debugging, content can be written from a file *memory.dat* into memory. It is structured as follows:

```
<8 bit address><8 bit value>
<8 bit address><8 bit value>
...
```

The respective file fills the first four addresses of the memory with the number 7:

```
0000000000000111
0000000100000111
0000001000000111
0000001100000111
```

The signal `dump` controls the output of the memory to the file *dump.dat*. If an error occurs, *XXXXXXXXXX* is at the output.

## Prerequisites
+ [GHDL](http://ghdl.free.fr) to compile and execute the VHDL code directly in your PC
+ [GTKWave](http://gtkwave.sourceforge.net) to view the generated waves

## Installation and Usage
At first, clone or download this project. Afterwards, go to the terminal and type `make` to compile and link this application. Finally, the testbench is started without errors:

```
ghdl -a --ieee=synopsys c96.vhd
ghdl -a --ieee=synopsys c96_tb.vhd
ghdl -e --ieee=synopsys c96_tb
./c96_tb --vcd=c96_tb.vcd
c96_tb.vhd:...: c96 testbench finished
```

To see the waves, simply open the file *c96_tb.vcd* with *GTKWave*. The command `ghdl -r c96_tb` starts this application again.

Furthermore, it is possible to delete the object files and so on using `make clean`.

## More information
Learn more about VHDL on [NAND LAND](https://www.nandland.com/vhdl/tutorials/tutorial-introduction-to-vhdl-for-beginners.html).