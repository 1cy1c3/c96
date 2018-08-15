GHDL=ghdl
GHDLFLAGS=--ieee=synopsys
MODULES=\
    c96.o \
		c96_tb

test: $(MODULES)
		./c96_tb --vcd=c96_tb.vcd

# Binary depends on the object file
%: %.o
		$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
		$(GHDL) -a $(GHDLFLAGS) $<

clean:
		echo "Cleaning up..."
		rm -f *.o *_tb c96 work*.cf e*.lst
