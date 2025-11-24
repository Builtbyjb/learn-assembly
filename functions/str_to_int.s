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
    sub     x9, x9, #48 // Subtract 48 from x9 to get integer value
    madd    x10, x10, x11, x9 // x9 equals w9 because the upper bits are zeroed out
    b       _int_convert_loop

_end_int_convert_loop:
    cmp     x12, #1
    b.ne    _return_int
    neg     x10, x10

_return_int:
    sub     x2, x10, #48 // Subtract 48 from x10 to get integer value
    ret
