
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
.data
myByte BYTE ?
myWord WORD ?

.code
main proc
     mov ax,bx
     mov bl,al
     mov al,[esi]
     mov myByte,al
     mov myWord,ax

	invoke ExitProcess,0
main endp
end main