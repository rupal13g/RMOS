[org 0x7c00]
[BITS 16]
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov si, msg
    call print
    jmp $

print:
    lodsb
    or al, al
    jz done
    mov ah, 0x0e
    int 0x10
    jmp print
done:
    ret

msg:
    db "Hello, World! Welcome To RMOS!", 0

times 510-($-$$) db 0
dw 0xaa55