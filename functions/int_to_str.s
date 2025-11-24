 // Convert integer to string
 _int_to_string:
    mov     x19, #0 // character count
    mov     w2, #10 // divisor
    sub     sp, sp, #64 // Allocate memory on the stack

# Convert all the digits of an integer to a string
 _convert_loop:
    udiv    w4, w0, w2
    msub    w5, w4, w2, w0 // Get remainder
    add     w5, w5, #'0' // Convert int to char
    strb    w5, [sp, x19]
    add     x19, x19, #1
    mov     w0, w4
    cbnz    w0, _convert_loop

    mov     x4, #0
    sub     x18, x19, #1

// The above operation inverts the values
// This function reverts the string values back to their original order
 _copy:
    ldrb    w5, [sp, x18] // Loads a character from the stack at index x18
    strb    w5, [x1, x4] // Store the character w5 to x1 at index x4
    add     x4, x4, #1
    sub     x18, x18, #1
    cmp     x4, x19
    b.lt    _copy

    add     sp, sp, #64
    ret
