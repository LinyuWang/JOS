
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 e0 0f 80 00       	push   $0x800fe0
  800048:	e8 44 01 00 00       	call   800191 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 2f 0b 00 00       	call   800b89 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 00 10 80 00       	push   $0x801000
  80006c:	e8 20 01 00 00       	call   800191 <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 2c 10 80 00       	push   $0x80102c
  80008d:	e8 ff 00 00 00       	call   800191 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a5:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000ac:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000af:	e8 b6 0a 00 00       	call   800b6a <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	85 db                	test   %ebx,%ebx
  8000c8:	7e 07                	jle    8000d1 <libmain+0x37>
		binaryname = argv[0];
  8000ca:	8b 06                	mov    (%esi),%eax
  8000cc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	e8 58 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000db:	e8 0a 00 00 00       	call   8000ea <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f0:	6a 00                	push   $0x0
  8000f2:	e8 32 0a 00 00       	call   800b29 <sys_env_destroy>
}
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800106:	8b 13                	mov    (%ebx),%edx
  800108:	8d 42 01             	lea    0x1(%edx),%eax
  80010b:	89 03                	mov    %eax,(%ebx)
  80010d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800110:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800114:	3d ff 00 00 00       	cmp    $0xff,%eax
  800119:	74 09                	je     800124 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800122:	c9                   	leave  
  800123:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	68 ff 00 00 00       	push   $0xff
  80012c:	8d 43 08             	lea    0x8(%ebx),%eax
  80012f:	50                   	push   %eax
  800130:	e8 b7 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  800135:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	eb db                	jmp    80011b <putch+0x1f>

00800140 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	68 fc 00 80 00       	push   $0x8000fc
  80016f:	e8 1a 01 00 00       	call   80028e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800183:	50                   	push   %eax
  800184:	e8 63 09 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 9d ff ff ff       	call   800140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 1c             	sub    $0x1c,%esp
  8001ae:	89 c7                	mov    %eax,%edi
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cc:	39 d3                	cmp    %edx,%ebx
  8001ce:	72 05                	jb     8001d5 <printnum+0x30>
  8001d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d3:	77 7a                	ja     80024f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	ff 75 18             	pushl  0x18(%ebp)
  8001db:	8b 45 14             	mov    0x14(%ebp),%eax
  8001de:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 a7 0b 00 00       	call   800da0 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 9e ff ff ff       	call   8001a5 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 13                	jmp    80021f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f ed                	jg     80020c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 89 0c 00 00       	call   800ec0 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 55 10 80 00 	movsbl 0x801055(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    
  80024f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800252:	eb c4                	jmp    800218 <printnum+0x73>

00800254 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	3b 50 04             	cmp    0x4(%eax),%edx
  800263:	73 0a                	jae    80026f <sprintputch+0x1b>
		*b->buf++ = ch;
  800265:	8d 4a 01             	lea    0x1(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	88 02                	mov    %al,(%edx)
}
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <printfmt>:
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800277:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027a:	50                   	push   %eax
  80027b:	ff 75 10             	pushl  0x10(%ebp)
  80027e:	ff 75 0c             	pushl  0xc(%ebp)
  800281:	ff 75 08             	pushl  0x8(%ebp)
  800284:	e8 05 00 00 00       	call   80028e <vprintfmt>
}
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <vprintfmt>:
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	57                   	push   %edi
  800292:	56                   	push   %esi
  800293:	53                   	push   %ebx
  800294:	83 ec 2c             	sub    $0x2c,%esp
  800297:	8b 75 08             	mov    0x8(%ebp),%esi
  80029a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a0:	e9 63 03 00 00       	jmp    800608 <vprintfmt+0x37a>
		padc = ' ';
  8002a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c3:	8d 47 01             	lea    0x1(%edi),%eax
  8002c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c9:	0f b6 17             	movzbl (%edi),%edx
  8002cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cf:	3c 55                	cmp    $0x55,%al
  8002d1:	0f 87 11 04 00 00    	ja     8006e8 <vprintfmt+0x45a>
  8002d7:	0f b6 c0             	movzbl %al,%eax
  8002da:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8002e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002e8:	eb d9                	jmp    8002c3 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d0                	jmp    8002c3 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	0f b6 d2             	movzbl %dl,%edx
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800304:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800308:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030e:	83 f9 09             	cmp    $0x9,%ecx
  800311:	77 55                	ja     800368 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800316:	eb e9                	jmp    800301 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800320:	8b 45 14             	mov    0x14(%ebp),%eax
  800323:	8d 40 04             	lea    0x4(%eax),%eax
  800326:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800330:	79 91                	jns    8002c3 <vprintfmt+0x35>
				width = precision, precision = -1;
  800332:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800335:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800338:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033f:	eb 82                	jmp    8002c3 <vprintfmt+0x35>
  800341:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800344:	85 c0                	test   %eax,%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	0f 49 d0             	cmovns %eax,%edx
  80034e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800354:	e9 6a ff ff ff       	jmp    8002c3 <vprintfmt+0x35>
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800363:	e9 5b ff ff ff       	jmp    8002c3 <vprintfmt+0x35>
  800368:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80036e:	eb bc                	jmp    80032c <vprintfmt+0x9e>
			lflag++;
  800370:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800376:	e9 48 ff ff ff       	jmp    8002c3 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8d 78 04             	lea    0x4(%eax),%edi
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	ff 30                	pushl  (%eax)
  800387:	ff d6                	call   *%esi
			break;
  800389:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038f:	e9 71 02 00 00       	jmp    800605 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	99                   	cltd   
  80039d:	31 d0                	xor    %edx,%eax
  80039f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a1:	83 f8 08             	cmp    $0x8,%eax
  8003a4:	7f 23                	jg     8003c9 <vprintfmt+0x13b>
  8003a6:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8003ad:	85 d2                	test   %edx,%edx
  8003af:	74 18                	je     8003c9 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003b1:	52                   	push   %edx
  8003b2:	68 76 10 80 00       	push   $0x801076
  8003b7:	53                   	push   %ebx
  8003b8:	56                   	push   %esi
  8003b9:	e8 b3 fe ff ff       	call   800271 <printfmt>
  8003be:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c4:	e9 3c 02 00 00       	jmp    800605 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8003c9:	50                   	push   %eax
  8003ca:	68 6d 10 80 00       	push   $0x80106d
  8003cf:	53                   	push   %ebx
  8003d0:	56                   	push   %esi
  8003d1:	e8 9b fe ff ff       	call   800271 <printfmt>
  8003d6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003dc:	e9 24 02 00 00       	jmp    800605 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	83 c0 04             	add    $0x4,%eax
  8003e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ef:	85 ff                	test   %edi,%edi
  8003f1:	b8 66 10 80 00       	mov    $0x801066,%eax
  8003f6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fd:	0f 8e bd 00 00 00    	jle    8004c0 <vprintfmt+0x232>
  800403:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800407:	75 0e                	jne    800417 <vprintfmt+0x189>
  800409:	89 75 08             	mov    %esi,0x8(%ebp)
  80040c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80040f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800412:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800415:	eb 6d                	jmp    800484 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 6d 03 00 00       	call   800790 <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0f                	jmp    80044b <vprintfmt+0x1bd>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ef 01             	sub    $0x1,%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 ff                	test   %edi,%edi
  80044d:	7f ed                	jg     80043c <vprintfmt+0x1ae>
  80044f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800452:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 49 c1             	cmovns %ecx,%eax
  80045f:	29 c1                	sub    %eax,%ecx
  800461:	89 75 08             	mov    %esi,0x8(%ebp)
  800464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046a:	89 cb                	mov    %ecx,%ebx
  80046c:	eb 16                	jmp    800484 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	75 31                	jne    8004a5 <vprintfmt+0x217>
					putch(ch, putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 0c             	pushl  0xc(%ebp)
  80047a:	50                   	push   %eax
  80047b:	ff 55 08             	call   *0x8(%ebp)
  80047e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800481:	83 eb 01             	sub    $0x1,%ebx
  800484:	83 c7 01             	add    $0x1,%edi
  800487:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80048b:	0f be c2             	movsbl %dl,%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	74 59                	je     8004eb <vprintfmt+0x25d>
  800492:	85 f6                	test   %esi,%esi
  800494:	78 d8                	js     80046e <vprintfmt+0x1e0>
  800496:	83 ee 01             	sub    $0x1,%esi
  800499:	79 d3                	jns    80046e <vprintfmt+0x1e0>
  80049b:	89 df                	mov    %ebx,%edi
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a3:	eb 37                	jmp    8004dc <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	0f be d2             	movsbl %dl,%edx
  8004a8:	83 ea 20             	sub    $0x20,%edx
  8004ab:	83 fa 5e             	cmp    $0x5e,%edx
  8004ae:	76 c4                	jbe    800474 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	6a 3f                	push   $0x3f
  8004b8:	ff 55 08             	call   *0x8(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	eb c1                	jmp    800481 <vprintfmt+0x1f3>
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cc:	eb b6                	jmp    800484 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	6a 20                	push   $0x20
  8004d4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d6:	83 ef 01             	sub    $0x1,%edi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7f ee                	jg     8004ce <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e6:	e9 1a 01 00 00       	jmp    800605 <vprintfmt+0x377>
  8004eb:	89 df                	mov    %ebx,%edi
  8004ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f3:	eb e7                	jmp    8004dc <vprintfmt+0x24e>
	if (lflag >= 2)
  8004f5:	83 f9 01             	cmp    $0x1,%ecx
  8004f8:	7e 3f                	jle    800539 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8b 50 04             	mov    0x4(%eax),%edx
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800505:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 40 08             	lea    0x8(%eax),%eax
  80050e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800511:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800515:	79 5c                	jns    800573 <vprintfmt+0x2e5>
				putch('-', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	53                   	push   %ebx
  80051b:	6a 2d                	push   $0x2d
  80051d:	ff d6                	call   *%esi
				num = -(long long) num;
  80051f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800522:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800525:	f7 da                	neg    %edx
  800527:	83 d1 00             	adc    $0x0,%ecx
  80052a:	f7 d9                	neg    %ecx
  80052c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800534:	e9 b2 00 00 00       	jmp    8005eb <vprintfmt+0x35d>
	else if (lflag)
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	75 1b                	jne    800558 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800545:	89 c1                	mov    %eax,%ecx
  800547:	c1 f9 1f             	sar    $0x1f,%ecx
  80054a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 40 04             	lea    0x4(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	eb b9                	jmp    800511 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 c1                	mov    %eax,%ecx
  800562:	c1 f9 1f             	sar    $0x1f,%ecx
  800565:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb 9e                	jmp    800511 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800573:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800576:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 6b                	jmp    8005eb <vprintfmt+0x35d>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 15                	jle    80059a <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8b 48 04             	mov    0x4(%eax),%ecx
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	eb 51                	jmp    8005eb <vprintfmt+0x35d>
	else if (lflag)
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	75 17                	jne    8005b5 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a8:	8d 40 04             	lea    0x4(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	eb 36                	jmp    8005eb <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	eb 1f                	jmp    8005eb <vprintfmt+0x35d>
	if (lflag >= 2)
  8005cc:	83 f9 01             	cmp    $0x1,%ecx
  8005cf:	7e 5b                	jle    80062c <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 50 04             	mov    0x4(%eax),%edx
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005dc:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005e2:	89 d1                	mov    %edx,%ecx
  8005e4:	89 c2                	mov    %eax,%edx
			base = 8;
  8005e6:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f2:	57                   	push   %edi
  8005f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f6:	50                   	push   %eax
  8005f7:	51                   	push   %ecx
  8005f8:	52                   	push   %edx
  8005f9:	89 da                	mov    %ebx,%edx
  8005fb:	89 f0                	mov    %esi,%eax
  8005fd:	e8 a3 fb ff ff       	call   8001a5 <printnum>
			break;
  800602:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800608:	83 c7 01             	add    $0x1,%edi
  80060b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060f:	83 f8 25             	cmp    $0x25,%eax
  800612:	0f 84 8d fc ff ff    	je     8002a5 <vprintfmt+0x17>
			if (ch == '\0')
  800618:	85 c0                	test   %eax,%eax
  80061a:	0f 84 e8 00 00 00    	je     800708 <vprintfmt+0x47a>
			putch(ch, putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	50                   	push   %eax
  800625:	ff d6                	call   *%esi
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	eb dc                	jmp    800608 <vprintfmt+0x37a>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	75 13                	jne    800643 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	89 d0                	mov    %edx,%eax
  800637:	99                   	cltd   
  800638:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800641:	eb 9f                	jmp    8005e2 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	89 d0                	mov    %edx,%eax
  80064a:	99                   	cltd   
  80064b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064e:	8d 49 04             	lea    0x4(%ecx),%ecx
  800651:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800654:	eb 8c                	jmp    8005e2 <vprintfmt+0x354>
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
			num = (unsigned long long)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800670:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067e:	e9 68 ff ff ff       	jmp    8005eb <vprintfmt+0x35d>
	if (lflag >= 2)
  800683:	83 f9 01             	cmp    $0x1,%ecx
  800686:	7e 18                	jle    8006a0 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	8b 48 04             	mov    0x4(%eax),%ecx
  800690:	8d 40 08             	lea    0x8(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
  80069b:	e9 4b ff ff ff       	jmp    8005eb <vprintfmt+0x35d>
	else if (lflag)
  8006a0:	85 c9                	test   %ecx,%ecx
  8006a2:	75 1a                	jne    8006be <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b9:	e9 2d ff ff ff       	jmp    8005eb <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d3:	e9 13 ff ff ff       	jmp    8005eb <vprintfmt+0x35d>
			putch(ch, putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 25                	push   $0x25
  8006de:	ff d6                	call   *%esi
			break;
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	e9 1d ff ff ff       	jmp    800605 <vprintfmt+0x377>
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	89 f8                	mov    %edi,%eax
  8006f5:	eb 03                	jmp    8006fa <vprintfmt+0x46c>
  8006f7:	83 e8 01             	sub    $0x1,%eax
  8006fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fe:	75 f7                	jne    8006f7 <vprintfmt+0x469>
  800700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800703:	e9 fd fe ff ff       	jmp    800605 <vprintfmt+0x377>
}
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 18             	sub    $0x18,%esp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 26                	je     800757 <vsnprintf+0x47>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 22                	jle    800757 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	ff 75 14             	pushl  0x14(%ebp)
  800738:	ff 75 10             	pushl  0x10(%ebp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	68 54 02 80 00       	push   $0x800254
  800744:	e8 45 fb ff ff       	call   80028e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	83 c4 10             	add    $0x10,%esp
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    
		return -E_INVAL;
  800757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075c:	eb f7                	jmp    800755 <vsnprintf+0x45>

0080075e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800767:	50                   	push   %eax
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	ff 75 08             	pushl  0x8(%ebp)
  800771:	e8 9a ff ff ff       	call   800710 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 03                	jmp    800788 <strlen+0x10>
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800788:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078c:	75 f7                	jne    800785 <strlen+0xd>
	return n;
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
  80079e:	eb 03                	jmp    8007a3 <strnlen+0x13>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	39 d0                	cmp    %edx,%eax
  8007a5:	74 06                	je     8007ad <strnlen+0x1d>
  8007a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ab:	75 f3                	jne    8007a0 <strnlen+0x10>
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	83 c2 01             	add    $0x1,%edx
  8007c1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c8:	84 db                	test   %bl,%bl
  8007ca:	75 ef                	jne    8007bb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cc:	5b                   	pop    %ebx
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	53                   	push   %ebx
  8007d7:	e8 9c ff ff ff       	call   800778 <strlen>
  8007dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	01 d8                	add    %ebx,%eax
  8007e4:	50                   	push   %eax
  8007e5:	e8 c5 ff ff ff       	call   8007af <strcpy>
	return dst;
}
  8007ea:	89 d8                	mov    %ebx,%eax
  8007ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fc:	89 f3                	mov    %esi,%ebx
  8007fe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	89 f2                	mov    %esi,%edx
  800803:	eb 0f                	jmp    800814 <strncpy+0x23>
		*dst++ = *src;
  800805:	83 c2 01             	add    $0x1,%edx
  800808:	0f b6 01             	movzbl (%ecx),%eax
  80080b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080e:	80 39 01             	cmpb   $0x1,(%ecx)
  800811:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800814:	39 da                	cmp    %ebx,%edx
  800816:	75 ed                	jne    800805 <strncpy+0x14>
	}
	return ret;
}
  800818:	89 f0                	mov    %esi,%eax
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	85 c9                	test   %ecx,%ecx
  800834:	75 0b                	jne    800841 <strlcpy+0x23>
  800836:	eb 17                	jmp    80084f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800838:	83 c2 01             	add    $0x1,%edx
  80083b:	83 c0 01             	add    $0x1,%eax
  80083e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	74 07                	je     80084c <strlcpy+0x2e>
  800845:	0f b6 0a             	movzbl (%edx),%ecx
  800848:	84 c9                	test   %cl,%cl
  80084a:	75 ec                	jne    800838 <strlcpy+0x1a>
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 16                	je     8008ac <strncmp+0x31>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb f6                	jmp    8008a9 <strncmp+0x2e>

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	0f b6 10             	movzbl (%eax),%edx
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	74 09                	je     8008cd <strchr+0x1a>
		if (*s == c)
  8008c4:	38 ca                	cmp    %cl,%dl
  8008c6:	74 0a                	je     8008d2 <strchr+0x1f>
	for (; *s; s++)
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	eb f0                	jmp    8008bd <strchr+0xa>
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 13                	je     800913 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 05                	jne    80090d <memset+0x1d>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	74 0d                	je     80091a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 f8                	mov    %edi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 18             	shl    $0x18,%eax
  800928:	89 d6                	mov    %edx,%esi
  80092a:	c1 e6 10             	shl    $0x10,%esi
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
  800931:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800933:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800936:	89 d0                	mov    %edx,%eax
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb d6                	jmp    800913 <memset+0x23>

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 c2                	cmp    %eax,%edx
  800954:	76 2e                	jbe    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	74 0c                	je     800971 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800965:	83 ef 01             	sub    $0x1,%edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 21                	jmp    800992 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 ef                	jne    800965 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb ea                	jmp    80096e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	74 09                	je     800996 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 f2                	jne    80098d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb ed                	jmp    800992 <memmove+0x55>

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	39 f0                	cmp    %esi,%eax
  8009ca:	74 1c                	je     8009e8 <memcmp+0x30>
		if (*s1 != *s2)
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	0f b6 1a             	movzbl (%edx),%ebx
  8009d2:	38 d9                	cmp    %bl,%cl
  8009d4:	75 08                	jne    8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
  8009dc:	eb ea                	jmp    8009c8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 05                	jmp    8009ed <memcmp+0x35>
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	39 d0                	cmp    %edx,%eax
  800a01:	73 09                	jae    800a0c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	38 08                	cmp    %cl,(%eax)
  800a05:	74 05                	je     800a0c <memfind+0x1b>
	for (; s < ends; s++)
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	eb f3                	jmp    8009ff <memfind+0xe>
			break;
	return (void *) s;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	eb 03                	jmp    800a1f <strtol+0x11>
		s++;
  800a1c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1f:	0f b6 01             	movzbl (%ecx),%eax
  800a22:	3c 20                	cmp    $0x20,%al
  800a24:	74 f6                	je     800a1c <strtol+0xe>
  800a26:	3c 09                	cmp    $0x9,%al
  800a28:	74 f2                	je     800a1c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a2a:	3c 2b                	cmp    $0x2b,%al
  800a2c:	74 2e                	je     800a5c <strtol+0x4e>
	int neg = 0;
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a33:	3c 2d                	cmp    $0x2d,%al
  800a35:	74 2f                	je     800a66 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3d:	75 05                	jne    800a44 <strtol+0x36>
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	74 2c                	je     800a70 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	75 0a                	jne    800a52 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a48:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	74 28                	je     800a7a <strtol+0x6c>
		base = 10;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5a:	eb 50                	jmp    800aac <strtol+0x9e>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb d1                	jmp    800a37 <strtol+0x29>
		s++, neg = 1;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6e:	eb c7                	jmp    800a37 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a74:	74 0e                	je     800a84 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 d8                	jne    800a52 <strtol+0x44>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a82:	eb ce                	jmp    800a52 <strtol+0x44>
		s += 2, base = 16;
  800a84:	83 c1 02             	add    $0x2,%ecx
  800a87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8c:	eb c4                	jmp    800a52 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 29                	ja     800ac1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa1:	7d 30                	jge    800ad3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aac:	0f b6 11             	movzbl (%ecx),%edx
  800aaf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 09             	cmp    $0x9,%bl
  800ab7:	77 d5                	ja     800a8e <strtol+0x80>
			dig = *s - '0';
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 30             	sub    $0x30,%edx
  800abf:	eb dd                	jmp    800a9e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 08                	ja     800ad3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
  800ad1:	eb cb                	jmp    800a9e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad7:	74 05                	je     800ade <strtol+0xd0>
		*endptr = (char *) s;
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	f7 da                	neg    %edx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 45 c2             	cmovne %edx,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 c6                	mov    %eax,%esi
  800b03:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3f:	89 cb                	mov    %ecx,%ebx
  800b41:	89 cf                	mov    %ecx,%edi
  800b43:	89 ce                	mov    %ecx,%esi
  800b45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7f 08                	jg     800b53 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	6a 03                	push   $0x3
  800b59:	68 a4 12 80 00       	push   $0x8012a4
  800b5e:	6a 23                	push   $0x23
  800b60:	68 c1 12 80 00       	push   $0x8012c1
  800b65:	e8 ed 01 00 00       	call   800d57 <_panic>

00800b6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	89 d1                	mov    %edx,%ecx
  800b9b:	89 d3                	mov    %edx,%ebx
  800b9d:	89 d7                	mov    %edx,%edi
  800b9f:	89 d6                	mov    %edx,%esi
  800ba1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	be 00 00 00 00       	mov    $0x0,%esi
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc4:	89 f7                	mov    %esi,%edi
  800bc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7f 08                	jg     800bd4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 04                	push   $0x4
  800bda:	68 a4 12 80 00       	push   $0x8012a4
  800bdf:	6a 23                	push   $0x23
  800be1:	68 c1 12 80 00       	push   $0x8012c1
  800be6:	e8 6c 01 00 00       	call   800d57 <_panic>

00800beb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c05:	8b 75 18             	mov    0x18(%ebp),%esi
  800c08:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7f 08                	jg     800c16 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 05                	push   $0x5
  800c1c:	68 a4 12 80 00       	push   $0x8012a4
  800c21:	6a 23                	push   $0x23
  800c23:	68 c1 12 80 00       	push   $0x8012c1
  800c28:	e8 2a 01 00 00       	call   800d57 <_panic>

00800c2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7f 08                	jg     800c58 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 06                	push   $0x6
  800c5e:	68 a4 12 80 00       	push   $0x8012a4
  800c63:	6a 23                	push   $0x23
  800c65:	68 c1 12 80 00       	push   $0x8012c1
  800c6a:	e8 e8 00 00 00       	call   800d57 <_panic>

00800c6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7f 08                	jg     800c9a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 08                	push   $0x8
  800ca0:	68 a4 12 80 00       	push   $0x8012a4
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 c1 12 80 00       	push   $0x8012c1
  800cac:	e8 a6 00 00 00       	call   800d57 <_panic>

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7f 08                	jg     800cdc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 09                	push   $0x9
  800ce2:	68 a4 12 80 00       	push   $0x8012a4
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 c1 12 80 00       	push   $0x8012c1
  800cee:	e8 64 00 00 00       	call   800d57 <_panic>

00800cf3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d04:	be 00 00 00 00       	mov    $0x0,%esi
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2c:	89 cb                	mov    %ecx,%ebx
  800d2e:	89 cf                	mov    %ecx,%edi
  800d30:	89 ce                	mov    %ecx,%esi
  800d32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7f 08                	jg     800d40 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 0c                	push   $0xc
  800d46:	68 a4 12 80 00       	push   $0x8012a4
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 c1 12 80 00       	push   $0x8012c1
  800d52:	e8 00 00 00 00       	call   800d57 <_panic>

00800d57 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d5c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d5f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d65:	e8 00 fe ff ff       	call   800b6a <sys_getenvid>
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	ff 75 0c             	pushl  0xc(%ebp)
  800d70:	ff 75 08             	pushl  0x8(%ebp)
  800d73:	56                   	push   %esi
  800d74:	50                   	push   %eax
  800d75:	68 d0 12 80 00       	push   $0x8012d0
  800d7a:	e8 12 f4 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d7f:	83 c4 18             	add    $0x18,%esp
  800d82:	53                   	push   %ebx
  800d83:	ff 75 10             	pushl  0x10(%ebp)
  800d86:	e8 b5 f3 ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  800d8b:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800d92:	e8 fa f3 ff ff       	call   800191 <cprintf>
  800d97:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d9a:	cc                   	int3   
  800d9b:	eb fd                	jmp    800d9a <_panic+0x43>
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800daf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800db7:	85 d2                	test   %edx,%edx
  800db9:	75 35                	jne    800df0 <__udivdi3+0x50>
  800dbb:	39 f3                	cmp    %esi,%ebx
  800dbd:	0f 87 bd 00 00 00    	ja     800e80 <__udivdi3+0xe0>
  800dc3:	85 db                	test   %ebx,%ebx
  800dc5:	89 d9                	mov    %ebx,%ecx
  800dc7:	75 0b                	jne    800dd4 <__udivdi3+0x34>
  800dc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f3                	div    %ebx
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	31 d2                	xor    %edx,%edx
  800dd6:	89 f0                	mov    %esi,%eax
  800dd8:	f7 f1                	div    %ecx
  800dda:	89 c6                	mov    %eax,%esi
  800ddc:	89 e8                	mov    %ebp,%eax
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	f7 f1                	div    %ecx
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	83 c4 1c             	add    $0x1c,%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 f2                	cmp    %esi,%edx
  800df2:	77 7c                	ja     800e70 <__udivdi3+0xd0>
  800df4:	0f bd fa             	bsr    %edx,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0xf8>
  800e00:	89 f9                	mov    %edi,%ecx
  800e02:	b8 20 00 00 00       	mov    $0x20,%eax
  800e07:	29 f8                	sub    %edi,%eax
  800e09:	d3 e2                	shl    %cl,%edx
  800e0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	89 da                	mov    %ebx,%edx
  800e13:	d3 ea                	shr    %cl,%edx
  800e15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e19:	09 d1                	or     %edx,%ecx
  800e1b:	89 f2                	mov    %esi,%edx
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e3                	shl    %cl,%ebx
  800e25:	89 c1                	mov    %eax,%ecx
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	89 f9                	mov    %edi,%ecx
  800e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e2f:	d3 e6                	shl    %cl,%esi
  800e31:	89 eb                	mov    %ebp,%ebx
  800e33:	89 c1                	mov    %eax,%ecx
  800e35:	d3 eb                	shr    %cl,%ebx
  800e37:	09 de                	or     %ebx,%esi
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	f7 74 24 08          	divl   0x8(%esp)
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	f7 64 24 0c          	mull   0xc(%esp)
  800e47:	39 d6                	cmp    %edx,%esi
  800e49:	72 0c                	jb     800e57 <__udivdi3+0xb7>
  800e4b:	89 f9                	mov    %edi,%ecx
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	39 c5                	cmp    %eax,%ebp
  800e51:	73 5d                	jae    800eb0 <__udivdi3+0x110>
  800e53:	39 d6                	cmp    %edx,%esi
  800e55:	75 59                	jne    800eb0 <__udivdi3+0x110>
  800e57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e5a:	31 ff                	xor    %edi,%edi
  800e5c:	89 fa                	mov    %edi,%edx
  800e5e:	83 c4 1c             	add    $0x1c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    
  800e66:	8d 76 00             	lea    0x0(%esi),%esi
  800e69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e70:	31 ff                	xor    %edi,%edi
  800e72:	31 c0                	xor    %eax,%eax
  800e74:	89 fa                	mov    %edi,%edx
  800e76:	83 c4 1c             	add    $0x1c,%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	31 ff                	xor    %edi,%edi
  800e82:	89 e8                	mov    %ebp,%eax
  800e84:	89 f2                	mov    %esi,%edx
  800e86:	f7 f3                	div    %ebx
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	72 06                	jb     800ea2 <__udivdi3+0x102>
  800e9c:	31 c0                	xor    %eax,%eax
  800e9e:	39 eb                	cmp    %ebp,%ebx
  800ea0:	77 d2                	ja     800e74 <__udivdi3+0xd4>
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	eb cb                	jmp    800e74 <__udivdi3+0xd4>
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	31 ff                	xor    %edi,%edi
  800eb4:	eb be                	jmp    800e74 <__udivdi3+0xd4>
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 ed                	test   %ebp,%ebp
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	89 da                	mov    %ebx,%edx
  800edd:	75 19                	jne    800ef8 <__umoddi3+0x38>
  800edf:	39 df                	cmp    %ebx,%edi
  800ee1:	0f 86 b1 00 00 00    	jbe    800f98 <__umoddi3+0xd8>
  800ee7:	f7 f7                	div    %edi
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 dd                	cmp    %ebx,%ebp
  800efa:	77 f1                	ja     800eed <__umoddi3+0x2d>
  800efc:	0f bd cd             	bsr    %ebp,%ecx
  800eff:	83 f1 1f             	xor    $0x1f,%ecx
  800f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f06:	0f 84 b4 00 00 00    	je     800fc0 <__umoddi3+0x100>
  800f0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f17:	29 c2                	sub    %eax,%edx
  800f19:	89 c1                	mov    %eax,%ecx
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	89 d1                	mov    %edx,%ecx
  800f21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f25:	d3 e8                	shr    %cl,%eax
  800f27:	09 c5                	or     %eax,%ebp
  800f29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f2d:	89 c1                	mov    %eax,%ecx
  800f2f:	d3 e7                	shl    %cl,%edi
  800f31:	89 d1                	mov    %edx,%ecx
  800f33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	d3 ef                	shr    %cl,%edi
  800f3b:	89 c1                	mov    %eax,%ecx
  800f3d:	89 f0                	mov    %esi,%eax
  800f3f:	d3 e3                	shl    %cl,%ebx
  800f41:	89 d1                	mov    %edx,%ecx
  800f43:	89 fa                	mov    %edi,%edx
  800f45:	d3 e8                	shr    %cl,%eax
  800f47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f4c:	09 d8                	or     %ebx,%eax
  800f4e:	f7 f5                	div    %ebp
  800f50:	d3 e6                	shl    %cl,%esi
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	f7 64 24 08          	mull   0x8(%esp)
  800f58:	39 d1                	cmp    %edx,%ecx
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	72 06                	jb     800f66 <__umoddi3+0xa6>
  800f60:	75 0e                	jne    800f70 <__umoddi3+0xb0>
  800f62:	39 c6                	cmp    %eax,%esi
  800f64:	73 0a                	jae    800f70 <__umoddi3+0xb0>
  800f66:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f6a:	19 ea                	sbb    %ebp,%edx
  800f6c:	89 d7                	mov    %edx,%edi
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	89 ca                	mov    %ecx,%edx
  800f72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f77:	29 de                	sub    %ebx,%esi
  800f79:	19 fa                	sbb    %edi,%edx
  800f7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f7f:	89 d0                	mov    %edx,%eax
  800f81:	d3 e0                	shl    %cl,%eax
  800f83:	89 d9                	mov    %ebx,%ecx
  800f85:	d3 ee                	shr    %cl,%esi
  800f87:	d3 ea                	shr    %cl,%edx
  800f89:	09 f0                	or     %esi,%eax
  800f8b:	83 c4 1c             	add    $0x1c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
  800f93:	90                   	nop
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	85 ff                	test   %edi,%edi
  800f9a:	89 f9                	mov    %edi,%ecx
  800f9c:	75 0b                	jne    800fa9 <__umoddi3+0xe9>
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f7                	div    %edi
  800fa7:	89 c1                	mov    %eax,%ecx
  800fa9:	89 d8                	mov    %ebx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f1                	div    %ecx
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	f7 f1                	div    %ecx
  800fb3:	e9 31 ff ff ff       	jmp    800ee9 <__umoddi3+0x29>
  800fb8:	90                   	nop
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	39 dd                	cmp    %ebx,%ebp
  800fc2:	72 08                	jb     800fcc <__umoddi3+0x10c>
  800fc4:	39 f7                	cmp    %esi,%edi
  800fc6:	0f 87 21 ff ff ff    	ja     800eed <__umoddi3+0x2d>
  800fcc:	89 da                	mov    %ebx,%edx
  800fce:	89 f0                	mov    %esi,%eax
  800fd0:	29 f8                	sub    %edi,%eax
  800fd2:	19 ea                	sbb    %ebp,%edx
  800fd4:	e9 14 ff ff ff       	jmp    800eed <__umoddi3+0x2d>
