  .section .data
  .section .text
  .global avx512_8v_dot_product_asm
  .type avx512_8v_dot_product_asm, @function
avx512_8v_dot_product_asm:
  # Prologue
  pushq %rbp
  movq %rsp, %rbp

  # Since all function arguments are less or equal than 8 bytes
  # and we only have 3 arguments, their values is already present
  # in each argument register.
  # %rdi contains double *v1
  # %rsi contains double *v2
  # %rdx contains unsigned long count.
  # First let's compute how many sub-8x8 dot products we need.
  # Backup into rax rdx, which is always used to store remainders.
  mov %rdx, %rax

  # Clear src and destination register at the end to define unsigned integer div.
  xor %rdx, %rdx

  # Load divisor.
  mov $8, %rcx
  div %rcx

  # Number of cycles stored in %rax and remainder in %rdx
  # for %rax times, perform the 8x8 and accumulate step.
  # Registers:
  # - r8: counter
  # - r9: mask.
  # - r10: pointer to next 8 doubles for v1.
  # - r11: pointer to next 8 doubles for v2.

  # Init accumulator and counter.
  mov $0, %r8
  mov $0xffff, %r9
  kmovq %r9, %k1
  mov %rdi, %r10
  mov %rsi, %r11

  # Zero out the accumulator
  vxorpd %zmm2, %zmm2, %zmm2
  jmp .LOOP_CMP

.LOOP_BODY:
  # load them into mmx registers
  vmovapd (%r10), %zmm0 {%k1}{z}
  vmovapd (%r11), %zmm1 {%k1}{z}

  # Multiply zmm0 and zmm1, store result in zmm0
  # Run fused multiply add zmm2 = (zmm0 * zmm1) + zmm2, for each 8 doubles.
  vfmadd231pd %zmm0, %zmm1, %zmm2

  # Increment to next 8-doubles addresses.
  add $64, %r10
  add $64, %r11

  # Increment index.
  add $1, %r8

.LOOP_CMP:
  cmpq %rax, %r8
  jb .LOOP_BODY

  ;; # Deal with reminder, if it's zero, skip to ACCUMULATE.
  ;; # test %rdx, %rdx
  ;; # jz .ACCUMULATE

  ;; # use rdx (cl points to lower 8 bits) as mask
  ;; # mov $1, %r9
  ;; # shlx %rdx, %r9, %r9
  ;; # dec %r9
  ;; # mov $1, %rax
  ;; # mov $0, %r8
  ;; # kmovq %r9, %k1

  ;; ;; # Set remainder to 0 and increment index.
  ;; # mov $0, %rdx
  ;; # jmp .LOOP_BODY

.ACCUMULATE:
  # Accumulate final value
  vextractf64x4  $0, %zmm2, %ymm1     # ymm1 = { d0, d1, d2, d3 }
  vextractf64x4  $1, %zmm2, %ymm0     # ymm0 = { d4, d5, d6, d7 }
  vaddpd %ymm1, %ymm0, %ymm1          # ymm1 = { d4+d0, d5+d1, d6+d2, d7+d3 }

  vextractf128 $1, %ymm1, %xmm2       # xmm2 = { (d2+d6), (d3+d7) }
  vextractf128 $0, %ymm1, %xmm3       # xmm3 = { (d0+d4), (d1+d5) }
  vaddpd %xmm2, %xmm3, %xmm3          # xmm3 = { (d0+d4)+(d2+d6), (d1+d5)+(d3+d7) }

  vpermilpd $0b00000001, %xmm3, %xmm2 # xmm2 = swap double [1] <-> [0]
  vaddsd %xmm2, %xmm3, %xmm3          # xmm3[0] = p0 + p1, [1] is now duplicate
  vmovsd %xmm3, %xmm0, %xmm0

  # Epilogue.
  popq %rbp
  ret
#if defined(__linux__) && defined(__ELF__)
  .section .note.GNU-stack,"",%progbits
#endif
