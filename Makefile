NASM = nasm
NASM_FLAGS = -f bin
EMULATOR = qemu-system-x86_64
OUTPUT = boot.bin
SRC = boot/boot.asm


$(OUTPUT): $(SRC)
	$(NASM) $(NASM_FLAGS) $(SRC) -o $(OUTPUT)
all:
	$(OUTPUT)

run: $(OUTPUT)
	$(EMULATOR) -drive format=raw,file=$(OUTPUT)

clean:
	rm -f $(OUTPUT)

.PHONY: all run clean

