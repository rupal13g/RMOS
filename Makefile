NASM = nasm
NASM_FLAGS = -f bin
EMULATOR = qemu-system-x86_64
BOUTPUT = boot.bin
BSRC = boot/boot.asm
KOUTPUT = kernel.bin
KSRC = kernel/main.asm


.PHONY: all floppy_image run clean debug


floppy_image: main_floppy.img

main_floppy.img : bootloader kernel
	dd if=/dev/zero of=main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" main_floppy.img
	dd if=$(BOUTPUT) of=main_floppy.img conv=notrunc
	mcopy -i main_floppy.img $(KOUTPUT) "::$(KOUTPUT)"


bootloader : $(BOUTPUT)

$(BOUTPUT): $(BSRC)
	$(NASM) $(NASM_FLAGS) $(BSRC) -o $(BOUTPUT)


kernel : $(KOUTPUT)

$(KOUTPUT): $(KSRC)
	$(NASM) $(NASM_FLAGS) $(KSRC) -o $(KOUTPUT)


all:
	$(BOUTPUT) $(KOUTPUT)

run: main_floppy.img
	$(EMULATOR) -drive format=raw,file=main_floppy.img

clean:
	rm -f *.bin *.img



