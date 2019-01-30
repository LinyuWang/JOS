
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 96 0d 00 00       	call   800dd7 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 96 0d 00 00       	call   800dee <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 62 0b 00 00       	call   800bd3 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 10 11 80 00       	push   $0x801110
  800080:	e8 75 01 00 00       	call   8001fa <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a3:	e8 5d 0d 00 00       	call   800e05 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 0c 0b 00 00       	call   800bd3 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 e0 10 80 00       	push   $0x8010e0
  8000d1:	e8 24 01 00 00       	call   8001fa <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 f5 0a 00 00       	call   800bd3 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 fa 10 80 00       	push   $0x8010fa
  8000e8:	e8 0d 01 00 00       	call   8001fa <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	e8 0a 0d 00 00       	call   800e05 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010e:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800115:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  800118:	e8 b6 0a 00 00       	call   800bd3 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x37>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 ef fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800159:	6a 00                	push   $0x0
  80015b:	e8 32 0a 00 00       	call   800b92 <sys_env_destroy>
}
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	74 09                	je     80018d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800184:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	68 ff 00 00 00       	push   $0xff
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 b7 09 00 00       	call   800b55 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a4:	83 c4 10             	add    $0x10,%esp
  8001a7:	eb db                	jmp    800184 <putch+0x1f>

008001a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b9:	00 00 00 
	b.cnt = 0;
  8001bc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c6:	ff 75 0c             	pushl  0xc(%ebp)
  8001c9:	ff 75 08             	pushl  0x8(%ebp)
  8001cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d2:	50                   	push   %eax
  8001d3:	68 65 01 80 00       	push   $0x800165
  8001d8:	e8 1a 01 00 00       	call   8002f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dd:	83 c4 08             	add    $0x8,%esp
  8001e0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	e8 63 09 00 00       	call   800b55 <sys_cputs>

	return b.cnt;
}
  8001f2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800200:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800203:	50                   	push   %eax
  800204:	ff 75 08             	pushl  0x8(%ebp)
  800207:	e8 9d ff ff ff       	call   8001a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	83 ec 1c             	sub    $0x1c,%esp
  800217:	89 c7                	mov    %eax,%edi
  800219:	89 d6                	mov    %edx,%esi
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800221:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800224:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800232:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800235:	39 d3                	cmp    %edx,%ebx
  800237:	72 05                	jb     80023e <printnum+0x30>
  800239:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023c:	77 7a                	ja     8002b8 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 18             	pushl  0x18(%ebp)
  800244:	8b 45 14             	mov    0x14(%ebp),%eax
  800247:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024a:	53                   	push   %ebx
  80024b:	ff 75 10             	pushl  0x10(%ebp)
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	ff 75 e4             	pushl  -0x1c(%ebp)
  800254:	ff 75 e0             	pushl  -0x20(%ebp)
  800257:	ff 75 dc             	pushl  -0x24(%ebp)
  80025a:	ff 75 d8             	pushl  -0x28(%ebp)
  80025d:	e8 3e 0c 00 00       	call   800ea0 <__udivdi3>
  800262:	83 c4 18             	add    $0x18,%esp
  800265:	52                   	push   %edx
  800266:	50                   	push   %eax
  800267:	89 f2                	mov    %esi,%edx
  800269:	89 f8                	mov    %edi,%eax
  80026b:	e8 9e ff ff ff       	call   80020e <printnum>
  800270:	83 c4 20             	add    $0x20,%esp
  800273:	eb 13                	jmp    800288 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	56                   	push   %esi
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	ff d7                	call   *%edi
  80027e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800281:	83 eb 01             	sub    $0x1,%ebx
  800284:	85 db                	test   %ebx,%ebx
  800286:	7f ed                	jg     800275 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	83 ec 04             	sub    $0x4,%esp
  80028f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800292:	ff 75 e0             	pushl  -0x20(%ebp)
  800295:	ff 75 dc             	pushl  -0x24(%ebp)
  800298:	ff 75 d8             	pushl  -0x28(%ebp)
  80029b:	e8 20 0d 00 00       	call   800fc0 <__umoddi3>
  8002a0:	83 c4 14             	add    $0x14,%esp
  8002a3:	0f be 80 40 11 80 00 	movsbl 0x801140(%eax),%eax
  8002aa:	50                   	push   %eax
  8002ab:	ff d7                	call   *%edi
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    
  8002b8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bb:	eb c4                	jmp    800281 <printnum+0x73>

008002bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cc:	73 0a                	jae    8002d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	88 02                	mov    %al,(%edx)
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <printfmt>:
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e3:	50                   	push   %eax
  8002e4:	ff 75 10             	pushl  0x10(%ebp)
  8002e7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	e8 05 00 00 00       	call   8002f7 <vprintfmt>
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <vprintfmt>:
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 2c             	sub    $0x2c,%esp
  800300:	8b 75 08             	mov    0x8(%ebp),%esi
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8b 7d 10             	mov    0x10(%ebp),%edi
  800309:	e9 63 03 00 00       	jmp    800671 <vprintfmt+0x37a>
		padc = ' ';
  80030e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800312:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800319:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800320:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800327:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8d 47 01             	lea    0x1(%edi),%eax
  80032f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800332:	0f b6 17             	movzbl (%edi),%edx
  800335:	8d 42 dd             	lea    -0x23(%edx),%eax
  800338:	3c 55                	cmp    $0x55,%al
  80033a:	0f 87 11 04 00 00    	ja     800751 <vprintfmt+0x45a>
  800340:	0f b6 c0             	movzbl %al,%eax
  800343:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800351:	eb d9                	jmp    80032c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800356:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035a:	eb d0                	jmp    80032c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	0f b6 d2             	movzbl %dl,%edx
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800362:	b8 00 00 00 00       	mov    $0x0,%eax
  800367:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800371:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800374:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800377:	83 f9 09             	cmp    $0x9,%ecx
  80037a:	77 55                	ja     8003d1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80037c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037f:	eb e9                	jmp    80036a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8b 00                	mov    (%eax),%eax
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 40 04             	lea    0x4(%eax),%eax
  80038f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800395:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800399:	79 91                	jns    80032c <vprintfmt+0x35>
				width = precision, precision = -1;
  80039b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a8:	eb 82                	jmp    80032c <vprintfmt+0x35>
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b4:	0f 49 d0             	cmovns %eax,%edx
  8003b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	e9 6a ff ff ff       	jmp    80032c <vprintfmt+0x35>
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cc:	e9 5b ff ff ff       	jmp    80032c <vprintfmt+0x35>
  8003d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d7:	eb bc                	jmp    800395 <vprintfmt+0x9e>
			lflag++;
  8003d9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003df:	e9 48 ff ff ff       	jmp    80032c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	53                   	push   %ebx
  8003ee:	ff 30                	pushl  (%eax)
  8003f0:	ff d6                	call   *%esi
			break;
  8003f2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f8:	e9 71 02 00 00       	jmp    80066e <vprintfmt+0x377>
			err = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 78 04             	lea    0x4(%eax),%edi
  800403:	8b 00                	mov    (%eax),%eax
  800405:	99                   	cltd   
  800406:	31 d0                	xor    %edx,%eax
  800408:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040a:	83 f8 08             	cmp    $0x8,%eax
  80040d:	7f 23                	jg     800432 <vprintfmt+0x13b>
  80040f:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800416:	85 d2                	test   %edx,%edx
  800418:	74 18                	je     800432 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80041a:	52                   	push   %edx
  80041b:	68 61 11 80 00       	push   $0x801161
  800420:	53                   	push   %ebx
  800421:	56                   	push   %esi
  800422:	e8 b3 fe ff ff       	call   8002da <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042d:	e9 3c 02 00 00       	jmp    80066e <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800432:	50                   	push   %eax
  800433:	68 58 11 80 00       	push   $0x801158
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 9b fe ff ff       	call   8002da <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800442:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800445:	e9 24 02 00 00       	jmp    80066e <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	83 c0 04             	add    $0x4,%eax
  800450:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800458:	85 ff                	test   %edi,%edi
  80045a:	b8 51 11 80 00       	mov    $0x801151,%eax
  80045f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800462:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800466:	0f 8e bd 00 00 00    	jle    800529 <vprintfmt+0x232>
  80046c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800470:	75 0e                	jne    800480 <vprintfmt+0x189>
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047e:	eb 6d                	jmp    8004ed <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 d0             	pushl  -0x30(%ebp)
  800486:	57                   	push   %edi
  800487:	e8 6d 03 00 00       	call   8007f9 <strnlen>
  80048c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048f:	29 c1                	sub    %eax,%ecx
  800491:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800494:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800497:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a1:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	eb 0f                	jmp    8004b4 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ac:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	83 ef 01             	sub    $0x1,%edi
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	7f ed                	jg     8004a5 <vprintfmt+0x1ae>
  8004b8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004bb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004be:	85 c9                	test   %ecx,%ecx
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	0f 49 c1             	cmovns %ecx,%eax
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d3:	89 cb                	mov    %ecx,%ebx
  8004d5:	eb 16                	jmp    8004ed <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004db:	75 31                	jne    80050e <vprintfmt+0x217>
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	50                   	push   %eax
  8004e4:	ff 55 08             	call   *0x8(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004f4:	0f be c2             	movsbl %dl,%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	74 59                	je     800554 <vprintfmt+0x25d>
  8004fb:	85 f6                	test   %esi,%esi
  8004fd:	78 d8                	js     8004d7 <vprintfmt+0x1e0>
  8004ff:	83 ee 01             	sub    $0x1,%esi
  800502:	79 d3                	jns    8004d7 <vprintfmt+0x1e0>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb 37                	jmp    800545 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	0f be d2             	movsbl %dl,%edx
  800511:	83 ea 20             	sub    $0x20,%edx
  800514:	83 fa 5e             	cmp    $0x5e,%edx
  800517:	76 c4                	jbe    8004dd <vprintfmt+0x1e6>
					putch('?', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	ff 75 0c             	pushl  0xc(%ebp)
  80051f:	6a 3f                	push   $0x3f
  800521:	ff 55 08             	call   *0x8(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb c1                	jmp    8004ea <vprintfmt+0x1f3>
  800529:	89 75 08             	mov    %esi,0x8(%ebp)
  80052c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800532:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800535:	eb b6                	jmp    8004ed <vprintfmt+0x1f6>
				putch(' ', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 20                	push   $0x20
  80053d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 ff                	test   %edi,%edi
  800547:	7f ee                	jg     800537 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800549:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	e9 1a 01 00 00       	jmp    80066e <vprintfmt+0x377>
  800554:	89 df                	mov    %ebx,%edi
  800556:	8b 75 08             	mov    0x8(%ebp),%esi
  800559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055c:	eb e7                	jmp    800545 <vprintfmt+0x24e>
	if (lflag >= 2)
  80055e:	83 f9 01             	cmp    $0x1,%ecx
  800561:	7e 3f                	jle    8005a2 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 50 04             	mov    0x4(%eax),%edx
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 08             	lea    0x8(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057e:	79 5c                	jns    8005dc <vprintfmt+0x2e5>
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	6a 2d                	push   $0x2d
  800586:	ff d6                	call   *%esi
				num = -(long long) num;
  800588:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058e:	f7 da                	neg    %edx
  800590:	83 d1 00             	adc    $0x0,%ecx
  800593:	f7 d9                	neg    %ecx
  800595:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059d:	e9 b2 00 00 00       	jmp    800654 <vprintfmt+0x35d>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	75 1b                	jne    8005c1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb b9                	jmp    80057a <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005da:	eb 9e                	jmp    80057a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	eb 6b                	jmp    800654 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005e9:	83 f9 01             	cmp    $0x1,%ecx
  8005ec:	7e 15                	jle    800603 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f6:	8d 40 08             	lea    0x8(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800601:	eb 51                	jmp    800654 <vprintfmt+0x35d>
	else if (lflag)
  800603:	85 c9                	test   %ecx,%ecx
  800605:	75 17                	jne    80061e <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061c:	eb 36                	jmp    800654 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	eb 1f                	jmp    800654 <vprintfmt+0x35d>
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 5b                	jle    800695 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800645:	8d 49 08             	lea    0x8(%ecx),%ecx
  800648:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80064b:	89 d1                	mov    %edx,%ecx
  80064d:	89 c2                	mov    %eax,%edx
			base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065b:	57                   	push   %edi
  80065c:	ff 75 e0             	pushl  -0x20(%ebp)
  80065f:	50                   	push   %eax
  800660:	51                   	push   %ecx
  800661:	52                   	push   %edx
  800662:	89 da                	mov    %ebx,%edx
  800664:	89 f0                	mov    %esi,%eax
  800666:	e8 a3 fb ff ff       	call   80020e <printnum>
			break;
  80066b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800671:	83 c7 01             	add    $0x1,%edi
  800674:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800678:	83 f8 25             	cmp    $0x25,%eax
  80067b:	0f 84 8d fc ff ff    	je     80030e <vprintfmt+0x17>
			if (ch == '\0')
  800681:	85 c0                	test   %eax,%eax
  800683:	0f 84 e8 00 00 00    	je     800771 <vprintfmt+0x47a>
			putch(ch, putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	50                   	push   %eax
  80068e:	ff d6                	call   *%esi
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb dc                	jmp    800671 <vprintfmt+0x37a>
	else if (lflag)
  800695:	85 c9                	test   %ecx,%ecx
  800697:	75 13                	jne    8006ac <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	89 d0                	mov    %edx,%eax
  8006a0:	99                   	cltd   
  8006a1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006a4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006aa:	eb 9f                	jmp    80064b <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	99                   	cltd   
  8006b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	eb 8c                	jmp    80064b <vprintfmt+0x354>
			putch('0', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 30                	push   $0x30
  8006c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c7:	83 c4 08             	add    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 78                	push   $0x78
  8006cd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	e9 68 ff ff ff       	jmp    800654 <vprintfmt+0x35d>
	if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7e 18                	jle    800709 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f9:	8d 40 08             	lea    0x8(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	e9 4b ff ff ff       	jmp    800654 <vprintfmt+0x35d>
	else if (lflag)
  800709:	85 c9                	test   %ecx,%ecx
  80070b:	75 1a                	jne    800727 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
  800722:	e9 2d ff ff ff       	jmp    800654 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 10                	mov    (%eax),%edx
  80072c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
  80073c:	e9 13 ff ff ff       	jmp    800654 <vprintfmt+0x35d>
			putch(ch, putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 25                	push   $0x25
  800747:	ff d6                	call   *%esi
			break;
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	e9 1d ff ff ff       	jmp    80066e <vprintfmt+0x377>
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 25                	push   $0x25
  800757:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	89 f8                	mov    %edi,%eax
  80075e:	eb 03                	jmp    800763 <vprintfmt+0x46c>
  800760:	83 e8 01             	sub    $0x1,%eax
  800763:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800767:	75 f7                	jne    800760 <vprintfmt+0x469>
  800769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076c:	e9 fd fe ff ff       	jmp    80066e <vprintfmt+0x377>
}
  800771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5f                   	pop    %edi
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 18             	sub    $0x18,%esp
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800788:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800796:	85 c0                	test   %eax,%eax
  800798:	74 26                	je     8007c0 <vsnprintf+0x47>
  80079a:	85 d2                	test   %edx,%edx
  80079c:	7e 22                	jle    8007c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079e:	ff 75 14             	pushl  0x14(%ebp)
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	68 bd 02 80 00       	push   $0x8002bd
  8007ad:	e8 45 fb ff ff       	call   8002f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bb:	83 c4 10             	add    $0x10,%esp
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    
		return -E_INVAL;
  8007c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c5:	eb f7                	jmp    8007be <vsnprintf+0x45>

008007c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 10             	pushl  0x10(%ebp)
  8007d4:	ff 75 0c             	pushl  0xc(%ebp)
  8007d7:	ff 75 08             	pushl  0x8(%ebp)
  8007da:	e8 9a ff ff ff       	call   800779 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 03                	jmp    8007f1 <strlen+0x10>
		n++;
  8007ee:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f5:	75 f7                	jne    8007ee <strlen+0xd>
	return n;
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 03                	jmp    80080c <strnlen+0x13>
		n++;
  800809:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080c:	39 d0                	cmp    %edx,%eax
  80080e:	74 06                	je     800816 <strnlen+0x1d>
  800810:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800814:	75 f3                	jne    800809 <strnlen+0x10>
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800822:	89 c2                	mov    %eax,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800831:	84 db                	test   %bl,%bl
  800833:	75 ef                	jne    800824 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083f:	53                   	push   %ebx
  800840:	e8 9c ff ff ff       	call   8007e1 <strlen>
  800845:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800848:	ff 75 0c             	pushl  0xc(%ebp)
  80084b:	01 d8                	add    %ebx,%eax
  80084d:	50                   	push   %eax
  80084e:	e8 c5 ff ff ff       	call   800818 <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 75 08             	mov    0x8(%ebp),%esi
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800865:	89 f3                	mov    %esi,%ebx
  800867:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086a:	89 f2                	mov    %esi,%edx
  80086c:	eb 0f                	jmp    80087d <strncpy+0x23>
		*dst++ = *src;
  80086e:	83 c2 01             	add    $0x1,%edx
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800877:	80 39 01             	cmpb   $0x1,(%ecx)
  80087a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80087d:	39 da                	cmp    %ebx,%edx
  80087f:	75 ed                	jne    80086e <strncpy+0x14>
	}
	return ret;
}
  800881:	89 f0                	mov    %esi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 75 08             	mov    0x8(%ebp),%esi
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800895:	89 f0                	mov    %esi,%eax
  800897:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089b:	85 c9                	test   %ecx,%ecx
  80089d:	75 0b                	jne    8008aa <strlcpy+0x23>
  80089f:	eb 17                	jmp    8008b8 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008aa:	39 d8                	cmp    %ebx,%eax
  8008ac:	74 07                	je     8008b5 <strlcpy+0x2e>
  8008ae:	0f b6 0a             	movzbl (%edx),%ecx
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	75 ec                	jne    8008a1 <strlcpy+0x1a>
		*dst = '\0';
  8008b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c7:	eb 06                	jmp    8008cf <strcmp+0x11>
		p++, q++;
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 04                	je     8008da <strcmp+0x1c>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	74 ef                	je     8008c9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 c0             	movzbl %al,%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 c3                	mov    %eax,%ebx
  8008f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f3:	eb 06                	jmp    8008fb <strncmp+0x17>
		n--, p++, q++;
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fb:	39 d8                	cmp    %ebx,%eax
  8008fd:	74 16                	je     800915 <strncmp+0x31>
  8008ff:	0f b6 08             	movzbl (%eax),%ecx
  800902:	84 c9                	test   %cl,%cl
  800904:	74 04                	je     80090a <strncmp+0x26>
  800906:	3a 0a                	cmp    (%edx),%cl
  800908:	74 eb                	je     8008f5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 00             	movzbl (%eax),%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    
		return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb f6                	jmp    800912 <strncmp+0x2e>

0080091c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	0f b6 10             	movzbl (%eax),%edx
  800929:	84 d2                	test   %dl,%dl
  80092b:	74 09                	je     800936 <strchr+0x1a>
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 0a                	je     80093b <strchr+0x1f>
	for (; *s; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	eb f0                	jmp    800926 <strchr+0xa>
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	eb 03                	jmp    80094c <strfind+0xf>
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094f:	38 ca                	cmp    %cl,%dl
  800951:	74 04                	je     800957 <strfind+0x1a>
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f2                	jne    800949 <strfind+0xc>
			break;
	return (char *) s;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 13                	je     80097c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 05                	jne    800976 <memset+0x1d>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	74 0d                	je     800983 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    
		c &= 0xFF;
  800983:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800987:	89 d3                	mov    %edx,%ebx
  800989:	c1 e3 08             	shl    $0x8,%ebx
  80098c:	89 d0                	mov    %edx,%eax
  80098e:	c1 e0 18             	shl    $0x18,%eax
  800991:	89 d6                	mov    %edx,%esi
  800993:	c1 e6 10             	shl    $0x10,%esi
  800996:	09 f0                	or     %esi,%eax
  800998:	09 c2                	or     %eax,%edx
  80099a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80099c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	fc                   	cld    
  8009a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a4:	eb d6                	jmp    80097c <memset+0x23>

008009a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	73 35                	jae    8009ed <memmove+0x47>
  8009b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bb:	39 c2                	cmp    %eax,%edx
  8009bd:	76 2e                	jbe    8009ed <memmove+0x47>
		s += n;
		d += n;
  8009bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	09 fe                	or     %edi,%esi
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	74 0c                	je     8009da <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ce:	83 ef 01             	sub    $0x1,%edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 21                	jmp    8009fb <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 ef                	jne    8009ce <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009df:	83 ef 04             	sub    $0x4,%edi
  8009e2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e8:	fd                   	std    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb ea                	jmp    8009d7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 f2                	mov    %esi,%edx
  8009ef:	09 c2                	or     %eax,%edx
  8009f1:	f6 c2 03             	test   $0x3,%dl
  8009f4:	74 09                	je     8009ff <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 f2                	jne    8009f6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a04:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0c:	eb ed                	jmp    8009fb <memmove+0x55>

00800a0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	ff 75 08             	pushl  0x8(%ebp)
  800a1a:	e8 87 ff ff ff       	call   8009a6 <memmove>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c6                	mov    %eax,%esi
  800a2e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	39 f0                	cmp    %esi,%eax
  800a33:	74 1c                	je     800a51 <memcmp+0x30>
		if (*s1 != *s2)
  800a35:	0f b6 08             	movzbl (%eax),%ecx
  800a38:	0f b6 1a             	movzbl (%edx),%ebx
  800a3b:	38 d9                	cmp    %bl,%cl
  800a3d:	75 08                	jne    800a47 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	eb ea                	jmp    800a31 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a47:	0f b6 c1             	movzbl %cl,%eax
  800a4a:	0f b6 db             	movzbl %bl,%ebx
  800a4d:	29 d8                	sub    %ebx,%eax
  800a4f:	eb 05                	jmp    800a56 <memcmp+0x35>
	}

	return 0;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a63:	89 c2                	mov    %eax,%edx
  800a65:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	73 09                	jae    800a75 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6c:	38 08                	cmp    %cl,(%eax)
  800a6e:	74 05                	je     800a75 <memfind+0x1b>
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	eb f3                	jmp    800a68 <memfind+0xe>
			break;
	return (void *) s;
}
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	eb 03                	jmp    800a88 <strtol+0x11>
		s++;
  800a85:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a88:	0f b6 01             	movzbl (%ecx),%eax
  800a8b:	3c 20                	cmp    $0x20,%al
  800a8d:	74 f6                	je     800a85 <strtol+0xe>
  800a8f:	3c 09                	cmp    $0x9,%al
  800a91:	74 f2                	je     800a85 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a93:	3c 2b                	cmp    $0x2b,%al
  800a95:	74 2e                	je     800ac5 <strtol+0x4e>
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a9c:	3c 2d                	cmp    $0x2d,%al
  800a9e:	74 2f                	je     800acf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa6:	75 05                	jne    800aad <strtol+0x36>
  800aa8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aab:	74 2c                	je     800ad9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	75 0a                	jne    800abb <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ab6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab9:	74 28                	je     800ae3 <strtol+0x6c>
		base = 10;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac3:	eb 50                	jmp    800b15 <strtol+0x9e>
		s++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
  800acd:	eb d1                	jmp    800aa0 <strtol+0x29>
		s++, neg = 1;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad7:	eb c7                	jmp    800aa0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800add:	74 0e                	je     800aed <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	75 d8                	jne    800abb <strtol+0x44>
		s++, base = 8;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aeb:	eb ce                	jmp    800abb <strtol+0x44>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb c4                	jmp    800abb <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800af7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 29                	ja     800b2a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0a:	7d 30                	jge    800b3c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b13:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 d5                	ja     800af7 <strtol+0x80>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb dd                	jmp    800b07 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b2a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 37             	sub    $0x37,%edx
  800b3a:	eb cb                	jmp    800b07 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b40:	74 05                	je     800b47 <strtol+0xd0>
		*endptr = (char *) s;
  800b42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b45:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	f7 da                	neg    %edx
  800b4b:	85 ff                	test   %edi,%edi
  800b4d:	0f 45 c2             	cmovne %edx,%eax
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 c7                	mov    %eax,%edi
  800b6a:	89 c6                	mov    %eax,%esi
  800b6c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	89 cb                	mov    %ecx,%ebx
  800baa:	89 cf                	mov    %ecx,%edi
  800bac:	89 ce                	mov    %ecx,%esi
  800bae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7f 08                	jg     800bbc <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 03                	push   $0x3
  800bc2:	68 84 13 80 00       	push   $0x801384
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 a1 13 80 00       	push   $0x8013a1
  800bce:	e8 82 02 00 00       	call   800e55 <_panic>

00800bd3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 02 00 00 00       	mov    $0x2,%eax
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	89 d7                	mov    %edx,%edi
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_yield>:

void
sys_yield(void)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	be 00 00 00 00       	mov    $0x0,%esi
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	89 f7                	mov    %esi,%edi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 04                	push   $0x4
  800c43:	68 84 13 80 00       	push   $0x801384
  800c48:	6a 23                	push   $0x23
  800c4a:	68 a1 13 80 00       	push   $0x8013a1
  800c4f:	e8 01 02 00 00       	call   800e55 <_panic>

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	b8 05 00 00 00       	mov    $0x5,%eax
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 05                	push   $0x5
  800c85:	68 84 13 80 00       	push   $0x801384
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 a1 13 80 00       	push   $0x8013a1
  800c91:	e8 bf 01 00 00       	call   800e55 <_panic>

00800c96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 06                	push   $0x6
  800cc7:	68 84 13 80 00       	push   $0x801384
  800ccc:	6a 23                	push   $0x23
  800cce:	68 a1 13 80 00       	push   $0x8013a1
  800cd3:	e8 7d 01 00 00       	call   800e55 <_panic>

00800cd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 08                	push   $0x8
  800d09:	68 84 13 80 00       	push   $0x801384
  800d0e:	6a 23                	push   $0x23
  800d10:	68 a1 13 80 00       	push   $0x8013a1
  800d15:	e8 3b 01 00 00       	call   800e55 <_panic>

00800d1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7f 08                	jg     800d45 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 09                	push   $0x9
  800d4b:	68 84 13 80 00       	push   $0x801384
  800d50:	6a 23                	push   $0x23
  800d52:	68 a1 13 80 00       	push   $0x8013a1
  800d57:	e8 f9 00 00 00       	call   800e55 <_panic>

00800d5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6d:	be 00 00 00 00       	mov    $0x0,%esi
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d78:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	89 cb                	mov    %ecx,%ebx
  800d97:	89 cf                	mov    %ecx,%edi
  800d99:	89 ce                	mov    %ecx,%esi
  800d9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7f 08                	jg     800da9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 0c                	push   $0xc
  800daf:	68 84 13 80 00       	push   $0x801384
  800db4:	6a 23                	push   $0x23
  800db6:	68 a1 13 80 00       	push   $0x8013a1
  800dbb:	e8 95 00 00 00       	call   800e55 <_panic>

00800dc0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800dc6:	68 bb 13 80 00       	push   $0x8013bb
  800dcb:	6a 51                	push   $0x51
  800dcd:	68 af 13 80 00       	push   $0x8013af
  800dd2:	e8 7e 00 00 00       	call   800e55 <_panic>

00800dd7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ddd:	68 ba 13 80 00       	push   $0x8013ba
  800de2:	6a 58                	push   $0x58
  800de4:	68 af 13 80 00       	push   $0x8013af
  800de9:	e8 67 00 00 00       	call   800e55 <_panic>

00800dee <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800df4:	68 d0 13 80 00       	push   $0x8013d0
  800df9:	6a 1a                	push   $0x1a
  800dfb:	68 e9 13 80 00       	push   $0x8013e9
  800e00:	e8 50 00 00 00       	call   800e55 <_panic>

00800e05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e0b:	68 f3 13 80 00       	push   $0x8013f3
  800e10:	6a 2a                	push   $0x2a
  800e12:	68 e9 13 80 00       	push   $0x8013e9
  800e17:	e8 39 00 00 00       	call   800e55 <_panic>

00800e1c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e27:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e2a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e30:	8b 52 50             	mov    0x50(%edx),%edx
  800e33:	39 ca                	cmp    %ecx,%edx
  800e35:	74 11                	je     800e48 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e37:	83 c0 01             	add    $0x1,%eax
  800e3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e3f:	75 e6                	jne    800e27 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	eb 0b                	jmp    800e53 <ipc_find_env+0x37>
			return envs[i].env_id;
  800e48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e50:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e5a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e5d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e63:	e8 6b fd ff ff       	call   800bd3 <sys_getenvid>
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	ff 75 0c             	pushl  0xc(%ebp)
  800e6e:	ff 75 08             	pushl  0x8(%ebp)
  800e71:	56                   	push   %esi
  800e72:	50                   	push   %eax
  800e73:	68 0c 14 80 00       	push   $0x80140c
  800e78:	e8 7d f3 ff ff       	call   8001fa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e7d:	83 c4 18             	add    $0x18,%esp
  800e80:	53                   	push   %ebx
  800e81:	ff 75 10             	pushl  0x10(%ebp)
  800e84:	e8 20 f3 ff ff       	call   8001a9 <vcprintf>
	cprintf("\n");
  800e89:	c7 04 24 f8 10 80 00 	movl   $0x8010f8,(%esp)
  800e90:	e8 65 f3 ff ff       	call   8001fa <cprintf>
  800e95:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e98:	cc                   	int3   
  800e99:	eb fd                	jmp    800e98 <_panic+0x43>
  800e9b:	66 90                	xchg   %ax,%ax
  800e9d:	66 90                	xchg   %ax,%ax
  800e9f:	90                   	nop

00800ea0 <__udivdi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800eb7:	85 d2                	test   %edx,%edx
  800eb9:	75 35                	jne    800ef0 <__udivdi3+0x50>
  800ebb:	39 f3                	cmp    %esi,%ebx
  800ebd:	0f 87 bd 00 00 00    	ja     800f80 <__udivdi3+0xe0>
  800ec3:	85 db                	test   %ebx,%ebx
  800ec5:	89 d9                	mov    %ebx,%ecx
  800ec7:	75 0b                	jne    800ed4 <__udivdi3+0x34>
  800ec9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	f7 f3                	div    %ebx
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	31 d2                	xor    %edx,%edx
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	f7 f1                	div    %ecx
  800eda:	89 c6                	mov    %eax,%esi
  800edc:	89 e8                	mov    %ebp,%eax
  800ede:	89 f7                	mov    %esi,%edi
  800ee0:	f7 f1                	div    %ecx
  800ee2:	89 fa                	mov    %edi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 f2                	cmp    %esi,%edx
  800ef2:	77 7c                	ja     800f70 <__udivdi3+0xd0>
  800ef4:	0f bd fa             	bsr    %edx,%edi
  800ef7:	83 f7 1f             	xor    $0x1f,%edi
  800efa:	0f 84 98 00 00 00    	je     800f98 <__udivdi3+0xf8>
  800f00:	89 f9                	mov    %edi,%ecx
  800f02:	b8 20 00 00 00       	mov    $0x20,%eax
  800f07:	29 f8                	sub    %edi,%eax
  800f09:	d3 e2                	shl    %cl,%edx
  800f0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	89 da                	mov    %ebx,%edx
  800f13:	d3 ea                	shr    %cl,%edx
  800f15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f19:	09 d1                	or     %edx,%ecx
  800f1b:	89 f2                	mov    %esi,%edx
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 e3                	shl    %cl,%ebx
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	d3 ea                	shr    %cl,%edx
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f2f:	d3 e6                	shl    %cl,%esi
  800f31:	89 eb                	mov    %ebp,%ebx
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	d3 eb                	shr    %cl,%ebx
  800f37:	09 de                	or     %ebx,%esi
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	f7 74 24 08          	divl   0x8(%esp)
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	f7 64 24 0c          	mull   0xc(%esp)
  800f47:	39 d6                	cmp    %edx,%esi
  800f49:	72 0c                	jb     800f57 <__udivdi3+0xb7>
  800f4b:	89 f9                	mov    %edi,%ecx
  800f4d:	d3 e5                	shl    %cl,%ebp
  800f4f:	39 c5                	cmp    %eax,%ebp
  800f51:	73 5d                	jae    800fb0 <__udivdi3+0x110>
  800f53:	39 d6                	cmp    %edx,%esi
  800f55:	75 59                	jne    800fb0 <__udivdi3+0x110>
  800f57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f5a:	31 ff                	xor    %edi,%edi
  800f5c:	89 fa                	mov    %edi,%edx
  800f5e:	83 c4 1c             	add    $0x1c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
  800f66:	8d 76 00             	lea    0x0(%esi),%esi
  800f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	31 c0                	xor    %eax,%eax
  800f74:	89 fa                	mov    %edi,%edx
  800f76:	83 c4 1c             	add    $0x1c,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	31 ff                	xor    %edi,%edi
  800f82:	89 e8                	mov    %ebp,%eax
  800f84:	89 f2                	mov    %esi,%edx
  800f86:	f7 f3                	div    %ebx
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	72 06                	jb     800fa2 <__udivdi3+0x102>
  800f9c:	31 c0                	xor    %eax,%eax
  800f9e:	39 eb                	cmp    %ebp,%ebx
  800fa0:	77 d2                	ja     800f74 <__udivdi3+0xd4>
  800fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa7:	eb cb                	jmp    800f74 <__udivdi3+0xd4>
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	31 ff                	xor    %edi,%edi
  800fb4:	eb be                	jmp    800f74 <__udivdi3+0xd4>
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fd7:	85 ed                	test   %ebp,%ebp
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	89 da                	mov    %ebx,%edx
  800fdd:	75 19                	jne    800ff8 <__umoddi3+0x38>
  800fdf:	39 df                	cmp    %ebx,%edi
  800fe1:	0f 86 b1 00 00 00    	jbe    801098 <__umoddi3+0xd8>
  800fe7:	f7 f7                	div    %edi
  800fe9:	89 d0                	mov    %edx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	83 c4 1c             	add    $0x1c,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi
  800ff8:	39 dd                	cmp    %ebx,%ebp
  800ffa:	77 f1                	ja     800fed <__umoddi3+0x2d>
  800ffc:	0f bd cd             	bsr    %ebp,%ecx
  800fff:	83 f1 1f             	xor    $0x1f,%ecx
  801002:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801006:	0f 84 b4 00 00 00    	je     8010c0 <__umoddi3+0x100>
  80100c:	b8 20 00 00 00       	mov    $0x20,%eax
  801011:	89 c2                	mov    %eax,%edx
  801013:	8b 44 24 04          	mov    0x4(%esp),%eax
  801017:	29 c2                	sub    %eax,%edx
  801019:	89 c1                	mov    %eax,%ecx
  80101b:	89 f8                	mov    %edi,%eax
  80101d:	d3 e5                	shl    %cl,%ebp
  80101f:	89 d1                	mov    %edx,%ecx
  801021:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801025:	d3 e8                	shr    %cl,%eax
  801027:	09 c5                	or     %eax,%ebp
  801029:	8b 44 24 04          	mov    0x4(%esp),%eax
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	d3 e7                	shl    %cl,%edi
  801031:	89 d1                	mov    %edx,%ecx
  801033:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801037:	89 df                	mov    %ebx,%edi
  801039:	d3 ef                	shr    %cl,%edi
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	d3 e3                	shl    %cl,%ebx
  801041:	89 d1                	mov    %edx,%ecx
  801043:	89 fa                	mov    %edi,%edx
  801045:	d3 e8                	shr    %cl,%eax
  801047:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80104c:	09 d8                	or     %ebx,%eax
  80104e:	f7 f5                	div    %ebp
  801050:	d3 e6                	shl    %cl,%esi
  801052:	89 d1                	mov    %edx,%ecx
  801054:	f7 64 24 08          	mull   0x8(%esp)
  801058:	39 d1                	cmp    %edx,%ecx
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	89 d7                	mov    %edx,%edi
  80105e:	72 06                	jb     801066 <__umoddi3+0xa6>
  801060:	75 0e                	jne    801070 <__umoddi3+0xb0>
  801062:	39 c6                	cmp    %eax,%esi
  801064:	73 0a                	jae    801070 <__umoddi3+0xb0>
  801066:	2b 44 24 08          	sub    0x8(%esp),%eax
  80106a:	19 ea                	sbb    %ebp,%edx
  80106c:	89 d7                	mov    %edx,%edi
  80106e:	89 c3                	mov    %eax,%ebx
  801070:	89 ca                	mov    %ecx,%edx
  801072:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801077:	29 de                	sub    %ebx,%esi
  801079:	19 fa                	sbb    %edi,%edx
  80107b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80107f:	89 d0                	mov    %edx,%eax
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 d9                	mov    %ebx,%ecx
  801085:	d3 ee                	shr    %cl,%esi
  801087:	d3 ea                	shr    %cl,%edx
  801089:	09 f0                	or     %esi,%eax
  80108b:	83 c4 1c             	add    $0x1c,%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
  801093:	90                   	nop
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	85 ff                	test   %edi,%edi
  80109a:	89 f9                	mov    %edi,%ecx
  80109c:	75 0b                	jne    8010a9 <__umoddi3+0xe9>
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f7                	div    %edi
  8010a7:	89 c1                	mov    %eax,%ecx
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f1                	div    %ecx
  8010af:	89 f0                	mov    %esi,%eax
  8010b1:	f7 f1                	div    %ecx
  8010b3:	e9 31 ff ff ff       	jmp    800fe9 <__umoddi3+0x29>
  8010b8:	90                   	nop
  8010b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	39 dd                	cmp    %ebx,%ebp
  8010c2:	72 08                	jb     8010cc <__umoddi3+0x10c>
  8010c4:	39 f7                	cmp    %esi,%edi
  8010c6:	0f 87 21 ff ff ff    	ja     800fed <__umoddi3+0x2d>
  8010cc:	89 da                	mov    %ebx,%edx
  8010ce:	89 f0                	mov    %esi,%eax
  8010d0:	29 f8                	sub    %edi,%eax
  8010d2:	19 ea                	sbb    %ebp,%edx
  8010d4:	e9 14 ff ff ff       	jmp    800fed <__umoddi3+0x2d>
