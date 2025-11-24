// Prints a value
_print_value:
    mov     x0, #1
    adr     x1, helloworld // value to print
    mov     x2, #14 // Output length
    mov     x16, #4 // System call to print value
    svc     #0x0

helloworld:
    .ascii "Hello, World!\n"
