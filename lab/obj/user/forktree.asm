
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 71 0b 00 00       	call   800bb3 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 10 80 00       	push   $0x801060
  80004c:	e8 89 01 00 00       	call   8001da <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 3e 07 00 00       	call   8007c1 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 71 10 80 00       	push   $0x801071
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 fb 06 00 00       	call   8007a7 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 ec 0c 00 00       	call   800da0 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 6a 00 00 00       	call   800133 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 70 10 80 00       	push   $0x801070
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ee:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000f5:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8000f8:	e8 b6 0a 00 00       	call   800bb3 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x37>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 aa ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 32 0a 00 00       	call   800b72 <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	83 ec 04             	sub    $0x4,%esp
  80014c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014f:	8b 13                	mov    (%ebx),%edx
  800151:	8d 42 01             	lea    0x1(%edx),%eax
  800154:	89 03                	mov    %eax,(%ebx)
  800156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800159:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800162:	74 09                	je     80016d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800164:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	68 ff 00 00 00       	push   $0xff
  800175:	8d 43 08             	lea    0x8(%ebx),%eax
  800178:	50                   	push   %eax
  800179:	e8 b7 09 00 00       	call   800b35 <sys_cputs>
		b->idx = 0;
  80017e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800184:	83 c4 10             	add    $0x10,%esp
  800187:	eb db                	jmp    800164 <putch+0x1f>

00800189 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800192:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800199:	00 00 00 
	b.cnt = 0;
  80019c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a6:	ff 75 0c             	pushl  0xc(%ebp)
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	68 45 01 80 00       	push   $0x800145
  8001b8:	e8 1a 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bd:	83 c4 08             	add    $0x8,%esp
  8001c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	e8 63 09 00 00       	call   800b35 <sys_cputs>

	return b.cnt;
}
  8001d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e3:	50                   	push   %eax
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	e8 9d ff ff ff       	call   800189 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 1c             	sub    $0x1c,%esp
  8001f7:	89 c7                	mov    %eax,%edi
  8001f9:	89 d6                	mov    %edx,%esi
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800207:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800212:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800215:	39 d3                	cmp    %edx,%ebx
  800217:	72 05                	jb     80021e <printnum+0x30>
  800219:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021c:	77 7a                	ja     800298 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	ff 75 18             	pushl  0x18(%ebp)
  800224:	8b 45 14             	mov    0x14(%ebp),%eax
  800227:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80022a:	53                   	push   %ebx
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	ff 75 e4             	pushl  -0x1c(%ebp)
  800234:	ff 75 e0             	pushl  -0x20(%ebp)
  800237:	ff 75 dc             	pushl  -0x24(%ebp)
  80023a:	ff 75 d8             	pushl  -0x28(%ebp)
  80023d:	e8 de 0b 00 00       	call   800e20 <__udivdi3>
  800242:	83 c4 18             	add    $0x18,%esp
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	89 f2                	mov    %esi,%edx
  800249:	89 f8                	mov    %edi,%eax
  80024b:	e8 9e ff ff ff       	call   8001ee <printnum>
  800250:	83 c4 20             	add    $0x20,%esp
  800253:	eb 13                	jmp    800268 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	56                   	push   %esi
  800259:	ff 75 18             	pushl  0x18(%ebp)
  80025c:	ff d7                	call   *%edi
  80025e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800261:	83 eb 01             	sub    $0x1,%ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f ed                	jg     800255 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	83 ec 04             	sub    $0x4,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 c0 0c 00 00       	call   800f40 <__umoddi3>
  800280:	83 c4 14             	add    $0x14,%esp
  800283:	0f be 80 80 10 80 00 	movsbl 0x801080(%eax),%eax
  80028a:	50                   	push   %eax
  80028b:	ff d7                	call   *%edi
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    
  800298:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029b:	eb c4                	jmp    800261 <printnum+0x73>

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e9:	e9 63 03 00 00       	jmp    800651 <vprintfmt+0x37a>
		padc = ' ';
  8002ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800300:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800307:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8d 47 01             	lea    0x1(%edi),%eax
  80030f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800312:	0f b6 17             	movzbl (%edi),%edx
  800315:	8d 42 dd             	lea    -0x23(%edx),%eax
  800318:	3c 55                	cmp    $0x55,%al
  80031a:	0f 87 11 04 00 00    	ja     800731 <vprintfmt+0x45a>
  800320:	0f b6 c0             	movzbl %al,%eax
  800323:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800331:	eb d9                	jmp    80030c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800336:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033a:	eb d0                	jmp    80030c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	0f b6 d2             	movzbl %dl,%edx
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800351:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800354:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800357:	83 f9 09             	cmp    $0x9,%ecx
  80035a:	77 55                	ja     8003b1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80035c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035f:	eb e9                	jmp    80034a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8b 00                	mov    (%eax),%eax
  800366:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 40 04             	lea    0x4(%eax),%eax
  80036f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800375:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800379:	79 91                	jns    80030c <vprintfmt+0x35>
				width = precision, precision = -1;
  80037b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800381:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800388:	eb 82                	jmp    80030c <vprintfmt+0x35>
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	85 c0                	test   %eax,%eax
  80038f:	ba 00 00 00 00       	mov    $0x0,%edx
  800394:	0f 49 d0             	cmovns %eax,%edx
  800397:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039d:	e9 6a ff ff ff       	jmp    80030c <vprintfmt+0x35>
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ac:	e9 5b ff ff ff       	jmp    80030c <vprintfmt+0x35>
  8003b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b7:	eb bc                	jmp    800375 <vprintfmt+0x9e>
			lflag++;
  8003b9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bf:	e9 48 ff ff ff       	jmp    80030c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	ff 30                	pushl  (%eax)
  8003d0:	ff d6                	call   *%esi
			break;
  8003d2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d8:	e9 71 02 00 00       	jmp    80064e <vprintfmt+0x377>
			err = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 78 04             	lea    0x4(%eax),%edi
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	99                   	cltd   
  8003e6:	31 d0                	xor    %edx,%eax
  8003e8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ea:	83 f8 08             	cmp    $0x8,%eax
  8003ed:	7f 23                	jg     800412 <vprintfmt+0x13b>
  8003ef:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 18                	je     800412 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003fa:	52                   	push   %edx
  8003fb:	68 a1 10 80 00       	push   $0x8010a1
  800400:	53                   	push   %ebx
  800401:	56                   	push   %esi
  800402:	e8 b3 fe ff ff       	call   8002ba <printfmt>
  800407:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040d:	e9 3c 02 00 00       	jmp    80064e <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800412:	50                   	push   %eax
  800413:	68 98 10 80 00       	push   $0x801098
  800418:	53                   	push   %ebx
  800419:	56                   	push   %esi
  80041a:	e8 9b fe ff ff       	call   8002ba <printfmt>
  80041f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800422:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800425:	e9 24 02 00 00       	jmp    80064e <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	83 c0 04             	add    $0x4,%eax
  800430:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800438:	85 ff                	test   %edi,%edi
  80043a:	b8 91 10 80 00       	mov    $0x801091,%eax
  80043f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800442:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800446:	0f 8e bd 00 00 00    	jle    800509 <vprintfmt+0x232>
  80044c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800450:	75 0e                	jne    800460 <vprintfmt+0x189>
  800452:	89 75 08             	mov    %esi,0x8(%ebp)
  800455:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800458:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80045b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80045e:	eb 6d                	jmp    8004cd <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 d0             	pushl  -0x30(%ebp)
  800466:	57                   	push   %edi
  800467:	e8 6d 03 00 00       	call   8007d9 <strnlen>
  80046c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046f:	29 c1                	sub    %eax,%ecx
  800471:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800477:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800481:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0f                	jmp    800494 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	ff 75 e0             	pushl  -0x20(%ebp)
  80048c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	83 ef 01             	sub    $0x1,%edi
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 ff                	test   %edi,%edi
  800496:	7f ed                	jg     800485 <vprintfmt+0x1ae>
  800498:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c1             	cmovns %ecx,%eax
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	89 cb                	mov    %ecx,%ebx
  8004b5:	eb 16                	jmp    8004cd <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bb:	75 31                	jne    8004ee <vprintfmt+0x217>
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	50                   	push   %eax
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	83 c7 01             	add    $0x1,%edi
  8004d0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d4:	0f be c2             	movsbl %dl,%eax
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	74 59                	je     800534 <vprintfmt+0x25d>
  8004db:	85 f6                	test   %esi,%esi
  8004dd:	78 d8                	js     8004b7 <vprintfmt+0x1e0>
  8004df:	83 ee 01             	sub    $0x1,%esi
  8004e2:	79 d3                	jns    8004b7 <vprintfmt+0x1e0>
  8004e4:	89 df                	mov    %ebx,%edi
  8004e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ec:	eb 37                	jmp    800525 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ee:	0f be d2             	movsbl %dl,%edx
  8004f1:	83 ea 20             	sub    $0x20,%edx
  8004f4:	83 fa 5e             	cmp    $0x5e,%edx
  8004f7:	76 c4                	jbe    8004bd <vprintfmt+0x1e6>
					putch('?', putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	6a 3f                	push   $0x3f
  800501:	ff 55 08             	call   *0x8(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	eb c1                	jmp    8004ca <vprintfmt+0x1f3>
  800509:	89 75 08             	mov    %esi,0x8(%ebp)
  80050c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800512:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800515:	eb b6                	jmp    8004cd <vprintfmt+0x1f6>
				putch(' ', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	53                   	push   %ebx
  80051b:	6a 20                	push   $0x20
  80051d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051f:	83 ef 01             	sub    $0x1,%edi
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 ff                	test   %edi,%edi
  800527:	7f ee                	jg     800517 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
  80052f:	e9 1a 01 00 00       	jmp    80064e <vprintfmt+0x377>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	eb e7                	jmp    800525 <vprintfmt+0x24e>
	if (lflag >= 2)
  80053e:	83 f9 01             	cmp    $0x1,%ecx
  800541:	7e 3f                	jle    800582 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 50 04             	mov    0x4(%eax),%edx
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 40 08             	lea    0x8(%eax),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80055a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055e:	79 5c                	jns    8005bc <vprintfmt+0x2e5>
				putch('-', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 2d                	push   $0x2d
  800566:	ff d6                	call   *%esi
				num = -(long long) num;
  800568:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056e:	f7 da                	neg    %edx
  800570:	83 d1 00             	adc    $0x0,%ecx
  800573:	f7 d9                	neg    %ecx
  800575:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800578:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057d:	e9 b2 00 00 00       	jmp    800634 <vprintfmt+0x35d>
	else if (lflag)
  800582:	85 c9                	test   %ecx,%ecx
  800584:	75 1b                	jne    8005a1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	89 c1                	mov    %eax,%ecx
  800590:	c1 f9 1f             	sar    $0x1f,%ecx
  800593:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
  80059f:	eb b9                	jmp    80055a <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 c1                	mov    %eax,%ecx
  8005ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 40 04             	lea    0x4(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ba:	eb 9e                	jmp    80055a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	eb 6b                	jmp    800634 <vprintfmt+0x35d>
	if (lflag >= 2)
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7e 15                	jle    8005e3 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d6:	8d 40 08             	lea    0x8(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e1:	eb 51                	jmp    800634 <vprintfmt+0x35d>
	else if (lflag)
  8005e3:	85 c9                	test   %ecx,%ecx
  8005e5:	75 17                	jne    8005fe <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f1:	8d 40 04             	lea    0x4(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fc:	eb 36                	jmp    800634 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	b9 00 00 00 00       	mov    $0x0,%ecx
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800613:	eb 1f                	jmp    800634 <vprintfmt+0x35d>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 5b                	jle    800675 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 50 04             	mov    0x4(%eax),%edx
  800620:	8b 00                	mov    (%eax),%eax
  800622:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800625:	8d 49 08             	lea    0x8(%ecx),%ecx
  800628:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80062b:	89 d1                	mov    %edx,%ecx
  80062d:	89 c2                	mov    %eax,%edx
			base = 8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063b:	57                   	push   %edi
  80063c:	ff 75 e0             	pushl  -0x20(%ebp)
  80063f:	50                   	push   %eax
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	89 da                	mov    %ebx,%edx
  800644:	89 f0                	mov    %esi,%eax
  800646:	e8 a3 fb ff ff       	call   8001ee <printnum>
			break;
  80064b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800651:	83 c7 01             	add    $0x1,%edi
  800654:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800658:	83 f8 25             	cmp    $0x25,%eax
  80065b:	0f 84 8d fc ff ff    	je     8002ee <vprintfmt+0x17>
			if (ch == '\0')
  800661:	85 c0                	test   %eax,%eax
  800663:	0f 84 e8 00 00 00    	je     800751 <vprintfmt+0x47a>
			putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	50                   	push   %eax
  80066e:	ff d6                	call   *%esi
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb dc                	jmp    800651 <vprintfmt+0x37a>
	else if (lflag)
  800675:	85 c9                	test   %ecx,%ecx
  800677:	75 13                	jne    80068c <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	89 d0                	mov    %edx,%eax
  800680:	99                   	cltd   
  800681:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800684:	8d 49 04             	lea    0x4(%ecx),%ecx
  800687:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80068a:	eb 9f                	jmp    80062b <vprintfmt+0x354>
		return va_arg(*ap, long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	89 d0                	mov    %edx,%eax
  800693:	99                   	cltd   
  800694:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800697:	8d 49 04             	lea    0x4(%ecx),%ecx
  80069a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80069d:	eb 8c                	jmp    80062b <vprintfmt+0x354>
			putch('0', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 30                	push   $0x30
  8006a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 78                	push   $0x78
  8006ad:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006bc:	8d 40 04             	lea    0x4(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c7:	e9 68 ff ff ff       	jmp    800634 <vprintfmt+0x35d>
	if (lflag >= 2)
  8006cc:	83 f9 01             	cmp    $0x1,%ecx
  8006cf:	7e 18                	jle    8006e9 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e4:	e9 4b ff ff ff       	jmp    800634 <vprintfmt+0x35d>
	else if (lflag)
  8006e9:	85 c9                	test   %ecx,%ecx
  8006eb:	75 1a                	jne    800707 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fd:	b8 10 00 00 00       	mov    $0x10,%eax
  800702:	e9 2d ff ff ff       	jmp    800634 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	8d 40 04             	lea    0x4(%eax),%eax
  800714:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
  80071c:	e9 13 ff ff ff       	jmp    800634 <vprintfmt+0x35d>
			putch(ch, putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 25                	push   $0x25
  800727:	ff d6                	call   *%esi
			break;
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	e9 1d ff ff ff       	jmp    80064e <vprintfmt+0x377>
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	89 f8                	mov    %edi,%eax
  80073e:	eb 03                	jmp    800743 <vprintfmt+0x46c>
  800740:	83 e8 01             	sub    $0x1,%eax
  800743:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800747:	75 f7                	jne    800740 <vprintfmt+0x469>
  800749:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074c:	e9 fd fe ff ff       	jmp    80064e <vprintfmt+0x377>
}
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800768:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800776:	85 c0                	test   %eax,%eax
  800778:	74 26                	je     8007a0 <vsnprintf+0x47>
  80077a:	85 d2                	test   %edx,%edx
  80077c:	7e 22                	jle    8007a0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077e:	ff 75 14             	pushl  0x14(%ebp)
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	68 9d 02 80 00       	push   $0x80029d
  80078d:	e8 45 fb ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800792:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800795:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079b:	83 c4 10             	add    $0x10,%esp
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    
		return -E_INVAL;
  8007a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a5:	eb f7                	jmp    80079e <vsnprintf+0x45>

008007a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	ff 75 08             	pushl  0x8(%ebp)
  8007ba:	e8 9a ff ff ff       	call   800759 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 03                	jmp    8007d1 <strlen+0x10>
		n++;
  8007ce:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d5:	75 f7                	jne    8007ce <strlen+0xd>
	return n;
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 03                	jmp    8007ec <strnlen+0x13>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	39 d0                	cmp    %edx,%eax
  8007ee:	74 06                	je     8007f6 <strnlen+0x1d>
  8007f0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f4:	75 f3                	jne    8007e9 <strnlen+0x10>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800802:	89 c2                	mov    %eax,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800811:	84 db                	test   %bl,%bl
  800813:	75 ef                	jne    800804 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081f:	53                   	push   %ebx
  800820:	e8 9c ff ff ff       	call   8007c1 <strlen>
  800825:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	01 d8                	add    %ebx,%eax
  80082d:	50                   	push   %eax
  80082e:	e8 c5 ff ff ff       	call   8007f8 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	89 f3                	mov    %esi,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	89 f2                	mov    %esi,%edx
  80084c:	eb 0f                	jmp    80085d <strncpy+0x23>
		*dst++ = *src;
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800857:	80 39 01             	cmpb   $0x1,(%ecx)
  80085a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80085d:	39 da                	cmp    %ebx,%edx
  80085f:	75 ed                	jne    80084e <strncpy+0x14>
	}
	return ret;
}
  800861:	89 f0                	mov    %esi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800875:	89 f0                	mov    %esi,%eax
  800877:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087b:	85 c9                	test   %ecx,%ecx
  80087d:	75 0b                	jne    80088a <strlcpy+0x23>
  80087f:	eb 17                	jmp    800898 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800881:	83 c2 01             	add    $0x1,%edx
  800884:	83 c0 01             	add    $0x1,%eax
  800887:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80088a:	39 d8                	cmp    %ebx,%eax
  80088c:	74 07                	je     800895 <strlcpy+0x2e>
  80088e:	0f b6 0a             	movzbl (%edx),%ecx
  800891:	84 c9                	test   %cl,%cl
  800893:	75 ec                	jne    800881 <strlcpy+0x1a>
		*dst = '\0';
  800895:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strcmp+0x11>
		p++, q++;
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008af:	0f b6 01             	movzbl (%ecx),%eax
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 04                	je     8008ba <strcmp+0x1c>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	74 ef                	je     8008a9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 c0             	movzbl %al,%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 c3                	mov    %eax,%ebx
  8008d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strncmp+0x17>
		n--, p++, q++;
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008db:	39 d8                	cmp    %ebx,%eax
  8008dd:	74 16                	je     8008f5 <strncmp+0x31>
  8008df:	0f b6 08             	movzbl (%eax),%ecx
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 04                	je     8008ea <strncmp+0x26>
  8008e6:	3a 0a                	cmp    (%edx),%cl
  8008e8:	74 eb                	je     8008d5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	0f b6 00             	movzbl (%eax),%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb f6                	jmp    8008f2 <strncmp+0x2e>

008008fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	0f b6 10             	movzbl (%eax),%edx
  800909:	84 d2                	test   %dl,%dl
  80090b:	74 09                	je     800916 <strchr+0x1a>
		if (*s == c)
  80090d:	38 ca                	cmp    %cl,%dl
  80090f:	74 0a                	je     80091b <strchr+0x1f>
	for (; *s; s++)
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	eb f0                	jmp    800906 <strchr+0xa>
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 03                	jmp    80092c <strfind+0xf>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 04                	je     800937 <strfind+0x1a>
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f2                	jne    800929 <strfind+0xc>
			break;
	return (char *) s;
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 13                	je     80095c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 05                	jne    800956 <memset+0x1d>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	74 0d                	je     800963 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	fc                   	cld    
  80095a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095c:	89 f8                	mov    %edi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5f                   	pop    %edi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    
		c &= 0xFF;
  800963:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800967:	89 d3                	mov    %edx,%ebx
  800969:	c1 e3 08             	shl    $0x8,%ebx
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	c1 e0 18             	shl    $0x18,%eax
  800971:	89 d6                	mov    %edx,%esi
  800973:	c1 e6 10             	shl    $0x10,%esi
  800976:	09 f0                	or     %esi,%eax
  800978:	09 c2                	or     %eax,%edx
  80097a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80097c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097f:	89 d0                	mov    %edx,%eax
  800981:	fc                   	cld    
  800982:	f3 ab                	rep stos %eax,%es:(%edi)
  800984:	eb d6                	jmp    80095c <memset+0x23>

00800986 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800994:	39 c6                	cmp    %eax,%esi
  800996:	73 35                	jae    8009cd <memmove+0x47>
  800998:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099b:	39 c2                	cmp    %eax,%edx
  80099d:	76 2e                	jbe    8009cd <memmove+0x47>
		s += n;
		d += n;
  80099f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	09 fe                	or     %edi,%esi
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	74 0c                	je     8009ba <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ae:	83 ef 01             	sub    $0x1,%edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 21                	jmp    8009db <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 ef                	jne    8009ae <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009bf:	83 ef 04             	sub    $0x4,%edi
  8009c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb ea                	jmp    8009b7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	89 f2                	mov    %esi,%edx
  8009cf:	09 c2                	or     %eax,%edx
  8009d1:	f6 c2 03             	test   $0x3,%dl
  8009d4:	74 09                	je     8009df <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 f2                	jne    8009d6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e7:	89 c7                	mov    %eax,%edi
  8009e9:	fc                   	cld    
  8009ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ec:	eb ed                	jmp    8009db <memmove+0x55>

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f1:	ff 75 10             	pushl  0x10(%ebp)
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	ff 75 08             	pushl  0x8(%ebp)
  8009fa:	e8 87 ff ff ff       	call   800986 <memmove>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 c6                	mov    %eax,%esi
  800a0e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	39 f0                	cmp    %esi,%eax
  800a13:	74 1c                	je     800a31 <memcmp+0x30>
		if (*s1 != *s2)
  800a15:	0f b6 08             	movzbl (%eax),%ecx
  800a18:	0f b6 1a             	movzbl (%edx),%ebx
  800a1b:	38 d9                	cmp    %bl,%cl
  800a1d:	75 08                	jne    800a27 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	eb ea                	jmp    800a11 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a27:	0f b6 c1             	movzbl %cl,%eax
  800a2a:	0f b6 db             	movzbl %bl,%ebx
  800a2d:	29 d8                	sub    %ebx,%eax
  800a2f:	eb 05                	jmp    800a36 <memcmp+0x35>
	}

	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	73 09                	jae    800a55 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	38 08                	cmp    %cl,(%eax)
  800a4e:	74 05                	je     800a55 <memfind+0x1b>
	for (; s < ends; s++)
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	eb f3                	jmp    800a48 <memfind+0xe>
			break;
	return (void *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	eb 03                	jmp    800a68 <strtol+0x11>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f6                	je     800a65 <strtol+0xe>
  800a6f:	3c 09                	cmp    $0x9,%al
  800a71:	74 f2                	je     800a65 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	74 2e                	je     800aa5 <strtol+0x4e>
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7c:	3c 2d                	cmp    $0x2d,%al
  800a7e:	74 2f                	je     800aaf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 05                	jne    800a8d <strtol+0x36>
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	74 2c                	je     800ab9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 0a                	jne    800a9b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a91:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	74 28                	je     800ac3 <strtol+0x6c>
		base = 10;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa3:	eb 50                	jmp    800af5 <strtol+0x9e>
		s++;
  800aa5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aad:	eb d1                	jmp    800a80 <strtol+0x29>
		s++, neg = 1;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab7:	eb c7                	jmp    800a80 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abd:	74 0e                	je     800acd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 d8                	jne    800a9b <strtol+0x44>
		s++, base = 8;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acb:	eb ce                	jmp    800a9b <strtol+0x44>
		s += 2, base = 16;
  800acd:	83 c1 02             	add    $0x2,%ecx
  800ad0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad5:	eb c4                	jmp    800a9b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 19             	cmp    $0x19,%bl
  800adf:	77 29                	ja     800b0a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aea:	7d 30                	jge    800b1c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aec:	83 c1 01             	add    $0x1,%ecx
  800aef:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 11             	movzbl (%ecx),%edx
  800af8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	77 d5                	ja     800ad7 <strtol+0x80>
			dig = *s - '0';
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 30             	sub    $0x30,%edx
  800b08:	eb dd                	jmp    800ae7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b14:	0f be d2             	movsbl %dl,%edx
  800b17:	83 ea 37             	sub    $0x37,%edx
  800b1a:	eb cb                	jmp    800ae7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b20:	74 05                	je     800b27 <strtol+0xd0>
		*endptr = (char *) s;
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	f7 da                	neg    %edx
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	0f 45 c2             	cmovne %edx,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	89 c3                	mov    %eax,%ebx
  800b48:	89 c7                	mov    %eax,%edi
  800b4a:	89 c6                	mov    %eax,%esi
  800b4c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	89 cb                	mov    %ecx,%ebx
  800b8a:	89 cf                	mov    %ecx,%edi
  800b8c:	89 ce                	mov    %ecx,%esi
  800b8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7f 08                	jg     800b9c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 03                	push   $0x3
  800ba2:	68 c4 12 80 00       	push   $0x8012c4
  800ba7:	6a 23                	push   $0x23
  800ba9:	68 e1 12 80 00       	push   $0x8012e1
  800bae:	e8 1b 02 00 00       	call   800dce <_panic>

00800bb3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc3:	89 d1                	mov    %edx,%ecx
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_yield>:

void
sys_yield(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	be 00 00 00 00       	mov    $0x0,%esi
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0d:	89 f7                	mov    %esi,%edi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c21:	6a 04                	push   $0x4
  800c23:	68 c4 12 80 00       	push   $0x8012c4
  800c28:	6a 23                	push   $0x23
  800c2a:	68 e1 12 80 00       	push   $0x8012e1
  800c2f:	e8 9a 01 00 00       	call   800dce <_panic>

00800c34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	b8 05 00 00 00       	mov    $0x5,%eax
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7f 08                	jg     800c5f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c63:	6a 05                	push   $0x5
  800c65:	68 c4 12 80 00       	push   $0x8012c4
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 e1 12 80 00       	push   $0x8012e1
  800c71:	e8 58 01 00 00       	call   800dce <_panic>

00800c76 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7f 08                	jg     800ca1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ca5:	6a 06                	push   $0x6
  800ca7:	68 c4 12 80 00       	push   $0x8012c4
  800cac:	6a 23                	push   $0x23
  800cae:	68 e1 12 80 00       	push   $0x8012e1
  800cb3:	e8 16 01 00 00       	call   800dce <_panic>

00800cb8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7f 08                	jg     800ce3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ce7:	6a 08                	push   $0x8
  800ce9:	68 c4 12 80 00       	push   $0x8012c4
  800cee:	6a 23                	push   $0x23
  800cf0:	68 e1 12 80 00       	push   $0x8012e1
  800cf5:	e8 d4 00 00 00       	call   800dce <_panic>

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7f 08                	jg     800d25 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 09                	push   $0x9
  800d2b:	68 c4 12 80 00       	push   $0x8012c4
  800d30:	6a 23                	push   $0x23
  800d32:	68 e1 12 80 00       	push   $0x8012e1
  800d37:	e8 92 00 00 00       	call   800dce <_panic>

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4d:	be 00 00 00 00       	mov    $0x0,%esi
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d58:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7f 08                	jg     800d89 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 0c                	push   $0xc
  800d8f:	68 c4 12 80 00       	push   $0x8012c4
  800d94:	6a 23                	push   $0x23
  800d96:	68 e1 12 80 00       	push   $0x8012e1
  800d9b:	e8 2e 00 00 00       	call   800dce <_panic>

00800da0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800da6:	68 fb 12 80 00       	push   $0x8012fb
  800dab:	6a 51                	push   $0x51
  800dad:	68 ef 12 80 00       	push   $0x8012ef
  800db2:	e8 17 00 00 00       	call   800dce <_panic>

00800db7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dbd:	68 fa 12 80 00       	push   $0x8012fa
  800dc2:	6a 58                	push   $0x58
  800dc4:	68 ef 12 80 00       	push   $0x8012ef
  800dc9:	e8 00 00 00 00       	call   800dce <_panic>

00800dce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dd6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ddc:	e8 d2 fd ff ff       	call   800bb3 <sys_getenvid>
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	ff 75 0c             	pushl  0xc(%ebp)
  800de7:	ff 75 08             	pushl  0x8(%ebp)
  800dea:	56                   	push   %esi
  800deb:	50                   	push   %eax
  800dec:	68 10 13 80 00       	push   $0x801310
  800df1:	e8 e4 f3 ff ff       	call   8001da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df6:	83 c4 18             	add    $0x18,%esp
  800df9:	53                   	push   %ebx
  800dfa:	ff 75 10             	pushl  0x10(%ebp)
  800dfd:	e8 87 f3 ff ff       	call   800189 <vcprintf>
	cprintf("\n");
  800e02:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800e09:	e8 cc f3 ff ff       	call   8001da <cprintf>
  800e0e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e11:	cc                   	int3   
  800e12:	eb fd                	jmp    800e11 <_panic+0x43>
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

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
