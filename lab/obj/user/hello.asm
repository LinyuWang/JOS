
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 c0 0f 80 00       	push   $0x800fc0
  80003e:	e8 12 01 00 00       	call   800155 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ce 0f 80 00       	push   $0x800fce
  800054:	e8 fc 00 00 00       	call   800155 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800069:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800070:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800073:	e8 b6 0a 00 00       	call   800b2e <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x37>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 32 0a 00 00       	call   800aed <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	74 09                	je     8000e8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 b7 09 00 00       	call   800ab0 <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	eb db                	jmp    8000df <putch+0x1f>

00800104 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	ff 75 0c             	pushl  0xc(%ebp)
  800124:	ff 75 08             	pushl  0x8(%ebp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	68 c0 00 80 00       	push   $0x8000c0
  800133:	e8 1a 01 00 00       	call   800252 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	83 c4 08             	add    $0x8,%esp
  80013b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	50                   	push   %eax
  800148:	e8 63 09 00 00       	call   800ab0 <sys_cputs>

	return b.cnt;
}
  80014d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015e:	50                   	push   %eax
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	e8 9d ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 1c             	sub    $0x1c,%esp
  800172:	89 c7                	mov    %eax,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800182:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800185:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800190:	39 d3                	cmp    %edx,%ebx
  800192:	72 05                	jb     800199 <printnum+0x30>
  800194:	39 45 10             	cmp    %eax,0x10(%ebp)
  800197:	77 7a                	ja     800213 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 18             	pushl  0x18(%ebp)
  80019f:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	ff 75 10             	pushl  0x10(%ebp)
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b8:	e8 b3 0b 00 00       	call   800d70 <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	e8 9e ff ff ff       	call   800169 <printnum>
  8001cb:	83 c4 20             	add    $0x20,%esp
  8001ce:	eb 13                	jmp    8001e3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	ff d7                	call   *%edi
  8001d9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	85 db                	test   %ebx,%ebx
  8001e1:	7f ed                	jg     8001d0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f6:	e8 95 0c 00 00       	call   800e90 <__umoddi3>
  8001fb:	83 c4 14             	add    $0x14,%esp
  8001fe:	0f be 80 ef 0f 80 00 	movsbl 0x800fef(%eax),%eax
  800205:	50                   	push   %eax
  800206:	ff d7                	call   *%edi
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
  800213:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800216:	eb c4                	jmp    8001dc <printnum+0x73>

00800218 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800222:	8b 10                	mov    (%eax),%edx
  800224:	3b 50 04             	cmp    0x4(%eax),%edx
  800227:	73 0a                	jae    800233 <sprintputch+0x1b>
		*b->buf++ = ch;
  800229:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	88 02                	mov    %al,(%edx)
}
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    

00800235 <printfmt>:
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	e8 05 00 00 00       	call   800252 <vprintfmt>
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <vprintfmt>:
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 2c             	sub    $0x2c,%esp
  80025b:	8b 75 08             	mov    0x8(%ebp),%esi
  80025e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800261:	8b 7d 10             	mov    0x10(%ebp),%edi
  800264:	e9 63 03 00 00       	jmp    8005cc <vprintfmt+0x37a>
		padc = ' ';
  800269:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80026d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800274:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80027b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800287:	8d 47 01             	lea    0x1(%edi),%eax
  80028a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028d:	0f b6 17             	movzbl (%edi),%edx
  800290:	8d 42 dd             	lea    -0x23(%edx),%eax
  800293:	3c 55                	cmp    $0x55,%al
  800295:	0f 87 11 04 00 00    	ja     8006ac <vprintfmt+0x45a>
  80029b:	0f b6 c0             	movzbl %al,%eax
  80029e:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ac:	eb d9                	jmp    800287 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b5:	eb d0                	jmp    800287 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b7:	0f b6 d2             	movzbl %dl,%edx
  8002ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002cc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002cf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d2:	83 f9 09             	cmp    $0x9,%ecx
  8002d5:	77 55                	ja     80032c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002da:	eb e9                	jmp    8002c5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002df:	8b 00                	mov    (%eax),%eax
  8002e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e7:	8d 40 04             	lea    0x4(%eax),%eax
  8002ea:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f4:	79 91                	jns    800287 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800303:	eb 82                	jmp    800287 <vprintfmt+0x35>
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	85 c0                	test   %eax,%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	0f 49 d0             	cmovns %eax,%edx
  800312:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800318:	e9 6a ff ff ff       	jmp    800287 <vprintfmt+0x35>
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800320:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800327:	e9 5b ff ff ff       	jmp    800287 <vprintfmt+0x35>
  80032c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800332:	eb bc                	jmp    8002f0 <vprintfmt+0x9e>
			lflag++;
  800334:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033a:	e9 48 ff ff ff       	jmp    800287 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8d 78 04             	lea    0x4(%eax),%edi
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	53                   	push   %ebx
  800349:	ff 30                	pushl  (%eax)
  80034b:	ff d6                	call   *%esi
			break;
  80034d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800350:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800353:	e9 71 02 00 00       	jmp    8005c9 <vprintfmt+0x377>
			err = va_arg(ap, int);
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8d 78 04             	lea    0x4(%eax),%edi
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	99                   	cltd   
  800361:	31 d0                	xor    %edx,%eax
  800363:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800365:	83 f8 08             	cmp    $0x8,%eax
  800368:	7f 23                	jg     80038d <vprintfmt+0x13b>
  80036a:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800371:	85 d2                	test   %edx,%edx
  800373:	74 18                	je     80038d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800375:	52                   	push   %edx
  800376:	68 10 10 80 00       	push   $0x801010
  80037b:	53                   	push   %ebx
  80037c:	56                   	push   %esi
  80037d:	e8 b3 fe ff ff       	call   800235 <printfmt>
  800382:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800385:	89 7d 14             	mov    %edi,0x14(%ebp)
  800388:	e9 3c 02 00 00       	jmp    8005c9 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80038d:	50                   	push   %eax
  80038e:	68 07 10 80 00       	push   $0x801007
  800393:	53                   	push   %ebx
  800394:	56                   	push   %esi
  800395:	e8 9b fe ff ff       	call   800235 <printfmt>
  80039a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a0:	e9 24 02 00 00       	jmp    8005c9 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	83 c0 04             	add    $0x4,%eax
  8003ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003b3:	85 ff                	test   %edi,%edi
  8003b5:	b8 00 10 80 00       	mov    $0x801000,%eax
  8003ba:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c1:	0f 8e bd 00 00 00    	jle    800484 <vprintfmt+0x232>
  8003c7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003cb:	75 0e                	jne    8003db <vprintfmt+0x189>
  8003cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8003d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003d9:	eb 6d                	jmp    800448 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e1:	57                   	push   %edi
  8003e2:	e8 6d 03 00 00       	call   800754 <strnlen>
  8003e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ea:	29 c1                	sub    %eax,%ecx
  8003ec:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003ef:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fc:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fe:	eb 0f                	jmp    80040f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 75 e0             	pushl  -0x20(%ebp)
  800407:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800409:	83 ef 01             	sub    $0x1,%edi
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	85 ff                	test   %edi,%edi
  800411:	7f ed                	jg     800400 <vprintfmt+0x1ae>
  800413:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800416:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800419:	85 c9                	test   %ecx,%ecx
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420:	0f 49 c1             	cmovns %ecx,%eax
  800423:	29 c1                	sub    %eax,%ecx
  800425:	89 75 08             	mov    %esi,0x8(%ebp)
  800428:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042e:	89 cb                	mov    %ecx,%ebx
  800430:	eb 16                	jmp    800448 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800432:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800436:	75 31                	jne    800469 <vprintfmt+0x217>
					putch(ch, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	50                   	push   %eax
  80043f:	ff 55 08             	call   *0x8(%ebp)
  800442:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800445:	83 eb 01             	sub    $0x1,%ebx
  800448:	83 c7 01             	add    $0x1,%edi
  80044b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80044f:	0f be c2             	movsbl %dl,%eax
  800452:	85 c0                	test   %eax,%eax
  800454:	74 59                	je     8004af <vprintfmt+0x25d>
  800456:	85 f6                	test   %esi,%esi
  800458:	78 d8                	js     800432 <vprintfmt+0x1e0>
  80045a:	83 ee 01             	sub    $0x1,%esi
  80045d:	79 d3                	jns    800432 <vprintfmt+0x1e0>
  80045f:	89 df                	mov    %ebx,%edi
  800461:	8b 75 08             	mov    0x8(%ebp),%esi
  800464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800467:	eb 37                	jmp    8004a0 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800469:	0f be d2             	movsbl %dl,%edx
  80046c:	83 ea 20             	sub    $0x20,%edx
  80046f:	83 fa 5e             	cmp    $0x5e,%edx
  800472:	76 c4                	jbe    800438 <vprintfmt+0x1e6>
					putch('?', putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 0c             	pushl  0xc(%ebp)
  80047a:	6a 3f                	push   $0x3f
  80047c:	ff 55 08             	call   *0x8(%ebp)
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb c1                	jmp    800445 <vprintfmt+0x1f3>
  800484:	89 75 08             	mov    %esi,0x8(%ebp)
  800487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800490:	eb b6                	jmp    800448 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	53                   	push   %ebx
  800496:	6a 20                	push   $0x20
  800498:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80049a:	83 ef 01             	sub    $0x1,%edi
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	85 ff                	test   %edi,%edi
  8004a2:	7f ee                	jg     800492 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004aa:	e9 1a 01 00 00       	jmp    8005c9 <vprintfmt+0x377>
  8004af:	89 df                	mov    %ebx,%edi
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	eb e7                	jmp    8004a0 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004b9:	83 f9 01             	cmp    $0x1,%ecx
  8004bc:	7e 3f                	jle    8004fd <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8b 50 04             	mov    0x4(%eax),%edx
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 40 08             	lea    0x8(%eax),%eax
  8004d2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d9:	79 5c                	jns    800537 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 2d                	push   $0x2d
  8004e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8004e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e9:	f7 da                	neg    %edx
  8004eb:	83 d1 00             	adc    $0x0,%ecx
  8004ee:	f7 d9                	neg    %ecx
  8004f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f8:	e9 b2 00 00 00       	jmp    8005af <vprintfmt+0x35d>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	75 1b                	jne    80051c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	89 c1                	mov    %eax,%ecx
  80050b:	c1 f9 1f             	sar    $0x1f,%ecx
  80050e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb b9                	jmp    8004d5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 c1                	mov    %eax,%ecx
  800526:	c1 f9 1f             	sar    $0x1f,%ecx
  800529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
  800535:	eb 9e                	jmp    8004d5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800542:	eb 6b                	jmp    8005af <vprintfmt+0x35d>
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 15                	jle    80055e <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	8b 48 04             	mov    0x4(%eax),%ecx
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055c:	eb 51                	jmp    8005af <vprintfmt+0x35d>
	else if (lflag)
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	75 17                	jne    800579 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 10                	mov    (%eax),%edx
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
  800577:	eb 36                	jmp    8005af <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 10                	mov    (%eax),%edx
  80057e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800583:	8d 40 04             	lea    0x4(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	eb 1f                	jmp    8005af <vprintfmt+0x35d>
	if (lflag >= 2)
  800590:	83 f9 01             	cmp    $0x1,%ecx
  800593:	7e 5b                	jle    8005f0 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 50 04             	mov    0x4(%eax),%edx
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005a0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005a6:	89 d1                	mov    %edx,%ecx
  8005a8:	89 c2                	mov    %eax,%edx
			base = 8;
  8005aa:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005af:	83 ec 0c             	sub    $0xc,%esp
  8005b2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005b6:	57                   	push   %edi
  8005b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ba:	50                   	push   %eax
  8005bb:	51                   	push   %ecx
  8005bc:	52                   	push   %edx
  8005bd:	89 da                	mov    %ebx,%edx
  8005bf:	89 f0                	mov    %esi,%eax
  8005c1:	e8 a3 fb ff ff       	call   800169 <printnum>
			break;
  8005c6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005cc:	83 c7 01             	add    $0x1,%edi
  8005cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d3:	83 f8 25             	cmp    $0x25,%eax
  8005d6:	0f 84 8d fc ff ff    	je     800269 <vprintfmt+0x17>
			if (ch == '\0')
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	0f 84 e8 00 00 00    	je     8006cc <vprintfmt+0x47a>
			putch(ch, putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	50                   	push   %eax
  8005e9:	ff d6                	call   *%esi
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb dc                	jmp    8005cc <vprintfmt+0x37a>
	else if (lflag)
  8005f0:	85 c9                	test   %ecx,%ecx
  8005f2:	75 13                	jne    800607 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	89 d0                	mov    %edx,%eax
  8005fb:	99                   	cltd   
  8005fc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ff:	8d 49 04             	lea    0x4(%ecx),%ecx
  800602:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800605:	eb 9f                	jmp    8005a6 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	89 d0                	mov    %edx,%eax
  80060e:	99                   	cltd   
  80060f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800612:	8d 49 04             	lea    0x4(%ecx),%ecx
  800615:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800618:	eb 8c                	jmp    8005a6 <vprintfmt+0x354>
			putch('0', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 30                	push   $0x30
  800620:	ff d6                	call   *%esi
			putch('x', putdat);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 78                	push   $0x78
  800628:	ff d6                	call   *%esi
			num = (unsigned long long)
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800634:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800642:	e9 68 ff ff ff       	jmp    8005af <vprintfmt+0x35d>
	if (lflag >= 2)
  800647:	83 f9 01             	cmp    $0x1,%ecx
  80064a:	7e 18                	jle    800664 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	8b 48 04             	mov    0x4(%eax),%ecx
  800654:	8d 40 08             	lea    0x8(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
  80065f:	e9 4b ff ff ff       	jmp    8005af <vprintfmt+0x35d>
	else if (lflag)
  800664:	85 c9                	test   %ecx,%ecx
  800666:	75 1a                	jne    800682 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
  80067d:	e9 2d ff ff ff       	jmp    8005af <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068c:	8d 40 04             	lea    0x4(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800692:	b8 10 00 00 00       	mov    $0x10,%eax
  800697:	e9 13 ff ff ff       	jmp    8005af <vprintfmt+0x35d>
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 25                	push   $0x25
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	e9 1d ff ff ff       	jmp    8005c9 <vprintfmt+0x377>
			putch('%', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 25                	push   $0x25
  8006b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	89 f8                	mov    %edi,%eax
  8006b9:	eb 03                	jmp    8006be <vprintfmt+0x46c>
  8006bb:	83 e8 01             	sub    $0x1,%eax
  8006be:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c2:	75 f7                	jne    8006bb <vprintfmt+0x469>
  8006c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c7:	e9 fd fe ff ff       	jmp    8005c9 <vprintfmt+0x377>
}
  8006cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 26                	je     80071b <vsnprintf+0x47>
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	7e 22                	jle    80071b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f9:	ff 75 14             	pushl  0x14(%ebp)
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	68 18 02 80 00       	push   $0x800218
  800708:	e8 45 fb ff ff       	call   800252 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800710:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	83 c4 10             	add    $0x10,%esp
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    
		return -E_INVAL;
  80071b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800720:	eb f7                	jmp    800719 <vsnprintf+0x45>

00800722 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	50                   	push   %eax
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	ff 75 08             	pushl  0x8(%ebp)
  800735:	e8 9a ff ff ff       	call   8006d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 03                	jmp    80074c <strlen+0x10>
		n++;
  800749:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80074c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800750:	75 f7                	jne    800749 <strlen+0xd>
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	b8 00 00 00 00       	mov    $0x0,%eax
  800762:	eb 03                	jmp    800767 <strnlen+0x13>
		n++;
  800764:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 d0                	cmp    %edx,%eax
  800769:	74 06                	je     800771 <strnlen+0x1d>
  80076b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076f:	75 f3                	jne    800764 <strnlen+0x10>
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c1 01             	add    $0x1,%ecx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9c ff ff ff       	call   80073c <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 c9                	test   %ecx,%ecx
  8007f8:	75 0b                	jne    800805 <strlcpy+0x23>
  8007fa:	eb 17                	jmp    800813 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800805:	39 d8                	cmp    %ebx,%eax
  800807:	74 07                	je     800810 <strlcpy+0x2e>
  800809:	0f b6 0a             	movzbl (%edx),%ecx
  80080c:	84 c9                	test   %cl,%cl
  80080e:	75 ec                	jne    8007fc <strlcpy+0x1a>
		*dst = '\0';
  800810:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800813:	29 f0                	sub    %esi,%eax
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800822:	eb 06                	jmp    80082a <strcmp+0x11>
		p++, q++;
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082a:	0f b6 01             	movzbl (%ecx),%eax
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x1c>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 ef                	je     800824 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 c3                	mov    %eax,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084e:	eb 06                	jmp    800856 <strncmp+0x17>
		n--, p++, q++;
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800856:	39 d8                	cmp    %ebx,%eax
  800858:	74 16                	je     800870 <strncmp+0x31>
  80085a:	0f b6 08             	movzbl (%eax),%ecx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	74 04                	je     800865 <strncmp+0x26>
  800861:	3a 0a                	cmp    (%edx),%cl
  800863:	74 eb                	je     800850 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 00             	movzbl (%eax),%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    
		return 0;
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	eb f6                	jmp    80086d <strncmp+0x2e>

00800877 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800881:	0f b6 10             	movzbl (%eax),%edx
  800884:	84 d2                	test   %dl,%dl
  800886:	74 09                	je     800891 <strchr+0x1a>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 0a                	je     800896 <strchr+0x1f>
	for (; *s; s++)
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	eb f0                	jmp    800881 <strchr+0xa>
			return (char *) s;
	return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	eb 03                	jmp    8008a7 <strfind+0xf>
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 04                	je     8008b2 <strfind+0x1a>
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c0:	85 c9                	test   %ecx,%ecx
  8008c2:	74 13                	je     8008d7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ca:	75 05                	jne    8008d1 <memset+0x1d>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	74 0d                	je     8008de <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d4:	fc                   	cld    
  8008d5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d7:	89 f8                	mov    %edi,%eax
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    
		c &= 0xFF;
  8008de:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e2:	89 d3                	mov    %edx,%ebx
  8008e4:	c1 e3 08             	shl    $0x8,%ebx
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 18             	shl    $0x18,%eax
  8008ec:	89 d6                	mov    %edx,%esi
  8008ee:	c1 e6 10             	shl    $0x10,%esi
  8008f1:	09 f0                	or     %esi,%eax
  8008f3:	09 c2                	or     %eax,%edx
  8008f5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ff:	eb d6                	jmp    8008d7 <memset+0x23>

00800901 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090f:	39 c6                	cmp    %eax,%esi
  800911:	73 35                	jae    800948 <memmove+0x47>
  800913:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800916:	39 c2                	cmp    %eax,%edx
  800918:	76 2e                	jbe    800948 <memmove+0x47>
		s += n;
		d += n;
  80091a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	09 fe                	or     %edi,%esi
  800921:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800927:	74 0c                	je     800935 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800929:	83 ef 01             	sub    $0x1,%edi
  80092c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80092f:	fd                   	std    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800932:	fc                   	cld    
  800933:	eb 21                	jmp    800956 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 ef                	jne    800929 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb ea                	jmp    800932 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 f2                	mov    %esi,%edx
  80094a:	09 c2                	or     %eax,%edx
  80094c:	f6 c2 03             	test   $0x3,%dl
  80094f:	74 09                	je     80095a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	f6 c1 03             	test   $0x3,%cl
  80095d:	75 f2                	jne    800951 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800962:	89 c7                	mov    %eax,%edi
  800964:	fc                   	cld    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb ed                	jmp    800956 <memmove+0x55>

00800969 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 87 ff ff ff       	call   800901 <memmove>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	89 c6                	mov    %eax,%esi
  800989:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098c:	39 f0                	cmp    %esi,%eax
  80098e:	74 1c                	je     8009ac <memcmp+0x30>
		if (*s1 != *s2)
  800990:	0f b6 08             	movzbl (%eax),%ecx
  800993:	0f b6 1a             	movzbl (%edx),%ebx
  800996:	38 d9                	cmp    %bl,%cl
  800998:	75 08                	jne    8009a2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	83 c2 01             	add    $0x1,%edx
  8009a0:	eb ea                	jmp    80098c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009a2:	0f b6 c1             	movzbl %cl,%eax
  8009a5:	0f b6 db             	movzbl %bl,%ebx
  8009a8:	29 d8                	sub    %ebx,%eax
  8009aa:	eb 05                	jmp    8009b1 <memcmp+0x35>
	}

	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c3:	39 d0                	cmp    %edx,%eax
  8009c5:	73 09                	jae    8009d0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	38 08                	cmp    %cl,(%eax)
  8009c9:	74 05                	je     8009d0 <memfind+0x1b>
	for (; s < ends; s++)
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	eb f3                	jmp    8009c3 <memfind+0xe>
			break;
	return (void *) s;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	57                   	push   %edi
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009de:	eb 03                	jmp    8009e3 <strtol+0x11>
		s++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e3:	0f b6 01             	movzbl (%ecx),%eax
  8009e6:	3c 20                	cmp    $0x20,%al
  8009e8:	74 f6                	je     8009e0 <strtol+0xe>
  8009ea:	3c 09                	cmp    $0x9,%al
  8009ec:	74 f2                	je     8009e0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ee:	3c 2b                	cmp    $0x2b,%al
  8009f0:	74 2e                	je     800a20 <strtol+0x4e>
	int neg = 0;
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f7:	3c 2d                	cmp    $0x2d,%al
  8009f9:	74 2f                	je     800a2a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a01:	75 05                	jne    800a08 <strtol+0x36>
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	74 2c                	je     800a34 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a08:	85 db                	test   %ebx,%ebx
  800a0a:	75 0a                	jne    800a16 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a11:	80 39 30             	cmpb   $0x30,(%ecx)
  800a14:	74 28                	je     800a3e <strtol+0x6c>
		base = 10;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1e:	eb 50                	jmp    800a70 <strtol+0x9e>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb d1                	jmp    8009fb <strtol+0x29>
		s++, neg = 1;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a32:	eb c7                	jmp    8009fb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a38:	74 0e                	je     800a48 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	75 d8                	jne    800a16 <strtol+0x44>
		s++, base = 8;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a46:	eb ce                	jmp    800a16 <strtol+0x44>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb c4                	jmp    800a16 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a52:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a55:	89 f3                	mov    %esi,%ebx
  800a57:	80 fb 19             	cmp    $0x19,%bl
  800a5a:	77 29                	ja     800a85 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a5c:	0f be d2             	movsbl %dl,%edx
  800a5f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a62:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a65:	7d 30                	jge    800a97 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 11             	movzbl (%ecx),%edx
  800a73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	77 d5                	ja     800a52 <strtol+0x80>
			dig = *s - '0';
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 30             	sub    $0x30,%edx
  800a83:	eb dd                	jmp    800a62 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 37             	sub    $0x37,%edx
  800a95:	eb cb                	jmp    800a62 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9b:	74 05                	je     800aa2 <strtol+0xd0>
		*endptr = (char *) s;
  800a9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	f7 da                	neg    %edx
  800aa6:	85 ff                	test   %edi,%edi
  800aa8:	0f 45 c2             	cmovne %edx,%eax
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	8b 55 08             	mov    0x8(%ebp),%edx
  800abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	b8 03 00 00 00       	mov    $0x3,%eax
  800b03:	89 cb                	mov    %ecx,%ebx
  800b05:	89 cf                	mov    %ecx,%edi
  800b07:	89 ce                	mov    %ecx,%esi
  800b09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	7f 08                	jg     800b17 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	50                   	push   %eax
  800b1b:	6a 03                	push   $0x3
  800b1d:	68 44 12 80 00       	push   $0x801244
  800b22:	6a 23                	push   $0x23
  800b24:	68 61 12 80 00       	push   $0x801261
  800b29:	e8 ed 01 00 00       	call   800d1b <_panic>

00800b2e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_yield>:

void
sys_yield(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b75:	be 00 00 00 00       	mov    $0x0,%esi
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	b8 04 00 00 00       	mov    $0x4,%eax
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b88:	89 f7                	mov    %esi,%edi
  800b8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7f 08                	jg     800b98 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 04                	push   $0x4
  800b9e:	68 44 12 80 00       	push   $0x801244
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 61 12 80 00       	push   $0x801261
  800baa:	e8 6c 01 00 00       	call   800d1b <_panic>

00800baf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 05                	push   $0x5
  800be0:	68 44 12 80 00       	push   $0x801244
  800be5:	6a 23                	push   $0x23
  800be7:	68 61 12 80 00       	push   $0x801261
  800bec:	e8 2a 01 00 00       	call   800d1b <_panic>

00800bf1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0a:	89 df                	mov    %ebx,%edi
  800c0c:	89 de                	mov    %ebx,%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 06                	push   $0x6
  800c22:	68 44 12 80 00       	push   $0x801244
  800c27:	6a 23                	push   $0x23
  800c29:	68 61 12 80 00       	push   $0x801261
  800c2e:	e8 e8 00 00 00       	call   800d1b <_panic>

00800c33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 08                	push   $0x8
  800c64:	68 44 12 80 00       	push   $0x801244
  800c69:	6a 23                	push   $0x23
  800c6b:	68 61 12 80 00       	push   $0x801261
  800c70:	e8 a6 00 00 00       	call   800d1b <_panic>

00800c75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 09                	push   $0x9
  800ca6:	68 44 12 80 00       	push   $0x801244
  800cab:	6a 23                	push   $0x23
  800cad:	68 61 12 80 00       	push   $0x801261
  800cb2:	e8 64 00 00 00       	call   800d1b <_panic>

00800cb7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf0:	89 cb                	mov    %ecx,%ebx
  800cf2:	89 cf                	mov    %ecx,%edi
  800cf4:	89 ce                	mov    %ecx,%esi
  800cf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7f 08                	jg     800d04 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 0c                	push   $0xc
  800d0a:	68 44 12 80 00       	push   $0x801244
  800d0f:	6a 23                	push   $0x23
  800d11:	68 61 12 80 00       	push   $0x801261
  800d16:	e8 00 00 00 00       	call   800d1b <_panic>

00800d1b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d20:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d23:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d29:	e8 00 fe ff ff       	call   800b2e <sys_getenvid>
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	ff 75 08             	pushl  0x8(%ebp)
  800d37:	56                   	push   %esi
  800d38:	50                   	push   %eax
  800d39:	68 70 12 80 00       	push   $0x801270
  800d3e:	e8 12 f4 ff ff       	call   800155 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d43:	83 c4 18             	add    $0x18,%esp
  800d46:	53                   	push   %ebx
  800d47:	ff 75 10             	pushl  0x10(%ebp)
  800d4a:	e8 b5 f3 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  800d4f:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d56:	e8 fa f3 ff ff       	call   800155 <cprintf>
  800d5b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d5e:	cc                   	int3   
  800d5f:	eb fd                	jmp    800d5e <_panic+0x43>
  800d61:	66 90                	xchg   %ax,%ax
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
