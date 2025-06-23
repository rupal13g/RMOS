clean:
	rm -f boot.img

.PHONY: boot

boot:
	nasm -f bin boot/boot.asm -o boot.img
	qemu-system-i386 boot.img
