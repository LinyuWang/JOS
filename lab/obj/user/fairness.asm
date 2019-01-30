
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 31 0b 00 00       	call   800b71 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 00 0d 00 00       	call   800d5e <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 10 80 00       	push   $0x801060
  80006a:	e8 29 01 00 00       	call   800198 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 10 80 00       	push   $0x801071
  800083:	e8 10 01 00 00       	call   800198 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 d9 0c 00 00       	call   800d75 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ac:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000b3:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000b6:	e8 b6 0a 00 00       	call   800b71 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c8:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7e 07                	jle    8000d8 <libmain+0x37>
		binaryname = argv[0];
  8000d1:	8b 06                	mov    (%esi),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	e8 51 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e2:	e8 0a 00 00 00       	call   8000f1 <exit>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f7:	6a 00                	push   $0x0
  8000f9:	e8 32 0a 00 00       	call   800b30 <sys_env_destroy>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	53                   	push   %ebx
  800107:	83 ec 04             	sub    $0x4,%esp
  80010a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010d:	8b 13                	mov    (%ebx),%edx
  80010f:	8d 42 01             	lea    0x1(%edx),%eax
  800112:	89 03                	mov    %eax,(%ebx)
  800114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800117:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800120:	74 09                	je     80012b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800122:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	68 ff 00 00 00       	push   $0xff
  800133:	8d 43 08             	lea    0x8(%ebx),%eax
  800136:	50                   	push   %eax
  800137:	e8 b7 09 00 00       	call   800af3 <sys_cputs>
		b->idx = 0;
  80013c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	eb db                	jmp    800122 <putch+0x1f>

00800147 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800150:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800157:	00 00 00 
	b.cnt = 0;
  80015a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800161:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800170:	50                   	push   %eax
  800171:	68 03 01 80 00       	push   $0x800103
  800176:	e8 1a 01 00 00       	call   800295 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800184:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 63 09 00 00       	call   800af3 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	e8 9d ff ff ff       	call   800147 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 1c             	sub    $0x1c,%esp
  8001b5:	89 c7                	mov    %eax,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d3:	39 d3                	cmp    %edx,%ebx
  8001d5:	72 05                	jb     8001dc <printnum+0x30>
  8001d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001da:	77 7a                	ja     800256 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e8:	53                   	push   %ebx
  8001e9:	ff 75 10             	pushl  0x10(%ebp)
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fb:	e8 10 0c 00 00       	call   800e10 <__udivdi3>
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	52                   	push   %edx
  800204:	50                   	push   %eax
  800205:	89 f2                	mov    %esi,%edx
  800207:	89 f8                	mov    %edi,%eax
  800209:	e8 9e ff ff ff       	call   8001ac <printnum>
  80020e:	83 c4 20             	add    $0x20,%esp
  800211:	eb 13                	jmp    800226 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	56                   	push   %esi
  800217:	ff 75 18             	pushl  0x18(%ebp)
  80021a:	ff d7                	call   *%edi
  80021c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	85 db                	test   %ebx,%ebx
  800224:	7f ed                	jg     800213 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800226:	83 ec 08             	sub    $0x8,%esp
  800229:	56                   	push   %esi
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800230:	ff 75 e0             	pushl  -0x20(%ebp)
  800233:	ff 75 dc             	pushl  -0x24(%ebp)
  800236:	ff 75 d8             	pushl  -0x28(%ebp)
  800239:	e8 f2 0c 00 00       	call   800f30 <__umoddi3>
  80023e:	83 c4 14             	add    $0x14,%esp
  800241:	0f be 80 92 10 80 00 	movsbl 0x801092(%eax),%eax
  800248:	50                   	push   %eax
  800249:	ff d7                	call   *%edi
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    
  800256:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800259:	eb c4                	jmp    80021f <printnum+0x73>

0080025b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800261:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800265:	8b 10                	mov    (%eax),%edx
  800267:	3b 50 04             	cmp    0x4(%eax),%edx
  80026a:	73 0a                	jae    800276 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	88 02                	mov    %al,(%edx)
}
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <printfmt>:
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800281:	50                   	push   %eax
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	ff 75 0c             	pushl  0xc(%ebp)
  800288:	ff 75 08             	pushl  0x8(%ebp)
  80028b:	e8 05 00 00 00       	call   800295 <vprintfmt>
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <vprintfmt>:
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 2c             	sub    $0x2c,%esp
  80029e:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a7:	e9 63 03 00 00       	jmp    80060f <vprintfmt+0x37a>
		padc = ' ';
  8002ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8d 47 01             	lea    0x1(%edi),%eax
  8002cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d0:	0f b6 17             	movzbl (%edi),%edx
  8002d3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d6:	3c 55                	cmp    $0x55,%al
  8002d8:	0f 87 11 04 00 00    	ja     8006ef <vprintfmt+0x45a>
  8002de:	0f b6 c0             	movzbl %al,%eax
  8002e1:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ef:	eb d9                	jmp    8002ca <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002f4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f8:	eb d0                	jmp    8002ca <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	0f b6 d2             	movzbl %dl,%edx
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800300:	b8 00 00 00 00       	mov    $0x0,%eax
  800305:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800308:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800312:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800315:	83 f9 09             	cmp    $0x9,%ecx
  800318:	77 55                	ja     80036f <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80031a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031d:	eb e9                	jmp    800308 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8b 00                	mov    (%eax),%eax
  800324:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 40 04             	lea    0x4(%eax),%eax
  80032d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800337:	79 91                	jns    8002ca <vprintfmt+0x35>
				width = precision, precision = -1;
  800339:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800346:	eb 82                	jmp    8002ca <vprintfmt+0x35>
  800348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034b:	85 c0                	test   %eax,%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	0f 49 d0             	cmovns %eax,%edx
  800355:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035b:	e9 6a ff ff ff       	jmp    8002ca <vprintfmt+0x35>
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800363:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036a:	e9 5b ff ff ff       	jmp    8002ca <vprintfmt+0x35>
  80036f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800372:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800375:	eb bc                	jmp    800333 <vprintfmt+0x9e>
			lflag++;
  800377:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037d:	e9 48 ff ff ff       	jmp    8002ca <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800382:	8b 45 14             	mov    0x14(%ebp),%eax
  800385:	8d 78 04             	lea    0x4(%eax),%edi
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	53                   	push   %ebx
  80038c:	ff 30                	pushl  (%eax)
  80038e:	ff d6                	call   *%esi
			break;
  800390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800396:	e9 71 02 00 00       	jmp    80060c <vprintfmt+0x377>
			err = va_arg(ap, int);
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 78 04             	lea    0x4(%eax),%edi
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	99                   	cltd   
  8003a4:	31 d0                	xor    %edx,%eax
  8003a6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a8:	83 f8 08             	cmp    $0x8,%eax
  8003ab:	7f 23                	jg     8003d0 <vprintfmt+0x13b>
  8003ad:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	74 18                	je     8003d0 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003b8:	52                   	push   %edx
  8003b9:	68 b3 10 80 00       	push   $0x8010b3
  8003be:	53                   	push   %ebx
  8003bf:	56                   	push   %esi
  8003c0:	e8 b3 fe ff ff       	call   800278 <printfmt>
  8003c5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003cb:	e9 3c 02 00 00       	jmp    80060c <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8003d0:	50                   	push   %eax
  8003d1:	68 aa 10 80 00       	push   $0x8010aa
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 9b fe ff ff       	call   800278 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e3:	e9 24 02 00 00       	jmp    80060c <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	83 c0 04             	add    $0x4,%eax
  8003ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f6:	85 ff                	test   %edi,%edi
  8003f8:	b8 a3 10 80 00       	mov    $0x8010a3,%eax
  8003fd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800400:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800404:	0f 8e bd 00 00 00    	jle    8004c7 <vprintfmt+0x232>
  80040a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040e:	75 0e                	jne    80041e <vprintfmt+0x189>
  800410:	89 75 08             	mov    %esi,0x8(%ebp)
  800413:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800416:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800419:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80041c:	eb 6d                	jmp    80048b <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	ff 75 d0             	pushl  -0x30(%ebp)
  800424:	57                   	push   %edi
  800425:	e8 6d 03 00 00       	call   800797 <strnlen>
  80042a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042d:	29 c1                	sub    %eax,%ecx
  80042f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800432:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800435:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800439:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	eb 0f                	jmp    800452 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	ff 75 e0             	pushl  -0x20(%ebp)
  80044a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ef 01             	sub    $0x1,%edi
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	85 ff                	test   %edi,%edi
  800454:	7f ed                	jg     800443 <vprintfmt+0x1ae>
  800456:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800459:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045c:	85 c9                	test   %ecx,%ecx
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	0f 49 c1             	cmovns %ecx,%eax
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 75 08             	mov    %esi,0x8(%ebp)
  80046b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800471:	89 cb                	mov    %ecx,%ebx
  800473:	eb 16                	jmp    80048b <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800475:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800479:	75 31                	jne    8004ac <vprintfmt+0x217>
					putch(ch, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	50                   	push   %eax
  800482:	ff 55 08             	call   *0x8(%ebp)
  800485:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800488:	83 eb 01             	sub    $0x1,%ebx
  80048b:	83 c7 01             	add    $0x1,%edi
  80048e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800492:	0f be c2             	movsbl %dl,%eax
  800495:	85 c0                	test   %eax,%eax
  800497:	74 59                	je     8004f2 <vprintfmt+0x25d>
  800499:	85 f6                	test   %esi,%esi
  80049b:	78 d8                	js     800475 <vprintfmt+0x1e0>
  80049d:	83 ee 01             	sub    $0x1,%esi
  8004a0:	79 d3                	jns    800475 <vprintfmt+0x1e0>
  8004a2:	89 df                	mov    %ebx,%edi
  8004a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004aa:	eb 37                	jmp    8004e3 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	0f be d2             	movsbl %dl,%edx
  8004af:	83 ea 20             	sub    $0x20,%edx
  8004b2:	83 fa 5e             	cmp    $0x5e,%edx
  8004b5:	76 c4                	jbe    80047b <vprintfmt+0x1e6>
					putch('?', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 0c             	pushl  0xc(%ebp)
  8004bd:	6a 3f                	push   $0x3f
  8004bf:	ff 55 08             	call   *0x8(%ebp)
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	eb c1                	jmp    800488 <vprintfmt+0x1f3>
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	eb b6                	jmp    80048b <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	6a 20                	push   $0x20
  8004db:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004dd:	83 ef 01             	sub    $0x1,%edi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 ff                	test   %edi,%edi
  8004e5:	7f ee                	jg     8004d5 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ed:	e9 1a 01 00 00       	jmp    80060c <vprintfmt+0x377>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	eb e7                	jmp    8004e3 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004fc:	83 f9 01             	cmp    $0x1,%ecx
  8004ff:	7e 3f                	jle    800540 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 50 04             	mov    0x4(%eax),%edx
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 40 08             	lea    0x8(%eax),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800518:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051c:	79 5c                	jns    80057a <vprintfmt+0x2e5>
				putch('-', putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	6a 2d                	push   $0x2d
  800524:	ff d6                	call   *%esi
				num = -(long long) num;
  800526:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800529:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052c:	f7 da                	neg    %edx
  80052e:	83 d1 00             	adc    $0x0,%ecx
  800531:	f7 d9                	neg    %ecx
  800533:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053b:	e9 b2 00 00 00       	jmp    8005f2 <vprintfmt+0x35d>
	else if (lflag)
  800540:	85 c9                	test   %ecx,%ecx
  800542:	75 1b                	jne    80055f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 c1                	mov    %eax,%ecx
  80054e:	c1 f9 1f             	sar    $0x1f,%ecx
  800551:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 40 04             	lea    0x4(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
  80055d:	eb b9                	jmp    800518 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 c1                	mov    %eax,%ecx
  800569:	c1 f9 1f             	sar    $0x1f,%ecx
  80056c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	eb 9e                	jmp    800518 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80057a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
  800585:	eb 6b                	jmp    8005f2 <vprintfmt+0x35d>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7e 15                	jle    8005a1 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	8b 48 04             	mov    0x4(%eax),%ecx
  800594:	8d 40 08             	lea    0x8(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	eb 51                	jmp    8005f2 <vprintfmt+0x35d>
	else if (lflag)
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	75 17                	jne    8005bc <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ba:	eb 36                	jmp    8005f2 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	eb 1f                	jmp    8005f2 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005d3:	83 f9 01             	cmp    $0x1,%ecx
  8005d6:	7e 5b                	jle    800633 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 50 04             	mov    0x4(%eax),%edx
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e3:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005e6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005e9:	89 d1                	mov    %edx,%ecx
  8005eb:	89 c2                	mov    %eax,%edx
			base = 8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f2:	83 ec 0c             	sub    $0xc,%esp
  8005f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f9:	57                   	push   %edi
  8005fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fd:	50                   	push   %eax
  8005fe:	51                   	push   %ecx
  8005ff:	52                   	push   %edx
  800600:	89 da                	mov    %ebx,%edx
  800602:	89 f0                	mov    %esi,%eax
  800604:	e8 a3 fb ff ff       	call   8001ac <printnum>
			break;
  800609:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060f:	83 c7 01             	add    $0x1,%edi
  800612:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800616:	83 f8 25             	cmp    $0x25,%eax
  800619:	0f 84 8d fc ff ff    	je     8002ac <vprintfmt+0x17>
			if (ch == '\0')
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 84 e8 00 00 00    	je     80070f <vprintfmt+0x47a>
			putch(ch, putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	50                   	push   %eax
  80062c:	ff d6                	call   *%esi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb dc                	jmp    80060f <vprintfmt+0x37a>
	else if (lflag)
  800633:	85 c9                	test   %ecx,%ecx
  800635:	75 13                	jne    80064a <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	89 d0                	mov    %edx,%eax
  80063e:	99                   	cltd   
  80063f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800642:	8d 49 04             	lea    0x4(%ecx),%ecx
  800645:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800648:	eb 9f                	jmp    8005e9 <vprintfmt+0x354>
		return va_arg(*ap, long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	89 d0                	mov    %edx,%eax
  800651:	99                   	cltd   
  800652:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800655:	8d 49 04             	lea    0x4(%ecx),%ecx
  800658:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065b:	eb 8c                	jmp    8005e9 <vprintfmt+0x354>
			putch('0', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 30                	push   $0x30
  800663:	ff d6                	call   *%esi
			putch('x', putdat);
  800665:	83 c4 08             	add    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 78                	push   $0x78
  80066b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800677:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800680:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800685:	e9 68 ff ff ff       	jmp    8005f2 <vprintfmt+0x35d>
	if (lflag >= 2)
  80068a:	83 f9 01             	cmp    $0x1,%ecx
  80068d:	7e 18                	jle    8006a7 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8b 48 04             	mov    0x4(%eax),%ecx
  800697:	8d 40 08             	lea    0x8(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069d:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a2:	e9 4b ff ff ff       	jmp    8005f2 <vprintfmt+0x35d>
	else if (lflag)
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	75 1a                	jne    8006c5 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c0:	e9 2d ff ff ff       	jmp    8005f2 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006da:	e9 13 ff ff ff       	jmp    8005f2 <vprintfmt+0x35d>
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 25                	push   $0x25
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	e9 1d ff ff ff       	jmp    80060c <vprintfmt+0x377>
			putch('%', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 25                	push   $0x25
  8006f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	89 f8                	mov    %edi,%eax
  8006fc:	eb 03                	jmp    800701 <vprintfmt+0x46c>
  8006fe:	83 e8 01             	sub    $0x1,%eax
  800701:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800705:	75 f7                	jne    8006fe <vprintfmt+0x469>
  800707:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070a:	e9 fd fe ff ff       	jmp    80060c <vprintfmt+0x377>
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 5b 02 80 00       	push   $0x80025b
  80074b:	e8 45 fb ff ff       	call   800295 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800763:	eb f7                	jmp    80075c <vsnprintf+0x45>

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 d0                	cmp    %edx,%eax
  8007ac:	74 06                	je     8007b4 <strnlen+0x1d>
  8007ae:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c1 01             	add    $0x1,%ecx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9c ff ff ff       	call   80077f <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800833:	89 f0                	mov    %esi,%eax
  800835:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	75 0b                	jne    800848 <strlcpy+0x23>
  80083d:	eb 17                	jmp    800856 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800848:	39 d8                	cmp    %ebx,%eax
  80084a:	74 07                	je     800853 <strlcpy+0x2e>
  80084c:	0f b6 0a             	movzbl (%edx),%ecx
  80084f:	84 c9                	test   %cl,%cl
  800851:	75 ec                	jne    80083f <strlcpy+0x1a>
		*dst = '\0';
  800853:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800856:	29 f0                	sub    %esi,%eax
}
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800865:	eb 06                	jmp    80086d <strcmp+0x11>
		p++, q++;
  800867:	83 c1 01             	add    $0x1,%ecx
  80086a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80086d:	0f b6 01             	movzbl (%ecx),%eax
  800870:	84 c0                	test   %al,%al
  800872:	74 04                	je     800878 <strcmp+0x1c>
  800874:	3a 02                	cmp    (%edx),%al
  800876:	74 ef                	je     800867 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 c0             	movzbl %al,%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 c3                	mov    %eax,%ebx
  80088e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800891:	eb 06                	jmp    800899 <strncmp+0x17>
		n--, p++, q++;
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 16                	je     8008b3 <strncmp+0x31>
  80089d:	0f b6 08             	movzbl (%eax),%ecx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	74 04                	je     8008a8 <strncmp+0x26>
  8008a4:	3a 0a                	cmp    (%edx),%cl
  8008a6:	74 eb                	je     800893 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 00             	movzbl (%eax),%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    
		return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb f6                	jmp    8008b0 <strncmp+0x2e>

008008ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	0f b6 10             	movzbl (%eax),%edx
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	74 09                	je     8008d4 <strchr+0x1a>
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 0a                	je     8008d9 <strchr+0x1f>
	for (; *s; s++)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	eb f0                	jmp    8008c4 <strchr+0xa>
			return (char *) s;
	return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 03                	jmp    8008ea <strfind+0xf>
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ed:	38 ca                	cmp    %cl,%dl
  8008ef:	74 04                	je     8008f5 <strfind+0x1a>
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 13                	je     80091a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800907:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090d:	75 05                	jne    800914 <memset+0x1d>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	74 0d                	je     800921 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	fc                   	cld    
  800918:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    
		c &= 0xFF;
  800921:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800925:	89 d3                	mov    %edx,%ebx
  800927:	c1 e3 08             	shl    $0x8,%ebx
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 18             	shl    $0x18,%eax
  80092f:	89 d6                	mov    %edx,%esi
  800931:	c1 e6 10             	shl    $0x10,%esi
  800934:	09 f0                	or     %esi,%eax
  800936:	09 c2                	or     %eax,%edx
  800938:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80093a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	fc                   	cld    
  800940:	f3 ab                	rep stos %eax,%es:(%edi)
  800942:	eb d6                	jmp    80091a <memset+0x23>

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800952:	39 c6                	cmp    %eax,%esi
  800954:	73 35                	jae    80098b <memmove+0x47>
  800956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800959:	39 c2                	cmp    %eax,%edx
  80095b:	76 2e                	jbe    80098b <memmove+0x47>
		s += n;
		d += n;
  80095d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	89 d6                	mov    %edx,%esi
  800962:	09 fe                	or     %edi,%esi
  800964:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096a:	74 0c                	je     800978 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096c:	83 ef 01             	sub    $0x1,%edi
  80096f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800972:	fd                   	std    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800975:	fc                   	cld    
  800976:	eb 21                	jmp    800999 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 ef                	jne    80096c <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097d:	83 ef 04             	sub    $0x4,%edi
  800980:	8d 72 fc             	lea    -0x4(%edx),%esi
  800983:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800986:	fd                   	std    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb ea                	jmp    800975 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	89 f2                	mov    %esi,%edx
  80098d:	09 c2                	or     %eax,%edx
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	74 09                	je     80099d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800994:	89 c7                	mov    %eax,%edi
  800996:	fc                   	cld    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800999:	5e                   	pop    %esi
  80099a:	5f                   	pop    %edi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 f2                	jne    800994 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb ed                	jmp    800999 <memmove+0x55>

008009ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009af:	ff 75 10             	pushl  0x10(%ebp)
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	ff 75 08             	pushl  0x8(%ebp)
  8009b8:	e8 87 ff ff ff       	call   800944 <memmove>
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	89 c6                	mov    %eax,%esi
  8009cc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 f0                	cmp    %esi,%eax
  8009d1:	74 1c                	je     8009ef <memcmp+0x30>
		if (*s1 != *s2)
  8009d3:	0f b6 08             	movzbl (%eax),%ecx
  8009d6:	0f b6 1a             	movzbl (%edx),%ebx
  8009d9:	38 d9                	cmp    %bl,%cl
  8009db:	75 08                	jne    8009e5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dd:	83 c0 01             	add    $0x1,%eax
  8009e0:	83 c2 01             	add    $0x1,%edx
  8009e3:	eb ea                	jmp    8009cf <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e5:	0f b6 c1             	movzbl %cl,%eax
  8009e8:	0f b6 db             	movzbl %bl,%ebx
  8009eb:	29 d8                	sub    %ebx,%eax
  8009ed:	eb 05                	jmp    8009f4 <memcmp+0x35>
	}

	return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	73 09                	jae    800a13 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	38 08                	cmp    %cl,(%eax)
  800a0c:	74 05                	je     800a13 <memfind+0x1b>
	for (; s < ends; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	eb f3                	jmp    800a06 <memfind+0xe>
			break;
	return (void *) s;
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	eb 03                	jmp    800a26 <strtol+0x11>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f6                	je     800a23 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f2                	je     800a23 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	74 2e                	je     800a63 <strtol+0x4e>
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a3a:	3c 2d                	cmp    $0x2d,%al
  800a3c:	74 2f                	je     800a6d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a44:	75 05                	jne    800a4b <strtol+0x36>
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	74 2c                	je     800a77 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	75 0a                	jne    800a59 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a54:	80 39 30             	cmpb   $0x30,(%ecx)
  800a57:	74 28                	je     800a81 <strtol+0x6c>
		base = 10;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a61:	eb 50                	jmp    800ab3 <strtol+0x9e>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb d1                	jmp    800a3e <strtol+0x29>
		s++, neg = 1;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	bf 01 00 00 00       	mov    $0x1,%edi
  800a75:	eb c7                	jmp    800a3e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7b:	74 0e                	je     800a8b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	75 d8                	jne    800a59 <strtol+0x44>
		s++, base = 8;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a89:	eb ce                	jmp    800a59 <strtol+0x44>
		s += 2, base = 16;
  800a8b:	83 c1 02             	add    $0x2,%ecx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb c4                	jmp    800a59 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 29                	ja     800ac8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa8:	7d 30                	jge    800ada <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab3:	0f b6 11             	movzbl (%ecx),%edx
  800ab6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab9:	89 f3                	mov    %esi,%ebx
  800abb:	80 fb 09             	cmp    $0x9,%bl
  800abe:	77 d5                	ja     800a95 <strtol+0x80>
			dig = *s - '0';
  800ac0:	0f be d2             	movsbl %dl,%edx
  800ac3:	83 ea 30             	sub    $0x30,%edx
  800ac6:	eb dd                	jmp    800aa5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800acb:	89 f3                	mov    %esi,%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ad2:	0f be d2             	movsbl %dl,%edx
  800ad5:	83 ea 37             	sub    $0x37,%edx
  800ad8:	eb cb                	jmp    800aa5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ade:	74 05                	je     800ae5 <strtol+0xd0>
		*endptr = (char *) s;
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	89 cb                	mov    %ecx,%ebx
  800b48:	89 cf                	mov    %ecx,%edi
  800b4a:	89 ce                	mov    %ecx,%esi
  800b4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7f 08                	jg     800b5a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 03                	push   $0x3
  800b60:	68 e4 12 80 00       	push   $0x8012e4
  800b65:	6a 23                	push   $0x23
  800b67:	68 01 13 80 00       	push   $0x801301
  800b6c:	e8 54 02 00 00       	call   800dc5 <_panic>

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_yield>:

void
sys_yield(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb8:	be 00 00 00 00       	mov    $0x0,%esi
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	89 f7                	mov    %esi,%edi
  800bcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7f 08                	jg     800bdb <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800bdf:	6a 04                	push   $0x4
  800be1:	68 e4 12 80 00       	push   $0x8012e4
  800be6:	6a 23                	push   $0x23
  800be8:	68 01 13 80 00       	push   $0x801301
  800bed:	e8 d3 01 00 00       	call   800dc5 <_panic>

00800bf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	b8 05 00 00 00       	mov    $0x5,%eax
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 05                	push   $0x5
  800c23:	68 e4 12 80 00       	push   $0x8012e4
  800c28:	6a 23                	push   $0x23
  800c2a:	68 01 13 80 00       	push   $0x801301
  800c2f:	e8 91 01 00 00       	call   800dc5 <_panic>

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7f 08                	jg     800c5f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 06                	push   $0x6
  800c65:	68 e4 12 80 00       	push   $0x8012e4
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 01 13 80 00       	push   $0x801301
  800c71:	e8 4f 01 00 00       	call   800dc5 <_panic>

00800c76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7f 08                	jg     800ca1 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 08                	push   $0x8
  800ca7:	68 e4 12 80 00       	push   $0x8012e4
  800cac:	6a 23                	push   $0x23
  800cae:	68 01 13 80 00       	push   $0x801301
  800cb3:	e8 0d 01 00 00       	call   800dc5 <_panic>

00800cb8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7f 08                	jg     800ce3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800ce7:	6a 09                	push   $0x9
  800ce9:	68 e4 12 80 00       	push   $0x8012e4
  800cee:	6a 23                	push   $0x23
  800cf0:	68 01 13 80 00       	push   $0x801301
  800cf5:	e8 cb 00 00 00       	call   800dc5 <_panic>

00800cfa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d16:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d33:	89 cb                	mov    %ecx,%ebx
  800d35:	89 cf                	mov    %ecx,%edi
  800d37:	89 ce                	mov    %ecx,%esi
  800d39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7f 08                	jg     800d47 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0c                	push   $0xc
  800d4d:	68 e4 12 80 00       	push   $0x8012e4
  800d52:	6a 23                	push   $0x23
  800d54:	68 01 13 80 00       	push   $0x801301
  800d59:	e8 67 00 00 00       	call   800dc5 <_panic>

00800d5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d64:	68 0f 13 80 00       	push   $0x80130f
  800d69:	6a 1a                	push   $0x1a
  800d6b:	68 28 13 80 00       	push   $0x801328
  800d70:	e8 50 00 00 00       	call   800dc5 <_panic>

00800d75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d7b:	68 32 13 80 00       	push   $0x801332
  800d80:	6a 2a                	push   $0x2a
  800d82:	68 28 13 80 00       	push   $0x801328
  800d87:	e8 39 00 00 00       	call   800dc5 <_panic>

00800d8c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d97:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d9a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800da0:	8b 52 50             	mov    0x50(%edx),%edx
  800da3:	39 ca                	cmp    %ecx,%edx
  800da5:	74 11                	je     800db8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800da7:	83 c0 01             	add    $0x1,%eax
  800daa:	3d 00 04 00 00       	cmp    $0x400,%eax
  800daf:	75 e6                	jne    800d97 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	eb 0b                	jmp    800dc3 <ipc_find_env+0x37>
			return envs[i].env_id;
  800db8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dbb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800dc0:	8b 40 48             	mov    0x48(%eax),%eax
}
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dcd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dd3:	e8 99 fd ff ff       	call   800b71 <sys_getenvid>
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	ff 75 0c             	pushl  0xc(%ebp)
  800dde:	ff 75 08             	pushl  0x8(%ebp)
  800de1:	56                   	push   %esi
  800de2:	50                   	push   %eax
  800de3:	68 4c 13 80 00       	push   $0x80134c
  800de8:	e8 ab f3 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ded:	83 c4 18             	add    $0x18,%esp
  800df0:	53                   	push   %ebx
  800df1:	ff 75 10             	pushl  0x10(%ebp)
  800df4:	e8 4e f3 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  800df9:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800e00:	e8 93 f3 ff ff       	call   800198 <cprintf>
  800e05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e08:	cc                   	int3   
  800e09:	eb fd                	jmp    800e08 <_panic+0x43>
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e27:	85 d2                	test   %edx,%edx
  800e29:	75 35                	jne    800e60 <__udivdi3+0x50>
  800e2b:	39 f3                	cmp    %esi,%ebx
  800e2d:	0f 87 bd 00 00 00    	ja     800ef0 <__udivdi3+0xe0>
  800e33:	85 db                	test   %ebx,%ebx
  800e35:	89 d9                	mov    %ebx,%ecx
  800e37:	75 0b                	jne    800e44 <__udivdi3+0x34>
  800e39:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	f7 f3                	div    %ebx
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	31 d2                	xor    %edx,%edx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	f7 f1                	div    %ecx
  800e4a:	89 c6                	mov    %eax,%esi
  800e4c:	89 e8                	mov    %ebp,%eax
  800e4e:	89 f7                	mov    %esi,%edi
  800e50:	f7 f1                	div    %ecx
  800e52:	89 fa                	mov    %edi,%edx
  800e54:	83 c4 1c             	add    $0x1c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
  800e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 f2                	cmp    %esi,%edx
  800e62:	77 7c                	ja     800ee0 <__udivdi3+0xd0>
  800e64:	0f bd fa             	bsr    %edx,%edi
  800e67:	83 f7 1f             	xor    $0x1f,%edi
  800e6a:	0f 84 98 00 00 00    	je     800f08 <__udivdi3+0xf8>
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	d3 e6                	shl    %cl,%esi
  800ea1:	89 eb                	mov    %ebp,%ebx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 0c                	jb     800ec7 <__udivdi3+0xb7>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 5d                	jae    800f20 <__udivdi3+0x110>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	75 59                	jne    800f20 <__udivdi3+0x110>
  800ec7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eca:	31 ff                	xor    %edi,%edi
  800ecc:	89 fa                	mov    %edi,%edx
  800ece:	83 c4 1c             	add    $0x1c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
  800ed6:	8d 76 00             	lea    0x0(%esi),%esi
  800ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ee0:	31 ff                	xor    %edi,%edi
  800ee2:	31 c0                	xor    %eax,%eax
  800ee4:	89 fa                	mov    %edi,%edx
  800ee6:	83 c4 1c             	add    $0x1c,%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	31 ff                	xor    %edi,%edi
  800ef2:	89 e8                	mov    %ebp,%eax
  800ef4:	89 f2                	mov    %esi,%edx
  800ef6:	f7 f3                	div    %ebx
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	72 06                	jb     800f12 <__udivdi3+0x102>
  800f0c:	31 c0                	xor    %eax,%eax
  800f0e:	39 eb                	cmp    %ebp,%ebx
  800f10:	77 d2                	ja     800ee4 <__udivdi3+0xd4>
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb cb                	jmp    800ee4 <__udivdi3+0xd4>
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	31 ff                	xor    %edi,%edi
  800f24:	eb be                	jmp    800ee4 <__udivdi3+0xd4>
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 ed                	test   %ebp,%ebp
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	89 da                	mov    %ebx,%edx
  800f4d:	75 19                	jne    800f68 <__umoddi3+0x38>
  800f4f:	39 df                	cmp    %ebx,%edi
  800f51:	0f 86 b1 00 00 00    	jbe    801008 <__umoddi3+0xd8>
  800f57:	f7 f7                	div    %edi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 1c             	add    $0x1c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	39 dd                	cmp    %ebx,%ebp
  800f6a:	77 f1                	ja     800f5d <__umoddi3+0x2d>
  800f6c:	0f bd cd             	bsr    %ebp,%ecx
  800f6f:	83 f1 1f             	xor    $0x1f,%ecx
  800f72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f76:	0f 84 b4 00 00 00    	je     801030 <__umoddi3+0x100>
  800f7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f87:	29 c2                	sub    %eax,%edx
  800f89:	89 c1                	mov    %eax,%ecx
  800f8b:	89 f8                	mov    %edi,%eax
  800f8d:	d3 e5                	shl    %cl,%ebp
  800f8f:	89 d1                	mov    %edx,%ecx
  800f91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	09 c5                	or     %eax,%ebp
  800f99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	d3 e7                	shl    %cl,%edi
  800fa1:	89 d1                	mov    %edx,%ecx
  800fa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fa7:	89 df                	mov    %ebx,%edi
  800fa9:	d3 ef                	shr    %cl,%edi
  800fab:	89 c1                	mov    %eax,%ecx
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	d3 e3                	shl    %cl,%ebx
  800fb1:	89 d1                	mov    %edx,%ecx
  800fb3:	89 fa                	mov    %edi,%edx
  800fb5:	d3 e8                	shr    %cl,%eax
  800fb7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbc:	09 d8                	or     %ebx,%eax
  800fbe:	f7 f5                	div    %ebp
  800fc0:	d3 e6                	shl    %cl,%esi
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	f7 64 24 08          	mull   0x8(%esp)
  800fc8:	39 d1                	cmp    %edx,%ecx
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	89 d7                	mov    %edx,%edi
  800fce:	72 06                	jb     800fd6 <__umoddi3+0xa6>
  800fd0:	75 0e                	jne    800fe0 <__umoddi3+0xb0>
  800fd2:	39 c6                	cmp    %eax,%esi
  800fd4:	73 0a                	jae    800fe0 <__umoddi3+0xb0>
  800fd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fda:	19 ea                	sbb    %ebp,%edx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	89 ca                	mov    %ecx,%edx
  800fe2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fe7:	29 de                	sub    %ebx,%esi
  800fe9:	19 fa                	sbb    %edi,%edx
  800feb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fef:	89 d0                	mov    %edx,%eax
  800ff1:	d3 e0                	shl    %cl,%eax
  800ff3:	89 d9                	mov    %ebx,%ecx
  800ff5:	d3 ee                	shr    %cl,%esi
  800ff7:	d3 ea                	shr    %cl,%edx
  800ff9:	09 f0                	or     %esi,%eax
  800ffb:	83 c4 1c             	add    $0x1c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	85 ff                	test   %edi,%edi
  80100a:	89 f9                	mov    %edi,%ecx
  80100c:	75 0b                	jne    801019 <__umoddi3+0xe9>
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f7                	div    %edi
  801017:	89 c1                	mov    %eax,%ecx
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f1                	div    %ecx
  80101f:	89 f0                	mov    %esi,%eax
  801021:	f7 f1                	div    %ecx
  801023:	e9 31 ff ff ff       	jmp    800f59 <__umoddi3+0x29>
  801028:	90                   	nop
  801029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801030:	39 dd                	cmp    %ebx,%ebp
  801032:	72 08                	jb     80103c <__umoddi3+0x10c>
  801034:	39 f7                	cmp    %esi,%edi
  801036:	0f 87 21 ff ff ff    	ja     800f5d <__umoddi3+0x2d>
  80103c:	89 da                	mov    %ebx,%edx
  80103e:	89 f0                	mov    %esi,%eax
  801040:	29 f8                	sub    %edi,%eax
  801042:	19 ea                	sbb    %ebp,%edx
  801044:	e9 14 ff ff ff       	jmp    800f5d <__umoddi3+0x2d>
