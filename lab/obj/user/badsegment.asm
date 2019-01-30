
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800050:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800053:	e8 c6 00 00 00       	call   80011e <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 db                	test   %ebx,%ebx
  80006c:	7e 07                	jle    800075 <libmain+0x37>
		binaryname = argv[0];
  80006e:	8b 06                	mov    (%esi),%eax
  800070:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	e8 b4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0a 00 00 00       	call   80008e <exit>
}
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800094:	6a 00                	push   $0x0
  800096:	e8 42 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7f 08                	jg     800107 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 aa 0f 80 00       	push   $0x800faa
  800112:	6a 23                	push   $0x23
  800114:	68 c7 0f 80 00       	push   $0x800fc7
  800119:	e8 ed 01 00 00       	call   80030b <_panic>

0080011e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <sys_yield>:

void
sys_yield(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	asm volatile("int %1\n"
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014d:	89 d1                	mov    %edx,%ecx
  80014f:	89 d3                	mov    %edx,%ebx
  800151:	89 d7                	mov    %edx,%edi
  800153:	89 d6                	mov    %edx,%esi
  800155:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5f                   	pop    %edi
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800165:	be 00 00 00 00       	mov    $0x0,%esi
  80016a:	8b 55 08             	mov    0x8(%ebp),%edx
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800178:	89 f7                	mov    %esi,%edi
  80017a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017c:	85 c0                	test   %eax,%eax
  80017e:	7f 08                	jg     800188 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	6a 04                	push   $0x4
  80018e:	68 aa 0f 80 00       	push   $0x800faa
  800193:	6a 23                	push   $0x23
  800195:	68 c7 0f 80 00       	push   $0x800fc7
  80019a:	e8 6c 01 00 00       	call   80030b <_panic>

0080019f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	57                   	push   %edi
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7f 08                	jg     8001ca <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5f                   	pop    %edi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 05                	push   $0x5
  8001d0:	68 aa 0f 80 00       	push   $0x800faa
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 c7 0f 80 00       	push   $0x800fc7
  8001dc:	e8 2a 01 00 00       	call   80030b <_panic>

008001e1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	89 df                	mov    %ebx,%edi
  8001fc:	89 de                	mov    %ebx,%esi
  8001fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7f 08                	jg     80020c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 06                	push   $0x6
  800212:	68 aa 0f 80 00       	push   $0x800faa
  800217:	6a 23                	push   $0x23
  800219:	68 c7 0f 80 00       	push   $0x800fc7
  80021e:	e8 e8 00 00 00       	call   80030b <_panic>

00800223 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	8b 55 08             	mov    0x8(%ebp),%edx
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7f 08                	jg     80024e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 08                	push   $0x8
  800254:	68 aa 0f 80 00       	push   $0x800faa
  800259:	6a 23                	push   $0x23
  80025b:	68 c7 0f 80 00       	push   $0x800fc7
  800260:	e8 a6 00 00 00       	call   80030b <_panic>

00800265 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7f 08                	jg     800290 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	50                   	push   %eax
  800294:	6a 09                	push   $0x9
  800296:	68 aa 0f 80 00       	push   $0x800faa
  80029b:	6a 23                	push   $0x23
  80029d:	68 c7 0f 80 00       	push   $0x800fc7
  8002a2:	e8 64 00 00 00       	call   80030b <_panic>

008002a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b8:	be 00 00 00 00       	mov    $0x0,%esi
  8002bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e0:	89 cb                	mov    %ecx,%ebx
  8002e2:	89 cf                	mov    %ecx,%edi
  8002e4:	89 ce                	mov    %ecx,%esi
  8002e6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	7f 08                	jg     8002f4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	50                   	push   %eax
  8002f8:	6a 0c                	push   $0xc
  8002fa:	68 aa 0f 80 00       	push   $0x800faa
  8002ff:	6a 23                	push   $0x23
  800301:	68 c7 0f 80 00       	push   $0x800fc7
  800306:	e8 00 00 00 00       	call   80030b <_panic>

0080030b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800313:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800319:	e8 00 fe ff ff       	call   80011e <sys_getenvid>
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	56                   	push   %esi
  800328:	50                   	push   %eax
  800329:	68 d8 0f 80 00       	push   $0x800fd8
  80032e:	e8 b3 00 00 00       	call   8003e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800333:	83 c4 18             	add    $0x18,%esp
  800336:	53                   	push   %ebx
  800337:	ff 75 10             	pushl  0x10(%ebp)
  80033a:	e8 56 00 00 00       	call   800395 <vcprintf>
	cprintf("\n");
  80033f:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800346:	e8 9b 00 00 00       	call   8003e6 <cprintf>
  80034b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034e:	cc                   	int3   
  80034f:	eb fd                	jmp    80034e <_panic+0x43>

00800351 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	53                   	push   %ebx
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035b:	8b 13                	mov    (%ebx),%edx
  80035d:	8d 42 01             	lea    0x1(%edx),%eax
  800360:	89 03                	mov    %eax,(%ebx)
  800362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800365:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800369:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036e:	74 09                	je     800379 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800370:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800377:	c9                   	leave  
  800378:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	68 ff 00 00 00       	push   $0xff
  800381:	8d 43 08             	lea    0x8(%ebx),%eax
  800384:	50                   	push   %eax
  800385:	e8 16 fd ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  80038a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	eb db                	jmp    800370 <putch+0x1f>

00800395 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a5:	00 00 00 
	b.cnt = 0;
  8003a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	68 51 03 80 00       	push   $0x800351
  8003c4:	e8 1a 01 00 00       	call   8004e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c9:	83 c4 08             	add    $0x8,%esp
  8003cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d8:	50                   	push   %eax
  8003d9:	e8 c2 fc ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8003de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	e8 9d ff ff ff       	call   800395 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 1c             	sub    $0x1c,%esp
  800403:	89 c7                	mov    %eax,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800421:	39 d3                	cmp    %edx,%ebx
  800423:	72 05                	jb     80042a <printnum+0x30>
  800425:	39 45 10             	cmp    %eax,0x10(%ebp)
  800428:	77 7a                	ja     8004a4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	83 ec 0c             	sub    $0xc,%esp
  80042d:	ff 75 18             	pushl  0x18(%ebp)
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800436:	53                   	push   %ebx
  800437:	ff 75 10             	pushl  0x10(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff 75 dc             	pushl  -0x24(%ebp)
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	e8 02 09 00 00       	call   800d50 <__udivdi3>
  80044e:	83 c4 18             	add    $0x18,%esp
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	89 f2                	mov    %esi,%edx
  800455:	89 f8                	mov    %edi,%eax
  800457:	e8 9e ff ff ff       	call   8003fa <printnum>
  80045c:	83 c4 20             	add    $0x20,%esp
  80045f:	eb 13                	jmp    800474 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	ff d7                	call   *%edi
  80046a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80046d:	83 eb 01             	sub    $0x1,%ebx
  800470:	85 db                	test   %ebx,%ebx
  800472:	7f ed                	jg     800461 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	56                   	push   %esi
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff 75 dc             	pushl  -0x24(%ebp)
  800484:	ff 75 d8             	pushl  -0x28(%ebp)
  800487:	e8 e4 09 00 00       	call   800e70 <__umoddi3>
  80048c:	83 c4 14             	add    $0x14,%esp
  80048f:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  800496:	50                   	push   %eax
  800497:	ff d7                	call   *%edi
}
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049f:	5b                   	pop    %ebx
  8004a0:	5e                   	pop    %esi
  8004a1:	5f                   	pop    %edi
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    
  8004a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a7:	eb c4                	jmp    80046d <printnum+0x73>

008004a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b8:	73 0a                	jae    8004c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c2:	88 02                	mov    %al,(%edx)
}
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <printfmt>:
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cf:	50                   	push   %eax
  8004d0:	ff 75 10             	pushl  0x10(%ebp)
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	ff 75 08             	pushl  0x8(%ebp)
  8004d9:	e8 05 00 00 00       	call   8004e3 <vprintfmt>
}
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <vprintfmt>:
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	57                   	push   %edi
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
  8004e9:	83 ec 2c             	sub    $0x2c,%esp
  8004ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f5:	e9 63 03 00 00       	jmp    80085d <vprintfmt+0x37a>
		padc = ' ';
  8004fa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004fe:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800505:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80050c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800513:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8d 47 01             	lea    0x1(%edi),%eax
  80051b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051e:	0f b6 17             	movzbl (%edi),%edx
  800521:	8d 42 dd             	lea    -0x23(%edx),%eax
  800524:	3c 55                	cmp    $0x55,%al
  800526:	0f 87 11 04 00 00    	ja     80093d <vprintfmt+0x45a>
  80052c:	0f b6 c0             	movzbl %al,%eax
  80052f:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800539:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053d:	eb d9                	jmp    800518 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800542:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800546:	eb d0                	jmp    800518 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800548:	0f b6 d2             	movzbl %dl,%edx
  80054b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80054e:	b8 00 00 00 00       	mov    $0x0,%eax
  800553:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800556:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800559:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80055d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800560:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800563:	83 f9 09             	cmp    $0x9,%ecx
  800566:	77 55                	ja     8005bd <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800568:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80056b:	eb e9                	jmp    800556 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 40 04             	lea    0x4(%eax),%eax
  80057b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	79 91                	jns    800518 <vprintfmt+0x35>
				width = precision, precision = -1;
  800587:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800594:	eb 82                	jmp    800518 <vprintfmt+0x35>
  800596:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800599:	85 c0                	test   %eax,%eax
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	0f 49 d0             	cmovns %eax,%edx
  8005a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 6a ff ff ff       	jmp    800518 <vprintfmt+0x35>
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b8:	e9 5b ff ff ff       	jmp    800518 <vprintfmt+0x35>
  8005bd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c3:	eb bc                	jmp    800581 <vprintfmt+0x9e>
			lflag++;
  8005c5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005cb:	e9 48 ff ff ff       	jmp    800518 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 78 04             	lea    0x4(%eax),%edi
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	ff 30                	pushl  (%eax)
  8005dc:	ff d6                	call   *%esi
			break;
  8005de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e4:	e9 71 02 00 00       	jmp    80085a <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 78 04             	lea    0x4(%eax),%edi
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	99                   	cltd   
  8005f2:	31 d0                	xor    %edx,%eax
  8005f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f6:	83 f8 08             	cmp    $0x8,%eax
  8005f9:	7f 23                	jg     80061e <vprintfmt+0x13b>
  8005fb:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800602:	85 d2                	test   %edx,%edx
  800604:	74 18                	je     80061e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800606:	52                   	push   %edx
  800607:	68 1f 10 80 00       	push   $0x80101f
  80060c:	53                   	push   %ebx
  80060d:	56                   	push   %esi
  80060e:	e8 b3 fe ff ff       	call   8004c6 <printfmt>
  800613:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800616:	89 7d 14             	mov    %edi,0x14(%ebp)
  800619:	e9 3c 02 00 00       	jmp    80085a <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 16 10 80 00       	push   $0x801016
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 9b fe ff ff       	call   8004c6 <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80062e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 24 02 00 00       	jmp    80085a <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	83 c0 04             	add    $0x4,%eax
  80063c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800644:	85 ff                	test   %edi,%edi
  800646:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  80064b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80064e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800652:	0f 8e bd 00 00 00    	jle    800715 <vprintfmt+0x232>
  800658:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80065c:	75 0e                	jne    80066c <vprintfmt+0x189>
  80065e:	89 75 08             	mov    %esi,0x8(%ebp)
  800661:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800664:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800667:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066a:	eb 6d                	jmp    8006d9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	ff 75 d0             	pushl  -0x30(%ebp)
  800672:	57                   	push   %edi
  800673:	e8 6d 03 00 00       	call   8009e5 <strnlen>
  800678:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067b:	29 c1                	sub    %eax,%ecx
  80067d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800680:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800683:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800687:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	eb 0f                	jmp    8006a0 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	ff 75 e0             	pushl  -0x20(%ebp)
  800698:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f ed                	jg     800691 <vprintfmt+0x1ae>
  8006a4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006aa:	85 c9                	test   %ecx,%ecx
  8006ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b1:	0f 49 c1             	cmovns %ecx,%eax
  8006b4:	29 c1                	sub    %eax,%ecx
  8006b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bf:	89 cb                	mov    %ecx,%ebx
  8006c1:	eb 16                	jmp    8006d9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c7:	75 31                	jne    8006fa <vprintfmt+0x217>
					putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	50                   	push   %eax
  8006d0:	ff 55 08             	call   *0x8(%ebp)
  8006d3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d6:	83 eb 01             	sub    $0x1,%ebx
  8006d9:	83 c7 01             	add    $0x1,%edi
  8006dc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006e0:	0f be c2             	movsbl %dl,%eax
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 59                	je     800740 <vprintfmt+0x25d>
  8006e7:	85 f6                	test   %esi,%esi
  8006e9:	78 d8                	js     8006c3 <vprintfmt+0x1e0>
  8006eb:	83 ee 01             	sub    $0x1,%esi
  8006ee:	79 d3                	jns    8006c3 <vprintfmt+0x1e0>
  8006f0:	89 df                	mov    %ebx,%edi
  8006f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f8:	eb 37                	jmp    800731 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	0f be d2             	movsbl %dl,%edx
  8006fd:	83 ea 20             	sub    $0x20,%edx
  800700:	83 fa 5e             	cmp    $0x5e,%edx
  800703:	76 c4                	jbe    8006c9 <vprintfmt+0x1e6>
					putch('?', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	6a 3f                	push   $0x3f
  80070d:	ff 55 08             	call   *0x8(%ebp)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb c1                	jmp    8006d6 <vprintfmt+0x1f3>
  800715:	89 75 08             	mov    %esi,0x8(%ebp)
  800718:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800721:	eb b6                	jmp    8006d9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	6a 20                	push   $0x20
  800729:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80072b:	83 ef 01             	sub    $0x1,%edi
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	85 ff                	test   %edi,%edi
  800733:	7f ee                	jg     800723 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800735:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
  80073b:	e9 1a 01 00 00       	jmp    80085a <vprintfmt+0x377>
  800740:	89 df                	mov    %ebx,%edi
  800742:	8b 75 08             	mov    0x8(%ebp),%esi
  800745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800748:	eb e7                	jmp    800731 <vprintfmt+0x24e>
	if (lflag >= 2)
  80074a:	83 f9 01             	cmp    $0x1,%ecx
  80074d:	7e 3f                	jle    80078e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 50 04             	mov    0x4(%eax),%edx
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 40 08             	lea    0x8(%eax),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800766:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076a:	79 5c                	jns    8007c8 <vprintfmt+0x2e5>
				putch('-', putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 2d                	push   $0x2d
  800772:	ff d6                	call   *%esi
				num = -(long long) num;
  800774:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800777:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077a:	f7 da                	neg    %edx
  80077c:	83 d1 00             	adc    $0x0,%ecx
  80077f:	f7 d9                	neg    %ecx
  800781:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800784:	b8 0a 00 00 00       	mov    $0xa,%eax
  800789:	e9 b2 00 00 00       	jmp    800840 <vprintfmt+0x35d>
	else if (lflag)
  80078e:	85 c9                	test   %ecx,%ecx
  800790:	75 1b                	jne    8007ad <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 00                	mov    (%eax),%eax
  800797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079a:	89 c1                	mov    %eax,%ecx
  80079c:	c1 f9 1f             	sar    $0x1f,%ecx
  80079f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 40 04             	lea    0x4(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ab:	eb b9                	jmp    800766 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b5:	89 c1                	mov    %eax,%ecx
  8007b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 40 04             	lea    0x4(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c6:	eb 9e                	jmp    800766 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d3:	eb 6b                	jmp    800840 <vprintfmt+0x35d>
	if (lflag >= 2)
  8007d5:	83 f9 01             	cmp    $0x1,%ecx
  8007d8:	7e 15                	jle    8007ef <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e2:	8d 40 08             	lea    0x8(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ed:	eb 51                	jmp    800840 <vprintfmt+0x35d>
	else if (lflag)
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	75 17                	jne    80080a <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800803:	b8 0a 00 00 00       	mov    $0xa,%eax
  800808:	eb 36                	jmp    800840 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800814:	8d 40 04             	lea    0x4(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	eb 1f                	jmp    800840 <vprintfmt+0x35d>
	if (lflag >= 2)
  800821:	83 f9 01             	cmp    $0x1,%ecx
  800824:	7e 5b                	jle    800881 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8b 50 04             	mov    0x4(%eax),%edx
  80082c:	8b 00                	mov    (%eax),%eax
  80082e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800831:	8d 49 08             	lea    0x8(%ecx),%ecx
  800834:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800837:	89 d1                	mov    %edx,%ecx
  800839:	89 c2                	mov    %eax,%edx
			base = 8;
  80083b:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800840:	83 ec 0c             	sub    $0xc,%esp
  800843:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800847:	57                   	push   %edi
  800848:	ff 75 e0             	pushl  -0x20(%ebp)
  80084b:	50                   	push   %eax
  80084c:	51                   	push   %ecx
  80084d:	52                   	push   %edx
  80084e:	89 da                	mov    %ebx,%edx
  800850:	89 f0                	mov    %esi,%eax
  800852:	e8 a3 fb ff ff       	call   8003fa <printnum>
			break;
  800857:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80085a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80085d:	83 c7 01             	add    $0x1,%edi
  800860:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800864:	83 f8 25             	cmp    $0x25,%eax
  800867:	0f 84 8d fc ff ff    	je     8004fa <vprintfmt+0x17>
			if (ch == '\0')
  80086d:	85 c0                	test   %eax,%eax
  80086f:	0f 84 e8 00 00 00    	je     80095d <vprintfmt+0x47a>
			putch(ch, putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	50                   	push   %eax
  80087a:	ff d6                	call   *%esi
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	eb dc                	jmp    80085d <vprintfmt+0x37a>
	else if (lflag)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	75 13                	jne    800898 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8b 10                	mov    (%eax),%edx
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	99                   	cltd   
  80088d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800890:	8d 49 04             	lea    0x4(%ecx),%ecx
  800893:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800896:	eb 9f                	jmp    800837 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8b 10                	mov    (%eax),%edx
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	99                   	cltd   
  8008a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a9:	eb 8c                	jmp    800837 <vprintfmt+0x354>
			putch('0', putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 30                	push   $0x30
  8008b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b3:	83 c4 08             	add    $0x8,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	6a 78                	push   $0x78
  8008b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8b 10                	mov    (%eax),%edx
  8008c0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008c8:	8d 40 04             	lea    0x4(%eax),%eax
  8008cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d3:	e9 68 ff ff ff       	jmp    800840 <vprintfmt+0x35d>
	if (lflag >= 2)
  8008d8:	83 f9 01             	cmp    $0x1,%ecx
  8008db:	7e 18                	jle    8008f5 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8b 10                	mov    (%eax),%edx
  8008e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e5:	8d 40 08             	lea    0x8(%eax),%eax
  8008e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f0:	e9 4b ff ff ff       	jmp    800840 <vprintfmt+0x35d>
	else if (lflag)
  8008f5:	85 c9                	test   %ecx,%ecx
  8008f7:	75 1a                	jne    800913 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8b 10                	mov    (%eax),%edx
  8008fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800903:	8d 40 04             	lea    0x4(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800909:	b8 10 00 00 00       	mov    $0x10,%eax
  80090e:	e9 2d ff ff ff       	jmp    800840 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8b 10                	mov    (%eax),%edx
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091d:	8d 40 04             	lea    0x4(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800923:	b8 10 00 00 00       	mov    $0x10,%eax
  800928:	e9 13 ff ff ff       	jmp    800840 <vprintfmt+0x35d>
			putch(ch, putdat);
  80092d:	83 ec 08             	sub    $0x8,%esp
  800930:	53                   	push   %ebx
  800931:	6a 25                	push   $0x25
  800933:	ff d6                	call   *%esi
			break;
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	e9 1d ff ff ff       	jmp    80085a <vprintfmt+0x377>
			putch('%', putdat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	6a 25                	push   $0x25
  800943:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	89 f8                	mov    %edi,%eax
  80094a:	eb 03                	jmp    80094f <vprintfmt+0x46c>
  80094c:	83 e8 01             	sub    $0x1,%eax
  80094f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800953:	75 f7                	jne    80094c <vprintfmt+0x469>
  800955:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800958:	e9 fd fe ff ff       	jmp    80085a <vprintfmt+0x377>
}
  80095d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 18             	sub    $0x18,%esp
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800971:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800974:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800978:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800982:	85 c0                	test   %eax,%eax
  800984:	74 26                	je     8009ac <vsnprintf+0x47>
  800986:	85 d2                	test   %edx,%edx
  800988:	7e 22                	jle    8009ac <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098a:	ff 75 14             	pushl  0x14(%ebp)
  80098d:	ff 75 10             	pushl  0x10(%ebp)
  800990:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800993:	50                   	push   %eax
  800994:	68 a9 04 80 00       	push   $0x8004a9
  800999:	e8 45 fb ff ff       	call   8004e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80099e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a7:	83 c4 10             	add    $0x10,%esp
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    
		return -E_INVAL;
  8009ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b1:	eb f7                	jmp    8009aa <vsnprintf+0x45>

008009b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009bc:	50                   	push   %eax
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 9a ff ff ff       	call   800965 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	eb 03                	jmp    8009dd <strlen+0x10>
		n++;
  8009da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e1:	75 f7                	jne    8009da <strlen+0xd>
	return n;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	eb 03                	jmp    8009f8 <strnlen+0x13>
		n++;
  8009f5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f8:	39 d0                	cmp    %edx,%eax
  8009fa:	74 06                	je     800a02 <strnlen+0x1d>
  8009fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a00:	75 f3                	jne    8009f5 <strnlen+0x10>
	return n;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a1a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ef                	jne    800a10 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a21:	5b                   	pop    %ebx
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	53                   	push   %ebx
  800a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a2b:	53                   	push   %ebx
  800a2c:	e8 9c ff ff ff       	call   8009cd <strlen>
  800a31:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	01 d8                	add    %ebx,%eax
  800a39:	50                   	push   %eax
  800a3a:	e8 c5 ff ff ff       	call   800a04 <strcpy>
	return dst;
}
  800a3f:	89 d8                	mov    %ebx,%eax
  800a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a51:	89 f3                	mov    %esi,%ebx
  800a53:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a56:	89 f2                	mov    %esi,%edx
  800a58:	eb 0f                	jmp    800a69 <strncpy+0x23>
		*dst++ = *src;
  800a5a:	83 c2 01             	add    $0x1,%edx
  800a5d:	0f b6 01             	movzbl (%ecx),%eax
  800a60:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a63:	80 39 01             	cmpb   $0x1,(%ecx)
  800a66:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a69:	39 da                	cmp    %ebx,%edx
  800a6b:	75 ed                	jne    800a5a <strncpy+0x14>
	}
	return ret;
}
  800a6d:	89 f0                	mov    %esi,%eax
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a81:	89 f0                	mov    %esi,%eax
  800a83:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a87:	85 c9                	test   %ecx,%ecx
  800a89:	75 0b                	jne    800a96 <strlcpy+0x23>
  800a8b:	eb 17                	jmp    800aa4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a8d:	83 c2 01             	add    $0x1,%edx
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 07                	je     800aa1 <strlcpy+0x2e>
  800a9a:	0f b6 0a             	movzbl (%edx),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	75 ec                	jne    800a8d <strlcpy+0x1a>
		*dst = '\0';
  800aa1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa4:	29 f0                	sub    %esi,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab3:	eb 06                	jmp    800abb <strcmp+0x11>
		p++, q++;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800abb:	0f b6 01             	movzbl (%ecx),%eax
  800abe:	84 c0                	test   %al,%al
  800ac0:	74 04                	je     800ac6 <strcmp+0x1c>
  800ac2:	3a 02                	cmp    (%edx),%al
  800ac4:	74 ef                	je     800ab5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac6:	0f b6 c0             	movzbl %al,%eax
  800ac9:	0f b6 12             	movzbl (%edx),%edx
  800acc:	29 d0                	sub    %edx,%eax
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800adf:	eb 06                	jmp    800ae7 <strncmp+0x17>
		n--, p++, q++;
  800ae1:	83 c0 01             	add    $0x1,%eax
  800ae4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ae7:	39 d8                	cmp    %ebx,%eax
  800ae9:	74 16                	je     800b01 <strncmp+0x31>
  800aeb:	0f b6 08             	movzbl (%eax),%ecx
  800aee:	84 c9                	test   %cl,%cl
  800af0:	74 04                	je     800af6 <strncmp+0x26>
  800af2:	3a 0a                	cmp    (%edx),%cl
  800af4:	74 eb                	je     800ae1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af6:	0f b6 00             	movzbl (%eax),%eax
  800af9:	0f b6 12             	movzbl (%edx),%edx
  800afc:	29 d0                	sub    %edx,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    
		return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	eb f6                	jmp    800afe <strncmp+0x2e>

00800b08 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b12:	0f b6 10             	movzbl (%eax),%edx
  800b15:	84 d2                	test   %dl,%dl
  800b17:	74 09                	je     800b22 <strchr+0x1a>
		if (*s == c)
  800b19:	38 ca                	cmp    %cl,%dl
  800b1b:	74 0a                	je     800b27 <strchr+0x1f>
	for (; *s; s++)
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	eb f0                	jmp    800b12 <strchr+0xa>
			return (char *) s;
	return 0;
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b33:	eb 03                	jmp    800b38 <strfind+0xf>
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b3b:	38 ca                	cmp    %cl,%dl
  800b3d:	74 04                	je     800b43 <strfind+0x1a>
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f2                	jne    800b35 <strfind+0xc>
			break;
	return (char *) s;
}
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b51:	85 c9                	test   %ecx,%ecx
  800b53:	74 13                	je     800b68 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5b:	75 05                	jne    800b62 <memset+0x1d>
  800b5d:	f6 c1 03             	test   $0x3,%cl
  800b60:	74 0d                	je     800b6f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	fc                   	cld    
  800b66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b68:	89 f8                	mov    %edi,%eax
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    
		c &= 0xFF;
  800b6f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	c1 e3 08             	shl    $0x8,%ebx
  800b78:	89 d0                	mov    %edx,%eax
  800b7a:	c1 e0 18             	shl    $0x18,%eax
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	c1 e6 10             	shl    $0x10,%esi
  800b82:	09 f0                	or     %esi,%eax
  800b84:	09 c2                	or     %eax,%edx
  800b86:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b88:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	fc                   	cld    
  800b8e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b90:	eb d6                	jmp    800b68 <memset+0x23>

00800b92 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba0:	39 c6                	cmp    %eax,%esi
  800ba2:	73 35                	jae    800bd9 <memmove+0x47>
  800ba4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba7:	39 c2                	cmp    %eax,%edx
  800ba9:	76 2e                	jbe    800bd9 <memmove+0x47>
		s += n;
		d += n;
  800bab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	09 fe                	or     %edi,%esi
  800bb2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb8:	74 0c                	je     800bc6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bba:	83 ef 01             	sub    $0x1,%edi
  800bbd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc0:	fd                   	std    
  800bc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc3:	fc                   	cld    
  800bc4:	eb 21                	jmp    800be7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc6:	f6 c1 03             	test   $0x3,%cl
  800bc9:	75 ef                	jne    800bba <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bcb:	83 ef 04             	sub    $0x4,%edi
  800bce:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bd4:	fd                   	std    
  800bd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd7:	eb ea                	jmp    800bc3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd9:	89 f2                	mov    %esi,%edx
  800bdb:	09 c2                	or     %eax,%edx
  800bdd:	f6 c2 03             	test   $0x3,%dl
  800be0:	74 09                	je     800beb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be2:	89 c7                	mov    %eax,%edi
  800be4:	fc                   	cld    
  800be5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800beb:	f6 c1 03             	test   $0x3,%cl
  800bee:	75 f2                	jne    800be2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	fc                   	cld    
  800bf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf8:	eb ed                	jmp    800be7 <memmove+0x55>

00800bfa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bfd:	ff 75 10             	pushl  0x10(%ebp)
  800c00:	ff 75 0c             	pushl  0xc(%ebp)
  800c03:	ff 75 08             	pushl  0x8(%ebp)
  800c06:	e8 87 ff ff ff       	call   800b92 <memmove>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c18:	89 c6                	mov    %eax,%esi
  800c1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1d:	39 f0                	cmp    %esi,%eax
  800c1f:	74 1c                	je     800c3d <memcmp+0x30>
		if (*s1 != *s2)
  800c21:	0f b6 08             	movzbl (%eax),%ecx
  800c24:	0f b6 1a             	movzbl (%edx),%ebx
  800c27:	38 d9                	cmp    %bl,%cl
  800c29:	75 08                	jne    800c33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	eb ea                	jmp    800c1d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c33:	0f b6 c1             	movzbl %cl,%eax
  800c36:	0f b6 db             	movzbl %bl,%ebx
  800c39:	29 d8                	sub    %ebx,%eax
  800c3b:	eb 05                	jmp    800c42 <memcmp+0x35>
	}

	return 0;
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c54:	39 d0                	cmp    %edx,%eax
  800c56:	73 09                	jae    800c61 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c58:	38 08                	cmp    %cl,(%eax)
  800c5a:	74 05                	je     800c61 <memfind+0x1b>
	for (; s < ends; s++)
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	eb f3                	jmp    800c54 <memfind+0xe>
			break;
	return (void *) s;
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6f:	eb 03                	jmp    800c74 <strtol+0x11>
		s++;
  800c71:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c74:	0f b6 01             	movzbl (%ecx),%eax
  800c77:	3c 20                	cmp    $0x20,%al
  800c79:	74 f6                	je     800c71 <strtol+0xe>
  800c7b:	3c 09                	cmp    $0x9,%al
  800c7d:	74 f2                	je     800c71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c7f:	3c 2b                	cmp    $0x2b,%al
  800c81:	74 2e                	je     800cb1 <strtol+0x4e>
	int neg = 0;
  800c83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c88:	3c 2d                	cmp    $0x2d,%al
  800c8a:	74 2f                	je     800cbb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c92:	75 05                	jne    800c99 <strtol+0x36>
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	74 2c                	je     800cc5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c99:	85 db                	test   %ebx,%ebx
  800c9b:	75 0a                	jne    800ca7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ca2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca5:	74 28                	je     800ccf <strtol+0x6c>
		base = 10;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800caf:	eb 50                	jmp    800d01 <strtol+0x9e>
		s++;
  800cb1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cb4:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb9:	eb d1                	jmp    800c8c <strtol+0x29>
		s++, neg = 1;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc3:	eb c7                	jmp    800c8c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc9:	74 0e                	je     800cd9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ccb:	85 db                	test   %ebx,%ebx
  800ccd:	75 d8                	jne    800ca7 <strtol+0x44>
		s++, base = 8;
  800ccf:	83 c1 01             	add    $0x1,%ecx
  800cd2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cd7:	eb ce                	jmp    800ca7 <strtol+0x44>
		s += 2, base = 16;
  800cd9:	83 c1 02             	add    $0x2,%ecx
  800cdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce1:	eb c4                	jmp    800ca7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 29                	ja     800d16 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf6:	7d 30                	jge    800d28 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cf8:	83 c1 01             	add    $0x1,%ecx
  800cfb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cff:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d01:	0f b6 11             	movzbl (%ecx),%edx
  800d04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d07:	89 f3                	mov    %esi,%ebx
  800d09:	80 fb 09             	cmp    $0x9,%bl
  800d0c:	77 d5                	ja     800ce3 <strtol+0x80>
			dig = *s - '0';
  800d0e:	0f be d2             	movsbl %dl,%edx
  800d11:	83 ea 30             	sub    $0x30,%edx
  800d14:	eb dd                	jmp    800cf3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d16:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d19:	89 f3                	mov    %esi,%ebx
  800d1b:	80 fb 19             	cmp    $0x19,%bl
  800d1e:	77 08                	ja     800d28 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d20:	0f be d2             	movsbl %dl,%edx
  800d23:	83 ea 37             	sub    $0x37,%edx
  800d26:	eb cb                	jmp    800cf3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d2c:	74 05                	je     800d33 <strtol+0xd0>
		*endptr = (char *) s;
  800d2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d31:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	f7 da                	neg    %edx
  800d37:	85 ff                	test   %edi,%edi
  800d39:	0f 45 c2             	cmovne %edx,%eax
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    
  800d41:	66 90                	xchg   %ax,%ax
  800d43:	66 90                	xchg   %ax,%ax
  800d45:	66 90                	xchg   %ax,%ax
  800d47:	66 90                	xchg   %ax,%ax
  800d49:	66 90                	xchg   %ax,%ax
  800d4b:	66 90                	xchg   %ax,%ax
  800d4d:	66 90                	xchg   %ax,%ax
  800d4f:	90                   	nop

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d67:	85 d2                	test   %edx,%edx
  800d69:	75 35                	jne    800da0 <__udivdi3+0x50>
  800d6b:	39 f3                	cmp    %esi,%ebx
  800d6d:	0f 87 bd 00 00 00    	ja     800e30 <__udivdi3+0xe0>
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	89 d9                	mov    %ebx,%ecx
  800d77:	75 0b                	jne    800d84 <__udivdi3+0x34>
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f3                	div    %ebx
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	31 d2                	xor    %edx,%edx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c6                	mov    %eax,%esi
  800d8c:	89 e8                	mov    %ebp,%eax
  800d8e:	89 f7                	mov    %esi,%edi
  800d90:	f7 f1                	div    %ecx
  800d92:	89 fa                	mov    %edi,%edx
  800d94:	83 c4 1c             	add    $0x1c,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
  800d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	77 7c                	ja     800e20 <__udivdi3+0xd0>
  800da4:	0f bd fa             	bsr    %edx,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0xf8>
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	b8 20 00 00 00       	mov    $0x20,%eax
  800db7:	29 f8                	sub    %edi,%eax
  800db9:	d3 e2                	shl    %cl,%edx
  800dbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 da                	mov    %ebx,%edx
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 d1                	or     %edx,%ecx
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	d3 ea                	shr    %cl,%edx
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	d3 e6                	shl    %cl,%esi
  800de1:	89 eb                	mov    %ebp,%ebx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 de                	or     %ebx,%esi
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	f7 74 24 08          	divl   0x8(%esp)
  800def:	89 d6                	mov    %edx,%esi
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	f7 64 24 0c          	mull   0xc(%esp)
  800df7:	39 d6                	cmp    %edx,%esi
  800df9:	72 0c                	jb     800e07 <__udivdi3+0xb7>
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	39 c5                	cmp    %eax,%ebp
  800e01:	73 5d                	jae    800e60 <__udivdi3+0x110>
  800e03:	39 d6                	cmp    %edx,%esi
  800e05:	75 59                	jne    800e60 <__udivdi3+0x110>
  800e07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e0a:	31 ff                	xor    %edi,%edi
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	8d 76 00             	lea    0x0(%esi),%esi
  800e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	83 c4 1c             	add    $0x1c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	89 e8                	mov    %ebp,%eax
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	f7 f3                	div    %ebx
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x102>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 d2                	ja     800e24 <__udivdi3+0xd4>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb cb                	jmp    800e24 <__udivdi3+0xd4>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	31 ff                	xor    %edi,%edi
  800e64:	eb be                	jmp    800e24 <__udivdi3+0xd4>
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 ed                	test   %ebp,%ebp
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	75 19                	jne    800ea8 <__umoddi3+0x38>
  800e8f:	39 df                	cmp    %ebx,%edi
  800e91:	0f 86 b1 00 00 00    	jbe    800f48 <__umoddi3+0xd8>
  800e97:	f7 f7                	div    %edi
  800e99:	89 d0                	mov    %edx,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 dd                	cmp    %ebx,%ebp
  800eaa:	77 f1                	ja     800e9d <__umoddi3+0x2d>
  800eac:	0f bd cd             	bsr    %ebp,%ecx
  800eaf:	83 f1 1f             	xor    $0x1f,%ecx
  800eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eb6:	0f 84 b4 00 00 00    	je     800f70 <__umoddi3+0x100>
  800ebc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ec7:	29 c2                	sub    %eax,%edx
  800ec9:	89 c1                	mov    %eax,%ecx
  800ecb:	89 f8                	mov    %edi,%eax
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed5:	d3 e8                	shr    %cl,%eax
  800ed7:	09 c5                	or     %eax,%ebp
  800ed9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edd:	89 c1                	mov    %eax,%ecx
  800edf:	d3 e7                	shl    %cl,%edi
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee7:	89 df                	mov    %ebx,%edi
  800ee9:	d3 ef                	shr    %cl,%edi
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	d3 e3                	shl    %cl,%ebx
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 fa                	mov    %edi,%edx
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800efc:	09 d8                	or     %ebx,%eax
  800efe:	f7 f5                	div    %ebp
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	f7 64 24 08          	mull   0x8(%esp)
  800f08:	39 d1                	cmp    %edx,%ecx
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	72 06                	jb     800f16 <__umoddi3+0xa6>
  800f10:	75 0e                	jne    800f20 <__umoddi3+0xb0>
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 0a                	jae    800f20 <__umoddi3+0xb0>
  800f16:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f1a:	19 ea                	sbb    %ebp,%edx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	89 ca                	mov    %ecx,%edx
  800f22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f27:	29 de                	sub    %ebx,%esi
  800f29:	19 fa                	sbb    %edi,%edx
  800f2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	89 d9                	mov    %ebx,%ecx
  800f35:	d3 ee                	shr    %cl,%esi
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	09 f0                	or     %esi,%eax
  800f3b:	83 c4 1c             	add    $0x1c,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	85 ff                	test   %edi,%edi
  800f4a:	89 f9                	mov    %edi,%ecx
  800f4c:	75 0b                	jne    800f59 <__umoddi3+0xe9>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f7                	div    %edi
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f1                	div    %ecx
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	f7 f1                	div    %ecx
  800f63:	e9 31 ff ff ff       	jmp    800e99 <__umoddi3+0x29>
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	39 dd                	cmp    %ebx,%ebp
  800f72:	72 08                	jb     800f7c <__umoddi3+0x10c>
  800f74:	39 f7                	cmp    %esi,%edi
  800f76:	0f 87 21 ff ff ff    	ja     800e9d <__umoddi3+0x2d>
  800f7c:	89 da                	mov    %ebx,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	29 f8                	sub    %edi,%eax
  800f82:	19 ea                	sbb    %ebp,%edx
  800f84:	e9 14 ff ff ff       	jmp    800e9d <__umoddi3+0x2d>
