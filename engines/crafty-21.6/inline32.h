/*
     Intel X86oinline functions for MSB(), LSB() and
     PopCnt().  Note that these are 64 bit functions and they use
     32 bit (double-word) X86 instructions.
*/
int static __inline__ PopCnt(BITBOARD word)
{
/*  r0=result, %1=tmp, %2=first input, %3=second input */
  long dummy1, dummy2, dummy3, dummy4;

asm("        xorl    %0, %0" "\n\t" "        testl   %2, %2" "\n\t" "        jz      2f" "\n\t" "1:      leal    -1(%2), %1" "\n\t" "        incl    %0" "\n\t" "        andl    %1, %2" "\n\t" "        jnz     1b" "\n\t" "2:      testl   %3, %3" "\n\t" "        jz      4f" "\n\t" "3:      leal    -1(%3), %1" "\n\t" "        incl    %0" "\n\t" "        andl    %1, %3" "\n\t" "        jnz     3b" "\n\t" "4:" "\n\t":"=&q"(dummy1), "=&q"(dummy2), "=&q"(dummy3),
      "=&q"
      (dummy4)
:    "2"((int) (word >> 32)), "3"((int) word)
:    "cc");
  return (dummy1);
}

int static __inline__ MSB(BITBOARD word)
{
  int dummy1, dummy2, dummy3;

asm("        bsr     %1, %0" "\n\t" "        jnz     1f" "\n\t" "        bsr     %2, %0" "\n\t" "        jnz     2f" "\n\t" "        movl    $64, %0" "\n\t" "        jmp     2f" "\n\t" "1:      addl    $32,%0" "\n\t" "2:":"=&q"(dummy1), "=&q"(dummy2),
      "=&q"
      (dummy3)
:    "1"((int) (word >> 32)), "2"((int) word)
:    "cc");
  return (dummy1);
}

int static __inline__ LSB(BITBOARD word)
{
  int dummy1, dummy2, dummy3;

asm("        bsf     %2, %0" "\n\t" "        jnz     2f" "\n\t" "        bsf     %1, %0" "\n\t" "        jnz     1f" "\n\t" "        movl    $64, %0" "\n\t" "        jmp     2f" "\n\t" "1:      addl    $32,%0" "\n\t" "2:":"=&q"(dummy1), "=&q"(dummy2),
      "=&q"
      (dummy3)
:    "1"((int) (word >> 32)), "2"((int) word)
:    "cc");
  return (dummy1);
}
