# ======================= macros.inc (RARS 1.6, RV32I) =======================
# Macros as thin wrappers. Work via argument registers (a0..a3) to avoid
# RARS parameter syntax pitfalls.

# a0 = address (zero-terminated string)
.macro PRINT_STR
    li a7, 4
    ecall
.end_macro

# a0 = integer
.macro PRINT_INT
    li a7, 1
    ecall
.end_macro

# a0 = character code
.macro PRINT_CHAR
    li a7, 11
    ecall
.end_macro

# a0 = buffer address, a1 = max length
.macro READ_STRING
    li a7, 8
    ecall
.end_macro

# a0 = ptr, a1 = len
.macro PRINT_ARRAY
    jal print_array_plain
.end_macro

# (a0=ptr, a1=end) -> (a0=newptr, a1=value, a2=ok)
.macro PARSE_NEXT_INT
    jal parse_next_int
.end_macro

# (a0=&A, a1=N, a2=&B) -> a0 = M
.macro CALL_BUILD_POS_IDX
    jal build_indices_pos
.end_macro
# ============================================================================
