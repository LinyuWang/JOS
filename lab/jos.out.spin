+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
c[?7l[2J[0mSeaBIOS (version rel-1.11.2-0-gf9626ccb91-prebuilt.qemu-project.org)


iPXE (http://ipxe.org) 00:03.0 C980 PCI2.10 PnP PMM+07F91530+07EF1530 C980
Press Ctrl-B to configure iPXE (PCI 00:03.0)...                                                                               


Booting from Hard Disk..
6828 decimal is 15254 octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
I am the parent.  Forking the child...
[00001000] user panic in <unknown> at lib/fork.c:81: fork not implemented
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
TRAP frame at 0xf02b0000 from CPU 0
  edi  0x00000000
  esi  0x008010d6
  ebp  0xeebfdf90
  oesp 0xefffffdc
  ebx  0xeebfdfa4
  edx  0xeebfde48
  ecx  0x00000001
  eax  0x00000001
  es   0x----0023
  ds   0x----0023
  trap 0x00000003 Breakpoint
  err  0x00000000
  eip  0x00800de4
  cs   0x----001b
  flag 0x00000086
  esp  0xeebfdf88
  ss   0x----0023
qemu-system-i386: terminating on signal 15 from pid 1574 (make)
