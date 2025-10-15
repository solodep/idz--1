
**Вариант 7:**

---

## 1. ФИО
- **ФИО:** Солод Алексей Александрович 
- **Группа:** БПИ-248
ё

---

## 2. Условие задачи
Ввести массив `A` из `N` целых (`1 ≤ N ≤ 10`).  
Сформировать массив `B`, записав в него индексы (1-based) элементов `A`, которые строго **положительные**.  
Вывести `A`, `B` и `|B|`. При некорректном `N` — завершить работу с сообщением об ошибке.

---

## 3. Структура проекта
├─ main_stdin.asm # основная программа: ввод с клавиатуры, вывод результатов
├─ lib_algo.asm # алгоритм build_indices_pos(&A,N,&B)->M (локальные на стеке)
├─ lib_io.asm # печать массива и парсер целых из буфера
├─ macros.inc # макросы-обёртки для ecall/вызовов подпрограмм
├─ tests.asm # отдельная программа автотестов (Case 1..3)

---

## 4. Сборка и запуск

- включить: **Assemble all files currently open**
- включить: **Initialize Program Counter to global ‘main’ if defined**

### Основная программа
1) Открыть: `main_stdin.asm`, `lib_io.asm`, `lib_algo.asm`, `macros.inc`  
2) **Assemble → Run**  
3) Ввести `N`, затем **ровно N** целых (можно в несколько строк)

### Автотесты
1) Открыть: `tests.asm`, `lib_algo.asm`, `macros.inc`  
2) **Assemble → Run** — появятся строки `Case 1..3: PASS/FAIL`


---

## 5. Ключевая подпрограмма

### `build_indices_pos(&A, N, &B) -> M`
- **Вход:** `a0=&A`, `a1=N`, `a2=&B`  
- **Выход:** `a0=M` — число записанных индексов  
- **Алгоритм:** один проход `i=0..N-1`: если `A[i] > 0`, то `B[m++] = i+1`  
- **Стек:** кадр 36 байт (сохранённые `ra`, `s*`, копии параметров)  
- **Сложность:** `O(N)` по времени, `O(1)` доп.память (кроме `B`)

---

## 6. Примеры запуска
Ввод:
Enter N (1..10): 7
Enter A[0..N-1] separated by spaces/newlines:
-2 5 0 7 -1 9 4
Вывод:
Source A: [ -2 5 0 7 -1 9 4 ]
Result B (1-based indices of positives): [ 2 4 6 7 ]
Count |B|: 4


Ввод:
N = 5
A = -3 0 -1 -8 -2
Вывод:
Source A: [ -3 0 -1 -8 -2 ]
Result B (1-based indices of positives): [ ]
Count |B|: 0


Ввод:
N = 0
Вывод:
Error: N must be in [1..10].

---

## 7. Автотесты (tests.asm)
Проверяются три набора:
1. `A = [-1, 0, 2, -5, 3]` → `B = [3, 5]`, `M = 2` → **PASS**  
2. `A = [0, 0, -7]` → `M = 0` → **PASS**  
3. `A = [5, 1, 9]` → `B = [1, 2, 3]`, `M = 3` → **PASS**  

---

## 8. Соответствие критериям
- **4–5:** консольный ввод; печать `A` и `B` с пояснениями; проверка диапазона `N`; комментарии в коде  
- **6–7:** подпрограммы с параметрами; **локальные переменные на стеке**; комментарии у вызовов (что передаём/что получаем)  
- **8:** модульность и **отдельная тестовая программа**  
- **9:** библиотека **макросов** `macros.inc`, используется и в `main`, и в `tests`

---

## 9. Тексты программы
main_stdin.asm:
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

---

macros.inc:
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

---

lib_algo.asm:
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

---

lib_io.asm:
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

---

tests.asm:
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


