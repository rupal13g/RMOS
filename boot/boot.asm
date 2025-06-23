[BITS 16]
[ORG 0x7C00]

start:
	mov ah, 0x0E	; Teletype output(BIOS interrupt)
	mov al, 'H'
	int 0x10
	mov al, 'e'
	int 0x10
	mov al, 'l'
	int 0x10
	mov al, 'l'
	int 0x10
	mov al, 'o'
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 'W'
	int 0x10
	mov al, 'o'
	int 0x10
	mov al, 'r'
	int 0x10
	mov al, 'l'
	int 0x10
	mov al, 'd'
	int 0x10

	cli
	hlt
times 510 - ($ - $$) db 0 ; pad bootloader to 512 bytes
dw 0xAA55	;Boot signature
