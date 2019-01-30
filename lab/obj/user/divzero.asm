
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 c0 0f 80 00       	push   $0x800fc0
  800056:	e8 fc 00 00 00       	call   800157 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006b:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800072:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800075:	e8 b6 0a 00 00       	call   800b30 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80007a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 db                	test   %ebx,%ebx
  80008e:	7e 07                	jle    800097 <libmain+0x37>
		binaryname = argv[0];
  800090:	8b 06                	mov    (%esi),%eax
  800092:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800097:	83 ec 08             	sub    $0x8,%esp
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ac:	5b                   	pop    %ebx
  8000ad:	5e                   	pop    %esi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 32 0a 00 00       	call   800aef <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cc:	8b 13                	mov    (%ebx),%edx
  8000ce:	8d 42 01             	lea    0x1(%edx),%eax
  8000d1:	89 03                	mov    %eax,(%ebx)
  8000d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	74 09                	je     8000ea <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	68 ff 00 00 00       	push   $0xff
  8000f2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	e8 b7 09 00 00       	call   800ab2 <sys_cputs>
		b->idx = 0;
  8000fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	eb db                	jmp    8000e1 <putch+0x1f>

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012f:	50                   	push   %eax
  800130:	68 c2 00 80 00       	push   $0x8000c2
  800135:	e8 1a 01 00 00       	call   800254 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013a:	83 c4 08             	add    $0x8,%esp
  80013d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800149:	50                   	push   %eax
  80014a:	e8 63 09 00 00       	call   800ab2 <sys_cputs>

	return b.cnt;
}
  80014f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800160:	50                   	push   %eax
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	e8 9d ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 1c             	sub    $0x1c,%esp
  800174:	89 c7                	mov    %eax,%edi
  800176:	89 d6                	mov    %edx,%esi
  800178:	8b 45 08             	mov    0x8(%ebp),%eax
  80017b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800181:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800184:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800192:	39 d3                	cmp    %edx,%ebx
  800194:	72 05                	jb     80019b <printnum+0x30>
  800196:	39 45 10             	cmp    %eax,0x10(%ebp)
  800199:	77 7a                	ja     800215 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 18             	pushl  0x18(%ebp)
  8001a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a7:	53                   	push   %ebx
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ba:	e8 b1 0b 00 00       	call   800d70 <__udivdi3>
  8001bf:	83 c4 18             	add    $0x18,%esp
  8001c2:	52                   	push   %edx
  8001c3:	50                   	push   %eax
  8001c4:	89 f2                	mov    %esi,%edx
  8001c6:	89 f8                	mov    %edi,%eax
  8001c8:	e8 9e ff ff ff       	call   80016b <printnum>
  8001cd:	83 c4 20             	add    $0x20,%esp
  8001d0:	eb 13                	jmp    8001e5 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d2:	83 ec 08             	sub    $0x8,%esp
  8001d5:	56                   	push   %esi
  8001d6:	ff 75 18             	pushl  0x18(%ebp)
  8001d9:	ff d7                	call   *%edi
  8001db:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001de:	83 eb 01             	sub    $0x1,%ebx
  8001e1:	85 db                	test   %ebx,%ebx
  8001e3:	7f ed                	jg     8001d2 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	83 ec 04             	sub    $0x4,%esp
  8001ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f8:	e8 93 0c 00 00       	call   800e90 <__umoddi3>
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	0f be 80 d8 0f 80 00 	movsbl 0x800fd8(%eax),%eax
  800207:	50                   	push   %eax
  800208:	ff d7                	call   *%edi
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800218:	eb c4                	jmp    8001de <printnum+0x73>

0080021a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800220:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800224:	8b 10                	mov    (%eax),%edx
  800226:	3b 50 04             	cmp    0x4(%eax),%edx
  800229:	73 0a                	jae    800235 <sprintputch+0x1b>
		*b->buf++ = ch;
  80022b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	88 02                	mov    %al,(%edx)
}
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <printfmt>:
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800240:	50                   	push   %eax
  800241:	ff 75 10             	pushl  0x10(%ebp)
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	e8 05 00 00 00       	call   800254 <vprintfmt>
}
  80024f:	83 c4 10             	add    $0x10,%esp
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <vprintfmt>:
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 2c             	sub    $0x2c,%esp
  80025d:	8b 75 08             	mov    0x8(%ebp),%esi
  800260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800263:	8b 7d 10             	mov    0x10(%ebp),%edi
  800266:	e9 63 03 00 00       	jmp    8005ce <vprintfmt+0x37a>
		padc = ' ';
  80026b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80026f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800276:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80027d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800284:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800289:	8d 47 01             	lea    0x1(%edi),%eax
  80028c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028f:	0f b6 17             	movzbl (%edi),%edx
  800292:	8d 42 dd             	lea    -0x23(%edx),%eax
  800295:	3c 55                	cmp    $0x55,%al
  800297:	0f 87 11 04 00 00    	ja     8006ae <vprintfmt+0x45a>
  80029d:	0f b6 c0             	movzbl %al,%eax
  8002a0:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ae:	eb d9                	jmp    800289 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002b3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b7:	eb d0                	jmp    800289 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b9:	0f b6 d2             	movzbl %dl,%edx
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ca:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ce:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d4:	83 f9 09             	cmp    $0x9,%ecx
  8002d7:	77 55                	ja     80032e <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002dc:	eb e9                	jmp    8002c7 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 40 04             	lea    0x4(%eax),%eax
  8002ec:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f6:	79 91                	jns    800289 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800305:	eb 82                	jmp    800289 <vprintfmt+0x35>
  800307:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030a:	85 c0                	test   %eax,%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	0f 49 d0             	cmovns %eax,%edx
  800314:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031a:	e9 6a ff ff ff       	jmp    800289 <vprintfmt+0x35>
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800322:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800329:	e9 5b ff ff ff       	jmp    800289 <vprintfmt+0x35>
  80032e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800331:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800334:	eb bc                	jmp    8002f2 <vprintfmt+0x9e>
			lflag++;
  800336:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033c:	e9 48 ff ff ff       	jmp    800289 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8d 78 04             	lea    0x4(%eax),%edi
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	53                   	push   %ebx
  80034b:	ff 30                	pushl  (%eax)
  80034d:	ff d6                	call   *%esi
			break;
  80034f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800352:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800355:	e9 71 02 00 00       	jmp    8005cb <vprintfmt+0x377>
			err = va_arg(ap, int);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 78 04             	lea    0x4(%eax),%edi
  800360:	8b 00                	mov    (%eax),%eax
  800362:	99                   	cltd   
  800363:	31 d0                	xor    %edx,%eax
  800365:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800367:	83 f8 08             	cmp    $0x8,%eax
  80036a:	7f 23                	jg     80038f <vprintfmt+0x13b>
  80036c:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800373:	85 d2                	test   %edx,%edx
  800375:	74 18                	je     80038f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800377:	52                   	push   %edx
  800378:	68 f9 0f 80 00       	push   $0x800ff9
  80037d:	53                   	push   %ebx
  80037e:	56                   	push   %esi
  80037f:	e8 b3 fe ff ff       	call   800237 <printfmt>
  800384:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800387:	89 7d 14             	mov    %edi,0x14(%ebp)
  80038a:	e9 3c 02 00 00       	jmp    8005cb <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80038f:	50                   	push   %eax
  800390:	68 f0 0f 80 00       	push   $0x800ff0
  800395:	53                   	push   %ebx
  800396:	56                   	push   %esi
  800397:	e8 9b fe ff ff       	call   800237 <printfmt>
  80039c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a2:	e9 24 02 00 00       	jmp    8005cb <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	83 c0 04             	add    $0x4,%eax
  8003ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003b5:	85 ff                	test   %edi,%edi
  8003b7:	b8 e9 0f 80 00       	mov    $0x800fe9,%eax
  8003bc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	0f 8e bd 00 00 00    	jle    800486 <vprintfmt+0x232>
  8003c9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003cd:	75 0e                	jne    8003dd <vprintfmt+0x189>
  8003cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8003d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003db:	eb 6d                	jmp    80044a <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e3:	57                   	push   %edi
  8003e4:	e8 6d 03 00 00       	call   800756 <strnlen>
  8003e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ec:	29 c1                	sub    %eax,%ecx
  8003ee:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fe:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800400:	eb 0f                	jmp    800411 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	53                   	push   %ebx
  800406:	ff 75 e0             	pushl  -0x20(%ebp)
  800409:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040b:	83 ef 01             	sub    $0x1,%edi
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	85 ff                	test   %edi,%edi
  800413:	7f ed                	jg     800402 <vprintfmt+0x1ae>
  800415:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800418:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80041b:	85 c9                	test   %ecx,%ecx
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	0f 49 c1             	cmovns %ecx,%eax
  800425:	29 c1                	sub    %eax,%ecx
  800427:	89 75 08             	mov    %esi,0x8(%ebp)
  80042a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800430:	89 cb                	mov    %ecx,%ebx
  800432:	eb 16                	jmp    80044a <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800434:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800438:	75 31                	jne    80046b <vprintfmt+0x217>
					putch(ch, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 0c             	pushl  0xc(%ebp)
  800440:	50                   	push   %eax
  800441:	ff 55 08             	call   *0x8(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800447:	83 eb 01             	sub    $0x1,%ebx
  80044a:	83 c7 01             	add    $0x1,%edi
  80044d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800451:	0f be c2             	movsbl %dl,%eax
  800454:	85 c0                	test   %eax,%eax
  800456:	74 59                	je     8004b1 <vprintfmt+0x25d>
  800458:	85 f6                	test   %esi,%esi
  80045a:	78 d8                	js     800434 <vprintfmt+0x1e0>
  80045c:	83 ee 01             	sub    $0x1,%esi
  80045f:	79 d3                	jns    800434 <vprintfmt+0x1e0>
  800461:	89 df                	mov    %ebx,%edi
  800463:	8b 75 08             	mov    0x8(%ebp),%esi
  800466:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800469:	eb 37                	jmp    8004a2 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80046b:	0f be d2             	movsbl %dl,%edx
  80046e:	83 ea 20             	sub    $0x20,%edx
  800471:	83 fa 5e             	cmp    $0x5e,%edx
  800474:	76 c4                	jbe    80043a <vprintfmt+0x1e6>
					putch('?', putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 0c             	pushl  0xc(%ebp)
  80047c:	6a 3f                	push   $0x3f
  80047e:	ff 55 08             	call   *0x8(%ebp)
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb c1                	jmp    800447 <vprintfmt+0x1f3>
  800486:	89 75 08             	mov    %esi,0x8(%ebp)
  800489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800492:	eb b6                	jmp    80044a <vprintfmt+0x1f6>
				putch(' ', putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	53                   	push   %ebx
  800498:	6a 20                	push   $0x20
  80049a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80049c:	83 ef 01             	sub    $0x1,%edi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	7f ee                	jg     800494 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ac:	e9 1a 01 00 00       	jmp    8005cb <vprintfmt+0x377>
  8004b1:	89 df                	mov    %ebx,%edi
  8004b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b9:	eb e7                	jmp    8004a2 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004bb:	83 f9 01             	cmp    $0x1,%ecx
  8004be:	7e 3f                	jle    8004ff <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8b 50 04             	mov    0x4(%eax),%edx
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 40 08             	lea    0x8(%eax),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004db:	79 5c                	jns    800539 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 2d                	push   $0x2d
  8004e3:	ff d6                	call   *%esi
				num = -(long long) num;
  8004e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004eb:	f7 da                	neg    %edx
  8004ed:	83 d1 00             	adc    $0x0,%ecx
  8004f0:	f7 d9                	neg    %ecx
  8004f2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004fa:	e9 b2 00 00 00       	jmp    8005b1 <vprintfmt+0x35d>
	else if (lflag)
  8004ff:	85 c9                	test   %ecx,%ecx
  800501:	75 1b                	jne    80051e <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	89 c1                	mov    %eax,%ecx
  80050d:	c1 f9 1f             	sar    $0x1f,%ecx
  800510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 04             	lea    0x4(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	eb b9                	jmp    8004d7 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 c1                	mov    %eax,%ecx
  800528:	c1 f9 1f             	sar    $0x1f,%ecx
  80052b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
  800537:	eb 9e                	jmp    8004d7 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800539:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800544:	eb 6b                	jmp    8005b1 <vprintfmt+0x35d>
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7e 15                	jle    800560 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8b 10                	mov    (%eax),%edx
  800550:	8b 48 04             	mov    0x4(%eax),%ecx
  800553:	8d 40 08             	lea    0x8(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800559:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055e:	eb 51                	jmp    8005b1 <vprintfmt+0x35d>
	else if (lflag)
  800560:	85 c9                	test   %ecx,%ecx
  800562:	75 17                	jne    80057b <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 10                	mov    (%eax),%edx
  800569:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056e:	8d 40 04             	lea    0x4(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800574:	b8 0a 00 00 00       	mov    $0xa,%eax
  800579:	eb 36                	jmp    8005b1 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	b9 00 00 00 00       	mov    $0x0,%ecx
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800590:	eb 1f                	jmp    8005b1 <vprintfmt+0x35d>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7e 5b                	jle    8005f2 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 50 04             	mov    0x4(%eax),%edx
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005a2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005a5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005a8:	89 d1                	mov    %edx,%ecx
  8005aa:	89 c2                	mov    %eax,%edx
			base = 8;
  8005ac:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005b8:	57                   	push   %edi
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	50                   	push   %eax
  8005bd:	51                   	push   %ecx
  8005be:	52                   	push   %edx
  8005bf:	89 da                	mov    %ebx,%edx
  8005c1:	89 f0                	mov    %esi,%eax
  8005c3:	e8 a3 fb ff ff       	call   80016b <printnum>
			break;
  8005c8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ce:	83 c7 01             	add    $0x1,%edi
  8005d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d5:	83 f8 25             	cmp    $0x25,%eax
  8005d8:	0f 84 8d fc ff ff    	je     80026b <vprintfmt+0x17>
			if (ch == '\0')
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	0f 84 e8 00 00 00    	je     8006ce <vprintfmt+0x47a>
			putch(ch, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	50                   	push   %eax
  8005eb:	ff d6                	call   *%esi
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	eb dc                	jmp    8005ce <vprintfmt+0x37a>
	else if (lflag)
  8005f2:	85 c9                	test   %ecx,%ecx
  8005f4:	75 13                	jne    800609 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	89 d0                	mov    %edx,%eax
  8005fd:	99                   	cltd   
  8005fe:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800601:	8d 49 04             	lea    0x4(%ecx),%ecx
  800604:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800607:	eb 9f                	jmp    8005a8 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	89 d0                	mov    %edx,%eax
  800610:	99                   	cltd   
  800611:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800614:	8d 49 04             	lea    0x4(%ecx),%ecx
  800617:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061a:	eb 8c                	jmp    8005a8 <vprintfmt+0x354>
			putch('0', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 30                	push   $0x30
  800622:	ff d6                	call   *%esi
			putch('x', putdat);
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 78                	push   $0x78
  80062a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800636:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800644:	e9 68 ff ff ff       	jmp    8005b1 <vprintfmt+0x35d>
	if (lflag >= 2)
  800649:	83 f9 01             	cmp    $0x1,%ecx
  80064c:	7e 18                	jle    800666 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	8b 48 04             	mov    0x4(%eax),%ecx
  800656:	8d 40 08             	lea    0x8(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065c:	b8 10 00 00 00       	mov    $0x10,%eax
  800661:	e9 4b ff ff ff       	jmp    8005b1 <vprintfmt+0x35d>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 1a                	jne    800684 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
  80067f:	e9 2d ff ff ff       	jmp    8005b1 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
  800699:	e9 13 ff ff ff       	jmp    8005b1 <vprintfmt+0x35d>
			putch(ch, putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 25                	push   $0x25
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	e9 1d ff ff ff       	jmp    8005cb <vprintfmt+0x377>
			putch('%', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 25                	push   $0x25
  8006b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	89 f8                	mov    %edi,%eax
  8006bb:	eb 03                	jmp    8006c0 <vprintfmt+0x46c>
  8006bd:	83 e8 01             	sub    $0x1,%eax
  8006c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c4:	75 f7                	jne    8006bd <vprintfmt+0x469>
  8006c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c9:	e9 fd fe ff ff       	jmp    8005cb <vprintfmt+0x377>
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 22                	jle    80071d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 1a 02 80 00       	push   $0x80021a
  80070a:	e8 45 fb ff ff       	call   800254 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
}
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800722:	eb f7                	jmp    80071b <vsnprintf+0x45>

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 9a ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strlen+0x10>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f7                	jne    80074b <strlen+0xd>
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	eb 03                	jmp    800769 <strnlen+0x13>
		n++;
  800766:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	39 d0                	cmp    %edx,%eax
  80076b:	74 06                	je     800773 <strnlen+0x1d>
  80076d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800771:	75 f3                	jne    800766 <strnlen+0x10>
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c1 01             	add    $0x1,%ecx
  800784:	83 c2 01             	add    $0x1,%edx
  800787:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078e:	84 db                	test   %bl,%bl
  800790:	75 ef                	jne    800781 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 9c ff ff ff       	call   80073e <strlen>
  8007a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 c5 ff ff ff       	call   800775 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 f3                	mov    %esi,%ebx
  8007c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 0f                	jmp    8007da <strncpy+0x23>
		*dst++ = *src;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007da:	39 da                	cmp    %ebx,%edx
  8007dc:	75 ed                	jne    8007cb <strncpy+0x14>
	}
	return ret;
}
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	75 0b                	jne    800807 <strlcpy+0x23>
  8007fc:	eb 17                	jmp    800815 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c0 01             	add    $0x1,%eax
  800804:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800807:	39 d8                	cmp    %ebx,%eax
  800809:	74 07                	je     800812 <strlcpy+0x2e>
  80080b:	0f b6 0a             	movzbl (%edx),%ecx
  80080e:	84 c9                	test   %cl,%cl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1a>
		*dst = '\0';
  800812:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800815:	29 f0                	sub    %esi,%eax
}
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800824:	eb 06                	jmp    80082c <strcmp+0x11>
		p++, q++;
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082c:	0f b6 01             	movzbl (%ecx),%eax
  80082f:	84 c0                	test   %al,%al
  800831:	74 04                	je     800837 <strcmp+0x1c>
  800833:	3a 02                	cmp    (%edx),%al
  800835:	74 ef                	je     800826 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800837:	0f b6 c0             	movzbl %al,%eax
  80083a:	0f b6 12             	movzbl (%edx),%edx
  80083d:	29 d0                	sub    %edx,%eax
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	89 c3                	mov    %eax,%ebx
  80084d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800850:	eb 06                	jmp    800858 <strncmp+0x17>
		n--, p++, q++;
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800858:	39 d8                	cmp    %ebx,%eax
  80085a:	74 16                	je     800872 <strncmp+0x31>
  80085c:	0f b6 08             	movzbl (%eax),%ecx
  80085f:	84 c9                	test   %cl,%cl
  800861:	74 04                	je     800867 <strncmp+0x26>
  800863:	3a 0a                	cmp    (%edx),%cl
  800865:	74 eb                	je     800852 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 00             	movzbl (%eax),%eax
  80086a:	0f b6 12             	movzbl (%edx),%edx
  80086d:	29 d0                	sub    %edx,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    
		return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
  800877:	eb f6                	jmp    80086f <strncmp+0x2e>

00800879 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800883:	0f b6 10             	movzbl (%eax),%edx
  800886:	84 d2                	test   %dl,%dl
  800888:	74 09                	je     800893 <strchr+0x1a>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0a                	je     800898 <strchr+0x1f>
	for (; *s; s++)
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	eb f0                	jmp    800883 <strchr+0xa>
			return (char *) s;
	return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a4:	eb 03                	jmp    8008a9 <strfind+0xf>
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 04                	je     8008b4 <strfind+0x1a>
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	57                   	push   %edi
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c2:	85 c9                	test   %ecx,%ecx
  8008c4:	74 13                	je     8008d9 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cc:	75 05                	jne    8008d3 <memset+0x1d>
  8008ce:	f6 c1 03             	test   $0x3,%cl
  8008d1:	74 0d                	je     8008e0 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d6:	fc                   	cld    
  8008d7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d9:	89 f8                	mov    %edi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    
		c &= 0xFF;
  8008e0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e4:	89 d3                	mov    %edx,%ebx
  8008e6:	c1 e3 08             	shl    $0x8,%ebx
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 18             	shl    $0x18,%eax
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	c1 e6 10             	shl    $0x10,%esi
  8008f3:	09 f0                	or     %esi,%eax
  8008f5:	09 c2                	or     %eax,%edx
  8008f7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	fc                   	cld    
  8008ff:	f3 ab                	rep stos %eax,%es:(%edi)
  800901:	eb d6                	jmp    8008d9 <memset+0x23>

00800903 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800911:	39 c6                	cmp    %eax,%esi
  800913:	73 35                	jae    80094a <memmove+0x47>
  800915:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800918:	39 c2                	cmp    %eax,%edx
  80091a:	76 2e                	jbe    80094a <memmove+0x47>
		s += n;
		d += n;
  80091c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091f:	89 d6                	mov    %edx,%esi
  800921:	09 fe                	or     %edi,%esi
  800923:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800929:	74 0c                	je     800937 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800931:	fd                   	std    
  800932:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800934:	fc                   	cld    
  800935:	eb 21                	jmp    800958 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 ef                	jne    80092b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb ea                	jmp    800934 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	89 f2                	mov    %esi,%edx
  80094c:	09 c2                	or     %eax,%edx
  80094e:	f6 c2 03             	test   $0x3,%dl
  800951:	74 09                	je     80095c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800953:	89 c7                	mov    %eax,%edi
  800955:	fc                   	cld    
  800956:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 f2                	jne    800953 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800961:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb ed                	jmp    800958 <memmove+0x55>

0080096b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096e:	ff 75 10             	pushl  0x10(%ebp)
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	ff 75 08             	pushl  0x8(%ebp)
  800977:	e8 87 ff ff ff       	call   800903 <memmove>
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c6                	mov    %eax,%esi
  80098b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098e:	39 f0                	cmp    %esi,%eax
  800990:	74 1c                	je     8009ae <memcmp+0x30>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	75 08                	jne    8009a4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	83 c2 01             	add    $0x1,%edx
  8009a2:	eb ea                	jmp    80098e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009a4:	0f b6 c1             	movzbl %cl,%eax
  8009a7:	0f b6 db             	movzbl %bl,%ebx
  8009aa:	29 d8                	sub    %ebx,%eax
  8009ac:	eb 05                	jmp    8009b3 <memcmp+0x35>
	}

	return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c0:	89 c2                	mov    %eax,%edx
  8009c2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c5:	39 d0                	cmp    %edx,%eax
  8009c7:	73 09                	jae    8009d2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	38 08                	cmp    %cl,(%eax)
  8009cb:	74 05                	je     8009d2 <memfind+0x1b>
	for (; s < ends; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	eb f3                	jmp    8009c5 <memfind+0xe>
			break;
	return (void *) s;
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e0:	eb 03                	jmp    8009e5 <strtol+0x11>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f6                	je     8009e2 <strtol+0xe>
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f2                	je     8009e2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009f0:	3c 2b                	cmp    $0x2b,%al
  8009f2:	74 2e                	je     800a22 <strtol+0x4e>
	int neg = 0;
  8009f4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f9:	3c 2d                	cmp    $0x2d,%al
  8009fb:	74 2f                	je     800a2c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 05                	jne    800a0a <strtol+0x36>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	74 2c                	je     800a36 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0a:	85 db                	test   %ebx,%ebx
  800a0c:	75 0a                	jne    800a18 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a13:	80 39 30             	cmpb   $0x30,(%ecx)
  800a16:	74 28                	je     800a40 <strtol+0x6c>
		base = 10;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a20:	eb 50                	jmp    800a72 <strtol+0x9e>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2a:	eb d1                	jmp    8009fd <strtol+0x29>
		s++, neg = 1;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a34:	eb c7                	jmp    8009fd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	74 0e                	je     800a4a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	75 d8                	jne    800a18 <strtol+0x44>
		s++, base = 8;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a48:	eb ce                	jmp    800a18 <strtol+0x44>
		s += 2, base = 16;
  800a4a:	83 c1 02             	add    $0x2,%ecx
  800a4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a52:	eb c4                	jmp    800a18 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a54:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 29                	ja     800a87 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a64:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a67:	7d 30                	jge    800a99 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a70:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a72:	0f b6 11             	movzbl (%ecx),%edx
  800a75:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 09             	cmp    $0x9,%bl
  800a7d:	77 d5                	ja     800a54 <strtol+0x80>
			dig = *s - '0';
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 30             	sub    $0x30,%edx
  800a85:	eb dd                	jmp    800a64 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a87:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 19             	cmp    $0x19,%bl
  800a8f:	77 08                	ja     800a99 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 37             	sub    $0x37,%edx
  800a97:	eb cb                	jmp    800a64 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 05                	je     800aa4 <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa4:	89 c2                	mov    %eax,%edx
  800aa6:	f7 da                	neg    %edx
  800aa8:	85 ff                	test   %edi,%edi
  800aaa:	0f 45 c2             	cmovne %edx,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	89 c7                	mov    %eax,%edi
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	89 d1                	mov    %edx,%ecx
  800ae2:	89 d3                	mov    %edx,%ebx
  800ae4:	89 d7                	mov    %edx,%edi
  800ae6:	89 d6                	mov    %edx,%esi
  800ae8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	b8 03 00 00 00       	mov    $0x3,%eax
  800b05:	89 cb                	mov    %ecx,%ebx
  800b07:	89 cf                	mov    %ecx,%edi
  800b09:	89 ce                	mov    %ecx,%esi
  800b0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	7f 08                	jg     800b19 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 24 12 80 00       	push   $0x801224
  800b24:	6a 23                	push   $0x23
  800b26:	68 41 12 80 00       	push   $0x801241
  800b2b:	e8 ed 01 00 00       	call   800d1d <_panic>

00800b30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_yield>:

void
sys_yield(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b77:	be 00 00 00 00       	mov    $0x0,%esi
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b82:	b8 04 00 00 00       	mov    $0x4,%eax
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	89 f7                	mov    %esi,%edi
  800b8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 24 12 80 00       	push   $0x801224
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 41 12 80 00       	push   $0x801241
  800bac:	e8 6c 01 00 00       	call   800d1d <_panic>

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7f 08                	jg     800bdc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 24 12 80 00       	push   $0x801224
  800be7:	6a 23                	push   $0x23
  800be9:	68 41 12 80 00       	push   $0x801241
  800bee:	e8 2a 01 00 00       	call   800d1d <_panic>

00800bf3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7f 08                	jg     800c1e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 24 12 80 00       	push   $0x801224
  800c29:	6a 23                	push   $0x23
  800c2b:	68 41 12 80 00       	push   $0x801241
  800c30:	e8 e8 00 00 00       	call   800d1d <_panic>

00800c35 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7f 08                	jg     800c60 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 24 12 80 00       	push   $0x801224
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 41 12 80 00       	push   $0x801241
  800c72:	e8 a6 00 00 00       	call   800d1d <_panic>

00800c77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7f 08                	jg     800ca2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 24 12 80 00       	push   $0x801224
  800cad:	6a 23                	push   $0x23
  800caf:	68 41 12 80 00       	push   $0x801241
  800cb4:	e8 64 00 00 00       	call   800d1d <_panic>

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf2:	89 cb                	mov    %ecx,%ebx
  800cf4:	89 cf                	mov    %ecx,%edi
  800cf6:	89 ce                	mov    %ecx,%esi
  800cf8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7f 08                	jg     800d06 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 0c                	push   $0xc
  800d0c:	68 24 12 80 00       	push   $0x801224
  800d11:	6a 23                	push   $0x23
  800d13:	68 41 12 80 00       	push   $0x801241
  800d18:	e8 00 00 00 00       	call   800d1d <_panic>

00800d1d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d22:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d25:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d2b:	e8 00 fe ff ff       	call   800b30 <sys_getenvid>
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	ff 75 0c             	pushl  0xc(%ebp)
  800d36:	ff 75 08             	pushl  0x8(%ebp)
  800d39:	56                   	push   %esi
  800d3a:	50                   	push   %eax
  800d3b:	68 50 12 80 00       	push   $0x801250
  800d40:	e8 12 f4 ff ff       	call   800157 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d45:	83 c4 18             	add    $0x18,%esp
  800d48:	53                   	push   %ebx
  800d49:	ff 75 10             	pushl  0x10(%ebp)
  800d4c:	e8 b5 f3 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  800d51:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d58:	e8 fa f3 ff ff       	call   800157 <cprintf>
  800d5d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d60:	cc                   	int3   
  800d61:	eb fd                	jmp    800d60 <_panic+0x43>
  800d63:	66 90                	xchg   %ax,%ax
  800d65:	66 90                	xchg   %ax,%ax
  800d67:	66 90                	xchg   %ax,%ax
  800d69:	66 90                	xchg   %ax,%ax
  800d6b:	66 90                	xchg   %ax,%ax
  800d6d:	66 90                	xchg   %ax,%ax
  800d6f:	90                   	nop

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d87:	85 d2                	test   %edx,%edx
  800d89:	75 35                	jne    800dc0 <__udivdi3+0x50>
  800d8b:	39 f3                	cmp    %esi,%ebx
  800d8d:	0f 87 bd 00 00 00    	ja     800e50 <__udivdi3+0xe0>
  800d93:	85 db                	test   %ebx,%ebx
  800d95:	89 d9                	mov    %ebx,%ecx
  800d97:	75 0b                	jne    800da4 <__udivdi3+0x34>
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f3                	div    %ebx
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	31 d2                	xor    %edx,%edx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	f7 f1                	div    %ecx
  800daa:	89 c6                	mov    %eax,%esi
  800dac:	89 e8                	mov    %ebp,%eax
  800dae:	89 f7                	mov    %esi,%edi
  800db0:	f7 f1                	div    %ecx
  800db2:	89 fa                	mov    %edi,%edx
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 f2                	cmp    %esi,%edx
  800dc2:	77 7c                	ja     800e40 <__udivdi3+0xd0>
  800dc4:	0f bd fa             	bsr    %edx,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0xf8>
  800dd0:	89 f9                	mov    %edi,%ecx
  800dd2:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd7:	29 f8                	sub    %edi,%eax
  800dd9:	d3 e2                	shl    %cl,%edx
  800ddb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	89 da                	mov    %ebx,%edx
  800de3:	d3 ea                	shr    %cl,%edx
  800de5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800de9:	09 d1                	or     %edx,%ecx
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e3                	shl    %cl,%ebx
  800df5:	89 c1                	mov    %eax,%ecx
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	89 f9                	mov    %edi,%ecx
  800dfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dff:	d3 e6                	shl    %cl,%esi
  800e01:	89 eb                	mov    %ebp,%ebx
  800e03:	89 c1                	mov    %eax,%ecx
  800e05:	d3 eb                	shr    %cl,%ebx
  800e07:	09 de                	or     %ebx,%esi
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	f7 74 24 08          	divl   0x8(%esp)
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	f7 64 24 0c          	mull   0xc(%esp)
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	72 0c                	jb     800e27 <__udivdi3+0xb7>
  800e1b:	89 f9                	mov    %edi,%ecx
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	39 c5                	cmp    %eax,%ebp
  800e21:	73 5d                	jae    800e80 <__udivdi3+0x110>
  800e23:	39 d6                	cmp    %edx,%esi
  800e25:	75 59                	jne    800e80 <__udivdi3+0x110>
  800e27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2a:	31 ff                	xor    %edi,%edi
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	83 c4 1c             	add    $0x1c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	8d 76 00             	lea    0x0(%esi),%esi
  800e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	31 c0                	xor    %eax,%eax
  800e44:	89 fa                	mov    %edi,%edx
  800e46:	83 c4 1c             	add    $0x1c,%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    
  800e4e:	66 90                	xchg   %ax,%ax
  800e50:	31 ff                	xor    %edi,%edi
  800e52:	89 e8                	mov    %ebp,%eax
  800e54:	89 f2                	mov    %esi,%edx
  800e56:	f7 f3                	div    %ebx
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x102>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 d2                	ja     800e44 <__udivdi3+0xd4>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb cb                	jmp    800e44 <__udivdi3+0xd4>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	31 ff                	xor    %edi,%edi
  800e84:	eb be                	jmp    800e44 <__udivdi3+0xd4>
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 ed                	test   %ebp,%ebp
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	89 da                	mov    %ebx,%edx
  800ead:	75 19                	jne    800ec8 <__umoddi3+0x38>
  800eaf:	39 df                	cmp    %ebx,%edi
  800eb1:	0f 86 b1 00 00 00    	jbe    800f68 <__umoddi3+0xd8>
  800eb7:	f7 f7                	div    %edi
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 dd                	cmp    %ebx,%ebp
  800eca:	77 f1                	ja     800ebd <__umoddi3+0x2d>
  800ecc:	0f bd cd             	bsr    %ebp,%ecx
  800ecf:	83 f1 1f             	xor    $0x1f,%ecx
  800ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ed6:	0f 84 b4 00 00 00    	je     800f90 <__umoddi3+0x100>
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	29 c2                	sub    %eax,%edx
  800ee9:	89 c1                	mov    %eax,%ecx
  800eeb:	89 f8                	mov    %edi,%eax
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	89 d1                	mov    %edx,%ecx
  800ef1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	09 c5                	or     %eax,%ebp
  800ef9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800efd:	89 c1                	mov    %eax,%ecx
  800eff:	d3 e7                	shl    %cl,%edi
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	d3 ef                	shr    %cl,%edi
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	89 f0                	mov    %esi,%eax
  800f0f:	d3 e3                	shl    %cl,%ebx
  800f11:	89 d1                	mov    %edx,%ecx
  800f13:	89 fa                	mov    %edi,%edx
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f1c:	09 d8                	or     %ebx,%eax
  800f1e:	f7 f5                	div    %ebp
  800f20:	d3 e6                	shl    %cl,%esi
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	f7 64 24 08          	mull   0x8(%esp)
  800f28:	39 d1                	cmp    %edx,%ecx
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	72 06                	jb     800f36 <__umoddi3+0xa6>
  800f30:	75 0e                	jne    800f40 <__umoddi3+0xb0>
  800f32:	39 c6                	cmp    %eax,%esi
  800f34:	73 0a                	jae    800f40 <__umoddi3+0xb0>
  800f36:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f3a:	19 ea                	sbb    %ebp,%edx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 c3                	mov    %eax,%ebx
  800f40:	89 ca                	mov    %ecx,%edx
  800f42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f47:	29 de                	sub    %ebx,%esi
  800f49:	19 fa                	sbb    %edi,%edx
  800f4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f4f:	89 d0                	mov    %edx,%eax
  800f51:	d3 e0                	shl    %cl,%eax
  800f53:	89 d9                	mov    %ebx,%ecx
  800f55:	d3 ee                	shr    %cl,%esi
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	09 f0                	or     %esi,%eax
  800f5b:	83 c4 1c             	add    $0x1c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	85 ff                	test   %edi,%edi
  800f6a:	89 f9                	mov    %edi,%ecx
  800f6c:	75 0b                	jne    800f79 <__umoddi3+0xe9>
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f7                	div    %edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f1                	div    %ecx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	f7 f1                	div    %ecx
  800f83:	e9 31 ff ff ff       	jmp    800eb9 <__umoddi3+0x29>
  800f88:	90                   	nop
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	39 dd                	cmp    %ebx,%ebp
  800f92:	72 08                	jb     800f9c <__umoddi3+0x10c>
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	0f 87 21 ff ff ff    	ja     800ebd <__umoddi3+0x2d>
  800f9c:	89 da                	mov    %ebx,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	29 f8                	sub    %edi,%eax
  800fa2:	19 ea                	sbb    %ebp,%edx
  800fa4:	e9 14 ff ff ff       	jmp    800ebd <__umoddi3+0x2d>
