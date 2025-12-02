/* A Simple calculator written in arm63 assembly (Apple Silicon */

.global _main
.align 4

_main:
    cmp     x0, #4 // Check if the argc is equal to 4
    b.ne   _invalid_argument

    // First command line argument
    ldr     x10, [x1, #8]
    bl      _check_float_setup
    bl      _str_to_int
    mov     x11, x10

    // third command line argument
    ldr     x10, [x1, #24]
    bl      _check_float_setup
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
    bl      _int_to_str
    b       _print_value

_subtraction:
    sub     x11, x11, x12
    bl      _int_to_str
    b       _print_value

_division:
    cmp     x12, #0
    b.eq    _zero_division_error
    udiv    x11, x11, x12
    bl      _int_to_str
    b       _print_value

_multiplication:
    mul     x11, x11, x12
    bl      _int_to_str
    b       _print_value

_invalid_argument:
    adr     x1, error_msg
    mov     x2, #72 // Output length
    b       _print_value

_zero_division_error:
    adr     x1, zero_division_error_msg
    mov     x2, #20 // Output length
    b       _print_value

_no_float_support_error:
    adr     x1, no_float_support_error_msg
    mov     x2, #43
    b       _print_value

_print_value:
    mov     x0, #1
    mov     x16, #4 // Syscall to write to stdout
    svc     #0x80 // Execute syscall

_print_newline:
    mov     x0, #1
    adr     x1, newline
    mov     x2, #1
    mov     x16, #4
    svc     #0x80

_exit:
    mov     x0, #0
    mov     x16, #1
    svc     #0x80

// Check if a command line value is float
_check_float_setup:
    mov     x12, #0

_check_float:
    ldrb    w9, [x10, x12]
    cbz     w9, _return_check_float
    cmp     w9, #'.'
    b.eq    _no_float_support_error
    add     x12, x12, #1
    b       _check_float

_return_check_float:
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

 _int_to_str:
    mov     x2, #0 // character count
    mov     x13, #10 // divisor
    sub     sp, sp, #64 // Allocate memory on the stack

_check_negative:
    mov     x12, #0
    cmp     x11, #0
    b.ge    _str_convert_loop
    mov     x12, #45
    str     x12, [sp, x2]
    add     x2, x2,  #1
    neg     x11, x11

 _str_convert_loop:
    udiv    x14, x11, x13
    msub    x15, x14, x13, x11 // Get remainder
    add     x15, x15, #'0' // Convert int to char
    str     x15, [sp, x2]
    add     x2, x2, #1
    mov     x11, x14
    cbnz    x11, _str_convert_loop
    mov     x14, #0
    sub     x9, x2, #1

 _copy:
    cmp     x12, #0
    b.eq    _n_copy
    mov     w15, #'-'
    strb    w15, [x1, x14]
    add     x14, x14, #1 // Increasing by 1 makes sure we never get to the last byte which is "-" in a negative case

_n_copy:
    ldrb    w15, [sp, x9]
    strb    w15, [x1, x14]
    add     x14, x14, #1
    sub     x9, x9, #1
    cmp     x14, x2
    b.lt    _n_copy
    add     sp, sp, #64
    ret

 newline:
    .ascii  "\n"

error_msg:
    .ascii  "Invalid Arguments: Example usage <program> 8 <operator = *, + , /, \\*> 7"

zero_division_error_msg:
    .ascii  "Zero Division Error"

no_float_support_error_msg:
    .ascii  "Floating point operations are not supported"
