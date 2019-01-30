
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 20 10 80 00       	push   $0x801020
  80003e:	e8 d6 01 00 00       	call   800219 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 68 10 80 00       	push   $0x801068
  800095:	e8 7f 01 00 00       	call   800219 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 c7 10 80 00       	push   $0x8010c7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 b8 10 80 00       	push   $0x8010b8
  8000b3:	e8 86 00 00 00       	call   80013e <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 9b 10 80 00       	push   $0x80109b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 b8 10 80 00       	push   $0x8010b8
  8000c5:	e8 74 00 00 00       	call   80013e <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 40 10 80 00       	push   $0x801040
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 b8 10 80 00       	push   $0x8010b8
  8000d7:	e8 62 00 00 00       	call   80013e <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e7:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000ee:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000f1:	e8 fc 0a 00 00       	call   800bf2 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800103:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800108:	85 db                	test   %ebx,%ebx
  80010a:	7e 07                	jle    800113 <libmain+0x37>
		binaryname = argv[0];
  80010c:	8b 06                	mov    (%esi),%eax
  80010e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	e8 16 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011d:	e8 0a 00 00 00       	call   80012c <exit>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800132:	6a 00                	push   $0x0
  800134:	e8 78 0a 00 00       	call   800bb1 <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800143:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800146:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014c:	e8 a1 0a 00 00       	call   800bf2 <sys_getenvid>
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	ff 75 0c             	pushl  0xc(%ebp)
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	56                   	push   %esi
  80015b:	50                   	push   %eax
  80015c:	68 e8 10 80 00       	push   $0x8010e8
  800161:	e8 b3 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800166:	83 c4 18             	add    $0x18,%esp
  800169:	53                   	push   %ebx
  80016a:	ff 75 10             	pushl  0x10(%ebp)
  80016d:	e8 56 00 00 00       	call   8001c8 <vcprintf>
	cprintf("\n");
  800172:	c7 04 24 b6 10 80 00 	movl   $0x8010b6,(%esp)
  800179:	e8 9b 00 00 00       	call   800219 <cprintf>
  80017e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800181:	cc                   	int3   
  800182:	eb fd                	jmp    800181 <_panic+0x43>

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 13                	mov    (%ebx),%edx
  800190:	8d 42 01             	lea    0x1(%edx),%eax
  800193:	89 03                	mov    %eax,(%ebx)
  800195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a1:	74 09                	je     8001ac <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	68 ff 00 00 00       	push   $0xff
  8001b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b7:	50                   	push   %eax
  8001b8:	e8 b7 09 00 00       	call   800b74 <sys_cputs>
		b->idx = 0;
  8001bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb db                	jmp    8001a3 <putch+0x1f>

008001c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 84 01 80 00       	push   $0x800184
  8001f7:	e8 1a 01 00 00       	call   800316 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 63 09 00 00       	call   800b74 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800222:	50                   	push   %eax
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	e8 9d ff ff ff       	call   8001c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 1c             	sub    $0x1c,%esp
  800236:	89 c7                	mov    %eax,%edi
  800238:	89 d6                	mov    %edx,%esi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800243:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800246:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800251:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800254:	39 d3                	cmp    %edx,%ebx
  800256:	72 05                	jb     80025d <printnum+0x30>
  800258:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025b:	77 7a                	ja     8002d7 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	ff 75 18             	pushl  0x18(%ebp)
  800263:	8b 45 14             	mov    0x14(%ebp),%eax
  800266:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800269:	53                   	push   %ebx
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 5f 0b 00 00       	call   800de0 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9e ff ff ff       	call   80022d <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 13                	jmp    8002a7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f ed                	jg     800294 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 41 0c 00 00       	call   800f00 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 0c 11 80 00 	movsbl 0x80110c(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    
  8002d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002da:	eb c4                	jmp    8002a0 <printnum+0x73>

008002dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002eb:	73 0a                	jae    8002f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	88 02                	mov    %al,(%edx)
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <printfmt>:
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	ff 75 08             	pushl  0x8(%ebp)
  80030c:	e8 05 00 00 00       	call   800316 <vprintfmt>
}
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <vprintfmt>:
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 2c             	sub    $0x2c,%esp
  80031f:	8b 75 08             	mov    0x8(%ebp),%esi
  800322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800325:	8b 7d 10             	mov    0x10(%ebp),%edi
  800328:	e9 63 03 00 00       	jmp    800690 <vprintfmt+0x37a>
		padc = ' ';
  80032d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800331:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800338:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80033f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 47 01             	lea    0x1(%edi),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	0f b6 17             	movzbl (%edi),%edx
  800354:	8d 42 dd             	lea    -0x23(%edx),%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 11 04 00 00    	ja     800770 <vprintfmt+0x45a>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800370:	eb d9                	jmp    80034b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800375:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800379:	eb d0                	jmp    80034b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	0f b6 d2             	movzbl %dl,%edx
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
  800386:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800389:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800390:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800393:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800396:	83 f9 09             	cmp    $0x9,%ecx
  800399:	77 55                	ja     8003f0 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80039b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039e:	eb e9                	jmp    800389 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 40 04             	lea    0x4(%eax),%eax
  8003ae:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	79 91                	jns    80034b <vprintfmt+0x35>
				width = precision, precision = -1;
  8003ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c7:	eb 82                	jmp    80034b <vprintfmt+0x35>
  8003c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d3:	0f 49 d0             	cmovns %eax,%edx
  8003d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dc:	e9 6a ff ff ff       	jmp    80034b <vprintfmt+0x35>
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003eb:	e9 5b ff ff ff       	jmp    80034b <vprintfmt+0x35>
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f6:	eb bc                	jmp    8003b4 <vprintfmt+0x9e>
			lflag++;
  8003f8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fe:	e9 48 ff ff ff       	jmp    80034b <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 78 04             	lea    0x4(%eax),%edi
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff d6                	call   *%esi
			break;
  800411:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800417:	e9 71 02 00 00       	jmp    80068d <vprintfmt+0x377>
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	8b 00                	mov    (%eax),%eax
  800424:	99                   	cltd   
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 08             	cmp    $0x8,%eax
  80042c:	7f 23                	jg     800451 <vprintfmt+0x13b>
  80042e:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	74 18                	je     800451 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 2d 11 80 00       	push   $0x80112d
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 b3 fe ff ff       	call   8002f9 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800449:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044c:	e9 3c 02 00 00       	jmp    80068d <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 24 11 80 00       	push   $0x801124
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 9b fe ff ff       	call   8002f9 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800464:	e9 24 02 00 00       	jmp    80068d <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800477:	85 ff                	test   %edi,%edi
  800479:	b8 1d 11 80 00       	mov    $0x80111d,%eax
  80047e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	0f 8e bd 00 00 00    	jle    800548 <vprintfmt+0x232>
  80048b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048f:	75 0e                	jne    80049f <vprintfmt+0x189>
  800491:	89 75 08             	mov    %esi,0x8(%ebp)
  800494:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800497:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049d:	eb 6d                	jmp    80050c <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a5:	57                   	push   %edi
  8004a6:	e8 6d 03 00 00       	call   800818 <strnlen>
  8004ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c0:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	eb 0f                	jmp    8004d3 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 ef 01             	sub    $0x1,%edi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	85 ff                	test   %edi,%edi
  8004d5:	7f ed                	jg     8004c4 <vprintfmt+0x1ae>
  8004d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004dd:	85 c9                	test   %ecx,%ecx
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	0f 49 c1             	cmovns %ecx,%eax
  8004e7:	29 c1                	sub    %eax,%ecx
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	89 cb                	mov    %ecx,%ebx
  8004f4:	eb 16                	jmp    80050c <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fa:	75 31                	jne    80052d <vprintfmt+0x217>
					putch(ch, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	50                   	push   %eax
  800503:	ff 55 08             	call   *0x8(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800509:	83 eb 01             	sub    $0x1,%ebx
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800513:	0f be c2             	movsbl %dl,%eax
  800516:	85 c0                	test   %eax,%eax
  800518:	74 59                	je     800573 <vprintfmt+0x25d>
  80051a:	85 f6                	test   %esi,%esi
  80051c:	78 d8                	js     8004f6 <vprintfmt+0x1e0>
  80051e:	83 ee 01             	sub    $0x1,%esi
  800521:	79 d3                	jns    8004f6 <vprintfmt+0x1e0>
  800523:	89 df                	mov    %ebx,%edi
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052b:	eb 37                	jmp    800564 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052d:	0f be d2             	movsbl %dl,%edx
  800530:	83 ea 20             	sub    $0x20,%edx
  800533:	83 fa 5e             	cmp    $0x5e,%edx
  800536:	76 c4                	jbe    8004fc <vprintfmt+0x1e6>
					putch('?', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	6a 3f                	push   $0x3f
  800540:	ff 55 08             	call   *0x8(%ebp)
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb c1                	jmp    800509 <vprintfmt+0x1f3>
  800548:	89 75 08             	mov    %esi,0x8(%ebp)
  80054b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800551:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800554:	eb b6                	jmp    80050c <vprintfmt+0x1f6>
				putch(' ', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 20                	push   $0x20
  80055c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ee                	jg     800556 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800568:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
  80056e:	e9 1a 01 00 00       	jmp    80068d <vprintfmt+0x377>
  800573:	89 df                	mov    %ebx,%edi
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057b:	eb e7                	jmp    800564 <vprintfmt+0x24e>
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7e 3f                	jle    8005c1 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 50 04             	mov    0x4(%eax),%edx
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 40 08             	lea    0x8(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800599:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059d:	79 5c                	jns    8005fb <vprintfmt+0x2e5>
				putch('-', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 2d                	push   $0x2d
  8005a5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ad:	f7 da                	neg    %edx
  8005af:	83 d1 00             	adc    $0x0,%ecx
  8005b2:	f7 d9                	neg    %ecx
  8005b4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 b2 00 00 00       	jmp    800673 <vprintfmt+0x35d>
	else if (lflag)
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	75 1b                	jne    8005e0 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cd:	89 c1                	mov    %eax,%ecx
  8005cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
  8005de:	eb b9                	jmp    800599 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f9:	eb 9e                	jmp    800599 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
  800606:	eb 6b                	jmp    800673 <vprintfmt+0x35d>
	if (lflag >= 2)
  800608:	83 f9 01             	cmp    $0x1,%ecx
  80060b:	7e 15                	jle    800622 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	8b 48 04             	mov    0x4(%eax),%ecx
  800615:	8d 40 08             	lea    0x8(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	eb 51                	jmp    800673 <vprintfmt+0x35d>
	else if (lflag)
  800622:	85 c9                	test   %ecx,%ecx
  800624:	75 17                	jne    80063d <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	eb 36                	jmp    800673 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800652:	eb 1f                	jmp    800673 <vprintfmt+0x35d>
	if (lflag >= 2)
  800654:	83 f9 01             	cmp    $0x1,%ecx
  800657:	7e 5b                	jle    8006b4 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 50 04             	mov    0x4(%eax),%edx
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800664:	8d 49 08             	lea    0x8(%ecx),%ecx
  800667:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80066a:	89 d1                	mov    %edx,%ecx
  80066c:	89 c2                	mov    %eax,%edx
			base = 8;
  80066e:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067a:	57                   	push   %edi
  80067b:	ff 75 e0             	pushl  -0x20(%ebp)
  80067e:	50                   	push   %eax
  80067f:	51                   	push   %ecx
  800680:	52                   	push   %edx
  800681:	89 da                	mov    %ebx,%edx
  800683:	89 f0                	mov    %esi,%eax
  800685:	e8 a3 fb ff ff       	call   80022d <printnum>
			break;
  80068a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800690:	83 c7 01             	add    $0x1,%edi
  800693:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800697:	83 f8 25             	cmp    $0x25,%eax
  80069a:	0f 84 8d fc ff ff    	je     80032d <vprintfmt+0x17>
			if (ch == '\0')
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	0f 84 e8 00 00 00    	je     800790 <vprintfmt+0x47a>
			putch(ch, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	50                   	push   %eax
  8006ad:	ff d6                	call   *%esi
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb dc                	jmp    800690 <vprintfmt+0x37a>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	75 13                	jne    8006cb <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	99                   	cltd   
  8006c0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c9:	eb 9f                	jmp    80066a <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	89 d0                	mov    %edx,%eax
  8006d2:	99                   	cltd   
  8006d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006dc:	eb 8c                	jmp    80066a <vprintfmt+0x354>
			putch('0', putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 30                	push   $0x30
  8006e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e6:	83 c4 08             	add    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 78                	push   $0x78
  8006ec:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800706:	e9 68 ff ff ff       	jmp    800673 <vprintfmt+0x35d>
	if (lflag >= 2)
  80070b:	83 f9 01             	cmp    $0x1,%ecx
  80070e:	7e 18                	jle    800728 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	8b 48 04             	mov    0x4(%eax),%ecx
  800718:	8d 40 08             	lea    0x8(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071e:	b8 10 00 00 00       	mov    $0x10,%eax
  800723:	e9 4b ff ff ff       	jmp    800673 <vprintfmt+0x35d>
	else if (lflag)
  800728:	85 c9                	test   %ecx,%ecx
  80072a:	75 1a                	jne    800746 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073c:	b8 10 00 00 00       	mov    $0x10,%eax
  800741:	e9 2d ff ff ff       	jmp    800673 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800756:	b8 10 00 00 00       	mov    $0x10,%eax
  80075b:	e9 13 ff ff ff       	jmp    800673 <vprintfmt+0x35d>
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	6a 25                	push   $0x25
  800766:	ff d6                	call   *%esi
			break;
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	e9 1d ff ff ff       	jmp    80068d <vprintfmt+0x377>
			putch('%', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 25                	push   $0x25
  800776:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	89 f8                	mov    %edi,%eax
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x46c>
  80077f:	83 e8 01             	sub    $0x1,%eax
  800782:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800786:	75 f7                	jne    80077f <vprintfmt+0x469>
  800788:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078b:	e9 fd fe ff ff       	jmp    80068d <vprintfmt+0x377>
}
  800790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 18             	sub    $0x18,%esp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	74 26                	je     8007df <vsnprintf+0x47>
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	7e 22                	jle    8007df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bd:	ff 75 14             	pushl  0x14(%ebp)
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c6:	50                   	push   %eax
  8007c7:	68 dc 02 80 00       	push   $0x8002dc
  8007cc:	e8 45 fb ff ff       	call   800316 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007da:	83 c4 10             	add    $0x10,%esp
}
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    
		return -E_INVAL;
  8007df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e4:	eb f7                	jmp    8007dd <vsnprintf+0x45>

008007e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	ff 75 08             	pushl  0x8(%ebp)
  8007f9:	e8 9a ff ff ff       	call   800798 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strlen+0x10>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	75 f7                	jne    80080d <strlen+0xd>
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strnlen+0x13>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	39 d0                	cmp    %edx,%eax
  80082d:	74 06                	je     800835 <strnlen+0x1d>
  80082f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800833:	75 f3                	jne    800828 <strnlen+0x10>
	return n;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800850:	84 db                	test   %bl,%bl
  800852:	75 ef                	jne    800843 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085e:	53                   	push   %ebx
  80085f:	e8 9c ff ff ff       	call   800800 <strlen>
  800864:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	01 d8                	add    %ebx,%eax
  80086c:	50                   	push   %eax
  80086d:	e8 c5 ff ff ff       	call   800837 <strcpy>
	return dst;
}
  800872:	89 d8                	mov    %ebx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	89 f3                	mov    %esi,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 0f                	jmp    80089c <strncpy+0x23>
		*dst++ = *src;
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	0f b6 01             	movzbl (%ecx),%eax
  800893:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800896:	80 39 01             	cmpb   $0x1,(%ecx)
  800899:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80089c:	39 da                	cmp    %ebx,%edx
  80089e:	75 ed                	jne    80088d <strncpy+0x14>
	}
	return ret;
}
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b4:	89 f0                	mov    %esi,%eax
  8008b6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ba:	85 c9                	test   %ecx,%ecx
  8008bc:	75 0b                	jne    8008c9 <strlcpy+0x23>
  8008be:	eb 17                	jmp    8008d7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c9:	39 d8                	cmp    %ebx,%eax
  8008cb:	74 07                	je     8008d4 <strlcpy+0x2e>
  8008cd:	0f b6 0a             	movzbl (%edx),%ecx
  8008d0:	84 c9                	test   %cl,%cl
  8008d2:	75 ec                	jne    8008c0 <strlcpy+0x1a>
		*dst = '\0';
  8008d4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d7:	29 f0                	sub    %esi,%eax
}
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e6:	eb 06                	jmp    8008ee <strcmp+0x11>
		p++, q++;
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ee:	0f b6 01             	movzbl (%ecx),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 04                	je     8008f9 <strcmp+0x1c>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	74 ef                	je     8008e8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f9:	0f b6 c0             	movzbl %al,%eax
  8008fc:	0f b6 12             	movzbl (%edx),%edx
  8008ff:	29 d0                	sub    %edx,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800912:	eb 06                	jmp    80091a <strncmp+0x17>
		n--, p++, q++;
  800914:	83 c0 01             	add    $0x1,%eax
  800917:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091a:	39 d8                	cmp    %ebx,%eax
  80091c:	74 16                	je     800934 <strncmp+0x31>
  80091e:	0f b6 08             	movzbl (%eax),%ecx
  800921:	84 c9                	test   %cl,%cl
  800923:	74 04                	je     800929 <strncmp+0x26>
  800925:	3a 0a                	cmp    (%edx),%cl
  800927:	74 eb                	je     800914 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 00             	movzbl (%eax),%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb f6                	jmp    800931 <strncmp+0x2e>

0080093b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 09                	je     800955 <strchr+0x1a>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 0a                	je     80095a <strchr+0x1f>
	for (; *s; s++)
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	eb f0                	jmp    800945 <strchr+0xa>
			return (char *) s;
	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800966:	eb 03                	jmp    80096b <strfind+0xf>
  800968:	83 c0 01             	add    $0x1,%eax
  80096b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 04                	je     800976 <strfind+0x1a>
  800972:	84 d2                	test   %dl,%dl
  800974:	75 f2                	jne    800968 <strfind+0xc>
			break;
	return (char *) s;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800984:	85 c9                	test   %ecx,%ecx
  800986:	74 13                	je     80099b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800988:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098e:	75 05                	jne    800995 <memset+0x1d>
  800990:	f6 c1 03             	test   $0x3,%cl
  800993:	74 0d                	je     8009a2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	fc                   	cld    
  800999:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    
		c &= 0xFF;
  8009a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a6:	89 d3                	mov    %edx,%ebx
  8009a8:	c1 e3 08             	shl    $0x8,%ebx
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	c1 e0 18             	shl    $0x18,%eax
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	c1 e6 10             	shl    $0x10,%esi
  8009b5:	09 f0                	or     %esi,%eax
  8009b7:	09 c2                	or     %eax,%edx
  8009b9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	fc                   	cld    
  8009c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c3:	eb d6                	jmp    80099b <memset+0x23>

008009c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d3:	39 c6                	cmp    %eax,%esi
  8009d5:	73 35                	jae    800a0c <memmove+0x47>
  8009d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009da:	39 c2                	cmp    %eax,%edx
  8009dc:	76 2e                	jbe    800a0c <memmove+0x47>
		s += n;
		d += n;
  8009de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	09 fe                	or     %edi,%esi
  8009e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009eb:	74 0c                	je     8009f9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ed:	83 ef 01             	sub    $0x1,%edi
  8009f0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f3:	fd                   	std    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f6:	fc                   	cld    
  8009f7:	eb 21                	jmp    800a1a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	f6 c1 03             	test   $0x3,%cl
  8009fc:	75 ef                	jne    8009ed <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fe:	83 ef 04             	sub    $0x4,%edi
  800a01:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a04:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a07:	fd                   	std    
  800a08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0a:	eb ea                	jmp    8009f6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	89 f2                	mov    %esi,%edx
  800a0e:	09 c2                	or     %eax,%edx
  800a10:	f6 c2 03             	test   $0x3,%dl
  800a13:	74 09                	je     800a1e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a15:	89 c7                	mov    %eax,%edi
  800a17:	fc                   	cld    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 f2                	jne    800a15 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a23:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2b:	eb ed                	jmp    800a1a <memmove+0x55>

00800a2d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a30:	ff 75 10             	pushl  0x10(%ebp)
  800a33:	ff 75 0c             	pushl  0xc(%ebp)
  800a36:	ff 75 08             	pushl  0x8(%ebp)
  800a39:	e8 87 ff ff ff       	call   8009c5 <memmove>
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4b:	89 c6                	mov    %eax,%esi
  800a4d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a50:	39 f0                	cmp    %esi,%eax
  800a52:	74 1c                	je     800a70 <memcmp+0x30>
		if (*s1 != *s2)
  800a54:	0f b6 08             	movzbl (%eax),%ecx
  800a57:	0f b6 1a             	movzbl (%edx),%ebx
  800a5a:	38 d9                	cmp    %bl,%cl
  800a5c:	75 08                	jne    800a66 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	83 c2 01             	add    $0x1,%edx
  800a64:	eb ea                	jmp    800a50 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a66:	0f b6 c1             	movzbl %cl,%eax
  800a69:	0f b6 db             	movzbl %bl,%ebx
  800a6c:	29 d8                	sub    %ebx,%eax
  800a6e:	eb 05                	jmp    800a75 <memcmp+0x35>
	}

	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a82:	89 c2                	mov    %eax,%edx
  800a84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a87:	39 d0                	cmp    %edx,%eax
  800a89:	73 09                	jae    800a94 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8b:	38 08                	cmp    %cl,(%eax)
  800a8d:	74 05                	je     800a94 <memfind+0x1b>
	for (; s < ends; s++)
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	eb f3                	jmp    800a87 <memfind+0xe>
			break;
	return (void *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa2:	eb 03                	jmp    800aa7 <strtol+0x11>
		s++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa7:	0f b6 01             	movzbl (%ecx),%eax
  800aaa:	3c 20                	cmp    $0x20,%al
  800aac:	74 f6                	je     800aa4 <strtol+0xe>
  800aae:	3c 09                	cmp    $0x9,%al
  800ab0:	74 f2                	je     800aa4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ab2:	3c 2b                	cmp    $0x2b,%al
  800ab4:	74 2e                	je     800ae4 <strtol+0x4e>
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800abb:	3c 2d                	cmp    $0x2d,%al
  800abd:	74 2f                	je     800aee <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac5:	75 05                	jne    800acc <strtol+0x36>
  800ac7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aca:	74 2c                	je     800af8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acc:	85 db                	test   %ebx,%ebx
  800ace:	75 0a                	jne    800ada <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ad5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad8:	74 28                	je     800b02 <strtol+0x6c>
		base = 10;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae2:	eb 50                	jmp    800b34 <strtol+0x9e>
		s++;
  800ae4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aec:	eb d1                	jmp    800abf <strtol+0x29>
		s++, neg = 1;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	bf 01 00 00 00       	mov    $0x1,%edi
  800af6:	eb c7                	jmp    800abf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afc:	74 0e                	je     800b0c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afe:	85 db                	test   %ebx,%ebx
  800b00:	75 d8                	jne    800ada <strtol+0x44>
		s++, base = 8;
  800b02:	83 c1 01             	add    $0x1,%ecx
  800b05:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b0a:	eb ce                	jmp    800ada <strtol+0x44>
		s += 2, base = 16;
  800b0c:	83 c1 02             	add    $0x2,%ecx
  800b0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b14:	eb c4                	jmp    800ada <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 29                	ja     800b49 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b26:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b29:	7d 30                	jge    800b5b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2b:	83 c1 01             	add    $0x1,%ecx
  800b2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b32:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b34:	0f b6 11             	movzbl (%ecx),%edx
  800b37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 09             	cmp    $0x9,%bl
  800b3f:	77 d5                	ja     800b16 <strtol+0x80>
			dig = *s - '0';
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 30             	sub    $0x30,%edx
  800b47:	eb dd                	jmp    800b26 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 08                	ja     800b5b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 37             	sub    $0x37,%edx
  800b59:	eb cb                	jmp    800b26 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 05                	je     800b66 <strtol+0xd0>
		*endptr = (char *) s;
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	f7 da                	neg    %edx
  800b6a:	85 ff                	test   %edi,%edi
  800b6c:	0f 45 c2             	cmovne %edx,%eax
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	89 c3                	mov    %eax,%ebx
  800b87:	89 c7                	mov    %eax,%edi
  800b89:	89 c6                	mov    %eax,%esi
  800b8b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc7:	89 cb                	mov    %ecx,%ebx
  800bc9:	89 cf                	mov    %ecx,%edi
  800bcb:	89 ce                	mov    %ecx,%esi
  800bcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7f 08                	jg     800bdb <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 03                	push   $0x3
  800be1:	68 64 13 80 00       	push   $0x801364
  800be6:	6a 23                	push   $0x23
  800be8:	68 81 13 80 00       	push   $0x801381
  800bed:	e8 4c f5 ff ff       	call   80013e <_panic>

00800bf2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 02 00 00 00       	mov    $0x2,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_yield>:

void
sys_yield(void)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 d3                	mov    %edx,%ebx
  800c25:	89 d7                	mov    %edx,%edi
  800c27:	89 d6                	mov    %edx,%esi
  800c29:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c39:	be 00 00 00 00       	mov    $0x0,%esi
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	b8 04 00 00 00       	mov    $0x4,%eax
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	89 f7                	mov    %esi,%edi
  800c4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7f 08                	jg     800c5c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 04                	push   $0x4
  800c62:	68 64 13 80 00       	push   $0x801364
  800c67:	6a 23                	push   $0x23
  800c69:	68 81 13 80 00       	push   $0x801381
  800c6e:	e8 cb f4 ff ff       	call   80013e <_panic>

00800c73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	b8 05 00 00 00       	mov    $0x5,%eax
  800c87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7f 08                	jg     800c9e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 05                	push   $0x5
  800ca4:	68 64 13 80 00       	push   $0x801364
  800ca9:	6a 23                	push   $0x23
  800cab:	68 81 13 80 00       	push   $0x801381
  800cb0:	e8 89 f4 ff ff       	call   80013e <_panic>

00800cb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cce:	89 df                	mov    %ebx,%edi
  800cd0:	89 de                	mov    %ebx,%esi
  800cd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7f 08                	jg     800ce0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 06                	push   $0x6
  800ce6:	68 64 13 80 00       	push   $0x801364
  800ceb:	6a 23                	push   $0x23
  800ced:	68 81 13 80 00       	push   $0x801381
  800cf2:	e8 47 f4 ff ff       	call   80013e <_panic>

00800cf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7f 08                	jg     800d22 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 08                	push   $0x8
  800d28:	68 64 13 80 00       	push   $0x801364
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 81 13 80 00       	push   $0x801381
  800d34:	e8 05 f4 ff ff       	call   80013e <_panic>

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7f 08                	jg     800d64 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800d68:	6a 09                	push   $0x9
  800d6a:	68 64 13 80 00       	push   $0x801364
  800d6f:	6a 23                	push   $0x23
  800d71:	68 81 13 80 00       	push   $0x801381
  800d76:	e8 c3 f3 ff ff       	call   80013e <_panic>

00800d7b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d97:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db4:	89 cb                	mov    %ecx,%ebx
  800db6:	89 cf                	mov    %ecx,%edi
  800db8:	89 ce                	mov    %ecx,%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7f 08                	jg     800dc8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 0c                	push   $0xc
  800dce:	68 64 13 80 00       	push   $0x801364
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 81 13 80 00       	push   $0x801381
  800dda:	e8 5f f3 ff ff       	call   80013e <_panic>
  800ddf:	90                   	nop

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800deb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800def:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800df7:	85 d2                	test   %edx,%edx
  800df9:	75 35                	jne    800e30 <__udivdi3+0x50>
  800dfb:	39 f3                	cmp    %esi,%ebx
  800dfd:	0f 87 bd 00 00 00    	ja     800ec0 <__udivdi3+0xe0>
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	89 d9                	mov    %ebx,%ecx
  800e07:	75 0b                	jne    800e14 <__udivdi3+0x34>
  800e09:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f3                	div    %ebx
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	31 d2                	xor    %edx,%edx
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 c6                	mov    %eax,%esi
  800e1c:	89 e8                	mov    %ebp,%eax
  800e1e:	89 f7                	mov    %esi,%edi
  800e20:	f7 f1                	div    %ecx
  800e22:	89 fa                	mov    %edi,%edx
  800e24:	83 c4 1c             	add    $0x1c,%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    
  800e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 f2                	cmp    %esi,%edx
  800e32:	77 7c                	ja     800eb0 <__udivdi3+0xd0>
  800e34:	0f bd fa             	bsr    %edx,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0xf8>
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	d3 e6                	shl    %cl,%esi
  800e71:	89 eb                	mov    %ebp,%ebx
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 0c                	jb     800e97 <__udivdi3+0xb7>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 5d                	jae    800ef0 <__udivdi3+0x110>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	75 59                	jne    800ef0 <__udivdi3+0x110>
  800e97:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e9a:	31 ff                	xor    %edi,%edi
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	83 c4 1c             	add    $0x1c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
  800ea6:	8d 76 00             	lea    0x0(%esi),%esi
  800ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800eb0:	31 ff                	xor    %edi,%edi
  800eb2:	31 c0                	xor    %eax,%eax
  800eb4:	89 fa                	mov    %edi,%edx
  800eb6:	83 c4 1c             	add    $0x1c,%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
  800ebe:	66 90                	xchg   %ax,%ax
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	89 e8                	mov    %ebp,%eax
  800ec4:	89 f2                	mov    %esi,%edx
  800ec6:	f7 f3                	div    %ebx
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	72 06                	jb     800ee2 <__udivdi3+0x102>
  800edc:	31 c0                	xor    %eax,%eax
  800ede:	39 eb                	cmp    %ebp,%ebx
  800ee0:	77 d2                	ja     800eb4 <__udivdi3+0xd4>
  800ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee7:	eb cb                	jmp    800eb4 <__udivdi3+0xd4>
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	31 ff                	xor    %edi,%edi
  800ef4:	eb be                	jmp    800eb4 <__udivdi3+0xd4>
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 ed                	test   %ebp,%ebp
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	89 da                	mov    %ebx,%edx
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	0f 86 b1 00 00 00    	jbe    800fd8 <__umoddi3+0xd8>
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 dd                	cmp    %ebx,%ebp
  800f3a:	77 f1                	ja     800f2d <__umoddi3+0x2d>
  800f3c:	0f bd cd             	bsr    %ebp,%ecx
  800f3f:	83 f1 1f             	xor    $0x1f,%ecx
  800f42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f46:	0f 84 b4 00 00 00    	je     801000 <__umoddi3+0x100>
  800f4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f57:	29 c2                	sub    %eax,%edx
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	d3 e5                	shl    %cl,%ebp
  800f5f:	89 d1                	mov    %edx,%ecx
  800f61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f65:	d3 e8                	shr    %cl,%eax
  800f67:	09 c5                	or     %eax,%ebp
  800f69:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	d3 e7                	shl    %cl,%edi
  800f71:	89 d1                	mov    %edx,%ecx
  800f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f77:	89 df                	mov    %ebx,%edi
  800f79:	d3 ef                	shr    %cl,%edi
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	89 f0                	mov    %esi,%eax
  800f7f:	d3 e3                	shl    %cl,%ebx
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 fa                	mov    %edi,%edx
  800f85:	d3 e8                	shr    %cl,%eax
  800f87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f8c:	09 d8                	or     %ebx,%eax
  800f8e:	f7 f5                	div    %ebp
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	f7 64 24 08          	mull   0x8(%esp)
  800f98:	39 d1                	cmp    %edx,%ecx
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	89 d7                	mov    %edx,%edi
  800f9e:	72 06                	jb     800fa6 <__umoddi3+0xa6>
  800fa0:	75 0e                	jne    800fb0 <__umoddi3+0xb0>
  800fa2:	39 c6                	cmp    %eax,%esi
  800fa4:	73 0a                	jae    800fb0 <__umoddi3+0xb0>
  800fa6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800faa:	19 ea                	sbb    %ebp,%edx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	89 c3                	mov    %eax,%ebx
  800fb0:	89 ca                	mov    %ecx,%edx
  800fb2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fb7:	29 de                	sub    %ebx,%esi
  800fb9:	19 fa                	sbb    %edi,%edx
  800fbb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fbf:	89 d0                	mov    %edx,%eax
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 d9                	mov    %ebx,%ecx
  800fc5:	d3 ee                	shr    %cl,%esi
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	09 f0                	or     %esi,%eax
  800fcb:	83 c4 1c             	add    $0x1c,%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
  800fd3:	90                   	nop
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	85 ff                	test   %edi,%edi
  800fda:	89 f9                	mov    %edi,%ecx
  800fdc:	75 0b                	jne    800fe9 <__umoddi3+0xe9>
  800fde:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f7                	div    %edi
  800fe7:	89 c1                	mov    %eax,%ecx
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f1                	div    %ecx
  800fef:	89 f0                	mov    %esi,%eax
  800ff1:	f7 f1                	div    %ecx
  800ff3:	e9 31 ff ff ff       	jmp    800f29 <__umoddi3+0x29>
  800ff8:	90                   	nop
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	39 dd                	cmp    %ebx,%ebp
  801002:	72 08                	jb     80100c <__umoddi3+0x10c>
  801004:	39 f7                	cmp    %esi,%edi
  801006:	0f 87 21 ff ff ff    	ja     800f2d <__umoddi3+0x2d>
  80100c:	89 da                	mov    %ebx,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	29 f8                	sub    %edi,%eax
  801012:	19 ea                	sbb    %ebp,%edx
  801014:	e9 14 ff ff ff       	jmp    800f2d <__umoddi3+0x2d>
