
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 c1 0b 00 00       	call   800bfe <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 a2 0d 00 00       	call   800deb <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 c3 0b 00 00       	call   800c1d <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 98 0b 00 00       	call   800c1d <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 20 80 00       	mov    0x802004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 9b 10 80 00       	push   $0x80109b
  8000c2:	e8 5e 01 00 00       	call   800225 <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 60 10 80 00       	push   $0x801060
  8000dc:	6a 21                	push   $0x21
  8000de:	68 88 10 80 00       	push   $0x801088
  8000e3:	e8 62 00 00 00       	call   80014a <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f3:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8000fa:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000fd:	e8 fc 0a 00 00       	call   800bfe <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800102:	25 ff 03 00 00       	and    $0x3ff,%eax
  800107:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010f:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800114:	85 db                	test   %ebx,%ebx
  800116:	7e 07                	jle    80011f <libmain+0x37>
		binaryname = argv[0];
  800118:	8b 06                	mov    (%esi),%eax
  80011a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011f:	83 ec 08             	sub    $0x8,%esp
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
  800124:	e8 0a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800129:	e8 0a 00 00 00       	call   800138 <exit>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5d                   	pop    %ebp
  800137:	c3                   	ret    

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013e:	6a 00                	push   $0x0
  800140:	e8 78 0a 00 00       	call   800bbd <sys_env_destroy>
}
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800152:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800158:	e8 a1 0a 00 00       	call   800bfe <sys_getenvid>
  80015d:	83 ec 0c             	sub    $0xc,%esp
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	56                   	push   %esi
  800167:	50                   	push   %eax
  800168:	68 c4 10 80 00       	push   $0x8010c4
  80016d:	e8 b3 00 00 00       	call   800225 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800172:	83 c4 18             	add    $0x18,%esp
  800175:	53                   	push   %ebx
  800176:	ff 75 10             	pushl  0x10(%ebp)
  800179:	e8 56 00 00 00       	call   8001d4 <vcprintf>
	cprintf("\n");
  80017e:	c7 04 24 b7 10 80 00 	movl   $0x8010b7,(%esp)
  800185:	e8 9b 00 00 00       	call   800225 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018d:	cc                   	int3   
  80018e:	eb fd                	jmp    80018d <_panic+0x43>

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 04             	sub    $0x4,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 13                	mov    (%ebx),%edx
  80019c:	8d 42 01             	lea    0x1(%edx),%eax
  80019f:	89 03                	mov    %eax,(%ebx)
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ad:	74 09                	je     8001b8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	68 ff 00 00 00       	push   $0xff
  8001c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c3:	50                   	push   %eax
  8001c4:	e8 b7 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  8001c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb db                	jmp    8001af <putch+0x1f>

008001d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	ff 75 08             	pushl  0x8(%ebp)
  8001f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	68 90 01 80 00       	push   $0x800190
  800203:	e8 1a 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800208:	83 c4 08             	add    $0x8,%esp
  80020b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800211:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800217:	50                   	push   %eax
  800218:	e8 63 09 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  80021d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022e:	50                   	push   %eax
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	e8 9d ff ff ff       	call   8001d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 1c             	sub    $0x1c,%esp
  800242:	89 c7                	mov    %eax,%edi
  800244:	89 d6                	mov    %edx,%esi
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800252:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800260:	39 d3                	cmp    %edx,%ebx
  800262:	72 05                	jb     800269 <printnum+0x30>
  800264:	39 45 10             	cmp    %eax,0x10(%ebp)
  800267:	77 7a                	ja     8002e3 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	ff 75 18             	pushl  0x18(%ebp)
  80026f:	8b 45 14             	mov    0x14(%ebp),%eax
  800272:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800275:	53                   	push   %ebx
  800276:	ff 75 10             	pushl  0x10(%ebp)
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027f:	ff 75 e0             	pushl  -0x20(%ebp)
  800282:	ff 75 dc             	pushl  -0x24(%ebp)
  800285:	ff 75 d8             	pushl  -0x28(%ebp)
  800288:	e8 93 0b 00 00       	call   800e20 <__udivdi3>
  80028d:	83 c4 18             	add    $0x18,%esp
  800290:	52                   	push   %edx
  800291:	50                   	push   %eax
  800292:	89 f2                	mov    %esi,%edx
  800294:	89 f8                	mov    %edi,%eax
  800296:	e8 9e ff ff ff       	call   800239 <printnum>
  80029b:	83 c4 20             	add    $0x20,%esp
  80029e:	eb 13                	jmp    8002b3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	ff 75 18             	pushl  0x18(%ebp)
  8002a7:	ff d7                	call   *%edi
  8002a9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ac:	83 eb 01             	sub    $0x1,%ebx
  8002af:	85 db                	test   %ebx,%ebx
  8002b1:	7f ed                	jg     8002a0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	56                   	push   %esi
  8002b7:	83 ec 04             	sub    $0x4,%esp
  8002ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c6:	e8 75 0c 00 00       	call   800f40 <__umoddi3>
  8002cb:	83 c4 14             	add    $0x14,%esp
  8002ce:	0f be 80 e8 10 80 00 	movsbl 0x8010e8(%eax),%eax
  8002d5:	50                   	push   %eax
  8002d6:	ff d7                	call   *%edi
}
  8002d8:	83 c4 10             	add    $0x10,%esp
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    
  8002e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e6:	eb c4                	jmp    8002ac <printnum+0x73>

008002e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f7:	73 0a                	jae    800303 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	88 02                	mov    %al,(%edx)
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <printfmt>:
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	e8 05 00 00 00       	call   800322 <vprintfmt>
}
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 2c             	sub    $0x2c,%esp
  80032b:	8b 75 08             	mov    0x8(%ebp),%esi
  80032e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800331:	8b 7d 10             	mov    0x10(%ebp),%edi
  800334:	e9 63 03 00 00       	jmp    80069c <vprintfmt+0x37a>
		padc = ' ';
  800339:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80033d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800344:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80034b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8d 47 01             	lea    0x1(%edi),%eax
  80035a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035d:	0f b6 17             	movzbl (%edi),%edx
  800360:	8d 42 dd             	lea    -0x23(%edx),%eax
  800363:	3c 55                	cmp    $0x55,%al
  800365:	0f 87 11 04 00 00    	ja     80077c <vprintfmt+0x45a>
  80036b:	0f b6 c0             	movzbl %al,%eax
  80036e:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037c:	eb d9                	jmp    800357 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800381:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800385:	eb d0                	jmp    800357 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800387:	0f b6 d2             	movzbl %dl,%edx
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038d:	b8 00 00 00 00       	mov    $0x0,%eax
  800392:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800395:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800398:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	77 55                	ja     8003fc <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003aa:	eb e9                	jmp    800395 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 40 04             	lea    0x4(%eax),%eax
  8003ba:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c4:	79 91                	jns    800357 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d3:	eb 82                	jmp    800357 <vprintfmt+0x35>
  8003d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	ba 00 00 00 00       	mov    $0x0,%edx
  8003df:	0f 49 d0             	cmovns %eax,%edx
  8003e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	e9 6a ff ff ff       	jmp    800357 <vprintfmt+0x35>
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f7:	e9 5b ff ff ff       	jmp    800357 <vprintfmt+0x35>
  8003fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800402:	eb bc                	jmp    8003c0 <vprintfmt+0x9e>
			lflag++;
  800404:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040a:	e9 48 ff ff ff       	jmp    800357 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 78 04             	lea    0x4(%eax),%edi
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 30                	pushl  (%eax)
  80041b:	ff d6                	call   *%esi
			break;
  80041d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800423:	e9 71 02 00 00       	jmp    800699 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 08             	cmp    $0x8,%eax
  800438:	7f 23                	jg     80045d <vprintfmt+0x13b>
  80043a:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	74 18                	je     80045d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 09 11 80 00       	push   $0x801109
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 b3 fe ff ff       	call   800305 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
  800458:	e9 3c 02 00 00       	jmp    800699 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80045d:	50                   	push   %eax
  80045e:	68 00 11 80 00       	push   $0x801100
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 9b fe ff ff       	call   800305 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 24 02 00 00       	jmp    800699 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	83 c0 04             	add    $0x4,%eax
  80047b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800483:	85 ff                	test   %edi,%edi
  800485:	b8 f9 10 80 00       	mov    $0x8010f9,%eax
  80048a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800491:	0f 8e bd 00 00 00    	jle    800554 <vprintfmt+0x232>
  800497:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049b:	75 0e                	jne    8004ab <vprintfmt+0x189>
  80049d:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a9:	eb 6d                	jmp    800518 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b1:	57                   	push   %edi
  8004b2:	e8 6d 03 00 00       	call   800824 <strnlen>
  8004b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cc:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	eb 0f                	jmp    8004df <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ef 01             	sub    $0x1,%edi
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	7f ed                	jg     8004d0 <vprintfmt+0x1ae>
  8004e3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	0f 49 c1             	cmovns %ecx,%eax
  8004f3:	29 c1                	sub    %eax,%ecx
  8004f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fe:	89 cb                	mov    %ecx,%ebx
  800500:	eb 16                	jmp    800518 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800506:	75 31                	jne    800539 <vprintfmt+0x217>
					putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	50                   	push   %eax
  80050f:	ff 55 08             	call   *0x8(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800515:	83 eb 01             	sub    $0x1,%ebx
  800518:	83 c7 01             	add    $0x1,%edi
  80051b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80051f:	0f be c2             	movsbl %dl,%eax
  800522:	85 c0                	test   %eax,%eax
  800524:	74 59                	je     80057f <vprintfmt+0x25d>
  800526:	85 f6                	test   %esi,%esi
  800528:	78 d8                	js     800502 <vprintfmt+0x1e0>
  80052a:	83 ee 01             	sub    $0x1,%esi
  80052d:	79 d3                	jns    800502 <vprintfmt+0x1e0>
  80052f:	89 df                	mov    %ebx,%edi
  800531:	8b 75 08             	mov    0x8(%ebp),%esi
  800534:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800537:	eb 37                	jmp    800570 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	0f be d2             	movsbl %dl,%edx
  80053c:	83 ea 20             	sub    $0x20,%edx
  80053f:	83 fa 5e             	cmp    $0x5e,%edx
  800542:	76 c4                	jbe    800508 <vprintfmt+0x1e6>
					putch('?', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	6a 3f                	push   $0x3f
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	eb c1                	jmp    800515 <vprintfmt+0x1f3>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb b6                	jmp    800518 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	6a 20                	push   $0x20
  800568:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056a:	83 ef 01             	sub    $0x1,%edi
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	85 ff                	test   %edi,%edi
  800572:	7f ee                	jg     800562 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800574:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	e9 1a 01 00 00       	jmp    800699 <vprintfmt+0x377>
  80057f:	89 df                	mov    %ebx,%edi
  800581:	8b 75 08             	mov    0x8(%ebp),%esi
  800584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800587:	eb e7                	jmp    800570 <vprintfmt+0x24e>
	if (lflag >= 2)
  800589:	83 f9 01             	cmp    $0x1,%ecx
  80058c:	7e 3f                	jle    8005cd <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 50 04             	mov    0x4(%eax),%edx
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 08             	lea    0x8(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a9:	79 5c                	jns    800607 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 2d                	push   $0x2d
  8005b1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b9:	f7 da                	neg    %edx
  8005bb:	83 d1 00             	adc    $0x0,%ecx
  8005be:	f7 d9                	neg    %ecx
  8005c0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c8:	e9 b2 00 00 00       	jmp    80067f <vprintfmt+0x35d>
	else if (lflag)
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	75 1b                	jne    8005ec <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ea:	eb b9                	jmp    8005a5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	eb 9e                	jmp    8005a5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800607:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	eb 6b                	jmp    80067f <vprintfmt+0x35d>
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7e 15                	jle    80062e <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	8b 48 04             	mov    0x4(%eax),%ecx
  800621:	8d 40 08             	lea    0x8(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	eb 51                	jmp    80067f <vprintfmt+0x35d>
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	75 17                	jne    800649 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	eb 36                	jmp    80067f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	eb 1f                	jmp    80067f <vprintfmt+0x35d>
	if (lflag >= 2)
  800660:	83 f9 01             	cmp    $0x1,%ecx
  800663:	7e 5b                	jle    8006c0 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 50 04             	mov    0x4(%eax),%edx
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800670:	8d 49 08             	lea    0x8(%ecx),%ecx
  800673:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800676:	89 d1                	mov    %edx,%ecx
  800678:	89 c2                	mov    %eax,%edx
			base = 8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800686:	57                   	push   %edi
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	50                   	push   %eax
  80068b:	51                   	push   %ecx
  80068c:	52                   	push   %edx
  80068d:	89 da                	mov    %ebx,%edx
  80068f:	89 f0                	mov    %esi,%eax
  800691:	e8 a3 fb ff ff       	call   800239 <printnum>
			break;
  800696:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80069c:	83 c7 01             	add    $0x1,%edi
  80069f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a3:	83 f8 25             	cmp    $0x25,%eax
  8006a6:	0f 84 8d fc ff ff    	je     800339 <vprintfmt+0x17>
			if (ch == '\0')
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	0f 84 e8 00 00 00    	je     80079c <vprintfmt+0x47a>
			putch(ch, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	50                   	push   %eax
  8006b9:	ff d6                	call   *%esi
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb dc                	jmp    80069c <vprintfmt+0x37a>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	75 13                	jne    8006d7 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	89 d0                	mov    %edx,%eax
  8006cb:	99                   	cltd   
  8006cc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006cf:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d5:	eb 9f                	jmp    800676 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	99                   	cltd   
  8006df:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e8:	eb 8c                	jmp    800676 <vprintfmt+0x354>
			putch('0', putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 30                	push   $0x30
  8006f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f2:	83 c4 08             	add    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 78                	push   $0x78
  8006f8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800704:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800707:	8d 40 04             	lea    0x4(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800712:	e9 68 ff ff ff       	jmp    80067f <vprintfmt+0x35d>
	if (lflag >= 2)
  800717:	83 f9 01             	cmp    $0x1,%ecx
  80071a:	7e 18                	jle    800734 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	8b 48 04             	mov    0x4(%eax),%ecx
  800724:	8d 40 08             	lea    0x8(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
  80072f:	e9 4b ff ff ff       	jmp    80067f <vprintfmt+0x35d>
	else if (lflag)
  800734:	85 c9                	test   %ecx,%ecx
  800736:	75 1a                	jne    800752 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800748:	b8 10 00 00 00       	mov    $0x10,%eax
  80074d:	e9 2d ff ff ff       	jmp    80067f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 10                	mov    (%eax),%edx
  800757:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075c:	8d 40 04             	lea    0x4(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
  800767:	e9 13 ff ff ff       	jmp    80067f <vprintfmt+0x35d>
			putch(ch, putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 25                	push   $0x25
  800772:	ff d6                	call   *%esi
			break;
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	e9 1d ff ff ff       	jmp    800699 <vprintfmt+0x377>
			putch('%', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 25                	push   $0x25
  800782:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	89 f8                	mov    %edi,%eax
  800789:	eb 03                	jmp    80078e <vprintfmt+0x46c>
  80078b:	83 e8 01             	sub    $0x1,%eax
  80078e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800792:	75 f7                	jne    80078b <vprintfmt+0x469>
  800794:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800797:	e9 fd fe ff ff       	jmp    800699 <vprintfmt+0x377>
}
  80079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5f                   	pop    %edi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 18             	sub    $0x18,%esp
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	74 26                	je     8007eb <vsnprintf+0x47>
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	7e 22                	jle    8007eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c9:	ff 75 14             	pushl  0x14(%ebp)
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	68 e8 02 80 00       	push   $0x8002e8
  8007d8:	e8 45 fb ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e6:	83 c4 10             	add    $0x10,%esp
}
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    
		return -E_INVAL;
  8007eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f0:	eb f7                	jmp    8007e9 <vsnprintf+0x45>

008007f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 10             	pushl  0x10(%ebp)
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	ff 75 08             	pushl  0x8(%ebp)
  800805:	e8 9a ff ff ff       	call   8007a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	eb 03                	jmp    80081c <strlen+0x10>
		n++;
  800819:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800820:	75 f7                	jne    800819 <strlen+0xd>
	return n;
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
  800832:	eb 03                	jmp    800837 <strnlen+0x13>
		n++;
  800834:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800837:	39 d0                	cmp    %edx,%eax
  800839:	74 06                	je     800841 <strnlen+0x1d>
  80083b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083f:	75 f3                	jne    800834 <strnlen+0x10>
	return n;
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ef                	jne    80084f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086a:	53                   	push   %ebx
  80086b:	e8 9c ff ff ff       	call   80080c <strlen>
  800870:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	01 d8                	add    %ebx,%eax
  800878:	50                   	push   %eax
  800879:	e8 c5 ff ff ff       	call   800843 <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800890:	89 f3                	mov    %esi,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	89 f2                	mov    %esi,%edx
  800897:	eb 0f                	jmp    8008a8 <strncpy+0x23>
		*dst++ = *src;
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008a8:	39 da                	cmp    %ebx,%edx
  8008aa:	75 ed                	jne    800899 <strncpy+0x14>
	}
	return ret;
}
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c6:	85 c9                	test   %ecx,%ecx
  8008c8:	75 0b                	jne    8008d5 <strlcpy+0x23>
  8008ca:	eb 17                	jmp    8008e3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008d5:	39 d8                	cmp    %ebx,%eax
  8008d7:	74 07                	je     8008e0 <strlcpy+0x2e>
  8008d9:	0f b6 0a             	movzbl (%edx),%ecx
  8008dc:	84 c9                	test   %cl,%cl
  8008de:	75 ec                	jne    8008cc <strlcpy+0x1a>
		*dst = '\0';
  8008e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e3:	29 f0                	sub    %esi,%eax
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strcmp+0x11>
		p++, q++;
  8008f4:	83 c1 01             	add    $0x1,%ecx
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008fa:	0f b6 01             	movzbl (%ecx),%eax
  8008fd:	84 c0                	test   %al,%al
  8008ff:	74 04                	je     800905 <strcmp+0x1c>
  800901:	3a 02                	cmp    (%edx),%al
  800903:	74 ef                	je     8008f4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 c0             	movzbl %al,%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
  800919:	89 c3                	mov    %eax,%ebx
  80091b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091e:	eb 06                	jmp    800926 <strncmp+0x17>
		n--, p++, q++;
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800926:	39 d8                	cmp    %ebx,%eax
  800928:	74 16                	je     800940 <strncmp+0x31>
  80092a:	0f b6 08             	movzbl (%eax),%ecx
  80092d:	84 c9                	test   %cl,%cl
  80092f:	74 04                	je     800935 <strncmp+0x26>
  800931:	3a 0a                	cmp    (%edx),%cl
  800933:	74 eb                	je     800920 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800935:	0f b6 00             	movzbl (%eax),%eax
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	29 d0                	sub    %edx,%eax
}
  80093d:	5b                   	pop    %ebx
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb f6                	jmp    80093d <strncmp+0x2e>

00800947 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	74 09                	je     800961 <strchr+0x1a>
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 0a                	je     800966 <strchr+0x1f>
	for (; *s; s++)
  80095c:	83 c0 01             	add    $0x1,%eax
  80095f:	eb f0                	jmp    800951 <strchr+0xa>
			return (char *) s;
	return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800972:	eb 03                	jmp    800977 <strfind+0xf>
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 04                	je     800982 <strfind+0x1a>
  80097e:	84 d2                	test   %dl,%dl
  800980:	75 f2                	jne    800974 <strfind+0xc>
			break;
	return (char *) s;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800990:	85 c9                	test   %ecx,%ecx
  800992:	74 13                	je     8009a7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800994:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099a:	75 05                	jne    8009a1 <memset+0x1d>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	74 0d                	je     8009ae <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	fc                   	cld    
  8009a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a7:	89 f8                	mov    %edi,%eax
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5f                   	pop    %edi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    
		c &= 0xFF;
  8009ae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b2:	89 d3                	mov    %edx,%ebx
  8009b4:	c1 e3 08             	shl    $0x8,%ebx
  8009b7:	89 d0                	mov    %edx,%eax
  8009b9:	c1 e0 18             	shl    $0x18,%eax
  8009bc:	89 d6                	mov    %edx,%esi
  8009be:	c1 e6 10             	shl    $0x10,%esi
  8009c1:	09 f0                	or     %esi,%eax
  8009c3:	09 c2                	or     %eax,%edx
  8009c5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ca:	89 d0                	mov    %edx,%eax
  8009cc:	fc                   	cld    
  8009cd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cf:	eb d6                	jmp    8009a7 <memset+0x23>

008009d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009df:	39 c6                	cmp    %eax,%esi
  8009e1:	73 35                	jae    800a18 <memmove+0x47>
  8009e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e6:	39 c2                	cmp    %eax,%edx
  8009e8:	76 2e                	jbe    800a18 <memmove+0x47>
		s += n;
		d += n;
  8009ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	09 fe                	or     %edi,%esi
  8009f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f7:	74 0c                	je     800a05 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f9:	83 ef 01             	sub    $0x1,%edi
  8009fc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ff:	fd                   	std    
  800a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a02:	fc                   	cld    
  800a03:	eb 21                	jmp    800a26 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 ef                	jne    8009f9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0a:	83 ef 04             	sub    $0x4,%edi
  800a0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a13:	fd                   	std    
  800a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a16:	eb ea                	jmp    800a02 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a18:	89 f2                	mov    %esi,%edx
  800a1a:	09 c2                	or     %eax,%edx
  800a1c:	f6 c2 03             	test   $0x3,%dl
  800a1f:	74 09                	je     800a2a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	fc                   	cld    
  800a24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f6 c1 03             	test   $0x3,%cl
  800a2d:	75 f2                	jne    800a21 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	fc                   	cld    
  800a35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a37:	eb ed                	jmp    800a26 <memmove+0x55>

00800a39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3c:	ff 75 10             	pushl  0x10(%ebp)
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	ff 75 08             	pushl  0x8(%ebp)
  800a45:	e8 87 ff ff ff       	call   8009d1 <memmove>
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a57:	89 c6                	mov    %eax,%esi
  800a59:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5c:	39 f0                	cmp    %esi,%eax
  800a5e:	74 1c                	je     800a7c <memcmp+0x30>
		if (*s1 != *s2)
  800a60:	0f b6 08             	movzbl (%eax),%ecx
  800a63:	0f b6 1a             	movzbl (%edx),%ebx
  800a66:	38 d9                	cmp    %bl,%cl
  800a68:	75 08                	jne    800a72 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	eb ea                	jmp    800a5c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a72:	0f b6 c1             	movzbl %cl,%eax
  800a75:	0f b6 db             	movzbl %bl,%ebx
  800a78:	29 d8                	sub    %ebx,%eax
  800a7a:	eb 05                	jmp    800a81 <memcmp+0x35>
	}

	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8e:	89 c2                	mov    %eax,%edx
  800a90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a93:	39 d0                	cmp    %edx,%eax
  800a95:	73 09                	jae    800aa0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a97:	38 08                	cmp    %cl,(%eax)
  800a99:	74 05                	je     800aa0 <memfind+0x1b>
	for (; s < ends; s++)
  800a9b:	83 c0 01             	add    $0x1,%eax
  800a9e:	eb f3                	jmp    800a93 <memfind+0xe>
			break;
	return (void *) s;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	eb 03                	jmp    800ab3 <strtol+0x11>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab3:	0f b6 01             	movzbl (%ecx),%eax
  800ab6:	3c 20                	cmp    $0x20,%al
  800ab8:	74 f6                	je     800ab0 <strtol+0xe>
  800aba:	3c 09                	cmp    $0x9,%al
  800abc:	74 f2                	je     800ab0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800abe:	3c 2b                	cmp    $0x2b,%al
  800ac0:	74 2e                	je     800af0 <strtol+0x4e>
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	74 2f                	je     800afa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad1:	75 05                	jne    800ad8 <strtol+0x36>
  800ad3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad6:	74 2c                	je     800b04 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	75 0a                	jne    800ae6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adc:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	74 28                	je     800b0e <strtol+0x6c>
		base = 10;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aee:	eb 50                	jmp    800b40 <strtol+0x9e>
		s++;
  800af0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
  800af8:	eb d1                	jmp    800acb <strtol+0x29>
		s++, neg = 1;
  800afa:	83 c1 01             	add    $0x1,%ecx
  800afd:	bf 01 00 00 00       	mov    $0x1,%edi
  800b02:	eb c7                	jmp    800acb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b04:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b08:	74 0e                	je     800b18 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	75 d8                	jne    800ae6 <strtol+0x44>
		s++, base = 8;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b16:	eb ce                	jmp    800ae6 <strtol+0x44>
		s += 2, base = 16;
  800b18:	83 c1 02             	add    $0x2,%ecx
  800b1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b20:	eb c4                	jmp    800ae6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 29                	ja     800b55 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b2c:	0f be d2             	movsbl %dl,%edx
  800b2f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b35:	7d 30                	jge    800b67 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b37:	83 c1 01             	add    $0x1,%ecx
  800b3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b40:	0f b6 11             	movzbl (%ecx),%edx
  800b43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 09             	cmp    $0x9,%bl
  800b4b:	77 d5                	ja     800b22 <strtol+0x80>
			dig = *s - '0';
  800b4d:	0f be d2             	movsbl %dl,%edx
  800b50:	83 ea 30             	sub    $0x30,%edx
  800b53:	eb dd                	jmp    800b32 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b55:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	80 fb 19             	cmp    $0x19,%bl
  800b5d:	77 08                	ja     800b67 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5f:	0f be d2             	movsbl %dl,%edx
  800b62:	83 ea 37             	sub    $0x37,%edx
  800b65:	eb cb                	jmp    800b32 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6b:	74 05                	je     800b72 <strtol+0xd0>
		*endptr = (char *) s;
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b70:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b72:	89 c2                	mov    %eax,%edx
  800b74:	f7 da                	neg    %edx
  800b76:	85 ff                	test   %edi,%edi
  800b78:	0f 45 c2             	cmovne %edx,%eax
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd3:	89 cb                	mov    %ecx,%ebx
  800bd5:	89 cf                	mov    %ecx,%edi
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7f 08                	jg     800be7 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 03                	push   $0x3
  800bed:	68 24 13 80 00       	push   $0x801324
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 41 13 80 00       	push   $0x801341
  800bf9:	e8 4c f5 ff ff       	call   80014a <_panic>

00800bfe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_yield>:

void
sys_yield(void)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c45:	be 00 00 00 00       	mov    $0x0,%esi
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	b8 04 00 00 00       	mov    $0x4,%eax
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	89 f7                	mov    %esi,%edi
  800c5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7f 08                	jg     800c68 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 04                	push   $0x4
  800c6e:	68 24 13 80 00       	push   $0x801324
  800c73:	6a 23                	push   $0x23
  800c75:	68 41 13 80 00       	push   $0x801341
  800c7a:	e8 cb f4 ff ff       	call   80014a <_panic>

00800c7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c99:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7f 08                	jg     800caa <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 05                	push   $0x5
  800cb0:	68 24 13 80 00       	push   $0x801324
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 41 13 80 00       	push   $0x801341
  800cbc:	e8 89 f4 ff ff       	call   80014a <_panic>

00800cc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 06                	push   $0x6
  800cf2:	68 24 13 80 00       	push   $0x801324
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 41 13 80 00       	push   $0x801341
  800cfe:	e8 47 f4 ff ff       	call   80014a <_panic>

00800d03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7f 08                	jg     800d2e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 08                	push   $0x8
  800d34:	68 24 13 80 00       	push   $0x801324
  800d39:	6a 23                	push   $0x23
  800d3b:	68 41 13 80 00       	push   $0x801341
  800d40:	e8 05 f4 ff ff       	call   80014a <_panic>

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7f 08                	jg     800d70 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 09                	push   $0x9
  800d76:	68 24 13 80 00       	push   $0x801324
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 41 13 80 00       	push   $0x801341
  800d82:	e8 c3 f3 ff ff       	call   80014a <_panic>

00800d87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d98:	be 00 00 00 00       	mov    $0x0,%esi
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 0c                	push   $0xc
  800dda:	68 24 13 80 00       	push   $0x801324
  800ddf:	6a 23                	push   $0x23
  800de1:	68 41 13 80 00       	push   $0x801341
  800de6:	e8 5f f3 ff ff       	call   80014a <_panic>

00800deb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800df1:	68 5b 13 80 00       	push   $0x80135b
  800df6:	6a 51                	push   $0x51
  800df8:	68 4f 13 80 00       	push   $0x80134f
  800dfd:	e8 48 f3 ff ff       	call   80014a <_panic>

00800e02 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e08:	68 5a 13 80 00       	push   $0x80135a
  800e0d:	6a 58                	push   $0x58
  800e0f:	68 4f 13 80 00       	push   $0x80134f
  800e14:	e8 31 f3 ff ff       	call   80014a <_panic>
  800e19:	66 90                	xchg   %ax,%ax
  800e1b:	66 90                	xchg   %ax,%ax
  800e1d:	66 90                	xchg   %ax,%ax
  800e1f:	90                   	nop

00800e20 <__udivdi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e37:	85 d2                	test   %edx,%edx
  800e39:	75 35                	jne    800e70 <__udivdi3+0x50>
  800e3b:	39 f3                	cmp    %esi,%ebx
  800e3d:	0f 87 bd 00 00 00    	ja     800f00 <__udivdi3+0xe0>
  800e43:	85 db                	test   %ebx,%ebx
  800e45:	89 d9                	mov    %ebx,%ecx
  800e47:	75 0b                	jne    800e54 <__udivdi3+0x34>
  800e49:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f3                	div    %ebx
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	31 d2                	xor    %edx,%edx
  800e56:	89 f0                	mov    %esi,%eax
  800e58:	f7 f1                	div    %ecx
  800e5a:	89 c6                	mov    %eax,%esi
  800e5c:	89 e8                	mov    %ebp,%eax
  800e5e:	89 f7                	mov    %esi,%edi
  800e60:	f7 f1                	div    %ecx
  800e62:	89 fa                	mov    %edi,%edx
  800e64:	83 c4 1c             	add    $0x1c,%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
  800e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 f2                	cmp    %esi,%edx
  800e72:	77 7c                	ja     800ef0 <__udivdi3+0xd0>
  800e74:	0f bd fa             	bsr    %edx,%edi
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	0f 84 98 00 00 00    	je     800f18 <__udivdi3+0xf8>
  800e80:	89 f9                	mov    %edi,%ecx
  800e82:	b8 20 00 00 00       	mov    $0x20,%eax
  800e87:	29 f8                	sub    %edi,%eax
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	89 da                	mov    %ebx,%edx
  800e93:	d3 ea                	shr    %cl,%edx
  800e95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e99:	09 d1                	or     %edx,%ecx
  800e9b:	89 f2                	mov    %esi,%edx
  800e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e3                	shl    %cl,%ebx
  800ea5:	89 c1                	mov    %eax,%ecx
  800ea7:	d3 ea                	shr    %cl,%edx
  800ea9:	89 f9                	mov    %edi,%ecx
  800eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eaf:	d3 e6                	shl    %cl,%esi
  800eb1:	89 eb                	mov    %ebp,%ebx
  800eb3:	89 c1                	mov    %eax,%ecx
  800eb5:	d3 eb                	shr    %cl,%ebx
  800eb7:	09 de                	or     %ebx,%esi
  800eb9:	89 f0                	mov    %esi,%eax
  800ebb:	f7 74 24 08          	divl   0x8(%esp)
  800ebf:	89 d6                	mov    %edx,%esi
  800ec1:	89 c3                	mov    %eax,%ebx
  800ec3:	f7 64 24 0c          	mull   0xc(%esp)
  800ec7:	39 d6                	cmp    %edx,%esi
  800ec9:	72 0c                	jb     800ed7 <__udivdi3+0xb7>
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	39 c5                	cmp    %eax,%ebp
  800ed1:	73 5d                	jae    800f30 <__udivdi3+0x110>
  800ed3:	39 d6                	cmp    %edx,%esi
  800ed5:	75 59                	jne    800f30 <__udivdi3+0x110>
  800ed7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eda:	31 ff                	xor    %edi,%edi
  800edc:	89 fa                	mov    %edi,%edx
  800ede:	83 c4 1c             	add    $0x1c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    
  800ee6:	8d 76 00             	lea    0x0(%esi),%esi
  800ee9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ef0:	31 ff                	xor    %edi,%edi
  800ef2:	31 c0                	xor    %eax,%eax
  800ef4:	89 fa                	mov    %edi,%edx
  800ef6:	83 c4 1c             	add    $0x1c,%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	31 ff                	xor    %edi,%edi
  800f02:	89 e8                	mov    %ebp,%eax
  800f04:	89 f2                	mov    %esi,%edx
  800f06:	f7 f3                	div    %ebx
  800f08:	89 fa                	mov    %edi,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	72 06                	jb     800f22 <__udivdi3+0x102>
  800f1c:	31 c0                	xor    %eax,%eax
  800f1e:	39 eb                	cmp    %ebp,%ebx
  800f20:	77 d2                	ja     800ef4 <__udivdi3+0xd4>
  800f22:	b8 01 00 00 00       	mov    $0x1,%eax
  800f27:	eb cb                	jmp    800ef4 <__udivdi3+0xd4>
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	31 ff                	xor    %edi,%edi
  800f34:	eb be                	jmp    800ef4 <__udivdi3+0xd4>
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f57:	85 ed                	test   %ebp,%ebp
  800f59:	89 f0                	mov    %esi,%eax
  800f5b:	89 da                	mov    %ebx,%edx
  800f5d:	75 19                	jne    800f78 <__umoddi3+0x38>
  800f5f:	39 df                	cmp    %ebx,%edi
  800f61:	0f 86 b1 00 00 00    	jbe    801018 <__umoddi3+0xd8>
  800f67:	f7 f7                	div    %edi
  800f69:	89 d0                	mov    %edx,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	83 c4 1c             	add    $0x1c,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	39 dd                	cmp    %ebx,%ebp
  800f7a:	77 f1                	ja     800f6d <__umoddi3+0x2d>
  800f7c:	0f bd cd             	bsr    %ebp,%ecx
  800f7f:	83 f1 1f             	xor    $0x1f,%ecx
  800f82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f86:	0f 84 b4 00 00 00    	je     801040 <__umoddi3+0x100>
  800f8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f91:	89 c2                	mov    %eax,%edx
  800f93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f97:	29 c2                	sub    %eax,%edx
  800f99:	89 c1                	mov    %eax,%ecx
  800f9b:	89 f8                	mov    %edi,%eax
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	89 d1                	mov    %edx,%ecx
  800fa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa5:	d3 e8                	shr    %cl,%eax
  800fa7:	09 c5                	or     %eax,%ebp
  800fa9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fad:	89 c1                	mov    %eax,%ecx
  800faf:	d3 e7                	shl    %cl,%edi
  800fb1:	89 d1                	mov    %edx,%ecx
  800fb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fb7:	89 df                	mov    %ebx,%edi
  800fb9:	d3 ef                	shr    %cl,%edi
  800fbb:	89 c1                	mov    %eax,%ecx
  800fbd:	89 f0                	mov    %esi,%eax
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 d1                	mov    %edx,%ecx
  800fc3:	89 fa                	mov    %edi,%edx
  800fc5:	d3 e8                	shr    %cl,%eax
  800fc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fcc:	09 d8                	or     %ebx,%eax
  800fce:	f7 f5                	div    %ebp
  800fd0:	d3 e6                	shl    %cl,%esi
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	f7 64 24 08          	mull   0x8(%esp)
  800fd8:	39 d1                	cmp    %edx,%ecx
  800fda:	89 c3                	mov    %eax,%ebx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	72 06                	jb     800fe6 <__umoddi3+0xa6>
  800fe0:	75 0e                	jne    800ff0 <__umoddi3+0xb0>
  800fe2:	39 c6                	cmp    %eax,%esi
  800fe4:	73 0a                	jae    800ff0 <__umoddi3+0xb0>
  800fe6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fea:	19 ea                	sbb    %ebp,%edx
  800fec:	89 d7                	mov    %edx,%edi
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	89 ca                	mov    %ecx,%edx
  800ff2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ff7:	29 de                	sub    %ebx,%esi
  800ff9:	19 fa                	sbb    %edi,%edx
  800ffb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fff:	89 d0                	mov    %edx,%eax
  801001:	d3 e0                	shl    %cl,%eax
  801003:	89 d9                	mov    %ebx,%ecx
  801005:	d3 ee                	shr    %cl,%esi
  801007:	d3 ea                	shr    %cl,%edx
  801009:	09 f0                	or     %esi,%eax
  80100b:	83 c4 1c             	add    $0x1c,%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    
  801013:	90                   	nop
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	85 ff                	test   %edi,%edi
  80101a:	89 f9                	mov    %edi,%ecx
  80101c:	75 0b                	jne    801029 <__umoddi3+0xe9>
  80101e:	b8 01 00 00 00       	mov    $0x1,%eax
  801023:	31 d2                	xor    %edx,%edx
  801025:	f7 f7                	div    %edi
  801027:	89 c1                	mov    %eax,%ecx
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f1                	div    %ecx
  80102f:	89 f0                	mov    %esi,%eax
  801031:	f7 f1                	div    %ecx
  801033:	e9 31 ff ff ff       	jmp    800f69 <__umoddi3+0x29>
  801038:	90                   	nop
  801039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801040:	39 dd                	cmp    %ebx,%ebp
  801042:	72 08                	jb     80104c <__umoddi3+0x10c>
  801044:	39 f7                	cmp    %esi,%edi
  801046:	0f 87 21 ff ff ff    	ja     800f6d <__umoddi3+0x2d>
  80104c:	89 da                	mov    %ebx,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	29 f8                	sub    %edi,%eax
  801052:	19 ea                	sbb    %ebp,%edx
  801054:	e9 14 ff ff ff       	jmp    800f6d <__umoddi3+0x2d>
