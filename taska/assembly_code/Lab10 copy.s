.text
.globl _start

_start:

    # stack ptr
    addi x2,  x0, 511      # SP = 511 (top of stack area)

    #base addresses
    addi x5,  x0, 768      # x5 = SWITCH_ADDR
    addi x6,  x0, 512      # x6 = LED_ADDR
    addi x7,  x0, 1024     # x7 = RESET_ADDR

    #test value
    addi x22, x0, 3        # x22 = test value 3

    #led off
    sw   x0, 0(x6)         # all LEDs off

# ============================================================
# IDLE STATE
# Read switches, wait for non-zero input
# if non zero input move to countdown else stay in idle
# ============================================================

IDLE_STATE:

    sw   x0, 0(x6)         #no led on

SWITCH_INP:

    #cehck for reset input
    lw   x10, 0(x7)        #read reg x7 (reset)
    bne  x10, x0, IDLE_STATE   #if reset input not 0, stay in IDLE state 

    #else : read swtich inp
    lw   x10, 0(x5)        #wtv switch value in x5 we read in x10

    #if swtich inp is 0 also stay in SWITHC INP because we check for input. 
    beq  x10, x0, SWITCH_INP  # loop if input == 0

    # Input is non-zero: x10 holds the count argument
    # Call countdown subroutine with x10 as argument

    # Save return address on stack before calling
    addi x2, x2, -4        # move stack pointer down 4 bytes -(int)
    sw   x1, 0(x2)         # push return address onto stack

    jal  x1, COUNTDOWN     # call subroutine, saves PC+4 into x1

    #Restore return address from stack after returning
    lw   x1, 0(x2)         # pop return address from stack
    addi x2, x2, 4         # move stack pointer back up

    # Countdown finished or reset: go back to IDLE
    beq  x0, x0, IDLE_STATE    # unconditional jump to IDLE


# ============================================================
# COUNTDOWN SUBROUTINE
# Argument:  x10 = initial count value
# Decrements count to zero, updates LEDs each step
# Saves and restores x11, x12 using the stack
# Checks reset at every step
# ============================================================

COUNTDOWN:

    # Save registers x11 and x12 on the stack
    addi x2,  x2,  -8      # make room for 2 registers (8 bytes)
    sw   x11, 4(x2)        #save x11 onto stack -> value to start counter and then decrement
    sw   x12, 0(x2)        #save x12 onto stack -> delay gap

    #Load argument into counter register
    add  x11, x10, x0      #x11 = counter = initial count value

DECREMENT_LOOP:

    #Display current counter value on LEDs
    sw   x11, 0(x6)        # write counter to LED address

    # Check if counter has reached zero
    beq  x11, x0, EXIT_COUNTER    # if counter == 0, exit

    #Test value check using x22
    bne  x11, x22, SKIP_TEST      # skip if counter != test value
    sw   x22, 0(x6)               # TEST MATCH: light up x22 on LEDs

SKIP_TEST:

    #check reset button before decrementing
    lw   x10, 0(x7)        #read reset register
    bne  x10, x0, RESET_NOW     #reset pressed: abort subroutine

    #Decrement counter by 1
    addi x11, x11, -1      #counter = counter - 1

    # Delay loop: approx 1 second
    addi x12, x0, 2      #x12 = delay count (500)

WAIT_LOOP:

    #Check reset inside delay loop too
    lw   x10, 0(x7)        #read reset register
    bne  x10, x0, RESET_NOW     #reset pressed: abort now

    addi x12, x12, -1      # decrement delay index
    bne  x12, x0, WAIT_LOOP       #keep looping until delay done

    # Delay done: go back to top of decrement loop
    beq  x0, x0, DECREMENT_LOOP   #unconditional jump


# ============================================================
# RESET_NOW
# Reset detected inside subroutine
# Clear LEDs, restore stack, return to caller
# ============================================================

RESET_NOW:

    sw   x0, 0(x6)         # clear LEDs immediately

    # (c) Restore x11 and x12 from stack
    lw   x11, 4(x2)        # restore x11
    lw   x12, 0(x2)        # restore x12
    addi x2,  x2, 8        # move stack pointer back up

    ret                    # return to caller (jalr x0, x1, 0)


# ============================================================
# EXIT_COUNTER
# Counter reached zero naturally
# Restore stack and return to caller
# ============================================================

EXIT_COUNTER:

    sw   x0, 0(x6)         # clear LEDs

    #Restore x11 and x12 from stack
    lw   x11, 4(x2)        # restore x11
    lw   x12, 0(x2)        # restore x12
    addi x2,  x2, 8        # move stack pointer back up

    ret                    # return to caller (jalr x0, x1, 0)