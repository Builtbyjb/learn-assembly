/* A Simple calculator written in arm63 assembly (Apple Silicon */

.global _main
.align 4
.text

_main:
    stp     x29, x30, [sp, #-16]!   // Store Frame Pointer (x29) and Link Register (x30)
    mov     x29, sp

    cmp     x0, #4 // Check if the argc is equal to 4
    b.ne   _invalid_argument

    // First command line argument
    ldr     x10, [x1, #8]
    bl      _str_to_int
    mov     x11, x10

    // third command line argument
    ldr     x10, [x1, #24]
    bl      _str_to_int
    mov     x12, x10

    // Second command line argument (operator)
    ldr     x10, [x1, #16]
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
    add     x11, x11, x12
    b       _print_value

_subtraction:
    sub     x11, x11, x12
    b       _print_value

_division:
    cmp     x12, #0
    b.eq    _zero_division_error
    udiv    x11, x11, x12
    b       _print_value

_multiplication:
    mul     x11, x11, x12
    b       _print_value

_invalid_argument:
    // Print the error message (string) using printf("%s\n", error_msg)
    adrp    x0, fmt_str@PAGE
    add     x0, x0, fmt_str@PAGEOFF
    adr     x1, error_msg
    bl      _printf
    b       _exit

_zero_division_error:
    // Print zero division error as a string
    adrp    x0, fmt_str@PAGE
    add     x0, x0, fmt_str@PAGEOFF
    adr     x1, zero_division_error_msg
    bl      _printf
    b       _exit

_no_float_support_error:
    // Print floating point support message
    adrp    x0, fmt_str@PAGE
    add     x0, x0, fmt_str@PAGEOFF
    adr     x1, no_float_support_error_msg
    bl      _printf
    b       _exit

_print_value:
    adrp    x0, fmt_result@PAGE
    add     x0, x0, fmt_result@PAGEOFF
    mov     x1, x11
    str     x1, [sp]
    bl      _printf
    b       _exit

_exit:
    mov     w0, #0                  // Return code 0
    ldp     x29, x30, [sp], #16     // Restore x29 and x30
    ret

_str_to_int:
    mov     x13, #0 // Accumulator (result)
    mov     x14, #10 // Constant
    mov     x15, #0 // Sign flag (0 = +, 1 = -)

    // Check for negative sign
    ldrb    w9, [x10] // Load first byte
    cmp     w9, #45 // Check if the first byte (character) is a negative sign ('-' is 45 is ASCII)
    b.ne    _int_convert_loop // If the first byte (character) is not negative start the loop
    mov     x15, #1 // Update negative flag
    add     x10, x10, #1 // Move the pointer to the next byte (Character)

_int_convert_loop:
    ldrb    w9, [x10], #1
    cbz     w9, _end_int_convert_loop
    sub     w9, w9, #48 // Subtract 48 from x9 to get integer value
    madd    x13, x13, x14, x9
    b       _int_convert_loop

_end_int_convert_loop:
    cmp     x15, #1
    b.ne    _return_int
    neg     x13, x13

_return_int:
    mov     x10, x13
    ret

error_msg:
    .asciz  "Invalid Arguments: Example usage <program> 8 <operator = *, + , /, \\*> 7"

zero_division_error_msg:
    .asciz  "Zero Division Error"

no_float_support_error_msg:
    .asciz  "Floating point operations are not supported"

.data
fmt_result:
    .asciz  "%lld\n"

fmt_str:
    .asciz  "%s\n"
