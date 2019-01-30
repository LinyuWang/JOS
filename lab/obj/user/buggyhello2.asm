
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 67 00 00 00       	call   8000b0 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800060:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800063:	e8 c6 00 00 00       	call   80012e <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7f 08                	jg     800117 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	50                   	push   %eax
  80011b:	6a 03                	push   $0x3
  80011d:	68 b8 0f 80 00       	push   $0x800fb8
  800122:	6a 23                	push   $0x23
  800124:	68 d5 0f 80 00       	push   $0x800fd5
  800129:	e8 ed 01 00 00       	call   80031b <_panic>

0080012e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_yield>:

void
sys_yield(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800175:	be 00 00 00 00       	mov    $0x0,%esi
  80017a:	8b 55 08             	mov    0x8(%ebp),%edx
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	b8 04 00 00 00       	mov    $0x4,%eax
  800185:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800188:	89 f7                	mov    %esi,%edi
  80018a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018c:	85 c0                	test   %eax,%eax
  80018e:	7f 08                	jg     800198 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	50                   	push   %eax
  80019c:	6a 04                	push   $0x4
  80019e:	68 b8 0f 80 00       	push   $0x800fb8
  8001a3:	6a 23                	push   $0x23
  8001a5:	68 d5 0f 80 00       	push   $0x800fd5
  8001aa:	e8 6c 01 00 00       	call   80031b <_panic>

008001af <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	7f 08                	jg     8001da <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	50                   	push   %eax
  8001de:	6a 05                	push   $0x5
  8001e0:	68 b8 0f 80 00       	push   $0x800fb8
  8001e5:	6a 23                	push   $0x23
  8001e7:	68 d5 0f 80 00       	push   $0x800fd5
  8001ec:	e8 2a 01 00 00       	call   80031b <_panic>

008001f1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	89 df                	mov    %ebx,%edi
  80020c:	89 de                	mov    %ebx,%esi
  80020e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7f 08                	jg     80021c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	50                   	push   %eax
  800220:	6a 06                	push   $0x6
  800222:	68 b8 0f 80 00       	push   $0x800fb8
  800227:	6a 23                	push   $0x23
  800229:	68 d5 0f 80 00       	push   $0x800fd5
  80022e:	e8 e8 00 00 00       	call   80031b <_panic>

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	b8 08 00 00 00       	mov    $0x8,%eax
  80024c:	89 df                	mov    %ebx,%edi
  80024e:	89 de                	mov    %ebx,%esi
  800250:	cd 30                	int    $0x30
	if(check && ret > 0)
  800252:	85 c0                	test   %eax,%eax
  800254:	7f 08                	jg     80025e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	50                   	push   %eax
  800262:	6a 08                	push   $0x8
  800264:	68 b8 0f 80 00       	push   $0x800fb8
  800269:	6a 23                	push   $0x23
  80026b:	68 d5 0f 80 00       	push   $0x800fd5
  800270:	e8 a6 00 00 00       	call   80031b <_panic>

00800275 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	89 df                	mov    %ebx,%edi
  800290:	89 de                	mov    %ebx,%esi
  800292:	cd 30                	int    $0x30
	if(check && ret > 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	7f 08                	jg     8002a0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a0:	83 ec 0c             	sub    $0xc,%esp
  8002a3:	50                   	push   %eax
  8002a4:	6a 09                	push   $0x9
  8002a6:	68 b8 0f 80 00       	push   $0x800fb8
  8002ab:	6a 23                	push   $0x23
  8002ad:	68 d5 0f 80 00       	push   $0x800fd5
  8002b2:	e8 64 00 00 00       	call   80031b <_panic>

008002b7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c8:	be 00 00 00 00       	mov    $0x0,%esi
  8002cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f0:	89 cb                	mov    %ecx,%ebx
  8002f2:	89 cf                	mov    %ecx,%edi
  8002f4:	89 ce                	mov    %ecx,%esi
  8002f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	7f 08                	jg     800304 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800304:	83 ec 0c             	sub    $0xc,%esp
  800307:	50                   	push   %eax
  800308:	6a 0c                	push   $0xc
  80030a:	68 b8 0f 80 00       	push   $0x800fb8
  80030f:	6a 23                	push   $0x23
  800311:	68 d5 0f 80 00       	push   $0x800fd5
  800316:	e8 00 00 00 00       	call   80031b <_panic>

0080031b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800323:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800329:	e8 00 fe ff ff       	call   80012e <sys_getenvid>
  80032e:	83 ec 0c             	sub    $0xc,%esp
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	56                   	push   %esi
  800338:	50                   	push   %eax
  800339:	68 e4 0f 80 00       	push   $0x800fe4
  80033e:	e8 b3 00 00 00       	call   8003f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	53                   	push   %ebx
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	e8 56 00 00 00       	call   8003a5 <vcprintf>
	cprintf("\n");
  80034f:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  800356:	e8 9b 00 00 00       	call   8003f6 <cprintf>
  80035b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035e:	cc                   	int3   
  80035f:	eb fd                	jmp    80035e <_panic+0x43>

00800361 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	53                   	push   %ebx
  800365:	83 ec 04             	sub    $0x4,%esp
  800368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036b:	8b 13                	mov    (%ebx),%edx
  80036d:	8d 42 01             	lea    0x1(%edx),%eax
  800370:	89 03                	mov    %eax,(%ebx)
  800372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800375:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800379:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037e:	74 09                	je     800389 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 16 fd ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
  8003a3:	eb db                	jmp    800380 <putch+0x1f>

008003a5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b5:	00 00 00 
	b.cnt = 0;
  8003b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c2:	ff 75 0c             	pushl  0xc(%ebp)
  8003c5:	ff 75 08             	pushl  0x8(%ebp)
  8003c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ce:	50                   	push   %eax
  8003cf:	68 61 03 80 00       	push   $0x800361
  8003d4:	e8 1a 01 00 00       	call   8004f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d9:	83 c4 08             	add    $0x8,%esp
  8003dc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e8:	50                   	push   %eax
  8003e9:	e8 c2 fc ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8003ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ff:	50                   	push   %eax
  800400:	ff 75 08             	pushl  0x8(%ebp)
  800403:	e8 9d ff ff ff       	call   8003a5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 1c             	sub    $0x1c,%esp
  800413:	89 c7                	mov    %eax,%edi
  800415:	89 d6                	mov    %edx,%esi
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800420:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800423:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800431:	39 d3                	cmp    %edx,%ebx
  800433:	72 05                	jb     80043a <printnum+0x30>
  800435:	39 45 10             	cmp    %eax,0x10(%ebp)
  800438:	77 7a                	ja     8004b4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	ff 75 18             	pushl  0x18(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800446:	53                   	push   %ebx
  800447:	ff 75 10             	pushl  0x10(%ebp)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800450:	ff 75 e0             	pushl  -0x20(%ebp)
  800453:	ff 75 dc             	pushl  -0x24(%ebp)
  800456:	ff 75 d8             	pushl  -0x28(%ebp)
  800459:	e8 02 09 00 00       	call   800d60 <__udivdi3>
  80045e:	83 c4 18             	add    $0x18,%esp
  800461:	52                   	push   %edx
  800462:	50                   	push   %eax
  800463:	89 f2                	mov    %esi,%edx
  800465:	89 f8                	mov    %edi,%eax
  800467:	e8 9e ff ff ff       	call   80040a <printnum>
  80046c:	83 c4 20             	add    $0x20,%esp
  80046f:	eb 13                	jmp    800484 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	ff 75 18             	pushl  0x18(%ebp)
  800478:	ff d7                	call   *%edi
  80047a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80047d:	83 eb 01             	sub    $0x1,%ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f ed                	jg     800471 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	56                   	push   %esi
  800488:	83 ec 04             	sub    $0x4,%esp
  80048b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048e:	ff 75 e0             	pushl  -0x20(%ebp)
  800491:	ff 75 dc             	pushl  -0x24(%ebp)
  800494:	ff 75 d8             	pushl  -0x28(%ebp)
  800497:	e8 e4 09 00 00       	call   800e80 <__umoddi3>
  80049c:	83 c4 14             	add    $0x14,%esp
  80049f:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  8004a6:	50                   	push   %eax
  8004a7:	ff d7                	call   *%edi
}
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5f                   	pop    %edi
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    
  8004b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b7:	eb c4                	jmp    80047d <printnum+0x73>

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 0a                	jae    8004d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d2:	88 02                	mov    %al,(%edx)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	50                   	push   %eax
  8004e0:	ff 75 10             	pushl  0x10(%ebp)
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	ff 75 08             	pushl  0x8(%ebp)
  8004e9:	e8 05 00 00 00       	call   8004f3 <vprintfmt>
}
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	c9                   	leave  
  8004f2:	c3                   	ret    

008004f3 <vprintfmt>:
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 2c             	sub    $0x2c,%esp
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	8b 7d 10             	mov    0x10(%ebp),%edi
  800505:	e9 63 03 00 00       	jmp    80086d <vprintfmt+0x37a>
		padc = ' ';
  80050a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80050e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800515:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80051c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800523:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8d 47 01             	lea    0x1(%edi),%eax
  80052b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052e:	0f b6 17             	movzbl (%edi),%edx
  800531:	8d 42 dd             	lea    -0x23(%edx),%eax
  800534:	3c 55                	cmp    $0x55,%al
  800536:	0f 87 11 04 00 00    	ja     80094d <vprintfmt+0x45a>
  80053c:	0f b6 c0             	movzbl %al,%eax
  80053f:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800549:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80054d:	eb d9                	jmp    800528 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800552:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800556:	eb d0                	jmp    800528 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800558:	0f b6 d2             	movzbl %dl,%edx
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055e:	b8 00 00 00 00       	mov    $0x0,%eax
  800563:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800566:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800569:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800570:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800573:	83 f9 09             	cmp    $0x9,%ecx
  800576:	77 55                	ja     8005cd <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800578:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057b:	eb e9                	jmp    800566 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 40 04             	lea    0x4(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	79 91                	jns    800528 <vprintfmt+0x35>
				width = precision, precision = -1;
  800597:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80059a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a4:	eb 82                	jmp    800528 <vprintfmt+0x35>
  8005a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b0:	0f 49 d0             	cmovns %eax,%edx
  8005b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 6a ff ff ff       	jmp    800528 <vprintfmt+0x35>
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c8:	e9 5b ff ff ff       	jmp    800528 <vprintfmt+0x35>
  8005cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d3:	eb bc                	jmp    800591 <vprintfmt+0x9e>
			lflag++;
  8005d5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005db:	e9 48 ff ff ff       	jmp    800528 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 78 04             	lea    0x4(%eax),%edi
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 30                	pushl  (%eax)
  8005ec:	ff d6                	call   *%esi
			break;
  8005ee:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005f4:	e9 71 02 00 00       	jmp    80086a <vprintfmt+0x377>
			err = va_arg(ap, int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 78 04             	lea    0x4(%eax),%edi
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	99                   	cltd   
  800602:	31 d0                	xor    %edx,%eax
  800604:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800606:	83 f8 08             	cmp    $0x8,%eax
  800609:	7f 23                	jg     80062e <vprintfmt+0x13b>
  80060b:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800612:	85 d2                	test   %edx,%edx
  800614:	74 18                	je     80062e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800616:	52                   	push   %edx
  800617:	68 29 10 80 00       	push   $0x801029
  80061c:	53                   	push   %ebx
  80061d:	56                   	push   %esi
  80061e:	e8 b3 fe ff ff       	call   8004d6 <printfmt>
  800623:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800626:	89 7d 14             	mov    %edi,0x14(%ebp)
  800629:	e9 3c 02 00 00       	jmp    80086a <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80062e:	50                   	push   %eax
  80062f:	68 20 10 80 00       	push   $0x801020
  800634:	53                   	push   %ebx
  800635:	56                   	push   %esi
  800636:	e8 9b fe ff ff       	call   8004d6 <printfmt>
  80063b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800641:	e9 24 02 00 00       	jmp    80086a <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	83 c0 04             	add    $0x4,%eax
  80064c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800654:	85 ff                	test   %edi,%edi
  800656:	b8 19 10 80 00       	mov    $0x801019,%eax
  80065b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80065e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800662:	0f 8e bd 00 00 00    	jle    800725 <vprintfmt+0x232>
  800668:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80066c:	75 0e                	jne    80067c <vprintfmt+0x189>
  80066e:	89 75 08             	mov    %esi,0x8(%ebp)
  800671:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800674:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800677:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067a:	eb 6d                	jmp    8006e9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	ff 75 d0             	pushl  -0x30(%ebp)
  800682:	57                   	push   %edi
  800683:	e8 6d 03 00 00       	call   8009f5 <strnlen>
  800688:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800690:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800693:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800697:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	eb 0f                	jmp    8006b0 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006aa:	83 ef 01             	sub    $0x1,%edi
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	85 ff                	test   %edi,%edi
  8006b2:	7f ed                	jg     8006a1 <vprintfmt+0x1ae>
  8006b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ba:	85 c9                	test   %ecx,%ecx
  8006bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c1:	0f 49 c1             	cmovns %ecx,%eax
  8006c4:	29 c1                	sub    %eax,%ecx
  8006c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cf:	89 cb                	mov    %ecx,%ebx
  8006d1:	eb 16                	jmp    8006e9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d7:	75 31                	jne    80070a <vprintfmt+0x217>
					putch(ch, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	50                   	push   %eax
  8006e0:	ff 55 08             	call   *0x8(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e6:	83 eb 01             	sub    $0x1,%ebx
  8006e9:	83 c7 01             	add    $0x1,%edi
  8006ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006f0:	0f be c2             	movsbl %dl,%eax
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 59                	je     800750 <vprintfmt+0x25d>
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	78 d8                	js     8006d3 <vprintfmt+0x1e0>
  8006fb:	83 ee 01             	sub    $0x1,%esi
  8006fe:	79 d3                	jns    8006d3 <vprintfmt+0x1e0>
  800700:	89 df                	mov    %ebx,%edi
  800702:	8b 75 08             	mov    0x8(%ebp),%esi
  800705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800708:	eb 37                	jmp    800741 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80070a:	0f be d2             	movsbl %dl,%edx
  80070d:	83 ea 20             	sub    $0x20,%edx
  800710:	83 fa 5e             	cmp    $0x5e,%edx
  800713:	76 c4                	jbe    8006d9 <vprintfmt+0x1e6>
					putch('?', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	ff 75 0c             	pushl  0xc(%ebp)
  80071b:	6a 3f                	push   $0x3f
  80071d:	ff 55 08             	call   *0x8(%ebp)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb c1                	jmp    8006e6 <vprintfmt+0x1f3>
  800725:	89 75 08             	mov    %esi,0x8(%ebp)
  800728:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800731:	eb b6                	jmp    8006e9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 20                	push   $0x20
  800739:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	85 ff                	test   %edi,%edi
  800743:	7f ee                	jg     800733 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800745:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
  80074b:	e9 1a 01 00 00       	jmp    80086a <vprintfmt+0x377>
  800750:	89 df                	mov    %ebx,%edi
  800752:	8b 75 08             	mov    0x8(%ebp),%esi
  800755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800758:	eb e7                	jmp    800741 <vprintfmt+0x24e>
	if (lflag >= 2)
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7e 3f                	jle    80079e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 50 04             	mov    0x4(%eax),%edx
  800765:	8b 00                	mov    (%eax),%eax
  800767:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8d 40 08             	lea    0x8(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800776:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077a:	79 5c                	jns    8007d8 <vprintfmt+0x2e5>
				putch('-', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 2d                	push   $0x2d
  800782:	ff d6                	call   *%esi
				num = -(long long) num;
  800784:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800787:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078a:	f7 da                	neg    %edx
  80078c:	83 d1 00             	adc    $0x0,%ecx
  80078f:	f7 d9                	neg    %ecx
  800791:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800794:	b8 0a 00 00 00       	mov    $0xa,%eax
  800799:	e9 b2 00 00 00       	jmp    800850 <vprintfmt+0x35d>
	else if (lflag)
  80079e:	85 c9                	test   %ecx,%ecx
  8007a0:	75 1b                	jne    8007bd <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007aa:	89 c1                	mov    %eax,%ecx
  8007ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8007af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bb:	eb b9                	jmp    800776 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d6:	eb 9e                	jmp    800776 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e3:	eb 6b                	jmp    800850 <vprintfmt+0x35d>
	if (lflag >= 2)
  8007e5:	83 f9 01             	cmp    $0x1,%ecx
  8007e8:	7e 15                	jle    8007ff <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f2:	8d 40 08             	lea    0x8(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fd:	eb 51                	jmp    800850 <vprintfmt+0x35d>
	else if (lflag)
  8007ff:	85 c9                	test   %ecx,%ecx
  800801:	75 17                	jne    80081a <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 10                	mov    (%eax),%edx
  800808:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080d:	8d 40 04             	lea    0x4(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	eb 36                	jmp    800850 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082f:	eb 1f                	jmp    800850 <vprintfmt+0x35d>
	if (lflag >= 2)
  800831:	83 f9 01             	cmp    $0x1,%ecx
  800834:	7e 5b                	jle    800891 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8b 50 04             	mov    0x4(%eax),%edx
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800841:	8d 49 08             	lea    0x8(%ecx),%ecx
  800844:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800847:	89 d1                	mov    %edx,%ecx
  800849:	89 c2                	mov    %eax,%edx
			base = 8;
  80084b:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800857:	57                   	push   %edi
  800858:	ff 75 e0             	pushl  -0x20(%ebp)
  80085b:	50                   	push   %eax
  80085c:	51                   	push   %ecx
  80085d:	52                   	push   %edx
  80085e:	89 da                	mov    %ebx,%edx
  800860:	89 f0                	mov    %esi,%eax
  800862:	e8 a3 fb ff ff       	call   80040a <printnum>
			break;
  800867:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80086d:	83 c7 01             	add    $0x1,%edi
  800870:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800874:	83 f8 25             	cmp    $0x25,%eax
  800877:	0f 84 8d fc ff ff    	je     80050a <vprintfmt+0x17>
			if (ch == '\0')
  80087d:	85 c0                	test   %eax,%eax
  80087f:	0f 84 e8 00 00 00    	je     80096d <vprintfmt+0x47a>
			putch(ch, putdat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	50                   	push   %eax
  80088a:	ff d6                	call   *%esi
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	eb dc                	jmp    80086d <vprintfmt+0x37a>
	else if (lflag)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	75 13                	jne    8008a8 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8b 10                	mov    (%eax),%edx
  80089a:	89 d0                	mov    %edx,%eax
  80089c:	99                   	cltd   
  80089d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a6:	eb 9f                	jmp    800847 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 10                	mov    (%eax),%edx
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	99                   	cltd   
  8008b0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b9:	eb 8c                	jmp    800847 <vprintfmt+0x354>
			putch('0', putdat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	6a 30                	push   $0x30
  8008c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c3:	83 c4 08             	add    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	6a 78                	push   $0x78
  8008c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008d8:	8d 40 04             	lea    0x4(%eax),%eax
  8008db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e3:	e9 68 ff ff ff       	jmp    800850 <vprintfmt+0x35d>
	if (lflag >= 2)
  8008e8:	83 f9 01             	cmp    $0x1,%ecx
  8008eb:	7e 18                	jle    800905 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8b 10                	mov    (%eax),%edx
  8008f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f5:	8d 40 08             	lea    0x8(%eax),%eax
  8008f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800900:	e9 4b ff ff ff       	jmp    800850 <vprintfmt+0x35d>
	else if (lflag)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	75 1a                	jne    800923 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8b 10                	mov    (%eax),%edx
  80090e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800913:	8d 40 04             	lea    0x4(%eax),%eax
  800916:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800919:	b8 10 00 00 00       	mov    $0x10,%eax
  80091e:	e9 2d ff ff ff       	jmp    800850 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 10                	mov    (%eax),%edx
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092d:	8d 40 04             	lea    0x4(%eax),%eax
  800930:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800933:	b8 10 00 00 00       	mov    $0x10,%eax
  800938:	e9 13 ff ff ff       	jmp    800850 <vprintfmt+0x35d>
			putch(ch, putdat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	6a 25                	push   $0x25
  800943:	ff d6                	call   *%esi
			break;
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	e9 1d ff ff ff       	jmp    80086a <vprintfmt+0x377>
			putch('%', putdat);
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	53                   	push   %ebx
  800951:	6a 25                	push   $0x25
  800953:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	89 f8                	mov    %edi,%eax
  80095a:	eb 03                	jmp    80095f <vprintfmt+0x46c>
  80095c:	83 e8 01             	sub    $0x1,%eax
  80095f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800963:	75 f7                	jne    80095c <vprintfmt+0x469>
  800965:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800968:	e9 fd fe ff ff       	jmp    80086a <vprintfmt+0x377>
}
  80096d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 18             	sub    $0x18,%esp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800984:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800988:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800992:	85 c0                	test   %eax,%eax
  800994:	74 26                	je     8009bc <vsnprintf+0x47>
  800996:	85 d2                	test   %edx,%edx
  800998:	7e 22                	jle    8009bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099a:	ff 75 14             	pushl  0x14(%ebp)
  80099d:	ff 75 10             	pushl  0x10(%ebp)
  8009a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a3:	50                   	push   %eax
  8009a4:	68 b9 04 80 00       	push   $0x8004b9
  8009a9:	e8 45 fb ff ff       	call   8004f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b7:	83 c4 10             	add    $0x10,%esp
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    
		return -E_INVAL;
  8009bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c1:	eb f7                	jmp    8009ba <vsnprintf+0x45>

008009c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009cc:	50                   	push   %eax
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	ff 75 08             	pushl  0x8(%ebp)
  8009d6:	e8 9a ff ff ff       	call   800975 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb 03                	jmp    8009ed <strlen+0x10>
		n++;
  8009ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f1:	75 f7                	jne    8009ea <strlen+0xd>
	return n;
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 03                	jmp    800a08 <strnlen+0x13>
		n++;
  800a05:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	74 06                	je     800a12 <strnlen+0x1d>
  800a0c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a10:	75 f3                	jne    800a05 <strnlen+0x10>
	return n;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	83 c1 01             	add    $0x1,%ecx
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a2a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a2d:	84 db                	test   %bl,%bl
  800a2f:	75 ef                	jne    800a20 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a31:	5b                   	pop    %ebx
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a3b:	53                   	push   %ebx
  800a3c:	e8 9c ff ff ff       	call   8009dd <strlen>
  800a41:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a44:	ff 75 0c             	pushl  0xc(%ebp)
  800a47:	01 d8                	add    %ebx,%eax
  800a49:	50                   	push   %eax
  800a4a:	e8 c5 ff ff ff       	call   800a14 <strcpy>
	return dst;
}
  800a4f:	89 d8                	mov    %ebx,%eax
  800a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a61:	89 f3                	mov    %esi,%ebx
  800a63:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a66:	89 f2                	mov    %esi,%edx
  800a68:	eb 0f                	jmp    800a79 <strncpy+0x23>
		*dst++ = *src;
  800a6a:	83 c2 01             	add    $0x1,%edx
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a73:	80 39 01             	cmpb   $0x1,(%ecx)
  800a76:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a79:	39 da                	cmp    %ebx,%edx
  800a7b:	75 ed                	jne    800a6a <strncpy+0x14>
	}
	return ret;
}
  800a7d:	89 f0                	mov    %esi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a91:	89 f0                	mov    %esi,%eax
  800a93:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a97:	85 c9                	test   %ecx,%ecx
  800a99:	75 0b                	jne    800aa6 <strlcpy+0x23>
  800a9b:	eb 17                	jmp    800ab4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a9d:	83 c2 01             	add    $0x1,%edx
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800aa6:	39 d8                	cmp    %ebx,%eax
  800aa8:	74 07                	je     800ab1 <strlcpy+0x2e>
  800aaa:	0f b6 0a             	movzbl (%edx),%ecx
  800aad:	84 c9                	test   %cl,%cl
  800aaf:	75 ec                	jne    800a9d <strlcpy+0x1a>
		*dst = '\0';
  800ab1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ab4:	29 f0                	sub    %esi,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ac3:	eb 06                	jmp    800acb <strcmp+0x11>
		p++, q++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800acb:	0f b6 01             	movzbl (%ecx),%eax
  800ace:	84 c0                	test   %al,%al
  800ad0:	74 04                	je     800ad6 <strcmp+0x1c>
  800ad2:	3a 02                	cmp    (%edx),%al
  800ad4:	74 ef                	je     800ac5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad6:	0f b6 c0             	movzbl %al,%eax
  800ad9:	0f b6 12             	movzbl (%edx),%edx
  800adc:	29 d0                	sub    %edx,%eax
}
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	53                   	push   %ebx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aea:	89 c3                	mov    %eax,%ebx
  800aec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aef:	eb 06                	jmp    800af7 <strncmp+0x17>
		n--, p++, q++;
  800af1:	83 c0 01             	add    $0x1,%eax
  800af4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800af7:	39 d8                	cmp    %ebx,%eax
  800af9:	74 16                	je     800b11 <strncmp+0x31>
  800afb:	0f b6 08             	movzbl (%eax),%ecx
  800afe:	84 c9                	test   %cl,%cl
  800b00:	74 04                	je     800b06 <strncmp+0x26>
  800b02:	3a 0a                	cmp    (%edx),%cl
  800b04:	74 eb                	je     800af1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b06:	0f b6 00             	movzbl (%eax),%eax
  800b09:	0f b6 12             	movzbl (%edx),%edx
  800b0c:	29 d0                	sub    %edx,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    
		return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb f6                	jmp    800b0e <strncmp+0x2e>

00800b18 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b22:	0f b6 10             	movzbl (%eax),%edx
  800b25:	84 d2                	test   %dl,%dl
  800b27:	74 09                	je     800b32 <strchr+0x1a>
		if (*s == c)
  800b29:	38 ca                	cmp    %cl,%dl
  800b2b:	74 0a                	je     800b37 <strchr+0x1f>
	for (; *s; s++)
  800b2d:	83 c0 01             	add    $0x1,%eax
  800b30:	eb f0                	jmp    800b22 <strchr+0xa>
			return (char *) s;
	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b43:	eb 03                	jmp    800b48 <strfind+0xf>
  800b45:	83 c0 01             	add    $0x1,%eax
  800b48:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b4b:	38 ca                	cmp    %cl,%dl
  800b4d:	74 04                	je     800b53 <strfind+0x1a>
  800b4f:	84 d2                	test   %dl,%dl
  800b51:	75 f2                	jne    800b45 <strfind+0xc>
			break;
	return (char *) s;
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b61:	85 c9                	test   %ecx,%ecx
  800b63:	74 13                	je     800b78 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b65:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6b:	75 05                	jne    800b72 <memset+0x1d>
  800b6d:	f6 c1 03             	test   $0x3,%cl
  800b70:	74 0d                	je     800b7f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	fc                   	cld    
  800b76:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b78:	89 f8                	mov    %edi,%eax
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
		c &= 0xFF;
  800b7f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	c1 e3 08             	shl    $0x8,%ebx
  800b88:	89 d0                	mov    %edx,%eax
  800b8a:	c1 e0 18             	shl    $0x18,%eax
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	c1 e6 10             	shl    $0x10,%esi
  800b92:	09 f0                	or     %esi,%eax
  800b94:	09 c2                	or     %eax,%edx
  800b96:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b98:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb d6                	jmp    800b78 <memset+0x23>

00800ba2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb0:	39 c6                	cmp    %eax,%esi
  800bb2:	73 35                	jae    800be9 <memmove+0x47>
  800bb4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb7:	39 c2                	cmp    %eax,%edx
  800bb9:	76 2e                	jbe    800be9 <memmove+0x47>
		s += n;
		d += n;
  800bbb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	09 fe                	or     %edi,%esi
  800bc2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bc8:	74 0c                	je     800bd6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bca:	83 ef 01             	sub    $0x1,%edi
  800bcd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bd0:	fd                   	std    
  800bd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd3:	fc                   	cld    
  800bd4:	eb 21                	jmp    800bf7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd6:	f6 c1 03             	test   $0x3,%cl
  800bd9:	75 ef                	jne    800bca <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bdb:	83 ef 04             	sub    $0x4,%edi
  800bde:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800be4:	fd                   	std    
  800be5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be7:	eb ea                	jmp    800bd3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be9:	89 f2                	mov    %esi,%edx
  800beb:	09 c2                	or     %eax,%edx
  800bed:	f6 c2 03             	test   $0x3,%dl
  800bf0:	74 09                	je     800bfb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	fc                   	cld    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfb:	f6 c1 03             	test   $0x3,%cl
  800bfe:	75 f2                	jne    800bf2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c00:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	fc                   	cld    
  800c06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c08:	eb ed                	jmp    800bf7 <memmove+0x55>

00800c0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c0d:	ff 75 10             	pushl  0x10(%ebp)
  800c10:	ff 75 0c             	pushl  0xc(%ebp)
  800c13:	ff 75 08             	pushl  0x8(%ebp)
  800c16:	e8 87 ff ff ff       	call   800ba2 <memmove>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c28:	89 c6                	mov    %eax,%esi
  800c2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2d:	39 f0                	cmp    %esi,%eax
  800c2f:	74 1c                	je     800c4d <memcmp+0x30>
		if (*s1 != *s2)
  800c31:	0f b6 08             	movzbl (%eax),%ecx
  800c34:	0f b6 1a             	movzbl (%edx),%ebx
  800c37:	38 d9                	cmp    %bl,%cl
  800c39:	75 08                	jne    800c43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	83 c2 01             	add    $0x1,%edx
  800c41:	eb ea                	jmp    800c2d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c43:	0f b6 c1             	movzbl %cl,%eax
  800c46:	0f b6 db             	movzbl %bl,%ebx
  800c49:	29 d8                	sub    %ebx,%eax
  800c4b:	eb 05                	jmp    800c52 <memcmp+0x35>
	}

	return 0;
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 09                	jae    800c71 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c68:	38 08                	cmp    %cl,(%eax)
  800c6a:	74 05                	je     800c71 <memfind+0x1b>
	for (; s < ends; s++)
  800c6c:	83 c0 01             	add    $0x1,%eax
  800c6f:	eb f3                	jmp    800c64 <memfind+0xe>
			break;
	return (void *) s;
}
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7f:	eb 03                	jmp    800c84 <strtol+0x11>
		s++;
  800c81:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c84:	0f b6 01             	movzbl (%ecx),%eax
  800c87:	3c 20                	cmp    $0x20,%al
  800c89:	74 f6                	je     800c81 <strtol+0xe>
  800c8b:	3c 09                	cmp    $0x9,%al
  800c8d:	74 f2                	je     800c81 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c8f:	3c 2b                	cmp    $0x2b,%al
  800c91:	74 2e                	je     800cc1 <strtol+0x4e>
	int neg = 0;
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c98:	3c 2d                	cmp    $0x2d,%al
  800c9a:	74 2f                	je     800ccb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca2:	75 05                	jne    800ca9 <strtol+0x36>
  800ca4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca7:	74 2c                	je     800cd5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca9:	85 db                	test   %ebx,%ebx
  800cab:	75 0a                	jne    800cb7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cad:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cb2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb5:	74 28                	je     800cdf <strtol+0x6c>
		base = 10;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cbf:	eb 50                	jmp    800d11 <strtol+0x9e>
		s++;
  800cc1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cc4:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc9:	eb d1                	jmp    800c9c <strtol+0x29>
		s++, neg = 1;
  800ccb:	83 c1 01             	add    $0x1,%ecx
  800cce:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd3:	eb c7                	jmp    800c9c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd9:	74 0e                	je     800ce9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	75 d8                	jne    800cb7 <strtol+0x44>
		s++, base = 8;
  800cdf:	83 c1 01             	add    $0x1,%ecx
  800ce2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ce7:	eb ce                	jmp    800cb7 <strtol+0x44>
		s += 2, base = 16;
  800ce9:	83 c1 02             	add    $0x2,%ecx
  800cec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf1:	eb c4                	jmp    800cb7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cf3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cf6:	89 f3                	mov    %esi,%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 29                	ja     800d26 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cfd:	0f be d2             	movsbl %dl,%edx
  800d00:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d03:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d06:	7d 30                	jge    800d38 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d08:	83 c1 01             	add    $0x1,%ecx
  800d0b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d0f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d11:	0f b6 11             	movzbl (%ecx),%edx
  800d14:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d17:	89 f3                	mov    %esi,%ebx
  800d19:	80 fb 09             	cmp    $0x9,%bl
  800d1c:	77 d5                	ja     800cf3 <strtol+0x80>
			dig = *s - '0';
  800d1e:	0f be d2             	movsbl %dl,%edx
  800d21:	83 ea 30             	sub    $0x30,%edx
  800d24:	eb dd                	jmp    800d03 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d26:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d29:	89 f3                	mov    %esi,%ebx
  800d2b:	80 fb 19             	cmp    $0x19,%bl
  800d2e:	77 08                	ja     800d38 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d30:	0f be d2             	movsbl %dl,%edx
  800d33:	83 ea 37             	sub    $0x37,%edx
  800d36:	eb cb                	jmp    800d03 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d3c:	74 05                	je     800d43 <strtol+0xd0>
		*endptr = (char *) s;
  800d3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d41:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	f7 da                	neg    %edx
  800d47:	85 ff                	test   %edi,%edi
  800d49:	0f 45 c2             	cmovne %edx,%eax
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
  800d51:	66 90                	xchg   %ax,%ax
  800d53:	66 90                	xchg   %ax,%ax
  800d55:	66 90                	xchg   %ax,%ax
  800d57:	66 90                	xchg   %ax,%ax
  800d59:	66 90                	xchg   %ax,%ax
  800d5b:	66 90                	xchg   %ax,%ax
  800d5d:	66 90                	xchg   %ax,%ax
  800d5f:	90                   	nop

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d77:	85 d2                	test   %edx,%edx
  800d79:	75 35                	jne    800db0 <__udivdi3+0x50>
  800d7b:	39 f3                	cmp    %esi,%ebx
  800d7d:	0f 87 bd 00 00 00    	ja     800e40 <__udivdi3+0xe0>
  800d83:	85 db                	test   %ebx,%ebx
  800d85:	89 d9                	mov    %ebx,%ecx
  800d87:	75 0b                	jne    800d94 <__udivdi3+0x34>
  800d89:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8e:	31 d2                	xor    %edx,%edx
  800d90:	f7 f3                	div    %ebx
  800d92:	89 c1                	mov    %eax,%ecx
  800d94:	31 d2                	xor    %edx,%edx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	f7 f1                	div    %ecx
  800d9a:	89 c6                	mov    %eax,%esi
  800d9c:	89 e8                	mov    %ebp,%eax
  800d9e:	89 f7                	mov    %esi,%edi
  800da0:	f7 f1                	div    %ecx
  800da2:	89 fa                	mov    %edi,%edx
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db0:	39 f2                	cmp    %esi,%edx
  800db2:	77 7c                	ja     800e30 <__udivdi3+0xd0>
  800db4:	0f bd fa             	bsr    %edx,%edi
  800db7:	83 f7 1f             	xor    $0x1f,%edi
  800dba:	0f 84 98 00 00 00    	je     800e58 <__udivdi3+0xf8>
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	b8 20 00 00 00       	mov    $0x20,%eax
  800dc7:	29 f8                	sub    %edi,%eax
  800dc9:	d3 e2                	shl    %cl,%edx
  800dcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	89 da                	mov    %ebx,%edx
  800dd3:	d3 ea                	shr    %cl,%edx
  800dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dd9:	09 d1                	or     %edx,%ecx
  800ddb:	89 f2                	mov    %esi,%edx
  800ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e3                	shl    %cl,%ebx
  800de5:	89 c1                	mov    %eax,%ecx
  800de7:	d3 ea                	shr    %cl,%edx
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800def:	d3 e6                	shl    %cl,%esi
  800df1:	89 eb                	mov    %ebp,%ebx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	d3 eb                	shr    %cl,%ebx
  800df7:	09 de                	or     %ebx,%esi
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	f7 74 24 08          	divl   0x8(%esp)
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	f7 64 24 0c          	mull   0xc(%esp)
  800e07:	39 d6                	cmp    %edx,%esi
  800e09:	72 0c                	jb     800e17 <__udivdi3+0xb7>
  800e0b:	89 f9                	mov    %edi,%ecx
  800e0d:	d3 e5                	shl    %cl,%ebp
  800e0f:	39 c5                	cmp    %eax,%ebp
  800e11:	73 5d                	jae    800e70 <__udivdi3+0x110>
  800e13:	39 d6                	cmp    %edx,%esi
  800e15:	75 59                	jne    800e70 <__udivdi3+0x110>
  800e17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e1a:	31 ff                	xor    %edi,%edi
  800e1c:	89 fa                	mov    %edi,%edx
  800e1e:	83 c4 1c             	add    $0x1c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
  800e26:	8d 76 00             	lea    0x0(%esi),%esi
  800e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	31 c0                	xor    %eax,%eax
  800e34:	89 fa                	mov    %edi,%edx
  800e36:	83 c4 1c             	add    $0x1c,%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
  800e3e:	66 90                	xchg   %ax,%ax
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	89 e8                	mov    %ebp,%eax
  800e44:	89 f2                	mov    %esi,%edx
  800e46:	f7 f3                	div    %ebx
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	83 c4 1c             	add    $0x1c,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x102>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 d2                	ja     800e34 <__udivdi3+0xd4>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb cb                	jmp    800e34 <__udivdi3+0xd4>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	31 ff                	xor    %edi,%edi
  800e74:	eb be                	jmp    800e34 <__udivdi3+0xd4>
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e97:	85 ed                	test   %ebp,%ebp
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	89 da                	mov    %ebx,%edx
  800e9d:	75 19                	jne    800eb8 <__umoddi3+0x38>
  800e9f:	39 df                	cmp    %ebx,%edi
  800ea1:	0f 86 b1 00 00 00    	jbe    800f58 <__umoddi3+0xd8>
  800ea7:	f7 f7                	div    %edi
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	83 c4 1c             	add    $0x1c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
  800eb8:	39 dd                	cmp    %ebx,%ebp
  800eba:	77 f1                	ja     800ead <__umoddi3+0x2d>
  800ebc:	0f bd cd             	bsr    %ebp,%ecx
  800ebf:	83 f1 1f             	xor    $0x1f,%ecx
  800ec2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ec6:	0f 84 b4 00 00 00    	je     800f80 <__umoddi3+0x100>
  800ecc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed7:	29 c2                	sub    %eax,%edx
  800ed9:	89 c1                	mov    %eax,%ecx
  800edb:	89 f8                	mov    %edi,%eax
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	89 d1                	mov    %edx,%ecx
  800ee1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee5:	d3 e8                	shr    %cl,%eax
  800ee7:	09 c5                	or     %eax,%ebp
  800ee9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eed:	89 c1                	mov    %eax,%ecx
  800eef:	d3 e7                	shl    %cl,%edi
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	d3 ef                	shr    %cl,%edi
  800efb:	89 c1                	mov    %eax,%ecx
  800efd:	89 f0                	mov    %esi,%eax
  800eff:	d3 e3                	shl    %cl,%ebx
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 fa                	mov    %edi,%edx
  800f05:	d3 e8                	shr    %cl,%eax
  800f07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f0c:	09 d8                	or     %ebx,%eax
  800f0e:	f7 f5                	div    %ebp
  800f10:	d3 e6                	shl    %cl,%esi
  800f12:	89 d1                	mov    %edx,%ecx
  800f14:	f7 64 24 08          	mull   0x8(%esp)
  800f18:	39 d1                	cmp    %edx,%ecx
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	72 06                	jb     800f26 <__umoddi3+0xa6>
  800f20:	75 0e                	jne    800f30 <__umoddi3+0xb0>
  800f22:	39 c6                	cmp    %eax,%esi
  800f24:	73 0a                	jae    800f30 <__umoddi3+0xb0>
  800f26:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f2a:	19 ea                	sbb    %ebp,%edx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	89 ca                	mov    %ecx,%edx
  800f32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f37:	29 de                	sub    %ebx,%esi
  800f39:	19 fa                	sbb    %edi,%edx
  800f3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f3f:	89 d0                	mov    %edx,%eax
  800f41:	d3 e0                	shl    %cl,%eax
  800f43:	89 d9                	mov    %ebx,%ecx
  800f45:	d3 ee                	shr    %cl,%esi
  800f47:	d3 ea                	shr    %cl,%edx
  800f49:	09 f0                	or     %esi,%eax
  800f4b:	83 c4 1c             	add    $0x1c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
  800f53:	90                   	nop
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	85 ff                	test   %edi,%edi
  800f5a:	89 f9                	mov    %edi,%ecx
  800f5c:	75 0b                	jne    800f69 <__umoddi3+0xe9>
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f7                	div    %edi
  800f67:	89 c1                	mov    %eax,%ecx
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f1                	div    %ecx
  800f6f:	89 f0                	mov    %esi,%eax
  800f71:	f7 f1                	div    %ecx
  800f73:	e9 31 ff ff ff       	jmp    800ea9 <__umoddi3+0x29>
  800f78:	90                   	nop
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	39 dd                	cmp    %ebx,%ebp
  800f82:	72 08                	jb     800f8c <__umoddi3+0x10c>
  800f84:	39 f7                	cmp    %esi,%edi
  800f86:	0f 87 21 ff ff ff    	ja     800ead <__umoddi3+0x2d>
  800f8c:	89 da                	mov    %ebx,%edx
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	29 f8                	sub    %edi,%eax
  800f92:	19 ea                	sbb    %ebp,%edx
  800f94:	e9 14 ff ff ff       	jmp    800ead <__umoddi3+0x2d>
