
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 6e 01 00 00       	call   80019f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 1e 0e 00 00       	call   800e5c <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9e 00 00 00    	jne    8000e7 <umain+0xb4>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 2e 0e 00 00       	call   800e8a <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 11 80 00       	push   $0x801180
  80006c:	e8 25 02 00 00       	call   800296 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 fe 07 00 00       	call   80087d <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 ed 08 00 00       	call   800980 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	74 3b                	je     8000d5 <umain+0xa2>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 35 00 20 80 00    	pushl  0x802000
  8000a3:	e8 d5 07 00 00       	call   80087d <strlen>
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	83 c0 01             	add    $0x1,%eax
  8000ae:	50                   	push   %eax
  8000af:	ff 35 00 20 80 00    	pushl  0x802000
  8000b5:	68 00 00 b0 00       	push   $0xb00000
  8000ba:	e8 eb 09 00 00       	call   800aaa <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000bf:	6a 07                	push   $0x7
  8000c1:	68 00 00 b0 00       	push   $0xb00000
  8000c6:	6a 00                	push   $0x0
  8000c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000cb:	e8 d1 0d 00 00       	call   800ea1 <ipc_send>
		return;
  8000d0:	83 c4 20             	add    $0x20,%esp
	ipc_recv(&who, TEMP_ADDR, 0);
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
			cprintf("child received correct message\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 94 11 80 00       	push   $0x801194
  8000dd:	e8 b4 01 00 00       	call   800296 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb b3                	jmp    80009a <umain+0x67>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 ae 0b 00 00       	call   800cad <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 04 20 80 00    	pushl  0x802004
  800108:	e8 70 07 00 00       	call   80087d <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	83 c0 01             	add    $0x1,%eax
  800113:	50                   	push   %eax
  800114:	ff 35 04 20 80 00    	pushl  0x802004
  80011a:	68 00 00 a0 00       	push   $0xa00000
  80011f:	e8 86 09 00 00       	call   800aaa <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800124:	6a 07                	push   $0x7
  800126:	68 00 00 a0 00       	push   $0xa00000
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 f4             	pushl  -0xc(%ebp)
  800130:	e8 6c 0d 00 00       	call   800ea1 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  800135:	83 c4 1c             	add    $0x1c,%esp
  800138:	6a 00                	push   $0x0
  80013a:	68 00 00 a0 00       	push   $0xa00000
  80013f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 42 0d 00 00       	call   800e8a <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	68 00 00 a0 00       	push   $0xa00000
  800150:	ff 75 f4             	pushl  -0xc(%ebp)
  800153:	68 80 11 80 00       	push   $0x801180
  800158:	e8 39 01 00 00       	call   800296 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 35 00 20 80 00    	pushl  0x802000
  800166:	e8 12 07 00 00       	call   80087d <strlen>
  80016b:	83 c4 0c             	add    $0xc,%esp
  80016e:	50                   	push   %eax
  80016f:	ff 35 00 20 80 00    	pushl  0x802000
  800175:	68 00 00 a0 00       	push   $0xa00000
  80017a:	e8 01 08 00 00       	call   800980 <strncmp>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	0f 85 49 ff ff ff    	jne    8000d3 <umain+0xa0>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 b4 11 80 00       	push   $0x8011b4
  800192:	e8 ff 00 00 00       	call   800296 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	e9 34 ff ff ff       	jmp    8000d3 <umain+0xa0>

0080019f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001aa:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8001b1:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8001b4:	e8 b6 0a 00 00       	call   800c6f <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8001b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7e 07                	jle    8001d6 <libmain+0x37>
		binaryname = argv[0];
  8001cf:	8b 06                	mov    (%esi),%eax
  8001d1:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	e8 53 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001e0:	e8 0a 00 00 00       	call   8001ef <exit>
}
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001f5:	6a 00                	push   $0x0
  8001f7:	e8 32 0a 00 00       	call   800c2e <sys_env_destroy>
}
  8001fc:	83 c4 10             	add    $0x10,%esp
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	53                   	push   %ebx
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020b:	8b 13                	mov    (%ebx),%edx
  80020d:	8d 42 01             	lea    0x1(%edx),%eax
  800210:	89 03                	mov    %eax,(%ebx)
  800212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800215:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800219:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021e:	74 09                	je     800229 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800220:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800227:	c9                   	leave  
  800228:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	68 ff 00 00 00       	push   $0xff
  800231:	8d 43 08             	lea    0x8(%ebx),%eax
  800234:	50                   	push   %eax
  800235:	e8 b7 09 00 00       	call   800bf1 <sys_cputs>
		b->idx = 0;
  80023a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	eb db                	jmp    800220 <putch+0x1f>

00800245 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800255:	00 00 00 
	b.cnt = 0;
  800258:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026e:	50                   	push   %eax
  80026f:	68 01 02 80 00       	push   $0x800201
  800274:	e8 1a 01 00 00       	call   800393 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800282:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800288:	50                   	push   %eax
  800289:	e8 63 09 00 00       	call   800bf1 <sys_cputs>

	return b.cnt;
}
  80028e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029f:	50                   	push   %eax
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	e8 9d ff ff ff       	call   800245 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 1c             	sub    $0x1c,%esp
  8002b3:	89 c7                	mov    %eax,%edi
  8002b5:	89 d6                	mov    %edx,%esi
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002d1:	39 d3                	cmp    %edx,%ebx
  8002d3:	72 05                	jb     8002da <printnum+0x30>
  8002d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d8:	77 7a                	ja     800354 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	ff 75 18             	pushl  0x18(%ebp)
  8002e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f9:	e8 42 0c 00 00       	call   800f40 <__udivdi3>
  8002fe:	83 c4 18             	add    $0x18,%esp
  800301:	52                   	push   %edx
  800302:	50                   	push   %eax
  800303:	89 f2                	mov    %esi,%edx
  800305:	89 f8                	mov    %edi,%eax
  800307:	e8 9e ff ff ff       	call   8002aa <printnum>
  80030c:	83 c4 20             	add    $0x20,%esp
  80030f:	eb 13                	jmp    800324 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	ff 75 18             	pushl  0x18(%ebp)
  800318:	ff d7                	call   *%edi
  80031a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f ed                	jg     800311 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	56                   	push   %esi
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032e:	ff 75 e0             	pushl  -0x20(%ebp)
  800331:	ff 75 dc             	pushl  -0x24(%ebp)
  800334:	ff 75 d8             	pushl  -0x28(%ebp)
  800337:	e8 24 0d 00 00       	call   801060 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 80 2c 12 80 00 	movsbl 0x80122c(%eax),%eax
  800346:	50                   	push   %eax
  800347:	ff d7                	call   *%edi
}
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    
  800354:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800357:	eb c4                	jmp    80031d <printnum+0x73>

00800359 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800363:	8b 10                	mov    (%eax),%edx
  800365:	3b 50 04             	cmp    0x4(%eax),%edx
  800368:	73 0a                	jae    800374 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 45 08             	mov    0x8(%ebp),%eax
  800372:	88 02                	mov    %al,(%edx)
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <printfmt>:
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037f:	50                   	push   %eax
  800380:	ff 75 10             	pushl  0x10(%ebp)
  800383:	ff 75 0c             	pushl  0xc(%ebp)
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	e8 05 00 00 00       	call   800393 <vprintfmt>
}
  80038e:	83 c4 10             	add    $0x10,%esp
  800391:	c9                   	leave  
  800392:	c3                   	ret    

00800393 <vprintfmt>:
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 2c             	sub    $0x2c,%esp
  80039c:	8b 75 08             	mov    0x8(%ebp),%esi
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a5:	e9 63 03 00 00       	jmp    80070d <vprintfmt+0x37a>
		padc = ' ';
  8003aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8d 47 01             	lea    0x1(%edi),%eax
  8003cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ce:	0f b6 17             	movzbl (%edi),%edx
  8003d1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d4:	3c 55                	cmp    $0x55,%al
  8003d6:	0f 87 11 04 00 00    	ja     8007ed <vprintfmt+0x45a>
  8003dc:	0f b6 c0             	movzbl %al,%eax
  8003df:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ed:	eb d9                	jmp    8003c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f6:	eb d0                	jmp    8003c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	0f b6 d2             	movzbl %dl,%edx
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800403:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800406:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800409:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80040d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800410:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800413:	83 f9 09             	cmp    $0x9,%ecx
  800416:	77 55                	ja     80046d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800418:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80041b:	eb e9                	jmp    800406 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 40 04             	lea    0x4(%eax),%eax
  80042b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	79 91                	jns    8003c8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800437:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800444:	eb 82                	jmp    8003c8 <vprintfmt+0x35>
  800446:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800449:	85 c0                	test   %eax,%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	0f 49 d0             	cmovns %eax,%edx
  800453:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	e9 6a ff ff ff       	jmp    8003c8 <vprintfmt+0x35>
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800461:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800468:	e9 5b ff ff ff       	jmp    8003c8 <vprintfmt+0x35>
  80046d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800470:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800473:	eb bc                	jmp    800431 <vprintfmt+0x9e>
			lflag++;
  800475:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80047b:	e9 48 ff ff ff       	jmp    8003c8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 78 04             	lea    0x4(%eax),%edi
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	53                   	push   %ebx
  80048a:	ff 30                	pushl  (%eax)
  80048c:	ff d6                	call   *%esi
			break;
  80048e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800491:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800494:	e9 71 02 00 00       	jmp    80070a <vprintfmt+0x377>
			err = va_arg(ap, int);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 78 04             	lea    0x4(%eax),%edi
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	99                   	cltd   
  8004a2:	31 d0                	xor    %edx,%eax
  8004a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a6:	83 f8 08             	cmp    $0x8,%eax
  8004a9:	7f 23                	jg     8004ce <vprintfmt+0x13b>
  8004ab:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	74 18                	je     8004ce <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004b6:	52                   	push   %edx
  8004b7:	68 4d 12 80 00       	push   $0x80124d
  8004bc:	53                   	push   %ebx
  8004bd:	56                   	push   %esi
  8004be:	e8 b3 fe ff ff       	call   800376 <printfmt>
  8004c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c9:	e9 3c 02 00 00       	jmp    80070a <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 44 12 80 00       	push   $0x801244
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 9b fe ff ff       	call   800376 <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004e1:	e9 24 02 00 00       	jmp    80070a <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	83 c0 04             	add    $0x4,%eax
  8004ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	b8 3d 12 80 00       	mov    $0x80123d,%eax
  8004fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800502:	0f 8e bd 00 00 00    	jle    8005c5 <vprintfmt+0x232>
  800508:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050c:	75 0e                	jne    80051c <vprintfmt+0x189>
  80050e:	89 75 08             	mov    %esi,0x8(%ebp)
  800511:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800514:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800517:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051a:	eb 6d                	jmp    800589 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 d0             	pushl  -0x30(%ebp)
  800522:	57                   	push   %edi
  800523:	e8 6d 03 00 00       	call   800895 <strnlen>
  800528:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052b:	29 c1                	sub    %eax,%ecx
  80052d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800533:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	eb 0f                	jmp    800550 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	ff 75 e0             	pushl  -0x20(%ebp)
  800548:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 ff                	test   %edi,%edi
  800552:	7f ed                	jg     800541 <vprintfmt+0x1ae>
  800554:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800557:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80055a:	85 c9                	test   %ecx,%ecx
  80055c:	b8 00 00 00 00       	mov    $0x0,%eax
  800561:	0f 49 c1             	cmovns %ecx,%eax
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056f:	89 cb                	mov    %ecx,%ebx
  800571:	eb 16                	jmp    800589 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800573:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800577:	75 31                	jne    8005aa <vprintfmt+0x217>
					putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	50                   	push   %eax
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	83 c7 01             	add    $0x1,%edi
  80058c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800590:	0f be c2             	movsbl %dl,%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	74 59                	je     8005f0 <vprintfmt+0x25d>
  800597:	85 f6                	test   %esi,%esi
  800599:	78 d8                	js     800573 <vprintfmt+0x1e0>
  80059b:	83 ee 01             	sub    $0x1,%esi
  80059e:	79 d3                	jns    800573 <vprintfmt+0x1e0>
  8005a0:	89 df                	mov    %ebx,%edi
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	eb 37                	jmp    8005e1 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	0f be d2             	movsbl %dl,%edx
  8005ad:	83 ea 20             	sub    $0x20,%edx
  8005b0:	83 fa 5e             	cmp    $0x5e,%edx
  8005b3:	76 c4                	jbe    800579 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	6a 3f                	push   $0x3f
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb c1                	jmp    800586 <vprintfmt+0x1f3>
  8005c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d1:	eb b6                	jmp    800589 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 20                	push   $0x20
  8005d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005db:	83 ef 01             	sub    $0x1,%edi
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	7f ee                	jg     8005d3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005eb:	e9 1a 01 00 00       	jmp    80070a <vprintfmt+0x377>
  8005f0:	89 df                	mov    %ebx,%edi
  8005f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f8:	eb e7                	jmp    8005e1 <vprintfmt+0x24e>
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7e 3f                	jle    80063e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 50 04             	mov    0x4(%eax),%edx
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 40 08             	lea    0x8(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	79 5c                	jns    800678 <vprintfmt+0x2e5>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800627:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062a:	f7 da                	neg    %edx
  80062c:	83 d1 00             	adc    $0x0,%ecx
  80062f:	f7 d9                	neg    %ecx
  800631:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	e9 b2 00 00 00       	jmp    8006f0 <vprintfmt+0x35d>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	75 1b                	jne    80065d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 c1                	mov    %eax,%ecx
  80064c:	c1 f9 1f             	sar    $0x1f,%ecx
  80064f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
  80065b:	eb b9                	jmp    800616 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c1                	mov    %eax,%ecx
  800667:	c1 f9 1f             	sar    $0x1f,%ecx
  80066a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
  800676:	eb 9e                	jmp    800616 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800678:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80067e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800683:	eb 6b                	jmp    8006f0 <vprintfmt+0x35d>
	if (lflag >= 2)
  800685:	83 f9 01             	cmp    $0x1,%ecx
  800688:	7e 15                	jle    80069f <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	8b 48 04             	mov    0x4(%eax),%ecx
  800692:	8d 40 08             	lea    0x8(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800698:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069d:	eb 51                	jmp    8006f0 <vprintfmt+0x35d>
	else if (lflag)
  80069f:	85 c9                	test   %ecx,%ecx
  8006a1:	75 17                	jne    8006ba <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b8:	eb 36                	jmp    8006f0 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cf:	eb 1f                	jmp    8006f0 <vprintfmt+0x35d>
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 5b                	jle    800731 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 50 04             	mov    0x4(%eax),%edx
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8006e7:	89 d1                	mov    %edx,%ecx
  8006e9:	89 c2                	mov    %eax,%edx
			base = 8;
  8006eb:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f7:	57                   	push   %edi
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	50                   	push   %eax
  8006fc:	51                   	push   %ecx
  8006fd:	52                   	push   %edx
  8006fe:	89 da                	mov    %ebx,%edx
  800700:	89 f0                	mov    %esi,%eax
  800702:	e8 a3 fb ff ff       	call   8002aa <printnum>
			break;
  800707:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070d:	83 c7 01             	add    $0x1,%edi
  800710:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800714:	83 f8 25             	cmp    $0x25,%eax
  800717:	0f 84 8d fc ff ff    	je     8003aa <vprintfmt+0x17>
			if (ch == '\0')
  80071d:	85 c0                	test   %eax,%eax
  80071f:	0f 84 e8 00 00 00    	je     80080d <vprintfmt+0x47a>
			putch(ch, putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	50                   	push   %eax
  80072a:	ff d6                	call   *%esi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb dc                	jmp    80070d <vprintfmt+0x37a>
	else if (lflag)
  800731:	85 c9                	test   %ecx,%ecx
  800733:	75 13                	jne    800748 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	89 d0                	mov    %edx,%eax
  80073c:	99                   	cltd   
  80073d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800740:	8d 49 04             	lea    0x4(%ecx),%ecx
  800743:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800746:	eb 9f                	jmp    8006e7 <vprintfmt+0x354>
		return va_arg(*ap, long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	89 d0                	mov    %edx,%eax
  80074f:	99                   	cltd   
  800750:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800753:	8d 49 04             	lea    0x4(%ecx),%ecx
  800756:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800759:	eb 8c                	jmp    8006e7 <vprintfmt+0x354>
			putch('0', putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	6a 30                	push   $0x30
  800761:	ff d6                	call   *%esi
			putch('x', putdat);
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 78                	push   $0x78
  800769:	ff d6                	call   *%esi
			num = (unsigned long long)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 10                	mov    (%eax),%edx
  800770:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800775:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800778:	8d 40 04             	lea    0x4(%eax),%eax
  80077b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800783:	e9 68 ff ff ff       	jmp    8006f0 <vprintfmt+0x35d>
	if (lflag >= 2)
  800788:	83 f9 01             	cmp    $0x1,%ecx
  80078b:	7e 18                	jle    8007a5 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8b 48 04             	mov    0x4(%eax),%ecx
  800795:	8d 40 08             	lea    0x8(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a0:	e9 4b ff ff ff       	jmp    8006f0 <vprintfmt+0x35d>
	else if (lflag)
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	75 1a                	jne    8007c3 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007be:	e9 2d ff ff ff       	jmp    8006f0 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cd:	8d 40 04             	lea    0x4(%eax),%eax
  8007d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d8:	e9 13 ff ff ff       	jmp    8006f0 <vprintfmt+0x35d>
			putch(ch, putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 25                	push   $0x25
  8007e3:	ff d6                	call   *%esi
			break;
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	e9 1d ff ff ff       	jmp    80070a <vprintfmt+0x377>
			putch('%', putdat);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	53                   	push   %ebx
  8007f1:	6a 25                	push   $0x25
  8007f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	89 f8                	mov    %edi,%eax
  8007fa:	eb 03                	jmp    8007ff <vprintfmt+0x46c>
  8007fc:	83 e8 01             	sub    $0x1,%eax
  8007ff:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800803:	75 f7                	jne    8007fc <vprintfmt+0x469>
  800805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800808:	e9 fd fe ff ff       	jmp    80070a <vprintfmt+0x377>
}
  80080d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5f                   	pop    %edi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 18             	sub    $0x18,%esp
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800821:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800824:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800828:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800832:	85 c0                	test   %eax,%eax
  800834:	74 26                	je     80085c <vsnprintf+0x47>
  800836:	85 d2                	test   %edx,%edx
  800838:	7e 22                	jle    80085c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083a:	ff 75 14             	pushl  0x14(%ebp)
  80083d:	ff 75 10             	pushl  0x10(%ebp)
  800840:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	68 59 03 80 00       	push   $0x800359
  800849:	e8 45 fb ff ff       	call   800393 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800851:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800857:	83 c4 10             	add    $0x10,%esp
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    
		return -E_INVAL;
  80085c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800861:	eb f7                	jmp    80085a <vsnprintf+0x45>

00800863 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086c:	50                   	push   %eax
  80086d:	ff 75 10             	pushl  0x10(%ebp)
  800870:	ff 75 0c             	pushl  0xc(%ebp)
  800873:	ff 75 08             	pushl  0x8(%ebp)
  800876:	e8 9a ff ff ff       	call   800815 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	eb 03                	jmp    80088d <strlen+0x10>
		n++;
  80088a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800891:	75 f7                	jne    80088a <strlen+0xd>
	return n;
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	eb 03                	jmp    8008a8 <strnlen+0x13>
		n++;
  8008a5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	39 d0                	cmp    %edx,%eax
  8008aa:	74 06                	je     8008b2 <strnlen+0x1d>
  8008ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b0:	75 f3                	jne    8008a5 <strnlen+0x10>
	return n;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cd:	84 db                	test   %bl,%bl
  8008cf:	75 ef                	jne    8008c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008db:	53                   	push   %ebx
  8008dc:	e8 9c ff ff ff       	call   80087d <strlen>
  8008e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	01 d8                	add    %ebx,%eax
  8008e9:	50                   	push   %eax
  8008ea:	e8 c5 ff ff ff       	call   8008b4 <strcpy>
	return dst;
}
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800901:	89 f3                	mov    %esi,%ebx
  800903:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800906:	89 f2                	mov    %esi,%edx
  800908:	eb 0f                	jmp    800919 <strncpy+0x23>
		*dst++ = *src;
  80090a:	83 c2 01             	add    $0x1,%edx
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 39 01             	cmpb   $0x1,(%ecx)
  800916:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800919:	39 da                	cmp    %ebx,%edx
  80091b:	75 ed                	jne    80090a <strncpy+0x14>
	}
	return ret;
}
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 75 08             	mov    0x8(%ebp),%esi
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800931:	89 f0                	mov    %esi,%eax
  800933:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800937:	85 c9                	test   %ecx,%ecx
  800939:	75 0b                	jne    800946 <strlcpy+0x23>
  80093b:	eb 17                	jmp    800954 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800946:	39 d8                	cmp    %ebx,%eax
  800948:	74 07                	je     800951 <strlcpy+0x2e>
  80094a:	0f b6 0a             	movzbl (%edx),%ecx
  80094d:	84 c9                	test   %cl,%cl
  80094f:	75 ec                	jne    80093d <strlcpy+0x1a>
		*dst = '\0';
  800951:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800954:	29 f0                	sub    %esi,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800963:	eb 06                	jmp    80096b <strcmp+0x11>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strcmp+0x1c>
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 ef                	je     800965 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	89 c3                	mov    %eax,%ebx
  80098c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098f:	eb 06                	jmp    800997 <strncmp+0x17>
		n--, p++, q++;
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800997:	39 d8                	cmp    %ebx,%eax
  800999:	74 16                	je     8009b1 <strncmp+0x31>
  80099b:	0f b6 08             	movzbl (%eax),%ecx
  80099e:	84 c9                	test   %cl,%cl
  8009a0:	74 04                	je     8009a6 <strncmp+0x26>
  8009a2:	3a 0a                	cmp    (%edx),%cl
  8009a4:	74 eb                	je     800991 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 00             	movzbl (%eax),%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    
		return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b6:	eb f6                	jmp    8009ae <strncmp+0x2e>

008009b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c2:	0f b6 10             	movzbl (%eax),%edx
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	74 09                	je     8009d2 <strchr+0x1a>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	74 0a                	je     8009d7 <strchr+0x1f>
	for (; *s; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	eb f0                	jmp    8009c2 <strchr+0xa>
			return (char *) s;
	return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e3:	eb 03                	jmp    8009e8 <strfind+0xf>
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009eb:	38 ca                	cmp    %cl,%dl
  8009ed:	74 04                	je     8009f3 <strfind+0x1a>
  8009ef:	84 d2                	test   %dl,%dl
  8009f1:	75 f2                	jne    8009e5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a01:	85 c9                	test   %ecx,%ecx
  800a03:	74 13                	je     800a18 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a05:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0b:	75 05                	jne    800a12 <memset+0x1d>
  800a0d:	f6 c1 03             	test   $0x3,%cl
  800a10:	74 0d                	je     800a1f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	fc                   	cld    
  800a16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a18:	89 f8                	mov    %edi,%eax
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    
		c &= 0xFF;
  800a1f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a23:	89 d3                	mov    %edx,%ebx
  800a25:	c1 e3 08             	shl    $0x8,%ebx
  800a28:	89 d0                	mov    %edx,%eax
  800a2a:	c1 e0 18             	shl    $0x18,%eax
  800a2d:	89 d6                	mov    %edx,%esi
  800a2f:	c1 e6 10             	shl    $0x10,%esi
  800a32:	09 f0                	or     %esi,%eax
  800a34:	09 c2                	or     %eax,%edx
  800a36:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a38:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3b:	89 d0                	mov    %edx,%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb d6                	jmp    800a18 <memset+0x23>

00800a42 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a50:	39 c6                	cmp    %eax,%esi
  800a52:	73 35                	jae    800a89 <memmove+0x47>
  800a54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a57:	39 c2                	cmp    %eax,%edx
  800a59:	76 2e                	jbe    800a89 <memmove+0x47>
		s += n;
		d += n;
  800a5b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	09 fe                	or     %edi,%esi
  800a62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a68:	74 0c                	je     800a76 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6a:	83 ef 01             	sub    $0x1,%edi
  800a6d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a70:	fd                   	std    
  800a71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a73:	fc                   	cld    
  800a74:	eb 21                	jmp    800a97 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 ef                	jne    800a6a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7b:	83 ef 04             	sub    $0x4,%edi
  800a7e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a81:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a84:	fd                   	std    
  800a85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a87:	eb ea                	jmp    800a73 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a89:	89 f2                	mov    %esi,%edx
  800a8b:	09 c2                	or     %eax,%edx
  800a8d:	f6 c2 03             	test   $0x3,%dl
  800a90:	74 09                	je     800a9b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a92:	89 c7                	mov    %eax,%edi
  800a94:	fc                   	cld    
  800a95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 f2                	jne    800a92 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa8:	eb ed                	jmp    800a97 <memmove+0x55>

00800aaa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aad:	ff 75 10             	pushl  0x10(%ebp)
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	ff 75 08             	pushl  0x8(%ebp)
  800ab6:	e8 87 ff ff ff       	call   800a42 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac8:	89 c6                	mov    %eax,%esi
  800aca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	74 1c                	je     800aed <memcmp+0x30>
		if (*s1 != *s2)
  800ad1:	0f b6 08             	movzbl (%eax),%ecx
  800ad4:	0f b6 1a             	movzbl (%edx),%ebx
  800ad7:	38 d9                	cmp    %bl,%cl
  800ad9:	75 08                	jne    800ae3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	83 c2 01             	add    $0x1,%edx
  800ae1:	eb ea                	jmp    800acd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ae3:	0f b6 c1             	movzbl %cl,%eax
  800ae6:	0f b6 db             	movzbl %bl,%ebx
  800ae9:	29 d8                	sub    %ebx,%eax
  800aeb:	eb 05                	jmp    800af2 <memcmp+0x35>
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 09                	jae    800b11 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b08:	38 08                	cmp    %cl,(%eax)
  800b0a:	74 05                	je     800b11 <memfind+0x1b>
	for (; s < ends; s++)
  800b0c:	83 c0 01             	add    $0x1,%eax
  800b0f:	eb f3                	jmp    800b04 <memfind+0xe>
			break;
	return (void *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 01             	movzbl (%ecx),%eax
  800b27:	3c 20                	cmp    $0x20,%al
  800b29:	74 f6                	je     800b21 <strtol+0xe>
  800b2b:	3c 09                	cmp    $0x9,%al
  800b2d:	74 f2                	je     800b21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2f:	3c 2b                	cmp    $0x2b,%al
  800b31:	74 2e                	je     800b61 <strtol+0x4e>
	int neg = 0;
  800b33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b38:	3c 2d                	cmp    $0x2d,%al
  800b3a:	74 2f                	je     800b6b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b42:	75 05                	jne    800b49 <strtol+0x36>
  800b44:	80 39 30             	cmpb   $0x30,(%ecx)
  800b47:	74 2c                	je     800b75 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b49:	85 db                	test   %ebx,%ebx
  800b4b:	75 0a                	jne    800b57 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b52:	80 39 30             	cmpb   $0x30,(%ecx)
  800b55:	74 28                	je     800b7f <strtol+0x6c>
		base = 10;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5f:	eb 50                	jmp    800bb1 <strtol+0x9e>
		s++;
  800b61:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b64:	bf 00 00 00 00       	mov    $0x0,%edi
  800b69:	eb d1                	jmp    800b3c <strtol+0x29>
		s++, neg = 1;
  800b6b:	83 c1 01             	add    $0x1,%ecx
  800b6e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b73:	eb c7                	jmp    800b3c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b79:	74 0e                	je     800b89 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b7b:	85 db                	test   %ebx,%ebx
  800b7d:	75 d8                	jne    800b57 <strtol+0x44>
		s++, base = 8;
  800b7f:	83 c1 01             	add    $0x1,%ecx
  800b82:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b87:	eb ce                	jmp    800b57 <strtol+0x44>
		s += 2, base = 16;
  800b89:	83 c1 02             	add    $0x2,%ecx
  800b8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b91:	eb c4                	jmp    800b57 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b96:	89 f3                	mov    %esi,%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 29                	ja     800bc6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9d:	0f be d2             	movsbl %dl,%edx
  800ba0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba6:	7d 30                	jge    800bd8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba8:	83 c1 01             	add    $0x1,%ecx
  800bab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800baf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb1:	0f b6 11             	movzbl (%ecx),%edx
  800bb4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 09             	cmp    $0x9,%bl
  800bbc:	77 d5                	ja     800b93 <strtol+0x80>
			dig = *s - '0';
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	83 ea 30             	sub    $0x30,%edx
  800bc4:	eb dd                	jmp    800ba3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 08                	ja     800bd8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 37             	sub    $0x37,%edx
  800bd6:	eb cb                	jmp    800ba3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdc:	74 05                	je     800be3 <strtol+0xd0>
		*endptr = (char *) s;
  800bde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be3:	89 c2                	mov    %eax,%edx
  800be5:	f7 da                	neg    %edx
  800be7:	85 ff                	test   %edi,%edi
  800be9:	0f 45 c2             	cmovne %edx,%eax
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	89 c3                	mov    %eax,%ebx
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 c6                	mov    %eax,%esi
  800c08:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c44:	89 cb                	mov    %ecx,%ebx
  800c46:	89 cf                	mov    %ecx,%edi
  800c48:	89 ce                	mov    %ecx,%esi
  800c4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7f 08                	jg     800c58 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800c5c:	6a 03                	push   $0x3
  800c5e:	68 84 14 80 00       	push   $0x801484
  800c63:	6a 23                	push   $0x23
  800c65:	68 a1 14 80 00       	push   $0x8014a1
  800c6a:	e8 82 02 00 00       	call   800ef1 <_panic>

00800c6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_yield>:

void
sys_yield(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	89 f7                	mov    %esi,%edi
  800ccb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7f 08                	jg     800cd9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 04                	push   $0x4
  800cdf:	68 84 14 80 00       	push   $0x801484
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 a1 14 80 00       	push   $0x8014a1
  800ceb:	e8 01 02 00 00       	call   800ef1 <_panic>

00800cf0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	b8 05 00 00 00       	mov    $0x5,%eax
  800d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d07:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7f 08                	jg     800d1b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 05                	push   $0x5
  800d21:	68 84 14 80 00       	push   $0x801484
  800d26:	6a 23                	push   $0x23
  800d28:	68 a1 14 80 00       	push   $0x8014a1
  800d2d:	e8 bf 01 00 00       	call   800ef1 <_panic>

00800d32 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	89 de                	mov    %ebx,%esi
  800d4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7f 08                	jg     800d5d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 06                	push   $0x6
  800d63:	68 84 14 80 00       	push   $0x801484
  800d68:	6a 23                	push   $0x23
  800d6a:	68 a1 14 80 00       	push   $0x8014a1
  800d6f:	e8 7d 01 00 00       	call   800ef1 <_panic>

00800d74 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8d:	89 df                	mov    %ebx,%edi
  800d8f:	89 de                	mov    %ebx,%esi
  800d91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7f 08                	jg     800d9f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 08                	push   $0x8
  800da5:	68 84 14 80 00       	push   $0x801484
  800daa:	6a 23                	push   $0x23
  800dac:	68 a1 14 80 00       	push   $0x8014a1
  800db1:	e8 3b 01 00 00       	call   800ef1 <_panic>

00800db6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7f 08                	jg     800de1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 09                	push   $0x9
  800de7:	68 84 14 80 00       	push   $0x801484
  800dec:	6a 23                	push   $0x23
  800dee:	68 a1 14 80 00       	push   $0x8014a1
  800df3:	e8 f9 00 00 00       	call   800ef1 <_panic>

00800df8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e09:	be 00 00 00 00       	mov    $0x0,%esi
  800e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e14:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e31:	89 cb                	mov    %ecx,%ebx
  800e33:	89 cf                	mov    %ecx,%edi
  800e35:	89 ce                	mov    %ecx,%esi
  800e37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7f 08                	jg     800e45 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 0c                	push   $0xc
  800e4b:	68 84 14 80 00       	push   $0x801484
  800e50:	6a 23                	push   $0x23
  800e52:	68 a1 14 80 00       	push   $0x8014a1
  800e57:	e8 95 00 00 00       	call   800ef1 <_panic>

00800e5c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e62:	68 bb 14 80 00       	push   $0x8014bb
  800e67:	6a 51                	push   $0x51
  800e69:	68 af 14 80 00       	push   $0x8014af
  800e6e:	e8 7e 00 00 00       	call   800ef1 <_panic>

00800e73 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e79:	68 ba 14 80 00       	push   $0x8014ba
  800e7e:	6a 58                	push   $0x58
  800e80:	68 af 14 80 00       	push   $0x8014af
  800e85:	e8 67 00 00 00       	call   800ef1 <_panic>

00800e8a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e90:	68 d0 14 80 00       	push   $0x8014d0
  800e95:	6a 1a                	push   $0x1a
  800e97:	68 e9 14 80 00       	push   $0x8014e9
  800e9c:	e8 50 00 00 00       	call   800ef1 <_panic>

00800ea1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800ea7:	68 f3 14 80 00       	push   $0x8014f3
  800eac:	6a 2a                	push   $0x2a
  800eae:	68 e9 14 80 00       	push   $0x8014e9
  800eb3:	e8 39 00 00 00       	call   800ef1 <_panic>

00800eb8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ec3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800ec6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ecc:	8b 52 50             	mov    0x50(%edx),%edx
  800ecf:	39 ca                	cmp    %ecx,%edx
  800ed1:	74 11                	je     800ee4 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800ed3:	83 c0 01             	add    $0x1,%eax
  800ed6:	3d 00 04 00 00       	cmp    $0x400,%eax
  800edb:	75 e6                	jne    800ec3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	eb 0b                	jmp    800eef <ipc_find_env+0x37>
			return envs[i].env_id;
  800ee4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eec:	8b 40 48             	mov    0x48(%eax),%eax
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ef6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ef9:	8b 35 08 20 80 00    	mov    0x802008,%esi
  800eff:	e8 6b fd ff ff       	call   800c6f <sys_getenvid>
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	ff 75 0c             	pushl  0xc(%ebp)
  800f0a:	ff 75 08             	pushl  0x8(%ebp)
  800f0d:	56                   	push   %esi
  800f0e:	50                   	push   %eax
  800f0f:	68 0c 15 80 00       	push   $0x80150c
  800f14:	e8 7d f3 ff ff       	call   800296 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f19:	83 c4 18             	add    $0x18,%esp
  800f1c:	53                   	push   %ebx
  800f1d:	ff 75 10             	pushl  0x10(%ebp)
  800f20:	e8 20 f3 ff ff       	call   800245 <vcprintf>
	cprintf("\n");
  800f25:	c7 04 24 92 11 80 00 	movl   $0x801192,(%esp)
  800f2c:	e8 65 f3 ff ff       	call   800296 <cprintf>
  800f31:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f34:	cc                   	int3   
  800f35:	eb fd                	jmp    800f34 <_panic+0x43>
  800f37:	66 90                	xchg   %ax,%ax
  800f39:	66 90                	xchg   %ax,%ax
  800f3b:	66 90                	xchg   %ax,%ax
  800f3d:	66 90                	xchg   %ax,%ax
  800f3f:	90                   	nop

00800f40 <__udivdi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f57:	85 d2                	test   %edx,%edx
  800f59:	75 35                	jne    800f90 <__udivdi3+0x50>
  800f5b:	39 f3                	cmp    %esi,%ebx
  800f5d:	0f 87 bd 00 00 00    	ja     801020 <__udivdi3+0xe0>
  800f63:	85 db                	test   %ebx,%ebx
  800f65:	89 d9                	mov    %ebx,%ecx
  800f67:	75 0b                	jne    800f74 <__udivdi3+0x34>
  800f69:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6e:	31 d2                	xor    %edx,%edx
  800f70:	f7 f3                	div    %ebx
  800f72:	89 c1                	mov    %eax,%ecx
  800f74:	31 d2                	xor    %edx,%edx
  800f76:	89 f0                	mov    %esi,%eax
  800f78:	f7 f1                	div    %ecx
  800f7a:	89 c6                	mov    %eax,%esi
  800f7c:	89 e8                	mov    %ebp,%eax
  800f7e:	89 f7                	mov    %esi,%edi
  800f80:	f7 f1                	div    %ecx
  800f82:	89 fa                	mov    %edi,%edx
  800f84:	83 c4 1c             	add    $0x1c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	39 f2                	cmp    %esi,%edx
  800f92:	77 7c                	ja     801010 <__udivdi3+0xd0>
  800f94:	0f bd fa             	bsr    %edx,%edi
  800f97:	83 f7 1f             	xor    $0x1f,%edi
  800f9a:	0f 84 98 00 00 00    	je     801038 <__udivdi3+0xf8>
  800fa0:	89 f9                	mov    %edi,%ecx
  800fa2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa7:	29 f8                	sub    %edi,%eax
  800fa9:	d3 e2                	shl    %cl,%edx
  800fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb9:	09 d1                	or     %edx,%ecx
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 e3                	shl    %cl,%ebx
  800fc5:	89 c1                	mov    %eax,%ecx
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcf:	d3 e6                	shl    %cl,%esi
  800fd1:	89 eb                	mov    %ebp,%ebx
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	d3 eb                	shr    %cl,%ebx
  800fd7:	09 de                	or     %ebx,%esi
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	f7 74 24 08          	divl   0x8(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	f7 64 24 0c          	mull   0xc(%esp)
  800fe7:	39 d6                	cmp    %edx,%esi
  800fe9:	72 0c                	jb     800ff7 <__udivdi3+0xb7>
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	39 c5                	cmp    %eax,%ebp
  800ff1:	73 5d                	jae    801050 <__udivdi3+0x110>
  800ff3:	39 d6                	cmp    %edx,%esi
  800ff5:	75 59                	jne    801050 <__udivdi3+0x110>
  800ff7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ffa:	31 ff                	xor    %edi,%edi
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	83 c4 1c             	add    $0x1c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	8d 76 00             	lea    0x0(%esi),%esi
  801009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801010:	31 ff                	xor    %edi,%edi
  801012:	31 c0                	xor    %eax,%eax
  801014:	89 fa                	mov    %edi,%edx
  801016:	83 c4 1c             	add    $0x1c,%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    
  80101e:	66 90                	xchg   %ax,%ax
  801020:	31 ff                	xor    %edi,%edi
  801022:	89 e8                	mov    %ebp,%eax
  801024:	89 f2                	mov    %esi,%edx
  801026:	f7 f3                	div    %ebx
  801028:	89 fa                	mov    %edi,%edx
  80102a:	83 c4 1c             	add    $0x1c,%esp
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    
  801032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801038:	39 f2                	cmp    %esi,%edx
  80103a:	72 06                	jb     801042 <__udivdi3+0x102>
  80103c:	31 c0                	xor    %eax,%eax
  80103e:	39 eb                	cmp    %ebp,%ebx
  801040:	77 d2                	ja     801014 <__udivdi3+0xd4>
  801042:	b8 01 00 00 00       	mov    $0x1,%eax
  801047:	eb cb                	jmp    801014 <__udivdi3+0xd4>
  801049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801050:	89 d8                	mov    %ebx,%eax
  801052:	31 ff                	xor    %edi,%edi
  801054:	eb be                	jmp    801014 <__udivdi3+0xd4>
  801056:	66 90                	xchg   %ax,%ax
  801058:	66 90                	xchg   %ax,%ax
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 1c             	sub    $0x1c,%esp
  801067:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80106b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80106f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801077:	85 ed                	test   %ebp,%ebp
  801079:	89 f0                	mov    %esi,%eax
  80107b:	89 da                	mov    %ebx,%edx
  80107d:	75 19                	jne    801098 <__umoddi3+0x38>
  80107f:	39 df                	cmp    %ebx,%edi
  801081:	0f 86 b1 00 00 00    	jbe    801138 <__umoddi3+0xd8>
  801087:	f7 f7                	div    %edi
  801089:	89 d0                	mov    %edx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 1c             	add    $0x1c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	39 dd                	cmp    %ebx,%ebp
  80109a:	77 f1                	ja     80108d <__umoddi3+0x2d>
  80109c:	0f bd cd             	bsr    %ebp,%ecx
  80109f:	83 f1 1f             	xor    $0x1f,%ecx
  8010a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010a6:	0f 84 b4 00 00 00    	je     801160 <__umoddi3+0x100>
  8010ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010b7:	29 c2                	sub    %eax,%edx
  8010b9:	89 c1                	mov    %eax,%ecx
  8010bb:	89 f8                	mov    %edi,%eax
  8010bd:	d3 e5                	shl    %cl,%ebp
  8010bf:	89 d1                	mov    %edx,%ecx
  8010c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c5:	d3 e8                	shr    %cl,%eax
  8010c7:	09 c5                	or     %eax,%ebp
  8010c9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010cd:	89 c1                	mov    %eax,%ecx
  8010cf:	d3 e7                	shl    %cl,%edi
  8010d1:	89 d1                	mov    %edx,%ecx
  8010d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010d7:	89 df                	mov    %ebx,%edi
  8010d9:	d3 ef                	shr    %cl,%edi
  8010db:	89 c1                	mov    %eax,%ecx
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	d3 e3                	shl    %cl,%ebx
  8010e1:	89 d1                	mov    %edx,%ecx
  8010e3:	89 fa                	mov    %edi,%edx
  8010e5:	d3 e8                	shr    %cl,%eax
  8010e7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ec:	09 d8                	or     %ebx,%eax
  8010ee:	f7 f5                	div    %ebp
  8010f0:	d3 e6                	shl    %cl,%esi
  8010f2:	89 d1                	mov    %edx,%ecx
  8010f4:	f7 64 24 08          	mull   0x8(%esp)
  8010f8:	39 d1                	cmp    %edx,%ecx
  8010fa:	89 c3                	mov    %eax,%ebx
  8010fc:	89 d7                	mov    %edx,%edi
  8010fe:	72 06                	jb     801106 <__umoddi3+0xa6>
  801100:	75 0e                	jne    801110 <__umoddi3+0xb0>
  801102:	39 c6                	cmp    %eax,%esi
  801104:	73 0a                	jae    801110 <__umoddi3+0xb0>
  801106:	2b 44 24 08          	sub    0x8(%esp),%eax
  80110a:	19 ea                	sbb    %ebp,%edx
  80110c:	89 d7                	mov    %edx,%edi
  80110e:	89 c3                	mov    %eax,%ebx
  801110:	89 ca                	mov    %ecx,%edx
  801112:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801117:	29 de                	sub    %ebx,%esi
  801119:	19 fa                	sbb    %edi,%edx
  80111b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80111f:	89 d0                	mov    %edx,%eax
  801121:	d3 e0                	shl    %cl,%eax
  801123:	89 d9                	mov    %ebx,%ecx
  801125:	d3 ee                	shr    %cl,%esi
  801127:	d3 ea                	shr    %cl,%edx
  801129:	09 f0                	or     %esi,%eax
  80112b:	83 c4 1c             	add    $0x1c,%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    
  801133:	90                   	nop
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	85 ff                	test   %edi,%edi
  80113a:	89 f9                	mov    %edi,%ecx
  80113c:	75 0b                	jne    801149 <__umoddi3+0xe9>
  80113e:	b8 01 00 00 00       	mov    $0x1,%eax
  801143:	31 d2                	xor    %edx,%edx
  801145:	f7 f7                	div    %edi
  801147:	89 c1                	mov    %eax,%ecx
  801149:	89 d8                	mov    %ebx,%eax
  80114b:	31 d2                	xor    %edx,%edx
  80114d:	f7 f1                	div    %ecx
  80114f:	89 f0                	mov    %esi,%eax
  801151:	f7 f1                	div    %ecx
  801153:	e9 31 ff ff ff       	jmp    801089 <__umoddi3+0x29>
  801158:	90                   	nop
  801159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801160:	39 dd                	cmp    %ebx,%ebp
  801162:	72 08                	jb     80116c <__umoddi3+0x10c>
  801164:	39 f7                	cmp    %esi,%edi
  801166:	0f 87 21 ff ff ff    	ja     80108d <__umoddi3+0x2d>
  80116c:	89 da                	mov    %ebx,%edx
  80116e:	89 f0                	mov    %esi,%eax
  801170:	29 f8                	sub    %edi,%eax
  801172:	19 ea                	sbb    %ebp,%edx
  801174:	e9 14 ff ff ff       	jmp    80108d <__umoddi3+0x2d>
