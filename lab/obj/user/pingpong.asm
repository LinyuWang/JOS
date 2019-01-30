
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 3c 0d 00 00       	call   800d7d <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 53 0d 00 00       	call   800dab <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 2e 0b 00 00       	call   800b90 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 b6 10 80 00       	push   $0x8010b6
  80006a:	e8 48 01 00 00       	call   8001b7 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 3b 0d 00 00       	call   800dc2 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 f2 0a 00 00       	call   800b90 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 a0 10 80 00       	push   $0x8010a0
  8000a8:	e8 0a 01 00 00       	call   8001b7 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 07 0d 00 00       	call   800dc2 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000cb:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d2:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000d5:	e8 b6 0a 00 00       	call   800b90 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x37>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 32 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 32 0a 00 00       	call   800b4f <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	53                   	push   %ebx
  800126:	83 ec 04             	sub    $0x4,%esp
  800129:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012c:	8b 13                	mov    (%ebx),%edx
  80012e:	8d 42 01             	lea    0x1(%edx),%eax
  800131:	89 03                	mov    %eax,(%ebx)
  800133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800136:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013f:	74 09                	je     80014a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800141:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800148:	c9                   	leave  
  800149:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	68 ff 00 00 00       	push   $0xff
  800152:	8d 43 08             	lea    0x8(%ebx),%eax
  800155:	50                   	push   %eax
  800156:	e8 b7 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  80015b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	eb db                	jmp    800141 <putch+0x1f>

00800166 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800176:	00 00 00 
	b.cnt = 0;
  800179:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800180:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800183:	ff 75 0c             	pushl  0xc(%ebp)
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018f:	50                   	push   %eax
  800190:	68 22 01 80 00       	push   $0x800122
  800195:	e8 1a 01 00 00       	call   8002b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019a:	83 c4 08             	add    $0x8,%esp
  80019d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a9:	50                   	push   %eax
  8001aa:	e8 63 09 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  8001af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c0:	50                   	push   %eax
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	e8 9d ff ff ff       	call   800166 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 1c             	sub    $0x1c,%esp
  8001d4:	89 c7                	mov    %eax,%edi
  8001d6:	89 d6                	mov    %edx,%esi
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f2:	39 d3                	cmp    %edx,%ebx
  8001f4:	72 05                	jb     8001fb <printnum+0x30>
  8001f6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f9:	77 7a                	ja     800275 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	8b 45 14             	mov    0x14(%ebp),%eax
  800204:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800207:	53                   	push   %ebx
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800211:	ff 75 e0             	pushl  -0x20(%ebp)
  800214:	ff 75 dc             	pushl  -0x24(%ebp)
  800217:	ff 75 d8             	pushl  -0x28(%ebp)
  80021a:	e8 41 0c 00 00       	call   800e60 <__udivdi3>
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	89 f2                	mov    %esi,%edx
  800226:	89 f8                	mov    %edi,%eax
  800228:	e8 9e ff ff ff       	call   8001cb <printnum>
  80022d:	83 c4 20             	add    $0x20,%esp
  800230:	eb 13                	jmp    800245 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800232:	83 ec 08             	sub    $0x8,%esp
  800235:	56                   	push   %esi
  800236:	ff 75 18             	pushl  0x18(%ebp)
  800239:	ff d7                	call   *%edi
  80023b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f ed                	jg     800232 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	56                   	push   %esi
  800249:	83 ec 04             	sub    $0x4,%esp
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 23 0d 00 00       	call   800f80 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 d3 10 80 00 	movsbl 0x8010d3(%eax),%eax
  800267:	50                   	push   %eax
  800268:	ff d7                	call   *%edi
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    
  800275:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800278:	eb c4                	jmp    80023e <printnum+0x73>

0080027a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800280:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800284:	8b 10                	mov    (%eax),%edx
  800286:	3b 50 04             	cmp    0x4(%eax),%edx
  800289:	73 0a                	jae    800295 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	88 02                	mov    %al,(%edx)
}
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <printfmt>:
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a0:	50                   	push   %eax
  8002a1:	ff 75 10             	pushl  0x10(%ebp)
  8002a4:	ff 75 0c             	pushl  0xc(%ebp)
  8002a7:	ff 75 08             	pushl  0x8(%ebp)
  8002aa:	e8 05 00 00 00       	call   8002b4 <vprintfmt>
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vprintfmt>:
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 2c             	sub    $0x2c,%esp
  8002bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c6:	e9 63 03 00 00       	jmp    80062e <vprintfmt+0x37a>
		padc = ' ';
  8002cb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002cf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ef:	0f b6 17             	movzbl (%edi),%edx
  8002f2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 11 04 00 00    	ja     80070e <vprintfmt+0x45a>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030e:	eb d9                	jmp    8002e9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800313:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800317:	eb d0                	jmp    8002e9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800319:	0f b6 d2             	movzbl %dl,%edx
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031f:	b8 00 00 00 00       	mov    $0x0,%eax
  800324:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800327:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800331:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800334:	83 f9 09             	cmp    $0x9,%ecx
  800337:	77 55                	ja     80038e <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800339:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033c:	eb e9                	jmp    800327 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8b 00                	mov    (%eax),%eax
  800343:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 40 04             	lea    0x4(%eax),%eax
  80034c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800356:	79 91                	jns    8002e9 <vprintfmt+0x35>
				width = precision, precision = -1;
  800358:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800365:	eb 82                	jmp    8002e9 <vprintfmt+0x35>
  800367:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036a:	85 c0                	test   %eax,%eax
  80036c:	ba 00 00 00 00       	mov    $0x0,%edx
  800371:	0f 49 d0             	cmovns %eax,%edx
  800374:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037a:	e9 6a ff ff ff       	jmp    8002e9 <vprintfmt+0x35>
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800382:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800389:	e9 5b ff ff ff       	jmp    8002e9 <vprintfmt+0x35>
  80038e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800391:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800394:	eb bc                	jmp    800352 <vprintfmt+0x9e>
			lflag++;
  800396:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039c:	e9 48 ff ff ff       	jmp    8002e9 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 78 04             	lea    0x4(%eax),%edi
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	53                   	push   %ebx
  8003ab:	ff 30                	pushl  (%eax)
  8003ad:	ff d6                	call   *%esi
			break;
  8003af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b5:	e9 71 02 00 00       	jmp    80062b <vprintfmt+0x377>
			err = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	99                   	cltd   
  8003c3:	31 d0                	xor    %edx,%eax
  8003c5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c7:	83 f8 08             	cmp    $0x8,%eax
  8003ca:	7f 23                	jg     8003ef <vprintfmt+0x13b>
  8003cc:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  8003d3:	85 d2                	test   %edx,%edx
  8003d5:	74 18                	je     8003ef <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	68 f4 10 80 00       	push   $0x8010f4
  8003dd:	53                   	push   %ebx
  8003de:	56                   	push   %esi
  8003df:	e8 b3 fe ff ff       	call   800297 <printfmt>
  8003e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ea:	e9 3c 02 00 00       	jmp    80062b <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 eb 10 80 00       	push   $0x8010eb
  8003f5:	53                   	push   %ebx
  8003f6:	56                   	push   %esi
  8003f7:	e8 9b fe ff ff       	call   800297 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ff:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800402:	e9 24 02 00 00       	jmp    80062b <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	83 c0 04             	add    $0x4,%eax
  80040d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800415:	85 ff                	test   %edi,%edi
  800417:	b8 e4 10 80 00       	mov    $0x8010e4,%eax
  80041c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800423:	0f 8e bd 00 00 00    	jle    8004e6 <vprintfmt+0x232>
  800429:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042d:	75 0e                	jne    80043d <vprintfmt+0x189>
  80042f:	89 75 08             	mov    %esi,0x8(%ebp)
  800432:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800435:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800438:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80043b:	eb 6d                	jmp    8004aa <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	ff 75 d0             	pushl  -0x30(%ebp)
  800443:	57                   	push   %edi
  800444:	e8 6d 03 00 00       	call   8007b6 <strnlen>
  800449:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800454:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045e:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	eb 0f                	jmp    800471 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 ff                	test   %edi,%edi
  800473:	7f ed                	jg     800462 <vprintfmt+0x1ae>
  800475:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800478:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80047b:	85 c9                	test   %ecx,%ecx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c1             	cmovns %ecx,%eax
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	89 cb                	mov    %ecx,%ebx
  800492:	eb 16                	jmp    8004aa <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800494:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800498:	75 31                	jne    8004cb <vprintfmt+0x217>
					putch(ch, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	50                   	push   %eax
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a7:	83 eb 01             	sub    $0x1,%ebx
  8004aa:	83 c7 01             	add    $0x1,%edi
  8004ad:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b1:	0f be c2             	movsbl %dl,%eax
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	74 59                	je     800511 <vprintfmt+0x25d>
  8004b8:	85 f6                	test   %esi,%esi
  8004ba:	78 d8                	js     800494 <vprintfmt+0x1e0>
  8004bc:	83 ee 01             	sub    $0x1,%esi
  8004bf:	79 d3                	jns    800494 <vprintfmt+0x1e0>
  8004c1:	89 df                	mov    %ebx,%edi
  8004c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c9:	eb 37                	jmp    800502 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cb:	0f be d2             	movsbl %dl,%edx
  8004ce:	83 ea 20             	sub    $0x20,%edx
  8004d1:	83 fa 5e             	cmp    $0x5e,%edx
  8004d4:	76 c4                	jbe    80049a <vprintfmt+0x1e6>
					putch('?', putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	6a 3f                	push   $0x3f
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb c1                	jmp    8004a7 <vprintfmt+0x1f3>
  8004e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f2:	eb b6                	jmp    8004aa <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	6a 20                	push   $0x20
  8004fa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fc:	83 ef 01             	sub    $0x1,%edi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 ff                	test   %edi,%edi
  800504:	7f ee                	jg     8004f4 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800509:	89 45 14             	mov    %eax,0x14(%ebp)
  80050c:	e9 1a 01 00 00       	jmp    80062b <vprintfmt+0x377>
  800511:	89 df                	mov    %ebx,%edi
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	eb e7                	jmp    800502 <vprintfmt+0x24e>
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7e 3f                	jle    80055f <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 50 04             	mov    0x4(%eax),%edx
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 08             	lea    0x8(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800537:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053b:	79 5c                	jns    800599 <vprintfmt+0x2e5>
				putch('-', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 2d                	push   $0x2d
  800543:	ff d6                	call   *%esi
				num = -(long long) num;
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054b:	f7 da                	neg    %edx
  80054d:	83 d1 00             	adc    $0x0,%ecx
  800550:	f7 d9                	neg    %ecx
  800552:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	e9 b2 00 00 00       	jmp    800611 <vprintfmt+0x35d>
	else if (lflag)
  80055f:	85 c9                	test   %ecx,%ecx
  800561:	75 1b                	jne    80057e <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	eb b9                	jmp    800537 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 c1                	mov    %eax,%ecx
  800588:	c1 f9 1f             	sar    $0x1f,%ecx
  80058b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 40 04             	lea    0x4(%eax),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)
  800597:	eb 9e                	jmp    800537 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800599:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a4:	eb 6b                	jmp    800611 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005a6:	83 f9 01             	cmp    $0x1,%ecx
  8005a9:	7e 15                	jle    8005c0 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 10                	mov    (%eax),%edx
  8005b0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b3:	8d 40 08             	lea    0x8(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	eb 51                	jmp    800611 <vprintfmt+0x35d>
	else if (lflag)
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	75 17                	jne    8005db <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 10                	mov    (%eax),%edx
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	8d 40 04             	lea    0x4(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d9:	eb 36                	jmp    800611 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f0:	eb 1f                	jmp    800611 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005f2:	83 f9 01             	cmp    $0x1,%ecx
  8005f5:	7e 5b                	jle    800652 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800602:	8d 49 08             	lea    0x8(%ecx),%ecx
  800605:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800608:	89 d1                	mov    %edx,%ecx
  80060a:	89 c2                	mov    %eax,%edx
			base = 8;
  80060c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800618:	57                   	push   %edi
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	50                   	push   %eax
  80061d:	51                   	push   %ecx
  80061e:	52                   	push   %edx
  80061f:	89 da                	mov    %ebx,%edx
  800621:	89 f0                	mov    %esi,%eax
  800623:	e8 a3 fb ff ff       	call   8001cb <printnum>
			break;
  800628:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80062e:	83 c7 01             	add    $0x1,%edi
  800631:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800635:	83 f8 25             	cmp    $0x25,%eax
  800638:	0f 84 8d fc ff ff    	je     8002cb <vprintfmt+0x17>
			if (ch == '\0')
  80063e:	85 c0                	test   %eax,%eax
  800640:	0f 84 e8 00 00 00    	je     80072e <vprintfmt+0x47a>
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	50                   	push   %eax
  80064b:	ff d6                	call   *%esi
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	eb dc                	jmp    80062e <vprintfmt+0x37a>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	75 13                	jne    800669 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	89 d0                	mov    %edx,%eax
  80065d:	99                   	cltd   
  80065e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800661:	8d 49 04             	lea    0x4(%ecx),%ecx
  800664:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800667:	eb 9f                	jmp    800608 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	89 d0                	mov    %edx,%eax
  800670:	99                   	cltd   
  800671:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800674:	8d 49 04             	lea    0x4(%ecx),%ecx
  800677:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80067a:	eb 8c                	jmp    800608 <vprintfmt+0x354>
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800696:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a4:	e9 68 ff ff ff       	jmp    800611 <vprintfmt+0x35d>
	if (lflag >= 2)
  8006a9:	83 f9 01             	cmp    $0x1,%ecx
  8006ac:	7e 18                	jle    8006c6 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b6:	8d 40 08             	lea    0x8(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c1:	e9 4b ff ff ff       	jmp    800611 <vprintfmt+0x35d>
	else if (lflag)
  8006c6:	85 c9                	test   %ecx,%ecx
  8006c8:	75 1a                	jne    8006e4 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
  8006df:	e9 2d ff ff ff       	jmp    800611 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f9:	e9 13 ff ff ff       	jmp    800611 <vprintfmt+0x35d>
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 25                	push   $0x25
  800704:	ff d6                	call   *%esi
			break;
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	e9 1d ff ff ff       	jmp    80062b <vprintfmt+0x377>
			putch('%', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 25                	push   $0x25
  800714:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	89 f8                	mov    %edi,%eax
  80071b:	eb 03                	jmp    800720 <vprintfmt+0x46c>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800724:	75 f7                	jne    80071d <vprintfmt+0x469>
  800726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800729:	e9 fd fe ff ff       	jmp    80062b <vprintfmt+0x377>
}
  80072e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 18             	sub    $0x18,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 26                	je     80077d <vsnprintf+0x47>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 22                	jle    80077d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	pushl  0x14(%ebp)
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	68 7a 02 80 00       	push   $0x80027a
  80076a:	e8 45 fb ff ff       	call   8002b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	83 c4 10             	add    $0x10,%esp
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb f7                	jmp    80077b <vsnprintf+0x45>

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 9a ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 03                	jmp    8007ae <strlen+0x10>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f7                	jne    8007ab <strlen+0xd>
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strnlen+0x13>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	39 d0                	cmp    %edx,%eax
  8007cb:	74 06                	je     8007d3 <strnlen+0x1d>
  8007cd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d1:	75 f3                	jne    8007c6 <strnlen+0x10>
	return n;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ee:	84 db                	test   %bl,%bl
  8007f0:	75 ef                	jne    8007e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	53                   	push   %ebx
  8007fd:	e8 9c ff ff ff       	call   80079e <strlen>
  800802:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	01 d8                	add    %ebx,%eax
  80080a:	50                   	push   %eax
  80080b:	e8 c5 ff ff ff       	call   8007d5 <strcpy>
	return dst;
}
  800810:	89 d8                	mov    %ebx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	89 f3                	mov    %esi,%ebx
  800824:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800827:	89 f2                	mov    %esi,%edx
  800829:	eb 0f                	jmp    80083a <strncpy+0x23>
		*dst++ = *src;
  80082b:	83 c2 01             	add    $0x1,%edx
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800834:	80 39 01             	cmpb   $0x1,(%ecx)
  800837:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80083a:	39 da                	cmp    %ebx,%edx
  80083c:	75 ed                	jne    80082b <strncpy+0x14>
	}
	return ret;
}
  80083e:	89 f0                	mov    %esi,%eax
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800852:	89 f0                	mov    %esi,%eax
  800854:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	75 0b                	jne    800867 <strlcpy+0x23>
  80085c:	eb 17                	jmp    800875 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 07                	je     800872 <strlcpy+0x2e>
  80086b:	0f b6 0a             	movzbl (%edx),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	75 ec                	jne    80085e <strlcpy+0x1a>
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 16                	je     8008d2 <strncmp+0x31>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb f6                	jmp    8008cf <strncmp+0x2e>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e3:	0f b6 10             	movzbl (%eax),%edx
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 09                	je     8008f3 <strchr+0x1a>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 0a                	je     8008f8 <strchr+0x1f>
	for (; *s; s++)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	eb f0                	jmp    8008e3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 03                	jmp    800909 <strfind+0xf>
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 04                	je     800914 <strfind+0x1a>
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strfind+0xc>
			break;
	return (char *) s;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800922:	85 c9                	test   %ecx,%ecx
  800924:	74 13                	je     800939 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800926:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092c:	75 05                	jne    800933 <memset+0x1d>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	74 0d                	je     800940 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    
		c &= 0xFF;
  800940:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	89 d3                	mov    %edx,%ebx
  800946:	c1 e3 08             	shl    $0x8,%ebx
  800949:	89 d0                	mov    %edx,%eax
  80094b:	c1 e0 18             	shl    $0x18,%eax
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 10             	shl    $0x10,%esi
  800953:	09 f0                	or     %esi,%eax
  800955:	09 c2                	or     %eax,%edx
  800957:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800959:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	fc                   	cld    
  80095f:	f3 ab                	rep stos %eax,%es:(%edi)
  800961:	eb d6                	jmp    800939 <memset+0x23>

00800963 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 35                	jae    8009aa <memmove+0x47>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	76 2e                	jbe    8009aa <memmove+0x47>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 d6                	mov    %edx,%esi
  800981:	09 fe                	or     %edi,%esi
  800983:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800989:	74 0c                	je     800997 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 21                	jmp    8009b8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 ef                	jne    80098b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099c:	83 ef 04             	sub    $0x4,%edi
  80099f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb ea                	jmp    800994 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 f2                	mov    %esi,%edx
  8009ac:	09 c2                	or     %eax,%edx
  8009ae:	f6 c2 03             	test   $0x3,%dl
  8009b1:	74 09                	je     8009bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 f2                	jne    8009b3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb ed                	jmp    8009b8 <memmove+0x55>

008009cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 87 ff ff ff       	call   800963 <memmove>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e9:	89 c6                	mov    %eax,%esi
  8009eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	74 1c                	je     800a0e <memcmp+0x30>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	75 08                	jne    800a04 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	eb ea                	jmp    8009ee <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a04:	0f b6 c1             	movzbl %cl,%eax
  800a07:	0f b6 db             	movzbl %bl,%ebx
  800a0a:	29 d8                	sub    %ebx,%eax
  800a0c:	eb 05                	jmp    800a13 <memcmp+0x35>
	}

	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 09                	jae    800a32 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x1b>
	for (; s < ends; s++)
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	eb f3                	jmp    800a25 <memfind+0xe>
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 03                	jmp    800a45 <strtol+0x11>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a45:	0f b6 01             	movzbl (%ecx),%eax
  800a48:	3c 20                	cmp    $0x20,%al
  800a4a:	74 f6                	je     800a42 <strtol+0xe>
  800a4c:	3c 09                	cmp    $0x9,%al
  800a4e:	74 f2                	je     800a42 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a50:	3c 2b                	cmp    $0x2b,%al
  800a52:	74 2e                	je     800a82 <strtol+0x4e>
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	74 2f                	je     800a8c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 05                	jne    800a6a <strtol+0x36>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	74 2c                	je     800a96 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 0a                	jne    800a78 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	74 28                	je     800aa0 <strtol+0x6c>
		base = 10;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a80:	eb 50                	jmp    800ad2 <strtol+0x9e>
		s++;
  800a82:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8a:	eb d1                	jmp    800a5d <strtol+0x29>
		s++, neg = 1;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a94:	eb c7                	jmp    800a5d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	74 0e                	je     800aaa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 d8                	jne    800a78 <strtol+0x44>
		s++, base = 8;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa8:	eb ce                	jmp    800a78 <strtol+0x44>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb c4                	jmp    800a78 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 29                	ja     800ae7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 30                	jge    800af9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 d5                	ja     800ab4 <strtol+0x80>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb dd                	jmp    800ac4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 37             	sub    $0x37,%edx
  800af7:	eb cb                	jmp    800ac4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 05                	je     800b04 <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	85 ff                	test   %edi,%edi
  800b0a:	0f 45 c2             	cmovne %edx,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	89 c3                	mov    %eax,%ebx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 c6                	mov    %eax,%esi
  800b29:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7f 08                	jg     800b79 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 24 13 80 00       	push   $0x801324
  800b84:	6a 23                	push   $0x23
  800b86:	68 41 13 80 00       	push   $0x801341
  800b8b:	e8 82 02 00 00       	call   800e12 <_panic>

00800b90 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_yield>:

void
sys_yield(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd7:	be 00 00 00 00       	mov    $0x0,%esi
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	b8 04 00 00 00       	mov    $0x4,%eax
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	89 f7                	mov    %esi,%edi
  800bec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7f 08                	jg     800bfa <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 24 13 80 00       	push   $0x801324
  800c05:	6a 23                	push   $0x23
  800c07:	68 41 13 80 00       	push   $0x801341
  800c0c:	e8 01 02 00 00       	call   800e12 <_panic>

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	b8 05 00 00 00       	mov    $0x5,%eax
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 24 13 80 00       	push   $0x801324
  800c47:	6a 23                	push   $0x23
  800c49:	68 41 13 80 00       	push   $0x801341
  800c4e:	e8 bf 01 00 00       	call   800e12 <_panic>

00800c53 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 24 13 80 00       	push   $0x801324
  800c89:	6a 23                	push   $0x23
  800c8b:	68 41 13 80 00       	push   $0x801341
  800c90:	e8 7d 01 00 00       	call   800e12 <_panic>

00800c95 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 24 13 80 00       	push   $0x801324
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 41 13 80 00       	push   $0x801341
  800cd2:	e8 3b 01 00 00       	call   800e12 <_panic>

00800cd7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 24 13 80 00       	push   $0x801324
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 41 13 80 00       	push   $0x801341
  800d14:	e8 f9 00 00 00       	call   800e12 <_panic>

00800d19 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d35:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d52:	89 cb                	mov    %ecx,%ebx
  800d54:	89 cf                	mov    %ecx,%edi
  800d56:	89 ce                	mov    %ecx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0c                	push   $0xc
  800d6c:	68 24 13 80 00       	push   $0x801324
  800d71:	6a 23                	push   $0x23
  800d73:	68 41 13 80 00       	push   $0x801341
  800d78:	e8 95 00 00 00       	call   800e12 <_panic>

00800d7d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d83:	68 5b 13 80 00       	push   $0x80135b
  800d88:	6a 51                	push   $0x51
  800d8a:	68 4f 13 80 00       	push   $0x80134f
  800d8f:	e8 7e 00 00 00       	call   800e12 <_panic>

00800d94 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d9a:	68 5a 13 80 00       	push   $0x80135a
  800d9f:	6a 58                	push   $0x58
  800da1:	68 4f 13 80 00       	push   $0x80134f
  800da6:	e8 67 00 00 00       	call   800e12 <_panic>

00800dab <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800db1:	68 70 13 80 00       	push   $0x801370
  800db6:	6a 1a                	push   $0x1a
  800db8:	68 89 13 80 00       	push   $0x801389
  800dbd:	e8 50 00 00 00       	call   800e12 <_panic>

00800dc2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800dc8:	68 93 13 80 00       	push   $0x801393
  800dcd:	6a 2a                	push   $0x2a
  800dcf:	68 89 13 80 00       	push   $0x801389
  800dd4:	e8 39 00 00 00       	call   800e12 <_panic>

00800dd9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800de4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800de7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ded:	8b 52 50             	mov    0x50(%edx),%edx
  800df0:	39 ca                	cmp    %ecx,%edx
  800df2:	74 11                	je     800e05 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800df4:	83 c0 01             	add    $0x1,%eax
  800df7:	3d 00 04 00 00       	cmp    $0x400,%eax
  800dfc:	75 e6                	jne    800de4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800e03:	eb 0b                	jmp    800e10 <ipc_find_env+0x37>
			return envs[i].env_id;
  800e05:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e08:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e0d:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e17:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e1a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e20:	e8 6b fd ff ff       	call   800b90 <sys_getenvid>
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	ff 75 0c             	pushl  0xc(%ebp)
  800e2b:	ff 75 08             	pushl  0x8(%ebp)
  800e2e:	56                   	push   %esi
  800e2f:	50                   	push   %eax
  800e30:	68 ac 13 80 00       	push   $0x8013ac
  800e35:	e8 7d f3 ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e3a:	83 c4 18             	add    $0x18,%esp
  800e3d:	53                   	push   %ebx
  800e3e:	ff 75 10             	pushl  0x10(%ebp)
  800e41:	e8 20 f3 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  800e46:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800e4d:	e8 65 f3 ff ff       	call   8001b7 <cprintf>
  800e52:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e55:	cc                   	int3   
  800e56:	eb fd                	jmp    800e55 <_panic+0x43>
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__udivdi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e77:	85 d2                	test   %edx,%edx
  800e79:	75 35                	jne    800eb0 <__udivdi3+0x50>
  800e7b:	39 f3                	cmp    %esi,%ebx
  800e7d:	0f 87 bd 00 00 00    	ja     800f40 <__udivdi3+0xe0>
  800e83:	85 db                	test   %ebx,%ebx
  800e85:	89 d9                	mov    %ebx,%ecx
  800e87:	75 0b                	jne    800e94 <__udivdi3+0x34>
  800e89:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f3                	div    %ebx
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	31 d2                	xor    %edx,%edx
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	f7 f1                	div    %ecx
  800e9a:	89 c6                	mov    %eax,%esi
  800e9c:	89 e8                	mov    %ebp,%eax
  800e9e:	89 f7                	mov    %esi,%edi
  800ea0:	f7 f1                	div    %ecx
  800ea2:	89 fa                	mov    %edi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 f2                	cmp    %esi,%edx
  800eb2:	77 7c                	ja     800f30 <__udivdi3+0xd0>
  800eb4:	0f bd fa             	bsr    %edx,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0xf8>
  800ec0:	89 f9                	mov    %edi,%ecx
  800ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec7:	29 f8                	sub    %edi,%eax
  800ec9:	d3 e2                	shl    %cl,%edx
  800ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	89 da                	mov    %ebx,%edx
  800ed3:	d3 ea                	shr    %cl,%edx
  800ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ed9:	09 d1                	or     %edx,%ecx
  800edb:	89 f2                	mov    %esi,%edx
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	d3 e3                	shl    %cl,%ebx
  800ee5:	89 c1                	mov    %eax,%ecx
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	89 f9                	mov    %edi,%ecx
  800eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eef:	d3 e6                	shl    %cl,%esi
  800ef1:	89 eb                	mov    %ebp,%ebx
  800ef3:	89 c1                	mov    %eax,%ecx
  800ef5:	d3 eb                	shr    %cl,%ebx
  800ef7:	09 de                	or     %ebx,%esi
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	f7 74 24 08          	divl   0x8(%esp)
  800eff:	89 d6                	mov    %edx,%esi
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	f7 64 24 0c          	mull   0xc(%esp)
  800f07:	39 d6                	cmp    %edx,%esi
  800f09:	72 0c                	jb     800f17 <__udivdi3+0xb7>
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 e5                	shl    %cl,%ebp
  800f0f:	39 c5                	cmp    %eax,%ebp
  800f11:	73 5d                	jae    800f70 <__udivdi3+0x110>
  800f13:	39 d6                	cmp    %edx,%esi
  800f15:	75 59                	jne    800f70 <__udivdi3+0x110>
  800f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f1a:	31 ff                	xor    %edi,%edi
  800f1c:	89 fa                	mov    %edi,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d 76 00             	lea    0x0(%esi),%esi
  800f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	31 c0                	xor    %eax,%eax
  800f34:	89 fa                	mov    %edi,%edx
  800f36:	83 c4 1c             	add    $0x1c,%esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    
  800f3e:	66 90                	xchg   %ax,%ax
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	89 e8                	mov    %ebp,%eax
  800f44:	89 f2                	mov    %esi,%edx
  800f46:	f7 f3                	div    %ebx
  800f48:	89 fa                	mov    %edi,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	72 06                	jb     800f62 <__udivdi3+0x102>
  800f5c:	31 c0                	xor    %eax,%eax
  800f5e:	39 eb                	cmp    %ebp,%ebx
  800f60:	77 d2                	ja     800f34 <__udivdi3+0xd4>
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb cb                	jmp    800f34 <__udivdi3+0xd4>
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	31 ff                	xor    %edi,%edi
  800f74:	eb be                	jmp    800f34 <__udivdi3+0xd4>
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 ed                	test   %ebp,%ebp
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	89 da                	mov    %ebx,%edx
  800f9d:	75 19                	jne    800fb8 <__umoddi3+0x38>
  800f9f:	39 df                	cmp    %ebx,%edi
  800fa1:	0f 86 b1 00 00 00    	jbe    801058 <__umoddi3+0xd8>
  800fa7:	f7 f7                	div    %edi
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	39 dd                	cmp    %ebx,%ebp
  800fba:	77 f1                	ja     800fad <__umoddi3+0x2d>
  800fbc:	0f bd cd             	bsr    %ebp,%ecx
  800fbf:	83 f1 1f             	xor    $0x1f,%ecx
  800fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc6:	0f 84 b4 00 00 00    	je     801080 <__umoddi3+0x100>
  800fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fd7:	29 c2                	sub    %eax,%edx
  800fd9:	89 c1                	mov    %eax,%ecx
  800fdb:	89 f8                	mov    %edi,%eax
  800fdd:	d3 e5                	shl    %cl,%ebp
  800fdf:	89 d1                	mov    %edx,%ecx
  800fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe5:	d3 e8                	shr    %cl,%eax
  800fe7:	09 c5                	or     %eax,%ebp
  800fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	d3 e7                	shl    %cl,%edi
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff7:	89 df                	mov    %ebx,%edi
  800ff9:	d3 ef                	shr    %cl,%edi
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	89 f0                	mov    %esi,%eax
  800fff:	d3 e3                	shl    %cl,%ebx
  801001:	89 d1                	mov    %edx,%ecx
  801003:	89 fa                	mov    %edi,%edx
  801005:	d3 e8                	shr    %cl,%eax
  801007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	f7 f5                	div    %ebp
  801010:	d3 e6                	shl    %cl,%esi
  801012:	89 d1                	mov    %edx,%ecx
  801014:	f7 64 24 08          	mull   0x8(%esp)
  801018:	39 d1                	cmp    %edx,%ecx
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	72 06                	jb     801026 <__umoddi3+0xa6>
  801020:	75 0e                	jne    801030 <__umoddi3+0xb0>
  801022:	39 c6                	cmp    %eax,%esi
  801024:	73 0a                	jae    801030 <__umoddi3+0xb0>
  801026:	2b 44 24 08          	sub    0x8(%esp),%eax
  80102a:	19 ea                	sbb    %ebp,%edx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	89 c3                	mov    %eax,%ebx
  801030:	89 ca                	mov    %ecx,%edx
  801032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801037:	29 de                	sub    %ebx,%esi
  801039:	19 fa                	sbb    %edi,%edx
  80103b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80103f:	89 d0                	mov    %edx,%eax
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 d9                	mov    %ebx,%ecx
  801045:	d3 ee                	shr    %cl,%esi
  801047:	d3 ea                	shr    %cl,%edx
  801049:	09 f0                	or     %esi,%eax
  80104b:	83 c4 1c             	add    $0x1c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
  801053:	90                   	nop
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	85 ff                	test   %edi,%edi
  80105a:	89 f9                	mov    %edi,%ecx
  80105c:	75 0b                	jne    801069 <__umoddi3+0xe9>
  80105e:	b8 01 00 00 00       	mov    $0x1,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f7                	div    %edi
  801067:	89 c1                	mov    %eax,%ecx
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f1                	div    %ecx
  80106f:	89 f0                	mov    %esi,%eax
  801071:	f7 f1                	div    %ecx
  801073:	e9 31 ff ff ff       	jmp    800fa9 <__umoddi3+0x29>
  801078:	90                   	nop
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	39 dd                	cmp    %ebx,%ebp
  801082:	72 08                	jb     80108c <__umoddi3+0x10c>
  801084:	39 f7                	cmp    %esi,%edi
  801086:	0f 87 21 ff ff ff    	ja     800fad <__umoddi3+0x2d>
  80108c:	89 da                	mov    %ebx,%edx
  80108e:	89 f0                	mov    %esi,%eax
  801090:	29 f8                	sub    %edi,%eax
  801092:	19 ea                	sbb    %ebp,%edx
  801094:	e9 14 ff ff ff       	jmp    800fad <__umoddi3+0x2d>
