
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 21 03 80 00       	push   $0x800321
  80003e:	6a 00                	push   $0x0
  800040:	e8 36 02 00 00       	call   80027b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005f:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800066:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800069:	e8 c6 00 00 00       	call   800134 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x37>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 42 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	89 c3                	mov    %eax,%ebx
  8000c9:	89 c7                	mov    %eax,%edi
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	b8 03 00 00 00       	mov    $0x3,%eax
  800109:	89 cb                	mov    %ecx,%ebx
  80010b:	89 cf                	mov    %ecx,%edi
  80010d:	89 ce                	mov    %ecx,%esi
  80010f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800111:	85 c0                	test   %eax,%eax
  800113:	7f 08                	jg     80011d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	50                   	push   %eax
  800121:	6a 03                	push   $0x3
  800123:	68 4a 10 80 00       	push   $0x80104a
  800128:	6a 23                	push   $0x23
  80012a:	68 67 10 80 00       	push   $0x801067
  80012f:	e8 1f 02 00 00       	call   800353 <_panic>

00800134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 02 00 00 00       	mov    $0x2,%eax
  800144:	89 d1                	mov    %edx,%ecx
  800146:	89 d3                	mov    %edx,%ebx
  800148:	89 d7                	mov    %edx,%edi
  80014a:	89 d6                	mov    %edx,%esi
  80014c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_yield>:

void
sys_yield(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80017b:	be 00 00 00 00       	mov    $0x0,%esi
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	89 f7                	mov    %esi,%edi
  800190:	cd 30                	int    $0x30
	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7f 08                	jg     80019e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	50                   	push   %eax
  8001a2:	6a 04                	push   $0x4
  8001a4:	68 4a 10 80 00       	push   $0x80104a
  8001a9:	6a 23                	push   $0x23
  8001ab:	68 67 10 80 00       	push   $0x801067
  8001b0:	e8 9e 01 00 00       	call   800353 <_panic>

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7f 08                	jg     8001e0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	6a 05                	push   $0x5
  8001e6:	68 4a 10 80 00       	push   $0x80104a
  8001eb:	6a 23                	push   $0x23
  8001ed:	68 67 10 80 00       	push   $0x801067
  8001f2:	e8 5c 01 00 00       	call   800353 <_panic>

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800200:	bb 00 00 00 00       	mov    $0x0,%ebx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	b8 06 00 00 00       	mov    $0x6,%eax
  800210:	89 df                	mov    %ebx,%edi
  800212:	89 de                	mov    %ebx,%esi
  800214:	cd 30                	int    $0x30
	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7f 08                	jg     800222 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	50                   	push   %eax
  800226:	6a 06                	push   $0x6
  800228:	68 4a 10 80 00       	push   $0x80104a
  80022d:	6a 23                	push   $0x23
  80022f:	68 67 10 80 00       	push   $0x801067
  800234:	e8 1a 01 00 00       	call   800353 <_panic>

00800239 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800242:	bb 00 00 00 00       	mov    $0x0,%ebx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	b8 08 00 00 00       	mov    $0x8,%eax
  800252:	89 df                	mov    %ebx,%edi
  800254:	89 de                	mov    %ebx,%esi
  800256:	cd 30                	int    $0x30
	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7f 08                	jg     800264 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	50                   	push   %eax
  800268:	6a 08                	push   $0x8
  80026a:	68 4a 10 80 00       	push   $0x80104a
  80026f:	6a 23                	push   $0x23
  800271:	68 67 10 80 00       	push   $0x801067
  800276:	e8 d8 00 00 00       	call   800353 <_panic>

0080027b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	b8 09 00 00 00       	mov    $0x9,%eax
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7f 08                	jg     8002a6 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	50                   	push   %eax
  8002aa:	6a 09                	push   $0x9
  8002ac:	68 4a 10 80 00       	push   $0x80104a
  8002b1:	6a 23                	push   $0x23
  8002b3:	68 67 10 80 00       	push   $0x801067
  8002b8:	e8 96 00 00 00       	call   800353 <_panic>

008002bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ce:	be 00 00 00 00       	mov    $0x0,%esi
  8002d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f6:	89 cb                	mov    %ecx,%ebx
  8002f8:	89 cf                	mov    %ecx,%edi
  8002fa:	89 ce                	mov    %ecx,%esi
  8002fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7f 08                	jg     80030a <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	50                   	push   %eax
  80030e:	6a 0c                	push   $0xc
  800310:	68 4a 10 80 00       	push   $0x80104a
  800315:	6a 23                	push   $0x23
  800317:	68 67 10 80 00       	push   $0x801067
  80031c:	e8 32 00 00 00       	call   800353 <_panic>

00800321 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800321:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800322:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800327:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800329:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	lea 48(%esp), %eax
  80032c:	8d 44 24 30          	lea    0x30(%esp),%eax
	movl (%eax), %eax
  800330:	8b 00                	mov    (%eax),%eax
	lea 40(%esp), %ebx
  800332:	8d 5c 24 28          	lea    0x28(%esp),%ebx
	movl (%ebx), %ebx
  800336:	8b 1b                	mov    (%ebx),%ebx
	subl $4, %eax
  800338:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  80033b:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	add $8, %esp
  80033d:	83 c4 08             	add    $0x8,%esp
	pop %edi
  800340:	5f                   	pop    %edi
	pop %esi
  800341:	5e                   	pop    %esi
	pop %ebp
  800342:	5d                   	pop    %ebp
	add $4, %esp
  800343:	83 c4 04             	add    $0x4,%esp
	pop %ebx
  800346:	5b                   	pop    %ebx
	pop %edx
  800347:	5a                   	pop    %edx
	pop %ecx
  800348:	59                   	pop    %ecx
	pop %eax
  800349:	58                   	pop    %eax
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80034a:	83 c4 04             	add    $0x4,%esp
	popfl
  80034d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80034e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	sub $4, %esp
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	c3                   	ret    

00800353 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	56                   	push   %esi
  800357:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800358:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800361:	e8 ce fd ff ff       	call   800134 <sys_getenvid>
  800366:	83 ec 0c             	sub    $0xc,%esp
  800369:	ff 75 0c             	pushl  0xc(%ebp)
  80036c:	ff 75 08             	pushl  0x8(%ebp)
  80036f:	56                   	push   %esi
  800370:	50                   	push   %eax
  800371:	68 78 10 80 00       	push   $0x801078
  800376:	e8 b3 00 00 00       	call   80042e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037b:	83 c4 18             	add    $0x18,%esp
  80037e:	53                   	push   %ebx
  80037f:	ff 75 10             	pushl  0x10(%ebp)
  800382:	e8 56 00 00 00       	call   8003dd <vcprintf>
	cprintf("\n");
  800387:	c7 04 24 9c 10 80 00 	movl   $0x80109c,(%esp)
  80038e:	e8 9b 00 00 00       	call   80042e <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800396:	cc                   	int3   
  800397:	eb fd                	jmp    800396 <_panic+0x43>

00800399 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	53                   	push   %ebx
  80039d:	83 ec 04             	sub    $0x4,%esp
  8003a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a3:	8b 13                	mov    (%ebx),%edx
  8003a5:	8d 42 01             	lea    0x1(%edx),%eax
  8003a8:	89 03                	mov    %eax,(%ebx)
  8003aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b6:	74 09                	je     8003c1 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	68 ff 00 00 00       	push   $0xff
  8003c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 e4 fc ff ff       	call   8000b6 <sys_cputs>
		b->idx = 0;
  8003d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	eb db                	jmp    8003b8 <putch+0x1f>

008003dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ed:	00 00 00 
	b.cnt = 0;
  8003f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003fa:	ff 75 0c             	pushl  0xc(%ebp)
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	68 99 03 80 00       	push   $0x800399
  80040c:	e8 1a 01 00 00       	call   80052b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800411:	83 c4 08             	add    $0x8,%esp
  800414:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800420:	50                   	push   %eax
  800421:	e8 90 fc ff ff       	call   8000b6 <sys_cputs>

	return b.cnt;
}
  800426:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800434:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 08             	pushl  0x8(%ebp)
  80043b:	e8 9d ff ff ff       	call   8003dd <vcprintf>
	va_end(ap);

	return cnt;
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	57                   	push   %edi
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
  800448:	83 ec 1c             	sub    $0x1c,%esp
  80044b:	89 c7                	mov    %eax,%edi
  80044d:	89 d6                	mov    %edx,%esi
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800458:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80045e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800463:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800466:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800469:	39 d3                	cmp    %edx,%ebx
  80046b:	72 05                	jb     800472 <printnum+0x30>
  80046d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800470:	77 7a                	ja     8004ec <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	ff 75 18             	pushl  0x18(%ebp)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80047e:	53                   	push   %ebx
  80047f:	ff 75 10             	pushl  0x10(%ebp)
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 5a 09 00 00       	call   800df0 <__udivdi3>
  800496:	83 c4 18             	add    $0x18,%esp
  800499:	52                   	push   %edx
  80049a:	50                   	push   %eax
  80049b:	89 f2                	mov    %esi,%edx
  80049d:	89 f8                	mov    %edi,%eax
  80049f:	e8 9e ff ff ff       	call   800442 <printnum>
  8004a4:	83 c4 20             	add    $0x20,%esp
  8004a7:	eb 13                	jmp    8004bc <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	ff 75 18             	pushl  0x18(%ebp)
  8004b0:	ff d7                	call   *%edi
  8004b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b5:	83 eb 01             	sub    $0x1,%ebx
  8004b8:	85 db                	test   %ebx,%ebx
  8004ba:	7f ed                	jg     8004a9 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	56                   	push   %esi
  8004c0:	83 ec 04             	sub    $0x4,%esp
  8004c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cf:	e8 3c 0a 00 00       	call   800f10 <__umoddi3>
  8004d4:	83 c4 14             	add    $0x14,%esp
  8004d7:	0f be 80 9e 10 80 00 	movsbl 0x80109e(%eax),%eax
  8004de:	50                   	push   %eax
  8004df:	ff d7                	call   *%edi
}
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5f                   	pop    %edi
  8004ea:	5d                   	pop    %ebp
  8004eb:	c3                   	ret    
  8004ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004ef:	eb c4                	jmp    8004b5 <printnum+0x73>

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800500:	73 0a                	jae    80050c <sprintputch+0x1b>
		*b->buf++ = ch;
  800502:	8d 4a 01             	lea    0x1(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	88 02                	mov    %al,(%edx)
}
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <printfmt>:
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800514:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800517:	50                   	push   %eax
  800518:	ff 75 10             	pushl  0x10(%ebp)
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	ff 75 08             	pushl  0x8(%ebp)
  800521:	e8 05 00 00 00       	call   80052b <vprintfmt>
}
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <vprintfmt>:
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 2c             	sub    $0x2c,%esp
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053d:	e9 63 03 00 00       	jmp    8008a5 <vprintfmt+0x37a>
		padc = ' ';
  800542:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800546:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80054d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800554:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8d 47 01             	lea    0x1(%edi),%eax
  800563:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800566:	0f b6 17             	movzbl (%edi),%edx
  800569:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056c:	3c 55                	cmp    $0x55,%al
  80056e:	0f 87 11 04 00 00    	ja     800985 <vprintfmt+0x45a>
  800574:	0f b6 c0             	movzbl %al,%eax
  800577:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800581:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800585:	eb d9                	jmp    800560 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80058a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80058e:	eb d0                	jmp    800560 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800590:	0f b6 d2             	movzbl %dl,%edx
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ab:	83 f9 09             	cmp    $0x9,%ecx
  8005ae:	77 55                	ja     800605 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8005b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b3:	eb e9                	jmp    80059e <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005cd:	79 91                	jns    800560 <vprintfmt+0x35>
				width = precision, precision = -1;
  8005cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005dc:	eb 82                	jmp    800560 <vprintfmt+0x35>
  8005de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	0f 49 d0             	cmovns %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	e9 6a ff ff ff       	jmp    800560 <vprintfmt+0x35>
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800600:	e9 5b ff ff ff       	jmp    800560 <vprintfmt+0x35>
  800605:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060b:	eb bc                	jmp    8005c9 <vprintfmt+0x9e>
			lflag++;
  80060d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800613:	e9 48 ff ff ff       	jmp    800560 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 78 04             	lea    0x4(%eax),%edi
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	ff 30                	pushl  (%eax)
  800624:	ff d6                	call   *%esi
			break;
  800626:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800629:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062c:	e9 71 02 00 00       	jmp    8008a2 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 78 04             	lea    0x4(%eax),%edi
  800637:	8b 00                	mov    (%eax),%eax
  800639:	99                   	cltd   
  80063a:	31 d0                	xor    %edx,%eax
  80063c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063e:	83 f8 08             	cmp    $0x8,%eax
  800641:	7f 23                	jg     800666 <vprintfmt+0x13b>
  800643:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	74 18                	je     800666 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80064e:	52                   	push   %edx
  80064f:	68 bf 10 80 00       	push   $0x8010bf
  800654:	53                   	push   %ebx
  800655:	56                   	push   %esi
  800656:	e8 b3 fe ff ff       	call   80050e <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800661:	e9 3c 02 00 00       	jmp    8008a2 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800666:	50                   	push   %eax
  800667:	68 b6 10 80 00       	push   $0x8010b6
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 9b fe ff ff       	call   80050e <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800676:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800679:	e9 24 02 00 00       	jmp    8008a2 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	83 c0 04             	add    $0x4,%eax
  800684:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068c:	85 ff                	test   %edi,%edi
  80068e:	b8 af 10 80 00       	mov    $0x8010af,%eax
  800693:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800696:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069a:	0f 8e bd 00 00 00    	jle    80075d <vprintfmt+0x232>
  8006a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a4:	75 0e                	jne    8006b4 <vprintfmt+0x189>
  8006a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b2:	eb 6d                	jmp    800721 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ba:	57                   	push   %edi
  8006bb:	e8 6d 03 00 00       	call   800a2d <strnlen>
  8006c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c3:	29 c1                	sub    %eax,%ecx
  8006c5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d5:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	eb 0f                	jmp    8006e8 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	7f ed                	jg     8006d9 <vprintfmt+0x1ae>
  8006ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ef:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	0f 49 c1             	cmovns %ecx,%eax
  8006fc:	29 c1                	sub    %eax,%ecx
  8006fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800701:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800704:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800707:	89 cb                	mov    %ecx,%ebx
  800709:	eb 16                	jmp    800721 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80070b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070f:	75 31                	jne    800742 <vprintfmt+0x217>
					putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	50                   	push   %eax
  800718:	ff 55 08             	call   *0x8(%ebp)
  80071b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071e:	83 eb 01             	sub    $0x1,%ebx
  800721:	83 c7 01             	add    $0x1,%edi
  800724:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800728:	0f be c2             	movsbl %dl,%eax
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 59                	je     800788 <vprintfmt+0x25d>
  80072f:	85 f6                	test   %esi,%esi
  800731:	78 d8                	js     80070b <vprintfmt+0x1e0>
  800733:	83 ee 01             	sub    $0x1,%esi
  800736:	79 d3                	jns    80070b <vprintfmt+0x1e0>
  800738:	89 df                	mov    %ebx,%edi
  80073a:	8b 75 08             	mov    0x8(%ebp),%esi
  80073d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800740:	eb 37                	jmp    800779 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800742:	0f be d2             	movsbl %dl,%edx
  800745:	83 ea 20             	sub    $0x20,%edx
  800748:	83 fa 5e             	cmp    $0x5e,%edx
  80074b:	76 c4                	jbe    800711 <vprintfmt+0x1e6>
					putch('?', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	6a 3f                	push   $0x3f
  800755:	ff 55 08             	call   *0x8(%ebp)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb c1                	jmp    80071e <vprintfmt+0x1f3>
  80075d:	89 75 08             	mov    %esi,0x8(%ebp)
  800760:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800763:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800766:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800769:	eb b6                	jmp    800721 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 20                	push   $0x20
  800771:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800773:	83 ef 01             	sub    $0x1,%edi
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	85 ff                	test   %edi,%edi
  80077b:	7f ee                	jg     80076b <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80077d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
  800783:	e9 1a 01 00 00       	jmp    8008a2 <vprintfmt+0x377>
  800788:	89 df                	mov    %ebx,%edi
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800790:	eb e7                	jmp    800779 <vprintfmt+0x24e>
	if (lflag >= 2)
  800792:	83 f9 01             	cmp    $0x1,%ecx
  800795:	7e 3f                	jle    8007d6 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 40 08             	lea    0x8(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007b2:	79 5c                	jns    800810 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 2d                	push   $0x2d
  8007ba:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c2:	f7 da                	neg    %edx
  8007c4:	83 d1 00             	adc    $0x0,%ecx
  8007c7:	f7 d9                	neg    %ecx
  8007c9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d1:	e9 b2 00 00 00       	jmp    800888 <vprintfmt+0x35d>
	else if (lflag)
  8007d6:	85 c9                	test   %ecx,%ecx
  8007d8:	75 1b                	jne    8007f5 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e2:	89 c1                	mov    %eax,%ecx
  8007e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8d 40 04             	lea    0x4(%eax),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f3:	eb b9                	jmp    8007ae <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8d 40 04             	lea    0x4(%eax),%eax
  80080b:	89 45 14             	mov    %eax,0x14(%ebp)
  80080e:	eb 9e                	jmp    8007ae <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800810:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800813:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	eb 6b                	jmp    800888 <vprintfmt+0x35d>
	if (lflag >= 2)
  80081d:	83 f9 01             	cmp    $0x1,%ecx
  800820:	7e 15                	jle    800837 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8b 48 04             	mov    0x4(%eax),%ecx
  80082a:	8d 40 08             	lea    0x8(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
  800835:	eb 51                	jmp    800888 <vprintfmt+0x35d>
	else if (lflag)
  800837:	85 c9                	test   %ecx,%ecx
  800839:	75 17                	jne    800852 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800850:	eb 36                	jmp    800888 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8b 10                	mov    (%eax),%edx
  800857:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085c:	8d 40 04             	lea    0x4(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
  800867:	eb 1f                	jmp    800888 <vprintfmt+0x35d>
	if (lflag >= 2)
  800869:	83 f9 01             	cmp    $0x1,%ecx
  80086c:	7e 5b                	jle    8008c9 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 50 04             	mov    0x4(%eax),%edx
  800874:	8b 00                	mov    (%eax),%eax
  800876:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800879:	8d 49 08             	lea    0x8(%ecx),%ecx
  80087c:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80087f:	89 d1                	mov    %edx,%ecx
  800881:	89 c2                	mov    %eax,%edx
			base = 8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80088f:	57                   	push   %edi
  800890:	ff 75 e0             	pushl  -0x20(%ebp)
  800893:	50                   	push   %eax
  800894:	51                   	push   %ecx
  800895:	52                   	push   %edx
  800896:	89 da                	mov    %ebx,%edx
  800898:	89 f0                	mov    %esi,%eax
  80089a:	e8 a3 fb ff ff       	call   800442 <printnum>
			break;
  80089f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a5:	83 c7 01             	add    $0x1,%edi
  8008a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ac:	83 f8 25             	cmp    $0x25,%eax
  8008af:	0f 84 8d fc ff ff    	je     800542 <vprintfmt+0x17>
			if (ch == '\0')
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	0f 84 e8 00 00 00    	je     8009a5 <vprintfmt+0x47a>
			putch(ch, putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	50                   	push   %eax
  8008c2:	ff d6                	call   *%esi
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	eb dc                	jmp    8008a5 <vprintfmt+0x37a>
	else if (lflag)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	75 13                	jne    8008e0 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	89 d0                	mov    %edx,%eax
  8008d4:	99                   	cltd   
  8008d5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008d8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008db:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008de:	eb 9f                	jmp    80087f <vprintfmt+0x354>
		return va_arg(*ap, long);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8b 10                	mov    (%eax),%edx
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	99                   	cltd   
  8008e8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008eb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008f1:	eb 8c                	jmp    80087f <vprintfmt+0x354>
			putch('0', putdat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	53                   	push   %ebx
  8008f7:	6a 30                	push   $0x30
  8008f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8008fb:	83 c4 08             	add    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	6a 78                	push   $0x78
  800901:	ff d6                	call   *%esi
			num = (unsigned long long)
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 10                	mov    (%eax),%edx
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80090d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800910:	8d 40 04             	lea    0x4(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800916:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80091b:	e9 68 ff ff ff       	jmp    800888 <vprintfmt+0x35d>
	if (lflag >= 2)
  800920:	83 f9 01             	cmp    $0x1,%ecx
  800923:	7e 18                	jle    80093d <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	8b 48 04             	mov    0x4(%eax),%ecx
  80092d:	8d 40 08             	lea    0x8(%eax),%eax
  800930:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800933:	b8 10 00 00 00       	mov    $0x10,%eax
  800938:	e9 4b ff ff ff       	jmp    800888 <vprintfmt+0x35d>
	else if (lflag)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	75 1a                	jne    80095b <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800941:	8b 45 14             	mov    0x14(%ebp),%eax
  800944:	8b 10                	mov    (%eax),%edx
  800946:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094b:	8d 40 04             	lea    0x4(%eax),%eax
  80094e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800951:	b8 10 00 00 00       	mov    $0x10,%eax
  800956:	e9 2d ff ff ff       	jmp    800888 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80095b:	8b 45 14             	mov    0x14(%ebp),%eax
  80095e:	8b 10                	mov    (%eax),%edx
  800960:	b9 00 00 00 00       	mov    $0x0,%ecx
  800965:	8d 40 04             	lea    0x4(%eax),%eax
  800968:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096b:	b8 10 00 00 00       	mov    $0x10,%eax
  800970:	e9 13 ff ff ff       	jmp    800888 <vprintfmt+0x35d>
			putch(ch, putdat);
  800975:	83 ec 08             	sub    $0x8,%esp
  800978:	53                   	push   %ebx
  800979:	6a 25                	push   $0x25
  80097b:	ff d6                	call   *%esi
			break;
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	e9 1d ff ff ff       	jmp    8008a2 <vprintfmt+0x377>
			putch('%', putdat);
  800985:	83 ec 08             	sub    $0x8,%esp
  800988:	53                   	push   %ebx
  800989:	6a 25                	push   $0x25
  80098b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	89 f8                	mov    %edi,%eax
  800992:	eb 03                	jmp    800997 <vprintfmt+0x46c>
  800994:	83 e8 01             	sub    $0x1,%eax
  800997:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099b:	75 f7                	jne    800994 <vprintfmt+0x469>
  80099d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a0:	e9 fd fe ff ff       	jmp    8008a2 <vprintfmt+0x377>
}
  8009a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 18             	sub    $0x18,%esp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	74 26                	je     8009f4 <vsnprintf+0x47>
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	7e 22                	jle    8009f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d2:	ff 75 14             	pushl  0x14(%ebp)
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009db:	50                   	push   %eax
  8009dc:	68 f1 04 80 00       	push   $0x8004f1
  8009e1:	e8 45 fb ff ff       	call   80052b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ef:	83 c4 10             	add    $0x10,%esp
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    
		return -E_INVAL;
  8009f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f9:	eb f7                	jmp    8009f2 <vsnprintf+0x45>

008009fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a04:	50                   	push   %eax
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	ff 75 08             	pushl  0x8(%ebp)
  800a0e:	e8 9a ff ff ff       	call   8009ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	eb 03                	jmp    800a25 <strlen+0x10>
		n++;
  800a22:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a29:	75 f7                	jne    800a22 <strlen+0xd>
	return n;
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a33:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 03                	jmp    800a40 <strnlen+0x13>
		n++;
  800a3d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	74 06                	je     800a4a <strnlen+0x1d>
  800a44:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a48:	75 f3                	jne    800a3d <strnlen+0x10>
	return n;
}
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a62:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a65:	84 db                	test   %bl,%bl
  800a67:	75 ef                	jne    800a58 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a73:	53                   	push   %ebx
  800a74:	e8 9c ff ff ff       	call   800a15 <strlen>
  800a79:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a7c:	ff 75 0c             	pushl  0xc(%ebp)
  800a7f:	01 d8                	add    %ebx,%eax
  800a81:	50                   	push   %eax
  800a82:	e8 c5 ff ff ff       	call   800a4c <strcpy>
	return dst;
}
  800a87:	89 d8                	mov    %ebx,%eax
  800a89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 75 08             	mov    0x8(%ebp),%esi
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	89 f3                	mov    %esi,%ebx
  800a9b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9e:	89 f2                	mov    %esi,%edx
  800aa0:	eb 0f                	jmp    800ab1 <strncpy+0x23>
		*dst++ = *src;
  800aa2:	83 c2 01             	add    $0x1,%edx
  800aa5:	0f b6 01             	movzbl (%ecx),%eax
  800aa8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aab:	80 39 01             	cmpb   $0x1,(%ecx)
  800aae:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ab1:	39 da                	cmp    %ebx,%edx
  800ab3:	75 ed                	jne    800aa2 <strncpy+0x14>
	}
	return ret;
}
  800ab5:	89 f0                	mov    %esi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ac9:	89 f0                	mov    %esi,%eax
  800acb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800acf:	85 c9                	test   %ecx,%ecx
  800ad1:	75 0b                	jne    800ade <strlcpy+0x23>
  800ad3:	eb 17                	jmp    800aec <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ade:	39 d8                	cmp    %ebx,%eax
  800ae0:	74 07                	je     800ae9 <strlcpy+0x2e>
  800ae2:	0f b6 0a             	movzbl (%edx),%ecx
  800ae5:	84 c9                	test   %cl,%cl
  800ae7:	75 ec                	jne    800ad5 <strlcpy+0x1a>
		*dst = '\0';
  800ae9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aec:	29 f0                	sub    %esi,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afb:	eb 06                	jmp    800b03 <strcmp+0x11>
		p++, q++;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b03:	0f b6 01             	movzbl (%ecx),%eax
  800b06:	84 c0                	test   %al,%al
  800b08:	74 04                	je     800b0e <strcmp+0x1c>
  800b0a:	3a 02                	cmp    (%edx),%al
  800b0c:	74 ef                	je     800afd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 c0             	movzbl %al,%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b27:	eb 06                	jmp    800b2f <strncmp+0x17>
		n--, p++, q++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2f:	39 d8                	cmp    %ebx,%eax
  800b31:	74 16                	je     800b49 <strncmp+0x31>
  800b33:	0f b6 08             	movzbl (%eax),%ecx
  800b36:	84 c9                	test   %cl,%cl
  800b38:	74 04                	je     800b3e <strncmp+0x26>
  800b3a:	3a 0a                	cmp    (%edx),%cl
  800b3c:	74 eb                	je     800b29 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3e:	0f b6 00             	movzbl (%eax),%eax
  800b41:	0f b6 12             	movzbl (%edx),%edx
  800b44:	29 d0                	sub    %edx,%eax
}
  800b46:	5b                   	pop    %ebx
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    
		return 0;
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	eb f6                	jmp    800b46 <strncmp+0x2e>

00800b50 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5a:	0f b6 10             	movzbl (%eax),%edx
  800b5d:	84 d2                	test   %dl,%dl
  800b5f:	74 09                	je     800b6a <strchr+0x1a>
		if (*s == c)
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 0a                	je     800b6f <strchr+0x1f>
	for (; *s; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	eb f0                	jmp    800b5a <strchr+0xa>
			return (char *) s;
	return 0;
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b7b:	eb 03                	jmp    800b80 <strfind+0xf>
  800b7d:	83 c0 01             	add    $0x1,%eax
  800b80:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b83:	38 ca                	cmp    %cl,%dl
  800b85:	74 04                	je     800b8b <strfind+0x1a>
  800b87:	84 d2                	test   %dl,%dl
  800b89:	75 f2                	jne    800b7d <strfind+0xc>
			break;
	return (char *) s;
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	74 13                	je     800bb0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba3:	75 05                	jne    800baa <memset+0x1d>
  800ba5:	f6 c1 03             	test   $0x3,%cl
  800ba8:	74 0d                	je     800bb7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	fc                   	cld    
  800bae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb0:	89 f8                	mov    %edi,%eax
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
		c &= 0xFF;
  800bb7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	c1 e3 08             	shl    $0x8,%ebx
  800bc0:	89 d0                	mov    %edx,%eax
  800bc2:	c1 e0 18             	shl    $0x18,%eax
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	c1 e6 10             	shl    $0x10,%esi
  800bca:	09 f0                	or     %esi,%eax
  800bcc:	09 c2                	or     %eax,%edx
  800bce:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bd0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bd3:	89 d0                	mov    %edx,%eax
  800bd5:	fc                   	cld    
  800bd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd8:	eb d6                	jmp    800bb0 <memset+0x23>

00800bda <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be8:	39 c6                	cmp    %eax,%esi
  800bea:	73 35                	jae    800c21 <memmove+0x47>
  800bec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bef:	39 c2                	cmp    %eax,%edx
  800bf1:	76 2e                	jbe    800c21 <memmove+0x47>
		s += n;
		d += n;
  800bf3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	09 fe                	or     %edi,%esi
  800bfa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c00:	74 0c                	je     800c0e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c02:	83 ef 01             	sub    $0x1,%edi
  800c05:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c08:	fd                   	std    
  800c09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c0b:	fc                   	cld    
  800c0c:	eb 21                	jmp    800c2f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0e:	f6 c1 03             	test   $0x3,%cl
  800c11:	75 ef                	jne    800c02 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c13:	83 ef 04             	sub    $0x4,%edi
  800c16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c1c:	fd                   	std    
  800c1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1f:	eb ea                	jmp    800c0b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c21:	89 f2                	mov    %esi,%edx
  800c23:	09 c2                	or     %eax,%edx
  800c25:	f6 c2 03             	test   $0x3,%dl
  800c28:	74 09                	je     800c33 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2a:	89 c7                	mov    %eax,%edi
  800c2c:	fc                   	cld    
  800c2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c33:	f6 c1 03             	test   $0x3,%cl
  800c36:	75 f2                	jne    800c2a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c38:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c3b:	89 c7                	mov    %eax,%edi
  800c3d:	fc                   	cld    
  800c3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c40:	eb ed                	jmp    800c2f <memmove+0x55>

00800c42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c45:	ff 75 10             	pushl  0x10(%ebp)
  800c48:	ff 75 0c             	pushl  0xc(%ebp)
  800c4b:	ff 75 08             	pushl  0x8(%ebp)
  800c4e:	e8 87 ff ff ff       	call   800bda <memmove>
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c60:	89 c6                	mov    %eax,%esi
  800c62:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c65:	39 f0                	cmp    %esi,%eax
  800c67:	74 1c                	je     800c85 <memcmp+0x30>
		if (*s1 != *s2)
  800c69:	0f b6 08             	movzbl (%eax),%ecx
  800c6c:	0f b6 1a             	movzbl (%edx),%ebx
  800c6f:	38 d9                	cmp    %bl,%cl
  800c71:	75 08                	jne    800c7b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	83 c2 01             	add    $0x1,%edx
  800c79:	eb ea                	jmp    800c65 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c7b:	0f b6 c1             	movzbl %cl,%eax
  800c7e:	0f b6 db             	movzbl %bl,%ebx
  800c81:	29 d8                	sub    %ebx,%eax
  800c83:	eb 05                	jmp    800c8a <memcmp+0x35>
	}

	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c9c:	39 d0                	cmp    %edx,%eax
  800c9e:	73 09                	jae    800ca9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca0:	38 08                	cmp    %cl,(%eax)
  800ca2:	74 05                	je     800ca9 <memfind+0x1b>
	for (; s < ends; s++)
  800ca4:	83 c0 01             	add    $0x1,%eax
  800ca7:	eb f3                	jmp    800c9c <memfind+0xe>
			break;
	return (void *) s;
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb7:	eb 03                	jmp    800cbc <strtol+0x11>
		s++;
  800cb9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cbc:	0f b6 01             	movzbl (%ecx),%eax
  800cbf:	3c 20                	cmp    $0x20,%al
  800cc1:	74 f6                	je     800cb9 <strtol+0xe>
  800cc3:	3c 09                	cmp    $0x9,%al
  800cc5:	74 f2                	je     800cb9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cc7:	3c 2b                	cmp    $0x2b,%al
  800cc9:	74 2e                	je     800cf9 <strtol+0x4e>
	int neg = 0;
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cd0:	3c 2d                	cmp    $0x2d,%al
  800cd2:	74 2f                	je     800d03 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cda:	75 05                	jne    800ce1 <strtol+0x36>
  800cdc:	80 39 30             	cmpb   $0x30,(%ecx)
  800cdf:	74 2c                	je     800d0d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	85 db                	test   %ebx,%ebx
  800ce3:	75 0a                	jne    800cef <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cea:	80 39 30             	cmpb   $0x30,(%ecx)
  800ced:	74 28                	je     800d17 <strtol+0x6c>
		base = 10;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cf7:	eb 50                	jmp    800d49 <strtol+0x9e>
		s++;
  800cf9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800d01:	eb d1                	jmp    800cd4 <strtol+0x29>
		s++, neg = 1;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	bf 01 00 00 00       	mov    $0x1,%edi
  800d0b:	eb c7                	jmp    800cd4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d11:	74 0e                	je     800d21 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d13:	85 db                	test   %ebx,%ebx
  800d15:	75 d8                	jne    800cef <strtol+0x44>
		s++, base = 8;
  800d17:	83 c1 01             	add    $0x1,%ecx
  800d1a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d1f:	eb ce                	jmp    800cef <strtol+0x44>
		s += 2, base = 16;
  800d21:	83 c1 02             	add    $0x2,%ecx
  800d24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d29:	eb c4                	jmp    800cef <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d2e:	89 f3                	mov    %esi,%ebx
  800d30:	80 fb 19             	cmp    $0x19,%bl
  800d33:	77 29                	ja     800d5e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d35:	0f be d2             	movsbl %dl,%edx
  800d38:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d3b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d3e:	7d 30                	jge    800d70 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d40:	83 c1 01             	add    $0x1,%ecx
  800d43:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d47:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d49:	0f b6 11             	movzbl (%ecx),%edx
  800d4c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d4f:	89 f3                	mov    %esi,%ebx
  800d51:	80 fb 09             	cmp    $0x9,%bl
  800d54:	77 d5                	ja     800d2b <strtol+0x80>
			dig = *s - '0';
  800d56:	0f be d2             	movsbl %dl,%edx
  800d59:	83 ea 30             	sub    $0x30,%edx
  800d5c:	eb dd                	jmp    800d3b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d61:	89 f3                	mov    %esi,%ebx
  800d63:	80 fb 19             	cmp    $0x19,%bl
  800d66:	77 08                	ja     800d70 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d68:	0f be d2             	movsbl %dl,%edx
  800d6b:	83 ea 37             	sub    $0x37,%edx
  800d6e:	eb cb                	jmp    800d3b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d74:	74 05                	je     800d7b <strtol+0xd0>
		*endptr = (char *) s;
  800d76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	f7 da                	neg    %edx
  800d7f:	85 ff                	test   %edi,%edi
  800d81:	0f 45 c2             	cmovne %edx,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 04             	sub    $0x4,%esp
	int r;
	envid_t trap_env_id = sys_getenvid();
  800d90:	e8 9f f3 ff ff       	call   800134 <sys_getenvid>
  800d95:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800d97:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d9e:	74 22                	je     800dc2 <set_pgfault_handler+0x39>
		// LAB 4: Your code here.
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
		
		//panic("set_pgfault_handler not implemented");
	}
	if (sys_env_set_pgfault_upcall(trap_env_id, _pgfault_upcall)) {
  800da0:	83 ec 08             	sub    $0x8,%esp
  800da3:	68 21 03 80 00       	push   $0x800321
  800da8:	53                   	push   %ebx
  800da9:	e8 cd f4 ff ff       	call   80027b <sys_env_set_pgfault_upcall>
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	75 22                	jne    800dd7 <set_pgfault_handler+0x4e>
		panic("set pgfault upcall failed!");
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	6a 06                	push   $0x6
  800dc7:	68 00 f0 bf ee       	push   $0xeebff000
  800dcc:	50                   	push   %eax
  800dcd:	e8 a0 f3 ff ff       	call   800172 <sys_page_alloc>
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	eb c9                	jmp    800da0 <set_pgfault_handler+0x17>
		panic("set pgfault upcall failed!");
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	68 e4 12 80 00       	push   $0x8012e4
  800ddf:	6a 25                	push   $0x25
  800de1:	68 ff 12 80 00       	push   $0x8012ff
  800de6:	e8 68 f5 ff ff       	call   800353 <_panic>
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e07:	85 d2                	test   %edx,%edx
  800e09:	75 35                	jne    800e40 <__udivdi3+0x50>
  800e0b:	39 f3                	cmp    %esi,%ebx
  800e0d:	0f 87 bd 00 00 00    	ja     800ed0 <__udivdi3+0xe0>
  800e13:	85 db                	test   %ebx,%ebx
  800e15:	89 d9                	mov    %ebx,%ecx
  800e17:	75 0b                	jne    800e24 <__udivdi3+0x34>
  800e19:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f3                	div    %ebx
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	31 d2                	xor    %edx,%edx
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	f7 f1                	div    %ecx
  800e2a:	89 c6                	mov    %eax,%esi
  800e2c:	89 e8                	mov    %ebp,%eax
  800e2e:	89 f7                	mov    %esi,%edi
  800e30:	f7 f1                	div    %ecx
  800e32:	89 fa                	mov    %edi,%edx
  800e34:	83 c4 1c             	add    $0x1c,%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
  800e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 f2                	cmp    %esi,%edx
  800e42:	77 7c                	ja     800ec0 <__udivdi3+0xd0>
  800e44:	0f bd fa             	bsr    %edx,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0xf8>
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	b8 20 00 00 00       	mov    $0x20,%eax
  800e57:	29 f8                	sub    %edi,%eax
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 da                	mov    %ebx,%edx
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 d1                	or     %edx,%ecx
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 c1                	mov    %eax,%ecx
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	d3 e6                	shl    %cl,%esi
  800e81:	89 eb                	mov    %ebp,%ebx
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 de                	or     %ebx,%esi
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	f7 74 24 08          	divl   0x8(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	f7 64 24 0c          	mull   0xc(%esp)
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	72 0c                	jb     800ea7 <__udivdi3+0xb7>
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e5                	shl    %cl,%ebp
  800e9f:	39 c5                	cmp    %eax,%ebp
  800ea1:	73 5d                	jae    800f00 <__udivdi3+0x110>
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	75 59                	jne    800f00 <__udivdi3+0x110>
  800ea7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eaa:	31 ff                	xor    %edi,%edi
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	83 c4 1c             	add    $0x1c,%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
  800eb6:	8d 76 00             	lea    0x0(%esi),%esi
  800eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	31 c0                	xor    %eax,%eax
  800ec4:	89 fa                	mov    %edi,%edx
  800ec6:	83 c4 1c             	add    $0x1c,%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
  800ece:	66 90                	xchg   %ax,%ax
  800ed0:	31 ff                	xor    %edi,%edi
  800ed2:	89 e8                	mov    %ebp,%eax
  800ed4:	89 f2                	mov    %esi,%edx
  800ed6:	f7 f3                	div    %ebx
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x102>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 d2                	ja     800ec4 <__udivdi3+0xd4>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb cb                	jmp    800ec4 <__udivdi3+0xd4>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	31 ff                	xor    %edi,%edi
  800f04:	eb be                	jmp    800ec4 <__udivdi3+0xd4>
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 ed                	test   %ebp,%ebp
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	89 da                	mov    %ebx,%edx
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	0f 86 b1 00 00 00    	jbe    800fe8 <__umoddi3+0xd8>
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	39 dd                	cmp    %ebx,%ebp
  800f4a:	77 f1                	ja     800f3d <__umoddi3+0x2d>
  800f4c:	0f bd cd             	bsr    %ebp,%ecx
  800f4f:	83 f1 1f             	xor    $0x1f,%ecx
  800f52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f56:	0f 84 b4 00 00 00    	je     801010 <__umoddi3+0x100>
  800f5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	29 c2                	sub    %eax,%edx
  800f69:	89 c1                	mov    %eax,%ecx
  800f6b:	89 f8                	mov    %edi,%eax
  800f6d:	d3 e5                	shl    %cl,%ebp
  800f6f:	89 d1                	mov    %edx,%ecx
  800f71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f75:	d3 e8                	shr    %cl,%eax
  800f77:	09 c5                	or     %eax,%ebp
  800f79:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	d3 e7                	shl    %cl,%edi
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	d3 ef                	shr    %cl,%edi
  800f8b:	89 c1                	mov    %eax,%ecx
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 d1                	mov    %edx,%ecx
  800f93:	89 fa                	mov    %edi,%edx
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f9c:	09 d8                	or     %ebx,%eax
  800f9e:	f7 f5                	div    %ebp
  800fa0:	d3 e6                	shl    %cl,%esi
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	f7 64 24 08          	mull   0x8(%esp)
  800fa8:	39 d1                	cmp    %edx,%ecx
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	72 06                	jb     800fb6 <__umoddi3+0xa6>
  800fb0:	75 0e                	jne    800fc0 <__umoddi3+0xb0>
  800fb2:	39 c6                	cmp    %eax,%esi
  800fb4:	73 0a                	jae    800fc0 <__umoddi3+0xb0>
  800fb6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fba:	19 ea                	sbb    %ebp,%edx
  800fbc:	89 d7                	mov    %edx,%edi
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	89 ca                	mov    %ecx,%edx
  800fc2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fc7:	29 de                	sub    %ebx,%esi
  800fc9:	19 fa                	sbb    %edi,%edx
  800fcb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fcf:	89 d0                	mov    %edx,%eax
  800fd1:	d3 e0                	shl    %cl,%eax
  800fd3:	89 d9                	mov    %ebx,%ecx
  800fd5:	d3 ee                	shr    %cl,%esi
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	09 f0                	or     %esi,%eax
  800fdb:	83 c4 1c             	add    $0x1c,%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    
  800fe3:	90                   	nop
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	85 ff                	test   %edi,%edi
  800fea:	89 f9                	mov    %edi,%ecx
  800fec:	75 0b                	jne    800ff9 <__umoddi3+0xe9>
  800fee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f7                	div    %edi
  800ff7:	89 c1                	mov    %eax,%ecx
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f1                	div    %ecx
  800fff:	89 f0                	mov    %esi,%eax
  801001:	f7 f1                	div    %ecx
  801003:	e9 31 ff ff ff       	jmp    800f39 <__umoddi3+0x29>
  801008:	90                   	nop
  801009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801010:	39 dd                	cmp    %ebx,%ebp
  801012:	72 08                	jb     80101c <__umoddi3+0x10c>
  801014:	39 f7                	cmp    %esi,%edi
  801016:	0f 87 21 ff ff ff    	ja     800f3d <__umoddi3+0x2d>
  80101c:	89 da                	mov    %ebx,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	29 f8                	sub    %edi,%eax
  801022:	19 ea                	sbb    %ebp,%edx
  801024:	e9 14 ff ff ff       	jmp    800f3d <__umoddi3+0x2d>
