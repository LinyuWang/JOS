
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 ee 0c 00 00       	call   800d38 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 17 0d 00 00       	call   800d7b <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 4f 0a 00 00       	call   800acd <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 30 0d 00 00       	call   800dbd <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 40 11 80 00       	push   $0x801140
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 53 11 80 00       	push   $0x801153
  8000a8:	e8 99 01 00 00       	call   800246 <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 63 11 80 00       	push   $0x801163
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 53 11 80 00       	push   $0x801153
  8000ba:	e8 87 01 00 00       	call   800246 <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 74 11 80 00       	push   $0x801174
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 53 11 80 00       	push   $0x801153
  8000cc:	e8 75 01 00 00       	call   800246 <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid == 0) {
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	74 0f                	je     8000f5 <dumbfork+0x24>
  8000e6:	89 c6                	mov    %eax,%esi
		cprintf("You returned 0\n");
	}
	if (envid < 0)
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	78 32                	js     80011e <dumbfork+0x4d>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000ec:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f3:	eb 4f                	jmp    800144 <dumbfork+0x73>
		cprintf("You returned 0\n");
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	68 87 11 80 00       	push   $0x801187
  8000fd:	e8 1f 02 00 00       	call   800321 <cprintf>
		thisenv = &envs[ENVX(sys_getenvid())];
  800102:	e8 f3 0b 00 00       	call   800cfa <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	eb 55                	jmp    800173 <dumbfork+0xa2>
		panic("sys_exofork: %e", envid);
  80011e:	53                   	push   %ebx
  80011f:	68 97 11 80 00       	push   $0x801197
  800124:	6a 3a                	push   $0x3a
  800126:	68 53 11 80 00       	push   $0x801153
  80012b:	e8 16 01 00 00       	call   800246 <_panic>
		duppage(envid, addr);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	52                   	push   %edx
  800134:	56                   	push   %esi
  800135:	e8 f9 fe ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80013a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800147:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  80014d:	72 e1                	jb     800130 <dumbfork+0x5f>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80014f:	83 ec 08             	sub    $0x8,%esp
  800152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800155:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80015a:	50                   	push   %eax
  80015b:	53                   	push   %ebx
  80015c:	e8 d2 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800161:	83 c4 08             	add    $0x8,%esp
  800164:	6a 02                	push   $0x2
  800166:	53                   	push   %ebx
  800167:	e8 93 0c 00 00       	call   800dff <sys_env_set_status>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	78 09                	js     80017c <dumbfork+0xab>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800173:	89 d8                	mov    %ebx,%eax
  800175:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 a7 11 80 00       	push   $0x8011a7
  800182:	6a 4f                	push   $0x4f
  800184:	68 53 11 80 00       	push   $0x801153
  800189:	e8 b8 00 00 00       	call   800246 <_panic>

0080018e <umain>:
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800197:	e8 35 ff ff ff       	call   8000d1 <dumbfork>
  80019c:	89 c7                	mov    %eax,%edi
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	be be 11 80 00       	mov    $0x8011be,%esi
  8001a5:	b8 c5 11 80 00       	mov    $0x8011c5,%eax
  8001aa:	0f 44 f0             	cmove  %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b2:	eb 1f                	jmp    8001d3 <umain+0x45>
  8001b4:	83 fb 13             	cmp    $0x13,%ebx
  8001b7:	7f 23                	jg     8001dc <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b9:	83 ec 04             	sub    $0x4,%esp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	68 cb 11 80 00       	push   $0x8011cb
  8001c3:	e8 59 01 00 00       	call   800321 <cprintf>
		sys_yield();
  8001c8:	e8 4c 0b 00 00       	call   800d19 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001cd:	83 c3 01             	add    $0x1,%ebx
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	85 ff                	test   %edi,%edi
  8001d5:	74 dd                	je     8001b4 <umain+0x26>
  8001d7:	83 fb 09             	cmp    $0x9,%ebx
  8001da:	7e dd                	jle    8001b9 <umain+0x2b>
}
  8001dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001ef:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8001f6:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8001f9:	e8 fc 0a 00 00       	call   800cfa <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8001fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800203:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800206:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800210:	85 db                	test   %ebx,%ebx
  800212:	7e 07                	jle    80021b <libmain+0x37>
		binaryname = argv[0];
  800214:	8b 06                	mov    (%esi),%eax
  800216:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	e8 69 ff ff ff       	call   80018e <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80023a:	6a 00                	push   $0x0
  80023c:	e8 78 0a 00 00       	call   800cb9 <sys_env_destroy>
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80024b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800254:	e8 a1 0a 00 00       	call   800cfa <sys_getenvid>
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	56                   	push   %esi
  800263:	50                   	push   %eax
  800264:	68 e8 11 80 00       	push   $0x8011e8
  800269:	e8 b3 00 00 00       	call   800321 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026e:	83 c4 18             	add    $0x18,%esp
  800271:	53                   	push   %ebx
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	e8 56 00 00 00       	call   8002d0 <vcprintf>
	cprintf("\n");
  80027a:	c7 04 24 db 11 80 00 	movl   $0x8011db,(%esp)
  800281:	e8 9b 00 00 00       	call   800321 <cprintf>
  800286:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800289:	cc                   	int3   
  80028a:	eb fd                	jmp    800289 <_panic+0x43>

0080028c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	53                   	push   %ebx
  800290:	83 ec 04             	sub    $0x4,%esp
  800293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800296:	8b 13                	mov    (%ebx),%edx
  800298:	8d 42 01             	lea    0x1(%edx),%eax
  80029b:	89 03                	mov    %eax,(%ebx)
  80029d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a9:	74 09                	je     8002b4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	68 ff 00 00 00       	push   $0xff
  8002bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bf:	50                   	push   %eax
  8002c0:	e8 b7 09 00 00       	call   800c7c <sys_cputs>
		b->idx = 0;
  8002c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	eb db                	jmp    8002ab <putch+0x1f>

008002d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e0:	00 00 00 
	b.cnt = 0;
  8002e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	68 8c 02 80 00       	push   $0x80028c
  8002ff:	e8 1a 01 00 00       	call   80041e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800304:	83 c4 08             	add    $0x8,%esp
  800307:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80030d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800313:	50                   	push   %eax
  800314:	e8 63 09 00 00       	call   800c7c <sys_cputs>

	return b.cnt;
}
  800319:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800327:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032a:	50                   	push   %eax
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	e8 9d ff ff ff       	call   8002d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 1c             	sub    $0x1c,%esp
  80033e:	89 c7                	mov    %eax,%edi
  800340:	89 d6                	mov    %edx,%esi
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	8b 55 0c             	mov    0xc(%ebp),%edx
  800348:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800351:	bb 00 00 00 00       	mov    $0x0,%ebx
  800356:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800359:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80035c:	39 d3                	cmp    %edx,%ebx
  80035e:	72 05                	jb     800365 <printnum+0x30>
  800360:	39 45 10             	cmp    %eax,0x10(%ebp)
  800363:	77 7a                	ja     8003df <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	ff 75 18             	pushl  0x18(%ebp)
  80036b:	8b 45 14             	mov    0x14(%ebp),%eax
  80036e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800371:	53                   	push   %ebx
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037b:	ff 75 e0             	pushl  -0x20(%ebp)
  80037e:	ff 75 dc             	pushl  -0x24(%ebp)
  800381:	ff 75 d8             	pushl  -0x28(%ebp)
  800384:	e8 67 0b 00 00       	call   800ef0 <__udivdi3>
  800389:	83 c4 18             	add    $0x18,%esp
  80038c:	52                   	push   %edx
  80038d:	50                   	push   %eax
  80038e:	89 f2                	mov    %esi,%edx
  800390:	89 f8                	mov    %edi,%eax
  800392:	e8 9e ff ff ff       	call   800335 <printnum>
  800397:	83 c4 20             	add    $0x20,%esp
  80039a:	eb 13                	jmp    8003af <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	56                   	push   %esi
  8003a0:	ff 75 18             	pushl  0x18(%ebp)
  8003a3:	ff d7                	call   *%edi
  8003a5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003a8:	83 eb 01             	sub    $0x1,%ebx
  8003ab:	85 db                	test   %ebx,%ebx
  8003ad:	7f ed                	jg     80039c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	56                   	push   %esi
  8003b3:	83 ec 04             	sub    $0x4,%esp
  8003b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c2:	e8 49 0c 00 00       	call   801010 <__umoddi3>
  8003c7:	83 c4 14             	add    $0x14,%esp
  8003ca:	0f be 80 0c 12 80 00 	movsbl 0x80120c(%eax),%eax
  8003d1:	50                   	push   %eax
  8003d2:	ff d7                	call   *%edi
}
  8003d4:	83 c4 10             	add    $0x10,%esp
  8003d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5e                   	pop    %esi
  8003dc:	5f                   	pop    %edi
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    
  8003df:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e2:	eb c4                	jmp    8003a8 <printnum+0x73>

008003e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ea:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ee:	8b 10                	mov    (%eax),%edx
  8003f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f3:	73 0a                	jae    8003ff <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	88 02                	mov    %al,(%edx)
}
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <printfmt>:
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800407:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040a:	50                   	push   %eax
  80040b:	ff 75 10             	pushl  0x10(%ebp)
  80040e:	ff 75 0c             	pushl  0xc(%ebp)
  800411:	ff 75 08             	pushl  0x8(%ebp)
  800414:	e8 05 00 00 00       	call   80041e <vprintfmt>
}
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <vprintfmt>:
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	57                   	push   %edi
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	83 ec 2c             	sub    $0x2c,%esp
  800427:	8b 75 08             	mov    0x8(%ebp),%esi
  80042a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800430:	e9 63 03 00 00       	jmp    800798 <vprintfmt+0x37a>
		padc = ' ';
  800435:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800439:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800440:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800447:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80044e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8d 47 01             	lea    0x1(%edi),%eax
  800456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800459:	0f b6 17             	movzbl (%edi),%edx
  80045c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80045f:	3c 55                	cmp    $0x55,%al
  800461:	0f 87 11 04 00 00    	ja     800878 <vprintfmt+0x45a>
  800467:	0f b6 c0             	movzbl %al,%eax
  80046a:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800474:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800478:	eb d9                	jmp    800453 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80047d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800481:	eb d0                	jmp    800453 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800483:	0f b6 d2             	movzbl %dl,%edx
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800491:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800494:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800498:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80049b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80049e:	83 f9 09             	cmp    $0x9,%ecx
  8004a1:	77 55                	ja     8004f8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a6:	eb e9                	jmp    800491 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 40 04             	lea    0x4(%eax),%eax
  8004b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c0:	79 91                	jns    800453 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004cf:	eb 82                	jmp    800453 <vprintfmt+0x35>
  8004d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004db:	0f 49 d0             	cmovns %eax,%edx
  8004de:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e4:	e9 6a ff ff ff       	jmp    800453 <vprintfmt+0x35>
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f3:	e9 5b ff ff ff       	jmp    800453 <vprintfmt+0x35>
  8004f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004fe:	eb bc                	jmp    8004bc <vprintfmt+0x9e>
			lflag++;
  800500:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800506:	e9 48 ff ff ff       	jmp    800453 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 78 04             	lea    0x4(%eax),%edi
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	ff 30                	pushl  (%eax)
  800517:	ff d6                	call   *%esi
			break;
  800519:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80051c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80051f:	e9 71 02 00 00       	jmp    800795 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 78 04             	lea    0x4(%eax),%edi
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	99                   	cltd   
  80052d:	31 d0                	xor    %edx,%eax
  80052f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	83 f8 08             	cmp    $0x8,%eax
  800534:	7f 23                	jg     800559 <vprintfmt+0x13b>
  800536:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  80053d:	85 d2                	test   %edx,%edx
  80053f:	74 18                	je     800559 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800541:	52                   	push   %edx
  800542:	68 2d 12 80 00       	push   $0x80122d
  800547:	53                   	push   %ebx
  800548:	56                   	push   %esi
  800549:	e8 b3 fe ff ff       	call   800401 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800551:	89 7d 14             	mov    %edi,0x14(%ebp)
  800554:	e9 3c 02 00 00       	jmp    800795 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800559:	50                   	push   %eax
  80055a:	68 24 12 80 00       	push   $0x801224
  80055f:	53                   	push   %ebx
  800560:	56                   	push   %esi
  800561:	e8 9b fe ff ff       	call   800401 <printfmt>
  800566:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800569:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056c:	e9 24 02 00 00       	jmp    800795 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	83 c0 04             	add    $0x4,%eax
  800577:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80057f:	85 ff                	test   %edi,%edi
  800581:	b8 1d 12 80 00       	mov    $0x80121d,%eax
  800586:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058d:	0f 8e bd 00 00 00    	jle    800650 <vprintfmt+0x232>
  800593:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800597:	75 0e                	jne    8005a7 <vprintfmt+0x189>
  800599:	89 75 08             	mov    %esi,0x8(%ebp)
  80059c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a5:	eb 6d                	jmp    800614 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ad:	57                   	push   %edi
  8005ae:	e8 6d 03 00 00       	call   800920 <strnlen>
  8005b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b6:	29 c1                	sub    %eax,%ecx
  8005b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ca:	eb 0f                	jmp    8005db <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	83 ef 01             	sub    $0x1,%edi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	85 ff                	test   %edi,%edi
  8005dd:	7f ed                	jg     8005cc <vprintfmt+0x1ae>
  8005df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	0f 49 c1             	cmovns %ecx,%eax
  8005ef:	29 c1                	sub    %eax,%ecx
  8005f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fa:	89 cb                	mov    %ecx,%ebx
  8005fc:	eb 16                	jmp    800614 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800602:	75 31                	jne    800635 <vprintfmt+0x217>
					putch(ch, putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	50                   	push   %eax
  80060b:	ff 55 08             	call   *0x8(%ebp)
  80060e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800611:	83 eb 01             	sub    $0x1,%ebx
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80061b:	0f be c2             	movsbl %dl,%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	74 59                	je     80067b <vprintfmt+0x25d>
  800622:	85 f6                	test   %esi,%esi
  800624:	78 d8                	js     8005fe <vprintfmt+0x1e0>
  800626:	83 ee 01             	sub    $0x1,%esi
  800629:	79 d3                	jns    8005fe <vprintfmt+0x1e0>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	eb 37                	jmp    80066c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800635:	0f be d2             	movsbl %dl,%edx
  800638:	83 ea 20             	sub    $0x20,%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 c4                	jbe    800604 <vprintfmt+0x1e6>
					putch('?', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 0c             	pushl  0xc(%ebp)
  800646:	6a 3f                	push   $0x3f
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb c1                	jmp    800611 <vprintfmt+0x1f3>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	eb b6                	jmp    800614 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 20                	push   $0x20
  800664:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800666:	83 ef 01             	sub    $0x1,%edi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	85 ff                	test   %edi,%edi
  80066e:	7f ee                	jg     80065e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800670:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
  800676:	e9 1a 01 00 00       	jmp    800795 <vprintfmt+0x377>
  80067b:	89 df                	mov    %ebx,%edi
  80067d:	8b 75 08             	mov    0x8(%ebp),%esi
  800680:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800683:	eb e7                	jmp    80066c <vprintfmt+0x24e>
	if (lflag >= 2)
  800685:	83 f9 01             	cmp    $0x1,%ecx
  800688:	7e 3f                	jle    8006c9 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 50 04             	mov    0x4(%eax),%edx
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a5:	79 5c                	jns    800703 <vprintfmt+0x2e5>
				putch('-', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 2d                	push   $0x2d
  8006ad:	ff d6                	call   *%esi
				num = -(long long) num;
  8006af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b5:	f7 da                	neg    %edx
  8006b7:	83 d1 00             	adc    $0x0,%ecx
  8006ba:	f7 d9                	neg    %ecx
  8006bc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 b2 00 00 00       	jmp    80077b <vprintfmt+0x35d>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	75 1b                	jne    8006e8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	89 c1                	mov    %eax,%ecx
  8006d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e6:	eb b9                	jmp    8006a1 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 c1                	mov    %eax,%ecx
  8006f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800701:	eb 9e                	jmp    8006a1 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800703:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800706:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	eb 6b                	jmp    80077b <vprintfmt+0x35d>
	if (lflag >= 2)
  800710:	83 f9 01             	cmp    $0x1,%ecx
  800713:	7e 15                	jle    80072a <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	8b 48 04             	mov    0x4(%eax),%ecx
  80071d:	8d 40 08             	lea    0x8(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
  800728:	eb 51                	jmp    80077b <vprintfmt+0x35d>
	else if (lflag)
  80072a:	85 c9                	test   %ecx,%ecx
  80072c:	75 17                	jne    800745 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800743:	eb 36                	jmp    80077b <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800755:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075a:	eb 1f                	jmp    80077b <vprintfmt+0x35d>
	if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7e 5b                	jle    8007bc <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 50 04             	mov    0x4(%eax),%edx
  800767:	8b 00                	mov    (%eax),%eax
  800769:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80076f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800772:	89 d1                	mov    %edx,%ecx
  800774:	89 c2                	mov    %eax,%edx
			base = 8;
  800776:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077b:	83 ec 0c             	sub    $0xc,%esp
  80077e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800782:	57                   	push   %edi
  800783:	ff 75 e0             	pushl  -0x20(%ebp)
  800786:	50                   	push   %eax
  800787:	51                   	push   %ecx
  800788:	52                   	push   %edx
  800789:	89 da                	mov    %ebx,%edx
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	e8 a3 fb ff ff       	call   800335 <printnum>
			break;
  800792:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800798:	83 c7 01             	add    $0x1,%edi
  80079b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079f:	83 f8 25             	cmp    $0x25,%eax
  8007a2:	0f 84 8d fc ff ff    	je     800435 <vprintfmt+0x17>
			if (ch == '\0')
  8007a8:	85 c0                	test   %eax,%eax
  8007aa:	0f 84 e8 00 00 00    	je     800898 <vprintfmt+0x47a>
			putch(ch, putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	50                   	push   %eax
  8007b5:	ff d6                	call   *%esi
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb dc                	jmp    800798 <vprintfmt+0x37a>
	else if (lflag)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	75 13                	jne    8007d3 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8b 10                	mov    (%eax),%edx
  8007c5:	89 d0                	mov    %edx,%eax
  8007c7:	99                   	cltd   
  8007c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007cb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d1:	eb 9f                	jmp    800772 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	89 d0                	mov    %edx,%eax
  8007da:	99                   	cltd   
  8007db:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007de:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007e4:	eb 8c                	jmp    800772 <vprintfmt+0x354>
			putch('0', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 30                	push   $0x30
  8007ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 78                	push   $0x78
  8007f4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800800:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800809:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80080e:	e9 68 ff ff ff       	jmp    80077b <vprintfmt+0x35d>
	if (lflag >= 2)
  800813:	83 f9 01             	cmp    $0x1,%ecx
  800816:	7e 18                	jle    800830 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8b 48 04             	mov    0x4(%eax),%ecx
  800820:	8d 40 08             	lea    0x8(%eax),%eax
  800823:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800826:	b8 10 00 00 00       	mov    $0x10,%eax
  80082b:	e9 4b ff ff ff       	jmp    80077b <vprintfmt+0x35d>
	else if (lflag)
  800830:	85 c9                	test   %ecx,%ecx
  800832:	75 1a                	jne    80084e <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	8d 40 04             	lea    0x4(%eax),%eax
  800841:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800844:	b8 10 00 00 00       	mov    $0x10,%eax
  800849:	e9 2d ff ff ff       	jmp    80077b <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8b 10                	mov    (%eax),%edx
  800853:	b9 00 00 00 00       	mov    $0x0,%ecx
  800858:	8d 40 04             	lea    0x4(%eax),%eax
  80085b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80085e:	b8 10 00 00 00       	mov    $0x10,%eax
  800863:	e9 13 ff ff ff       	jmp    80077b <vprintfmt+0x35d>
			putch(ch, putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 25                	push   $0x25
  80086e:	ff d6                	call   *%esi
			break;
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	e9 1d ff ff ff       	jmp    800795 <vprintfmt+0x377>
			putch('%', putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 25                	push   $0x25
  80087e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	89 f8                	mov    %edi,%eax
  800885:	eb 03                	jmp    80088a <vprintfmt+0x46c>
  800887:	83 e8 01             	sub    $0x1,%eax
  80088a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80088e:	75 f7                	jne    800887 <vprintfmt+0x469>
  800890:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800893:	e9 fd fe ff ff       	jmp    800795 <vprintfmt+0x377>
}
  800898:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	74 26                	je     8008e7 <vsnprintf+0x47>
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	7e 22                	jle    8008e7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c5:	ff 75 14             	pushl  0x14(%ebp)
  8008c8:	ff 75 10             	pushl  0x10(%ebp)
  8008cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	68 e4 03 80 00       	push   $0x8003e4
  8008d4:	e8 45 fb ff ff       	call   80041e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e2:	83 c4 10             	add    $0x10,%esp
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    
		return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ec:	eb f7                	jmp    8008e5 <vsnprintf+0x45>

008008ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f7:	50                   	push   %eax
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	ff 75 08             	pushl  0x8(%ebp)
  800901:	e8 9a ff ff ff       	call   8008a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
  800913:	eb 03                	jmp    800918 <strlen+0x10>
		n++;
  800915:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800918:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091c:	75 f7                	jne    800915 <strlen+0xd>
	return n;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 03                	jmp    800933 <strnlen+0x13>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800933:	39 d0                	cmp    %edx,%eax
  800935:	74 06                	je     80093d <strnlen+0x1d>
  800937:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093b:	75 f3                	jne    800930 <strnlen+0x10>
	return n;
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800949:	89 c2                	mov    %eax,%edx
  80094b:	83 c1 01             	add    $0x1,%ecx
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800955:	88 5a ff             	mov    %bl,-0x1(%edx)
  800958:	84 db                	test   %bl,%bl
  80095a:	75 ef                	jne    80094b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800966:	53                   	push   %ebx
  800967:	e8 9c ff ff ff       	call   800908 <strlen>
  80096c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	01 d8                	add    %ebx,%eax
  800974:	50                   	push   %eax
  800975:	e8 c5 ff ff ff       	call   80093f <strcpy>
	return dst;
}
  80097a:	89 d8                	mov    %ebx,%eax
  80097c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 75 08             	mov    0x8(%ebp),%esi
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098c:	89 f3                	mov    %esi,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800991:	89 f2                	mov    %esi,%edx
  800993:	eb 0f                	jmp    8009a4 <strncpy+0x23>
		*dst++ = *src;
  800995:	83 c2 01             	add    $0x1,%edx
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099e:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a1:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a4:	39 da                	cmp    %ebx,%edx
  8009a6:	75 ed                	jne    800995 <strncpy+0x14>
	}
	return ret;
}
  8009a8:	89 f0                	mov    %esi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bc:	89 f0                	mov    %esi,%eax
  8009be:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	85 c9                	test   %ecx,%ecx
  8009c4:	75 0b                	jne    8009d1 <strlcpy+0x23>
  8009c6:	eb 17                	jmp    8009df <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c8:	83 c2 01             	add    $0x1,%edx
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d1:	39 d8                	cmp    %ebx,%eax
  8009d3:	74 07                	je     8009dc <strlcpy+0x2e>
  8009d5:	0f b6 0a             	movzbl (%edx),%ecx
  8009d8:	84 c9                	test   %cl,%cl
  8009da:	75 ec                	jne    8009c8 <strlcpy+0x1a>
		*dst = '\0';
  8009dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009df:	29 f0                	sub    %esi,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ee:	eb 06                	jmp    8009f6 <strcmp+0x11>
		p++, q++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 04                	je     800a01 <strcmp+0x1c>
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	74 ef                	je     8009f0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a15:	89 c3                	mov    %eax,%ebx
  800a17:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1a:	eb 06                	jmp    800a22 <strncmp+0x17>
		n--, p++, q++;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a22:	39 d8                	cmp    %ebx,%eax
  800a24:	74 16                	je     800a3c <strncmp+0x31>
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	84 c9                	test   %cl,%cl
  800a2b:	74 04                	je     800a31 <strncmp+0x26>
  800a2d:	3a 0a                	cmp    (%edx),%cl
  800a2f:	74 eb                	je     800a1c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 00             	movzbl (%eax),%eax
  800a34:	0f b6 12             	movzbl (%edx),%edx
  800a37:	29 d0                	sub    %edx,%eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    
		return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb f6                	jmp    800a39 <strncmp+0x2e>

00800a43 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	74 09                	je     800a5d <strchr+0x1a>
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0a                	je     800a62 <strchr+0x1f>
	for (; *s; s++)
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	eb f0                	jmp    800a4d <strchr+0xa>
			return (char *) s;
	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6e:	eb 03                	jmp    800a73 <strfind+0xf>
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 04                	je     800a7e <strfind+0x1a>
  800a7a:	84 d2                	test   %dl,%dl
  800a7c:	75 f2                	jne    800a70 <strfind+0xc>
			break;
	return (char *) s;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8c:	85 c9                	test   %ecx,%ecx
  800a8e:	74 13                	je     800aa3 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a96:	75 05                	jne    800a9d <memset+0x1d>
  800a98:	f6 c1 03             	test   $0x3,%cl
  800a9b:	74 0d                	je     800aaa <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	fc                   	cld    
  800aa1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa3:	89 f8                	mov    %edi,%eax
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    
		c &= 0xFF;
  800aaa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	c1 e3 08             	shl    $0x8,%ebx
  800ab3:	89 d0                	mov    %edx,%eax
  800ab5:	c1 e0 18             	shl    $0x18,%eax
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	c1 e6 10             	shl    $0x10,%esi
  800abd:	09 f0                	or     %esi,%eax
  800abf:	09 c2                	or     %eax,%edx
  800ac1:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac6:	89 d0                	mov    %edx,%eax
  800ac8:	fc                   	cld    
  800ac9:	f3 ab                	rep stos %eax,%es:(%edi)
  800acb:	eb d6                	jmp    800aa3 <memset+0x23>

00800acd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800adb:	39 c6                	cmp    %eax,%esi
  800add:	73 35                	jae    800b14 <memmove+0x47>
  800adf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae2:	39 c2                	cmp    %eax,%edx
  800ae4:	76 2e                	jbe    800b14 <memmove+0x47>
		s += n;
		d += n;
  800ae6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	09 fe                	or     %edi,%esi
  800aed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af3:	74 0c                	je     800b01 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af5:	83 ef 01             	sub    $0x1,%edi
  800af8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800afb:	fd                   	std    
  800afc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afe:	fc                   	cld    
  800aff:	eb 21                	jmp    800b22 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b01:	f6 c1 03             	test   $0x3,%cl
  800b04:	75 ef                	jne    800af5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b06:	83 ef 04             	sub    $0x4,%edi
  800b09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0f:	fd                   	std    
  800b10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b12:	eb ea                	jmp    800afe <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b14:	89 f2                	mov    %esi,%edx
  800b16:	09 c2                	or     %eax,%edx
  800b18:	f6 c2 03             	test   $0x3,%dl
  800b1b:	74 09                	je     800b26 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	fc                   	cld    
  800b20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 f2                	jne    800b1d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb ed                	jmp    800b22 <memmove+0x55>

00800b35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b38:	ff 75 10             	pushl  0x10(%ebp)
  800b3b:	ff 75 0c             	pushl  0xc(%ebp)
  800b3e:	ff 75 08             	pushl  0x8(%ebp)
  800b41:	e8 87 ff ff ff       	call   800acd <memmove>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b58:	39 f0                	cmp    %esi,%eax
  800b5a:	74 1c                	je     800b78 <memcmp+0x30>
		if (*s1 != *s2)
  800b5c:	0f b6 08             	movzbl (%eax),%ecx
  800b5f:	0f b6 1a             	movzbl (%edx),%ebx
  800b62:	38 d9                	cmp    %bl,%cl
  800b64:	75 08                	jne    800b6e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	83 c2 01             	add    $0x1,%edx
  800b6c:	eb ea                	jmp    800b58 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6e:	0f b6 c1             	movzbl %cl,%eax
  800b71:	0f b6 db             	movzbl %bl,%ebx
  800b74:	29 d8                	sub    %ebx,%eax
  800b76:	eb 05                	jmp    800b7d <memcmp+0x35>
	}

	return 0;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8f:	39 d0                	cmp    %edx,%eax
  800b91:	73 09                	jae    800b9c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b93:	38 08                	cmp    %cl,(%eax)
  800b95:	74 05                	je     800b9c <memfind+0x1b>
	for (; s < ends; s++)
  800b97:	83 c0 01             	add    $0x1,%eax
  800b9a:	eb f3                	jmp    800b8f <memfind+0xe>
			break;
	return (void *) s;
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	eb 03                	jmp    800baf <strtol+0x11>
		s++;
  800bac:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800baf:	0f b6 01             	movzbl (%ecx),%eax
  800bb2:	3c 20                	cmp    $0x20,%al
  800bb4:	74 f6                	je     800bac <strtol+0xe>
  800bb6:	3c 09                	cmp    $0x9,%al
  800bb8:	74 f2                	je     800bac <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bba:	3c 2b                	cmp    $0x2b,%al
  800bbc:	74 2e                	je     800bec <strtol+0x4e>
	int neg = 0;
  800bbe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc3:	3c 2d                	cmp    $0x2d,%al
  800bc5:	74 2f                	je     800bf6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcd:	75 05                	jne    800bd4 <strtol+0x36>
  800bcf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd2:	74 2c                	je     800c00 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	75 0a                	jne    800be2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bdd:	80 39 30             	cmpb   $0x30,(%ecx)
  800be0:	74 28                	je     800c0a <strtol+0x6c>
		base = 10;
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
  800be7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bea:	eb 50                	jmp    800c3c <strtol+0x9e>
		s++;
  800bec:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf4:	eb d1                	jmp    800bc7 <strtol+0x29>
		s++, neg = 1;
  800bf6:	83 c1 01             	add    $0x1,%ecx
  800bf9:	bf 01 00 00 00       	mov    $0x1,%edi
  800bfe:	eb c7                	jmp    800bc7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c04:	74 0e                	je     800c14 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c06:	85 db                	test   %ebx,%ebx
  800c08:	75 d8                	jne    800be2 <strtol+0x44>
		s++, base = 8;
  800c0a:	83 c1 01             	add    $0x1,%ecx
  800c0d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c12:	eb ce                	jmp    800be2 <strtol+0x44>
		s += 2, base = 16;
  800c14:	83 c1 02             	add    $0x2,%ecx
  800c17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1c:	eb c4                	jmp    800be2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c21:	89 f3                	mov    %esi,%ebx
  800c23:	80 fb 19             	cmp    $0x19,%bl
  800c26:	77 29                	ja     800c51 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c28:	0f be d2             	movsbl %dl,%edx
  800c2b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c31:	7d 30                	jge    800c63 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c33:	83 c1 01             	add    $0x1,%ecx
  800c36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c3c:	0f b6 11             	movzbl (%ecx),%edx
  800c3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c42:	89 f3                	mov    %esi,%ebx
  800c44:	80 fb 09             	cmp    $0x9,%bl
  800c47:	77 d5                	ja     800c1e <strtol+0x80>
			dig = *s - '0';
  800c49:	0f be d2             	movsbl %dl,%edx
  800c4c:	83 ea 30             	sub    $0x30,%edx
  800c4f:	eb dd                	jmp    800c2e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c54:	89 f3                	mov    %esi,%ebx
  800c56:	80 fb 19             	cmp    $0x19,%bl
  800c59:	77 08                	ja     800c63 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c5b:	0f be d2             	movsbl %dl,%edx
  800c5e:	83 ea 37             	sub    $0x37,%edx
  800c61:	eb cb                	jmp    800c2e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c67:	74 05                	je     800c6e <strtol+0xd0>
		*endptr = (char *) s;
  800c69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	f7 da                	neg    %edx
  800c72:	85 ff                	test   %edi,%edi
  800c74:	0f 45 c2             	cmovne %edx,%eax
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	89 c3                	mov    %eax,%ebx
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	89 c6                	mov    %eax,%esi
  800c93:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccf:	89 cb                	mov    %ecx,%ebx
  800cd1:	89 cf                	mov    %ecx,%edi
  800cd3:	89 ce                	mov    %ecx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7f 08                	jg     800ce3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 03                	push   $0x3
  800ce9:	68 64 14 80 00       	push   $0x801464
  800cee:	6a 23                	push   $0x23
  800cf0:	68 81 14 80 00       	push   $0x801481
  800cf5:	e8 4c f5 ff ff       	call   800246 <_panic>

00800cfa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	89 d7                	mov    %edx,%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_yield>:

void
sys_yield(void)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d29:	89 d1                	mov    %edx,%ecx
  800d2b:	89 d3                	mov    %edx,%ebx
  800d2d:	89 d7                	mov    %edx,%edi
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	89 f7                	mov    %esi,%edi
  800d56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7f 08                	jg     800d64 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 04                	push   $0x4
  800d6a:	68 64 14 80 00       	push   $0x801464
  800d6f:	6a 23                	push   $0x23
  800d71:	68 81 14 80 00       	push   $0x801481
  800d76:	e8 cb f4 ff ff       	call   800246 <_panic>

00800d7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d95:	8b 75 18             	mov    0x18(%ebp),%esi
  800d98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7f 08                	jg     800da6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 05                	push   $0x5
  800dac:	68 64 14 80 00       	push   $0x801464
  800db1:	6a 23                	push   $0x23
  800db3:	68 81 14 80 00       	push   $0x801481
  800db8:	e8 89 f4 ff ff       	call   800246 <_panic>

00800dbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7f 08                	jg     800de8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 06                	push   $0x6
  800dee:	68 64 14 80 00       	push   $0x801464
  800df3:	6a 23                	push   $0x23
  800df5:	68 81 14 80 00       	push   $0x801481
  800dfa:	e8 47 f4 ff ff       	call   800246 <_panic>

00800dff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	b8 08 00 00 00       	mov    $0x8,%eax
  800e18:	89 df                	mov    %ebx,%edi
  800e1a:	89 de                	mov    %ebx,%esi
  800e1c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	7f 08                	jg     800e2a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	83 ec 0c             	sub    $0xc,%esp
  800e2d:	50                   	push   %eax
  800e2e:	6a 08                	push   $0x8
  800e30:	68 64 14 80 00       	push   $0x801464
  800e35:	6a 23                	push   $0x23
  800e37:	68 81 14 80 00       	push   $0x801481
  800e3c:	e8 05 f4 ff ff       	call   800246 <_panic>

00800e41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5a:	89 df                	mov    %ebx,%edi
  800e5c:	89 de                	mov    %ebx,%esi
  800e5e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7f 08                	jg     800e6c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 09                	push   $0x9
  800e72:	68 64 14 80 00       	push   $0x801464
  800e77:	6a 23                	push   $0x23
  800e79:	68 81 14 80 00       	push   $0x801481
  800e7e:	e8 c3 f3 ff ff       	call   800246 <_panic>

00800e83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e94:	be 00 00 00 00       	mov    $0x0,%esi
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebc:	89 cb                	mov    %ecx,%ebx
  800ebe:	89 cf                	mov    %ecx,%edi
  800ec0:	89 ce                	mov    %ecx,%esi
  800ec2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7f 08                	jg     800ed0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	50                   	push   %eax
  800ed4:	6a 0c                	push   $0xc
  800ed6:	68 64 14 80 00       	push   $0x801464
  800edb:	6a 23                	push   $0x23
  800edd:	68 81 14 80 00       	push   $0x801481
  800ee2:	e8 5f f3 ff ff       	call   800246 <_panic>
  800ee7:	66 90                	xchg   %ax,%ax
  800ee9:	66 90                	xchg   %ax,%ax
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f07:	85 d2                	test   %edx,%edx
  800f09:	75 35                	jne    800f40 <__udivdi3+0x50>
  800f0b:	39 f3                	cmp    %esi,%ebx
  800f0d:	0f 87 bd 00 00 00    	ja     800fd0 <__udivdi3+0xe0>
  800f13:	85 db                	test   %ebx,%ebx
  800f15:	89 d9                	mov    %ebx,%ecx
  800f17:	75 0b                	jne    800f24 <__udivdi3+0x34>
  800f19:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1e:	31 d2                	xor    %edx,%edx
  800f20:	f7 f3                	div    %ebx
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	31 d2                	xor    %edx,%edx
  800f26:	89 f0                	mov    %esi,%eax
  800f28:	f7 f1                	div    %ecx
  800f2a:	89 c6                	mov    %eax,%esi
  800f2c:	89 e8                	mov    %ebp,%eax
  800f2e:	89 f7                	mov    %esi,%edi
  800f30:	f7 f1                	div    %ecx
  800f32:	89 fa                	mov    %edi,%edx
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	39 f2                	cmp    %esi,%edx
  800f42:	77 7c                	ja     800fc0 <__udivdi3+0xd0>
  800f44:	0f bd fa             	bsr    %edx,%edi
  800f47:	83 f7 1f             	xor    $0x1f,%edi
  800f4a:	0f 84 98 00 00 00    	je     800fe8 <__udivdi3+0xf8>
  800f50:	89 f9                	mov    %edi,%ecx
  800f52:	b8 20 00 00 00       	mov    $0x20,%eax
  800f57:	29 f8                	sub    %edi,%eax
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	89 da                	mov    %ebx,%edx
  800f63:	d3 ea                	shr    %cl,%edx
  800f65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f69:	09 d1                	or     %edx,%ecx
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e3                	shl    %cl,%ebx
  800f75:	89 c1                	mov    %eax,%ecx
  800f77:	d3 ea                	shr    %cl,%edx
  800f79:	89 f9                	mov    %edi,%ecx
  800f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f7f:	d3 e6                	shl    %cl,%esi
  800f81:	89 eb                	mov    %ebp,%ebx
  800f83:	89 c1                	mov    %eax,%ecx
  800f85:	d3 eb                	shr    %cl,%ebx
  800f87:	09 de                	or     %ebx,%esi
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	f7 74 24 08          	divl   0x8(%esp)
  800f8f:	89 d6                	mov    %edx,%esi
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	f7 64 24 0c          	mull   0xc(%esp)
  800f97:	39 d6                	cmp    %edx,%esi
  800f99:	72 0c                	jb     800fa7 <__udivdi3+0xb7>
  800f9b:	89 f9                	mov    %edi,%ecx
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	39 c5                	cmp    %eax,%ebp
  800fa1:	73 5d                	jae    801000 <__udivdi3+0x110>
  800fa3:	39 d6                	cmp    %edx,%esi
  800fa5:	75 59                	jne    801000 <__udivdi3+0x110>
  800fa7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800faa:	31 ff                	xor    %edi,%edi
  800fac:	89 fa                	mov    %edi,%edx
  800fae:	83 c4 1c             	add    $0x1c,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    
  800fb6:	8d 76 00             	lea    0x0(%esi),%esi
  800fb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800fc0:	31 ff                	xor    %edi,%edi
  800fc2:	31 c0                	xor    %eax,%eax
  800fc4:	89 fa                	mov    %edi,%edx
  800fc6:	83 c4 1c             	add    $0x1c,%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
  800fce:	66 90                	xchg   %ax,%ax
  800fd0:	31 ff                	xor    %edi,%edi
  800fd2:	89 e8                	mov    %ebp,%eax
  800fd4:	89 f2                	mov    %esi,%edx
  800fd6:	f7 f3                	div    %ebx
  800fd8:	89 fa                	mov    %edi,%edx
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	39 f2                	cmp    %esi,%edx
  800fea:	72 06                	jb     800ff2 <__udivdi3+0x102>
  800fec:	31 c0                	xor    %eax,%eax
  800fee:	39 eb                	cmp    %ebp,%ebx
  800ff0:	77 d2                	ja     800fc4 <__udivdi3+0xd4>
  800ff2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff7:	eb cb                	jmp    800fc4 <__udivdi3+0xd4>
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	89 d8                	mov    %ebx,%eax
  801002:	31 ff                	xor    %edi,%edi
  801004:	eb be                	jmp    800fc4 <__udivdi3+0xd4>
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80101b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80101f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801027:	85 ed                	test   %ebp,%ebp
  801029:	89 f0                	mov    %esi,%eax
  80102b:	89 da                	mov    %ebx,%edx
  80102d:	75 19                	jne    801048 <__umoddi3+0x38>
  80102f:	39 df                	cmp    %ebx,%edi
  801031:	0f 86 b1 00 00 00    	jbe    8010e8 <__umoddi3+0xd8>
  801037:	f7 f7                	div    %edi
  801039:	89 d0                	mov    %edx,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	83 c4 1c             	add    $0x1c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	39 dd                	cmp    %ebx,%ebp
  80104a:	77 f1                	ja     80103d <__umoddi3+0x2d>
  80104c:	0f bd cd             	bsr    %ebp,%ecx
  80104f:	83 f1 1f             	xor    $0x1f,%ecx
  801052:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801056:	0f 84 b4 00 00 00    	je     801110 <__umoddi3+0x100>
  80105c:	b8 20 00 00 00       	mov    $0x20,%eax
  801061:	89 c2                	mov    %eax,%edx
  801063:	8b 44 24 04          	mov    0x4(%esp),%eax
  801067:	29 c2                	sub    %eax,%edx
  801069:	89 c1                	mov    %eax,%ecx
  80106b:	89 f8                	mov    %edi,%eax
  80106d:	d3 e5                	shl    %cl,%ebp
  80106f:	89 d1                	mov    %edx,%ecx
  801071:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801075:	d3 e8                	shr    %cl,%eax
  801077:	09 c5                	or     %eax,%ebp
  801079:	8b 44 24 04          	mov    0x4(%esp),%eax
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	d3 e7                	shl    %cl,%edi
  801081:	89 d1                	mov    %edx,%ecx
  801083:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801087:	89 df                	mov    %ebx,%edi
  801089:	d3 ef                	shr    %cl,%edi
  80108b:	89 c1                	mov    %eax,%ecx
  80108d:	89 f0                	mov    %esi,%eax
  80108f:	d3 e3                	shl    %cl,%ebx
  801091:	89 d1                	mov    %edx,%ecx
  801093:	89 fa                	mov    %edi,%edx
  801095:	d3 e8                	shr    %cl,%eax
  801097:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109c:	09 d8                	or     %ebx,%eax
  80109e:	f7 f5                	div    %ebp
  8010a0:	d3 e6                	shl    %cl,%esi
  8010a2:	89 d1                	mov    %edx,%ecx
  8010a4:	f7 64 24 08          	mull   0x8(%esp)
  8010a8:	39 d1                	cmp    %edx,%ecx
  8010aa:	89 c3                	mov    %eax,%ebx
  8010ac:	89 d7                	mov    %edx,%edi
  8010ae:	72 06                	jb     8010b6 <__umoddi3+0xa6>
  8010b0:	75 0e                	jne    8010c0 <__umoddi3+0xb0>
  8010b2:	39 c6                	cmp    %eax,%esi
  8010b4:	73 0a                	jae    8010c0 <__umoddi3+0xb0>
  8010b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8010ba:	19 ea                	sbb    %ebp,%edx
  8010bc:	89 d7                	mov    %edx,%edi
  8010be:	89 c3                	mov    %eax,%ebx
  8010c0:	89 ca                	mov    %ecx,%edx
  8010c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8010c7:	29 de                	sub    %ebx,%esi
  8010c9:	19 fa                	sbb    %edi,%edx
  8010cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8010cf:	89 d0                	mov    %edx,%eax
  8010d1:	d3 e0                	shl    %cl,%eax
  8010d3:	89 d9                	mov    %ebx,%ecx
  8010d5:	d3 ee                	shr    %cl,%esi
  8010d7:	d3 ea                	shr    %cl,%edx
  8010d9:	09 f0                	or     %esi,%eax
  8010db:	83 c4 1c             	add    $0x1c,%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    
  8010e3:	90                   	nop
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	85 ff                	test   %edi,%edi
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	75 0b                	jne    8010f9 <__umoddi3+0xe9>
  8010ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f7                	div    %edi
  8010f7:	89 c1                	mov    %eax,%ecx
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	f7 f1                	div    %ecx
  8010ff:	89 f0                	mov    %esi,%eax
  801101:	f7 f1                	div    %ecx
  801103:	e9 31 ff ff ff       	jmp    801039 <__umoddi3+0x29>
  801108:	90                   	nop
  801109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801110:	39 dd                	cmp    %ebx,%ebp
  801112:	72 08                	jb     80111c <__umoddi3+0x10c>
  801114:	39 f7                	cmp    %esi,%edi
  801116:	0f 87 21 ff ff ff    	ja     80103d <__umoddi3+0x2d>
  80111c:	89 da                	mov    %ebx,%edx
  80111e:	89 f0                	mov    %esi,%eax
  801120:	29 f8                	sub    %edi,%eax
  801122:	19 ea                	sbb    %ebp,%edx
  801124:	e9 14 ff ff ff       	jmp    80103d <__umoddi3+0x2d>
