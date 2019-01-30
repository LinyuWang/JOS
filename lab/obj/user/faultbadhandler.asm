
obj/user/faultbadhandler:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3c 01 00 00       	call   800183 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 36 02 00 00       	call   80028c <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800070:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800077:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80007a:	e8 c6 00 00 00       	call   800145 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x37>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0a 00 00 00       	call   8000b5 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bb:	6a 00                	push   $0x0
  8000bd:	e8 42 00 00 00       	call   800104 <sys_env_destroy>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	89 c3                	mov    %eax,%ebx
  8000da:	89 c7                	mov    %eax,%edi
  8000dc:	89 c6                	mov    %eax,%esi
  8000de:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f5:	89 d1                	mov    %edx,%ecx
  8000f7:	89 d3                	mov    %edx,%ebx
  8000f9:	89 d7                	mov    %edx,%edi
  8000fb:	89 d6                	mov    %edx,%esi
  8000fd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
  80010a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	89 cb                	mov    %ecx,%ebx
  80011c:	89 cf                	mov    %ecx,%edi
  80011e:	89 ce                	mov    %ecx,%esi
  800120:	cd 30                	int    $0x30
	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7f 08                	jg     80012e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	50                   	push   %eax
  800132:	6a 03                	push   $0x3
  800134:	68 ca 0f 80 00       	push   $0x800fca
  800139:	6a 23                	push   $0x23
  80013b:	68 e7 0f 80 00       	push   $0x800fe7
  800140:	e8 ed 01 00 00       	call   800332 <_panic>

00800145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	57                   	push   %edi
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014b:	ba 00 00 00 00       	mov    $0x0,%edx
  800150:	b8 02 00 00 00       	mov    $0x2,%eax
  800155:	89 d1                	mov    %edx,%ecx
  800157:	89 d3                	mov    %edx,%ebx
  800159:	89 d7                	mov    %edx,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_yield>:

void
sys_yield(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016a:	ba 00 00 00 00       	mov    $0x0,%edx
  80016f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800174:	89 d1                	mov    %edx,%ecx
  800176:	89 d3                	mov    %edx,%ebx
  800178:	89 d7                	mov    %edx,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018c:	be 00 00 00 00       	mov    $0x0,%esi
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	89 f7                	mov    %esi,%edi
  8001a1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	7f 08                	jg     8001af <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001aa:	5b                   	pop    %ebx
  8001ab:	5e                   	pop    %esi
  8001ac:	5f                   	pop    %edi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	50                   	push   %eax
  8001b3:	6a 04                	push   $0x4
  8001b5:	68 ca 0f 80 00       	push   $0x800fca
  8001ba:	6a 23                	push   $0x23
  8001bc:	68 e7 0f 80 00       	push   $0x800fe7
  8001c1:	e8 6c 01 00 00       	call   800332 <_panic>

008001c6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	7f 08                	jg     8001f1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	50                   	push   %eax
  8001f5:	6a 05                	push   $0x5
  8001f7:	68 ca 0f 80 00       	push   $0x800fca
  8001fc:	6a 23                	push   $0x23
  8001fe:	68 e7 0f 80 00       	push   $0x800fe7
  800203:	e8 2a 01 00 00       	call   800332 <_panic>

00800208 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800211:	bb 00 00 00 00       	mov    $0x0,%ebx
  800216:	8b 55 08             	mov    0x8(%ebp),%edx
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	b8 06 00 00 00       	mov    $0x6,%eax
  800221:	89 df                	mov    %ebx,%edi
  800223:	89 de                	mov    %ebx,%esi
  800225:	cd 30                	int    $0x30
	if(check && ret > 0)
  800227:	85 c0                	test   %eax,%eax
  800229:	7f 08                	jg     800233 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800233:	83 ec 0c             	sub    $0xc,%esp
  800236:	50                   	push   %eax
  800237:	6a 06                	push   $0x6
  800239:	68 ca 0f 80 00       	push   $0x800fca
  80023e:	6a 23                	push   $0x23
  800240:	68 e7 0f 80 00       	push   $0x800fe7
  800245:	e8 e8 00 00 00       	call   800332 <_panic>

0080024a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	b8 08 00 00 00       	mov    $0x8,%eax
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
	if(check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7f 08                	jg     800275 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	50                   	push   %eax
  800279:	6a 08                	push   $0x8
  80027b:	68 ca 0f 80 00       	push   $0x800fca
  800280:	6a 23                	push   $0x23
  800282:	68 e7 0f 80 00       	push   $0x800fe7
  800287:	e8 a6 00 00 00       	call   800332 <_panic>

0080028c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a5:	89 df                	mov    %ebx,%edi
  8002a7:	89 de                	mov    %ebx,%esi
  8002a9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	7f 08                	jg     8002b7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	50                   	push   %eax
  8002bb:	6a 09                	push   $0x9
  8002bd:	68 ca 0f 80 00       	push   $0x800fca
  8002c2:	6a 23                	push   $0x23
  8002c4:	68 e7 0f 80 00       	push   $0x800fe7
  8002c9:	e8 64 00 00 00       	call   800332 <_panic>

008002ce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002df:	be 00 00 00 00       	mov    $0x0,%esi
  8002e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ea:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	89 cb                	mov    %ecx,%ebx
  800309:	89 cf                	mov    %ecx,%edi
  80030b:	89 ce                	mov    %ecx,%esi
  80030d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7f 08                	jg     80031b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031b:	83 ec 0c             	sub    $0xc,%esp
  80031e:	50                   	push   %eax
  80031f:	6a 0c                	push   $0xc
  800321:	68 ca 0f 80 00       	push   $0x800fca
  800326:	6a 23                	push   $0x23
  800328:	68 e7 0f 80 00       	push   $0x800fe7
  80032d:	e8 00 00 00 00       	call   800332 <_panic>

00800332 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800337:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800340:	e8 00 fe ff ff       	call   800145 <sys_getenvid>
  800345:	83 ec 0c             	sub    $0xc,%esp
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	56                   	push   %esi
  80034f:	50                   	push   %eax
  800350:	68 f8 0f 80 00       	push   $0x800ff8
  800355:	e8 b3 00 00 00       	call   80040d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	83 c4 18             	add    $0x18,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	e8 56 00 00 00       	call   8003bc <vcprintf>
	cprintf("\n");
  800366:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  80036d:	e8 9b 00 00 00       	call   80040d <cprintf>
  800372:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800375:	cc                   	int3   
  800376:	eb fd                	jmp    800375 <_panic+0x43>

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	74 09                	je     8003a0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800397:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	68 ff 00 00 00       	push   $0xff
  8003a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 16 fd ff ff       	call   8000c7 <sys_cputs>
		b->idx = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	eb db                	jmp    800397 <putch+0x1f>

008003bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cc:	00 00 00 
	b.cnt = 0;
  8003cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d9:	ff 75 0c             	pushl  0xc(%ebp)
  8003dc:	ff 75 08             	pushl  0x8(%ebp)
  8003df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e5:	50                   	push   %eax
  8003e6:	68 78 03 80 00       	push   $0x800378
  8003eb:	e8 1a 01 00 00       	call   80050a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f0:	83 c4 08             	add    $0x8,%esp
  8003f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ff:	50                   	push   %eax
  800400:	e8 c2 fc ff ff       	call   8000c7 <sys_cputs>

	return b.cnt;
}
  800405:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040b:	c9                   	leave  
  80040c:	c3                   	ret    

0080040d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800413:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800416:	50                   	push   %eax
  800417:	ff 75 08             	pushl  0x8(%ebp)
  80041a:	e8 9d ff ff ff       	call   8003bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
  800427:	83 ec 1c             	sub    $0x1c,%esp
  80042a:	89 c7                	mov    %eax,%edi
  80042c:	89 d6                	mov    %edx,%esi
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	8b 55 0c             	mov    0xc(%ebp),%edx
  800434:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800437:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800442:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800445:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800448:	39 d3                	cmp    %edx,%ebx
  80044a:	72 05                	jb     800451 <printnum+0x30>
  80044c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80044f:	77 7a                	ja     8004cb <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800451:	83 ec 0c             	sub    $0xc,%esp
  800454:	ff 75 18             	pushl  0x18(%ebp)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045d:	53                   	push   %ebx
  80045e:	ff 75 10             	pushl  0x10(%ebp)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	ff 75 e4             	pushl  -0x1c(%ebp)
  800467:	ff 75 e0             	pushl  -0x20(%ebp)
  80046a:	ff 75 dc             	pushl  -0x24(%ebp)
  80046d:	ff 75 d8             	pushl  -0x28(%ebp)
  800470:	e8 fb 08 00 00       	call   800d70 <__udivdi3>
  800475:	83 c4 18             	add    $0x18,%esp
  800478:	52                   	push   %edx
  800479:	50                   	push   %eax
  80047a:	89 f2                	mov    %esi,%edx
  80047c:	89 f8                	mov    %edi,%eax
  80047e:	e8 9e ff ff ff       	call   800421 <printnum>
  800483:	83 c4 20             	add    $0x20,%esp
  800486:	eb 13                	jmp    80049b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	ff 75 18             	pushl  0x18(%ebp)
  80048f:	ff d7                	call   *%edi
  800491:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800494:	83 eb 01             	sub    $0x1,%ebx
  800497:	85 db                	test   %ebx,%ebx
  800499:	7f ed                	jg     800488 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	83 ec 04             	sub    $0x4,%esp
  8004a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	e8 dd 09 00 00       	call   800e90 <__umoddi3>
  8004b3:	83 c4 14             	add    $0x14,%esp
  8004b6:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004bd:	50                   	push   %eax
  8004be:	ff d7                	call   *%edi
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5f                   	pop    %edi
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    
  8004cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004ce:	eb c4                	jmp    800494 <printnum+0x73>

008004d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004df:	73 0a                	jae    8004eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	88 02                	mov    %al,(%edx)
}
  8004eb:	5d                   	pop    %ebp
  8004ec:	c3                   	ret    

008004ed <printfmt>:
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f6:	50                   	push   %eax
  8004f7:	ff 75 10             	pushl  0x10(%ebp)
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	e8 05 00 00 00       	call   80050a <vprintfmt>
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <vprintfmt>:
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	53                   	push   %ebx
  800510:	83 ec 2c             	sub    $0x2c,%esp
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051c:	e9 63 03 00 00       	jmp    800884 <vprintfmt+0x37a>
		padc = ' ';
  800521:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800525:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80052c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800533:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80053a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8d 47 01             	lea    0x1(%edi),%eax
  800542:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800545:	0f b6 17             	movzbl (%edi),%edx
  800548:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054b:	3c 55                	cmp    $0x55,%al
  80054d:	0f 87 11 04 00 00    	ja     800964 <vprintfmt+0x45a>
  800553:	0f b6 c0             	movzbl %al,%eax
  800556:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800560:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800564:	eb d9                	jmp    80053f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800569:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80056d:	eb d0                	jmp    80053f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	0f b6 d2             	movzbl %dl,%edx
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80057d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800580:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800584:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800587:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80058a:	83 f9 09             	cmp    $0x9,%ecx
  80058d:	77 55                	ja     8005e4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80058f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800592:	eb e9                	jmp    80057d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ac:	79 91                	jns    80053f <vprintfmt+0x35>
				width = precision, precision = -1;
  8005ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005bb:	eb 82                	jmp    80053f <vprintfmt+0x35>
  8005bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c7:	0f 49 d0             	cmovns %eax,%edx
  8005ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d0:	e9 6a ff ff ff       	jmp    80053f <vprintfmt+0x35>
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005df:	e9 5b ff ff ff       	jmp    80053f <vprintfmt+0x35>
  8005e4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ea:	eb bc                	jmp    8005a8 <vprintfmt+0x9e>
			lflag++;
  8005ec:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f2:	e9 48 ff ff ff       	jmp    80053f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 78 04             	lea    0x4(%eax),%edi
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	ff 30                	pushl  (%eax)
  800603:	ff d6                	call   *%esi
			break;
  800605:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800608:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060b:	e9 71 02 00 00       	jmp    800881 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 08             	cmp    $0x8,%eax
  800620:	7f 23                	jg     800645 <vprintfmt+0x13b>
  800622:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	74 18                	je     800645 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80062d:	52                   	push   %edx
  80062e:	68 3f 10 80 00       	push   $0x80103f
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 b3 fe ff ff       	call   8004ed <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800640:	e9 3c 02 00 00       	jmp    800881 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800645:	50                   	push   %eax
  800646:	68 36 10 80 00       	push   $0x801036
  80064b:	53                   	push   %ebx
  80064c:	56                   	push   %esi
  80064d:	e8 9b fe ff ff       	call   8004ed <printfmt>
  800652:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800655:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800658:	e9 24 02 00 00       	jmp    800881 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	83 c0 04             	add    $0x4,%eax
  800663:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80066b:	85 ff                	test   %edi,%edi
  80066d:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  800672:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800675:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800679:	0f 8e bd 00 00 00    	jle    80073c <vprintfmt+0x232>
  80067f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800683:	75 0e                	jne    800693 <vprintfmt+0x189>
  800685:	89 75 08             	mov    %esi,0x8(%ebp)
  800688:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800691:	eb 6d                	jmp    800700 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	ff 75 d0             	pushl  -0x30(%ebp)
  800699:	57                   	push   %edi
  80069a:	e8 6d 03 00 00       	call   800a0c <strnlen>
  80069f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a2:	29 c1                	sub    %eax,%ecx
  8006a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b6:	eb 0f                	jmp    8006c7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c1:	83 ef 01             	sub    $0x1,%edi
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	85 ff                	test   %edi,%edi
  8006c9:	7f ed                	jg     8006b8 <vprintfmt+0x1ae>
  8006cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d1:	85 c9                	test   %ecx,%ecx
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	0f 49 c1             	cmovns %ecx,%eax
  8006db:	29 c1                	sub    %eax,%ecx
  8006dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e6:	89 cb                	mov    %ecx,%ebx
  8006e8:	eb 16                	jmp    800700 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ee:	75 31                	jne    800721 <vprintfmt+0x217>
					putch(ch, putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	50                   	push   %eax
  8006f7:	ff 55 08             	call   *0x8(%ebp)
  8006fa:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fd:	83 eb 01             	sub    $0x1,%ebx
  800700:	83 c7 01             	add    $0x1,%edi
  800703:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800707:	0f be c2             	movsbl %dl,%eax
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 59                	je     800767 <vprintfmt+0x25d>
  80070e:	85 f6                	test   %esi,%esi
  800710:	78 d8                	js     8006ea <vprintfmt+0x1e0>
  800712:	83 ee 01             	sub    $0x1,%esi
  800715:	79 d3                	jns    8006ea <vprintfmt+0x1e0>
  800717:	89 df                	mov    %ebx,%edi
  800719:	8b 75 08             	mov    0x8(%ebp),%esi
  80071c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071f:	eb 37                	jmp    800758 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800721:	0f be d2             	movsbl %dl,%edx
  800724:	83 ea 20             	sub    $0x20,%edx
  800727:	83 fa 5e             	cmp    $0x5e,%edx
  80072a:	76 c4                	jbe    8006f0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	6a 3f                	push   $0x3f
  800734:	ff 55 08             	call   *0x8(%ebp)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb c1                	jmp    8006fd <vprintfmt+0x1f3>
  80073c:	89 75 08             	mov    %esi,0x8(%ebp)
  80073f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800748:	eb b6                	jmp    800700 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 20                	push   $0x20
  800750:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800752:	83 ef 01             	sub    $0x1,%edi
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	85 ff                	test   %edi,%edi
  80075a:	7f ee                	jg     80074a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80075c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
  800762:	e9 1a 01 00 00       	jmp    800881 <vprintfmt+0x377>
  800767:	89 df                	mov    %ebx,%edi
  800769:	8b 75 08             	mov    0x8(%ebp),%esi
  80076c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076f:	eb e7                	jmp    800758 <vprintfmt+0x24e>
	if (lflag >= 2)
  800771:	83 f9 01             	cmp    $0x1,%ecx
  800774:	7e 3f                	jle    8007b5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8b 50 04             	mov    0x4(%eax),%edx
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800781:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 40 08             	lea    0x8(%eax),%eax
  80078a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80078d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800791:	79 5c                	jns    8007ef <vprintfmt+0x2e5>
				putch('-', putdat);
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	53                   	push   %ebx
  800797:	6a 2d                	push   $0x2d
  800799:	ff d6                	call   *%esi
				num = -(long long) num;
  80079b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007a1:	f7 da                	neg    %edx
  8007a3:	83 d1 00             	adc    $0x0,%ecx
  8007a6:	f7 d9                	neg    %ecx
  8007a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b0:	e9 b2 00 00 00       	jmp    800867 <vprintfmt+0x35d>
	else if (lflag)
  8007b5:	85 c9                	test   %ecx,%ecx
  8007b7:	75 1b                	jne    8007d4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c1:	89 c1                	mov    %eax,%ecx
  8007c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d2:	eb b9                	jmp    80078d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dc:	89 c1                	mov    %eax,%ecx
  8007de:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ed:	eb 9e                	jmp    80078d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fa:	eb 6b                	jmp    800867 <vprintfmt+0x35d>
	if (lflag >= 2)
  8007fc:	83 f9 01             	cmp    $0x1,%ecx
  8007ff:	7e 15                	jle    800816 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	8b 48 04             	mov    0x4(%eax),%ecx
  800809:	8d 40 08             	lea    0x8(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800814:	eb 51                	jmp    800867 <vprintfmt+0x35d>
	else if (lflag)
  800816:	85 c9                	test   %ecx,%ecx
  800818:	75 17                	jne    800831 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082f:	eb 36                	jmp    800867 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 10                	mov    (%eax),%edx
  800836:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083b:	8d 40 04             	lea    0x4(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
  800846:	eb 1f                	jmp    800867 <vprintfmt+0x35d>
	if (lflag >= 2)
  800848:	83 f9 01             	cmp    $0x1,%ecx
  80084b:	7e 5b                	jle    8008a8 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 50 04             	mov    0x4(%eax),%edx
  800853:	8b 00                	mov    (%eax),%eax
  800855:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800858:	8d 49 08             	lea    0x8(%ecx),%ecx
  80085b:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80085e:	89 d1                	mov    %edx,%ecx
  800860:	89 c2                	mov    %eax,%edx
			base = 8;
  800862:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800867:	83 ec 0c             	sub    $0xc,%esp
  80086a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80086e:	57                   	push   %edi
  80086f:	ff 75 e0             	pushl  -0x20(%ebp)
  800872:	50                   	push   %eax
  800873:	51                   	push   %ecx
  800874:	52                   	push   %edx
  800875:	89 da                	mov    %ebx,%edx
  800877:	89 f0                	mov    %esi,%eax
  800879:	e8 a3 fb ff ff       	call   800421 <printnum>
			break;
  80087e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	0f 84 8d fc ff ff    	je     800521 <vprintfmt+0x17>
			if (ch == '\0')
  800894:	85 c0                	test   %eax,%eax
  800896:	0f 84 e8 00 00 00    	je     800984 <vprintfmt+0x47a>
			putch(ch, putdat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	50                   	push   %eax
  8008a1:	ff d6                	call   *%esi
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb dc                	jmp    800884 <vprintfmt+0x37a>
	else if (lflag)
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	75 13                	jne    8008bf <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8b 10                	mov    (%eax),%edx
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	99                   	cltd   
  8008b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008bd:	eb 9f                	jmp    80085e <vprintfmt+0x354>
		return va_arg(*ap, long);
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8b 10                	mov    (%eax),%edx
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	99                   	cltd   
  8008c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ca:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008d0:	eb 8c                	jmp    80085e <vprintfmt+0x354>
			putch('0', putdat);
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	53                   	push   %ebx
  8008d6:	6a 30                	push   $0x30
  8008d8:	ff d6                	call   *%esi
			putch('x', putdat);
  8008da:	83 c4 08             	add    $0x8,%esp
  8008dd:	53                   	push   %ebx
  8008de:	6a 78                	push   $0x78
  8008e0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008ec:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008ef:	8d 40 04             	lea    0x4(%eax),%eax
  8008f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008fa:	e9 68 ff ff ff       	jmp    800867 <vprintfmt+0x35d>
	if (lflag >= 2)
  8008ff:	83 f9 01             	cmp    $0x1,%ecx
  800902:	7e 18                	jle    80091c <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800904:	8b 45 14             	mov    0x14(%ebp),%eax
  800907:	8b 10                	mov    (%eax),%edx
  800909:	8b 48 04             	mov    0x4(%eax),%ecx
  80090c:	8d 40 08             	lea    0x8(%eax),%eax
  80090f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800912:	b8 10 00 00 00       	mov    $0x10,%eax
  800917:	e9 4b ff ff ff       	jmp    800867 <vprintfmt+0x35d>
	else if (lflag)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	75 1a                	jne    80093a <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8b 10                	mov    (%eax),%edx
  800925:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092a:	8d 40 04             	lea    0x4(%eax),%eax
  80092d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800930:	b8 10 00 00 00       	mov    $0x10,%eax
  800935:	e9 2d ff ff ff       	jmp    800867 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8b 10                	mov    (%eax),%edx
  80093f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800944:	8d 40 04             	lea    0x4(%eax),%eax
  800947:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094a:	b8 10 00 00 00       	mov    $0x10,%eax
  80094f:	e9 13 ff ff ff       	jmp    800867 <vprintfmt+0x35d>
			putch(ch, putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 25                	push   $0x25
  80095a:	ff d6                	call   *%esi
			break;
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	e9 1d ff ff ff       	jmp    800881 <vprintfmt+0x377>
			putch('%', putdat);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	53                   	push   %ebx
  800968:	6a 25                	push   $0x25
  80096a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	89 f8                	mov    %edi,%eax
  800971:	eb 03                	jmp    800976 <vprintfmt+0x46c>
  800973:	83 e8 01             	sub    $0x1,%eax
  800976:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80097a:	75 f7                	jne    800973 <vprintfmt+0x469>
  80097c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80097f:	e9 fd fe ff ff       	jmp    800881 <vprintfmt+0x377>
}
  800984:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 18             	sub    $0x18,%esp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800998:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80099f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a9:	85 c0                	test   %eax,%eax
  8009ab:	74 26                	je     8009d3 <vsnprintf+0x47>
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	7e 22                	jle    8009d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b1:	ff 75 14             	pushl  0x14(%ebp)
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ba:	50                   	push   %eax
  8009bb:	68 d0 04 80 00       	push   $0x8004d0
  8009c0:	e8 45 fb ff ff       	call   80050a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ce:	83 c4 10             	add    $0x10,%esp
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    
		return -E_INVAL;
  8009d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d8:	eb f7                	jmp    8009d1 <vsnprintf+0x45>

008009da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e3:	50                   	push   %eax
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ea:	ff 75 08             	pushl  0x8(%ebp)
  8009ed:	e8 9a ff ff ff       	call   80098c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 03                	jmp    800a04 <strlen+0x10>
		n++;
  800a01:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a04:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a08:	75 f7                	jne    800a01 <strlen+0xd>
	return n;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 03                	jmp    800a1f <strnlen+0x13>
		n++;
  800a1c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	74 06                	je     800a29 <strnlen+0x1d>
  800a23:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a27:	75 f3                	jne    800a1c <strnlen+0x10>
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
  800a3d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a41:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a44:	84 db                	test   %bl,%bl
  800a46:	75 ef                	jne    800a37 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a52:	53                   	push   %ebx
  800a53:	e8 9c ff ff ff       	call   8009f4 <strlen>
  800a58:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	01 d8                	add    %ebx,%eax
  800a60:	50                   	push   %eax
  800a61:	e8 c5 ff ff ff       	call   800a2b <strcpy>
	return dst;
}
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 75 08             	mov    0x8(%ebp),%esi
  800a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7d:	89 f2                	mov    %esi,%edx
  800a7f:	eb 0f                	jmp    800a90 <strncpy+0x23>
		*dst++ = *src;
  800a81:	83 c2 01             	add    $0x1,%edx
  800a84:	0f b6 01             	movzbl (%ecx),%eax
  800a87:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a8d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a90:	39 da                	cmp    %ebx,%edx
  800a92:	75 ed                	jne    800a81 <strncpy+0x14>
	}
	return ret;
}
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aa8:	89 f0                	mov    %esi,%eax
  800aaa:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aae:	85 c9                	test   %ecx,%ecx
  800ab0:	75 0b                	jne    800abd <strlcpy+0x23>
  800ab2:	eb 17                	jmp    800acb <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab4:	83 c2 01             	add    $0x1,%edx
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800abd:	39 d8                	cmp    %ebx,%eax
  800abf:	74 07                	je     800ac8 <strlcpy+0x2e>
  800ac1:	0f b6 0a             	movzbl (%edx),%ecx
  800ac4:	84 c9                	test   %cl,%cl
  800ac6:	75 ec                	jne    800ab4 <strlcpy+0x1a>
		*dst = '\0';
  800ac8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800acb:	29 f0                	sub    %esi,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ada:	eb 06                	jmp    800ae2 <strcmp+0x11>
		p++, q++;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ae2:	0f b6 01             	movzbl (%ecx),%eax
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 04                	je     800aed <strcmp+0x1c>
  800ae9:	3a 02                	cmp    (%edx),%al
  800aeb:	74 ef                	je     800adc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 c0             	movzbl %al,%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b06:	eb 06                	jmp    800b0e <strncmp+0x17>
		n--, p++, q++;
  800b08:	83 c0 01             	add    $0x1,%eax
  800b0b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b0e:	39 d8                	cmp    %ebx,%eax
  800b10:	74 16                	je     800b28 <strncmp+0x31>
  800b12:	0f b6 08             	movzbl (%eax),%ecx
  800b15:	84 c9                	test   %cl,%cl
  800b17:	74 04                	je     800b1d <strncmp+0x26>
  800b19:	3a 0a                	cmp    (%edx),%cl
  800b1b:	74 eb                	je     800b08 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1d:	0f b6 00             	movzbl (%eax),%eax
  800b20:	0f b6 12             	movzbl (%edx),%edx
  800b23:	29 d0                	sub    %edx,%eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    
		return 0;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	eb f6                	jmp    800b25 <strncmp+0x2e>

00800b2f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b39:	0f b6 10             	movzbl (%eax),%edx
  800b3c:	84 d2                	test   %dl,%dl
  800b3e:	74 09                	je     800b49 <strchr+0x1a>
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 0a                	je     800b4e <strchr+0x1f>
	for (; *s; s++)
  800b44:	83 c0 01             	add    $0x1,%eax
  800b47:	eb f0                	jmp    800b39 <strchr+0xa>
			return (char *) s;
	return 0;
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5a:	eb 03                	jmp    800b5f <strfind+0xf>
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	74 04                	je     800b6a <strfind+0x1a>
  800b66:	84 d2                	test   %dl,%dl
  800b68:	75 f2                	jne    800b5c <strfind+0xc>
			break;
	return (char *) s;
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b78:	85 c9                	test   %ecx,%ecx
  800b7a:	74 13                	je     800b8f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b82:	75 05                	jne    800b89 <memset+0x1d>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	74 0d                	je     800b96 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8c:	fc                   	cld    
  800b8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8f:	89 f8                	mov    %edi,%eax
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    
		c &= 0xFF;
  800b96:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	c1 e3 08             	shl    $0x8,%ebx
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	c1 e0 18             	shl    $0x18,%eax
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	c1 e6 10             	shl    $0x10,%esi
  800ba9:	09 f0                	or     %esi,%eax
  800bab:	09 c2                	or     %eax,%edx
  800bad:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800baf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bb2:	89 d0                	mov    %edx,%eax
  800bb4:	fc                   	cld    
  800bb5:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb7:	eb d6                	jmp    800b8f <memset+0x23>

00800bb9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc7:	39 c6                	cmp    %eax,%esi
  800bc9:	73 35                	jae    800c00 <memmove+0x47>
  800bcb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bce:	39 c2                	cmp    %eax,%edx
  800bd0:	76 2e                	jbe    800c00 <memmove+0x47>
		s += n;
		d += n;
  800bd2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	09 fe                	or     %edi,%esi
  800bd9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdf:	74 0c                	je     800bed <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be1:	83 ef 01             	sub    $0x1,%edi
  800be4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800be7:	fd                   	std    
  800be8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bea:	fc                   	cld    
  800beb:	eb 21                	jmp    800c0e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bed:	f6 c1 03             	test   $0x3,%cl
  800bf0:	75 ef                	jne    800be1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf2:	83 ef 04             	sub    $0x4,%edi
  800bf5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bfb:	fd                   	std    
  800bfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfe:	eb ea                	jmp    800bea <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c00:	89 f2                	mov    %esi,%edx
  800c02:	09 c2                	or     %eax,%edx
  800c04:	f6 c2 03             	test   $0x3,%dl
  800c07:	74 09                	je     800c12 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c12:	f6 c1 03             	test   $0x3,%cl
  800c15:	75 f2                	jne    800c09 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	fc                   	cld    
  800c1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1f:	eb ed                	jmp    800c0e <memmove+0x55>

00800c21 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	ff 75 08             	pushl  0x8(%ebp)
  800c2d:	e8 87 ff ff ff       	call   800bb9 <memmove>
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	39 f0                	cmp    %esi,%eax
  800c46:	74 1c                	je     800c64 <memcmp+0x30>
		if (*s1 != *s2)
  800c48:	0f b6 08             	movzbl (%eax),%ecx
  800c4b:	0f b6 1a             	movzbl (%edx),%ebx
  800c4e:	38 d9                	cmp    %bl,%cl
  800c50:	75 08                	jne    800c5a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	83 c2 01             	add    $0x1,%edx
  800c58:	eb ea                	jmp    800c44 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c5a:	0f b6 c1             	movzbl %cl,%eax
  800c5d:	0f b6 db             	movzbl %bl,%ebx
  800c60:	29 d8                	sub    %ebx,%eax
  800c62:	eb 05                	jmp    800c69 <memcmp+0x35>
	}

	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c76:	89 c2                	mov    %eax,%edx
  800c78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	73 09                	jae    800c88 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7f:	38 08                	cmp    %cl,(%eax)
  800c81:	74 05                	je     800c88 <memfind+0x1b>
	for (; s < ends; s++)
  800c83:	83 c0 01             	add    $0x1,%eax
  800c86:	eb f3                	jmp    800c7b <memfind+0xe>
			break;
	return (void *) s;
}
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c96:	eb 03                	jmp    800c9b <strtol+0x11>
		s++;
  800c98:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c9b:	0f b6 01             	movzbl (%ecx),%eax
  800c9e:	3c 20                	cmp    $0x20,%al
  800ca0:	74 f6                	je     800c98 <strtol+0xe>
  800ca2:	3c 09                	cmp    $0x9,%al
  800ca4:	74 f2                	je     800c98 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ca6:	3c 2b                	cmp    $0x2b,%al
  800ca8:	74 2e                	je     800cd8 <strtol+0x4e>
	int neg = 0;
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800caf:	3c 2d                	cmp    $0x2d,%al
  800cb1:	74 2f                	je     800ce2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cb9:	75 05                	jne    800cc0 <strtol+0x36>
  800cbb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbe:	74 2c                	je     800cec <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc0:	85 db                	test   %ebx,%ebx
  800cc2:	75 0a                	jne    800cce <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc4:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccc:	74 28                	je     800cf6 <strtol+0x6c>
		base = 10;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cd6:	eb 50                	jmp    800d28 <strtol+0x9e>
		s++;
  800cd8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cdb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce0:	eb d1                	jmp    800cb3 <strtol+0x29>
		s++, neg = 1;
  800ce2:	83 c1 01             	add    $0x1,%ecx
  800ce5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cea:	eb c7                	jmp    800cb3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf0:	74 0e                	je     800d00 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cf2:	85 db                	test   %ebx,%ebx
  800cf4:	75 d8                	jne    800cce <strtol+0x44>
		s++, base = 8;
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cfe:	eb ce                	jmp    800cce <strtol+0x44>
		s += 2, base = 16;
  800d00:	83 c1 02             	add    $0x2,%ecx
  800d03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d08:	eb c4                	jmp    800cce <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d0d:	89 f3                	mov    %esi,%ebx
  800d0f:	80 fb 19             	cmp    $0x19,%bl
  800d12:	77 29                	ja     800d3d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d14:	0f be d2             	movsbl %dl,%edx
  800d17:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d1d:	7d 30                	jge    800d4f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d1f:	83 c1 01             	add    $0x1,%ecx
  800d22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d26:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d28:	0f b6 11             	movzbl (%ecx),%edx
  800d2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d2e:	89 f3                	mov    %esi,%ebx
  800d30:	80 fb 09             	cmp    $0x9,%bl
  800d33:	77 d5                	ja     800d0a <strtol+0x80>
			dig = *s - '0';
  800d35:	0f be d2             	movsbl %dl,%edx
  800d38:	83 ea 30             	sub    $0x30,%edx
  800d3b:	eb dd                	jmp    800d1a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d40:	89 f3                	mov    %esi,%ebx
  800d42:	80 fb 19             	cmp    $0x19,%bl
  800d45:	77 08                	ja     800d4f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d47:	0f be d2             	movsbl %dl,%edx
  800d4a:	83 ea 37             	sub    $0x37,%edx
  800d4d:	eb cb                	jmp    800d1a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d53:	74 05                	je     800d5a <strtol+0xd0>
		*endptr = (char *) s;
  800d55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d58:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	f7 da                	neg    %edx
  800d5e:	85 ff                	test   %edi,%edi
  800d60:	0f 45 c2             	cmovne %edx,%eax
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d87:	85 d2                	test   %edx,%edx
  800d89:	75 35                	jne    800dc0 <__udivdi3+0x50>
  800d8b:	39 f3                	cmp    %esi,%ebx
  800d8d:	0f 87 bd 00 00 00    	ja     800e50 <__udivdi3+0xe0>
  800d93:	85 db                	test   %ebx,%ebx
  800d95:	89 d9                	mov    %ebx,%ecx
  800d97:	75 0b                	jne    800da4 <__udivdi3+0x34>
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f3                	div    %ebx
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	31 d2                	xor    %edx,%edx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	f7 f1                	div    %ecx
  800daa:	89 c6                	mov    %eax,%esi
  800dac:	89 e8                	mov    %ebp,%eax
  800dae:	89 f7                	mov    %esi,%edi
  800db0:	f7 f1                	div    %ecx
  800db2:	89 fa                	mov    %edi,%edx
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 f2                	cmp    %esi,%edx
  800dc2:	77 7c                	ja     800e40 <__udivdi3+0xd0>
  800dc4:	0f bd fa             	bsr    %edx,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0xf8>
  800dd0:	89 f9                	mov    %edi,%ecx
  800dd2:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd7:	29 f8                	sub    %edi,%eax
  800dd9:	d3 e2                	shl    %cl,%edx
  800ddb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	89 da                	mov    %ebx,%edx
  800de3:	d3 ea                	shr    %cl,%edx
  800de5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800de9:	09 d1                	or     %edx,%ecx
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e3                	shl    %cl,%ebx
  800df5:	89 c1                	mov    %eax,%ecx
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	89 f9                	mov    %edi,%ecx
  800dfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dff:	d3 e6                	shl    %cl,%esi
  800e01:	89 eb                	mov    %ebp,%ebx
  800e03:	89 c1                	mov    %eax,%ecx
  800e05:	d3 eb                	shr    %cl,%ebx
  800e07:	09 de                	or     %ebx,%esi
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	f7 74 24 08          	divl   0x8(%esp)
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	f7 64 24 0c          	mull   0xc(%esp)
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	72 0c                	jb     800e27 <__udivdi3+0xb7>
  800e1b:	89 f9                	mov    %edi,%ecx
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	39 c5                	cmp    %eax,%ebp
  800e21:	73 5d                	jae    800e80 <__udivdi3+0x110>
  800e23:	39 d6                	cmp    %edx,%esi
  800e25:	75 59                	jne    800e80 <__udivdi3+0x110>
  800e27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2a:	31 ff                	xor    %edi,%edi
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	83 c4 1c             	add    $0x1c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	8d 76 00             	lea    0x0(%esi),%esi
  800e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	31 c0                	xor    %eax,%eax
  800e44:	89 fa                	mov    %edi,%edx
  800e46:	83 c4 1c             	add    $0x1c,%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    
  800e4e:	66 90                	xchg   %ax,%ax
  800e50:	31 ff                	xor    %edi,%edi
  800e52:	89 e8                	mov    %ebp,%eax
  800e54:	89 f2                	mov    %esi,%edx
  800e56:	f7 f3                	div    %ebx
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x102>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 d2                	ja     800e44 <__udivdi3+0xd4>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb cb                	jmp    800e44 <__udivdi3+0xd4>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	31 ff                	xor    %edi,%edi
  800e84:	eb be                	jmp    800e44 <__udivdi3+0xd4>
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 ed                	test   %ebp,%ebp
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	89 da                	mov    %ebx,%edx
  800ead:	75 19                	jne    800ec8 <__umoddi3+0x38>
  800eaf:	39 df                	cmp    %ebx,%edi
  800eb1:	0f 86 b1 00 00 00    	jbe    800f68 <__umoddi3+0xd8>
  800eb7:	f7 f7                	div    %edi
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 dd                	cmp    %ebx,%ebp
  800eca:	77 f1                	ja     800ebd <__umoddi3+0x2d>
  800ecc:	0f bd cd             	bsr    %ebp,%ecx
  800ecf:	83 f1 1f             	xor    $0x1f,%ecx
  800ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ed6:	0f 84 b4 00 00 00    	je     800f90 <__umoddi3+0x100>
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	29 c2                	sub    %eax,%edx
  800ee9:	89 c1                	mov    %eax,%ecx
  800eeb:	89 f8                	mov    %edi,%eax
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	89 d1                	mov    %edx,%ecx
  800ef1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	09 c5                	or     %eax,%ebp
  800ef9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800efd:	89 c1                	mov    %eax,%ecx
  800eff:	d3 e7                	shl    %cl,%edi
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	d3 ef                	shr    %cl,%edi
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	89 f0                	mov    %esi,%eax
  800f0f:	d3 e3                	shl    %cl,%ebx
  800f11:	89 d1                	mov    %edx,%ecx
  800f13:	89 fa                	mov    %edi,%edx
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f1c:	09 d8                	or     %ebx,%eax
  800f1e:	f7 f5                	div    %ebp
  800f20:	d3 e6                	shl    %cl,%esi
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	f7 64 24 08          	mull   0x8(%esp)
  800f28:	39 d1                	cmp    %edx,%ecx
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	72 06                	jb     800f36 <__umoddi3+0xa6>
  800f30:	75 0e                	jne    800f40 <__umoddi3+0xb0>
  800f32:	39 c6                	cmp    %eax,%esi
  800f34:	73 0a                	jae    800f40 <__umoddi3+0xb0>
  800f36:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f3a:	19 ea                	sbb    %ebp,%edx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 c3                	mov    %eax,%ebx
  800f40:	89 ca                	mov    %ecx,%edx
  800f42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f47:	29 de                	sub    %ebx,%esi
  800f49:	19 fa                	sbb    %edi,%edx
  800f4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f4f:	89 d0                	mov    %edx,%eax
  800f51:	d3 e0                	shl    %cl,%eax
  800f53:	89 d9                	mov    %ebx,%ecx
  800f55:	d3 ee                	shr    %cl,%esi
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	09 f0                	or     %esi,%eax
  800f5b:	83 c4 1c             	add    $0x1c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	85 ff                	test   %edi,%edi
  800f6a:	89 f9                	mov    %edi,%ecx
  800f6c:	75 0b                	jne    800f79 <__umoddi3+0xe9>
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f7                	div    %edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f1                	div    %ecx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	f7 f1                	div    %ecx
  800f83:	e9 31 ff ff ff       	jmp    800eb9 <__umoddi3+0x29>
  800f88:	90                   	nop
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	39 dd                	cmp    %ebx,%ebp
  800f92:	72 08                	jb     800f9c <__umoddi3+0x10c>
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	0f 87 21 ff ff ff    	ja     800ebd <__umoddi3+0x2d>
  800f9c:	89 da                	mov    %ebx,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	29 f8                	sub    %edi,%eax
  800fa2:	19 ea                	sbb    %ebp,%edx
  800fa4:	e9 14 ff ff ff       	jmp    800ebd <__umoddi3+0x2d>
