
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 ae 05 00 00       	call   8005df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 15 80 00       	push   $0x8015f1
  800049:	68 c0 15 80 00       	push   $0x8015c0
  80004e:	e8 c9 06 00 00       	call   80071c <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 15 80 00       	push   $0x8015d0
  80005c:	68 d4 15 80 00       	push   $0x8015d4
  800061:	e8 b6 06 00 00       	call   80071c <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 31 02 00 00    	je     8002a4 <check_regs+0x271>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 e8 15 80 00       	push   $0x8015e8
  80007b:	e8 9c 06 00 00       	call   80071c <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 f2 15 80 00       	push   $0x8015f2
  800093:	68 d4 15 80 00       	push   $0x8015d4
  800098:	e8 7f 06 00 00       	call   80071c <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 12 02 00 00    	je     8002be <check_regs+0x28b>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 e8 15 80 00       	push   $0x8015e8
  8000b4:	e8 63 06 00 00       	call   80071c <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 f6 15 80 00       	push   $0x8015f6
  8000cc:	68 d4 15 80 00       	push   $0x8015d4
  8000d1:	e8 46 06 00 00       	call   80071c <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 ee 01 00 00    	je     8002d3 <check_regs+0x2a0>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 e8 15 80 00       	push   $0x8015e8
  8000ed:	e8 2a 06 00 00       	call   80071c <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 fa 15 80 00       	push   $0x8015fa
  800105:	68 d4 15 80 00       	push   $0x8015d4
  80010a:	e8 0d 06 00 00       	call   80071c <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 ca 01 00 00    	je     8002e8 <check_regs+0x2b5>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 e8 15 80 00       	push   $0x8015e8
  800126:	e8 f1 05 00 00       	call   80071c <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 fe 15 80 00       	push   $0x8015fe
  80013e:	68 d4 15 80 00       	push   $0x8015d4
  800143:	e8 d4 05 00 00       	call   80071c <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a6 01 00 00    	je     8002fd <check_regs+0x2ca>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 e8 15 80 00       	push   $0x8015e8
  80015f:	e8 b8 05 00 00       	call   80071c <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 02 16 80 00       	push   $0x801602
  800177:	68 d4 15 80 00       	push   $0x8015d4
  80017c:	e8 9b 05 00 00       	call   80071c <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 82 01 00 00    	je     800312 <check_regs+0x2df>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e8 15 80 00       	push   $0x8015e8
  800198:	e8 7f 05 00 00       	call   80071c <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 06 16 80 00       	push   $0x801606
  8001b0:	68 d4 15 80 00       	push   $0x8015d4
  8001b5:	e8 62 05 00 00       	call   80071c <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5e 01 00 00    	je     800327 <check_regs+0x2f4>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 e8 15 80 00       	push   $0x8015e8
  8001d1:	e8 46 05 00 00       	call   80071c <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 0a 16 80 00       	push   $0x80160a
  8001e9:	68 d4 15 80 00       	push   $0x8015d4
  8001ee:	e8 29 05 00 00       	call   80071c <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 3a 01 00 00    	je     80033c <check_regs+0x309>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 e8 15 80 00       	push   $0x8015e8
  80020a:	e8 0d 05 00 00       	call   80071c <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 0e 16 80 00       	push   $0x80160e
  800222:	68 d4 15 80 00       	push   $0x8015d4
  800227:	e8 f0 04 00 00       	call   80071c <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 16 01 00 00    	je     800351 <check_regs+0x31e>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 e8 15 80 00       	push   $0x8015e8
  800243:	e8 d4 04 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 15 16 80 00       	push   $0x801615
  800253:	68 d4 15 80 00       	push   $0x8015d4
  800258:	e8 bf 04 00 00       	call   80071c <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 e8 15 80 00       	push   $0x8015e8
  800274:	e8 a3 04 00 00       	call   80071c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 19 16 80 00       	push   $0x801619
  800284:	e8 93 04 00 00       	call   80071c <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 e8 15 80 00       	push   $0x8015e8
  800294:	e8 83 04 00 00       	call   80071c <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
	CHECK(edi, regs.reg_edi);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 e4 15 80 00       	push   $0x8015e4
  8002ac:	e8 6b 04 00 00       	call   80071c <cprintf>
  8002b1:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	e9 ca fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	68 e4 15 80 00       	push   $0x8015e4
  8002c6:	e8 51 04 00 00       	call   80071c <cprintf>
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	e9 ee fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	68 e4 15 80 00       	push   $0x8015e4
  8002db:	e8 3c 04 00 00       	call   80071c <cprintf>
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	e9 12 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 e4 15 80 00       	push   $0x8015e4
  8002f0:	e8 27 04 00 00       	call   80071c <cprintf>
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	e9 36 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	68 e4 15 80 00       	push   $0x8015e4
  800305:	e8 12 04 00 00       	call   80071c <cprintf>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	e9 5a fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	68 e4 15 80 00       	push   $0x8015e4
  80031a:	e8 fd 03 00 00       	call   80071c <cprintf>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	e9 7e fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 e4 15 80 00       	push   $0x8015e4
  80032f:	e8 e8 03 00 00       	call   80071c <cprintf>
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	e9 a2 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 e4 15 80 00       	push   $0x8015e4
  800344:	e8 d3 03 00 00       	call   80071c <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	e9 c6 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	68 e4 15 80 00       	push   $0x8015e4
  800359:	e8 be 03 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  80035e:	ff 73 28             	pushl  0x28(%ebx)
  800361:	ff 76 28             	pushl  0x28(%esi)
  800364:	68 15 16 80 00       	push   $0x801615
  800369:	68 d4 15 80 00       	push   $0x8015d4
  80036e:	e8 a9 03 00 00       	call   80071c <cprintf>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	8b 43 28             	mov    0x28(%ebx),%eax
  800379:	39 46 28             	cmp    %eax,0x28(%esi)
  80037c:	0f 85 ea fe ff ff    	jne    80026c <check_regs+0x239>
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 e4 15 80 00       	push   $0x8015e4
  80038a:	e8 8d 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	68 19 16 80 00       	push   $0x801619
  80039a:	e8 7d 03 00 00       	call   80071c <cprintf>
	if (!mismatch)
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	85 ff                	test   %edi,%edi
  8003a4:	0f 85 e2 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	68 e4 15 80 00       	push   $0x8015e4
  8003b2:	e8 65 03 00 00       	call   80071c <cprintf>
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	e9 dd fe ff ff       	jmp    80029c <check_regs+0x269>
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 e4 15 80 00       	push   $0x8015e4
  8003c7:	e8 50 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 19 16 80 00       	push   $0x801619
  8003d7:	e8 40 03 00 00       	call   80071c <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 3f 16 80 00       	push   $0x80163f
  80046b:	68 4d 16 80 00       	push   $0x80164d
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba 38 16 80 00       	mov    $0x801638,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 9e 0c 00 00       	call   801133 <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	pushl  0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 80 16 80 00       	push   $0x801680
  8004aa:	6a 51                	push   $0x51
  8004ac:	68 27 16 80 00       	push   $0x801627
  8004b1:	e8 8b 01 00 00       	call   800641 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 54 16 80 00       	push   $0x801654
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 27 16 80 00       	push   $0x801627
  8004c3:	e8 79 01 00 00       	call   800641 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 0a 0e 00 00       	call   8012e2 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	74 10                	je     8005af <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	68 b4 16 80 00       	push   $0x8016b4
  8005a7:	e8 70 01 00 00       	call   80071c <cprintf>
  8005ac:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8005af:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005b4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	68 67 16 80 00       	push   $0x801667
  8005c1:	68 78 16 80 00       	push   $0x801678
  8005c6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005cb:	ba 38 16 80 00       	mov    $0x801638,%edx
  8005d0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005d5:	e8 59 fa ff ff       	call   800033 <check_regs>
}
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005ea:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005f1:	00 00 00 
	envid_t thisenv_id = sys_getenvid();
  8005f4:	e8 fc 0a 00 00       	call   8010f5 <sys_getenvid>
	thisenv = envs + ENVX(thisenv_id);
  8005f9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005fe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800601:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800606:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060b:	85 db                	test   %ebx,%ebx
  80060d:	7e 07                	jle    800616 <libmain+0x37>
		binaryname = argv[0];
  80060f:	8b 06                	mov    (%esi),%eax
  800611:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	56                   	push   %esi
  80061a:	53                   	push   %ebx
  80061b:	e8 a8 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  800620:	e8 0a 00 00 00       	call   80062f <exit>
}
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800635:	6a 00                	push   $0x0
  800637:	e8 78 0a 00 00       	call   8010b4 <sys_env_destroy>
}
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	c9                   	leave  
  800640:	c3                   	ret    

00800641 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	56                   	push   %esi
  800645:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800646:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800649:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80064f:	e8 a1 0a 00 00       	call   8010f5 <sys_getenvid>
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	ff 75 08             	pushl  0x8(%ebp)
  80065d:	56                   	push   %esi
  80065e:	50                   	push   %eax
  80065f:	68 e0 16 80 00       	push   $0x8016e0
  800664:	e8 b3 00 00 00       	call   80071c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800669:	83 c4 18             	add    $0x18,%esp
  80066c:	53                   	push   %ebx
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	e8 56 00 00 00       	call   8006cb <vcprintf>
	cprintf("\n");
  800675:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  80067c:	e8 9b 00 00 00       	call   80071c <cprintf>
  800681:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800684:	cc                   	int3   
  800685:	eb fd                	jmp    800684 <_panic+0x43>

00800687 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	53                   	push   %ebx
  80068b:	83 ec 04             	sub    $0x4,%esp
  80068e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800691:	8b 13                	mov    (%ebx),%edx
  800693:	8d 42 01             	lea    0x1(%edx),%eax
  800696:	89 03                	mov    %eax,(%ebx)
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80069f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a4:	74 09                	je     8006af <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	68 ff 00 00 00       	push   $0xff
  8006b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8006ba:	50                   	push   %eax
  8006bb:	e8 b7 09 00 00       	call   801077 <sys_cputs>
		b->idx = 0;
  8006c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb db                	jmp    8006a6 <putch+0x1f>

008006cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006db:	00 00 00 
	b.cnt = 0;
  8006de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e8:	ff 75 0c             	pushl  0xc(%ebp)
  8006eb:	ff 75 08             	pushl  0x8(%ebp)
  8006ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	68 87 06 80 00       	push   $0x800687
  8006fa:	e8 1a 01 00 00       	call   800819 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ff:	83 c4 08             	add    $0x8,%esp
  800702:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800708:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	e8 63 09 00 00       	call   801077 <sys_cputs>

	return b.cnt;
}
  800714:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800722:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800725:	50                   	push   %eax
  800726:	ff 75 08             	pushl  0x8(%ebp)
  800729:	e8 9d ff ff ff       	call   8006cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 1c             	sub    $0x1c,%esp
  800739:	89 c7                	mov    %eax,%edi
  80073b:	89 d6                	mov    %edx,%esi
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800749:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80074c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800751:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800754:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800757:	39 d3                	cmp    %edx,%ebx
  800759:	72 05                	jb     800760 <printnum+0x30>
  80075b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80075e:	77 7a                	ja     8007da <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800760:	83 ec 0c             	sub    $0xc,%esp
  800763:	ff 75 18             	pushl  0x18(%ebp)
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80076c:	53                   	push   %ebx
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	ff 75 e4             	pushl  -0x1c(%ebp)
  800776:	ff 75 e0             	pushl  -0x20(%ebp)
  800779:	ff 75 dc             	pushl  -0x24(%ebp)
  80077c:	ff 75 d8             	pushl  -0x28(%ebp)
  80077f:	e8 fc 0b 00 00       	call   801380 <__udivdi3>
  800784:	83 c4 18             	add    $0x18,%esp
  800787:	52                   	push   %edx
  800788:	50                   	push   %eax
  800789:	89 f2                	mov    %esi,%edx
  80078b:	89 f8                	mov    %edi,%eax
  80078d:	e8 9e ff ff ff       	call   800730 <printnum>
  800792:	83 c4 20             	add    $0x20,%esp
  800795:	eb 13                	jmp    8007aa <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	56                   	push   %esi
  80079b:	ff 75 18             	pushl  0x18(%ebp)
  80079e:	ff d7                	call   *%edi
  8007a0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007a3:	83 eb 01             	sub    $0x1,%ebx
  8007a6:	85 db                	test   %ebx,%ebx
  8007a8:	7f ed                	jg     800797 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	56                   	push   %esi
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8007ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8007bd:	e8 de 0c 00 00       	call   8014a0 <__umoddi3>
  8007c2:	83 c4 14             	add    $0x14,%esp
  8007c5:	0f be 80 04 17 80 00 	movsbl 0x801704(%eax),%eax
  8007cc:	50                   	push   %eax
  8007cd:	ff d7                	call   *%edi
}
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5f                   	pop    %edi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    
  8007da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007dd:	eb c4                	jmp    8007a3 <printnum+0x73>

008007df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ee:	73 0a                	jae    8007fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8007f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007f3:	89 08                	mov    %ecx,(%eax)
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	88 02                	mov    %al,(%edx)
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <printfmt>:
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800802:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800805:	50                   	push   %eax
  800806:	ff 75 10             	pushl  0x10(%ebp)
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	ff 75 08             	pushl  0x8(%ebp)
  80080f:	e8 05 00 00 00       	call   800819 <vprintfmt>
}
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <vprintfmt>:
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	83 ec 2c             	sub    $0x2c,%esp
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800828:	8b 7d 10             	mov    0x10(%ebp),%edi
  80082b:	e9 63 03 00 00       	jmp    800b93 <vprintfmt+0x37a>
		padc = ' ';
  800830:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800834:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80083b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800842:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800849:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8d 47 01             	lea    0x1(%edi),%eax
  800851:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800854:	0f b6 17             	movzbl (%edi),%edx
  800857:	8d 42 dd             	lea    -0x23(%edx),%eax
  80085a:	3c 55                	cmp    $0x55,%al
  80085c:	0f 87 11 04 00 00    	ja     800c73 <vprintfmt+0x45a>
  800862:	0f b6 c0             	movzbl %al,%eax
  800865:	ff 24 85 c0 17 80 00 	jmp    *0x8017c0(,%eax,4)
  80086c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80086f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800873:	eb d9                	jmp    80084e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800875:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800878:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087c:	eb d0                	jmp    80084e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	0f b6 d2             	movzbl %dl,%edx
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80088c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800893:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800896:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800899:	83 f9 09             	cmp    $0x9,%ecx
  80089c:	77 55                	ja     8008f3 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80089e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008a1:	eb e9                	jmp    80088c <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8b 00                	mov    (%eax),%eax
  8008a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 40 04             	lea    0x4(%eax),%eax
  8008b1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008bb:	79 91                	jns    80084e <vprintfmt+0x35>
				width = precision, precision = -1;
  8008bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ca:	eb 82                	jmp    80084e <vprintfmt+0x35>
  8008cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d6:	0f 49 d0             	cmovns %eax,%edx
  8008d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008df:	e9 6a ff ff ff       	jmp    80084e <vprintfmt+0x35>
  8008e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8008e7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008ee:	e9 5b ff ff ff       	jmp    80084e <vprintfmt+0x35>
  8008f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f9:	eb bc                	jmp    8008b7 <vprintfmt+0x9e>
			lflag++;
  8008fb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800901:	e9 48 ff ff ff       	jmp    80084e <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8d 78 04             	lea    0x4(%eax),%edi
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	53                   	push   %ebx
  800910:	ff 30                	pushl  (%eax)
  800912:	ff d6                	call   *%esi
			break;
  800914:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800917:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80091a:	e9 71 02 00 00       	jmp    800b90 <vprintfmt+0x377>
			err = va_arg(ap, int);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 78 04             	lea    0x4(%eax),%edi
  800925:	8b 00                	mov    (%eax),%eax
  800927:	99                   	cltd   
  800928:	31 d0                	xor    %edx,%eax
  80092a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092c:	83 f8 08             	cmp    $0x8,%eax
  80092f:	7f 23                	jg     800954 <vprintfmt+0x13b>
  800931:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  800938:	85 d2                	test   %edx,%edx
  80093a:	74 18                	je     800954 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80093c:	52                   	push   %edx
  80093d:	68 25 17 80 00       	push   $0x801725
  800942:	53                   	push   %ebx
  800943:	56                   	push   %esi
  800944:	e8 b3 fe ff ff       	call   8007fc <printfmt>
  800949:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80094c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80094f:	e9 3c 02 00 00       	jmp    800b90 <vprintfmt+0x377>
				printfmt(putch, putdat, "error %d", err);
  800954:	50                   	push   %eax
  800955:	68 1c 17 80 00       	push   $0x80171c
  80095a:	53                   	push   %ebx
  80095b:	56                   	push   %esi
  80095c:	e8 9b fe ff ff       	call   8007fc <printfmt>
  800961:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800964:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800967:	e9 24 02 00 00       	jmp    800b90 <vprintfmt+0x377>
			if ((p = va_arg(ap, char *)) == NULL)
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	83 c0 04             	add    $0x4,%eax
  800972:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097a:	85 ff                	test   %edi,%edi
  80097c:	b8 15 17 80 00       	mov    $0x801715,%eax
  800981:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800984:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800988:	0f 8e bd 00 00 00    	jle    800a4b <vprintfmt+0x232>
  80098e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800992:	75 0e                	jne    8009a2 <vprintfmt+0x189>
  800994:	89 75 08             	mov    %esi,0x8(%ebp)
  800997:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80099a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80099d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009a0:	eb 6d                	jmp    800a0f <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a8:	57                   	push   %edi
  8009a9:	e8 6d 03 00 00       	call   800d1b <strnlen>
  8009ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b1:	29 c1                	sub    %eax,%ecx
  8009b3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8009b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c3:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	eb 0f                	jmp    8009d6 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	53                   	push   %ebx
  8009cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ce:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d0:	83 ef 01             	sub    $0x1,%edi
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	7f ed                	jg     8009c7 <vprintfmt+0x1ae>
  8009da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	0f 49 c1             	cmovns %ecx,%eax
  8009ea:	29 c1                	sub    %eax,%ecx
  8009ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	eb 16                	jmp    800a0f <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	75 31                	jne    800a30 <vprintfmt+0x217>
					putch(ch, putdat);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	50                   	push   %eax
  800a06:	ff 55 08             	call   *0x8(%ebp)
  800a09:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0c:	83 eb 01             	sub    $0x1,%ebx
  800a0f:	83 c7 01             	add    $0x1,%edi
  800a12:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a16:	0f be c2             	movsbl %dl,%eax
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	74 59                	je     800a76 <vprintfmt+0x25d>
  800a1d:	85 f6                	test   %esi,%esi
  800a1f:	78 d8                	js     8009f9 <vprintfmt+0x1e0>
  800a21:	83 ee 01             	sub    $0x1,%esi
  800a24:	79 d3                	jns    8009f9 <vprintfmt+0x1e0>
  800a26:	89 df                	mov    %ebx,%edi
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2e:	eb 37                	jmp    800a67 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a30:	0f be d2             	movsbl %dl,%edx
  800a33:	83 ea 20             	sub    $0x20,%edx
  800a36:	83 fa 5e             	cmp    $0x5e,%edx
  800a39:	76 c4                	jbe    8009ff <vprintfmt+0x1e6>
					putch('?', putdat);
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	6a 3f                	push   $0x3f
  800a43:	ff 55 08             	call   *0x8(%ebp)
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	eb c1                	jmp    800a0c <vprintfmt+0x1f3>
  800a4b:	89 75 08             	mov    %esi,0x8(%ebp)
  800a4e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a51:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a54:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a57:	eb b6                	jmp    800a0f <vprintfmt+0x1f6>
				putch(' ', putdat);
  800a59:	83 ec 08             	sub    $0x8,%esp
  800a5c:	53                   	push   %ebx
  800a5d:	6a 20                	push   $0x20
  800a5f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ee                	jg     800a59 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800a6b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a6e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a71:	e9 1a 01 00 00       	jmp    800b90 <vprintfmt+0x377>
  800a76:	89 df                	mov    %ebx,%edi
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7e:	eb e7                	jmp    800a67 <vprintfmt+0x24e>
	if (lflag >= 2)
  800a80:	83 f9 01             	cmp    $0x1,%ecx
  800a83:	7e 3f                	jle    800ac4 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8b 50 04             	mov    0x4(%eax),%edx
  800a8b:	8b 00                	mov    (%eax),%eax
  800a8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a90:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a93:	8b 45 14             	mov    0x14(%ebp),%eax
  800a96:	8d 40 08             	lea    0x8(%eax),%eax
  800a99:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800a9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800aa0:	79 5c                	jns    800afe <vprintfmt+0x2e5>
				putch('-', putdat);
  800aa2:	83 ec 08             	sub    $0x8,%esp
  800aa5:	53                   	push   %ebx
  800aa6:	6a 2d                	push   $0x2d
  800aa8:	ff d6                	call   *%esi
				num = -(long long) num;
  800aaa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ab0:	f7 da                	neg    %edx
  800ab2:	83 d1 00             	adc    $0x0,%ecx
  800ab5:	f7 d9                	neg    %ecx
  800ab7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800aba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800abf:	e9 b2 00 00 00       	jmp    800b76 <vprintfmt+0x35d>
	else if (lflag)
  800ac4:	85 c9                	test   %ecx,%ecx
  800ac6:	75 1b                	jne    800ae3 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  800acb:	8b 00                	mov    (%eax),%eax
  800acd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  800adb:	8d 40 04             	lea    0x4(%eax),%eax
  800ade:	89 45 14             	mov    %eax,0x14(%ebp)
  800ae1:	eb b9                	jmp    800a9c <vprintfmt+0x283>
		return va_arg(*ap, long);
  800ae3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae6:	8b 00                	mov    (%eax),%eax
  800ae8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aeb:	89 c1                	mov    %eax,%ecx
  800aed:	c1 f9 1f             	sar    $0x1f,%ecx
  800af0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	8d 40 04             	lea    0x4(%eax),%eax
  800af9:	89 45 14             	mov    %eax,0x14(%ebp)
  800afc:	eb 9e                	jmp    800a9c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800afe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b01:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	eb 6b                	jmp    800b76 <vprintfmt+0x35d>
	if (lflag >= 2)
  800b0b:	83 f9 01             	cmp    $0x1,%ecx
  800b0e:	7e 15                	jle    800b25 <vprintfmt+0x30c>
		return va_arg(*ap, unsigned long long);
  800b10:	8b 45 14             	mov    0x14(%ebp),%eax
  800b13:	8b 10                	mov    (%eax),%edx
  800b15:	8b 48 04             	mov    0x4(%eax),%ecx
  800b18:	8d 40 08             	lea    0x8(%eax),%eax
  800b1b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b23:	eb 51                	jmp    800b76 <vprintfmt+0x35d>
	else if (lflag)
  800b25:	85 c9                	test   %ecx,%ecx
  800b27:	75 17                	jne    800b40 <vprintfmt+0x327>
		return va_arg(*ap, unsigned int);
  800b29:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2c:	8b 10                	mov    (%eax),%edx
  800b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b33:	8d 40 04             	lea    0x4(%eax),%eax
  800b36:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3e:	eb 36                	jmp    800b76 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800b40:	8b 45 14             	mov    0x14(%ebp),%eax
  800b43:	8b 10                	mov    (%eax),%edx
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	8d 40 04             	lea    0x4(%eax),%eax
  800b4d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b55:	eb 1f                	jmp    800b76 <vprintfmt+0x35d>
	if (lflag >= 2)
  800b57:	83 f9 01             	cmp    $0x1,%ecx
  800b5a:	7e 5b                	jle    800bb7 <vprintfmt+0x39e>
		return va_arg(*ap, long long);
  800b5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5f:	8b 50 04             	mov    0x4(%eax),%edx
  800b62:	8b 00                	mov    (%eax),%eax
  800b64:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b67:	8d 49 08             	lea    0x8(%ecx),%ecx
  800b6a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 c2                	mov    %eax,%edx
			base = 8;
  800b71:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b7d:	57                   	push   %edi
  800b7e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b81:	50                   	push   %eax
  800b82:	51                   	push   %ecx
  800b83:	52                   	push   %edx
  800b84:	89 da                	mov    %ebx,%edx
  800b86:	89 f0                	mov    %esi,%eax
  800b88:	e8 a3 fb ff ff       	call   800730 <printnum>
			break;
  800b8d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800b90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b93:	83 c7 01             	add    $0x1,%edi
  800b96:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b9a:	83 f8 25             	cmp    $0x25,%eax
  800b9d:	0f 84 8d fc ff ff    	je     800830 <vprintfmt+0x17>
			if (ch == '\0')
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	0f 84 e8 00 00 00    	je     800c93 <vprintfmt+0x47a>
			putch(ch, putdat);
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	53                   	push   %ebx
  800baf:	50                   	push   %eax
  800bb0:	ff d6                	call   *%esi
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	eb dc                	jmp    800b93 <vprintfmt+0x37a>
	else if (lflag)
  800bb7:	85 c9                	test   %ecx,%ecx
  800bb9:	75 13                	jne    800bce <vprintfmt+0x3b5>
		return va_arg(*ap, int);
  800bbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbe:	8b 10                	mov    (%eax),%edx
  800bc0:	89 d0                	mov    %edx,%eax
  800bc2:	99                   	cltd   
  800bc3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bc6:	8d 49 04             	lea    0x4(%ecx),%ecx
  800bc9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bcc:	eb 9f                	jmp    800b6d <vprintfmt+0x354>
		return va_arg(*ap, long);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	8b 10                	mov    (%eax),%edx
  800bd3:	89 d0                	mov    %edx,%eax
  800bd5:	99                   	cltd   
  800bd6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bd9:	8d 49 04             	lea    0x4(%ecx),%ecx
  800bdc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bdf:	eb 8c                	jmp    800b6d <vprintfmt+0x354>
			putch('0', putdat);
  800be1:	83 ec 08             	sub    $0x8,%esp
  800be4:	53                   	push   %ebx
  800be5:	6a 30                	push   $0x30
  800be7:	ff d6                	call   *%esi
			putch('x', putdat);
  800be9:	83 c4 08             	add    $0x8,%esp
  800bec:	53                   	push   %ebx
  800bed:	6a 78                	push   $0x78
  800bef:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bf1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf4:	8b 10                	mov    (%eax),%edx
  800bf6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bfb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bfe:	8d 40 04             	lea    0x4(%eax),%eax
  800c01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c04:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c09:	e9 68 ff ff ff       	jmp    800b76 <vprintfmt+0x35d>
	if (lflag >= 2)
  800c0e:	83 f9 01             	cmp    $0x1,%ecx
  800c11:	7e 18                	jle    800c2b <vprintfmt+0x412>
		return va_arg(*ap, unsigned long long);
  800c13:	8b 45 14             	mov    0x14(%ebp),%eax
  800c16:	8b 10                	mov    (%eax),%edx
  800c18:	8b 48 04             	mov    0x4(%eax),%ecx
  800c1b:	8d 40 08             	lea    0x8(%eax),%eax
  800c1e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c21:	b8 10 00 00 00       	mov    $0x10,%eax
  800c26:	e9 4b ff ff ff       	jmp    800b76 <vprintfmt+0x35d>
	else if (lflag)
  800c2b:	85 c9                	test   %ecx,%ecx
  800c2d:	75 1a                	jne    800c49 <vprintfmt+0x430>
		return va_arg(*ap, unsigned int);
  800c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c32:	8b 10                	mov    (%eax),%edx
  800c34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c39:	8d 40 04             	lea    0x4(%eax),%eax
  800c3c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c3f:	b8 10 00 00 00       	mov    $0x10,%eax
  800c44:	e9 2d ff ff ff       	jmp    800b76 <vprintfmt+0x35d>
		return va_arg(*ap, unsigned long);
  800c49:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4c:	8b 10                	mov    (%eax),%edx
  800c4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c53:	8d 40 04             	lea    0x4(%eax),%eax
  800c56:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c59:	b8 10 00 00 00       	mov    $0x10,%eax
  800c5e:	e9 13 ff ff ff       	jmp    800b76 <vprintfmt+0x35d>
			putch(ch, putdat);
  800c63:	83 ec 08             	sub    $0x8,%esp
  800c66:	53                   	push   %ebx
  800c67:	6a 25                	push   $0x25
  800c69:	ff d6                	call   *%esi
			break;
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	e9 1d ff ff ff       	jmp    800b90 <vprintfmt+0x377>
			putch('%', putdat);
  800c73:	83 ec 08             	sub    $0x8,%esp
  800c76:	53                   	push   %ebx
  800c77:	6a 25                	push   $0x25
  800c79:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	89 f8                	mov    %edi,%eax
  800c80:	eb 03                	jmp    800c85 <vprintfmt+0x46c>
  800c82:	83 e8 01             	sub    $0x1,%eax
  800c85:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c89:	75 f7                	jne    800c82 <vprintfmt+0x469>
  800c8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8e:	e9 fd fe ff ff       	jmp    800b90 <vprintfmt+0x377>
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 18             	sub    $0x18,%esp
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800caa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	74 26                	je     800ce2 <vsnprintf+0x47>
  800cbc:	85 d2                	test   %edx,%edx
  800cbe:	7e 22                	jle    800ce2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cc0:	ff 75 14             	pushl  0x14(%ebp)
  800cc3:	ff 75 10             	pushl  0x10(%ebp)
  800cc6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc9:	50                   	push   %eax
  800cca:	68 df 07 80 00       	push   $0x8007df
  800ccf:	e8 45 fb ff ff       	call   800819 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdd:	83 c4 10             	add    $0x10,%esp
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    
		return -E_INVAL;
  800ce2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce7:	eb f7                	jmp    800ce0 <vsnprintf+0x45>

00800ce9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	50                   	push   %eax
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	e8 9a ff ff ff       	call   800c9b <vsnprintf>
	va_end(ap);

	return rc;
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	eb 03                	jmp    800d13 <strlen+0x10>
		n++;
  800d10:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d17:	75 f7                	jne    800d10 <strlen+0xd>
	return n;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d21:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d24:	b8 00 00 00 00       	mov    $0x0,%eax
  800d29:	eb 03                	jmp    800d2e <strnlen+0x13>
		n++;
  800d2b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2e:	39 d0                	cmp    %edx,%eax
  800d30:	74 06                	je     800d38 <strnlen+0x1d>
  800d32:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d36:	75 f3                	jne    800d2b <strnlen+0x10>
	return n;
}
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	83 c1 01             	add    $0x1,%ecx
  800d49:	83 c2 01             	add    $0x1,%edx
  800d4c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d50:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d53:	84 db                	test   %bl,%bl
  800d55:	75 ef                	jne    800d46 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d57:	5b                   	pop    %ebx
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	53                   	push   %ebx
  800d5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d61:	53                   	push   %ebx
  800d62:	e8 9c ff ff ff       	call   800d03 <strlen>
  800d67:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d6a:	ff 75 0c             	pushl  0xc(%ebp)
  800d6d:	01 d8                	add    %ebx,%eax
  800d6f:	50                   	push   %eax
  800d70:	e8 c5 ff ff ff       	call   800d3a <strcpy>
	return dst;
}
  800d75:	89 d8                	mov    %ebx,%eax
  800d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	8b 75 08             	mov    0x8(%ebp),%esi
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	89 f3                	mov    %esi,%ebx
  800d89:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d8c:	89 f2                	mov    %esi,%edx
  800d8e:	eb 0f                	jmp    800d9f <strncpy+0x23>
		*dst++ = *src;
  800d90:	83 c2 01             	add    $0x1,%edx
  800d93:	0f b6 01             	movzbl (%ecx),%eax
  800d96:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d99:	80 39 01             	cmpb   $0x1,(%ecx)
  800d9c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800d9f:	39 da                	cmp    %ebx,%edx
  800da1:	75 ed                	jne    800d90 <strncpy+0x14>
	}
	return ret;
}
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	8b 75 08             	mov    0x8(%ebp),%esi
  800db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dbd:	85 c9                	test   %ecx,%ecx
  800dbf:	75 0b                	jne    800dcc <strlcpy+0x23>
  800dc1:	eb 17                	jmp    800dda <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dc3:	83 c2 01             	add    $0x1,%edx
  800dc6:	83 c0 01             	add    $0x1,%eax
  800dc9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800dcc:	39 d8                	cmp    %ebx,%eax
  800dce:	74 07                	je     800dd7 <strlcpy+0x2e>
  800dd0:	0f b6 0a             	movzbl (%edx),%ecx
  800dd3:	84 c9                	test   %cl,%cl
  800dd5:	75 ec                	jne    800dc3 <strlcpy+0x1a>
		*dst = '\0';
  800dd7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dda:	29 f0                	sub    %esi,%eax
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de9:	eb 06                	jmp    800df1 <strcmp+0x11>
		p++, q++;
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800df1:	0f b6 01             	movzbl (%ecx),%eax
  800df4:	84 c0                	test   %al,%al
  800df6:	74 04                	je     800dfc <strcmp+0x1c>
  800df8:	3a 02                	cmp    (%edx),%al
  800dfa:	74 ef                	je     800deb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfc:	0f b6 c0             	movzbl %al,%eax
  800dff:	0f b6 12             	movzbl (%edx),%edx
  800e02:	29 d0                	sub    %edx,%eax
}
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	53                   	push   %ebx
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e15:	eb 06                	jmp    800e1d <strncmp+0x17>
		n--, p++, q++;
  800e17:	83 c0 01             	add    $0x1,%eax
  800e1a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e1d:	39 d8                	cmp    %ebx,%eax
  800e1f:	74 16                	je     800e37 <strncmp+0x31>
  800e21:	0f b6 08             	movzbl (%eax),%ecx
  800e24:	84 c9                	test   %cl,%cl
  800e26:	74 04                	je     800e2c <strncmp+0x26>
  800e28:	3a 0a                	cmp    (%edx),%cl
  800e2a:	74 eb                	je     800e17 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2c:	0f b6 00             	movzbl (%eax),%eax
  800e2f:	0f b6 12             	movzbl (%edx),%edx
  800e32:	29 d0                	sub    %edx,%eax
}
  800e34:	5b                   	pop    %ebx
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
		return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	eb f6                	jmp    800e34 <strncmp+0x2e>

00800e3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e48:	0f b6 10             	movzbl (%eax),%edx
  800e4b:	84 d2                	test   %dl,%dl
  800e4d:	74 09                	je     800e58 <strchr+0x1a>
		if (*s == c)
  800e4f:	38 ca                	cmp    %cl,%dl
  800e51:	74 0a                	je     800e5d <strchr+0x1f>
	for (; *s; s++)
  800e53:	83 c0 01             	add    $0x1,%eax
  800e56:	eb f0                	jmp    800e48 <strchr+0xa>
			return (char *) s;
	return 0;
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e69:	eb 03                	jmp    800e6e <strfind+0xf>
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e71:	38 ca                	cmp    %cl,%dl
  800e73:	74 04                	je     800e79 <strfind+0x1a>
  800e75:	84 d2                	test   %dl,%dl
  800e77:	75 f2                	jne    800e6b <strfind+0xc>
			break;
	return (char *) s;
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e87:	85 c9                	test   %ecx,%ecx
  800e89:	74 13                	je     800e9e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e91:	75 05                	jne    800e98 <memset+0x1d>
  800e93:	f6 c1 03             	test   $0x3,%cl
  800e96:	74 0d                	je     800ea5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9b:	fc                   	cld    
  800e9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e9e:	89 f8                	mov    %edi,%eax
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
		c &= 0xFF;
  800ea5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ea9:	89 d3                	mov    %edx,%ebx
  800eab:	c1 e3 08             	shl    $0x8,%ebx
  800eae:	89 d0                	mov    %edx,%eax
  800eb0:	c1 e0 18             	shl    $0x18,%eax
  800eb3:	89 d6                	mov    %edx,%esi
  800eb5:	c1 e6 10             	shl    $0x10,%esi
  800eb8:	09 f0                	or     %esi,%eax
  800eba:	09 c2                	or     %eax,%edx
  800ebc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ebe:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ec1:	89 d0                	mov    %edx,%eax
  800ec3:	fc                   	cld    
  800ec4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec6:	eb d6                	jmp    800e9e <memset+0x23>

00800ec8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed6:	39 c6                	cmp    %eax,%esi
  800ed8:	73 35                	jae    800f0f <memmove+0x47>
  800eda:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800edd:	39 c2                	cmp    %eax,%edx
  800edf:	76 2e                	jbe    800f0f <memmove+0x47>
		s += n;
		d += n;
  800ee1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	09 fe                	or     %edi,%esi
  800ee8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eee:	74 0c                	je     800efc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ef0:	83 ef 01             	sub    $0x1,%edi
  800ef3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ef6:	fd                   	std    
  800ef7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef9:	fc                   	cld    
  800efa:	eb 21                	jmp    800f1d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efc:	f6 c1 03             	test   $0x3,%cl
  800eff:	75 ef                	jne    800ef0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f01:	83 ef 04             	sub    $0x4,%edi
  800f04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f07:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f0a:	fd                   	std    
  800f0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0d:	eb ea                	jmp    800ef9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	09 c2                	or     %eax,%edx
  800f13:	f6 c2 03             	test   $0x3,%dl
  800f16:	74 09                	je     800f21 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f18:	89 c7                	mov    %eax,%edi
  800f1a:	fc                   	cld    
  800f1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f21:	f6 c1 03             	test   $0x3,%cl
  800f24:	75 f2                	jne    800f18 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f26:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f29:	89 c7                	mov    %eax,%edi
  800f2b:	fc                   	cld    
  800f2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2e:	eb ed                	jmp    800f1d <memmove+0x55>

00800f30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f33:	ff 75 10             	pushl  0x10(%ebp)
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	ff 75 08             	pushl  0x8(%ebp)
  800f3c:	e8 87 ff ff ff       	call   800ec8 <memmove>
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4e:	89 c6                	mov    %eax,%esi
  800f50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f53:	39 f0                	cmp    %esi,%eax
  800f55:	74 1c                	je     800f73 <memcmp+0x30>
		if (*s1 != *s2)
  800f57:	0f b6 08             	movzbl (%eax),%ecx
  800f5a:	0f b6 1a             	movzbl (%edx),%ebx
  800f5d:	38 d9                	cmp    %bl,%cl
  800f5f:	75 08                	jne    800f69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f61:	83 c0 01             	add    $0x1,%eax
  800f64:	83 c2 01             	add    $0x1,%edx
  800f67:	eb ea                	jmp    800f53 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800f69:	0f b6 c1             	movzbl %cl,%eax
  800f6c:	0f b6 db             	movzbl %bl,%ebx
  800f6f:	29 d8                	sub    %ebx,%eax
  800f71:	eb 05                	jmp    800f78 <memcmp+0x35>
	}

	return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f85:	89 c2                	mov    %eax,%edx
  800f87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f8a:	39 d0                	cmp    %edx,%eax
  800f8c:	73 09                	jae    800f97 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f8e:	38 08                	cmp    %cl,(%eax)
  800f90:	74 05                	je     800f97 <memfind+0x1b>
	for (; s < ends; s++)
  800f92:	83 c0 01             	add    $0x1,%eax
  800f95:	eb f3                	jmp    800f8a <memfind+0xe>
			break;
	return (void *) s;
}
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa5:	eb 03                	jmp    800faa <strtol+0x11>
		s++;
  800fa7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800faa:	0f b6 01             	movzbl (%ecx),%eax
  800fad:	3c 20                	cmp    $0x20,%al
  800faf:	74 f6                	je     800fa7 <strtol+0xe>
  800fb1:	3c 09                	cmp    $0x9,%al
  800fb3:	74 f2                	je     800fa7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800fb5:	3c 2b                	cmp    $0x2b,%al
  800fb7:	74 2e                	je     800fe7 <strtol+0x4e>
	int neg = 0;
  800fb9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800fbe:	3c 2d                	cmp    $0x2d,%al
  800fc0:	74 2f                	je     800ff1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fc2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fc8:	75 05                	jne    800fcf <strtol+0x36>
  800fca:	80 39 30             	cmpb   $0x30,(%ecx)
  800fcd:	74 2c                	je     800ffb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fcf:	85 db                	test   %ebx,%ebx
  800fd1:	75 0a                	jne    800fdd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fd3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800fd8:	80 39 30             	cmpb   $0x30,(%ecx)
  800fdb:	74 28                	je     801005 <strtol+0x6c>
		base = 10;
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800fe5:	eb 50                	jmp    801037 <strtol+0x9e>
		s++;
  800fe7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800fea:	bf 00 00 00 00       	mov    $0x0,%edi
  800fef:	eb d1                	jmp    800fc2 <strtol+0x29>
		s++, neg = 1;
  800ff1:	83 c1 01             	add    $0x1,%ecx
  800ff4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ff9:	eb c7                	jmp    800fc2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ffb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fff:	74 0e                	je     80100f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801001:	85 db                	test   %ebx,%ebx
  801003:	75 d8                	jne    800fdd <strtol+0x44>
		s++, base = 8;
  801005:	83 c1 01             	add    $0x1,%ecx
  801008:	bb 08 00 00 00       	mov    $0x8,%ebx
  80100d:	eb ce                	jmp    800fdd <strtol+0x44>
		s += 2, base = 16;
  80100f:	83 c1 02             	add    $0x2,%ecx
  801012:	bb 10 00 00 00       	mov    $0x10,%ebx
  801017:	eb c4                	jmp    800fdd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801019:	8d 72 9f             	lea    -0x61(%edx),%esi
  80101c:	89 f3                	mov    %esi,%ebx
  80101e:	80 fb 19             	cmp    $0x19,%bl
  801021:	77 29                	ja     80104c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801023:	0f be d2             	movsbl %dl,%edx
  801026:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801029:	3b 55 10             	cmp    0x10(%ebp),%edx
  80102c:	7d 30                	jge    80105e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80102e:	83 c1 01             	add    $0x1,%ecx
  801031:	0f af 45 10          	imul   0x10(%ebp),%eax
  801035:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801037:	0f b6 11             	movzbl (%ecx),%edx
  80103a:	8d 72 d0             	lea    -0x30(%edx),%esi
  80103d:	89 f3                	mov    %esi,%ebx
  80103f:	80 fb 09             	cmp    $0x9,%bl
  801042:	77 d5                	ja     801019 <strtol+0x80>
			dig = *s - '0';
  801044:	0f be d2             	movsbl %dl,%edx
  801047:	83 ea 30             	sub    $0x30,%edx
  80104a:	eb dd                	jmp    801029 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  80104c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80104f:	89 f3                	mov    %esi,%ebx
  801051:	80 fb 19             	cmp    $0x19,%bl
  801054:	77 08                	ja     80105e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801056:	0f be d2             	movsbl %dl,%edx
  801059:	83 ea 37             	sub    $0x37,%edx
  80105c:	eb cb                	jmp    801029 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80105e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801062:	74 05                	je     801069 <strtol+0xd0>
		*endptr = (char *) s;
  801064:	8b 75 0c             	mov    0xc(%ebp),%esi
  801067:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801069:	89 c2                	mov    %eax,%edx
  80106b:	f7 da                	neg    %edx
  80106d:	85 ff                	test   %edi,%edi
  80106f:	0f 45 c2             	cmovne %edx,%eax
}
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_cgetc>:

int
sys_cgetc(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	89 d3                	mov    %edx,%ebx
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	89 d6                	mov    %edx,%esi
  8010ad:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8010ca:	89 cb                	mov    %ecx,%ebx
  8010cc:	89 cf                	mov    %ecx,%edi
  8010ce:	89 ce                	mov    %ecx,%esi
  8010d0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	7f 08                	jg     8010de <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	50                   	push   %eax
  8010e2:	6a 03                	push   $0x3
  8010e4:	68 44 19 80 00       	push   $0x801944
  8010e9:	6a 23                	push   $0x23
  8010eb:	68 61 19 80 00       	push   $0x801961
  8010f0:	e8 4c f5 ff ff       	call   800641 <_panic>

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	asm volatile("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	8b 55 08             	mov    0x8(%ebp),%edx
  801144:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801147:	b8 04 00 00 00       	mov    $0x4,%eax
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7f 08                	jg     80115f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	50                   	push   %eax
  801163:	6a 04                	push   $0x4
  801165:	68 44 19 80 00       	push   $0x801944
  80116a:	6a 23                	push   $0x23
  80116c:	68 61 19 80 00       	push   $0x801961
  801171:	e8 cb f4 ff ff       	call   800641 <_panic>

00801176 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80117f:	8b 55 08             	mov    0x8(%ebp),%edx
  801182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801185:	b8 05 00 00 00       	mov    $0x5,%eax
  80118a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801190:	8b 75 18             	mov    0x18(%ebp),%esi
  801193:	cd 30                	int    $0x30
	if(check && ret > 0)
  801195:	85 c0                	test   %eax,%eax
  801197:	7f 08                	jg     8011a1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	50                   	push   %eax
  8011a5:	6a 05                	push   $0x5
  8011a7:	68 44 19 80 00       	push   $0x801944
  8011ac:	6a 23                	push   $0x23
  8011ae:	68 61 19 80 00       	push   $0x801961
  8011b3:	e8 89 f4 ff ff       	call   800641 <_panic>

008011b8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8011d1:	89 df                	mov    %ebx,%edi
  8011d3:	89 de                	mov    %ebx,%esi
  8011d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7f 08                	jg     8011e3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	50                   	push   %eax
  8011e7:	6a 06                	push   $0x6
  8011e9:	68 44 19 80 00       	push   $0x801944
  8011ee:	6a 23                	push   $0x23
  8011f0:	68 61 19 80 00       	push   $0x801961
  8011f5:	e8 47 f4 ff ff       	call   800641 <_panic>

008011fa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801203:	bb 00 00 00 00       	mov    $0x0,%ebx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120e:	b8 08 00 00 00       	mov    $0x8,%eax
  801213:	89 df                	mov    %ebx,%edi
  801215:	89 de                	mov    %ebx,%esi
  801217:	cd 30                	int    $0x30
	if(check && ret > 0)
  801219:	85 c0                	test   %eax,%eax
  80121b:	7f 08                	jg     801225 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	50                   	push   %eax
  801229:	6a 08                	push   $0x8
  80122b:	68 44 19 80 00       	push   $0x801944
  801230:	6a 23                	push   $0x23
  801232:	68 61 19 80 00       	push   $0x801961
  801237:	e8 05 f4 ff ff       	call   800641 <_panic>

0080123c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801250:	b8 09 00 00 00       	mov    $0x9,%eax
  801255:	89 df                	mov    %ebx,%edi
  801257:	89 de                	mov    %ebx,%esi
  801259:	cd 30                	int    $0x30
	if(check && ret > 0)
  80125b:	85 c0                	test   %eax,%eax
  80125d:	7f 08                	jg     801267 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80125f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801262:	5b                   	pop    %ebx
  801263:	5e                   	pop    %esi
  801264:	5f                   	pop    %edi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	50                   	push   %eax
  80126b:	6a 09                	push   $0x9
  80126d:	68 44 19 80 00       	push   $0x801944
  801272:	6a 23                	push   $0x23
  801274:	68 61 19 80 00       	push   $0x801961
  801279:	e8 c3 f3 ff ff       	call   800641 <_panic>

0080127e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
	asm volatile("int %1\n"
  801284:	8b 55 08             	mov    0x8(%ebp),%edx
  801287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80128f:	be 00 00 00 00       	mov    $0x0,%esi
  801294:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801297:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012af:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012b7:	89 cb                	mov    %ecx,%ebx
  8012b9:	89 cf                	mov    %ecx,%edi
  8012bb:	89 ce                	mov    %ecx,%esi
  8012bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	7f 08                	jg     8012cb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	50                   	push   %eax
  8012cf:	6a 0c                	push   $0xc
  8012d1:	68 44 19 80 00       	push   $0x801944
  8012d6:	6a 23                	push   $0x23
  8012d8:	68 61 19 80 00       	push   $0x801961
  8012dd:	e8 5f f3 ff ff       	call   800641 <_panic>

008012e2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 04             	sub    $0x4,%esp
	int r;
	envid_t trap_env_id = sys_getenvid();
  8012e9:	e8 07 fe ff ff       	call   8010f5 <sys_getenvid>
  8012ee:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  8012f0:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8012f7:	74 22                	je     80131b <set_pgfault_handler+0x39>
		// LAB 4: Your code here.
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
		
		//panic("set_pgfault_handler not implemented");
	}
	if (sys_env_set_pgfault_upcall(trap_env_id, _pgfault_upcall)) {
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	68 44 13 80 00       	push   $0x801344
  801301:	53                   	push   %ebx
  801302:	e8 35 ff ff ff       	call   80123c <sys_env_set_pgfault_upcall>
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	75 22                	jne    801330 <set_pgfault_handler+0x4e>
		panic("set pgfault upcall failed!");
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    
		int alloc_ret = sys_page_alloc(trap_env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80131b:	83 ec 04             	sub    $0x4,%esp
  80131e:	6a 06                	push   $0x6
  801320:	68 00 f0 bf ee       	push   $0xeebff000
  801325:	50                   	push   %eax
  801326:	e8 08 fe ff ff       	call   801133 <sys_page_alloc>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	eb c9                	jmp    8012f9 <set_pgfault_handler+0x17>
		panic("set pgfault upcall failed!");
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	68 6f 19 80 00       	push   $0x80196f
  801338:	6a 25                	push   $0x25
  80133a:	68 8a 19 80 00       	push   $0x80198a
  80133f:	e8 fd f2 ff ff       	call   800641 <_panic>

00801344 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801344:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801345:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80134a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80134c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	lea 48(%esp), %eax
  80134f:	8d 44 24 30          	lea    0x30(%esp),%eax
	movl (%eax), %eax
  801353:	8b 00                	mov    (%eax),%eax
	lea 40(%esp), %ebx
  801355:	8d 5c 24 28          	lea    0x28(%esp),%ebx
	movl (%ebx), %ebx
  801359:	8b 1b                	mov    (%ebx),%ebx
	subl $4, %eax
  80135b:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  80135e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	add $8, %esp
  801360:	83 c4 08             	add    $0x8,%esp
	pop %edi
  801363:	5f                   	pop    %edi
	pop %esi
  801364:	5e                   	pop    %esi
	pop %ebp
  801365:	5d                   	pop    %ebp
	add $4, %esp
  801366:	83 c4 04             	add    $0x4,%esp
	pop %ebx
  801369:	5b                   	pop    %ebx
	pop %edx
  80136a:	5a                   	pop    %edx
	pop %ecx
  80136b:	59                   	pop    %ecx
	pop %eax
  80136c:	58                   	pop    %eax
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80136d:	83 c4 04             	add    $0x4,%esp
	popfl
  801370:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801371:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	sub $4, %esp
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	c3                   	ret    
  801376:	66 90                	xchg   %ax,%ax
  801378:	66 90                	xchg   %ax,%ax
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__udivdi3>:
  801380:	55                   	push   %ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	83 ec 1c             	sub    $0x1c,%esp
  801387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80138b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80138f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801393:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801397:	85 d2                	test   %edx,%edx
  801399:	75 35                	jne    8013d0 <__udivdi3+0x50>
  80139b:	39 f3                	cmp    %esi,%ebx
  80139d:	0f 87 bd 00 00 00    	ja     801460 <__udivdi3+0xe0>
  8013a3:	85 db                	test   %ebx,%ebx
  8013a5:	89 d9                	mov    %ebx,%ecx
  8013a7:	75 0b                	jne    8013b4 <__udivdi3+0x34>
  8013a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ae:	31 d2                	xor    %edx,%edx
  8013b0:	f7 f3                	div    %ebx
  8013b2:	89 c1                	mov    %eax,%ecx
  8013b4:	31 d2                	xor    %edx,%edx
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	f7 f1                	div    %ecx
  8013ba:	89 c6                	mov    %eax,%esi
  8013bc:	89 e8                	mov    %ebp,%eax
  8013be:	89 f7                	mov    %esi,%edi
  8013c0:	f7 f1                	div    %ecx
  8013c2:	89 fa                	mov    %edi,%edx
  8013c4:	83 c4 1c             	add    $0x1c,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	39 f2                	cmp    %esi,%edx
  8013d2:	77 7c                	ja     801450 <__udivdi3+0xd0>
  8013d4:	0f bd fa             	bsr    %edx,%edi
  8013d7:	83 f7 1f             	xor    $0x1f,%edi
  8013da:	0f 84 98 00 00 00    	je     801478 <__udivdi3+0xf8>
  8013e0:	89 f9                	mov    %edi,%ecx
  8013e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013e7:	29 f8                	sub    %edi,%eax
  8013e9:	d3 e2                	shl    %cl,%edx
  8013eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013ef:	89 c1                	mov    %eax,%ecx
  8013f1:	89 da                	mov    %ebx,%edx
  8013f3:	d3 ea                	shr    %cl,%edx
  8013f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013f9:	09 d1                	or     %edx,%ecx
  8013fb:	89 f2                	mov    %esi,%edx
  8013fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801401:	89 f9                	mov    %edi,%ecx
  801403:	d3 e3                	shl    %cl,%ebx
  801405:	89 c1                	mov    %eax,%ecx
  801407:	d3 ea                	shr    %cl,%edx
  801409:	89 f9                	mov    %edi,%ecx
  80140b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140f:	d3 e6                	shl    %cl,%esi
  801411:	89 eb                	mov    %ebp,%ebx
  801413:	89 c1                	mov    %eax,%ecx
  801415:	d3 eb                	shr    %cl,%ebx
  801417:	09 de                	or     %ebx,%esi
  801419:	89 f0                	mov    %esi,%eax
  80141b:	f7 74 24 08          	divl   0x8(%esp)
  80141f:	89 d6                	mov    %edx,%esi
  801421:	89 c3                	mov    %eax,%ebx
  801423:	f7 64 24 0c          	mull   0xc(%esp)
  801427:	39 d6                	cmp    %edx,%esi
  801429:	72 0c                	jb     801437 <__udivdi3+0xb7>
  80142b:	89 f9                	mov    %edi,%ecx
  80142d:	d3 e5                	shl    %cl,%ebp
  80142f:	39 c5                	cmp    %eax,%ebp
  801431:	73 5d                	jae    801490 <__udivdi3+0x110>
  801433:	39 d6                	cmp    %edx,%esi
  801435:	75 59                	jne    801490 <__udivdi3+0x110>
  801437:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80143a:	31 ff                	xor    %edi,%edi
  80143c:	89 fa                	mov    %edi,%edx
  80143e:	83 c4 1c             	add    $0x1c,%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    
  801446:	8d 76 00             	lea    0x0(%esi),%esi
  801449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801450:	31 ff                	xor    %edi,%edi
  801452:	31 c0                	xor    %eax,%eax
  801454:	89 fa                	mov    %edi,%edx
  801456:	83 c4 1c             	add    $0x1c,%esp
  801459:	5b                   	pop    %ebx
  80145a:	5e                   	pop    %esi
  80145b:	5f                   	pop    %edi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    
  80145e:	66 90                	xchg   %ax,%ax
  801460:	31 ff                	xor    %edi,%edi
  801462:	89 e8                	mov    %ebp,%eax
  801464:	89 f2                	mov    %esi,%edx
  801466:	f7 f3                	div    %ebx
  801468:	89 fa                	mov    %edi,%edx
  80146a:	83 c4 1c             	add    $0x1c,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    
  801472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801478:	39 f2                	cmp    %esi,%edx
  80147a:	72 06                	jb     801482 <__udivdi3+0x102>
  80147c:	31 c0                	xor    %eax,%eax
  80147e:	39 eb                	cmp    %ebp,%ebx
  801480:	77 d2                	ja     801454 <__udivdi3+0xd4>
  801482:	b8 01 00 00 00       	mov    $0x1,%eax
  801487:	eb cb                	jmp    801454 <__udivdi3+0xd4>
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	89 d8                	mov    %ebx,%eax
  801492:	31 ff                	xor    %edi,%edi
  801494:	eb be                	jmp    801454 <__udivdi3+0xd4>
  801496:	66 90                	xchg   %ax,%ax
  801498:	66 90                	xchg   %ax,%ax
  80149a:	66 90                	xchg   %ax,%ax
  80149c:	66 90                	xchg   %ax,%ax
  80149e:	66 90                	xchg   %ax,%ax

008014a0 <__umoddi3>:
  8014a0:	55                   	push   %ebp
  8014a1:	57                   	push   %edi
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 1c             	sub    $0x1c,%esp
  8014a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8014ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8014af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8014b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014b7:	85 ed                	test   %ebp,%ebp
  8014b9:	89 f0                	mov    %esi,%eax
  8014bb:	89 da                	mov    %ebx,%edx
  8014bd:	75 19                	jne    8014d8 <__umoddi3+0x38>
  8014bf:	39 df                	cmp    %ebx,%edi
  8014c1:	0f 86 b1 00 00 00    	jbe    801578 <__umoddi3+0xd8>
  8014c7:	f7 f7                	div    %edi
  8014c9:	89 d0                	mov    %edx,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	83 c4 1c             	add    $0x1c,%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	5f                   	pop    %edi
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    
  8014d5:	8d 76 00             	lea    0x0(%esi),%esi
  8014d8:	39 dd                	cmp    %ebx,%ebp
  8014da:	77 f1                	ja     8014cd <__umoddi3+0x2d>
  8014dc:	0f bd cd             	bsr    %ebp,%ecx
  8014df:	83 f1 1f             	xor    $0x1f,%ecx
  8014e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e6:	0f 84 b4 00 00 00    	je     8015a0 <__umoddi3+0x100>
  8014ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014f7:	29 c2                	sub    %eax,%edx
  8014f9:	89 c1                	mov    %eax,%ecx
  8014fb:	89 f8                	mov    %edi,%eax
  8014fd:	d3 e5                	shl    %cl,%ebp
  8014ff:	89 d1                	mov    %edx,%ecx
  801501:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801505:	d3 e8                	shr    %cl,%eax
  801507:	09 c5                	or     %eax,%ebp
  801509:	8b 44 24 04          	mov    0x4(%esp),%eax
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	d3 e7                	shl    %cl,%edi
  801511:	89 d1                	mov    %edx,%ecx
  801513:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801517:	89 df                	mov    %ebx,%edi
  801519:	d3 ef                	shr    %cl,%edi
  80151b:	89 c1                	mov    %eax,%ecx
  80151d:	89 f0                	mov    %esi,%eax
  80151f:	d3 e3                	shl    %cl,%ebx
  801521:	89 d1                	mov    %edx,%ecx
  801523:	89 fa                	mov    %edi,%edx
  801525:	d3 e8                	shr    %cl,%eax
  801527:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80152c:	09 d8                	or     %ebx,%eax
  80152e:	f7 f5                	div    %ebp
  801530:	d3 e6                	shl    %cl,%esi
  801532:	89 d1                	mov    %edx,%ecx
  801534:	f7 64 24 08          	mull   0x8(%esp)
  801538:	39 d1                	cmp    %edx,%ecx
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	89 d7                	mov    %edx,%edi
  80153e:	72 06                	jb     801546 <__umoddi3+0xa6>
  801540:	75 0e                	jne    801550 <__umoddi3+0xb0>
  801542:	39 c6                	cmp    %eax,%esi
  801544:	73 0a                	jae    801550 <__umoddi3+0xb0>
  801546:	2b 44 24 08          	sub    0x8(%esp),%eax
  80154a:	19 ea                	sbb    %ebp,%edx
  80154c:	89 d7                	mov    %edx,%edi
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	89 ca                	mov    %ecx,%edx
  801552:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801557:	29 de                	sub    %ebx,%esi
  801559:	19 fa                	sbb    %edi,%edx
  80155b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80155f:	89 d0                	mov    %edx,%eax
  801561:	d3 e0                	shl    %cl,%eax
  801563:	89 d9                	mov    %ebx,%ecx
  801565:	d3 ee                	shr    %cl,%esi
  801567:	d3 ea                	shr    %cl,%edx
  801569:	09 f0                	or     %esi,%eax
  80156b:	83 c4 1c             	add    $0x1c,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
  801573:	90                   	nop
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	85 ff                	test   %edi,%edi
  80157a:	89 f9                	mov    %edi,%ecx
  80157c:	75 0b                	jne    801589 <__umoddi3+0xe9>
  80157e:	b8 01 00 00 00       	mov    $0x1,%eax
  801583:	31 d2                	xor    %edx,%edx
  801585:	f7 f7                	div    %edi
  801587:	89 c1                	mov    %eax,%ecx
  801589:	89 d8                	mov    %ebx,%eax
  80158b:	31 d2                	xor    %edx,%edx
  80158d:	f7 f1                	div    %ecx
  80158f:	89 f0                	mov    %esi,%eax
  801591:	f7 f1                	div    %ecx
  801593:	e9 31 ff ff ff       	jmp    8014c9 <__umoddi3+0x29>
  801598:	90                   	nop
  801599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	39 dd                	cmp    %ebx,%ebp
  8015a2:	72 08                	jb     8015ac <__umoddi3+0x10c>
  8015a4:	39 f7                	cmp    %esi,%edi
  8015a6:	0f 87 21 ff ff ff    	ja     8014cd <__umoddi3+0x2d>
  8015ac:	89 da                	mov    %ebx,%edx
  8015ae:	89 f0                	mov    %esi,%eax
  8015b0:	29 f8                	sub    %edi,%eax
  8015b2:	19 ea                	sbb    %ebp,%edx
  8015b4:	e9 14 ff ff ff       	jmp    8014cd <__umoddi3+0x2d>
