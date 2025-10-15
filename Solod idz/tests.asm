# ========================== tests.asm (RV32I) ===============================
        .include "macros.inc"

        .data
ok_msg:   .asciz "PASS\n"
fail_msg: .asciz "FAIL\n"
case_msg: .asciz "Case "
colon_sp: .byte 58,32,0

        .align 2
# --- Case 1 ---
A1: .word -1, 0, 2, -5, 3
B1: .space 40
E1: .word 3, 5

        .align 2
# --- Case 2 (no positives) ---
A2: .word 0, 0, -7
B2: .space 40

        .align 2
# --- Case 3 (all positives) ---
A3: .word 5, 1, 9
B3: .space 40
E3: .word 1, 2, 3

        .text
        .globl main

# eq_arrays(ptr1,len1, ptr2,len2) -> a0=1/0
eq_arrays:
        addi sp, sp, -24
        sw   ra, 20(sp)
        sw   s0, 16(sp)
        sw   s1, 12(sp)
        sw   s2,  8(sp)
        sw   s3,  4(sp)
        sw   s4,  0(sp)

        mv   s0, a0      # p1
        mv   s1, a1      # n1
        mv   s2, a2      # p2
        mv   s3, a3      # n2

        bne  s1, s3, .ne

        mv   s4, zero    # i=0
.eq_loop:
        bge  s4, s1, .ok
        slli t0, s4, 2
        add  t1, s0, t0
        add  t2, s2, t0
        lw   t3, 0(t1)
        lw   t4, 0(t2)
        bne  t3, t4, .ne
        addi s4, s4, 1
        j    .eq_loop

.ok:    li a0, 1
        j  .ret
.ne:    li a0, 0
.ret:
        lw   ra, 20(sp)
        lw   s0, 16(sp)
        lw   s1, 12(sp)
        lw   s2,  8(sp)
        lw   s3,  4(sp)
        lw   s4,  0(sp)
        addi sp, sp, 24
        ret

# print "Case id: PASS/FAIL"
# in: a0=1/0, a1=id
print_case_result:
        addi sp, sp, -4
        sw   ra, 0(sp)
        la   a0, case_msg
        PRINT_STR
        mv   a0, a1
        PRINT_INT
        la   a0, colon_sp
        PRINT_STR
        beq  a0, zero, .p_fail
        la   a0, ok_msg
        PRINT_STR
        j    .p_done
.p_fail:
        la   a0, fail_msg
        PRINT_STR
.p_done:
        lw   ra, 0(sp)
        addi sp, sp, 4
        ret

main:
        # ---- Case 1: expect [3,5], M=2 ----
        la a0, A1          # a0=&A1
        li a1, 5           # a1=N
        la a2, B1          # a2=&B1
        CALL_BUILD_POS_IDX # -> a0=M
        mv s0, a0          # M
        la a0, B1          # compare B1 vs E1, len M vs 2
        mv a1, s0
        la a2, E1
        li a3, 2
        jal eq_arrays
        li a1, 1
        jal print_case_result

        # ---- Case 2: no positives, M=0 ----
        la a0, A2
        li a1, 3
        la a2, B2
        CALL_BUILD_POS_IDX
        mv s0, a0
        la a0, B2
        mv a1, s0
        la a2, B2          # any valid ptr; length check only
        li a3, 0
        jal eq_arrays
        li a1, 2
        jal print_case_result

        # ---- Case 3: all positives [1,2,3], M=3 ----
        la a0, A3
        li a1, 3
        la a2, B3
        CALL_BUILD_POS_IDX
        mv s0, a0
        la a0, B3
        mv a1, s0
        la a2, E3
        li a3, 3
        jal eq_arrays
        li a1, 3
        jal print_case_result

        li a7, 10
        ecall
# ============================================================================
