/* A Simple calculator written in arm64 assembly */

.global _main
.align 2
.text

_main:
    cmp     x0, #4 // Check if the argc is equal to 4
    b.ne   _invalid_argument
    // First command line argument
    ldr     x2, [x1, #8]
    bl      _str_to_int
    mov     w0, w2
    // Second command line argument
    ldr     x2, [x1, #16]
    ldrb    w3, [x2] // Store operator
    // third command line argument
    ldr     x2, [x1, #24]
    bl      _str_to_int
    mov     w7, w2

_compare:  // Compare operators
    cmp     w3, #'+'
    b.eq    _addition
    cmp     w3, #'*'
    b.eq    _multiplication
    cmp     w3, #'-'
    b.eq    _subtraction
    cmp     w3, #'/'
    b.eq    _division

_addition:
    add     w0, w0, w7
    bl      _int_to_str
    b       _print_value

_subtraction:
    sub     w0, w0, w7
    bl      _int_to_str
    b       _print_value

_division:
    cmp     w1, #0
    b.eq    _zero_division_error
    udiv    w0, w0, w7
    bl      _int_to_str
    b       _print_value

_multiplication:
    mul     w0, w0, w7
    bl      _int_to_str
    b       _print_value

_invalid_argument:
    adr     x1, error_msg
    mov     x19, #72
    b       _print_value

_zero_division_error:
    adr     x1, zero_division_error_msg
    mov     x19, #20
    b       _print_value

_print_value:
    mov     x0, #1
    mov     x2, x19 // Output length
    mov     x16, #4
    svc     #0x0

_print_newline:
    mov     x0, #1
    adr     x1, newline
    mov     x2, #1
    mov     x16, #4
    svc     #0x0

_exit:
    mov     x0, #0
    mov     x16, #1
    svc     #0x0

_str_to_int:
    mov     x10, #0 // Accumulator (result)
    mov     x11, #10 // Constant
    mov     x12, #0 // Sign flag (0 = +, 1 = -)
    // Check for negative sign
    ldrb    w9, [x2] // Load first byte
    cmp     w9, #45 // Check if the first byte (character) is a negative sign ('-' is 45 is ASCII)
    b.ne    _int_convert_loop // If the first byte (character) is not negative start the loop
    mov     x12, #1 // Update negative flag
    add     x2, x2, #1 // Move the pointer to the next byte (Character)

_int_convert_loop:
    ldrb    w9, [x2], #1
    cbz     w9, _end_int_convert_loop
    madd    x10, x10, x11, x9 // x9 equals w9 because the upper bits are zeroed out
    b       _int_convert_loop

_end_int_convert_loop:
    cmp     x12, #1
    b.ne    _return_int
    neg     x10, x10

_return_int:
    sub     x2, x10, #48 // Subtract 48 from x10 to get integer value
    ret

 _int_to_str:
    mov     x19, #0 // character count
    mov     w2, #10 // divisor
    sub     sp, sp, #128 // Allocate memory on the stack

 _str_convert_loop:
    udiv    w4, w0, w2
    msub    w5, w4, w2, w0 // Get remainder
    add     w5, w5, #'0' // Convert int to char
    strb    w5, [sp, x19]
    add     x19, x19, #1
    mov     w0, w4
    cbnz    w0, _str_convert_loop
    mov     x4, #0
    sub     x18, x19, #1

 _copy:
    ldrb    w5, [sp, x18] // Loads a character from the stack at index x18
    strb    w5, [x1, x4] // Store the character w5 to x1 at index x4
    add     x4, x4, #1
    sub     x18, x18, #1
    cmp     x4, x19
    b.lt    _copy
    add     sp, sp, #64
    ret

 newline:
    .ascii  "\n"

error_msg:
    .ascii "Invalid Arguments: Example usage <program> 8 <operator = *, + , /, \\*> 7"

zero_division_error_msg:
    .ascii "Zero Division Error"
