; AddTwo.asm - adds two 32-bit integers.
; Chapter 3 example

.386
.model flat
.stack 4096

; see. https://docs.microsoft.com/en-us/cpp/porting/overview-of-potential-upgrade-issues-visual-cpp?view=msvc-170 
; Upgrading with the linker options /NODEFAULTLIB, /ENTRY, and /NOENTRY
; Errors involving CRT functions
INCLUDELIB msvcrt.lib
INCLUDELIB ucrt.lib
INCLUDELIB vcruntime.lib
INCLUDELIB legacy_stdio_definitions.lib

printf PROTO C, :VARARG
getchar PROTO C
exit PROTO C, :DWORD

; Functions in C.c:
greater PROTO C :DWORD, :DWORD          ; Declaration of greater (int,int)
hello PROTO C                           ; Declaration of hello (void)

.data
fmt db "%s %u", 10, 0                   ; '10': printf of msvcrt.dll doesn't accept "\n"
PorukaZaIspis db "Message from ASM: ", 0

.code
_main PROC
    invoke greater, 8, 3
    call output                         ; "Message from ASM ..."
    invoke hello                        ; "Message from C ..."
    call getchar
    invoke exit, 0FFh
_main ENDP

output PROC                             ; ARG: EAX
    invoke printf, OFFSET fmt, OFFSET PorukaZaIspis, eax
    ret
output ENDP

END _main