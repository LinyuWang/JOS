
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
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
  800040:	68 c0 10 80 00       	push   $0x8010c0
  800045:	e8 bd 01 00 00       	call   800207 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 c0 0b 00 00       	call   800c1e <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 0c 11 80 00       	push   $0x80110c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 61 07 00 00       	call   8007d4 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 e0 10 80 00       	push   $0x8010e0
  800085:	6a 0e                	push   $0xe
  800087:	68 ca 10 80 00       	push   $0x8010ca
  80008c:	e8 9b 00 00 00       	call   80012c <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 2c 0d 00 00       	call   800dcd <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 dc 10 80 00       	push   $0x8010dc
  8000ae:	e8 54 01 00 00       	call   800207 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 dc 10 80 00       	push   $0x8010dc
  8000c0:	e8 42 01 00 00       	call   800207 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d5:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000dc:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000df:	e8 fc 0a 00 00       	call   800be0 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f1:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f6:	85 db                	test   %ebx,%ebx
  8000f8:	7e 07                	jle    800101 <libmain+0x37>
		binaryname = argv[0];
  8000fa:	8b 06                	mov    (%esi),%eax
  8000fc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 86 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80010b:	e8 0a 00 00 00       	call   80011a <exit>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800120:	6a 00                	push   $0x0
  800122:	e8 78 0a 00 00       	call   800b9f <sys_env_destroy>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013a:	e8 a1 0a 00 00       	call   800be0 <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	56                   	push   %esi
  800149:	50                   	push   %eax
  80014a:	68 38 11 80 00       	push   $0x801138
  80014f:	e8 b3 00 00 00       	call   800207 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	53                   	push   %ebx
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 56 00 00 00       	call   8001b6 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 de 10 80 00 	movl   $0x8010de,(%esp)
  800167:	e8 9b 00 00 00       	call   800207 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>

00800172 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	53                   	push   %ebx
  800176:	83 ec 04             	sub    $0x4,%esp
  800179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017c:	8b 13                	mov    (%ebx),%edx
  80017e:	8d 42 01             	lea    0x1(%edx),%eax
  800181:	89 03                	mov    %eax,(%ebx)
  800183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800186:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	74 09                	je     80019a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800191:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800198:	c9                   	leave  
  800199:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	68 ff 00 00 00       	push   $0xff
  8001a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 b7 09 00 00       	call   800b62 <sys_cputs>
		b->idx = 0;
  8001ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b1:	83 c4 10             	add    $0x10,%esp
  8001b4:	eb db                	jmp    800191 <putch+0x1f>

008001b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c6:	00 00 00 
	b.cnt = 0;
  8001c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001df:	50                   	push   %eax
  8001e0:	68 72 01 80 00       	push   $0x800172
  8001e5:	e8 1a 01 00 00       	call   800304 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ea:	83 c4 08             	add    $0x8,%esp
  8001ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f9:	50                   	push   %eax
  8001fa:	e8 63 09 00 00       	call   800b62 <sys_cputs>

	return b.cnt;
}
  8001ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800210:	50                   	push   %eax
  800211:	ff 75 08             	pushl  0x8(%ebp)
  800214:	e8 9d ff ff ff       	call   8001b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	57                   	push   %edi
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 1c             	sub    $0x1c,%esp
  800224:	89 c7                	mov    %eax,%edi
  800226:	89 d6                	mov    %edx,%esi
  800228:	8b 45 08             	mov    0x8(%ebp),%eax
  80022b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800231:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800234:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800242:	39 d3                	cmp    %edx,%ebx
  800244:	72 05                	jb     80024b <printnum+0x30>
  800246:	39 45 10             	cmp    %eax,0x10(%ebp)
  800249:	77 7a                	ja     8002c5 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	ff 75 18             	pushl  0x18(%ebp)
  800251:	8b 45 14             	mov    0x14(%ebp),%eax
  800254:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800261:	ff 75 e0             	pushl  -0x20(%ebp)
  800264:	ff 75 dc             	pushl  -0x24(%ebp)
  800267:	ff 75 d8             	pushl  -0x28(%ebp)
  80026a:	e8 01 0c 00 00       	call   800e70 <__udivdi3>
  80026f:	83 c4 18             	add    $0x18,%esp
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	89 f2                	mov    %esi,%edx
  800276:	89 f8                	mov    %edi,%eax
  800278:	e8 9e ff ff ff       	call   80021b <printnum>
  80027d:	83 c4 20             	add    $0x20,%esp
  800280:	eb 13                	jmp    800295 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	ff 75 18             	pushl  0x18(%ebp)
  800289:	ff d7                	call   *%edi
  80028b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028e:	83 eb 01             	sub    $0x1,%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f ed                	jg     800282 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029f:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 e3 0c 00 00       	call   800f90 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 5c 11 80 00 	movsbl 0x80115c(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    
  8002c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c8:	eb c4                	jmp    80028e <printnum+0x73>

008002ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d9:	73 0a                	jae    8002e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	88 02                	mov    %al,(%edx)
}
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <printfmt>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f0:	50                   	push   %eax
  8002f1:	ff 75 10             	pushl  0x10(%ebp)
  8002f4:	ff 75 0c             	pushl  0xc(%ebp)
  8002f7:	ff 75 08             	pushl  0x8(%ebp)
  8002fa:	e8 05 00 00 00       	call   800304 <vprintfmt>
}
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <vprintfmt>:
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 2c             	sub    $0x2c,%esp
  80030d:	8b 75 08             	mov    0x8(%ebp),%esi
  800310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800313:	8b 7d 10             	mov    0x10(%ebp),%edi
  800316:	e9 63 03 00 00       	jmp    80067e <vprintfmt+0x37a>
		padc = ' ';
  80031b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800326:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80032d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800334:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8d 47 01             	lea    0x1(%edi),%eax
  80033c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033f:	0f b6 17             	movzbl (%edi),%edx
  800342:	8d 42 dd             	lea    -0x23(%edx),%eax
  800345:	3c 55                	cmp    $0x55,%al
  800347:	0f 87 11 04 00 00    	ja     80075e <vprintfmt+0x45a>
  80034d:	0f b6 c0             	movzbl %al,%eax
  800350:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035e:	eb d9                	jmp    800339 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800363:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800367:	eb d0                	jmp    800339 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800369:	0f b6 d2             	movzbl %dl,%edx
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80036f:	b8 00 00 00 00       	mov    $0x0,%eax
  800374:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800377:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80037e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800381:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800384:	83 f9 09             	cmp    $0x9,%ecx
  800387:	77 55                	ja     8003de <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800389:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038c:	eb e9                	jmp    800377 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 40 04             	lea    0x4(%eax),%eax
  80039c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a6:	79 91                	jns    800339 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b5:	eb 82                	jmp    800339 <vprintfmt+0x35>
  8003b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c1:	0f 49 d0             	cmovns %eax,%edx
  8003c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ca:	e9 6a ff ff ff       	jmp    800339 <vprintfmt+0x35>
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d9:	e9 5b ff ff ff       	jmp    800339 <vprintfmt+0x35>
  8003de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e4:	eb bc                	jmp    8003a2 <vprintfmt+0x9e>
			lflag++;
  8003e6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ec:	e9 48 ff ff ff       	jmp    800339 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 78 04             	lea    0x4(%eax),%edi
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800402:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800405:	e9 71 02 00 00       	jmp    80067b <vprintfmt+0x377>
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 78 04             	lea    0x4(%eax),%edi
  800410:	8b 00                	mov    (%eax),%eax
  800412:	99                   	cltd   
  800413:	31 d0                	xor    %edx,%eax
  800415:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800417:	83 f8 08             	cmp    $0x8,%eax
  80041a:	7f 23                	jg     80043f <vprintfmt+0x13b>
  80041c:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800423:	85 d2                	test   %edx,%edx
  800425:	74 18                	je     80043f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800427:	52                   	push   %edx
  800428:	68 7d 11 80 00       	push   $0x80117d
  80042d:	53                   	push   %ebx
  80042e:	56                   	push   %esi
  80042f:	e8 b3 fe ff ff       	call   8002e7 <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800437:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043a:	e9 3c 02 00 00       	jmp    80067b <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  80043f:	50                   	push   %eax
  800440:	68 74 11 80 00       	push   $0x801174
  800445:	53                   	push   %ebx
  800446:	56                   	push   %esi
  800447:	e8 9b fe ff ff       	call   8002e7 <printfmt>
  80044c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800452:	e9 24 02 00 00       	jmp    80067b <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	83 c0 04             	add    $0x4,%eax
  80045d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 6d 11 80 00       	mov    $0x80116d,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e bd 00 00 00    	jle    800536 <vprintfmt+0x232>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	75 0e                	jne    80048d <vprintfmt+0x189>
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048b:	eb 6d                	jmp    8004fa <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 d0             	pushl  -0x30(%ebp)
  800493:	57                   	push   %edi
  800494:	e8 6d 03 00 00       	call   800806 <strnlen>
  800499:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049c:	29 c1                	sub    %eax,%ecx
  80049e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ae:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	eb 0f                	jmp    8004c1 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ef 01             	sub    $0x1,%edi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 ff                	test   %edi,%edi
  8004c3:	7f ed                	jg     8004b2 <vprintfmt+0x1ae>
  8004c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004cb:	85 c9                	test   %ecx,%ecx
  8004cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d2:	0f 49 c1             	cmovns %ecx,%eax
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e0:	89 cb                	mov    %ecx,%ebx
  8004e2:	eb 16                	jmp    8004fa <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e8:	75 31                	jne    80051b <vprintfmt+0x217>
					putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	50                   	push   %eax
  8004f1:	ff 55 08             	call   *0x8(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 eb 01             	sub    $0x1,%ebx
  8004fa:	83 c7 01             	add    $0x1,%edi
  8004fd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800501:	0f be c2             	movsbl %dl,%eax
  800504:	85 c0                	test   %eax,%eax
  800506:	74 59                	je     800561 <vprintfmt+0x25d>
  800508:	85 f6                	test   %esi,%esi
  80050a:	78 d8                	js     8004e4 <vprintfmt+0x1e0>
  80050c:	83 ee 01             	sub    $0x1,%esi
  80050f:	79 d3                	jns    8004e4 <vprintfmt+0x1e0>
  800511:	89 df                	mov    %ebx,%edi
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	eb 37                	jmp    800552 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80051b:	0f be d2             	movsbl %dl,%edx
  80051e:	83 ea 20             	sub    $0x20,%edx
  800521:	83 fa 5e             	cmp    $0x5e,%edx
  800524:	76 c4                	jbe    8004ea <vprintfmt+0x1e6>
					putch('?', putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	6a 3f                	push   $0x3f
  80052e:	ff 55 08             	call   *0x8(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	eb c1                	jmp    8004f7 <vprintfmt+0x1f3>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	eb b6                	jmp    8004fa <vprintfmt+0x1f6>
				putch(' ', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	6a 20                	push   $0x20
  80054a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054c:	83 ef 01             	sub    $0x1,%edi
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	85 ff                	test   %edi,%edi
  800554:	7f ee                	jg     800544 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800556:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
  80055c:	e9 1a 01 00 00       	jmp    80067b <vprintfmt+0x377>
  800561:	89 df                	mov    %ebx,%edi
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	eb e7                	jmp    800552 <vprintfmt+0x24e>
	if (lflag >= 2)
  80056b:	83 f9 01             	cmp    $0x1,%ecx
  80056e:	7e 3f                	jle    8005af <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 50 04             	mov    0x4(%eax),%edx
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 08             	lea    0x8(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800587:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058b:	79 5c                	jns    8005e9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	6a 2d                	push   $0x2d
  800593:	ff d6                	call   *%esi
				num = -(long long) num;
  800595:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800598:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059b:	f7 da                	neg    %edx
  80059d:	83 d1 00             	adc    $0x0,%ecx
  8005a0:	f7 d9                	neg    %ecx
  8005a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	e9 b2 00 00 00       	jmp    800661 <vprintfmt+0x35d>
	else if (lflag)
  8005af:	85 c9                	test   %ecx,%ecx
  8005b1:	75 1b                	jne    8005ce <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 c1                	mov    %eax,%ecx
  8005bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cc:	eb b9                	jmp    800587 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e7:	eb 9e                	jmp    800587 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	eb 6b                	jmp    800661 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005f6:	83 f9 01             	cmp    $0x1,%ecx
  8005f9:	7e 15                	jle    800610 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8b 48 04             	mov    0x4(%eax),%ecx
  800603:	8d 40 08             	lea    0x8(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	eb 51                	jmp    800661 <vprintfmt+0x35d>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	75 17                	jne    80062b <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	eb 36                	jmp    800661 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800640:	eb 1f                	jmp    800661 <vprintfmt+0x35d>
	if (lflag >= 2)
  800642:	83 f9 01             	cmp    $0x1,%ecx
  800645:	7e 5b                	jle    8006a2 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 50 04             	mov    0x4(%eax),%edx
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800652:	8d 49 08             	lea    0x8(%ecx),%ecx
  800655:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800658:	89 d1                	mov    %edx,%ecx
  80065a:	89 c2                	mov    %eax,%edx
			base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	50                   	push   %eax
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 a3 fb ff ff       	call   80021b <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067e:	83 c7 01             	add    $0x1,%edi
  800681:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800685:	83 f8 25             	cmp    $0x25,%eax
  800688:	0f 84 8d fc ff ff    	je     80031b <vprintfmt+0x17>
			if (ch == '\0')
  80068e:	85 c0                	test   %eax,%eax
  800690:	0f 84 e8 00 00 00    	je     80077e <vprintfmt+0x47a>
			putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	50                   	push   %eax
  80069b:	ff d6                	call   *%esi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb dc                	jmp    80067e <vprintfmt+0x37a>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	75 13                	jne    8006b9 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	89 d0                	mov    %edx,%eax
  8006ad:	99                   	cltd   
  8006ae:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b7:	eb 9f                	jmp    800658 <vprintfmt+0x354>
		return va_arg(*ap, long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	89 d0                	mov    %edx,%eax
  8006c0:	99                   	cltd   
  8006c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ca:	eb 8c                	jmp    800658 <vprintfmt+0x354>
			putch('0', putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 30                	push   $0x30
  8006d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d4:	83 c4 08             	add    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 78                	push   $0x78
  8006da:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f4:	e9 68 ff ff ff       	jmp    800661 <vprintfmt+0x35d>
	if (lflag >= 2)
  8006f9:	83 f9 01             	cmp    $0x1,%ecx
  8006fc:	7e 18                	jle    800716 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	8b 48 04             	mov    0x4(%eax),%ecx
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	b8 10 00 00 00       	mov    $0x10,%eax
  800711:	e9 4b ff ff ff       	jmp    800661 <vprintfmt+0x35d>
	else if (lflag)
  800716:	85 c9                	test   %ecx,%ecx
  800718:	75 1a                	jne    800734 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
  80072f:	e9 2d ff ff ff       	jmp    800661 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
  800749:	e9 13 ff ff ff       	jmp    800661 <vprintfmt+0x35d>
			putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			break;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	e9 1d ff ff ff       	jmp    80067b <vprintfmt+0x377>
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	89 f8                	mov    %edi,%eax
  80076b:	eb 03                	jmp    800770 <vprintfmt+0x46c>
  80076d:	83 e8 01             	sub    $0x1,%eax
  800770:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800774:	75 f7                	jne    80076d <vprintfmt+0x469>
  800776:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800779:	e9 fd fe ff ff       	jmp    80067b <vprintfmt+0x377>
}
  80077e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 18             	sub    $0x18,%esp
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800792:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800795:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800799:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	74 26                	je     8007cd <vsnprintf+0x47>
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	7e 22                	jle    8007cd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ab:	ff 75 14             	pushl  0x14(%ebp)
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 ca 02 80 00       	push   $0x8002ca
  8007ba:	e8 45 fb ff ff       	call   800304 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c8:	83 c4 10             	add    $0x10,%esp
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
		return -E_INVAL;
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d2:	eb f7                	jmp    8007cb <vsnprintf+0x45>

008007d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dd:	50                   	push   %eax
  8007de:	ff 75 10             	pushl  0x10(%ebp)
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	ff 75 08             	pushl  0x8(%ebp)
  8007e7:	e8 9a ff ff ff       	call   800786 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f9:	eb 03                	jmp    8007fe <strlen+0x10>
		n++;
  8007fb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800802:	75 f7                	jne    8007fb <strlen+0xd>
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 03                	jmp    800819 <strnlen+0x13>
		n++;
  800816:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800819:	39 d0                	cmp    %edx,%eax
  80081b:	74 06                	je     800823 <strnlen+0x1d>
  80081d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800821:	75 f3                	jne    800816 <strnlen+0x10>
	return n;
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082f:	89 c2                	mov    %eax,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	83 c2 01             	add    $0x1,%edx
  800837:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083e:	84 db                	test   %bl,%bl
  800840:	75 ef                	jne    800831 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084c:	53                   	push   %ebx
  80084d:	e8 9c ff ff ff       	call   8007ee <strlen>
  800852:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800855:	ff 75 0c             	pushl  0xc(%ebp)
  800858:	01 d8                	add    %ebx,%eax
  80085a:	50                   	push   %eax
  80085b:	e8 c5 ff ff ff       	call   800825 <strcpy>
	return dst;
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	89 f3                	mov    %esi,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 0f                	jmp    80088a <strncpy+0x23>
		*dst++ = *src;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	0f b6 01             	movzbl (%ecx),%eax
  800881:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800884:	80 39 01             	cmpb   $0x1,(%ecx)
  800887:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80088a:	39 da                	cmp    %ebx,%edx
  80088c:	75 ed                	jne    80087b <strncpy+0x14>
	}
	return ret;
}
  80088e:	89 f0                	mov    %esi,%eax
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	75 0b                	jne    8008b7 <strlcpy+0x23>
  8008ac:	eb 17                	jmp    8008c5 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 07                	je     8008c2 <strlcpy+0x2e>
  8008bb:	0f b6 0a             	movzbl (%edx),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	75 ec                	jne    8008ae <strlcpy+0x1a>
		*dst = '\0';
  8008c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c5:	29 f0                	sub    %esi,%eax
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strcmp+0x11>
		p++, q++;
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008dc:	0f b6 01             	movzbl (%ecx),%eax
  8008df:	84 c0                	test   %al,%al
  8008e1:	74 04                	je     8008e7 <strcmp+0x1c>
  8008e3:	3a 02                	cmp    (%edx),%al
  8008e5:	74 ef                	je     8008d6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 c0             	movzbl %al,%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	89 c3                	mov    %eax,%ebx
  8008fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800900:	eb 06                	jmp    800908 <strncmp+0x17>
		n--, p++, q++;
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800908:	39 d8                	cmp    %ebx,%eax
  80090a:	74 16                	je     800922 <strncmp+0x31>
  80090c:	0f b6 08             	movzbl (%eax),%ecx
  80090f:	84 c9                	test   %cl,%cl
  800911:	74 04                	je     800917 <strncmp+0x26>
  800913:	3a 0a                	cmp    (%edx),%cl
  800915:	74 eb                	je     800902 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800917:	0f b6 00             	movzbl (%eax),%eax
  80091a:	0f b6 12             	movzbl (%edx),%edx
  80091d:	29 d0                	sub    %edx,%eax
}
  80091f:	5b                   	pop    %ebx
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb f6                	jmp    80091f <strncmp+0x2e>

00800929 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800933:	0f b6 10             	movzbl (%eax),%edx
  800936:	84 d2                	test   %dl,%dl
  800938:	74 09                	je     800943 <strchr+0x1a>
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 0a                	je     800948 <strchr+0x1f>
	for (; *s; s++)
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	eb f0                	jmp    800933 <strchr+0xa>
			return (char *) s;
	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	eb 03                	jmp    800959 <strfind+0xf>
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 04                	je     800964 <strfind+0x1a>
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f2                	jne    800956 <strfind+0xc>
			break;
	return (char *) s;
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	57                   	push   %edi
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800972:	85 c9                	test   %ecx,%ecx
  800974:	74 13                	je     800989 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800976:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097c:	75 05                	jne    800983 <memset+0x1d>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	74 0d                	je     800990 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    
		c &= 0xFF;
  800990:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800994:	89 d3                	mov    %edx,%ebx
  800996:	c1 e3 08             	shl    $0x8,%ebx
  800999:	89 d0                	mov    %edx,%eax
  80099b:	c1 e0 18             	shl    $0x18,%eax
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	c1 e6 10             	shl    $0x10,%esi
  8009a3:	09 f0                	or     %esi,%eax
  8009a5:	09 c2                	or     %eax,%edx
  8009a7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	fc                   	cld    
  8009af:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b1:	eb d6                	jmp    800989 <memset+0x23>

008009b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c1:	39 c6                	cmp    %eax,%esi
  8009c3:	73 35                	jae    8009fa <memmove+0x47>
  8009c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c8:	39 c2                	cmp    %eax,%edx
  8009ca:	76 2e                	jbe    8009fa <memmove+0x47>
		s += n;
		d += n;
  8009cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	89 d6                	mov    %edx,%esi
  8009d1:	09 fe                	or     %edi,%esi
  8009d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d9:	74 0c                	je     8009e7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009db:	83 ef 01             	sub    $0x1,%edi
  8009de:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e1:	fd                   	std    
  8009e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e4:	fc                   	cld    
  8009e5:	eb 21                	jmp    800a08 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 ef                	jne    8009db <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ec:	83 ef 04             	sub    $0x4,%edi
  8009ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f5:	fd                   	std    
  8009f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f8:	eb ea                	jmp    8009e4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	89 f2                	mov    %esi,%edx
  8009fc:	09 c2                	or     %eax,%edx
  8009fe:	f6 c2 03             	test   $0x3,%dl
  800a01:	74 09                	je     800a0c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 f2                	jne    800a03 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a11:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb ed                	jmp    800a08 <memmove+0x55>

00800a1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1e:	ff 75 10             	pushl  0x10(%ebp)
  800a21:	ff 75 0c             	pushl  0xc(%ebp)
  800a24:	ff 75 08             	pushl  0x8(%ebp)
  800a27:	e8 87 ff ff ff       	call   8009b3 <memmove>
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a39:	89 c6                	mov    %eax,%esi
  800a3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	74 1c                	je     800a5e <memcmp+0x30>
		if (*s1 != *s2)
  800a42:	0f b6 08             	movzbl (%eax),%ecx
  800a45:	0f b6 1a             	movzbl (%edx),%ebx
  800a48:	38 d9                	cmp    %bl,%cl
  800a4a:	75 08                	jne    800a54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	83 c2 01             	add    $0x1,%edx
  800a52:	eb ea                	jmp    800a3e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a54:	0f b6 c1             	movzbl %cl,%eax
  800a57:	0f b6 db             	movzbl %bl,%ebx
  800a5a:	29 d8                	sub    %ebx,%eax
  800a5c:	eb 05                	jmp    800a63 <memcmp+0x35>
	}

	return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 09                	jae    800a82 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a79:	38 08                	cmp    %cl,(%eax)
  800a7b:	74 05                	je     800a82 <memfind+0x1b>
	for (; s < ends; s++)
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	eb f3                	jmp    800a75 <memfind+0xe>
			break;
	return (void *) s;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a90:	eb 03                	jmp    800a95 <strtol+0x11>
		s++;
  800a92:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a95:	0f b6 01             	movzbl (%ecx),%eax
  800a98:	3c 20                	cmp    $0x20,%al
  800a9a:	74 f6                	je     800a92 <strtol+0xe>
  800a9c:	3c 09                	cmp    $0x9,%al
  800a9e:	74 f2                	je     800a92 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800aa0:	3c 2b                	cmp    $0x2b,%al
  800aa2:	74 2e                	je     800ad2 <strtol+0x4e>
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	74 2f                	je     800adc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab3:	75 05                	jne    800aba <strtol+0x36>
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	74 2c                	je     800ae6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aba:	85 db                	test   %ebx,%ebx
  800abc:	75 0a                	jne    800ac8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abe:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ac3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac6:	74 28                	je     800af0 <strtol+0x6c>
		base = 10;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad0:	eb 50                	jmp    800b22 <strtol+0x9e>
		s++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad5:	bf 00 00 00 00       	mov    $0x0,%edi
  800ada:	eb d1                	jmp    800aad <strtol+0x29>
		s++, neg = 1;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae4:	eb c7                	jmp    800aad <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aea:	74 0e                	je     800afa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	75 d8                	jne    800ac8 <strtol+0x44>
		s++, base = 8;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af8:	eb ce                	jmp    800ac8 <strtol+0x44>
		s += 2, base = 16;
  800afa:	83 c1 02             	add    $0x2,%ecx
  800afd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b02:	eb c4                	jmp    800ac8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b04:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 29                	ja     800b37 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b14:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b17:	7d 30                	jge    800b49 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b20:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 d5                	ja     800b04 <strtol+0x80>
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
  800b35:	eb dd                	jmp    800b14 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b37:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 37             	sub    $0x37,%edx
  800b47:	eb cb                	jmp    800b14 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4d:	74 05                	je     800b54 <strtol+0xd0>
		*endptr = (char *) s;
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b52:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b54:	89 c2                	mov    %eax,%edx
  800b56:	f7 da                	neg    %edx
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	0f 45 c2             	cmovne %edx,%eax
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb5:	89 cb                	mov    %ecx,%ebx
  800bb7:	89 cf                	mov    %ecx,%edi
  800bb9:	89 ce                	mov    %ecx,%esi
  800bbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7f 08                	jg     800bc9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 03                	push   $0x3
  800bcf:	68 a4 13 80 00       	push   $0x8013a4
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 c1 13 80 00       	push   $0x8013c1
  800bdb:	e8 4c f5 ff ff       	call   80012c <_panic>

00800be0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_yield>:

void
sys_yield(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	b8 04 00 00 00       	mov    $0x4,%eax
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7f 08                	jg     800c4a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 04                	push   $0x4
  800c50:	68 a4 13 80 00       	push   $0x8013a4
  800c55:	6a 23                	push   $0x23
  800c57:	68 c1 13 80 00       	push   $0x8013c1
  800c5c:	e8 cb f4 ff ff       	call   80012c <_panic>

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 05 00 00 00       	mov    $0x5,%eax
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 05                	push   $0x5
  800c92:	68 a4 13 80 00       	push   $0x8013a4
  800c97:	6a 23                	push   $0x23
  800c99:	68 c1 13 80 00       	push   $0x8013c1
  800c9e:	e8 89 f4 ff ff       	call   80012c <_panic>

00800ca3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7f 08                	jg     800cce <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 06                	push   $0x6
  800cd4:	68 a4 13 80 00       	push   $0x8013a4
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 c1 13 80 00       	push   $0x8013c1
  800ce0:	e8 47 f4 ff ff       	call   80012c <_panic>

00800ce5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 08                	push   $0x8
  800d16:	68 a4 13 80 00       	push   $0x8013a4
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 c1 13 80 00       	push   $0x8013c1
  800d22:	e8 05 f4 ff ff       	call   80012c <_panic>

00800d27 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 09                	push   $0x9
  800d58:	68 a4 13 80 00       	push   $0x8013a4
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 c1 13 80 00       	push   $0x8013c1
  800d64:	e8 c3 f3 ff ff       	call   80012c <_panic>

00800d69 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7a:	be 00 00 00 00       	mov    $0x0,%esi
  800d7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d85:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da2:	89 cb                	mov    %ecx,%ebx
  800da4:	89 cf                	mov    %ecx,%edi
  800da6:	89 ce                	mov    %ecx,%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 0c                	push   $0xc
  800dbc:	68 a4 13 80 00       	push   $0x8013a4
  800dc1:	6a 23                	push   $0x23
  800dc3:	68 c1 13 80 00       	push   $0x8013c1
  800dc8:	e8 5f f3 ff ff       	call   80012c <_panic>

00800dcd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 04             	sub    $0x4,%esp
	int r;
	envid_t trap_env_id = sys_getenvid();
  800dd4:	e8 07 fe ff ff       	call   800be0 <sys_getenvid>
  800dd9:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800ddb:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800de2:	74 22                	je     800e06 <set_pgfault_handler+0x39>
		// LAB 4: Your code here.
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
		
		//panic("set_pgfault_handler not implemented");
	}
	if (sys_env_set_pgfault_upcall(trap_env_id, _pgfault_upcall)) {
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	68 2f 0e 80 00       	push   $0x800e2f
  800dec:	53                   	push   %ebx
  800ded:	e8 35 ff ff ff       	call   800d27 <sys_env_set_pgfault_upcall>
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	75 22                	jne    800e1b <set_pgfault_handler+0x4e>
		panic("set pgfault upcall failed!");
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	6a 06                	push   $0x6
  800e0b:	68 00 f0 bf ee       	push   $0xeebff000
  800e10:	50                   	push   %eax
  800e11:	e8 08 fe ff ff       	call   800c1e <sys_page_alloc>
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	eb c9                	jmp    800de4 <set_pgfault_handler+0x17>
		panic("set pgfault upcall failed!");
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	68 cf 13 80 00       	push   $0x8013cf
  800e23:	6a 25                	push   $0x25
  800e25:	68 ea 13 80 00       	push   $0x8013ea
  800e2a:	e8 fd f2 ff ff       	call   80012c <_panic>

00800e2f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e2f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e30:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e35:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e37:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	lea 48(%esp), %eax
  800e3a:	8d 44 24 30          	lea    0x30(%esp),%eax
	movl (%eax), %eax
  800e3e:	8b 00                	mov    (%eax),%eax
	lea 40(%esp), %ebx
  800e40:	8d 5c 24 28          	lea    0x28(%esp),%ebx
	movl (%ebx), %ebx
  800e44:	8b 1b                	mov    (%ebx),%ebx
	subl $4, %eax
  800e46:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  800e49:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	add $8, %esp
  800e4b:	83 c4 08             	add    $0x8,%esp
	pop %edi
  800e4e:	5f                   	pop    %edi
	pop %esi
  800e4f:	5e                   	pop    %esi
	pop %ebp
  800e50:	5d                   	pop    %ebp
	add $4, %esp
  800e51:	83 c4 04             	add    $0x4,%esp
	pop %ebx
  800e54:	5b                   	pop    %ebx
	pop %edx
  800e55:	5a                   	pop    %edx
	pop %ecx
  800e56:	59                   	pop    %ecx
	pop %eax
  800e57:	58                   	pop    %eax
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  800e58:	83 c4 04             	add    $0x4,%esp
	popfl
  800e5b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800e5c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	sub $4, %esp
  800e5d:	83 ec 04             	sub    $0x4,%esp
  800e60:	c3                   	ret    
  800e61:	66 90                	xchg   %ax,%ax
  800e63:	66 90                	xchg   %ax,%ax
  800e65:	66 90                	xchg   %ax,%ax
  800e67:	66 90                	xchg   %ax,%ax
  800e69:	66 90                	xchg   %ax,%ax
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e87:	85 d2                	test   %edx,%edx
  800e89:	75 35                	jne    800ec0 <__udivdi3+0x50>
  800e8b:	39 f3                	cmp    %esi,%ebx
  800e8d:	0f 87 bd 00 00 00    	ja     800f50 <__udivdi3+0xe0>
  800e93:	85 db                	test   %ebx,%ebx
  800e95:	89 d9                	mov    %ebx,%ecx
  800e97:	75 0b                	jne    800ea4 <__udivdi3+0x34>
  800e99:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9e:	31 d2                	xor    %edx,%edx
  800ea0:	f7 f3                	div    %ebx
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	31 d2                	xor    %edx,%edx
  800ea6:	89 f0                	mov    %esi,%eax
  800ea8:	f7 f1                	div    %ecx
  800eaa:	89 c6                	mov    %eax,%esi
  800eac:	89 e8                	mov    %ebp,%eax
  800eae:	89 f7                	mov    %esi,%edi
  800eb0:	f7 f1                	div    %ecx
  800eb2:	89 fa                	mov    %edi,%edx
  800eb4:	83 c4 1c             	add    $0x1c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
  800ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 f2                	cmp    %esi,%edx
  800ec2:	77 7c                	ja     800f40 <__udivdi3+0xd0>
  800ec4:	0f bd fa             	bsr    %edx,%edi
  800ec7:	83 f7 1f             	xor    $0x1f,%edi
  800eca:	0f 84 98 00 00 00    	je     800f68 <__udivdi3+0xf8>
  800ed0:	89 f9                	mov    %edi,%ecx
  800ed2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed7:	29 f8                	sub    %edi,%eax
  800ed9:	d3 e2                	shl    %cl,%edx
  800edb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	89 da                	mov    %ebx,%edx
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ee9:	09 d1                	or     %edx,%ecx
  800eeb:	89 f2                	mov    %esi,%edx
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e3                	shl    %cl,%ebx
  800ef5:	89 c1                	mov    %eax,%ecx
  800ef7:	d3 ea                	shr    %cl,%edx
  800ef9:	89 f9                	mov    %edi,%ecx
  800efb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eff:	d3 e6                	shl    %cl,%esi
  800f01:	89 eb                	mov    %ebp,%ebx
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	d3 eb                	shr    %cl,%ebx
  800f07:	09 de                	or     %ebx,%esi
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	f7 74 24 08          	divl   0x8(%esp)
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	89 c3                	mov    %eax,%ebx
  800f13:	f7 64 24 0c          	mull   0xc(%esp)
  800f17:	39 d6                	cmp    %edx,%esi
  800f19:	72 0c                	jb     800f27 <__udivdi3+0xb7>
  800f1b:	89 f9                	mov    %edi,%ecx
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	39 c5                	cmp    %eax,%ebp
  800f21:	73 5d                	jae    800f80 <__udivdi3+0x110>
  800f23:	39 d6                	cmp    %edx,%esi
  800f25:	75 59                	jne    800f80 <__udivdi3+0x110>
  800f27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f2a:	31 ff                	xor    %edi,%edi
  800f2c:	89 fa                	mov    %edi,%edx
  800f2e:	83 c4 1c             	add    $0x1c,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
  800f36:	8d 76 00             	lea    0x0(%esi),%esi
  800f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	31 c0                	xor    %eax,%eax
  800f44:	89 fa                	mov    %edi,%edx
  800f46:	83 c4 1c             	add    $0x1c,%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    
  800f4e:	66 90                	xchg   %ax,%ax
  800f50:	31 ff                	xor    %edi,%edi
  800f52:	89 e8                	mov    %ebp,%eax
  800f54:	89 f2                	mov    %esi,%edx
  800f56:	f7 f3                	div    %ebx
  800f58:	89 fa                	mov    %edi,%edx
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	72 06                	jb     800f72 <__udivdi3+0x102>
  800f6c:	31 c0                	xor    %eax,%eax
  800f6e:	39 eb                	cmp    %ebp,%ebx
  800f70:	77 d2                	ja     800f44 <__udivdi3+0xd4>
  800f72:	b8 01 00 00 00       	mov    $0x1,%eax
  800f77:	eb cb                	jmp    800f44 <__udivdi3+0xd4>
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	31 ff                	xor    %edi,%edi
  800f84:	eb be                	jmp    800f44 <__udivdi3+0xd4>
  800f86:	66 90                	xchg   %ax,%ax
  800f88:	66 90                	xchg   %ax,%ax
  800f8a:	66 90                	xchg   %ax,%ax
  800f8c:	66 90                	xchg   %ax,%ax
  800f8e:	66 90                	xchg   %ax,%ax

00800f90 <__umoddi3>:
  800f90:	55                   	push   %ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 1c             	sub    $0x1c,%esp
  800f97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fa7:	85 ed                	test   %ebp,%ebp
  800fa9:	89 f0                	mov    %esi,%eax
  800fab:	89 da                	mov    %ebx,%edx
  800fad:	75 19                	jne    800fc8 <__umoddi3+0x38>
  800faf:	39 df                	cmp    %ebx,%edi
  800fb1:	0f 86 b1 00 00 00    	jbe    801068 <__umoddi3+0xd8>
  800fb7:	f7 f7                	div    %edi
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 1c             	add    $0x1c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	39 dd                	cmp    %ebx,%ebp
  800fca:	77 f1                	ja     800fbd <__umoddi3+0x2d>
  800fcc:	0f bd cd             	bsr    %ebp,%ecx
  800fcf:	83 f1 1f             	xor    $0x1f,%ecx
  800fd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fd6:	0f 84 b4 00 00 00    	je     801090 <__umoddi3+0x100>
  800fdc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fe7:	29 c2                	sub    %eax,%edx
  800fe9:	89 c1                	mov    %eax,%ecx
  800feb:	89 f8                	mov    %edi,%eax
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	89 d1                	mov    %edx,%ecx
  800ff1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff5:	d3 e8                	shr    %cl,%eax
  800ff7:	09 c5                	or     %eax,%ebp
  800ff9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	d3 e7                	shl    %cl,%edi
  801001:	89 d1                	mov    %edx,%ecx
  801003:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801007:	89 df                	mov    %ebx,%edi
  801009:	d3 ef                	shr    %cl,%edi
  80100b:	89 c1                	mov    %eax,%ecx
  80100d:	89 f0                	mov    %esi,%eax
  80100f:	d3 e3                	shl    %cl,%ebx
  801011:	89 d1                	mov    %edx,%ecx
  801013:	89 fa                	mov    %edi,%edx
  801015:	d3 e8                	shr    %cl,%eax
  801017:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101c:	09 d8                	or     %ebx,%eax
  80101e:	f7 f5                	div    %ebp
  801020:	d3 e6                	shl    %cl,%esi
  801022:	89 d1                	mov    %edx,%ecx
  801024:	f7 64 24 08          	mull   0x8(%esp)
  801028:	39 d1                	cmp    %edx,%ecx
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	72 06                	jb     801036 <__umoddi3+0xa6>
  801030:	75 0e                	jne    801040 <__umoddi3+0xb0>
  801032:	39 c6                	cmp    %eax,%esi
  801034:	73 0a                	jae    801040 <__umoddi3+0xb0>
  801036:	2b 44 24 08          	sub    0x8(%esp),%eax
  80103a:	19 ea                	sbb    %ebp,%edx
  80103c:	89 d7                	mov    %edx,%edi
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 ca                	mov    %ecx,%edx
  801042:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801047:	29 de                	sub    %ebx,%esi
  801049:	19 fa                	sbb    %edi,%edx
  80104b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80104f:	89 d0                	mov    %edx,%eax
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 d9                	mov    %ebx,%ecx
  801055:	d3 ee                	shr    %cl,%esi
  801057:	d3 ea                	shr    %cl,%edx
  801059:	09 f0                	or     %esi,%eax
  80105b:	83 c4 1c             	add    $0x1c,%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
  801063:	90                   	nop
  801064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801068:	85 ff                	test   %edi,%edi
  80106a:	89 f9                	mov    %edi,%ecx
  80106c:	75 0b                	jne    801079 <__umoddi3+0xe9>
  80106e:	b8 01 00 00 00       	mov    $0x1,%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	f7 f7                	div    %edi
  801077:	89 c1                	mov    %eax,%ecx
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f1                	div    %ecx
  80107f:	89 f0                	mov    %esi,%eax
  801081:	f7 f1                	div    %ecx
  801083:	e9 31 ff ff ff       	jmp    800fb9 <__umoddi3+0x29>
  801088:	90                   	nop
  801089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801090:	39 dd                	cmp    %ebx,%ebp
  801092:	72 08                	jb     80109c <__umoddi3+0x10c>
  801094:	39 f7                	cmp    %esi,%edi
  801096:	0f 87 21 ff ff ff    	ja     800fbd <__umoddi3+0x2d>
  80109c:	89 da                	mov    %ebx,%edx
  80109e:	89 f0                	mov    %esi,%eax
  8010a0:	29 f8                	sub    %edi,%eax
  8010a2:	19 ea                	sbb    %ebp,%edx
  8010a4:	e9 14 ff ff ff       	jmp    800fbd <__umoddi3+0x2d>
