extern _printf ; the C function, to be called
extern _getchar
SECTION .data ; Data section, initialized variables 
myint dd 1234 
mystring db "This number -> %d <- should be 1234",10,0
 
SECTION .text ; Code section. .
global _main ; the standard gcc entry point
_main: ; the program label for the entry point
push dword [myint]   ; one of my integer variables 
push dword mystring  ; pointer into my data segment 
call _printf 
add esp,byte 8      ; `byte' saves space 
call _getchar ;let us C ;)
 
ret ; return 