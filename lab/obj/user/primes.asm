
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 dd 0d 00 00       	call   800e29 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 e0 10 80 00       	push   $0x8010e0
  800060:	e8 d0 01 00 00       	call   800235 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 91 0d 00 00       	call   800dfb <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 30                	js     8000a3 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 c8                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800077:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	6a 00                	push   $0x0
  80007f:	6a 00                	push   $0x0
  800081:	56                   	push   %esi
  800082:	e8 a2 0d 00 00       	call   800e29 <ipc_recv>
  800087:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800089:	99                   	cltd   
  80008a:	f7 fb                	idiv   %ebx
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	85 d2                	test   %edx,%edx
  800091:	74 e7                	je     80007a <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	51                   	push   %ecx
  800098:	57                   	push   %edi
  800099:	e8 a2 0d 00 00       	call   800e40 <ipc_send>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	eb d7                	jmp    80007a <primeproc+0x47>
		panic("fork: %e", id);
  8000a3:	50                   	push   %eax
  8000a4:	68 ec 10 80 00       	push   $0x8010ec
  8000a9:	6a 1a                	push   $0x1a
  8000ab:	68 f5 10 80 00       	push   $0x8010f5
  8000b0:	e8 a5 00 00 00       	call   80015a <_panic>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 3c 0d 00 00       	call   800dfb <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1c                	js     8000e1 <umain+0x2c>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	74 25                	je     8000f3 <umain+0x3e>
		ipc_send(id, i, 0, 0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	6a 00                	push   $0x0
  8000d2:	53                   	push   %ebx
  8000d3:	56                   	push   %esi
  8000d4:	e8 67 0d 00 00       	call   800e40 <ipc_send>
	for (i = 2; ; i++)
  8000d9:	83 c3 01             	add    $0x1,%ebx
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	eb ed                	jmp    8000ce <umain+0x19>
		panic("fork: %e", id);
  8000e1:	50                   	push   %eax
  8000e2:	68 ec 10 80 00       	push   $0x8010ec
  8000e7:	6a 2d                	push   $0x2d
  8000e9:	68 f5 10 80 00       	push   $0x8010f5
  8000ee:	e8 67 00 00 00       	call   80015a <_panic>
		primeproc();
  8000f3:	e8 3b ff ff ff       	call   800033 <primeproc>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800103:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80010a:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  80010d:	e8 fc 0a 00 00       	call   800c0e <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x37>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 7c ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014e:	6a 00                	push   $0x0
  800150:	e8 78 0a 00 00       	call   800bcd <sys_env_destroy>
}
  800155:	83 c4 10             	add    $0x10,%esp
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800162:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800168:	e8 a1 0a 00 00       	call   800c0e <sys_getenvid>
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	ff 75 0c             	pushl  0xc(%ebp)
  800173:	ff 75 08             	pushl  0x8(%ebp)
  800176:	56                   	push   %esi
  800177:	50                   	push   %eax
  800178:	68 10 11 80 00       	push   $0x801110
  80017d:	e8 b3 00 00 00       	call   800235 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800182:	83 c4 18             	add    $0x18,%esp
  800185:	53                   	push   %ebx
  800186:	ff 75 10             	pushl  0x10(%ebp)
  800189:	e8 56 00 00 00       	call   8001e4 <vcprintf>
	cprintf("\n");
  80018e:	c7 04 24 34 11 80 00 	movl   $0x801134,(%esp)
  800195:	e8 9b 00 00 00       	call   800235 <cprintf>
  80019a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019d:	cc                   	int3   
  80019e:	eb fd                	jmp    80019d <_panic+0x43>

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 13                	mov    (%ebx),%edx
  8001ac:	8d 42 01             	lea    0x1(%edx),%eax
  8001af:	89 03                	mov    %eax,(%ebx)
  8001b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	74 09                	je     8001c8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 ff 00 00 00       	push   $0xff
  8001d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d3:	50                   	push   %eax
  8001d4:	e8 b7 09 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	eb db                	jmp    8001bf <putch+0x1f>

008001e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f4:	00 00 00 
	b.cnt = 0;
  8001f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800201:	ff 75 0c             	pushl  0xc(%ebp)
  800204:	ff 75 08             	pushl  0x8(%ebp)
  800207:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020d:	50                   	push   %eax
  80020e:	68 a0 01 80 00       	push   $0x8001a0
  800213:	e8 1a 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800218:	83 c4 08             	add    $0x8,%esp
  80021b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800221:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800227:	50                   	push   %eax
  800228:	e8 63 09 00 00       	call   800b90 <sys_cputs>

	return b.cnt;
}
  80022d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 08             	pushl  0x8(%ebp)
  800242:	e8 9d ff ff ff       	call   8001e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 1c             	sub    $0x1c,%esp
  800252:	89 c7                	mov    %eax,%edi
  800254:	89 d6                	mov    %edx,%esi
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800262:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800270:	39 d3                	cmp    %edx,%ebx
  800272:	72 05                	jb     800279 <printnum+0x30>
  800274:	39 45 10             	cmp    %eax,0x10(%ebp)
  800277:	77 7a                	ja     8002f3 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	ff 75 18             	pushl  0x18(%ebp)
  80027f:	8b 45 14             	mov    0x14(%ebp),%eax
  800282:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800285:	53                   	push   %ebx
  800286:	ff 75 10             	pushl  0x10(%ebp)
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028f:	ff 75 e0             	pushl  -0x20(%ebp)
  800292:	ff 75 dc             	pushl  -0x24(%ebp)
  800295:	ff 75 d8             	pushl  -0x28(%ebp)
  800298:	e8 f3 0b 00 00       	call   800e90 <__udivdi3>
  80029d:	83 c4 18             	add    $0x18,%esp
  8002a0:	52                   	push   %edx
  8002a1:	50                   	push   %eax
  8002a2:	89 f2                	mov    %esi,%edx
  8002a4:	89 f8                	mov    %edi,%eax
  8002a6:	e8 9e ff ff ff       	call   800249 <printnum>
  8002ab:	83 c4 20             	add    $0x20,%esp
  8002ae:	eb 13                	jmp    8002c3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	56                   	push   %esi
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	ff d7                	call   *%edi
  8002b9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	85 db                	test   %ebx,%ebx
  8002c1:	7f ed                	jg     8002b0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d6:	e8 d5 0c 00 00       	call   800fb0 <__umoddi3>
  8002db:	83 c4 14             	add    $0x14,%esp
  8002de:	0f be 80 36 11 80 00 	movsbl 0x801136(%eax),%eax
  8002e5:	50                   	push   %eax
  8002e6:	ff d7                	call   *%edi
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    
  8002f3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f6:	eb c4                	jmp    8002bc <printnum+0x73>

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	e9 63 03 00 00       	jmp    8006ac <vprintfmt+0x37a>
		padc = ' ';
  800349:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80034d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800354:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80035b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8d 47 01             	lea    0x1(%edi),%eax
  80036a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036d:	0f b6 17             	movzbl (%edi),%edx
  800370:	8d 42 dd             	lea    -0x23(%edx),%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 11 04 00 00    	ja     80078c <vprintfmt+0x45a>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800388:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80038c:	eb d9                	jmp    800367 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800391:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800395:	eb d0                	jmp    800367 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800397:	0f b6 d2             	movzbl %dl,%edx
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003af:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b2:	83 f9 09             	cmp    $0x9,%ecx
  8003b5:	77 55                	ja     80040c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ba:	eb e9                	jmp    8003a5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 40 04             	lea    0x4(%eax),%eax
  8003ca:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	79 91                	jns    800367 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e3:	eb 82                	jmp    800367 <vprintfmt+0x35>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	0f 49 d0             	cmovns %eax,%edx
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	e9 6a ff ff ff       	jmp    800367 <vprintfmt+0x35>
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800400:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800407:	e9 5b ff ff ff       	jmp    800367 <vprintfmt+0x35>
  80040c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800412:	eb bc                	jmp    8003d0 <vprintfmt+0x9e>
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041a:	e9 48 ff ff ff       	jmp    800367 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 78 04             	lea    0x4(%eax),%edi
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	53                   	push   %ebx
  800429:	ff 30                	pushl  (%eax)
  80042b:	ff d6                	call   *%esi
			break;
  80042d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800430:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800433:	e9 71 02 00 00       	jmp    8006a9 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 78 04             	lea    0x4(%eax),%edi
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
  800441:	31 d0                	xor    %edx,%eax
  800443:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 08             	cmp    $0x8,%eax
  800448:	7f 23                	jg     80046d <vprintfmt+0x13b>
  80044a:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	74 18                	je     80046d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800455:	52                   	push   %edx
  800456:	68 57 11 80 00       	push   $0x801157
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 b3 fe ff ff       	call   800315 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800465:	89 7d 14             	mov    %edi,0x14(%ebp)
  800468:	e9 3c 02 00 00       	jmp    8006a9 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 4e 11 80 00       	push   $0x80114e
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 9b fe ff ff       	call   800315 <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 24 02 00 00       	jmp    8006a9 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	83 c0 04             	add    $0x4,%eax
  80048b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800493:	85 ff                	test   %edi,%edi
  800495:	b8 47 11 80 00       	mov    $0x801147,%eax
  80049a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	0f 8e bd 00 00 00    	jle    800564 <vprintfmt+0x232>
  8004a7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ab:	75 0e                	jne    8004bb <vprintfmt+0x189>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	eb 6d                	jmp    800528 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c1:	57                   	push   %edi
  8004c2:	e8 6d 03 00 00       	call   800834 <strnlen>
  8004c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004dc:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	eb 0f                	jmp    8004ef <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ef 01             	sub    $0x1,%edi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	7f ed                	jg     8004e0 <vprintfmt+0x1ae>
  8004f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	0f 49 c1             	cmovns %ecx,%eax
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050e:	89 cb                	mov    %ecx,%ebx
  800510:	eb 16                	jmp    800528 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	75 31                	jne    800549 <vprintfmt+0x217>
					putch(ch, putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	50                   	push   %eax
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800525:	83 eb 01             	sub    $0x1,%ebx
  800528:	83 c7 01             	add    $0x1,%edi
  80052b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80052f:	0f be c2             	movsbl %dl,%eax
  800532:	85 c0                	test   %eax,%eax
  800534:	74 59                	je     80058f <vprintfmt+0x25d>
  800536:	85 f6                	test   %esi,%esi
  800538:	78 d8                	js     800512 <vprintfmt+0x1e0>
  80053a:	83 ee 01             	sub    $0x1,%esi
  80053d:	79 d3                	jns    800512 <vprintfmt+0x1e0>
  80053f:	89 df                	mov    %ebx,%edi
  800541:	8b 75 08             	mov    0x8(%ebp),%esi
  800544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800547:	eb 37                	jmp    800580 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	0f be d2             	movsbl %dl,%edx
  80054c:	83 ea 20             	sub    $0x20,%edx
  80054f:	83 fa 5e             	cmp    $0x5e,%edx
  800552:	76 c4                	jbe    800518 <vprintfmt+0x1e6>
					putch('?', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	6a 3f                	push   $0x3f
  80055c:	ff 55 08             	call   *0x8(%ebp)
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	eb c1                	jmp    800525 <vprintfmt+0x1f3>
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800570:	eb b6                	jmp    800528 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	53                   	push   %ebx
  800576:	6a 20                	push   $0x20
  800578:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80057a:	83 ef 01             	sub    $0x1,%edi
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	85 ff                	test   %edi,%edi
  800582:	7f ee                	jg     800572 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	e9 1a 01 00 00       	jmp    8006a9 <vprintfmt+0x377>
  80058f:	89 df                	mov    %ebx,%edi
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800597:	eb e7                	jmp    800580 <vprintfmt+0x24e>
	if (lflag >= 2)
  800599:	83 f9 01             	cmp    $0x1,%ecx
  80059c:	7e 3f                	jle    8005dd <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 50 04             	mov    0x4(%eax),%edx
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 08             	lea    0x8(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b9:	79 5c                	jns    800617 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 2d                	push   $0x2d
  8005c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c9:	f7 da                	neg    %edx
  8005cb:	83 d1 00             	adc    $0x0,%ecx
  8005ce:	f7 d9                	neg    %ecx
  8005d0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 b2 00 00 00       	jmp    80068f <vprintfmt+0x35d>
	else if (lflag)
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	75 1b                	jne    8005fc <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 c1                	mov    %eax,%ecx
  8005eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	eb b9                	jmp    8005b5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 c1                	mov    %eax,%ecx
  800606:	c1 f9 1f             	sar    $0x1f,%ecx
  800609:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
  800615:	eb 9e                	jmp    8005b5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800617:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	eb 6b                	jmp    80068f <vprintfmt+0x35d>
	if (lflag >= 2)
  800624:	83 f9 01             	cmp    $0x1,%ecx
  800627:	7e 15                	jle    80063e <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	8b 48 04             	mov    0x4(%eax),%ecx
  800631:	8d 40 08             	lea    0x8(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063c:	eb 51                	jmp    80068f <vprintfmt+0x35d>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	75 17                	jne    800659 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	eb 36                	jmp    80068f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800669:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066e:	eb 1f                	jmp    80068f <vprintfmt+0x35d>
	if (lflag >= 2)
  800670:	83 f9 01             	cmp    $0x1,%ecx
  800673:	7e 5b                	jle    8006d0 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 50 04             	mov    0x4(%eax),%edx
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800680:	8d 49 08             	lea    0x8(%ecx),%ecx
  800683:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800686:	89 d1                	mov    %edx,%ecx
  800688:	89 c2                	mov    %eax,%edx
			base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800696:	57                   	push   %edi
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	50                   	push   %eax
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 a3 fb ff ff       	call   800249 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ac:	83 c7 01             	add    $0x1,%edi
  8006af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b3:	83 f8 25             	cmp    $0x25,%eax
  8006b6:	0f 84 8d fc ff ff    	je     800349 <vprintfmt+0x17>
			if (ch == '\0')
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	0f 84 e8 00 00 00    	je     8007ac <vprintfmt+0x47a>
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	50                   	push   %eax
  8006c9:	ff d6                	call   *%esi
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb dc                	jmp    8006ac <vprintfmt+0x37a>
	else if (lflag)
  8006d0:	85 c9                	test   %ecx,%ecx
  8006d2:	75 13                	jne    8006e7 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	89 d0                	mov    %edx,%eax
  8006db:	99                   	cltd   
  8006dc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006df:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e5:	eb 9f                	jmp    800686 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	89 d0                	mov    %edx,%eax
  8006ee:	99                   	cltd   
  8006ef:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006f2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f8:	eb 8c                	jmp    800686 <vprintfmt+0x354>
			putch('0', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 30                	push   $0x30
  800700:	ff d6                	call   *%esi
			putch('x', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 78                	push   $0x78
  800708:	ff d6                	call   *%esi
			num = (unsigned long long)
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800714:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800722:	e9 68 ff ff ff       	jmp    80068f <vprintfmt+0x35d>
	if (lflag >= 2)
  800727:	83 f9 01             	cmp    $0x1,%ecx
  80072a:	7e 18                	jle    800744 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	8b 48 04             	mov    0x4(%eax),%ecx
  800734:	8d 40 08             	lea    0x8(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
  80073f:	e9 4b ff ff ff       	jmp    80068f <vprintfmt+0x35d>
	else if (lflag)
  800744:	85 c9                	test   %ecx,%ecx
  800746:	75 1a                	jne    800762 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	b8 10 00 00 00       	mov    $0x10,%eax
  80075d:	e9 2d ff ff ff       	jmp    80068f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800772:	b8 10 00 00 00       	mov    $0x10,%eax
  800777:	e9 13 ff ff ff       	jmp    80068f <vprintfmt+0x35d>
			putch(ch, putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 25                	push   $0x25
  800782:	ff d6                	call   *%esi
			break;
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	e9 1d ff ff ff       	jmp    8006a9 <vprintfmt+0x377>
			putch('%', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 25                	push   $0x25
  800792:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	89 f8                	mov    %edi,%eax
  800799:	eb 03                	jmp    80079e <vprintfmt+0x46c>
  80079b:	83 e8 01             	sub    $0x1,%eax
  80079e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a2:	75 f7                	jne    80079b <vprintfmt+0x469>
  8007a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a7:	e9 fd fe ff ff       	jmp    8006a9 <vprintfmt+0x377>
}
  8007ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5f                   	pop    %edi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 18             	sub    $0x18,%esp
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 26                	je     8007fb <vsnprintf+0x47>
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	7e 22                	jle    8007fb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d9:	ff 75 14             	pushl  0x14(%ebp)
  8007dc:	ff 75 10             	pushl  0x10(%ebp)
  8007df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	68 f8 02 80 00       	push   $0x8002f8
  8007e8:	e8 45 fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f6:	83 c4 10             	add    $0x10,%esp
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
		return -E_INVAL;
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800800:	eb f7                	jmp    8007f9 <vsnprintf+0x45>

00800802 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080b:	50                   	push   %eax
  80080c:	ff 75 10             	pushl  0x10(%ebp)
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 9a ff ff ff       	call   8007b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 03                	jmp    80082c <strlen+0x10>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800830:	75 f7                	jne    800829 <strlen+0xd>
	return n;
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	eb 03                	jmp    800847 <strnlen+0x13>
		n++;
  800844:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 d0                	cmp    %edx,%eax
  800849:	74 06                	je     800851 <strnlen+0x1d>
  80084b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084f:	75 f3                	jne    800844 <strnlen+0x10>
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ef                	jne    80085f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	53                   	push   %ebx
  80087b:	e8 9c ff ff ff       	call   80081c <strlen>
  800880:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	01 d8                	add    %ebx,%eax
  800888:	50                   	push   %eax
  800889:	e8 c5 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f2                	mov    %esi,%edx
  8008a7:	eb 0f                	jmp    8008b8 <strncpy+0x23>
		*dst++ = *src;
  8008a9:	83 c2 01             	add    $0x1,%edx
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b8:	39 da                	cmp    %ebx,%edx
  8008ba:	75 ed                	jne    8008a9 <strncpy+0x14>
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	75 0b                	jne    8008e5 <strlcpy+0x23>
  8008da:	eb 17                	jmp    8008f3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e5:	39 d8                	cmp    %ebx,%eax
  8008e7:	74 07                	je     8008f0 <strlcpy+0x2e>
  8008e9:	0f b6 0a             	movzbl (%edx),%ecx
  8008ec:	84 c9                	test   %cl,%cl
  8008ee:	75 ec                	jne    8008dc <strlcpy+0x1a>
		*dst = '\0';
  8008f0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f3:	29 f0                	sub    %esi,%eax
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800902:	eb 06                	jmp    80090a <strcmp+0x11>
		p++, q++;
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80090a:	0f b6 01             	movzbl (%ecx),%eax
  80090d:	84 c0                	test   %al,%al
  80090f:	74 04                	je     800915 <strcmp+0x1c>
  800911:	3a 02                	cmp    (%edx),%al
  800913:	74 ef                	je     800904 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800915:	0f b6 c0             	movzbl %al,%eax
  800918:	0f b6 12             	movzbl (%edx),%edx
  80091b:	29 d0                	sub    %edx,%eax
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c3                	mov    %eax,%ebx
  80092b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092e:	eb 06                	jmp    800936 <strncmp+0x17>
		n--, p++, q++;
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800936:	39 d8                	cmp    %ebx,%eax
  800938:	74 16                	je     800950 <strncmp+0x31>
  80093a:	0f b6 08             	movzbl (%eax),%ecx
  80093d:	84 c9                	test   %cl,%cl
  80093f:	74 04                	je     800945 <strncmp+0x26>
  800941:	3a 0a                	cmp    (%edx),%cl
  800943:	74 eb                	je     800930 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800945:	0f b6 00             	movzbl (%eax),%eax
  800948:	0f b6 12             	movzbl (%edx),%edx
  80094b:	29 d0                	sub    %edx,%eax
}
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    
		return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
  800955:	eb f6                	jmp    80094d <strncmp+0x2e>

00800957 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800961:	0f b6 10             	movzbl (%eax),%edx
  800964:	84 d2                	test   %dl,%dl
  800966:	74 09                	je     800971 <strchr+0x1a>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 0a                	je     800976 <strchr+0x1f>
	for (; *s; s++)
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	eb f0                	jmp    800961 <strchr+0xa>
			return (char *) s;
	return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800982:	eb 03                	jmp    800987 <strfind+0xf>
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 04                	je     800992 <strfind+0x1a>
  80098e:	84 d2                	test   %dl,%dl
  800990:	75 f2                	jne    800984 <strfind+0xc>
			break;
	return (char *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 13                	je     8009b7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 05                	jne    8009b1 <memset+0x1d>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	74 0d                	je     8009be <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	fc                   	cld    
  8009b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b7:	89 f8                	mov    %edi,%eax
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    
		c &= 0xFF;
  8009be:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c2:	89 d3                	mov    %edx,%ebx
  8009c4:	c1 e3 08             	shl    $0x8,%ebx
  8009c7:	89 d0                	mov    %edx,%eax
  8009c9:	c1 e0 18             	shl    $0x18,%eax
  8009cc:	89 d6                	mov    %edx,%esi
  8009ce:	c1 e6 10             	shl    $0x10,%esi
  8009d1:	09 f0                	or     %esi,%eax
  8009d3:	09 c2                	or     %eax,%edx
  8009d5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009da:	89 d0                	mov    %edx,%eax
  8009dc:	fc                   	cld    
  8009dd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009df:	eb d6                	jmp    8009b7 <memset+0x23>

008009e1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ef:	39 c6                	cmp    %eax,%esi
  8009f1:	73 35                	jae    800a28 <memmove+0x47>
  8009f3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f6:	39 c2                	cmp    %eax,%edx
  8009f8:	76 2e                	jbe    800a28 <memmove+0x47>
		s += n;
		d += n;
  8009fa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	09 fe                	or     %edi,%esi
  800a01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a07:	74 0c                	je     800a15 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a09:	83 ef 01             	sub    $0x1,%edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 21                	jmp    800a36 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 ef                	jne    800a09 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb ea                	jmp    800a12 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	89 f2                	mov    %esi,%edx
  800a2a:	09 c2                	or     %eax,%edx
  800a2c:	f6 c2 03             	test   $0x3,%dl
  800a2f:	74 09                	je     800a3a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 f2                	jne    800a31 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a47:	eb ed                	jmp    800a36 <memmove+0x55>

00800a49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4c:	ff 75 10             	pushl  0x10(%ebp)
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	ff 75 08             	pushl  0x8(%ebp)
  800a55:	e8 87 ff ff ff       	call   8009e1 <memmove>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a67:	89 c6                	mov    %eax,%esi
  800a69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6c:	39 f0                	cmp    %esi,%eax
  800a6e:	74 1c                	je     800a8c <memcmp+0x30>
		if (*s1 != *s2)
  800a70:	0f b6 08             	movzbl (%eax),%ecx
  800a73:	0f b6 1a             	movzbl (%edx),%ebx
  800a76:	38 d9                	cmp    %bl,%cl
  800a78:	75 08                	jne    800a82 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	eb ea                	jmp    800a6c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c1             	movzbl %cl,%eax
  800a85:	0f b6 db             	movzbl %bl,%ebx
  800a88:	29 d8                	sub    %ebx,%eax
  800a8a:	eb 05                	jmp    800a91 <memcmp+0x35>
	}

	return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9e:	89 c2                	mov    %eax,%edx
  800aa0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	73 09                	jae    800ab0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa7:	38 08                	cmp    %cl,(%eax)
  800aa9:	74 05                	je     800ab0 <memfind+0x1b>
	for (; s < ends; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	eb f3                	jmp    800aa3 <memfind+0xe>
			break;
	return (void *) s;
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abe:	eb 03                	jmp    800ac3 <strtol+0x11>
		s++;
  800ac0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac3:	0f b6 01             	movzbl (%ecx),%eax
  800ac6:	3c 20                	cmp    $0x20,%al
  800ac8:	74 f6                	je     800ac0 <strtol+0xe>
  800aca:	3c 09                	cmp    $0x9,%al
  800acc:	74 f2                	je     800ac0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ace:	3c 2b                	cmp    $0x2b,%al
  800ad0:	74 2e                	je     800b00 <strtol+0x4e>
	int neg = 0;
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad7:	3c 2d                	cmp    $0x2d,%al
  800ad9:	74 2f                	je     800b0a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae1:	75 05                	jne    800ae8 <strtol+0x36>
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	74 2c                	je     800b14 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	75 0a                	jne    800af6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aec:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800af1:	80 39 30             	cmpb   $0x30,(%ecx)
  800af4:	74 28                	je     800b1e <strtol+0x6c>
		base = 10;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afe:	eb 50                	jmp    800b50 <strtol+0x9e>
		s++;
  800b00:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
  800b08:	eb d1                	jmp    800adb <strtol+0x29>
		s++, neg = 1;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b12:	eb c7                	jmp    800adb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b18:	74 0e                	je     800b28 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	75 d8                	jne    800af6 <strtol+0x44>
		s++, base = 8;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b26:	eb ce                	jmp    800af6 <strtol+0x44>
		s += 2, base = 16;
  800b28:	83 c1 02             	add    $0x2,%ecx
  800b2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b30:	eb c4                	jmp    800af6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b35:	89 f3                	mov    %esi,%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 29                	ja     800b65 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3c:	0f be d2             	movsbl %dl,%edx
  800b3f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b45:	7d 30                	jge    800b77 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b47:	83 c1 01             	add    $0x1,%ecx
  800b4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b50:	0f b6 11             	movzbl (%ecx),%edx
  800b53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b56:	89 f3                	mov    %esi,%ebx
  800b58:	80 fb 09             	cmp    $0x9,%bl
  800b5b:	77 d5                	ja     800b32 <strtol+0x80>
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
  800b63:	eb dd                	jmp    800b42 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 19             	cmp    $0x19,%bl
  800b6d:	77 08                	ja     800b77 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	83 ea 37             	sub    $0x37,%edx
  800b75:	eb cb                	jmp    800b42 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7b:	74 05                	je     800b82 <strtol+0xd0>
		*endptr = (char *) s;
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	f7 da                	neg    %edx
  800b86:	85 ff                	test   %edi,%edi
  800b88:	0f 45 c2             	cmovne %edx,%eax
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	b8 03 00 00 00       	mov    $0x3,%eax
  800be3:	89 cb                	mov    %ecx,%ebx
  800be5:	89 cf                	mov    %ecx,%edi
  800be7:	89 ce                	mov    %ecx,%esi
  800be9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7f 08                	jg     800bf7 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 03                	push   $0x3
  800bfd:	68 84 13 80 00       	push   $0x801384
  800c02:	6a 23                	push   $0x23
  800c04:	68 a1 13 80 00       	push   $0x8013a1
  800c09:	e8 4c f5 ff ff       	call   80015a <_panic>

00800c0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_yield>:

void
sys_yield(void)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3d:	89 d1                	mov    %edx,%ecx
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	89 d7                	mov    %edx,%edi
  800c43:	89 d6                	mov    %edx,%esi
  800c45:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	be 00 00 00 00       	mov    $0x0,%esi
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	b8 04 00 00 00       	mov    $0x4,%eax
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	89 f7                	mov    %esi,%edi
  800c6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7f 08                	jg     800c78 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 04                	push   $0x4
  800c7e:	68 84 13 80 00       	push   $0x801384
  800c83:	6a 23                	push   $0x23
  800c85:	68 a1 13 80 00       	push   $0x8013a1
  800c8a:	e8 cb f4 ff ff       	call   80015a <_panic>

00800c8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cac:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7f 08                	jg     800cba <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 05                	push   $0x5
  800cc0:	68 84 13 80 00       	push   $0x801384
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 a1 13 80 00       	push   $0x8013a1
  800ccc:	e8 89 f4 ff ff       	call   80015a <_panic>

00800cd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7f 08                	jg     800cfc <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 06                	push   $0x6
  800d02:	68 84 13 80 00       	push   $0x801384
  800d07:	6a 23                	push   $0x23
  800d09:	68 a1 13 80 00       	push   $0x8013a1
  800d0e:	e8 47 f4 ff ff       	call   80015a <_panic>

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7f 08                	jg     800d3e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 08                	push   $0x8
  800d44:	68 84 13 80 00       	push   $0x801384
  800d49:	6a 23                	push   $0x23
  800d4b:	68 a1 13 80 00       	push   $0x8013a1
  800d50:	e8 05 f4 ff ff       	call   80015a <_panic>

00800d55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7f 08                	jg     800d80 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 09                	push   $0x9
  800d86:	68 84 13 80 00       	push   $0x801384
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 a1 13 80 00       	push   $0x8013a1
  800d92:	e8 c3 f3 ff ff       	call   80015a <_panic>

00800d97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da8:	be 00 00 00 00       	mov    $0x0,%esi
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7f 08                	jg     800de4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 0c                	push   $0xc
  800dea:	68 84 13 80 00       	push   $0x801384
  800def:	6a 23                	push   $0x23
  800df1:	68 a1 13 80 00       	push   $0x8013a1
  800df6:	e8 5f f3 ff ff       	call   80015a <_panic>

00800dfb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e01:	68 bb 13 80 00       	push   $0x8013bb
  800e06:	6a 51                	push   $0x51
  800e08:	68 af 13 80 00       	push   $0x8013af
  800e0d:	e8 48 f3 ff ff       	call   80015a <_panic>

00800e12 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e18:	68 ba 13 80 00       	push   $0x8013ba
  800e1d:	6a 58                	push   $0x58
  800e1f:	68 af 13 80 00       	push   $0x8013af
  800e24:	e8 31 f3 ff ff       	call   80015a <_panic>

00800e29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e2f:	68 d0 13 80 00       	push   $0x8013d0
  800e34:	6a 1a                	push   $0x1a
  800e36:	68 e9 13 80 00       	push   $0x8013e9
  800e3b:	e8 1a f3 ff ff       	call   80015a <_panic>

00800e40 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e46:	68 f3 13 80 00       	push   $0x8013f3
  800e4b:	6a 2a                	push   $0x2a
  800e4d:	68 e9 13 80 00       	push   $0x8013e9
  800e52:	e8 03 f3 ff ff       	call   80015a <_panic>

00800e57 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e62:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e65:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e6b:	8b 52 50             	mov    0x50(%edx),%edx
  800e6e:	39 ca                	cmp    %ecx,%edx
  800e70:	74 11                	je     800e83 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e72:	83 c0 01             	add    $0x1,%eax
  800e75:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e7a:	75 e6                	jne    800e62 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	eb 0b                	jmp    800e8e <ipc_find_env+0x37>
			return envs[i].env_id;
  800e83:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e86:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8b:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <__udivdi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	75 35                	jne    800ee0 <__udivdi3+0x50>
  800eab:	39 f3                	cmp    %esi,%ebx
  800ead:	0f 87 bd 00 00 00    	ja     800f70 <__udivdi3+0xe0>
  800eb3:	85 db                	test   %ebx,%ebx
  800eb5:	89 d9                	mov    %ebx,%ecx
  800eb7:	75 0b                	jne    800ec4 <__udivdi3+0x34>
  800eb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebe:	31 d2                	xor    %edx,%edx
  800ec0:	f7 f3                	div    %ebx
  800ec2:	89 c1                	mov    %eax,%ecx
  800ec4:	31 d2                	xor    %edx,%edx
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	f7 f1                	div    %ecx
  800eca:	89 c6                	mov    %eax,%esi
  800ecc:	89 e8                	mov    %ebp,%eax
  800ece:	89 f7                	mov    %esi,%edi
  800ed0:	f7 f1                	div    %ecx
  800ed2:	89 fa                	mov    %edi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	39 f2                	cmp    %esi,%edx
  800ee2:	77 7c                	ja     800f60 <__udivdi3+0xd0>
  800ee4:	0f bd fa             	bsr    %edx,%edi
  800ee7:	83 f7 1f             	xor    $0x1f,%edi
  800eea:	0f 84 98 00 00 00    	je     800f88 <__udivdi3+0xf8>
  800ef0:	89 f9                	mov    %edi,%ecx
  800ef2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef7:	29 f8                	sub    %edi,%eax
  800ef9:	d3 e2                	shl    %cl,%edx
  800efb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	89 da                	mov    %ebx,%edx
  800f03:	d3 ea                	shr    %cl,%edx
  800f05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f09:	09 d1                	or     %edx,%ecx
  800f0b:	89 f2                	mov    %esi,%edx
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e3                	shl    %cl,%ebx
  800f15:	89 c1                	mov    %eax,%ecx
  800f17:	d3 ea                	shr    %cl,%edx
  800f19:	89 f9                	mov    %edi,%ecx
  800f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1f:	d3 e6                	shl    %cl,%esi
  800f21:	89 eb                	mov    %ebp,%ebx
  800f23:	89 c1                	mov    %eax,%ecx
  800f25:	d3 eb                	shr    %cl,%ebx
  800f27:	09 de                	or     %ebx,%esi
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	f7 74 24 08          	divl   0x8(%esp)
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	f7 64 24 0c          	mull   0xc(%esp)
  800f37:	39 d6                	cmp    %edx,%esi
  800f39:	72 0c                	jb     800f47 <__udivdi3+0xb7>
  800f3b:	89 f9                	mov    %edi,%ecx
  800f3d:	d3 e5                	shl    %cl,%ebp
  800f3f:	39 c5                	cmp    %eax,%ebp
  800f41:	73 5d                	jae    800fa0 <__udivdi3+0x110>
  800f43:	39 d6                	cmp    %edx,%esi
  800f45:	75 59                	jne    800fa0 <__udivdi3+0x110>
  800f47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f4a:	31 ff                	xor    %edi,%edi
  800f4c:	89 fa                	mov    %edi,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d 76 00             	lea    0x0(%esi),%esi
  800f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f60:	31 ff                	xor    %edi,%edi
  800f62:	31 c0                	xor    %eax,%eax
  800f64:	89 fa                	mov    %edi,%edx
  800f66:	83 c4 1c             	add    $0x1c,%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
  800f6e:	66 90                	xchg   %ax,%ax
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	89 e8                	mov    %ebp,%eax
  800f74:	89 f2                	mov    %esi,%edx
  800f76:	f7 f3                	div    %ebx
  800f78:	89 fa                	mov    %edi,%edx
  800f7a:	83 c4 1c             	add    $0x1c,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	72 06                	jb     800f92 <__udivdi3+0x102>
  800f8c:	31 c0                	xor    %eax,%eax
  800f8e:	39 eb                	cmp    %ebp,%ebx
  800f90:	77 d2                	ja     800f64 <__udivdi3+0xd4>
  800f92:	b8 01 00 00 00       	mov    $0x1,%eax
  800f97:	eb cb                	jmp    800f64 <__udivdi3+0xd4>
  800f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 d8                	mov    %ebx,%eax
  800fa2:	31 ff                	xor    %edi,%edi
  800fa4:	eb be                	jmp    800f64 <__udivdi3+0xd4>
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	66 90                	xchg   %ax,%ax
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__umoddi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 1c             	sub    $0x1c,%esp
  800fb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fc7:	85 ed                	test   %ebp,%ebp
  800fc9:	89 f0                	mov    %esi,%eax
  800fcb:	89 da                	mov    %ebx,%edx
  800fcd:	75 19                	jne    800fe8 <__umoddi3+0x38>
  800fcf:	39 df                	cmp    %ebx,%edi
  800fd1:	0f 86 b1 00 00 00    	jbe    801088 <__umoddi3+0xd8>
  800fd7:	f7 f7                	div    %edi
  800fd9:	89 d0                	mov    %edx,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	83 c4 1c             	add    $0x1c,%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
  800fe5:	8d 76 00             	lea    0x0(%esi),%esi
  800fe8:	39 dd                	cmp    %ebx,%ebp
  800fea:	77 f1                	ja     800fdd <__umoddi3+0x2d>
  800fec:	0f bd cd             	bsr    %ebp,%ecx
  800fef:	83 f1 1f             	xor    $0x1f,%ecx
  800ff2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ff6:	0f 84 b4 00 00 00    	je     8010b0 <__umoddi3+0x100>
  800ffc:	b8 20 00 00 00       	mov    $0x20,%eax
  801001:	89 c2                	mov    %eax,%edx
  801003:	8b 44 24 04          	mov    0x4(%esp),%eax
  801007:	29 c2                	sub    %eax,%edx
  801009:	89 c1                	mov    %eax,%ecx
  80100b:	89 f8                	mov    %edi,%eax
  80100d:	d3 e5                	shl    %cl,%ebp
  80100f:	89 d1                	mov    %edx,%ecx
  801011:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801015:	d3 e8                	shr    %cl,%eax
  801017:	09 c5                	or     %eax,%ebp
  801019:	8b 44 24 04          	mov    0x4(%esp),%eax
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	d3 e7                	shl    %cl,%edi
  801021:	89 d1                	mov    %edx,%ecx
  801023:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801027:	89 df                	mov    %ebx,%edi
  801029:	d3 ef                	shr    %cl,%edi
  80102b:	89 c1                	mov    %eax,%ecx
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	d3 e3                	shl    %cl,%ebx
  801031:	89 d1                	mov    %edx,%ecx
  801033:	89 fa                	mov    %edi,%edx
  801035:	d3 e8                	shr    %cl,%eax
  801037:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80103c:	09 d8                	or     %ebx,%eax
  80103e:	f7 f5                	div    %ebp
  801040:	d3 e6                	shl    %cl,%esi
  801042:	89 d1                	mov    %edx,%ecx
  801044:	f7 64 24 08          	mull   0x8(%esp)
  801048:	39 d1                	cmp    %edx,%ecx
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	89 d7                	mov    %edx,%edi
  80104e:	72 06                	jb     801056 <__umoddi3+0xa6>
  801050:	75 0e                	jne    801060 <__umoddi3+0xb0>
  801052:	39 c6                	cmp    %eax,%esi
  801054:	73 0a                	jae    801060 <__umoddi3+0xb0>
  801056:	2b 44 24 08          	sub    0x8(%esp),%eax
  80105a:	19 ea                	sbb    %ebp,%edx
  80105c:	89 d7                	mov    %edx,%edi
  80105e:	89 c3                	mov    %eax,%ebx
  801060:	89 ca                	mov    %ecx,%edx
  801062:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801067:	29 de                	sub    %ebx,%esi
  801069:	19 fa                	sbb    %edi,%edx
  80106b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80106f:	89 d0                	mov    %edx,%eax
  801071:	d3 e0                	shl    %cl,%eax
  801073:	89 d9                	mov    %ebx,%ecx
  801075:	d3 ee                	shr    %cl,%esi
  801077:	d3 ea                	shr    %cl,%edx
  801079:	09 f0                	or     %esi,%eax
  80107b:	83 c4 1c             	add    $0x1c,%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    
  801083:	90                   	nop
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	85 ff                	test   %edi,%edi
  80108a:	89 f9                	mov    %edi,%ecx
  80108c:	75 0b                	jne    801099 <__umoddi3+0xe9>
  80108e:	b8 01 00 00 00       	mov    $0x1,%eax
  801093:	31 d2                	xor    %edx,%edx
  801095:	f7 f7                	div    %edi
  801097:	89 c1                	mov    %eax,%ecx
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f1                	div    %ecx
  80109f:	89 f0                	mov    %esi,%eax
  8010a1:	f7 f1                	div    %ecx
  8010a3:	e9 31 ff ff ff       	jmp    800fd9 <__umoddi3+0x29>
  8010a8:	90                   	nop
  8010a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	39 dd                	cmp    %ebx,%ebp
  8010b2:	72 08                	jb     8010bc <__umoddi3+0x10c>
  8010b4:	39 f7                	cmp    %esi,%edi
  8010b6:	0f 87 21 ff ff ff    	ja     800fdd <__umoddi3+0x2d>
  8010bc:	89 da                	mov    %ebx,%edx
  8010be:	89 f0                	mov    %esi,%eax
  8010c0:	29 f8                	sub    %edi,%eax
  8010c2:	19 ea                	sbb    %ebp,%edx
  8010c4:	e9 14 ff ff ff       	jmp    800fdd <__umoddi3+0x2d>
