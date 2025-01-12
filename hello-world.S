  # $rsp stack pointer (top of the stack) register stack pointer
  # $rbp register base pointer
  .data
msg:  .ascii "Hello World!\n"
len =  . - msg
  .text
  .global hello_world
hello_world:
  mov $1, %rax
  mov $1, %rdi
  mov $msg, %rsi
  mov $len, %rdx
  syscall
  mov $60, %rax
  mov $0, %rdi
  syscall
;; #if defined(__linux__) && defined(__ELF__)
;; .section .note.GNU-stack,"",%progbits
;; #endif
