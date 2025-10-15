# ======================= main_stdin.asm (RV32I) =============================
        .include "macros.inc"

        .data
askN:   .asciz "Enter N (1..10): "
askA:   .asciz "Enter A[0..N-1] separated by spaces/newlines:\n"
badN:   .asciz "Error: N must be in [1..10].\n"
msgA:   .asciz "Source A: "
msgB:   .asciz "Result B (1-based indices of positives): "
msgC:   .asciz "Count |B|: "
nl:     .byte 10,0

        .align 2
buf:    .space 512

        .align 2
A:      .space 40      # N<=10, 4 bytes per element
        .align 2
B:      .space 40

        .text
        .globl main

# Required subroutines live in other modules:
#   print_array_plain, parse_next_int — lib_io.asm
#   build_indices_pos                — lib_algo.asm

main:
        # --- read N ---
        la a0, askN
        PRINT_STR

        la a0, buf
        li a1, 511
        READ_STRING

        # parse N: (a0=buf, a1=buf+511)
        la a0, buf
        la a1, buf
        addi a1, a1, 511
        PARSE_NEXT_INT                 # -> a0=newptr, a1=N, a2=ok
        beq a2, zero, BAD_N
        mv  s2, a1
        li  t0, 1
        blt s2, t0, BAD_N
        li  t0, 10
        bgt s2, t0, BAD_N

        # --- read A (supports multi-line input) ---
        la a0, askA
        PRINT_STR

        mv  s3, zero           # read count
        la  s4, A              # write ptr

.readA_line:
        la a0, buf
        li a1, 511
        READ_STRING

        la s6, buf
        la s7, buf
        addi s7, s7, 511

.readA_parse:
        bge  s3, s2, .readA_done
        mv  a0, s6
        mv  a1, s7
        PARSE_NEXT_INT
        beq a2, zero, .readA_line   # no more ints in this line
        sw  a1, 0(s4)
        addi s4, s4, 4
        addi s3, s3, 1
        mv  s6, a0
        j   .readA_parse

.readA_done:

        # --- build B ---
        # passing actual params:
        #   a0=&A, a1=N, a2=&B ; return M in a0
        la a0, A
        mv a1, s2
        la a2, B
        CALL_BUILD_POS_IDX
        mv s5, a0

        # --- print A ---
        la a0, msgA
        PRINT_STR
        la a0, A
        mv a1, s2
        PRINT_ARRAY
        la a0, nl
        PRINT_STR

        # --- print B ---
        la a0, msgB
        PRINT_STR
        la a0, B
        mv a1, s5
        PRINT_ARRAY
        la a0, nl
        PRINT_STR

        # --- print count ---
        la a0, msgC
        PRINT_STR
        mv a0, s5
        PRINT_INT
        la a0, nl
        PRINT_STR

        li a7, 10
        ecall

BAD_N:
        la a0, badN
        PRINT_STR
        li a7, 10
        ecall
# ============================================================================
