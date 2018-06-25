
all: ram_dump.gb


%.o: %.asm
	rgbasm -p 0 -o $@ $^

%.gb: %.o
	rgblink -p 0 -o $@ $^
	rgbfix -v -m 0x13 -r 3 -p 0 $@
