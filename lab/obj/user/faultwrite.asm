
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800054:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800057:	e8 c6 00 00 00       	call   800122 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 db                	test   %ebx,%ebx
  800070:	7e 07                	jle    800079 <libmain+0x37>
		binaryname = argv[0];
  800072:	8b 06                	mov    (%esi),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 0a 00 00 00       	call   800092 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800098:	6a 00                	push   $0x0
  80009a:	e8 42 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7f 08                	jg     80010b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 aa 0f 80 00       	push   $0x800faa
  800116:	6a 23                	push   $0x23
  800118:	68 c7 0f 80 00       	push   $0x800fc7
  80011d:	e8 ed 01 00 00       	call   80030f <_panic>

00800122 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	asm volatile("int %1\n"
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 02 00 00 00       	mov    $0x2,%eax
  800132:	89 d1                	mov    %edx,%ecx
  800134:	89 d3                	mov    %edx,%ebx
  800136:	89 d7                	mov    %edx,%edi
  800138:	89 d6                	mov    %edx,%esi
  80013a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5f                   	pop    %edi
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <sys_yield>:

void
sys_yield(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	57                   	push   %edi
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	asm volatile("int %1\n"
  800147:	ba 00 00 00 00       	mov    $0x0,%edx
  80014c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800151:	89 d1                	mov    %edx,%ecx
  800153:	89 d3                	mov    %edx,%ebx
  800155:	89 d7                	mov    %edx,%edi
  800157:	89 d6                	mov    %edx,%esi
  800159:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800169:	be 00 00 00 00       	mov    $0x0,%esi
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017c:	89 f7                	mov    %esi,%edi
  80017e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800180:	85 c0                	test   %eax,%eax
  800182:	7f 08                	jg     80018c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5f                   	pop    %edi
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 aa 0f 80 00       	push   $0x800faa
  800197:	6a 23                	push   $0x23
  800199:	68 c7 0f 80 00       	push   $0x800fc7
  80019e:	e8 6c 01 00 00       	call   80030f <_panic>

008001a3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7f 08                	jg     8001ce <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 aa 0f 80 00       	push   $0x800faa
  8001d9:	6a 23                	push   $0x23
  8001db:	68 c7 0f 80 00       	push   $0x800fc7
  8001e0:	e8 2a 01 00 00       	call   80030f <_panic>

008001e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	89 df                	mov    %ebx,%edi
  800200:	89 de                	mov    %ebx,%esi
  800202:	cd 30                	int    $0x30
	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7f 08                	jg     800210 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 aa 0f 80 00       	push   $0x800faa
  80021b:	6a 23                	push   $0x23
  80021d:	68 c7 0f 80 00       	push   $0x800fc7
  800222:	e8 e8 00 00 00       	call   80030f <_panic>

00800227 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7f 08                	jg     800252 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 aa 0f 80 00       	push   $0x800faa
  80025d:	6a 23                	push   $0x23
  80025f:	68 c7 0f 80 00       	push   $0x800fc7
  800264:	e8 a6 00 00 00       	call   80030f <_panic>

00800269 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7f 08                	jg     800294 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 aa 0f 80 00       	push   $0x800faa
  80029f:	6a 23                	push   $0x23
  8002a1:	68 c7 0f 80 00       	push   $0x800fc7
  8002a6:	e8 64 00 00 00       	call   80030f <_panic>

008002ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bc:	be 00 00 00 00       	mov    $0x0,%esi
  8002c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e4:	89 cb                	mov    %ecx,%ebx
  8002e6:	89 cf                	mov    %ecx,%edi
  8002e8:	89 ce                	mov    %ecx,%esi
  8002ea:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7f 08                	jg     8002f8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f3:	5b                   	pop    %ebx
  8002f4:	5e                   	pop    %esi
  8002f5:	5f                   	pop    %edi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 aa 0f 80 00       	push   $0x800faa
  800303:	6a 23                	push   $0x23
  800305:	68 c7 0f 80 00       	push   $0x800fc7
  80030a:	e8 00 00 00 00       	call   80030f <_panic>

0080030f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800317:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031d:	e8 00 fe ff ff       	call   800122 <sys_getenvid>
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	56                   	push   %esi
  80032c:	50                   	push   %eax
  80032d:	68 d8 0f 80 00       	push   $0x800fd8
  800332:	e8 b3 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800337:	83 c4 18             	add    $0x18,%esp
  80033a:	53                   	push   %ebx
  80033b:	ff 75 10             	pushl  0x10(%ebp)
  80033e:	e8 56 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800343:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  80034a:	e8 9b 00 00 00       	call   8003ea <cprintf>
  80034f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800352:	cc                   	int3   
  800353:	eb fd                	jmp    800352 <_panic+0x43>

00800355 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	53                   	push   %ebx
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035f:	8b 13                	mov    (%ebx),%edx
  800361:	8d 42 01             	lea    0x1(%edx),%eax
  800364:	89 03                	mov    %eax,(%ebx)
  800366:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800369:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800372:	74 09                	je     80037d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800374:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	68 ff 00 00 00       	push   $0xff
  800385:	8d 43 08             	lea    0x8(%ebx),%eax
  800388:	50                   	push   %eax
  800389:	e8 16 fd ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  80038e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800394:	83 c4 10             	add    $0x10,%esp
  800397:	eb db                	jmp    800374 <putch+0x1f>

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 55 03 80 00       	push   $0x800355
  8003c8:	e8 1a 01 00 00       	call   8004e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c2 fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800417:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800422:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800425:	39 d3                	cmp    %edx,%ebx
  800427:	72 05                	jb     80042e <printnum+0x30>
  800429:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042c:	77 7a                	ja     8004a8 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff 75 18             	pushl  0x18(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043a:	53                   	push   %ebx
  80043b:	ff 75 10             	pushl  0x10(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 fe 08 00 00       	call   800d50 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 13                	jmp    800478 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800471:	83 eb 01             	sub    $0x1,%ebx
  800474:	85 db                	test   %ebx,%ebx
  800476:	7f ed                	jg     800465 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	83 ec 04             	sub    $0x4,%esp
  80047f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	e8 e0 09 00 00       	call   800e70 <__umoddi3>
  800490:	83 c4 14             	add    $0x14,%esp
  800493:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  80049a:	50                   	push   %eax
  80049b:	ff d7                	call   *%edi
}
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a3:	5b                   	pop    %ebx
  8004a4:	5e                   	pop    %esi
  8004a5:	5f                   	pop    %edi
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    
  8004a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004ab:	eb c4                	jmp    800471 <printnum+0x73>

008004ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bc:	73 0a                	jae    8004c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c1:	89 08                	mov    %ecx,(%eax)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	88 02                	mov    %al,(%edx)
}
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <printfmt>:
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d3:	50                   	push   %eax
  8004d4:	ff 75 10             	pushl  0x10(%ebp)
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	ff 75 08             	pushl  0x8(%ebp)
  8004dd:	e8 05 00 00 00       	call   8004e7 <vprintfmt>
}
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	c9                   	leave  
  8004e6:	c3                   	ret    

008004e7 <vprintfmt>:
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	57                   	push   %edi
  8004eb:	56                   	push   %esi
  8004ec:	53                   	push   %ebx
  8004ed:	83 ec 2c             	sub    $0x2c,%esp
  8004f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f9:	e9 63 03 00 00       	jmp    800861 <vprintfmt+0x37a>
		padc = ' ';
  8004fe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800502:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800509:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800510:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800517:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8d 47 01             	lea    0x1(%edi),%eax
  80051f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800522:	0f b6 17             	movzbl (%edi),%edx
  800525:	8d 42 dd             	lea    -0x23(%edx),%eax
  800528:	3c 55                	cmp    $0x55,%al
  80052a:	0f 87 11 04 00 00    	ja     800941 <vprintfmt+0x45a>
  800530:	0f b6 c0             	movzbl %al,%eax
  800533:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800541:	eb d9                	jmp    80051c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800546:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054a:	eb d0                	jmp    80051c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	0f b6 d2             	movzbl %dl,%edx
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800552:	b8 00 00 00 00       	mov    $0x0,%eax
  800557:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800561:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800564:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800567:	83 f9 09             	cmp    $0x9,%ecx
  80056a:	77 55                	ja     8005c1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80056c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80056f:	eb e9                	jmp    80055a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800589:	79 91                	jns    80051c <vprintfmt+0x35>
				width = precision, precision = -1;
  80058b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800591:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800598:	eb 82                	jmp    80051c <vprintfmt+0x35>
  80059a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059d:	85 c0                	test   %eax,%eax
  80059f:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a4:	0f 49 d0             	cmovns %eax,%edx
  8005a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 6a ff ff ff       	jmp    80051c <vprintfmt+0x35>
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bc:	e9 5b ff ff ff       	jmp    80051c <vprintfmt+0x35>
  8005c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c7:	eb bc                	jmp    800585 <vprintfmt+0x9e>
			lflag++;
  8005c9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005cf:	e9 48 ff ff ff       	jmp    80051c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 78 04             	lea    0x4(%eax),%edi
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	ff 30                	pushl  (%eax)
  8005e0:	ff d6                	call   *%esi
			break;
  8005e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e8:	e9 71 02 00 00       	jmp    80085e <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 78 04             	lea    0x4(%eax),%edi
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	99                   	cltd   
  8005f6:	31 d0                	xor    %edx,%eax
  8005f8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fa:	83 f8 08             	cmp    $0x8,%eax
  8005fd:	7f 23                	jg     800622 <vprintfmt+0x13b>
  8005ff:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800606:	85 d2                	test   %edx,%edx
  800608:	74 18                	je     800622 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80060a:	52                   	push   %edx
  80060b:	68 1f 10 80 00       	push   $0x80101f
  800610:	53                   	push   %ebx
  800611:	56                   	push   %esi
  800612:	e8 b3 fe ff ff       	call   8004ca <printfmt>
  800617:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80061d:	e9 3c 02 00 00       	jmp    80085e <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800622:	50                   	push   %eax
  800623:	68 16 10 80 00       	push   $0x801016
  800628:	53                   	push   %ebx
  800629:	56                   	push   %esi
  80062a:	e8 9b fe ff ff       	call   8004ca <printfmt>
  80062f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800632:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800635:	e9 24 02 00 00       	jmp    80085e <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	83 c0 04             	add    $0x4,%eax
  800640:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800648:	85 ff                	test   %edi,%edi
  80064a:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  80064f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800652:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800656:	0f 8e bd 00 00 00    	jle    800719 <vprintfmt+0x232>
  80065c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800660:	75 0e                	jne    800670 <vprintfmt+0x189>
  800662:	89 75 08             	mov    %esi,0x8(%ebp)
  800665:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066e:	eb 6d                	jmp    8006dd <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	ff 75 d0             	pushl  -0x30(%ebp)
  800676:	57                   	push   %edi
  800677:	e8 6d 03 00 00       	call   8009e9 <strnlen>
  80067c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067f:	29 c1                	sub    %eax,%ecx
  800681:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800684:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800687:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800691:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800693:	eb 0f                	jmp    8006a4 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	ff 75 e0             	pushl  -0x20(%ebp)
  80069c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	85 ff                	test   %edi,%edi
  8006a6:	7f ed                	jg     800695 <vprintfmt+0x1ae>
  8006a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b5:	0f 49 c1             	cmovns %ecx,%eax
  8006b8:	29 c1                	sub    %eax,%ecx
  8006ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c3:	89 cb                	mov    %ecx,%ebx
  8006c5:	eb 16                	jmp    8006dd <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006cb:	75 31                	jne    8006fe <vprintfmt+0x217>
					putch(ch, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	ff 55 08             	call   *0x8(%ebp)
  8006d7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	83 eb 01             	sub    $0x1,%ebx
  8006dd:	83 c7 01             	add    $0x1,%edi
  8006e0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006e4:	0f be c2             	movsbl %dl,%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 59                	je     800744 <vprintfmt+0x25d>
  8006eb:	85 f6                	test   %esi,%esi
  8006ed:	78 d8                	js     8006c7 <vprintfmt+0x1e0>
  8006ef:	83 ee 01             	sub    $0x1,%esi
  8006f2:	79 d3                	jns    8006c7 <vprintfmt+0x1e0>
  8006f4:	89 df                	mov    %ebx,%edi
  8006f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fc:	eb 37                	jmp    800735 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fe:	0f be d2             	movsbl %dl,%edx
  800701:	83 ea 20             	sub    $0x20,%edx
  800704:	83 fa 5e             	cmp    $0x5e,%edx
  800707:	76 c4                	jbe    8006cd <vprintfmt+0x1e6>
					putch('?', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	6a 3f                	push   $0x3f
  800711:	ff 55 08             	call   *0x8(%ebp)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb c1                	jmp    8006da <vprintfmt+0x1f3>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb b6                	jmp    8006dd <vprintfmt+0x1f6>
				putch(' ', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 20                	push   $0x20
  80072d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80072f:	83 ef 01             	sub    $0x1,%edi
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 ff                	test   %edi,%edi
  800737:	7f ee                	jg     800727 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800739:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
  80073f:	e9 1a 01 00 00       	jmp    80085e <vprintfmt+0x377>
  800744:	89 df                	mov    %ebx,%edi
  800746:	8b 75 08             	mov    0x8(%ebp),%esi
  800749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074c:	eb e7                	jmp    800735 <vprintfmt+0x24e>
	if (lflag >= 2)
  80074e:	83 f9 01             	cmp    $0x1,%ecx
  800751:	7e 3f                	jle    800792 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 50 04             	mov    0x4(%eax),%edx
  800759:	8b 00                	mov    (%eax),%eax
  80075b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 40 08             	lea    0x8(%eax),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80076a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076e:	79 5c                	jns    8007cc <vprintfmt+0x2e5>
				putch('-', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 2d                	push   $0x2d
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077e:	f7 da                	neg    %edx
  800780:	83 d1 00             	adc    $0x0,%ecx
  800783:	f7 d9                	neg    %ecx
  800785:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 b2 00 00 00       	jmp    800844 <vprintfmt+0x35d>
	else if (lflag)
  800792:	85 c9                	test   %ecx,%ecx
  800794:	75 1b                	jne    8007b1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079e:	89 c1                	mov    %eax,%ecx
  8007a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8007af:	eb b9                	jmp    80076a <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 c1                	mov    %eax,%ecx
  8007bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 40 04             	lea    0x4(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ca:	eb 9e                	jmp    80076a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d7:	eb 6b                	jmp    800844 <vprintfmt+0x35d>
	if (lflag >= 2)
  8007d9:	83 f9 01             	cmp    $0x1,%ecx
  8007dc:	7e 15                	jle    8007f3 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8b 10                	mov    (%eax),%edx
  8007e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e6:	8d 40 08             	lea    0x8(%eax),%eax
  8007e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f1:	eb 51                	jmp    800844 <vprintfmt+0x35d>
	else if (lflag)
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	75 17                	jne    80080e <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800801:	8d 40 04             	lea    0x4(%eax),%eax
  800804:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080c:	eb 36                	jmp    800844 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8b 10                	mov    (%eax),%edx
  800813:	b9 00 00 00 00       	mov    $0x0,%ecx
  800818:	8d 40 04             	lea    0x4(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	eb 1f                	jmp    800844 <vprintfmt+0x35d>
	if (lflag >= 2)
  800825:	83 f9 01             	cmp    $0x1,%ecx
  800828:	7e 5b                	jle    800885 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8b 50 04             	mov    0x4(%eax),%edx
  800830:	8b 00                	mov    (%eax),%eax
  800832:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800835:	8d 49 08             	lea    0x8(%ecx),%ecx
  800838:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80083b:	89 d1                	mov    %edx,%ecx
  80083d:	89 c2                	mov    %eax,%edx
			base = 8;
  80083f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800844:	83 ec 0c             	sub    $0xc,%esp
  800847:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80084b:	57                   	push   %edi
  80084c:	ff 75 e0             	pushl  -0x20(%ebp)
  80084f:	50                   	push   %eax
  800850:	51                   	push   %ecx
  800851:	52                   	push   %edx
  800852:	89 da                	mov    %ebx,%edx
  800854:	89 f0                	mov    %esi,%eax
  800856:	e8 a3 fb ff ff       	call   8003fe <printnum>
			break;
  80085b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800861:	83 c7 01             	add    $0x1,%edi
  800864:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800868:	83 f8 25             	cmp    $0x25,%eax
  80086b:	0f 84 8d fc ff ff    	je     8004fe <vprintfmt+0x17>
			if (ch == '\0')
  800871:	85 c0                	test   %eax,%eax
  800873:	0f 84 e8 00 00 00    	je     800961 <vprintfmt+0x47a>
			putch(ch, putdat);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	53                   	push   %ebx
  80087d:	50                   	push   %eax
  80087e:	ff d6                	call   *%esi
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	eb dc                	jmp    800861 <vprintfmt+0x37a>
	else if (lflag)
  800885:	85 c9                	test   %ecx,%ecx
  800887:	75 13                	jne    80089c <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	89 d0                	mov    %edx,%eax
  800890:	99                   	cltd   
  800891:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800894:	8d 49 04             	lea    0x4(%ecx),%ecx
  800897:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089a:	eb 9f                	jmp    80083b <vprintfmt+0x354>
		return va_arg(*ap, long);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8b 10                	mov    (%eax),%edx
  8008a1:	89 d0                	mov    %edx,%eax
  8008a3:	99                   	cltd   
  8008a4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ad:	eb 8c                	jmp    80083b <vprintfmt+0x354>
			putch('0', putdat);
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	6a 30                	push   $0x30
  8008b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b7:	83 c4 08             	add    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 78                	push   $0x78
  8008bd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8b 10                	mov    (%eax),%edx
  8008c4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008cc:	8d 40 04             	lea    0x4(%eax),%eax
  8008cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d7:	e9 68 ff ff ff       	jmp    800844 <vprintfmt+0x35d>
	if (lflag >= 2)
  8008dc:	83 f9 01             	cmp    $0x1,%ecx
  8008df:	7e 18                	jle    8008f9 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8b 10                	mov    (%eax),%edx
  8008e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e9:	8d 40 08             	lea    0x8(%eax),%eax
  8008ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ef:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f4:	e9 4b ff ff ff       	jmp    800844 <vprintfmt+0x35d>
	else if (lflag)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	75 1a                	jne    800917 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 10                	mov    (%eax),%edx
  800902:	b9 00 00 00 00       	mov    $0x0,%ecx
  800907:	8d 40 04             	lea    0x4(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090d:	b8 10 00 00 00       	mov    $0x10,%eax
  800912:	e9 2d ff ff ff       	jmp    800844 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8b 10                	mov    (%eax),%edx
  80091c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800921:	8d 40 04             	lea    0x4(%eax),%eax
  800924:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800927:	b8 10 00 00 00       	mov    $0x10,%eax
  80092c:	e9 13 ff ff ff       	jmp    800844 <vprintfmt+0x35d>
			putch(ch, putdat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	53                   	push   %ebx
  800935:	6a 25                	push   $0x25
  800937:	ff d6                	call   *%esi
			break;
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	e9 1d ff ff ff       	jmp    80085e <vprintfmt+0x377>
			putch('%', putdat);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	53                   	push   %ebx
  800945:	6a 25                	push   $0x25
  800947:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	eb 03                	jmp    800953 <vprintfmt+0x46c>
  800950:	83 e8 01             	sub    $0x1,%eax
  800953:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800957:	75 f7                	jne    800950 <vprintfmt+0x469>
  800959:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80095c:	e9 fd fe ff ff       	jmp    80085e <vprintfmt+0x377>
}
  800961:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	83 ec 18             	sub    $0x18,%esp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800975:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800978:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80097c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800986:	85 c0                	test   %eax,%eax
  800988:	74 26                	je     8009b0 <vsnprintf+0x47>
  80098a:	85 d2                	test   %edx,%edx
  80098c:	7e 22                	jle    8009b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098e:	ff 75 14             	pushl  0x14(%ebp)
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800997:	50                   	push   %eax
  800998:	68 ad 04 80 00       	push   $0x8004ad
  80099d:	e8 45 fb ff ff       	call   8004e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ab:	83 c4 10             	add    $0x10,%esp
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    
		return -E_INVAL;
  8009b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b5:	eb f7                	jmp    8009ae <vsnprintf+0x45>

008009b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c0:	50                   	push   %eax
  8009c1:	ff 75 10             	pushl  0x10(%ebp)
  8009c4:	ff 75 0c             	pushl  0xc(%ebp)
  8009c7:	ff 75 08             	pushl  0x8(%ebp)
  8009ca:	e8 9a ff ff ff       	call   800969 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb 03                	jmp    8009e1 <strlen+0x10>
		n++;
  8009de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e5:	75 f7                	jne    8009de <strlen+0xd>
	return n;
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	eb 03                	jmp    8009fc <strnlen+0x13>
		n++;
  8009f9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fc:	39 d0                	cmp    %edx,%eax
  8009fe:	74 06                	je     800a06 <strnlen+0x1d>
  800a00:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a04:	75 f3                	jne    8009f9 <strnlen+0x10>
	return n;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	53                   	push   %ebx
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a1e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a21:	84 db                	test   %bl,%bl
  800a23:	75 ef                	jne    800a14 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a25:	5b                   	pop    %ebx
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	53                   	push   %ebx
  800a2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a2f:	53                   	push   %ebx
  800a30:	e8 9c ff ff ff       	call   8009d1 <strlen>
  800a35:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a38:	ff 75 0c             	pushl  0xc(%ebp)
  800a3b:	01 d8                	add    %ebx,%eax
  800a3d:	50                   	push   %eax
  800a3e:	e8 c5 ff ff ff       	call   800a08 <strcpy>
	return dst;
}
  800a43:	89 d8                	mov    %ebx,%eax
  800a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    

00800a4a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a55:	89 f3                	mov    %esi,%ebx
  800a57:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a5a:	89 f2                	mov    %esi,%edx
  800a5c:	eb 0f                	jmp    800a6d <strncpy+0x23>
		*dst++ = *src;
  800a5e:	83 c2 01             	add    $0x1,%edx
  800a61:	0f b6 01             	movzbl (%ecx),%eax
  800a64:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a67:	80 39 01             	cmpb   $0x1,(%ecx)
  800a6a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a6d:	39 da                	cmp    %ebx,%edx
  800a6f:	75 ed                	jne    800a5e <strncpy+0x14>
	}
	return ret;
}
  800a71:	89 f0                	mov    %esi,%eax
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a85:	89 f0                	mov    %esi,%eax
  800a87:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a8b:	85 c9                	test   %ecx,%ecx
  800a8d:	75 0b                	jne    800a9a <strlcpy+0x23>
  800a8f:	eb 17                	jmp    800aa8 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a9a:	39 d8                	cmp    %ebx,%eax
  800a9c:	74 07                	je     800aa5 <strlcpy+0x2e>
  800a9e:	0f b6 0a             	movzbl (%edx),%ecx
  800aa1:	84 c9                	test   %cl,%cl
  800aa3:	75 ec                	jne    800a91 <strlcpy+0x1a>
		*dst = '\0';
  800aa5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa8:	29 f0                	sub    %esi,%eax
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab7:	eb 06                	jmp    800abf <strcmp+0x11>
		p++, q++;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800abf:	0f b6 01             	movzbl (%ecx),%eax
  800ac2:	84 c0                	test   %al,%al
  800ac4:	74 04                	je     800aca <strcmp+0x1c>
  800ac6:	3a 02                	cmp    (%edx),%al
  800ac8:	74 ef                	je     800ab9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aca:	0f b6 c0             	movzbl %al,%eax
  800acd:	0f b6 12             	movzbl (%edx),%edx
  800ad0:	29 d0                	sub    %edx,%eax
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ade:	89 c3                	mov    %eax,%ebx
  800ae0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae3:	eb 06                	jmp    800aeb <strncmp+0x17>
		n--, p++, q++;
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aeb:	39 d8                	cmp    %ebx,%eax
  800aed:	74 16                	je     800b05 <strncmp+0x31>
  800aef:	0f b6 08             	movzbl (%eax),%ecx
  800af2:	84 c9                	test   %cl,%cl
  800af4:	74 04                	je     800afa <strncmp+0x26>
  800af6:	3a 0a                	cmp    (%edx),%cl
  800af8:	74 eb                	je     800ae5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afa:	0f b6 00             	movzbl (%eax),%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    
		return 0;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	eb f6                	jmp    800b02 <strncmp+0x2e>

00800b0c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b16:	0f b6 10             	movzbl (%eax),%edx
  800b19:	84 d2                	test   %dl,%dl
  800b1b:	74 09                	je     800b26 <strchr+0x1a>
		if (*s == c)
  800b1d:	38 ca                	cmp    %cl,%dl
  800b1f:	74 0a                	je     800b2b <strchr+0x1f>
	for (; *s; s++)
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	eb f0                	jmp    800b16 <strchr+0xa>
			return (char *) s;
	return 0;
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b37:	eb 03                	jmp    800b3c <strfind+0xf>
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b3f:	38 ca                	cmp    %cl,%dl
  800b41:	74 04                	je     800b47 <strfind+0x1a>
  800b43:	84 d2                	test   %dl,%dl
  800b45:	75 f2                	jne    800b39 <strfind+0xc>
			break;
	return (char *) s;
}
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b55:	85 c9                	test   %ecx,%ecx
  800b57:	74 13                	je     800b6c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5f:	75 05                	jne    800b66 <memset+0x1d>
  800b61:	f6 c1 03             	test   $0x3,%cl
  800b64:	74 0d                	je     800b73 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	fc                   	cld    
  800b6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6c:	89 f8                	mov    %edi,%eax
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    
		c &= 0xFF;
  800b73:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	c1 e3 08             	shl    $0x8,%ebx
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	c1 e0 18             	shl    $0x18,%eax
  800b81:	89 d6                	mov    %edx,%esi
  800b83:	c1 e6 10             	shl    $0x10,%esi
  800b86:	09 f0                	or     %esi,%eax
  800b88:	09 c2                	or     %eax,%edx
  800b8a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b8c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	fc                   	cld    
  800b92:	f3 ab                	rep stos %eax,%es:(%edi)
  800b94:	eb d6                	jmp    800b6c <memset+0x23>

00800b96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba4:	39 c6                	cmp    %eax,%esi
  800ba6:	73 35                	jae    800bdd <memmove+0x47>
  800ba8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bab:	39 c2                	cmp    %eax,%edx
  800bad:	76 2e                	jbe    800bdd <memmove+0x47>
		s += n;
		d += n;
  800baf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	09 fe                	or     %edi,%esi
  800bb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbc:	74 0c                	je     800bca <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bbe:	83 ef 01             	sub    $0x1,%edi
  800bc1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc4:	fd                   	std    
  800bc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc7:	fc                   	cld    
  800bc8:	eb 21                	jmp    800beb <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bca:	f6 c1 03             	test   $0x3,%cl
  800bcd:	75 ef                	jne    800bbe <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bcf:	83 ef 04             	sub    $0x4,%edi
  800bd2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bd8:	fd                   	std    
  800bd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdb:	eb ea                	jmp    800bc7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdd:	89 f2                	mov    %esi,%edx
  800bdf:	09 c2                	or     %eax,%edx
  800be1:	f6 c2 03             	test   $0x3,%dl
  800be4:	74 09                	je     800bef <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	fc                   	cld    
  800be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	f6 c1 03             	test   $0x3,%cl
  800bf2:	75 f2                	jne    800be6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	fc                   	cld    
  800bfa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfc:	eb ed                	jmp    800beb <memmove+0x55>

00800bfe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c01:	ff 75 10             	pushl  0x10(%ebp)
  800c04:	ff 75 0c             	pushl  0xc(%ebp)
  800c07:	ff 75 08             	pushl  0x8(%ebp)
  800c0a:	e8 87 ff ff ff       	call   800b96 <memmove>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c21:	39 f0                	cmp    %esi,%eax
  800c23:	74 1c                	je     800c41 <memcmp+0x30>
		if (*s1 != *s2)
  800c25:	0f b6 08             	movzbl (%eax),%ecx
  800c28:	0f b6 1a             	movzbl (%edx),%ebx
  800c2b:	38 d9                	cmp    %bl,%cl
  800c2d:	75 08                	jne    800c37 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c2f:	83 c0 01             	add    $0x1,%eax
  800c32:	83 c2 01             	add    $0x1,%edx
  800c35:	eb ea                	jmp    800c21 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c37:	0f b6 c1             	movzbl %cl,%eax
  800c3a:	0f b6 db             	movzbl %bl,%ebx
  800c3d:	29 d8                	sub    %ebx,%eax
  800c3f:	eb 05                	jmp    800c46 <memcmp+0x35>
	}

	return 0;
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c53:	89 c2                	mov    %eax,%edx
  800c55:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c58:	39 d0                	cmp    %edx,%eax
  800c5a:	73 09                	jae    800c65 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5c:	38 08                	cmp    %cl,(%eax)
  800c5e:	74 05                	je     800c65 <memfind+0x1b>
	for (; s < ends; s++)
  800c60:	83 c0 01             	add    $0x1,%eax
  800c63:	eb f3                	jmp    800c58 <memfind+0xe>
			break;
	return (void *) s;
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c73:	eb 03                	jmp    800c78 <strtol+0x11>
		s++;
  800c75:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c78:	0f b6 01             	movzbl (%ecx),%eax
  800c7b:	3c 20                	cmp    $0x20,%al
  800c7d:	74 f6                	je     800c75 <strtol+0xe>
  800c7f:	3c 09                	cmp    $0x9,%al
  800c81:	74 f2                	je     800c75 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c83:	3c 2b                	cmp    $0x2b,%al
  800c85:	74 2e                	je     800cb5 <strtol+0x4e>
	int neg = 0;
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c8c:	3c 2d                	cmp    $0x2d,%al
  800c8e:	74 2f                	je     800cbf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c90:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c96:	75 05                	jne    800c9d <strtol+0x36>
  800c98:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9b:	74 2c                	je     800cc9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9d:	85 db                	test   %ebx,%ebx
  800c9f:	75 0a                	jne    800cab <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ca6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca9:	74 28                	je     800cd3 <strtol+0x6c>
		base = 10;
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cb3:	eb 50                	jmp    800d05 <strtol+0x9e>
		s++;
  800cb5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cb8:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbd:	eb d1                	jmp    800c90 <strtol+0x29>
		s++, neg = 1;
  800cbf:	83 c1 01             	add    $0x1,%ecx
  800cc2:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc7:	eb c7                	jmp    800c90 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ccd:	74 0e                	je     800cdd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ccf:	85 db                	test   %ebx,%ebx
  800cd1:	75 d8                	jne    800cab <strtol+0x44>
		s++, base = 8;
  800cd3:	83 c1 01             	add    $0x1,%ecx
  800cd6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cdb:	eb ce                	jmp    800cab <strtol+0x44>
		s += 2, base = 16;
  800cdd:	83 c1 02             	add    $0x2,%ecx
  800ce0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce5:	eb c4                	jmp    800cab <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ce7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cea:	89 f3                	mov    %esi,%ebx
  800cec:	80 fb 19             	cmp    $0x19,%bl
  800cef:	77 29                	ja     800d1a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cf1:	0f be d2             	movsbl %dl,%edx
  800cf4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cfa:	7d 30                	jge    800d2c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cfc:	83 c1 01             	add    $0x1,%ecx
  800cff:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d03:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d05:	0f b6 11             	movzbl (%ecx),%edx
  800d08:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0b:	89 f3                	mov    %esi,%ebx
  800d0d:	80 fb 09             	cmp    $0x9,%bl
  800d10:	77 d5                	ja     800ce7 <strtol+0x80>
			dig = *s - '0';
  800d12:	0f be d2             	movsbl %dl,%edx
  800d15:	83 ea 30             	sub    $0x30,%edx
  800d18:	eb dd                	jmp    800cf7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d1d:	89 f3                	mov    %esi,%ebx
  800d1f:	80 fb 19             	cmp    $0x19,%bl
  800d22:	77 08                	ja     800d2c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d24:	0f be d2             	movsbl %dl,%edx
  800d27:	83 ea 37             	sub    $0x37,%edx
  800d2a:	eb cb                	jmp    800cf7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d30:	74 05                	je     800d37 <strtol+0xd0>
		*endptr = (char *) s;
  800d32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d35:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d37:	89 c2                	mov    %eax,%edx
  800d39:	f7 da                	neg    %edx
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	0f 45 c2             	cmovne %edx,%eax
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
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
