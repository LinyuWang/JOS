
obj/user/faultreadkernel:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 a0 0f 80 00       	push   $0x800fa0
  800044:	e8 fc 00 00 00       	call   800145 <cprintf>
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
  800059:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800060:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800063:	e8 b6 0a 00 00       	call   800b1e <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a6:	e8 32 0a 00 00       	call   800add <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 13                	mov    (%ebx),%edx
  8000bc:	8d 42 01             	lea    0x1(%edx),%eax
  8000bf:	89 03                	mov    %eax,(%ebx)
  8000c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cd:	74 09                	je     8000d8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 b7 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	eb db                	jmp    8000cf <putch+0x1f>

008000f4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800104:	00 00 00 
	b.cnt = 0;
  800107:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800111:	ff 75 0c             	pushl  0xc(%ebp)
  800114:	ff 75 08             	pushl  0x8(%ebp)
  800117:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011d:	50                   	push   %eax
  80011e:	68 b0 00 80 00       	push   $0x8000b0
  800123:	e8 1a 01 00 00       	call   800242 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800128:	83 c4 08             	add    $0x8,%esp
  80012b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800131:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800137:	50                   	push   %eax
  800138:	e8 63 09 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  80013d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014e:	50                   	push   %eax
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	e8 9d ff ff ff       	call   8000f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	83 ec 1c             	sub    $0x1c,%esp
  800162:	89 c7                	mov    %eax,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800172:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800175:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800180:	39 d3                	cmp    %edx,%ebx
  800182:	72 05                	jb     800189 <printnum+0x30>
  800184:	39 45 10             	cmp    %eax,0x10(%ebp)
  800187:	77 7a                	ja     800203 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800189:	83 ec 0c             	sub    $0xc,%esp
  80018c:	ff 75 18             	pushl  0x18(%ebp)
  80018f:	8b 45 14             	mov    0x14(%ebp),%eax
  800192:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800195:	53                   	push   %ebx
  800196:	ff 75 10             	pushl  0x10(%ebp)
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019f:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a8:	e8 b3 0b 00 00       	call   800d60 <__udivdi3>
  8001ad:	83 c4 18             	add    $0x18,%esp
  8001b0:	52                   	push   %edx
  8001b1:	50                   	push   %eax
  8001b2:	89 f2                	mov    %esi,%edx
  8001b4:	89 f8                	mov    %edi,%eax
  8001b6:	e8 9e ff ff ff       	call   800159 <printnum>
  8001bb:	83 c4 20             	add    $0x20,%esp
  8001be:	eb 13                	jmp    8001d3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	56                   	push   %esi
  8001c4:	ff 75 18             	pushl  0x18(%ebp)
  8001c7:	ff d7                	call   *%edi
  8001c9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001cc:	83 eb 01             	sub    $0x1,%ebx
  8001cf:	85 db                	test   %ebx,%ebx
  8001d1:	7f ed                	jg     8001c0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	56                   	push   %esi
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e6:	e8 95 0c 00 00       	call   800e80 <__umoddi3>
  8001eb:	83 c4 14             	add    $0x14,%esp
  8001ee:	0f be 80 d1 0f 80 00 	movsbl 0x800fd1(%eax),%eax
  8001f5:	50                   	push   %eax
  8001f6:	ff d7                	call   *%edi
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    
  800203:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800206:	eb c4                	jmp    8001cc <printnum+0x73>

00800208 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800212:	8b 10                	mov    (%eax),%edx
  800214:	3b 50 04             	cmp    0x4(%eax),%edx
  800217:	73 0a                	jae    800223 <sprintputch+0x1b>
		*b->buf++ = ch;
  800219:	8d 4a 01             	lea    0x1(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	88 02                	mov    %al,(%edx)
}
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <printfmt>:
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80022b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022e:	50                   	push   %eax
  80022f:	ff 75 10             	pushl  0x10(%ebp)
  800232:	ff 75 0c             	pushl  0xc(%ebp)
  800235:	ff 75 08             	pushl  0x8(%ebp)
  800238:	e8 05 00 00 00       	call   800242 <vprintfmt>
}
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <vprintfmt>:
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	57                   	push   %edi
  800246:	56                   	push   %esi
  800247:	53                   	push   %ebx
  800248:	83 ec 2c             	sub    $0x2c,%esp
  80024b:	8b 75 08             	mov    0x8(%ebp),%esi
  80024e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800251:	8b 7d 10             	mov    0x10(%ebp),%edi
  800254:	e9 63 03 00 00       	jmp    8005bc <vprintfmt+0x37a>
		padc = ' ';
  800259:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80025d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800264:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80026b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800277:	8d 47 01             	lea    0x1(%edi),%eax
  80027a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027d:	0f b6 17             	movzbl (%edi),%edx
  800280:	8d 42 dd             	lea    -0x23(%edx),%eax
  800283:	3c 55                	cmp    $0x55,%al
  800285:	0f 87 11 04 00 00    	ja     80069c <vprintfmt+0x45a>
  80028b:	0f b6 c0             	movzbl %al,%eax
  80028e:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800298:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80029c:	eb d9                	jmp    800277 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80029e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002a5:	eb d0                	jmp    800277 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	0f b6 d2             	movzbl %dl,%edx
  8002aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002b8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002bc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002bf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002c2:	83 f9 09             	cmp    $0x9,%ecx
  8002c5:	77 55                	ja     80031c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002ca:	eb e9                	jmp    8002b5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002cf:	8b 00                	mov    (%eax),%eax
  8002d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d7:	8d 40 04             	lea    0x4(%eax),%eax
  8002da:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002e4:	79 91                	jns    800277 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f3:	eb 82                	jmp    800277 <vprintfmt+0x35>
  8002f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	0f 49 d0             	cmovns %eax,%edx
  800302:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800308:	e9 6a ff ff ff       	jmp    800277 <vprintfmt+0x35>
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800310:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800317:	e9 5b ff ff ff       	jmp    800277 <vprintfmt+0x35>
  80031c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80031f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800322:	eb bc                	jmp    8002e0 <vprintfmt+0x9e>
			lflag++;
  800324:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032a:	e9 48 ff ff ff       	jmp    800277 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 78 04             	lea    0x4(%eax),%edi
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	53                   	push   %ebx
  800339:	ff 30                	pushl  (%eax)
  80033b:	ff d6                	call   *%esi
			break;
  80033d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800340:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800343:	e9 71 02 00 00       	jmp    8005b9 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8d 78 04             	lea    0x4(%eax),%edi
  80034e:	8b 00                	mov    (%eax),%eax
  800350:	99                   	cltd   
  800351:	31 d0                	xor    %edx,%eax
  800353:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800355:	83 f8 08             	cmp    $0x8,%eax
  800358:	7f 23                	jg     80037d <vprintfmt+0x13b>
  80035a:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800361:	85 d2                	test   %edx,%edx
  800363:	74 18                	je     80037d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800365:	52                   	push   %edx
  800366:	68 f2 0f 80 00       	push   $0x800ff2
  80036b:	53                   	push   %ebx
  80036c:	56                   	push   %esi
  80036d:	e8 b3 fe ff ff       	call   800225 <printfmt>
  800372:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800375:	89 7d 14             	mov    %edi,0x14(%ebp)
  800378:	e9 3c 02 00 00       	jmp    8005b9 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80037d:	50                   	push   %eax
  80037e:	68 e9 0f 80 00       	push   $0x800fe9
  800383:	53                   	push   %ebx
  800384:	56                   	push   %esi
  800385:	e8 9b fe ff ff       	call   800225 <printfmt>
  80038a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800390:	e9 24 02 00 00       	jmp    8005b9 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	83 c0 04             	add    $0x4,%eax
  80039b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003a3:	85 ff                	test   %edi,%edi
  8003a5:	b8 e2 0f 80 00       	mov    $0x800fe2,%eax
  8003aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	0f 8e bd 00 00 00    	jle    800474 <vprintfmt+0x232>
  8003b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003bb:	75 0e                	jne    8003cb <vprintfmt+0x189>
  8003bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003c9:	eb 6d                	jmp    800438 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8003d1:	57                   	push   %edi
  8003d2:	e8 6d 03 00 00       	call   800744 <strnlen>
  8003d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003da:	29 c1                	sub    %eax,%ecx
  8003dc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003df:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003e2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ec:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ee:	eb 0f                	jmp    8003ff <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	53                   	push   %ebx
  8003f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f9:	83 ef 01             	sub    $0x1,%edi
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	85 ff                	test   %edi,%edi
  800401:	7f ed                	jg     8003f0 <vprintfmt+0x1ae>
  800403:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800406:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800409:	85 c9                	test   %ecx,%ecx
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	0f 49 c1             	cmovns %ecx,%eax
  800413:	29 c1                	sub    %eax,%ecx
  800415:	89 75 08             	mov    %esi,0x8(%ebp)
  800418:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80041b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80041e:	89 cb                	mov    %ecx,%ebx
  800420:	eb 16                	jmp    800438 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800422:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800426:	75 31                	jne    800459 <vprintfmt+0x217>
					putch(ch, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 0c             	pushl  0xc(%ebp)
  80042e:	50                   	push   %eax
  80042f:	ff 55 08             	call   *0x8(%ebp)
  800432:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800435:	83 eb 01             	sub    $0x1,%ebx
  800438:	83 c7 01             	add    $0x1,%edi
  80043b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80043f:	0f be c2             	movsbl %dl,%eax
  800442:	85 c0                	test   %eax,%eax
  800444:	74 59                	je     80049f <vprintfmt+0x25d>
  800446:	85 f6                	test   %esi,%esi
  800448:	78 d8                	js     800422 <vprintfmt+0x1e0>
  80044a:	83 ee 01             	sub    $0x1,%esi
  80044d:	79 d3                	jns    800422 <vprintfmt+0x1e0>
  80044f:	89 df                	mov    %ebx,%edi
  800451:	8b 75 08             	mov    0x8(%ebp),%esi
  800454:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800457:	eb 37                	jmp    800490 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800459:	0f be d2             	movsbl %dl,%edx
  80045c:	83 ea 20             	sub    $0x20,%edx
  80045f:	83 fa 5e             	cmp    $0x5e,%edx
  800462:	76 c4                	jbe    800428 <vprintfmt+0x1e6>
					putch('?', putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	ff 75 0c             	pushl  0xc(%ebp)
  80046a:	6a 3f                	push   $0x3f
  80046c:	ff 55 08             	call   *0x8(%ebp)
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb c1                	jmp    800435 <vprintfmt+0x1f3>
  800474:	89 75 08             	mov    %esi,0x8(%ebp)
  800477:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800480:	eb b6                	jmp    800438 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	53                   	push   %ebx
  800486:	6a 20                	push   $0x20
  800488:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048a:	83 ef 01             	sub    $0x1,%edi
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 ff                	test   %edi,%edi
  800492:	7f ee                	jg     800482 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800494:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800497:	89 45 14             	mov    %eax,0x14(%ebp)
  80049a:	e9 1a 01 00 00       	jmp    8005b9 <vprintfmt+0x377>
  80049f:	89 df                	mov    %ebx,%edi
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a7:	eb e7                	jmp    800490 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004a9:	83 f9 01             	cmp    $0x1,%ecx
  8004ac:	7e 3f                	jle    8004ed <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8b 50 04             	mov    0x4(%eax),%edx
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 40 08             	lea    0x8(%eax),%eax
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c9:	79 5c                	jns    800527 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	6a 2d                	push   $0x2d
  8004d1:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d9:	f7 da                	neg    %edx
  8004db:	83 d1 00             	adc    $0x0,%ecx
  8004de:	f7 d9                	neg    %ecx
  8004e0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004e8:	e9 b2 00 00 00       	jmp    80059f <vprintfmt+0x35d>
	else if (lflag)
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	75 1b                	jne    80050c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	89 c1                	mov    %eax,%ecx
  8004fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 04             	lea    0x4(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	eb b9                	jmp    8004c5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	89 c1                	mov    %eax,%ecx
  800516:	c1 f9 1f             	sar    $0x1f,%ecx
  800519:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 40 04             	lea    0x4(%eax),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	eb 9e                	jmp    8004c5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800527:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80052d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800532:	eb 6b                	jmp    80059f <vprintfmt+0x35d>
	if (lflag >= 2)
  800534:	83 f9 01             	cmp    $0x1,%ecx
  800537:	7e 15                	jle    80054e <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 10                	mov    (%eax),%edx
  80053e:	8b 48 04             	mov    0x4(%eax),%ecx
  800541:	8d 40 08             	lea    0x8(%eax),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054c:	eb 51                	jmp    80059f <vprintfmt+0x35d>
	else if (lflag)
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	75 17                	jne    800569 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 10                	mov    (%eax),%edx
  800557:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	eb 36                	jmp    80059f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 1f                	jmp    80059f <vprintfmt+0x35d>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 5b                	jle    8005e0 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 50 04             	mov    0x4(%eax),%edx
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800590:	8d 49 08             	lea    0x8(%ecx),%ecx
  800593:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800596:	89 d1                	mov    %edx,%ecx
  800598:	89 c2                	mov    %eax,%edx
			base = 8;
  80059a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005a6:	57                   	push   %edi
  8005a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005aa:	50                   	push   %eax
  8005ab:	51                   	push   %ecx
  8005ac:	52                   	push   %edx
  8005ad:	89 da                	mov    %ebx,%edx
  8005af:	89 f0                	mov    %esi,%eax
  8005b1:	e8 a3 fb ff ff       	call   800159 <printnum>
			break;
  8005b6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005bc:	83 c7 01             	add    $0x1,%edi
  8005bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c3:	83 f8 25             	cmp    $0x25,%eax
  8005c6:	0f 84 8d fc ff ff    	je     800259 <vprintfmt+0x17>
			if (ch == '\0')
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	0f 84 e8 00 00 00    	je     8006bc <vprintfmt+0x47a>
			putch(ch, putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	50                   	push   %eax
  8005d9:	ff d6                	call   *%esi
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	eb dc                	jmp    8005bc <vprintfmt+0x37a>
	else if (lflag)
  8005e0:	85 c9                	test   %ecx,%ecx
  8005e2:	75 13                	jne    8005f7 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	89 d0                	mov    %edx,%eax
  8005eb:	99                   	cltd   
  8005ec:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ef:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f5:	eb 9f                	jmp    800596 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	89 d0                	mov    %edx,%eax
  8005fe:	99                   	cltd   
  8005ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800602:	8d 49 04             	lea    0x4(%ecx),%ecx
  800605:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800608:	eb 8c                	jmp    800596 <vprintfmt+0x354>
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800624:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800632:	e9 68 ff ff ff       	jmp    80059f <vprintfmt+0x35d>
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7e 18                	jle    800654 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	8b 48 04             	mov    0x4(%eax),%ecx
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
  80064f:	e9 4b ff ff ff       	jmp    80059f <vprintfmt+0x35d>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	75 1a                	jne    800672 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
  80066d:	e9 2d ff ff ff       	jmp    80059f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
  800687:	e9 13 ff ff ff       	jmp    80059f <vprintfmt+0x35d>
			putch(ch, putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 25                	push   $0x25
  800692:	ff d6                	call   *%esi
			break;
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	e9 1d ff ff ff       	jmp    8005b9 <vprintfmt+0x377>
			putch('%', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 25                	push   $0x25
  8006a2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	89 f8                	mov    %edi,%eax
  8006a9:	eb 03                	jmp    8006ae <vprintfmt+0x46c>
  8006ab:	83 e8 01             	sub    $0x1,%eax
  8006ae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b2:	75 f7                	jne    8006ab <vprintfmt+0x469>
  8006b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b7:	e9 fd fe ff ff       	jmp    8005b9 <vprintfmt+0x377>
}
  8006bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bf:	5b                   	pop    %ebx
  8006c0:	5e                   	pop    %esi
  8006c1:	5f                   	pop    %edi
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 18             	sub    $0x18,%esp
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	74 26                	je     80070b <vsnprintf+0x47>
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	7e 22                	jle    80070b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e9:	ff 75 14             	pushl  0x14(%ebp)
  8006ec:	ff 75 10             	pushl  0x10(%ebp)
  8006ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	68 08 02 80 00       	push   $0x800208
  8006f8:	e8 45 fb ff ff       	call   800242 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800700:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800706:	83 c4 10             	add    $0x10,%esp
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    
		return -E_INVAL;
  80070b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800710:	eb f7                	jmp    800709 <vsnprintf+0x45>

00800712 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071b:	50                   	push   %eax
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	ff 75 08             	pushl  0x8(%ebp)
  800725:	e8 9a ff ff ff       	call   8006c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	eb 03                	jmp    80073c <strlen+0x10>
		n++;
  800739:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800740:	75 f7                	jne    800739 <strlen+0xd>
	return n;
}
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strnlen+0x13>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 06                	je     800761 <strnlen+0x1d>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f3                	jne    800754 <strnlen+0x10>
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	89 c2                	mov    %eax,%edx
  80076f:	83 c1 01             	add    $0x1,%ecx
  800772:	83 c2 01             	add    $0x1,%edx
  800775:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800779:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077c:	84 db                	test   %bl,%bl
  80077e:	75 ef                	jne    80076f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	53                   	push   %ebx
  80078b:	e8 9c ff ff ff       	call   80072c <strlen>
  800790:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	01 d8                	add    %ebx,%eax
  800798:	50                   	push   %eax
  800799:	e8 c5 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  80079e:	89 d8                	mov    %ebx,%eax
  8007a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	89 f3                	mov    %esi,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 0f                	jmp    8007c8 <strncpy+0x23>
		*dst++ = *src;
  8007b9:	83 c2 01             	add    $0x1,%edx
  8007bc:	0f b6 01             	movzbl (%ecx),%eax
  8007bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007c8:	39 da                	cmp    %ebx,%edx
  8007ca:	75 ed                	jne    8007b9 <strncpy+0x14>
	}
	return ret;
}
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e6:	85 c9                	test   %ecx,%ecx
  8007e8:	75 0b                	jne    8007f5 <strlcpy+0x23>
  8007ea:	eb 17                	jmp    800803 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	83 c0 01             	add    $0x1,%eax
  8007f2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007f5:	39 d8                	cmp    %ebx,%eax
  8007f7:	74 07                	je     800800 <strlcpy+0x2e>
  8007f9:	0f b6 0a             	movzbl (%edx),%ecx
  8007fc:	84 c9                	test   %cl,%cl
  8007fe:	75 ec                	jne    8007ec <strlcpy+0x1a>
		*dst = '\0';
  800800:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800803:	29 f0                	sub    %esi,%eax
}
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800812:	eb 06                	jmp    80081a <strcmp+0x11>
		p++, q++;
  800814:	83 c1 01             	add    $0x1,%ecx
  800817:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	84 c0                	test   %al,%al
  80081f:	74 04                	je     800825 <strcmp+0x1c>
  800821:	3a 02                	cmp    (%edx),%al
  800823:	74 ef                	je     800814 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 c0             	movzbl %al,%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 c3                	mov    %eax,%ebx
  80083b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083e:	eb 06                	jmp    800846 <strncmp+0x17>
		n--, p++, q++;
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800846:	39 d8                	cmp    %ebx,%eax
  800848:	74 16                	je     800860 <strncmp+0x31>
  80084a:	0f b6 08             	movzbl (%eax),%ecx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	74 04                	je     800855 <strncmp+0x26>
  800851:	3a 0a                	cmp    (%edx),%cl
  800853:	74 eb                	je     800840 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 00             	movzbl (%eax),%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
}
  80085d:	5b                   	pop    %ebx
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    
		return 0;
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	eb f6                	jmp    80085d <strncmp+0x2e>

00800867 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800871:	0f b6 10             	movzbl (%eax),%edx
  800874:	84 d2                	test   %dl,%dl
  800876:	74 09                	je     800881 <strchr+0x1a>
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 0a                	je     800886 <strchr+0x1f>
	for (; *s; s++)
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	eb f0                	jmp    800871 <strchr+0xa>
			return (char *) s;
	return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 03                	jmp    800897 <strfind+0xf>
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	74 04                	je     8008a2 <strfind+0x1a>
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b0:	85 c9                	test   %ecx,%ecx
  8008b2:	74 13                	je     8008c7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ba:	75 05                	jne    8008c1 <memset+0x1d>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	74 0d                	je     8008ce <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	fc                   	cld    
  8008c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    
		c &= 0xFF;
  8008ce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d2:	89 d3                	mov    %edx,%ebx
  8008d4:	c1 e3 08             	shl    $0x8,%ebx
  8008d7:	89 d0                	mov    %edx,%eax
  8008d9:	c1 e0 18             	shl    $0x18,%eax
  8008dc:	89 d6                	mov    %edx,%esi
  8008de:	c1 e6 10             	shl    $0x10,%esi
  8008e1:	09 f0                	or     %esi,%eax
  8008e3:	09 c2                	or     %eax,%edx
  8008e5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	fc                   	cld    
  8008ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ef:	eb d6                	jmp    8008c7 <memset+0x23>

008008f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ff:	39 c6                	cmp    %eax,%esi
  800901:	73 35                	jae    800938 <memmove+0x47>
  800903:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800906:	39 c2                	cmp    %eax,%edx
  800908:	76 2e                	jbe    800938 <memmove+0x47>
		s += n;
		d += n;
  80090a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	09 fe                	or     %edi,%esi
  800911:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800917:	74 0c                	je     800925 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800919:	83 ef 01             	sub    $0x1,%edi
  80091c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80091f:	fd                   	std    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800922:	fc                   	cld    
  800923:	eb 21                	jmp    800946 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 ef                	jne    800919 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092a:	83 ef 04             	sub    $0x4,%edi
  80092d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800930:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800933:	fd                   	std    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb ea                	jmp    800922 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800938:	89 f2                	mov    %esi,%edx
  80093a:	09 c2                	or     %eax,%edx
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	74 09                	je     80094a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	f6 c1 03             	test   $0x3,%cl
  80094d:	75 f2                	jne    800941 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb ed                	jmp    800946 <memmove+0x55>

00800959 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 87 ff ff ff       	call   8008f1 <memmove>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	89 c6                	mov    %eax,%esi
  800979:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	39 f0                	cmp    %esi,%eax
  80097e:	74 1c                	je     80099c <memcmp+0x30>
		if (*s1 != *s2)
  800980:	0f b6 08             	movzbl (%eax),%ecx
  800983:	0f b6 1a             	movzbl (%edx),%ebx
  800986:	38 d9                	cmp    %bl,%cl
  800988:	75 08                	jne    800992 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	83 c2 01             	add    $0x1,%edx
  800990:	eb ea                	jmp    80097c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800992:	0f b6 c1             	movzbl %cl,%eax
  800995:	0f b6 db             	movzbl %bl,%ebx
  800998:	29 d8                	sub    %ebx,%eax
  80099a:	eb 05                	jmp    8009a1 <memcmp+0x35>
	}

	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ae:	89 c2                	mov    %eax,%edx
  8009b0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b3:	39 d0                	cmp    %edx,%eax
  8009b5:	73 09                	jae    8009c0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b7:	38 08                	cmp    %cl,(%eax)
  8009b9:	74 05                	je     8009c0 <memfind+0x1b>
	for (; s < ends; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	eb f3                	jmp    8009b3 <memfind+0xe>
			break;
	return (void *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 03                	jmp    8009d3 <strtol+0x11>
		s++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f6                	je     8009d0 <strtol+0xe>
  8009da:	3c 09                	cmp    $0x9,%al
  8009dc:	74 f2                	je     8009d0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009de:	3c 2b                	cmp    $0x2b,%al
  8009e0:	74 2e                	je     800a10 <strtol+0x4e>
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009e7:	3c 2d                	cmp    $0x2d,%al
  8009e9:	74 2f                	je     800a1a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009eb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f1:	75 05                	jne    8009f8 <strtol+0x36>
  8009f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f6:	74 2c                	je     800a24 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	75 0a                	jne    800a06 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	74 28                	je     800a2e <strtol+0x6c>
		base = 10;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a0e:	eb 50                	jmp    800a60 <strtol+0x9e>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
  800a18:	eb d1                	jmp    8009eb <strtol+0x29>
		s++, neg = 1;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a22:	eb c7                	jmp    8009eb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	74 0e                	je     800a38 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	75 d8                	jne    800a06 <strtol+0x44>
		s++, base = 8;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a36:	eb ce                	jmp    800a06 <strtol+0x44>
		s += 2, base = 16;
  800a38:	83 c1 02             	add    $0x2,%ecx
  800a3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a40:	eb c4                	jmp    800a06 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a42:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 29                	ja     800a75 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a55:	7d 30                	jge    800a87 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a60:	0f b6 11             	movzbl (%ecx),%edx
  800a63:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 09             	cmp    $0x9,%bl
  800a6b:	77 d5                	ja     800a42 <strtol+0x80>
			dig = *s - '0';
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 30             	sub    $0x30,%edx
  800a73:	eb dd                	jmp    800a52 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
  800a85:	eb cb                	jmp    800a52 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8b:	74 05                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 55 08             	mov    0x8(%ebp),%edx
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	b8 03 00 00 00       	mov    $0x3,%eax
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7f 08                	jg     800b07 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 03                	push   $0x3
  800b0d:	68 24 12 80 00       	push   $0x801224
  800b12:	6a 23                	push   $0x23
  800b14:	68 41 12 80 00       	push   $0x801241
  800b19:	e8 ed 01 00 00       	call   800d0b <_panic>

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	b8 04 00 00 00       	mov    $0x4,%eax
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7f 08                	jg     800b88 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 04                	push   $0x4
  800b8e:	68 24 12 80 00       	push   $0x801224
  800b93:	6a 23                	push   $0x23
  800b95:	68 41 12 80 00       	push   $0x801241
  800b9a:	e8 6c 01 00 00       	call   800d0b <_panic>

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7f 08                	jg     800bca <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 05                	push   $0x5
  800bd0:	68 24 12 80 00       	push   $0x801224
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 41 12 80 00       	push   $0x801241
  800bdc:	e8 2a 01 00 00       	call   800d0b <_panic>

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7f 08                	jg     800c0c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 06                	push   $0x6
  800c12:	68 24 12 80 00       	push   $0x801224
  800c17:	6a 23                	push   $0x23
  800c19:	68 41 12 80 00       	push   $0x801241
  800c1e:	e8 e8 00 00 00       	call   800d0b <_panic>

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7f 08                	jg     800c4e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 08                	push   $0x8
  800c54:	68 24 12 80 00       	push   $0x801224
  800c59:	6a 23                	push   $0x23
  800c5b:	68 41 12 80 00       	push   $0x801241
  800c60:	e8 a6 00 00 00       	call   800d0b <_panic>

00800c65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7f 08                	jg     800c90 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 09                	push   $0x9
  800c96:	68 24 12 80 00       	push   $0x801224
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 41 12 80 00       	push   $0x801241
  800ca2:	e8 64 00 00 00       	call   800d0b <_panic>

00800ca7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb8:	be 00 00 00 00       	mov    $0x0,%esi
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce0:	89 cb                	mov    %ecx,%ebx
  800ce2:	89 cf                	mov    %ecx,%edi
  800ce4:	89 ce                	mov    %ecx,%esi
  800ce6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7f 08                	jg     800cf4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 0c                	push   $0xc
  800cfa:	68 24 12 80 00       	push   $0x801224
  800cff:	6a 23                	push   $0x23
  800d01:	68 41 12 80 00       	push   $0x801241
  800d06:	e8 00 00 00 00       	call   800d0b <_panic>

00800d0b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d10:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d13:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d19:	e8 00 fe ff ff       	call   800b1e <sys_getenvid>
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	ff 75 0c             	pushl  0xc(%ebp)
  800d24:	ff 75 08             	pushl  0x8(%ebp)
  800d27:	56                   	push   %esi
  800d28:	50                   	push   %eax
  800d29:	68 50 12 80 00       	push   $0x801250
  800d2e:	e8 12 f4 ff ff       	call   800145 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d33:	83 c4 18             	add    $0x18,%esp
  800d36:	53                   	push   %ebx
  800d37:	ff 75 10             	pushl  0x10(%ebp)
  800d3a:	e8 b5 f3 ff ff       	call   8000f4 <vcprintf>
	cprintf("\n");
  800d3f:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d46:	e8 fa f3 ff ff       	call   800145 <cprintf>
  800d4b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d4e:	cc                   	int3   
  800d4f:	eb fd                	jmp    800d4e <_panic+0x43>
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
