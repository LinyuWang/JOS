
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 67 00 00 00       	call   8000ac <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800055:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005c:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x37>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 aa 0f 80 00       	push   $0x800faa
  80011e:	6a 23                	push   $0x23
  800120:	68 c7 0f 80 00       	push   $0x800fc7
  800125:	e8 ed 01 00 00       	call   800317 <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 aa 0f 80 00       	push   $0x800faa
  80019f:	6a 23                	push   $0x23
  8001a1:	68 c7 0f 80 00       	push   $0x800fc7
  8001a6:	e8 6c 01 00 00       	call   800317 <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 aa 0f 80 00       	push   $0x800faa
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 c7 0f 80 00       	push   $0x800fc7
  8001e8:	e8 2a 01 00 00       	call   800317 <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 aa 0f 80 00       	push   $0x800faa
  800223:	6a 23                	push   $0x23
  800225:	68 c7 0f 80 00       	push   $0x800fc7
  80022a:	e8 e8 00 00 00       	call   800317 <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 aa 0f 80 00       	push   $0x800faa
  800265:	6a 23                	push   $0x23
  800267:	68 c7 0f 80 00       	push   $0x800fc7
  80026c:	e8 a6 00 00 00       	call   800317 <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 aa 0f 80 00       	push   $0x800faa
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 c7 0f 80 00       	push   $0x800fc7
  8002ae:	e8 64 00 00 00       	call   800317 <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 aa 0f 80 00       	push   $0x800faa
  80030b:	6a 23                	push   $0x23
  80030d:	68 c7 0f 80 00       	push   $0x800fc7
  800312:	e8 00 00 00 00       	call   800317 <_panic>

00800317 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80031c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800325:	e8 00 fe ff ff       	call   80012a <sys_getenvid>
  80032a:	83 ec 0c             	sub    $0xc,%esp
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	56                   	push   %esi
  800334:	50                   	push   %eax
  800335:	68 d8 0f 80 00       	push   $0x800fd8
  80033a:	e8 b3 00 00 00       	call   8003f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033f:	83 c4 18             	add    $0x18,%esp
  800342:	53                   	push   %ebx
  800343:	ff 75 10             	pushl  0x10(%ebp)
  800346:	e8 56 00 00 00       	call   8003a1 <vcprintf>
	cprintf("\n");
  80034b:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800352:	e8 9b 00 00 00       	call   8003f2 <cprintf>
  800357:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035a:	cc                   	int3   
  80035b:	eb fd                	jmp    80035a <_panic+0x43>

0080035d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	53                   	push   %ebx
  800361:	83 ec 04             	sub    $0x4,%esp
  800364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800367:	8b 13                	mov    (%ebx),%edx
  800369:	8d 42 01             	lea    0x1(%edx),%eax
  80036c:	89 03                	mov    %eax,(%ebx)
  80036e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800371:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800375:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037a:	74 09                	je     800385 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80037c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800383:	c9                   	leave  
  800384:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	68 ff 00 00 00       	push   $0xff
  80038d:	8d 43 08             	lea    0x8(%ebx),%eax
  800390:	50                   	push   %eax
  800391:	e8 16 fd ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800396:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	eb db                	jmp    80037c <putch+0x1f>

008003a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b1:	00 00 00 
	b.cnt = 0;
  8003b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003be:	ff 75 0c             	pushl  0xc(%ebp)
  8003c1:	ff 75 08             	pushl  0x8(%ebp)
  8003c4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ca:	50                   	push   %eax
  8003cb:	68 5d 03 80 00       	push   $0x80035d
  8003d0:	e8 1a 01 00 00       	call   8004ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d5:	83 c4 08             	add    $0x8,%esp
  8003d8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e4:	50                   	push   %eax
  8003e5:	e8 c2 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8003ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fb:	50                   	push   %eax
  8003fc:	ff 75 08             	pushl  0x8(%ebp)
  8003ff:	e8 9d ff ff ff       	call   8003a1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	57                   	push   %edi
  80040a:	56                   	push   %esi
  80040b:	53                   	push   %ebx
  80040c:	83 ec 1c             	sub    $0x1c,%esp
  80040f:	89 c7                	mov    %eax,%edi
  800411:	89 d6                	mov    %edx,%esi
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 55 0c             	mov    0xc(%ebp),%edx
  800419:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800422:	bb 00 00 00 00       	mov    $0x0,%ebx
  800427:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042d:	39 d3                	cmp    %edx,%ebx
  80042f:	72 05                	jb     800436 <printnum+0x30>
  800431:	39 45 10             	cmp    %eax,0x10(%ebp)
  800434:	77 7a                	ja     8004b0 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800436:	83 ec 0c             	sub    $0xc,%esp
  800439:	ff 75 18             	pushl  0x18(%ebp)
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800442:	53                   	push   %ebx
  800443:	ff 75 10             	pushl  0x10(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff 75 dc             	pushl  -0x24(%ebp)
  800452:	ff 75 d8             	pushl  -0x28(%ebp)
  800455:	e8 f6 08 00 00       	call   800d50 <__udivdi3>
  80045a:	83 c4 18             	add    $0x18,%esp
  80045d:	52                   	push   %edx
  80045e:	50                   	push   %eax
  80045f:	89 f2                	mov    %esi,%edx
  800461:	89 f8                	mov    %edi,%eax
  800463:	e8 9e ff ff ff       	call   800406 <printnum>
  800468:	83 c4 20             	add    $0x20,%esp
  80046b:	eb 13                	jmp    800480 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	ff 75 18             	pushl  0x18(%ebp)
  800474:	ff d7                	call   *%edi
  800476:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f ed                	jg     80046d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff 75 dc             	pushl  -0x24(%ebp)
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	e8 d8 09 00 00       	call   800e70 <__umoddi3>
  800498:	83 c4 14             	add    $0x14,%esp
  80049b:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  8004a2:	50                   	push   %eax
  8004a3:	ff d7                	call   *%edi
}
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    
  8004b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b3:	eb c4                	jmp    800479 <printnum+0x73>

008004b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c4:	73 0a                	jae    8004d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ce:	88 02                	mov    %al,(%edx)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	50                   	push   %eax
  8004dc:	ff 75 10             	pushl  0x10(%ebp)
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 05 00 00 00       	call   8004ef <vprintfmt>
}
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <vprintfmt>:
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	57                   	push   %edi
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 2c             	sub    $0x2c,%esp
  8004f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800501:	e9 63 03 00 00       	jmp    800869 <vprintfmt+0x37a>
		padc = ' ';
  800506:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80050a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800511:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800518:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80051f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8d 47 01             	lea    0x1(%edi),%eax
  800527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052a:	0f b6 17             	movzbl (%edi),%edx
  80052d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800530:	3c 55                	cmp    $0x55,%al
  800532:	0f 87 11 04 00 00    	ja     800949 <vprintfmt+0x45a>
  800538:	0f b6 c0             	movzbl %al,%eax
  80053b:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800545:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800549:	eb d9                	jmp    800524 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80054e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800552:	eb d0                	jmp    800524 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800554:	0f b6 d2             	movzbl %dl,%edx
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800562:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800565:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800569:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056f:	83 f9 09             	cmp    $0x9,%ecx
  800572:	77 55                	ja     8005c9 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800574:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800577:	eb e9                	jmp    800562 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	79 91                	jns    800524 <vprintfmt+0x35>
				width = precision, precision = -1;
  800593:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800596:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800599:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a0:	eb 82                	jmp    800524 <vprintfmt+0x35>
  8005a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ac:	0f 49 d0             	cmovns %eax,%edx
  8005af:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	e9 6a ff ff ff       	jmp    800524 <vprintfmt+0x35>
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005bd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c4:	e9 5b ff ff ff       	jmp    800524 <vprintfmt+0x35>
  8005c9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005cf:	eb bc                	jmp    80058d <vprintfmt+0x9e>
			lflag++;
  8005d1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d7:	e9 48 ff ff ff       	jmp    800524 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 78 04             	lea    0x4(%eax),%edi
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	ff 30                	pushl  (%eax)
  8005e8:	ff d6                	call   *%esi
			break;
  8005ea:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005ed:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005f0:	e9 71 02 00 00       	jmp    800866 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 78 04             	lea    0x4(%eax),%edi
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	99                   	cltd   
  8005fe:	31 d0                	xor    %edx,%eax
  800600:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800602:	83 f8 08             	cmp    $0x8,%eax
  800605:	7f 23                	jg     80062a <vprintfmt+0x13b>
  800607:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 18                	je     80062a <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800612:	52                   	push   %edx
  800613:	68 1f 10 80 00       	push   $0x80101f
  800618:	53                   	push   %ebx
  800619:	56                   	push   %esi
  80061a:	e8 b3 fe ff ff       	call   8004d2 <printfmt>
  80061f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800622:	89 7d 14             	mov    %edi,0x14(%ebp)
  800625:	e9 3c 02 00 00       	jmp    800866 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80062a:	50                   	push   %eax
  80062b:	68 16 10 80 00       	push   $0x801016
  800630:	53                   	push   %ebx
  800631:	56                   	push   %esi
  800632:	e8 9b fe ff ff       	call   8004d2 <printfmt>
  800637:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80063d:	e9 24 02 00 00       	jmp    800866 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	83 c0 04             	add    $0x4,%eax
  800648:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800650:	85 ff                	test   %edi,%edi
  800652:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  800657:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80065a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065e:	0f 8e bd 00 00 00    	jle    800721 <vprintfmt+0x232>
  800664:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800668:	75 0e                	jne    800678 <vprintfmt+0x189>
  80066a:	89 75 08             	mov    %esi,0x8(%ebp)
  80066d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800670:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800673:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800676:	eb 6d                	jmp    8006e5 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	ff 75 d0             	pushl  -0x30(%ebp)
  80067e:	57                   	push   %edi
  80067f:	e8 6d 03 00 00       	call   8009f1 <strnlen>
  800684:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800687:	29 c1                	sub    %eax,%ecx
  800689:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80068c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800696:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800699:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069b:	eb 0f                	jmp    8006ac <vprintfmt+0x1bd>
					putch(padc, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	85 ff                	test   %edi,%edi
  8006ae:	7f ed                	jg     80069d <vprintfmt+0x1ae>
  8006b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bd:	0f 49 c1             	cmovns %ecx,%eax
  8006c0:	29 c1                	sub    %eax,%ecx
  8006c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cb:	89 cb                	mov    %ecx,%ebx
  8006cd:	eb 16                	jmp    8006e5 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d3:	75 31                	jne    800706 <vprintfmt+0x217>
					putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	ff 75 0c             	pushl  0xc(%ebp)
  8006db:	50                   	push   %eax
  8006dc:	ff 55 08             	call   *0x8(%ebp)
  8006df:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e2:	83 eb 01             	sub    $0x1,%ebx
  8006e5:	83 c7 01             	add    $0x1,%edi
  8006e8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006ec:	0f be c2             	movsbl %dl,%eax
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 59                	je     80074c <vprintfmt+0x25d>
  8006f3:	85 f6                	test   %esi,%esi
  8006f5:	78 d8                	js     8006cf <vprintfmt+0x1e0>
  8006f7:	83 ee 01             	sub    $0x1,%esi
  8006fa:	79 d3                	jns    8006cf <vprintfmt+0x1e0>
  8006fc:	89 df                	mov    %ebx,%edi
  8006fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800704:	eb 37                	jmp    80073d <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800706:	0f be d2             	movsbl %dl,%edx
  800709:	83 ea 20             	sub    $0x20,%edx
  80070c:	83 fa 5e             	cmp    $0x5e,%edx
  80070f:	76 c4                	jbe    8006d5 <vprintfmt+0x1e6>
					putch('?', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	6a 3f                	push   $0x3f
  800719:	ff 55 08             	call   *0x8(%ebp)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb c1                	jmp    8006e2 <vprintfmt+0x1f3>
  800721:	89 75 08             	mov    %esi,0x8(%ebp)
  800724:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800727:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072d:	eb b6                	jmp    8006e5 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 20                	push   $0x20
  800735:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800737:	83 ef 01             	sub    $0x1,%edi
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	85 ff                	test   %edi,%edi
  80073f:	7f ee                	jg     80072f <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800741:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
  800747:	e9 1a 01 00 00       	jmp    800866 <vprintfmt+0x377>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	eb e7                	jmp    80073d <vprintfmt+0x24e>
	if (lflag >= 2)
  800756:	83 f9 01             	cmp    $0x1,%ecx
  800759:	7e 3f                	jle    80079a <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 50 04             	mov    0x4(%eax),%edx
  800761:	8b 00                	mov    (%eax),%eax
  800763:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800766:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 40 08             	lea    0x8(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800772:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800776:	79 5c                	jns    8007d4 <vprintfmt+0x2e5>
				putch('-', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	53                   	push   %ebx
  80077c:	6a 2d                	push   $0x2d
  80077e:	ff d6                	call   *%esi
				num = -(long long) num;
  800780:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800783:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800786:	f7 da                	neg    %edx
  800788:	83 d1 00             	adc    $0x0,%ecx
  80078b:	f7 d9                	neg    %ecx
  80078d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800790:	b8 0a 00 00 00       	mov    $0xa,%eax
  800795:	e9 b2 00 00 00       	jmp    80084c <vprintfmt+0x35d>
	else if (lflag)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	75 1b                	jne    8007b9 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	89 c1                	mov    %eax,%ecx
  8007a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b7:	eb b9                	jmp    800772 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c1:	89 c1                	mov    %eax,%ecx
  8007c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d2:	eb 9e                	jmp    800772 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007df:	eb 6b                	jmp    80084c <vprintfmt+0x35d>
	if (lflag >= 2)
  8007e1:	83 f9 01             	cmp    $0x1,%ecx
  8007e4:	7e 15                	jle    8007fb <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ee:	8d 40 08             	lea    0x8(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f9:	eb 51                	jmp    80084c <vprintfmt+0x35d>
	else if (lflag)
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	75 17                	jne    800816 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800814:	eb 36                	jmp    80084c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800820:	8d 40 04             	lea    0x4(%eax),%eax
  800823:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082b:	eb 1f                	jmp    80084c <vprintfmt+0x35d>
	if (lflag >= 2)
  80082d:	83 f9 01             	cmp    $0x1,%ecx
  800830:	7e 5b                	jle    80088d <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 50 04             	mov    0x4(%eax),%edx
  800838:	8b 00                	mov    (%eax),%eax
  80083a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80083d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800840:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800843:	89 d1                	mov    %edx,%ecx
  800845:	89 c2                	mov    %eax,%edx
			base = 8;
  800847:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80084c:	83 ec 0c             	sub    $0xc,%esp
  80084f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800853:	57                   	push   %edi
  800854:	ff 75 e0             	pushl  -0x20(%ebp)
  800857:	50                   	push   %eax
  800858:	51                   	push   %ecx
  800859:	52                   	push   %edx
  80085a:	89 da                	mov    %ebx,%edx
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	e8 a3 fb ff ff       	call   800406 <printnum>
			break;
  800863:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800869:	83 c7 01             	add    $0x1,%edi
  80086c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800870:	83 f8 25             	cmp    $0x25,%eax
  800873:	0f 84 8d fc ff ff    	je     800506 <vprintfmt+0x17>
			if (ch == '\0')
  800879:	85 c0                	test   %eax,%eax
  80087b:	0f 84 e8 00 00 00    	je     800969 <vprintfmt+0x47a>
			putch(ch, putdat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	53                   	push   %ebx
  800885:	50                   	push   %eax
  800886:	ff d6                	call   *%esi
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	eb dc                	jmp    800869 <vprintfmt+0x37a>
	else if (lflag)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	75 13                	jne    8008a4 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 10                	mov    (%eax),%edx
  800896:	89 d0                	mov    %edx,%eax
  800898:	99                   	cltd   
  800899:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80089f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a2:	eb 9f                	jmp    800843 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8b 10                	mov    (%eax),%edx
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	99                   	cltd   
  8008ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008af:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b5:	eb 8c                	jmp    800843 <vprintfmt+0x354>
			putch('0', putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 30                	push   $0x30
  8008bd:	ff d6                	call   *%esi
			putch('x', putdat);
  8008bf:	83 c4 08             	add    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	6a 78                	push   $0x78
  8008c5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8b 10                	mov    (%eax),%edx
  8008cc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008d1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008d4:	8d 40 04             	lea    0x4(%eax),%eax
  8008d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008df:	e9 68 ff ff ff       	jmp    80084c <vprintfmt+0x35d>
	if (lflag >= 2)
  8008e4:	83 f9 01             	cmp    $0x1,%ecx
  8008e7:	7e 18                	jle    800901 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	8b 10                	mov    (%eax),%edx
  8008ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f1:	8d 40 08             	lea    0x8(%eax),%eax
  8008f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8008fc:	e9 4b ff ff ff       	jmp    80084c <vprintfmt+0x35d>
	else if (lflag)
  800901:	85 c9                	test   %ecx,%ecx
  800903:	75 1a                	jne    80091f <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8b 10                	mov    (%eax),%edx
  80090a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090f:	8d 40 04             	lea    0x4(%eax),%eax
  800912:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800915:	b8 10 00 00 00       	mov    $0x10,%eax
  80091a:	e9 2d ff ff ff       	jmp    80084c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8b 10                	mov    (%eax),%edx
  800924:	b9 00 00 00 00       	mov    $0x0,%ecx
  800929:	8d 40 04             	lea    0x4(%eax),%eax
  80092c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092f:	b8 10 00 00 00       	mov    $0x10,%eax
  800934:	e9 13 ff ff ff       	jmp    80084c <vprintfmt+0x35d>
			putch(ch, putdat);
  800939:	83 ec 08             	sub    $0x8,%esp
  80093c:	53                   	push   %ebx
  80093d:	6a 25                	push   $0x25
  80093f:	ff d6                	call   *%esi
			break;
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	e9 1d ff ff ff       	jmp    800866 <vprintfmt+0x377>
			putch('%', putdat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	53                   	push   %ebx
  80094d:	6a 25                	push   $0x25
  80094f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	89 f8                	mov    %edi,%eax
  800956:	eb 03                	jmp    80095b <vprintfmt+0x46c>
  800958:	83 e8 01             	sub    $0x1,%eax
  80095b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095f:	75 f7                	jne    800958 <vprintfmt+0x469>
  800961:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800964:	e9 fd fe ff ff       	jmp    800866 <vprintfmt+0x377>
}
  800969:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 18             	sub    $0x18,%esp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800980:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800984:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800987:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098e:	85 c0                	test   %eax,%eax
  800990:	74 26                	je     8009b8 <vsnprintf+0x47>
  800992:	85 d2                	test   %edx,%edx
  800994:	7e 22                	jle    8009b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800996:	ff 75 14             	pushl  0x14(%ebp)
  800999:	ff 75 10             	pushl  0x10(%ebp)
  80099c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099f:	50                   	push   %eax
  8009a0:	68 b5 04 80 00       	push   $0x8004b5
  8009a5:	e8 45 fb ff ff       	call   8004ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b3:	83 c4 10             	add    $0x10,%esp
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    
		return -E_INVAL;
  8009b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009bd:	eb f7                	jmp    8009b6 <vsnprintf+0x45>

008009bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c8:	50                   	push   %eax
  8009c9:	ff 75 10             	pushl  0x10(%ebp)
  8009cc:	ff 75 0c             	pushl  0xc(%ebp)
  8009cf:	ff 75 08             	pushl  0x8(%ebp)
  8009d2:	e8 9a ff ff ff       	call   800971 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	eb 03                	jmp    8009e9 <strlen+0x10>
		n++;
  8009e6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ed:	75 f7                	jne    8009e6 <strlen+0xd>
	return n;
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 03                	jmp    800a04 <strnlen+0x13>
		n++;
  800a01:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	74 06                	je     800a0e <strnlen+0x1d>
  800a08:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a0c:	75 f3                	jne    800a01 <strnlen+0x10>
	return n;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a26:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a29:	84 db                	test   %bl,%bl
  800a2b:	75 ef                	jne    800a1c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a37:	53                   	push   %ebx
  800a38:	e8 9c ff ff ff       	call   8009d9 <strlen>
  800a3d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	01 d8                	add    %ebx,%eax
  800a45:	50                   	push   %eax
  800a46:	e8 c5 ff ff ff       	call   800a10 <strcpy>
	return dst;
}
  800a4b:	89 d8                	mov    %ebx,%eax
  800a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a62:	89 f2                	mov    %esi,%edx
  800a64:	eb 0f                	jmp    800a75 <strncpy+0x23>
		*dst++ = *src;
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	0f b6 01             	movzbl (%ecx),%eax
  800a6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a72:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a75:	39 da                	cmp    %ebx,%edx
  800a77:	75 ed                	jne    800a66 <strncpy+0x14>
	}
	return ret;
}
  800a79:	89 f0                	mov    %esi,%eax
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a8d:	89 f0                	mov    %esi,%eax
  800a8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	75 0b                	jne    800aa2 <strlcpy+0x23>
  800a97:	eb 17                	jmp    800ab0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800aa2:	39 d8                	cmp    %ebx,%eax
  800aa4:	74 07                	je     800aad <strlcpy+0x2e>
  800aa6:	0f b6 0a             	movzbl (%edx),%ecx
  800aa9:	84 c9                	test   %cl,%cl
  800aab:	75 ec                	jne    800a99 <strlcpy+0x1a>
		*dst = '\0';
  800aad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ab0:	29 f0                	sub    %esi,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800abf:	eb 06                	jmp    800ac7 <strcmp+0x11>
		p++, q++;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ac7:	0f b6 01             	movzbl (%ecx),%eax
  800aca:	84 c0                	test   %al,%al
  800acc:	74 04                	je     800ad2 <strcmp+0x1c>
  800ace:	3a 02                	cmp    (%edx),%al
  800ad0:	74 ef                	je     800ac1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad2:	0f b6 c0             	movzbl %al,%eax
  800ad5:	0f b6 12             	movzbl (%edx),%edx
  800ad8:	29 d0                	sub    %edx,%eax
}
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aeb:	eb 06                	jmp    800af3 <strncmp+0x17>
		n--, p++, q++;
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800af3:	39 d8                	cmp    %ebx,%eax
  800af5:	74 16                	je     800b0d <strncmp+0x31>
  800af7:	0f b6 08             	movzbl (%eax),%ecx
  800afa:	84 c9                	test   %cl,%cl
  800afc:	74 04                	je     800b02 <strncmp+0x26>
  800afe:	3a 0a                	cmp    (%edx),%cl
  800b00:	74 eb                	je     800aed <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b02:	0f b6 00             	movzbl (%eax),%eax
  800b05:	0f b6 12             	movzbl (%edx),%edx
  800b08:	29 d0                	sub    %edx,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	eb f6                	jmp    800b0a <strncmp+0x2e>

00800b14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1e:	0f b6 10             	movzbl (%eax),%edx
  800b21:	84 d2                	test   %dl,%dl
  800b23:	74 09                	je     800b2e <strchr+0x1a>
		if (*s == c)
  800b25:	38 ca                	cmp    %cl,%dl
  800b27:	74 0a                	je     800b33 <strchr+0x1f>
	for (; *s; s++)
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	eb f0                	jmp    800b1e <strchr+0xa>
			return (char *) s;
	return 0;
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3f:	eb 03                	jmp    800b44 <strfind+0xf>
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b47:	38 ca                	cmp    %cl,%dl
  800b49:	74 04                	je     800b4f <strfind+0x1a>
  800b4b:	84 d2                	test   %dl,%dl
  800b4d:	75 f2                	jne    800b41 <strfind+0xc>
			break;
	return (char *) s;
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b5d:	85 c9                	test   %ecx,%ecx
  800b5f:	74 13                	je     800b74 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b67:	75 05                	jne    800b6e <memset+0x1d>
  800b69:	f6 c1 03             	test   $0x3,%cl
  800b6c:	74 0d                	je     800b7b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	fc                   	cld    
  800b72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b74:	89 f8                	mov    %edi,%eax
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    
		c &= 0xFF;
  800b7b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7f:	89 d3                	mov    %edx,%ebx
  800b81:	c1 e3 08             	shl    $0x8,%ebx
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	c1 e0 18             	shl    $0x18,%eax
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	c1 e6 10             	shl    $0x10,%esi
  800b8e:	09 f0                	or     %esi,%eax
  800b90:	09 c2                	or     %eax,%edx
  800b92:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b94:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	fc                   	cld    
  800b9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9c:	eb d6                	jmp    800b74 <memset+0x23>

00800b9e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bac:	39 c6                	cmp    %eax,%esi
  800bae:	73 35                	jae    800be5 <memmove+0x47>
  800bb0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb3:	39 c2                	cmp    %eax,%edx
  800bb5:	76 2e                	jbe    800be5 <memmove+0x47>
		s += n;
		d += n;
  800bb7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	09 fe                	or     %edi,%esi
  800bbe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bc4:	74 0c                	je     800bd2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bc6:	83 ef 01             	sub    $0x1,%edi
  800bc9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bcc:	fd                   	std    
  800bcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bcf:	fc                   	cld    
  800bd0:	eb 21                	jmp    800bf3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd2:	f6 c1 03             	test   $0x3,%cl
  800bd5:	75 ef                	jne    800bc6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd7:	83 ef 04             	sub    $0x4,%edi
  800bda:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800be0:	fd                   	std    
  800be1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be3:	eb ea                	jmp    800bcf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be5:	89 f2                	mov    %esi,%edx
  800be7:	09 c2                	or     %eax,%edx
  800be9:	f6 c2 03             	test   $0x3,%dl
  800bec:	74 09                	je     800bf7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	fc                   	cld    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 f2                	jne    800bee <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bfc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	fc                   	cld    
  800c02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c04:	eb ed                	jmp    800bf3 <memmove+0x55>

00800c06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c09:	ff 75 10             	pushl  0x10(%ebp)
  800c0c:	ff 75 0c             	pushl  0xc(%ebp)
  800c0f:	ff 75 08             	pushl  0x8(%ebp)
  800c12:	e8 87 ff ff ff       	call   800b9e <memmove>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c24:	89 c6                	mov    %eax,%esi
  800c26:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c29:	39 f0                	cmp    %esi,%eax
  800c2b:	74 1c                	je     800c49 <memcmp+0x30>
		if (*s1 != *s2)
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	0f b6 1a             	movzbl (%edx),%ebx
  800c33:	38 d9                	cmp    %bl,%cl
  800c35:	75 08                	jne    800c3f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c37:	83 c0 01             	add    $0x1,%eax
  800c3a:	83 c2 01             	add    $0x1,%edx
  800c3d:	eb ea                	jmp    800c29 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c3f:	0f b6 c1             	movzbl %cl,%eax
  800c42:	0f b6 db             	movzbl %bl,%ebx
  800c45:	29 d8                	sub    %ebx,%eax
  800c47:	eb 05                	jmp    800c4e <memcmp+0x35>
	}

	return 0;
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c60:	39 d0                	cmp    %edx,%eax
  800c62:	73 09                	jae    800c6d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c64:	38 08                	cmp    %cl,(%eax)
  800c66:	74 05                	je     800c6d <memfind+0x1b>
	for (; s < ends; s++)
  800c68:	83 c0 01             	add    $0x1,%eax
  800c6b:	eb f3                	jmp    800c60 <memfind+0xe>
			break;
	return (void *) s;
}
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7b:	eb 03                	jmp    800c80 <strtol+0x11>
		s++;
  800c7d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c80:	0f b6 01             	movzbl (%ecx),%eax
  800c83:	3c 20                	cmp    $0x20,%al
  800c85:	74 f6                	je     800c7d <strtol+0xe>
  800c87:	3c 09                	cmp    $0x9,%al
  800c89:	74 f2                	je     800c7d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c8b:	3c 2b                	cmp    $0x2b,%al
  800c8d:	74 2e                	je     800cbd <strtol+0x4e>
	int neg = 0;
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c94:	3c 2d                	cmp    $0x2d,%al
  800c96:	74 2f                	je     800cc7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c98:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c9e:	75 05                	jne    800ca5 <strtol+0x36>
  800ca0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca3:	74 2c                	je     800cd1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca5:	85 db                	test   %ebx,%ebx
  800ca7:	75 0a                	jne    800cb3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cae:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb1:	74 28                	je     800cdb <strtol+0x6c>
		base = 10;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cbb:	eb 50                	jmp    800d0d <strtol+0x9e>
		s++;
  800cbd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc5:	eb d1                	jmp    800c98 <strtol+0x29>
		s++, neg = 1;
  800cc7:	83 c1 01             	add    $0x1,%ecx
  800cca:	bf 01 00 00 00       	mov    $0x1,%edi
  800ccf:	eb c7                	jmp    800c98 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd5:	74 0e                	je     800ce5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cd7:	85 db                	test   %ebx,%ebx
  800cd9:	75 d8                	jne    800cb3 <strtol+0x44>
		s++, base = 8;
  800cdb:	83 c1 01             	add    $0x1,%ecx
  800cde:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ce3:	eb ce                	jmp    800cb3 <strtol+0x44>
		s += 2, base = 16;
  800ce5:	83 c1 02             	add    $0x2,%ecx
  800ce8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ced:	eb c4                	jmp    800cb3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cef:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cf2:	89 f3                	mov    %esi,%ebx
  800cf4:	80 fb 19             	cmp    $0x19,%bl
  800cf7:	77 29                	ja     800d22 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cf9:	0f be d2             	movsbl %dl,%edx
  800cfc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d02:	7d 30                	jge    800d34 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d04:	83 c1 01             	add    $0x1,%ecx
  800d07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d0b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d0d:	0f b6 11             	movzbl (%ecx),%edx
  800d10:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d13:	89 f3                	mov    %esi,%ebx
  800d15:	80 fb 09             	cmp    $0x9,%bl
  800d18:	77 d5                	ja     800cef <strtol+0x80>
			dig = *s - '0';
  800d1a:	0f be d2             	movsbl %dl,%edx
  800d1d:	83 ea 30             	sub    $0x30,%edx
  800d20:	eb dd                	jmp    800cff <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d25:	89 f3                	mov    %esi,%ebx
  800d27:	80 fb 19             	cmp    $0x19,%bl
  800d2a:	77 08                	ja     800d34 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d2c:	0f be d2             	movsbl %dl,%edx
  800d2f:	83 ea 37             	sub    $0x37,%edx
  800d32:	eb cb                	jmp    800cff <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d38:	74 05                	je     800d3f <strtol+0xd0>
		*endptr = (char *) s;
  800d3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d3f:	89 c2                	mov    %eax,%edx
  800d41:	f7 da                	neg    %edx
  800d43:	85 ff                	test   %edi,%edi
  800d45:	0f 45 c2             	cmovne %edx,%eax
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
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
