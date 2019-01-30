
obj/user/faultallocbad:     file format elf32-i386


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

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 a0 10 80 00       	push   $0x8010a0
  800045:	e8 a8 01 00 00       	call   8001f2 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ab 0b 00 00       	call   800c09 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ec 10 80 00       	push   $0x8010ec
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 4c 07 00 00       	call   8007bf <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 c0 10 80 00       	push   $0x8010c0
  800085:	6a 0f                	push   $0xf
  800087:	68 aa 10 80 00       	push   $0x8010aa
  80008c:	e8 86 00 00 00       	call   800117 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 17 0d 00 00       	call   800db8 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 9d 0a 00 00       	call   800b4d <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000ca:	e8 fc 0a 00 00       	call   800bcb <sys_getenvid>
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
  8000f1:	e8 9b ff ff ff       	call   800091 <umain>

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
  80010d:	e8 78 0a 00 00       	call   800b8a <sys_env_destroy>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800125:	e8 a1 0a 00 00       	call   800bcb <sys_getenvid>
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	ff 75 0c             	pushl  0xc(%ebp)
  800130:	ff 75 08             	pushl  0x8(%ebp)
  800133:	56                   	push   %esi
  800134:	50                   	push   %eax
  800135:	68 18 11 80 00       	push   $0x801118
  80013a:	e8 b3 00 00 00       	call   8001f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013f:	83 c4 18             	add    $0x18,%esp
  800142:	53                   	push   %ebx
  800143:	ff 75 10             	pushl  0x10(%ebp)
  800146:	e8 56 00 00 00       	call   8001a1 <vcprintf>
	cprintf("\n");
  80014b:	c7 04 24 a8 10 80 00 	movl   $0x8010a8,(%esp)
  800152:	e8 9b 00 00 00       	call   8001f2 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015a:	cc                   	int3   
  80015b:	eb fd                	jmp    80015a <_panic+0x43>

0080015d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	53                   	push   %ebx
  800161:	83 ec 04             	sub    $0x4,%esp
  800164:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800167:	8b 13                	mov    (%ebx),%edx
  800169:	8d 42 01             	lea    0x1(%edx),%eax
  80016c:	89 03                	mov    %eax,(%ebx)
  80016e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800175:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017a:	74 09                	je     800185 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800183:	c9                   	leave  
  800184:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 b7 09 00 00       	call   800b4d <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	eb db                	jmp    80017c <putch+0x1f>

008001a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b1:	00 00 00 
	b.cnt = 0;
  8001b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	68 5d 01 80 00       	push   $0x80015d
  8001d0:	e8 1a 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d5:	83 c4 08             	add    $0x8,%esp
  8001d8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	e8 63 09 00 00       	call   800b4d <sys_cputs>

	return b.cnt;
}
  8001ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fb:	50                   	push   %eax
  8001fc:	ff 75 08             	pushl  0x8(%ebp)
  8001ff:	e8 9d ff ff ff       	call   8001a1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 1c             	sub    $0x1c,%esp
  80020f:	89 c7                	mov    %eax,%edi
  800211:	89 d6                	mov    %edx,%esi
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	8b 55 0c             	mov    0xc(%ebp),%edx
  800219:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022d:	39 d3                	cmp    %edx,%ebx
  80022f:	72 05                	jb     800236 <printnum+0x30>
  800231:	39 45 10             	cmp    %eax,0x10(%ebp)
  800234:	77 7a                	ja     8002b0 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	ff 75 18             	pushl  0x18(%ebp)
  80023c:	8b 45 14             	mov    0x14(%ebp),%eax
  80023f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800242:	53                   	push   %ebx
  800243:	ff 75 10             	pushl  0x10(%ebp)
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024c:	ff 75 e0             	pushl  -0x20(%ebp)
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	e8 f6 0b 00 00       	call   800e50 <__udivdi3>
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	89 f2                	mov    %esi,%edx
  800261:	89 f8                	mov    %edi,%eax
  800263:	e8 9e ff ff ff       	call   800206 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 13                	jmp    800280 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	ff 75 18             	pushl  0x18(%ebp)
  800274:	ff d7                	call   *%edi
  800276:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f ed                	jg     80026d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 d8 0c 00 00       	call   800f70 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 3c 11 80 00 	movsbl 0x80113c(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b3:	eb c4                	jmp    800279 <printnum+0x73>

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 0a                	jae    8002d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ce:	88 02                	mov    %al,(%edx)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 2c             	sub    $0x2c,%esp
  8002f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800301:	e9 63 03 00 00       	jmp    800669 <vprintfmt+0x37a>
		padc = ' ';
  800306:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80030a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800311:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800318:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 17             	movzbl (%edi),%edx
  80032d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800330:	3c 55                	cmp    $0x55,%al
  800332:	0f 87 11 04 00 00    	ja     800749 <vprintfmt+0x45a>
  800338:	0f b6 c0             	movzbl %al,%eax
  80033b:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800345:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800349:	eb d9                	jmp    800324 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d0                	jmp    800324 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800354:	0f b6 d2             	movzbl %dl,%edx
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80035a:	b8 00 00 00 00       	mov    $0x0,%eax
  80035f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800362:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800365:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800369:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036f:	83 f9 09             	cmp    $0x9,%ecx
  800372:	77 55                	ja     8003c9 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800374:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800377:	eb e9                	jmp    800362 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 40 04             	lea    0x4(%eax),%eax
  800387:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800391:	79 91                	jns    800324 <vprintfmt+0x35>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	eb 82                	jmp    800324 <vprintfmt+0x35>
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ac:	0f 49 d0             	cmovns %eax,%edx
  8003af:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	e9 6a ff ff ff       	jmp    800324 <vprintfmt+0x35>
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c4:	e9 5b ff ff ff       	jmp    800324 <vprintfmt+0x35>
  8003c9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003cf:	eb bc                	jmp    80038d <vprintfmt+0x9e>
			lflag++;
  8003d1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d7:	e9 48 ff ff ff       	jmp    800324 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 78 04             	lea    0x4(%eax),%edi
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	53                   	push   %ebx
  8003e6:	ff 30                	pushl  (%eax)
  8003e8:	ff d6                	call   *%esi
			break;
  8003ea:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f0:	e9 71 02 00 00       	jmp    800666 <vprintfmt+0x377>
			err = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 78 04             	lea    0x4(%eax),%edi
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	99                   	cltd   
  8003fe:	31 d0                	xor    %edx,%eax
  800400:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800402:	83 f8 08             	cmp    $0x8,%eax
  800405:	7f 23                	jg     80042a <vprintfmt+0x13b>
  800407:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  80040e:	85 d2                	test   %edx,%edx
  800410:	74 18                	je     80042a <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800412:	52                   	push   %edx
  800413:	68 5d 11 80 00       	push   $0x80115d
  800418:	53                   	push   %ebx
  800419:	56                   	push   %esi
  80041a:	e8 b3 fe ff ff       	call   8002d2 <printfmt>
  80041f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800422:	89 7d 14             	mov    %edi,0x14(%ebp)
  800425:	e9 3c 02 00 00       	jmp    800666 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 54 11 80 00       	push   $0x801154
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 9b fe ff ff       	call   8002d2 <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 24 02 00 00       	jmp    800666 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	83 c0 04             	add    $0x4,%eax
  800448:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800450:	85 ff                	test   %edi,%edi
  800452:	b8 4d 11 80 00       	mov    $0x80114d,%eax
  800457:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045e:	0f 8e bd 00 00 00    	jle    800521 <vprintfmt+0x232>
  800464:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800468:	75 0e                	jne    800478 <vprintfmt+0x189>
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800476:	eb 6d                	jmp    8004e5 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	57                   	push   %edi
  80047f:	e8 6d 03 00 00       	call   8007f1 <strnlen>
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800499:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1bd>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1ae>
  8004b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	0f 49 c1             	cmovns %ecx,%eax
  8004c0:	29 c1                	sub    %eax,%ecx
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	eb 16                	jmp    8004e5 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	75 31                	jne    800506 <vprintfmt+0x217>
					putch(ch, putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	50                   	push   %eax
  8004dc:	ff 55 08             	call   *0x8(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	83 eb 01             	sub    $0x1,%ebx
  8004e5:	83 c7 01             	add    $0x1,%edi
  8004e8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ec:	0f be c2             	movsbl %dl,%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	74 59                	je     80054c <vprintfmt+0x25d>
  8004f3:	85 f6                	test   %esi,%esi
  8004f5:	78 d8                	js     8004cf <vprintfmt+0x1e0>
  8004f7:	83 ee 01             	sub    $0x1,%esi
  8004fa:	79 d3                	jns    8004cf <vprintfmt+0x1e0>
  8004fc:	89 df                	mov    %ebx,%edi
  8004fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800504:	eb 37                	jmp    80053d <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800506:	0f be d2             	movsbl %dl,%edx
  800509:	83 ea 20             	sub    $0x20,%edx
  80050c:	83 fa 5e             	cmp    $0x5e,%edx
  80050f:	76 c4                	jbe    8004d5 <vprintfmt+0x1e6>
					putch('?', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	6a 3f                	push   $0x3f
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb c1                	jmp    8004e2 <vprintfmt+0x1f3>
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052d:	eb b6                	jmp    8004e5 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	6a 20                	push   $0x20
  800535:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800537:	83 ef 01             	sub    $0x1,%edi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f ee                	jg     80052f <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800541:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
  800547:	e9 1a 01 00 00       	jmp    800666 <vprintfmt+0x377>
  80054c:	89 df                	mov    %ebx,%edi
  80054e:	8b 75 08             	mov    0x8(%ebp),%esi
  800551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800554:	eb e7                	jmp    80053d <vprintfmt+0x24e>
	if (lflag >= 2)
  800556:	83 f9 01             	cmp    $0x1,%ecx
  800559:	7e 3f                	jle    80059a <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 50 04             	mov    0x4(%eax),%edx
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 08             	lea    0x8(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800572:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800576:	79 5c                	jns    8005d4 <vprintfmt+0x2e5>
				putch('-', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 2d                	push   $0x2d
  80057e:	ff d6                	call   *%esi
				num = -(long long) num;
  800580:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800583:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800586:	f7 da                	neg    %edx
  800588:	83 d1 00             	adc    $0x0,%ecx
  80058b:	f7 d9                	neg    %ecx
  80058d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
  800595:	e9 b2 00 00 00       	jmp    80064c <vprintfmt+0x35d>
	else if (lflag)
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	75 1b                	jne    8005b9 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 c1                	mov    %eax,%ecx
  8005a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b7:	eb b9                	jmp    800572 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 c1                	mov    %eax,%ecx
  8005c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d2:	eb 9e                	jmp    800572 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005df:	eb 6b                	jmp    80064c <vprintfmt+0x35d>
	if (lflag >= 2)
  8005e1:	83 f9 01             	cmp    $0x1,%ecx
  8005e4:	7e 15                	jle    8005fb <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ee:	8d 40 08             	lea    0x8(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f9:	eb 51                	jmp    80064c <vprintfmt+0x35d>
	else if (lflag)
  8005fb:	85 c9                	test   %ecx,%ecx
  8005fd:	75 17                	jne    800616 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	b9 00 00 00 00       	mov    $0x0,%ecx
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800614:	eb 36                	jmp    80064c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800620:	8d 40 04             	lea    0x4(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062b:	eb 1f                	jmp    80064c <vprintfmt+0x35d>
	if (lflag >= 2)
  80062d:	83 f9 01             	cmp    $0x1,%ecx
  800630:	7e 5b                	jle    80068d <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800640:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800643:	89 d1                	mov    %edx,%ecx
  800645:	89 c2                	mov    %eax,%edx
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800653:	57                   	push   %edi
  800654:	ff 75 e0             	pushl  -0x20(%ebp)
  800657:	50                   	push   %eax
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	e8 a3 fb ff ff       	call   800206 <printnum>
			break;
  800663:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800669:	83 c7 01             	add    $0x1,%edi
  80066c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800670:	83 f8 25             	cmp    $0x25,%eax
  800673:	0f 84 8d fc ff ff    	je     800306 <vprintfmt+0x17>
			if (ch == '\0')
  800679:	85 c0                	test   %eax,%eax
  80067b:	0f 84 e8 00 00 00    	je     800769 <vprintfmt+0x47a>
			putch(ch, putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	50                   	push   %eax
  800686:	ff d6                	call   *%esi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb dc                	jmp    800669 <vprintfmt+0x37a>
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	75 13                	jne    8006a4 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	89 d0                	mov    %edx,%eax
  800698:	99                   	cltd   
  800699:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80069f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a2:	eb 9f                	jmp    800643 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	89 d0                	mov    %edx,%eax
  8006ab:	99                   	cltd   
  8006ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006af:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b5:	eb 8c                	jmp    800643 <vprintfmt+0x354>
			putch('0', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 30                	push   $0x30
  8006bd:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bf:	83 c4 08             	add    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 78                	push   $0x78
  8006c5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	e9 68 ff ff ff       	jmp    80064c <vprintfmt+0x35d>
	if (lflag >= 2)
  8006e4:	83 f9 01             	cmp    $0x1,%ecx
  8006e7:	7e 18                	jle    800701 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8b 10                	mov    (%eax),%edx
  8006ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f1:	8d 40 08             	lea    0x8(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fc:	e9 4b ff ff ff       	jmp    80064c <vprintfmt+0x35d>
	else if (lflag)
  800701:	85 c9                	test   %ecx,%ecx
  800703:	75 1a                	jne    80071f <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
  80071a:	e9 2d ff ff ff       	jmp    80064c <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
  800734:	e9 13 ff ff ff       	jmp    80064c <vprintfmt+0x35d>
			putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 25                	push   $0x25
  80073f:	ff d6                	call   *%esi
			break;
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	e9 1d ff ff ff       	jmp    800666 <vprintfmt+0x377>
			putch('%', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 25                	push   $0x25
  80074f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	89 f8                	mov    %edi,%eax
  800756:	eb 03                	jmp    80075b <vprintfmt+0x46c>
  800758:	83 e8 01             	sub    $0x1,%eax
  80075b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075f:	75 f7                	jne    800758 <vprintfmt+0x469>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800764:	e9 fd fe ff ff       	jmp    800666 <vprintfmt+0x377>
}
  800769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 18             	sub    $0x18,%esp
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800780:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800784:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 26                	je     8007b8 <vsnprintf+0x47>
  800792:	85 d2                	test   %edx,%edx
  800794:	7e 22                	jle    8007b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800796:	ff 75 14             	pushl  0x14(%ebp)
  800799:	ff 75 10             	pushl  0x10(%ebp)
  80079c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	68 b5 02 80 00       	push   $0x8002b5
  8007a5:	e8 45 fb ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b3:	83 c4 10             	add    $0x10,%esp
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    
		return -E_INVAL;
  8007b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bd:	eb f7                	jmp    8007b6 <vsnprintf+0x45>

008007bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c8:	50                   	push   %eax
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	ff 75 08             	pushl  0x8(%ebp)
  8007d2:	e8 9a ff ff ff       	call   800771 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	eb 03                	jmp    8007e9 <strlen+0x10>
		n++;
  8007e6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ed:	75 f7                	jne    8007e6 <strlen+0xd>
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	eb 03                	jmp    800804 <strnlen+0x13>
		n++;
  800801:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	39 d0                	cmp    %edx,%eax
  800806:	74 06                	je     80080e <strnlen+0x1d>
  800808:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080c:	75 f3                	jne    800801 <strnlen+0x10>
	return n;
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081a:	89 c2                	mov    %eax,%edx
  80081c:	83 c1 01             	add    $0x1,%ecx
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800826:	88 5a ff             	mov    %bl,-0x1(%edx)
  800829:	84 db                	test   %bl,%bl
  80082b:	75 ef                	jne    80081c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800837:	53                   	push   %ebx
  800838:	e8 9c ff ff ff       	call   8007d9 <strlen>
  80083d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	01 d8                	add    %ebx,%eax
  800845:	50                   	push   %eax
  800846:	e8 c5 ff ff ff       	call   800810 <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f2                	mov    %esi,%edx
  800864:	eb 0f                	jmp    800875 <strncpy+0x23>
		*dst++ = *src;
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	0f b6 01             	movzbl (%ecx),%eax
  80086c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 39 01             	cmpb   $0x1,(%ecx)
  800872:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800875:	39 da                	cmp    %ebx,%edx
  800877:	75 ed                	jne    800866 <strncpy+0x14>
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 c9                	test   %ecx,%ecx
  800895:	75 0b                	jne    8008a2 <strlcpy+0x23>
  800897:	eb 17                	jmp    8008b0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	83 c0 01             	add    $0x1,%eax
  80089f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a2:	39 d8                	cmp    %ebx,%eax
  8008a4:	74 07                	je     8008ad <strlcpy+0x2e>
  8008a6:	0f b6 0a             	movzbl (%edx),%ecx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 ec                	jne    800899 <strlcpy+0x1a>
		*dst = '\0';
  8008ad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 06                	jmp    8008c7 <strcmp+0x11>
		p++, q++;
  8008c1:	83 c1 01             	add    $0x1,%ecx
  8008c4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c7:	0f b6 01             	movzbl (%ecx),%eax
  8008ca:	84 c0                	test   %al,%al
  8008cc:	74 04                	je     8008d2 <strcmp+0x1c>
  8008ce:	3a 02                	cmp    (%edx),%al
  8008d0:	74 ef                	je     8008c1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 c0             	movzbl %al,%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 c3                	mov    %eax,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008eb:	eb 06                	jmp    8008f3 <strncmp+0x17>
		n--, p++, q++;
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f3:	39 d8                	cmp    %ebx,%eax
  8008f5:	74 16                	je     80090d <strncmp+0x31>
  8008f7:	0f b6 08             	movzbl (%eax),%ecx
  8008fa:	84 c9                	test   %cl,%cl
  8008fc:	74 04                	je     800902 <strncmp+0x26>
  8008fe:	3a 0a                	cmp    (%edx),%cl
  800900:	74 eb                	je     8008ed <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800902:	0f b6 00             	movzbl (%eax),%eax
  800905:	0f b6 12             	movzbl (%edx),%edx
  800908:	29 d0                	sub    %edx,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb f6                	jmp    80090a <strncmp+0x2e>

00800914 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	84 d2                	test   %dl,%dl
  800923:	74 09                	je     80092e <strchr+0x1a>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0a                	je     800933 <strchr+0x1f>
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	eb f0                	jmp    80091e <strchr+0xa>
			return (char *) s;
	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093f:	eb 03                	jmp    800944 <strfind+0xf>
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800947:	38 ca                	cmp    %cl,%dl
  800949:	74 04                	je     80094f <strfind+0x1a>
  80094b:	84 d2                	test   %dl,%dl
  80094d:	75 f2                	jne    800941 <strfind+0xc>
			break;
	return (char *) s;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 13                	je     800974 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800961:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800967:	75 05                	jne    80096e <memset+0x1d>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	74 0d                	je     80097b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    
		c &= 0xFF;
  80097b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 18             	shl    $0x18,%eax
  800989:	89 d6                	mov    %edx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 c2                	or     %eax,%edx
  800992:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800997:	89 d0                	mov    %edx,%eax
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb d6                	jmp    800974 <memset+0x23>

0080099e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ac:	39 c6                	cmp    %eax,%esi
  8009ae:	73 35                	jae    8009e5 <memmove+0x47>
  8009b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b3:	39 c2                	cmp    %eax,%edx
  8009b5:	76 2e                	jbe    8009e5 <memmove+0x47>
		s += n;
		d += n;
  8009b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	09 fe                	or     %edi,%esi
  8009be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c4:	74 0c                	je     8009d2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 21                	jmp    8009f3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 ef                	jne    8009c6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d7:	83 ef 04             	sub    $0x4,%edi
  8009da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb ea                	jmp    8009cf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	89 f2                	mov    %esi,%edx
  8009e7:	09 c2                	or     %eax,%edx
  8009e9:	f6 c2 03             	test   $0x3,%dl
  8009ec:	74 09                	je     8009f7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 f2                	jne    8009ee <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ff:	89 c7                	mov    %eax,%edi
  800a01:	fc                   	cld    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb ed                	jmp    8009f3 <memmove+0x55>

00800a06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a09:	ff 75 10             	pushl  0x10(%ebp)
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	ff 75 08             	pushl  0x8(%ebp)
  800a12:	e8 87 ff ff ff       	call   80099e <memmove>
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a24:	89 c6                	mov    %eax,%esi
  800a26:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 f0                	cmp    %esi,%eax
  800a2b:	74 1c                	je     800a49 <memcmp+0x30>
		if (*s1 != *s2)
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	0f b6 1a             	movzbl (%edx),%ebx
  800a33:	38 d9                	cmp    %bl,%cl
  800a35:	75 08                	jne    800a3f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	83 c2 01             	add    $0x1,%edx
  800a3d:	eb ea                	jmp    800a29 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a3f:	0f b6 c1             	movzbl %cl,%eax
  800a42:	0f b6 db             	movzbl %bl,%ebx
  800a45:	29 d8                	sub    %ebx,%eax
  800a47:	eb 05                	jmp    800a4e <memcmp+0x35>
	}

	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a60:	39 d0                	cmp    %edx,%eax
  800a62:	73 09                	jae    800a6d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a64:	38 08                	cmp    %cl,(%eax)
  800a66:	74 05                	je     800a6d <memfind+0x1b>
	for (; s < ends; s++)
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	eb f3                	jmp    800a60 <memfind+0xe>
			break;
	return (void *) s;
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	eb 03                	jmp    800a80 <strtol+0x11>
		s++;
  800a7d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a80:	0f b6 01             	movzbl (%ecx),%eax
  800a83:	3c 20                	cmp    $0x20,%al
  800a85:	74 f6                	je     800a7d <strtol+0xe>
  800a87:	3c 09                	cmp    $0x9,%al
  800a89:	74 f2                	je     800a7d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a8b:	3c 2b                	cmp    $0x2b,%al
  800a8d:	74 2e                	je     800abd <strtol+0x4e>
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a94:	3c 2d                	cmp    $0x2d,%al
  800a96:	74 2f                	je     800ac7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a98:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9e:	75 05                	jne    800aa5 <strtol+0x36>
  800aa0:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa3:	74 2c                	je     800ad1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	75 0a                	jne    800ab3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aae:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab1:	74 28                	je     800adb <strtol+0x6c>
		base = 10;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800abb:	eb 50                	jmp    800b0d <strtol+0x9e>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb d1                	jmp    800a98 <strtol+0x29>
		s++, neg = 1;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	bf 01 00 00 00       	mov    $0x1,%edi
  800acf:	eb c7                	jmp    800a98 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad5:	74 0e                	je     800ae5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 d8                	jne    800ab3 <strtol+0x44>
		s++, base = 8;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae3:	eb ce                	jmp    800ab3 <strtol+0x44>
		s += 2, base = 16;
  800ae5:	83 c1 02             	add    $0x2,%ecx
  800ae8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aed:	eb c4                	jmp    800ab3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aef:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 29                	ja     800b22 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b02:	7d 30                	jge    800b34 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0d:	0f b6 11             	movzbl (%ecx),%edx
  800b10:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b13:	89 f3                	mov    %esi,%ebx
  800b15:	80 fb 09             	cmp    $0x9,%bl
  800b18:	77 d5                	ja     800aef <strtol+0x80>
			dig = *s - '0';
  800b1a:	0f be d2             	movsbl %dl,%edx
  800b1d:	83 ea 30             	sub    $0x30,%edx
  800b20:	eb dd                	jmp    800aff <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 08                	ja     800b34 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b2c:	0f be d2             	movsbl %dl,%edx
  800b2f:	83 ea 37             	sub    $0x37,%edx
  800b32:	eb cb                	jmp    800aff <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b38:	74 05                	je     800b3f <strtol+0xd0>
		*endptr = (char *) s;
  800b3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	f7 da                	neg    %edx
  800b43:	85 ff                	test   %edi,%edi
  800b45:	0f 45 c2             	cmovne %edx,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	89 c3                	mov    %eax,%ebx
  800b60:	89 c7                	mov    %eax,%edi
  800b62:	89 c6                	mov    %eax,%esi
  800b64:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7b:	89 d1                	mov    %edx,%ecx
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	89 d7                	mov    %edx,%edi
  800b81:	89 d6                	mov    %edx,%esi
  800b83:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	89 cb                	mov    %ecx,%ebx
  800ba2:	89 cf                	mov    %ecx,%edi
  800ba4:	89 ce                	mov    %ecx,%esi
  800ba6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7f 08                	jg     800bb4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 03                	push   $0x3
  800bba:	68 84 13 80 00       	push   $0x801384
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 a1 13 80 00       	push   $0x8013a1
  800bc6:	e8 4c f5 ff ff       	call   800117 <_panic>

00800bcb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_yield>:

void
sys_yield(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	be 00 00 00 00       	mov    $0x0,%esi
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c25:	89 f7                	mov    %esi,%edi
  800c27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7f 08                	jg     800c35 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 04                	push   $0x4
  800c3b:	68 84 13 80 00       	push   $0x801384
  800c40:	6a 23                	push   $0x23
  800c42:	68 a1 13 80 00       	push   $0x8013a1
  800c47:	e8 cb f4 ff ff       	call   800117 <_panic>

00800c4c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c66:	8b 75 18             	mov    0x18(%ebp),%esi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 05                	push   $0x5
  800c7d:	68 84 13 80 00       	push   $0x801384
  800c82:	6a 23                	push   $0x23
  800c84:	68 a1 13 80 00       	push   $0x8013a1
  800c89:	e8 89 f4 ff ff       	call   800117 <_panic>

00800c8e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 06                	push   $0x6
  800cbf:	68 84 13 80 00       	push   $0x801384
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 a1 13 80 00       	push   $0x8013a1
  800ccb:	e8 47 f4 ff ff       	call   800117 <_panic>

00800cd0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce9:	89 df                	mov    %ebx,%edi
  800ceb:	89 de                	mov    %ebx,%esi
  800ced:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7f 08                	jg     800cfb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 08                	push   $0x8
  800d01:	68 84 13 80 00       	push   $0x801384
  800d06:	6a 23                	push   $0x23
  800d08:	68 a1 13 80 00       	push   $0x8013a1
  800d0d:	e8 05 f4 ff ff       	call   800117 <_panic>

00800d12 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7f 08                	jg     800d3d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 09                	push   $0x9
  800d43:	68 84 13 80 00       	push   $0x801384
  800d48:	6a 23                	push   $0x23
  800d4a:	68 a1 13 80 00       	push   $0x8013a1
  800d4f:	e8 c3 f3 ff ff       	call   800117 <_panic>

00800d54 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d70:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8d:	89 cb                	mov    %ecx,%ebx
  800d8f:	89 cf                	mov    %ecx,%edi
  800d91:	89 ce                	mov    %ecx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 0c                	push   $0xc
  800da7:	68 84 13 80 00       	push   $0x801384
  800dac:	6a 23                	push   $0x23
  800dae:	68 a1 13 80 00       	push   $0x8013a1
  800db3:	e8 5f f3 ff ff       	call   800117 <_panic>

00800db8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 04             	sub    $0x4,%esp
	int r;
	envid_t trap_env_id = sys_getenvid();
  800dbf:	e8 07 fe ff ff       	call   800bcb <sys_getenvid>
  800dc4:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800dc6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dcd:	74 22                	je     800df1 <set_pgfault_handler+0x39>
		// LAB 4: Your code here.
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
		
		//panic("set_pgfault_handler not implemented");
	}
	if (sys_env_set_pgfault_upcall(trap_env_id, _pgfault_upcall)) {
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	68 1a 0e 80 00       	push   $0x800e1a
  800dd7:	53                   	push   %ebx
  800dd8:	e8 35 ff ff ff       	call   800d12 <sys_env_set_pgfault_upcall>
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	75 22                	jne    800e06 <set_pgfault_handler+0x4e>
		panic("set pgfault upcall failed!");
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800def:	c9                   	leave  
  800df0:	c3                   	ret    
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	6a 06                	push   $0x6
  800df6:	68 00 f0 bf ee       	push   $0xeebff000
  800dfb:	50                   	push   %eax
  800dfc:	e8 08 fe ff ff       	call   800c09 <sys_page_alloc>
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	eb c9                	jmp    800dcf <set_pgfault_handler+0x17>
		panic("set pgfault upcall failed!");
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	68 af 13 80 00       	push   $0x8013af
  800e0e:	6a 25                	push   $0x25
  800e10:	68 ca 13 80 00       	push   $0x8013ca
  800e15:	e8 fd f2 ff ff       	call   800117 <_panic>

00800e1a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e1a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e1b:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e20:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e22:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	lea 48(%esp), %eax
  800e25:	8d 44 24 30          	lea    0x30(%esp),%eax
	movl (%eax), %eax
  800e29:	8b 00                	mov    (%eax),%eax
	lea 40(%esp), %ebx
  800e2b:	8d 5c 24 28          	lea    0x28(%esp),%ebx
	movl (%ebx), %ebx
  800e2f:	8b 1b                	mov    (%ebx),%ebx
	subl $4, %eax
  800e31:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  800e34:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	add $8, %esp
  800e36:	83 c4 08             	add    $0x8,%esp
	pop %edi
  800e39:	5f                   	pop    %edi
	pop %esi
  800e3a:	5e                   	pop    %esi
	pop %ebp
  800e3b:	5d                   	pop    %ebp
	add $4, %esp
  800e3c:	83 c4 04             	add    $0x4,%esp
	pop %ebx
  800e3f:	5b                   	pop    %ebx
	pop %edx
  800e40:	5a                   	pop    %edx
	pop %ecx
  800e41:	59                   	pop    %ecx
	pop %eax
  800e42:	58                   	pop    %eax
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  800e43:	83 c4 04             	add    $0x4,%esp
	popfl
  800e46:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800e47:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	sub $4, %esp
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	c3                   	ret    
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e67:	85 d2                	test   %edx,%edx
  800e69:	75 35                	jne    800ea0 <__udivdi3+0x50>
  800e6b:	39 f3                	cmp    %esi,%ebx
  800e6d:	0f 87 bd 00 00 00    	ja     800f30 <__udivdi3+0xe0>
  800e73:	85 db                	test   %ebx,%ebx
  800e75:	89 d9                	mov    %ebx,%ecx
  800e77:	75 0b                	jne    800e84 <__udivdi3+0x34>
  800e79:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7e:	31 d2                	xor    %edx,%edx
  800e80:	f7 f3                	div    %ebx
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	31 d2                	xor    %edx,%edx
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	f7 f1                	div    %ecx
  800e8a:	89 c6                	mov    %eax,%esi
  800e8c:	89 e8                	mov    %ebp,%eax
  800e8e:	89 f7                	mov    %esi,%edi
  800e90:	f7 f1                	div    %ecx
  800e92:	89 fa                	mov    %edi,%edx
  800e94:	83 c4 1c             	add    $0x1c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 f2                	cmp    %esi,%edx
  800ea2:	77 7c                	ja     800f20 <__udivdi3+0xd0>
  800ea4:	0f bd fa             	bsr    %edx,%edi
  800ea7:	83 f7 1f             	xor    $0x1f,%edi
  800eaa:	0f 84 98 00 00 00    	je     800f48 <__udivdi3+0xf8>
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb7:	29 f8                	sub    %edi,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	d3 ea                	shr    %cl,%edx
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 d1                	or     %edx,%ecx
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 c1                	mov    %eax,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	d3 e6                	shl    %cl,%esi
  800ee1:	89 eb                	mov    %ebp,%ebx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 de                	or     %ebx,%esi
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	f7 74 24 08          	divl   0x8(%esp)
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	f7 64 24 0c          	mull   0xc(%esp)
  800ef7:	39 d6                	cmp    %edx,%esi
  800ef9:	72 0c                	jb     800f07 <__udivdi3+0xb7>
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e5                	shl    %cl,%ebp
  800eff:	39 c5                	cmp    %eax,%ebp
  800f01:	73 5d                	jae    800f60 <__udivdi3+0x110>
  800f03:	39 d6                	cmp    %edx,%esi
  800f05:	75 59                	jne    800f60 <__udivdi3+0x110>
  800f07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f0a:	31 ff                	xor    %edi,%edi
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	83 c4 1c             	add    $0x1c,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
  800f16:	8d 76 00             	lea    0x0(%esi),%esi
  800f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f20:	31 ff                	xor    %edi,%edi
  800f22:	31 c0                	xor    %eax,%eax
  800f24:	89 fa                	mov    %edi,%edx
  800f26:	83 c4 1c             	add    $0x1c,%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	89 e8                	mov    %ebp,%eax
  800f34:	89 f2                	mov    %esi,%edx
  800f36:	f7 f3                	div    %ebx
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	72 06                	jb     800f52 <__udivdi3+0x102>
  800f4c:	31 c0                	xor    %eax,%eax
  800f4e:	39 eb                	cmp    %ebp,%ebx
  800f50:	77 d2                	ja     800f24 <__udivdi3+0xd4>
  800f52:	b8 01 00 00 00       	mov    $0x1,%eax
  800f57:	eb cb                	jmp    800f24 <__udivdi3+0xd4>
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	31 ff                	xor    %edi,%edi
  800f64:	eb be                	jmp    800f24 <__udivdi3+0xd4>
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f87:	85 ed                	test   %ebp,%ebp
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	89 da                	mov    %ebx,%edx
  800f8d:	75 19                	jne    800fa8 <__umoddi3+0x38>
  800f8f:	39 df                	cmp    %ebx,%edi
  800f91:	0f 86 b1 00 00 00    	jbe    801048 <__umoddi3+0xd8>
  800f97:	f7 f7                	div    %edi
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 1c             	add    $0x1c,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	39 dd                	cmp    %ebx,%ebp
  800faa:	77 f1                	ja     800f9d <__umoddi3+0x2d>
  800fac:	0f bd cd             	bsr    %ebp,%ecx
  800faf:	83 f1 1f             	xor    $0x1f,%ecx
  800fb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb6:	0f 84 b4 00 00 00    	je     801070 <__umoddi3+0x100>
  800fbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fc7:	29 c2                	sub    %eax,%edx
  800fc9:	89 c1                	mov    %eax,%ecx
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	89 d1                	mov    %edx,%ecx
  800fd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd5:	d3 e8                	shr    %cl,%eax
  800fd7:	09 c5                	or     %eax,%ebp
  800fd9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	d3 e7                	shl    %cl,%edi
  800fe1:	89 d1                	mov    %edx,%ecx
  800fe3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	d3 ef                	shr    %cl,%edi
  800feb:	89 c1                	mov    %eax,%ecx
  800fed:	89 f0                	mov    %esi,%eax
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 fa                	mov    %edi,%edx
  800ff5:	d3 e8                	shr    %cl,%eax
  800ff7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffc:	09 d8                	or     %ebx,%eax
  800ffe:	f7 f5                	div    %ebp
  801000:	d3 e6                	shl    %cl,%esi
  801002:	89 d1                	mov    %edx,%ecx
  801004:	f7 64 24 08          	mull   0x8(%esp)
  801008:	39 d1                	cmp    %edx,%ecx
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	89 d7                	mov    %edx,%edi
  80100e:	72 06                	jb     801016 <__umoddi3+0xa6>
  801010:	75 0e                	jne    801020 <__umoddi3+0xb0>
  801012:	39 c6                	cmp    %eax,%esi
  801014:	73 0a                	jae    801020 <__umoddi3+0xb0>
  801016:	2b 44 24 08          	sub    0x8(%esp),%eax
  80101a:	19 ea                	sbb    %ebp,%edx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	89 ca                	mov    %ecx,%edx
  801022:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801027:	29 de                	sub    %ebx,%esi
  801029:	19 fa                	sbb    %edi,%edx
  80102b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80102f:	89 d0                	mov    %edx,%eax
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 d9                	mov    %ebx,%ecx
  801035:	d3 ee                	shr    %cl,%esi
  801037:	d3 ea                	shr    %cl,%edx
  801039:	09 f0                	or     %esi,%eax
  80103b:	83 c4 1c             	add    $0x1c,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	85 ff                	test   %edi,%edi
  80104a:	89 f9                	mov    %edi,%ecx
  80104c:	75 0b                	jne    801059 <__umoddi3+0xe9>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f7                	div    %edi
  801057:	89 c1                	mov    %eax,%ecx
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f1                	div    %ecx
  80105f:	89 f0                	mov    %esi,%eax
  801061:	f7 f1                	div    %ecx
  801063:	e9 31 ff ff ff       	jmp    800f99 <__umoddi3+0x29>
  801068:	90                   	nop
  801069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801070:	39 dd                	cmp    %ebx,%ebp
  801072:	72 08                	jb     80107c <__umoddi3+0x10c>
  801074:	39 f7                	cmp    %esi,%edi
  801076:	0f 87 21 ff ff ff    	ja     800f9d <__umoddi3+0x2d>
  80107c:	89 da                	mov    %ebx,%edx
  80107e:	89 f0                	mov    %esi,%eax
  801080:	29 f8                	sub    %edi,%eax
  801082:	19 ea                	sbb    %ebp,%edx
  801084:	e9 14 ff ff ff       	jmp    800f9d <__umoddi3+0x2d>
