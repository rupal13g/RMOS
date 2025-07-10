org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A


; FAT 12 Header
jmp short start
nop


bdb_oem:     			    db 'MSWIN4.1'  ;8bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880
bdb_media_descriptor_type:  db 0F0h     ; F0 = 3.5" floppy disk
bdb_sectors_per_file:       dw 9        ;9 sectors per fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0


; extended boot record
ebr_drive_number:           db 0        ;0x00 floppy, 0x80 hdd
							db 0        ;reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h ;serial numbers, value doesn't matter
ebr_volume_lable:           db '    RMOS   ' ;11 bytes padded with spaces
ebr_system_id:              db 'FAT12   ' ;8bytes


;Code part now



start:
	jmp main

; Prints a string to the screen
;params:
;	-ds:si points to string
;
puts:
	; save the registers we will modify
	push si
	push ax

.loop:
	lodsb	;loads next character in al
	or al, al	; verify if the next character is null
	jz .done

	mov ah, 0x0e ;call bios interrupt
	mov bh, 0
	int 0x10

	jmp .loop

.done:
	pop ax
	pop si
	ret

main:

	;setup data segments
	mov ax, 0 ; can't write to ds/es directly
	mov ds, ax
	mov es, ax

	;setup stack
	mov ss, ax
	mov sp, 0x7C00 ; stack grows downwards from where we are located in the m/m

	;Read from floppy

	mov [ebr_drive_number], dl

	mov ax, 1                   ; LBA = 1 second sector from disk
	mov cl, 1                   ; 1 sector to read
	mov bx, 0x7E00              ; data should be after the bootloader
	call disk_read

	; Print message
	mov si, msg_hello
	call puts
	hlt


floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h                  ; wait for keypress
	jmp 0FFFFh:0             ; jump to beginning of bios, should reboot

.halt:
	cli                      ; disable interrupts
	hlt



;
; Disk routines
;

; Converts an LBA address to CHS address
; parameters
;	-ax : LBA address
; Returns
;	-cx [bits 0 to 5] : Sector number
;	-cx [bits 6 to 15]: cylinder
;	-dh : head

lba_to_chs:

	push ax
	push dx
	
	xor dx, dx       ; dx=0
	div word [bdb_sectors_per_track]  ; ax = LBA / SectorsPerTrack
									  ; dx = LBA % SectorsPerTrack
	
	inc dx                            ; dx = (LBA % SectorsPerTrack +1) = Sector
	mov cx, dx                        ; cx = sector

	xor dx, dx
	div word [bdb_heads]              ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
									  ; dx = (LBA / SectorsPerTrack) % Heads = head
	mov dh, dl                        ; dl = head
	mov ch, al                        ; ch = cylinder (lower 8 bits)
	shl al, 6
	or cl, ah                         ; putting upper 2 bits of cylinder in cl

	pop ax
	mov dl, al                        ; restoring dl
	pop ax
	ret


; reads sectors from a disk
; Parameters
;	-ax: LBA address
;	-cl: number of sector to read (upto 128)
;	-dl: drive number
;	-es:bx: memory address where to store data
;
;
disk_read:

	push ax
	push bx
	push cx
	push dx
	push di

	push cx                        ; temporarily saving cl(number of sectors to read)
	call lba_to_chs
	pop cx

	mov ah, 02h
	mov di, 3                      ; retry count


.retry:
	pusha                          ; saving all registers, we don't know what bios modifies
	stc                            ; setting the carry flag, some bios don't set it
	int 13h                        ; carry flag cleared = success
	jnc .done                      ; jump if carry not set

	;failed
	popa
	call disk_reset

	dec di
	test di, di
	jnz .retry

.failed:
	; after all attempts are failed
	jmp floppy_error

.done:

	popa

	push di
	push dx
	push cx
	push bx
	push ax
	ret


;
;disk reset
; parameters
;	-dl = drive number

disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret


msg_hello: db 'Welcome To RMOS!', ENDL, 0
msg_read_failed: db 'Read from disk failed', ENDL, 0

times 510 - ($-$$) db 0
dw 0AA55h
