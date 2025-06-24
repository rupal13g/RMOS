NASM = nasm
NASM_FLAGS = -f bin
EMULATOR = qemu-system-i386
OUTPUT = boot.bin
SRC = boot/boot.asm


$(OUTPUT): $(SRC)
	$(NASM) $(NASM_FLAGS) $(SRC) -o $(OUTPUT)
all:
	$(OUTPUT)

run: $(OUTPUT)
	$(EMULATOR) -fda $(OUTPUT)

clean:
	rm -f $(OUTPUT)

.PHONY: all run clean

