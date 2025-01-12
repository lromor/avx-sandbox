  # $rsp stack pointer (top of the stack) register stack pointer
  # $rbp register base pointer
  .data
msg:  .ascii "Hello World!\n"
len =  . - msg
  .text
  .global hello_world
hello_world:
  # Function prologue.
  # Stash register containing caller stack base pointer data.
  # NOTE: this has nothing to do with the instructions (%rip).
  pushq %rbp
  # Store the current stack pointer as base from which we can allocate stuff.
  movq %rsp, %rbp
  mov $1, %rax
  mov $1, %rdi
  mov $msg, %rsi
  mov $len, %rdx
  syscall
  # Function epilogue.
  popq %rbp
  # Opposite of call, pops the stack once more
  # and jumps to that address.
  ret

#if defined(__linux__) && defined(__ELF__)
  .section .note.GNU-stack,"",%progbits
#endif
