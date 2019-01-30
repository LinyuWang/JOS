
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 67 00 00 00       	call   8000a9 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800059:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80005c:	e8 c6 00 00 00       	call   800127 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x37>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 42 00 00 00       	call   8000e6 <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7f 08                	jg     800110 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	50                   	push   %eax
  800114:	6a 03                	push   $0x3
  800116:	68 aa 0f 80 00       	push   $0x800faa
  80011b:	6a 23                	push   $0x23
  80011d:	68 c7 0f 80 00       	push   $0x800fc7
  800122:	e8 ed 01 00 00       	call   800314 <_panic>

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 0a 00 00 00       	mov    $0xa,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016e:	be 00 00 00 00       	mov    $0x0,%esi
  800173:	8b 55 08             	mov    0x8(%ebp),%edx
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	b8 04 00 00 00       	mov    $0x4,%eax
  80017e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800181:	89 f7                	mov    %esi,%edi
  800183:	cd 30                	int    $0x30
	if(check && ret > 0)
  800185:	85 c0                	test   %eax,%eax
  800187:	7f 08                	jg     800191 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	6a 04                	push   $0x4
  800197:	68 aa 0f 80 00       	push   $0x800faa
  80019c:	6a 23                	push   $0x23
  80019e:	68 c7 0f 80 00       	push   $0x800fc7
  8001a3:	e8 6c 01 00 00       	call   800314 <_panic>

008001a8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	7f 08                	jg     8001d3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	50                   	push   %eax
  8001d7:	6a 05                	push   $0x5
  8001d9:	68 aa 0f 80 00       	push   $0x800faa
  8001de:	6a 23                	push   $0x23
  8001e0:	68 c7 0f 80 00       	push   $0x800fc7
  8001e5:	e8 2a 01 00 00       	call   800314 <_panic>

008001ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	57                   	push   %edi
  8001ee:	56                   	push   %esi
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	b8 06 00 00 00       	mov    $0x6,%eax
  800203:	89 df                	mov    %ebx,%edi
  800205:	89 de                	mov    %ebx,%esi
  800207:	cd 30                	int    $0x30
	if(check && ret > 0)
  800209:	85 c0                	test   %eax,%eax
  80020b:	7f 08                	jg     800215 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	6a 06                	push   $0x6
  80021b:	68 aa 0f 80 00       	push   $0x800faa
  800220:	6a 23                	push   $0x23
  800222:	68 c7 0f 80 00       	push   $0x800fc7
  800227:	e8 e8 00 00 00       	call   800314 <_panic>

0080022c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	b8 08 00 00 00       	mov    $0x8,%eax
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7f 08                	jg     800257 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	50                   	push   %eax
  80025b:	6a 08                	push   $0x8
  80025d:	68 aa 0f 80 00       	push   $0x800faa
  800262:	6a 23                	push   $0x23
  800264:	68 c7 0f 80 00       	push   $0x800fc7
  800269:	e8 a6 00 00 00       	call   800314 <_panic>

0080026e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800277:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	b8 09 00 00 00       	mov    $0x9,%eax
  800287:	89 df                	mov    %ebx,%edi
  800289:	89 de                	mov    %ebx,%esi
  80028b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028d:	85 c0                	test   %eax,%eax
  80028f:	7f 08                	jg     800299 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	50                   	push   %eax
  80029d:	6a 09                	push   $0x9
  80029f:	68 aa 0f 80 00       	push   $0x800faa
  8002a4:	6a 23                	push   $0x23
  8002a6:	68 c7 0f 80 00       	push   $0x800fc7
  8002ab:	e8 64 00 00 00       	call   800314 <_panic>

008002b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c1:	be 00 00 00 00       	mov    $0x0,%esi
  8002c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cc:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	89 cb                	mov    %ecx,%ebx
  8002eb:	89 cf                	mov    %ecx,%edi
  8002ed:	89 ce                	mov    %ecx,%esi
  8002ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7f 08                	jg     8002fd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	50                   	push   %eax
  800301:	6a 0c                	push   $0xc
  800303:	68 aa 0f 80 00       	push   $0x800faa
  800308:	6a 23                	push   $0x23
  80030a:	68 c7 0f 80 00       	push   $0x800fc7
  80030f:	e8 00 00 00 00       	call   800314 <_panic>

00800314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800322:	e8 00 fe ff ff       	call   800127 <sys_getenvid>
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	56                   	push   %esi
  800331:	50                   	push   %eax
  800332:	68 d8 0f 80 00       	push   $0x800fd8
  800337:	e8 b3 00 00 00       	call   8003ef <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	53                   	push   %ebx
  800340:	ff 75 10             	pushl  0x10(%ebp)
  800343:	e8 56 00 00 00       	call   80039e <vcprintf>
	cprintf("\n");
  800348:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  80034f:	e8 9b 00 00 00       	call   8003ef <cprintf>
  800354:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800357:	cc                   	int3   
  800358:	eb fd                	jmp    800357 <_panic+0x43>

0080035a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	53                   	push   %ebx
  80035e:	83 ec 04             	sub    $0x4,%esp
  800361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800364:	8b 13                	mov    (%ebx),%edx
  800366:	8d 42 01             	lea    0x1(%edx),%eax
  800369:	89 03                	mov    %eax,(%ebx)
  80036b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800372:	3d ff 00 00 00       	cmp    $0xff,%eax
  800377:	74 09                	je     800382 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800379:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800380:	c9                   	leave  
  800381:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	68 ff 00 00 00       	push   $0xff
  80038a:	8d 43 08             	lea    0x8(%ebx),%eax
  80038d:	50                   	push   %eax
  80038e:	e8 16 fd ff ff       	call   8000a9 <sys_cputs>
		b->idx = 0;
  800393:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	eb db                	jmp    800379 <putch+0x1f>

0080039e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ae:	00 00 00 
	b.cnt = 0;
  8003b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003bb:	ff 75 0c             	pushl  0xc(%ebp)
  8003be:	ff 75 08             	pushl  0x8(%ebp)
  8003c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c7:	50                   	push   %eax
  8003c8:	68 5a 03 80 00       	push   $0x80035a
  8003cd:	e8 1a 01 00 00       	call   8004ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d2:	83 c4 08             	add    $0x8,%esp
  8003d5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e1:	50                   	push   %eax
  8003e2:	e8 c2 fc ff ff       	call   8000a9 <sys_cputs>

	return b.cnt;
}
  8003e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    

008003ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 08             	pushl  0x8(%ebp)
  8003fc:	e8 9d ff ff ff       	call   80039e <vcprintf>
	va_end(ap);

	return cnt;
}
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	83 ec 1c             	sub    $0x1c,%esp
  80040c:	89 c7                	mov    %eax,%edi
  80040e:	89 d6                	mov    %edx,%esi
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	8b 55 0c             	mov    0xc(%ebp),%edx
  800416:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800419:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800424:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800427:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042a:	39 d3                	cmp    %edx,%ebx
  80042c:	72 05                	jb     800433 <printnum+0x30>
  80042e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800431:	77 7a                	ja     8004ad <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	ff 75 18             	pushl  0x18(%ebp)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043f:	53                   	push   %ebx
  800440:	ff 75 10             	pushl  0x10(%ebp)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	ff 75 e4             	pushl  -0x1c(%ebp)
  800449:	ff 75 e0             	pushl  -0x20(%ebp)
  80044c:	ff 75 dc             	pushl  -0x24(%ebp)
  80044f:	ff 75 d8             	pushl  -0x28(%ebp)
  800452:	e8 f9 08 00 00       	call   800d50 <__udivdi3>
  800457:	83 c4 18             	add    $0x18,%esp
  80045a:	52                   	push   %edx
  80045b:	50                   	push   %eax
  80045c:	89 f2                	mov    %esi,%edx
  80045e:	89 f8                	mov    %edi,%eax
  800460:	e8 9e ff ff ff       	call   800403 <printnum>
  800465:	83 c4 20             	add    $0x20,%esp
  800468:	eb 13                	jmp    80047d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	56                   	push   %esi
  80046e:	ff 75 18             	pushl  0x18(%ebp)
  800471:	ff d7                	call   *%edi
  800473:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f ed                	jg     80046a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	e8 db 09 00 00       	call   800e70 <__umoddi3>
  800495:	83 c4 14             	add    $0x14,%esp
  800498:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff d7                	call   *%edi
}
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a8:	5b                   	pop    %ebx
  8004a9:	5e                   	pop    %esi
  8004aa:	5f                   	pop    %edi
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    
  8004ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b0:	eb c4                	jmp    800476 <printnum+0x73>

008004b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bc:	8b 10                	mov    (%eax),%edx
  8004be:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c1:	73 0a                	jae    8004cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cb:	88 02                	mov    %al,(%edx)
}
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    

008004cf <printfmt>:
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d8:	50                   	push   %eax
  8004d9:	ff 75 10             	pushl  0x10(%ebp)
  8004dc:	ff 75 0c             	pushl  0xc(%ebp)
  8004df:	ff 75 08             	pushl  0x8(%ebp)
  8004e2:	e8 05 00 00 00       	call   8004ec <vprintfmt>
}
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <vprintfmt>:
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 2c             	sub    $0x2c,%esp
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fe:	e9 63 03 00 00       	jmp    800866 <vprintfmt+0x37a>
		padc = ' ';
  800503:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800507:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80050e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800515:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80051c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8d 47 01             	lea    0x1(%edi),%eax
  800524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800527:	0f b6 17             	movzbl (%edi),%edx
  80052a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052d:	3c 55                	cmp    $0x55,%al
  80052f:	0f 87 11 04 00 00    	ja     800946 <vprintfmt+0x45a>
  800535:	0f b6 c0             	movzbl %al,%eax
  800538:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800542:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800546:	eb d9                	jmp    800521 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80054b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054f:	eb d0                	jmp    800521 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800551:	0f b6 d2             	movzbl %dl,%edx
  800554:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
  80055c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800562:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800566:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800569:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056c:	83 f9 09             	cmp    $0x9,%ecx
  80056f:	77 55                	ja     8005c6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800571:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800574:	eb e9                	jmp    80055f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80058a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058e:	79 91                	jns    800521 <vprintfmt+0x35>
				width = precision, precision = -1;
  800590:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059d:	eb 82                	jmp    800521 <vprintfmt+0x35>
  80059f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a9:	0f 49 d0             	cmovns %eax,%edx
  8005ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	e9 6a ff ff ff       	jmp    800521 <vprintfmt+0x35>
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c1:	e9 5b ff ff ff       	jmp    800521 <vprintfmt+0x35>
  8005c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005cc:	eb bc                	jmp    80058a <vprintfmt+0x9e>
			lflag++;
  8005ce:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d4:	e9 48 ff ff ff       	jmp    800521 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 78 04             	lea    0x4(%eax),%edi
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	ff 30                	pushl  (%eax)
  8005e5:	ff d6                	call   *%esi
			break;
  8005e7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005ea:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ed:	e9 71 02 00 00       	jmp    800863 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 78 04             	lea    0x4(%eax),%edi
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	99                   	cltd   
  8005fb:	31 d0                	xor    %edx,%eax
  8005fd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ff:	83 f8 08             	cmp    $0x8,%eax
  800602:	7f 23                	jg     800627 <vprintfmt+0x13b>
  800604:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	74 18                	je     800627 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80060f:	52                   	push   %edx
  800610:	68 1f 10 80 00       	push   $0x80101f
  800615:	53                   	push   %ebx
  800616:	56                   	push   %esi
  800617:	e8 b3 fe ff ff       	call   8004cf <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800622:	e9 3c 02 00 00       	jmp    800863 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800627:	50                   	push   %eax
  800628:	68 16 10 80 00       	push   $0x801016
  80062d:	53                   	push   %ebx
  80062e:	56                   	push   %esi
  80062f:	e8 9b fe ff ff       	call   8004cf <printfmt>
  800634:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800637:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80063a:	e9 24 02 00 00       	jmp    800863 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	83 c0 04             	add    $0x4,%eax
  800645:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80064d:	85 ff                	test   %edi,%edi
  80064f:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  800654:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800657:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065b:	0f 8e bd 00 00 00    	jle    80071e <vprintfmt+0x232>
  800661:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800665:	75 0e                	jne    800675 <vprintfmt+0x189>
  800667:	89 75 08             	mov    %esi,0x8(%ebp)
  80066a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800670:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800673:	eb 6d                	jmp    8006e2 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	ff 75 d0             	pushl  -0x30(%ebp)
  80067b:	57                   	push   %edi
  80067c:	e8 6d 03 00 00       	call   8009ee <strnlen>
  800681:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800684:	29 c1                	sub    %eax,%ecx
  800686:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800689:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800690:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800693:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800696:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800698:	eb 0f                	jmp    8006a9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	83 ef 01             	sub    $0x1,%edi
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	85 ff                	test   %edi,%edi
  8006ab:	7f ed                	jg     80069a <vprintfmt+0x1ae>
  8006ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ba:	0f 49 c1             	cmovns %ecx,%eax
  8006bd:	29 c1                	sub    %eax,%ecx
  8006bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c8:	89 cb                	mov    %ecx,%ebx
  8006ca:	eb 16                	jmp    8006e2 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d0:	75 31                	jne    800703 <vprintfmt+0x217>
					putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	50                   	push   %eax
  8006d9:	ff 55 08             	call   *0x8(%ebp)
  8006dc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006df:	83 eb 01             	sub    $0x1,%ebx
  8006e2:	83 c7 01             	add    $0x1,%edi
  8006e5:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006e9:	0f be c2             	movsbl %dl,%eax
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 59                	je     800749 <vprintfmt+0x25d>
  8006f0:	85 f6                	test   %esi,%esi
  8006f2:	78 d8                	js     8006cc <vprintfmt+0x1e0>
  8006f4:	83 ee 01             	sub    $0x1,%esi
  8006f7:	79 d3                	jns    8006cc <vprintfmt+0x1e0>
  8006f9:	89 df                	mov    %ebx,%edi
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800701:	eb 37                	jmp    80073a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800703:	0f be d2             	movsbl %dl,%edx
  800706:	83 ea 20             	sub    $0x20,%edx
  800709:	83 fa 5e             	cmp    $0x5e,%edx
  80070c:	76 c4                	jbe    8006d2 <vprintfmt+0x1e6>
					putch('?', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	6a 3f                	push   $0x3f
  800716:	ff 55 08             	call   *0x8(%ebp)
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb c1                	jmp    8006df <vprintfmt+0x1f3>
  80071e:	89 75 08             	mov    %esi,0x8(%ebp)
  800721:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800724:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800727:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072a:	eb b6                	jmp    8006e2 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 20                	push   $0x20
  800732:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800734:	83 ef 01             	sub    $0x1,%edi
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	85 ff                	test   %edi,%edi
  80073c:	7f ee                	jg     80072c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80073e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
  800744:	e9 1a 01 00 00       	jmp    800863 <vprintfmt+0x377>
  800749:	89 df                	mov    %ebx,%edi
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800751:	eb e7                	jmp    80073a <vprintfmt+0x24e>
	if (lflag >= 2)
  800753:	83 f9 01             	cmp    $0x1,%ecx
  800756:	7e 3f                	jle    800797 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 50 04             	mov    0x4(%eax),%edx
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800763:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 40 08             	lea    0x8(%eax),%eax
  80076c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80076f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800773:	79 5c                	jns    8007d1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 2d                	push   $0x2d
  80077b:	ff d6                	call   *%esi
				num = -(long long) num;
  80077d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800780:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800783:	f7 da                	neg    %edx
  800785:	83 d1 00             	adc    $0x0,%ecx
  800788:	f7 d9                	neg    %ecx
  80078a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80078d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800792:	e9 b2 00 00 00       	jmp    800849 <vprintfmt+0x35d>
	else if (lflag)
  800797:	85 c9                	test   %ecx,%ecx
  800799:	75 1b                	jne    8007b6 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a3:	89 c1                	mov    %eax,%ecx
  8007a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b4:	eb b9                	jmp    80076f <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007be:	89 c1                	mov    %eax,%ecx
  8007c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 40 04             	lea    0x4(%eax),%eax
  8007cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cf:	eb 9e                	jmp    80076f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dc:	eb 6b                	jmp    800849 <vprintfmt+0x35d>
	if (lflag >= 2)
  8007de:	83 f9 01             	cmp    $0x1,%ecx
  8007e1:	7e 15                	jle    8007f8 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007eb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f6:	eb 51                	jmp    800849 <vprintfmt+0x35d>
	else if (lflag)
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	75 17                	jne    800813 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800811:	eb 36                	jmp    800849 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 10                	mov    (%eax),%edx
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081d:	8d 40 04             	lea    0x4(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800823:	b8 0a 00 00 00       	mov    $0xa,%eax
  800828:	eb 1f                	jmp    800849 <vprintfmt+0x35d>
	if (lflag >= 2)
  80082a:	83 f9 01             	cmp    $0x1,%ecx
  80082d:	7e 5b                	jle    80088a <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8b 50 04             	mov    0x4(%eax),%edx
  800835:	8b 00                	mov    (%eax),%eax
  800837:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80083a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80083d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800840:	89 d1                	mov    %edx,%ecx
  800842:	89 c2                	mov    %eax,%edx
			base = 8;
  800844:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800849:	83 ec 0c             	sub    $0xc,%esp
  80084c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800850:	57                   	push   %edi
  800851:	ff 75 e0             	pushl  -0x20(%ebp)
  800854:	50                   	push   %eax
  800855:	51                   	push   %ecx
  800856:	52                   	push   %edx
  800857:	89 da                	mov    %ebx,%edx
  800859:	89 f0                	mov    %esi,%eax
  80085b:	e8 a3 fb ff ff       	call   800403 <printnum>
			break;
  800860:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800866:	83 c7 01             	add    $0x1,%edi
  800869:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80086d:	83 f8 25             	cmp    $0x25,%eax
  800870:	0f 84 8d fc ff ff    	je     800503 <vprintfmt+0x17>
			if (ch == '\0')
  800876:	85 c0                	test   %eax,%eax
  800878:	0f 84 e8 00 00 00    	je     800966 <vprintfmt+0x47a>
			putch(ch, putdat);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	50                   	push   %eax
  800883:	ff d6                	call   *%esi
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	eb dc                	jmp    800866 <vprintfmt+0x37a>
	else if (lflag)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	75 13                	jne    8008a1 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8b 10                	mov    (%eax),%edx
  800893:	89 d0                	mov    %edx,%eax
  800895:	99                   	cltd   
  800896:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800899:	8d 49 04             	lea    0x4(%ecx),%ecx
  80089c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089f:	eb 9f                	jmp    800840 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8b 10                	mov    (%eax),%edx
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	99                   	cltd   
  8008a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ac:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b2:	eb 8c                	jmp    800840 <vprintfmt+0x354>
			putch('0', putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	6a 30                	push   $0x30
  8008ba:	ff d6                	call   *%esi
			putch('x', putdat);
  8008bc:	83 c4 08             	add    $0x8,%esp
  8008bf:	53                   	push   %ebx
  8008c0:	6a 78                	push   $0x78
  8008c2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8b 10                	mov    (%eax),%edx
  8008c9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008ce:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008d1:	8d 40 04             	lea    0x4(%eax),%eax
  8008d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008dc:	e9 68 ff ff ff       	jmp    800849 <vprintfmt+0x35d>
	if (lflag >= 2)
  8008e1:	83 f9 01             	cmp    $0x1,%ecx
  8008e4:	7e 18                	jle    8008fe <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8b 10                	mov    (%eax),%edx
  8008eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ee:	8d 40 08             	lea    0x8(%eax),%eax
  8008f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f9:	e9 4b ff ff ff       	jmp    800849 <vprintfmt+0x35d>
	else if (lflag)
  8008fe:	85 c9                	test   %ecx,%ecx
  800900:	75 1a                	jne    80091c <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8b 10                	mov    (%eax),%edx
  800907:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090c:	8d 40 04             	lea    0x4(%eax),%eax
  80090f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800912:	b8 10 00 00 00       	mov    $0x10,%eax
  800917:	e9 2d ff ff ff       	jmp    800849 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8b 10                	mov    (%eax),%edx
  800921:	b9 00 00 00 00       	mov    $0x0,%ecx
  800926:	8d 40 04             	lea    0x4(%eax),%eax
  800929:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092c:	b8 10 00 00 00       	mov    $0x10,%eax
  800931:	e9 13 ff ff ff       	jmp    800849 <vprintfmt+0x35d>
			putch(ch, putdat);
  800936:	83 ec 08             	sub    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 25                	push   $0x25
  80093c:	ff d6                	call   *%esi
			break;
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	e9 1d ff ff ff       	jmp    800863 <vprintfmt+0x377>
			putch('%', putdat);
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	53                   	push   %ebx
  80094a:	6a 25                	push   $0x25
  80094c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	89 f8                	mov    %edi,%eax
  800953:	eb 03                	jmp    800958 <vprintfmt+0x46c>
  800955:	83 e8 01             	sub    $0x1,%eax
  800958:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095c:	75 f7                	jne    800955 <vprintfmt+0x469>
  80095e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800961:	e9 fd fe ff ff       	jmp    800863 <vprintfmt+0x377>
}
  800966:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 18             	sub    $0x18,%esp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800981:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800984:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098b:	85 c0                	test   %eax,%eax
  80098d:	74 26                	je     8009b5 <vsnprintf+0x47>
  80098f:	85 d2                	test   %edx,%edx
  800991:	7e 22                	jle    8009b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	ff 75 14             	pushl  0x14(%ebp)
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099c:	50                   	push   %eax
  80099d:	68 b2 04 80 00       	push   $0x8004b2
  8009a2:	e8 45 fb ff ff       	call   8004ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b0:	83 c4 10             	add    $0x10,%esp
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    
		return -E_INVAL;
  8009b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ba:	eb f7                	jmp    8009b3 <vsnprintf+0x45>

008009bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c5:	50                   	push   %eax
  8009c6:	ff 75 10             	pushl  0x10(%ebp)
  8009c9:	ff 75 0c             	pushl  0xc(%ebp)
  8009cc:	ff 75 08             	pushl  0x8(%ebp)
  8009cf:	e8 9a ff ff ff       	call   80096e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	eb 03                	jmp    8009e6 <strlen+0x10>
		n++;
  8009e3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ea:	75 f7                	jne    8009e3 <strlen+0xd>
	return n;
}
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb 03                	jmp    800a01 <strnlen+0x13>
		n++;
  8009fe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	74 06                	je     800a0b <strnlen+0x1d>
  800a05:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a09:	75 f3                	jne    8009fe <strnlen+0x10>
	return n;
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	53                   	push   %ebx
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a17:	89 c2                	mov    %eax,%edx
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	83 c2 01             	add    $0x1,%edx
  800a1f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a23:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a26:	84 db                	test   %bl,%bl
  800a28:	75 ef                	jne    800a19 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a34:	53                   	push   %ebx
  800a35:	e8 9c ff ff ff       	call   8009d6 <strlen>
  800a3a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a3d:	ff 75 0c             	pushl  0xc(%ebp)
  800a40:	01 d8                	add    %ebx,%eax
  800a42:	50                   	push   %eax
  800a43:	e8 c5 ff ff ff       	call   800a0d <strcpy>
	return dst;
}
  800a48:	89 d8                	mov    %ebx,%eax
  800a4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a5f:	89 f2                	mov    %esi,%edx
  800a61:	eb 0f                	jmp    800a72 <strncpy+0x23>
		*dst++ = *src;
  800a63:	83 c2 01             	add    $0x1,%edx
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a6c:	80 39 01             	cmpb   $0x1,(%ecx)
  800a6f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a72:	39 da                	cmp    %ebx,%edx
  800a74:	75 ed                	jne    800a63 <strncpy+0x14>
	}
	return ret;
}
  800a76:	89 f0                	mov    %esi,%eax
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 08             	mov    0x8(%ebp),%esi
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	75 0b                	jne    800a9f <strlcpy+0x23>
  800a94:	eb 17                	jmp    800aad <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a9f:	39 d8                	cmp    %ebx,%eax
  800aa1:	74 07                	je     800aaa <strlcpy+0x2e>
  800aa3:	0f b6 0a             	movzbl (%edx),%ecx
  800aa6:	84 c9                	test   %cl,%cl
  800aa8:	75 ec                	jne    800a96 <strlcpy+0x1a>
		*dst = '\0';
  800aaa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aad:	29 f0                	sub    %esi,%eax
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800abc:	eb 06                	jmp    800ac4 <strcmp+0x11>
		p++, q++;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ac4:	0f b6 01             	movzbl (%ecx),%eax
  800ac7:	84 c0                	test   %al,%al
  800ac9:	74 04                	je     800acf <strcmp+0x1c>
  800acb:	3a 02                	cmp    (%edx),%al
  800acd:	74 ef                	je     800abe <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800acf:	0f b6 c0             	movzbl %al,%eax
  800ad2:	0f b6 12             	movzbl (%edx),%edx
  800ad5:	29 d0                	sub    %edx,%eax
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae8:	eb 06                	jmp    800af0 <strncmp+0x17>
		n--, p++, q++;
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800af0:	39 d8                	cmp    %ebx,%eax
  800af2:	74 16                	je     800b0a <strncmp+0x31>
  800af4:	0f b6 08             	movzbl (%eax),%ecx
  800af7:	84 c9                	test   %cl,%cl
  800af9:	74 04                	je     800aff <strncmp+0x26>
  800afb:	3a 0a                	cmp    (%edx),%cl
  800afd:	74 eb                	je     800aea <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aff:	0f b6 00             	movzbl (%eax),%eax
  800b02:	0f b6 12             	movzbl (%edx),%edx
  800b05:	29 d0                	sub    %edx,%eax
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    
		return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	eb f6                	jmp    800b07 <strncmp+0x2e>

00800b11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1b:	0f b6 10             	movzbl (%eax),%edx
  800b1e:	84 d2                	test   %dl,%dl
  800b20:	74 09                	je     800b2b <strchr+0x1a>
		if (*s == c)
  800b22:	38 ca                	cmp    %cl,%dl
  800b24:	74 0a                	je     800b30 <strchr+0x1f>
	for (; *s; s++)
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	eb f0                	jmp    800b1b <strchr+0xa>
			return (char *) s;
	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3c:	eb 03                	jmp    800b41 <strfind+0xf>
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b44:	38 ca                	cmp    %cl,%dl
  800b46:	74 04                	je     800b4c <strfind+0x1a>
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	75 f2                	jne    800b3e <strfind+0xc>
			break;
	return (char *) s;
}
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b5a:	85 c9                	test   %ecx,%ecx
  800b5c:	74 13                	je     800b71 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b64:	75 05                	jne    800b6b <memset+0x1d>
  800b66:	f6 c1 03             	test   $0x3,%cl
  800b69:	74 0d                	je     800b78 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	fc                   	cld    
  800b6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b71:	89 f8                	mov    %edi,%eax
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
		c &= 0xFF;
  800b78:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	c1 e3 08             	shl    $0x8,%ebx
  800b81:	89 d0                	mov    %edx,%eax
  800b83:	c1 e0 18             	shl    $0x18,%eax
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	c1 e6 10             	shl    $0x10,%esi
  800b8b:	09 f0                	or     %esi,%eax
  800b8d:	09 c2                	or     %eax,%edx
  800b8f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b91:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b94:	89 d0                	mov    %edx,%eax
  800b96:	fc                   	cld    
  800b97:	f3 ab                	rep stos %eax,%es:(%edi)
  800b99:	eb d6                	jmp    800b71 <memset+0x23>

00800b9b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba9:	39 c6                	cmp    %eax,%esi
  800bab:	73 35                	jae    800be2 <memmove+0x47>
  800bad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb0:	39 c2                	cmp    %eax,%edx
  800bb2:	76 2e                	jbe    800be2 <memmove+0x47>
		s += n;
		d += n;
  800bb4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	09 fe                	or     %edi,%esi
  800bbb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bc1:	74 0c                	je     800bcf <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bc3:	83 ef 01             	sub    $0x1,%edi
  800bc6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc9:	fd                   	std    
  800bca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bcc:	fc                   	cld    
  800bcd:	eb 21                	jmp    800bf0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcf:	f6 c1 03             	test   $0x3,%cl
  800bd2:	75 ef                	jne    800bc3 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd4:	83 ef 04             	sub    $0x4,%edi
  800bd7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bda:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bdd:	fd                   	std    
  800bde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be0:	eb ea                	jmp    800bcc <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be2:	89 f2                	mov    %esi,%edx
  800be4:	09 c2                	or     %eax,%edx
  800be6:	f6 c2 03             	test   $0x3,%dl
  800be9:	74 09                	je     800bf4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	fc                   	cld    
  800bee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf4:	f6 c1 03             	test   $0x3,%cl
  800bf7:	75 f2                	jne    800beb <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	fc                   	cld    
  800bff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c01:	eb ed                	jmp    800bf0 <memmove+0x55>

00800c03 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	ff 75 08             	pushl  0x8(%ebp)
  800c0f:	e8 87 ff ff ff       	call   800b9b <memmove>
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c21:	89 c6                	mov    %eax,%esi
  800c23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c26:	39 f0                	cmp    %esi,%eax
  800c28:	74 1c                	je     800c46 <memcmp+0x30>
		if (*s1 != *s2)
  800c2a:	0f b6 08             	movzbl (%eax),%ecx
  800c2d:	0f b6 1a             	movzbl (%edx),%ebx
  800c30:	38 d9                	cmp    %bl,%cl
  800c32:	75 08                	jne    800c3c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c34:	83 c0 01             	add    $0x1,%eax
  800c37:	83 c2 01             	add    $0x1,%edx
  800c3a:	eb ea                	jmp    800c26 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c3c:	0f b6 c1             	movzbl %cl,%eax
  800c3f:	0f b6 db             	movzbl %bl,%ebx
  800c42:	29 d8                	sub    %ebx,%eax
  800c44:	eb 05                	jmp    800c4b <memcmp+0x35>
	}

	return 0;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c58:	89 c2                	mov    %eax,%edx
  800c5a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c5d:	39 d0                	cmp    %edx,%eax
  800c5f:	73 09                	jae    800c6a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c61:	38 08                	cmp    %cl,(%eax)
  800c63:	74 05                	je     800c6a <memfind+0x1b>
	for (; s < ends; s++)
  800c65:	83 c0 01             	add    $0x1,%eax
  800c68:	eb f3                	jmp    800c5d <memfind+0xe>
			break;
	return (void *) s;
}
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c78:	eb 03                	jmp    800c7d <strtol+0x11>
		s++;
  800c7a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c7d:	0f b6 01             	movzbl (%ecx),%eax
  800c80:	3c 20                	cmp    $0x20,%al
  800c82:	74 f6                	je     800c7a <strtol+0xe>
  800c84:	3c 09                	cmp    $0x9,%al
  800c86:	74 f2                	je     800c7a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c88:	3c 2b                	cmp    $0x2b,%al
  800c8a:	74 2e                	je     800cba <strtol+0x4e>
	int neg = 0;
  800c8c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c91:	3c 2d                	cmp    $0x2d,%al
  800c93:	74 2f                	je     800cc4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c9b:	75 05                	jne    800ca2 <strtol+0x36>
  800c9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca0:	74 2c                	je     800cce <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca2:	85 db                	test   %ebx,%ebx
  800ca4:	75 0a                	jne    800cb0 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca6:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cab:	80 39 30             	cmpb   $0x30,(%ecx)
  800cae:	74 28                	je     800cd8 <strtol+0x6c>
		base = 10;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cb8:	eb 50                	jmp    800d0a <strtol+0x9e>
		s++;
  800cba:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cbd:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc2:	eb d1                	jmp    800c95 <strtol+0x29>
		s++, neg = 1;
  800cc4:	83 c1 01             	add    $0x1,%ecx
  800cc7:	bf 01 00 00 00       	mov    $0x1,%edi
  800ccc:	eb c7                	jmp    800c95 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd2:	74 0e                	je     800ce2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cd4:	85 db                	test   %ebx,%ebx
  800cd6:	75 d8                	jne    800cb0 <strtol+0x44>
		s++, base = 8;
  800cd8:	83 c1 01             	add    $0x1,%ecx
  800cdb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ce0:	eb ce                	jmp    800cb0 <strtol+0x44>
		s += 2, base = 16;
  800ce2:	83 c1 02             	add    $0x2,%ecx
  800ce5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cea:	eb c4                	jmp    800cb0 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cec:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cef:	89 f3                	mov    %esi,%ebx
  800cf1:	80 fb 19             	cmp    $0x19,%bl
  800cf4:	77 29                	ja     800d1f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cf6:	0f be d2             	movsbl %dl,%edx
  800cf9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cfc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cff:	7d 30                	jge    800d31 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d01:	83 c1 01             	add    $0x1,%ecx
  800d04:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d08:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d0a:	0f b6 11             	movzbl (%ecx),%edx
  800d0d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d10:	89 f3                	mov    %esi,%ebx
  800d12:	80 fb 09             	cmp    $0x9,%bl
  800d15:	77 d5                	ja     800cec <strtol+0x80>
			dig = *s - '0';
  800d17:	0f be d2             	movsbl %dl,%edx
  800d1a:	83 ea 30             	sub    $0x30,%edx
  800d1d:	eb dd                	jmp    800cfc <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d22:	89 f3                	mov    %esi,%ebx
  800d24:	80 fb 19             	cmp    $0x19,%bl
  800d27:	77 08                	ja     800d31 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d29:	0f be d2             	movsbl %dl,%edx
  800d2c:	83 ea 37             	sub    $0x37,%edx
  800d2f:	eb cb                	jmp    800cfc <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d35:	74 05                	je     800d3c <strtol+0xd0>
		*endptr = (char *) s;
  800d37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	f7 da                	neg    %edx
  800d40:	85 ff                	test   %edi,%edi
  800d42:	0f 45 c2             	cmovne %edx,%eax
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

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
