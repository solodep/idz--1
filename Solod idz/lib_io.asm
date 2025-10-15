# ========================= lib_io.asm (RV32I) ===============================
        .include "macros.inc"

        .data
lbrack: .asciz "["
rbrack: .asciz "]"
space:  .asciz " "

        .text
        .globl print_array_plain
        .globl parse_next_int

# print_array_plain(ptr,len) -> prints: [x y z]
print_array_plain:
        addi sp, sp, -16
        sw   ra, 12(sp)
        sw   s0,  8(sp)
        sw   s1,  4(sp)
        sw   s2,  0(sp)

        mv   s0, a0
        mv   s1, a1

        la   a0, lbrack
        PRINT_STR

        mv   s2, zero
.pap_loop:
        bge  s2, s1, .pap_done
        slli t0, s2, 2
        add  t1, s0, t0
        lw   t2, 0(t1)
        mv   a0, t2
        PRINT_INT
        addi s2, s2, 1
        blt  s2, s1, .pap_space
        j    .pap_loop

.pap_space:
        la   a0, space
        PRINT_STR
        j    .pap_loop

.pap_done:
        la   a0, rbrack
        PRINT_STR

        lw   ra, 12(sp)
        lw   s0,  8(sp)
        lw   s1,  4(sp)
        lw   s2,  0(sp)
        addi sp, sp, 16
        ret

# parse_next_int(ptr, end) -> (newptr, value, ok)
# in : a0=ptr, a1=end
# out: a0=newptr, a1=value, a2=ok (1/0)
parse_next_int:
        addi sp, sp, -24
        sw   ra, 20(sp)
        sw   s0, 16(sp)
        sw   s1, 12(sp)
        sw   s2,  8(sp)
        sw   s3,  4(sp)
        sw   s4,  0(sp)

        mv   s0, a0
        mv   s1, a1

# skip spaces (<= ' ')
.p_skip:
        bge  s0, s1, .p_fail
        lbu  t0, 0(s0)
        li   t1, 32
        bgt  t0, t1, .p_sign
        addi s0, s0, 1
        j    .p_skip

# optional sign
.p_sign:
        li   s2, 1
        bge  s0, s1, .p_fail
        lbu  t0, 0(s0)
        li   t1, 45          # '-'
        beq  t0, t1, .p_neg
        li   t1, 43          # '+'
        beq  t0, t1, .p_pos
        j    .p_digits
.p_neg:
        li   s2, -1
        addi s0, s0, 1
        j    .p_digits
.p_pos:
        addi s0, s0, 1

# digits
.p_digits:
        li   s3, 0           # value
        li   t2, 0           # digit_count
.p_dloop:
        bge  s0, s1, .p_enddigits
        lbu  t0, 0(s0)
        li   t1, '0'
        blt  t0, t1, .p_enddigits
        li   t4, '9'
        bgt  t0, t4, .p_enddigits
        addi t0, t0, -48
        li   t5, 10
        mul  s3, s3, t5
        add  s3, s3, t0
        addi s0, s0, 1
        addi t2, t2, 1
        j    .p_dloop

.p_enddigits:
        beq  t2, zero, .p_fail
        mul  s3, s3, s2
        mv   a0, s0
        mv   a1, s3
        li   a2, 1
        j    .p_ret

.p_fail:
        mv   a0, s0
        li   a1, 0
        li   a2, 0

.p_ret:
        lw   ra, 20(sp)
        lw   s0, 16(sp)
        lw   s1, 12(sp)
        lw   s2,  8(sp)
        lw   s3,  4(sp)
        lw   s4,  0(sp)
        addi sp, sp, 24
        ret
# ============================================================================
