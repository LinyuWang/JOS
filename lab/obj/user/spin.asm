
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 40 10 80 00       	push   $0x801040
  80003f:	e8 68 01 00 00       	call   8001ac <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 29 0d 00 00       	call   800d72 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 10 80 00       	push   $0x8010b8
  800058:	e8 4f 01 00 00       	call   8001ac <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 10 80 00       	push   $0x801068
  80006c:	e8 3b 01 00 00       	call   8001ac <cprintf>
	sys_yield();
  800071:	e8 2e 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  800076:	e8 29 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  80007b:	e8 24 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  800080:	e8 1f 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  800085:	e8 1a 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  80008a:	e8 15 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  80008f:	e8 10 0b 00 00       	call   800ba4 <sys_yield>
	sys_yield();
  800094:	e8 0b 0b 00 00       	call   800ba4 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 10 80 00 	movl   $0x801090,(%esp)
  8000a0:	e8 07 01 00 00       	call   8001ac <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 97 0a 00 00       	call   800b44 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000c7:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000ca:	e8 b6 0a 00 00       	call   800b85 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dc:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e1:	85 db                	test   %ebx,%ebx
  8000e3:	7e 07                	jle    8000ec <libmain+0x37>
		binaryname = argv[0];
  8000e5:	8b 06                	mov    (%esi),%eax
  8000e7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	e8 3d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f6:	e8 0a 00 00 00       	call   800105 <exit>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010b:	6a 00                	push   $0x0
  80010d:	e8 32 0a 00 00       	call   800b44 <sys_env_destroy>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	53                   	push   %ebx
  80011b:	83 ec 04             	sub    $0x4,%esp
  80011e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800121:	8b 13                	mov    (%ebx),%edx
  800123:	8d 42 01             	lea    0x1(%edx),%eax
  800126:	89 03                	mov    %eax,(%ebx)
  800128:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800134:	74 09                	je     80013f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800136:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	68 ff 00 00 00       	push   $0xff
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 b7 09 00 00       	call   800b07 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb db                	jmp    800136 <putch+0x1f>

0080015b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800164:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016b:	00 00 00 
	b.cnt = 0;
  80016e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800175:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	68 17 01 80 00       	push   $0x800117
  80018a:	e8 1a 01 00 00       	call   8002a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 63 09 00 00       	call   800b07 <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	e8 9d ff ff ff       	call   80015b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 1c             	sub    $0x1c,%esp
  8001c9:	89 c7                	mov    %eax,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e7:	39 d3                	cmp    %edx,%ebx
  8001e9:	72 05                	jb     8001f0 <printnum+0x30>
  8001eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ee:	77 7a                	ja     80026a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fc:	53                   	push   %ebx
  8001fd:	ff 75 10             	pushl  0x10(%ebp)
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 e4             	pushl  -0x1c(%ebp)
  800206:	ff 75 e0             	pushl  -0x20(%ebp)
  800209:	ff 75 dc             	pushl  -0x24(%ebp)
  80020c:	ff 75 d8             	pushl  -0x28(%ebp)
  80020f:	e8 dc 0b 00 00       	call   800df0 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 f2                	mov    %esi,%edx
  80021b:	89 f8                	mov    %edi,%eax
  80021d:	e8 9e ff ff ff       	call   8001c0 <printnum>
  800222:	83 c4 20             	add    $0x20,%esp
  800225:	eb 13                	jmp    80023a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	ff 75 18             	pushl  0x18(%ebp)
  80022e:	ff d7                	call   *%edi
  800230:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800233:	83 eb 01             	sub    $0x1,%ebx
  800236:	85 db                	test   %ebx,%ebx
  800238:	7f ed                	jg     800227 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	56                   	push   %esi
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	ff 75 e4             	pushl  -0x1c(%ebp)
  800244:	ff 75 e0             	pushl  -0x20(%ebp)
  800247:	ff 75 dc             	pushl  -0x24(%ebp)
  80024a:	ff 75 d8             	pushl  -0x28(%ebp)
  80024d:	e8 be 0c 00 00       	call   800f10 <__umoddi3>
  800252:	83 c4 14             	add    $0x14,%esp
  800255:	0f be 80 e0 10 80 00 	movsbl 0x8010e0(%eax),%eax
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026d:	eb c4                	jmp    800233 <printnum+0x73>

0080026f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1b>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 10             	pushl  0x10(%ebp)
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	e8 05 00 00 00       	call   8002a9 <vprintfmt>
}
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <vprintfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 2c             	sub    $0x2c,%esp
  8002b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bb:	e9 63 03 00 00       	jmp    800623 <vprintfmt+0x37a>
		padc = ' ';
  8002c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 17             	movzbl (%edi),%edx
  8002e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 11 04 00 00    	ja     800703 <vprintfmt+0x45a>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800303:	eb d9                	jmp    8002de <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800308:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030c:	eb d0                	jmp    8002de <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	0f b6 d2             	movzbl %dl,%edx
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800314:	b8 00 00 00 00       	mov    $0x0,%eax
  800319:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800323:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800326:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800329:	83 f9 09             	cmp    $0x9,%ecx
  80032c:	77 55                	ja     800383 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80032e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800331:	eb e9                	jmp    80031c <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800333:	8b 45 14             	mov    0x14(%ebp),%eax
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 40 04             	lea    0x4(%eax),%eax
  800341:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800347:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034b:	79 91                	jns    8002de <vprintfmt+0x35>
				width = precision, precision = -1;
  80034d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800350:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800353:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035a:	eb 82                	jmp    8002de <vprintfmt+0x35>
  80035c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035f:	85 c0                	test   %eax,%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	0f 49 d0             	cmovns %eax,%edx
  800369:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036f:	e9 6a ff ff ff       	jmp    8002de <vprintfmt+0x35>
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800377:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037e:	e9 5b ff ff ff       	jmp    8002de <vprintfmt+0x35>
  800383:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800389:	eb bc                	jmp    800347 <vprintfmt+0x9e>
			lflag++;
  80038b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800391:	e9 48 ff ff ff       	jmp    8002de <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 78 04             	lea    0x4(%eax),%edi
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003aa:	e9 71 02 00 00       	jmp    800620 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 78 04             	lea    0x4(%eax),%edi
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	99                   	cltd   
  8003b8:	31 d0                	xor    %edx,%eax
  8003ba:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bc:	83 f8 08             	cmp    $0x8,%eax
  8003bf:	7f 23                	jg     8003e4 <vprintfmt+0x13b>
  8003c1:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	74 18                	je     8003e4 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003cc:	52                   	push   %edx
  8003cd:	68 01 11 80 00       	push   $0x801101
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 b3 fe ff ff       	call   80028c <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003dc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003df:	e9 3c 02 00 00       	jmp    800620 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8003e4:	50                   	push   %eax
  8003e5:	68 f8 10 80 00       	push   $0x8010f8
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 9b fe ff ff       	call   80028c <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f7:	e9 24 02 00 00       	jmp    800620 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	83 c0 04             	add    $0x4,%eax
  800402:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040a:	85 ff                	test   %edi,%edi
  80040c:	b8 f1 10 80 00       	mov    $0x8010f1,%eax
  800411:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 8e bd 00 00 00    	jle    8004db <vprintfmt+0x232>
  80041e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800422:	75 0e                	jne    800432 <vprintfmt+0x189>
  800424:	89 75 08             	mov    %esi,0x8(%ebp)
  800427:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800430:	eb 6d                	jmp    80049f <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 d0             	pushl  -0x30(%ebp)
  800438:	57                   	push   %edi
  800439:	e8 6d 03 00 00       	call   8007ab <strnlen>
  80043e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800441:	29 c1                	sub    %eax,%ecx
  800443:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800449:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800453:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	eb 0f                	jmp    800466 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 ff                	test   %edi,%edi
  800468:	7f ed                	jg     800457 <vprintfmt+0x1ae>
  80046a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800470:	85 c9                	test   %ecx,%ecx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c1             	cmovns %ecx,%eax
  80047a:	29 c1                	sub    %eax,%ecx
  80047c:	89 75 08             	mov    %esi,0x8(%ebp)
  80047f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800485:	89 cb                	mov    %ecx,%ebx
  800487:	eb 16                	jmp    80049f <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048d:	75 31                	jne    8004c0 <vprintfmt+0x217>
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	50                   	push   %eax
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	83 c7 01             	add    $0x1,%edi
  8004a2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004a6:	0f be c2             	movsbl %dl,%eax
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	74 59                	je     800506 <vprintfmt+0x25d>
  8004ad:	85 f6                	test   %esi,%esi
  8004af:	78 d8                	js     800489 <vprintfmt+0x1e0>
  8004b1:	83 ee 01             	sub    $0x1,%esi
  8004b4:	79 d3                	jns    800489 <vprintfmt+0x1e0>
  8004b6:	89 df                	mov    %ebx,%edi
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004be:	eb 37                	jmp    8004f7 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	0f be d2             	movsbl %dl,%edx
  8004c3:	83 ea 20             	sub    $0x20,%edx
  8004c6:	83 fa 5e             	cmp    $0x5e,%edx
  8004c9:	76 c4                	jbe    80048f <vprintfmt+0x1e6>
					putch('?', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	6a 3f                	push   $0x3f
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	eb c1                	jmp    80049c <vprintfmt+0x1f3>
  8004db:	89 75 08             	mov    %esi,0x8(%ebp)
  8004de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e7:	eb b6                	jmp    80049f <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	6a 20                	push   $0x20
  8004ef:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ee                	jg     8004e9 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800501:	e9 1a 01 00 00       	jmp    800620 <vprintfmt+0x377>
  800506:	89 df                	mov    %ebx,%edi
  800508:	8b 75 08             	mov    0x8(%ebp),%esi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	eb e7                	jmp    8004f7 <vprintfmt+0x24e>
	if (lflag >= 2)
  800510:	83 f9 01             	cmp    $0x1,%ecx
  800513:	7e 3f                	jle    800554 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 50 04             	mov    0x4(%eax),%edx
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800520:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 40 08             	lea    0x8(%eax),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800530:	79 5c                	jns    80058e <vprintfmt+0x2e5>
				putch('-', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 2d                	push   $0x2d
  800538:	ff d6                	call   *%esi
				num = -(long long) num;
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800540:	f7 da                	neg    %edx
  800542:	83 d1 00             	adc    $0x0,%ecx
  800545:	f7 d9                	neg    %ecx
  800547:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054f:	e9 b2 00 00 00       	jmp    800606 <vprintfmt+0x35d>
	else if (lflag)
  800554:	85 c9                	test   %ecx,%ecx
  800556:	75 1b                	jne    800573 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 c1                	mov    %eax,%ecx
  800562:	c1 f9 1f             	sar    $0x1f,%ecx
  800565:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb b9                	jmp    80052c <vprintfmt+0x283>
		return va_arg(*ap, long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 c1                	mov    %eax,%ecx
  80057d:	c1 f9 1f             	sar    $0x1f,%ecx
  800580:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb 9e                	jmp    80052c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80058e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800591:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	eb 6b                	jmp    800606 <vprintfmt+0x35d>
	if (lflag >= 2)
  80059b:	83 f9 01             	cmp    $0x1,%ecx
  80059e:	7e 15                	jle    8005b5 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a8:	8d 40 08             	lea    0x8(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	eb 51                	jmp    800606 <vprintfmt+0x35d>
	else if (lflag)
  8005b5:	85 c9                	test   %ecx,%ecx
  8005b7:	75 17                	jne    8005d0 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ce:	eb 36                	jmp    800606 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	eb 1f                	jmp    800606 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7e 5b                	jle    800647 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005fd:	89 d1                	mov    %edx,%ecx
  8005ff:	89 c2                	mov    %eax,%edx
			base = 8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80060d:	57                   	push   %edi
  80060e:	ff 75 e0             	pushl  -0x20(%ebp)
  800611:	50                   	push   %eax
  800612:	51                   	push   %ecx
  800613:	52                   	push   %edx
  800614:	89 da                	mov    %ebx,%edx
  800616:	89 f0                	mov    %esi,%eax
  800618:	e8 a3 fb ff ff       	call   8001c0 <printnum>
			break;
  80061d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800623:	83 c7 01             	add    $0x1,%edi
  800626:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062a:	83 f8 25             	cmp    $0x25,%eax
  80062d:	0f 84 8d fc ff ff    	je     8002c0 <vprintfmt+0x17>
			if (ch == '\0')
  800633:	85 c0                	test   %eax,%eax
  800635:	0f 84 e8 00 00 00    	je     800723 <vprintfmt+0x47a>
			putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	50                   	push   %eax
  800640:	ff d6                	call   *%esi
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	eb dc                	jmp    800623 <vprintfmt+0x37a>
	else if (lflag)
  800647:	85 c9                	test   %ecx,%ecx
  800649:	75 13                	jne    80065e <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	89 d0                	mov    %edx,%eax
  800652:	99                   	cltd   
  800653:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800656:	8d 49 04             	lea    0x4(%ecx),%ecx
  800659:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065c:	eb 9f                	jmp    8005fd <vprintfmt+0x354>
		return va_arg(*ap, long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	89 d0                	mov    %edx,%eax
  800665:	99                   	cltd   
  800666:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800669:	8d 49 04             	lea    0x4(%ecx),%ecx
  80066c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80066f:	eb 8c                	jmp    8005fd <vprintfmt+0x354>
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 30                	push   $0x30
  800677:	ff d6                	call   *%esi
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 78                	push   $0x78
  80067f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800699:	e9 68 ff ff ff       	jmp    800606 <vprintfmt+0x35d>
	if (lflag >= 2)
  80069e:	83 f9 01             	cmp    $0x1,%ecx
  8006a1:	7e 18                	jle    8006bb <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ab:	8d 40 08             	lea    0x8(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b6:	e9 4b ff ff ff       	jmp    800606 <vprintfmt+0x35d>
	else if (lflag)
  8006bb:	85 c9                	test   %ecx,%ecx
  8006bd:	75 1a                	jne    8006d9 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d4:	e9 2d ff ff ff       	jmp    800606 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ee:	e9 13 ff ff ff       	jmp    800606 <vprintfmt+0x35d>
			putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			break;
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	e9 1d ff ff ff       	jmp    800620 <vprintfmt+0x377>
			putch('%', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	6a 25                	push   $0x25
  800709:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	89 f8                	mov    %edi,%eax
  800710:	eb 03                	jmp    800715 <vprintfmt+0x46c>
  800712:	83 e8 01             	sub    $0x1,%eax
  800715:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800719:	75 f7                	jne    800712 <vprintfmt+0x469>
  80071b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071e:	e9 fd fe ff ff       	jmp    800620 <vprintfmt+0x377>
}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 18             	sub    $0x18,%esp
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800748:	85 c0                	test   %eax,%eax
  80074a:	74 26                	je     800772 <vsnprintf+0x47>
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e 22                	jle    800772 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800750:	ff 75 14             	pushl  0x14(%ebp)
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	68 6f 02 80 00       	push   $0x80026f
  80075f:	e8 45 fb ff ff       	call   8002a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	83 c4 10             	add    $0x10,%esp
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    
		return -E_INVAL;
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb f7                	jmp    800770 <vsnprintf+0x45>

00800779 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800782:	50                   	push   %eax
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	ff 75 0c             	pushl  0xc(%ebp)
  800789:	ff 75 08             	pushl  0x8(%ebp)
  80078c:	e8 9a ff ff ff       	call   80072b <vsnprintf>
	va_end(ap);

	return rc;
}
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
  80079e:	eb 03                	jmp    8007a3 <strlen+0x10>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0xd>
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	eb 03                	jmp    8007be <strnlen+0x13>
		n++;
  8007bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	39 d0                	cmp    %edx,%eax
  8007c0:	74 06                	je     8007c8 <strnlen+0x1d>
  8007c2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c6:	75 f3                	jne    8007bb <strnlen+0x10>
	return n;
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	89 c2                	mov    %eax,%edx
  8007d6:	83 c1 01             	add    $0x1,%ecx
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e3:	84 db                	test   %bl,%bl
  8007e5:	75 ef                	jne    8007d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	53                   	push   %ebx
  8007f2:	e8 9c ff ff ff       	call   800793 <strlen>
  8007f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	50                   	push   %eax
  800800:	e8 c5 ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  800805:	89 d8                	mov    %ebx,%eax
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800817:	89 f3                	mov    %esi,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	89 f2                	mov    %esi,%edx
  80081e:	eb 0f                	jmp    80082f <strncpy+0x23>
		*dst++ = *src;
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	0f b6 01             	movzbl (%ecx),%eax
  800826:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800829:	80 39 01             	cmpb   $0x1,(%ecx)
  80082c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80082f:	39 da                	cmp    %ebx,%edx
  800831:	75 ed                	jne    800820 <strncpy+0x14>
	}
	return ret;
}
  800833:	89 f0                	mov    %esi,%eax
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
  800844:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800847:	89 f0                	mov    %esi,%eax
  800849:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	75 0b                	jne    80085c <strlcpy+0x23>
  800851:	eb 17                	jmp    80086a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800853:	83 c2 01             	add    $0x1,%edx
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	74 07                	je     800867 <strlcpy+0x2e>
  800860:	0f b6 0a             	movzbl (%edx),%ecx
  800863:	84 c9                	test   %cl,%cl
  800865:	75 ec                	jne    800853 <strlcpy+0x1a>
		*dst = '\0';
  800867:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086a:	29 f0                	sub    %esi,%eax
}
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800879:	eb 06                	jmp    800881 <strcmp+0x11>
		p++, q++;
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800881:	0f b6 01             	movzbl (%ecx),%eax
  800884:	84 c0                	test   %al,%al
  800886:	74 04                	je     80088c <strcmp+0x1c>
  800888:	3a 02                	cmp    (%edx),%al
  80088a:	74 ef                	je     80087b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 c0             	movzbl %al,%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 c3                	mov    %eax,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strncmp+0x17>
		n--, p++, q++;
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ad:	39 d8                	cmp    %ebx,%eax
  8008af:	74 16                	je     8008c7 <strncmp+0x31>
  8008b1:	0f b6 08             	movzbl (%eax),%ecx
  8008b4:	84 c9                	test   %cl,%cl
  8008b6:	74 04                	je     8008bc <strncmp+0x26>
  8008b8:	3a 0a                	cmp    (%edx),%cl
  8008ba:	74 eb                	je     8008a7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bc:	0f b6 00             	movzbl (%eax),%eax
  8008bf:	0f b6 12             	movzbl (%edx),%edx
  8008c2:	29 d0                	sub    %edx,%eax
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    
		return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	eb f6                	jmp    8008c4 <strncmp+0x2e>

008008ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d8:	0f b6 10             	movzbl (%eax),%edx
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	74 09                	je     8008e8 <strchr+0x1a>
		if (*s == c)
  8008df:	38 ca                	cmp    %cl,%dl
  8008e1:	74 0a                	je     8008ed <strchr+0x1f>
	for (; *s; s++)
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	eb f0                	jmp    8008d8 <strchr+0xa>
			return (char *) s;
	return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f9:	eb 03                	jmp    8008fe <strfind+0xf>
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 04                	je     800909 <strfind+0x1a>
  800905:	84 d2                	test   %dl,%dl
  800907:	75 f2                	jne    8008fb <strfind+0xc>
			break;
	return (char *) s;
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 7d 08             	mov    0x8(%ebp),%edi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	74 13                	je     80092e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800921:	75 05                	jne    800928 <memset+0x1d>
  800923:	f6 c1 03             	test   $0x3,%cl
  800926:	74 0d                	je     800935 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	fc                   	cld    
  80092c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092e:	89 f8                	mov    %edi,%eax
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d0                	mov    %edx,%eax
  800940:	c1 e0 18             	shl    $0x18,%eax
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 10             	shl    $0x10,%esi
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 c2                	or     %eax,%edx
  80094c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80094e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800951:	89 d0                	mov    %edx,%eax
  800953:	fc                   	cld    
  800954:	f3 ab                	rep stos %eax,%es:(%edi)
  800956:	eb d6                	jmp    80092e <memset+0x23>

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 35                	jae    80099f <memmove+0x47>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 c2                	cmp    %eax,%edx
  80096f:	76 2e                	jbe    80099f <memmove+0x47>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 d6                	mov    %edx,%esi
  800976:	09 fe                	or     %edi,%esi
  800978:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097e:	74 0c                	je     80098c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800980:	83 ef 01             	sub    $0x1,%edi
  800983:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800986:	fd                   	std    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800989:	fc                   	cld    
  80098a:	eb 21                	jmp    8009ad <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 ef                	jne    800980 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800991:	83 ef 04             	sub    $0x4,%edi
  800994:	8d 72 fc             	lea    -0x4(%edx),%esi
  800997:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099a:	fd                   	std    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb ea                	jmp    800989 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 f2                	mov    %esi,%edx
  8009a1:	09 c2                	or     %eax,%edx
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	74 09                	je     8009b1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 f2                	jne    8009a8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb ed                	jmp    8009ad <memmove+0x55>

008009c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c3:	ff 75 10             	pushl  0x10(%ebp)
  8009c6:	ff 75 0c             	pushl  0xc(%ebp)
  8009c9:	ff 75 08             	pushl  0x8(%ebp)
  8009cc:	e8 87 ff ff ff       	call   800958 <memmove>
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 c6                	mov    %eax,%esi
  8009e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	39 f0                	cmp    %esi,%eax
  8009e5:	74 1c                	je     800a03 <memcmp+0x30>
		if (*s1 != *s2)
  8009e7:	0f b6 08             	movzbl (%eax),%ecx
  8009ea:	0f b6 1a             	movzbl (%edx),%ebx
  8009ed:	38 d9                	cmp    %bl,%cl
  8009ef:	75 08                	jne    8009f9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	83 c2 01             	add    $0x1,%edx
  8009f7:	eb ea                	jmp    8009e3 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c1             	movzbl %cl,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 05                	jmp    800a08 <memcmp+0x35>
	}

	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	73 09                	jae    800a27 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	38 08                	cmp    %cl,(%eax)
  800a20:	74 05                	je     800a27 <memfind+0x1b>
	for (; s < ends; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	eb f3                	jmp    800a1a <memfind+0xe>
			break;
	return (void *) s;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	74 2e                	je     800a77 <strtol+0x4e>
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	74 2f                	je     800a81 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 05                	jne    800a5f <strtol+0x36>
  800a5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5d:	74 2c                	je     800a8b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	75 0a                	jne    800a6d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a63:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a68:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6b:	74 28                	je     800a95 <strtol+0x6c>
		base = 10;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a75:	eb 50                	jmp    800ac7 <strtol+0x9e>
		s++;
  800a77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7f:	eb d1                	jmp    800a52 <strtol+0x29>
		s++, neg = 1;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	bf 01 00 00 00       	mov    $0x1,%edi
  800a89:	eb c7                	jmp    800a52 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8f:	74 0e                	je     800a9f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	75 d8                	jne    800a6d <strtol+0x44>
		s++, base = 8;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9d:	eb ce                	jmp    800a6d <strtol+0x44>
		s += 2, base = 16;
  800a9f:	83 c1 02             	add    $0x2,%ecx
  800aa2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa7:	eb c4                	jmp    800a6d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 29                	ja     800adc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abc:	7d 30                	jge    800aee <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac7:	0f b6 11             	movzbl (%ecx),%edx
  800aca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 09             	cmp    $0x9,%bl
  800ad2:	77 d5                	ja     800aa9 <strtol+0x80>
			dig = *s - '0';
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 30             	sub    $0x30,%edx
  800ada:	eb dd                	jmp    800ab9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800adc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 37             	sub    $0x37,%edx
  800aec:	eb cb                	jmp    800ab9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af2:	74 05                	je     800af9 <strtol+0xd0>
		*endptr = (char *) s;
  800af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	85 ff                	test   %edi,%edi
  800aff:	0f 45 c2             	cmovne %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7f 08                	jg     800b6e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	50                   	push   %eax
  800b72:	6a 03                	push   $0x3
  800b74:	68 24 13 80 00       	push   $0x801324
  800b79:	6a 23                	push   $0x23
  800b7b:	68 41 13 80 00       	push   $0x801341
  800b80:	e8 1b 02 00 00       	call   800da0 <_panic>

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7f 08                	jg     800bef <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 04                	push   $0x4
  800bf5:	68 24 13 80 00       	push   $0x801324
  800bfa:	6a 23                	push   $0x23
  800bfc:	68 41 13 80 00       	push   $0x801341
  800c01:	e8 9a 01 00 00       	call   800da0 <_panic>

00800c06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c20:	8b 75 18             	mov    0x18(%ebp),%esi
  800c23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7f 08                	jg     800c31 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 05                	push   $0x5
  800c37:	68 24 13 80 00       	push   $0x801324
  800c3c:	6a 23                	push   $0x23
  800c3e:	68 41 13 80 00       	push   $0x801341
  800c43:	e8 58 01 00 00       	call   800da0 <_panic>

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7f 08                	jg     800c73 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 06                	push   $0x6
  800c79:	68 24 13 80 00       	push   $0x801324
  800c7e:	6a 23                	push   $0x23
  800c80:	68 41 13 80 00       	push   $0x801341
  800c85:	e8 16 01 00 00       	call   800da0 <_panic>

00800c8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7f 08                	jg     800cb5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	6a 08                	push   $0x8
  800cbb:	68 24 13 80 00       	push   $0x801324
  800cc0:	6a 23                	push   $0x23
  800cc2:	68 41 13 80 00       	push   $0x801341
  800cc7:	e8 d4 00 00 00       	call   800da0 <_panic>

00800ccc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7f 08                	jg     800cf7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 09                	push   $0x9
  800cfd:	68 24 13 80 00       	push   $0x801324
  800d02:	6a 23                	push   $0x23
  800d04:	68 41 13 80 00       	push   $0x801341
  800d09:	e8 92 00 00 00       	call   800da0 <_panic>

00800d0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d47:	89 cb                	mov    %ecx,%ebx
  800d49:	89 cf                	mov    %ecx,%edi
  800d4b:	89 ce                	mov    %ecx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7f 08                	jg     800d5b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 0c                	push   $0xc
  800d61:	68 24 13 80 00       	push   $0x801324
  800d66:	6a 23                	push   $0x23
  800d68:	68 41 13 80 00       	push   $0x801341
  800d6d:	e8 2e 00 00 00       	call   800da0 <_panic>

00800d72 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d78:	68 5b 13 80 00       	push   $0x80135b
  800d7d:	6a 51                	push   $0x51
  800d7f:	68 4f 13 80 00       	push   $0x80134f
  800d84:	e8 17 00 00 00       	call   800da0 <_panic>

00800d89 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d8f:	68 5a 13 80 00       	push   $0x80135a
  800d94:	6a 58                	push   $0x58
  800d96:	68 4f 13 80 00       	push   $0x80134f
  800d9b:	e8 00 00 00 00       	call   800da0 <_panic>

00800da0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800da5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800da8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dae:	e8 d2 fd ff ff       	call   800b85 <sys_getenvid>
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	ff 75 08             	pushl  0x8(%ebp)
  800dbc:	56                   	push   %esi
  800dbd:	50                   	push   %eax
  800dbe:	68 70 13 80 00       	push   $0x801370
  800dc3:	e8 e4 f3 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc8:	83 c4 18             	add    $0x18,%esp
  800dcb:	53                   	push   %ebx
  800dcc:	ff 75 10             	pushl  0x10(%ebp)
  800dcf:	e8 87 f3 ff ff       	call   80015b <vcprintf>
	cprintf("\n");
  800dd4:	c7 04 24 d4 10 80 00 	movl   $0x8010d4,(%esp)
  800ddb:	e8 cc f3 ff ff       	call   8001ac <cprintf>
  800de0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800de3:	cc                   	int3   
  800de4:	eb fd                	jmp    800de3 <_panic+0x43>
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e07:	85 d2                	test   %edx,%edx
  800e09:	75 35                	jne    800e40 <__udivdi3+0x50>
  800e0b:	39 f3                	cmp    %esi,%ebx
  800e0d:	0f 87 bd 00 00 00    	ja     800ed0 <__udivdi3+0xe0>
  800e13:	85 db                	test   %ebx,%ebx
  800e15:	89 d9                	mov    %ebx,%ecx
  800e17:	75 0b                	jne    800e24 <__udivdi3+0x34>
  800e19:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f3                	div    %ebx
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	31 d2                	xor    %edx,%edx
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	f7 f1                	div    %ecx
  800e2a:	89 c6                	mov    %eax,%esi
  800e2c:	89 e8                	mov    %ebp,%eax
  800e2e:	89 f7                	mov    %esi,%edi
  800e30:	f7 f1                	div    %ecx
  800e32:	89 fa                	mov    %edi,%edx
  800e34:	83 c4 1c             	add    $0x1c,%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
  800e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 f2                	cmp    %esi,%edx
  800e42:	77 7c                	ja     800ec0 <__udivdi3+0xd0>
  800e44:	0f bd fa             	bsr    %edx,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0xf8>
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	b8 20 00 00 00       	mov    $0x20,%eax
  800e57:	29 f8                	sub    %edi,%eax
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 da                	mov    %ebx,%edx
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 d1                	or     %edx,%ecx
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 c1                	mov    %eax,%ecx
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	d3 e6                	shl    %cl,%esi
  800e81:	89 eb                	mov    %ebp,%ebx
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 de                	or     %ebx,%esi
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	f7 74 24 08          	divl   0x8(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	f7 64 24 0c          	mull   0xc(%esp)
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	72 0c                	jb     800ea7 <__udivdi3+0xb7>
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e5                	shl    %cl,%ebp
  800e9f:	39 c5                	cmp    %eax,%ebp
  800ea1:	73 5d                	jae    800f00 <__udivdi3+0x110>
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	75 59                	jne    800f00 <__udivdi3+0x110>
  800ea7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eaa:	31 ff                	xor    %edi,%edi
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	83 c4 1c             	add    $0x1c,%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
  800eb6:	8d 76 00             	lea    0x0(%esi),%esi
  800eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	31 c0                	xor    %eax,%eax
  800ec4:	89 fa                	mov    %edi,%edx
  800ec6:	83 c4 1c             	add    $0x1c,%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
  800ece:	66 90                	xchg   %ax,%ax
  800ed0:	31 ff                	xor    %edi,%edi
  800ed2:	89 e8                	mov    %ebp,%eax
  800ed4:	89 f2                	mov    %esi,%edx
  800ed6:	f7 f3                	div    %ebx
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x102>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 d2                	ja     800ec4 <__udivdi3+0xd4>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb cb                	jmp    800ec4 <__udivdi3+0xd4>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	31 ff                	xor    %edi,%edi
  800f04:	eb be                	jmp    800ec4 <__udivdi3+0xd4>
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 ed                	test   %ebp,%ebp
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	89 da                	mov    %ebx,%edx
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	0f 86 b1 00 00 00    	jbe    800fe8 <__umoddi3+0xd8>
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	39 dd                	cmp    %ebx,%ebp
  800f4a:	77 f1                	ja     800f3d <__umoddi3+0x2d>
  800f4c:	0f bd cd             	bsr    %ebp,%ecx
  800f4f:	83 f1 1f             	xor    $0x1f,%ecx
  800f52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f56:	0f 84 b4 00 00 00    	je     801010 <__umoddi3+0x100>
  800f5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	29 c2                	sub    %eax,%edx
  800f69:	89 c1                	mov    %eax,%ecx
  800f6b:	89 f8                	mov    %edi,%eax
  800f6d:	d3 e5                	shl    %cl,%ebp
  800f6f:	89 d1                	mov    %edx,%ecx
  800f71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f75:	d3 e8                	shr    %cl,%eax
  800f77:	09 c5                	or     %eax,%ebp
  800f79:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	d3 e7                	shl    %cl,%edi
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	d3 ef                	shr    %cl,%edi
  800f8b:	89 c1                	mov    %eax,%ecx
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 d1                	mov    %edx,%ecx
  800f93:	89 fa                	mov    %edi,%edx
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f9c:	09 d8                	or     %ebx,%eax
  800f9e:	f7 f5                	div    %ebp
  800fa0:	d3 e6                	shl    %cl,%esi
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	f7 64 24 08          	mull   0x8(%esp)
  800fa8:	39 d1                	cmp    %edx,%ecx
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	72 06                	jb     800fb6 <__umoddi3+0xa6>
  800fb0:	75 0e                	jne    800fc0 <__umoddi3+0xb0>
  800fb2:	39 c6                	cmp    %eax,%esi
  800fb4:	73 0a                	jae    800fc0 <__umoddi3+0xb0>
  800fb6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fba:	19 ea                	sbb    %ebp,%edx
  800fbc:	89 d7                	mov    %edx,%edi
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	89 ca                	mov    %ecx,%edx
  800fc2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fc7:	29 de                	sub    %ebx,%esi
  800fc9:	19 fa                	sbb    %edi,%edx
  800fcb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fcf:	89 d0                	mov    %edx,%eax
  800fd1:	d3 e0                	shl    %cl,%eax
  800fd3:	89 d9                	mov    %ebx,%ecx
  800fd5:	d3 ee                	shr    %cl,%esi
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	09 f0                	or     %esi,%eax
  800fdb:	83 c4 1c             	add    $0x1c,%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    
  800fe3:	90                   	nop
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	85 ff                	test   %edi,%edi
  800fea:	89 f9                	mov    %edi,%ecx
  800fec:	75 0b                	jne    800ff9 <__umoddi3+0xe9>
  800fee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f7                	div    %edi
  800ff7:	89 c1                	mov    %eax,%ecx
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f1                	div    %ecx
  800fff:	89 f0                	mov    %esi,%eax
  801001:	f7 f1                	div    %ecx
  801003:	e9 31 ff ff ff       	jmp    800f39 <__umoddi3+0x29>
  801008:	90                   	nop
  801009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801010:	39 dd                	cmp    %ebx,%ebp
  801012:	72 08                	jb     80101c <__umoddi3+0x10c>
  801014:	39 f7                	cmp    %esi,%edi
  801016:	0f 87 21 ff ff ff    	ja     800f3d <__umoddi3+0x2d>
  80101c:	89 da                	mov    %ebx,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	29 f8                	sub    %edi,%eax
  801022:	19 ea                	sbb    %ebp,%edx
  801024:	e9 14 ff ff ff       	jmp    800f3d <__umoddi3+0x2d>
