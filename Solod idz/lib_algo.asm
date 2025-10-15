# ======================== lib_algo.asm (RV32I) ==============================
        .text
        .globl build_indices_pos

# build_indices_pos(&A, N, &B) -> a0 = M
# Requirement (6–7): use stack frame and local variables.
# Stack frame layout (36 bytes):
#   32(sp): ra
#   28(sp): s0
#   24(sp): s1
#   20(sp): s2
#   16(sp): s3
#   12(sp): s4
#    8(sp): param copy &A   (for report/inspection)
#    4(sp): param copy N
#    0(sp): param copy &B
build_indices_pos:
        addi sp, sp, -36
        sw   ra, 32(sp)
        sw   s0, 28(sp)
        sw   s1, 24(sp)
        sw   s2, 20(sp)
        sw   s3, 16(sp)
        sw   s4, 12(sp)

        sw   a0, 8(sp)     # copy &A
        sw   a1, 4(sp)     # copy N
        sw   a2, 0(sp)     # copy &B

        mv   s0, a0        # ptrA
        mv   s1, a2        # ptrB
        mv   s2, zero      # i
        mv   s3, a1        # N
        mv   s4, zero      # m (count)

.loop:
        bge  s2, s3, .done
        slli t0, s2, 2
        add  t1, s0, t0
        lw   t2, 0(t1)     # A[i]
        ble  t2, zero, .next

        addi t3, s2, 1     # store 1-based index
        sw   t3, 0(s1)
        addi s1, s1, 4
        addi s4, s4, 1

.next:
        addi s2, s2, 1
        j    .loop

.done:
        mv   a0, s4        # return M

        lw   ra, 32(sp)
        lw   s0, 28(sp)
        lw   s1, 24(sp)
        lw   s2, 20(sp)
        lw   s3, 16(sp)
        lw   s4, 12(sp)
        addi sp, sp, 36
        ret
# ============================================================================
