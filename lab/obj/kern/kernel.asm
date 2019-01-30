
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 de 22 f0 00 	cmpl   $0x0,0xf022de80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 b5 08 00 00       	call   f0100910 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 de 22 f0    	mov    %esi,0xf022de80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 fb 59 00 00       	call   f0105a6b <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 a0 60 10 f0       	push   $0xf01060a0
f010007c:	e8 50 39 00 00       	call   f01039d1 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 20 39 00 00       	call   f01039ab <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 96 72 10 f0 	movl   $0xf0107296,(%esp)
f0100092:	e8 3a 39 00 00       	call   f01039d1 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 08             	sub    $0x8,%esp
	memset(edata, 0, end - edata);
f01000a3:	b8 08 f0 26 f0       	mov    $0xf026f008,%eax
f01000a8:	2d f0 c2 22 f0       	sub    $0xf022c2f0,%eax
f01000ad:	50                   	push   %eax
f01000ae:	6a 00                	push   $0x0
f01000b0:	68 f0 c2 22 f0       	push   $0xf022c2f0
f01000b5:	e8 8c 53 00 00       	call   f0105446 <memset>
	cons_init();
f01000ba:	e8 9a 05 00 00       	call   f0100659 <cons_init>
	cprintf("\n6828 decimal is %o octal!\n", 6828);
f01000bf:	83 c4 08             	add    $0x8,%esp
f01000c2:	68 ac 1a 00 00       	push   $0x1aac
f01000c7:	68 0c 61 10 f0       	push   $0xf010610c
f01000cc:	e8 00 39 00 00       	call   f01039d1 <cprintf>
	mem_init();
f01000d1:	e8 ae 12 00 00       	call   f0101384 <mem_init>
	env_init();
f01000d6:	e8 ed 30 00 00       	call   f01031c8 <env_init>
	trap_init();
f01000db:	e8 e5 39 00 00       	call   f0103ac5 <trap_init>
	mp_init();
f01000e0:	e8 74 56 00 00       	call   f0105759 <mp_init>
	lapic_init();
f01000e5:	e8 9b 59 00 00       	call   f0105a85 <lapic_init>
	pic_init();
f01000ea:	e8 05 38 00 00       	call   f01038f4 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ef:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000f6:	e8 e0 5b 00 00       	call   f0105cdb <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000fb:	83 c4 10             	add    $0x10,%esp
f01000fe:	83 3d 88 de 22 f0 07 	cmpl   $0x7,0xf022de88
f0100105:	76 27                	jbe    f010012e <i386_init+0x92>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100107:	83 ec 04             	sub    $0x4,%esp
f010010a:	b8 be 56 10 f0       	mov    $0xf01056be,%eax
f010010f:	2d 44 56 10 f0       	sub    $0xf0105644,%eax
f0100114:	50                   	push   %eax
f0100115:	68 44 56 10 f0       	push   $0xf0105644
f010011a:	68 00 70 00 f0       	push   $0xf0007000
f010011f:	e8 6f 53 00 00       	call   f0105493 <memmove>
f0100124:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100127:	bb 20 e0 22 f0       	mov    $0xf022e020,%ebx
f010012c:	eb 19                	jmp    f0100147 <i386_init+0xab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010012e:	68 00 70 00 00       	push   $0x7000
f0100133:	68 c4 60 10 f0       	push   $0xf01060c4
f0100138:	6a 54                	push   $0x54
f010013a:	68 28 61 10 f0       	push   $0xf0106128
f010013f:	e8 fc fe ff ff       	call   f0100040 <_panic>
f0100144:	83 c3 74             	add    $0x74,%ebx
f0100147:	6b 05 c4 e3 22 f0 74 	imul   $0x74,0xf022e3c4,%eax
f010014e:	05 20 e0 22 f0       	add    $0xf022e020,%eax
f0100153:	39 c3                	cmp    %eax,%ebx
f0100155:	73 4c                	jae    f01001a3 <i386_init+0x107>
		if (c == cpus + cpunum())  // We've started already.
f0100157:	e8 0f 59 00 00       	call   f0105a6b <cpunum>
f010015c:	6b c0 74             	imul   $0x74,%eax,%eax
f010015f:	05 20 e0 22 f0       	add    $0xf022e020,%eax
f0100164:	39 c3                	cmp    %eax,%ebx
f0100166:	74 dc                	je     f0100144 <i386_init+0xa8>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100168:	89 d8                	mov    %ebx,%eax
f010016a:	2d 20 e0 22 f0       	sub    $0xf022e020,%eax
f010016f:	c1 f8 02             	sar    $0x2,%eax
f0100172:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100178:	c1 e0 0f             	shl    $0xf,%eax
f010017b:	05 00 70 23 f0       	add    $0xf0237000,%eax
f0100180:	a3 84 de 22 f0       	mov    %eax,0xf022de84
		lapic_startap(c->cpu_id, PADDR(code));
f0100185:	83 ec 08             	sub    $0x8,%esp
f0100188:	68 00 70 00 00       	push   $0x7000
f010018d:	0f b6 03             	movzbl (%ebx),%eax
f0100190:	50                   	push   %eax
f0100191:	e8 40 5a 00 00       	call   f0105bd6 <lapic_startap>
f0100196:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100199:	8b 43 04             	mov    0x4(%ebx),%eax
f010019c:	83 f8 01             	cmp    $0x1,%eax
f010019f:	75 f8                	jne    f0100199 <i386_init+0xfd>
f01001a1:	eb a1                	jmp    f0100144 <i386_init+0xa8>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a3:	83 ec 08             	sub    $0x8,%esp
f01001a6:	6a 00                	push   $0x0
f01001a8:	68 08 db 1c f0       	push   $0xf01cdb08
f01001ad:	e8 ff 31 00 00       	call   f01033b1 <env_create>
	sched_yield();
f01001b2:	e8 02 43 00 00       	call   f01044b9 <sched_yield>

f01001b7 <mp_main>:
{
f01001b7:	55                   	push   %ebp
f01001b8:	89 e5                	mov    %esp,%ebp
f01001ba:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001bd:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c7:	77 12                	ja     f01001db <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c9:	50                   	push   %eax
f01001ca:	68 e8 60 10 f0       	push   $0xf01060e8
f01001cf:	6a 6b                	push   $0x6b
f01001d1:	68 28 61 10 f0       	push   $0xf0106128
f01001d6:	e8 65 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001db:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001e0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e3:	e8 83 58 00 00       	call   f0105a6b <cpunum>
f01001e8:	83 ec 08             	sub    $0x8,%esp
f01001eb:	50                   	push   %eax
f01001ec:	68 34 61 10 f0       	push   $0xf0106134
f01001f1:	e8 db 37 00 00       	call   f01039d1 <cprintf>
	lapic_init();
f01001f6:	e8 8a 58 00 00       	call   f0105a85 <lapic_init>
	env_init_percpu();
f01001fb:	e8 98 2f 00 00       	call   f0103198 <env_init_percpu>
	trap_init_percpu();
f0100200:	e8 e0 37 00 00       	call   f01039e5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100205:	e8 61 58 00 00       	call   f0105a6b <cpunum>
f010020a:	6b d0 74             	imul   $0x74,%eax,%edx
f010020d:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100210:	b8 01 00 00 00       	mov    $0x1,%eax
f0100215:	f0 87 82 20 e0 22 f0 	lock xchg %eax,-0xfdd1fe0(%edx)
f010021c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100223:	e8 b3 5a 00 00       	call   f0105cdb <spin_lock>
	sched_yield();
f0100228:	e8 8c 42 00 00       	call   f01044b9 <sched_yield>

f010022d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022d:	55                   	push   %ebp
f010022e:	89 e5                	mov    %esp,%ebp
f0100230:	53                   	push   %ebx
f0100231:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100234:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100237:	ff 75 0c             	pushl  0xc(%ebp)
f010023a:	ff 75 08             	pushl  0x8(%ebp)
f010023d:	68 4a 61 10 f0       	push   $0xf010614a
f0100242:	e8 8a 37 00 00       	call   f01039d1 <cprintf>
	vcprintf(fmt, ap);
f0100247:	83 c4 08             	add    $0x8,%esp
f010024a:	53                   	push   %ebx
f010024b:	ff 75 10             	pushl  0x10(%ebp)
f010024e:	e8 58 37 00 00       	call   f01039ab <vcprintf>
	cprintf("\n");
f0100253:	c7 04 24 96 72 10 f0 	movl   $0xf0107296,(%esp)
f010025a:	e8 72 37 00 00       	call   f01039d1 <cprintf>
	va_end(ap);
}
f010025f:	83 c4 10             	add    $0x10,%esp
f0100262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100265:	c9                   	leave  
f0100266:	c3                   	ret    

f0100267 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100267:	55                   	push   %ebp
f0100268:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010026a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100270:	a8 01                	test   $0x1,%al
f0100272:	74 0b                	je     f010027f <serial_proc_data+0x18>
f0100274:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100279:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010027a:	0f b6 c0             	movzbl %al,%eax
}
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    
		return -1;
f010027f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100284:	eb f7                	jmp    f010027d <serial_proc_data+0x16>

f0100286 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100286:	55                   	push   %ebp
f0100287:	89 e5                	mov    %esp,%ebp
f0100289:	53                   	push   %ebx
f010028a:	83 ec 04             	sub    $0x4,%esp
f010028d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028f:	ff d3                	call   *%ebx
f0100291:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100294:	74 2d                	je     f01002c3 <cons_intr+0x3d>
		if (c == 0)
f0100296:	85 c0                	test   %eax,%eax
f0100298:	74 f5                	je     f010028f <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010029a:	8b 0d 24 d2 22 f0    	mov    0xf022d224,%ecx
f01002a0:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a3:	89 15 24 d2 22 f0    	mov    %edx,0xf022d224
f01002a9:	88 81 20 d0 22 f0    	mov    %al,-0xfdd2fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002af:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b5:	75 d8                	jne    f010028f <cons_intr+0x9>
			cons.wpos = 0;
f01002b7:	c7 05 24 d2 22 f0 00 	movl   $0x0,0xf022d224
f01002be:	00 00 00 
f01002c1:	eb cc                	jmp    f010028f <cons_intr+0x9>
	}
}
f01002c3:	83 c4 04             	add    $0x4,%esp
f01002c6:	5b                   	pop    %ebx
f01002c7:	5d                   	pop    %ebp
f01002c8:	c3                   	ret    

f01002c9 <kbd_proc_data>:
{
f01002c9:	55                   	push   %ebp
f01002ca:	89 e5                	mov    %esp,%ebp
f01002cc:	53                   	push   %ebx
f01002cd:	83 ec 04             	sub    $0x4,%esp
f01002d0:	ba 64 00 00 00       	mov    $0x64,%edx
f01002d5:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002d6:	a8 01                	test   $0x1,%al
f01002d8:	0f 84 fa 00 00 00    	je     f01003d8 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002de:	a8 20                	test   $0x20,%al
f01002e0:	0f 85 f9 00 00 00    	jne    f01003df <kbd_proc_data+0x116>
f01002e6:	ba 60 00 00 00       	mov    $0x60,%edx
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002ee:	3c e0                	cmp    $0xe0,%al
f01002f0:	0f 84 8e 00 00 00    	je     f0100384 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002f6:	84 c0                	test   %al,%al
f01002f8:	0f 88 99 00 00 00    	js     f0100397 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002fe:	8b 0d 00 d0 22 f0    	mov    0xf022d000,%ecx
f0100304:	f6 c1 40             	test   $0x40,%cl
f0100307:	74 0e                	je     f0100317 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100309:	83 c8 80             	or     $0xffffff80,%eax
f010030c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010030e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100311:	89 0d 00 d0 22 f0    	mov    %ecx,0xf022d000
	shift |= shiftcode[data];
f0100317:	0f b6 d2             	movzbl %dl,%edx
f010031a:	0f b6 82 c0 62 10 f0 	movzbl -0xfef9d40(%edx),%eax
f0100321:	0b 05 00 d0 22 f0    	or     0xf022d000,%eax
	shift ^= togglecode[data];
f0100327:	0f b6 8a c0 61 10 f0 	movzbl -0xfef9e40(%edx),%ecx
f010032e:	31 c8                	xor    %ecx,%eax
f0100330:	a3 00 d0 22 f0       	mov    %eax,0xf022d000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100335:	89 c1                	mov    %eax,%ecx
f0100337:	83 e1 03             	and    $0x3,%ecx
f010033a:	8b 0c 8d a0 61 10 f0 	mov    -0xfef9e60(,%ecx,4),%ecx
f0100341:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100345:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100348:	a8 08                	test   $0x8,%al
f010034a:	74 0d                	je     f0100359 <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f010034c:	89 da                	mov    %ebx,%edx
f010034e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100351:	83 f9 19             	cmp    $0x19,%ecx
f0100354:	77 74                	ja     f01003ca <kbd_proc_data+0x101>
			c += 'A' - 'a';
f0100356:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100359:	f7 d0                	not    %eax
f010035b:	a8 06                	test   $0x6,%al
f010035d:	75 31                	jne    f0100390 <kbd_proc_data+0xc7>
f010035f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100365:	75 29                	jne    f0100390 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100367:	83 ec 0c             	sub    $0xc,%esp
f010036a:	68 64 61 10 f0       	push   $0xf0106164
f010036f:	e8 5d 36 00 00       	call   f01039d1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100374:	b8 03 00 00 00       	mov    $0x3,%eax
f0100379:	ba 92 00 00 00       	mov    $0x92,%edx
f010037e:	ee                   	out    %al,(%dx)
f010037f:	83 c4 10             	add    $0x10,%esp
f0100382:	eb 0c                	jmp    f0100390 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100384:	83 0d 00 d0 22 f0 40 	orl    $0x40,0xf022d000
		return 0;
f010038b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100390:	89 d8                	mov    %ebx,%eax
f0100392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100395:	c9                   	leave  
f0100396:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100397:	8b 0d 00 d0 22 f0    	mov    0xf022d000,%ecx
f010039d:	89 cb                	mov    %ecx,%ebx
f010039f:	83 e3 40             	and    $0x40,%ebx
f01003a2:	83 e0 7f             	and    $0x7f,%eax
f01003a5:	85 db                	test   %ebx,%ebx
f01003a7:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003aa:	0f b6 d2             	movzbl %dl,%edx
f01003ad:	0f b6 82 c0 62 10 f0 	movzbl -0xfef9d40(%edx),%eax
f01003b4:	83 c8 40             	or     $0x40,%eax
f01003b7:	0f b6 c0             	movzbl %al,%eax
f01003ba:	f7 d0                	not    %eax
f01003bc:	21 c8                	and    %ecx,%eax
f01003be:	a3 00 d0 22 f0       	mov    %eax,0xf022d000
		return 0;
f01003c3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c8:	eb c6                	jmp    f0100390 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003ca:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003cd:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003d0:	83 fa 1a             	cmp    $0x1a,%edx
f01003d3:	0f 42 d9             	cmovb  %ecx,%ebx
f01003d6:	eb 81                	jmp    f0100359 <kbd_proc_data+0x90>
		return -1;
f01003d8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003dd:	eb b1                	jmp    f0100390 <kbd_proc_data+0xc7>
		return -1;
f01003df:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e4:	eb aa                	jmp    f0100390 <kbd_proc_data+0xc7>

f01003e6 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e6:	55                   	push   %ebp
f01003e7:	89 e5                	mov    %esp,%ebp
f01003e9:	57                   	push   %edi
f01003ea:	56                   	push   %esi
f01003eb:	53                   	push   %ebx
f01003ec:	83 ec 1c             	sub    $0x1c,%esp
f01003ef:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f6:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003fb:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100400:	eb 09                	jmp    f010040b <cons_putc+0x25>
f0100402:	89 ca                	mov    %ecx,%edx
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
f0100406:	ec                   	in     (%dx),%al
f0100407:	ec                   	in     (%dx),%al
	     i++)
f0100408:	83 c3 01             	add    $0x1,%ebx
f010040b:	89 f2                	mov    %esi,%edx
f010040d:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040e:	a8 20                	test   $0x20,%al
f0100410:	75 08                	jne    f010041a <cons_putc+0x34>
f0100412:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100418:	7e e8                	jle    f0100402 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010041a:	89 f8                	mov    %edi,%eax
f010041c:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100424:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100425:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042a:	be 79 03 00 00       	mov    $0x379,%esi
f010042f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100434:	eb 09                	jmp    f010043f <cons_putc+0x59>
f0100436:	89 ca                	mov    %ecx,%edx
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	ec                   	in     (%dx),%al
f010043c:	83 c3 01             	add    $0x1,%ebx
f010043f:	89 f2                	mov    %esi,%edx
f0100441:	ec                   	in     (%dx),%al
f0100442:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100448:	7f 04                	jg     f010044e <cons_putc+0x68>
f010044a:	84 c0                	test   %al,%al
f010044c:	79 e8                	jns    f0100436 <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100453:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100457:	ee                   	out    %al,(%dx)
f0100458:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100462:	ee                   	out    %al,(%dx)
f0100463:	b8 08 00 00 00       	mov    $0x8,%eax
f0100468:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100469:	89 fa                	mov    %edi,%edx
f010046b:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100471:	89 f8                	mov    %edi,%eax
f0100473:	80 cc 07             	or     $0x7,%ah
f0100476:	85 d2                	test   %edx,%edx
f0100478:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010047b:	89 f8                	mov    %edi,%eax
f010047d:	0f b6 c0             	movzbl %al,%eax
f0100480:	83 f8 09             	cmp    $0x9,%eax
f0100483:	0f 84 b6 00 00 00    	je     f010053f <cons_putc+0x159>
f0100489:	83 f8 09             	cmp    $0x9,%eax
f010048c:	7e 73                	jle    f0100501 <cons_putc+0x11b>
f010048e:	83 f8 0a             	cmp    $0xa,%eax
f0100491:	0f 84 9b 00 00 00    	je     f0100532 <cons_putc+0x14c>
f0100497:	83 f8 0d             	cmp    $0xd,%eax
f010049a:	0f 85 d6 00 00 00    	jne    f0100576 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f01004a0:	0f b7 05 28 d2 22 f0 	movzwl 0xf022d228,%eax
f01004a7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ad:	c1 e8 16             	shr    $0x16,%eax
f01004b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b3:	c1 e0 04             	shl    $0x4,%eax
f01004b6:	66 a3 28 d2 22 f0    	mov    %ax,0xf022d228
	if (crt_pos >= CRT_SIZE) {
f01004bc:	66 81 3d 28 d2 22 f0 	cmpw   $0x7cf,0xf022d228
f01004c3:	cf 07 
f01004c5:	0f 87 ce 00 00 00    	ja     f0100599 <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004cb:	8b 0d 30 d2 22 f0    	mov    0xf022d230,%ecx
f01004d1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d6:	89 ca                	mov    %ecx,%edx
f01004d8:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d9:	0f b7 1d 28 d2 22 f0 	movzwl 0xf022d228,%ebx
f01004e0:	8d 71 01             	lea    0x1(%ecx),%esi
f01004e3:	89 d8                	mov    %ebx,%eax
f01004e5:	66 c1 e8 08          	shr    $0x8,%ax
f01004e9:	89 f2                	mov    %esi,%edx
f01004eb:	ee                   	out    %al,(%dx)
f01004ec:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004f1:	89 ca                	mov    %ecx,%edx
f01004f3:	ee                   	out    %al,(%dx)
f01004f4:	89 d8                	mov    %ebx,%eax
f01004f6:	89 f2                	mov    %esi,%edx
f01004f8:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004fc:	5b                   	pop    %ebx
f01004fd:	5e                   	pop    %esi
f01004fe:	5f                   	pop    %edi
f01004ff:	5d                   	pop    %ebp
f0100500:	c3                   	ret    
	switch (c & 0xff) {
f0100501:	83 f8 08             	cmp    $0x8,%eax
f0100504:	75 70                	jne    f0100576 <cons_putc+0x190>
		if (crt_pos > 0) {
f0100506:	0f b7 05 28 d2 22 f0 	movzwl 0xf022d228,%eax
f010050d:	66 85 c0             	test   %ax,%ax
f0100510:	74 b9                	je     f01004cb <cons_putc+0xe5>
			crt_pos--;
f0100512:	83 e8 01             	sub    $0x1,%eax
f0100515:	66 a3 28 d2 22 f0    	mov    %ax,0xf022d228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100523:	83 cf 20             	or     $0x20,%edi
f0100526:	8b 15 2c d2 22 f0    	mov    0xf022d22c,%edx
f010052c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100530:	eb 8a                	jmp    f01004bc <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f0100532:	66 83 05 28 d2 22 f0 	addw   $0x50,0xf022d228
f0100539:	50 
f010053a:	e9 61 ff ff ff       	jmp    f01004a0 <cons_putc+0xba>
		cons_putc(' ');
f010053f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100544:	e8 9d fe ff ff       	call   f01003e6 <cons_putc>
		cons_putc(' ');
f0100549:	b8 20 00 00 00       	mov    $0x20,%eax
f010054e:	e8 93 fe ff ff       	call   f01003e6 <cons_putc>
		cons_putc(' ');
f0100553:	b8 20 00 00 00       	mov    $0x20,%eax
f0100558:	e8 89 fe ff ff       	call   f01003e6 <cons_putc>
		cons_putc(' ');
f010055d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100562:	e8 7f fe ff ff       	call   f01003e6 <cons_putc>
		cons_putc(' ');
f0100567:	b8 20 00 00 00       	mov    $0x20,%eax
f010056c:	e8 75 fe ff ff       	call   f01003e6 <cons_putc>
f0100571:	e9 46 ff ff ff       	jmp    f01004bc <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100576:	0f b7 05 28 d2 22 f0 	movzwl 0xf022d228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 d2 22 f0 	mov    %dx,0xf022d228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c d2 22 f0    	mov    0xf022d22c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100594:	e9 23 ff ff ff       	jmp    f01004bc <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100599:	a1 2c d2 22 f0       	mov    0xf022d22c,%eax
f010059e:	83 ec 04             	sub    $0x4,%esp
f01005a1:	68 00 0f 00 00       	push   $0xf00
f01005a6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005ac:	52                   	push   %edx
f01005ad:	50                   	push   %eax
f01005ae:	e8 e0 4e 00 00       	call   f0105493 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005b3:	8b 15 2c d2 22 f0    	mov    0xf022d22c,%edx
f01005b9:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bf:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c5:	83 c4 10             	add    $0x10,%esp
f01005c8:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005cd:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d0:	39 d0                	cmp    %edx,%eax
f01005d2:	75 f4                	jne    f01005c8 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005d4:	66 83 2d 28 d2 22 f0 	subw   $0x50,0xf022d228
f01005db:	50 
f01005dc:	e9 ea fe ff ff       	jmp    f01004cb <cons_putc+0xe5>

f01005e1 <serial_intr>:
	if (serial_exists)
f01005e1:	80 3d 34 d2 22 f0 00 	cmpb   $0x0,0xf022d234
f01005e8:	75 02                	jne    f01005ec <serial_intr+0xb>
f01005ea:	f3 c3                	repz ret 
{
f01005ec:	55                   	push   %ebp
f01005ed:	89 e5                	mov    %esp,%ebp
f01005ef:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005f2:	b8 67 02 10 f0       	mov    $0xf0100267,%eax
f01005f7:	e8 8a fc ff ff       	call   f0100286 <cons_intr>
}
f01005fc:	c9                   	leave  
f01005fd:	c3                   	ret    

f01005fe <kbd_intr>:
{
f01005fe:	55                   	push   %ebp
f01005ff:	89 e5                	mov    %esp,%ebp
f0100601:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100604:	b8 c9 02 10 f0       	mov    $0xf01002c9,%eax
f0100609:	e8 78 fc ff ff       	call   f0100286 <cons_intr>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <cons_getc>:
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100616:	e8 c6 ff ff ff       	call   f01005e1 <serial_intr>
	kbd_intr();
f010061b:	e8 de ff ff ff       	call   f01005fe <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100620:	8b 15 20 d2 22 f0    	mov    0xf022d220,%edx
	return 0;
f0100626:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010062b:	3b 15 24 d2 22 f0    	cmp    0xf022d224,%edx
f0100631:	74 18                	je     f010064b <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100633:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100636:	89 0d 20 d2 22 f0    	mov    %ecx,0xf022d220
f010063c:	0f b6 82 20 d0 22 f0 	movzbl -0xfdd2fe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100643:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100649:	74 02                	je     f010064d <cons_getc+0x3d>
}
f010064b:	c9                   	leave  
f010064c:	c3                   	ret    
			cons.rpos = 0;
f010064d:	c7 05 20 d2 22 f0 00 	movl   $0x0,0xf022d220
f0100654:	00 00 00 
f0100657:	eb f2                	jmp    f010064b <cons_getc+0x3b>

f0100659 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100659:	55                   	push   %ebp
f010065a:	89 e5                	mov    %esp,%ebp
f010065c:	57                   	push   %edi
f010065d:	56                   	push   %esi
f010065e:	53                   	push   %ebx
f010065f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100662:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100669:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100670:	5a a5 
	if (*cp != 0xA55A) {
f0100672:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100679:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010067d:	0f 84 d4 00 00 00    	je     f0100757 <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f0100683:	c7 05 30 d2 22 f0 b4 	movl   $0x3b4,0xf022d230
f010068a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100692:	8b 3d 30 d2 22 f0    	mov    0xf022d230,%edi
f0100698:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a0:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a3:	89 ca                	mov    %ecx,%edx
f01006a5:	ec                   	in     (%dx),%al
f01006a6:	0f b6 c0             	movzbl %al,%eax
f01006a9:	c1 e0 08             	shl    $0x8,%eax
f01006ac:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ae:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b3:	89 fa                	mov    %edi,%edx
f01006b5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b6:	89 ca                	mov    %ecx,%edx
f01006b8:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b9:	89 35 2c d2 22 f0    	mov    %esi,0xf022d22c
	pos |= inb(addr_6845 + 1);
f01006bf:	0f b6 c0             	movzbl %al,%eax
f01006c2:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c4:	66 a3 28 d2 22 f0    	mov    %ax,0xf022d228
	kbd_intr();
f01006ca:	e8 2f ff ff ff       	call   f01005fe <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006cf:	83 ec 0c             	sub    $0xc,%esp
f01006d2:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006d9:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006de:	50                   	push   %eax
f01006df:	e8 92 31 00 00       	call   f0103876 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e9:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006ee:	89 d8                	mov    %ebx,%eax
f01006f0:	89 ca                	mov    %ecx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006f8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006fd:	89 fa                	mov    %edi,%edx
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100705:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070a:	ee                   	out    %al,(%dx)
f010070b:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100710:	89 d8                	mov    %ebx,%eax
f0100712:	89 f2                	mov    %esi,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b8 03 00 00 00       	mov    $0x3,%eax
f010071a:	89 fa                	mov    %edi,%edx
f010071c:	ee                   	out    %al,(%dx)
f010071d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100722:	89 d8                	mov    %ebx,%eax
f0100724:	ee                   	out    %al,(%dx)
f0100725:	b8 01 00 00 00       	mov    $0x1,%eax
f010072a:	89 f2                	mov    %esi,%edx
f010072c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100732:	ec                   	in     (%dx),%al
f0100733:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100735:	83 c4 10             	add    $0x10,%esp
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 05 34 d2 22 f0 	setne  0xf022d234
f0100741:	89 ca                	mov    %ecx,%edx
f0100743:	ec                   	in     (%dx),%al
f0100744:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100749:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010074a:	80 fb ff             	cmp    $0xff,%bl
f010074d:	74 23                	je     f0100772 <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f010074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100752:	5b                   	pop    %ebx
f0100753:	5e                   	pop    %esi
f0100754:	5f                   	pop    %edi
f0100755:	5d                   	pop    %ebp
f0100756:	c3                   	ret    
		*cp = was;
f0100757:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010075e:	c7 05 30 d2 22 f0 d4 	movl   $0x3d4,0xf022d230
f0100765:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100768:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010076d:	e9 20 ff ff ff       	jmp    f0100692 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100772:	83 ec 0c             	sub    $0xc,%esp
f0100775:	68 70 61 10 f0       	push   $0xf0106170
f010077a:	e8 52 32 00 00       	call   f01039d1 <cprintf>
f010077f:	83 c4 10             	add    $0x10,%esp
}
f0100782:	eb cb                	jmp    f010074f <cons_init+0xf6>

f0100784 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100784:	55                   	push   %ebp
f0100785:	89 e5                	mov    %esp,%ebp
f0100787:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010078a:	8b 45 08             	mov    0x8(%ebp),%eax
f010078d:	e8 54 fc ff ff       	call   f01003e6 <cons_putc>
}
f0100792:	c9                   	leave  
f0100793:	c3                   	ret    

f0100794 <getchar>:

int
getchar(void)
{
f0100794:	55                   	push   %ebp
f0100795:	89 e5                	mov    %esp,%ebp
f0100797:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010079a:	e8 71 fe ff ff       	call   f0100610 <cons_getc>
f010079f:	85 c0                	test   %eax,%eax
f01007a1:	74 f7                	je     f010079a <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a3:	c9                   	leave  
f01007a4:	c3                   	ret    

f01007a5 <iscons>:

int
iscons(int fdnum)
{
f01007a5:	55                   	push   %ebp
f01007a6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ad:	5d                   	pop    %ebp
f01007ae:	c3                   	ret    

f01007af <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b5:	68 c0 63 10 f0       	push   $0xf01063c0
f01007ba:	68 de 63 10 f0       	push   $0xf01063de
f01007bf:	68 e3 63 10 f0       	push   $0xf01063e3
f01007c4:	e8 08 32 00 00       	call   f01039d1 <cprintf>
f01007c9:	83 c4 0c             	add    $0xc,%esp
f01007cc:	68 70 64 10 f0       	push   $0xf0106470
f01007d1:	68 ec 63 10 f0       	push   $0xf01063ec
f01007d6:	68 e3 63 10 f0       	push   $0xf01063e3
f01007db:	e8 f1 31 00 00       	call   f01039d1 <cprintf>
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	68 98 64 10 f0       	push   $0xf0106498
f01007e8:	68 f5 63 10 f0       	push   $0xf01063f5
f01007ed:	68 e3 63 10 f0       	push   $0xf01063e3
f01007f2:	e8 da 31 00 00       	call   f01039d1 <cprintf>
	return 0;
}
f01007f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fc:	c9                   	leave  
f01007fd:	c3                   	ret    

f01007fe <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fe:	55                   	push   %ebp
f01007ff:	89 e5                	mov    %esp,%ebp
f0100801:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100804:	68 00 64 10 f0       	push   $0xf0106400
f0100809:	e8 c3 31 00 00       	call   f01039d1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080e:	83 c4 08             	add    $0x8,%esp
f0100811:	68 0c 00 10 00       	push   $0x10000c
f0100816:	68 c4 64 10 f0       	push   $0xf01064c4
f010081b:	e8 b1 31 00 00       	call   f01039d1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 0c 00 10 00       	push   $0x10000c
f0100828:	68 0c 00 10 f0       	push   $0xf010000c
f010082d:	68 ec 64 10 f0       	push   $0xf01064ec
f0100832:	e8 9a 31 00 00       	call   f01039d1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 99 60 10 00       	push   $0x106099
f010083f:	68 99 60 10 f0       	push   $0xf0106099
f0100844:	68 10 65 10 f0       	push   $0xf0106510
f0100849:	e8 83 31 00 00       	call   f01039d1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 f0 c2 22 00       	push   $0x22c2f0
f0100856:	68 f0 c2 22 f0       	push   $0xf022c2f0
f010085b:	68 34 65 10 f0       	push   $0xf0106534
f0100860:	e8 6c 31 00 00       	call   f01039d1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 08 f0 26 00       	push   $0x26f008
f010086d:	68 08 f0 26 f0       	push   $0xf026f008
f0100872:	68 58 65 10 f0       	push   $0xf0106558
f0100877:	e8 55 31 00 00       	call   f01039d1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010087f:	b8 07 f4 26 f0       	mov    $0xf026f407,%eax
f0100884:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	c1 f8 0a             	sar    $0xa,%eax
f010088c:	50                   	push   %eax
f010088d:	68 7c 65 10 f0       	push   $0xf010657c
f0100892:	e8 3a 31 00 00       	call   f01039d1 <cprintf>
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	55                   	push   %ebp
f010089f:	89 e5                	mov    %esp,%ebp
f01008a1:	57                   	push   %edi
f01008a2:	56                   	push   %esi
f01008a3:	53                   	push   %ebx
f01008a4:	83 ec 18             	sub    $0x18,%esp
	// Your code here.
	cprintf("Stack backtrace:\n");
f01008a7:	68 19 64 10 f0       	push   $0xf0106419
f01008ac:	e8 20 31 00 00       	call   f01039d1 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b1:	89 ee                	mov    %ebp,%esi
	uint32_t *current_ebp = (uint32_t*)read_ebp();
	while (current_ebp) {
f01008b3:	83 c4 10             	add    $0x10,%esp
f01008b6:	eb 47                	jmp    f01008ff <mon_backtrace+0x61>
		uint32_t *prev_ebp = (uint32_t*)current_ebp[0];
f01008b8:	8b 3e                	mov    (%esi),%edi
		uint32_t ret_addr = current_ebp[1];
		cprintf("  ebp  %08x  eip  %08x  args  ", current_ebp, ret_addr);
f01008ba:	83 ec 04             	sub    $0x4,%esp
f01008bd:	ff 76 04             	pushl  0x4(%esi)
f01008c0:	56                   	push   %esi
f01008c1:	68 a8 65 10 f0       	push   $0xf01065a8
f01008c6:	e8 06 31 00 00       	call   f01039d1 <cprintf>
f01008cb:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008ce:	83 c6 1c             	add    $0x1c,%esi
f01008d1:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 5; ++i) {
			cprintf("%08x  ", current_ebp[2 + i]);
f01008d4:	83 ec 08             	sub    $0x8,%esp
f01008d7:	ff 33                	pushl  (%ebx)
f01008d9:	68 2b 64 10 f0       	push   $0xf010642b
f01008de:	e8 ee 30 00 00       	call   f01039d1 <cprintf>
f01008e3:	83 c3 04             	add    $0x4,%ebx
		for (int i = 0; i < 5; ++i) {
f01008e6:	83 c4 10             	add    $0x10,%esp
f01008e9:	39 f3                	cmp    %esi,%ebx
f01008eb:	75 e7                	jne    f01008d4 <mon_backtrace+0x36>
		}
		cprintf("\n");
f01008ed:	83 ec 0c             	sub    $0xc,%esp
f01008f0:	68 96 72 10 f0       	push   $0xf0107296
f01008f5:	e8 d7 30 00 00       	call   f01039d1 <cprintf>
		current_ebp = prev_ebp;
f01008fa:	83 c4 10             	add    $0x10,%esp
f01008fd:	89 fe                	mov    %edi,%esi
	while (current_ebp) {
f01008ff:	85 f6                	test   %esi,%esi
f0100901:	75 b5                	jne    f01008b8 <mon_backtrace+0x1a>
		//cprintf("  ebp  %08x")
	}
	return 0;
}
f0100903:	b8 00 00 00 00       	mov    $0x0,%eax
f0100908:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090b:	5b                   	pop    %ebx
f010090c:	5e                   	pop    %esi
f010090d:	5f                   	pop    %edi
f010090e:	5d                   	pop    %ebp
f010090f:	c3                   	ret    

f0100910 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100910:	55                   	push   %ebp
f0100911:	89 e5                	mov    %esp,%ebp
f0100913:	57                   	push   %edi
f0100914:	56                   	push   %esi
f0100915:	53                   	push   %ebx
f0100916:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100919:	68 c8 65 10 f0       	push   $0xf01065c8
f010091e:	e8 ae 30 00 00       	call   f01039d1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100923:	c7 04 24 ec 65 10 f0 	movl   $0xf01065ec,(%esp)
f010092a:	e8 a2 30 00 00       	call   f01039d1 <cprintf>

	if (tf != NULL)
f010092f:	83 c4 10             	add    $0x10,%esp
f0100932:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100936:	74 57                	je     f010098f <monitor+0x7f>
		print_trapframe(tf);
f0100938:	83 ec 0c             	sub    $0xc,%esp
f010093b:	ff 75 08             	pushl  0x8(%ebp)
f010093e:	e8 cd 34 00 00       	call   f0103e10 <print_trapframe>
f0100943:	83 c4 10             	add    $0x10,%esp
f0100946:	eb 47                	jmp    f010098f <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100948:	83 ec 08             	sub    $0x8,%esp
f010094b:	0f be c0             	movsbl %al,%eax
f010094e:	50                   	push   %eax
f010094f:	68 36 64 10 f0       	push   $0xf0106436
f0100954:	e8 b0 4a 00 00       	call   f0105409 <strchr>
f0100959:	83 c4 10             	add    $0x10,%esp
f010095c:	85 c0                	test   %eax,%eax
f010095e:	74 0a                	je     f010096a <monitor+0x5a>
			*buf++ = 0;
f0100960:	c6 03 00             	movb   $0x0,(%ebx)
f0100963:	89 f7                	mov    %esi,%edi
f0100965:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100968:	eb 6b                	jmp    f01009d5 <monitor+0xc5>
		if (*buf == 0)
f010096a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010096d:	74 73                	je     f01009e2 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f010096f:	83 fe 0f             	cmp    $0xf,%esi
f0100972:	74 09                	je     f010097d <monitor+0x6d>
		argv[argc++] = buf;
f0100974:	8d 7e 01             	lea    0x1(%esi),%edi
f0100977:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010097b:	eb 39                	jmp    f01009b6 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010097d:	83 ec 08             	sub    $0x8,%esp
f0100980:	6a 10                	push   $0x10
f0100982:	68 3b 64 10 f0       	push   $0xf010643b
f0100987:	e8 45 30 00 00       	call   f01039d1 <cprintf>
f010098c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098f:	83 ec 0c             	sub    $0xc,%esp
f0100992:	68 32 64 10 f0       	push   $0xf0106432
f0100997:	e8 50 48 00 00       	call   f01051ec <readline>
f010099c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010099e:	83 c4 10             	add    $0x10,%esp
f01009a1:	85 c0                	test   %eax,%eax
f01009a3:	74 ea                	je     f010098f <monitor+0x7f>
	argv[argc] = 0;
f01009a5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009ac:	be 00 00 00 00       	mov    $0x0,%esi
f01009b1:	eb 24                	jmp    f01009d7 <monitor+0xc7>
			buf++;
f01009b3:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b6:	0f b6 03             	movzbl (%ebx),%eax
f01009b9:	84 c0                	test   %al,%al
f01009bb:	74 18                	je     f01009d5 <monitor+0xc5>
f01009bd:	83 ec 08             	sub    $0x8,%esp
f01009c0:	0f be c0             	movsbl %al,%eax
f01009c3:	50                   	push   %eax
f01009c4:	68 36 64 10 f0       	push   $0xf0106436
f01009c9:	e8 3b 4a 00 00       	call   f0105409 <strchr>
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	85 c0                	test   %eax,%eax
f01009d3:	74 de                	je     f01009b3 <monitor+0xa3>
			*buf++ = 0;
f01009d5:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009d7:	0f b6 03             	movzbl (%ebx),%eax
f01009da:	84 c0                	test   %al,%al
f01009dc:	0f 85 66 ff ff ff    	jne    f0100948 <monitor+0x38>
	argv[argc] = 0;
f01009e2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009e9:	00 
	if (argc == 0)
f01009ea:	85 f6                	test   %esi,%esi
f01009ec:	74 a1                	je     f010098f <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f3:	83 ec 08             	sub    $0x8,%esp
f01009f6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009f9:	ff 34 85 20 66 10 f0 	pushl  -0xfef99e0(,%eax,4)
f0100a00:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a03:	e8 a3 49 00 00       	call   f01053ab <strcmp>
f0100a08:	83 c4 10             	add    $0x10,%esp
f0100a0b:	85 c0                	test   %eax,%eax
f0100a0d:	74 20                	je     f0100a2f <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a0f:	83 c3 01             	add    $0x1,%ebx
f0100a12:	83 fb 03             	cmp    $0x3,%ebx
f0100a15:	75 dc                	jne    f01009f3 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a17:	83 ec 08             	sub    $0x8,%esp
f0100a1a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a1d:	68 58 64 10 f0       	push   $0xf0106458
f0100a22:	e8 aa 2f 00 00       	call   f01039d1 <cprintf>
f0100a27:	83 c4 10             	add    $0x10,%esp
f0100a2a:	e9 60 ff ff ff       	jmp    f010098f <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100a2f:	83 ec 04             	sub    $0x4,%esp
f0100a32:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a35:	ff 75 08             	pushl  0x8(%ebp)
f0100a38:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a3b:	52                   	push   %edx
f0100a3c:	56                   	push   %esi
f0100a3d:	ff 14 85 28 66 10 f0 	call   *-0xfef99d8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a44:	83 c4 10             	add    $0x10,%esp
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	0f 89 40 ff ff ff    	jns    f010098f <monitor+0x7f>
				break;
	}
}
f0100a4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a52:	5b                   	pop    %ebx
f0100a53:	5e                   	pop    %esi
f0100a54:	5f                   	pop    %edi
f0100a55:	5d                   	pop    %ebp
f0100a56:	c3                   	ret    

f0100a57 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a57:	55                   	push   %ebp
f0100a58:	89 e5                	mov    %esp,%ebp
f0100a5a:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a5c:	83 3d 38 d2 22 f0 00 	cmpl   $0x0,0xf022d238
f0100a63:	74 1b                	je     f0100a80 <boot_alloc+0x29>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	uint32_t alloc_size = ROUNDUP(n, PGSIZE);
	void *alloc_addr = nextfree;
f0100a65:	a1 38 d2 22 f0       	mov    0xf022d238,%eax
	uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100a6a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
	nextfree += alloc_size;
f0100a70:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a76:	01 c2                	add    %eax,%edx
f0100a78:	89 15 38 d2 22 f0    	mov    %edx,0xf022d238
	return alloc_addr;
}
f0100a7e:	5d                   	pop    %ebp
f0100a7f:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a80:	b8 07 00 27 f0       	mov    $0xf0270007,%eax
f0100a85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a8a:	a3 38 d2 22 f0       	mov    %eax,0xf022d238
f0100a8f:	eb d4                	jmp    f0100a65 <boot_alloc+0xe>

f0100a91 <nvram_read>:
{
f0100a91:	55                   	push   %ebp
f0100a92:	89 e5                	mov    %esp,%ebp
f0100a94:	56                   	push   %esi
f0100a95:	53                   	push   %ebx
f0100a96:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a98:	83 ec 0c             	sub    $0xc,%esp
f0100a9b:	50                   	push   %eax
f0100a9c:	e8 a7 2d 00 00       	call   f0103848 <mc146818_read>
f0100aa1:	89 c3                	mov    %eax,%ebx
f0100aa3:	83 c6 01             	add    $0x1,%esi
f0100aa6:	89 34 24             	mov    %esi,(%esp)
f0100aa9:	e8 9a 2d 00 00       	call   f0103848 <mc146818_read>
f0100aae:	c1 e0 08             	shl    $0x8,%eax
f0100ab1:	09 d8                	or     %ebx,%eax
}
f0100ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ab6:	5b                   	pop    %ebx
f0100ab7:	5e                   	pop    %esi
f0100ab8:	5d                   	pop    %ebp
f0100ab9:	c3                   	ret    

f0100aba <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100aba:	89 d1                	mov    %edx,%ecx
f0100abc:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100abf:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ac2:	a8 01                	test   $0x1,%al
f0100ac4:	74 52                	je     f0100b18 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100acb:	89 c1                	mov    %eax,%ecx
f0100acd:	c1 e9 0c             	shr    $0xc,%ecx
f0100ad0:	3b 0d 88 de 22 f0    	cmp    0xf022de88,%ecx
f0100ad6:	73 25                	jae    f0100afd <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100ad8:	c1 ea 0c             	shr    $0xc,%edx
f0100adb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ae1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ae8:	89 c2                	mov    %eax,%edx
f0100aea:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100aed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af2:	85 d2                	test   %edx,%edx
f0100af4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100af9:	0f 44 c2             	cmove  %edx,%eax
f0100afc:	c3                   	ret    
{
f0100afd:	55                   	push   %ebp
f0100afe:	89 e5                	mov    %esp,%ebp
f0100b00:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b03:	50                   	push   %eax
f0100b04:	68 c4 60 10 f0       	push   $0xf01060c4
f0100b09:	68 ad 03 00 00       	push   $0x3ad
f0100b0e:	68 89 6f 10 f0       	push   $0xf0106f89
f0100b13:	e8 28 f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b1d:	c3                   	ret    

f0100b1e <check_page_free_list>:
{
f0100b1e:	55                   	push   %ebp
f0100b1f:	89 e5                	mov    %esp,%ebp
f0100b21:	57                   	push   %edi
f0100b22:	56                   	push   %esi
f0100b23:	53                   	push   %ebx
f0100b24:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b27:	84 c0                	test   %al,%al
f0100b29:	0f 85 86 02 00 00    	jne    f0100db5 <check_page_free_list+0x297>
	if (!page_free_list)
f0100b2f:	83 3d 40 d2 22 f0 00 	cmpl   $0x0,0xf022d240
f0100b36:	74 0a                	je     f0100b42 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b38:	be 00 04 00 00       	mov    $0x400,%esi
f0100b3d:	e9 ce 02 00 00       	jmp    f0100e10 <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100b42:	83 ec 04             	sub    $0x4,%esp
f0100b45:	68 44 66 10 f0       	push   $0xf0106644
f0100b4a:	68 dc 02 00 00       	push   $0x2dc
f0100b4f:	68 89 6f 10 f0       	push   $0xf0106f89
f0100b54:	e8 e7 f4 ff ff       	call   f0100040 <_panic>
f0100b59:	50                   	push   %eax
f0100b5a:	68 c4 60 10 f0       	push   $0xf01060c4
f0100b5f:	6a 58                	push   $0x58
f0100b61:	68 95 6f 10 f0       	push   $0xf0106f95
f0100b66:	e8 d5 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b6b:	8b 1b                	mov    (%ebx),%ebx
f0100b6d:	85 db                	test   %ebx,%ebx
f0100b6f:	74 41                	je     f0100bb2 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b71:	89 d8                	mov    %ebx,%eax
f0100b73:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0100b79:	c1 f8 03             	sar    $0x3,%eax
f0100b7c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b7f:	89 c2                	mov    %eax,%edx
f0100b81:	c1 ea 16             	shr    $0x16,%edx
f0100b84:	39 f2                	cmp    %esi,%edx
f0100b86:	73 e3                	jae    f0100b6b <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b88:	89 c2                	mov    %eax,%edx
f0100b8a:	c1 ea 0c             	shr    $0xc,%edx
f0100b8d:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0100b93:	73 c4                	jae    f0100b59 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100b95:	83 ec 04             	sub    $0x4,%esp
f0100b98:	68 80 00 00 00       	push   $0x80
f0100b9d:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ba2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ba7:	50                   	push   %eax
f0100ba8:	e8 99 48 00 00       	call   f0105446 <memset>
f0100bad:	83 c4 10             	add    $0x10,%esp
f0100bb0:	eb b9                	jmp    f0100b6b <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bb7:	e8 9b fe ff ff       	call   f0100a57 <boot_alloc>
f0100bbc:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bbf:	8b 15 40 d2 22 f0    	mov    0xf022d240,%edx
		assert(pp >= pages);
f0100bc5:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
		assert(pp < pages + npages);
f0100bcb:	a1 88 de 22 f0       	mov    0xf022de88,%eax
f0100bd0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100bd3:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bd6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bd9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bdc:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be1:	e9 04 01 00 00       	jmp    f0100cea <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100be6:	68 a3 6f 10 f0       	push   $0xf0106fa3
f0100beb:	68 af 6f 10 f0       	push   $0xf0106faf
f0100bf0:	68 f6 02 00 00       	push   $0x2f6
f0100bf5:	68 89 6f 10 f0       	push   $0xf0106f89
f0100bfa:	e8 41 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100bff:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0100c04:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c09:	68 f7 02 00 00       	push   $0x2f7
f0100c0e:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c13:	e8 28 f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c18:	68 68 66 10 f0       	push   $0xf0106668
f0100c1d:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c22:	68 f8 02 00 00       	push   $0x2f8
f0100c27:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c2c:	e8 0f f4 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c31:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0100c36:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c3b:	68 fb 02 00 00       	push   $0x2fb
f0100c40:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c45:	e8 f6 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c4a:	68 e9 6f 10 f0       	push   $0xf0106fe9
f0100c4f:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c54:	68 fc 02 00 00       	push   $0x2fc
f0100c59:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c5e:	e8 dd f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c63:	68 9c 66 10 f0       	push   $0xf010669c
f0100c68:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c6d:	68 fd 02 00 00       	push   $0x2fd
f0100c72:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c77:	e8 c4 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c7c:	68 02 70 10 f0       	push   $0xf0107002
f0100c81:	68 af 6f 10 f0       	push   $0xf0106faf
f0100c86:	68 fe 02 00 00       	push   $0x2fe
f0100c8b:	68 89 6f 10 f0       	push   $0xf0106f89
f0100c90:	e8 ab f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100c95:	89 c7                	mov    %eax,%edi
f0100c97:	c1 ef 0c             	shr    $0xc,%edi
f0100c9a:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100c9d:	76 1b                	jbe    f0100cba <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100c9f:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ca5:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100ca8:	77 22                	ja     f0100ccc <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100caa:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100caf:	0f 84 98 00 00 00    	je     f0100d4d <check_page_free_list+0x22f>
			++nfree_extmem;
f0100cb5:	83 c3 01             	add    $0x1,%ebx
f0100cb8:	eb 2e                	jmp    f0100ce8 <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cba:	50                   	push   %eax
f0100cbb:	68 c4 60 10 f0       	push   $0xf01060c4
f0100cc0:	6a 58                	push   $0x58
f0100cc2:	68 95 6f 10 f0       	push   $0xf0106f95
f0100cc7:	e8 74 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ccc:	68 c0 66 10 f0       	push   $0xf01066c0
f0100cd1:	68 af 6f 10 f0       	push   $0xf0106faf
f0100cd6:	68 ff 02 00 00       	push   $0x2ff
f0100cdb:	68 89 6f 10 f0       	push   $0xf0106f89
f0100ce0:	e8 5b f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100ce5:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce8:	8b 12                	mov    (%edx),%edx
f0100cea:	85 d2                	test   %edx,%edx
f0100cec:	74 78                	je     f0100d66 <check_page_free_list+0x248>
		assert(pp >= pages);
f0100cee:	39 d1                	cmp    %edx,%ecx
f0100cf0:	0f 87 f0 fe ff ff    	ja     f0100be6 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100cf6:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100cf9:	0f 86 00 ff ff ff    	jbe    f0100bff <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cff:	89 d0                	mov    %edx,%eax
f0100d01:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d04:	a8 07                	test   $0x7,%al
f0100d06:	0f 85 0c ff ff ff    	jne    f0100c18 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d0c:	c1 f8 03             	sar    $0x3,%eax
f0100d0f:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d12:	85 c0                	test   %eax,%eax
f0100d14:	0f 84 17 ff ff ff    	je     f0100c31 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d1a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d1f:	0f 84 25 ff ff ff    	je     f0100c4a <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d25:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d2a:	0f 84 33 ff ff ff    	je     f0100c63 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d30:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d35:	0f 84 41 ff ff ff    	je     f0100c7c <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d40:	0f 87 4f ff ff ff    	ja     f0100c95 <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d46:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d4b:	75 98                	jne    f0100ce5 <check_page_free_list+0x1c7>
f0100d4d:	68 1c 70 10 f0       	push   $0xf010701c
f0100d52:	68 af 6f 10 f0       	push   $0xf0106faf
f0100d57:	68 01 03 00 00       	push   $0x301
f0100d5c:	68 89 6f 10 f0       	push   $0xf0106f89
f0100d61:	e8 da f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100d66:	85 f6                	test   %esi,%esi
f0100d68:	7e 19                	jle    f0100d83 <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100d6a:	85 db                	test   %ebx,%ebx
f0100d6c:	7e 2e                	jle    f0100d9c <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100d6e:	83 ec 0c             	sub    $0xc,%esp
f0100d71:	68 08 67 10 f0       	push   $0xf0106708
f0100d76:	e8 56 2c 00 00       	call   f01039d1 <cprintf>
}
f0100d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d7e:	5b                   	pop    %ebx
f0100d7f:	5e                   	pop    %esi
f0100d80:	5f                   	pop    %edi
f0100d81:	5d                   	pop    %ebp
f0100d82:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d83:	68 39 70 10 f0       	push   $0xf0107039
f0100d88:	68 af 6f 10 f0       	push   $0xf0106faf
f0100d8d:	68 09 03 00 00       	push   $0x309
f0100d92:	68 89 6f 10 f0       	push   $0xf0106f89
f0100d97:	e8 a4 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d9c:	68 4b 70 10 f0       	push   $0xf010704b
f0100da1:	68 af 6f 10 f0       	push   $0xf0106faf
f0100da6:	68 0a 03 00 00       	push   $0x30a
f0100dab:	68 89 6f 10 f0       	push   $0xf0106f89
f0100db0:	e8 8b f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100db5:	a1 40 d2 22 f0       	mov    0xf022d240,%eax
f0100dba:	85 c0                	test   %eax,%eax
f0100dbc:	0f 84 80 fd ff ff    	je     f0100b42 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100dc2:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dc5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dc8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dce:	89 c2                	mov    %eax,%edx
f0100dd0:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dd6:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ddc:	0f 95 c2             	setne  %dl
f0100ddf:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100de2:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100de6:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100de8:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dec:	8b 00                	mov    (%eax),%eax
f0100dee:	85 c0                	test   %eax,%eax
f0100df0:	75 dc                	jne    f0100dce <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100df5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dfb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e01:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e03:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e06:	a3 40 d2 22 f0       	mov    %eax,0xf022d240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e0b:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e10:	8b 1d 40 d2 22 f0    	mov    0xf022d240,%ebx
f0100e16:	e9 52 fd ff ff       	jmp    f0100b6d <check_page_free_list+0x4f>

f0100e1b <page_init>:
{
f0100e1b:	55                   	push   %ebp
f0100e1c:	89 e5                	mov    %esp,%ebp
f0100e1e:	57                   	push   %edi
f0100e1f:	56                   	push   %esi
f0100e20:	53                   	push   %ebx
f0100e21:	83 ec 1c             	sub    $0x1c,%esp
	int KernRegion_addr = PADDR(boot_alloc(0));
f0100e24:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e29:	e8 29 fc ff ff       	call   f0100a57 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e2e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e33:	76 23                	jbe    f0100e58 <page_init+0x3d>
	int KernRegion_end = ROUNDUP(KernRegion_addr, PGSIZE) / PGSIZE;
f0100e35:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0100e3a:	c1 f8 0c             	sar    $0xc,%eax
f0100e3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		} else if (i > 0 && i < npages_basemem) {
f0100e40:	8b 35 44 d2 22 f0    	mov    0xf022d244,%esi
f0100e46:	8b 3d 40 d2 22 f0    	mov    0xf022d240,%edi
	for (int i = 0; i < npages; ++i) {
f0100e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e56:	eb 7f                	jmp    f0100ed7 <page_init+0xbc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e58:	50                   	push   %eax
f0100e59:	68 e8 60 10 f0       	push   $0xf01060e8
f0100e5e:	68 3c 01 00 00       	push   $0x13c
f0100e63:	68 89 6f 10 f0       	push   $0xf0106f89
f0100e68:	e8 d3 f1 ff ff       	call   f0100040 <_panic>
		} else if (i > 0 && i < npages_basemem) {
f0100e6d:	85 c0                	test   %eax,%eax
f0100e6f:	7e 3f                	jle    f0100eb0 <page_init+0x95>
f0100e71:	39 d6                	cmp    %edx,%esi
f0100e73:	76 3b                	jbe    f0100eb0 <page_init+0x95>
			if (i == mpentry_page) {
f0100e75:	83 f8 07             	cmp    $0x7,%eax
f0100e78:	74 22                	je     f0100e9c <page_init+0x81>
f0100e7a:	c1 e2 03             	shl    $0x3,%edx
				pages[i].pp_ref = 0;
f0100e7d:	89 d1                	mov    %edx,%ecx
f0100e7f:	03 0d 90 de 22 f0    	add    0xf022de90,%ecx
f0100e85:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
				pages[i].pp_link = page_free_list;
f0100e8b:	89 39                	mov    %edi,(%ecx)
				page_free_list = pages + i;
f0100e8d:	89 d7                	mov    %edx,%edi
f0100e8f:	03 3d 90 de 22 f0    	add    0xf022de90,%edi
f0100e95:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100e9a:	eb 38                	jmp    f0100ed4 <page_init+0xb9>
				pages[i].pp_ref++;
f0100e9c:	8b 15 90 de 22 f0    	mov    0xf022de90,%edx
f0100ea2:	66 83 42 3c 01       	addw   $0x1,0x3c(%edx)
				pages[i].pp_link = NULL;
f0100ea7:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
f0100eae:	eb 24                	jmp    f0100ed4 <page_init+0xb9>
		} else if (i >= IORegion_begin && i <= IORegion_end) {
f0100eb0:	8d 8a 60 ff ff ff    	lea    -0xa0(%edx),%ecx
f0100eb6:	83 f9 60             	cmp    $0x60,%ecx
f0100eb9:	77 43                	ja     f0100efe <page_init+0xe3>
			pages[i].pp_link = NULL;
f0100ebb:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
f0100ec1:	c7 04 d1 00 00 00 00 	movl   $0x0,(%ecx,%edx,8)
			pages[i].pp_ref++;
f0100ec8:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
f0100ece:	66 83 44 d1 04 01    	addw   $0x1,0x4(%ecx,%edx,8)
	for (int i = 0; i < npages; ++i) {
f0100ed4:	83 c0 01             	add    $0x1,%eax
f0100ed7:	89 c2                	mov    %eax,%edx
f0100ed9:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f0100edf:	73 66                	jae    f0100f47 <page_init+0x12c>
		if (i == 0) {
f0100ee1:	85 c0                	test   %eax,%eax
f0100ee3:	75 88                	jne    f0100e6d <page_init+0x52>
			pages[i].pp_link = NULL;
f0100ee5:	8b 15 90 de 22 f0    	mov    0xf022de90,%edx
f0100eeb:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
			pages[i].pp_ref++;
f0100ef1:	8b 15 90 de 22 f0    	mov    0xf022de90,%edx
f0100ef7:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
f0100efc:	eb d6                	jmp    f0100ed4 <page_init+0xb9>
		} else if (i > IORegion_end) {
f0100efe:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100f03:	7e cf                	jle    f0100ed4 <page_init+0xb9>
			if (i <= KernRegion_end) {
f0100f05:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100f08:	7f 1b                	jg     f0100f25 <page_init+0x10a>
				pages[i].pp_link = NULL;
f0100f0a:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
f0100f10:	c7 04 d1 00 00 00 00 	movl   $0x0,(%ecx,%edx,8)
				pages[i].pp_ref++;
f0100f17:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
f0100f1d:	66 83 44 d1 04 01    	addw   $0x1,0x4(%ecx,%edx,8)
f0100f23:	eb af                	jmp    f0100ed4 <page_init+0xb9>
f0100f25:	c1 e2 03             	shl    $0x3,%edx
				pages[i].pp_ref = 0;
f0100f28:	89 d1                	mov    %edx,%ecx
f0100f2a:	03 0d 90 de 22 f0    	add    0xf022de90,%ecx
f0100f30:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
				pages[i].pp_link = page_free_list;
f0100f36:	89 39                	mov    %edi,(%ecx)
				page_free_list = pages + i;
f0100f38:	89 d7                	mov    %edx,%edi
f0100f3a:	03 3d 90 de 22 f0    	add    0xf022de90,%edi
f0100f40:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f45:	eb 8d                	jmp    f0100ed4 <page_init+0xb9>
f0100f47:	84 db                	test   %bl,%bl
f0100f49:	75 08                	jne    f0100f53 <page_init+0x138>
}
f0100f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f4e:	5b                   	pop    %ebx
f0100f4f:	5e                   	pop    %esi
f0100f50:	5f                   	pop    %edi
f0100f51:	5d                   	pop    %ebp
f0100f52:	c3                   	ret    
f0100f53:	89 3d 40 d2 22 f0    	mov    %edi,0xf022d240
f0100f59:	eb f0                	jmp    f0100f4b <page_init+0x130>

f0100f5b <page_alloc>:
{
f0100f5b:	55                   	push   %ebp
f0100f5c:	89 e5                	mov    %esp,%ebp
f0100f5e:	53                   	push   %ebx
f0100f5f:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100f62:	8b 1d 40 d2 22 f0    	mov    0xf022d240,%ebx
f0100f68:	85 db                	test   %ebx,%ebx
f0100f6a:	74 13                	je     f0100f7f <page_alloc+0x24>
		page_free_list = page_free_list->pp_link;
f0100f6c:	8b 03                	mov    (%ebx),%eax
f0100f6e:	a3 40 d2 22 f0       	mov    %eax,0xf022d240
		free_page->pp_link = NULL;
f0100f73:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags) {
f0100f79:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100f7d:	75 07                	jne    f0100f86 <page_alloc+0x2b>
}
f0100f7f:	89 d8                	mov    %ebx,%eax
f0100f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f84:	c9                   	leave  
f0100f85:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f86:	89 d8                	mov    %ebx,%eax
f0100f88:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0100f8e:	c1 f8 03             	sar    $0x3,%eax
f0100f91:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f94:	89 c2                	mov    %eax,%edx
f0100f96:	c1 ea 0c             	shr    $0xc,%edx
f0100f99:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0100f9f:	73 1a                	jae    f0100fbb <page_alloc+0x60>
			memset(page2kva(free_page), 0, PGSIZE);
f0100fa1:	83 ec 04             	sub    $0x4,%esp
f0100fa4:	68 00 10 00 00       	push   $0x1000
f0100fa9:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fb0:	50                   	push   %eax
f0100fb1:	e8 90 44 00 00       	call   f0105446 <memset>
f0100fb6:	83 c4 10             	add    $0x10,%esp
	return free_page;
f0100fb9:	eb c4                	jmp    f0100f7f <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbb:	50                   	push   %eax
f0100fbc:	68 c4 60 10 f0       	push   $0xf01060c4
f0100fc1:	6a 58                	push   $0x58
f0100fc3:	68 95 6f 10 f0       	push   $0xf0106f95
f0100fc8:	e8 73 f0 ff ff       	call   f0100040 <_panic>

f0100fcd <page_free>:
{
f0100fcd:	55                   	push   %ebp
f0100fce:	89 e5                	mov    %esp,%ebp
f0100fd0:	83 ec 08             	sub    $0x8,%esp
f0100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_link || pp->pp_ref) {
f0100fd6:	83 38 00             	cmpl   $0x0,(%eax)
f0100fd9:	75 16                	jne    f0100ff1 <page_free+0x24>
f0100fdb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fe0:	75 0f                	jne    f0100ff1 <page_free+0x24>
	pp->pp_link = page_free_list;
f0100fe2:	8b 15 40 d2 22 f0    	mov    0xf022d240,%edx
f0100fe8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fea:	a3 40 d2 22 f0       	mov    %eax,0xf022d240
}
f0100fef:	c9                   	leave  
f0100ff0:	c3                   	ret    
		panic("This page is already in used");
f0100ff1:	83 ec 04             	sub    $0x4,%esp
f0100ff4:	68 5c 70 10 f0       	push   $0xf010705c
f0100ff9:	68 88 01 00 00       	push   $0x188
f0100ffe:	68 89 6f 10 f0       	push   $0xf0106f89
f0101003:	e8 38 f0 ff ff       	call   f0100040 <_panic>

f0101008 <page_decref>:
{
f0101008:	55                   	push   %ebp
f0101009:	89 e5                	mov    %esp,%ebp
f010100b:	83 ec 08             	sub    $0x8,%esp
f010100e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101011:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101015:	83 e8 01             	sub    $0x1,%eax
f0101018:	66 89 42 04          	mov    %ax,0x4(%edx)
f010101c:	66 85 c0             	test   %ax,%ax
f010101f:	74 02                	je     f0101023 <page_decref+0x1b>
}
f0101021:	c9                   	leave  
f0101022:	c3                   	ret    
		page_free(pp);
f0101023:	83 ec 0c             	sub    $0xc,%esp
f0101026:	52                   	push   %edx
f0101027:	e8 a1 ff ff ff       	call   f0100fcd <page_free>
f010102c:	83 c4 10             	add    $0x10,%esp
}
f010102f:	eb f0                	jmp    f0101021 <page_decref+0x19>

f0101031 <pgdir_walk>:
{
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	56                   	push   %esi
f0101035:	53                   	push   %ebx
f0101036:	8b 45 08             	mov    0x8(%ebp),%eax
f0101039:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (!pgdir) {
f010103c:	85 c0                	test   %eax,%eax
f010103e:	0f 84 b8 00 00 00    	je     f01010fc <pgdir_walk+0xcb>
	int pgdir_index = PDX(va);
f0101044:	89 da                	mov    %ebx,%edx
f0101046:	c1 ea 16             	shr    $0x16,%edx
	if (pgdir[pgdir_index] & PTE_P) {
f0101049:	8d 34 90             	lea    (%eax,%edx,4),%esi
f010104c:	8b 06                	mov    (%esi),%eax
f010104e:	a8 01                	test   $0x1,%al
f0101050:	74 3e                	je     f0101090 <pgdir_walk+0x5f>
		physaddr_t phys_pgtable = PTE_ADDR(pgdir[pgdir_index]);
f0101052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101057:	89 c2                	mov    %eax,%edx
f0101059:	c1 ea 0c             	shr    $0xc,%edx
f010105c:	39 15 88 de 22 f0    	cmp    %edx,0xf022de88
f0101062:	76 17                	jbe    f010107b <pgdir_walk+0x4a>
		int pgtable_index = PTX(va);
f0101064:	c1 eb 0a             	shr    $0xa,%ebx
		ret_pte = va_pgtable + pgtable_index;
f0101067:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010106d:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
}
f0101074:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101077:	5b                   	pop    %ebx
f0101078:	5e                   	pop    %esi
f0101079:	5d                   	pop    %ebp
f010107a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107b:	50                   	push   %eax
f010107c:	68 c4 60 10 f0       	push   $0xf01060c4
f0101081:	68 ba 01 00 00       	push   $0x1ba
f0101086:	68 89 6f 10 f0       	push   $0xf0106f89
f010108b:	e8 b0 ef ff ff       	call   f0100040 <_panic>
		if (create) {
f0101090:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101094:	74 70                	je     f0101106 <pgdir_walk+0xd5>
			struct PageInfo *pgtable_pg = page_alloc(1);
f0101096:	83 ec 0c             	sub    $0xc,%esp
f0101099:	6a 01                	push   $0x1
f010109b:	e8 bb fe ff ff       	call   f0100f5b <page_alloc>
			if (pgtable_pg) {
f01010a0:	83 c4 10             	add    $0x10,%esp
f01010a3:	85 c0                	test   %eax,%eax
f01010a5:	74 69                	je     f0101110 <pgdir_walk+0xdf>
	return (pp - pages) << PGSHIFT;
f01010a7:	89 c2                	mov    %eax,%edx
f01010a9:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f01010af:	c1 fa 03             	sar    $0x3,%edx
f01010b2:	c1 e2 0c             	shl    $0xc,%edx
				pgdir[pgdir_index] = page2pa(pgtable_pg) | PTE_P | PTE_U | PTE_W;
f01010b5:	83 ca 07             	or     $0x7,%edx
f01010b8:	89 16                	mov    %edx,(%esi)
				pgtable_pg->pp_ref++;
f01010ba:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01010bf:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f01010c5:	c1 f8 03             	sar    $0x3,%eax
f01010c8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01010cb:	89 c2                	mov    %eax,%edx
f01010cd:	c1 ea 0c             	shr    $0xc,%edx
f01010d0:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f01010d6:	73 12                	jae    f01010ea <pgdir_walk+0xb9>
				int pgtable_index = PTX(va);
f01010d8:	c1 eb 0a             	shr    $0xa,%ebx
				ret_pte = va_pgtable + pgtable_index;
f01010db:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01010e1:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01010e8:	eb 8a                	jmp    f0101074 <pgdir_walk+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ea:	50                   	push   %eax
f01010eb:	68 c4 60 10 f0       	push   $0xf01060c4
f01010f0:	6a 58                	push   $0x58
f01010f2:	68 95 6f 10 f0       	push   $0xf0106f95
f01010f7:	e8 44 ef ff ff       	call   f0100040 <_panic>
		return NULL;
f01010fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101101:	e9 6e ff ff ff       	jmp    f0101074 <pgdir_walk+0x43>
			ret_pte = NULL;
f0101106:	b8 00 00 00 00       	mov    $0x0,%eax
f010110b:	e9 64 ff ff ff       	jmp    f0101074 <pgdir_walk+0x43>
				ret_pte = NULL;
f0101110:	b8 00 00 00 00       	mov    $0x0,%eax
f0101115:	e9 5a ff ff ff       	jmp    f0101074 <pgdir_walk+0x43>

f010111a <boot_map_region>:
{
f010111a:	55                   	push   %ebp
f010111b:	89 e5                	mov    %esp,%ebp
f010111d:	57                   	push   %edi
f010111e:	56                   	push   %esi
f010111f:	53                   	push   %ebx
f0101120:	83 ec 1c             	sub    $0x1c,%esp
f0101123:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101126:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgcnt = size / PGSIZE;
f0101129:	c1 e9 0c             	shr    $0xc,%ecx
f010112c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < pgcnt; ++i) {
f010112f:	89 c3                	mov    %eax,%ebx
f0101131:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *va_pte = pgdir_walk(pgdir, (void*)(va + i * PGSIZE), 1);
f0101136:	89 d7                	mov    %edx,%edi
f0101138:	29 c7                	sub    %eax,%edi
			*va_pte = (pa + i * PGSIZE) | PTE_P | perm;
f010113a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010113d:	83 c8 01             	or     $0x1,%eax
f0101140:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < pgcnt; ++i) {
f0101143:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101146:	7d 41                	jge    f0101189 <boot_map_region+0x6f>
		pte_t *va_pte = pgdir_walk(pgdir, (void*)(va + i * PGSIZE), 1);
f0101148:	83 ec 04             	sub    $0x4,%esp
f010114b:	6a 01                	push   $0x1
f010114d:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101150:	50                   	push   %eax
f0101151:	ff 75 e0             	pushl  -0x20(%ebp)
f0101154:	e8 d8 fe ff ff       	call   f0101031 <pgdir_walk>
		if (va_pte) {
f0101159:	83 c4 10             	add    $0x10,%esp
f010115c:	85 c0                	test   %eax,%eax
f010115e:	74 12                	je     f0101172 <boot_map_region+0x58>
			*va_pte = (pa + i * PGSIZE) | PTE_P | perm;
f0101160:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101163:	09 da                	or     %ebx,%edx
f0101165:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < pgcnt; ++i) {
f0101167:	83 c6 01             	add    $0x1,%esi
f010116a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101170:	eb d1                	jmp    f0101143 <boot_map_region+0x29>
			panic("No enough physical memory for map!");
f0101172:	83 ec 04             	sub    $0x4,%esp
f0101175:	68 2c 67 10 f0       	push   $0xf010672c
f010117a:	68 e4 01 00 00       	push   $0x1e4
f010117f:	68 89 6f 10 f0       	push   $0xf0106f89
f0101184:	e8 b7 ee ff ff       	call   f0100040 <_panic>
}
f0101189:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010118c:	5b                   	pop    %ebx
f010118d:	5e                   	pop    %esi
f010118e:	5f                   	pop    %edi
f010118f:	5d                   	pop    %ebp
f0101190:	c3                   	ret    

f0101191 <page_lookup>:
{
f0101191:	55                   	push   %ebp
f0101192:	89 e5                	mov    %esp,%ebp
f0101194:	53                   	push   %ebx
f0101195:	83 ec 08             	sub    $0x8,%esp
f0101198:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *va_pte = pgdir_walk(pgdir, va, 0);
f010119b:	6a 00                	push   $0x0
f010119d:	ff 75 0c             	pushl  0xc(%ebp)
f01011a0:	ff 75 08             	pushl  0x8(%ebp)
f01011a3:	e8 89 fe ff ff       	call   f0101031 <pgdir_walk>
	if (va_pte && (*va_pte & PTE_P)) {
f01011a8:	83 c4 10             	add    $0x10,%esp
f01011ab:	85 c0                	test   %eax,%eax
f01011ad:	74 3a                	je     f01011e9 <page_lookup+0x58>
f01011af:	f6 00 01             	testb  $0x1,(%eax)
f01011b2:	74 3c                	je     f01011f0 <page_lookup+0x5f>
		if (pte_store) {
f01011b4:	85 db                	test   %ebx,%ebx
f01011b6:	74 02                	je     f01011ba <page_lookup+0x29>
			*pte_store = va_pte;
f01011b8:	89 03                	mov    %eax,(%ebx)
f01011ba:	8b 00                	mov    (%eax),%eax
f01011bc:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011bf:	39 05 88 de 22 f0    	cmp    %eax,0xf022de88
f01011c5:	76 0e                	jbe    f01011d5 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011c7:	8b 15 90 de 22 f0    	mov    0xf022de90,%edx
f01011cd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011d3:	c9                   	leave  
f01011d4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011d5:	83 ec 04             	sub    $0x4,%esp
f01011d8:	68 50 67 10 f0       	push   $0xf0106750
f01011dd:	6a 51                	push   $0x51
f01011df:	68 95 6f 10 f0       	push   $0xf0106f95
f01011e4:	e8 57 ee ff ff       	call   f0100040 <_panic>
		return NULL;
f01011e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ee:	eb e0                	jmp    f01011d0 <page_lookup+0x3f>
f01011f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f5:	eb d9                	jmp    f01011d0 <page_lookup+0x3f>

f01011f7 <tlb_invalidate>:
{
f01011f7:	55                   	push   %ebp
f01011f8:	89 e5                	mov    %esp,%ebp
f01011fa:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011fd:	e8 69 48 00 00       	call   f0105a6b <cpunum>
f0101202:	6b c0 74             	imul   $0x74,%eax,%eax
f0101205:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f010120c:	74 16                	je     f0101224 <tlb_invalidate+0x2d>
f010120e:	e8 58 48 00 00       	call   f0105a6b <cpunum>
f0101213:	6b c0 74             	imul   $0x74,%eax,%eax
f0101216:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f010121c:	8b 55 08             	mov    0x8(%ebp),%edx
f010121f:	39 50 60             	cmp    %edx,0x60(%eax)
f0101222:	75 06                	jne    f010122a <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101224:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101227:	0f 01 38             	invlpg (%eax)
}
f010122a:	c9                   	leave  
f010122b:	c3                   	ret    

f010122c <page_remove>:
{
f010122c:	55                   	push   %ebp
f010122d:	89 e5                	mov    %esp,%ebp
f010122f:	56                   	push   %esi
f0101230:	53                   	push   %ebx
f0101231:	83 ec 14             	sub    $0x14,%esp
f0101234:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101237:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *va_pte = NULL;
f010123a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *va_page = page_lookup(pgdir, va, &va_pte);
f0101241:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101244:	50                   	push   %eax
f0101245:	56                   	push   %esi
f0101246:	53                   	push   %ebx
f0101247:	e8 45 ff ff ff       	call   f0101191 <page_lookup>
	if (va_page) {
f010124c:	83 c4 10             	add    $0x10,%esp
f010124f:	85 c0                	test   %eax,%eax
f0101251:	74 26                	je     f0101279 <page_remove+0x4d>
		page_decref(va_page);
f0101253:	83 ec 0c             	sub    $0xc,%esp
f0101256:	50                   	push   %eax
f0101257:	e8 ac fd ff ff       	call   f0101008 <page_decref>
		if (va_pte) {
f010125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010125f:	83 c4 10             	add    $0x10,%esp
f0101262:	85 c0                	test   %eax,%eax
f0101264:	74 06                	je     f010126c <page_remove+0x40>
			*va_pte = 0;
f0101266:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010126c:	83 ec 08             	sub    $0x8,%esp
f010126f:	56                   	push   %esi
f0101270:	53                   	push   %ebx
f0101271:	e8 81 ff ff ff       	call   f01011f7 <tlb_invalidate>
f0101276:	83 c4 10             	add    $0x10,%esp
}
f0101279:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010127c:	5b                   	pop    %ebx
f010127d:	5e                   	pop    %esi
f010127e:	5d                   	pop    %ebp
f010127f:	c3                   	ret    

f0101280 <page_insert>:
{
f0101280:	55                   	push   %ebp
f0101281:	89 e5                	mov    %esp,%ebp
f0101283:	57                   	push   %edi
f0101284:	56                   	push   %esi
f0101285:	53                   	push   %ebx
f0101286:	83 ec 10             	sub    $0x10,%esp
f0101289:	8b 75 0c             	mov    0xc(%ebp),%esi
f010128c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *va_pte = pgdir_walk(pgdir, va, 0);
f010128f:	6a 00                	push   $0x0
f0101291:	57                   	push   %edi
f0101292:	ff 75 08             	pushl  0x8(%ebp)
f0101295:	e8 97 fd ff ff       	call   f0101031 <pgdir_walk>
	if (va_pte && (*va_pte & PTE_P)) {
f010129a:	83 c4 10             	add    $0x10,%esp
f010129d:	85 c0                	test   %eax,%eax
f010129f:	74 07                	je     f01012a8 <page_insert+0x28>
f01012a1:	89 c3                	mov    %eax,%ebx
f01012a3:	f6 00 01             	testb  $0x1,(%eax)
f01012a6:	75 3f                	jne    f01012e7 <page_insert+0x67>
		va_pte = pgdir_walk(pgdir, va, 1);
f01012a8:	83 ec 04             	sub    $0x4,%esp
f01012ab:	6a 01                	push   $0x1
f01012ad:	57                   	push   %edi
f01012ae:	ff 75 08             	pushl  0x8(%ebp)
f01012b1:	e8 7b fd ff ff       	call   f0101031 <pgdir_walk>
		if (va_pte) {
f01012b6:	83 c4 10             	add    $0x10,%esp
f01012b9:	85 c0                	test   %eax,%eax
f01012bb:	74 5d                	je     f010131a <page_insert+0x9a>
	return (pp - pages) << PGSHIFT;
f01012bd:	89 f2                	mov    %esi,%edx
f01012bf:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f01012c5:	c1 fa 03             	sar    $0x3,%edx
f01012c8:	c1 e2 0c             	shl    $0xc,%edx
			*va_pte = page2pa(pp) | PTE_P | perm;
f01012cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01012ce:	83 c9 01             	or     $0x1,%ecx
f01012d1:	09 ca                	or     %ecx,%edx
f01012d3:	89 10                	mov    %edx,(%eax)
			pp->pp_ref++;
f01012d5:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	return 0;
f01012da:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e2:	5b                   	pop    %ebx
f01012e3:	5e                   	pop    %esi
f01012e4:	5f                   	pop    %edi
f01012e5:	5d                   	pop    %ebp
f01012e6:	c3                   	ret    
		pp->pp_ref++;
f01012e7:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
		page_remove(pgdir, va);
f01012ec:	83 ec 08             	sub    $0x8,%esp
f01012ef:	57                   	push   %edi
f01012f0:	ff 75 08             	pushl  0x8(%ebp)
f01012f3:	e8 34 ff ff ff       	call   f010122c <page_remove>
f01012f8:	89 f0                	mov    %esi,%eax
f01012fa:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0101300:	c1 f8 03             	sar    $0x3,%eax
f0101303:	c1 e0 0c             	shl    $0xc,%eax
		*va_pte = page2pa(pp) | PTE_P | perm;
f0101306:	8b 55 14             	mov    0x14(%ebp),%edx
f0101309:	83 ca 01             	or     $0x1,%edx
f010130c:	09 d0                	or     %edx,%eax
f010130e:	89 03                	mov    %eax,(%ebx)
f0101310:	83 c4 10             	add    $0x10,%esp
	return 0;
f0101313:	b8 00 00 00 00       	mov    $0x0,%eax
		*va_pte = page2pa(pp) | PTE_P | perm;
f0101318:	eb c5                	jmp    f01012df <page_insert+0x5f>
			return -E_NO_MEM;
f010131a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010131f:	eb be                	jmp    f01012df <page_insert+0x5f>

f0101321 <mmio_map_region>:
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	53                   	push   %ebx
f0101325:	83 ec 04             	sub    $0x4,%esp
	size = ROUNDUP(size, PGSIZE);
f0101328:	8b 45 0c             	mov    0xc(%ebp),%eax
f010132b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101331:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size >= MMIOLIM) {
f0101337:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010133d:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101340:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101345:	77 26                	ja     f010136d <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101347:	83 ec 08             	sub    $0x8,%esp
f010134a:	6a 1a                	push   $0x1a
f010134c:	ff 75 08             	pushl  0x8(%ebp)
f010134f:	89 d9                	mov    %ebx,%ecx
f0101351:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101356:	e8 bf fd ff ff       	call   f010111a <boot_map_region>
	void *map_addr = (void*)base;
f010135b:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base += size;
f0101360:	01 c3                	add    %eax,%ebx
f0101362:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010136b:	c9                   	leave  
f010136c:	c3                   	ret    
		panic("MMIO Overflows!");
f010136d:	83 ec 04             	sub    $0x4,%esp
f0101370:	68 79 70 10 f0       	push   $0xf0107079
f0101375:	68 7f 02 00 00       	push   $0x27f
f010137a:	68 89 6f 10 f0       	push   $0xf0106f89
f010137f:	e8 bc ec ff ff       	call   f0100040 <_panic>

f0101384 <mem_init>:
{
f0101384:	55                   	push   %ebp
f0101385:	89 e5                	mov    %esp,%ebp
f0101387:	57                   	push   %edi
f0101388:	56                   	push   %esi
f0101389:	53                   	push   %ebx
f010138a:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010138d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101392:	e8 fa f6 ff ff       	call   f0100a91 <nvram_read>
f0101397:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101399:	b8 17 00 00 00       	mov    $0x17,%eax
f010139e:	e8 ee f6 ff ff       	call   f0100a91 <nvram_read>
f01013a3:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013a5:	b8 34 00 00 00       	mov    $0x34,%eax
f01013aa:	e8 e2 f6 ff ff       	call   f0100a91 <nvram_read>
f01013af:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01013b2:	85 c0                	test   %eax,%eax
f01013b4:	0f 85 e4 00 00 00    	jne    f010149e <mem_init+0x11a>
		totalmem = 1 * 1024 + extmem;
f01013ba:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013c0:	85 f6                	test   %esi,%esi
f01013c2:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013c5:	89 c2                	mov    %eax,%edx
f01013c7:	c1 ea 02             	shr    $0x2,%edx
f01013ca:	89 15 88 de 22 f0    	mov    %edx,0xf022de88
	npages_basemem = basemem / (PGSIZE / 1024);
f01013d0:	89 da                	mov    %ebx,%edx
f01013d2:	c1 ea 02             	shr    $0x2,%edx
f01013d5:	89 15 44 d2 22 f0    	mov    %edx,0xf022d244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013db:	89 c2                	mov    %eax,%edx
f01013dd:	29 da                	sub    %ebx,%edx
f01013df:	52                   	push   %edx
f01013e0:	53                   	push   %ebx
f01013e1:	50                   	push   %eax
f01013e2:	68 70 67 10 f0       	push   $0xf0106770
f01013e7:	e8 e5 25 00 00       	call   f01039d1 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ec:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013f1:	e8 61 f6 ff ff       	call   f0100a57 <boot_alloc>
f01013f6:	a3 8c de 22 f0       	mov    %eax,0xf022de8c
	memset(kern_pgdir, 0, PGSIZE);
f01013fb:	83 c4 0c             	add    $0xc,%esp
f01013fe:	68 00 10 00 00       	push   $0x1000
f0101403:	6a 00                	push   $0x0
f0101405:	50                   	push   %eax
f0101406:	e8 3b 40 00 00       	call   f0105446 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010140b:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101410:	83 c4 10             	add    $0x10,%esp
f0101413:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101418:	0f 86 8a 00 00 00    	jbe    f01014a8 <mem_init+0x124>
	return (physaddr_t)kva - KERNBASE;
f010141e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101424:	83 ca 05             	or     $0x5,%edx
f0101427:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(sizeof(struct PageInfo) * npages);
f010142d:	a1 88 de 22 f0       	mov    0xf022de88,%eax
f0101432:	c1 e0 03             	shl    $0x3,%eax
f0101435:	e8 1d f6 ff ff       	call   f0100a57 <boot_alloc>
f010143a:	a3 90 de 22 f0       	mov    %eax,0xf022de90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f010143f:	83 ec 04             	sub    $0x4,%esp
f0101442:	8b 0d 88 de 22 f0    	mov    0xf022de88,%ecx
f0101448:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010144f:	52                   	push   %edx
f0101450:	6a 00                	push   $0x0
f0101452:	50                   	push   %eax
f0101453:	e8 ee 3f 00 00       	call   f0105446 <memset>
	envs = boot_alloc(sizeof(struct Env) * NENV);
f0101458:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010145d:	e8 f5 f5 ff ff       	call   f0100a57 <boot_alloc>
f0101462:	a3 48 d2 22 f0       	mov    %eax,0xf022d248
	memset(envs, 0, sizeof(struct Env) * NENV);
f0101467:	83 c4 0c             	add    $0xc,%esp
f010146a:	68 00 f0 01 00       	push   $0x1f000
f010146f:	6a 00                	push   $0x0
f0101471:	50                   	push   %eax
f0101472:	e8 cf 3f 00 00       	call   f0105446 <memset>
	page_init();
f0101477:	e8 9f f9 ff ff       	call   f0100e1b <page_init>
	check_page_free_list(1);
f010147c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101481:	e8 98 f6 ff ff       	call   f0100b1e <check_page_free_list>
	if (!pages)
f0101486:	83 c4 10             	add    $0x10,%esp
f0101489:	83 3d 90 de 22 f0 00 	cmpl   $0x0,0xf022de90
f0101490:	74 2b                	je     f01014bd <mem_init+0x139>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101492:	a1 40 d2 22 f0       	mov    0xf022d240,%eax
f0101497:	bb 00 00 00 00       	mov    $0x0,%ebx
f010149c:	eb 3b                	jmp    f01014d9 <mem_init+0x155>
		totalmem = 16 * 1024 + ext16mem;
f010149e:	05 00 40 00 00       	add    $0x4000,%eax
f01014a3:	e9 1d ff ff ff       	jmp    f01013c5 <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014a8:	50                   	push   %eax
f01014a9:	68 e8 60 10 f0       	push   $0xf01060e8
f01014ae:	68 93 00 00 00       	push   $0x93
f01014b3:	68 89 6f 10 f0       	push   $0xf0106f89
f01014b8:	e8 83 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01014bd:	83 ec 04             	sub    $0x4,%esp
f01014c0:	68 89 70 10 f0       	push   $0xf0107089
f01014c5:	68 1d 03 00 00       	push   $0x31d
f01014ca:	68 89 6f 10 f0       	push   $0xf0106f89
f01014cf:	e8 6c eb ff ff       	call   f0100040 <_panic>
		++nfree;
f01014d4:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014d7:	8b 00                	mov    (%eax),%eax
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	75 f7                	jne    f01014d4 <mem_init+0x150>
	assert((pp0 = page_alloc(0)));
f01014dd:	83 ec 0c             	sub    $0xc,%esp
f01014e0:	6a 00                	push   $0x0
f01014e2:	e8 74 fa ff ff       	call   f0100f5b <page_alloc>
f01014e7:	89 c7                	mov    %eax,%edi
f01014e9:	83 c4 10             	add    $0x10,%esp
f01014ec:	85 c0                	test   %eax,%eax
f01014ee:	0f 84 12 02 00 00    	je     f0101706 <mem_init+0x382>
	assert((pp1 = page_alloc(0)));
f01014f4:	83 ec 0c             	sub    $0xc,%esp
f01014f7:	6a 00                	push   $0x0
f01014f9:	e8 5d fa ff ff       	call   f0100f5b <page_alloc>
f01014fe:	89 c6                	mov    %eax,%esi
f0101500:	83 c4 10             	add    $0x10,%esp
f0101503:	85 c0                	test   %eax,%eax
f0101505:	0f 84 14 02 00 00    	je     f010171f <mem_init+0x39b>
	assert((pp2 = page_alloc(0)));
f010150b:	83 ec 0c             	sub    $0xc,%esp
f010150e:	6a 00                	push   $0x0
f0101510:	e8 46 fa ff ff       	call   f0100f5b <page_alloc>
f0101515:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101518:	83 c4 10             	add    $0x10,%esp
f010151b:	85 c0                	test   %eax,%eax
f010151d:	0f 84 15 02 00 00    	je     f0101738 <mem_init+0x3b4>
	assert(pp1 && pp1 != pp0);
f0101523:	39 f7                	cmp    %esi,%edi
f0101525:	0f 84 26 02 00 00    	je     f0101751 <mem_init+0x3cd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010152b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010152e:	39 c6                	cmp    %eax,%esi
f0101530:	0f 84 34 02 00 00    	je     f010176a <mem_init+0x3e6>
f0101536:	39 c7                	cmp    %eax,%edi
f0101538:	0f 84 2c 02 00 00    	je     f010176a <mem_init+0x3e6>
	return (pp - pages) << PGSHIFT;
f010153e:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101544:	8b 15 88 de 22 f0    	mov    0xf022de88,%edx
f010154a:	c1 e2 0c             	shl    $0xc,%edx
f010154d:	89 f8                	mov    %edi,%eax
f010154f:	29 c8                	sub    %ecx,%eax
f0101551:	c1 f8 03             	sar    $0x3,%eax
f0101554:	c1 e0 0c             	shl    $0xc,%eax
f0101557:	39 d0                	cmp    %edx,%eax
f0101559:	0f 83 24 02 00 00    	jae    f0101783 <mem_init+0x3ff>
f010155f:	89 f0                	mov    %esi,%eax
f0101561:	29 c8                	sub    %ecx,%eax
f0101563:	c1 f8 03             	sar    $0x3,%eax
f0101566:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101569:	39 c2                	cmp    %eax,%edx
f010156b:	0f 86 2b 02 00 00    	jbe    f010179c <mem_init+0x418>
f0101571:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101574:	29 c8                	sub    %ecx,%eax
f0101576:	c1 f8 03             	sar    $0x3,%eax
f0101579:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010157c:	39 c2                	cmp    %eax,%edx
f010157e:	0f 86 31 02 00 00    	jbe    f01017b5 <mem_init+0x431>
	fl = page_free_list;
f0101584:	a1 40 d2 22 f0       	mov    0xf022d240,%eax
f0101589:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010158c:	c7 05 40 d2 22 f0 00 	movl   $0x0,0xf022d240
f0101593:	00 00 00 
	assert(!page_alloc(0));
f0101596:	83 ec 0c             	sub    $0xc,%esp
f0101599:	6a 00                	push   $0x0
f010159b:	e8 bb f9 ff ff       	call   f0100f5b <page_alloc>
f01015a0:	83 c4 10             	add    $0x10,%esp
f01015a3:	85 c0                	test   %eax,%eax
f01015a5:	0f 85 23 02 00 00    	jne    f01017ce <mem_init+0x44a>
	page_free(pp0);
f01015ab:	83 ec 0c             	sub    $0xc,%esp
f01015ae:	57                   	push   %edi
f01015af:	e8 19 fa ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f01015b4:	89 34 24             	mov    %esi,(%esp)
f01015b7:	e8 11 fa ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f01015bc:	83 c4 04             	add    $0x4,%esp
f01015bf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015c2:	e8 06 fa ff ff       	call   f0100fcd <page_free>
	assert((pp0 = page_alloc(0)));
f01015c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ce:	e8 88 f9 ff ff       	call   f0100f5b <page_alloc>
f01015d3:	89 c6                	mov    %eax,%esi
f01015d5:	83 c4 10             	add    $0x10,%esp
f01015d8:	85 c0                	test   %eax,%eax
f01015da:	0f 84 07 02 00 00    	je     f01017e7 <mem_init+0x463>
	assert((pp1 = page_alloc(0)));
f01015e0:	83 ec 0c             	sub    $0xc,%esp
f01015e3:	6a 00                	push   $0x0
f01015e5:	e8 71 f9 ff ff       	call   f0100f5b <page_alloc>
f01015ea:	89 c7                	mov    %eax,%edi
f01015ec:	83 c4 10             	add    $0x10,%esp
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	0f 84 09 02 00 00    	je     f0101800 <mem_init+0x47c>
	assert((pp2 = page_alloc(0)));
f01015f7:	83 ec 0c             	sub    $0xc,%esp
f01015fa:	6a 00                	push   $0x0
f01015fc:	e8 5a f9 ff ff       	call   f0100f5b <page_alloc>
f0101601:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101604:	83 c4 10             	add    $0x10,%esp
f0101607:	85 c0                	test   %eax,%eax
f0101609:	0f 84 0a 02 00 00    	je     f0101819 <mem_init+0x495>
	assert(pp1 && pp1 != pp0);
f010160f:	39 fe                	cmp    %edi,%esi
f0101611:	0f 84 1b 02 00 00    	je     f0101832 <mem_init+0x4ae>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101617:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010161a:	39 c6                	cmp    %eax,%esi
f010161c:	0f 84 29 02 00 00    	je     f010184b <mem_init+0x4c7>
f0101622:	39 c7                	cmp    %eax,%edi
f0101624:	0f 84 21 02 00 00    	je     f010184b <mem_init+0x4c7>
	assert(!page_alloc(0));
f010162a:	83 ec 0c             	sub    $0xc,%esp
f010162d:	6a 00                	push   $0x0
f010162f:	e8 27 f9 ff ff       	call   f0100f5b <page_alloc>
f0101634:	83 c4 10             	add    $0x10,%esp
f0101637:	85 c0                	test   %eax,%eax
f0101639:	0f 85 25 02 00 00    	jne    f0101864 <mem_init+0x4e0>
f010163f:	89 f0                	mov    %esi,%eax
f0101641:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0101647:	c1 f8 03             	sar    $0x3,%eax
f010164a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010164d:	89 c2                	mov    %eax,%edx
f010164f:	c1 ea 0c             	shr    $0xc,%edx
f0101652:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0101658:	0f 83 1f 02 00 00    	jae    f010187d <mem_init+0x4f9>
	memset(page2kva(pp0), 1, PGSIZE);
f010165e:	83 ec 04             	sub    $0x4,%esp
f0101661:	68 00 10 00 00       	push   $0x1000
f0101666:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101668:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010166d:	50                   	push   %eax
f010166e:	e8 d3 3d 00 00       	call   f0105446 <memset>
	page_free(pp0);
f0101673:	89 34 24             	mov    %esi,(%esp)
f0101676:	e8 52 f9 ff ff       	call   f0100fcd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010167b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101682:	e8 d4 f8 ff ff       	call   f0100f5b <page_alloc>
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	85 c0                	test   %eax,%eax
f010168c:	0f 84 fd 01 00 00    	je     f010188f <mem_init+0x50b>
	assert(pp && pp0 == pp);
f0101692:	39 c6                	cmp    %eax,%esi
f0101694:	0f 85 0e 02 00 00    	jne    f01018a8 <mem_init+0x524>
	return (pp - pages) << PGSHIFT;
f010169a:	89 f2                	mov    %esi,%edx
f010169c:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f01016a2:	c1 fa 03             	sar    $0x3,%edx
f01016a5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016a8:	89 d0                	mov    %edx,%eax
f01016aa:	c1 e8 0c             	shr    $0xc,%eax
f01016ad:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f01016b3:	0f 83 08 02 00 00    	jae    f01018c1 <mem_init+0x53d>
	return (void *)(pa + KERNBASE);
f01016b9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01016bf:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01016c5:	80 38 00             	cmpb   $0x0,(%eax)
f01016c8:	0f 85 05 02 00 00    	jne    f01018d3 <mem_init+0x54f>
f01016ce:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01016d1:	39 d0                	cmp    %edx,%eax
f01016d3:	75 f0                	jne    f01016c5 <mem_init+0x341>
	page_free_list = fl;
f01016d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016d8:	a3 40 d2 22 f0       	mov    %eax,0xf022d240
	page_free(pp0);
f01016dd:	83 ec 0c             	sub    $0xc,%esp
f01016e0:	56                   	push   %esi
f01016e1:	e8 e7 f8 ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f01016e6:	89 3c 24             	mov    %edi,(%esp)
f01016e9:	e8 df f8 ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f01016ee:	83 c4 04             	add    $0x4,%esp
f01016f1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016f4:	e8 d4 f8 ff ff       	call   f0100fcd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016f9:	a1 40 d2 22 f0       	mov    0xf022d240,%eax
f01016fe:	83 c4 10             	add    $0x10,%esp
f0101701:	e9 eb 01 00 00       	jmp    f01018f1 <mem_init+0x56d>
	assert((pp0 = page_alloc(0)));
f0101706:	68 a4 70 10 f0       	push   $0xf01070a4
f010170b:	68 af 6f 10 f0       	push   $0xf0106faf
f0101710:	68 25 03 00 00       	push   $0x325
f0101715:	68 89 6f 10 f0       	push   $0xf0106f89
f010171a:	e8 21 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010171f:	68 ba 70 10 f0       	push   $0xf01070ba
f0101724:	68 af 6f 10 f0       	push   $0xf0106faf
f0101729:	68 26 03 00 00       	push   $0x326
f010172e:	68 89 6f 10 f0       	push   $0xf0106f89
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101738:	68 d0 70 10 f0       	push   $0xf01070d0
f010173d:	68 af 6f 10 f0       	push   $0xf0106faf
f0101742:	68 27 03 00 00       	push   $0x327
f0101747:	68 89 6f 10 f0       	push   $0xf0106f89
f010174c:	e8 ef e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101751:	68 e6 70 10 f0       	push   $0xf01070e6
f0101756:	68 af 6f 10 f0       	push   $0xf0106faf
f010175b:	68 2a 03 00 00       	push   $0x32a
f0101760:	68 89 6f 10 f0       	push   $0xf0106f89
f0101765:	e8 d6 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010176a:	68 ac 67 10 f0       	push   $0xf01067ac
f010176f:	68 af 6f 10 f0       	push   $0xf0106faf
f0101774:	68 2b 03 00 00       	push   $0x32b
f0101779:	68 89 6f 10 f0       	push   $0xf0106f89
f010177e:	e8 bd e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101783:	68 f8 70 10 f0       	push   $0xf01070f8
f0101788:	68 af 6f 10 f0       	push   $0xf0106faf
f010178d:	68 2c 03 00 00       	push   $0x32c
f0101792:	68 89 6f 10 f0       	push   $0xf0106f89
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010179c:	68 15 71 10 f0       	push   $0xf0107115
f01017a1:	68 af 6f 10 f0       	push   $0xf0106faf
f01017a6:	68 2d 03 00 00       	push   $0x32d
f01017ab:	68 89 6f 10 f0       	push   $0xf0106f89
f01017b0:	e8 8b e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017b5:	68 32 71 10 f0       	push   $0xf0107132
f01017ba:	68 af 6f 10 f0       	push   $0xf0106faf
f01017bf:	68 2e 03 00 00       	push   $0x32e
f01017c4:	68 89 6f 10 f0       	push   $0xf0106f89
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017ce:	68 4f 71 10 f0       	push   $0xf010714f
f01017d3:	68 af 6f 10 f0       	push   $0xf0106faf
f01017d8:	68 35 03 00 00       	push   $0x335
f01017dd:	68 89 6f 10 f0       	push   $0xf0106f89
f01017e2:	e8 59 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017e7:	68 a4 70 10 f0       	push   $0xf01070a4
f01017ec:	68 af 6f 10 f0       	push   $0xf0106faf
f01017f1:	68 3c 03 00 00       	push   $0x33c
f01017f6:	68 89 6f 10 f0       	push   $0xf0106f89
f01017fb:	e8 40 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101800:	68 ba 70 10 f0       	push   $0xf01070ba
f0101805:	68 af 6f 10 f0       	push   $0xf0106faf
f010180a:	68 3d 03 00 00       	push   $0x33d
f010180f:	68 89 6f 10 f0       	push   $0xf0106f89
f0101814:	e8 27 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101819:	68 d0 70 10 f0       	push   $0xf01070d0
f010181e:	68 af 6f 10 f0       	push   $0xf0106faf
f0101823:	68 3e 03 00 00       	push   $0x33e
f0101828:	68 89 6f 10 f0       	push   $0xf0106f89
f010182d:	e8 0e e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101832:	68 e6 70 10 f0       	push   $0xf01070e6
f0101837:	68 af 6f 10 f0       	push   $0xf0106faf
f010183c:	68 40 03 00 00       	push   $0x340
f0101841:	68 89 6f 10 f0       	push   $0xf0106f89
f0101846:	e8 f5 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010184b:	68 ac 67 10 f0       	push   $0xf01067ac
f0101850:	68 af 6f 10 f0       	push   $0xf0106faf
f0101855:	68 41 03 00 00       	push   $0x341
f010185a:	68 89 6f 10 f0       	push   $0xf0106f89
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101864:	68 4f 71 10 f0       	push   $0xf010714f
f0101869:	68 af 6f 10 f0       	push   $0xf0106faf
f010186e:	68 42 03 00 00       	push   $0x342
f0101873:	68 89 6f 10 f0       	push   $0xf0106f89
f0101878:	e8 c3 e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010187d:	50                   	push   %eax
f010187e:	68 c4 60 10 f0       	push   $0xf01060c4
f0101883:	6a 58                	push   $0x58
f0101885:	68 95 6f 10 f0       	push   $0xf0106f95
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010188f:	68 5e 71 10 f0       	push   $0xf010715e
f0101894:	68 af 6f 10 f0       	push   $0xf0106faf
f0101899:	68 4a 03 00 00       	push   $0x34a
f010189e:	68 89 6f 10 f0       	push   $0xf0106f89
f01018a3:	e8 98 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018a8:	68 7c 71 10 f0       	push   $0xf010717c
f01018ad:	68 af 6f 10 f0       	push   $0xf0106faf
f01018b2:	68 4b 03 00 00       	push   $0x34b
f01018b7:	68 89 6f 10 f0       	push   $0xf0106f89
f01018bc:	e8 7f e7 ff ff       	call   f0100040 <_panic>
f01018c1:	52                   	push   %edx
f01018c2:	68 c4 60 10 f0       	push   $0xf01060c4
f01018c7:	6a 58                	push   $0x58
f01018c9:	68 95 6f 10 f0       	push   $0xf0106f95
f01018ce:	e8 6d e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018d3:	68 8c 71 10 f0       	push   $0xf010718c
f01018d8:	68 af 6f 10 f0       	push   $0xf0106faf
f01018dd:	68 4e 03 00 00       	push   $0x34e
f01018e2:	68 89 6f 10 f0       	push   $0xf0106f89
f01018e7:	e8 54 e7 ff ff       	call   f0100040 <_panic>
		--nfree;
f01018ec:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018ef:	8b 00                	mov    (%eax),%eax
f01018f1:	85 c0                	test   %eax,%eax
f01018f3:	75 f7                	jne    f01018ec <mem_init+0x568>
	assert(nfree == 0);
f01018f5:	85 db                	test   %ebx,%ebx
f01018f7:	0f 85 77 09 00 00    	jne    f0102274 <mem_init+0xef0>
	cprintf("check_page_alloc() succeeded!\n");
f01018fd:	83 ec 0c             	sub    $0xc,%esp
f0101900:	68 cc 67 10 f0       	push   $0xf01067cc
f0101905:	e8 c7 20 00 00       	call   f01039d1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010190a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101911:	e8 45 f6 ff ff       	call   f0100f5b <page_alloc>
f0101916:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101919:	83 c4 10             	add    $0x10,%esp
f010191c:	85 c0                	test   %eax,%eax
f010191e:	0f 84 69 09 00 00    	je     f010228d <mem_init+0xf09>
	assert((pp1 = page_alloc(0)));
f0101924:	83 ec 0c             	sub    $0xc,%esp
f0101927:	6a 00                	push   $0x0
f0101929:	e8 2d f6 ff ff       	call   f0100f5b <page_alloc>
f010192e:	89 c3                	mov    %eax,%ebx
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	0f 84 6b 09 00 00    	je     f01022a6 <mem_init+0xf22>
	assert((pp2 = page_alloc(0)));
f010193b:	83 ec 0c             	sub    $0xc,%esp
f010193e:	6a 00                	push   $0x0
f0101940:	e8 16 f6 ff ff       	call   f0100f5b <page_alloc>
f0101945:	89 c6                	mov    %eax,%esi
f0101947:	83 c4 10             	add    $0x10,%esp
f010194a:	85 c0                	test   %eax,%eax
f010194c:	0f 84 6d 09 00 00    	je     f01022bf <mem_init+0xf3b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101952:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101955:	0f 84 7d 09 00 00    	je     f01022d8 <mem_init+0xf54>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010195b:	39 c3                	cmp    %eax,%ebx
f010195d:	0f 84 8e 09 00 00    	je     f01022f1 <mem_init+0xf6d>
f0101963:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101966:	0f 84 85 09 00 00    	je     f01022f1 <mem_init+0xf6d>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010196c:	a1 40 d2 22 f0       	mov    0xf022d240,%eax
f0101971:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101974:	c7 05 40 d2 22 f0 00 	movl   $0x0,0xf022d240
f010197b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010197e:	83 ec 0c             	sub    $0xc,%esp
f0101981:	6a 00                	push   $0x0
f0101983:	e8 d3 f5 ff ff       	call   f0100f5b <page_alloc>
f0101988:	83 c4 10             	add    $0x10,%esp
f010198b:	85 c0                	test   %eax,%eax
f010198d:	0f 85 77 09 00 00    	jne    f010230a <mem_init+0xf86>
	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101993:	83 ec 04             	sub    $0x4,%esp
f0101996:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101999:	50                   	push   %eax
f010199a:	6a 00                	push   $0x0
f010199c:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01019a2:	e8 ea f7 ff ff       	call   f0101191 <page_lookup>
f01019a7:	83 c4 10             	add    $0x10,%esp
f01019aa:	85 c0                	test   %eax,%eax
f01019ac:	0f 85 71 09 00 00    	jne    f0102323 <mem_init+0xf9f>

	// there is no free memory, so we can't allocate a page table

	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019b2:	6a 02                	push   $0x2
f01019b4:	6a 00                	push   $0x0
f01019b6:	53                   	push   %ebx
f01019b7:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01019bd:	e8 be f8 ff ff       	call   f0101280 <page_insert>
f01019c2:	83 c4 10             	add    $0x10,%esp
f01019c5:	85 c0                	test   %eax,%eax
f01019c7:	0f 89 6f 09 00 00    	jns    f010233c <mem_init+0xfb8>
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019cd:	83 ec 0c             	sub    $0xc,%esp
f01019d0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019d3:	e8 f5 f5 ff ff       	call   f0100fcd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019d8:	6a 02                	push   $0x2
f01019da:	6a 00                	push   $0x0
f01019dc:	53                   	push   %ebx
f01019dd:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01019e3:	e8 98 f8 ff ff       	call   f0101280 <page_insert>
f01019e8:	83 c4 20             	add    $0x20,%esp
f01019eb:	85 c0                	test   %eax,%eax
f01019ed:	0f 85 62 09 00 00    	jne    f0102355 <mem_init+0xfd1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019f3:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
	return (pp - pages) << PGSHIFT;
f01019f9:	8b 0d 90 de 22 f0    	mov    0xf022de90,%ecx
f01019ff:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101a02:	8b 17                	mov    (%edi),%edx
f0101a04:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a0d:	29 c8                	sub    %ecx,%eax
f0101a0f:	c1 f8 03             	sar    $0x3,%eax
f0101a12:	c1 e0 0c             	shl    $0xc,%eax
f0101a15:	39 c2                	cmp    %eax,%edx
f0101a17:	0f 85 51 09 00 00    	jne    f010236e <mem_init+0xfea>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a22:	89 f8                	mov    %edi,%eax
f0101a24:	e8 91 f0 ff ff       	call   f0100aba <check_va2pa>
f0101a29:	89 da                	mov    %ebx,%edx
f0101a2b:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101a2e:	c1 fa 03             	sar    $0x3,%edx
f0101a31:	c1 e2 0c             	shl    $0xc,%edx
f0101a34:	39 d0                	cmp    %edx,%eax
f0101a36:	0f 85 4b 09 00 00    	jne    f0102387 <mem_init+0x1003>
	assert(pp1->pp_ref == 1);
f0101a3c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a41:	0f 85 59 09 00 00    	jne    f01023a0 <mem_init+0x101c>
	assert(pp0->pp_ref == 1);
f0101a47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a4a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a4f:	0f 85 64 09 00 00    	jne    f01023b9 <mem_init+0x1035>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a55:	6a 02                	push   $0x2
f0101a57:	68 00 10 00 00       	push   $0x1000
f0101a5c:	56                   	push   %esi
f0101a5d:	57                   	push   %edi
f0101a5e:	e8 1d f8 ff ff       	call   f0101280 <page_insert>
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	0f 85 64 09 00 00    	jne    f01023d2 <mem_init+0x104e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a73:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101a78:	e8 3d f0 ff ff       	call   f0100aba <check_va2pa>
f0101a7d:	89 f2                	mov    %esi,%edx
f0101a7f:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f0101a85:	c1 fa 03             	sar    $0x3,%edx
f0101a88:	c1 e2 0c             	shl    $0xc,%edx
f0101a8b:	39 d0                	cmp    %edx,%eax
f0101a8d:	0f 85 58 09 00 00    	jne    f01023eb <mem_init+0x1067>
	assert(pp2->pp_ref == 1);
f0101a93:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a98:	0f 85 66 09 00 00    	jne    f0102404 <mem_init+0x1080>

	// should be no free memory
	assert(!page_alloc(0));
f0101a9e:	83 ec 0c             	sub    $0xc,%esp
f0101aa1:	6a 00                	push   $0x0
f0101aa3:	e8 b3 f4 ff ff       	call   f0100f5b <page_alloc>
f0101aa8:	83 c4 10             	add    $0x10,%esp
f0101aab:	85 c0                	test   %eax,%eax
f0101aad:	0f 85 6a 09 00 00    	jne    f010241d <mem_init+0x1099>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab3:	6a 02                	push   $0x2
f0101ab5:	68 00 10 00 00       	push   $0x1000
f0101aba:	56                   	push   %esi
f0101abb:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101ac1:	e8 ba f7 ff ff       	call   f0101280 <page_insert>
f0101ac6:	83 c4 10             	add    $0x10,%esp
f0101ac9:	85 c0                	test   %eax,%eax
f0101acb:	0f 85 65 09 00 00    	jne    f0102436 <mem_init+0x10b2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ad1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ad6:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101adb:	e8 da ef ff ff       	call   f0100aba <check_va2pa>
f0101ae0:	89 f2                	mov    %esi,%edx
f0101ae2:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f0101ae8:	c1 fa 03             	sar    $0x3,%edx
f0101aeb:	c1 e2 0c             	shl    $0xc,%edx
f0101aee:	39 d0                	cmp    %edx,%eax
f0101af0:	0f 85 59 09 00 00    	jne    f010244f <mem_init+0x10cb>
	assert(pp2->pp_ref == 1);
f0101af6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101afb:	0f 85 67 09 00 00    	jne    f0102468 <mem_init+0x10e4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b01:	83 ec 0c             	sub    $0xc,%esp
f0101b04:	6a 00                	push   $0x0
f0101b06:	e8 50 f4 ff ff       	call   f0100f5b <page_alloc>
f0101b0b:	83 c4 10             	add    $0x10,%esp
f0101b0e:	85 c0                	test   %eax,%eax
f0101b10:	0f 85 6b 09 00 00    	jne    f0102481 <mem_init+0x10fd>
	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b16:	8b 15 8c de 22 f0    	mov    0xf022de8c,%edx
f0101b1c:	8b 02                	mov    (%edx),%eax
f0101b1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101b23:	89 c1                	mov    %eax,%ecx
f0101b25:	c1 e9 0c             	shr    $0xc,%ecx
f0101b28:	3b 0d 88 de 22 f0    	cmp    0xf022de88,%ecx
f0101b2e:	0f 83 66 09 00 00    	jae    f010249a <mem_init+0x1116>
	return (void *)(pa + KERNBASE);
f0101b34:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b3c:	83 ec 04             	sub    $0x4,%esp
f0101b3f:	6a 00                	push   $0x0
f0101b41:	68 00 10 00 00       	push   $0x1000
f0101b46:	52                   	push   %edx
f0101b47:	e8 e5 f4 ff ff       	call   f0101031 <pgdir_walk>
f0101b4c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b4f:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b52:	83 c4 10             	add    $0x10,%esp
f0101b55:	39 d0                	cmp    %edx,%eax
f0101b57:	0f 85 52 09 00 00    	jne    f01024af <mem_init+0x112b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b5d:	6a 06                	push   $0x6
f0101b5f:	68 00 10 00 00       	push   $0x1000
f0101b64:	56                   	push   %esi
f0101b65:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101b6b:	e8 10 f7 ff ff       	call   f0101280 <page_insert>
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	0f 85 4d 09 00 00    	jne    f01024c8 <mem_init+0x1144>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b7b:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
f0101b81:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b86:	89 f8                	mov    %edi,%eax
f0101b88:	e8 2d ef ff ff       	call   f0100aba <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b8d:	89 f2                	mov    %esi,%edx
f0101b8f:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f0101b95:	c1 fa 03             	sar    $0x3,%edx
f0101b98:	c1 e2 0c             	shl    $0xc,%edx
f0101b9b:	39 d0                	cmp    %edx,%eax
f0101b9d:	0f 85 3e 09 00 00    	jne    f01024e1 <mem_init+0x115d>
	assert(pp2->pp_ref == 1);
f0101ba3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba8:	0f 85 4c 09 00 00    	jne    f01024fa <mem_init+0x1176>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bae:	83 ec 04             	sub    $0x4,%esp
f0101bb1:	6a 00                	push   $0x0
f0101bb3:	68 00 10 00 00       	push   $0x1000
f0101bb8:	57                   	push   %edi
f0101bb9:	e8 73 f4 ff ff       	call   f0101031 <pgdir_walk>
f0101bbe:	83 c4 10             	add    $0x10,%esp
f0101bc1:	f6 00 04             	testb  $0x4,(%eax)
f0101bc4:	0f 84 49 09 00 00    	je     f0102513 <mem_init+0x118f>
	assert(kern_pgdir[0] & PTE_U);
f0101bca:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101bcf:	f6 00 04             	testb  $0x4,(%eax)
f0101bd2:	0f 84 54 09 00 00    	je     f010252c <mem_init+0x11a8>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bd8:	6a 02                	push   $0x2
f0101bda:	68 00 10 00 00       	push   $0x1000
f0101bdf:	56                   	push   %esi
f0101be0:	50                   	push   %eax
f0101be1:	e8 9a f6 ff ff       	call   f0101280 <page_insert>
f0101be6:	83 c4 10             	add    $0x10,%esp
f0101be9:	85 c0                	test   %eax,%eax
f0101beb:	0f 85 54 09 00 00    	jne    f0102545 <mem_init+0x11c1>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bf1:	83 ec 04             	sub    $0x4,%esp
f0101bf4:	6a 00                	push   $0x0
f0101bf6:	68 00 10 00 00       	push   $0x1000
f0101bfb:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101c01:	e8 2b f4 ff ff       	call   f0101031 <pgdir_walk>
f0101c06:	83 c4 10             	add    $0x10,%esp
f0101c09:	f6 00 02             	testb  $0x2,(%eax)
f0101c0c:	0f 84 4c 09 00 00    	je     f010255e <mem_init+0x11da>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c12:	83 ec 04             	sub    $0x4,%esp
f0101c15:	6a 00                	push   $0x0
f0101c17:	68 00 10 00 00       	push   $0x1000
f0101c1c:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101c22:	e8 0a f4 ff ff       	call   f0101031 <pgdir_walk>
f0101c27:	83 c4 10             	add    $0x10,%esp
f0101c2a:	f6 00 04             	testb  $0x4,(%eax)
f0101c2d:	0f 85 44 09 00 00    	jne    f0102577 <mem_init+0x11f3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c33:	6a 02                	push   $0x2
f0101c35:	68 00 00 40 00       	push   $0x400000
f0101c3a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c3d:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101c43:	e8 38 f6 ff ff       	call   f0101280 <page_insert>
f0101c48:	83 c4 10             	add    $0x10,%esp
f0101c4b:	85 c0                	test   %eax,%eax
f0101c4d:	0f 89 3d 09 00 00    	jns    f0102590 <mem_init+0x120c>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c53:	6a 02                	push   $0x2
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	53                   	push   %ebx
f0101c5b:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101c61:	e8 1a f6 ff ff       	call   f0101280 <page_insert>
f0101c66:	83 c4 10             	add    $0x10,%esp
f0101c69:	85 c0                	test   %eax,%eax
f0101c6b:	0f 85 38 09 00 00    	jne    f01025a9 <mem_init+0x1225>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c71:	83 ec 04             	sub    $0x4,%esp
f0101c74:	6a 00                	push   $0x0
f0101c76:	68 00 10 00 00       	push   $0x1000
f0101c7b:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101c81:	e8 ab f3 ff ff       	call   f0101031 <pgdir_walk>
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	f6 00 04             	testb  $0x4,(%eax)
f0101c8c:	0f 85 30 09 00 00    	jne    f01025c2 <mem_init+0x123e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c92:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
f0101c98:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c9d:	89 f8                	mov    %edi,%eax
f0101c9f:	e8 16 ee ff ff       	call   f0100aba <check_va2pa>
f0101ca4:	89 c1                	mov    %eax,%ecx
f0101ca6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ca9:	89 d8                	mov    %ebx,%eax
f0101cab:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0101cb1:	c1 f8 03             	sar    $0x3,%eax
f0101cb4:	c1 e0 0c             	shl    $0xc,%eax
f0101cb7:	39 c1                	cmp    %eax,%ecx
f0101cb9:	0f 85 1c 09 00 00    	jne    f01025db <mem_init+0x1257>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cbf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc4:	89 f8                	mov    %edi,%eax
f0101cc6:	e8 ef ed ff ff       	call   f0100aba <check_va2pa>
f0101ccb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101cce:	0f 85 20 09 00 00    	jne    f01025f4 <mem_init+0x1270>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cd4:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cd9:	0f 85 2e 09 00 00    	jne    f010260d <mem_init+0x1289>
	assert(pp2->pp_ref == 0);
f0101cdf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ce4:	0f 85 3c 09 00 00    	jne    f0102626 <mem_init+0x12a2>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cea:	83 ec 0c             	sub    $0xc,%esp
f0101ced:	6a 00                	push   $0x0
f0101cef:	e8 67 f2 ff ff       	call   f0100f5b <page_alloc>
f0101cf4:	83 c4 10             	add    $0x10,%esp
f0101cf7:	85 c0                	test   %eax,%eax
f0101cf9:	0f 84 40 09 00 00    	je     f010263f <mem_init+0x12bb>
f0101cff:	39 c6                	cmp    %eax,%esi
f0101d01:	0f 85 38 09 00 00    	jne    f010263f <mem_init+0x12bb>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d07:	83 ec 08             	sub    $0x8,%esp
f0101d0a:	6a 00                	push   $0x0
f0101d0c:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101d12:	e8 15 f5 ff ff       	call   f010122c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d17:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
f0101d1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d22:	89 f8                	mov    %edi,%eax
f0101d24:	e8 91 ed ff ff       	call   f0100aba <check_va2pa>
f0101d29:	83 c4 10             	add    $0x10,%esp
f0101d2c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d2f:	0f 85 23 09 00 00    	jne    f0102658 <mem_init+0x12d4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d35:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3a:	89 f8                	mov    %edi,%eax
f0101d3c:	e8 79 ed ff ff       	call   f0100aba <check_va2pa>
f0101d41:	89 da                	mov    %ebx,%edx
f0101d43:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f0101d49:	c1 fa 03             	sar    $0x3,%edx
f0101d4c:	c1 e2 0c             	shl    $0xc,%edx
f0101d4f:	39 d0                	cmp    %edx,%eax
f0101d51:	0f 85 1a 09 00 00    	jne    f0102671 <mem_init+0x12ed>
	assert(pp1->pp_ref == 1);
f0101d57:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d5c:	0f 85 28 09 00 00    	jne    f010268a <mem_init+0x1306>
	assert(pp2->pp_ref == 0);
f0101d62:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d67:	0f 85 36 09 00 00    	jne    f01026a3 <mem_init+0x131f>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d6d:	6a 00                	push   $0x0
f0101d6f:	68 00 10 00 00       	push   $0x1000
f0101d74:	53                   	push   %ebx
f0101d75:	57                   	push   %edi
f0101d76:	e8 05 f5 ff ff       	call   f0101280 <page_insert>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	85 c0                	test   %eax,%eax
f0101d80:	0f 85 36 09 00 00    	jne    f01026bc <mem_init+0x1338>
	assert(pp1->pp_ref);
f0101d86:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d8b:	0f 84 44 09 00 00    	je     f01026d5 <mem_init+0x1351>
	assert(pp1->pp_link == NULL);
f0101d91:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d94:	0f 85 54 09 00 00    	jne    f01026ee <mem_init+0x136a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d9a:	83 ec 08             	sub    $0x8,%esp
f0101d9d:	68 00 10 00 00       	push   $0x1000
f0101da2:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101da8:	e8 7f f4 ff ff       	call   f010122c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dad:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
f0101db3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101db8:	89 f8                	mov    %edi,%eax
f0101dba:	e8 fb ec ff ff       	call   f0100aba <check_va2pa>
f0101dbf:	83 c4 10             	add    $0x10,%esp
f0101dc2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dc5:	0f 85 3c 09 00 00    	jne    f0102707 <mem_init+0x1383>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101dcb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd0:	89 f8                	mov    %edi,%eax
f0101dd2:	e8 e3 ec ff ff       	call   f0100aba <check_va2pa>
f0101dd7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dda:	0f 85 40 09 00 00    	jne    f0102720 <mem_init+0x139c>
	assert(pp1->pp_ref == 0);
f0101de0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101de5:	0f 85 4e 09 00 00    	jne    f0102739 <mem_init+0x13b5>
	assert(pp2->pp_ref == 0);
f0101deb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101df0:	0f 85 5c 09 00 00    	jne    f0102752 <mem_init+0x13ce>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101df6:	83 ec 0c             	sub    $0xc,%esp
f0101df9:	6a 00                	push   $0x0
f0101dfb:	e8 5b f1 ff ff       	call   f0100f5b <page_alloc>
f0101e00:	83 c4 10             	add    $0x10,%esp
f0101e03:	39 c3                	cmp    %eax,%ebx
f0101e05:	0f 85 60 09 00 00    	jne    f010276b <mem_init+0x13e7>
f0101e0b:	85 c0                	test   %eax,%eax
f0101e0d:	0f 84 58 09 00 00    	je     f010276b <mem_init+0x13e7>

	// should be no free memory
	assert(!page_alloc(0));
f0101e13:	83 ec 0c             	sub    $0xc,%esp
f0101e16:	6a 00                	push   $0x0
f0101e18:	e8 3e f1 ff ff       	call   f0100f5b <page_alloc>
f0101e1d:	83 c4 10             	add    $0x10,%esp
f0101e20:	85 c0                	test   %eax,%eax
f0101e22:	0f 85 5c 09 00 00    	jne    f0102784 <mem_init+0x1400>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e28:	8b 0d 8c de 22 f0    	mov    0xf022de8c,%ecx
f0101e2e:	8b 11                	mov    (%ecx),%edx
f0101e30:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e39:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0101e3f:	c1 f8 03             	sar    $0x3,%eax
f0101e42:	c1 e0 0c             	shl    $0xc,%eax
f0101e45:	39 c2                	cmp    %eax,%edx
f0101e47:	0f 85 50 09 00 00    	jne    f010279d <mem_init+0x1419>
	kern_pgdir[0] = 0;
f0101e4d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e56:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e5b:	0f 85 55 09 00 00    	jne    f01027b6 <mem_init+0x1432>
	pp0->pp_ref = 0;
f0101e61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e64:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e6a:	83 ec 0c             	sub    $0xc,%esp
f0101e6d:	50                   	push   %eax
f0101e6e:	e8 5a f1 ff ff       	call   f0100fcd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e73:	83 c4 0c             	add    $0xc,%esp
f0101e76:	6a 01                	push   $0x1
f0101e78:	68 00 10 40 00       	push   $0x401000
f0101e7d:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101e83:	e8 a9 f1 ff ff       	call   f0101031 <pgdir_walk>
f0101e88:	89 c7                	mov    %eax,%edi
f0101e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e8d:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101e92:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e95:	8b 40 04             	mov    0x4(%eax),%eax
f0101e98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e9d:	8b 0d 88 de 22 f0    	mov    0xf022de88,%ecx
f0101ea3:	89 c2                	mov    %eax,%edx
f0101ea5:	c1 ea 0c             	shr    $0xc,%edx
f0101ea8:	83 c4 10             	add    $0x10,%esp
f0101eab:	39 ca                	cmp    %ecx,%edx
f0101ead:	0f 83 1c 09 00 00    	jae    f01027cf <mem_init+0x144b>
	assert(ptep == ptep1 + PTX(va));
f0101eb3:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101eb8:	39 c7                	cmp    %eax,%edi
f0101eba:	0f 85 24 09 00 00    	jne    f01027e4 <mem_init+0x1460>
	kern_pgdir[PDX(va)] = 0;
f0101ec0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ec3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101eca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ecd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101ed3:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0101ed9:	c1 f8 03             	sar    $0x3,%eax
f0101edc:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101edf:	89 c2                	mov    %eax,%edx
f0101ee1:	c1 ea 0c             	shr    $0xc,%edx
f0101ee4:	39 d1                	cmp    %edx,%ecx
f0101ee6:	0f 86 11 09 00 00    	jbe    f01027fd <mem_init+0x1479>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101eec:	83 ec 04             	sub    $0x4,%esp
f0101eef:	68 00 10 00 00       	push   $0x1000
f0101ef4:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ef9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101efe:	50                   	push   %eax
f0101eff:	e8 42 35 00 00       	call   f0105446 <memset>
	page_free(pp0);
f0101f04:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f07:	89 3c 24             	mov    %edi,(%esp)
f0101f0a:	e8 be f0 ff ff       	call   f0100fcd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f0f:	83 c4 0c             	add    $0xc,%esp
f0101f12:	6a 01                	push   $0x1
f0101f14:	6a 00                	push   $0x0
f0101f16:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0101f1c:	e8 10 f1 ff ff       	call   f0101031 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f21:	89 fa                	mov    %edi,%edx
f0101f23:	2b 15 90 de 22 f0    	sub    0xf022de90,%edx
f0101f29:	c1 fa 03             	sar    $0x3,%edx
f0101f2c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f2f:	89 d0                	mov    %edx,%eax
f0101f31:	c1 e8 0c             	shr    $0xc,%eax
f0101f34:	83 c4 10             	add    $0x10,%esp
f0101f37:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f0101f3d:	0f 83 cc 08 00 00    	jae    f010280f <mem_init+0x148b>
	return (void *)(pa + KERNBASE);
f0101f43:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f4c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f52:	f6 00 01             	testb  $0x1,(%eax)
f0101f55:	0f 85 c6 08 00 00    	jne    f0102821 <mem_init+0x149d>
f0101f5b:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f5e:	39 d0                	cmp    %edx,%eax
f0101f60:	75 f0                	jne    f0101f52 <mem_init+0xbce>
	kern_pgdir[0] = 0;
f0101f62:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0101f67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f70:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f76:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f79:	89 0d 40 d2 22 f0    	mov    %ecx,0xf022d240

	// free the pages we took
	page_free(pp0);
f0101f7f:	83 ec 0c             	sub    $0xc,%esp
f0101f82:	50                   	push   %eax
f0101f83:	e8 45 f0 ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f0101f88:	89 1c 24             	mov    %ebx,(%esp)
f0101f8b:	e8 3d f0 ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f0101f90:	89 34 24             	mov    %esi,(%esp)
f0101f93:	e8 35 f0 ff ff       	call   f0100fcd <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f98:	83 c4 08             	add    $0x8,%esp
f0101f9b:	68 01 10 00 00       	push   $0x1001
f0101fa0:	6a 00                	push   $0x0
f0101fa2:	e8 7a f3 ff ff       	call   f0101321 <mmio_map_region>
f0101fa7:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101fa9:	83 c4 08             	add    $0x8,%esp
f0101fac:	68 00 10 00 00       	push   $0x1000
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	e8 69 f3 ff ff       	call   f0101321 <mmio_map_region>
f0101fb8:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0101fba:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0101fc0:	83 c4 10             	add    $0x10,%esp
f0101fc3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101fc9:	0f 86 6b 08 00 00    	jbe    f010283a <mem_init+0x14b6>
f0101fcf:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101fd4:	0f 87 60 08 00 00    	ja     f010283a <mem_init+0x14b6>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0101fda:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0101fe0:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101fe6:	0f 87 67 08 00 00    	ja     f0102853 <mem_init+0x14cf>
f0101fec:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101ff2:	0f 86 5b 08 00 00    	jbe    f0102853 <mem_init+0x14cf>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101ff8:	89 da                	mov    %ebx,%edx
f0101ffa:	09 f2                	or     %esi,%edx
f0101ffc:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102002:	0f 85 64 08 00 00    	jne    f010286c <mem_init+0x14e8>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102008:	39 c6                	cmp    %eax,%esi
f010200a:	0f 82 75 08 00 00    	jb     f0102885 <mem_init+0x1501>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102010:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
f0102016:	89 da                	mov    %ebx,%edx
f0102018:	89 f8                	mov    %edi,%eax
f010201a:	e8 9b ea ff ff       	call   f0100aba <check_va2pa>
f010201f:	85 c0                	test   %eax,%eax
f0102021:	0f 85 77 08 00 00    	jne    f010289e <mem_init+0x151a>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102027:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010202d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102030:	89 c2                	mov    %eax,%edx
f0102032:	89 f8                	mov    %edi,%eax
f0102034:	e8 81 ea ff ff       	call   f0100aba <check_va2pa>
f0102039:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010203e:	0f 85 73 08 00 00    	jne    f01028b7 <mem_init+0x1533>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102044:	89 f2                	mov    %esi,%edx
f0102046:	89 f8                	mov    %edi,%eax
f0102048:	e8 6d ea ff ff       	call   f0100aba <check_va2pa>
f010204d:	85 c0                	test   %eax,%eax
f010204f:	0f 85 7b 08 00 00    	jne    f01028d0 <mem_init+0x154c>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102055:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010205b:	89 f8                	mov    %edi,%eax
f010205d:	e8 58 ea ff ff       	call   f0100aba <check_va2pa>
f0102062:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102065:	0f 85 7e 08 00 00    	jne    f01028e9 <mem_init+0x1565>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010206b:	83 ec 04             	sub    $0x4,%esp
f010206e:	6a 00                	push   $0x0
f0102070:	53                   	push   %ebx
f0102071:	57                   	push   %edi
f0102072:	e8 ba ef ff ff       	call   f0101031 <pgdir_walk>
f0102077:	83 c4 10             	add    $0x10,%esp
f010207a:	f6 00 1a             	testb  $0x1a,(%eax)
f010207d:	0f 84 7f 08 00 00    	je     f0102902 <mem_init+0x157e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102083:	83 ec 04             	sub    $0x4,%esp
f0102086:	6a 00                	push   $0x0
f0102088:	53                   	push   %ebx
f0102089:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f010208f:	e8 9d ef ff ff       	call   f0101031 <pgdir_walk>
f0102094:	83 c4 10             	add    $0x10,%esp
f0102097:	f6 00 04             	testb  $0x4,(%eax)
f010209a:	0f 85 7b 08 00 00    	jne    f010291b <mem_init+0x1597>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01020a0:	83 ec 04             	sub    $0x4,%esp
f01020a3:	6a 00                	push   $0x0
f01020a5:	53                   	push   %ebx
f01020a6:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01020ac:	e8 80 ef ff ff       	call   f0101031 <pgdir_walk>
f01020b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01020b7:	83 c4 0c             	add    $0xc,%esp
f01020ba:	6a 00                	push   $0x0
f01020bc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020bf:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01020c5:	e8 67 ef ff ff       	call   f0101031 <pgdir_walk>
f01020ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01020d0:	83 c4 0c             	add    $0xc,%esp
f01020d3:	6a 00                	push   $0x0
f01020d5:	56                   	push   %esi
f01020d6:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f01020dc:	e8 50 ef ff ff       	call   f0101031 <pgdir_walk>
f01020e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01020e7:	c7 04 24 7f 72 10 f0 	movl   $0xf010727f,(%esp)
f01020ee:	e8 de 18 00 00       	call   f01039d1 <cprintf>
	size_t mm_size = npages * sizeof(struct PageInfo);
f01020f3:	a1 88 de 22 f0       	mov    0xf022de88,%eax
f01020f8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(mm_size, PGSIZE), PADDR(pages), PTE_P | PTE_U);
f01020ff:	a1 90 de 22 f0       	mov    0xf022de90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102104:	83 c4 10             	add    $0x10,%esp
f0102107:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010210c:	0f 86 22 08 00 00    	jbe    f0102934 <mem_init+0x15b0>
f0102112:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102118:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010211e:	83 ec 08             	sub    $0x8,%esp
f0102121:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102123:	05 00 00 00 10       	add    $0x10000000,%eax
f0102128:	50                   	push   %eax
f0102129:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010212e:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0102133:	e8 e2 ef ff ff       	call   f010111a <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(env_size, PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0102138:	a1 48 d2 22 f0       	mov    0xf022d248,%eax
	if ((uint32_t)kva < KERNBASE)
f010213d:	83 c4 10             	add    $0x10,%esp
f0102140:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102145:	0f 86 fe 07 00 00    	jbe    f0102949 <mem_init+0x15c5>
f010214b:	83 ec 08             	sub    $0x8,%esp
f010214e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102150:	05 00 00 00 10       	add    $0x10000000,%eax
f0102155:	50                   	push   %eax
f0102156:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010215b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102160:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0102165:	e8 b0 ef ff ff       	call   f010111a <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010216a:	83 c4 10             	add    $0x10,%esp
f010216d:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102172:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102177:	0f 86 e1 07 00 00    	jbe    f010295e <mem_init+0x15da>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), PTE_P | PTE_W);
f010217d:	83 ec 08             	sub    $0x8,%esp
f0102180:	6a 03                	push   $0x3
f0102182:	68 00 70 11 00       	push   $0x117000
f0102187:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010218c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102191:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f0102196:	e8 7f ef ff ff       	call   f010111a <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f010219b:	83 c4 08             	add    $0x8,%esp
f010219e:	6a 03                	push   $0x3
f01021a0:	6a 00                	push   $0x0
f01021a2:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01021a7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021ac:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f01021b1:	e8 64 ef ff ff       	call   f010111a <boot_map_region>
f01021b6:	c7 45 cc 00 f0 22 f0 	movl   $0xf022f000,-0x34(%ebp)
f01021bd:	bf 00 f0 26 f0       	mov    $0xf026f000,%edi
f01021c2:	83 c4 10             	add    $0x10,%esp
f01021c5:	bb 00 f0 22 f0       	mov    $0xf022f000,%ebx
f01021ca:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01021cf:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01021d5:	0f 86 98 07 00 00    	jbe    f0102973 <mem_init+0x15ef>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(kstackaddr_i), PTE_P | PTE_W);
f01021db:	83 ec 08             	sub    $0x8,%esp
f01021de:	6a 03                	push   $0x3
f01021e0:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01021e6:	50                   	push   %eax
f01021e7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021ec:	89 f2                	mov    %esi,%edx
f01021ee:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
f01021f3:	e8 22 ef ff ff       	call   f010111a <boot_map_region>
f01021f8:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01021fe:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++) {
f0102204:	83 c4 10             	add    $0x10,%esp
f0102207:	39 fb                	cmp    %edi,%ebx
f0102209:	75 c4                	jne    f01021cf <mem_init+0xe4b>
	pgdir = kern_pgdir;
f010220b:	8b 3d 8c de 22 f0    	mov    0xf022de8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102211:	a1 88 de 22 f0       	mov    0xf022de88,%eax
f0102216:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102219:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102220:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102225:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102228:	a1 90 de 22 f0       	mov    0xf022de90,%eax
f010222d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102230:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102233:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) {
f0102239:	bb 00 00 00 00       	mov    $0x0,%ebx
f010223e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102241:	0f 86 71 07 00 00    	jbe    f01029b8 <mem_init+0x1634>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102247:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010224d:	89 f8                	mov    %edi,%eax
f010224f:	e8 66 e8 ff ff       	call   f0100aba <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102254:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010225b:	0f 86 27 07 00 00    	jbe    f0102988 <mem_init+0x1604>
f0102261:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102264:	39 d0                	cmp    %edx,%eax
f0102266:	0f 85 33 07 00 00    	jne    f010299f <mem_init+0x161b>
	for (i = 0; i < n; i += PGSIZE) {
f010226c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102272:	eb ca                	jmp    f010223e <mem_init+0xeba>
	assert(nfree == 0);
f0102274:	68 96 71 10 f0       	push   $0xf0107196
f0102279:	68 af 6f 10 f0       	push   $0xf0106faf
f010227e:	68 5b 03 00 00       	push   $0x35b
f0102283:	68 89 6f 10 f0       	push   $0xf0106f89
f0102288:	e8 b3 dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010228d:	68 a4 70 10 f0       	push   $0xf01070a4
f0102292:	68 af 6f 10 f0       	push   $0xf0106faf
f0102297:	68 c2 03 00 00       	push   $0x3c2
f010229c:	68 89 6f 10 f0       	push   $0xf0106f89
f01022a1:	e8 9a dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01022a6:	68 ba 70 10 f0       	push   $0xf01070ba
f01022ab:	68 af 6f 10 f0       	push   $0xf0106faf
f01022b0:	68 c3 03 00 00       	push   $0x3c3
f01022b5:	68 89 6f 10 f0       	push   $0xf0106f89
f01022ba:	e8 81 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01022bf:	68 d0 70 10 f0       	push   $0xf01070d0
f01022c4:	68 af 6f 10 f0       	push   $0xf0106faf
f01022c9:	68 c4 03 00 00       	push   $0x3c4
f01022ce:	68 89 6f 10 f0       	push   $0xf0106f89
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01022d8:	68 e6 70 10 f0       	push   $0xf01070e6
f01022dd:	68 af 6f 10 f0       	push   $0xf0106faf
f01022e2:	68 c7 03 00 00       	push   $0x3c7
f01022e7:	68 89 6f 10 f0       	push   $0xf0106f89
f01022ec:	e8 4f dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022f1:	68 ac 67 10 f0       	push   $0xf01067ac
f01022f6:	68 af 6f 10 f0       	push   $0xf0106faf
f01022fb:	68 c8 03 00 00       	push   $0x3c8
f0102300:	68 89 6f 10 f0       	push   $0xf0106f89
f0102305:	e8 36 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010230a:	68 4f 71 10 f0       	push   $0xf010714f
f010230f:	68 af 6f 10 f0       	push   $0xf0106faf
f0102314:	68 cf 03 00 00       	push   $0x3cf
f0102319:	68 89 6f 10 f0       	push   $0xf0106f89
f010231e:	e8 1d dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102323:	68 ec 67 10 f0       	push   $0xf01067ec
f0102328:	68 af 6f 10 f0       	push   $0xf0106faf
f010232d:	68 d1 03 00 00       	push   $0x3d1
f0102332:	68 89 6f 10 f0       	push   $0xf0106f89
f0102337:	e8 04 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010233c:	68 24 68 10 f0       	push   $0xf0106824
f0102341:	68 af 6f 10 f0       	push   $0xf0106faf
f0102346:	68 d5 03 00 00       	push   $0x3d5
f010234b:	68 89 6f 10 f0       	push   $0xf0106f89
f0102350:	e8 eb dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102355:	68 54 68 10 f0       	push   $0xf0106854
f010235a:	68 af 6f 10 f0       	push   $0xf0106faf
f010235f:	68 d8 03 00 00       	push   $0x3d8
f0102364:	68 89 6f 10 f0       	push   $0xf0106f89
f0102369:	e8 d2 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010236e:	68 84 68 10 f0       	push   $0xf0106884
f0102373:	68 af 6f 10 f0       	push   $0xf0106faf
f0102378:	68 d9 03 00 00       	push   $0x3d9
f010237d:	68 89 6f 10 f0       	push   $0xf0106f89
f0102382:	e8 b9 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102387:	68 ac 68 10 f0       	push   $0xf01068ac
f010238c:	68 af 6f 10 f0       	push   $0xf0106faf
f0102391:	68 da 03 00 00       	push   $0x3da
f0102396:	68 89 6f 10 f0       	push   $0xf0106f89
f010239b:	e8 a0 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023a0:	68 a1 71 10 f0       	push   $0xf01071a1
f01023a5:	68 af 6f 10 f0       	push   $0xf0106faf
f01023aa:	68 db 03 00 00       	push   $0x3db
f01023af:	68 89 6f 10 f0       	push   $0xf0106f89
f01023b4:	e8 87 dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01023b9:	68 b2 71 10 f0       	push   $0xf01071b2
f01023be:	68 af 6f 10 f0       	push   $0xf0106faf
f01023c3:	68 dc 03 00 00       	push   $0x3dc
f01023c8:	68 89 6f 10 f0       	push   $0xf0106f89
f01023cd:	e8 6e dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023d2:	68 dc 68 10 f0       	push   $0xf01068dc
f01023d7:	68 af 6f 10 f0       	push   $0xf0106faf
f01023dc:	68 df 03 00 00       	push   $0x3df
f01023e1:	68 89 6f 10 f0       	push   $0xf0106f89
f01023e6:	e8 55 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023eb:	68 18 69 10 f0       	push   $0xf0106918
f01023f0:	68 af 6f 10 f0       	push   $0xf0106faf
f01023f5:	68 e0 03 00 00       	push   $0x3e0
f01023fa:	68 89 6f 10 f0       	push   $0xf0106f89
f01023ff:	e8 3c dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102404:	68 c3 71 10 f0       	push   $0xf01071c3
f0102409:	68 af 6f 10 f0       	push   $0xf0106faf
f010240e:	68 e1 03 00 00       	push   $0x3e1
f0102413:	68 89 6f 10 f0       	push   $0xf0106f89
f0102418:	e8 23 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010241d:	68 4f 71 10 f0       	push   $0xf010714f
f0102422:	68 af 6f 10 f0       	push   $0xf0106faf
f0102427:	68 e4 03 00 00       	push   $0x3e4
f010242c:	68 89 6f 10 f0       	push   $0xf0106f89
f0102431:	e8 0a dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102436:	68 dc 68 10 f0       	push   $0xf01068dc
f010243b:	68 af 6f 10 f0       	push   $0xf0106faf
f0102440:	68 e7 03 00 00       	push   $0x3e7
f0102445:	68 89 6f 10 f0       	push   $0xf0106f89
f010244a:	e8 f1 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010244f:	68 18 69 10 f0       	push   $0xf0106918
f0102454:	68 af 6f 10 f0       	push   $0xf0106faf
f0102459:	68 e8 03 00 00       	push   $0x3e8
f010245e:	68 89 6f 10 f0       	push   $0xf0106f89
f0102463:	e8 d8 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102468:	68 c3 71 10 f0       	push   $0xf01071c3
f010246d:	68 af 6f 10 f0       	push   $0xf0106faf
f0102472:	68 e9 03 00 00       	push   $0x3e9
f0102477:	68 89 6f 10 f0       	push   $0xf0106f89
f010247c:	e8 bf db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102481:	68 4f 71 10 f0       	push   $0xf010714f
f0102486:	68 af 6f 10 f0       	push   $0xf0106faf
f010248b:	68 ed 03 00 00       	push   $0x3ed
f0102490:	68 89 6f 10 f0       	push   $0xf0106f89
f0102495:	e8 a6 db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010249a:	50                   	push   %eax
f010249b:	68 c4 60 10 f0       	push   $0xf01060c4
f01024a0:	68 ef 03 00 00       	push   $0x3ef
f01024a5:	68 89 6f 10 f0       	push   $0xf0106f89
f01024aa:	e8 91 db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024af:	68 48 69 10 f0       	push   $0xf0106948
f01024b4:	68 af 6f 10 f0       	push   $0xf0106faf
f01024b9:	68 f0 03 00 00       	push   $0x3f0
f01024be:	68 89 6f 10 f0       	push   $0xf0106f89
f01024c3:	e8 78 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024c8:	68 88 69 10 f0       	push   $0xf0106988
f01024cd:	68 af 6f 10 f0       	push   $0xf0106faf
f01024d2:	68 f3 03 00 00       	push   $0x3f3
f01024d7:	68 89 6f 10 f0       	push   $0xf0106f89
f01024dc:	e8 5f db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e1:	68 18 69 10 f0       	push   $0xf0106918
f01024e6:	68 af 6f 10 f0       	push   $0xf0106faf
f01024eb:	68 f4 03 00 00       	push   $0x3f4
f01024f0:	68 89 6f 10 f0       	push   $0xf0106f89
f01024f5:	e8 46 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024fa:	68 c3 71 10 f0       	push   $0xf01071c3
f01024ff:	68 af 6f 10 f0       	push   $0xf0106faf
f0102504:	68 f5 03 00 00       	push   $0x3f5
f0102509:	68 89 6f 10 f0       	push   $0xf0106f89
f010250e:	e8 2d db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102513:	68 c8 69 10 f0       	push   $0xf01069c8
f0102518:	68 af 6f 10 f0       	push   $0xf0106faf
f010251d:	68 f6 03 00 00       	push   $0x3f6
f0102522:	68 89 6f 10 f0       	push   $0xf0106f89
f0102527:	e8 14 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010252c:	68 d4 71 10 f0       	push   $0xf01071d4
f0102531:	68 af 6f 10 f0       	push   $0xf0106faf
f0102536:	68 f7 03 00 00       	push   $0x3f7
f010253b:	68 89 6f 10 f0       	push   $0xf0106f89
f0102540:	e8 fb da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102545:	68 dc 68 10 f0       	push   $0xf01068dc
f010254a:	68 af 6f 10 f0       	push   $0xf0106faf
f010254f:	68 fa 03 00 00       	push   $0x3fa
f0102554:	68 89 6f 10 f0       	push   $0xf0106f89
f0102559:	e8 e2 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010255e:	68 fc 69 10 f0       	push   $0xf01069fc
f0102563:	68 af 6f 10 f0       	push   $0xf0106faf
f0102568:	68 fb 03 00 00       	push   $0x3fb
f010256d:	68 89 6f 10 f0       	push   $0xf0106f89
f0102572:	e8 c9 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102577:	68 30 6a 10 f0       	push   $0xf0106a30
f010257c:	68 af 6f 10 f0       	push   $0xf0106faf
f0102581:	68 fc 03 00 00       	push   $0x3fc
f0102586:	68 89 6f 10 f0       	push   $0xf0106f89
f010258b:	e8 b0 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102590:	68 68 6a 10 f0       	push   $0xf0106a68
f0102595:	68 af 6f 10 f0       	push   $0xf0106faf
f010259a:	68 ff 03 00 00       	push   $0x3ff
f010259f:	68 89 6f 10 f0       	push   $0xf0106f89
f01025a4:	e8 97 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025a9:	68 a0 6a 10 f0       	push   $0xf0106aa0
f01025ae:	68 af 6f 10 f0       	push   $0xf0106faf
f01025b3:	68 02 04 00 00       	push   $0x402
f01025b8:	68 89 6f 10 f0       	push   $0xf0106f89
f01025bd:	e8 7e da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025c2:	68 30 6a 10 f0       	push   $0xf0106a30
f01025c7:	68 af 6f 10 f0       	push   $0xf0106faf
f01025cc:	68 03 04 00 00       	push   $0x403
f01025d1:	68 89 6f 10 f0       	push   $0xf0106f89
f01025d6:	e8 65 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025db:	68 dc 6a 10 f0       	push   $0xf0106adc
f01025e0:	68 af 6f 10 f0       	push   $0xf0106faf
f01025e5:	68 06 04 00 00       	push   $0x406
f01025ea:	68 89 6f 10 f0       	push   $0xf0106f89
f01025ef:	e8 4c da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025f4:	68 08 6b 10 f0       	push   $0xf0106b08
f01025f9:	68 af 6f 10 f0       	push   $0xf0106faf
f01025fe:	68 07 04 00 00       	push   $0x407
f0102603:	68 89 6f 10 f0       	push   $0xf0106f89
f0102608:	e8 33 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f010260d:	68 ea 71 10 f0       	push   $0xf01071ea
f0102612:	68 af 6f 10 f0       	push   $0xf0106faf
f0102617:	68 09 04 00 00       	push   $0x409
f010261c:	68 89 6f 10 f0       	push   $0xf0106f89
f0102621:	e8 1a da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102626:	68 fb 71 10 f0       	push   $0xf01071fb
f010262b:	68 af 6f 10 f0       	push   $0xf0106faf
f0102630:	68 0a 04 00 00       	push   $0x40a
f0102635:	68 89 6f 10 f0       	push   $0xf0106f89
f010263a:	e8 01 da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010263f:	68 38 6b 10 f0       	push   $0xf0106b38
f0102644:	68 af 6f 10 f0       	push   $0xf0106faf
f0102649:	68 0d 04 00 00       	push   $0x40d
f010264e:	68 89 6f 10 f0       	push   $0xf0106f89
f0102653:	e8 e8 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102658:	68 5c 6b 10 f0       	push   $0xf0106b5c
f010265d:	68 af 6f 10 f0       	push   $0xf0106faf
f0102662:	68 11 04 00 00       	push   $0x411
f0102667:	68 89 6f 10 f0       	push   $0xf0106f89
f010266c:	e8 cf d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102671:	68 08 6b 10 f0       	push   $0xf0106b08
f0102676:	68 af 6f 10 f0       	push   $0xf0106faf
f010267b:	68 12 04 00 00       	push   $0x412
f0102680:	68 89 6f 10 f0       	push   $0xf0106f89
f0102685:	e8 b6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010268a:	68 a1 71 10 f0       	push   $0xf01071a1
f010268f:	68 af 6f 10 f0       	push   $0xf0106faf
f0102694:	68 13 04 00 00       	push   $0x413
f0102699:	68 89 6f 10 f0       	push   $0xf0106f89
f010269e:	e8 9d d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a3:	68 fb 71 10 f0       	push   $0xf01071fb
f01026a8:	68 af 6f 10 f0       	push   $0xf0106faf
f01026ad:	68 14 04 00 00       	push   $0x414
f01026b2:	68 89 6f 10 f0       	push   $0xf0106f89
f01026b7:	e8 84 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026bc:	68 80 6b 10 f0       	push   $0xf0106b80
f01026c1:	68 af 6f 10 f0       	push   $0xf0106faf
f01026c6:	68 17 04 00 00       	push   $0x417
f01026cb:	68 89 6f 10 f0       	push   $0xf0106f89
f01026d0:	e8 6b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01026d5:	68 0c 72 10 f0       	push   $0xf010720c
f01026da:	68 af 6f 10 f0       	push   $0xf0106faf
f01026df:	68 18 04 00 00       	push   $0x418
f01026e4:	68 89 6f 10 f0       	push   $0xf0106f89
f01026e9:	e8 52 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01026ee:	68 18 72 10 f0       	push   $0xf0107218
f01026f3:	68 af 6f 10 f0       	push   $0xf0106faf
f01026f8:	68 19 04 00 00       	push   $0x419
f01026fd:	68 89 6f 10 f0       	push   $0xf0106f89
f0102702:	e8 39 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102707:	68 5c 6b 10 f0       	push   $0xf0106b5c
f010270c:	68 af 6f 10 f0       	push   $0xf0106faf
f0102711:	68 1d 04 00 00       	push   $0x41d
f0102716:	68 89 6f 10 f0       	push   $0xf0106f89
f010271b:	e8 20 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102720:	68 b8 6b 10 f0       	push   $0xf0106bb8
f0102725:	68 af 6f 10 f0       	push   $0xf0106faf
f010272a:	68 1e 04 00 00       	push   $0x41e
f010272f:	68 89 6f 10 f0       	push   $0xf0106f89
f0102734:	e8 07 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102739:	68 2d 72 10 f0       	push   $0xf010722d
f010273e:	68 af 6f 10 f0       	push   $0xf0106faf
f0102743:	68 1f 04 00 00       	push   $0x41f
f0102748:	68 89 6f 10 f0       	push   $0xf0106f89
f010274d:	e8 ee d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102752:	68 fb 71 10 f0       	push   $0xf01071fb
f0102757:	68 af 6f 10 f0       	push   $0xf0106faf
f010275c:	68 20 04 00 00       	push   $0x420
f0102761:	68 89 6f 10 f0       	push   $0xf0106f89
f0102766:	e8 d5 d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010276b:	68 e0 6b 10 f0       	push   $0xf0106be0
f0102770:	68 af 6f 10 f0       	push   $0xf0106faf
f0102775:	68 23 04 00 00       	push   $0x423
f010277a:	68 89 6f 10 f0       	push   $0xf0106f89
f010277f:	e8 bc d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102784:	68 4f 71 10 f0       	push   $0xf010714f
f0102789:	68 af 6f 10 f0       	push   $0xf0106faf
f010278e:	68 26 04 00 00       	push   $0x426
f0102793:	68 89 6f 10 f0       	push   $0xf0106f89
f0102798:	e8 a3 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010279d:	68 84 68 10 f0       	push   $0xf0106884
f01027a2:	68 af 6f 10 f0       	push   $0xf0106faf
f01027a7:	68 29 04 00 00       	push   $0x429
f01027ac:	68 89 6f 10 f0       	push   $0xf0106f89
f01027b1:	e8 8a d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01027b6:	68 b2 71 10 f0       	push   $0xf01071b2
f01027bb:	68 af 6f 10 f0       	push   $0xf0106faf
f01027c0:	68 2b 04 00 00       	push   $0x42b
f01027c5:	68 89 6f 10 f0       	push   $0xf0106f89
f01027ca:	e8 71 d8 ff ff       	call   f0100040 <_panic>
f01027cf:	50                   	push   %eax
f01027d0:	68 c4 60 10 f0       	push   $0xf01060c4
f01027d5:	68 32 04 00 00       	push   $0x432
f01027da:	68 89 6f 10 f0       	push   $0xf0106f89
f01027df:	e8 5c d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027e4:	68 3e 72 10 f0       	push   $0xf010723e
f01027e9:	68 af 6f 10 f0       	push   $0xf0106faf
f01027ee:	68 33 04 00 00       	push   $0x433
f01027f3:	68 89 6f 10 f0       	push   $0xf0106f89
f01027f8:	e8 43 d8 ff ff       	call   f0100040 <_panic>
f01027fd:	50                   	push   %eax
f01027fe:	68 c4 60 10 f0       	push   $0xf01060c4
f0102803:	6a 58                	push   $0x58
f0102805:	68 95 6f 10 f0       	push   $0xf0106f95
f010280a:	e8 31 d8 ff ff       	call   f0100040 <_panic>
f010280f:	52                   	push   %edx
f0102810:	68 c4 60 10 f0       	push   $0xf01060c4
f0102815:	6a 58                	push   $0x58
f0102817:	68 95 6f 10 f0       	push   $0xf0106f95
f010281c:	e8 1f d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102821:	68 56 72 10 f0       	push   $0xf0107256
f0102826:	68 af 6f 10 f0       	push   $0xf0106faf
f010282b:	68 3d 04 00 00       	push   $0x43d
f0102830:	68 89 6f 10 f0       	push   $0xf0106f89
f0102835:	e8 06 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010283a:	68 04 6c 10 f0       	push   $0xf0106c04
f010283f:	68 af 6f 10 f0       	push   $0xf0106faf
f0102844:	68 4d 04 00 00       	push   $0x44d
f0102849:	68 89 6f 10 f0       	push   $0xf0106f89
f010284e:	e8 ed d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102853:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0102858:	68 af 6f 10 f0       	push   $0xf0106faf
f010285d:	68 4e 04 00 00       	push   $0x44e
f0102862:	68 89 6f 10 f0       	push   $0xf0106f89
f0102867:	e8 d4 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010286c:	68 54 6c 10 f0       	push   $0xf0106c54
f0102871:	68 af 6f 10 f0       	push   $0xf0106faf
f0102876:	68 50 04 00 00       	push   $0x450
f010287b:	68 89 6f 10 f0       	push   $0xf0106f89
f0102880:	e8 bb d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102885:	68 6d 72 10 f0       	push   $0xf010726d
f010288a:	68 af 6f 10 f0       	push   $0xf0106faf
f010288f:	68 52 04 00 00       	push   $0x452
f0102894:	68 89 6f 10 f0       	push   $0xf0106f89
f0102899:	e8 a2 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010289e:	68 7c 6c 10 f0       	push   $0xf0106c7c
f01028a3:	68 af 6f 10 f0       	push   $0xf0106faf
f01028a8:	68 54 04 00 00       	push   $0x454
f01028ad:	68 89 6f 10 f0       	push   $0xf0106f89
f01028b2:	e8 89 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01028b7:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01028bc:	68 af 6f 10 f0       	push   $0xf0106faf
f01028c1:	68 55 04 00 00       	push   $0x455
f01028c6:	68 89 6f 10 f0       	push   $0xf0106f89
f01028cb:	e8 70 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01028d0:	68 d0 6c 10 f0       	push   $0xf0106cd0
f01028d5:	68 af 6f 10 f0       	push   $0xf0106faf
f01028da:	68 56 04 00 00       	push   $0x456
f01028df:	68 89 6f 10 f0       	push   $0xf0106f89
f01028e4:	e8 57 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01028e9:	68 f4 6c 10 f0       	push   $0xf0106cf4
f01028ee:	68 af 6f 10 f0       	push   $0xf0106faf
f01028f3:	68 57 04 00 00       	push   $0x457
f01028f8:	68 89 6f 10 f0       	push   $0xf0106f89
f01028fd:	e8 3e d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102902:	68 20 6d 10 f0       	push   $0xf0106d20
f0102907:	68 af 6f 10 f0       	push   $0xf0106faf
f010290c:	68 59 04 00 00       	push   $0x459
f0102911:	68 89 6f 10 f0       	push   $0xf0106f89
f0102916:	e8 25 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010291b:	68 64 6d 10 f0       	push   $0xf0106d64
f0102920:	68 af 6f 10 f0       	push   $0xf0106faf
f0102925:	68 5a 04 00 00       	push   $0x45a
f010292a:	68 89 6f 10 f0       	push   $0xf0106f89
f010292f:	e8 0c d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102934:	50                   	push   %eax
f0102935:	68 e8 60 10 f0       	push   $0xf01060e8
f010293a:	68 bd 00 00 00       	push   $0xbd
f010293f:	68 89 6f 10 f0       	push   $0xf0106f89
f0102944:	e8 f7 d6 ff ff       	call   f0100040 <_panic>
f0102949:	50                   	push   %eax
f010294a:	68 e8 60 10 f0       	push   $0xf01060e8
f010294f:	68 c6 00 00 00       	push   $0xc6
f0102954:	68 89 6f 10 f0       	push   $0xf0106f89
f0102959:	e8 e2 d6 ff ff       	call   f0100040 <_panic>
f010295e:	50                   	push   %eax
f010295f:	68 e8 60 10 f0       	push   $0xf01060e8
f0102964:	68 d2 00 00 00       	push   $0xd2
f0102969:	68 89 6f 10 f0       	push   $0xf0106f89
f010296e:	e8 cd d6 ff ff       	call   f0100040 <_panic>
f0102973:	53                   	push   %ebx
f0102974:	68 e8 60 10 f0       	push   $0xf01060e8
f0102979:	68 12 01 00 00       	push   $0x112
f010297e:	68 89 6f 10 f0       	push   $0xf0106f89
f0102983:	e8 b8 d6 ff ff       	call   f0100040 <_panic>
f0102988:	ff 75 c4             	pushl  -0x3c(%ebp)
f010298b:	68 e8 60 10 f0       	push   $0xf01060e8
f0102990:	68 73 03 00 00       	push   $0x373
f0102995:	68 89 6f 10 f0       	push   $0xf0106f89
f010299a:	e8 a1 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010299f:	68 98 6d 10 f0       	push   $0xf0106d98
f01029a4:	68 af 6f 10 f0       	push   $0xf0106faf
f01029a9:	68 73 03 00 00       	push   $0x373
f01029ae:	68 89 6f 10 f0       	push   $0xf0106f89
f01029b3:	e8 88 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029b8:	a1 48 d2 22 f0       	mov    0xf022d248,%eax
f01029bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01029c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029c3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029c8:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01029ce:	89 da                	mov    %ebx,%edx
f01029d0:	89 f8                	mov    %edi,%eax
f01029d2:	e8 e3 e0 ff ff       	call   f0100aba <check_va2pa>
f01029d7:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029de:	76 22                	jbe    f0102a02 <mem_init+0x167e>
f01029e0:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01029e3:	39 d0                	cmp    %edx,%eax
f01029e5:	75 32                	jne    f0102a19 <mem_init+0x1695>
f01029e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01029ed:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01029f3:	75 d9                	jne    f01029ce <mem_init+0x164a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029f5:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01029f8:	c1 e6 0c             	shl    $0xc,%esi
f01029fb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a00:	eb 4b                	jmp    f0102a4d <mem_init+0x16c9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a02:	ff 75 d0             	pushl  -0x30(%ebp)
f0102a05:	68 e8 60 10 f0       	push   $0xf01060e8
f0102a0a:	68 79 03 00 00       	push   $0x379
f0102a0f:	68 89 6f 10 f0       	push   $0xf0106f89
f0102a14:	e8 27 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a19:	68 cc 6d 10 f0       	push   $0xf0106dcc
f0102a1e:	68 af 6f 10 f0       	push   $0xf0106faf
f0102a23:	68 79 03 00 00       	push   $0x379
f0102a28:	68 89 6f 10 f0       	push   $0xf0106f89
f0102a2d:	e8 0e d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a32:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a38:	89 f8                	mov    %edi,%eax
f0102a3a:	e8 7b e0 ff ff       	call   f0100aba <check_va2pa>
f0102a3f:	39 c3                	cmp    %eax,%ebx
f0102a41:	0f 85 f9 00 00 00    	jne    f0102b40 <mem_init+0x17bc>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a47:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a4d:	39 f3                	cmp    %esi,%ebx
f0102a4f:	72 e1                	jb     f0102a32 <mem_init+0x16ae>
f0102a51:	c7 45 d4 00 f0 22 f0 	movl   $0xf022f000,-0x2c(%ebp)
f0102a58:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a60:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102a63:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102a69:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a6c:	89 f3                	mov    %esi,%ebx
f0102a6e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a71:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a76:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0102a79:	89 c6                	mov    %eax,%esi
f0102a7b:	89 da                	mov    %ebx,%edx
f0102a7d:	89 f8                	mov    %edi,%eax
f0102a7f:	e8 36 e0 ff ff       	call   f0100aba <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a84:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102a8b:	0f 86 c8 00 00 00    	jbe    f0102b59 <mem_init+0x17d5>
f0102a91:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a94:	39 d0                	cmp    %edx,%eax
f0102a96:	0f 85 d4 00 00 00    	jne    f0102b70 <mem_init+0x17ec>
f0102a9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102aa2:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102aa5:	75 d4                	jne    f0102a7b <mem_init+0x16f7>
f0102aa7:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102aaa:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ab0:	89 da                	mov    %ebx,%edx
f0102ab2:	89 f8                	mov    %edi,%eax
f0102ab4:	e8 01 e0 ff ff       	call   f0100aba <check_va2pa>
f0102ab9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102abc:	0f 85 c7 00 00 00    	jne    f0102b89 <mem_init+0x1805>
f0102ac2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102ac8:	39 f3                	cmp    %esi,%ebx
f0102aca:	75 e4                	jne    f0102ab0 <mem_init+0x172c>
f0102acc:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102ad2:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f0102ad9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102adc:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102ae3:	3d 00 f0 2e f0       	cmp    $0xf02ef000,%eax
f0102ae8:	0f 85 6f ff ff ff    	jne    f0102a5d <mem_init+0x16d9>
	for (i = 0; i < NPDENTRIES; i++) {
f0102aee:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102af3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102af8:	0f 87 a4 00 00 00    	ja     f0102ba2 <mem_init+0x181e>
				assert(pgdir[i] == 0);
f0102afe:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b02:	0f 85 dd 00 00 00    	jne    f0102be5 <mem_init+0x1861>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b08:	83 c0 01             	add    $0x1,%eax
f0102b0b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b10:	0f 87 e8 00 00 00    	ja     f0102bfe <mem_init+0x187a>
		switch (i) {
f0102b16:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b1c:	83 fa 04             	cmp    $0x4,%edx
f0102b1f:	77 d2                	ja     f0102af3 <mem_init+0x176f>
			assert(pgdir[i] & PTE_P);
f0102b21:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b25:	75 e1                	jne    f0102b08 <mem_init+0x1784>
f0102b27:	68 98 72 10 f0       	push   $0xf0107298
f0102b2c:	68 af 6f 10 f0       	push   $0xf0106faf
f0102b31:	68 92 03 00 00       	push   $0x392
f0102b36:	68 89 6f 10 f0       	push   $0xf0106f89
f0102b3b:	e8 00 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b40:	68 00 6e 10 f0       	push   $0xf0106e00
f0102b45:	68 af 6f 10 f0       	push   $0xf0106faf
f0102b4a:	68 7d 03 00 00       	push   $0x37d
f0102b4f:	68 89 6f 10 f0       	push   $0xf0106f89
f0102b54:	e8 e7 d4 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b59:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102b5c:	68 e8 60 10 f0       	push   $0xf01060e8
f0102b61:	68 85 03 00 00       	push   $0x385
f0102b66:	68 89 6f 10 f0       	push   $0xf0106f89
f0102b6b:	e8 d0 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b70:	68 28 6e 10 f0       	push   $0xf0106e28
f0102b75:	68 af 6f 10 f0       	push   $0xf0106faf
f0102b7a:	68 85 03 00 00       	push   $0x385
f0102b7f:	68 89 6f 10 f0       	push   $0xf0106f89
f0102b84:	e8 b7 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b89:	68 70 6e 10 f0       	push   $0xf0106e70
f0102b8e:	68 af 6f 10 f0       	push   $0xf0106faf
f0102b93:	68 87 03 00 00       	push   $0x387
f0102b98:	68 89 6f 10 f0       	push   $0xf0106f89
f0102b9d:	e8 9e d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ba2:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ba5:	f6 c2 01             	test   $0x1,%dl
f0102ba8:	74 22                	je     f0102bcc <mem_init+0x1848>
				assert(pgdir[i] & PTE_W);
f0102baa:	f6 c2 02             	test   $0x2,%dl
f0102bad:	0f 85 55 ff ff ff    	jne    f0102b08 <mem_init+0x1784>
f0102bb3:	68 a9 72 10 f0       	push   $0xf01072a9
f0102bb8:	68 af 6f 10 f0       	push   $0xf0106faf
f0102bbd:	68 97 03 00 00       	push   $0x397
f0102bc2:	68 89 6f 10 f0       	push   $0xf0106f89
f0102bc7:	e8 74 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bcc:	68 98 72 10 f0       	push   $0xf0107298
f0102bd1:	68 af 6f 10 f0       	push   $0xf0106faf
f0102bd6:	68 96 03 00 00       	push   $0x396
f0102bdb:	68 89 6f 10 f0       	push   $0xf0106f89
f0102be0:	e8 5b d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102be5:	68 ba 72 10 f0       	push   $0xf01072ba
f0102bea:	68 af 6f 10 f0       	push   $0xf0106faf
f0102bef:	68 99 03 00 00       	push   $0x399
f0102bf4:	68 89 6f 10 f0       	push   $0xf0106f89
f0102bf9:	e8 42 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bfe:	83 ec 0c             	sub    $0xc,%esp
f0102c01:	68 94 6e 10 f0       	push   $0xf0106e94
f0102c06:	e8 c6 0d 00 00       	call   f01039d1 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c0b:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c10:	83 c4 10             	add    $0x10,%esp
f0102c13:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c18:	0f 86 fe 01 00 00    	jbe    f0102e1c <mem_init+0x1a98>
	return (physaddr_t)kva - KERNBASE;
f0102c1e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c23:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c2b:	e8 ee de ff ff       	call   f0100b1e <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c30:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c33:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c36:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c3b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c3e:	83 ec 0c             	sub    $0xc,%esp
f0102c41:	6a 00                	push   $0x0
f0102c43:	e8 13 e3 ff ff       	call   f0100f5b <page_alloc>
f0102c48:	89 c3                	mov    %eax,%ebx
f0102c4a:	83 c4 10             	add    $0x10,%esp
f0102c4d:	85 c0                	test   %eax,%eax
f0102c4f:	0f 84 dc 01 00 00    	je     f0102e31 <mem_init+0x1aad>
	assert((pp1 = page_alloc(0)));
f0102c55:	83 ec 0c             	sub    $0xc,%esp
f0102c58:	6a 00                	push   $0x0
f0102c5a:	e8 fc e2 ff ff       	call   f0100f5b <page_alloc>
f0102c5f:	89 c7                	mov    %eax,%edi
f0102c61:	83 c4 10             	add    $0x10,%esp
f0102c64:	85 c0                	test   %eax,%eax
f0102c66:	0f 84 de 01 00 00    	je     f0102e4a <mem_init+0x1ac6>
	assert((pp2 = page_alloc(0)));
f0102c6c:	83 ec 0c             	sub    $0xc,%esp
f0102c6f:	6a 00                	push   $0x0
f0102c71:	e8 e5 e2 ff ff       	call   f0100f5b <page_alloc>
f0102c76:	89 c6                	mov    %eax,%esi
f0102c78:	83 c4 10             	add    $0x10,%esp
f0102c7b:	85 c0                	test   %eax,%eax
f0102c7d:	0f 84 e0 01 00 00    	je     f0102e63 <mem_init+0x1adf>
	page_free(pp0);
f0102c83:	83 ec 0c             	sub    $0xc,%esp
f0102c86:	53                   	push   %ebx
f0102c87:	e8 41 e3 ff ff       	call   f0100fcd <page_free>
	return (pp - pages) << PGSHIFT;
f0102c8c:	89 f8                	mov    %edi,%eax
f0102c8e:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0102c94:	c1 f8 03             	sar    $0x3,%eax
f0102c97:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c9a:	89 c2                	mov    %eax,%edx
f0102c9c:	c1 ea 0c             	shr    $0xc,%edx
f0102c9f:	83 c4 10             	add    $0x10,%esp
f0102ca2:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0102ca8:	0f 83 ce 01 00 00    	jae    f0102e7c <mem_init+0x1af8>
	memset(page2kva(pp1), 1, PGSIZE);
f0102cae:	83 ec 04             	sub    $0x4,%esp
f0102cb1:	68 00 10 00 00       	push   $0x1000
f0102cb6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102cb8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cbd:	50                   	push   %eax
f0102cbe:	e8 83 27 00 00       	call   f0105446 <memset>
	return (pp - pages) << PGSHIFT;
f0102cc3:	89 f0                	mov    %esi,%eax
f0102cc5:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0102ccb:	c1 f8 03             	sar    $0x3,%eax
f0102cce:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cd1:	89 c2                	mov    %eax,%edx
f0102cd3:	c1 ea 0c             	shr    $0xc,%edx
f0102cd6:	83 c4 10             	add    $0x10,%esp
f0102cd9:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0102cdf:	0f 83 a9 01 00 00    	jae    f0102e8e <mem_init+0x1b0a>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ce5:	83 ec 04             	sub    $0x4,%esp
f0102ce8:	68 00 10 00 00       	push   $0x1000
f0102ced:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102cef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cf4:	50                   	push   %eax
f0102cf5:	e8 4c 27 00 00       	call   f0105446 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cfa:	6a 02                	push   $0x2
f0102cfc:	68 00 10 00 00       	push   $0x1000
f0102d01:	57                   	push   %edi
f0102d02:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0102d08:	e8 73 e5 ff ff       	call   f0101280 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d0d:	83 c4 20             	add    $0x20,%esp
f0102d10:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d15:	0f 85 85 01 00 00    	jne    f0102ea0 <mem_init+0x1b1c>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d1b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d22:	01 01 01 
f0102d25:	0f 85 8e 01 00 00    	jne    f0102eb9 <mem_init+0x1b35>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d2b:	6a 02                	push   $0x2
f0102d2d:	68 00 10 00 00       	push   $0x1000
f0102d32:	56                   	push   %esi
f0102d33:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0102d39:	e8 42 e5 ff ff       	call   f0101280 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d3e:	83 c4 10             	add    $0x10,%esp
f0102d41:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d48:	02 02 02 
f0102d4b:	0f 85 81 01 00 00    	jne    f0102ed2 <mem_init+0x1b4e>
	assert(pp2->pp_ref == 1);
f0102d51:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d56:	0f 85 8f 01 00 00    	jne    f0102eeb <mem_init+0x1b67>
	assert(pp1->pp_ref == 0);
f0102d5c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d61:	0f 85 9d 01 00 00    	jne    f0102f04 <mem_init+0x1b80>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d67:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d6e:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d71:	89 f0                	mov    %esi,%eax
f0102d73:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0102d79:	c1 f8 03             	sar    $0x3,%eax
f0102d7c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102d7f:	89 c2                	mov    %eax,%edx
f0102d81:	c1 ea 0c             	shr    $0xc,%edx
f0102d84:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f0102d8a:	0f 83 8d 01 00 00    	jae    f0102f1d <mem_init+0x1b99>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d90:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d97:	03 03 03 
f0102d9a:	0f 85 8f 01 00 00    	jne    f0102f2f <mem_init+0x1bab>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102da0:	83 ec 08             	sub    $0x8,%esp
f0102da3:	68 00 10 00 00       	push   $0x1000
f0102da8:	ff 35 8c de 22 f0    	pushl  0xf022de8c
f0102dae:	e8 79 e4 ff ff       	call   f010122c <page_remove>
	assert(pp2->pp_ref == 0);
f0102db3:	83 c4 10             	add    $0x10,%esp
f0102db6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dbb:	0f 85 87 01 00 00    	jne    f0102f48 <mem_init+0x1bc4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dc1:	8b 0d 8c de 22 f0    	mov    0xf022de8c,%ecx
f0102dc7:	8b 11                	mov    (%ecx),%edx
f0102dc9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102dcf:	89 d8                	mov    %ebx,%eax
f0102dd1:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f0102dd7:	c1 f8 03             	sar    $0x3,%eax
f0102dda:	c1 e0 0c             	shl    $0xc,%eax
f0102ddd:	39 c2                	cmp    %eax,%edx
f0102ddf:	0f 85 7c 01 00 00    	jne    f0102f61 <mem_init+0x1bdd>
	kern_pgdir[0] = 0;
f0102de5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102deb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102df0:	0f 85 84 01 00 00    	jne    f0102f7a <mem_init+0x1bf6>
	pp0->pp_ref = 0;
f0102df6:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102dfc:	83 ec 0c             	sub    $0xc,%esp
f0102dff:	53                   	push   %ebx
f0102e00:	e8 c8 e1 ff ff       	call   f0100fcd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e05:	c7 04 24 28 6f 10 f0 	movl   $0xf0106f28,(%esp)
f0102e0c:	e8 c0 0b 00 00       	call   f01039d1 <cprintf>
}
f0102e11:	83 c4 10             	add    $0x10,%esp
f0102e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e17:	5b                   	pop    %ebx
f0102e18:	5e                   	pop    %esi
f0102e19:	5f                   	pop    %edi
f0102e1a:	5d                   	pop    %ebp
f0102e1b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1c:	50                   	push   %eax
f0102e1d:	68 e8 60 10 f0       	push   $0xf01060e8
f0102e22:	68 ea 00 00 00       	push   $0xea
f0102e27:	68 89 6f 10 f0       	push   $0xf0106f89
f0102e2c:	e8 0f d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e31:	68 a4 70 10 f0       	push   $0xf01070a4
f0102e36:	68 af 6f 10 f0       	push   $0xf0106faf
f0102e3b:	68 6f 04 00 00       	push   $0x46f
f0102e40:	68 89 6f 10 f0       	push   $0xf0106f89
f0102e45:	e8 f6 d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e4a:	68 ba 70 10 f0       	push   $0xf01070ba
f0102e4f:	68 af 6f 10 f0       	push   $0xf0106faf
f0102e54:	68 70 04 00 00       	push   $0x470
f0102e59:	68 89 6f 10 f0       	push   $0xf0106f89
f0102e5e:	e8 dd d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e63:	68 d0 70 10 f0       	push   $0xf01070d0
f0102e68:	68 af 6f 10 f0       	push   $0xf0106faf
f0102e6d:	68 71 04 00 00       	push   $0x471
f0102e72:	68 89 6f 10 f0       	push   $0xf0106f89
f0102e77:	e8 c4 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e7c:	50                   	push   %eax
f0102e7d:	68 c4 60 10 f0       	push   $0xf01060c4
f0102e82:	6a 58                	push   $0x58
f0102e84:	68 95 6f 10 f0       	push   $0xf0106f95
f0102e89:	e8 b2 d1 ff ff       	call   f0100040 <_panic>
f0102e8e:	50                   	push   %eax
f0102e8f:	68 c4 60 10 f0       	push   $0xf01060c4
f0102e94:	6a 58                	push   $0x58
f0102e96:	68 95 6f 10 f0       	push   $0xf0106f95
f0102e9b:	e8 a0 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102ea0:	68 a1 71 10 f0       	push   $0xf01071a1
f0102ea5:	68 af 6f 10 f0       	push   $0xf0106faf
f0102eaa:	68 76 04 00 00       	push   $0x476
f0102eaf:	68 89 6f 10 f0       	push   $0xf0106f89
f0102eb4:	e8 87 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102eb9:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0102ebe:	68 af 6f 10 f0       	push   $0xf0106faf
f0102ec3:	68 77 04 00 00       	push   $0x477
f0102ec8:	68 89 6f 10 f0       	push   $0xf0106f89
f0102ecd:	e8 6e d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ed2:	68 d8 6e 10 f0       	push   $0xf0106ed8
f0102ed7:	68 af 6f 10 f0       	push   $0xf0106faf
f0102edc:	68 79 04 00 00       	push   $0x479
f0102ee1:	68 89 6f 10 f0       	push   $0xf0106f89
f0102ee6:	e8 55 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102eeb:	68 c3 71 10 f0       	push   $0xf01071c3
f0102ef0:	68 af 6f 10 f0       	push   $0xf0106faf
f0102ef5:	68 7a 04 00 00       	push   $0x47a
f0102efa:	68 89 6f 10 f0       	push   $0xf0106f89
f0102eff:	e8 3c d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f04:	68 2d 72 10 f0       	push   $0xf010722d
f0102f09:	68 af 6f 10 f0       	push   $0xf0106faf
f0102f0e:	68 7b 04 00 00       	push   $0x47b
f0102f13:	68 89 6f 10 f0       	push   $0xf0106f89
f0102f18:	e8 23 d1 ff ff       	call   f0100040 <_panic>
f0102f1d:	50                   	push   %eax
f0102f1e:	68 c4 60 10 f0       	push   $0xf01060c4
f0102f23:	6a 58                	push   $0x58
f0102f25:	68 95 6f 10 f0       	push   $0xf0106f95
f0102f2a:	e8 11 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f2f:	68 fc 6e 10 f0       	push   $0xf0106efc
f0102f34:	68 af 6f 10 f0       	push   $0xf0106faf
f0102f39:	68 7d 04 00 00       	push   $0x47d
f0102f3e:	68 89 6f 10 f0       	push   $0xf0106f89
f0102f43:	e8 f8 d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102f48:	68 fb 71 10 f0       	push   $0xf01071fb
f0102f4d:	68 af 6f 10 f0       	push   $0xf0106faf
f0102f52:	68 7f 04 00 00       	push   $0x47f
f0102f57:	68 89 6f 10 f0       	push   $0xf0106f89
f0102f5c:	e8 df d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f61:	68 84 68 10 f0       	push   $0xf0106884
f0102f66:	68 af 6f 10 f0       	push   $0xf0106faf
f0102f6b:	68 82 04 00 00       	push   $0x482
f0102f70:	68 89 6f 10 f0       	push   $0xf0106f89
f0102f75:	e8 c6 d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102f7a:	68 b2 71 10 f0       	push   $0xf01071b2
f0102f7f:	68 af 6f 10 f0       	push   $0xf0106faf
f0102f84:	68 84 04 00 00       	push   $0x484
f0102f89:	68 89 6f 10 f0       	push   $0xf0106f89
f0102f8e:	e8 ad d0 ff ff       	call   f0100040 <_panic>

f0102f93 <pte_perm_check>:
{
f0102f93:	55                   	push   %ebp
f0102f94:	89 e5                	mov    %esp,%ebp
f0102f96:	8b 55 08             	mov    0x8(%ebp),%edx
		return false;
f0102f99:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!test) {
f0102f9e:	85 d2                	test   %edx,%edx
f0102fa0:	74 08                	je     f0102faa <pte_perm_check+0x17>
	if ((*test) & perm) {
f0102fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fa5:	85 02                	test   %eax,(%edx)
f0102fa7:	0f 95 c0             	setne  %al
}
f0102faa:	5d                   	pop    %ebp
f0102fab:	c3                   	ret    

f0102fac <user_mem_check>:
{
f0102fac:	55                   	push   %ebp
f0102fad:	89 e5                	mov    %esp,%ebp
f0102faf:	57                   	push   %edi
f0102fb0:	56                   	push   %esi
f0102fb1:	53                   	push   %ebx
f0102fb2:	83 ec 0c             	sub    $0xc,%esp
f0102fb5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102fb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uintptr_t va_hi = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f0102fbb:	89 de                	mov    %ebx,%esi
f0102fbd:	03 75 10             	add    0x10(%ebp),%esi
f0102fc0:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0102fc6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (const void* p = va; p < (void*)va_hi; p++) {
f0102fcc:	39 f3                	cmp    %esi,%ebx
f0102fce:	73 40                	jae    f0103010 <user_mem_check+0x64>
		pte_t *pte = pgdir_walk(env->env_pgdir, p, 0);
f0102fd0:	83 ec 04             	sub    $0x4,%esp
f0102fd3:	6a 00                	push   $0x0
f0102fd5:	53                   	push   %ebx
f0102fd6:	ff 77 60             	pushl  0x60(%edi)
f0102fd9:	e8 53 e0 ff ff       	call   f0101031 <pgdir_walk>
		if (!pte || !pte_perm_check(pte, perm)) {
f0102fde:	83 c4 10             	add    $0x10,%esp
f0102fe1:	85 c0                	test   %eax,%eax
f0102fe3:	74 18                	je     f0102ffd <user_mem_check+0x51>
f0102fe5:	83 ec 08             	sub    $0x8,%esp
f0102fe8:	ff 75 14             	pushl  0x14(%ebp)
f0102feb:	50                   	push   %eax
f0102fec:	e8 a2 ff ff ff       	call   f0102f93 <pte_perm_check>
f0102ff1:	83 c4 10             	add    $0x10,%esp
f0102ff4:	84 c0                	test   %al,%al
f0102ff6:	74 05                	je     f0102ffd <user_mem_check+0x51>
	for (const void* p = va; p < (void*)va_hi; p++) {
f0102ff8:	83 c3 01             	add    $0x1,%ebx
f0102ffb:	eb cf                	jmp    f0102fcc <user_mem_check+0x20>
			user_mem_check_addr = (uintptr_t)p;
f0102ffd:	89 1d 3c d2 22 f0    	mov    %ebx,0xf022d23c
			return -E_FAULT;
f0103003:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0103008:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010300b:	5b                   	pop    %ebx
f010300c:	5e                   	pop    %esi
f010300d:	5f                   	pop    %edi
f010300e:	5d                   	pop    %ebp
f010300f:	c3                   	ret    
	return 0;
f0103010:	b8 00 00 00 00       	mov    $0x0,%eax
f0103015:	eb f1                	jmp    f0103008 <user_mem_check+0x5c>

f0103017 <user_mem_assert>:
{
f0103017:	55                   	push   %ebp
f0103018:	89 e5                	mov    %esp,%ebp
f010301a:	53                   	push   %ebx
f010301b:	83 ec 04             	sub    $0x4,%esp
f010301e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103021:	8b 45 14             	mov    0x14(%ebp),%eax
f0103024:	83 c8 04             	or     $0x4,%eax
f0103027:	50                   	push   %eax
f0103028:	ff 75 10             	pushl  0x10(%ebp)
f010302b:	ff 75 0c             	pushl  0xc(%ebp)
f010302e:	53                   	push   %ebx
f010302f:	e8 78 ff ff ff       	call   f0102fac <user_mem_check>
f0103034:	83 c4 10             	add    $0x10,%esp
f0103037:	85 c0                	test   %eax,%eax
f0103039:	78 05                	js     f0103040 <user_mem_assert+0x29>
}
f010303b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010303e:	c9                   	leave  
f010303f:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103040:	83 ec 04             	sub    $0x4,%esp
f0103043:	ff 35 3c d2 22 f0    	pushl  0xf022d23c
f0103049:	ff 73 48             	pushl  0x48(%ebx)
f010304c:	68 54 6f 10 f0       	push   $0xf0106f54
f0103051:	e8 7b 09 00 00       	call   f01039d1 <cprintf>
		env_destroy(env);	// may not return
f0103056:	89 1c 24             	mov    %ebx,(%esp)
f0103059:	e8 71 06 00 00       	call   f01036cf <env_destroy>
f010305e:	83 c4 10             	add    $0x10,%esp
}
f0103061:	eb d8                	jmp    f010303b <user_mem_assert+0x24>

f0103063 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103063:	55                   	push   %ebp
f0103064:	89 e5                	mov    %esp,%ebp
f0103066:	57                   	push   %edi
f0103067:	56                   	push   %esi
f0103068:	53                   	push   %ebx
f0103069:	83 ec 1c             	sub    $0x1c,%esp
f010306c:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_low = ROUNDDOWN((uintptr_t)va, PGSIZE);
f010306e:	89 d6                	mov    %edx,%esi
f0103070:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uintptr_t va_high = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0103076:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
	size_t pgcnt = (va_high - va_low) / PGSIZE;
f010307d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103082:	29 f0                	sub    %esi,%eax
f0103084:	c1 e8 0c             	shr    $0xc,%eax
f0103087:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (int i = 0; i < pgcnt; ++i) {
f010308a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010308f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103092:	74 42                	je     f01030d6 <region_alloc+0x73>
		struct PageInfo *p = page_alloc(0);
f0103094:	83 ec 0c             	sub    $0xc,%esp
f0103097:	6a 00                	push   $0x0
f0103099:	e8 bd de ff ff       	call   f0100f5b <page_alloc>
		if (!p) {
f010309e:	83 c4 10             	add    $0x10,%esp
f01030a1:	85 c0                	test   %eax,%eax
f01030a3:	74 1a                	je     f01030bf <region_alloc+0x5c>
			panic("Allocate page failed!");
		}
		page_insert(e->env_pgdir, p, (void*)va_low + i * PGSIZE, PTE_P | PTE_U | PTE_W);
f01030a5:	6a 07                	push   $0x7
f01030a7:	56                   	push   %esi
f01030a8:	50                   	push   %eax
f01030a9:	ff 77 60             	pushl  0x60(%edi)
f01030ac:	e8 cf e1 ff ff       	call   f0101280 <page_insert>
	for (int i = 0; i < pgcnt; ++i) {
f01030b1:	83 c3 01             	add    $0x1,%ebx
f01030b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01030ba:	83 c4 10             	add    $0x10,%esp
f01030bd:	eb d0                	jmp    f010308f <region_alloc+0x2c>
			panic("Allocate page failed!");
f01030bf:	83 ec 04             	sub    $0x4,%esp
f01030c2:	68 c8 72 10 f0       	push   $0xf01072c8
f01030c7:	68 2b 01 00 00       	push   $0x12b
f01030cc:	68 de 72 10 f0       	push   $0xf01072de
f01030d1:	e8 6a cf ff ff       	call   f0100040 <_panic>
	}

}
f01030d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030d9:	5b                   	pop    %ebx
f01030da:	5e                   	pop    %esi
f01030db:	5f                   	pop    %edi
f01030dc:	5d                   	pop    %ebp
f01030dd:	c3                   	ret    

f01030de <envid2env>:
{
f01030de:	55                   	push   %ebp
f01030df:	89 e5                	mov    %esp,%ebp
f01030e1:	57                   	push   %edi
f01030e2:	56                   	push   %esi
f01030e3:	53                   	push   %ebx
f01030e4:	83 ec 0c             	sub    $0xc,%esp
f01030e7:	8b 75 08             	mov    0x8(%ebp),%esi
f01030ea:	8b 7d 10             	mov    0x10(%ebp),%edi
	if (envid == 0) {
f01030ed:	85 f6                	test   %esi,%esi
f01030ef:	74 47                	je     f0103138 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f01030f1:	89 f3                	mov    %esi,%ebx
f01030f3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030f9:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01030fc:	03 1d 48 d2 22 f0    	add    0xf022d248,%ebx
	cprintf("%d------\n", e->env_id);
f0103102:	83 ec 08             	sub    $0x8,%esp
f0103105:	ff 73 48             	pushl  0x48(%ebx)
f0103108:	68 e9 72 10 f0       	push   $0xf01072e9
f010310d:	e8 bf 08 00 00       	call   f01039d1 <cprintf>
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103112:	83 c4 10             	add    $0x10,%esp
f0103115:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103119:	74 37                	je     f0103152 <envid2env+0x74>
f010311b:	39 73 48             	cmp    %esi,0x48(%ebx)
f010311e:	75 32                	jne    f0103152 <envid2env+0x74>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103120:	89 f8                	mov    %edi,%eax
f0103122:	84 c0                	test   %al,%al
f0103124:	75 3c                	jne    f0103162 <envid2env+0x84>
	*env_store = e;
f0103126:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103129:	89 18                	mov    %ebx,(%eax)
	return 0;
f010312b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103130:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103133:	5b                   	pop    %ebx
f0103134:	5e                   	pop    %esi
f0103135:	5f                   	pop    %edi
f0103136:	5d                   	pop    %ebp
f0103137:	c3                   	ret    
		*env_store = curenv;
f0103138:	e8 2e 29 00 00       	call   f0105a6b <cpunum>
f010313d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103140:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0103146:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103149:	89 02                	mov    %eax,(%edx)
		return 0;
f010314b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103150:	eb de                	jmp    f0103130 <envid2env+0x52>
		*env_store = 0;
f0103152:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103155:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010315b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103160:	eb ce                	jmp    f0103130 <envid2env+0x52>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103162:	e8 04 29 00 00       	call   f0105a6b <cpunum>
f0103167:	6b c0 74             	imul   $0x74,%eax,%eax
f010316a:	39 98 28 e0 22 f0    	cmp    %ebx,-0xfdd1fd8(%eax)
f0103170:	74 b4                	je     f0103126 <envid2env+0x48>
f0103172:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103175:	e8 f1 28 00 00       	call   f0105a6b <cpunum>
f010317a:	6b c0 74             	imul   $0x74,%eax,%eax
f010317d:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0103183:	3b 70 48             	cmp    0x48(%eax),%esi
f0103186:	74 9e                	je     f0103126 <envid2env+0x48>
		*env_store = 0;
f0103188:	8b 45 0c             	mov    0xc(%ebp),%eax
f010318b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103191:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103196:	eb 98                	jmp    f0103130 <envid2env+0x52>

f0103198 <env_init_percpu>:
{
f0103198:	55                   	push   %ebp
f0103199:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f010319b:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01031a0:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031a3:	b8 23 00 00 00       	mov    $0x23,%eax
f01031a8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031aa:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031ac:	b8 10 00 00 00       	mov    $0x10,%eax
f01031b1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031b3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031b5:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031b7:	ea be 31 10 f0 08 00 	ljmp   $0x8,$0xf01031be
	asm volatile("lldt %0" : : "r" (sel));
f01031be:	b8 00 00 00 00       	mov    $0x0,%eax
f01031c3:	0f 00 d0             	lldt   %ax
}
f01031c6:	5d                   	pop    %ebp
f01031c7:	c3                   	ret    

f01031c8 <env_init>:
{
f01031c8:	55                   	push   %ebp
f01031c9:	89 e5                	mov    %esp,%ebp
f01031cb:	56                   	push   %esi
f01031cc:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f01031cd:	8b 35 48 d2 22 f0    	mov    0xf022d248,%esi
f01031d3:	8b 15 4c d2 22 f0    	mov    0xf022d24c,%edx
f01031d9:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01031df:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01031e2:	89 c1                	mov    %eax,%ecx
f01031e4:	89 50 44             	mov    %edx,0x44(%eax)
		envs[i].env_id = 0;
f01031e7:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f01031ee:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs + i;
f01031f1:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; --i) {
f01031f3:	39 d8                	cmp    %ebx,%eax
f01031f5:	75 eb                	jne    f01031e2 <env_init+0x1a>
f01031f7:	89 35 4c d2 22 f0    	mov    %esi,0xf022d24c
	env_init_percpu();
f01031fd:	e8 96 ff ff ff       	call   f0103198 <env_init_percpu>
}
f0103202:	5b                   	pop    %ebx
f0103203:	5e                   	pop    %esi
f0103204:	5d                   	pop    %ebp
f0103205:	c3                   	ret    

f0103206 <env_alloc>:
{
f0103206:	55                   	push   %ebp
f0103207:	89 e5                	mov    %esp,%ebp
f0103209:	53                   	push   %ebx
f010320a:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f010320d:	8b 1d 4c d2 22 f0    	mov    0xf022d24c,%ebx
f0103213:	85 db                	test   %ebx,%ebx
f0103215:	0f 84 88 01 00 00    	je     f01033a3 <env_alloc+0x19d>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010321b:	83 ec 0c             	sub    $0xc,%esp
f010321e:	6a 01                	push   $0x1
f0103220:	e8 36 dd ff ff       	call   f0100f5b <page_alloc>
f0103225:	83 c4 10             	add    $0x10,%esp
f0103228:	85 c0                	test   %eax,%eax
f010322a:	0f 84 7a 01 00 00    	je     f01033aa <env_alloc+0x1a4>
	p->pp_ref++;
f0103230:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0103235:	2b 05 90 de 22 f0    	sub    0xf022de90,%eax
f010323b:	c1 f8 03             	sar    $0x3,%eax
f010323e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103241:	89 c2                	mov    %eax,%edx
f0103243:	c1 ea 0c             	shr    $0xc,%edx
f0103246:	3b 15 88 de 22 f0    	cmp    0xf022de88,%edx
f010324c:	0f 83 2a 01 00 00    	jae    f010337c <env_alloc+0x176>
	return (void *)(pa + KERNBASE);
f0103252:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103257:	89 43 60             	mov    %eax,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f010325a:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f010325f:	8b 53 60             	mov    0x60(%ebx),%edx
f0103262:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0103269:	83 c0 04             	add    $0x4,%eax
	for (int i = 0; i < utop_pgdir_index; ++i) {
f010326c:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103271:	75 ec                	jne    f010325f <env_alloc+0x59>
		e->env_pgdir[i] = kern_pgdir[i];
f0103273:	8b 15 8c de 22 f0    	mov    0xf022de8c,%edx
f0103279:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010327c:	8b 53 60             	mov    0x60(%ebx),%edx
f010327f:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103282:	83 c0 04             	add    $0x4,%eax
	for (int i = utop_pgdir_index; i <= PDX(0xffffffff); ++i) {
f0103285:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010328a:	75 e7                	jne    f0103273 <env_alloc+0x6d>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010328c:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010328f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103294:	0f 86 f4 00 00 00    	jbe    f010338e <env_alloc+0x188>
	return (physaddr_t)kva - KERNBASE;
f010329a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032a0:	83 ca 05             	or     $0x5,%edx
f01032a3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032a9:	8b 43 48             	mov    0x48(%ebx),%eax
f01032ac:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032b1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032b6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032bb:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032be:	89 da                	mov    %ebx,%edx
f01032c0:	2b 15 48 d2 22 f0    	sub    0xf022d248,%edx
f01032c6:	c1 fa 02             	sar    $0x2,%edx
f01032c9:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01032cf:	09 d0                	or     %edx,%eax
f01032d1:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01032d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032d7:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01032da:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01032e1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01032e8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01032ef:	83 ec 04             	sub    $0x4,%esp
f01032f2:	6a 44                	push   $0x44
f01032f4:	6a 00                	push   $0x0
f01032f6:	53                   	push   %ebx
f01032f7:	e8 4a 21 00 00       	call   f0105446 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01032fc:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103302:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103308:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010330e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103315:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f010331b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103322:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103326:	8b 43 44             	mov    0x44(%ebx),%eax
f0103329:	a3 4c d2 22 f0       	mov    %eax,0xf022d24c
	*newenv_store = e;
f010332e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103331:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103333:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103336:	e8 30 27 00 00       	call   f0105a6b <cpunum>
f010333b:	6b c0 74             	imul   $0x74,%eax,%eax
f010333e:	83 c4 10             	add    $0x10,%esp
f0103341:	ba 00 00 00 00       	mov    $0x0,%edx
f0103346:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f010334d:	74 11                	je     f0103360 <env_alloc+0x15a>
f010334f:	e8 17 27 00 00       	call   f0105a6b <cpunum>
f0103354:	6b c0 74             	imul   $0x74,%eax,%eax
f0103357:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f010335d:	8b 50 48             	mov    0x48(%eax),%edx
f0103360:	83 ec 04             	sub    $0x4,%esp
f0103363:	53                   	push   %ebx
f0103364:	52                   	push   %edx
f0103365:	68 f3 72 10 f0       	push   $0xf01072f3
f010336a:	e8 62 06 00 00       	call   f01039d1 <cprintf>
	return 0;
f010336f:	83 c4 10             	add    $0x10,%esp
f0103372:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010337a:	c9                   	leave  
f010337b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010337c:	50                   	push   %eax
f010337d:	68 c4 60 10 f0       	push   $0xf01060c4
f0103382:	6a 58                	push   $0x58
f0103384:	68 95 6f 10 f0       	push   $0xf0106f95
f0103389:	e8 b2 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010338e:	50                   	push   %eax
f010338f:	68 e8 60 10 f0       	push   $0xf01060e8
f0103394:	68 c7 00 00 00       	push   $0xc7
f0103399:	68 de 72 10 f0       	push   $0xf01072de
f010339e:	e8 9d cc ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01033a3:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033a8:	eb cd                	jmp    f0103377 <env_alloc+0x171>
		return -E_NO_MEM;
f01033aa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01033af:	eb c6                	jmp    f0103377 <env_alloc+0x171>

f01033b1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033b1:	55                   	push   %ebp
f01033b2:	89 e5                	mov    %esp,%ebp
f01033b4:	57                   	push   %edi
f01033b5:	56                   	push   %esi
f01033b6:	53                   	push   %ebx
f01033b7:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *new_env = NULL;
f01033ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = env_alloc(&new_env, 0);
f01033c1:	6a 00                	push   $0x0
f01033c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033c6:	50                   	push   %eax
f01033c7:	e8 3a fe ff ff       	call   f0103206 <env_alloc>
	if (ret < 0) {
f01033cc:	83 c4 10             	add    $0x10,%esp
f01033cf:	85 c0                	test   %eax,%eax
f01033d1:	78 21                	js     f01033f4 <env_create+0x43>
		panic("allocate new env failed!");
	}
	load_icode(new_env, binary);
f01033d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (Elf_header->e_magic != ELF_MAGIC) {
f01033d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d9:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01033df:	75 2a                	jne    f010340b <env_create+0x5a>
	struct Proghdr *ph = (struct Proghdr*)(binary + Elf_header->e_phoff);
f01033e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01033e4:	89 c3                	mov    %eax,%ebx
f01033e6:	03 58 1c             	add    0x1c(%eax),%ebx
	struct Proghdr *eph = ph + Elf_header->e_phnum;
f01033e9:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01033ed:	c1 e6 05             	shl    $0x5,%esi
f01033f0:	01 de                	add    %ebx,%esi
f01033f2:	eb 5b                	jmp    f010344f <env_create+0x9e>
		panic("allocate new env failed!");
f01033f4:	83 ec 04             	sub    $0x4,%esp
f01033f7:	68 08 73 10 f0       	push   $0xf0107308
f01033fc:	68 90 01 00 00       	push   $0x190
f0103401:	68 de 72 10 f0       	push   $0xf01072de
f0103406:	e8 35 cc ff ff       	call   f0100040 <_panic>
		panic("Not a valid elf file!");
f010340b:	83 ec 04             	sub    $0x4,%esp
f010340e:	68 21 73 10 f0       	push   $0xf0107321
f0103413:	68 6a 01 00 00       	push   $0x16a
f0103418:	68 de 72 10 f0       	push   $0xf01072de
f010341d:	e8 1e cc ff ff       	call   f0100040 <_panic>
f0103422:	50                   	push   %eax
f0103423:	68 e8 60 10 f0       	push   $0xf01060e8
f0103428:	68 73 01 00 00       	push   $0x173
f010342d:	68 de 72 10 f0       	push   $0xf01072de
f0103432:	e8 09 cc ff ff       	call   f0100040 <_panic>
f0103437:	50                   	push   %eax
f0103438:	68 e8 60 10 f0       	push   $0xf01060e8
f010343d:	68 76 01 00 00       	push   $0x176
f0103442:	68 de 72 10 f0       	push   $0xf01072de
f0103447:	e8 f4 cb ff ff       	call   f0100040 <_panic>
	for (; ph < eph; ph++) {
f010344c:	83 c3 20             	add    $0x20,%ebx
f010344f:	39 de                	cmp    %ebx,%esi
f0103451:	76 62                	jbe    f01034b5 <env_create+0x104>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103453:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103456:	75 f4                	jne    f010344c <env_create+0x9b>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0103458:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010345b:	8b 53 08             	mov    0x8(%ebx),%edx
f010345e:	89 f8                	mov    %edi,%eax
f0103460:	e8 fe fb ff ff       	call   f0103063 <region_alloc>
			lcr3(PADDR(e->env_pgdir));
f0103465:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103468:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010346d:	76 b3                	jbe    f0103422 <env_create+0x71>
	return (physaddr_t)kva - KERNBASE;
f010346f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103474:	0f 22 d8             	mov    %eax,%cr3
			memset((void*)ph->p_va, 0, ph->p_memsz);
f0103477:	83 ec 04             	sub    $0x4,%esp
f010347a:	ff 73 14             	pushl  0x14(%ebx)
f010347d:	6a 00                	push   $0x0
f010347f:	ff 73 08             	pushl  0x8(%ebx)
f0103482:	e8 bf 1f 00 00       	call   f0105446 <memset>
			memcpy((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103487:	83 c4 0c             	add    $0xc,%esp
f010348a:	ff 73 10             	pushl  0x10(%ebx)
f010348d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103490:	03 43 04             	add    0x4(%ebx),%eax
f0103493:	50                   	push   %eax
f0103494:	ff 73 08             	pushl  0x8(%ebx)
f0103497:	e8 5f 20 00 00       	call   f01054fb <memcpy>
			lcr3(PADDR(kern_pgdir));
f010349c:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034a1:	83 c4 10             	add    $0x10,%esp
f01034a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034a9:	76 8c                	jbe    f0103437 <env_create+0x86>
	return (physaddr_t)kva - KERNBASE;
f01034ab:	05 00 00 00 10       	add    $0x10000000,%eax
f01034b0:	0f 22 d8             	mov    %eax,%cr3
f01034b3:	eb 97                	jmp    f010344c <env_create+0x9b>
	region_alloc(e, (void*)USTACKTOP - PGSIZE, PGSIZE);
f01034b5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01034ba:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01034bf:	89 f8                	mov    %edi,%eax
f01034c1:	e8 9d fb ff ff       	call   f0103063 <region_alloc>
	e->env_tf.tf_eip = Elf_header->e_entry;
f01034c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c9:	8b 40 18             	mov    0x18(%eax),%eax
f01034cc:	89 47 30             	mov    %eax,0x30(%edi)
	new_env->env_parent_id = 0;
f01034cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034d2:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)

}
f01034d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034dc:	5b                   	pop    %ebx
f01034dd:	5e                   	pop    %esi
f01034de:	5f                   	pop    %edi
f01034df:	5d                   	pop    %ebp
f01034e0:	c3                   	ret    

f01034e1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034e1:	55                   	push   %ebp
f01034e2:	89 e5                	mov    %esp,%ebp
f01034e4:	57                   	push   %edi
f01034e5:	56                   	push   %esi
f01034e6:	53                   	push   %ebx
f01034e7:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034ea:	e8 7c 25 00 00       	call   f0105a6b <cpunum>
f01034ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01034f2:	8b 55 08             	mov    0x8(%ebp),%edx
f01034f5:	39 90 28 e0 22 f0    	cmp    %edx,-0xfdd1fd8(%eax)
f01034fb:	75 14                	jne    f0103511 <env_free+0x30>
		lcr3(PADDR(kern_pgdir));
f01034fd:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103502:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103507:	76 56                	jbe    f010355f <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103509:	05 00 00 00 10       	add    $0x10000000,%eax
f010350e:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103511:	8b 45 08             	mov    0x8(%ebp),%eax
f0103514:	8b 58 48             	mov    0x48(%eax),%ebx
f0103517:	e8 4f 25 00 00       	call   f0105a6b <cpunum>
f010351c:	6b c0 74             	imul   $0x74,%eax,%eax
f010351f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103524:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f010352b:	74 11                	je     f010353e <env_free+0x5d>
f010352d:	e8 39 25 00 00       	call   f0105a6b <cpunum>
f0103532:	6b c0 74             	imul   $0x74,%eax,%eax
f0103535:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f010353b:	8b 50 48             	mov    0x48(%eax),%edx
f010353e:	83 ec 04             	sub    $0x4,%esp
f0103541:	53                   	push   %ebx
f0103542:	52                   	push   %edx
f0103543:	68 37 73 10 f0       	push   $0xf0107337
f0103548:	e8 84 04 00 00       	call   f01039d1 <cprintf>
f010354d:	83 c4 10             	add    $0x10,%esp
f0103550:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103557:	8b 7d 08             	mov    0x8(%ebp),%edi
f010355a:	e9 8f 00 00 00       	jmp    f01035ee <env_free+0x10d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010355f:	50                   	push   %eax
f0103560:	68 e8 60 10 f0       	push   $0xf01060e8
f0103565:	68 a5 01 00 00       	push   $0x1a5
f010356a:	68 de 72 10 f0       	push   $0xf01072de
f010356f:	e8 cc ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103574:	50                   	push   %eax
f0103575:	68 c4 60 10 f0       	push   $0xf01060c4
f010357a:	68 b4 01 00 00       	push   $0x1b4
f010357f:	68 de 72 10 f0       	push   $0xf01072de
f0103584:	e8 b7 ca ff ff       	call   f0100040 <_panic>
f0103589:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010358c:	39 f3                	cmp    %esi,%ebx
f010358e:	74 21                	je     f01035b1 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103590:	f6 03 01             	testb  $0x1,(%ebx)
f0103593:	74 f4                	je     f0103589 <env_free+0xa8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103595:	83 ec 08             	sub    $0x8,%esp
f0103598:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010359b:	01 d8                	add    %ebx,%eax
f010359d:	c1 e0 0a             	shl    $0xa,%eax
f01035a0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01035a3:	50                   	push   %eax
f01035a4:	ff 77 60             	pushl  0x60(%edi)
f01035a7:	e8 80 dc ff ff       	call   f010122c <page_remove>
f01035ac:	83 c4 10             	add    $0x10,%esp
f01035af:	eb d8                	jmp    f0103589 <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035b1:	8b 47 60             	mov    0x60(%edi),%eax
f01035b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035b7:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01035be:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035c1:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f01035c7:	73 6a                	jae    f0103633 <env_free+0x152>
		page_decref(pa2page(pa));
f01035c9:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035cc:	a1 90 de 22 f0       	mov    0xf022de90,%eax
f01035d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035d4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035d7:	50                   	push   %eax
f01035d8:	e8 2b da ff ff       	call   f0101008 <page_decref>
f01035dd:	83 c4 10             	add    $0x10,%esp
f01035e0:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01035e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035e7:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01035ec:	74 59                	je     f0103647 <env_free+0x166>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035ee:	8b 47 60             	mov    0x60(%edi),%eax
f01035f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035f4:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01035f7:	a8 01                	test   $0x1,%al
f01035f9:	74 e5                	je     f01035e0 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103600:	89 c2                	mov    %eax,%edx
f0103602:	c1 ea 0c             	shr    $0xc,%edx
f0103605:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103608:	39 15 88 de 22 f0    	cmp    %edx,0xf022de88
f010360e:	0f 86 60 ff ff ff    	jbe    f0103574 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f0103614:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010361a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010361d:	c1 e2 14             	shl    $0x14,%edx
f0103620:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103623:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103629:	f7 d8                	neg    %eax
f010362b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010362e:	e9 5d ff ff ff       	jmp    f0103590 <env_free+0xaf>
		panic("pa2page called with invalid pa");
f0103633:	83 ec 04             	sub    $0x4,%esp
f0103636:	68 50 67 10 f0       	push   $0xf0106750
f010363b:	6a 51                	push   $0x51
f010363d:	68 95 6f 10 f0       	push   $0xf0106f95
f0103642:	e8 f9 c9 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103647:	8b 45 08             	mov    0x8(%ebp),%eax
f010364a:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010364d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103652:	76 52                	jbe    f01036a6 <env_free+0x1c5>
	e->env_pgdir = 0;
f0103654:	8b 55 08             	mov    0x8(%ebp),%edx
f0103657:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f010365e:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103663:	c1 e8 0c             	shr    $0xc,%eax
f0103666:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f010366c:	73 4d                	jae    f01036bb <env_free+0x1da>
	page_decref(pa2page(pa));
f010366e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103671:	8b 15 90 de 22 f0    	mov    0xf022de90,%edx
f0103677:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010367a:	50                   	push   %eax
f010367b:	e8 88 d9 ff ff       	call   f0101008 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103680:	8b 45 08             	mov    0x8(%ebp),%eax
f0103683:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010368a:	a1 4c d2 22 f0       	mov    0xf022d24c,%eax
f010368f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103692:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103695:	89 15 4c d2 22 f0    	mov    %edx,0xf022d24c
}
f010369b:	83 c4 10             	add    $0x10,%esp
f010369e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036a1:	5b                   	pop    %ebx
f01036a2:	5e                   	pop    %esi
f01036a3:	5f                   	pop    %edi
f01036a4:	5d                   	pop    %ebp
f01036a5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036a6:	50                   	push   %eax
f01036a7:	68 e8 60 10 f0       	push   $0xf01060e8
f01036ac:	68 c2 01 00 00       	push   $0x1c2
f01036b1:	68 de 72 10 f0       	push   $0xf01072de
f01036b6:	e8 85 c9 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01036bb:	83 ec 04             	sub    $0x4,%esp
f01036be:	68 50 67 10 f0       	push   $0xf0106750
f01036c3:	6a 51                	push   $0x51
f01036c5:	68 95 6f 10 f0       	push   $0xf0106f95
f01036ca:	e8 71 c9 ff ff       	call   f0100040 <_panic>

f01036cf <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01036cf:	55                   	push   %ebp
f01036d0:	89 e5                	mov    %esp,%ebp
f01036d2:	53                   	push   %ebx
f01036d3:	83 ec 04             	sub    $0x4,%esp
f01036d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01036d9:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01036dd:	74 21                	je     f0103700 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01036df:	83 ec 0c             	sub    $0xc,%esp
f01036e2:	53                   	push   %ebx
f01036e3:	e8 f9 fd ff ff       	call   f01034e1 <env_free>

	if (curenv == e) {
f01036e8:	e8 7e 23 00 00       	call   f0105a6b <cpunum>
f01036ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f0:	83 c4 10             	add    $0x10,%esp
f01036f3:	39 98 28 e0 22 f0    	cmp    %ebx,-0xfdd1fd8(%eax)
f01036f9:	74 1e                	je     f0103719 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01036fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036fe:	c9                   	leave  
f01036ff:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103700:	e8 66 23 00 00       	call   f0105a6b <cpunum>
f0103705:	6b c0 74             	imul   $0x74,%eax,%eax
f0103708:	39 98 28 e0 22 f0    	cmp    %ebx,-0xfdd1fd8(%eax)
f010370e:	74 cf                	je     f01036df <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103710:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103717:	eb e2                	jmp    f01036fb <env_destroy+0x2c>
		curenv = NULL;
f0103719:	e8 4d 23 00 00       	call   f0105a6b <cpunum>
f010371e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103721:	c7 80 28 e0 22 f0 00 	movl   $0x0,-0xfdd1fd8(%eax)
f0103728:	00 00 00 
		sched_yield();
f010372b:	e8 89 0d 00 00       	call   f01044b9 <sched_yield>

f0103730 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103730:	55                   	push   %ebp
f0103731:	89 e5                	mov    %esp,%ebp
f0103733:	53                   	push   %ebx
f0103734:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103737:	e8 2f 23 00 00       	call   f0105a6b <cpunum>
f010373c:	6b c0 74             	imul   $0x74,%eax,%eax
f010373f:	8b 98 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%ebx
f0103745:	e8 21 23 00 00       	call   f0105a6b <cpunum>
f010374a:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f010374d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103750:	61                   	popa   
f0103751:	07                   	pop    %es
f0103752:	1f                   	pop    %ds
f0103753:	83 c4 08             	add    $0x8,%esp
f0103756:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103757:	83 ec 04             	sub    $0x4,%esp
f010375a:	68 4d 73 10 f0       	push   $0xf010734d
f010375f:	68 f8 01 00 00       	push   $0x1f8
f0103764:	68 de 72 10 f0       	push   $0xf01072de
f0103769:	e8 d2 c8 ff ff       	call   f0100040 <_panic>

f010376e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010376e:	55                   	push   %ebp
f010376f:	89 e5                	mov    %esp,%ebp
f0103771:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103774:	e8 f2 22 00 00       	call   f0105a6b <cpunum>
f0103779:	6b c0 74             	imul   $0x74,%eax,%eax
f010377c:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f0103783:	74 14                	je     f0103799 <env_run+0x2b>
f0103785:	e8 e1 22 00 00       	call   f0105a6b <cpunum>
f010378a:	6b c0 74             	imul   $0x74,%eax,%eax
f010378d:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0103793:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103797:	74 77                	je     f0103810 <env_run+0xa2>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f0103799:	e8 cd 22 00 00       	call   f0105a6b <cpunum>
f010379e:	6b c0 74             	imul   $0x74,%eax,%eax
f01037a1:	8b 55 08             	mov    0x8(%ebp),%edx
f01037a4:	89 90 28 e0 22 f0    	mov    %edx,-0xfdd1fd8(%eax)
	curenv->env_runs++;
f01037aa:	e8 bc 22 00 00       	call   f0105a6b <cpunum>
f01037af:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b2:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f01037b8:	83 40 58 01          	addl   $0x1,0x58(%eax)
	curenv->env_status = ENV_RUNNING;
f01037bc:	e8 aa 22 00 00       	call   f0105a6b <cpunum>
f01037c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c4:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f01037ca:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037d1:	83 ec 0c             	sub    $0xc,%esp
f01037d4:	68 c0 13 12 f0       	push   $0xf01213c0
f01037d9:	e8 9a 25 00 00       	call   f0105d78 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037de:	f3 90                	pause  
	unlock_kernel();
	lcr3(PADDR(curenv->env_pgdir));
f01037e0:	e8 86 22 00 00       	call   f0105a6b <cpunum>
f01037e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e8:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f01037ee:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01037f1:	83 c4 10             	add    $0x10,%esp
f01037f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f9:	77 2f                	ja     f010382a <env_run+0xbc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037fb:	50                   	push   %eax
f01037fc:	68 e8 60 10 f0       	push   $0xf01060e8
f0103801:	68 1d 02 00 00       	push   $0x21d
f0103806:	68 de 72 10 f0       	push   $0xf01072de
f010380b:	e8 30 c8 ff ff       	call   f0100040 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103810:	e8 56 22 00 00       	call   f0105a6b <cpunum>
f0103815:	6b c0 74             	imul   $0x74,%eax,%eax
f0103818:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f010381e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103825:	e9 6f ff ff ff       	jmp    f0103799 <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f010382a:	05 00 00 00 10       	add    $0x10000000,%eax
f010382f:	0f 22 d8             	mov    %eax,%cr3
	
	env_pop_tf(&curenv->env_tf);
f0103832:	e8 34 22 00 00       	call   f0105a6b <cpunum>
f0103837:	83 ec 0c             	sub    $0xc,%esp
f010383a:	6b c0 74             	imul   $0x74,%eax,%eax
f010383d:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f0103843:	e8 e8 fe ff ff       	call   f0103730 <env_pop_tf>

f0103848 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103848:	55                   	push   %ebp
f0103849:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010384b:	8b 45 08             	mov    0x8(%ebp),%eax
f010384e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103853:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103854:	ba 71 00 00 00       	mov    $0x71,%edx
f0103859:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010385a:	0f b6 c0             	movzbl %al,%eax
}
f010385d:	5d                   	pop    %ebp
f010385e:	c3                   	ret    

f010385f <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010385f:	55                   	push   %ebp
f0103860:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103862:	8b 45 08             	mov    0x8(%ebp),%eax
f0103865:	ba 70 00 00 00       	mov    $0x70,%edx
f010386a:	ee                   	out    %al,(%dx)
f010386b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010386e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103873:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103874:	5d                   	pop    %ebp
f0103875:	c3                   	ret    

f0103876 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103876:	55                   	push   %ebp
f0103877:	89 e5                	mov    %esp,%ebp
f0103879:	56                   	push   %esi
f010387a:	53                   	push   %ebx
f010387b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010387e:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103884:	80 3d 50 d2 22 f0 00 	cmpb   $0x0,0xf022d250
f010388b:	75 07                	jne    f0103894 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010388d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103890:	5b                   	pop    %ebx
f0103891:	5e                   	pop    %esi
f0103892:	5d                   	pop    %ebp
f0103893:	c3                   	ret    
f0103894:	89 c6                	mov    %eax,%esi
f0103896:	ba 21 00 00 00       	mov    $0x21,%edx
f010389b:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010389c:	66 c1 e8 08          	shr    $0x8,%ax
f01038a0:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038a5:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01038a6:	83 ec 0c             	sub    $0xc,%esp
f01038a9:	68 59 73 10 f0       	push   $0xf0107359
f01038ae:	e8 1e 01 00 00       	call   f01039d1 <cprintf>
f01038b3:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01038b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01038bb:	0f b7 f6             	movzwl %si,%esi
f01038be:	f7 d6                	not    %esi
f01038c0:	eb 08                	jmp    f01038ca <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f01038c2:	83 c3 01             	add    $0x1,%ebx
f01038c5:	83 fb 10             	cmp    $0x10,%ebx
f01038c8:	74 18                	je     f01038e2 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01038ca:	0f a3 de             	bt     %ebx,%esi
f01038cd:	73 f3                	jae    f01038c2 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f01038cf:	83 ec 08             	sub    $0x8,%esp
f01038d2:	53                   	push   %ebx
f01038d3:	68 5f 78 10 f0       	push   $0xf010785f
f01038d8:	e8 f4 00 00 00       	call   f01039d1 <cprintf>
f01038dd:	83 c4 10             	add    $0x10,%esp
f01038e0:	eb e0                	jmp    f01038c2 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f01038e2:	83 ec 0c             	sub    $0xc,%esp
f01038e5:	68 96 72 10 f0       	push   $0xf0107296
f01038ea:	e8 e2 00 00 00       	call   f01039d1 <cprintf>
f01038ef:	83 c4 10             	add    $0x10,%esp
f01038f2:	eb 99                	jmp    f010388d <irq_setmask_8259A+0x17>

f01038f4 <pic_init>:
{
f01038f4:	55                   	push   %ebp
f01038f5:	89 e5                	mov    %esp,%ebp
f01038f7:	57                   	push   %edi
f01038f8:	56                   	push   %esi
f01038f9:	53                   	push   %ebx
f01038fa:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01038fd:	c6 05 50 d2 22 f0 01 	movb   $0x1,0xf022d250
f0103904:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103909:	bb 21 00 00 00       	mov    $0x21,%ebx
f010390e:	89 da                	mov    %ebx,%edx
f0103910:	ee                   	out    %al,(%dx)
f0103911:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103916:	89 ca                	mov    %ecx,%edx
f0103918:	ee                   	out    %al,(%dx)
f0103919:	bf 11 00 00 00       	mov    $0x11,%edi
f010391e:	be 20 00 00 00       	mov    $0x20,%esi
f0103923:	89 f8                	mov    %edi,%eax
f0103925:	89 f2                	mov    %esi,%edx
f0103927:	ee                   	out    %al,(%dx)
f0103928:	b8 20 00 00 00       	mov    $0x20,%eax
f010392d:	89 da                	mov    %ebx,%edx
f010392f:	ee                   	out    %al,(%dx)
f0103930:	b8 04 00 00 00       	mov    $0x4,%eax
f0103935:	ee                   	out    %al,(%dx)
f0103936:	b8 03 00 00 00       	mov    $0x3,%eax
f010393b:	ee                   	out    %al,(%dx)
f010393c:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103941:	89 f8                	mov    %edi,%eax
f0103943:	89 da                	mov    %ebx,%edx
f0103945:	ee                   	out    %al,(%dx)
f0103946:	b8 28 00 00 00       	mov    $0x28,%eax
f010394b:	89 ca                	mov    %ecx,%edx
f010394d:	ee                   	out    %al,(%dx)
f010394e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103953:	ee                   	out    %al,(%dx)
f0103954:	b8 01 00 00 00       	mov    $0x1,%eax
f0103959:	ee                   	out    %al,(%dx)
f010395a:	bf 68 00 00 00       	mov    $0x68,%edi
f010395f:	89 f8                	mov    %edi,%eax
f0103961:	89 f2                	mov    %esi,%edx
f0103963:	ee                   	out    %al,(%dx)
f0103964:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103969:	89 c8                	mov    %ecx,%eax
f010396b:	ee                   	out    %al,(%dx)
f010396c:	89 f8                	mov    %edi,%eax
f010396e:	89 da                	mov    %ebx,%edx
f0103970:	ee                   	out    %al,(%dx)
f0103971:	89 c8                	mov    %ecx,%eax
f0103973:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103974:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010397b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010397f:	74 0f                	je     f0103990 <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f0103981:	83 ec 0c             	sub    $0xc,%esp
f0103984:	0f b7 c0             	movzwl %ax,%eax
f0103987:	50                   	push   %eax
f0103988:	e8 e9 fe ff ff       	call   f0103876 <irq_setmask_8259A>
f010398d:	83 c4 10             	add    $0x10,%esp
}
f0103990:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103993:	5b                   	pop    %ebx
f0103994:	5e                   	pop    %esi
f0103995:	5f                   	pop    %edi
f0103996:	5d                   	pop    %ebp
f0103997:	c3                   	ret    

f0103998 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103998:	55                   	push   %ebp
f0103999:	89 e5                	mov    %esp,%ebp
f010399b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010399e:	ff 75 08             	pushl  0x8(%ebp)
f01039a1:	e8 de cd ff ff       	call   f0100784 <cputchar>
	*cnt++;
}
f01039a6:	83 c4 10             	add    $0x10,%esp
f01039a9:	c9                   	leave  
f01039aa:	c3                   	ret    

f01039ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039ab:	55                   	push   %ebp
f01039ac:	89 e5                	mov    %esp,%ebp
f01039ae:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01039b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039b8:	ff 75 0c             	pushl  0xc(%ebp)
f01039bb:	ff 75 08             	pushl  0x8(%ebp)
f01039be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039c1:	50                   	push   %eax
f01039c2:	68 98 39 10 f0       	push   $0xf0103998
f01039c7:	e8 36 13 00 00       	call   f0104d02 <vprintfmt>
	return cnt;
}
f01039cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039cf:	c9                   	leave  
f01039d0:	c3                   	ret    

f01039d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039d1:	55                   	push   %ebp
f01039d2:	89 e5                	mov    %esp,%ebp
f01039d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039da:	50                   	push   %eax
f01039db:	ff 75 08             	pushl  0x8(%ebp)
f01039de:	e8 c8 ff ff ff       	call   f01039ab <vcprintf>
	va_end(ap);

	return cnt;
}
f01039e3:	c9                   	leave  
f01039e4:	c3                   	ret    

f01039e5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039e5:	55                   	push   %ebp
f01039e6:	89 e5                	mov    %esp,%ebp
f01039e8:	57                   	push   %edi
f01039e9:	56                   	push   %esi
f01039ea:	53                   	push   %ebx
f01039eb:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//ts.ts_esp0 = KSTACKTOP;
	int cpuid = thiscpu->cpu_id;
f01039ee:	e8 78 20 00 00       	call   f0105a6b <cpunum>
f01039f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f6:	0f b6 b0 20 e0 22 f0 	movzbl -0xfdd1fe0(%eax),%esi
f01039fd:	89 f0                	mov    %esi,%eax
f01039ff:	0f b6 d8             	movzbl %al,%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpuid * (KSTKSIZE + KSTKGAP);
f0103a02:	e8 64 20 00 00       	call   f0105a6b <cpunum>
f0103a07:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a0a:	89 d9                	mov    %ebx,%ecx
f0103a0c:	c1 e1 10             	shl    $0x10,%ecx
f0103a0f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103a14:	29 ca                	sub    %ecx,%edx
f0103a16:	89 90 30 e0 22 f0    	mov    %edx,-0xfdd1fd0(%eax)
	//ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103a1c:	e8 4a 20 00 00       	call   f0105a6b <cpunum>
f0103a21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a24:	66 c7 80 34 e0 22 f0 	movw   $0x10,-0xfdd1fcc(%eax)
f0103a2b:	10 00 
	//ts.ts_iomb = sizeof(struct Taskstate);
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103a2d:	e8 39 20 00 00       	call   f0105a6b <cpunum>
f0103a32:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a35:	66 c7 80 92 e0 22 f0 	movw   $0x68,-0xfdd1f6e(%eax)
f0103a3c:	68 00 
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + (cpuid)] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103a3e:	83 c3 05             	add    $0x5,%ebx
f0103a41:	e8 25 20 00 00       	call   f0105a6b <cpunum>
f0103a46:	89 c7                	mov    %eax,%edi
f0103a48:	e8 1e 20 00 00       	call   f0105a6b <cpunum>
f0103a4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a50:	e8 16 20 00 00       	call   f0105a6b <cpunum>
f0103a55:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0103a5c:	f0 68 00 
f0103a5f:	6b ff 74             	imul   $0x74,%edi,%edi
f0103a62:	81 c7 2c e0 22 f0    	add    $0xf022e02c,%edi
f0103a68:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103a6f:	f0 
f0103a70:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a74:	81 c2 2c e0 22 f0    	add    $0xf022e02c,%edx
f0103a7a:	c1 ea 10             	shr    $0x10,%edx
f0103a7d:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103a84:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103a8b:	40 
f0103a8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a8f:	05 2c e0 22 f0       	add    $0xf022e02c,%eax
f0103a94:	c1 e8 18             	shr    $0x18,%eax
f0103a97:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + (cpuid)].sd_s = 0;
f0103a9e:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103aa5:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpuid << 3));
f0103aa6:	89 f0                	mov    %esi,%eax
f0103aa8:	0f b6 f0             	movzbl %al,%esi
f0103aab:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	asm volatile("ltr %0" : : "r" (sel));
f0103ab2:	0f 00 de             	ltr    %si
	asm volatile("lidt (%0)" : : "r" (p));
f0103ab5:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103aba:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
}
f0103abd:	83 c4 1c             	add    $0x1c,%esp
f0103ac0:	5b                   	pop    %ebx
f0103ac1:	5e                   	pop    %esi
f0103ac2:	5f                   	pop    %edi
f0103ac3:	5d                   	pop    %ebp
f0103ac4:	c3                   	ret    

f0103ac5 <trap_init>:
{
f0103ac5:	55                   	push   %ebp
f0103ac6:	89 e5                	mov    %esp,%ebp
f0103ac8:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[0], 0, GD_KT, th0, 0);
f0103acb:	b8 84 43 10 f0       	mov    $0xf0104384,%eax
f0103ad0:	66 a3 60 d2 22 f0    	mov    %ax,0xf022d260
f0103ad6:	66 c7 05 62 d2 22 f0 	movw   $0x8,0xf022d262
f0103add:	08 00 
f0103adf:	c6 05 64 d2 22 f0 00 	movb   $0x0,0xf022d264
f0103ae6:	c6 05 65 d2 22 f0 8e 	movb   $0x8e,0xf022d265
f0103aed:	c1 e8 10             	shr    $0x10,%eax
f0103af0:	66 a3 66 d2 22 f0    	mov    %ax,0xf022d266
	SETGATE(idt[1], 0, GD_KT, th1, 0);
f0103af6:	b8 8a 43 10 f0       	mov    $0xf010438a,%eax
f0103afb:	66 a3 68 d2 22 f0    	mov    %ax,0xf022d268
f0103b01:	66 c7 05 6a d2 22 f0 	movw   $0x8,0xf022d26a
f0103b08:	08 00 
f0103b0a:	c6 05 6c d2 22 f0 00 	movb   $0x0,0xf022d26c
f0103b11:	c6 05 6d d2 22 f0 8e 	movb   $0x8e,0xf022d26d
f0103b18:	c1 e8 10             	shr    $0x10,%eax
f0103b1b:	66 a3 6e d2 22 f0    	mov    %ax,0xf022d26e
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f0103b21:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103b26:	66 a3 78 d2 22 f0    	mov    %ax,0xf022d278
f0103b2c:	66 c7 05 7a d2 22 f0 	movw   $0x8,0xf022d27a
f0103b33:	08 00 
f0103b35:	c6 05 7c d2 22 f0 00 	movb   $0x0,0xf022d27c
f0103b3c:	c6 05 7d d2 22 f0 ee 	movb   $0xee,0xf022d27d
f0103b43:	c1 e8 10             	shr    $0x10,%eax
f0103b46:	66 a3 7e d2 22 f0    	mov    %ax,0xf022d27e
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103b4c:	b8 96 43 10 f0       	mov    $0xf0104396,%eax
f0103b51:	66 a3 80 d2 22 f0    	mov    %ax,0xf022d280
f0103b57:	66 c7 05 82 d2 22 f0 	movw   $0x8,0xf022d282
f0103b5e:	08 00 
f0103b60:	c6 05 84 d2 22 f0 00 	movb   $0x0,0xf022d284
f0103b67:	c6 05 85 d2 22 f0 8e 	movb   $0x8e,0xf022d285
f0103b6e:	c1 e8 10             	shr    $0x10,%eax
f0103b71:	66 a3 86 d2 22 f0    	mov    %ax,0xf022d286
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f0103b77:	b8 9c 43 10 f0       	mov    $0xf010439c,%eax
f0103b7c:	66 a3 88 d2 22 f0    	mov    %ax,0xf022d288
f0103b82:	66 c7 05 8a d2 22 f0 	movw   $0x8,0xf022d28a
f0103b89:	08 00 
f0103b8b:	c6 05 8c d2 22 f0 00 	movb   $0x0,0xf022d28c
f0103b92:	c6 05 8d d2 22 f0 8e 	movb   $0x8e,0xf022d28d
f0103b99:	c1 e8 10             	shr    $0x10,%eax
f0103b9c:	66 a3 8e d2 22 f0    	mov    %ax,0xf022d28e
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f0103ba2:	b8 a2 43 10 f0       	mov    $0xf01043a2,%eax
f0103ba7:	66 a3 90 d2 22 f0    	mov    %ax,0xf022d290
f0103bad:	66 c7 05 92 d2 22 f0 	movw   $0x8,0xf022d292
f0103bb4:	08 00 
f0103bb6:	c6 05 94 d2 22 f0 00 	movb   $0x0,0xf022d294
f0103bbd:	c6 05 95 d2 22 f0 8e 	movb   $0x8e,0xf022d295
f0103bc4:	c1 e8 10             	shr    $0x10,%eax
f0103bc7:	66 a3 96 d2 22 f0    	mov    %ax,0xf022d296
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103bcd:	b8 a8 43 10 f0       	mov    $0xf01043a8,%eax
f0103bd2:	66 a3 98 d2 22 f0    	mov    %ax,0xf022d298
f0103bd8:	66 c7 05 9a d2 22 f0 	movw   $0x8,0xf022d29a
f0103bdf:	08 00 
f0103be1:	c6 05 9c d2 22 f0 00 	movb   $0x0,0xf022d29c
f0103be8:	c6 05 9d d2 22 f0 8e 	movb   $0x8e,0xf022d29d
f0103bef:	c1 e8 10             	shr    $0x10,%eax
f0103bf2:	66 a3 9e d2 22 f0    	mov    %ax,0xf022d29e
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103bf8:	b8 ae 43 10 f0       	mov    $0xf01043ae,%eax
f0103bfd:	66 a3 a0 d2 22 f0    	mov    %ax,0xf022d2a0
f0103c03:	66 c7 05 a2 d2 22 f0 	movw   $0x8,0xf022d2a2
f0103c0a:	08 00 
f0103c0c:	c6 05 a4 d2 22 f0 00 	movb   $0x0,0xf022d2a4
f0103c13:	c6 05 a5 d2 22 f0 8e 	movb   $0x8e,0xf022d2a5
f0103c1a:	c1 e8 10             	shr    $0x10,%eax
f0103c1d:	66 a3 a6 d2 22 f0    	mov    %ax,0xf022d2a6
	SETGATE(idt[9], 0, GD_KT, th9, 0);
f0103c23:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f0103c28:	66 a3 a8 d2 22 f0    	mov    %ax,0xf022d2a8
f0103c2e:	66 c7 05 aa d2 22 f0 	movw   $0x8,0xf022d2aa
f0103c35:	08 00 
f0103c37:	c6 05 ac d2 22 f0 00 	movb   $0x0,0xf022d2ac
f0103c3e:	c6 05 ad d2 22 f0 8e 	movb   $0x8e,0xf022d2ad
f0103c45:	c1 e8 10             	shr    $0x10,%eax
f0103c48:	66 a3 ae d2 22 f0    	mov    %ax,0xf022d2ae
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103c4e:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f0103c53:	66 a3 b0 d2 22 f0    	mov    %ax,0xf022d2b0
f0103c59:	66 c7 05 b2 d2 22 f0 	movw   $0x8,0xf022d2b2
f0103c60:	08 00 
f0103c62:	c6 05 b4 d2 22 f0 00 	movb   $0x0,0xf022d2b4
f0103c69:	c6 05 b5 d2 22 f0 8e 	movb   $0x8e,0xf022d2b5
f0103c70:	c1 e8 10             	shr    $0x10,%eax
f0103c73:	66 a3 b6 d2 22 f0    	mov    %ax,0xf022d2b6
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f0103c79:	b8 bc 43 10 f0       	mov    $0xf01043bc,%eax
f0103c7e:	66 a3 b8 d2 22 f0    	mov    %ax,0xf022d2b8
f0103c84:	66 c7 05 ba d2 22 f0 	movw   $0x8,0xf022d2ba
f0103c8b:	08 00 
f0103c8d:	c6 05 bc d2 22 f0 00 	movb   $0x0,0xf022d2bc
f0103c94:	c6 05 bd d2 22 f0 8e 	movb   $0x8e,0xf022d2bd
f0103c9b:	c1 e8 10             	shr    $0x10,%eax
f0103c9e:	66 a3 be d2 22 f0    	mov    %ax,0xf022d2be
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f0103ca4:	b8 c0 43 10 f0       	mov    $0xf01043c0,%eax
f0103ca9:	66 a3 c0 d2 22 f0    	mov    %ax,0xf022d2c0
f0103caf:	66 c7 05 c2 d2 22 f0 	movw   $0x8,0xf022d2c2
f0103cb6:	08 00 
f0103cb8:	c6 05 c4 d2 22 f0 00 	movb   $0x0,0xf022d2c4
f0103cbf:	c6 05 c5 d2 22 f0 8e 	movb   $0x8e,0xf022d2c5
f0103cc6:	c1 e8 10             	shr    $0x10,%eax
f0103cc9:	66 a3 c6 d2 22 f0    	mov    %ax,0xf022d2c6
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103ccf:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103cd4:	66 a3 c8 d2 22 f0    	mov    %ax,0xf022d2c8
f0103cda:	66 c7 05 ca d2 22 f0 	movw   $0x8,0xf022d2ca
f0103ce1:	08 00 
f0103ce3:	c6 05 cc d2 22 f0 00 	movb   $0x0,0xf022d2cc
f0103cea:	c6 05 cd d2 22 f0 8e 	movb   $0x8e,0xf022d2cd
f0103cf1:	c1 e8 10             	shr    $0x10,%eax
f0103cf4:	66 a3 ce d2 22 f0    	mov    %ax,0xf022d2ce
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103cfa:	b8 c8 43 10 f0       	mov    $0xf01043c8,%eax
f0103cff:	66 a3 d0 d2 22 f0    	mov    %ax,0xf022d2d0
f0103d05:	66 c7 05 d2 d2 22 f0 	movw   $0x8,0xf022d2d2
f0103d0c:	08 00 
f0103d0e:	c6 05 d4 d2 22 f0 00 	movb   $0x0,0xf022d2d4
f0103d15:	c6 05 d5 d2 22 f0 8e 	movb   $0x8e,0xf022d2d5
f0103d1c:	c1 e8 10             	shr    $0x10,%eax
f0103d1f:	66 a3 d6 d2 22 f0    	mov    %ax,0xf022d2d6
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103d25:	b8 cc 43 10 f0       	mov    $0xf01043cc,%eax
f0103d2a:	66 a3 e0 d2 22 f0    	mov    %ax,0xf022d2e0
f0103d30:	66 c7 05 e2 d2 22 f0 	movw   $0x8,0xf022d2e2
f0103d37:	08 00 
f0103d39:	c6 05 e4 d2 22 f0 00 	movb   $0x0,0xf022d2e4
f0103d40:	c6 05 e5 d2 22 f0 8e 	movb   $0x8e,0xf022d2e5
f0103d47:	c1 e8 10             	shr    $0x10,%eax
f0103d4a:	66 a3 e6 d2 22 f0    	mov    %ax,0xf022d2e6
	SETGATE(idt[48], 0, GD_KT, th48, 3);
f0103d50:	b8 d0 43 10 f0       	mov    $0xf01043d0,%eax
f0103d55:	66 a3 e0 d3 22 f0    	mov    %ax,0xf022d3e0
f0103d5b:	66 c7 05 e2 d3 22 f0 	movw   $0x8,0xf022d3e2
f0103d62:	08 00 
f0103d64:	c6 05 e4 d3 22 f0 00 	movb   $0x0,0xf022d3e4
f0103d6b:	c6 05 e5 d3 22 f0 ee 	movb   $0xee,0xf022d3e5
f0103d72:	c1 e8 10             	shr    $0x10,%eax
f0103d75:	66 a3 e6 d3 22 f0    	mov    %ax,0xf022d3e6
	trap_init_percpu();
f0103d7b:	e8 65 fc ff ff       	call   f01039e5 <trap_init_percpu>
}
f0103d80:	c9                   	leave  
f0103d81:	c3                   	ret    

f0103d82 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d82:	55                   	push   %ebp
f0103d83:	89 e5                	mov    %esp,%ebp
f0103d85:	53                   	push   %ebx
f0103d86:	83 ec 0c             	sub    $0xc,%esp
f0103d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d8c:	ff 33                	pushl  (%ebx)
f0103d8e:	68 6d 73 10 f0       	push   $0xf010736d
f0103d93:	e8 39 fc ff ff       	call   f01039d1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d98:	83 c4 08             	add    $0x8,%esp
f0103d9b:	ff 73 04             	pushl  0x4(%ebx)
f0103d9e:	68 7c 73 10 f0       	push   $0xf010737c
f0103da3:	e8 29 fc ff ff       	call   f01039d1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103da8:	83 c4 08             	add    $0x8,%esp
f0103dab:	ff 73 08             	pushl  0x8(%ebx)
f0103dae:	68 8b 73 10 f0       	push   $0xf010738b
f0103db3:	e8 19 fc ff ff       	call   f01039d1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103db8:	83 c4 08             	add    $0x8,%esp
f0103dbb:	ff 73 0c             	pushl  0xc(%ebx)
f0103dbe:	68 9a 73 10 f0       	push   $0xf010739a
f0103dc3:	e8 09 fc ff ff       	call   f01039d1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103dc8:	83 c4 08             	add    $0x8,%esp
f0103dcb:	ff 73 10             	pushl  0x10(%ebx)
f0103dce:	68 a9 73 10 f0       	push   $0xf01073a9
f0103dd3:	e8 f9 fb ff ff       	call   f01039d1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103dd8:	83 c4 08             	add    $0x8,%esp
f0103ddb:	ff 73 14             	pushl  0x14(%ebx)
f0103dde:	68 b8 73 10 f0       	push   $0xf01073b8
f0103de3:	e8 e9 fb ff ff       	call   f01039d1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103de8:	83 c4 08             	add    $0x8,%esp
f0103deb:	ff 73 18             	pushl  0x18(%ebx)
f0103dee:	68 c7 73 10 f0       	push   $0xf01073c7
f0103df3:	e8 d9 fb ff ff       	call   f01039d1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103df8:	83 c4 08             	add    $0x8,%esp
f0103dfb:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dfe:	68 d6 73 10 f0       	push   $0xf01073d6
f0103e03:	e8 c9 fb ff ff       	call   f01039d1 <cprintf>
}
f0103e08:	83 c4 10             	add    $0x10,%esp
f0103e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e0e:	c9                   	leave  
f0103e0f:	c3                   	ret    

f0103e10 <print_trapframe>:
{
f0103e10:	55                   	push   %ebp
f0103e11:	89 e5                	mov    %esp,%ebp
f0103e13:	56                   	push   %esi
f0103e14:	53                   	push   %ebx
f0103e15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e18:	e8 4e 1c 00 00       	call   f0105a6b <cpunum>
f0103e1d:	83 ec 04             	sub    $0x4,%esp
f0103e20:	50                   	push   %eax
f0103e21:	53                   	push   %ebx
f0103e22:	68 3a 74 10 f0       	push   $0xf010743a
f0103e27:	e8 a5 fb ff ff       	call   f01039d1 <cprintf>
	print_regs(&tf->tf_regs);
f0103e2c:	89 1c 24             	mov    %ebx,(%esp)
f0103e2f:	e8 4e ff ff ff       	call   f0103d82 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e34:	83 c4 08             	add    $0x8,%esp
f0103e37:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e3b:	50                   	push   %eax
f0103e3c:	68 58 74 10 f0       	push   $0xf0107458
f0103e41:	e8 8b fb ff ff       	call   f01039d1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e46:	83 c4 08             	add    $0x8,%esp
f0103e49:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e4d:	50                   	push   %eax
f0103e4e:	68 6b 74 10 f0       	push   $0xf010746b
f0103e53:	e8 79 fb ff ff       	call   f01039d1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e58:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103e5b:	83 c4 10             	add    $0x10,%esp
f0103e5e:	83 f8 13             	cmp    $0x13,%eax
f0103e61:	76 1f                	jbe    f0103e82 <print_trapframe+0x72>
		return "System call";
f0103e63:	ba e5 73 10 f0       	mov    $0xf01073e5,%edx
	if (trapno == T_SYSCALL)
f0103e68:	83 f8 30             	cmp    $0x30,%eax
f0103e6b:	74 1c                	je     f0103e89 <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e6d:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0103e70:	83 fa 10             	cmp    $0x10,%edx
f0103e73:	ba f1 73 10 f0       	mov    $0xf01073f1,%edx
f0103e78:	b9 04 74 10 f0       	mov    $0xf0107404,%ecx
f0103e7d:	0f 43 d1             	cmovae %ecx,%edx
f0103e80:	eb 07                	jmp    f0103e89 <print_trapframe+0x79>
		return excnames[trapno];
f0103e82:	8b 14 85 40 77 10 f0 	mov    -0xfef88c0(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e89:	83 ec 04             	sub    $0x4,%esp
f0103e8c:	52                   	push   %edx
f0103e8d:	50                   	push   %eax
f0103e8e:	68 7e 74 10 f0       	push   $0xf010747e
f0103e93:	e8 39 fb ff ff       	call   f01039d1 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e98:	83 c4 10             	add    $0x10,%esp
f0103e9b:	39 1d 60 da 22 f0    	cmp    %ebx,0xf022da60
f0103ea1:	0f 84 a6 00 00 00    	je     f0103f4d <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103ea7:	83 ec 08             	sub    $0x8,%esp
f0103eaa:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ead:	68 9f 74 10 f0       	push   $0xf010749f
f0103eb2:	e8 1a fb ff ff       	call   f01039d1 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103eb7:	83 c4 10             	add    $0x10,%esp
f0103eba:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ebe:	0f 85 ac 00 00 00    	jne    f0103f70 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ec4:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103ec7:	89 c2                	mov    %eax,%edx
f0103ec9:	83 e2 01             	and    $0x1,%edx
f0103ecc:	b9 13 74 10 f0       	mov    $0xf0107413,%ecx
f0103ed1:	ba 1e 74 10 f0       	mov    $0xf010741e,%edx
f0103ed6:	0f 44 ca             	cmove  %edx,%ecx
f0103ed9:	89 c2                	mov    %eax,%edx
f0103edb:	83 e2 02             	and    $0x2,%edx
f0103ede:	be 2a 74 10 f0       	mov    $0xf010742a,%esi
f0103ee3:	ba 30 74 10 f0       	mov    $0xf0107430,%edx
f0103ee8:	0f 45 d6             	cmovne %esi,%edx
f0103eeb:	83 e0 04             	and    $0x4,%eax
f0103eee:	b8 35 74 10 f0       	mov    $0xf0107435,%eax
f0103ef3:	be 97 75 10 f0       	mov    $0xf0107597,%esi
f0103ef8:	0f 44 c6             	cmove  %esi,%eax
f0103efb:	51                   	push   %ecx
f0103efc:	52                   	push   %edx
f0103efd:	50                   	push   %eax
f0103efe:	68 ad 74 10 f0       	push   $0xf01074ad
f0103f03:	e8 c9 fa ff ff       	call   f01039d1 <cprintf>
f0103f08:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f0b:	83 ec 08             	sub    $0x8,%esp
f0103f0e:	ff 73 30             	pushl  0x30(%ebx)
f0103f11:	68 bc 74 10 f0       	push   $0xf01074bc
f0103f16:	e8 b6 fa ff ff       	call   f01039d1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f1b:	83 c4 08             	add    $0x8,%esp
f0103f1e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f22:	50                   	push   %eax
f0103f23:	68 cb 74 10 f0       	push   $0xf01074cb
f0103f28:	e8 a4 fa ff ff       	call   f01039d1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f2d:	83 c4 08             	add    $0x8,%esp
f0103f30:	ff 73 38             	pushl  0x38(%ebx)
f0103f33:	68 de 74 10 f0       	push   $0xf01074de
f0103f38:	e8 94 fa ff ff       	call   f01039d1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f3d:	83 c4 10             	add    $0x10,%esp
f0103f40:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f44:	75 3c                	jne    f0103f82 <print_trapframe+0x172>
}
f0103f46:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f49:	5b                   	pop    %ebx
f0103f4a:	5e                   	pop    %esi
f0103f4b:	5d                   	pop    %ebp
f0103f4c:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f4d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f51:	0f 85 50 ff ff ff    	jne    f0103ea7 <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f57:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f5a:	83 ec 08             	sub    $0x8,%esp
f0103f5d:	50                   	push   %eax
f0103f5e:	68 90 74 10 f0       	push   $0xf0107490
f0103f63:	e8 69 fa ff ff       	call   f01039d1 <cprintf>
f0103f68:	83 c4 10             	add    $0x10,%esp
f0103f6b:	e9 37 ff ff ff       	jmp    f0103ea7 <print_trapframe+0x97>
		cprintf("\n");
f0103f70:	83 ec 0c             	sub    $0xc,%esp
f0103f73:	68 96 72 10 f0       	push   $0xf0107296
f0103f78:	e8 54 fa ff ff       	call   f01039d1 <cprintf>
f0103f7d:	83 c4 10             	add    $0x10,%esp
f0103f80:	eb 89                	jmp    f0103f0b <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f82:	83 ec 08             	sub    $0x8,%esp
f0103f85:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f88:	68 ed 74 10 f0       	push   $0xf01074ed
f0103f8d:	e8 3f fa ff ff       	call   f01039d1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f92:	83 c4 08             	add    $0x8,%esp
f0103f95:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f99:	50                   	push   %eax
f0103f9a:	68 fc 74 10 f0       	push   $0xf01074fc
f0103f9f:	e8 2d fa ff ff       	call   f01039d1 <cprintf>
f0103fa4:	83 c4 10             	add    $0x10,%esp
}
f0103fa7:	eb 9d                	jmp    f0103f46 <print_trapframe+0x136>

f0103fa9 <page_fault_handler>:
{
	return esp > (UXSTACKTOP - PGSIZE) && esp <= (UXSTACKTOP - 1);
}
void
page_fault_handler(struct Trapframe *tf)
{
f0103fa9:	55                   	push   %ebp
f0103faa:	89 e5                	mov    %esp,%ebp
f0103fac:	57                   	push   %edi
f0103fad:	56                   	push   %esi
f0103fae:	53                   	push   %ebx
f0103faf:	83 ec 3c             	sub    $0x3c,%esp
f0103fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fb5:	0f 20 d7             	mov    %cr2,%edi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// if page faults happended in kernel mode, we just panic
	if (tf->tf_cs == GD_KT) {
f0103fb8:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103fbd:	74 7d                	je     f010403c <page_fault_handler+0x93>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct Env *trap_env = (struct Env*)curenv;
f0103fbf:	e8 a7 1a 00 00       	call   f0105a6b <cpunum>
f0103fc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc7:	8b b0 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%esi
	if (trap_env->env_pgfault_upcall) {
f0103fcd:	83 7e 64 00          	cmpl   $0x0,0x64(%esi)
f0103fd1:	0f 84 4d 01 00 00    	je     f0104124 <page_fault_handler+0x17b>
		// allocate  an exception stack
		uintptr_t exception_stack_top =UXSTACKTOP;
		if (trap_from_exception(tf->tf_esp)) {
f0103fd7:	8b 43 3c             	mov    0x3c(%ebx),%eax
	return esp > (UXSTACKTOP - PGSIZE) && esp <= (UXSTACKTOP - 1);
f0103fda:	8d 90 ff 0f 40 11    	lea    0x11400fff(%eax),%edx
		if (trap_from_exception(tf->tf_esp)) {
f0103fe0:	81 fa fe 0f 00 00    	cmp    $0xffe,%edx
f0103fe6:	77 73                	ja     f010405b <page_fault_handler+0xb2>
			// trap recursively from current exception stack
			exception_stack_top = tf->tf_esp - 4;
		} else {
			exception_stack_top = UXSTACKTOP;
		}
		int32_t current_exception_stack_size = exception_stack_top - (UXSTACKTOP - PGSIZE);
f0103fe8:	8d 90 fc 0f 40 11    	lea    0x11400ffc(%eax),%edx
		if (current_exception_stack_size > sizeof(struct UTrapframe)) {
f0103fee:	83 fa 34             	cmp    $0x34,%edx
f0103ff1:	77 60                	ja     f0104053 <page_fault_handler+0xaa>
		}
	} else {
		cprintf("env pagefault upcall is none!");
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ff3:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ff6:	e8 70 1a 00 00       	call   f0105a6b <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ffb:	56                   	push   %esi
f0103ffc:	57                   	push   %edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ffd:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104000:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0104006:	ff 70 48             	pushl  0x48(%eax)
f0104009:	68 18 77 10 f0       	push   $0xf0107718
f010400e:	e8 be f9 ff ff       	call   f01039d1 <cprintf>
	print_trapframe(tf);
f0104013:	89 1c 24             	mov    %ebx,(%esp)
f0104016:	e8 f5 fd ff ff       	call   f0103e10 <print_trapframe>
	env_destroy(curenv);
f010401b:	e8 4b 1a 00 00       	call   f0105a6b <cpunum>
f0104020:	83 c4 04             	add    $0x4,%esp
f0104023:	6b c0 74             	imul   $0x74,%eax,%eax
f0104026:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f010402c:	e8 9e f6 ff ff       	call   f01036cf <env_destroy>
}
f0104031:	83 c4 10             	add    $0x10,%esp
f0104034:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104037:	5b                   	pop    %ebx
f0104038:	5e                   	pop    %esi
f0104039:	5f                   	pop    %edi
f010403a:	5d                   	pop    %ebp
f010403b:	c3                   	ret    
		panic("Page faults happened in kernel mode!");
f010403c:	83 ec 04             	sub    $0x4,%esp
f010403f:	68 f0 76 10 f0       	push   $0xf01076f0
f0104044:	68 53 01 00 00       	push   $0x153
f0104049:	68 0f 75 10 f0       	push   $0xf010750f
f010404e:	e8 ed bf ff ff       	call   f0100040 <_panic>
			exception_stack_top = tf->tf_esp - 4;
f0104053:	83 e8 04             	sub    $0x4,%eax
f0104056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104059:	eb 0c                	jmp    f0104067 <page_fault_handler+0xbe>
			exception_stack_top = UXSTACKTOP;
f010405b:	c7 45 e4 00 00 c0 ee 	movl   $0xeec00000,-0x1c(%ebp)
		int32_t current_exception_stack_size = exception_stack_top - (UXSTACKTOP - PGSIZE);
f0104062:	ba 00 10 00 00       	mov    $0x1000,%edx
 			user_mem_assert(trap_env, (const void*)exception_stack_top, current_exception_stack_size, PTE_W & PTE_U);
f0104067:	6a 00                	push   $0x0
f0104069:	52                   	push   %edx
f010406a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010406d:	56                   	push   %esi
f010406e:	e8 a4 ef ff ff       	call   f0103017 <user_mem_assert>
			struct UTrapframe user_pf_trapframe = {fault_va, tf->tf_err, tf->tf_regs, tf->tf_eip, tf->tf_eflags, tf->tf_esp};
f0104073:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104076:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104079:	8b 13                	mov    (%ebx),%edx
f010407b:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010407e:	8b 43 04             	mov    0x4(%ebx),%eax
f0104081:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104084:	8b 43 08             	mov    0x8(%ebx),%eax
f0104087:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010408a:	8b 53 0c             	mov    0xc(%ebx),%edx
f010408d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104090:	8b 43 10             	mov    0x10(%ebx),%eax
f0104093:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104096:	8b 43 14             	mov    0x14(%ebx),%eax
f0104099:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010409c:	8b 53 18             	mov    0x18(%ebx),%edx
f010409f:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01040a2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01040a5:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01040a8:	8b 43 30             	mov    0x30(%ebx),%eax
f01040ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01040ae:	8b 53 38             	mov    0x38(%ebx),%edx
f01040b1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01040b4:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
			cprintf("fault va : %x\n", user_pf_trapframe.utf_fault_va);
f01040b7:	83 c4 08             	add    $0x8,%esp
f01040ba:	57                   	push   %edi
f01040bb:	68 1b 75 10 f0       	push   $0xf010751b
f01040c0:	e8 0c f9 ff ff       	call   f01039d1 <cprintf>
			trap_env->env_tf.tf_esp = exception_stack_top - sizeof(struct UTrapframe);
f01040c5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01040c8:	8d 41 cc             	lea    -0x34(%ecx),%eax
f01040cb:	89 46 3c             	mov    %eax,0x3c(%esi)
			*pf_upcall_arg = user_pf_trapframe;
f01040ce:	89 79 cc             	mov    %edi,-0x34(%ecx)
f01040d1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01040d4:	89 48 04             	mov    %ecx,0x4(%eax)
f01040d7:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01040da:	89 50 08             	mov    %edx,0x8(%eax)
f01040dd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01040e0:	89 48 0c             	mov    %ecx,0xc(%eax)
f01040e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01040e6:	89 48 10             	mov    %ecx,0x10(%eax)
f01040e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040ec:	89 50 14             	mov    %edx,0x14(%eax)
f01040ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01040f2:	89 48 18             	mov    %ecx,0x18(%eax)
f01040f5:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01040f8:	89 48 1c             	mov    %ecx,0x1c(%eax)
f01040fb:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01040fe:	89 50 20             	mov    %edx,0x20(%eax)
f0104101:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104104:	89 48 24             	mov    %ecx,0x24(%eax)
f0104107:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010410a:	89 48 28             	mov    %ecx,0x28(%eax)
f010410d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104110:	89 50 2c             	mov    %edx,0x2c(%eax)
f0104113:	89 58 30             	mov    %ebx,0x30(%eax)
			trap_env->env_tf.tf_eip = (uintptr_t)trap_env->env_pgfault_upcall;
f0104116:	8b 46 64             	mov    0x64(%esi),%eax
f0104119:	89 46 30             	mov    %eax,0x30(%esi)
			env_run(trap_env);
f010411c:	89 34 24             	mov    %esi,(%esp)
f010411f:	e8 4a f6 ff ff       	call   f010376e <env_run>
		cprintf("env pagefault upcall is none!");
f0104124:	83 ec 0c             	sub    $0xc,%esp
f0104127:	68 2a 75 10 f0       	push   $0xf010752a
f010412c:	e8 a0 f8 ff ff       	call   f01039d1 <cprintf>
f0104131:	83 c4 10             	add    $0x10,%esp
f0104134:	e9 ba fe ff ff       	jmp    f0103ff3 <page_fault_handler+0x4a>

f0104139 <trap>:
{
f0104139:	55                   	push   %ebp
f010413a:	89 e5                	mov    %esp,%ebp
f010413c:	57                   	push   %edi
f010413d:	56                   	push   %esi
f010413e:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104141:	fc                   	cld    
	if (panicstr)
f0104142:	83 3d 80 de 22 f0 00 	cmpl   $0x0,0xf022de80
f0104149:	74 01                	je     f010414c <trap+0x13>
		asm volatile("hlt");
f010414b:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010414c:	e8 1a 19 00 00       	call   f0105a6b <cpunum>
f0104151:	6b d0 74             	imul   $0x74,%eax,%edx
f0104154:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104157:	b8 01 00 00 00       	mov    $0x1,%eax
f010415c:	f0 87 82 20 e0 22 f0 	lock xchg %eax,-0xfdd1fe0(%edx)
f0104163:	83 f8 02             	cmp    $0x2,%eax
f0104166:	0f 84 b4 00 00 00    	je     f0104220 <trap+0xe7>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010416c:	9c                   	pushf  
f010416d:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010416e:	f6 c4 02             	test   $0x2,%ah
f0104171:	0f 85 be 00 00 00    	jne    f0104235 <trap+0xfc>
	if ((tf->tf_cs & 3) == 3) {
f0104177:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010417b:	83 e0 03             	and    $0x3,%eax
f010417e:	66 83 f8 03          	cmp    $0x3,%ax
f0104182:	0f 84 c6 00 00 00    	je     f010424e <trap+0x115>
	last_tf = tf;
f0104188:	89 35 60 da 22 f0    	mov    %esi,0xf022da60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010418e:	8b 46 28             	mov    0x28(%esi),%eax
f0104191:	83 f8 27             	cmp    $0x27,%eax
f0104194:	0f 84 59 01 00 00    	je     f01042f3 <trap+0x1ba>
	if (tf->tf_trapno == T_PGFLT) {
f010419a:	83 f8 0e             	cmp    $0xe,%eax
f010419d:	0f 84 6d 01 00 00    	je     f0104310 <trap+0x1d7>
	} else if (tf->tf_trapno == T_BRKPT) {
f01041a3:	83 f8 03             	cmp    $0x3,%eax
f01041a6:	0f 84 75 01 00 00    	je     f0104321 <trap+0x1e8>
	} else if (tf->tf_trapno == T_SYSCALL) {
f01041ac:	83 f8 30             	cmp    $0x30,%eax
f01041af:	0f 84 7d 01 00 00    	je     f0104332 <trap+0x1f9>
	print_trapframe(tf);
f01041b5:	83 ec 0c             	sub    $0xc,%esp
f01041b8:	56                   	push   %esi
f01041b9:	e8 52 fc ff ff       	call   f0103e10 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01041be:	83 c4 10             	add    $0x10,%esp
f01041c1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01041c6:	0f 84 8a 01 00 00    	je     f0104356 <trap+0x21d>
		cprintf("------done!\n");
f01041cc:	83 ec 0c             	sub    $0xc,%esp
f01041cf:	68 9e 75 10 f0       	push   $0xf010759e
f01041d4:	e8 f8 f7 ff ff       	call   f01039d1 <cprintf>
		env_destroy(curenv);
f01041d9:	e8 8d 18 00 00       	call   f0105a6b <cpunum>
f01041de:	83 c4 04             	add    $0x4,%esp
f01041e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e4:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f01041ea:	e8 e0 f4 ff ff       	call   f01036cf <env_destroy>
f01041ef:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01041f2:	e8 74 18 00 00       	call   f0105a6b <cpunum>
f01041f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fa:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f0104201:	74 18                	je     f010421b <trap+0xe2>
f0104203:	e8 63 18 00 00       	call   f0105a6b <cpunum>
f0104208:	6b c0 74             	imul   $0x74,%eax,%eax
f010420b:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0104211:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104215:	0f 84 52 01 00 00    	je     f010436d <trap+0x234>
		sched_yield();
f010421b:	e8 99 02 00 00       	call   f01044b9 <sched_yield>
	spin_lock(&kernel_lock);
f0104220:	83 ec 0c             	sub    $0xc,%esp
f0104223:	68 c0 13 12 f0       	push   $0xf01213c0
f0104228:	e8 ae 1a 00 00       	call   f0105cdb <spin_lock>
f010422d:	83 c4 10             	add    $0x10,%esp
f0104230:	e9 37 ff ff ff       	jmp    f010416c <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104235:	68 48 75 10 f0       	push   $0xf0107548
f010423a:	68 af 6f 10 f0       	push   $0xf0106faf
f010423f:	68 11 01 00 00       	push   $0x111
f0104244:	68 0f 75 10 f0       	push   $0xf010750f
f0104249:	e8 f2 bd ff ff       	call   f0100040 <_panic>
		assert(curenv);
f010424e:	e8 18 18 00 00       	call   f0105a6b <cpunum>
f0104253:	6b c0 74             	imul   $0x74,%eax,%eax
f0104256:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f010425d:	74 4e                	je     f01042ad <trap+0x174>
f010425f:	83 ec 0c             	sub    $0xc,%esp
f0104262:	68 c0 13 12 f0       	push   $0xf01213c0
f0104267:	e8 6f 1a 00 00       	call   f0105cdb <spin_lock>
		if (curenv->env_status == ENV_DYING) {
f010426c:	e8 fa 17 00 00       	call   f0105a6b <cpunum>
f0104271:	6b c0 74             	imul   $0x74,%eax,%eax
f0104274:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f010427a:	83 c4 10             	add    $0x10,%esp
f010427d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104281:	74 43                	je     f01042c6 <trap+0x18d>
		curenv->env_tf = *tf;
f0104283:	e8 e3 17 00 00       	call   f0105a6b <cpunum>
f0104288:	6b c0 74             	imul   $0x74,%eax,%eax
f010428b:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0104291:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104296:	89 c7                	mov    %eax,%edi
f0104298:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f010429a:	e8 cc 17 00 00       	call   f0105a6b <cpunum>
f010429f:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a2:	8b b0 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%esi
f01042a8:	e9 db fe ff ff       	jmp    f0104188 <trap+0x4f>
		assert(curenv);
f01042ad:	68 61 75 10 f0       	push   $0xf0107561
f01042b2:	68 af 6f 10 f0       	push   $0xf0106faf
f01042b7:	68 18 01 00 00       	push   $0x118
f01042bc:	68 0f 75 10 f0       	push   $0xf010750f
f01042c1:	e8 7a bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f01042c6:	e8 a0 17 00 00       	call   f0105a6b <cpunum>
f01042cb:	83 ec 0c             	sub    $0xc,%esp
f01042ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d1:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f01042d7:	e8 05 f2 ff ff       	call   f01034e1 <env_free>
			curenv = NULL;
f01042dc:	e8 8a 17 00 00       	call   f0105a6b <cpunum>
f01042e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e4:	c7 80 28 e0 22 f0 00 	movl   $0x0,-0xfdd1fd8(%eax)
f01042eb:	00 00 00 
			sched_yield();
f01042ee:	e8 c6 01 00 00       	call   f01044b9 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f01042f3:	83 ec 0c             	sub    $0xc,%esp
f01042f6:	68 68 75 10 f0       	push   $0xf0107568
f01042fb:	e8 d1 f6 ff ff       	call   f01039d1 <cprintf>
		print_trapframe(tf);
f0104300:	89 34 24             	mov    %esi,(%esp)
f0104303:	e8 08 fb ff ff       	call   f0103e10 <print_trapframe>
f0104308:	83 c4 10             	add    $0x10,%esp
f010430b:	e9 e2 fe ff ff       	jmp    f01041f2 <trap+0xb9>
		page_fault_handler(tf);
f0104310:	83 ec 0c             	sub    $0xc,%esp
f0104313:	56                   	push   %esi
f0104314:	e8 90 fc ff ff       	call   f0103fa9 <page_fault_handler>
f0104319:	83 c4 10             	add    $0x10,%esp
f010431c:	e9 94 fe ff ff       	jmp    f01041b5 <trap+0x7c>
		monitor(tf);
f0104321:	83 ec 0c             	sub    $0xc,%esp
f0104324:	56                   	push   %esi
f0104325:	e8 e6 c5 ff ff       	call   f0100910 <monitor>
f010432a:	83 c4 10             	add    $0x10,%esp
f010432d:	e9 83 fe ff ff       	jmp    f01041b5 <trap+0x7c>
		int32_t syscall_ret = syscall(tf->tf_regs.reg_eax,
f0104332:	83 ec 08             	sub    $0x8,%esp
f0104335:	ff 76 04             	pushl  0x4(%esi)
f0104338:	ff 36                	pushl  (%esi)
f010433a:	ff 76 10             	pushl  0x10(%esi)
f010433d:	ff 76 18             	pushl  0x18(%esi)
f0104340:	ff 76 14             	pushl  0x14(%esi)
f0104343:	ff 76 1c             	pushl  0x1c(%esi)
f0104346:	e8 2b 02 00 00       	call   f0104576 <syscall>
		tf->tf_regs.reg_eax = syscall_ret;
f010434b:	89 46 1c             	mov    %eax,0x1c(%esi)
f010434e:	83 c4 20             	add    $0x20,%esp
f0104351:	e9 9c fe ff ff       	jmp    f01041f2 <trap+0xb9>
		panic("unhandled trap in kernel");
f0104356:	83 ec 04             	sub    $0x4,%esp
f0104359:	68 85 75 10 f0       	push   $0xf0107585
f010435e:	68 f6 00 00 00       	push   $0xf6
f0104363:	68 0f 75 10 f0       	push   $0xf010750f
f0104368:	e8 d3 bc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010436d:	e8 f9 16 00 00       	call   f0105a6b <cpunum>
f0104372:	83 ec 0c             	sub    $0xc,%esp
f0104375:	6b c0 74             	imul   $0x74,%eax,%eax
f0104378:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f010437e:	e8 eb f3 ff ff       	call   f010376e <env_run>
f0104383:	90                   	nop

f0104384 <th0>:
	pushl $(num);							\
	jmp _alltraps



TRAPHANDLER_NOEC(th0, 0)
f0104384:	6a 00                	push   $0x0
f0104386:	6a 00                	push   $0x0
f0104388:	eb 4c                	jmp    f01043d6 <_alltraps>

f010438a <th1>:
TRAPHANDLER_NOEC(th1, 1)
f010438a:	6a 00                	push   $0x0
f010438c:	6a 01                	push   $0x1
f010438e:	eb 46                	jmp    f01043d6 <_alltraps>

f0104390 <th3>:
TRAPHANDLER_NOEC(th3, 3)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 03                	push   $0x3
f0104394:	eb 40                	jmp    f01043d6 <_alltraps>

f0104396 <th4>:
TRAPHANDLER_NOEC(th4, 4)
f0104396:	6a 00                	push   $0x0
f0104398:	6a 04                	push   $0x4
f010439a:	eb 3a                	jmp    f01043d6 <_alltraps>

f010439c <th5>:
TRAPHANDLER_NOEC(th5, 5)
f010439c:	6a 00                	push   $0x0
f010439e:	6a 05                	push   $0x5
f01043a0:	eb 34                	jmp    f01043d6 <_alltraps>

f01043a2 <th6>:
TRAPHANDLER_NOEC(th6, 6)
f01043a2:	6a 00                	push   $0x0
f01043a4:	6a 06                	push   $0x6
f01043a6:	eb 2e                	jmp    f01043d6 <_alltraps>

f01043a8 <th7>:
TRAPHANDLER_NOEC(th7, 7)
f01043a8:	6a 00                	push   $0x0
f01043aa:	6a 07                	push   $0x7
f01043ac:	eb 28                	jmp    f01043d6 <_alltraps>

f01043ae <th8>:
TRAPHANDLER(th8, 8)
f01043ae:	6a 08                	push   $0x8
f01043b0:	eb 24                	jmp    f01043d6 <_alltraps>

f01043b2 <th9>:
TRAPHANDLER_NOEC(th9, 9)
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 09                	push   $0x9
f01043b6:	eb 1e                	jmp    f01043d6 <_alltraps>

f01043b8 <th10>:
TRAPHANDLER(th10, 10)
f01043b8:	6a 0a                	push   $0xa
f01043ba:	eb 1a                	jmp    f01043d6 <_alltraps>

f01043bc <th11>:
TRAPHANDLER(th11, 11)
f01043bc:	6a 0b                	push   $0xb
f01043be:	eb 16                	jmp    f01043d6 <_alltraps>

f01043c0 <th12>:
TRAPHANDLER(th12, 12)
f01043c0:	6a 0c                	push   $0xc
f01043c2:	eb 12                	jmp    f01043d6 <_alltraps>

f01043c4 <th13>:
TRAPHANDLER(th13, 13)
f01043c4:	6a 0d                	push   $0xd
f01043c6:	eb 0e                	jmp    f01043d6 <_alltraps>

f01043c8 <th14>:
TRAPHANDLER(th14, 14)
f01043c8:	6a 0e                	push   $0xe
f01043ca:	eb 0a                	jmp    f01043d6 <_alltraps>

f01043cc <th16>:
TRAPHANDLER(th16, 16)
f01043cc:	6a 10                	push   $0x10
f01043ce:	eb 06                	jmp    f01043d6 <_alltraps>

f01043d0 <th48>:
TRAPHANDLER_NOEC(th48, 48)
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 30                	push   $0x30
f01043d4:	eb 00                	jmp    f01043d6 <_alltraps>

f01043d6 <_alltraps>:
/*

 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	push %ds
f01043d6:	1e                   	push   %ds
	push %es
f01043d7:	06                   	push   %es
	pushal
f01043d8:	60                   	pusha  
	movl $GD_KD, %eax
f01043d9:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %es
f01043de:	8e c0                	mov    %eax,%es
	movw %ax, %ds
f01043e0:	8e d8                	mov    %eax,%ds
	pushl %esp
f01043e2:	54                   	push   %esp
	call trap
f01043e3:	e8 51 fd ff ff       	call   f0104139 <trap>

f01043e8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043e8:	55                   	push   %ebp
f01043e9:	89 e5                	mov    %esp,%ebp
f01043eb:	83 ec 08             	sub    $0x8,%esp
f01043ee:	a1 48 d2 22 f0       	mov    0xf022d248,%eax
f01043f3:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043f6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01043fb:	8b 10                	mov    (%eax),%edx
f01043fd:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104400:	83 fa 02             	cmp    $0x2,%edx
f0104403:	76 2d                	jbe    f0104432 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104405:	83 c1 01             	add    $0x1,%ecx
f0104408:	83 c0 7c             	add    $0x7c,%eax
f010440b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104411:	75 e8                	jne    f01043fb <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104413:	83 ec 0c             	sub    $0xc,%esp
f0104416:	68 90 77 10 f0       	push   $0xf0107790
f010441b:	e8 b1 f5 ff ff       	call   f01039d1 <cprintf>
f0104420:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104423:	83 ec 0c             	sub    $0xc,%esp
f0104426:	6a 00                	push   $0x0
f0104428:	e8 e3 c4 ff ff       	call   f0100910 <monitor>
f010442d:	83 c4 10             	add    $0x10,%esp
f0104430:	eb f1                	jmp    f0104423 <sched_halt+0x3b>
	if (i == NENV) {
f0104432:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104438:	74 d9                	je     f0104413 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010443a:	e8 2c 16 00 00       	call   f0105a6b <cpunum>
f010443f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104442:	c7 80 28 e0 22 f0 00 	movl   $0x0,-0xfdd1fd8(%eax)
f0104449:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010444c:	a1 8c de 22 f0       	mov    0xf022de8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104451:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104456:	76 4f                	jbe    f01044a7 <sched_halt+0xbf>
	return (physaddr_t)kva - KERNBASE;
f0104458:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010445d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104460:	e8 06 16 00 00       	call   f0105a6b <cpunum>
f0104465:	6b d0 74             	imul   $0x74,%eax,%edx
f0104468:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010446b:	b8 02 00 00 00       	mov    $0x2,%eax
f0104470:	f0 87 82 20 e0 22 f0 	lock xchg %eax,-0xfdd1fe0(%edx)
	spin_unlock(&kernel_lock);
f0104477:	83 ec 0c             	sub    $0xc,%esp
f010447a:	68 c0 13 12 f0       	push   $0xf01213c0
f010447f:	e8 f4 18 00 00       	call   f0105d78 <spin_unlock>
	asm volatile("pause");
f0104484:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104486:	e8 e0 15 00 00       	call   f0105a6b <cpunum>
f010448b:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010448e:	8b 80 30 e0 22 f0    	mov    -0xfdd1fd0(%eax),%eax
f0104494:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104499:	89 c4                	mov    %eax,%esp
f010449b:	6a 00                	push   $0x0
f010449d:	6a 00                	push   $0x0
f010449f:	f4                   	hlt    
f01044a0:	eb fd                	jmp    f010449f <sched_halt+0xb7>
}
f01044a2:	83 c4 10             	add    $0x10,%esp
f01044a5:	c9                   	leave  
f01044a6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044a7:	50                   	push   %eax
f01044a8:	68 e8 60 10 f0       	push   $0xf01060e8
f01044ad:	6a 4a                	push   $0x4a
f01044af:	68 b9 77 10 f0       	push   $0xf01077b9
f01044b4:	e8 87 bb ff ff       	call   f0100040 <_panic>

f01044b9 <sched_yield>:
{
f01044b9:	55                   	push   %ebp
f01044ba:	89 e5                	mov    %esp,%ebp
f01044bc:	53                   	push   %ebx
f01044bd:	83 ec 04             	sub    $0x4,%esp
	int i = thiscpu->cpu_env - envs;
f01044c0:	e8 a6 15 00 00       	call   f0105a6b <cpunum>
f01044c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c8:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f01044ce:	2b 05 48 d2 22 f0    	sub    0xf022d248,%eax
f01044d4:	c1 f8 02             	sar    $0x2,%eax
f01044d7:	69 d8 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%ebx
	if (thiscpu->cpu_env == NULL) {
f01044dd:	e8 89 15 00 00       	call   f0105a6b <cpunum>
f01044e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e5:	83 b8 28 e0 22 f0 00 	cmpl   $0x0,-0xfdd1fd8(%eax)
f01044ec:	74 5f                	je     f010454d <sched_yield+0x94>
	int last_env = thiscpu->cpu_env - envs;
f01044ee:	e8 78 15 00 00       	call   f0105a6b <cpunum>
f01044f3:	8b 0d 48 d2 22 f0    	mov    0xf022d248,%ecx
f01044f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044fc:	8b 90 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%edx
f0104502:	29 ca                	sub    %ecx,%edx
f0104504:	c1 fa 02             	sar    $0x2,%edx
f0104507:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
	i = (i + 1) % NENV;
f010450d:	8d 43 01             	lea    0x1(%ebx),%eax
f0104510:	89 c3                	mov    %eax,%ebx
f0104512:	c1 fb 1f             	sar    $0x1f,%ebx
f0104515:	c1 eb 16             	shr    $0x16,%ebx
f0104518:	01 d8                	add    %ebx,%eax
f010451a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010451f:	29 d8                	sub    %ebx,%eax
	for (; i < NENV; ) {
f0104521:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0104526:	7f 44                	jg     f010456c <sched_yield+0xb3>
		if (envs[i].env_status == ENV_RUNNABLE || i == last_env) {
f0104528:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f010452b:	01 cb                	add    %ecx,%ebx
f010452d:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104531:	74 30                	je     f0104563 <sched_yield+0xaa>
f0104533:	39 d0                	cmp    %edx,%eax
f0104535:	74 2c                	je     f0104563 <sched_yield+0xaa>
			i = (i + 1) % NENV;
f0104537:	83 c0 01             	add    $0x1,%eax
f010453a:	89 c3                	mov    %eax,%ebx
f010453c:	c1 fb 1f             	sar    $0x1f,%ebx
f010453f:	c1 eb 16             	shr    $0x16,%ebx
f0104542:	01 d8                	add    %ebx,%eax
f0104544:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104549:	29 d8                	sub    %ebx,%eax
f010454b:	eb d4                	jmp    f0104521 <sched_yield+0x68>
		thiscpu->cpu_env = envs;
f010454d:	e8 19 15 00 00       	call   f0105a6b <cpunum>
f0104552:	6b c0 74             	imul   $0x74,%eax,%eax
f0104555:	8b 15 48 d2 22 f0    	mov    0xf022d248,%edx
f010455b:	89 90 28 e0 22 f0    	mov    %edx,-0xfdd1fd8(%eax)
f0104561:	eb 8b                	jmp    f01044ee <sched_yield+0x35>
			env_run(envs + i);
f0104563:	83 ec 0c             	sub    $0xc,%esp
f0104566:	53                   	push   %ebx
f0104567:	e8 02 f2 ff ff       	call   f010376e <env_run>
	sched_halt();
f010456c:	e8 77 fe ff ff       	call   f01043e8 <sched_halt>
}
f0104571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104574:	c9                   	leave  
f0104575:	c3                   	ret    

f0104576 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104576:	55                   	push   %ebp
f0104577:	89 e5                	mov    %esp,%ebp
f0104579:	57                   	push   %edi
f010457a:	56                   	push   %esi
f010457b:	53                   	push   %ebx
f010457c:	83 ec 1c             	sub    $0x1c,%esp
f010457f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
	
	switch (syscallno) {
f0104582:	83 f8 0a             	cmp    $0xa,%eax
f0104585:	0f 87 c1 03 00 00    	ja     f010494c <syscall+0x3d6>
f010458b:	ff 24 85 0c 78 10 f0 	jmp    *-0xfef87f4(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f0104592:	e8 d4 14 00 00       	call   f0105a6b <cpunum>
f0104597:	6a 04                	push   $0x4
f0104599:	ff 75 10             	pushl  0x10(%ebp)
f010459c:	ff 75 0c             	pushl  0xc(%ebp)
f010459f:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a2:	ff b0 28 e0 22 f0    	pushl  -0xfdd1fd8(%eax)
f01045a8:	e8 6a ea ff ff       	call   f0103017 <user_mem_assert>
	cprintf("%.*s", len, s);
f01045ad:	83 c4 0c             	add    $0xc,%esp
f01045b0:	ff 75 0c             	pushl  0xc(%ebp)
f01045b3:	ff 75 10             	pushl  0x10(%ebp)
f01045b6:	68 c6 77 10 f0       	push   $0xf01077c6
f01045bb:	e8 11 f4 ff ff       	call   f01039d1 <cprintf>
f01045c0:	83 c4 10             	add    $0x10,%esp
		case SYS_cputs:
		{
			sys_cputs((const char*)a1, (size_t)a2);
			return 0;
f01045c3:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
		}
		default:
			return -E_INVAL;
	}
}
f01045c8:	89 d8                	mov    %ebx,%eax
f01045ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045cd:	5b                   	pop    %ebx
f01045ce:	5e                   	pop    %esi
f01045cf:	5f                   	pop    %edi
f01045d0:	5d                   	pop    %ebp
f01045d1:	c3                   	ret    
	return cons_getc();
f01045d2:	e8 39 c0 ff ff       	call   f0100610 <cons_getc>
f01045d7:	89 c3                	mov    %eax,%ebx
			return ret;
f01045d9:	eb ed                	jmp    f01045c8 <syscall+0x52>
	return curenv->env_id;
f01045db:	e8 8b 14 00 00       	call   f0105a6b <cpunum>
f01045e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e3:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f01045e9:	8b 58 48             	mov    0x48(%eax),%ebx
			return envid;
f01045ec:	eb da                	jmp    f01045c8 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01045ee:	83 ec 04             	sub    $0x4,%esp
f01045f1:	6a 01                	push   $0x1
f01045f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045f6:	50                   	push   %eax
f01045f7:	ff 75 0c             	pushl  0xc(%ebp)
f01045fa:	e8 df ea ff ff       	call   f01030de <envid2env>
f01045ff:	89 c3                	mov    %eax,%ebx
f0104601:	83 c4 10             	add    $0x10,%esp
f0104604:	85 c0                	test   %eax,%eax
f0104606:	78 c0                	js     f01045c8 <syscall+0x52>
	if (e == curenv)
f0104608:	e8 5e 14 00 00       	call   f0105a6b <cpunum>
f010460d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104610:	6b c0 74             	imul   $0x74,%eax,%eax
f0104613:	39 90 28 e0 22 f0    	cmp    %edx,-0xfdd1fd8(%eax)
f0104619:	74 3d                	je     f0104658 <syscall+0xe2>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010461b:	8b 5a 48             	mov    0x48(%edx),%ebx
f010461e:	e8 48 14 00 00       	call   f0105a6b <cpunum>
f0104623:	83 ec 04             	sub    $0x4,%esp
f0104626:	53                   	push   %ebx
f0104627:	6b c0 74             	imul   $0x74,%eax,%eax
f010462a:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0104630:	ff 70 48             	pushl  0x48(%eax)
f0104633:	68 e6 77 10 f0       	push   $0xf01077e6
f0104638:	e8 94 f3 ff ff       	call   f01039d1 <cprintf>
f010463d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104640:	83 ec 0c             	sub    $0xc,%esp
f0104643:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104646:	e8 84 f0 ff ff       	call   f01036cf <env_destroy>
f010464b:	83 c4 10             	add    $0x10,%esp
	return 0;
f010464e:	bb 00 00 00 00       	mov    $0x0,%ebx
			return ret;
f0104653:	e9 70 ff ff ff       	jmp    f01045c8 <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104658:	e8 0e 14 00 00       	call   f0105a6b <cpunum>
f010465d:	83 ec 08             	sub    $0x8,%esp
f0104660:	6b c0 74             	imul   $0x74,%eax,%eax
f0104663:	8b 80 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%eax
f0104669:	ff 70 48             	pushl  0x48(%eax)
f010466c:	68 cb 77 10 f0       	push   $0xf01077cb
f0104671:	e8 5b f3 ff ff       	call   f01039d1 <cprintf>
f0104676:	83 c4 10             	add    $0x10,%esp
f0104679:	eb c5                	jmp    f0104640 <syscall+0xca>
	sched_yield();
f010467b:	e8 39 fe ff ff       	call   f01044b9 <sched_yield>
	struct Env *current_env = thiscpu->cpu_env;
f0104680:	e8 e6 13 00 00       	call   f0105a6b <cpunum>
f0104685:	6b c0 74             	imul   $0x74,%eax,%eax
f0104688:	8b b0 28 e0 22 f0    	mov    -0xfdd1fd8(%eax),%esi
	envid_t thisenv_pid = current_env->env_id;
f010468e:	8b 46 48             	mov    0x48(%esi),%eax
	struct Env *new_env = NULL;
f0104691:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int env_alloc_ret = env_alloc(&new_env, thisenv_pid);
f0104698:	83 ec 08             	sub    $0x8,%esp
f010469b:	50                   	push   %eax
f010469c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010469f:	50                   	push   %eax
f01046a0:	e8 61 eb ff ff       	call   f0103206 <env_alloc>
f01046a5:	89 c3                	mov    %eax,%ebx
	if (env_alloc_ret) {
f01046a7:	83 c4 10             	add    $0x10,%esp
f01046aa:	85 c0                	test   %eax,%eax
f01046ac:	0f 85 16 ff ff ff    	jne    f01045c8 <syscall+0x52>
	new_env->env_status = ENV_NOT_RUNNABLE;
f01046b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046b5:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	new_env->env_tf = current_env->env_tf;
f01046bc:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046c1:	89 c7                	mov    %eax,%edi
f01046c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f01046c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id;
f01046cf:	8b 58 48             	mov    0x48(%eax),%ebx
			return ret;
f01046d2:	e9 f1 fe ff ff       	jmp    f01045c8 <syscall+0x52>
	struct Env *current_env = NULL;
f01046d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = envid2env(envid, &current_env, 1);
f01046de:	83 ec 04             	sub    $0x4,%esp
f01046e1:	6a 01                	push   $0x1
f01046e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e6:	50                   	push   %eax
f01046e7:	ff 75 0c             	pushl  0xc(%ebp)
f01046ea:	e8 ef e9 ff ff       	call   f01030de <envid2env>
f01046ef:	89 c3                	mov    %eax,%ebx
	if (ret != 0) {
f01046f1:	83 c4 10             	add    $0x10,%esp
f01046f4:	85 c0                	test   %eax,%eax
f01046f6:	75 4e                	jne    f0104746 <syscall+0x1d0>
	struct PageInfo *new_page = page_alloc(0);
f01046f8:	83 ec 0c             	sub    $0xc,%esp
f01046fb:	6a 00                	push   $0x0
f01046fd:	e8 59 c8 ff ff       	call   f0100f5b <page_alloc>
	if (!new_page) {
f0104702:	83 c4 10             	add    $0x10,%esp
f0104705:	85 c0                	test   %eax,%eax
f0104707:	74 55                	je     f010475e <syscall+0x1e8>
	if ((uintptr_t)va >= UTOP || ((uintptr_t)va % PGSIZE != 0)) {
f0104709:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104710:	77 56                	ja     f0104768 <syscall+0x1f2>
f0104712:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104719:	75 57                	jne    f0104772 <syscall+0x1fc>
	if ((perm & (PTE_U | PTE_P)) && !(perm & ~(PTE_U | PTE_P | PTE_AVAIL | PTE_W))) {
f010471b:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f010471f:	74 5b                	je     f010477c <syscall+0x206>
f0104721:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104728:	75 5c                	jne    f0104786 <syscall+0x210>
	int insert_ret = page_insert(current_env->env_pgdir, new_page, va, perm);
f010472a:	ff 75 14             	pushl  0x14(%ebp)
f010472d:	ff 75 10             	pushl  0x10(%ebp)
f0104730:	50                   	push   %eax
f0104731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104734:	ff 70 60             	pushl  0x60(%eax)
f0104737:	e8 44 cb ff ff       	call   f0101280 <page_insert>
f010473c:	89 c3                	mov    %eax,%ebx
f010473e:	83 c4 10             	add    $0x10,%esp
f0104741:	e9 82 fe ff ff       	jmp    f01045c8 <syscall+0x52>
		cprintf("envid : %d\n", envid);
f0104746:	83 ec 08             	sub    $0x8,%esp
f0104749:	ff 75 0c             	pushl  0xc(%ebp)
f010474c:	68 fe 77 10 f0       	push   $0xf01077fe
f0104751:	e8 7b f2 ff ff       	call   f01039d1 <cprintf>
f0104756:	83 c4 10             	add    $0x10,%esp
f0104759:	e9 6a fe ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_NO_MEM;
f010475e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104763:	e9 60 fe ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f0104768:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010476d:	e9 56 fe ff ff       	jmp    f01045c8 <syscall+0x52>
f0104772:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104777:	e9 4c fe ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f010477c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104781:	e9 42 fe ff ff       	jmp    f01045c8 <syscall+0x52>
f0104786:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return ret;
f010478b:	e9 38 fe ff ff       	jmp    f01045c8 <syscall+0x52>
	struct Env *src_env = NULL;
f0104790:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	struct Env *dst_env = NULL;
f0104797:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int get_srcenv_ret = envid2env(srcenvid, &src_env, 1);
f010479e:	83 ec 04             	sub    $0x4,%esp
f01047a1:	6a 01                	push   $0x1
f01047a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01047a6:	50                   	push   %eax
f01047a7:	ff 75 0c             	pushl  0xc(%ebp)
f01047aa:	e8 2f e9 ff ff       	call   f01030de <envid2env>
f01047af:	89 c3                	mov    %eax,%ebx
	int get_dstenv_ret = envid2env(dstenvid, &dst_env, 1);
f01047b1:	83 c4 0c             	add    $0xc,%esp
f01047b4:	6a 01                	push   $0x1
f01047b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047b9:	50                   	push   %eax
f01047ba:	ff 75 14             	pushl  0x14(%ebp)
f01047bd:	e8 1c e9 ff ff       	call   f01030de <envid2env>
	if (get_srcenv_ret || get_dstenv_ret) {
f01047c2:	83 c4 10             	add    $0x10,%esp
f01047c5:	09 c3                	or     %eax,%ebx
f01047c7:	75 7c                	jne    f0104845 <syscall+0x2cf>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) {
f01047c9:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047d0:	77 7d                	ja     f010484f <syscall+0x2d9>
	if ((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE) {
f01047d2:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047d9:	75 7e                	jne    f0104859 <syscall+0x2e3>
f01047db:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01047e2:	77 75                	ja     f0104859 <syscall+0x2e3>
f01047e4:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01047eb:	75 76                	jne    f0104863 <syscall+0x2ed>
	if ((perm & (PTE_U | PTE_P)) && !(perm & ~(PTE_U | PTE_P | PTE_AVAIL | PTE_W))) {
f01047ed:	f6 45 1c 05          	testb  $0x5,0x1c(%ebp)
f01047f1:	74 7a                	je     f010486d <syscall+0x2f7>
f01047f3:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01047fa:	75 7b                	jne    f0104877 <syscall+0x301>
	pte_t *srcva_pte = NULL;
f01047fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *src_page = page_lookup(src_env->env_pgdir, srcva, &srcva_pte);
f0104803:	83 ec 04             	sub    $0x4,%esp
f0104806:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104809:	50                   	push   %eax
f010480a:	ff 75 10             	pushl  0x10(%ebp)
f010480d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104810:	ff 70 60             	pushl  0x60(%eax)
f0104813:	e8 79 c9 ff ff       	call   f0101191 <page_lookup>
	if (!(*srcva_pte & PTE_W) && (perm & PTE_W)) {
f0104818:	83 c4 10             	add    $0x10,%esp
f010481b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010481e:	f6 02 02             	testb  $0x2,(%edx)
f0104821:	75 06                	jne    f0104829 <syscall+0x2b3>
f0104823:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104827:	75 58                	jne    f0104881 <syscall+0x30b>
	int page_insert_ret = page_insert(dst_env->env_pgdir, src_page, dstva, perm);
f0104829:	ff 75 1c             	pushl  0x1c(%ebp)
f010482c:	ff 75 18             	pushl  0x18(%ebp)
f010482f:	50                   	push   %eax
f0104830:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104833:	ff 70 60             	pushl  0x60(%eax)
f0104836:	e8 45 ca ff ff       	call   f0101280 <page_insert>
f010483b:	89 c3                	mov    %eax,%ebx
f010483d:	83 c4 10             	add    $0x10,%esp
f0104840:	e9 83 fd ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_BAD_ENV;
f0104845:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010484a:	e9 79 fd ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f010484f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104854:	e9 6f fd ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f0104859:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010485e:	e9 65 fd ff ff       	jmp    f01045c8 <syscall+0x52>
f0104863:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104868:	e9 5b fd ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f010486d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104872:	e9 51 fd ff ff       	jmp    f01045c8 <syscall+0x52>
f0104877:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010487c:	e9 47 fd ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f0104881:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return ret;
f0104886:	e9 3d fd ff ff       	jmp    f01045c8 <syscall+0x52>
	struct Env *current_env = NULL;
f010488b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = envid2env(envid, &current_env, 1);
f0104892:	83 ec 04             	sub    $0x4,%esp
f0104895:	6a 01                	push   $0x1
f0104897:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010489a:	50                   	push   %eax
f010489b:	ff 75 0c             	pushl  0xc(%ebp)
f010489e:	e8 3b e8 ff ff       	call   f01030de <envid2env>
f01048a3:	89 c3                	mov    %eax,%ebx
	if (ret) {
f01048a5:	83 c4 10             	add    $0x10,%esp
f01048a8:	85 c0                	test   %eax,%eax
f01048aa:	0f 85 18 fd ff ff    	jne    f01045c8 <syscall+0x52>
	page_remove(current_env->env_pgdir, va);
f01048b0:	83 ec 08             	sub    $0x8,%esp
f01048b3:	ff 75 10             	pushl  0x10(%ebp)
f01048b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048b9:	ff 70 60             	pushl  0x60(%eax)
f01048bc:	e8 6b c9 ff ff       	call   f010122c <page_remove>
f01048c1:	83 c4 10             	add    $0x10,%esp
			return ret;
f01048c4:	e9 ff fc ff ff       	jmp    f01045c8 <syscall+0x52>
	struct Env *env = NULL;
f01048c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = envid2env(envid, &env, 1);
f01048d0:	83 ec 04             	sub    $0x4,%esp
f01048d3:	6a 01                	push   $0x1
f01048d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d8:	50                   	push   %eax
f01048d9:	ff 75 0c             	pushl  0xc(%ebp)
f01048dc:	e8 fd e7 ff ff       	call   f01030de <envid2env>
f01048e1:	89 c3                	mov    %eax,%ebx
	if (!ret && (status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE)) {
f01048e3:	83 c4 10             	add    $0x10,%esp
f01048e6:	85 c0                	test   %eax,%eax
f01048e8:	75 1b                	jne    f0104905 <syscall+0x38f>
f01048ea:	8b 45 10             	mov    0x10(%ebp),%eax
f01048ed:	83 e8 02             	sub    $0x2,%eax
f01048f0:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01048f5:	75 18                	jne    f010490f <syscall+0x399>
		env->env_status = status;
f01048f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01048fd:	89 48 54             	mov    %ecx,0x54(%eax)
f0104900:	e9 c3 fc ff ff       	jmp    f01045c8 <syscall+0x52>
		return -E_INVAL;
f0104905:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010490a:	e9 b9 fc ff ff       	jmp    f01045c8 <syscall+0x52>
f010490f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return ret;
f0104914:	e9 af fc ff ff       	jmp    f01045c8 <syscall+0x52>
	struct Env *env = NULL;
f0104919:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = envid2env(envid, &env, 1);
f0104920:	83 ec 04             	sub    $0x4,%esp
f0104923:	6a 01                	push   $0x1
f0104925:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104928:	50                   	push   %eax
f0104929:	ff 75 0c             	pushl  0xc(%ebp)
f010492c:	e8 ad e7 ff ff       	call   f01030de <envid2env>
f0104931:	89 c3                	mov    %eax,%ebx
	if (ret) {
f0104933:	83 c4 10             	add    $0x10,%esp
f0104936:	85 c0                	test   %eax,%eax
f0104938:	0f 85 8a fc ff ff    	jne    f01045c8 <syscall+0x52>
	env->env_pgfault_upcall = func;
f010493e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104941:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104944:	89 78 64             	mov    %edi,0x64(%eax)
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104947:	e9 7c fc ff ff       	jmp    f01045c8 <syscall+0x52>
			return -E_INVAL;
f010494c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104951:	e9 72 fc ff ff       	jmp    f01045c8 <syscall+0x52>

f0104956 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104956:	55                   	push   %ebp
f0104957:	89 e5                	mov    %esp,%ebp
f0104959:	57                   	push   %edi
f010495a:	56                   	push   %esi
f010495b:	53                   	push   %ebx
f010495c:	83 ec 14             	sub    $0x14,%esp
f010495f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104962:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104965:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104968:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010496b:	8b 32                	mov    (%edx),%esi
f010496d:	8b 01                	mov    (%ecx),%eax
f010496f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104972:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104979:	eb 2f                	jmp    f01049aa <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010497b:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010497e:	39 c6                	cmp    %eax,%esi
f0104980:	7f 49                	jg     f01049cb <stab_binsearch+0x75>
f0104982:	0f b6 0a             	movzbl (%edx),%ecx
f0104985:	83 ea 0c             	sub    $0xc,%edx
f0104988:	39 f9                	cmp    %edi,%ecx
f010498a:	75 ef                	jne    f010497b <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010498c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010498f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104992:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104996:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104999:	73 35                	jae    f01049d0 <stab_binsearch+0x7a>
			*region_left = m;
f010499b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010499e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01049a0:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01049a3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01049aa:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01049ad:	7f 4e                	jg     f01049fd <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01049af:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049b2:	01 f0                	add    %esi,%eax
f01049b4:	89 c3                	mov    %eax,%ebx
f01049b6:	c1 eb 1f             	shr    $0x1f,%ebx
f01049b9:	01 c3                	add    %eax,%ebx
f01049bb:	d1 fb                	sar    %ebx
f01049bd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01049c0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01049c3:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01049c7:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01049c9:	eb b3                	jmp    f010497e <stab_binsearch+0x28>
			l = true_m + 1;
f01049cb:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01049ce:	eb da                	jmp    f01049aa <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01049d0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01049d3:	76 14                	jbe    f01049e9 <stab_binsearch+0x93>
			*region_right = m - 1;
f01049d5:	83 e8 01             	sub    $0x1,%eax
f01049d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01049db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01049de:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01049e0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01049e7:	eb c1                	jmp    f01049aa <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01049e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049ec:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01049ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01049f2:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01049f4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01049fb:	eb ad                	jmp    f01049aa <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01049fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104a01:	74 16                	je     f0104a19 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a06:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104a08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a0b:	8b 0e                	mov    (%esi),%ecx
f0104a0d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a10:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104a13:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104a17:	eb 12                	jmp    f0104a2b <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a1c:	8b 00                	mov    (%eax),%eax
f0104a1e:	83 e8 01             	sub    $0x1,%eax
f0104a21:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104a24:	89 07                	mov    %eax,(%edi)
f0104a26:	eb 16                	jmp    f0104a3e <stab_binsearch+0xe8>
		     l--)
f0104a28:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104a2b:	39 c1                	cmp    %eax,%ecx
f0104a2d:	7d 0a                	jge    f0104a39 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104a2f:	0f b6 1a             	movzbl (%edx),%ebx
f0104a32:	83 ea 0c             	sub    $0xc,%edx
f0104a35:	39 fb                	cmp    %edi,%ebx
f0104a37:	75 ef                	jne    f0104a28 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104a39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a3c:	89 07                	mov    %eax,(%edi)
	}
}
f0104a3e:	83 c4 14             	add    $0x14,%esp
f0104a41:	5b                   	pop    %ebx
f0104a42:	5e                   	pop    %esi
f0104a43:	5f                   	pop    %edi
f0104a44:	5d                   	pop    %ebp
f0104a45:	c3                   	ret    

f0104a46 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104a46:	55                   	push   %ebp
f0104a47:	89 e5                	mov    %esp,%ebp
f0104a49:	57                   	push   %edi
f0104a4a:	56                   	push   %esi
f0104a4b:	53                   	push   %ebx
f0104a4c:	83 ec 2c             	sub    $0x2c,%esp
f0104a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a52:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104a55:	c7 06 38 78 10 f0    	movl   $0xf0107838,(%esi)
	info->eip_line = 0;
f0104a5b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104a62:	c7 46 08 38 78 10 f0 	movl   $0xf0107838,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104a69:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104a70:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104a73:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104a7a:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104a80:	77 21                	ja     f0104aa3 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104a82:	a1 00 00 20 00       	mov    0x200000,%eax
f0104a87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104a8a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104a8f:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104a95:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104a98:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104a9e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104aa1:	eb 1a                	jmp    f0104abd <debuginfo_eip+0x77>
		stabstr_end = __STABSTR_END__;
f0104aa3:	c7 45 d0 69 6b 11 f0 	movl   $0xf0116b69,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104aaa:	c7 45 cc b9 32 11 f0 	movl   $0xf01132b9,-0x34(%ebp)
		stab_end = __STAB_END__;
f0104ab1:	b8 b8 32 11 f0       	mov    $0xf01132b8,%eax
		stabs = __STAB_BEGIN__;
f0104ab6:	c7 45 d4 14 7d 10 f0 	movl   $0xf0107d14,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104abd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104ac0:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104ac3:	0f 83 2e 01 00 00    	jae    f0104bf7 <debuginfo_eip+0x1b1>
f0104ac9:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104acd:	0f 85 2b 01 00 00    	jne    f0104bfe <debuginfo_eip+0x1b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104ad3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104ada:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104add:	29 d8                	sub    %ebx,%eax
f0104adf:	c1 f8 02             	sar    $0x2,%eax
f0104ae2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104ae8:	83 e8 01             	sub    $0x1,%eax
f0104aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104aee:	57                   	push   %edi
f0104aef:	6a 64                	push   $0x64
f0104af1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104af4:	89 c1                	mov    %eax,%ecx
f0104af6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104af9:	89 d8                	mov    %ebx,%eax
f0104afb:	e8 56 fe ff ff       	call   f0104956 <stab_binsearch>
	if (lfile == 0)
f0104b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b03:	83 c4 08             	add    $0x8,%esp
f0104b06:	85 c0                	test   %eax,%eax
f0104b08:	0f 84 f7 00 00 00    	je     f0104c05 <debuginfo_eip+0x1bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104b0e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b14:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104b17:	57                   	push   %edi
f0104b18:	6a 24                	push   $0x24
f0104b1a:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104b1d:	89 c1                	mov    %eax,%ecx
f0104b1f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104b22:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104b25:	89 d8                	mov    %ebx,%eax
f0104b27:	e8 2a fe ff ff       	call   f0104956 <stab_binsearch>

	if (lfun <= rfun) {
f0104b2c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b2f:	83 c4 08             	add    $0x8,%esp
f0104b32:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104b35:	7f 47                	jg     f0104b7e <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104b37:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104b3a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104b3d:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104b40:	8b 02                	mov    (%edx),%eax
f0104b42:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104b45:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104b48:	29 f9                	sub    %edi,%ecx
f0104b4a:	39 c8                	cmp    %ecx,%eax
f0104b4c:	73 05                	jae    f0104b53 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104b4e:	01 f8                	add    %edi,%eax
f0104b50:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104b53:	8b 42 08             	mov    0x8(%edx),%eax
f0104b56:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104b59:	83 ec 08             	sub    $0x8,%esp
f0104b5c:	6a 3a                	push   $0x3a
f0104b5e:	ff 76 08             	pushl  0x8(%esi)
f0104b61:	e8 c4 08 00 00       	call   f010542a <strfind>
f0104b66:	2b 46 08             	sub    0x8(%esi),%eax
f0104b69:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104b6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b6f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104b72:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104b75:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f0104b79:	83 c4 10             	add    $0x10,%esp
f0104b7c:	eb 0e                	jmp    f0104b8c <debuginfo_eip+0x146>
		info->eip_fn_addr = addr;
f0104b7e:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104b81:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b84:	eb d3                	jmp    f0104b59 <debuginfo_eip+0x113>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104b86:	83 eb 01             	sub    $0x1,%ebx
f0104b89:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0104b8c:	39 df                	cmp    %ebx,%edi
f0104b8e:	7f 2e                	jg     f0104bbe <debuginfo_eip+0x178>
	       && stabs[lline].n_type != N_SOL
f0104b90:	0f b6 10             	movzbl (%eax),%edx
f0104b93:	80 fa 84             	cmp    $0x84,%dl
f0104b96:	74 0b                	je     f0104ba3 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104b98:	80 fa 64             	cmp    $0x64,%dl
f0104b9b:	75 e9                	jne    f0104b86 <debuginfo_eip+0x140>
f0104b9d:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104ba1:	74 e3                	je     f0104b86 <debuginfo_eip+0x140>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ba3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ba6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ba9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104bac:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104baf:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104bb2:	29 f8                	sub    %edi,%eax
f0104bb4:	39 c2                	cmp    %eax,%edx
f0104bb6:	73 06                	jae    f0104bbe <debuginfo_eip+0x178>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104bb8:	89 f8                	mov    %edi,%eax
f0104bba:	01 d0                	add    %edx,%eax
f0104bbc:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104bbe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104bc1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104bc4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104bc9:	39 cb                	cmp    %ecx,%ebx
f0104bcb:	7d 44                	jge    f0104c11 <debuginfo_eip+0x1cb>
		for (lline = lfun + 1;
f0104bcd:	8d 53 01             	lea    0x1(%ebx),%edx
f0104bd0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104bd3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bd6:	8d 44 87 10          	lea    0x10(%edi,%eax,4),%eax
f0104bda:	eb 07                	jmp    f0104be3 <debuginfo_eip+0x19d>
			info->eip_fn_narg++;
f0104bdc:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline++)
f0104be0:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0104be3:	39 d1                	cmp    %edx,%ecx
f0104be5:	74 25                	je     f0104c0c <debuginfo_eip+0x1c6>
f0104be7:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104bea:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104bee:	74 ec                	je     f0104bdc <debuginfo_eip+0x196>
	return 0;
f0104bf0:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bf5:	eb 1a                	jmp    f0104c11 <debuginfo_eip+0x1cb>
		return -1;
f0104bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104bfc:	eb 13                	jmp    f0104c11 <debuginfo_eip+0x1cb>
f0104bfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c03:	eb 0c                	jmp    f0104c11 <debuginfo_eip+0x1cb>
		return -1;
f0104c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c0a:	eb 05                	jmp    f0104c11 <debuginfo_eip+0x1cb>
	return 0;
f0104c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c14:	5b                   	pop    %ebx
f0104c15:	5e                   	pop    %esi
f0104c16:	5f                   	pop    %edi
f0104c17:	5d                   	pop    %ebp
f0104c18:	c3                   	ret    

f0104c19 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104c19:	55                   	push   %ebp
f0104c1a:	89 e5                	mov    %esp,%ebp
f0104c1c:	57                   	push   %edi
f0104c1d:	56                   	push   %esi
f0104c1e:	53                   	push   %ebx
f0104c1f:	83 ec 1c             	sub    $0x1c,%esp
f0104c22:	89 c7                	mov    %eax,%edi
f0104c24:	89 d6                	mov    %edx,%esi
f0104c26:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c29:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c2f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104c32:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104c35:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c3a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c3d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104c40:	39 d3                	cmp    %edx,%ebx
f0104c42:	72 05                	jb     f0104c49 <printnum+0x30>
f0104c44:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104c47:	77 7a                	ja     f0104cc3 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104c49:	83 ec 0c             	sub    $0xc,%esp
f0104c4c:	ff 75 18             	pushl  0x18(%ebp)
f0104c4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c52:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104c55:	53                   	push   %ebx
f0104c56:	ff 75 10             	pushl  0x10(%ebp)
f0104c59:	83 ec 08             	sub    $0x8,%esp
f0104c5c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c5f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c62:	ff 75 dc             	pushl  -0x24(%ebp)
f0104c65:	ff 75 d8             	pushl  -0x28(%ebp)
f0104c68:	e8 f3 11 00 00       	call   f0105e60 <__udivdi3>
f0104c6d:	83 c4 18             	add    $0x18,%esp
f0104c70:	52                   	push   %edx
f0104c71:	50                   	push   %eax
f0104c72:	89 f2                	mov    %esi,%edx
f0104c74:	89 f8                	mov    %edi,%eax
f0104c76:	e8 9e ff ff ff       	call   f0104c19 <printnum>
f0104c7b:	83 c4 20             	add    $0x20,%esp
f0104c7e:	eb 13                	jmp    f0104c93 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104c80:	83 ec 08             	sub    $0x8,%esp
f0104c83:	56                   	push   %esi
f0104c84:	ff 75 18             	pushl  0x18(%ebp)
f0104c87:	ff d7                	call   *%edi
f0104c89:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104c8c:	83 eb 01             	sub    $0x1,%ebx
f0104c8f:	85 db                	test   %ebx,%ebx
f0104c91:	7f ed                	jg     f0104c80 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104c93:	83 ec 08             	sub    $0x8,%esp
f0104c96:	56                   	push   %esi
f0104c97:	83 ec 04             	sub    $0x4,%esp
f0104c9a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c9d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ca0:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ca3:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ca6:	e8 d5 12 00 00       	call   f0105f80 <__umoddi3>
f0104cab:	83 c4 14             	add    $0x14,%esp
f0104cae:	0f be 80 42 78 10 f0 	movsbl -0xfef87be(%eax),%eax
f0104cb5:	50                   	push   %eax
f0104cb6:	ff d7                	call   *%edi
}
f0104cb8:	83 c4 10             	add    $0x10,%esp
f0104cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104cbe:	5b                   	pop    %ebx
f0104cbf:	5e                   	pop    %esi
f0104cc0:	5f                   	pop    %edi
f0104cc1:	5d                   	pop    %ebp
f0104cc2:	c3                   	ret    
f0104cc3:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104cc6:	eb c4                	jmp    f0104c8c <printnum+0x73>

f0104cc8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104cc8:	55                   	push   %ebp
f0104cc9:	89 e5                	mov    %esp,%ebp
f0104ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104cce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104cd2:	8b 10                	mov    (%eax),%edx
f0104cd4:	3b 50 04             	cmp    0x4(%eax),%edx
f0104cd7:	73 0a                	jae    f0104ce3 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104cd9:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104cdc:	89 08                	mov    %ecx,(%eax)
f0104cde:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ce1:	88 02                	mov    %al,(%edx)
}
f0104ce3:	5d                   	pop    %ebp
f0104ce4:	c3                   	ret    

f0104ce5 <printfmt>:
{
f0104ce5:	55                   	push   %ebp
f0104ce6:	89 e5                	mov    %esp,%ebp
f0104ce8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104ceb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104cee:	50                   	push   %eax
f0104cef:	ff 75 10             	pushl  0x10(%ebp)
f0104cf2:	ff 75 0c             	pushl  0xc(%ebp)
f0104cf5:	ff 75 08             	pushl  0x8(%ebp)
f0104cf8:	e8 05 00 00 00       	call   f0104d02 <vprintfmt>
}
f0104cfd:	83 c4 10             	add    $0x10,%esp
f0104d00:	c9                   	leave  
f0104d01:	c3                   	ret    

f0104d02 <vprintfmt>:
{
f0104d02:	55                   	push   %ebp
f0104d03:	89 e5                	mov    %esp,%ebp
f0104d05:	57                   	push   %edi
f0104d06:	56                   	push   %esi
f0104d07:	53                   	push   %ebx
f0104d08:	83 ec 2c             	sub    $0x2c,%esp
f0104d0b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d11:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d14:	e9 63 03 00 00       	jmp    f010507c <vprintfmt+0x37a>
		padc = ' ';
f0104d19:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104d1d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104d24:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0104d2b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104d32:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104d37:	8d 47 01             	lea    0x1(%edi),%eax
f0104d3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d3d:	0f b6 17             	movzbl (%edi),%edx
f0104d40:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104d43:	3c 55                	cmp    $0x55,%al
f0104d45:	0f 87 11 04 00 00    	ja     f010515c <vprintfmt+0x45a>
f0104d4b:	0f b6 c0             	movzbl %al,%eax
f0104d4e:	ff 24 85 00 79 10 f0 	jmp    *-0xfef8700(,%eax,4)
f0104d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104d58:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104d5c:	eb d9                	jmp    f0104d37 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104d5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104d61:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104d65:	eb d0                	jmp    f0104d37 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104d67:	0f b6 d2             	movzbl %dl,%edx
f0104d6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104d6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d72:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104d75:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104d78:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104d7c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104d7f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104d82:	83 f9 09             	cmp    $0x9,%ecx
f0104d85:	77 55                	ja     f0104ddc <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0104d87:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104d8a:	eb e9                	jmp    f0104d75 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0104d8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d8f:	8b 00                	mov    (%eax),%eax
f0104d91:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d94:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d97:	8d 40 04             	lea    0x4(%eax),%eax
f0104d9a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104d9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104da0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104da4:	79 91                	jns    f0104d37 <vprintfmt+0x35>
				width = precision, precision = -1;
f0104da6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104da9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104dac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104db3:	eb 82                	jmp    f0104d37 <vprintfmt+0x35>
f0104db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104db8:	85 c0                	test   %eax,%eax
f0104dba:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dbf:	0f 49 d0             	cmovns %eax,%edx
f0104dc2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104dc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104dc8:	e9 6a ff ff ff       	jmp    f0104d37 <vprintfmt+0x35>
f0104dcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104dd0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104dd7:	e9 5b ff ff ff       	jmp    f0104d37 <vprintfmt+0x35>
f0104ddc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104ddf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104de2:	eb bc                	jmp    f0104da0 <vprintfmt+0x9e>
			lflag++;
f0104de4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104de7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104dea:	e9 48 ff ff ff       	jmp    f0104d37 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0104def:	8b 45 14             	mov    0x14(%ebp),%eax
f0104df2:	8d 78 04             	lea    0x4(%eax),%edi
f0104df5:	83 ec 08             	sub    $0x8,%esp
f0104df8:	53                   	push   %ebx
f0104df9:	ff 30                	pushl  (%eax)
f0104dfb:	ff d6                	call   *%esi
			break;
f0104dfd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104e00:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104e03:	e9 71 02 00 00       	jmp    f0105079 <vprintfmt+0x377>
			err = va_arg(ap, int);
f0104e08:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e0b:	8d 78 04             	lea    0x4(%eax),%edi
f0104e0e:	8b 00                	mov    (%eax),%eax
f0104e10:	99                   	cltd   
f0104e11:	31 d0                	xor    %edx,%eax
f0104e13:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104e15:	83 f8 08             	cmp    $0x8,%eax
f0104e18:	7f 23                	jg     f0104e3d <vprintfmt+0x13b>
f0104e1a:	8b 14 85 60 7a 10 f0 	mov    -0xfef85a0(,%eax,4),%edx
f0104e21:	85 d2                	test   %edx,%edx
f0104e23:	74 18                	je     f0104e3d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0104e25:	52                   	push   %edx
f0104e26:	68 c1 6f 10 f0       	push   $0xf0106fc1
f0104e2b:	53                   	push   %ebx
f0104e2c:	56                   	push   %esi
f0104e2d:	e8 b3 fe ff ff       	call   f0104ce5 <printfmt>
f0104e32:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104e35:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104e38:	e9 3c 02 00 00       	jmp    f0105079 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
f0104e3d:	50                   	push   %eax
f0104e3e:	68 5a 78 10 f0       	push   $0xf010785a
f0104e43:	53                   	push   %ebx
f0104e44:	56                   	push   %esi
f0104e45:	e8 9b fe ff ff       	call   f0104ce5 <printfmt>
f0104e4a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104e4d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104e50:	e9 24 02 00 00       	jmp    f0105079 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
f0104e55:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e58:	83 c0 04             	add    $0x4,%eax
f0104e5b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104e5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e61:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104e63:	85 ff                	test   %edi,%edi
f0104e65:	b8 53 78 10 f0       	mov    $0xf0107853,%eax
f0104e6a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104e6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104e71:	0f 8e bd 00 00 00    	jle    f0104f34 <vprintfmt+0x232>
f0104e77:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104e7b:	75 0e                	jne    f0104e8b <vprintfmt+0x189>
f0104e7d:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e80:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104e83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e86:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e89:	eb 6d                	jmp    f0104ef8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e8b:	83 ec 08             	sub    $0x8,%esp
f0104e8e:	ff 75 d0             	pushl  -0x30(%ebp)
f0104e91:	57                   	push   %edi
f0104e92:	e8 4f 04 00 00       	call   f01052e6 <strnlen>
f0104e97:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104e9a:	29 c1                	sub    %eax,%ecx
f0104e9c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104e9f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104ea2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104ea9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104eac:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104eae:	eb 0f                	jmp    f0104ebf <vprintfmt+0x1bd>
					putch(padc, putdat);
f0104eb0:	83 ec 08             	sub    $0x8,%esp
f0104eb3:	53                   	push   %ebx
f0104eb4:	ff 75 e0             	pushl  -0x20(%ebp)
f0104eb7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104eb9:	83 ef 01             	sub    $0x1,%edi
f0104ebc:	83 c4 10             	add    $0x10,%esp
f0104ebf:	85 ff                	test   %edi,%edi
f0104ec1:	7f ed                	jg     f0104eb0 <vprintfmt+0x1ae>
f0104ec3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ec6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104ec9:	85 c9                	test   %ecx,%ecx
f0104ecb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ed0:	0f 49 c1             	cmovns %ecx,%eax
f0104ed3:	29 c1                	sub    %eax,%ecx
f0104ed5:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ed8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104edb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ede:	89 cb                	mov    %ecx,%ebx
f0104ee0:	eb 16                	jmp    f0104ef8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f0104ee2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104ee6:	75 31                	jne    f0104f19 <vprintfmt+0x217>
					putch(ch, putdat);
f0104ee8:	83 ec 08             	sub    $0x8,%esp
f0104eeb:	ff 75 0c             	pushl  0xc(%ebp)
f0104eee:	50                   	push   %eax
f0104eef:	ff 55 08             	call   *0x8(%ebp)
f0104ef2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ef5:	83 eb 01             	sub    $0x1,%ebx
f0104ef8:	83 c7 01             	add    $0x1,%edi
f0104efb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104eff:	0f be c2             	movsbl %dl,%eax
f0104f02:	85 c0                	test   %eax,%eax
f0104f04:	74 59                	je     f0104f5f <vprintfmt+0x25d>
f0104f06:	85 f6                	test   %esi,%esi
f0104f08:	78 d8                	js     f0104ee2 <vprintfmt+0x1e0>
f0104f0a:	83 ee 01             	sub    $0x1,%esi
f0104f0d:	79 d3                	jns    f0104ee2 <vprintfmt+0x1e0>
f0104f0f:	89 df                	mov    %ebx,%edi
f0104f11:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f17:	eb 37                	jmp    f0104f50 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104f19:	0f be d2             	movsbl %dl,%edx
f0104f1c:	83 ea 20             	sub    $0x20,%edx
f0104f1f:	83 fa 5e             	cmp    $0x5e,%edx
f0104f22:	76 c4                	jbe    f0104ee8 <vprintfmt+0x1e6>
					putch('?', putdat);
f0104f24:	83 ec 08             	sub    $0x8,%esp
f0104f27:	ff 75 0c             	pushl  0xc(%ebp)
f0104f2a:	6a 3f                	push   $0x3f
f0104f2c:	ff 55 08             	call   *0x8(%ebp)
f0104f2f:	83 c4 10             	add    $0x10,%esp
f0104f32:	eb c1                	jmp    f0104ef5 <vprintfmt+0x1f3>
f0104f34:	89 75 08             	mov    %esi,0x8(%ebp)
f0104f37:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104f40:	eb b6                	jmp    f0104ef8 <vprintfmt+0x1f6>
				putch(' ', putdat);
f0104f42:	83 ec 08             	sub    $0x8,%esp
f0104f45:	53                   	push   %ebx
f0104f46:	6a 20                	push   $0x20
f0104f48:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104f4a:	83 ef 01             	sub    $0x1,%edi
f0104f4d:	83 c4 10             	add    $0x10,%esp
f0104f50:	85 ff                	test   %edi,%edi
f0104f52:	7f ee                	jg     f0104f42 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0104f54:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104f57:	89 45 14             	mov    %eax,0x14(%ebp)
f0104f5a:	e9 1a 01 00 00       	jmp    f0105079 <vprintfmt+0x377>
f0104f5f:	89 df                	mov    %ebx,%edi
f0104f61:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f67:	eb e7                	jmp    f0104f50 <vprintfmt+0x24e>
	if (lflag >= 2)
f0104f69:	83 f9 01             	cmp    $0x1,%ecx
f0104f6c:	7e 3f                	jle    f0104fad <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0104f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f71:	8b 50 04             	mov    0x4(%eax),%edx
f0104f74:	8b 00                	mov    (%eax),%eax
f0104f76:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f79:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104f7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f7f:	8d 40 08             	lea    0x8(%eax),%eax
f0104f82:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104f85:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104f89:	79 5c                	jns    f0104fe7 <vprintfmt+0x2e5>
				putch('-', putdat);
f0104f8b:	83 ec 08             	sub    $0x8,%esp
f0104f8e:	53                   	push   %ebx
f0104f8f:	6a 2d                	push   $0x2d
f0104f91:	ff d6                	call   *%esi
				num = -(long long) num;
f0104f93:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104f96:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104f99:	f7 da                	neg    %edx
f0104f9b:	83 d1 00             	adc    $0x0,%ecx
f0104f9e:	f7 d9                	neg    %ecx
f0104fa0:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104fa3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104fa8:	e9 b2 00 00 00       	jmp    f010505f <vprintfmt+0x35d>
	else if (lflag)
f0104fad:	85 c9                	test   %ecx,%ecx
f0104faf:	75 1b                	jne    f0104fcc <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0104fb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb4:	8b 00                	mov    (%eax),%eax
f0104fb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fb9:	89 c1                	mov    %eax,%ecx
f0104fbb:	c1 f9 1f             	sar    $0x1f,%ecx
f0104fbe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104fc1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fc4:	8d 40 04             	lea    0x4(%eax),%eax
f0104fc7:	89 45 14             	mov    %eax,0x14(%ebp)
f0104fca:	eb b9                	jmp    f0104f85 <vprintfmt+0x283>
		return va_arg(*ap, long);
f0104fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fcf:	8b 00                	mov    (%eax),%eax
f0104fd1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fd4:	89 c1                	mov    %eax,%ecx
f0104fd6:	c1 f9 1f             	sar    $0x1f,%ecx
f0104fd9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104fdc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fdf:	8d 40 04             	lea    0x4(%eax),%eax
f0104fe2:	89 45 14             	mov    %eax,0x14(%ebp)
f0104fe5:	eb 9e                	jmp    f0104f85 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f0104fe7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104fea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104fed:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ff2:	eb 6b                	jmp    f010505f <vprintfmt+0x35d>
	if (lflag >= 2)
f0104ff4:	83 f9 01             	cmp    $0x1,%ecx
f0104ff7:	7e 15                	jle    f010500e <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
f0104ff9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ffc:	8b 10                	mov    (%eax),%edx
f0104ffe:	8b 48 04             	mov    0x4(%eax),%ecx
f0105001:	8d 40 08             	lea    0x8(%eax),%eax
f0105004:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105007:	b8 0a 00 00 00       	mov    $0xa,%eax
f010500c:	eb 51                	jmp    f010505f <vprintfmt+0x35d>
	else if (lflag)
f010500e:	85 c9                	test   %ecx,%ecx
f0105010:	75 17                	jne    f0105029 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
f0105012:	8b 45 14             	mov    0x14(%ebp),%eax
f0105015:	8b 10                	mov    (%eax),%edx
f0105017:	b9 00 00 00 00       	mov    $0x0,%ecx
f010501c:	8d 40 04             	lea    0x4(%eax),%eax
f010501f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105022:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105027:	eb 36                	jmp    f010505f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
f0105029:	8b 45 14             	mov    0x14(%ebp),%eax
f010502c:	8b 10                	mov    (%eax),%edx
f010502e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105033:	8d 40 04             	lea    0x4(%eax),%eax
f0105036:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105039:	b8 0a 00 00 00       	mov    $0xa,%eax
f010503e:	eb 1f                	jmp    f010505f <vprintfmt+0x35d>
	if (lflag >= 2)
f0105040:	83 f9 01             	cmp    $0x1,%ecx
f0105043:	7e 5b                	jle    f01050a0 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
f0105045:	8b 45 14             	mov    0x14(%ebp),%eax
f0105048:	8b 50 04             	mov    0x4(%eax),%edx
f010504b:	8b 00                	mov    (%eax),%eax
f010504d:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105050:	8d 49 08             	lea    0x8(%ecx),%ecx
f0105053:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0105056:	89 d1                	mov    %edx,%ecx
f0105058:	89 c2                	mov    %eax,%edx
			base = 8;
f010505a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f010505f:	83 ec 0c             	sub    $0xc,%esp
f0105062:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105066:	57                   	push   %edi
f0105067:	ff 75 e0             	pushl  -0x20(%ebp)
f010506a:	50                   	push   %eax
f010506b:	51                   	push   %ecx
f010506c:	52                   	push   %edx
f010506d:	89 da                	mov    %ebx,%edx
f010506f:	89 f0                	mov    %esi,%eax
f0105071:	e8 a3 fb ff ff       	call   f0104c19 <printnum>
			break;
f0105076:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105079:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010507c:	83 c7 01             	add    $0x1,%edi
f010507f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105083:	83 f8 25             	cmp    $0x25,%eax
f0105086:	0f 84 8d fc ff ff    	je     f0104d19 <vprintfmt+0x17>
			if (ch == '\0')
f010508c:	85 c0                	test   %eax,%eax
f010508e:	0f 84 e8 00 00 00    	je     f010517c <vprintfmt+0x47a>
			putch(ch, putdat);
f0105094:	83 ec 08             	sub    $0x8,%esp
f0105097:	53                   	push   %ebx
f0105098:	50                   	push   %eax
f0105099:	ff d6                	call   *%esi
f010509b:	83 c4 10             	add    $0x10,%esp
f010509e:	eb dc                	jmp    f010507c <vprintfmt+0x37a>
	else if (lflag)
f01050a0:	85 c9                	test   %ecx,%ecx
f01050a2:	75 13                	jne    f01050b7 <vprintfmt+0x3b5>
		return va_arg(*ap, int);
f01050a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050a7:	8b 10                	mov    (%eax),%edx
f01050a9:	89 d0                	mov    %edx,%eax
f01050ab:	99                   	cltd   
f01050ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01050af:	8d 49 04             	lea    0x4(%ecx),%ecx
f01050b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01050b5:	eb 9f                	jmp    f0105056 <vprintfmt+0x354>
		return va_arg(*ap, long);
f01050b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ba:	8b 10                	mov    (%eax),%edx
f01050bc:	89 d0                	mov    %edx,%eax
f01050be:	99                   	cltd   
f01050bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01050c2:	8d 49 04             	lea    0x4(%ecx),%ecx
f01050c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01050c8:	eb 8c                	jmp    f0105056 <vprintfmt+0x354>
			putch('0', putdat);
f01050ca:	83 ec 08             	sub    $0x8,%esp
f01050cd:	53                   	push   %ebx
f01050ce:	6a 30                	push   $0x30
f01050d0:	ff d6                	call   *%esi
			putch('x', putdat);
f01050d2:	83 c4 08             	add    $0x8,%esp
f01050d5:	53                   	push   %ebx
f01050d6:	6a 78                	push   $0x78
f01050d8:	ff d6                	call   *%esi
			num = (unsigned long long)
f01050da:	8b 45 14             	mov    0x14(%ebp),%eax
f01050dd:	8b 10                	mov    (%eax),%edx
f01050df:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01050e4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01050e7:	8d 40 04             	lea    0x4(%eax),%eax
f01050ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01050ed:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01050f2:	e9 68 ff ff ff       	jmp    f010505f <vprintfmt+0x35d>
	if (lflag >= 2)
f01050f7:	83 f9 01             	cmp    $0x1,%ecx
f01050fa:	7e 18                	jle    f0105114 <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
f01050fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ff:	8b 10                	mov    (%eax),%edx
f0105101:	8b 48 04             	mov    0x4(%eax),%ecx
f0105104:	8d 40 08             	lea    0x8(%eax),%eax
f0105107:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010510a:	b8 10 00 00 00       	mov    $0x10,%eax
f010510f:	e9 4b ff ff ff       	jmp    f010505f <vprintfmt+0x35d>
	else if (lflag)
f0105114:	85 c9                	test   %ecx,%ecx
f0105116:	75 1a                	jne    f0105132 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
f0105118:	8b 45 14             	mov    0x14(%ebp),%eax
f010511b:	8b 10                	mov    (%eax),%edx
f010511d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105122:	8d 40 04             	lea    0x4(%eax),%eax
f0105125:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105128:	b8 10 00 00 00       	mov    $0x10,%eax
f010512d:	e9 2d ff ff ff       	jmp    f010505f <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
f0105132:	8b 45 14             	mov    0x14(%ebp),%eax
f0105135:	8b 10                	mov    (%eax),%edx
f0105137:	b9 00 00 00 00       	mov    $0x0,%ecx
f010513c:	8d 40 04             	lea    0x4(%eax),%eax
f010513f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105142:	b8 10 00 00 00       	mov    $0x10,%eax
f0105147:	e9 13 ff ff ff       	jmp    f010505f <vprintfmt+0x35d>
			putch(ch, putdat);
f010514c:	83 ec 08             	sub    $0x8,%esp
f010514f:	53                   	push   %ebx
f0105150:	6a 25                	push   $0x25
f0105152:	ff d6                	call   *%esi
			break;
f0105154:	83 c4 10             	add    $0x10,%esp
f0105157:	e9 1d ff ff ff       	jmp    f0105079 <vprintfmt+0x377>
			putch('%', putdat);
f010515c:	83 ec 08             	sub    $0x8,%esp
f010515f:	53                   	push   %ebx
f0105160:	6a 25                	push   $0x25
f0105162:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105164:	83 c4 10             	add    $0x10,%esp
f0105167:	89 f8                	mov    %edi,%eax
f0105169:	eb 03                	jmp    f010516e <vprintfmt+0x46c>
f010516b:	83 e8 01             	sub    $0x1,%eax
f010516e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105172:	75 f7                	jne    f010516b <vprintfmt+0x469>
f0105174:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105177:	e9 fd fe ff ff       	jmp    f0105079 <vprintfmt+0x377>
}
f010517c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010517f:	5b                   	pop    %ebx
f0105180:	5e                   	pop    %esi
f0105181:	5f                   	pop    %edi
f0105182:	5d                   	pop    %ebp
f0105183:	c3                   	ret    

f0105184 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105184:	55                   	push   %ebp
f0105185:	89 e5                	mov    %esp,%ebp
f0105187:	83 ec 18             	sub    $0x18,%esp
f010518a:	8b 45 08             	mov    0x8(%ebp),%eax
f010518d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105190:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105193:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105197:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010519a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01051a1:	85 c0                	test   %eax,%eax
f01051a3:	74 26                	je     f01051cb <vsnprintf+0x47>
f01051a5:	85 d2                	test   %edx,%edx
f01051a7:	7e 22                	jle    f01051cb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01051a9:	ff 75 14             	pushl  0x14(%ebp)
f01051ac:	ff 75 10             	pushl  0x10(%ebp)
f01051af:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01051b2:	50                   	push   %eax
f01051b3:	68 c8 4c 10 f0       	push   $0xf0104cc8
f01051b8:	e8 45 fb ff ff       	call   f0104d02 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01051bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01051c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01051c6:	83 c4 10             	add    $0x10,%esp
}
f01051c9:	c9                   	leave  
f01051ca:	c3                   	ret    
		return -E_INVAL;
f01051cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051d0:	eb f7                	jmp    f01051c9 <vsnprintf+0x45>

f01051d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01051d2:	55                   	push   %ebp
f01051d3:	89 e5                	mov    %esp,%ebp
f01051d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01051d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01051db:	50                   	push   %eax
f01051dc:	ff 75 10             	pushl  0x10(%ebp)
f01051df:	ff 75 0c             	pushl  0xc(%ebp)
f01051e2:	ff 75 08             	pushl  0x8(%ebp)
f01051e5:	e8 9a ff ff ff       	call   f0105184 <vsnprintf>
	va_end(ap);

	return rc;
}
f01051ea:	c9                   	leave  
f01051eb:	c3                   	ret    

f01051ec <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01051ec:	55                   	push   %ebp
f01051ed:	89 e5                	mov    %esp,%ebp
f01051ef:	57                   	push   %edi
f01051f0:	56                   	push   %esi
f01051f1:	53                   	push   %ebx
f01051f2:	83 ec 0c             	sub    $0xc,%esp
f01051f5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01051f8:	85 c0                	test   %eax,%eax
f01051fa:	74 11                	je     f010520d <readline+0x21>
		cprintf("%s", prompt);
f01051fc:	83 ec 08             	sub    $0x8,%esp
f01051ff:	50                   	push   %eax
f0105200:	68 c1 6f 10 f0       	push   $0xf0106fc1
f0105205:	e8 c7 e7 ff ff       	call   f01039d1 <cprintf>
f010520a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010520d:	83 ec 0c             	sub    $0xc,%esp
f0105210:	6a 00                	push   $0x0
f0105212:	e8 8e b5 ff ff       	call   f01007a5 <iscons>
f0105217:	89 c7                	mov    %eax,%edi
f0105219:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010521c:	be 00 00 00 00       	mov    $0x0,%esi
f0105221:	eb 3f                	jmp    f0105262 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105223:	83 ec 08             	sub    $0x8,%esp
f0105226:	50                   	push   %eax
f0105227:	68 84 7a 10 f0       	push   $0xf0107a84
f010522c:	e8 a0 e7 ff ff       	call   f01039d1 <cprintf>
			return NULL;
f0105231:	83 c4 10             	add    $0x10,%esp
f0105234:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105239:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010523c:	5b                   	pop    %ebx
f010523d:	5e                   	pop    %esi
f010523e:	5f                   	pop    %edi
f010523f:	5d                   	pop    %ebp
f0105240:	c3                   	ret    
			if (echoing)
f0105241:	85 ff                	test   %edi,%edi
f0105243:	75 05                	jne    f010524a <readline+0x5e>
			i--;
f0105245:	83 ee 01             	sub    $0x1,%esi
f0105248:	eb 18                	jmp    f0105262 <readline+0x76>
				cputchar('\b');
f010524a:	83 ec 0c             	sub    $0xc,%esp
f010524d:	6a 08                	push   $0x8
f010524f:	e8 30 b5 ff ff       	call   f0100784 <cputchar>
f0105254:	83 c4 10             	add    $0x10,%esp
f0105257:	eb ec                	jmp    f0105245 <readline+0x59>
			buf[i++] = c;
f0105259:	88 9e 80 da 22 f0    	mov    %bl,-0xfdd2580(%esi)
f010525f:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105262:	e8 2d b5 ff ff       	call   f0100794 <getchar>
f0105267:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105269:	85 c0                	test   %eax,%eax
f010526b:	78 b6                	js     f0105223 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010526d:	83 f8 08             	cmp    $0x8,%eax
f0105270:	0f 94 c2             	sete   %dl
f0105273:	83 f8 7f             	cmp    $0x7f,%eax
f0105276:	0f 94 c0             	sete   %al
f0105279:	08 c2                	or     %al,%dl
f010527b:	74 04                	je     f0105281 <readline+0x95>
f010527d:	85 f6                	test   %esi,%esi
f010527f:	7f c0                	jg     f0105241 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105281:	83 fb 1f             	cmp    $0x1f,%ebx
f0105284:	7e 1a                	jle    f01052a0 <readline+0xb4>
f0105286:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010528c:	7f 12                	jg     f01052a0 <readline+0xb4>
			if (echoing)
f010528e:	85 ff                	test   %edi,%edi
f0105290:	74 c7                	je     f0105259 <readline+0x6d>
				cputchar(c);
f0105292:	83 ec 0c             	sub    $0xc,%esp
f0105295:	53                   	push   %ebx
f0105296:	e8 e9 b4 ff ff       	call   f0100784 <cputchar>
f010529b:	83 c4 10             	add    $0x10,%esp
f010529e:	eb b9                	jmp    f0105259 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01052a0:	83 fb 0a             	cmp    $0xa,%ebx
f01052a3:	74 05                	je     f01052aa <readline+0xbe>
f01052a5:	83 fb 0d             	cmp    $0xd,%ebx
f01052a8:	75 b8                	jne    f0105262 <readline+0x76>
			if (echoing)
f01052aa:	85 ff                	test   %edi,%edi
f01052ac:	75 11                	jne    f01052bf <readline+0xd3>
			buf[i] = 0;
f01052ae:	c6 86 80 da 22 f0 00 	movb   $0x0,-0xfdd2580(%esi)
			return buf;
f01052b5:	b8 80 da 22 f0       	mov    $0xf022da80,%eax
f01052ba:	e9 7a ff ff ff       	jmp    f0105239 <readline+0x4d>
				cputchar('\n');
f01052bf:	83 ec 0c             	sub    $0xc,%esp
f01052c2:	6a 0a                	push   $0xa
f01052c4:	e8 bb b4 ff ff       	call   f0100784 <cputchar>
f01052c9:	83 c4 10             	add    $0x10,%esp
f01052cc:	eb e0                	jmp    f01052ae <readline+0xc2>

f01052ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01052ce:	55                   	push   %ebp
f01052cf:	89 e5                	mov    %esp,%ebp
f01052d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01052d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01052d9:	eb 03                	jmp    f01052de <strlen+0x10>
		n++;
f01052db:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01052de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01052e2:	75 f7                	jne    f01052db <strlen+0xd>
	return n;
}
f01052e4:	5d                   	pop    %ebp
f01052e5:	c3                   	ret    

f01052e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01052e6:	55                   	push   %ebp
f01052e7:	89 e5                	mov    %esp,%ebp
f01052e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01052ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f4:	eb 03                	jmp    f01052f9 <strnlen+0x13>
		n++;
f01052f6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01052f9:	39 d0                	cmp    %edx,%eax
f01052fb:	74 06                	je     f0105303 <strnlen+0x1d>
f01052fd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105301:	75 f3                	jne    f01052f6 <strnlen+0x10>
	return n;
}
f0105303:	5d                   	pop    %ebp
f0105304:	c3                   	ret    

f0105305 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105305:	55                   	push   %ebp
f0105306:	89 e5                	mov    %esp,%ebp
f0105308:	53                   	push   %ebx
f0105309:	8b 45 08             	mov    0x8(%ebp),%eax
f010530c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010530f:	89 c2                	mov    %eax,%edx
f0105311:	83 c1 01             	add    $0x1,%ecx
f0105314:	83 c2 01             	add    $0x1,%edx
f0105317:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010531b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010531e:	84 db                	test   %bl,%bl
f0105320:	75 ef                	jne    f0105311 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105322:	5b                   	pop    %ebx
f0105323:	5d                   	pop    %ebp
f0105324:	c3                   	ret    

f0105325 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105325:	55                   	push   %ebp
f0105326:	89 e5                	mov    %esp,%ebp
f0105328:	53                   	push   %ebx
f0105329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010532c:	53                   	push   %ebx
f010532d:	e8 9c ff ff ff       	call   f01052ce <strlen>
f0105332:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105335:	ff 75 0c             	pushl  0xc(%ebp)
f0105338:	01 d8                	add    %ebx,%eax
f010533a:	50                   	push   %eax
f010533b:	e8 c5 ff ff ff       	call   f0105305 <strcpy>
	return dst;
}
f0105340:	89 d8                	mov    %ebx,%eax
f0105342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105345:	c9                   	leave  
f0105346:	c3                   	ret    

f0105347 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105347:	55                   	push   %ebp
f0105348:	89 e5                	mov    %esp,%ebp
f010534a:	56                   	push   %esi
f010534b:	53                   	push   %ebx
f010534c:	8b 75 08             	mov    0x8(%ebp),%esi
f010534f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105352:	89 f3                	mov    %esi,%ebx
f0105354:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105357:	89 f2                	mov    %esi,%edx
f0105359:	eb 0f                	jmp    f010536a <strncpy+0x23>
		*dst++ = *src;
f010535b:	83 c2 01             	add    $0x1,%edx
f010535e:	0f b6 01             	movzbl (%ecx),%eax
f0105361:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105364:	80 39 01             	cmpb   $0x1,(%ecx)
f0105367:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010536a:	39 da                	cmp    %ebx,%edx
f010536c:	75 ed                	jne    f010535b <strncpy+0x14>
	}
	return ret;
}
f010536e:	89 f0                	mov    %esi,%eax
f0105370:	5b                   	pop    %ebx
f0105371:	5e                   	pop    %esi
f0105372:	5d                   	pop    %ebp
f0105373:	c3                   	ret    

f0105374 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105374:	55                   	push   %ebp
f0105375:	89 e5                	mov    %esp,%ebp
f0105377:	56                   	push   %esi
f0105378:	53                   	push   %ebx
f0105379:	8b 75 08             	mov    0x8(%ebp),%esi
f010537c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010537f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105382:	89 f0                	mov    %esi,%eax
f0105384:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105388:	85 c9                	test   %ecx,%ecx
f010538a:	75 0b                	jne    f0105397 <strlcpy+0x23>
f010538c:	eb 17                	jmp    f01053a5 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010538e:	83 c2 01             	add    $0x1,%edx
f0105391:	83 c0 01             	add    $0x1,%eax
f0105394:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105397:	39 d8                	cmp    %ebx,%eax
f0105399:	74 07                	je     f01053a2 <strlcpy+0x2e>
f010539b:	0f b6 0a             	movzbl (%edx),%ecx
f010539e:	84 c9                	test   %cl,%cl
f01053a0:	75 ec                	jne    f010538e <strlcpy+0x1a>
		*dst = '\0';
f01053a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01053a5:	29 f0                	sub    %esi,%eax
}
f01053a7:	5b                   	pop    %ebx
f01053a8:	5e                   	pop    %esi
f01053a9:	5d                   	pop    %ebp
f01053aa:	c3                   	ret    

f01053ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01053ab:	55                   	push   %ebp
f01053ac:	89 e5                	mov    %esp,%ebp
f01053ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01053b4:	eb 06                	jmp    f01053bc <strcmp+0x11>
		p++, q++;
f01053b6:	83 c1 01             	add    $0x1,%ecx
f01053b9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01053bc:	0f b6 01             	movzbl (%ecx),%eax
f01053bf:	84 c0                	test   %al,%al
f01053c1:	74 04                	je     f01053c7 <strcmp+0x1c>
f01053c3:	3a 02                	cmp    (%edx),%al
f01053c5:	74 ef                	je     f01053b6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01053c7:	0f b6 c0             	movzbl %al,%eax
f01053ca:	0f b6 12             	movzbl (%edx),%edx
f01053cd:	29 d0                	sub    %edx,%eax
}
f01053cf:	5d                   	pop    %ebp
f01053d0:	c3                   	ret    

f01053d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01053d1:	55                   	push   %ebp
f01053d2:	89 e5                	mov    %esp,%ebp
f01053d4:	53                   	push   %ebx
f01053d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01053d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053db:	89 c3                	mov    %eax,%ebx
f01053dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01053e0:	eb 06                	jmp    f01053e8 <strncmp+0x17>
		n--, p++, q++;
f01053e2:	83 c0 01             	add    $0x1,%eax
f01053e5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01053e8:	39 d8                	cmp    %ebx,%eax
f01053ea:	74 16                	je     f0105402 <strncmp+0x31>
f01053ec:	0f b6 08             	movzbl (%eax),%ecx
f01053ef:	84 c9                	test   %cl,%cl
f01053f1:	74 04                	je     f01053f7 <strncmp+0x26>
f01053f3:	3a 0a                	cmp    (%edx),%cl
f01053f5:	74 eb                	je     f01053e2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01053f7:	0f b6 00             	movzbl (%eax),%eax
f01053fa:	0f b6 12             	movzbl (%edx),%edx
f01053fd:	29 d0                	sub    %edx,%eax
}
f01053ff:	5b                   	pop    %ebx
f0105400:	5d                   	pop    %ebp
f0105401:	c3                   	ret    
		return 0;
f0105402:	b8 00 00 00 00       	mov    $0x0,%eax
f0105407:	eb f6                	jmp    f01053ff <strncmp+0x2e>

f0105409 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105409:	55                   	push   %ebp
f010540a:	89 e5                	mov    %esp,%ebp
f010540c:	8b 45 08             	mov    0x8(%ebp),%eax
f010540f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105413:	0f b6 10             	movzbl (%eax),%edx
f0105416:	84 d2                	test   %dl,%dl
f0105418:	74 09                	je     f0105423 <strchr+0x1a>
		if (*s == c)
f010541a:	38 ca                	cmp    %cl,%dl
f010541c:	74 0a                	je     f0105428 <strchr+0x1f>
	for (; *s; s++)
f010541e:	83 c0 01             	add    $0x1,%eax
f0105421:	eb f0                	jmp    f0105413 <strchr+0xa>
			return (char *) s;
	return 0;
f0105423:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105428:	5d                   	pop    %ebp
f0105429:	c3                   	ret    

f010542a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010542a:	55                   	push   %ebp
f010542b:	89 e5                	mov    %esp,%ebp
f010542d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105430:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105434:	eb 03                	jmp    f0105439 <strfind+0xf>
f0105436:	83 c0 01             	add    $0x1,%eax
f0105439:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010543c:	38 ca                	cmp    %cl,%dl
f010543e:	74 04                	je     f0105444 <strfind+0x1a>
f0105440:	84 d2                	test   %dl,%dl
f0105442:	75 f2                	jne    f0105436 <strfind+0xc>
			break;
	return (char *) s;
}
f0105444:	5d                   	pop    %ebp
f0105445:	c3                   	ret    

f0105446 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105446:	55                   	push   %ebp
f0105447:	89 e5                	mov    %esp,%ebp
f0105449:	57                   	push   %edi
f010544a:	56                   	push   %esi
f010544b:	53                   	push   %ebx
f010544c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010544f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105452:	85 c9                	test   %ecx,%ecx
f0105454:	74 13                	je     f0105469 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105456:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010545c:	75 05                	jne    f0105463 <memset+0x1d>
f010545e:	f6 c1 03             	test   $0x3,%cl
f0105461:	74 0d                	je     f0105470 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105463:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105466:	fc                   	cld    
f0105467:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105469:	89 f8                	mov    %edi,%eax
f010546b:	5b                   	pop    %ebx
f010546c:	5e                   	pop    %esi
f010546d:	5f                   	pop    %edi
f010546e:	5d                   	pop    %ebp
f010546f:	c3                   	ret    
		c &= 0xFF;
f0105470:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105474:	89 d3                	mov    %edx,%ebx
f0105476:	c1 e3 08             	shl    $0x8,%ebx
f0105479:	89 d0                	mov    %edx,%eax
f010547b:	c1 e0 18             	shl    $0x18,%eax
f010547e:	89 d6                	mov    %edx,%esi
f0105480:	c1 e6 10             	shl    $0x10,%esi
f0105483:	09 f0                	or     %esi,%eax
f0105485:	09 c2                	or     %eax,%edx
f0105487:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105489:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010548c:	89 d0                	mov    %edx,%eax
f010548e:	fc                   	cld    
f010548f:	f3 ab                	rep stos %eax,%es:(%edi)
f0105491:	eb d6                	jmp    f0105469 <memset+0x23>

f0105493 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105493:	55                   	push   %ebp
f0105494:	89 e5                	mov    %esp,%ebp
f0105496:	57                   	push   %edi
f0105497:	56                   	push   %esi
f0105498:	8b 45 08             	mov    0x8(%ebp),%eax
f010549b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010549e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01054a1:	39 c6                	cmp    %eax,%esi
f01054a3:	73 35                	jae    f01054da <memmove+0x47>
f01054a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01054a8:	39 c2                	cmp    %eax,%edx
f01054aa:	76 2e                	jbe    f01054da <memmove+0x47>
		s += n;
		d += n;
f01054ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054af:	89 d6                	mov    %edx,%esi
f01054b1:	09 fe                	or     %edi,%esi
f01054b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01054b9:	74 0c                	je     f01054c7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01054bb:	83 ef 01             	sub    $0x1,%edi
f01054be:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01054c1:	fd                   	std    
f01054c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01054c4:	fc                   	cld    
f01054c5:	eb 21                	jmp    f01054e8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054c7:	f6 c1 03             	test   $0x3,%cl
f01054ca:	75 ef                	jne    f01054bb <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01054cc:	83 ef 04             	sub    $0x4,%edi
f01054cf:	8d 72 fc             	lea    -0x4(%edx),%esi
f01054d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01054d5:	fd                   	std    
f01054d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01054d8:	eb ea                	jmp    f01054c4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054da:	89 f2                	mov    %esi,%edx
f01054dc:	09 c2                	or     %eax,%edx
f01054de:	f6 c2 03             	test   $0x3,%dl
f01054e1:	74 09                	je     f01054ec <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01054e3:	89 c7                	mov    %eax,%edi
f01054e5:	fc                   	cld    
f01054e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01054e8:	5e                   	pop    %esi
f01054e9:	5f                   	pop    %edi
f01054ea:	5d                   	pop    %ebp
f01054eb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054ec:	f6 c1 03             	test   $0x3,%cl
f01054ef:	75 f2                	jne    f01054e3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01054f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01054f4:	89 c7                	mov    %eax,%edi
f01054f6:	fc                   	cld    
f01054f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01054f9:	eb ed                	jmp    f01054e8 <memmove+0x55>

f01054fb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01054fb:	55                   	push   %ebp
f01054fc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01054fe:	ff 75 10             	pushl  0x10(%ebp)
f0105501:	ff 75 0c             	pushl  0xc(%ebp)
f0105504:	ff 75 08             	pushl  0x8(%ebp)
f0105507:	e8 87 ff ff ff       	call   f0105493 <memmove>
}
f010550c:	c9                   	leave  
f010550d:	c3                   	ret    

f010550e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010550e:	55                   	push   %ebp
f010550f:	89 e5                	mov    %esp,%ebp
f0105511:	56                   	push   %esi
f0105512:	53                   	push   %ebx
f0105513:	8b 45 08             	mov    0x8(%ebp),%eax
f0105516:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105519:	89 c6                	mov    %eax,%esi
f010551b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010551e:	39 f0                	cmp    %esi,%eax
f0105520:	74 1c                	je     f010553e <memcmp+0x30>
		if (*s1 != *s2)
f0105522:	0f b6 08             	movzbl (%eax),%ecx
f0105525:	0f b6 1a             	movzbl (%edx),%ebx
f0105528:	38 d9                	cmp    %bl,%cl
f010552a:	75 08                	jne    f0105534 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010552c:	83 c0 01             	add    $0x1,%eax
f010552f:	83 c2 01             	add    $0x1,%edx
f0105532:	eb ea                	jmp    f010551e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105534:	0f b6 c1             	movzbl %cl,%eax
f0105537:	0f b6 db             	movzbl %bl,%ebx
f010553a:	29 d8                	sub    %ebx,%eax
f010553c:	eb 05                	jmp    f0105543 <memcmp+0x35>
	}

	return 0;
f010553e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105543:	5b                   	pop    %ebx
f0105544:	5e                   	pop    %esi
f0105545:	5d                   	pop    %ebp
f0105546:	c3                   	ret    

f0105547 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105547:	55                   	push   %ebp
f0105548:	89 e5                	mov    %esp,%ebp
f010554a:	8b 45 08             	mov    0x8(%ebp),%eax
f010554d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105550:	89 c2                	mov    %eax,%edx
f0105552:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105555:	39 d0                	cmp    %edx,%eax
f0105557:	73 09                	jae    f0105562 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105559:	38 08                	cmp    %cl,(%eax)
f010555b:	74 05                	je     f0105562 <memfind+0x1b>
	for (; s < ends; s++)
f010555d:	83 c0 01             	add    $0x1,%eax
f0105560:	eb f3                	jmp    f0105555 <memfind+0xe>
			break;
	return (void *) s;
}
f0105562:	5d                   	pop    %ebp
f0105563:	c3                   	ret    

f0105564 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105564:	55                   	push   %ebp
f0105565:	89 e5                	mov    %esp,%ebp
f0105567:	57                   	push   %edi
f0105568:	56                   	push   %esi
f0105569:	53                   	push   %ebx
f010556a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010556d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105570:	eb 03                	jmp    f0105575 <strtol+0x11>
		s++;
f0105572:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105575:	0f b6 01             	movzbl (%ecx),%eax
f0105578:	3c 20                	cmp    $0x20,%al
f010557a:	74 f6                	je     f0105572 <strtol+0xe>
f010557c:	3c 09                	cmp    $0x9,%al
f010557e:	74 f2                	je     f0105572 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105580:	3c 2b                	cmp    $0x2b,%al
f0105582:	74 2e                	je     f01055b2 <strtol+0x4e>
	int neg = 0;
f0105584:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105589:	3c 2d                	cmp    $0x2d,%al
f010558b:	74 2f                	je     f01055bc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010558d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105593:	75 05                	jne    f010559a <strtol+0x36>
f0105595:	80 39 30             	cmpb   $0x30,(%ecx)
f0105598:	74 2c                	je     f01055c6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010559a:	85 db                	test   %ebx,%ebx
f010559c:	75 0a                	jne    f01055a8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010559e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01055a3:	80 39 30             	cmpb   $0x30,(%ecx)
f01055a6:	74 28                	je     f01055d0 <strtol+0x6c>
		base = 10;
f01055a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ad:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01055b0:	eb 50                	jmp    f0105602 <strtol+0x9e>
		s++;
f01055b2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01055b5:	bf 00 00 00 00       	mov    $0x0,%edi
f01055ba:	eb d1                	jmp    f010558d <strtol+0x29>
		s++, neg = 1;
f01055bc:	83 c1 01             	add    $0x1,%ecx
f01055bf:	bf 01 00 00 00       	mov    $0x1,%edi
f01055c4:	eb c7                	jmp    f010558d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01055ca:	74 0e                	je     f01055da <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01055cc:	85 db                	test   %ebx,%ebx
f01055ce:	75 d8                	jne    f01055a8 <strtol+0x44>
		s++, base = 8;
f01055d0:	83 c1 01             	add    $0x1,%ecx
f01055d3:	bb 08 00 00 00       	mov    $0x8,%ebx
f01055d8:	eb ce                	jmp    f01055a8 <strtol+0x44>
		s += 2, base = 16;
f01055da:	83 c1 02             	add    $0x2,%ecx
f01055dd:	bb 10 00 00 00       	mov    $0x10,%ebx
f01055e2:	eb c4                	jmp    f01055a8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01055e4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01055e7:	89 f3                	mov    %esi,%ebx
f01055e9:	80 fb 19             	cmp    $0x19,%bl
f01055ec:	77 29                	ja     f0105617 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01055ee:	0f be d2             	movsbl %dl,%edx
f01055f1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01055f4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01055f7:	7d 30                	jge    f0105629 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01055f9:	83 c1 01             	add    $0x1,%ecx
f01055fc:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105600:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105602:	0f b6 11             	movzbl (%ecx),%edx
f0105605:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105608:	89 f3                	mov    %esi,%ebx
f010560a:	80 fb 09             	cmp    $0x9,%bl
f010560d:	77 d5                	ja     f01055e4 <strtol+0x80>
			dig = *s - '0';
f010560f:	0f be d2             	movsbl %dl,%edx
f0105612:	83 ea 30             	sub    $0x30,%edx
f0105615:	eb dd                	jmp    f01055f4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105617:	8d 72 bf             	lea    -0x41(%edx),%esi
f010561a:	89 f3                	mov    %esi,%ebx
f010561c:	80 fb 19             	cmp    $0x19,%bl
f010561f:	77 08                	ja     f0105629 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105621:	0f be d2             	movsbl %dl,%edx
f0105624:	83 ea 37             	sub    $0x37,%edx
f0105627:	eb cb                	jmp    f01055f4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105629:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010562d:	74 05                	je     f0105634 <strtol+0xd0>
		*endptr = (char *) s;
f010562f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105632:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105634:	89 c2                	mov    %eax,%edx
f0105636:	f7 da                	neg    %edx
f0105638:	85 ff                	test   %edi,%edi
f010563a:	0f 45 c2             	cmovne %edx,%eax
}
f010563d:	5b                   	pop    %ebx
f010563e:	5e                   	pop    %esi
f010563f:	5f                   	pop    %edi
f0105640:	5d                   	pop    %ebp
f0105641:	c3                   	ret    
f0105642:	66 90                	xchg   %ax,%ax

f0105644 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105644:	fa                   	cli    

	xorw    %ax, %ax
f0105645:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105647:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105649:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010564b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010564d:	0f 01 16             	lgdtl  (%esi)
f0105650:	74 70                	je     f01056c2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105652:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105655:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105659:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010565c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105662:	08 00                	or     %al,(%eax)

f0105664 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105664:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105668:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010566a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010566c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010566e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105672:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105674:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105676:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010567b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010567e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105681:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105686:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105689:	8b 25 84 de 22 f0    	mov    0xf022de84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010568f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105694:	b8 b7 01 10 f0       	mov    $0xf01001b7,%eax
	call    *%eax
f0105699:	ff d0                	call   *%eax

f010569b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010569b:	eb fe                	jmp    f010569b <spin>
f010569d:	8d 76 00             	lea    0x0(%esi),%esi

f01056a0 <gdt>:
	...
f01056a8:	ff                   	(bad)  
f01056a9:	ff 00                	incl   (%eax)
f01056ab:	00 00                	add    %al,(%eax)
f01056ad:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01056b4:	00                   	.byte 0x0
f01056b5:	92                   	xchg   %eax,%edx
f01056b6:	cf                   	iret   
	...

f01056b8 <gdtdesc>:
f01056b8:	17                   	pop    %ss
f01056b9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01056be <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01056be:	90                   	nop

f01056bf <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01056bf:	55                   	push   %ebp
f01056c0:	89 e5                	mov    %esp,%ebp
f01056c2:	57                   	push   %edi
f01056c3:	56                   	push   %esi
f01056c4:	53                   	push   %ebx
f01056c5:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f01056c8:	8b 0d 88 de 22 f0    	mov    0xf022de88,%ecx
f01056ce:	89 c3                	mov    %eax,%ebx
f01056d0:	c1 eb 0c             	shr    $0xc,%ebx
f01056d3:	39 cb                	cmp    %ecx,%ebx
f01056d5:	73 1a                	jae    f01056f1 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01056d7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01056dd:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f01056e0:	89 f0                	mov    %esi,%eax
f01056e2:	c1 e8 0c             	shr    $0xc,%eax
f01056e5:	39 c8                	cmp    %ecx,%eax
f01056e7:	73 1a                	jae    f0105703 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01056e9:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01056ef:	eb 27                	jmp    f0105718 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01056f1:	50                   	push   %eax
f01056f2:	68 c4 60 10 f0       	push   $0xf01060c4
f01056f7:	6a 57                	push   $0x57
f01056f9:	68 21 7c 10 f0       	push   $0xf0107c21
f01056fe:	e8 3d a9 ff ff       	call   f0100040 <_panic>
f0105703:	56                   	push   %esi
f0105704:	68 c4 60 10 f0       	push   $0xf01060c4
f0105709:	6a 57                	push   $0x57
f010570b:	68 21 7c 10 f0       	push   $0xf0107c21
f0105710:	e8 2b a9 ff ff       	call   f0100040 <_panic>
f0105715:	83 c3 10             	add    $0x10,%ebx
f0105718:	39 f3                	cmp    %esi,%ebx
f010571a:	73 2e                	jae    f010574a <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010571c:	83 ec 04             	sub    $0x4,%esp
f010571f:	6a 04                	push   $0x4
f0105721:	68 31 7c 10 f0       	push   $0xf0107c31
f0105726:	53                   	push   %ebx
f0105727:	e8 e2 fd ff ff       	call   f010550e <memcmp>
f010572c:	83 c4 10             	add    $0x10,%esp
f010572f:	85 c0                	test   %eax,%eax
f0105731:	75 e2                	jne    f0105715 <mpsearch1+0x56>
f0105733:	89 da                	mov    %ebx,%edx
f0105735:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105738:	0f b6 0a             	movzbl (%edx),%ecx
f010573b:	01 c8                	add    %ecx,%eax
f010573d:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105740:	39 fa                	cmp    %edi,%edx
f0105742:	75 f4                	jne    f0105738 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105744:	84 c0                	test   %al,%al
f0105746:	75 cd                	jne    f0105715 <mpsearch1+0x56>
f0105748:	eb 05                	jmp    f010574f <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010574a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010574f:	89 d8                	mov    %ebx,%eax
f0105751:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105754:	5b                   	pop    %ebx
f0105755:	5e                   	pop    %esi
f0105756:	5f                   	pop    %edi
f0105757:	5d                   	pop    %ebp
f0105758:	c3                   	ret    

f0105759 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105759:	55                   	push   %ebp
f010575a:	89 e5                	mov    %esp,%ebp
f010575c:	57                   	push   %edi
f010575d:	56                   	push   %esi
f010575e:	53                   	push   %ebx
f010575f:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105762:	c7 05 c0 e3 22 f0 20 	movl   $0xf022e020,0xf022e3c0
f0105769:	e0 22 f0 
	if (PGNUM(pa) >= npages)
f010576c:	83 3d 88 de 22 f0 00 	cmpl   $0x0,0xf022de88
f0105773:	0f 84 87 00 00 00    	je     f0105800 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105779:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105780:	85 c0                	test   %eax,%eax
f0105782:	0f 84 8e 00 00 00    	je     f0105816 <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105788:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010578b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105790:	e8 2a ff ff ff       	call   f01056bf <mpsearch1>
f0105795:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105798:	85 c0                	test   %eax,%eax
f010579a:	0f 84 9a 00 00 00    	je     f010583a <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f01057a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057a3:	8b 41 04             	mov    0x4(%ecx),%eax
f01057a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057a9:	85 c0                	test   %eax,%eax
f01057ab:	0f 84 a8 00 00 00    	je     f0105859 <mp_init+0x100>
f01057b1:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f01057b5:	0f 85 9e 00 00 00    	jne    f0105859 <mp_init+0x100>
f01057bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057be:	c1 e8 0c             	shr    $0xc,%eax
f01057c1:	3b 05 88 de 22 f0    	cmp    0xf022de88,%eax
f01057c7:	0f 83 a1 00 00 00    	jae    f010586e <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f01057cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057d0:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01057d6:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01057d8:	83 ec 04             	sub    $0x4,%esp
f01057db:	6a 04                	push   $0x4
f01057dd:	68 36 7c 10 f0       	push   $0xf0107c36
f01057e2:	53                   	push   %ebx
f01057e3:	e8 26 fd ff ff       	call   f010550e <memcmp>
f01057e8:	83 c4 10             	add    $0x10,%esp
f01057eb:	85 c0                	test   %eax,%eax
f01057ed:	0f 85 92 00 00 00    	jne    f0105885 <mp_init+0x12c>
f01057f3:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01057f7:	01 df                	add    %ebx,%edi
	sum = 0;
f01057f9:	89 c2                	mov    %eax,%edx
f01057fb:	e9 a2 00 00 00       	jmp    f01058a2 <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105800:	68 00 04 00 00       	push   $0x400
f0105805:	68 c4 60 10 f0       	push   $0xf01060c4
f010580a:	6a 6f                	push   $0x6f
f010580c:	68 21 7c 10 f0       	push   $0xf0107c21
f0105811:	e8 2a a8 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105816:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010581d:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105820:	2d 00 04 00 00       	sub    $0x400,%eax
f0105825:	ba 00 04 00 00       	mov    $0x400,%edx
f010582a:	e8 90 fe ff ff       	call   f01056bf <mpsearch1>
f010582f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105832:	85 c0                	test   %eax,%eax
f0105834:	0f 85 66 ff ff ff    	jne    f01057a0 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f010583a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010583f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105844:	e8 76 fe ff ff       	call   f01056bf <mpsearch1>
f0105849:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f010584c:	85 c0                	test   %eax,%eax
f010584e:	0f 85 4c ff ff ff    	jne    f01057a0 <mp_init+0x47>
f0105854:	e9 a8 01 00 00       	jmp    f0105a01 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105859:	83 ec 0c             	sub    $0xc,%esp
f010585c:	68 94 7a 10 f0       	push   $0xf0107a94
f0105861:	e8 6b e1 ff ff       	call   f01039d1 <cprintf>
f0105866:	83 c4 10             	add    $0x10,%esp
f0105869:	e9 93 01 00 00       	jmp    f0105a01 <mp_init+0x2a8>
f010586e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105871:	68 c4 60 10 f0       	push   $0xf01060c4
f0105876:	68 90 00 00 00       	push   $0x90
f010587b:	68 21 7c 10 f0       	push   $0xf0107c21
f0105880:	e8 bb a7 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105885:	83 ec 0c             	sub    $0xc,%esp
f0105888:	68 c4 7a 10 f0       	push   $0xf0107ac4
f010588d:	e8 3f e1 ff ff       	call   f01039d1 <cprintf>
f0105892:	83 c4 10             	add    $0x10,%esp
f0105895:	e9 67 01 00 00       	jmp    f0105a01 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f010589a:	0f b6 0b             	movzbl (%ebx),%ecx
f010589d:	01 ca                	add    %ecx,%edx
f010589f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01058a2:	39 fb                	cmp    %edi,%ebx
f01058a4:	75 f4                	jne    f010589a <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f01058a6:	84 d2                	test   %dl,%dl
f01058a8:	75 16                	jne    f01058c0 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f01058aa:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f01058ae:	80 fa 01             	cmp    $0x1,%dl
f01058b1:	74 05                	je     f01058b8 <mp_init+0x15f>
f01058b3:	80 fa 04             	cmp    $0x4,%dl
f01058b6:	75 1d                	jne    f01058d5 <mp_init+0x17c>
f01058b8:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01058bc:	01 d9                	add    %ebx,%ecx
f01058be:	eb 36                	jmp    f01058f6 <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01058c0:	83 ec 0c             	sub    $0xc,%esp
f01058c3:	68 f8 7a 10 f0       	push   $0xf0107af8
f01058c8:	e8 04 e1 ff ff       	call   f01039d1 <cprintf>
f01058cd:	83 c4 10             	add    $0x10,%esp
f01058d0:	e9 2c 01 00 00       	jmp    f0105a01 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01058d5:	83 ec 08             	sub    $0x8,%esp
f01058d8:	0f b6 d2             	movzbl %dl,%edx
f01058db:	52                   	push   %edx
f01058dc:	68 1c 7b 10 f0       	push   $0xf0107b1c
f01058e1:	e8 eb e0 ff ff       	call   f01039d1 <cprintf>
f01058e6:	83 c4 10             	add    $0x10,%esp
f01058e9:	e9 13 01 00 00       	jmp    f0105a01 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f01058ee:	0f b6 13             	movzbl (%ebx),%edx
f01058f1:	01 d0                	add    %edx,%eax
f01058f3:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01058f6:	39 d9                	cmp    %ebx,%ecx
f01058f8:	75 f4                	jne    f01058ee <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01058fa:	02 46 2a             	add    0x2a(%esi),%al
f01058fd:	75 29                	jne    f0105928 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f01058ff:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105906:	0f 84 f5 00 00 00    	je     f0105a01 <mp_init+0x2a8>
		return;
	ismp = 1;
f010590c:	c7 05 00 e0 22 f0 01 	movl   $0x1,0xf022e000
f0105913:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105916:	8b 46 24             	mov    0x24(%esi),%eax
f0105919:	a3 00 f0 26 f0       	mov    %eax,0xf026f000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010591e:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105921:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105926:	eb 4d                	jmp    f0105975 <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105928:	83 ec 0c             	sub    $0xc,%esp
f010592b:	68 3c 7b 10 f0       	push   $0xf0107b3c
f0105930:	e8 9c e0 ff ff       	call   f01039d1 <cprintf>
f0105935:	83 c4 10             	add    $0x10,%esp
f0105938:	e9 c4 00 00 00       	jmp    f0105a01 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010593d:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105941:	74 11                	je     f0105954 <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105943:	6b 05 c4 e3 22 f0 74 	imul   $0x74,0xf022e3c4,%eax
f010594a:	05 20 e0 22 f0       	add    $0xf022e020,%eax
f010594f:	a3 c0 e3 22 f0       	mov    %eax,0xf022e3c0
			if (ncpu < NCPU) {
f0105954:	a1 c4 e3 22 f0       	mov    0xf022e3c4,%eax
f0105959:	83 f8 07             	cmp    $0x7,%eax
f010595c:	7f 2f                	jg     f010598d <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f010595e:	6b d0 74             	imul   $0x74,%eax,%edx
f0105961:	88 82 20 e0 22 f0    	mov    %al,-0xfdd1fe0(%edx)
				ncpu++;
f0105967:	83 c0 01             	add    $0x1,%eax
f010596a:	a3 c4 e3 22 f0       	mov    %eax,0xf022e3c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010596f:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105972:	83 c3 01             	add    $0x1,%ebx
f0105975:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105979:	39 d8                	cmp    %ebx,%eax
f010597b:	76 4b                	jbe    f01059c8 <mp_init+0x26f>
		switch (*p) {
f010597d:	0f b6 07             	movzbl (%edi),%eax
f0105980:	84 c0                	test   %al,%al
f0105982:	74 b9                	je     f010593d <mp_init+0x1e4>
f0105984:	3c 04                	cmp    $0x4,%al
f0105986:	77 1c                	ja     f01059a4 <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105988:	83 c7 08             	add    $0x8,%edi
			continue;
f010598b:	eb e5                	jmp    f0105972 <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010598d:	83 ec 08             	sub    $0x8,%esp
f0105990:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105994:	50                   	push   %eax
f0105995:	68 6c 7b 10 f0       	push   $0xf0107b6c
f010599a:	e8 32 e0 ff ff       	call   f01039d1 <cprintf>
f010599f:	83 c4 10             	add    $0x10,%esp
f01059a2:	eb cb                	jmp    f010596f <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01059a4:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01059a7:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01059aa:	50                   	push   %eax
f01059ab:	68 94 7b 10 f0       	push   $0xf0107b94
f01059b0:	e8 1c e0 ff ff       	call   f01039d1 <cprintf>
			ismp = 0;
f01059b5:	c7 05 00 e0 22 f0 00 	movl   $0x0,0xf022e000
f01059bc:	00 00 00 
			i = conf->entry;
f01059bf:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01059c3:	83 c4 10             	add    $0x10,%esp
f01059c6:	eb aa                	jmp    f0105972 <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01059c8:	a1 c0 e3 22 f0       	mov    0xf022e3c0,%eax
f01059cd:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01059d4:	83 3d 00 e0 22 f0 00 	cmpl   $0x0,0xf022e000
f01059db:	75 2c                	jne    f0105a09 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01059dd:	c7 05 c4 e3 22 f0 01 	movl   $0x1,0xf022e3c4
f01059e4:	00 00 00 
		lapicaddr = 0;
f01059e7:	c7 05 00 f0 26 f0 00 	movl   $0x0,0xf026f000
f01059ee:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01059f1:	83 ec 0c             	sub    $0xc,%esp
f01059f4:	68 b4 7b 10 f0       	push   $0xf0107bb4
f01059f9:	e8 d3 df ff ff       	call   f01039d1 <cprintf>
		return;
f01059fe:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a04:	5b                   	pop    %ebx
f0105a05:	5e                   	pop    %esi
f0105a06:	5f                   	pop    %edi
f0105a07:	5d                   	pop    %ebp
f0105a08:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105a09:	83 ec 04             	sub    $0x4,%esp
f0105a0c:	ff 35 c4 e3 22 f0    	pushl  0xf022e3c4
f0105a12:	0f b6 00             	movzbl (%eax),%eax
f0105a15:	50                   	push   %eax
f0105a16:	68 3b 7c 10 f0       	push   $0xf0107c3b
f0105a1b:	e8 b1 df ff ff       	call   f01039d1 <cprintf>
	if (mp->imcrp) {
f0105a20:	83 c4 10             	add    $0x10,%esp
f0105a23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a26:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105a2a:	74 d5                	je     f0105a01 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105a2c:	83 ec 0c             	sub    $0xc,%esp
f0105a2f:	68 e0 7b 10 f0       	push   $0xf0107be0
f0105a34:	e8 98 df ff ff       	call   f01039d1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a39:	b8 70 00 00 00       	mov    $0x70,%eax
f0105a3e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105a43:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105a44:	ba 23 00 00 00       	mov    $0x23,%edx
f0105a49:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105a4a:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a4d:	ee                   	out    %al,(%dx)
f0105a4e:	83 c4 10             	add    $0x10,%esp
f0105a51:	eb ae                	jmp    f0105a01 <mp_init+0x2a8>

f0105a53 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105a53:	55                   	push   %ebp
f0105a54:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105a56:	8b 0d 04 f0 26 f0    	mov    0xf026f004,%ecx
f0105a5c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105a5f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105a61:	a1 04 f0 26 f0       	mov    0xf026f004,%eax
f0105a66:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105a69:	5d                   	pop    %ebp
f0105a6a:	c3                   	ret    

f0105a6b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105a6b:	55                   	push   %ebp
f0105a6c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105a6e:	8b 15 04 f0 26 f0    	mov    0xf026f004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105a74:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105a79:	85 d2                	test   %edx,%edx
f0105a7b:	74 06                	je     f0105a83 <cpunum+0x18>
		return lapic[ID] >> 24;
f0105a7d:	8b 42 20             	mov    0x20(%edx),%eax
f0105a80:	c1 e8 18             	shr    $0x18,%eax
}
f0105a83:	5d                   	pop    %ebp
f0105a84:	c3                   	ret    

f0105a85 <lapic_init>:
	if (!lapicaddr)
f0105a85:	a1 00 f0 26 f0       	mov    0xf026f000,%eax
f0105a8a:	85 c0                	test   %eax,%eax
f0105a8c:	75 02                	jne    f0105a90 <lapic_init+0xb>
f0105a8e:	f3 c3                	repz ret 
{
f0105a90:	55                   	push   %ebp
f0105a91:	89 e5                	mov    %esp,%ebp
f0105a93:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105a96:	68 00 10 00 00       	push   $0x1000
f0105a9b:	50                   	push   %eax
f0105a9c:	e8 80 b8 ff ff       	call   f0101321 <mmio_map_region>
f0105aa1:	a3 04 f0 26 f0       	mov    %eax,0xf026f004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105aa6:	ba 27 01 00 00       	mov    $0x127,%edx
f0105aab:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105ab0:	e8 9e ff ff ff       	call   f0105a53 <lapicw>
	lapicw(TDCR, X1);
f0105ab5:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105aba:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105abf:	e8 8f ff ff ff       	call   f0105a53 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105ac4:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105ac9:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105ace:	e8 80 ff ff ff       	call   f0105a53 <lapicw>
	lapicw(TICR, 10000000); 
f0105ad3:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ad8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105add:	e8 71 ff ff ff       	call   f0105a53 <lapicw>
	if (thiscpu != bootcpu)
f0105ae2:	e8 84 ff ff ff       	call   f0105a6b <cpunum>
f0105ae7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105aea:	05 20 e0 22 f0       	add    $0xf022e020,%eax
f0105aef:	83 c4 10             	add    $0x10,%esp
f0105af2:	39 05 c0 e3 22 f0    	cmp    %eax,0xf022e3c0
f0105af8:	74 0f                	je     f0105b09 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f0105afa:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105aff:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105b04:	e8 4a ff ff ff       	call   f0105a53 <lapicw>
	lapicw(LINT1, MASKED);
f0105b09:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b0e:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105b13:	e8 3b ff ff ff       	call   f0105a53 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105b18:	a1 04 f0 26 f0       	mov    0xf026f004,%eax
f0105b1d:	8b 40 30             	mov    0x30(%eax),%eax
f0105b20:	c1 e8 10             	shr    $0x10,%eax
f0105b23:	3c 03                	cmp    $0x3,%al
f0105b25:	77 7c                	ja     f0105ba3 <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105b27:	ba 33 00 00 00       	mov    $0x33,%edx
f0105b2c:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105b31:	e8 1d ff ff ff       	call   f0105a53 <lapicw>
	lapicw(ESR, 0);
f0105b36:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b3b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105b40:	e8 0e ff ff ff       	call   f0105a53 <lapicw>
	lapicw(ESR, 0);
f0105b45:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b4a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105b4f:	e8 ff fe ff ff       	call   f0105a53 <lapicw>
	lapicw(EOI, 0);
f0105b54:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b59:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105b5e:	e8 f0 fe ff ff       	call   f0105a53 <lapicw>
	lapicw(ICRHI, 0);
f0105b63:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b68:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b6d:	e8 e1 fe ff ff       	call   f0105a53 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105b72:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105b77:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b7c:	e8 d2 fe ff ff       	call   f0105a53 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105b81:	8b 15 04 f0 26 f0    	mov    0xf026f004,%edx
f0105b87:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b8d:	f6 c4 10             	test   $0x10,%ah
f0105b90:	75 f5                	jne    f0105b87 <lapic_init+0x102>
	lapicw(TPR, 0);
f0105b92:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b97:	b8 20 00 00 00       	mov    $0x20,%eax
f0105b9c:	e8 b2 fe ff ff       	call   f0105a53 <lapicw>
}
f0105ba1:	c9                   	leave  
f0105ba2:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105ba3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ba8:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105bad:	e8 a1 fe ff ff       	call   f0105a53 <lapicw>
f0105bb2:	e9 70 ff ff ff       	jmp    f0105b27 <lapic_init+0xa2>

f0105bb7 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105bb7:	83 3d 04 f0 26 f0 00 	cmpl   $0x0,0xf026f004
f0105bbe:	74 14                	je     f0105bd4 <lapic_eoi+0x1d>
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0105bc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bc8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105bcd:	e8 81 fe ff ff       	call   f0105a53 <lapicw>
}
f0105bd2:	5d                   	pop    %ebp
f0105bd3:	c3                   	ret    
f0105bd4:	f3 c3                	repz ret 

f0105bd6 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105bd6:	55                   	push   %ebp
f0105bd7:	89 e5                	mov    %esp,%ebp
f0105bd9:	56                   	push   %esi
f0105bda:	53                   	push   %ebx
f0105bdb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105be1:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105be6:	ba 70 00 00 00       	mov    $0x70,%edx
f0105beb:	ee                   	out    %al,(%dx)
f0105bec:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bf1:	ba 71 00 00 00       	mov    $0x71,%edx
f0105bf6:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105bf7:	83 3d 88 de 22 f0 00 	cmpl   $0x0,0xf022de88
f0105bfe:	74 7e                	je     f0105c7e <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105c00:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105c07:	00 00 
	wrv[1] = addr >> 4;
f0105c09:	89 d8                	mov    %ebx,%eax
f0105c0b:	c1 e8 04             	shr    $0x4,%eax
f0105c0e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105c14:	c1 e6 18             	shl    $0x18,%esi
f0105c17:	89 f2                	mov    %esi,%edx
f0105c19:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c1e:	e8 30 fe ff ff       	call   f0105a53 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105c23:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105c28:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c2d:	e8 21 fe ff ff       	call   f0105a53 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105c32:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105c37:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c3c:	e8 12 fe ff ff       	call   f0105a53 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c41:	c1 eb 0c             	shr    $0xc,%ebx
f0105c44:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105c47:	89 f2                	mov    %esi,%edx
f0105c49:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c4e:	e8 00 fe ff ff       	call   f0105a53 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c53:	89 da                	mov    %ebx,%edx
f0105c55:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c5a:	e8 f4 fd ff ff       	call   f0105a53 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105c5f:	89 f2                	mov    %esi,%edx
f0105c61:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c66:	e8 e8 fd ff ff       	call   f0105a53 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c6b:	89 da                	mov    %ebx,%edx
f0105c6d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c72:	e8 dc fd ff ff       	call   f0105a53 <lapicw>
		microdelay(200);
	}
}
f0105c77:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c7a:	5b                   	pop    %ebx
f0105c7b:	5e                   	pop    %esi
f0105c7c:	5d                   	pop    %ebp
f0105c7d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c7e:	68 67 04 00 00       	push   $0x467
f0105c83:	68 c4 60 10 f0       	push   $0xf01060c4
f0105c88:	68 9b 00 00 00       	push   $0x9b
f0105c8d:	68 58 7c 10 f0       	push   $0xf0107c58
f0105c92:	e8 a9 a3 ff ff       	call   f0100040 <_panic>

f0105c97 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105c97:	55                   	push   %ebp
f0105c98:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105c9a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c9d:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105ca3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ca8:	e8 a6 fd ff ff       	call   f0105a53 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105cad:	8b 15 04 f0 26 f0    	mov    0xf026f004,%edx
f0105cb3:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105cb9:	f6 c4 10             	test   $0x10,%ah
f0105cbc:	75 f5                	jne    f0105cb3 <lapic_ipi+0x1c>
		;
}
f0105cbe:	5d                   	pop    %ebp
f0105cbf:	c3                   	ret    

f0105cc0 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105cc0:	55                   	push   %ebp
f0105cc1:	89 e5                	mov    %esp,%ebp
f0105cc3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105cc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ccf:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105cd2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105cd9:	5d                   	pop    %ebp
f0105cda:	c3                   	ret    

f0105cdb <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105cdb:	55                   	push   %ebp
f0105cdc:	89 e5                	mov    %esp,%ebp
f0105cde:	56                   	push   %esi
f0105cdf:	53                   	push   %ebx
f0105ce0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105ce3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ce6:	75 07                	jne    f0105cef <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0105ce8:	ba 01 00 00 00       	mov    $0x1,%edx
f0105ced:	eb 34                	jmp    f0105d23 <spin_lock+0x48>
f0105cef:	8b 73 08             	mov    0x8(%ebx),%esi
f0105cf2:	e8 74 fd ff ff       	call   f0105a6b <cpunum>
f0105cf7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cfa:	05 20 e0 22 f0       	add    $0xf022e020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105cff:	39 c6                	cmp    %eax,%esi
f0105d01:	75 e5                	jne    f0105ce8 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105d03:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105d06:	e8 60 fd ff ff       	call   f0105a6b <cpunum>
f0105d0b:	83 ec 0c             	sub    $0xc,%esp
f0105d0e:	53                   	push   %ebx
f0105d0f:	50                   	push   %eax
f0105d10:	68 68 7c 10 f0       	push   $0xf0107c68
f0105d15:	6a 41                	push   $0x41
f0105d17:	68 cc 7c 10 f0       	push   $0xf0107ccc
f0105d1c:	e8 1f a3 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105d21:	f3 90                	pause  
f0105d23:	89 d0                	mov    %edx,%eax
f0105d25:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105d28:	85 c0                	test   %eax,%eax
f0105d2a:	75 f5                	jne    f0105d21 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105d2c:	e8 3a fd ff ff       	call   f0105a6b <cpunum>
f0105d31:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d34:	05 20 e0 22 f0       	add    $0xf022e020,%eax
f0105d39:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105d3c:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105d3f:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105d41:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d46:	eb 0b                	jmp    f0105d53 <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0105d48:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105d4b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105d4e:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105d50:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105d53:	83 f8 09             	cmp    $0x9,%eax
f0105d56:	7f 14                	jg     f0105d6c <spin_lock+0x91>
f0105d58:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105d5e:	77 e8                	ja     f0105d48 <spin_lock+0x6d>
f0105d60:	eb 0a                	jmp    f0105d6c <spin_lock+0x91>
		pcs[i] = 0;
f0105d62:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0105d69:	83 c0 01             	add    $0x1,%eax
f0105d6c:	83 f8 09             	cmp    $0x9,%eax
f0105d6f:	7e f1                	jle    f0105d62 <spin_lock+0x87>
#endif
}
f0105d71:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d74:	5b                   	pop    %ebx
f0105d75:	5e                   	pop    %esi
f0105d76:	5d                   	pop    %ebp
f0105d77:	c3                   	ret    

f0105d78 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105d78:	55                   	push   %ebp
f0105d79:	89 e5                	mov    %esp,%ebp
f0105d7b:	57                   	push   %edi
f0105d7c:	56                   	push   %esi
f0105d7d:	53                   	push   %ebx
f0105d7e:	83 ec 4c             	sub    $0x4c,%esp
f0105d81:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105d84:	83 3e 00             	cmpl   $0x0,(%esi)
f0105d87:	75 35                	jne    f0105dbe <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105d89:	83 ec 04             	sub    $0x4,%esp
f0105d8c:	6a 28                	push   $0x28
f0105d8e:	8d 46 0c             	lea    0xc(%esi),%eax
f0105d91:	50                   	push   %eax
f0105d92:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105d95:	53                   	push   %ebx
f0105d96:	e8 f8 f6 ff ff       	call   f0105493 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105d9b:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105d9e:	0f b6 38             	movzbl (%eax),%edi
f0105da1:	8b 76 04             	mov    0x4(%esi),%esi
f0105da4:	e8 c2 fc ff ff       	call   f0105a6b <cpunum>
f0105da9:	57                   	push   %edi
f0105daa:	56                   	push   %esi
f0105dab:	50                   	push   %eax
f0105dac:	68 94 7c 10 f0       	push   $0xf0107c94
f0105db1:	e8 1b dc ff ff       	call   f01039d1 <cprintf>
f0105db6:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105db9:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105dbc:	eb 61                	jmp    f0105e1f <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f0105dbe:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105dc1:	e8 a5 fc ff ff       	call   f0105a6b <cpunum>
f0105dc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dc9:	05 20 e0 22 f0       	add    $0xf022e020,%eax
	if (!holding(lk)) {
f0105dce:	39 c3                	cmp    %eax,%ebx
f0105dd0:	75 b7                	jne    f0105d89 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105dd2:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105dd9:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105de0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105de5:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105deb:	5b                   	pop    %ebx
f0105dec:	5e                   	pop    %esi
f0105ded:	5f                   	pop    %edi
f0105dee:	5d                   	pop    %ebp
f0105def:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0105df0:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105df2:	83 ec 04             	sub    $0x4,%esp
f0105df5:	89 c2                	mov    %eax,%edx
f0105df7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105dfa:	52                   	push   %edx
f0105dfb:	ff 75 b0             	pushl  -0x50(%ebp)
f0105dfe:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105e01:	ff 75 ac             	pushl  -0x54(%ebp)
f0105e04:	ff 75 a8             	pushl  -0x58(%ebp)
f0105e07:	50                   	push   %eax
f0105e08:	68 dc 7c 10 f0       	push   $0xf0107cdc
f0105e0d:	e8 bf db ff ff       	call   f01039d1 <cprintf>
f0105e12:	83 c4 20             	add    $0x20,%esp
f0105e15:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105e18:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105e1b:	39 c3                	cmp    %eax,%ebx
f0105e1d:	74 2d                	je     f0105e4c <spin_unlock+0xd4>
f0105e1f:	89 de                	mov    %ebx,%esi
f0105e21:	8b 03                	mov    (%ebx),%eax
f0105e23:	85 c0                	test   %eax,%eax
f0105e25:	74 25                	je     f0105e4c <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105e27:	83 ec 08             	sub    $0x8,%esp
f0105e2a:	57                   	push   %edi
f0105e2b:	50                   	push   %eax
f0105e2c:	e8 15 ec ff ff       	call   f0104a46 <debuginfo_eip>
f0105e31:	83 c4 10             	add    $0x10,%esp
f0105e34:	85 c0                	test   %eax,%eax
f0105e36:	79 b8                	jns    f0105df0 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f0105e38:	83 ec 08             	sub    $0x8,%esp
f0105e3b:	ff 36                	pushl  (%esi)
f0105e3d:	68 f3 7c 10 f0       	push   $0xf0107cf3
f0105e42:	e8 8a db ff ff       	call   f01039d1 <cprintf>
f0105e47:	83 c4 10             	add    $0x10,%esp
f0105e4a:	eb c9                	jmp    f0105e15 <spin_unlock+0x9d>
		panic("spin_unlock");
f0105e4c:	83 ec 04             	sub    $0x4,%esp
f0105e4f:	68 fb 7c 10 f0       	push   $0xf0107cfb
f0105e54:	6a 67                	push   $0x67
f0105e56:	68 cc 7c 10 f0       	push   $0xf0107ccc
f0105e5b:	e8 e0 a1 ff ff       	call   f0100040 <_panic>

f0105e60 <__udivdi3>:
f0105e60:	55                   	push   %ebp
f0105e61:	57                   	push   %edi
f0105e62:	56                   	push   %esi
f0105e63:	53                   	push   %ebx
f0105e64:	83 ec 1c             	sub    $0x1c,%esp
f0105e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105e77:	85 d2                	test   %edx,%edx
f0105e79:	75 35                	jne    f0105eb0 <__udivdi3+0x50>
f0105e7b:	39 f3                	cmp    %esi,%ebx
f0105e7d:	0f 87 bd 00 00 00    	ja     f0105f40 <__udivdi3+0xe0>
f0105e83:	85 db                	test   %ebx,%ebx
f0105e85:	89 d9                	mov    %ebx,%ecx
f0105e87:	75 0b                	jne    f0105e94 <__udivdi3+0x34>
f0105e89:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e8e:	31 d2                	xor    %edx,%edx
f0105e90:	f7 f3                	div    %ebx
f0105e92:	89 c1                	mov    %eax,%ecx
f0105e94:	31 d2                	xor    %edx,%edx
f0105e96:	89 f0                	mov    %esi,%eax
f0105e98:	f7 f1                	div    %ecx
f0105e9a:	89 c6                	mov    %eax,%esi
f0105e9c:	89 e8                	mov    %ebp,%eax
f0105e9e:	89 f7                	mov    %esi,%edi
f0105ea0:	f7 f1                	div    %ecx
f0105ea2:	89 fa                	mov    %edi,%edx
f0105ea4:	83 c4 1c             	add    $0x1c,%esp
f0105ea7:	5b                   	pop    %ebx
f0105ea8:	5e                   	pop    %esi
f0105ea9:	5f                   	pop    %edi
f0105eaa:	5d                   	pop    %ebp
f0105eab:	c3                   	ret    
f0105eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105eb0:	39 f2                	cmp    %esi,%edx
f0105eb2:	77 7c                	ja     f0105f30 <__udivdi3+0xd0>
f0105eb4:	0f bd fa             	bsr    %edx,%edi
f0105eb7:	83 f7 1f             	xor    $0x1f,%edi
f0105eba:	0f 84 98 00 00 00    	je     f0105f58 <__udivdi3+0xf8>
f0105ec0:	89 f9                	mov    %edi,%ecx
f0105ec2:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ec7:	29 f8                	sub    %edi,%eax
f0105ec9:	d3 e2                	shl    %cl,%edx
f0105ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ecf:	89 c1                	mov    %eax,%ecx
f0105ed1:	89 da                	mov    %ebx,%edx
f0105ed3:	d3 ea                	shr    %cl,%edx
f0105ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105ed9:	09 d1                	or     %edx,%ecx
f0105edb:	89 f2                	mov    %esi,%edx
f0105edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ee1:	89 f9                	mov    %edi,%ecx
f0105ee3:	d3 e3                	shl    %cl,%ebx
f0105ee5:	89 c1                	mov    %eax,%ecx
f0105ee7:	d3 ea                	shr    %cl,%edx
f0105ee9:	89 f9                	mov    %edi,%ecx
f0105eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105eef:	d3 e6                	shl    %cl,%esi
f0105ef1:	89 eb                	mov    %ebp,%ebx
f0105ef3:	89 c1                	mov    %eax,%ecx
f0105ef5:	d3 eb                	shr    %cl,%ebx
f0105ef7:	09 de                	or     %ebx,%esi
f0105ef9:	89 f0                	mov    %esi,%eax
f0105efb:	f7 74 24 08          	divl   0x8(%esp)
f0105eff:	89 d6                	mov    %edx,%esi
f0105f01:	89 c3                	mov    %eax,%ebx
f0105f03:	f7 64 24 0c          	mull   0xc(%esp)
f0105f07:	39 d6                	cmp    %edx,%esi
f0105f09:	72 0c                	jb     f0105f17 <__udivdi3+0xb7>
f0105f0b:	89 f9                	mov    %edi,%ecx
f0105f0d:	d3 e5                	shl    %cl,%ebp
f0105f0f:	39 c5                	cmp    %eax,%ebp
f0105f11:	73 5d                	jae    f0105f70 <__udivdi3+0x110>
f0105f13:	39 d6                	cmp    %edx,%esi
f0105f15:	75 59                	jne    f0105f70 <__udivdi3+0x110>
f0105f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105f1a:	31 ff                	xor    %edi,%edi
f0105f1c:	89 fa                	mov    %edi,%edx
f0105f1e:	83 c4 1c             	add    $0x1c,%esp
f0105f21:	5b                   	pop    %ebx
f0105f22:	5e                   	pop    %esi
f0105f23:	5f                   	pop    %edi
f0105f24:	5d                   	pop    %ebp
f0105f25:	c3                   	ret    
f0105f26:	8d 76 00             	lea    0x0(%esi),%esi
f0105f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105f30:	31 ff                	xor    %edi,%edi
f0105f32:	31 c0                	xor    %eax,%eax
f0105f34:	89 fa                	mov    %edi,%edx
f0105f36:	83 c4 1c             	add    $0x1c,%esp
f0105f39:	5b                   	pop    %ebx
f0105f3a:	5e                   	pop    %esi
f0105f3b:	5f                   	pop    %edi
f0105f3c:	5d                   	pop    %ebp
f0105f3d:	c3                   	ret    
f0105f3e:	66 90                	xchg   %ax,%ax
f0105f40:	31 ff                	xor    %edi,%edi
f0105f42:	89 e8                	mov    %ebp,%eax
f0105f44:	89 f2                	mov    %esi,%edx
f0105f46:	f7 f3                	div    %ebx
f0105f48:	89 fa                	mov    %edi,%edx
f0105f4a:	83 c4 1c             	add    $0x1c,%esp
f0105f4d:	5b                   	pop    %ebx
f0105f4e:	5e                   	pop    %esi
f0105f4f:	5f                   	pop    %edi
f0105f50:	5d                   	pop    %ebp
f0105f51:	c3                   	ret    
f0105f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105f58:	39 f2                	cmp    %esi,%edx
f0105f5a:	72 06                	jb     f0105f62 <__udivdi3+0x102>
f0105f5c:	31 c0                	xor    %eax,%eax
f0105f5e:	39 eb                	cmp    %ebp,%ebx
f0105f60:	77 d2                	ja     f0105f34 <__udivdi3+0xd4>
f0105f62:	b8 01 00 00 00       	mov    $0x1,%eax
f0105f67:	eb cb                	jmp    f0105f34 <__udivdi3+0xd4>
f0105f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105f70:	89 d8                	mov    %ebx,%eax
f0105f72:	31 ff                	xor    %edi,%edi
f0105f74:	eb be                	jmp    f0105f34 <__udivdi3+0xd4>
f0105f76:	66 90                	xchg   %ax,%ax
f0105f78:	66 90                	xchg   %ax,%ax
f0105f7a:	66 90                	xchg   %ax,%ax
f0105f7c:	66 90                	xchg   %ax,%ax
f0105f7e:	66 90                	xchg   %ax,%ax

f0105f80 <__umoddi3>:
f0105f80:	55                   	push   %ebp
f0105f81:	57                   	push   %edi
f0105f82:	56                   	push   %esi
f0105f83:	53                   	push   %ebx
f0105f84:	83 ec 1c             	sub    $0x1c,%esp
f0105f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0105f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f97:	85 ed                	test   %ebp,%ebp
f0105f99:	89 f0                	mov    %esi,%eax
f0105f9b:	89 da                	mov    %ebx,%edx
f0105f9d:	75 19                	jne    f0105fb8 <__umoddi3+0x38>
f0105f9f:	39 df                	cmp    %ebx,%edi
f0105fa1:	0f 86 b1 00 00 00    	jbe    f0106058 <__umoddi3+0xd8>
f0105fa7:	f7 f7                	div    %edi
f0105fa9:	89 d0                	mov    %edx,%eax
f0105fab:	31 d2                	xor    %edx,%edx
f0105fad:	83 c4 1c             	add    $0x1c,%esp
f0105fb0:	5b                   	pop    %ebx
f0105fb1:	5e                   	pop    %esi
f0105fb2:	5f                   	pop    %edi
f0105fb3:	5d                   	pop    %ebp
f0105fb4:	c3                   	ret    
f0105fb5:	8d 76 00             	lea    0x0(%esi),%esi
f0105fb8:	39 dd                	cmp    %ebx,%ebp
f0105fba:	77 f1                	ja     f0105fad <__umoddi3+0x2d>
f0105fbc:	0f bd cd             	bsr    %ebp,%ecx
f0105fbf:	83 f1 1f             	xor    $0x1f,%ecx
f0105fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105fc6:	0f 84 b4 00 00 00    	je     f0106080 <__umoddi3+0x100>
f0105fcc:	b8 20 00 00 00       	mov    $0x20,%eax
f0105fd1:	89 c2                	mov    %eax,%edx
f0105fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105fd7:	29 c2                	sub    %eax,%edx
f0105fd9:	89 c1                	mov    %eax,%ecx
f0105fdb:	89 f8                	mov    %edi,%eax
f0105fdd:	d3 e5                	shl    %cl,%ebp
f0105fdf:	89 d1                	mov    %edx,%ecx
f0105fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105fe5:	d3 e8                	shr    %cl,%eax
f0105fe7:	09 c5                	or     %eax,%ebp
f0105fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105fed:	89 c1                	mov    %eax,%ecx
f0105fef:	d3 e7                	shl    %cl,%edi
f0105ff1:	89 d1                	mov    %edx,%ecx
f0105ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105ff7:	89 df                	mov    %ebx,%edi
f0105ff9:	d3 ef                	shr    %cl,%edi
f0105ffb:	89 c1                	mov    %eax,%ecx
f0105ffd:	89 f0                	mov    %esi,%eax
f0105fff:	d3 e3                	shl    %cl,%ebx
f0106001:	89 d1                	mov    %edx,%ecx
f0106003:	89 fa                	mov    %edi,%edx
f0106005:	d3 e8                	shr    %cl,%eax
f0106007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010600c:	09 d8                	or     %ebx,%eax
f010600e:	f7 f5                	div    %ebp
f0106010:	d3 e6                	shl    %cl,%esi
f0106012:	89 d1                	mov    %edx,%ecx
f0106014:	f7 64 24 08          	mull   0x8(%esp)
f0106018:	39 d1                	cmp    %edx,%ecx
f010601a:	89 c3                	mov    %eax,%ebx
f010601c:	89 d7                	mov    %edx,%edi
f010601e:	72 06                	jb     f0106026 <__umoddi3+0xa6>
f0106020:	75 0e                	jne    f0106030 <__umoddi3+0xb0>
f0106022:	39 c6                	cmp    %eax,%esi
f0106024:	73 0a                	jae    f0106030 <__umoddi3+0xb0>
f0106026:	2b 44 24 08          	sub    0x8(%esp),%eax
f010602a:	19 ea                	sbb    %ebp,%edx
f010602c:	89 d7                	mov    %edx,%edi
f010602e:	89 c3                	mov    %eax,%ebx
f0106030:	89 ca                	mov    %ecx,%edx
f0106032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0106037:	29 de                	sub    %ebx,%esi
f0106039:	19 fa                	sbb    %edi,%edx
f010603b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010603f:	89 d0                	mov    %edx,%eax
f0106041:	d3 e0                	shl    %cl,%eax
f0106043:	89 d9                	mov    %ebx,%ecx
f0106045:	d3 ee                	shr    %cl,%esi
f0106047:	d3 ea                	shr    %cl,%edx
f0106049:	09 f0                	or     %esi,%eax
f010604b:	83 c4 1c             	add    $0x1c,%esp
f010604e:	5b                   	pop    %ebx
f010604f:	5e                   	pop    %esi
f0106050:	5f                   	pop    %edi
f0106051:	5d                   	pop    %ebp
f0106052:	c3                   	ret    
f0106053:	90                   	nop
f0106054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106058:	85 ff                	test   %edi,%edi
f010605a:	89 f9                	mov    %edi,%ecx
f010605c:	75 0b                	jne    f0106069 <__umoddi3+0xe9>
f010605e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106063:	31 d2                	xor    %edx,%edx
f0106065:	f7 f7                	div    %edi
f0106067:	89 c1                	mov    %eax,%ecx
f0106069:	89 d8                	mov    %ebx,%eax
f010606b:	31 d2                	xor    %edx,%edx
f010606d:	f7 f1                	div    %ecx
f010606f:	89 f0                	mov    %esi,%eax
f0106071:	f7 f1                	div    %ecx
f0106073:	e9 31 ff ff ff       	jmp    f0105fa9 <__umoddi3+0x29>
f0106078:	90                   	nop
f0106079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106080:	39 dd                	cmp    %ebx,%ebp
f0106082:	72 08                	jb     f010608c <__umoddi3+0x10c>
f0106084:	39 f7                	cmp    %esi,%edi
f0106086:	0f 87 21 ff ff ff    	ja     f0105fad <__umoddi3+0x2d>
f010608c:	89 da                	mov    %ebx,%edx
f010608e:	89 f0                	mov    %esi,%eax
f0106090:	29 f8                	sub    %edi,%eax
f0106092:	19 ea                	sbb    %ebp,%edx
f0106094:	e9 14 ff ff ff       	jmp    f0105fad <__umoddi3+0x2d>
