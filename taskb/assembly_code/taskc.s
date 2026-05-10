# taskc.s  -  Task C: Recursive Summation with Binary Switch Input
#
# Input: sw[2:0] read as a 3-bit binary number -> n (0 to 7)
#   sw[2:0] = 000 -> poll, do nothing
#   sw[2:0] = 001 -> n=1, sum=1
#   sw[2:0] = 010 -> n=2, sum=3
#   sw[2:0] = 011 -> n=3, sum=6
#   sw[2:0] = 100 -> n=4, sum=10
#   sw[2:0] = 101 -> n=5, sum=15
#   sw[2:0] = 110 -> n=6, sum=21
#   sw[2:0] = 111 -> n=7, sum=28
#
# Output:
#   7-seg = ABCD (from LUI)
#   LEDs  = binary of sum(n)
#
# Instructions used: addi, sw, lw, andi, beq, lui, jal, add, bne, addi, jalr
# Stack lives at byte address 500 downward. Max depth 7 uses 56 bytes -> safe.

_start:
    addi sp,  x0,  500      # stack pointer = byte address 500
    addi x30, x0,  768      # x30 = switch MMIO address (0x300)
    addi x31, x0,  512      # x31 = LED/7-seg MMIO address (0x200)

IDLE:
    sw   x0,  0(x31)        # clear display

POLL:
    lw   a0,  0(x30)        # read switches
    andi a0,  a0,  7        # mask to sw[2:0] -> n (0-7)
    beq  a0,  x0,  POLL    # if n=0, keep polling

    lui  x20, 0xABCD0       # x20 = 0xABCD0000 (for 7-seg display)
    jal  ra,  rec_sum       # CALL rec_sum(n) -> result in a0
    add  a0,  a0,  x20      # combine: upper=ABCD, lower=sum
    sw   a0,  0(x31)        # write to MMIO -> 7-seg=ABCD, LEDs=sum

HALT:
    jal  x0,  HALT         # freeze result on display

# ============================================================
# rec_sum(n): returns sum = 1+2+...+n in a0
# Base case: n=0 -> return 0 (a0 already 0)
# Recursive: push ra and n, call rec_sum(n-1), pop, add n
# ============================================================
rec_sum:
    bne  a0, x0, do_recurse # BNE: if n != 0, recurse
    jalr x0, ra, 0          # base case: return (a0=0)

do_recurse:
    addi sp, sp, -8         # push stack frame
    sw   ra, 4(sp)          # save return address
    sw   a0, 0(sp)          # save n
    addi a0, a0, -1         # n-1
    jal  ra, rec_sum        # recursive call: rec_sum(n-1)
    lw   x5, 0(sp)          # restore n into x5
    lw   ra, 4(sp)          # restore return address
    addi sp, sp, 8          # pop stack frame
    add  a0, a0, x5         # sum = rec_sum(n-1) + n
    jalr x0, ra, 0          # return