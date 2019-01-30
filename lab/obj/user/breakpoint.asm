
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800044:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004b:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80004e:	e8 c6 00 00 00       	call   800119 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x37>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 0a 00 00 00       	call   800089 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800085:	5b                   	pop    %ebx
  800086:	5e                   	pop    %esi
  800087:	5d                   	pop    %ebp
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008f:	6a 00                	push   $0x0
  800091:	e8 42 00 00 00       	call   8000d8 <sys_env_destroy>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	c9                   	leave  
  80009a:	c3                   	ret    

0080009b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	89 c7                	mov    %eax,%edi
  8000b0:	89 c6                	mov    %eax,%esi
  8000b2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c9:	89 d1                	mov    %edx,%ecx
  8000cb:	89 d3                	mov    %edx,%ebx
  8000cd:	89 d7                	mov    %edx,%edi
  8000cf:	89 d6                	mov    %edx,%esi
  8000d1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	89 cb                	mov    %ecx,%ebx
  8000f0:	89 cf                	mov    %ecx,%edi
  8000f2:	89 ce                	mov    %ecx,%esi
  8000f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	7f 08                	jg     800102 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	50                   	push   %eax
  800106:	6a 03                	push   $0x3
  800108:	68 8a 0f 80 00       	push   $0x800f8a
  80010d:	6a 23                	push   $0x23
  80010f:	68 a7 0f 80 00       	push   $0x800fa7
  800114:	e8 ed 01 00 00       	call   800306 <_panic>

00800119 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011f:	ba 00 00 00 00       	mov    $0x0,%edx
  800124:	b8 02 00 00 00       	mov    $0x2,%eax
  800129:	89 d1                	mov    %edx,%ecx
  80012b:	89 d3                	mov    %edx,%ebx
  80012d:	89 d7                	mov    %edx,%edi
  80012f:	89 d6                	mov    %edx,%esi
  800131:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5f                   	pop    %edi
  800136:	5d                   	pop    %ebp
  800137:	c3                   	ret    

00800138 <sys_yield>:

void
sys_yield(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 0a 00 00 00       	mov    $0xa,%eax
  800148:	89 d1                	mov    %edx,%ecx
  80014a:	89 d3                	mov    %edx,%ebx
  80014c:	89 d7                	mov    %edx,%edi
  80014e:	89 d6                	mov    %edx,%esi
  800150:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800160:	be 00 00 00 00       	mov    $0x0,%esi
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	b8 04 00 00 00       	mov    $0x4,%eax
  800170:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800173:	89 f7                	mov    %esi,%edi
  800175:	cd 30                	int    $0x30
	if(check && ret > 0)
  800177:	85 c0                	test   %eax,%eax
  800179:	7f 08                	jg     800183 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	50                   	push   %eax
  800187:	6a 04                	push   $0x4
  800189:	68 8a 0f 80 00       	push   $0x800f8a
  80018e:	6a 23                	push   $0x23
  800190:	68 a7 0f 80 00       	push   $0x800fa7
  800195:	e8 6c 01 00 00       	call   800306 <_panic>

0080019a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	57                   	push   %edi
  80019e:	56                   	push   %esi
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b4:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	7f 08                	jg     8001c5 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c5:	83 ec 0c             	sub    $0xc,%esp
  8001c8:	50                   	push   %eax
  8001c9:	6a 05                	push   $0x5
  8001cb:	68 8a 0f 80 00       	push   $0x800f8a
  8001d0:	6a 23                	push   $0x23
  8001d2:	68 a7 0f 80 00       	push   $0x800fa7
  8001d7:	e8 2a 01 00 00       	call   800306 <_panic>

008001dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f5:	89 df                	mov    %ebx,%edi
  8001f7:	89 de                	mov    %ebx,%esi
  8001f9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	7f 08                	jg     800207 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5f                   	pop    %edi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	50                   	push   %eax
  80020b:	6a 06                	push   $0x6
  80020d:	68 8a 0f 80 00       	push   $0x800f8a
  800212:	6a 23                	push   $0x23
  800214:	68 a7 0f 80 00       	push   $0x800fa7
  800219:	e8 e8 00 00 00       	call   800306 <_panic>

0080021e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	b8 08 00 00 00       	mov    $0x8,%eax
  800237:	89 df                	mov    %ebx,%edi
  800239:	89 de                	mov    %ebx,%esi
  80023b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023d:	85 c0                	test   %eax,%eax
  80023f:	7f 08                	jg     800249 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	50                   	push   %eax
  80024d:	6a 08                	push   $0x8
  80024f:	68 8a 0f 80 00       	push   $0x800f8a
  800254:	6a 23                	push   $0x23
  800256:	68 a7 0f 80 00       	push   $0x800fa7
  80025b:	e8 a6 00 00 00       	call   800306 <_panic>

00800260 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	8b 55 08             	mov    0x8(%ebp),%edx
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	b8 09 00 00 00       	mov    $0x9,%eax
  800279:	89 df                	mov    %ebx,%edi
  80027b:	89 de                	mov    %ebx,%esi
  80027d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027f:	85 c0                	test   %eax,%eax
  800281:	7f 08                	jg     80028b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	50                   	push   %eax
  80028f:	6a 09                	push   $0x9
  800291:	68 8a 0f 80 00       	push   $0x800f8a
  800296:	6a 23                	push   $0x23
  800298:	68 a7 0f 80 00       	push   $0x800fa7
  80029d:	e8 64 00 00 00       	call   800306 <_panic>

008002a2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002be:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002db:	89 cb                	mov    %ecx,%ebx
  8002dd:	89 cf                	mov    %ecx,%edi
  8002df:	89 ce                	mov    %ecx,%esi
  8002e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	7f 08                	jg     8002ef <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0c                	push   $0xc
  8002f5:	68 8a 0f 80 00       	push   $0x800f8a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 a7 0f 80 00       	push   $0x800fa7
  800301:	e8 00 00 00 00       	call   800306 <_panic>

00800306 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800314:	e8 00 fe ff ff       	call   800119 <sys_getenvid>
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	ff 75 0c             	pushl  0xc(%ebp)
  80031f:	ff 75 08             	pushl  0x8(%ebp)
  800322:	56                   	push   %esi
  800323:	50                   	push   %eax
  800324:	68 b8 0f 80 00       	push   $0x800fb8
  800329:	e8 b3 00 00 00       	call   8003e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032e:	83 c4 18             	add    $0x18,%esp
  800331:	53                   	push   %ebx
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	e8 56 00 00 00       	call   800390 <vcprintf>
	cprintf("\n");
  80033a:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800341:	e8 9b 00 00 00       	call   8003e1 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800349:	cc                   	int3   
  80034a:	eb fd                	jmp    800349 <_panic+0x43>

0080034c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	53                   	push   %ebx
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800356:	8b 13                	mov    (%ebx),%edx
  800358:	8d 42 01             	lea    0x1(%edx),%eax
  80035b:	89 03                	mov    %eax,(%ebx)
  80035d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800360:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800364:	3d ff 00 00 00       	cmp    $0xff,%eax
  800369:	74 09                	je     800374 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80036b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800372:	c9                   	leave  
  800373:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	68 ff 00 00 00       	push   $0xff
  80037c:	8d 43 08             	lea    0x8(%ebx),%eax
  80037f:	50                   	push   %eax
  800380:	e8 16 fd ff ff       	call   80009b <sys_cputs>
		b->idx = 0;
  800385:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038b:	83 c4 10             	add    $0x10,%esp
  80038e:	eb db                	jmp    80036b <putch+0x1f>

00800390 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800399:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a0:	00 00 00 
	b.cnt = 0;
  8003a3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003aa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ad:	ff 75 0c             	pushl  0xc(%ebp)
  8003b0:	ff 75 08             	pushl  0x8(%ebp)
  8003b3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b9:	50                   	push   %eax
  8003ba:	68 4c 03 80 00       	push   $0x80034c
  8003bf:	e8 1a 01 00 00       	call   8004de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c4:	83 c4 08             	add    $0x8,%esp
  8003c7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d3:	50                   	push   %eax
  8003d4:	e8 c2 fc ff ff       	call   80009b <sys_cputs>

	return b.cnt;
}
  8003d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ea:	50                   	push   %eax
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	e8 9d ff ff ff       	call   800390 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 1c             	sub    $0x1c,%esp
  8003fe:	89 c7                	mov    %eax,%edi
  800400:	89 d6                	mov    %edx,%esi
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
  800405:	8b 55 0c             	mov    0xc(%ebp),%edx
  800408:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800411:	bb 00 00 00 00       	mov    $0x0,%ebx
  800416:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800419:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041c:	39 d3                	cmp    %edx,%ebx
  80041e:	72 05                	jb     800425 <printnum+0x30>
  800420:	39 45 10             	cmp    %eax,0x10(%ebp)
  800423:	77 7a                	ja     80049f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800425:	83 ec 0c             	sub    $0xc,%esp
  800428:	ff 75 18             	pushl  0x18(%ebp)
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800431:	53                   	push   %ebx
  800432:	ff 75 10             	pushl  0x10(%ebp)
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043b:	ff 75 e0             	pushl  -0x20(%ebp)
  80043e:	ff 75 dc             	pushl  -0x24(%ebp)
  800441:	ff 75 d8             	pushl  -0x28(%ebp)
  800444:	e8 f7 08 00 00       	call   800d40 <__udivdi3>
  800449:	83 c4 18             	add    $0x18,%esp
  80044c:	52                   	push   %edx
  80044d:	50                   	push   %eax
  80044e:	89 f2                	mov    %esi,%edx
  800450:	89 f8                	mov    %edi,%eax
  800452:	e8 9e ff ff ff       	call   8003f5 <printnum>
  800457:	83 c4 20             	add    $0x20,%esp
  80045a:	eb 13                	jmp    80046f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	56                   	push   %esi
  800460:	ff 75 18             	pushl  0x18(%ebp)
  800463:	ff d7                	call   *%edi
  800465:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800468:	83 eb 01             	sub    $0x1,%ebx
  80046b:	85 db                	test   %ebx,%ebx
  80046d:	7f ed                	jg     80045c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	56                   	push   %esi
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	ff 75 e4             	pushl  -0x1c(%ebp)
  800479:	ff 75 e0             	pushl  -0x20(%ebp)
  80047c:	ff 75 dc             	pushl  -0x24(%ebp)
  80047f:	ff 75 d8             	pushl  -0x28(%ebp)
  800482:	e8 d9 09 00 00       	call   800e60 <__umoddi3>
  800487:	83 c4 14             	add    $0x14,%esp
  80048a:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800491:	50                   	push   %eax
  800492:	ff d7                	call   *%edi
}
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049a:	5b                   	pop    %ebx
  80049b:	5e                   	pop    %esi
  80049c:	5f                   	pop    %edi
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    
  80049f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a2:	eb c4                	jmp    800468 <printnum+0x73>

008004a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b3:	73 0a                	jae    8004bf <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b8:	89 08                	mov    %ecx,(%eax)
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	88 02                	mov    %al,(%edx)
}
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <printfmt>:
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ca:	50                   	push   %eax
  8004cb:	ff 75 10             	pushl  0x10(%ebp)
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	ff 75 08             	pushl  0x8(%ebp)
  8004d4:	e8 05 00 00 00       	call   8004de <vprintfmt>
}
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <vprintfmt>:
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 2c             	sub    $0x2c,%esp
  8004e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f0:	e9 63 03 00 00       	jmp    800858 <vprintfmt+0x37a>
		padc = ' ';
  8004f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800507:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8d 47 01             	lea    0x1(%edi),%eax
  800516:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800519:	0f b6 17             	movzbl (%edi),%edx
  80051c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80051f:	3c 55                	cmp    $0x55,%al
  800521:	0f 87 11 04 00 00    	ja     800938 <vprintfmt+0x45a>
  800527:	0f b6 c0             	movzbl %al,%eax
  80052a:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800534:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800538:	eb d9                	jmp    800513 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80053d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800541:	eb d0                	jmp    800513 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800543:	0f b6 d2             	movzbl %dl,%edx
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800551:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800554:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800558:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80055e:	83 f9 09             	cmp    $0x9,%ecx
  800561:	77 55                	ja     8005b8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800563:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800566:	eb e9                	jmp    800551 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	79 91                	jns    800513 <vprintfmt+0x35>
				width = precision, precision = -1;
  800582:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800585:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800588:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058f:	eb 82                	jmp    800513 <vprintfmt+0x35>
  800591:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800594:	85 c0                	test   %eax,%eax
  800596:	ba 00 00 00 00       	mov    $0x0,%edx
  80059b:	0f 49 d0             	cmovns %eax,%edx
  80059e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 6a ff ff ff       	jmp    800513 <vprintfmt+0x35>
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	e9 5b ff ff ff       	jmp    800513 <vprintfmt+0x35>
  8005b8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005be:	eb bc                	jmp    80057c <vprintfmt+0x9e>
			lflag++;
  8005c0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c6:	e9 48 ff ff ff       	jmp    800513 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 78 04             	lea    0x4(%eax),%edi
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	ff 30                	pushl  (%eax)
  8005d7:	ff d6                	call   *%esi
			break;
  8005d9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005dc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005df:	e9 71 02 00 00       	jmp    800855 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 78 04             	lea    0x4(%eax),%edi
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	99                   	cltd   
  8005ed:	31 d0                	xor    %edx,%eax
  8005ef:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f1:	83 f8 08             	cmp    $0x8,%eax
  8005f4:	7f 23                	jg     800619 <vprintfmt+0x13b>
  8005f6:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	74 18                	je     800619 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800601:	52                   	push   %edx
  800602:	68 ff 0f 80 00       	push   $0x800fff
  800607:	53                   	push   %ebx
  800608:	56                   	push   %esi
  800609:	e8 b3 fe ff ff       	call   8004c1 <printfmt>
  80060e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800611:	89 7d 14             	mov    %edi,0x14(%ebp)
  800614:	e9 3c 02 00 00       	jmp    800855 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800619:	50                   	push   %eax
  80061a:	68 f6 0f 80 00       	push   $0x800ff6
  80061f:	53                   	push   %ebx
  800620:	56                   	push   %esi
  800621:	e8 9b fe ff ff       	call   8004c1 <printfmt>
  800626:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800629:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80062c:	e9 24 02 00 00       	jmp    800855 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	83 c0 04             	add    $0x4,%eax
  800637:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80063f:	85 ff                	test   %edi,%edi
  800641:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  800646:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800649:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064d:	0f 8e bd 00 00 00    	jle    800710 <vprintfmt+0x232>
  800653:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800657:	75 0e                	jne    800667 <vprintfmt+0x189>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	eb 6d                	jmp    8006d4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 d0             	pushl  -0x30(%ebp)
  80066d:	57                   	push   %edi
  80066e:	e8 6d 03 00 00       	call   8009e0 <strnlen>
  800673:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800676:	29 c1                	sub    %eax,%ecx
  800678:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800685:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800688:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	eb 0f                	jmp    80069b <vprintfmt+0x1bd>
					putch(padc, putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	83 ef 01             	sub    $0x1,%edi
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 ff                	test   %edi,%edi
  80069d:	7f ed                	jg     80068c <vprintfmt+0x1ae>
  80069f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a5:	85 c9                	test   %ecx,%ecx
  8006a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ac:	0f 49 c1             	cmovns %ecx,%eax
  8006af:	29 c1                	sub    %eax,%ecx
  8006b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ba:	89 cb                	mov    %ecx,%ebx
  8006bc:	eb 16                	jmp    8006d4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c2:	75 31                	jne    8006f5 <vprintfmt+0x217>
					putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ca:	50                   	push   %eax
  8006cb:	ff 55 08             	call   *0x8(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	83 eb 01             	sub    $0x1,%ebx
  8006d4:	83 c7 01             	add    $0x1,%edi
  8006d7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006db:	0f be c2             	movsbl %dl,%eax
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	74 59                	je     80073b <vprintfmt+0x25d>
  8006e2:	85 f6                	test   %esi,%esi
  8006e4:	78 d8                	js     8006be <vprintfmt+0x1e0>
  8006e6:	83 ee 01             	sub    $0x1,%esi
  8006e9:	79 d3                	jns    8006be <vprintfmt+0x1e0>
  8006eb:	89 df                	mov    %ebx,%edi
  8006ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f3:	eb 37                	jmp    80072c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f5:	0f be d2             	movsbl %dl,%edx
  8006f8:	83 ea 20             	sub    $0x20,%edx
  8006fb:	83 fa 5e             	cmp    $0x5e,%edx
  8006fe:	76 c4                	jbe    8006c4 <vprintfmt+0x1e6>
					putch('?', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	ff 75 0c             	pushl  0xc(%ebp)
  800706:	6a 3f                	push   $0x3f
  800708:	ff 55 08             	call   *0x8(%ebp)
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb c1                	jmp    8006d1 <vprintfmt+0x1f3>
  800710:	89 75 08             	mov    %esi,0x8(%ebp)
  800713:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800716:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800719:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071c:	eb b6                	jmp    8006d4 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 20                	push   $0x20
  800724:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800726:	83 ef 01             	sub    $0x1,%edi
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	85 ff                	test   %edi,%edi
  80072e:	7f ee                	jg     80071e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800730:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
  800736:	e9 1a 01 00 00       	jmp    800855 <vprintfmt+0x377>
  80073b:	89 df                	mov    %ebx,%edi
  80073d:	8b 75 08             	mov    0x8(%ebp),%esi
  800740:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800743:	eb e7                	jmp    80072c <vprintfmt+0x24e>
	if (lflag >= 2)
  800745:	83 f9 01             	cmp    $0x1,%ecx
  800748:	7e 3f                	jle    800789 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 50 04             	mov    0x4(%eax),%edx
  800750:	8b 00                	mov    (%eax),%eax
  800752:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800755:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800761:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800765:	79 5c                	jns    8007c3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 2d                	push   $0x2d
  80076d:	ff d6                	call   *%esi
				num = -(long long) num;
  80076f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800772:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800775:	f7 da                	neg    %edx
  800777:	83 d1 00             	adc    $0x0,%ecx
  80077a:	f7 d9                	neg    %ecx
  80077c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	e9 b2 00 00 00       	jmp    80083b <vprintfmt+0x35d>
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 1b                	jne    8007a8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 00                	mov    (%eax),%eax
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 c1                	mov    %eax,%ecx
  800797:	c1 f9 1f             	sar    $0x1f,%ecx
  80079a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 40 04             	lea    0x4(%eax),%eax
  8007a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a6:	eb b9                	jmp    800761 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 00                	mov    (%eax),%eax
  8007ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b0:	89 c1                	mov    %eax,%ecx
  8007b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 40 04             	lea    0x4(%eax),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c1:	eb 9e                	jmp    800761 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ce:	eb 6b                	jmp    80083b <vprintfmt+0x35d>
	if (lflag >= 2)
  8007d0:	83 f9 01             	cmp    $0x1,%ecx
  8007d3:	7e 15                	jle    8007ea <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8b 10                	mov    (%eax),%edx
  8007da:	8b 48 04             	mov    0x4(%eax),%ecx
  8007dd:	8d 40 08             	lea    0x8(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e8:	eb 51                	jmp    80083b <vprintfmt+0x35d>
	else if (lflag)
  8007ea:	85 c9                	test   %ecx,%ecx
  8007ec:	75 17                	jne    800805 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8b 10                	mov    (%eax),%edx
  8007f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f8:	8d 40 04             	lea    0x4(%eax),%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800803:	eb 36                	jmp    80083b <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081a:	eb 1f                	jmp    80083b <vprintfmt+0x35d>
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7e 5b                	jle    80087c <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 50 04             	mov    0x4(%eax),%edx
  800827:	8b 00                	mov    (%eax),%eax
  800829:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80082c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80082f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800832:	89 d1                	mov    %edx,%ecx
  800834:	89 c2                	mov    %eax,%edx
			base = 8;
  800836:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80083b:	83 ec 0c             	sub    $0xc,%esp
  80083e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800842:	57                   	push   %edi
  800843:	ff 75 e0             	pushl  -0x20(%ebp)
  800846:	50                   	push   %eax
  800847:	51                   	push   %ecx
  800848:	52                   	push   %edx
  800849:	89 da                	mov    %ebx,%edx
  80084b:	89 f0                	mov    %esi,%eax
  80084d:	e8 a3 fb ff ff       	call   8003f5 <printnum>
			break;
  800852:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800858:	83 c7 01             	add    $0x1,%edi
  80085b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80085f:	83 f8 25             	cmp    $0x25,%eax
  800862:	0f 84 8d fc ff ff    	je     8004f5 <vprintfmt+0x17>
			if (ch == '\0')
  800868:	85 c0                	test   %eax,%eax
  80086a:	0f 84 e8 00 00 00    	je     800958 <vprintfmt+0x47a>
			putch(ch, putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	50                   	push   %eax
  800875:	ff d6                	call   *%esi
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	eb dc                	jmp    800858 <vprintfmt+0x37a>
	else if (lflag)
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	75 13                	jne    800893 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8b 10                	mov    (%eax),%edx
  800885:	89 d0                	mov    %edx,%eax
  800887:	99                   	cltd   
  800888:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80088b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800891:	eb 9f                	jmp    800832 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8b 10                	mov    (%eax),%edx
  800898:	89 d0                	mov    %edx,%eax
  80089a:	99                   	cltd   
  80089b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089e:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a4:	eb 8c                	jmp    800832 <vprintfmt+0x354>
			putch('0', putdat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	53                   	push   %ebx
  8008aa:	6a 30                	push   $0x30
  8008ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8008ae:	83 c4 08             	add    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	6a 78                	push   $0x78
  8008b4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008c3:	8d 40 04             	lea    0x4(%eax),%eax
  8008c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ce:	e9 68 ff ff ff       	jmp    80083b <vprintfmt+0x35d>
	if (lflag >= 2)
  8008d3:	83 f9 01             	cmp    $0x1,%ecx
  8008d6:	7e 18                	jle    8008f0 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8b 10                	mov    (%eax),%edx
  8008dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e0:	8d 40 08             	lea    0x8(%eax),%eax
  8008e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008eb:	e9 4b ff ff ff       	jmp    80083b <vprintfmt+0x35d>
	else if (lflag)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	75 1a                	jne    80090e <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8b 10                	mov    (%eax),%edx
  8008f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fe:	8d 40 04             	lea    0x4(%eax),%eax
  800901:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800904:	b8 10 00 00 00       	mov    $0x10,%eax
  800909:	e9 2d ff ff ff       	jmp    80083b <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 10                	mov    (%eax),%edx
  800913:	b9 00 00 00 00       	mov    $0x0,%ecx
  800918:	8d 40 04             	lea    0x4(%eax),%eax
  80091b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091e:	b8 10 00 00 00       	mov    $0x10,%eax
  800923:	e9 13 ff ff ff       	jmp    80083b <vprintfmt+0x35d>
			putch(ch, putdat);
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	53                   	push   %ebx
  80092c:	6a 25                	push   $0x25
  80092e:	ff d6                	call   *%esi
			break;
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	e9 1d ff ff ff       	jmp    800855 <vprintfmt+0x377>
			putch('%', putdat);
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	53                   	push   %ebx
  80093c:	6a 25                	push   $0x25
  80093e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	89 f8                	mov    %edi,%eax
  800945:	eb 03                	jmp    80094a <vprintfmt+0x46c>
  800947:	83 e8 01             	sub    $0x1,%eax
  80094a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80094e:	75 f7                	jne    800947 <vprintfmt+0x469>
  800950:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800953:	e9 fd fe ff ff       	jmp    800855 <vprintfmt+0x377>
}
  800958:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 18             	sub    $0x18,%esp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800973:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800976:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097d:	85 c0                	test   %eax,%eax
  80097f:	74 26                	je     8009a7 <vsnprintf+0x47>
  800981:	85 d2                	test   %edx,%edx
  800983:	7e 22                	jle    8009a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800985:	ff 75 14             	pushl  0x14(%ebp)
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098e:	50                   	push   %eax
  80098f:	68 a4 04 80 00       	push   $0x8004a4
  800994:	e8 45 fb ff ff       	call   8004de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800999:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80099c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a2:	83 c4 10             	add    $0x10,%esp
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    
		return -E_INVAL;
  8009a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ac:	eb f7                	jmp    8009a5 <vsnprintf+0x45>

008009ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b7:	50                   	push   %eax
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	ff 75 08             	pushl  0x8(%ebp)
  8009c1:	e8 9a ff ff ff       	call   800960 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb 03                	jmp    8009d8 <strlen+0x10>
		n++;
  8009d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009dc:	75 f7                	jne    8009d5 <strlen+0xd>
	return n;
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	eb 03                	jmp    8009f3 <strnlen+0x13>
		n++;
  8009f0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f3:	39 d0                	cmp    %edx,%eax
  8009f5:	74 06                	je     8009fd <strnlen+0x1d>
  8009f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009fb:	75 f3                	jne    8009f0 <strnlen+0x10>
	return n;
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a15:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a18:	84 db                	test   %bl,%bl
  800a1a:	75 ef                	jne    800a0b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a26:	53                   	push   %ebx
  800a27:	e8 9c ff ff ff       	call   8009c8 <strlen>
  800a2c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	01 d8                	add    %ebx,%eax
  800a34:	50                   	push   %eax
  800a35:	e8 c5 ff ff ff       	call   8009ff <strcpy>
	return dst;
}
  800a3a:	89 d8                	mov    %ebx,%eax
  800a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	eb 0f                	jmp    800a64 <strncpy+0x23>
		*dst++ = *src;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	0f b6 01             	movzbl (%ecx),%eax
  800a5b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a61:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a64:	39 da                	cmp    %ebx,%edx
  800a66:	75 ed                	jne    800a55 <strncpy+0x14>
	}
	return ret;
}
  800a68:	89 f0                	mov    %esi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 75 08             	mov    0x8(%ebp),%esi
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a7c:	89 f0                	mov    %esi,%eax
  800a7e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a82:	85 c9                	test   %ecx,%ecx
  800a84:	75 0b                	jne    800a91 <strlcpy+0x23>
  800a86:	eb 17                	jmp    800a9f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a88:	83 c2 01             	add    $0x1,%edx
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a91:	39 d8                	cmp    %ebx,%eax
  800a93:	74 07                	je     800a9c <strlcpy+0x2e>
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	84 c9                	test   %cl,%cl
  800a9a:	75 ec                	jne    800a88 <strlcpy+0x1a>
		*dst = '\0';
  800a9c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9f:	29 f0                	sub    %esi,%eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aae:	eb 06                	jmp    800ab6 <strcmp+0x11>
		p++, q++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	84 c0                	test   %al,%al
  800abb:	74 04                	je     800ac1 <strcmp+0x1c>
  800abd:	3a 02                	cmp    (%edx),%al
  800abf:	74 ef                	je     800ab0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 12             	movzbl (%edx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ada:	eb 06                	jmp    800ae2 <strncmp+0x17>
		n--, p++, q++;
  800adc:	83 c0 01             	add    $0x1,%eax
  800adf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 16                	je     800afc <strncmp+0x31>
  800ae6:	0f b6 08             	movzbl (%eax),%ecx
  800ae9:	84 c9                	test   %cl,%cl
  800aeb:	74 04                	je     800af1 <strncmp+0x26>
  800aed:	3a 0a                	cmp    (%edx),%cl
  800aef:	74 eb                	je     800adc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 00             	movzbl (%eax),%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    
		return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb f6                	jmp    800af9 <strncmp+0x2e>

00800b03 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	84 d2                	test   %dl,%dl
  800b12:	74 09                	je     800b1d <strchr+0x1a>
		if (*s == c)
  800b14:	38 ca                	cmp    %cl,%dl
  800b16:	74 0a                	je     800b22 <strchr+0x1f>
	for (; *s; s++)
  800b18:	83 c0 01             	add    $0x1,%eax
  800b1b:	eb f0                	jmp    800b0d <strchr+0xa>
			return (char *) s;
	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2e:	eb 03                	jmp    800b33 <strfind+0xf>
  800b30:	83 c0 01             	add    $0x1,%eax
  800b33:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b36:	38 ca                	cmp    %cl,%dl
  800b38:	74 04                	je     800b3e <strfind+0x1a>
  800b3a:	84 d2                	test   %dl,%dl
  800b3c:	75 f2                	jne    800b30 <strfind+0xc>
			break;
	return (char *) s;
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4c:	85 c9                	test   %ecx,%ecx
  800b4e:	74 13                	je     800b63 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b50:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b56:	75 05                	jne    800b5d <memset+0x1d>
  800b58:	f6 c1 03             	test   $0x3,%cl
  800b5b:	74 0d                	je     800b6a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b60:	fc                   	cld    
  800b61:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b63:	89 f8                	mov    %edi,%eax
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    
		c &= 0xFF;
  800b6a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	c1 e3 08             	shl    $0x8,%ebx
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	c1 e0 18             	shl    $0x18,%eax
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	c1 e6 10             	shl    $0x10,%esi
  800b7d:	09 f0                	or     %esi,%eax
  800b7f:	09 c2                	or     %eax,%edx
  800b81:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b83:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b86:	89 d0                	mov    %edx,%eax
  800b88:	fc                   	cld    
  800b89:	f3 ab                	rep stos %eax,%es:(%edi)
  800b8b:	eb d6                	jmp    800b63 <memset+0x23>

00800b8d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9b:	39 c6                	cmp    %eax,%esi
  800b9d:	73 35                	jae    800bd4 <memmove+0x47>
  800b9f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba2:	39 c2                	cmp    %eax,%edx
  800ba4:	76 2e                	jbe    800bd4 <memmove+0x47>
		s += n;
		d += n;
  800ba6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	09 fe                	or     %edi,%esi
  800bad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb3:	74 0c                	je     800bc1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb5:	83 ef 01             	sub    $0x1,%edi
  800bb8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bbb:	fd                   	std    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbe:	fc                   	cld    
  800bbf:	eb 21                	jmp    800be2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	f6 c1 03             	test   $0x3,%cl
  800bc4:	75 ef                	jne    800bb5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc6:	83 ef 04             	sub    $0x4,%edi
  800bc9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bcc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bcf:	fd                   	std    
  800bd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd2:	eb ea                	jmp    800bbe <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	09 c2                	or     %eax,%edx
  800bd8:	f6 c2 03             	test   $0x3,%dl
  800bdb:	74 09                	je     800be6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bdd:	89 c7                	mov    %eax,%edi
  800bdf:	fc                   	cld    
  800be0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be6:	f6 c1 03             	test   $0x3,%cl
  800be9:	75 f2                	jne    800bdd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800beb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	fc                   	cld    
  800bf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf3:	eb ed                	jmp    800be2 <memmove+0x55>

00800bf5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	ff 75 08             	pushl  0x8(%ebp)
  800c01:	e8 87 ff ff ff       	call   800b8d <memmove>
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	74 1c                	je     800c38 <memcmp+0x30>
		if (*s1 != *s2)
  800c1c:	0f b6 08             	movzbl (%eax),%ecx
  800c1f:	0f b6 1a             	movzbl (%edx),%ebx
  800c22:	38 d9                	cmp    %bl,%cl
  800c24:	75 08                	jne    800c2e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c26:	83 c0 01             	add    $0x1,%eax
  800c29:	83 c2 01             	add    $0x1,%edx
  800c2c:	eb ea                	jmp    800c18 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c2e:	0f b6 c1             	movzbl %cl,%eax
  800c31:	0f b6 db             	movzbl %bl,%ebx
  800c34:	29 d8                	sub    %ebx,%eax
  800c36:	eb 05                	jmp    800c3d <memcmp+0x35>
	}

	return 0;
  800c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c4a:	89 c2                	mov    %eax,%edx
  800c4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c4f:	39 d0                	cmp    %edx,%eax
  800c51:	73 09                	jae    800c5c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c53:	38 08                	cmp    %cl,(%eax)
  800c55:	74 05                	je     800c5c <memfind+0x1b>
	for (; s < ends; s++)
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	eb f3                	jmp    800c4f <memfind+0xe>
			break;
	return (void *) s;
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	eb 03                	jmp    800c6f <strtol+0x11>
		s++;
  800c6c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c6f:	0f b6 01             	movzbl (%ecx),%eax
  800c72:	3c 20                	cmp    $0x20,%al
  800c74:	74 f6                	je     800c6c <strtol+0xe>
  800c76:	3c 09                	cmp    $0x9,%al
  800c78:	74 f2                	je     800c6c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c7a:	3c 2b                	cmp    $0x2b,%al
  800c7c:	74 2e                	je     800cac <strtol+0x4e>
	int neg = 0;
  800c7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c83:	3c 2d                	cmp    $0x2d,%al
  800c85:	74 2f                	je     800cb6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c87:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c8d:	75 05                	jne    800c94 <strtol+0x36>
  800c8f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c92:	74 2c                	je     800cc0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c94:	85 db                	test   %ebx,%ebx
  800c96:	75 0a                	jne    800ca2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c98:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca0:	74 28                	je     800cca <strtol+0x6c>
		base = 10;
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800caa:	eb 50                	jmp    800cfc <strtol+0x9e>
		s++;
  800cac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb4:	eb d1                	jmp    800c87 <strtol+0x29>
		s++, neg = 1;
  800cb6:	83 c1 01             	add    $0x1,%ecx
  800cb9:	bf 01 00 00 00       	mov    $0x1,%edi
  800cbe:	eb c7                	jmp    800c87 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc4:	74 0e                	je     800cd4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cc6:	85 db                	test   %ebx,%ebx
  800cc8:	75 d8                	jne    800ca2 <strtol+0x44>
		s++, base = 8;
  800cca:	83 c1 01             	add    $0x1,%ecx
  800ccd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cd2:	eb ce                	jmp    800ca2 <strtol+0x44>
		s += 2, base = 16;
  800cd4:	83 c1 02             	add    $0x2,%ecx
  800cd7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdc:	eb c4                	jmp    800ca2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cde:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce1:	89 f3                	mov    %esi,%ebx
  800ce3:	80 fb 19             	cmp    $0x19,%bl
  800ce6:	77 29                	ja     800d11 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ce8:	0f be d2             	movsbl %dl,%edx
  800ceb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf1:	7d 30                	jge    800d23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cf3:	83 c1 01             	add    $0x1,%ecx
  800cf6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cfa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cfc:	0f b6 11             	movzbl (%ecx),%edx
  800cff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d02:	89 f3                	mov    %esi,%ebx
  800d04:	80 fb 09             	cmp    $0x9,%bl
  800d07:	77 d5                	ja     800cde <strtol+0x80>
			dig = *s - '0';
  800d09:	0f be d2             	movsbl %dl,%edx
  800d0c:	83 ea 30             	sub    $0x30,%edx
  800d0f:	eb dd                	jmp    800cee <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d11:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d14:	89 f3                	mov    %esi,%ebx
  800d16:	80 fb 19             	cmp    $0x19,%bl
  800d19:	77 08                	ja     800d23 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d1b:	0f be d2             	movsbl %dl,%edx
  800d1e:	83 ea 37             	sub    $0x37,%edx
  800d21:	eb cb                	jmp    800cee <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d27:	74 05                	je     800d2e <strtol+0xd0>
		*endptr = (char *) s;
  800d29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	f7 da                	neg    %edx
  800d32:	85 ff                	test   %edi,%edi
  800d34:	0f 45 c2             	cmovne %edx,%eax
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d57:	85 d2                	test   %edx,%edx
  800d59:	75 35                	jne    800d90 <__udivdi3+0x50>
  800d5b:	39 f3                	cmp    %esi,%ebx
  800d5d:	0f 87 bd 00 00 00    	ja     800e20 <__udivdi3+0xe0>
  800d63:	85 db                	test   %ebx,%ebx
  800d65:	89 d9                	mov    %ebx,%ecx
  800d67:	75 0b                	jne    800d74 <__udivdi3+0x34>
  800d69:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f3                	div    %ebx
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	31 d2                	xor    %edx,%edx
  800d76:	89 f0                	mov    %esi,%eax
  800d78:	f7 f1                	div    %ecx
  800d7a:	89 c6                	mov    %eax,%esi
  800d7c:	89 e8                	mov    %ebp,%eax
  800d7e:	89 f7                	mov    %esi,%edi
  800d80:	f7 f1                	div    %ecx
  800d82:	89 fa                	mov    %edi,%edx
  800d84:	83 c4 1c             	add    $0x1c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    
  800d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 f2                	cmp    %esi,%edx
  800d92:	77 7c                	ja     800e10 <__udivdi3+0xd0>
  800d94:	0f bd fa             	bsr    %edx,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0xf8>
  800da0:	89 f9                	mov    %edi,%ecx
  800da2:	b8 20 00 00 00       	mov    $0x20,%eax
  800da7:	29 f8                	sub    %edi,%eax
  800da9:	d3 e2                	shl    %cl,%edx
  800dab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	89 da                	mov    %ebx,%edx
  800db3:	d3 ea                	shr    %cl,%edx
  800db5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800db9:	09 d1                	or     %edx,%ecx
  800dbb:	89 f2                	mov    %esi,%edx
  800dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e3                	shl    %cl,%ebx
  800dc5:	89 c1                	mov    %eax,%ecx
  800dc7:	d3 ea                	shr    %cl,%edx
  800dc9:	89 f9                	mov    %edi,%ecx
  800dcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dcf:	d3 e6                	shl    %cl,%esi
  800dd1:	89 eb                	mov    %ebp,%ebx
  800dd3:	89 c1                	mov    %eax,%ecx
  800dd5:	d3 eb                	shr    %cl,%ebx
  800dd7:	09 de                	or     %ebx,%esi
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	f7 74 24 08          	divl   0x8(%esp)
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	f7 64 24 0c          	mull   0xc(%esp)
  800de7:	39 d6                	cmp    %edx,%esi
  800de9:	72 0c                	jb     800df7 <__udivdi3+0xb7>
  800deb:	89 f9                	mov    %edi,%ecx
  800ded:	d3 e5                	shl    %cl,%ebp
  800def:	39 c5                	cmp    %eax,%ebp
  800df1:	73 5d                	jae    800e50 <__udivdi3+0x110>
  800df3:	39 d6                	cmp    %edx,%esi
  800df5:	75 59                	jne    800e50 <__udivdi3+0x110>
  800df7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dfa:	31 ff                	xor    %edi,%edi
  800dfc:	89 fa                	mov    %edi,%edx
  800dfe:	83 c4 1c             	add    $0x1c,%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	8d 76 00             	lea    0x0(%esi),%esi
  800e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e10:	31 ff                	xor    %edi,%edi
  800e12:	31 c0                	xor    %eax,%eax
  800e14:	89 fa                	mov    %edi,%edx
  800e16:	83 c4 1c             	add    $0x1c,%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
  800e1e:	66 90                	xchg   %ax,%ax
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	89 e8                	mov    %ebp,%eax
  800e24:	89 f2                	mov    %esi,%edx
  800e26:	f7 f3                	div    %ebx
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	72 06                	jb     800e42 <__udivdi3+0x102>
  800e3c:	31 c0                	xor    %eax,%eax
  800e3e:	39 eb                	cmp    %ebp,%ebx
  800e40:	77 d2                	ja     800e14 <__udivdi3+0xd4>
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	eb cb                	jmp    800e14 <__udivdi3+0xd4>
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	31 ff                	xor    %edi,%edi
  800e54:	eb be                	jmp    800e14 <__udivdi3+0xd4>
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 ed                	test   %ebp,%ebp
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	89 da                	mov    %ebx,%edx
  800e7d:	75 19                	jne    800e98 <__umoddi3+0x38>
  800e7f:	39 df                	cmp    %ebx,%edi
  800e81:	0f 86 b1 00 00 00    	jbe    800f38 <__umoddi3+0xd8>
  800e87:	f7 f7                	div    %edi
  800e89:	89 d0                	mov    %edx,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	83 c4 1c             	add    $0x1c,%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	39 dd                	cmp    %ebx,%ebp
  800e9a:	77 f1                	ja     800e8d <__umoddi3+0x2d>
  800e9c:	0f bd cd             	bsr    %ebp,%ecx
  800e9f:	83 f1 1f             	xor    $0x1f,%ecx
  800ea2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ea6:	0f 84 b4 00 00 00    	je     800f60 <__umoddi3+0x100>
  800eac:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eb7:	29 c2                	sub    %eax,%edx
  800eb9:	89 c1                	mov    %eax,%ecx
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	89 d1                	mov    %edx,%ecx
  800ec1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ec5:	d3 e8                	shr    %cl,%eax
  800ec7:	09 c5                	or     %eax,%ebp
  800ec9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecd:	89 c1                	mov    %eax,%ecx
  800ecf:	d3 e7                	shl    %cl,%edi
  800ed1:	89 d1                	mov    %edx,%ecx
  800ed3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	d3 ef                	shr    %cl,%edi
  800edb:	89 c1                	mov    %eax,%ecx
  800edd:	89 f0                	mov    %esi,%eax
  800edf:	d3 e3                	shl    %cl,%ebx
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 fa                	mov    %edi,%edx
  800ee5:	d3 e8                	shr    %cl,%eax
  800ee7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eec:	09 d8                	or     %ebx,%eax
  800eee:	f7 f5                	div    %ebp
  800ef0:	d3 e6                	shl    %cl,%esi
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	f7 64 24 08          	mull   0x8(%esp)
  800ef8:	39 d1                	cmp    %edx,%ecx
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	72 06                	jb     800f06 <__umoddi3+0xa6>
  800f00:	75 0e                	jne    800f10 <__umoddi3+0xb0>
  800f02:	39 c6                	cmp    %eax,%esi
  800f04:	73 0a                	jae    800f10 <__umoddi3+0xb0>
  800f06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f0a:	19 ea                	sbb    %ebp,%edx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	89 ca                	mov    %ecx,%edx
  800f12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f17:	29 de                	sub    %ebx,%esi
  800f19:	19 fa                	sbb    %edi,%edx
  800f1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	d3 e0                	shl    %cl,%eax
  800f23:	89 d9                	mov    %ebx,%ecx
  800f25:	d3 ee                	shr    %cl,%esi
  800f27:	d3 ea                	shr    %cl,%edx
  800f29:	09 f0                	or     %esi,%eax
  800f2b:	83 c4 1c             	add    $0x1c,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    
  800f33:	90                   	nop
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	85 ff                	test   %edi,%edi
  800f3a:	89 f9                	mov    %edi,%ecx
  800f3c:	75 0b                	jne    800f49 <__umoddi3+0xe9>
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f7                	div    %edi
  800f47:	89 c1                	mov    %eax,%ecx
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	f7 f1                	div    %ecx
  800f53:	e9 31 ff ff ff       	jmp    800e89 <__umoddi3+0x29>
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	39 dd                	cmp    %ebx,%ebp
  800f62:	72 08                	jb     800f6c <__umoddi3+0x10c>
  800f64:	39 f7                	cmp    %esi,%edi
  800f66:	0f 87 21 ff ff ff    	ja     800e8d <__umoddi3+0x2d>
  800f6c:	89 da                	mov    %ebx,%edx
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	29 f8                	sub    %edi,%eax
  800f72:	19 ea                	sbb    %ebp,%edx
  800f74:	e9 14 ff ff ff       	jmp    800e8d <__umoddi3+0x2d>
