
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004c:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80004f:	e8 c6 00 00 00       	call   80011a <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800061:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 db                	test   %ebx,%ebx
  800068:	7e 07                	jle    800071 <libmain+0x37>
		binaryname = argv[0];
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	56                   	push   %esi
  800075:	53                   	push   %ebx
  800076:	e8 b8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007b:	e8 0a 00 00 00       	call   80008a <exit>
}
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800090:	6a 00                	push   $0x0
  800092:	e8 42 00 00 00       	call   8000d9 <sys_env_destroy>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7f 08                	jg     800103 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	6a 03                	push   $0x3
  800109:	68 8a 0f 80 00       	push   $0x800f8a
  80010e:	6a 23                	push   $0x23
  800110:	68 a7 0f 80 00       	push   $0x800fa7
  800115:	e8 ed 01 00 00       	call   800307 <_panic>

0080011a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 02 00 00 00       	mov    $0x2,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <sys_yield>:

void
sys_yield(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 0a 00 00 00       	mov    $0xa,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800161:	be 00 00 00 00       	mov    $0x0,%esi
  800166:	8b 55 08             	mov    0x8(%ebp),%edx
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800174:	89 f7                	mov    %esi,%edi
  800176:	cd 30                	int    $0x30
	if(check && ret > 0)
  800178:	85 c0                	test   %eax,%eax
  80017a:	7f 08                	jg     800184 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	50                   	push   %eax
  800188:	6a 04                	push   $0x4
  80018a:	68 8a 0f 80 00       	push   $0x800f8a
  80018f:	6a 23                	push   $0x23
  800191:	68 a7 0f 80 00       	push   $0x800fa7
  800196:	e8 6c 01 00 00       	call   800307 <_panic>

0080019b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	7f 08                	jg     8001c6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	6a 05                	push   $0x5
  8001cc:	68 8a 0f 80 00       	push   $0x800f8a
  8001d1:	6a 23                	push   $0x23
  8001d3:	68 a7 0f 80 00       	push   $0x800fa7
  8001d8:	e8 2a 01 00 00       	call   800307 <_panic>

008001dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	89 df                	mov    %ebx,%edi
  8001f8:	89 de                	mov    %ebx,%esi
  8001fa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7f 08                	jg     800208 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5f                   	pop    %edi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 06                	push   $0x6
  80020e:	68 8a 0f 80 00       	push   $0x800f8a
  800213:	6a 23                	push   $0x23
  800215:	68 a7 0f 80 00       	push   $0x800fa7
  80021a:	e8 e8 00 00 00       	call   800307 <_panic>

0080021f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7f 08                	jg     80024a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	50                   	push   %eax
  80024e:	6a 08                	push   $0x8
  800250:	68 8a 0f 80 00       	push   $0x800f8a
  800255:	6a 23                	push   $0x23
  800257:	68 a7 0f 80 00       	push   $0x800fa7
  80025c:	e8 a6 00 00 00       	call   800307 <_panic>

00800261 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	8b 55 08             	mov    0x8(%ebp),%edx
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	89 df                	mov    %ebx,%edi
  80027c:	89 de                	mov    %ebx,%esi
  80027e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800280:	85 c0                	test   %eax,%eax
  800282:	7f 08                	jg     80028c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800287:	5b                   	pop    %ebx
  800288:	5e                   	pop    %esi
  800289:	5f                   	pop    %edi
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	50                   	push   %eax
  800290:	6a 09                	push   $0x9
  800292:	68 8a 0f 80 00       	push   $0x800f8a
  800297:	6a 23                	push   $0x23
  800299:	68 a7 0f 80 00       	push   $0x800fa7
  80029e:	e8 64 00 00 00       	call   800307 <_panic>

008002a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002af:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b4:	be 00 00 00 00       	mov    $0x0,%esi
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	89 cb                	mov    %ecx,%ebx
  8002de:	89 cf                	mov    %ecx,%edi
  8002e0:	89 ce                	mov    %ecx,%esi
  8002e2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7f 08                	jg     8002f0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	50                   	push   %eax
  8002f4:	6a 0c                	push   $0xc
  8002f6:	68 8a 0f 80 00       	push   $0x800f8a
  8002fb:	6a 23                	push   $0x23
  8002fd:	68 a7 0f 80 00       	push   $0x800fa7
  800302:	e8 00 00 00 00       	call   800307 <_panic>

00800307 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800315:	e8 00 fe ff ff       	call   80011a <sys_getenvid>
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	56                   	push   %esi
  800324:	50                   	push   %eax
  800325:	68 b8 0f 80 00       	push   $0x800fb8
  80032a:	e8 b3 00 00 00       	call   8003e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032f:	83 c4 18             	add    $0x18,%esp
  800332:	53                   	push   %ebx
  800333:	ff 75 10             	pushl  0x10(%ebp)
  800336:	e8 56 00 00 00       	call   800391 <vcprintf>
	cprintf("\n");
  80033b:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800342:	e8 9b 00 00 00       	call   8003e2 <cprintf>
  800347:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034a:	cc                   	int3   
  80034b:	eb fd                	jmp    80034a <_panic+0x43>

0080034d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	53                   	push   %ebx
  800351:	83 ec 04             	sub    $0x4,%esp
  800354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800357:	8b 13                	mov    (%ebx),%edx
  800359:	8d 42 01             	lea    0x1(%edx),%eax
  80035c:	89 03                	mov    %eax,(%ebx)
  80035e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800361:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800365:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036a:	74 09                	je     800375 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80036c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800373:	c9                   	leave  
  800374:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	68 ff 00 00 00       	push   $0xff
  80037d:	8d 43 08             	lea    0x8(%ebx),%eax
  800380:	50                   	push   %eax
  800381:	e8 16 fd ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  800386:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	eb db                	jmp    80036c <putch+0x1f>

00800391 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a1:	00 00 00 
	b.cnt = 0;
  8003a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ae:	ff 75 0c             	pushl  0xc(%ebp)
  8003b1:	ff 75 08             	pushl  0x8(%ebp)
  8003b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ba:	50                   	push   %eax
  8003bb:	68 4d 03 80 00       	push   $0x80034d
  8003c0:	e8 1a 01 00 00       	call   8004df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c5:	83 c4 08             	add    $0x8,%esp
  8003c8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d4:	50                   	push   %eax
  8003d5:	e8 c2 fc ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  8003da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003eb:	50                   	push   %eax
  8003ec:	ff 75 08             	pushl  0x8(%ebp)
  8003ef:	e8 9d ff ff ff       	call   800391 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	57                   	push   %edi
  8003fa:	56                   	push   %esi
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 1c             	sub    $0x1c,%esp
  8003ff:	89 c7                	mov    %eax,%edi
  800401:	89 d6                	mov    %edx,%esi
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800412:	bb 00 00 00 00       	mov    $0x0,%ebx
  800417:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041d:	39 d3                	cmp    %edx,%ebx
  80041f:	72 05                	jb     800426 <printnum+0x30>
  800421:	39 45 10             	cmp    %eax,0x10(%ebp)
  800424:	77 7a                	ja     8004a0 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800426:	83 ec 0c             	sub    $0xc,%esp
  800429:	ff 75 18             	pushl  0x18(%ebp)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800432:	53                   	push   %ebx
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff 75 dc             	pushl  -0x24(%ebp)
  800442:	ff 75 d8             	pushl  -0x28(%ebp)
  800445:	e8 f6 08 00 00       	call   800d40 <__udivdi3>
  80044a:	83 c4 18             	add    $0x18,%esp
  80044d:	52                   	push   %edx
  80044e:	50                   	push   %eax
  80044f:	89 f2                	mov    %esi,%edx
  800451:	89 f8                	mov    %edi,%eax
  800453:	e8 9e ff ff ff       	call   8003f6 <printnum>
  800458:	83 c4 20             	add    $0x20,%esp
  80045b:	eb 13                	jmp    800470 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	56                   	push   %esi
  800461:	ff 75 18             	pushl  0x18(%ebp)
  800464:	ff d7                	call   *%edi
  800466:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800469:	83 eb 01             	sub    $0x1,%ebx
  80046c:	85 db                	test   %ebx,%ebx
  80046e:	7f ed                	jg     80045d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	56                   	push   %esi
  800474:	83 ec 04             	sub    $0x4,%esp
  800477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff 75 dc             	pushl  -0x24(%ebp)
  800480:	ff 75 d8             	pushl  -0x28(%ebp)
  800483:	e8 d8 09 00 00       	call   800e60 <__umoddi3>
  800488:	83 c4 14             	add    $0x14,%esp
  80048b:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800492:	50                   	push   %eax
  800493:	ff d7                	call   *%edi
}
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049b:	5b                   	pop    %ebx
  80049c:	5e                   	pop    %esi
  80049d:	5f                   	pop    %edi
  80049e:	5d                   	pop    %ebp
  80049f:	c3                   	ret    
  8004a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a3:	eb c4                	jmp    800469 <printnum+0x73>

008004a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004af:	8b 10                	mov    (%eax),%edx
  8004b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b4:	73 0a                	jae    8004c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004be:	88 02                	mov    %al,(%edx)
}
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <printfmt>:
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cb:	50                   	push   %eax
  8004cc:	ff 75 10             	pushl  0x10(%ebp)
  8004cf:	ff 75 0c             	pushl  0xc(%ebp)
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 05 00 00 00       	call   8004df <vprintfmt>
}
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	c9                   	leave  
  8004de:	c3                   	ret    

008004df <vprintfmt>:
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	57                   	push   %edi
  8004e3:	56                   	push   %esi
  8004e4:	53                   	push   %ebx
  8004e5:	83 ec 2c             	sub    $0x2c,%esp
  8004e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f1:	e9 63 03 00 00       	jmp    800859 <vprintfmt+0x37a>
		padc = ' ';
  8004f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800501:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800508:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80050f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8d 47 01             	lea    0x1(%edi),%eax
  800517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051a:	0f b6 17             	movzbl (%edi),%edx
  80051d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800520:	3c 55                	cmp    $0x55,%al
  800522:	0f 87 11 04 00 00    	ja     800939 <vprintfmt+0x45a>
  800528:	0f b6 c0             	movzbl %al,%eax
  80052b:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800535:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800539:	eb d9                	jmp    800514 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80053e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800542:	eb d0                	jmp    800514 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800544:	0f b6 d2             	movzbl %dl,%edx
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
  80054f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800552:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800555:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800559:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80055f:	83 f9 09             	cmp    $0x9,%ecx
  800562:	77 55                	ja     8005b9 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800564:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800567:	eb e9                	jmp    800552 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80057d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800581:	79 91                	jns    800514 <vprintfmt+0x35>
				width = precision, precision = -1;
  800583:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800586:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800589:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800590:	eb 82                	jmp    800514 <vprintfmt+0x35>
  800592:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	ba 00 00 00 00       	mov    $0x0,%edx
  80059c:	0f 49 d0             	cmovns %eax,%edx
  80059f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a5:	e9 6a ff ff ff       	jmp    800514 <vprintfmt+0x35>
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005ad:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b4:	e9 5b ff ff ff       	jmp    800514 <vprintfmt+0x35>
  8005b9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bf:	eb bc                	jmp    80057d <vprintfmt+0x9e>
			lflag++;
  8005c1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c7:	e9 48 ff ff ff       	jmp    800514 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 78 04             	lea    0x4(%eax),%edi
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	ff 30                	pushl  (%eax)
  8005d8:	ff d6                	call   *%esi
			break;
  8005da:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005dd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e0:	e9 71 02 00 00       	jmp    800856 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 78 04             	lea    0x4(%eax),%edi
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	99                   	cltd   
  8005ee:	31 d0                	xor    %edx,%eax
  8005f0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f2:	83 f8 08             	cmp    $0x8,%eax
  8005f5:	7f 23                	jg     80061a <vprintfmt+0x13b>
  8005f7:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8005fe:	85 d2                	test   %edx,%edx
  800600:	74 18                	je     80061a <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 ff 0f 80 00       	push   $0x800fff
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 b3 fe ff ff       	call   8004c2 <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800612:	89 7d 14             	mov    %edi,0x14(%ebp)
  800615:	e9 3c 02 00 00       	jmp    800856 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80061a:	50                   	push   %eax
  80061b:	68 f6 0f 80 00       	push   $0x800ff6
  800620:	53                   	push   %ebx
  800621:	56                   	push   %esi
  800622:	e8 9b fe ff ff       	call   8004c2 <printfmt>
  800627:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80062a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80062d:	e9 24 02 00 00       	jmp    800856 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	83 c0 04             	add    $0x4,%eax
  800638:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800640:	85 ff                	test   %edi,%edi
  800642:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  800647:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80064a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064e:	0f 8e bd 00 00 00    	jle    800711 <vprintfmt+0x232>
  800654:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800658:	75 0e                	jne    800668 <vprintfmt+0x189>
  80065a:	89 75 08             	mov    %esi,0x8(%ebp)
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800666:	eb 6d                	jmp    8006d5 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	ff 75 d0             	pushl  -0x30(%ebp)
  80066e:	57                   	push   %edi
  80066f:	e8 6d 03 00 00       	call   8009e1 <strnlen>
  800674:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800677:	29 c1                	sub    %eax,%ecx
  800679:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800683:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800686:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800689:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	eb 0f                	jmp    80069c <vprintfmt+0x1bd>
					putch(padc, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	ff 75 e0             	pushl  -0x20(%ebp)
  800694:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800696:	83 ef 01             	sub    $0x1,%edi
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	85 ff                	test   %edi,%edi
  80069e:	7f ed                	jg     80068d <vprintfmt+0x1ae>
  8006a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a6:	85 c9                	test   %ecx,%ecx
  8006a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ad:	0f 49 c1             	cmovns %ecx,%eax
  8006b0:	29 c1                	sub    %eax,%ecx
  8006b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bb:	89 cb                	mov    %ecx,%ebx
  8006bd:	eb 16                	jmp    8006d5 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c3:	75 31                	jne    8006f6 <vprintfmt+0x217>
					putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	50                   	push   %eax
  8006cc:	ff 55 08             	call   *0x8(%ebp)
  8006cf:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d2:	83 eb 01             	sub    $0x1,%ebx
  8006d5:	83 c7 01             	add    $0x1,%edi
  8006d8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006dc:	0f be c2             	movsbl %dl,%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 59                	je     80073c <vprintfmt+0x25d>
  8006e3:	85 f6                	test   %esi,%esi
  8006e5:	78 d8                	js     8006bf <vprintfmt+0x1e0>
  8006e7:	83 ee 01             	sub    $0x1,%esi
  8006ea:	79 d3                	jns    8006bf <vprintfmt+0x1e0>
  8006ec:	89 df                	mov    %ebx,%edi
  8006ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f4:	eb 37                	jmp    80072d <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f6:	0f be d2             	movsbl %dl,%edx
  8006f9:	83 ea 20             	sub    $0x20,%edx
  8006fc:	83 fa 5e             	cmp    $0x5e,%edx
  8006ff:	76 c4                	jbe    8006c5 <vprintfmt+0x1e6>
					putch('?', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	6a 3f                	push   $0x3f
  800709:	ff 55 08             	call   *0x8(%ebp)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb c1                	jmp    8006d2 <vprintfmt+0x1f3>
  800711:	89 75 08             	mov    %esi,0x8(%ebp)
  800714:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800717:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071d:	eb b6                	jmp    8006d5 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 20                	push   $0x20
  800725:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800727:	83 ef 01             	sub    $0x1,%edi
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 ff                	test   %edi,%edi
  80072f:	7f ee                	jg     80071f <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800731:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
  800737:	e9 1a 01 00 00       	jmp    800856 <vprintfmt+0x377>
  80073c:	89 df                	mov    %ebx,%edi
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800744:	eb e7                	jmp    80072d <vprintfmt+0x24e>
	if (lflag >= 2)
  800746:	83 f9 01             	cmp    $0x1,%ecx
  800749:	7e 3f                	jle    80078a <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 50 04             	mov    0x4(%eax),%edx
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800756:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 40 08             	lea    0x8(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800762:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800766:	79 5c                	jns    8007c4 <vprintfmt+0x2e5>
				putch('-', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 2d                	push   $0x2d
  80076e:	ff d6                	call   *%esi
				num = -(long long) num;
  800770:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800773:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800776:	f7 da                	neg    %edx
  800778:	83 d1 00             	adc    $0x0,%ecx
  80077b:	f7 d9                	neg    %ecx
  80077d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800780:	b8 0a 00 00 00       	mov    $0xa,%eax
  800785:	e9 b2 00 00 00       	jmp    80083c <vprintfmt+0x35d>
	else if (lflag)
  80078a:	85 c9                	test   %ecx,%ecx
  80078c:	75 1b                	jne    8007a9 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 00                	mov    (%eax),%eax
  800793:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800796:	89 c1                	mov    %eax,%ecx
  800798:	c1 f9 1f             	sar    $0x1f,%ecx
  80079b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 40 04             	lea    0x4(%eax),%eax
  8007a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a7:	eb b9                	jmp    800762 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b1:	89 c1                	mov    %eax,%ecx
  8007b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c2:	eb 9e                	jmp    800762 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cf:	eb 6b                	jmp    80083c <vprintfmt+0x35d>
	if (lflag >= 2)
  8007d1:	83 f9 01             	cmp    $0x1,%ecx
  8007d4:	7e 15                	jle    8007eb <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8b 48 04             	mov    0x4(%eax),%ecx
  8007de:	8d 40 08             	lea    0x8(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e9:	eb 51                	jmp    80083c <vprintfmt+0x35d>
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	75 17                	jne    800806 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800804:	eb 36                	jmp    80083c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	eb 1f                	jmp    80083c <vprintfmt+0x35d>
	if (lflag >= 2)
  80081d:	83 f9 01             	cmp    $0x1,%ecx
  800820:	7e 5b                	jle    80087d <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 50 04             	mov    0x4(%eax),%edx
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80082d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800830:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800833:	89 d1                	mov    %edx,%ecx
  800835:	89 c2                	mov    %eax,%edx
			base = 8;
  800837:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80083c:	83 ec 0c             	sub    $0xc,%esp
  80083f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800843:	57                   	push   %edi
  800844:	ff 75 e0             	pushl  -0x20(%ebp)
  800847:	50                   	push   %eax
  800848:	51                   	push   %ecx
  800849:	52                   	push   %edx
  80084a:	89 da                	mov    %ebx,%edx
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	e8 a3 fb ff ff       	call   8003f6 <printnum>
			break;
  800853:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800859:	83 c7 01             	add    $0x1,%edi
  80085c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800860:	83 f8 25             	cmp    $0x25,%eax
  800863:	0f 84 8d fc ff ff    	je     8004f6 <vprintfmt+0x17>
			if (ch == '\0')
  800869:	85 c0                	test   %eax,%eax
  80086b:	0f 84 e8 00 00 00    	je     800959 <vprintfmt+0x47a>
			putch(ch, putdat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	50                   	push   %eax
  800876:	ff d6                	call   *%esi
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	eb dc                	jmp    800859 <vprintfmt+0x37a>
	else if (lflag)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	75 13                	jne    800894 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8b 10                	mov    (%eax),%edx
  800886:	89 d0                	mov    %edx,%eax
  800888:	99                   	cltd   
  800889:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80088c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800892:	eb 9f                	jmp    800833 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	89 d0                	mov    %edx,%eax
  80089b:	99                   	cltd   
  80089c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089f:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a5:	eb 8c                	jmp    800833 <vprintfmt+0x354>
			putch('0', putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	53                   	push   %ebx
  8008ab:	6a 30                	push   $0x30
  8008ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	6a 78                	push   $0x78
  8008b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8b 10                	mov    (%eax),%edx
  8008bc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008c4:	8d 40 04             	lea    0x4(%eax),%eax
  8008c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008cf:	e9 68 ff ff ff       	jmp    80083c <vprintfmt+0x35d>
	if (lflag >= 2)
  8008d4:	83 f9 01             	cmp    $0x1,%ecx
  8008d7:	7e 18                	jle    8008f1 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8b 10                	mov    (%eax),%edx
  8008de:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e1:	8d 40 08             	lea    0x8(%eax),%eax
  8008e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e7:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ec:	e9 4b ff ff ff       	jmp    80083c <vprintfmt+0x35d>
	else if (lflag)
  8008f1:	85 c9                	test   %ecx,%ecx
  8008f3:	75 1a                	jne    80090f <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8b 10                	mov    (%eax),%edx
  8008fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ff:	8d 40 04             	lea    0x4(%eax),%eax
  800902:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800905:	b8 10 00 00 00       	mov    $0x10,%eax
  80090a:	e9 2d ff ff ff       	jmp    80083c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	b9 00 00 00 00       	mov    $0x0,%ecx
  800919:	8d 40 04             	lea    0x4(%eax),%eax
  80091c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091f:	b8 10 00 00 00       	mov    $0x10,%eax
  800924:	e9 13 ff ff ff       	jmp    80083c <vprintfmt+0x35d>
			putch(ch, putdat);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	53                   	push   %ebx
  80092d:	6a 25                	push   $0x25
  80092f:	ff d6                	call   *%esi
			break;
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	e9 1d ff ff ff       	jmp    800856 <vprintfmt+0x377>
			putch('%', putdat);
  800939:	83 ec 08             	sub    $0x8,%esp
  80093c:	53                   	push   %ebx
  80093d:	6a 25                	push   $0x25
  80093f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	89 f8                	mov    %edi,%eax
  800946:	eb 03                	jmp    80094b <vprintfmt+0x46c>
  800948:	83 e8 01             	sub    $0x1,%eax
  80094b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80094f:	75 f7                	jne    800948 <vprintfmt+0x469>
  800951:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800954:	e9 fd fe ff ff       	jmp    800856 <vprintfmt+0x377>
}
  800959:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 18             	sub    $0x18,%esp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800970:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800974:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800977:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097e:	85 c0                	test   %eax,%eax
  800980:	74 26                	je     8009a8 <vsnprintf+0x47>
  800982:	85 d2                	test   %edx,%edx
  800984:	7e 22                	jle    8009a8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800986:	ff 75 14             	pushl  0x14(%ebp)
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098f:	50                   	push   %eax
  800990:	68 a5 04 80 00       	push   $0x8004a5
  800995:	e8 45 fb ff ff       	call   8004df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80099a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80099d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a3:	83 c4 10             	add    $0x10,%esp
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    
		return -E_INVAL;
  8009a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ad:	eb f7                	jmp    8009a6 <vsnprintf+0x45>

008009af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b8:	50                   	push   %eax
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	ff 75 0c             	pushl  0xc(%ebp)
  8009bf:	ff 75 08             	pushl  0x8(%ebp)
  8009c2:	e8 9a ff ff ff       	call   800961 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	eb 03                	jmp    8009d9 <strlen+0x10>
		n++;
  8009d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009dd:	75 f7                	jne    8009d6 <strlen+0xd>
	return n;
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 03                	jmp    8009f4 <strnlen+0x13>
		n++;
  8009f1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	74 06                	je     8009fe <strnlen+0x1d>
  8009f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009fc:	75 f3                	jne    8009f1 <strnlen+0x10>
	return n;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a0a:	89 c2                	mov    %eax,%edx
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	83 c2 01             	add    $0x1,%edx
  800a12:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a16:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a19:	84 db                	test   %bl,%bl
  800a1b:	75 ef                	jne    800a0c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	53                   	push   %ebx
  800a24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a27:	53                   	push   %ebx
  800a28:	e8 9c ff ff ff       	call   8009c9 <strlen>
  800a2d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	01 d8                	add    %ebx,%eax
  800a35:	50                   	push   %eax
  800a36:	e8 c5 ff ff ff       	call   800a00 <strcpy>
	return dst;
}
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a52:	89 f2                	mov    %esi,%edx
  800a54:	eb 0f                	jmp    800a65 <strncpy+0x23>
		*dst++ = *src;
  800a56:	83 c2 01             	add    $0x1,%edx
  800a59:	0f b6 01             	movzbl (%ecx),%eax
  800a5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a62:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a65:	39 da                	cmp    %ebx,%edx
  800a67:	75 ed                	jne    800a56 <strncpy+0x14>
	}
	return ret;
}
  800a69:	89 f0                	mov    %esi,%eax
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 75 08             	mov    0x8(%ebp),%esi
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a7d:	89 f0                	mov    %esi,%eax
  800a7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a83:	85 c9                	test   %ecx,%ecx
  800a85:	75 0b                	jne    800a92 <strlcpy+0x23>
  800a87:	eb 17                	jmp    800aa0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a89:	83 c2 01             	add    $0x1,%edx
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a92:	39 d8                	cmp    %ebx,%eax
  800a94:	74 07                	je     800a9d <strlcpy+0x2e>
  800a96:	0f b6 0a             	movzbl (%edx),%ecx
  800a99:	84 c9                	test   %cl,%cl
  800a9b:	75 ec                	jne    800a89 <strlcpy+0x1a>
		*dst = '\0';
  800a9d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa0:	29 f0                	sub    %esi,%eax
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aaf:	eb 06                	jmp    800ab7 <strcmp+0x11>
		p++, q++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ab7:	0f b6 01             	movzbl (%ecx),%eax
  800aba:	84 c0                	test   %al,%al
  800abc:	74 04                	je     800ac2 <strcmp+0x1c>
  800abe:	3a 02                	cmp    (%edx),%al
  800ac0:	74 ef                	je     800ab1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac2:	0f b6 c0             	movzbl %al,%eax
  800ac5:	0f b6 12             	movzbl (%edx),%edx
  800ac8:	29 d0                	sub    %edx,%eax
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad6:	89 c3                	mov    %eax,%ebx
  800ad8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800adb:	eb 06                	jmp    800ae3 <strncmp+0x17>
		n--, p++, q++;
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ae3:	39 d8                	cmp    %ebx,%eax
  800ae5:	74 16                	je     800afd <strncmp+0x31>
  800ae7:	0f b6 08             	movzbl (%eax),%ecx
  800aea:	84 c9                	test   %cl,%cl
  800aec:	74 04                	je     800af2 <strncmp+0x26>
  800aee:	3a 0a                	cmp    (%edx),%cl
  800af0:	74 eb                	je     800add <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	0f b6 12             	movzbl (%edx),%edx
  800af8:	29 d0                	sub    %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    
		return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	eb f6                	jmp    800afa <strncmp+0x2e>

00800b04 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0e:	0f b6 10             	movzbl (%eax),%edx
  800b11:	84 d2                	test   %dl,%dl
  800b13:	74 09                	je     800b1e <strchr+0x1a>
		if (*s == c)
  800b15:	38 ca                	cmp    %cl,%dl
  800b17:	74 0a                	je     800b23 <strchr+0x1f>
	for (; *s; s++)
  800b19:	83 c0 01             	add    $0x1,%eax
  800b1c:	eb f0                	jmp    800b0e <strchr+0xa>
			return (char *) s;
	return 0;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2f:	eb 03                	jmp    800b34 <strfind+0xf>
  800b31:	83 c0 01             	add    $0x1,%eax
  800b34:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b37:	38 ca                	cmp    %cl,%dl
  800b39:	74 04                	je     800b3f <strfind+0x1a>
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f2                	jne    800b31 <strfind+0xc>
			break;
	return (char *) s;
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4d:	85 c9                	test   %ecx,%ecx
  800b4f:	74 13                	je     800b64 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b51:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b57:	75 05                	jne    800b5e <memset+0x1d>
  800b59:	f6 c1 03             	test   $0x3,%cl
  800b5c:	74 0d                	je     800b6b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	fc                   	cld    
  800b62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b64:	89 f8                	mov    %edi,%eax
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    
		c &= 0xFF;
  800b6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	c1 e3 08             	shl    $0x8,%ebx
  800b74:	89 d0                	mov    %edx,%eax
  800b76:	c1 e0 18             	shl    $0x18,%eax
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	c1 e6 10             	shl    $0x10,%esi
  800b7e:	09 f0                	or     %esi,%eax
  800b80:	09 c2                	or     %eax,%edx
  800b82:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b84:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	fc                   	cld    
  800b8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b8c:	eb d6                	jmp    800b64 <memset+0x23>

00800b8e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9c:	39 c6                	cmp    %eax,%esi
  800b9e:	73 35                	jae    800bd5 <memmove+0x47>
  800ba0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba3:	39 c2                	cmp    %eax,%edx
  800ba5:	76 2e                	jbe    800bd5 <memmove+0x47>
		s += n;
		d += n;
  800ba7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	09 fe                	or     %edi,%esi
  800bae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb4:	74 0c                	je     800bc2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb6:	83 ef 01             	sub    $0x1,%edi
  800bb9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bbc:	fd                   	std    
  800bbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbf:	fc                   	cld    
  800bc0:	eb 21                	jmp    800be3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc2:	f6 c1 03             	test   $0x3,%cl
  800bc5:	75 ef                	jne    800bb6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc7:	83 ef 04             	sub    $0x4,%edi
  800bca:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bcd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bd0:	fd                   	std    
  800bd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd3:	eb ea                	jmp    800bbf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd5:	89 f2                	mov    %esi,%edx
  800bd7:	09 c2                	or     %eax,%edx
  800bd9:	f6 c2 03             	test   $0x3,%dl
  800bdc:	74 09                	je     800be7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bde:	89 c7                	mov    %eax,%edi
  800be0:	fc                   	cld    
  800be1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 f2                	jne    800bde <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bec:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	fc                   	cld    
  800bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf4:	eb ed                	jmp    800be3 <memmove+0x55>

00800bf6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf9:	ff 75 10             	pushl  0x10(%ebp)
  800bfc:	ff 75 0c             	pushl  0xc(%ebp)
  800bff:	ff 75 08             	pushl  0x8(%ebp)
  800c02:	e8 87 ff ff ff       	call   800b8e <memmove>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c14:	89 c6                	mov    %eax,%esi
  800c16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c19:	39 f0                	cmp    %esi,%eax
  800c1b:	74 1c                	je     800c39 <memcmp+0x30>
		if (*s1 != *s2)
  800c1d:	0f b6 08             	movzbl (%eax),%ecx
  800c20:	0f b6 1a             	movzbl (%edx),%ebx
  800c23:	38 d9                	cmp    %bl,%cl
  800c25:	75 08                	jne    800c2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c27:	83 c0 01             	add    $0x1,%eax
  800c2a:	83 c2 01             	add    $0x1,%edx
  800c2d:	eb ea                	jmp    800c19 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c2f:	0f b6 c1             	movzbl %cl,%eax
  800c32:	0f b6 db             	movzbl %bl,%ebx
  800c35:	29 d8                	sub    %ebx,%eax
  800c37:	eb 05                	jmp    800c3e <memcmp+0x35>
	}

	return 0;
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c4b:	89 c2                	mov    %eax,%edx
  800c4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c50:	39 d0                	cmp    %edx,%eax
  800c52:	73 09                	jae    800c5d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c54:	38 08                	cmp    %cl,(%eax)
  800c56:	74 05                	je     800c5d <memfind+0x1b>
	for (; s < ends; s++)
  800c58:	83 c0 01             	add    $0x1,%eax
  800c5b:	eb f3                	jmp    800c50 <memfind+0xe>
			break;
	return (void *) s;
}
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6b:	eb 03                	jmp    800c70 <strtol+0x11>
		s++;
  800c6d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c70:	0f b6 01             	movzbl (%ecx),%eax
  800c73:	3c 20                	cmp    $0x20,%al
  800c75:	74 f6                	je     800c6d <strtol+0xe>
  800c77:	3c 09                	cmp    $0x9,%al
  800c79:	74 f2                	je     800c6d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c7b:	3c 2b                	cmp    $0x2b,%al
  800c7d:	74 2e                	je     800cad <strtol+0x4e>
	int neg = 0;
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c84:	3c 2d                	cmp    $0x2d,%al
  800c86:	74 2f                	je     800cb7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c8e:	75 05                	jne    800c95 <strtol+0x36>
  800c90:	80 39 30             	cmpb   $0x30,(%ecx)
  800c93:	74 2c                	je     800cc1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c95:	85 db                	test   %ebx,%ebx
  800c97:	75 0a                	jne    800ca3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c99:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca1:	74 28                	je     800ccb <strtol+0x6c>
		base = 10;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cab:	eb 50                	jmp    800cfd <strtol+0x9e>
		s++;
  800cad:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb5:	eb d1                	jmp    800c88 <strtol+0x29>
		s++, neg = 1;
  800cb7:	83 c1 01             	add    $0x1,%ecx
  800cba:	bf 01 00 00 00       	mov    $0x1,%edi
  800cbf:	eb c7                	jmp    800c88 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc5:	74 0e                	je     800cd5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cc7:	85 db                	test   %ebx,%ebx
  800cc9:	75 d8                	jne    800ca3 <strtol+0x44>
		s++, base = 8;
  800ccb:	83 c1 01             	add    $0x1,%ecx
  800cce:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cd3:	eb ce                	jmp    800ca3 <strtol+0x44>
		s += 2, base = 16;
  800cd5:	83 c1 02             	add    $0x2,%ecx
  800cd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdd:	eb c4                	jmp    800ca3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cdf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce2:	89 f3                	mov    %esi,%ebx
  800ce4:	80 fb 19             	cmp    $0x19,%bl
  800ce7:	77 29                	ja     800d12 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ce9:	0f be d2             	movsbl %dl,%edx
  800cec:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cef:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf2:	7d 30                	jge    800d24 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cf4:	83 c1 01             	add    $0x1,%ecx
  800cf7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cfb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cfd:	0f b6 11             	movzbl (%ecx),%edx
  800d00:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d03:	89 f3                	mov    %esi,%ebx
  800d05:	80 fb 09             	cmp    $0x9,%bl
  800d08:	77 d5                	ja     800cdf <strtol+0x80>
			dig = *s - '0';
  800d0a:	0f be d2             	movsbl %dl,%edx
  800d0d:	83 ea 30             	sub    $0x30,%edx
  800d10:	eb dd                	jmp    800cef <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d12:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d15:	89 f3                	mov    %esi,%ebx
  800d17:	80 fb 19             	cmp    $0x19,%bl
  800d1a:	77 08                	ja     800d24 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d1c:	0f be d2             	movsbl %dl,%edx
  800d1f:	83 ea 37             	sub    $0x37,%edx
  800d22:	eb cb                	jmp    800cef <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d28:	74 05                	je     800d2f <strtol+0xd0>
		*endptr = (char *) s;
  800d2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	f7 da                	neg    %edx
  800d33:	85 ff                	test   %edi,%edi
  800d35:	0f 45 c2             	cmovne %edx,%eax
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
  800d3d:	66 90                	xchg   %ax,%ax
  800d3f:	90                   	nop

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
