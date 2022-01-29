first: first.o
hello: hello.o

%.o: %.asm
	nasm -O0 -f elf64 $^
	xxd $@ > %.oh

