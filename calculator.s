/* A Simple calculator written in arm63 assembly (Apple Silicon */

.global _main
.align 4
.text

_main:
    stp     x29, x30, [sp, #-16]!   // Store Frame Pointer (x29) and Link Register (x30)
    mov     x29, sp

    cmp     x0, #4 // Check if the argc is equal to 4
    b.ne   _invalid_argument

    mov     x19, x1 // Stores the value of x1 in x19, incase x1 gets modified by _atof

    // First command line argument
    ldr     x0, [x19, #8]
    bl      _atof
    fmov     d11, d0

    // third command line argument
    ldr     x0, [x19, #24]
    bl      _atof
    fmov    d12, d0

    // Second command line argument (operator)
    ldr     x10, [x19, #16]
    ldrb    w9, [x10]

_compare:  // Compare operators
    cmp     w9, #'+'
    b.eq    _addition
    cmp     w9, #'*'
    b.eq    _multiplication
    cmp     w9, #'-'
    b.eq    _subtraction
    cmp     w9, #'/'
    b.eq    _division

_addition:
    fadd     d11, d11, d12
    b       _print_value

_subtraction:
    fsub     d11, d11, d12
    b       _print_value

_division:
    fcmp     d12, #0.0
    b.eq    _zero_division_error
    fdiv    d11, d11, d12
    b       _print_value

_multiplication:
    fmul     d11, d11, d12
    b       _print_value

_invalid_argument:
    // Print the error message (string) using printf("%s\n", error_msg)
    adrp    x0, fmt_str@PAGE
    add     x0, x0, fmt_str@PAGEOFF
    adr     x1, error_msg
    str     x1, [sp]
    bl      _printf
    b       _exit

_zero_division_error:
    // Print zero division error as a string
    adrp    x0, fmt_str@PAGE
    add     x0, x0, fmt_str@PAGEOFF
    adr     x1, zero_division_error_msg
    str     x1, [sp]
    bl      _printf
    b       _exit

_print_value:
    adrp    x0, fmt_result@PAGE
    add     x0, x0, fmt_result@PAGEOFF
    str     d11, [sp]
    bl      _printf
    b       _exit

_exit:
    mov     w0, #0                  // Return code 0
    ldp     x29, x30, [sp], #16     // Restore x29 and x30
    ret

error_msg:
    .asciz  "Invalid Arguments: Example usage <program> 8 <operator = *, + , /, \\*> 7"

zero_division_error_msg:
    .asciz  "Zero Division Error"

.data
fmt_result:
    .asciz  "%f\n"

fmt_str:
    .asciz  "%s\n"
