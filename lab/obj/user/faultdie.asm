
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 60 10 80 00       	push   $0x801060
  80004a:	e8 28 01 00 00       	call   800177 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 fc 0a 00 00       	call   800b50 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 b3 0a 00 00       	call   800b0f <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 cc 0c 00 00       	call   800d3d <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800092:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800095:	e8 b6 0a 00 00       	call   800b50 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80009a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 db                	test   %ebx,%ebx
  8000ae:	7e 07                	jle    8000b7 <libmain+0x37>
		binaryname = argv[0];
  8000b0:	8b 06                	mov    (%esi),%eax
  8000b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
  8000bc:	e8 a0 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0a 00 00 00       	call   8000d0 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 32 0a 00 00       	call   800b0f <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 04             	sub    $0x4,%esp
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ec:	8b 13                	mov    (%ebx),%edx
  8000ee:	8d 42 01             	lea    0x1(%edx),%eax
  8000f1:	89 03                	mov    %eax,(%ebx)
  8000f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	74 09                	je     80010a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800101:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800108:	c9                   	leave  
  800109:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80010a:	83 ec 08             	sub    $0x8,%esp
  80010d:	68 ff 00 00 00       	push   $0xff
  800112:	8d 43 08             	lea    0x8(%ebx),%eax
  800115:	50                   	push   %eax
  800116:	e8 b7 09 00 00       	call   800ad2 <sys_cputs>
		b->idx = 0;
  80011b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	eb db                	jmp    800101 <putch+0x1f>

00800126 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	68 e2 00 80 00       	push   $0x8000e2
  800155:	e8 1a 01 00 00       	call   800274 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800163:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	e8 63 09 00 00       	call   800ad2 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	50                   	push   %eax
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	e8 9d ff ff ff       	call   800126 <vcprintf>
	va_end(ap);

	return cnt;
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 1c             	sub    $0x1c,%esp
  800194:	89 c7                	mov    %eax,%edi
  800196:	89 d6                	mov    %edx,%esi
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b2:	39 d3                	cmp    %edx,%ebx
  8001b4:	72 05                	jb     8001bb <printnum+0x30>
  8001b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b9:	77 7a                	ja     800235 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c7:	53                   	push   %ebx
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	83 ec 08             	sub    $0x8,%esp
  8001ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001da:	e8 41 0c 00 00       	call   800e20 <__udivdi3>
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	52                   	push   %edx
  8001e3:	50                   	push   %eax
  8001e4:	89 f2                	mov    %esi,%edx
  8001e6:	89 f8                	mov    %edi,%eax
  8001e8:	e8 9e ff ff ff       	call   80018b <printnum>
  8001ed:	83 c4 20             	add    $0x20,%esp
  8001f0:	eb 13                	jmp    800205 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	ff 75 18             	pushl  0x18(%ebp)
  8001f9:	ff d7                	call   *%edi
  8001fb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fe:	83 eb 01             	sub    $0x1,%ebx
  800201:	85 db                	test   %ebx,%ebx
  800203:	7f ed                	jg     8001f2 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	83 ec 04             	sub    $0x4,%esp
  80020c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020f:	ff 75 e0             	pushl  -0x20(%ebp)
  800212:	ff 75 dc             	pushl  -0x24(%ebp)
  800215:	ff 75 d8             	pushl  -0x28(%ebp)
  800218:	e8 23 0d 00 00       	call   800f40 <__umoddi3>
  80021d:	83 c4 14             	add    $0x14,%esp
  800220:	0f be 80 86 10 80 00 	movsbl 0x801086(%eax),%eax
  800227:	50                   	push   %eax
  800228:	ff d7                	call   *%edi
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5f                   	pop    %edi
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800238:	eb c4                	jmp    8001fe <printnum+0x73>

0080023a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800240:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800244:	8b 10                	mov    (%eax),%edx
  800246:	3b 50 04             	cmp    0x4(%eax),%edx
  800249:	73 0a                	jae    800255 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024e:	89 08                	mov    %ecx,(%eax)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	88 02                	mov    %al,(%edx)
}
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <printfmt>:
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800260:	50                   	push   %eax
  800261:	ff 75 10             	pushl  0x10(%ebp)
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	e8 05 00 00 00       	call   800274 <vprintfmt>
}
  80026f:	83 c4 10             	add    $0x10,%esp
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <vprintfmt>:
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 2c             	sub    $0x2c,%esp
  80027d:	8b 75 08             	mov    0x8(%ebp),%esi
  800280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800283:	8b 7d 10             	mov    0x10(%ebp),%edi
  800286:	e9 63 03 00 00       	jmp    8005ee <vprintfmt+0x37a>
		padc = ' ';
  80028b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80028f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800296:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80029d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002af:	0f b6 17             	movzbl (%edi),%edx
  8002b2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b5:	3c 55                	cmp    $0x55,%al
  8002b7:	0f 87 11 04 00 00    	ja     8006ce <vprintfmt+0x45a>
  8002bd:	0f b6 c0             	movzbl %al,%eax
  8002c0:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8002c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ca:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ce:	eb d9                	jmp    8002a9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002d3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d7:	eb d0                	jmp    8002a9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	0f b6 d2             	movzbl %dl,%edx
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002df:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ea:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ee:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f4:	83 f9 09             	cmp    $0x9,%ecx
  8002f7:	77 55                	ja     80034e <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fc:	eb e9                	jmp    8002e7 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800301:	8b 00                	mov    (%eax),%eax
  800303:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800306:	8b 45 14             	mov    0x14(%ebp),%eax
  800309:	8d 40 04             	lea    0x4(%eax),%eax
  80030c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800312:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800316:	79 91                	jns    8002a9 <vprintfmt+0x35>
				width = precision, precision = -1;
  800318:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800325:	eb 82                	jmp    8002a9 <vprintfmt+0x35>
  800327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032a:	85 c0                	test   %eax,%eax
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
  800331:	0f 49 d0             	cmovns %eax,%edx
  800334:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033a:	e9 6a ff ff ff       	jmp    8002a9 <vprintfmt+0x35>
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800342:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800349:	e9 5b ff ff ff       	jmp    8002a9 <vprintfmt+0x35>
  80034e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800351:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800354:	eb bc                	jmp    800312 <vprintfmt+0x9e>
			lflag++;
  800356:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035c:	e9 48 ff ff ff       	jmp    8002a9 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 78 04             	lea    0x4(%eax),%edi
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	ff 30                	pushl  (%eax)
  80036d:	ff d6                	call   *%esi
			break;
  80036f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800372:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800375:	e9 71 02 00 00       	jmp    8005eb <vprintfmt+0x377>
			err = va_arg(ap, int);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 78 04             	lea    0x4(%eax),%edi
  800380:	8b 00                	mov    (%eax),%eax
  800382:	99                   	cltd   
  800383:	31 d0                	xor    %edx,%eax
  800385:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800387:	83 f8 08             	cmp    $0x8,%eax
  80038a:	7f 23                	jg     8003af <vprintfmt+0x13b>
  80038c:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800393:	85 d2                	test   %edx,%edx
  800395:	74 18                	je     8003af <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800397:	52                   	push   %edx
  800398:	68 a7 10 80 00       	push   $0x8010a7
  80039d:	53                   	push   %ebx
  80039e:	56                   	push   %esi
  80039f:	e8 b3 fe ff ff       	call   800257 <printfmt>
  8003a4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003aa:	e9 3c 02 00 00       	jmp    8005eb <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8003af:	50                   	push   %eax
  8003b0:	68 9e 10 80 00       	push   $0x80109e
  8003b5:	53                   	push   %ebx
  8003b6:	56                   	push   %esi
  8003b7:	e8 9b fe ff ff       	call   800257 <printfmt>
  8003bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c2:	e9 24 02 00 00       	jmp    8005eb <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	83 c0 04             	add    $0x4,%eax
  8003cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d5:	85 ff                	test   %edi,%edi
  8003d7:	b8 97 10 80 00       	mov    $0x801097,%eax
  8003dc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e3:	0f 8e bd 00 00 00    	jle    8004a6 <vprintfmt+0x232>
  8003e9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ed:	75 0e                	jne    8003fd <vprintfmt+0x189>
  8003ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8003f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003fb:	eb 6d                	jmp    80046a <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	ff 75 d0             	pushl  -0x30(%ebp)
  800403:	57                   	push   %edi
  800404:	e8 6d 03 00 00       	call   800776 <strnlen>
  800409:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040c:	29 c1                	sub    %eax,%ecx
  80040e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800411:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800414:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041e:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	eb 0f                	jmp    800431 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 75 e0             	pushl  -0x20(%ebp)
  800429:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80042b:	83 ef 01             	sub    $0x1,%edi
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	85 ff                	test   %edi,%edi
  800433:	7f ed                	jg     800422 <vprintfmt+0x1ae>
  800435:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800438:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80043b:	85 c9                	test   %ecx,%ecx
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	0f 49 c1             	cmovns %ecx,%eax
  800445:	29 c1                	sub    %eax,%ecx
  800447:	89 75 08             	mov    %esi,0x8(%ebp)
  80044a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800450:	89 cb                	mov    %ecx,%ebx
  800452:	eb 16                	jmp    80046a <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800454:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800458:	75 31                	jne    80048b <vprintfmt+0x217>
					putch(ch, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	50                   	push   %eax
  800461:	ff 55 08             	call   *0x8(%ebp)
  800464:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800467:	83 eb 01             	sub    $0x1,%ebx
  80046a:	83 c7 01             	add    $0x1,%edi
  80046d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800471:	0f be c2             	movsbl %dl,%eax
  800474:	85 c0                	test   %eax,%eax
  800476:	74 59                	je     8004d1 <vprintfmt+0x25d>
  800478:	85 f6                	test   %esi,%esi
  80047a:	78 d8                	js     800454 <vprintfmt+0x1e0>
  80047c:	83 ee 01             	sub    $0x1,%esi
  80047f:	79 d3                	jns    800454 <vprintfmt+0x1e0>
  800481:	89 df                	mov    %ebx,%edi
  800483:	8b 75 08             	mov    0x8(%ebp),%esi
  800486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800489:	eb 37                	jmp    8004c2 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80048b:	0f be d2             	movsbl %dl,%edx
  80048e:	83 ea 20             	sub    $0x20,%edx
  800491:	83 fa 5e             	cmp    $0x5e,%edx
  800494:	76 c4                	jbe    80045a <vprintfmt+0x1e6>
					putch('?', putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	ff 75 0c             	pushl  0xc(%ebp)
  80049c:	6a 3f                	push   $0x3f
  80049e:	ff 55 08             	call   *0x8(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	eb c1                	jmp    800467 <vprintfmt+0x1f3>
  8004a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b2:	eb b6                	jmp    80046a <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	53                   	push   %ebx
  8004b8:	6a 20                	push   $0x20
  8004ba:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f ee                	jg     8004b4 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	e9 1a 01 00 00       	jmp    8005eb <vprintfmt+0x377>
  8004d1:	89 df                	mov    %ebx,%edi
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d9:	eb e7                	jmp    8004c2 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004db:	83 f9 01             	cmp    $0x1,%ecx
  8004de:	7e 3f                	jle    80051f <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8b 50 04             	mov    0x4(%eax),%edx
  8004e6:	8b 00                	mov    (%eax),%eax
  8004e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 40 08             	lea    0x8(%eax),%eax
  8004f4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fb:	79 5c                	jns    800559 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	6a 2d                	push   $0x2d
  800503:	ff d6                	call   *%esi
				num = -(long long) num;
  800505:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800508:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050b:	f7 da                	neg    %edx
  80050d:	83 d1 00             	adc    $0x0,%ecx
  800510:	f7 d9                	neg    %ecx
  800512:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800515:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051a:	e9 b2 00 00 00       	jmp    8005d1 <vprintfmt+0x35d>
	else if (lflag)
  80051f:	85 c9                	test   %ecx,%ecx
  800521:	75 1b                	jne    80053e <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 04             	lea    0x4(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
  80053c:	eb b9                	jmp    8004f7 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	89 c1                	mov    %eax,%ecx
  800548:	c1 f9 1f             	sar    $0x1f,%ecx
  80054b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 40 04             	lea    0x4(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	eb 9e                	jmp    8004f7 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80055f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800564:	eb 6b                	jmp    8005d1 <vprintfmt+0x35d>
	if (lflag >= 2)
  800566:	83 f9 01             	cmp    $0x1,%ecx
  800569:	7e 15                	jle    800580 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8b 48 04             	mov    0x4(%eax),%ecx
  800573:	8d 40 08             	lea    0x8(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 51                	jmp    8005d1 <vprintfmt+0x35d>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	75 17                	jne    80059b <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 10                	mov    (%eax),%edx
  800589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058e:	8d 40 04             	lea    0x4(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	eb 36                	jmp    8005d1 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b0:	eb 1f                	jmp    8005d1 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005b2:	83 f9 01             	cmp    $0x1,%ecx
  8005b5:	7e 5b                	jle    800612 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005c2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005c8:	89 d1                	mov    %edx,%ecx
  8005ca:	89 c2                	mov    %eax,%edx
			base = 8;
  8005cc:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005d1:	83 ec 0c             	sub    $0xc,%esp
  8005d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d8:	57                   	push   %edi
  8005d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005dc:	50                   	push   %eax
  8005dd:	51                   	push   %ecx
  8005de:	52                   	push   %edx
  8005df:	89 da                	mov    %ebx,%edx
  8005e1:	89 f0                	mov    %esi,%eax
  8005e3:	e8 a3 fb ff ff       	call   80018b <printnum>
			break;
  8005e8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ee:	83 c7 01             	add    $0x1,%edi
  8005f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f5:	83 f8 25             	cmp    $0x25,%eax
  8005f8:	0f 84 8d fc ff ff    	je     80028b <vprintfmt+0x17>
			if (ch == '\0')
  8005fe:	85 c0                	test   %eax,%eax
  800600:	0f 84 e8 00 00 00    	je     8006ee <vprintfmt+0x47a>
			putch(ch, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	50                   	push   %eax
  80060b:	ff d6                	call   *%esi
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	eb dc                	jmp    8005ee <vprintfmt+0x37a>
	else if (lflag)
  800612:	85 c9                	test   %ecx,%ecx
  800614:	75 13                	jne    800629 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	89 d0                	mov    %edx,%eax
  80061d:	99                   	cltd   
  80061e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800621:	8d 49 04             	lea    0x4(%ecx),%ecx
  800624:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800627:	eb 9f                	jmp    8005c8 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	89 d0                	mov    %edx,%eax
  800630:	99                   	cltd   
  800631:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800634:	8d 49 04             	lea    0x4(%ecx),%ecx
  800637:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063a:	eb 8c                	jmp    8005c8 <vprintfmt+0x354>
			putch('0', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 30                	push   $0x30
  800642:	ff d6                	call   *%esi
			putch('x', putdat);
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 78                	push   $0x78
  80064a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800656:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800659:	8d 40 04             	lea    0x4(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800664:	e9 68 ff ff ff       	jmp    8005d1 <vprintfmt+0x35d>
	if (lflag >= 2)
  800669:	83 f9 01             	cmp    $0x1,%ecx
  80066c:	7e 18                	jle    800686 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	8b 48 04             	mov    0x4(%eax),%ecx
  800676:	8d 40 08             	lea    0x8(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
  800681:	e9 4b ff ff ff       	jmp    8005d1 <vprintfmt+0x35d>
	else if (lflag)
  800686:	85 c9                	test   %ecx,%ecx
  800688:	75 1a                	jne    8006a4 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
  80069f:	e9 2d ff ff ff       	jmp    8005d1 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b9:	e9 13 ff ff ff       	jmp    8005d1 <vprintfmt+0x35d>
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 25                	push   $0x25
  8006c4:	ff d6                	call   *%esi
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	e9 1d ff ff ff       	jmp    8005eb <vprintfmt+0x377>
			putch('%', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 25                	push   $0x25
  8006d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	89 f8                	mov    %edi,%eax
  8006db:	eb 03                	jmp    8006e0 <vprintfmt+0x46c>
  8006dd:	83 e8 01             	sub    $0x1,%eax
  8006e0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e4:	75 f7                	jne    8006dd <vprintfmt+0x469>
  8006e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e9:	e9 fd fe ff ff       	jmp    8005eb <vprintfmt+0x377>
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 3a 02 80 00       	push   $0x80023a
  80072a:	e8 45 fb ff ff       	call   800274 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800742:	eb f7                	jmp    80073b <vsnprintf+0x45>

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 d0                	cmp    %edx,%eax
  80078b:	74 06                	je     800793 <strnlen+0x1d>
  80078d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	83 c1 01             	add    $0x1,%ecx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ab:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ae:	84 db                	test   %bl,%bl
  8007b0:	75 ef                	jne    8007a1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bc:	53                   	push   %ebx
  8007bd:	e8 9c ff ff ff       	call   80075e <strlen>
  8007c2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	01 d8                	add    %ebx,%eax
  8007ca:	50                   	push   %eax
  8007cb:	e8 c5 ff ff ff       	call   800795 <strcpy>
	return dst;
}
  8007d0:	89 d8                	mov    %ebx,%eax
  8007d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	89 f3                	mov    %esi,%ebx
  8007e4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	89 f2                	mov    %esi,%edx
  8007e9:	eb 0f                	jmp    8007fa <strncpy+0x23>
		*dst++ = *src;
  8007eb:	83 c2 01             	add    $0x1,%edx
  8007ee:	0f b6 01             	movzbl (%ecx),%eax
  8007f1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f7:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007fa:	39 da                	cmp    %ebx,%edx
  8007fc:	75 ed                	jne    8007eb <strncpy+0x14>
	}
	return ret;
}
  8007fe:	89 f0                	mov    %esi,%eax
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	8b 75 08             	mov    0x8(%ebp),%esi
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800812:	89 f0                	mov    %esi,%eax
  800814:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 c9                	test   %ecx,%ecx
  80081a:	75 0b                	jne    800827 <strlcpy+0x23>
  80081c:	eb 17                	jmp    800835 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800827:	39 d8                	cmp    %ebx,%eax
  800829:	74 07                	je     800832 <strlcpy+0x2e>
  80082b:	0f b6 0a             	movzbl (%edx),%ecx
  80082e:	84 c9                	test   %cl,%cl
  800830:	75 ec                	jne    80081e <strlcpy+0x1a>
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	eb 06                	jmp    80084c <strcmp+0x11>
		p++, q++;
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	84 c0                	test   %al,%al
  800851:	74 04                	je     800857 <strcmp+0x1c>
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 ef                	je     800846 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x17>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 16                	je     800892 <strncmp+0x31>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x26>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    
		return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb f6                	jmp    80088f <strncmp+0x2e>

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	0f b6 10             	movzbl (%eax),%edx
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	74 09                	je     8008b3 <strchr+0x1a>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 0a                	je     8008b8 <strchr+0x1f>
	for (; *s; s++)
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	eb f0                	jmp    8008a3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 03                	jmp    8008c9 <strfind+0xf>
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 04                	je     8008d4 <strfind+0x1a>
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 13                	je     8008f9 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ec:	75 05                	jne    8008f3 <memset+0x1d>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	74 0d                	je     800900 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	fc                   	cld    
  8008f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f9:	89 f8                	mov    %edi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5f                   	pop    %edi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    
		c &= 0xFF;
  800900:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d3                	mov    %edx,%ebx
  800906:	c1 e3 08             	shl    $0x8,%ebx
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 18             	shl    $0x18,%eax
  80090e:	89 d6                	mov    %edx,%esi
  800910:	c1 e6 10             	shl    $0x10,%esi
  800913:	09 f0                	or     %esi,%eax
  800915:	09 c2                	or     %eax,%edx
  800917:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb d6                	jmp    8008f9 <memset+0x23>

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 35                	jae    80096a <memmove+0x47>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 c2                	cmp    %eax,%edx
  80093a:	76 2e                	jbe    80096a <memmove+0x47>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	89 d6                	mov    %edx,%esi
  800941:	09 fe                	or     %edi,%esi
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	74 0c                	je     800957 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094b:	83 ef 01             	sub    $0x1,%edi
  80094e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800951:	fd                   	std    
  800952:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800954:	fc                   	cld    
  800955:	eb 21                	jmp    800978 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 ef                	jne    80094b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095c:	83 ef 04             	sub    $0x4,%edi
  80095f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800962:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800965:	fd                   	std    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb ea                	jmp    800954 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	74 09                	je     80097c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 f2                	jne    800973 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800981:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb ed                	jmp    800978 <memmove+0x55>

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 87 ff ff ff       	call   800923 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	74 1c                	je     8009ce <memcmp+0x30>
		if (*s1 != *s2)
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	38 d9                	cmp    %bl,%cl
  8009ba:	75 08                	jne    8009c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	83 c2 01             	add    $0x1,%edx
  8009c2:	eb ea                	jmp    8009ae <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c4:	0f b6 c1             	movzbl %cl,%eax
  8009c7:	0f b6 db             	movzbl %bl,%ebx
  8009ca:	29 d8                	sub    %ebx,%eax
  8009cc:	eb 05                	jmp    8009d3 <memcmp+0x35>
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e5:	39 d0                	cmp    %edx,%eax
  8009e7:	73 09                	jae    8009f2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	38 08                	cmp    %cl,(%eax)
  8009eb:	74 05                	je     8009f2 <memfind+0x1b>
	for (; s < ends; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	eb f3                	jmp    8009e5 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	eb 03                	jmp    800a05 <strtol+0x11>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a05:	0f b6 01             	movzbl (%ecx),%eax
  800a08:	3c 20                	cmp    $0x20,%al
  800a0a:	74 f6                	je     800a02 <strtol+0xe>
  800a0c:	3c 09                	cmp    $0x9,%al
  800a0e:	74 f2                	je     800a02 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a10:	3c 2b                	cmp    $0x2b,%al
  800a12:	74 2e                	je     800a42 <strtol+0x4e>
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	74 2f                	je     800a4c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 05                	jne    800a2a <strtol+0x36>
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	74 2c                	je     800a56 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	75 0a                	jne    800a38 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a33:	80 39 30             	cmpb   $0x30,(%ecx)
  800a36:	74 28                	je     800a60 <strtol+0x6c>
		base = 10;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a40:	eb 50                	jmp    800a92 <strtol+0x9e>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4a:	eb d1                	jmp    800a1d <strtol+0x29>
		s++, neg = 1;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a54:	eb c7                	jmp    800a1d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5a:	74 0e                	je     800a6a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	75 d8                	jne    800a38 <strtol+0x44>
		s++, base = 8;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a68:	eb ce                	jmp    800a38 <strtol+0x44>
		s += 2, base = 16;
  800a6a:	83 c1 02             	add    $0x2,%ecx
  800a6d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a72:	eb c4                	jmp    800a38 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 29                	ja     800aa7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a84:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a87:	7d 30                	jge    800ab9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a90:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a92:	0f b6 11             	movzbl (%ecx),%edx
  800a95:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 09             	cmp    $0x9,%bl
  800a9d:	77 d5                	ja     800a74 <strtol+0x80>
			dig = *s - '0';
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 30             	sub    $0x30,%edx
  800aa5:	eb dd                	jmp    800a84 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aa7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 19             	cmp    $0x19,%bl
  800aaf:	77 08                	ja     800ab9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 37             	sub    $0x37,%edx
  800ab7:	eb cb                	jmp    800a84 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abd:	74 05                	je     800ac4 <strtol+0xd0>
		*endptr = (char *) s;
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	f7 da                	neg    %edx
  800ac8:	85 ff                	test   %edi,%edi
  800aca:	0f 45 c2             	cmovne %edx,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	89 c6                	mov    %eax,%esi
  800ae9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	89 d1                	mov    %edx,%ecx
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	89 d7                	mov    %edx,%edi
  800b06:	89 d6                	mov    %edx,%esi
  800b08:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	b8 03 00 00 00       	mov    $0x3,%eax
  800b25:	89 cb                	mov    %ecx,%ebx
  800b27:	89 cf                	mov    %ecx,%edi
  800b29:	89 ce                	mov    %ecx,%esi
  800b2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7f 08                	jg     800b39 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 03                	push   $0x3
  800b3f:	68 c4 12 80 00       	push   $0x8012c4
  800b44:	6a 23                	push   $0x23
  800b46:	68 e1 12 80 00       	push   $0x8012e1
  800b4b:	e8 81 02 00 00       	call   800dd1 <_panic>

00800b50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	89 d3                	mov    %edx,%ebx
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_yield>:

void
sys_yield(void)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b75:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7f:	89 d1                	mov    %edx,%ecx
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b97:	be 00 00 00 00       	mov    $0x0,%esi
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baa:	89 f7                	mov    %esi,%edi
  800bac:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7f 08                	jg     800bba <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 04                	push   $0x4
  800bc0:	68 c4 12 80 00       	push   $0x8012c4
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 e1 12 80 00       	push   $0x8012e1
  800bcc:	e8 00 02 00 00       	call   800dd1 <_panic>

00800bd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800beb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7f 08                	jg     800bfc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 05                	push   $0x5
  800c02:	68 c4 12 80 00       	push   $0x8012c4
  800c07:	6a 23                	push   $0x23
  800c09:	68 e1 12 80 00       	push   $0x8012e1
  800c0e:	e8 be 01 00 00       	call   800dd1 <_panic>

00800c13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	89 df                	mov    %ebx,%edi
  800c2e:	89 de                	mov    %ebx,%esi
  800c30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7f 08                	jg     800c3e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 06                	push   $0x6
  800c44:	68 c4 12 80 00       	push   $0x8012c4
  800c49:	6a 23                	push   $0x23
  800c4b:	68 e1 12 80 00       	push   $0x8012e1
  800c50:	e8 7c 01 00 00       	call   800dd1 <_panic>

00800c55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7f 08                	jg     800c80 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 08                	push   $0x8
  800c86:	68 c4 12 80 00       	push   $0x8012c4
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 e1 12 80 00       	push   $0x8012e1
  800c92:	e8 3a 01 00 00       	call   800dd1 <_panic>

00800c97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7f 08                	jg     800cc2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 09                	push   $0x9
  800cc8:	68 c4 12 80 00       	push   $0x8012c4
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 e1 12 80 00       	push   $0x8012e1
  800cd4:	e8 f8 00 00 00       	call   800dd1 <_panic>

00800cd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d12:	89 cb                	mov    %ecx,%ebx
  800d14:	89 cf                	mov    %ecx,%edi
  800d16:	89 ce                	mov    %ecx,%esi
  800d18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7f 08                	jg     800d26 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0c                	push   $0xc
  800d2c:	68 c4 12 80 00       	push   $0x8012c4
  800d31:	6a 23                	push   $0x23
  800d33:	68 e1 12 80 00       	push   $0x8012e1
  800d38:	e8 94 00 00 00       	call   800dd1 <_panic>

00800d3d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
	int r;
	envid_t trap_env_id = sys_getenvid();
  800d44:	e8 07 fe ff ff       	call   800b50 <sys_getenvid>
  800d49:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800d4b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d52:	74 22                	je     800d76 <set_pgfault_handler+0x39>
		// LAB 4: Your code here.
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
		
		//panic("set_pgfault_handler not implemented");
	}
	if (sys_env_set_pgfault_upcall(trap_env_id, _pgfault_upcall)) {
  800d54:	83 ec 08             	sub    $0x8,%esp
  800d57:	68 9f 0d 80 00       	push   $0x800d9f
  800d5c:	53                   	push   %ebx
  800d5d:	e8 35 ff ff ff       	call   800c97 <sys_env_set_pgfault_upcall>
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	75 22                	jne    800d8b <set_pgfault_handler+0x4e>
		panic("set pgfault upcall failed!");
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	6a 06                	push   $0x6
  800d7b:	68 00 f0 bf ee       	push   $0xeebff000
  800d80:	50                   	push   %eax
  800d81:	e8 08 fe ff ff       	call   800b8e <sys_page_alloc>
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	eb c9                	jmp    800d54 <set_pgfault_handler+0x17>
		panic("set pgfault upcall failed!");
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 ef 12 80 00       	push   $0x8012ef
  800d93:	6a 25                	push   $0x25
  800d95:	68 0a 13 80 00       	push   $0x80130a
  800d9a:	e8 32 00 00 00       	call   800dd1 <_panic>

00800d9f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d9f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800da5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800da7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	lea 48(%esp), %eax
  800daa:	8d 44 24 30          	lea    0x30(%esp),%eax
	movl (%eax), %eax
  800dae:	8b 00                	mov    (%eax),%eax
	lea 40(%esp), %ebx
  800db0:	8d 5c 24 28          	lea    0x28(%esp),%ebx
	movl (%ebx), %ebx
  800db4:	8b 1b                	mov    (%ebx),%ebx
	subl $4, %eax
  800db6:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  800db9:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	add $8, %esp
  800dbb:	83 c4 08             	add    $0x8,%esp
	pop %edi
  800dbe:	5f                   	pop    %edi
	pop %esi
  800dbf:	5e                   	pop    %esi
	pop %ebp
  800dc0:	5d                   	pop    %ebp
	add $4, %esp
  800dc1:	83 c4 04             	add    $0x4,%esp
	pop %ebx
  800dc4:	5b                   	pop    %ebx
	pop %edx
  800dc5:	5a                   	pop    %edx
	pop %ecx
  800dc6:	59                   	pop    %ecx
	pop %eax
  800dc7:	58                   	pop    %eax
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  800dc8:	83 c4 04             	add    $0x4,%esp
	popfl
  800dcb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800dcc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	sub $4, %esp
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	c3                   	ret    

00800dd1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dd9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ddf:	e8 6c fd ff ff       	call   800b50 <sys_getenvid>
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	ff 75 08             	pushl  0x8(%ebp)
  800ded:	56                   	push   %esi
  800dee:	50                   	push   %eax
  800def:	68 18 13 80 00       	push   $0x801318
  800df4:	e8 7e f3 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df9:	83 c4 18             	add    $0x18,%esp
  800dfc:	53                   	push   %ebx
  800dfd:	ff 75 10             	pushl  0x10(%ebp)
  800e00:	e8 21 f3 ff ff       	call   800126 <vcprintf>
	cprintf("\n");
  800e05:	c7 04 24 7a 10 80 00 	movl   $0x80107a,(%esp)
  800e0c:	e8 66 f3 ff ff       	call   800177 <cprintf>
  800e11:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e14:	cc                   	int3   
  800e15:	eb fd                	jmp    800e14 <_panic+0x43>
  800e17:	66 90                	xchg   %ax,%ax
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
